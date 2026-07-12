import '../../../../core/network/json_value.dart';
import '../../domain/entities/customer.dart';

abstract final class CustomerApiMapper {
  static Customer fromJson(Map<String, dynamic> json) {
    final createdAt = _date(
      JsonValue.string(json, const ['createdAt', 'created_at']),
    );
    return Customer(
      id: JsonValue.string(json, const ['id', 'uuid']),
      name: JsonValue.string(
        json,
        const ['name', 'companyOrPersonName', 'company_or_person_name'],
      ),
      phone: JsonValue.string(json, const ['mobile', 'phone']),
      address: JsonValue.string(json, const ['address']),
      totalSales: JsonValue.integer(
        json,
        const ['totalSales', 'total_sales'],
      ),
      totalPaid: JsonValue.integer(
        json,
        const ['totalPaid', 'total_paid'],
      ),
      currentDue: JsonValue.integer(
        json,
        const ['due', 'currentDue', 'current_due'],
      ),
      createdAt: createdAt,
      updatedAt: _date(
        JsonValue.string(json, const ['updatedAt', 'updated_at']),
        fallback: createdAt,
      ),
    );
  }

  static Map<String, dynamic> createInput(
    CreateCustomerInput input, {
    String? shopId,
  }) {
    return {
      if (shopId != null && shopId.isNotEmpty) 'shopId': shopId,
      'client_id': input.clientId,
      'name': input.name,
      'mobile': input.phone,
      'address': input.address,
      'openingDue': input.openingDue,
    };
  }

  static DateTime _date(String value, {DateTime? fallback}) {
    return DateTime.tryParse(value)?.toLocal() ?? fallback ?? DateTime.now();
  }
}
