import 'package:employees_directory_syed_umair/core/data/models/employee.dart';
import 'package:flutter/material.dart';

class RoleSelectionBottomSheet extends StatelessWidget {
  final Role? selectedRole;
  final Function(Role) onRoleSelected;

  const RoleSelectionBottomSheet({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: Role.values.length,
              separatorBuilder:
                  (context, index) => Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outline.withAlpha(40),
                  ),
              itemBuilder: (context, index) {
                final role = Role.values[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
                  title: Center(
                    child: Text(
                      role.roleTitle,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  onTap: () {
                    onRoleSelected(role);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
