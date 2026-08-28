import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_support.dart';
import '../../../../core/network/offline_api_cache.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../domain/entities/retailer_entities.dart';
import '../../domain/repositories/retailer_repository.dart';
import '../dtos/retailer_dtos.dart';

class DioRetailerRepository implements RetailerRepository {
  DioRetailerRepository(this._api, {OfflineApiCache? cache}) : _cache = cache;
  final ApiClient _api;
  final OfflineApiCache? _cache;

  Future<Object?> _get(
    String path, {
    Map<String, Object?>? query,
    String? cacheKey,
  }) {
    Future<Object?> remote() => _api.get(path, query: query);
    final cache = _cache;
    return cache == null
        ? remote()
        : cache.readThrough(cacheKey ?? path, remote);
  }

  Future<List<T>> _list<T>(
    String path,
    T Function(Map<String, Object?>) parser,
  ) async => ApiData.list(
    await _get(path, cacheKey: 'retailer:$path'),
  ).map(parser).toList();

  Future<Map<String, Object?>> _reportData(
    String path, {
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final query = _reportQuery(dateFrom, dateTo);
    final payload = ApiData.map(
      await _get(
        path,
        query: query,
        cacheKey: 'retailer:report:$path:${query ?? const {}}',
      ),
    );
    return ApiData.map(payload['data']);
  }

  @override
  Future<List<RetailProduct>> getInventory() => _list(
    ApiEndpoints.inventory,
    (json) => RetailProductDto.fromJson(json).toDomain(),
  );
  @override
  Future<List<RetailAlertView>> getAlerts() => _list(
    ApiEndpoints.retailAlerts,
    (json) => RetailAlertDto.fromJson(json).toDomain(),
  );
  @override
  Future<List<RetailSaleView>> getSales() => _list(
    ApiEndpoints.sales,
    (json) => RetailSaleDto.fromJson(json).toDomain(),
  );
  @override
  Future<List<ReceivedRetailBatch>> getReceivedBatches() => _list(
    ApiEndpoints.retailIncomingLabels,
    (json) => ReceivedBatchDto.fromJson(json).toDomain(),
  );
  @override
  Future<ReceivedRetailBatch?> findIncomingBatch(String scannedValue) async {
    try {
      final response = await _get(
        ApiEndpoints.retailerResolveLabel,
        query: {'code': scannedValue},
        cacheKey: 'retailer:resolve:$scannedValue',
      );
      final envelope = ApiData.map(response);
      return ReceivedBatchDto.fromJson(
        ApiData.map(envelope['data'] ?? envelope),
      ).toDomain();
    } on NotFoundException {
      return null;
    }
  }

  @override
  Future<RetailReportSummary> getReportSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async => RetailReportSummaryDto.fromJson(
    await _reportData(
      ApiEndpoints.reportSummary,
      dateFrom: dateFrom,
      dateTo: dateTo,
    ),
  ).toDomain();

  @override
  Future<List<RetailSalesReportRow>> getSalesReport({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final data = await _reportData(
      ApiEndpoints.reportSales,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
    return ApiData.listValue(data, 'rows')
        .map((row) => RetailSalesReportRowDto.fromJson(_map(row)).toDomain())
        .toList(growable: false);
  }

  @override
  Future<List<RetailInventoryReportRow>> getInventoryReport({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final data = await _reportData(
      ApiEndpoints.reportInventory,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
    return ApiData.listValue(data, 'rows')
        .map(
          (row) => RetailInventoryReportRowDto.fromJson(_map(row)).toDomain(),
        )
        .toList(growable: false);
  }
}

Map<String, Object?> _map(Object? value) =>
    value is Map ? value.cast<String, Object?>() : const {};

Map<String, Object?>? _reportQuery(DateTime? dateFrom, DateTime? dateTo) {
  String format(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  final query = <String, Object?>{};
  if (dateFrom != null) query['date_from'] = format(dateFrom);
  if (dateTo != null) query['date_to'] = format(dateTo);
  return query.isEmpty ? null : query;
}
