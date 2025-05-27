import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MapLoadingIndicator extends StatelessWidget {
  const MapLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading map...',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Finding nearby users',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}