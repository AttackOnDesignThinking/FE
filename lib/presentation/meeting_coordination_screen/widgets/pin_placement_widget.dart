import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class PinPlacementWidget extends StatelessWidget {
  final bool isCurrentUserTurn;
  final bool isPinPlaced;
  final bool isOtherUserPinPlaced;
  final bool isMeetingConfirmed;
  final String otherUserName;

  const PinPlacementWidget({
    super.key,
    required this.isCurrentUserTurn,
    required this.isPinPlaced,
    required this.isOtherUserPinPlaced,
    required this.isMeetingConfirmed,
    required this.otherUserName,
  });

  @override
  Widget build(BuildContext context) {
    // If meeting is confirmed, show success message
    if (isMeetingConfirmed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.success.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.success.withAlpha(77),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Meeting Location Confirmed!',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.success,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Redirecting to meeting details...',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.success),
              ),
            ),
          ],
        ),
      );
    }

    // If it's current user's turn and pin is not placed yet
    if (isCurrentUserTurn && !isPinPlaced) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primary.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primary.withAlpha(77),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomIconWidget(
                  iconName: 'touch_app',
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Turn',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tap on the map to suggest a meeting location',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // If waiting for other user's response
    if (isPinPlaced && !isOtherUserPinPlaced) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.info.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.info.withAlpha(77),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomIconWidget(
                  iconName: 'hourglass_empty',
                  color: AppTheme.info,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Waiting for Response',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$otherUserName is reviewing your suggested meeting location',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // If other user suggested a different location
    if (isOtherUserPinPlaced && !isCurrentUserTurn) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.warning.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.warning.withAlpha(77),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomIconWidget(
                  iconName: 'place',
                  color: AppTheme.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'New Suggestion',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$otherUserName suggested a different meeting location',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your turn will come next',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.textTertiary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Default state (waiting for other user's first pin)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.info.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.info.withAlpha(77),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CustomIconWidget(
                iconName: 'hourglass_empty',
                color: AppTheme.info,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Waiting for First Suggestion',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$otherUserName will place the first pin on the map',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}