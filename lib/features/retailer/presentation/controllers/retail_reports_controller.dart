import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../domain/entities/retailer_entities.dart';
import '../../domain/repositories/retailer_repository.dart';

class RetailReportsController extends GetxController {
  RetailReportsController({required RetailReportRepository repository})
    : _repository = repository;

  final RetailReportRepository _repository;

  final summary = Rxn<RetailReportSummary>();
  final sales = <RetailSalesReportRow>[].obs;
  final inventory = <RetailInventoryReportRow>[].obs;
  final selectedRange = Rxn<DateTimeRange>();
  final loading = false.obs;
  final error = Rxn<AppException>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({DateTimeRange? range}) async {
    if (range != null) selectedRange.value = range;
    final activeRange = selectedRange.value;
    loading.value = true;
    error.value = null;
    try {
      final result = await Future.wait([
        _repository.getReportSummary(
          dateFrom: activeRange?.start,
          dateTo: activeRange?.end,
        ),
        _repository.getSalesReport(
          dateFrom: activeRange?.start,
          dateTo: activeRange?.end,
        ),
        _repository.getInventoryReport(
          dateFrom: activeRange?.start,
          dateTo: activeRange?.end,
        ),
      ]);
      summary.value = result[0] as RetailReportSummary;
      sales.assignAll(result[1] as List<RetailSalesReportRow>);
      inventory.assignAll(result[2] as List<RetailInventoryReportRow>);
    } on AppException catch (failure) {
      error.value = failure;
    } finally {
      loading.value = false;
    }
  }
}
