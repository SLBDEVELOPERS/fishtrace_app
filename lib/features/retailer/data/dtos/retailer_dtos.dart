import '../../../../core/models/models.dart';
import '../../../../core/network/api_support.dart';
import '../../domain/entities/retailer_entities.dart';

class RetailProductDto {
  const RetailProductDto(this.json);
  final Map<String, Object?> json;
  factory RetailProductDto.fromJson(Map<String, Object?> json) =>
      RetailProductDto(json);
  RetailProduct toDomain() {
    final batch = _map(json['batch']);
    final species = _map(batch['species']);
    final label = _map(json['label']);
    final availablePackages = ApiData.number(json, 'availablePackages');
    final packageWeight = ApiData.number(label, 'packageWeightKg');
    return RetailProduct(
      id: ApiData.string(json, 'id'),
      name: ApiData.string(
        species,
        'commonName',
        ApiData.string(batch, 'productType'),
      ),
      scientificName: ApiData.string(species, 'scientificName'),
      category: ApiData.string(batch, 'productType'),
      stockKg: availablePackages * packageWeight,
      availablePackages: availablePackages.toInt(),
      packageWeightKg: packageWeight,
      expiry: _nullableDate(json, 'expiresAt'),
      batchId: ApiData.string(json, 'fishBatchId'),
      batchCode: ApiData.string(batch, 'batchCode'),
      unitPrice: _nullableNumber(json, 'defaultUnitPrice'),
      lowStockThreshold: _nullableNumber(json, 'lowStockThresholdKg'),
      quarantined: ApiData.string(json, 'status') == 'RECALLED',
    );
  }
}

class RetailAlertDto {
  const RetailAlertDto(this.json);
  final Map<String, Object?> json;
  factory RetailAlertDto.fromJson(Map<String, Object?> json) =>
      RetailAlertDto(json);
  RetailAlertView toDomain() {
    final type = _alertType(ApiData.string(json, 'type'));
    final batch = _map(json['batch']);
    final measured = ApiData.value(json, 'measuredValue');
    final threshold = ApiData.value(json, 'thresholdValue');
    final lastDetectedAt = ApiData.date(json, 'lastDetectedAt');
    return RetailAlertView(
      id: ApiData.string(json, 'id'),
      title: _alertTitle(type),
      message: measured == null || threshold == null
          ? 'Batch ${ApiData.string(batch, 'batchCode')} requires attention.'
          : 'Measured $measured; configured threshold $threshold.',
      type: type,
      severity: _alertSeverity(ApiData.string(json, 'severity')),
      timeLabel: _timeLabel(lastDetectedAt),
      status: ApiData.string(json, 'status', 'OPEN'),
      measuredValue: _nullableNumber(json, 'measuredValue'),
      thresholdValue: _nullableNumber(json, 'thresholdValue'),
      lastDetectedAt: lastDetectedAt.millisecondsSinceEpoch == 0
          ? null
          : lastDetectedAt,
      batchId: ApiData.value(json, 'fishBatchId')?.toString(),
      batchCode: ApiData.string(batch, 'batchCode'),
    );
  }
}

class RetailSaleDto {
  const RetailSaleDto(this.json);
  final Map<String, Object?> json;
  factory RetailSaleDto.fromJson(Map<String, Object?> json) =>
      RetailSaleDto(json);
  RetailSaleView toDomain() {
    final items = ApiData.listValue(json, 'items');
    final quantity = items.fold<double>(
      0,
      (total, item) => total + ApiData.number(_map(item), 'quantity'),
    );
    final location = _map(json['location']);
    return RetailSaleView(
      id: ApiData.string(json, 'id'),
      product: ApiData.string(
        location,
        'name',
        ApiData.string(json, 'receiptNumber', 'Retail sale'),
      ),
      quantityKg: quantity,
      total: ApiData.number(json, 'total'),
      createdAt: ApiData.date(json, 'soldAt', ApiData.date(json, 'createdAt')),
    );
  }
}

class ReceivedBatchDto {
  const ReceivedBatchDto(this.json);
  final Map<String, Object?> json;
  factory ReceivedBatchDto.fromJson(Map<String, Object?> json) =>
      ReceivedBatchDto(json);
  ReceivedRetailBatch toDomain() {
    final batch = _map(json['batch']);
    final species = _map(batch['species']);
    final inventory = _map(ApiData.value(json, 'inventoryLot'));
    final organization = _map(batch['organization']);
    final isLabel = json.containsKey('label_code');
    return ReceivedRetailBatch(
      id: ApiData.string(json, 'id'),
      supplier: ApiData.string(
        organization,
        'name',
        ApiData.string(_map(json['location']), 'name', 'Verified supplier'),
      ),
      product: ApiData.string(
        species,
        'commonName',
        ApiData.string(batch, 'productType'),
      ),
      netWeightKg: isLabel
          ? ApiData.number(json, 'packageWeightKg') *
                ApiData.integer(json, 'packageCount')
          : ApiData.number(json, 'receivedWeightKg'),
      expiry: _nullableDate(inventory, 'expiresAt'),
      quality: ApiData.string(batch, 'qualityGrade', 'Not graded'),
      temperatureHistory: ApiData.listValue(
        json,
        'temperatureHistory',
      ).map((value) => (value as num).toDouble()).toList(),
      receivedAt: ApiData.date(json, isLabel ? 'createdAt' : 'receivedAt'),
      packageCount: ApiData.integer(
        json,
        isLabel ? 'packageCount' : 'receivedPackageCount',
        1,
      ),
      labelCode: ApiData.string(json, 'labelCode'),
      traceUrl: ApiData.string(json, 'traceUrl'),
    );
  }
}

class RetailReportSummaryDto {
  const RetailReportSummaryDto(this.json);
  final Map<String, Object?> json;

  factory RetailReportSummaryDto.fromJson(Map<String, Object?> json) =>
      RetailReportSummaryDto(json);

  RetailReportSummary toDomain() => RetailReportSummary(
    catchWeightKg: ApiData.number(json, 'catchWeightKg'),
    batchCount: ApiData.integer(json, 'batches'),
    processingRecordCount: ApiData.integer(json, 'processingRecords'),
    transportTripCount: ApiData.integer(json, 'transportTrips'),
    openColdChainAlertCount: ApiData.integer(json, 'openColdChainAlerts'),
    availableInventoryPackages: ApiData.integer(
      json,
      'availableInventoryPackages',
    ),
    salesTotal: ApiData.number(json, 'salesTotal'),
    generatedAt: ApiData.date(json, 'generatedAt'),
  );
}

class RetailSalesReportRowDto {
  const RetailSalesReportRowDto(this.json);
  final Map<String, Object?> json;

  factory RetailSalesReportRowDto.fromJson(Map<String, Object?> json) =>
      RetailSalesReportRowDto(json);

  RetailSalesReportRow toDomain() => RetailSalesReportRow(
    receiptNumber: ApiData.string(json, 'receiptNumber'),
    location: ApiData.string(json, 'location'),
    status: ApiData.string(json, 'status'),
    total: ApiData.number(json, 'total'),
    soldAt: ApiData.date(json, 'soldAt'),
  );
}

class RetailInventoryReportRowDto {
  const RetailInventoryReportRowDto(this.json);
  final Map<String, Object?> json;

  factory RetailInventoryReportRowDto.fromJson(Map<String, Object?> json) =>
      RetailInventoryReportRowDto(json);

  RetailInventoryReportRow toDomain() => RetailInventoryReportRow(
    labelCode: ApiData.string(json, 'labelCode'),
    batchCode: ApiData.string(json, 'batchCode'),
    location: ApiData.string(json, 'location'),
    status: ApiData.string(json, 'status'),
    totalPackages: ApiData.integer(json, 'totalPackages'),
    availablePackages: ApiData.integer(json, 'availablePackages'),
    reservedPackages: ApiData.integer(json, 'reservedPackages'),
    soldPackages: ApiData.integer(json, 'soldPackages'),
    expiresAt: ApiData.date(json, 'expiresAt'),
  );
}

Map<String, Object?> _map(Object? value) =>
    value is Map ? value.cast<String, Object?>() : const {};

double? _nullableNumber(Map<String, Object?> json, String key) {
  final value = ApiData.value(json, key);
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}

DateTime? _nullableDate(Map<String, Object?> json, String key) {
  final value = ApiData.value(json, key);
  return value == null ? null : DateTime.tryParse(value.toString())?.toUtc();
}

AlertType _alertType(String raw) {
  final normalized = raw.toUpperCase();
  if (normalized.contains('TEMP')) return AlertType.temperature;
  if (normalized.contains('BATTERY')) return AlertType.battery;
  if (normalized.contains('SENSOR')) return AlertType.sensorOffline;
  if (normalized.contains('DOOR')) return AlertType.doorOpened;
  if (normalized.contains('STOCK')) return AlertType.stock;
  if (normalized.contains('EXPIR')) return AlertType.expiry;
  if (normalized.contains('RECALL')) return AlertType.recall;
  return AlertType.system;
}

AlertSeverity _alertSeverity(String raw) => switch (raw.toUpperCase()) {
  'CRITICAL' || 'HIGH' => AlertSeverity.critical,
  'WARNING' || 'MEDIUM' => AlertSeverity.warning,
  _ => AlertSeverity.info,
};

String _alertTitle(AlertType type) => switch (type) {
  AlertType.temperature => 'Temperature Alert',
  AlertType.battery => 'Battery Alert',
  AlertType.sensorOffline => 'Sensor Offline',
  AlertType.doorOpened => 'Door Opened',
  AlertType.stock => 'Low Stock Alert',
  AlertType.expiry => 'Expiry Alert',
  AlertType.recall => 'Recall Alert',
  AlertType.system => 'System Alert',
};

String _timeLabel(DateTime value) {
  if (value.millisecondsSinceEpoch == 0) return 'Just now';
  final difference = DateTime.now().difference(value.toLocal());
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes.clamp(1, 59)}m ago';
  }
  if (difference.inHours < 24) return '${difference.inHours}h ago';
  return '${difference.inDays}d ago';
}
