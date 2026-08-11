import 'package:get/get.dart';

import '../data/repositories.dart';
import '../models/models.dart';

class SyncController extends GetxController {
  SyncController(this._session);
  final AppController _session;

  RxList<SyncQueueItem> get records => _session.syncItems;
  RxBool get isSyncing => _session.syncing;
  Rxn<DateTime> get lastSuccessfulSync => _session.lastSuccessfulSync;
  int get pendingCount =>
      records.where((item) => item.status == SyncStatus.pending).length;
  int get failedCount =>
      records.where((item) => item.status == SyncStatus.failed).length;

  Future<void> syncNow() => _session.syncNow();
  Future<void> retryFailed() => _session.retryFailed();
}
