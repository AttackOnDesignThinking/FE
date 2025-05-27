import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CustomIconWidget(
                iconName: 'person_search',
                color: AppTheme.textTertiary,
                size: 60,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No users nearby',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll keep looking and refresh automatically',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // This will trigger the RefreshIndicator's onRefresh callback
              // when the user pulls down the list
              Navigator.pushNamed(context, '/main-map-screen');
            },
            icon: const CustomIconWidget(
              iconName: 'map',
              color: Colors.white,
              size: 20,
            ),
            label: const Text('View Map'),
          ),
        ],
      ),
    );
  }
}