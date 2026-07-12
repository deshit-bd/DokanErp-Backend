enum UserRole {
  owner,
  salesman;

  bool get isOwner => this == UserRole.owner;
  bool get isSalesman => this == UserRole.salesman;
}
