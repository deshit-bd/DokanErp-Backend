import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unwraps an object response', () {
    const response = ApiResponse(
      data: {
        'data': {'id': 7, 'name': 'Rice'},
      },
      statusCode: 200,
    );

    expect(ApiPayload.object(response), {'id': 7, 'name': 'Rice'});
  });

  test('queued mutation response lets repositories keep local entities', () {
    const response = ApiResponse(
      data: {'queued': true},
      statusCode: 202,
    );

    expect(ApiPayload.object(response), isEmpty);
  });

  test('unwraps list envelopes and ignores invalid entries', () {
    const response = ApiResponse(
      data: {
        'results': [
          {'id': 1},
          'invalid',
          {'id': 2},
        ],
      },
      statusCode: 200,
    );

    expect(ApiPayload.list(response), [
      {'id': 1},
      {'id': 2},
    ]);
  });

  test('unwraps named lists nested inside data', () {
    const response = ApiResponse(
      data: {
        'data': {
          'products': [
            {'id': 'P1'},
            {'id': 'P2'},
          ],
        },
      },
      statusCode: 200,
    );

    expect(ApiPayload.list(response), [
      {'id': 'P1'},
      {'id': 'P2'},
    ]);
  });

  test('parses snake_case pagination metadata', () {
    final pagination = ApiPagination.fromJson({
      'current_page': '2',
      'per_page': 25,
      'total': '60',
      'last_page': 3,
    });

    expect(pagination.page, 2);
    expect(pagination.perPage, 25);
    expect(pagination.total, 60);
    expect(pagination.lastPage, 3);
  });
}
