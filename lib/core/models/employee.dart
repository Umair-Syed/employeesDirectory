import 'package:isar/isar.dart';

part 'employee.g.dart';

@collection
class Employee {
  Id id = Isar.autoIncrement;
  String? name;
  @Enumerated(EnumType.name)
  Role? role;
  DateTime? from;
  DateTime? to;
  bool? deleted;
}

enum Role {
  productDesigner('Product Designer'),
  flutterDeveloper('Flutter Developer'),
  qaTester('QA Tester'),
  productOwner('Product Owner');

  const Role(this.roleTitle);
  final String roleTitle;
}
