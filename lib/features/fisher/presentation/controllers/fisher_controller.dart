import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/data/repositories.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/network/api_models.dart';
import '../../domain/entities/fisher_entities.dart';
import '../../domain/repositories/fisher_repository.dart';

enum BoatFilter { all, active, inactive }

enum CatchFilter { all, verified, unverified }

class FisherController extends GetxController {
  FisherController({
    required FisherRepository repository,
    required AppController session,
  }) : _repository = repository,
       _session = session;

  final FisherRepository _repository;
  final AppController _session;
  final _uuid = const Uuid();

  final boats = <FisherBoat>[].obs;
  final catches = <FisherCatch>[].obs;
  final catchReferenceData = const FisherCatchReferenceData.empty().obs;
  final batches = <FisherBatchSummary>[].obs;
  final batchDetails = Rxn<FisherBatchDetails>();
  final batchDetailsLoading = false.obs;
  final batchDetailsError = Rxn<AppException>();
  final activeTrip = Rxn<ActiveFishingTrip>();
  final loading = false.obs;
  final boatFilter = BoatFilter.all.obs;
  final catchFilter = CatchFilter.all.obs;
  final boatSearch = ''.obs;
  final catchSearch = ''.obs;
  final error = Rxn<AppException>();
  final boatPagination = const PaginationState<FisherBoat>().obs;
  late final Worker _boatSearchWorker;

  List<FisherBoat> get filteredBoats => boats.where((boat) {
    final query = boatSearch.value.trim().toLowerCase();
    final matchesSearch =
        query.isEmpty ||
        boat.name.toLowerCase().contains(query) ||
        boat.registration.toLowerCase().contains(query);
    final matchesFilter = switch (boatFilter.value) {
      BoatFilter.all => true,
      BoatFilter.active => boat.active,
      BoatFilter.inactive => !boat.active,
    };
    return matchesSearch && matchesFilter;
  }).toList();

  List<FisherCatch> get filteredCatches => catches.where((item) {
    final query = catchSearch.value.trim().toLowerCase();
    final matchesSearch =
        query.isEmpty ||
        item.species.toLowerCase().contains(query) ||
        item.id.toLowerCase().contains(query);
    final matchesFilter = switch (catchFilter.value) {
      CatchFilter.all => true,
      CatchFilter.verified => item.verified,
      CatchFilter.unverified => !item.verified,
    };
    return matchesSearch && matchesFilter;
  }).toList();

  double get totalCatchKg =>
      catches.fold(0, (total, item) => total + item.weightKg);

  @override
  void onInit() {
    super.onInit();
    _boatSearchWorker = debounce<String>(
      boatSearch,
      (_) => _reloadBoats(),
      time: const Duration(milliseconds: 400),
    );
    load();
  }

  Future<void> _reloadBoats() async {
    try {
      boatPagination.value = const PaginationState<FisherBoat>(
        isInitialLoading: true,
      );
      final page = await _repository.getBoatsPage(
        PageQuery(search: boatSearch.value.trim()),
      );
      boats.assignAll(page.items);
      boatPagination.value = PaginationState(
        items: page.items,
        currentPage: page.currentPage,
        lastPage: page.lastPage,
      );
    } on AppException catch (failure) {
      error.value = failure;
      boatPagination.value = const PaginationState<FisherBoat>();
    }
  }

  Future<void> loadMoreBoats() async {
    final state = boatPagination.value;
    if (!state.hasMore || state.isLoadingMore) return;
    boatPagination.value = PaginationState(
      items: state.items,
      currentPage: state.currentPage,
      lastPage: state.lastPage,
      isLoadingMore: true,
    );
    try {
      final page = await _repository.getBoatsPage(
        PageQuery(page: state.currentPage + 1, search: boatSearch.value.trim()),
      );
      boats.addAll(page.items);
      boatPagination.value = PaginationState(
        items: List.unmodifiable(boats),
        currentPage: page.currentPage,
        lastPage: page.lastPage,
      );
    } on AppException catch (failure) {
      error.value = failure;
      boatPagination.value = PaginationState(
        items: state.items,
        currentPage: state.currentPage,
        lastPage: state.lastPage,
      );
    }
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final results = await Future.wait([
        _repository.getBoats(),
        _repository.getCatches(),
        _repository.getBatches(),
        _repository.getActiveTrip(),
        _repository.getCatchReferenceData(),
      ]);
      boats.assignAll(results[0] as List<FisherBoat>);
      catches.assignAll(results[1] as List<FisherCatch>);
      batches.assignAll(results[2] as List<FisherBatchSummary>);
      activeTrip.value = results[3] as ActiveFishingTrip?;
      catchReferenceData.value = results[4] as FisherCatchReferenceData;
    } on AppException catch (failure) {
      error.value = failure;
    } finally {
      loading.value = false;
    }
  }

  Future<void> saveBoat(FisherBoat boat) async {
    final saved = await _repository.saveBoat(boat);
    final index = boats.indexWhere((item) => item.id == saved.id);
    if (index >= 0) {
      boats[index] = saved;
    } else {
      boats.add(saved);
    }
  }

  Future<void> addCatch(FisherCatch catchRecord) async {
    catches.insert(0, catchRecord);
    if (_repository case final FisherDraftStore store) {
      await store.saveCatchDraft(
        catchRecord,
        tripId: activeTrip.value?.id ?? 'TRIP-LOCAL',
      );
    }
  }

  Future<void> addBatch(FisherBatchSummary batch) async {
    batches.insert(0, batch);
    if (_repository case final FisherDraftStore store) {
      await store.saveBatchDraft(batch);
    }
  }

  Future<void> loadBatchDetails(String id) async {
    batchDetails.value = null;
    batchDetailsError.value = null;
    if (id.startsWith('LOCAL-') || id.startsWith('BATCH-')) return;
    batchDetailsLoading.value = true;
    try {
      batchDetails.value = await _repository.getBatchDetails(id);
    } on AppException catch (failure) {
      batchDetailsError.value = failure;
    } finally {
      batchDetailsLoading.value = false;
    }
  }

  Future<void> startTrip(ActiveFishingTrip trip) async {
    activeTrip.value = trip;
    if (_repository case final FisherDraftStore store) {
      await store.saveTripDraft(trip);
    }
  }

  Future<void> completeActiveTrip() async {
    final current = activeTrip.value;
    if (current == null) return;
    final completed = ActiveFishingTrip(
      id: current.id,
      boatId: current.boatId,
      boatName: current.boatName,
      startedAt: current.startedAt,
      fishingArea: current.fishingArea,
      crew: current.crew,
      catchKg: current.catchKg,
      batchCount: current.batchCount,
      status: TripStatus.completed,
    );
    activeTrip.value = null;
    if (_repository case final FisherDraftStore store) {
      await store.saveTripDraft(completed);
    }
  }

  String nextLocalId(String prefix) =>
      '$prefix-${_uuid.v4().split('-').first.toUpperCase()}';

  Future<void> queueOperation(
    String label,
    String recordType,
    Map<String, Object?> payload,
  ) => _session.queue(label, recordType: recordType, payload: payload);

  @override
  void onClose() {
    _boatSearchWorker.dispose();
    super.onClose();
  }
}
