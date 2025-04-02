import 'package:employees_directory_syed_umair/core/utils/constants/assets.dart';
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(Assets.noRecords),
          const SizedBox(height: 16),
          Text(
            'No employee records found',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }
}
