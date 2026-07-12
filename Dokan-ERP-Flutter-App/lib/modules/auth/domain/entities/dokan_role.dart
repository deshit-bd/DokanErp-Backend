enum DokanRole {
  owner,
  salesman,
}

extension DokanRoleIndexX on DokanRole {
  int get index => switch (this) {
        DokanRole.owner => 0,
        DokanRole.salesman => 1,
      };

  String get label => switch (this) {
        DokanRole.owner => 'Owner',
        DokanRole.salesman => 'Salesman',
      };
}

extension DokanRoleParsingX on int {
  DokanRole toDokanRole() => this == 1 ? DokanRole.salesman : DokanRole.owner;
}
