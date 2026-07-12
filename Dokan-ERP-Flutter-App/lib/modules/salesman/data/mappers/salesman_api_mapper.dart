import '../../../../core/network/json_value.dart';
import '../../domain/entities/salesman.dart';

abstract final class SalesmanApiMapper {
  static Salesman fromJson(Map<String, dynamic> json) {
    final sales = JsonValue.integer(
      json,
      const ['sales', 'totalSales', 'total_sales', 'salesAmount'],
    );
    final target = JsonValue.integer(
      json,
      const ['target', 'salesTarget', 'sales_target'],
      fallback: 50000,
    );
    return Salesman(
      name: JsonValue.string(json, const ['name', 'fullName', 'full_name']),
      branch: JsonValue.string(
        json,
        const [
          'branch',
          'branchName',
          'branch_name',
          'storeName',
          'store_name'
        ],
        fallback: 'Main Branch',
      ),
      sales: sales,
      target: target <= 0 ? 50000 : target,
      commission: JsonValue.integer(
        json,
        const ['commission', 'commissionPoints', 'commission_points'],
      ),
      active: JsonValue.boolean(
        json,
        const ['active', 'isActive', 'is_active', 'status'],
        fallback: JsonValue.string(json, const ['status']).toLowerCase() !=
            'inactive',
      ),
      phone: JsonValue.string(json, const ['phone', 'mobile']),
      email: JsonValue.string(json, const ['email']),
    );
  }

  static Map<String, dynamic> createInput({
    required String name,
    required String phone,
    required String email,
    String password = '',
  }) {
    return {
      'name': name,
      'mobile': phone,
      'phone': phone,
      if (email.isNotEmpty) 'email': email,
      if (password.isNotEmpty) 'password': password,
      if (password.isNotEmpty) 'pin': password,
      'role': 'salesman',
      'active': true,
    };
  }
}
