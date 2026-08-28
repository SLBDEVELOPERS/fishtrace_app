import 'package:fishtrace/core/database/fishtrace_database.dart';
import 'package:fishtrace/core/errors/app_exceptions.dart';
import 'package:fishtrace/core/network/offline_api_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FishTraceDatabase database;
  var offline = false;
  var userId = 'user-1';

  setUp(() {
    database = FishTraceDatabase.memory();
    offline = false;
    userId = 'user-1';
  });

  tearDown(() => database.close());

  OfflineApiCache cache() => OfflineApiCache(
    database: database,
    isOffline: () => offline,
    userScope: () => userId,
  );

  test(
    'serves a successful API response after the device goes offline',
    () async {
      var remoteCalls = 0;
      final online = await cache().readThrough('processor:incoming', () async {
        remoteCalls++;
        return {
          'data': [
            {'id': 'batch-1'},
          ],
        };
      });

      offline = true;
      final cached = await cache().readThrough('processor:incoming', () async {
        remoteCalls++;
        return const {};
      });

      expect(cached, online);
      expect(remoteCalls, 1);
    },
  );

  test('does not expose one user cache to another user', () async {
    await cache().readThrough(
      'retailer:inventory',
      () async => {
        'data': [
          {'id': 'lot-1'},
        ],
      },
    );

    offline = true;
    userId = 'user-2';

    await expectLater(
      cache().readThrough('retailer:inventory', () async => const {}),
      throwsA(isA<NetworkException>()),
    );
  });

  test('uses cached data when a connected network request fails', () async {
    await cache().readThrough(
      'transporter:trips',
      () async => {
        'data': [
          {'id': 'trip-1'},
        ],
      },
    );

    final cached = await cache().readThrough(
      'transporter:trips',
      () => Future.error(const NetworkException()),
    );

    expect(cached, {
      'data': [
        {'id': 'trip-1'},
      ],
    });
  });
}
