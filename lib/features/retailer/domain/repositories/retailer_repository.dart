import '../entities/retailer_entities.dart';

abstract interface class InventoryRepository {
  Future<List<RetailProduct>> getInventory();
}

abstract interface class RetailAlertRepository {
  Future<List<RetailAlertView>> getAlerts();
}

abstract interface class SaleRepository {
  Future<List<RetailSaleView>> getSales();
}

abstract interface class ReceiptRepository {
  Future<List<ReceivedRetailBatch>> getReceivedBatches();
  Future<ReceivedRetailBatch?> findIncomingBatch(String scannedValue);
}

abstract interface class RetailReportRepository {
  Future<RetailReportSummary> getReportSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<List<RetailSalesReportRow>> getSalesReport({
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<List<RetailInventoryReportRow>> getInventoryReport({
    DateTime? dateFrom,
    DateTime? dateTo,
  });
}

abstract interface class RetailerRepository
    implements
        InventoryRepository,
        RetailAlertRepository,
        SaleRepository,
        ReceiptRepository,
        RetailReportRepository {}
