class ApiResponse<T> {
  const ApiResponse({
    required this.data,
    required this.statusCode,
    this.message,
    this.headers = const {},
    this.requestId,
    this.pagination,
  });

  final T data;
  final int statusCode;
  final String? message;
  final Map<String, String> headers;
  final String? requestId;
  final ApiPagination? pagination;

  bool get isSuccessful => statusCode >= 200 && statusCode < 300;
}

class ApiPagination {
  const ApiPagination({
    required this.page,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  final int page;
  final int perPage;
  final int total;
  final int lastPage;

  factory ApiPagination.fromJson(Map<String, dynamic> json) {
    return ApiPagination(
      page: _asInt(json['page'] ?? json['current_page'], fallback: 1),
      perPage: _asInt(json['perPage'] ?? json['per_page'], fallback: 20),
      total: _asInt(json['total']),
      lastPage: _asInt(json['lastPage'] ?? json['last_page'], fallback: 1),
    );
  }
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}
