import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class TimeoutDialogWidget extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onCancel;

  const TimeoutDialogWidget({
    super.key,
    required this.onContinue,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const CustomIconWidget(
            iconName: 'access_time',
            color: AppTheme.warning,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Inactive Session',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.warning,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You haven\'t interacted with the map for a while.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Would you like to continue coordinating your meeting location?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Cancel Meeting',
            style: TextStyle(color: AppTheme.error),
          ),
        ),
        ElevatedButton(
          onPressed: onContinue,
          child: const Text('Continue'),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
    );
  }
}