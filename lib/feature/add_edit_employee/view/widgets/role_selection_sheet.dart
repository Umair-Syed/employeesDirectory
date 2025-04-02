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
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Select Role',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: Role.values.length,
              itemBuilder: (context, index) {
                final role = Role.values[index];
                return ListTile(
                  title: Text(role.roleTitle),
                  trailing:
                      selectedRole == role
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                  onTap: () {
                    onRoleSelected(role);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
