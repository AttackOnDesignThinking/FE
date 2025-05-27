import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class TurnIndicatorWidget extends StatelessWidget {
  final bool isCurrentUserTurn;
  final String currentUserName;
  final String otherUserName;
  final bool isPinPlaced;
  final bool isOtherUserPinPlaced;
  final bool isMeetingConfirmed;

  const TurnIndicatorWidget({
    super.key,
    required this.isCurrentUserTurn,
    required this.currentUserName,
    required this.otherUserName,
    required this.isPinPlaced,
    required this.isOtherUserPinPlaced,
    required this.isMeetingConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the status message based on the current state
    String statusMessage;
    Color statusColor;
    IconData statusIcon;
    
    if (isMeetingConfirmed) {
      statusMessage = "Meeting location confirmed!";
      statusColor = AppTheme.success;
      statusIcon = Icons.check_circle;
    } else if (!isCurrentUserTurn && !isOtherUserPinPlaced) {
      statusMessage = "Waiting for $otherUserName to place a pin";
      statusColor = AppTheme.info;
      statusIcon = Icons.hourglass_empty;
    } else if (isCurrentUserTurn && !isPinPlaced) {
      statusMessage = "Your turn to place a pin";
      statusColor = AppTheme.primary;
      statusIcon = Icons.touch_app;
    } else if (isPinPlaced && !isOtherUserPinPlaced) {
      statusMessage = "Waiting for $otherUserName to respond";
      statusColor = AppTheme.info;
      statusIcon = Icons.hourglass_empty;
    } else if (isOtherUserPinPlaced && !isCurrentUserTurn) {
      statusMessage = "$otherUserName suggested a different location";
      statusColor = AppTheme.warning;
      statusIcon = Icons.place;
    } else {
      statusMessage = "Coordinating meeting location...";
      statusColor = AppTheme.textSecondary;
      statusIcon = Icons.sync;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withAlpha(77),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: _getIconName(statusIcon),
            color: statusColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusMessage,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!isMeetingConfirmed) ...[
                  const SizedBox(height: 4),
                  Text(
                    _getInstructionText(),
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isMeetingConfirmed) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCurrentUserTurn ? AppTheme.primary.withAlpha(51) : AppTheme.info.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: Text(
                isCurrentUserTurn ? "Y" : "A",
                style: TextStyle(
                  color: isCurrentUserTurn ? AppTheme.primary : AppTheme.info,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  // Helper method to get the instruction text based on the current state
  String _getInstructionText() {
    if (!isCurrentUserTurn && !isOtherUserPinPlaced) {
      return "$otherUserName is selecting a meeting point first";
    } else if (isCurrentUserTurn && !isPinPlaced) {
      return "Tap on the map to suggest a meeting location";
    } else if (isPinPlaced && !isOtherUserPinPlaced) {
      return "Your suggestion has been sent to $otherUserName";
    } else if (isOtherUserPinPlaced && !isCurrentUserTurn) {
      return "Review their suggestion or wait for your turn";
    } else {
      return "Coordinate until you both agree on a location";
    }
  }
  
  // Helper method to convert IconData to string name for CustomIconWidget
  String _getIconName(IconData icon) {
    if (icon == Icons.check_circle) return 'check_circle';
    if (icon == Icons.hourglass_empty) return 'hourglass_empty';
    if (icon == Icons.touch_app) return 'touch_app';
    if (icon == Icons.place) return 'place';
    return 'sync';
  }
}