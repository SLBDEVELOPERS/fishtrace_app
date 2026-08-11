import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/data/repositories.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/models/models.dart';
import '../../domain/entities/retailer_entities.dart';
import '../../domain/repositories/retailer_repository.dart';

enum InventoryCategory { all, fish, shellfish, other }

enum RetailAlertFilter { all, critical, info }

class RetailerController extends GetxController {
  RetailerController({
    required RetailerRepository repository,
    required AppController session,
  }) : _repository = repository,
       _session = session;

  final RetailerRepository _repository;
  final AppController _session;
  final _uuid = const Uuid();

  final inventory = <RetailProduct>[].obs;
  final alerts = <RetailAlertView>[].obs;
  final sales = <RetailSaleView>[].obs;
  final received = <ReceivedRetailBatch>[].obs;
  final selectedProduct = Rxn<RetailProduct>();
  final selectedBatch = Rxn<ReceivedRetailBatch>();
  final inventoryCategory = InventoryCategory.all.obs;
  final alertFilter = RetailAlertFilter.all.obs;
  final search = ''.obs;
  final loading = false.obs;
  final error = Rxn<AppException>();

  List<RetailProduct> get filteredInventory => inventory.where((product) {
    final query = search.value.trim().toLowerCase();
    final matchesQuery =
        query.isEmpty ||
        product.name.toLowerCase().contains(query) ||
        product.batchId.toLowerCase().contains(query);
    final matchesCategory = switch (inventoryCategory.value) {
      InventoryCategory.all => true,
      InventoryCategory.fish => product.category == 'Fish',
      InventoryCategory.shellfish => product.category == 'Shellfish',
      InventoryCategory.other =>
        product.category != 'Fish' && product.category != 'Shellfish',
    };
    return matchesQuery && matchesCategory;
  }).toList();

  List<RetailAlertView> get filteredAlerts => alerts.where((alert) {
    return switch (alertFilter.value) {
      RetailAlertFilter.all => true,
      RetailAlertFilter.critical => alert.severity == AlertSeverity.critical,
      RetailAlertFilter.info => alert.severity == AlertSeverity.info,
    };
  }).toList();

  double get totalStock =>
      inventory.fold(0, (total, item) => total + item.stockKg);
  double get totalSales => sales.fold(0, (total, item) => total + item.total);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final result = await Future.wait([
        _repository.getInventory(),
        _repository.getAlerts(),
        _repository.getSales(),
        _repository.getReceivedBatches(),
      ]);
      inventory.assignAll(result[0] as List<RetailProduct>);
      alerts.assignAll(result[1] as List<RetailAlertView>);
      sales.assignAll(result[2] as List<RetailSaleView>);
      received.assignAll(result[3] as List<ReceivedRetailBatch>);
      selectedProduct.value = inventory.firstOrNull;
      selectedBatch.value = received.firstOrNull;
    } on AppException catch (failure) {
      error.value = failure;
    } finally {
      loading.value = false;
    }
  }

  Future<ReceivedRetailBatch?> resolveIncomingBatch(String scannedValue) async {
    final cached = received.firstWhereOrNull(
      (item) => item.matchesScan(scannedValue),
    );
    if (cached != null) return cached;
    final resolved = await _repository.findIncomingBatch(scannedValue);
    if (resolved != null && received.every((item) => item.id != resolved.id)) {
      received.insert(0, resolved);
    }
    return resolved;
  }

  String? validateSale(int packageCount) {
    final product = selectedProduct.value;
    if (product == null) return 'Select a product.';
    if (packageCount < 1) return 'Enter at least one package.';
    if (packageCount > product.availablePackages) {
      return 'Only ${product.availablePackages} packages are available.';
    }
    return null;
  }

  Future<void> recordSale(
    int packageCount,
    double unitPrice,
    String reference,
  ) async {
    final selectedId = selectedProduct.value?.id;
    if (selectedId == null) throw StateError('Select a product.');
    inventory.assignAll(await _repository.getInventory());
    final product = inventory.firstWhereOrNull((item) => item.id == selectedId);
    selectedProduct.value = product;
    if (product == null) {
      throw StateError('This product is no longer available.');
    }
    final error = validateSale(packageCount);
    if (error != null) throw ArgumentError(error);
    await _session.queue(
      'Record retail sale',
      recordType: 'sale',
      payload: {
        'productId': product.id,
        'quantityPackages': packageCount,
        'unitPrice': unitPrice,
        'customerReference': reference,
      },
    );
    final updated = product.copyWith(
      stockKg: product.stockKg - packageCount * product.packageWeightKg,
      availablePackages: product.availablePackages - packageCount,
    );
    final index = inventory.indexWhere((item) => item.id == product.id);
    inventory[index] = updated;
    selectedProduct.value = updated;
    sales.insert(
      0,
      RetailSaleView(
        id: 'INV-${_uuid.v4().split('-').first.toUpperCase()}',
        product: product.name,
        quantityKg: packageCount * product.packageWeightKg,
        total: packageCount * product.packageWeightKg * unitPrice,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> adjustStock(int packageCount) async {
    final selectedId = selectedProduct.value?.id;
    if (selectedId == null) throw StateError('Select a product.');
    inventory.assignAll(await _repository.getInventory());
    final product = inventory.firstWhereOrNull((item) => item.id == selectedId);
    selectedProduct.value = product;
    if (product == null) {
      throw StateError('This product is no longer available.');
    }
    if (packageCount == 0) throw ArgumentError('Enter a non-zero adjustment.');
    if (packageCount < 0 && packageCount.abs() > product.availablePackages) {
      throw ArgumentError(
        'Only ${product.availablePackages} packages can be removed.',
      );
    }
    await _session.queue(
      'Adjust retail stock',
      recordType: 'stock',
      payload: {'productId': product.id, 'quantityPackages': packageCount},
    );
    final updated = product.copyWith(
      stockKg: product.stockKg + packageCount * product.packageWeightKg,
      availablePackages: product.availablePackages + packageCount,
    );
    final index = inventory.indexWhere((item) => item.id == product.id);
    inventory[index] = updated;
    selectedProduct.value = updated;
  }

  Future<void> quarantine(String batchId, {required String alertId}) async {
    await _session.queue(
      'Quarantine recalled batch',
      recordType: 'recall',
      payload: {
        'batchId': batchId,
        'alertId': alertId,
        'reason': 'Product quarantined after a recall alert.',
      },
    );
    for (var index = 0; index < inventory.length; index++) {
      if (inventory[index].batchId == batchId) {
        inventory[index] = inventory[index].copyWith(quarantined: true);
      }
    }
    final index = alerts.indexWhere((alert) => alert.id == alertId);
    if (index >= 0) {
      alerts[index] = alerts[index].copyWith(status: 'ACKNOWLEDGED');
    }
  }

  Future<void> resolveAlert(
    RetailAlertView alert, {
    required String note,
  }) async {
    final normalizedNote = note.trim();
    if (normalizedNote.length < 5) {
      throw ArgumentError(
        'Enter at least 5 characters for the resolution note.',
      );
    }
    await _session.queue(
      'Resolve retail alert',
      recordType: 'retail-alert-resolution',
      payload: {'alertId': alert.id, 'note': normalizedNote},
    );
    final index = alerts.indexWhere((item) => item.id == alert.id);
    if (index >= 0) {
      alerts[index] = alert.copyWith(status: 'RESOLVED');
    }
  }

  Future<void> queue(String label, String type, Map<String, Object?> payload) =>
      _session.queue(label, recordType: type, payload: payload);
}
