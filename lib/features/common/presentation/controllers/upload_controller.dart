import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../domain/repositories/file_repository.dart';

class UploadController extends GetxController {
  UploadController(this._repository);
  final FileRepository _repository;

  final progress = 0.0.obs;
  final uploading = false.obs;
  final error = Rxn<AppException>();
  final uploaded = <UploadedFile>[].obs;
  CancelToken? _cancelToken;

  Future<UploadedFile?> upload(
    String path, {
    required String category,
    required String entityType,
    required String entityId,
  }) async {
    _cancelToken?.cancel('Replaced by a new upload.');
    final token = CancelToken();
    _cancelToken = token;
    uploading.value = true;
    progress.value = 0;
    error.value = null;
    try {
      final result = await _repository.upload(
        path,
        category: category,
        entityType: entityType,
        entityId: entityId,
        cancelToken: token,
        onProgress: (sent, total) {
          progress.value = total == 0 ? 0 : sent / total;
        },
      );
      uploaded.add(result);
      return result;
    } on AppException catch (failure) {
      error.value = failure;
      return null;
    } finally {
      if (identical(_cancelToken, token)) _cancelToken = null;
      uploading.value = false;
    }
  }

  void remove(UploadedFile file) => uploaded.remove(file);
  void cancel() => _cancelToken?.cancel('Cancelled by user.');

  @override
  void onClose() {
    cancel();
    super.onClose();
  }
}
