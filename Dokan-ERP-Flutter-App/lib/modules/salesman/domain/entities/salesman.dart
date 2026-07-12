class Salesman {
  const Salesman({
    required this.name,
    required this.branch,
    required this.sales,
    required this.target,
    required this.commission,
    required this.active,
    this.phone = '',
    this.email = '',
  });

  final String name;
  final String branch;
  final int sales;
  final int target;
  final int commission;
  final bool active;
  final String phone;
  final String email;
}
