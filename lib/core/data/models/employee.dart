// ignore_for_file: depend_on_referenced_packages

import 'package:meta/meta.dart';

enum Role {
  productDesigner('Product Designer'),
  flutterDeveloper('Flutter Developer'),
  qaTester('QA Tester'),
  productOwner('Product Owner');

  const Role(this.roleTitle);
  final String roleTitle;

  static Role? fromTitle(String? title) {
    if (title == null) return null;
    for (final role in Role.values) {
      if (role.roleTitle == title) {
        return role;
      }
    }
    return null;
  }
}

@immutable
class Employee {
  final int? internalId; // Sembast auto-increment integer key
  final String? id;
  final String? name;
  final Role? role;
  final DateTime? from;
  final DateTime? to;
  final bool deleted; // non-nullable bool, default is false

  const Employee({
    this.internalId,
    this.id,
    required this.name,
    required this.role,
    required this.from,
    this.to,
    this.deleted = false,
  });

  factory Employee.fromJson(Map<String, dynamic> json, int internalId) {
    return Employee(
      internalId: internalId,
      id: json['id'] as String?,
      name: json['name'] as String?,
      role: Role.fromTitle(json['roleTitle'] as String?),
      from:
          json['from'] != null
              ? DateTime.tryParse(json['from'] as String)
              : null,
      to: json['to'] != null ? DateTime.tryParse(json['to'] as String) : null,
      deleted: json['deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Don't include internalId
      'id': id,
      'name': name,
      'roleTitle': role?.roleTitle,
      'from': from?.toIso8601String(),
      'to': to?.toIso8601String(),
      'deleted': deleted,
    };
  }

  Employee copyWith({
    int? internalId,
    String? id,
    String? name,
    Role? role,
    DateTime? from,
    DateTime? to,
    bool? deleted,
  }) {
    return Employee(
      internalId: internalId ?? this.internalId,
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      from: from ?? this.from,
      to: to ?? this.to, // Use `?? this.to` to allow setting null explicitly
      deleted: deleted ?? this.deleted,
    );
  }
}
