class Customer {
  const Customer({
    required this.id,
    required this.name,
    this.phone = '',
    this.address = '',
    this.totalSales = 0,
    this.totalPaid = 0,
    this.currentDue = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String phone;
  final String address;
  final int totalSales;
  final int totalPaid;
  final int currentDue;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class CreateCustomerInput {
  const CreateCustomerInput({
    required this.clientId,
    required this.name,
    required this.phone,
    required this.address,
    required this.openingDue,
  });

  final String clientId;
  final String name;
  final String phone;
  final String address;
  final int openingDue;
}
