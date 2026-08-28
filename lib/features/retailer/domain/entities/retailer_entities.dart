import '../../../../core/models/models.dart';
import '../../../../core/utils/display_identifier.dart';

class RetailProduct {
  const RetailProduct({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.category,
    required this.stockKg,
    required this.availablePackages,
    required this.packageWeightKg,
    this.expiry,
    required this.batchId,
    this.batchCode = '',
    this.unitPrice,
    this.lowStockThreshold,
    this.quarantined = false,
  });

  final String id;
  final String name;
  final String scientificName;
  final String category;
  final double stockKg;
  final int availablePackages;
  final double packageWeightKg;
  final DateTime? expiry;
  final String batchId;
  final String batchCode;
  final double? unitPrice;
  final double? lowStockThreshold;
  final bool quarantined;

  String get batchLabel =>
      DisplayIdentifier.resolve(id: batchId, code: batchCode, noun: 'Batch');

  bool get lowStock =>
      lowStockThreshold != null && stockKg <= lowStockThreshold!;

  RetailProduct copyWith({
    double? stockKg,
    int? availablePackages,
    bool? quarantined,
  }) => RetailProduct(
    id: id,
    name: name,
    scientificName: scientificName,
    category: category,
    stockKg: stockKg ?? this.stockKg,
    availablePackages: availablePackages ?? this.availablePackages,
    packageWeightKg: packageWeightKg,
    expiry: expiry,
    batchId: batchId,
    batchCode: batchCode,
    unitPrice: unitPrice,
    lowStockThreshold: lowStockThreshold,
    quarantined: quarantined ?? this.quarantined,
  );
}

class RetailAlertView {
  const RetailAlertView({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.severity,
    required this.timeLabel,
    this.status = 'OPEN',
    this.measuredValue,
    this.thresholdValue,
    this.lastDetectedAt,
    this.batchId,
    this.batchCode = '',
  });

  final String id;
  final String title;
  final String message;
  final AlertType type;
  final AlertSeverity severity;
  final String timeLabel;
  final String status;
  final double? measuredValue;
  final double? thresholdValue;
  final DateTime? lastDetectedAt;
  final String? batchId;
  final String batchCode;

  String? get batchLabel => batchId == null
      ? null
      : DisplayIdentifier.resolve(id: batchId!, code: batchCode, noun: 'Batch');

  RetailAlertView copyWith({String? status}) => RetailAlertView(
    id: id,
    title: title,
    message: message,
    type: type,
    severity: severity,
    timeLabel: timeLabel,
    status: status ?? this.status,
    measuredValue: measuredValue,
    thresholdValue: thresholdValue,
    lastDetectedAt: lastDetectedAt,
    batchId: batchId,
    batchCode: batchCode,
  );
}

class RetailSaleView {
  const RetailSaleView({
    required this.id,
    required this.product,
    required this.quantityKg,
    required this.total,
    required this.createdAt,
  });

  final String id;
  final String product;
  final double quantityKg;
  final double total;
  final DateTime createdAt;
}

class ReceivedRetailBatch {
  const ReceivedRetailBatch({
    required this.id,
    required this.supplier,
    required this.product,
    required this.netWeightKg,
    this.expiry,
    required this.quality,
    required this.temperatureHistory,
    required this.receivedAt,
    this.packageCount = 1,
    this.labelCode = '',
    this.traceUrl = '',
  });

  final String id;
  final String supplier;
  final String product;
  final double netWeightKg;
  final DateTime? expiry;
  final String quality;
  final List<double> temperatureHistory;
  final DateTime receivedAt;
  final int packageCount;
  final String labelCode;
  final String traceUrl;

  String get label =>
      DisplayIdentifier.resolve(id: id, code: labelCode, noun: 'Package');

  bool matchesScan(String value) {
    final normalized = value.trim().toLowerCase();
    final scannedUri = Uri.tryParse(normalized);
    final scannedToken = scannedUri?.pathSegments.isNotEmpty == true
        ? scannedUri!.pathSegments.last
        : normalized;
    final traceUri = Uri.tryParse(traceUrl);
    final traceToken = traceUri?.pathSegments.isNotEmpty == true
        ? traceUri!.pathSegments.last.toLowerCase()
        : '';
    return id.toLowerCase() == normalized ||
        id.toLowerCase() == scannedToken ||
        labelCode.toLowerCase() == normalized ||
        traceUrl.toLowerCase() == normalized ||
        (traceToken.isNotEmpty && traceToken == scannedToken);
  }
}

class RetailReportSummary {
  const RetailReportSummary({
    required this.catchWeightKg,
    required this.batchCount,
    required this.processingRecordCount,
    required this.transportTripCount,
    required this.openColdChainAlertCount,
    required this.availableInventoryPackages,
    required this.salesTotal,
    required this.generatedAt,
  });

  final double catchWeightKg;
  final int batchCount;
  final int processingRecordCount;
  final int transportTripCount;
  final int openColdChainAlertCount;
  final int availableInventoryPackages;
  final double salesTotal;
  final DateTime generatedAt;
}

class RetailSalesReportRow {
  const RetailSalesReportRow({
    required this.receiptNumber,
    required this.location,
    required this.status,
    required this.total,
    required this.soldAt,
  });

  final String receiptNumber;
  final String location;
  final String status;
  final double total;
  final DateTime soldAt;
}

class RetailInventoryReportRow {
  const RetailInventoryReportRow({
    required this.labelCode,
    required this.batchCode,
    required this.location,
    required this.status,
    required this.totalPackages,
    required this.availablePackages,
    required this.reservedPackages,
    required this.soldPackages,
    required this.expiresAt,
  });

  final String labelCode;
  final String batchCode;
  final String location;
  final String status;
  final int totalPackages;
  final int availablePackages;
  final int reservedPackages;
  final int soldPackages;
  final DateTime expiresAt;
}
