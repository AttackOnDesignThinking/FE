import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback onRetry;

  const LocationPermissionDialog({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Location Permission Required',
        style: AppTheme.lightTheme.textTheme.titleLarge,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CustomIconWidget(
                iconName: 'location_on',
                color: AppTheme.primary,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Dolphins needs access to your location to find nearby users within 3km.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your location will only be used while the app is in use.',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Cancel',
            style: TextStyle(color: AppTheme.lightTheme.colorScheme.secondary),
          ),
        ),
        ElevatedButton(
          onPressed: onRetry,
          child: const Text('Grant Permission'),
        ),
      ],
    );
  }
}