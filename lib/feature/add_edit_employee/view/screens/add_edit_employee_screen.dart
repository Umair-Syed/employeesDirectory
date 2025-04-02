import 'package:employees_directory_syed_umair/core/blocs/employee_bloc/employee_bloc.dart';
import 'package:employees_directory_syed_umair/core/data/models/employee.dart';
import 'package:employees_directory_syed_umair/feature/add_edit_employee/view/widgets/date_picker.dart';
import 'package:employees_directory_syed_umair/feature/add_edit_employee/view/widgets/role_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEditEmployeeView extends StatefulWidget {
  final Employee? employee;

  const AddEditEmployeeView({super.key, this.employee});

  @override
  State<AddEditEmployeeView> createState() => _AddEditEmployeeViewState();
}

class _AddEditEmployeeViewState extends State<AddEditEmployeeView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  Role? _selectedRole;
  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;

  bool get _isEditMode => widget.employee != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee?.name);
    _selectedRole = widget.employee?.role;
    _selectedFromDate = widget.employee?.from;
    _selectedToDate = widget.employee?.to;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _isEditMode ? 'Edit Employee Details' : 'Add Employee Details',
        ),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Delete Employee',
              onPressed: _deleteEmployee,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // MARK: - Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Employee name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // MARK: - Role
              InkWell(
                onTap: () => _showRoleBottomSheet(),
                child: FormField<Role>(
                  validator:
                      (value) =>
                          _selectedRole == null ? 'Please select a role' : null,
                  builder: (FormFieldState<Role> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Select role',
                        prefixIcon: const Icon(Icons.work_outline),
                        suffixIcon: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        border: const OutlineInputBorder(),
                        errorText: state.errorText,
                      ),
                      isEmpty: _selectedRole == null,
                      child: Text(_selectedRole?.roleTitle ?? ''),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // MARK: - Date Picker
              Row(
                children: [
                  Expanded(
                    child: DatePickerField(
                      label: 'From',
                      selectedDate: _selectedFromDate,
                      onDateSelected: (date) {
                        setState(() {
                          _selectedFromDate = date;
                          if (_selectedToDate != null &&
                              _selectedToDate!.isBefore(_selectedFromDate!)) {
                            _selectedToDate = null;
                          }
                        });
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.arrow_forward, color: Colors.blue),
                  ),
                  Expanded(
                    child: DatePickerField(
                      label: 'To',
                      selectedDate: _selectedToDate,
                      isToDate: true,
                      fromDate: _selectedFromDate,
                      onDateSelected: (date) {
                        setState(() {
                          _selectedToDate = date;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SaveCancelBottomBar(
        onSave: _saveForm,
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  // MARK: - Save
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedFromDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a start date.')),
        );
        return;
      }

      // Validation done, lets save the employee
      final name = _nameController.text;
      final role = _selectedRole!;
      final fromDate = _selectedFromDate!;
      final toDate = _selectedToDate; // Can be null

      final employeeToSave = Employee(
        internalId: widget.employee?.internalId, // if editing, keep the same id
        id:
            widget.employee?.id ??
            '${name.toLowerCase().replaceAll(' ', '-')}-${fromDate.year}',
        name: name,
        role: role,
        from: fromDate,
        to: toDate,
      );

      if (_isEditMode) {
        context.read<EmployeeBloc>().add(EmployeeUpdate(employeeToSave));
      } else {
        context.read<EmployeeBloc>().add(EmployeeAdd(employeeToSave));
      }

      Navigator.of(context).pop();
    }
  }

  // MARK: - Delete
  void _deleteEmployee() {
    if (!_isEditMode || widget.employee?.internalId == null) return;
    context.read<EmployeeBloc>().add(
      EmployeeDelete(widget.employee!.internalId!),
    );
    Navigator.of(context).pop('deleted');
  }

  // MARK: - Role Bottom Sheet
  void _showRoleBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return RoleSelectionBottomSheet(
          selectedRole: _selectedRole,
          onRoleSelected: (role) {
            setState(() {
              _selectedRole = role;
            });
          },
        );
      },
    );
  }
}

class SaveCancelBottomBar extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const SaveCancelBottomBar({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withAlpha(20),
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
