class ApiResponse<T> {
  const ApiResponse({required this.data, this.message});
  final T data;
  final String? message;
}

class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;
  bool get hasMore => currentPage < lastPage;
}

class PageQuery {
  const PageQuery({
    this.page = 1,
    this.perPage = 20,
    this.search,
    this.status,
    this.dateFrom,
    this.dateTo,
    this.sort,
    this.direction,
  });
  final int page;
  final int perPage;
  final String? search;
  final String? status;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? sort;
  final String? direction;

  Map<String, Object?> toQuery() => {
    'page': page,
    'per_page': perPage,
    if (search?.isNotEmpty ?? false) 'search': search,
    if (status?.isNotEmpty ?? false) 'status': status,
    if (dateFrom != null) 'date_from': dateFrom!.toUtc().toIso8601String(),
    if (dateTo != null) 'date_to': dateTo!.toUtc().toIso8601String(),
    if (sort?.isNotEmpty ?? false) 'sort': sort,
    if (direction?.isNotEmpty ?? false) 'direction': direction,
  };
}

class PaginationState<T> {
  const PaginationState({
    this.items = const [],
    this.currentPage = 0,
    this.lastPage = 1,
    this.isInitialLoading = false,
    this.isLoadingMore = false,
  });
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final bool isInitialLoading;
  final bool isLoadingMore;
  bool get hasMore => currentPage < lastPage;
}

class ApiErrorDto {
  const ApiErrorDto({
    required this.code,
    required this.message,
    this.fieldErrors = const {},
  });
  final String? code;
  final String message;
  final Map<String, List<String>> fieldErrors;

  factory ApiErrorDto.fromJson(Map<String, Object?> json) {
    final raw = json['error'] is Map
        ? (json['error'] as Map).cast<String, Object?>()
        : json;
    final fieldSource = raw['field_errors'] ?? raw['errors'];
    final fields = <String, List<String>>{};
    if (fieldSource is Map) {
      for (final entry in fieldSource.entries) {
        final value = entry.value;
        fields[entry.key.toString()] = value is List
            ? value.map((item) => item.toString()).toList()
            : [value.toString()];
      }
    }
    return ApiErrorDto(
      code: raw['code']?.toString(),
      message:
          raw['message']?.toString() ?? 'The request could not be completed.',
      fieldErrors: fields,
    );
  }
}
