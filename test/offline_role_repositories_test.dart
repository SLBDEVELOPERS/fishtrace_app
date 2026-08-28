import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fishtrace/core/database/fishtrace_database.dart';
import 'package:fishtrace/core/network/api_client.dart';
import 'package:fishtrace/core/network/error_mapper.dart';
import 'package:fishtrace/core/network/offline_api_cache.dart';
import 'package:fishtrace/features/processor/data/repositories/dio_processor_repository.dart';
import 'package:fishtrace/features/retailer/data/repositories/dio_retailer_repository.dart';
import 'package:fishtrace/features/transporter/data/repositories/dio_transporter_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'all operational role directories use the persistent offline cache',
    () async {
      final database = FishTraceDatabase.memory();
      addTearDown(database.close);
      var offline = false;
      final cache = OfflineApiCache(
        database: database,
        isOffline: () => offline,
        userScope: () => 'user-1',
      );
      final adapter = _EmptyDirectoryAdapter();
      final api = ApiClient(
        Dio()..httpClientAdapter = adapter,
        const ErrorMapper(),
      );
      final processor = DioProcessorRepository(api, cache: cache);
      final transporter = DioTransporterRepository(api, cache: cache);
      final retailer = DioRetailerRepository(api, cache: cache);

      expect(await processor.getIncomingBatches(), isEmpty);
      expect(await transporter.getTrips(), isEmpty);
      expect(await retailer.getInventory(), isEmpty);
      expect(adapter.requestCount, 3);

      offline = true;
      expect(await processor.getIncomingBatches(), isEmpty);
      expect(await transporter.getTrips(), isEmpty);
      expect(await retailer.getInventory(), isEmpty);
      expect(adapter.requestCount, 3);
    },
  );
}

class _EmptyDirectoryAdapter implements HttpClientAdapter {
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    return ResponseBody.fromString(
      jsonEncode({'data': []}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
