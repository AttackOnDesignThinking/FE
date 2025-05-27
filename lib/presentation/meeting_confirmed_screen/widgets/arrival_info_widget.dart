import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class ArrivalInfoWidget extends StatelessWidget {
  final Map<String, dynamic> meetingData;

  const ArrivalInfoWidget({
    super.key,
    required this.meetingData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meeting point info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.locationPin.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const CustomIconWidget(
                  iconName: 'place',
                  color: AppTheme.locationPin,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meetingData["meetingPoint"]["name"],
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meetingData["meetingPoint"]["address"],
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Divider(height: 24),
          
          // Arrival times
          Row(
            children: [
              // Your arrival info
              Expanded(
                child: _buildArrivalInfo(
                  name: meetingData["userA"]["name"],
                  time: meetingData["userA"]["arrivalTime"],
                  distance: meetingData["userA"]["distance"],
                  color: AppTheme.primary,
                ),
              ),
              
              Container(
                height: 40,
                width: 1,
                color: AppTheme.border,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              
              // Other user's arrival info
              Expanded(
                child: _buildArrivalInfo(
                  name: meetingData["userB"]["name"],
                  time: meetingData["userB"]["arrivalTime"],
                  distance: meetingData["userB"]["distance"],
                  color: AppTheme.info,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Countdown timer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomIconWidget(
                  iconName: 'access_time',
                  color: AppTheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Meeting in approximately ${meetingData["userB"]["arrivalTime"]}',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrivalInfo({
    required String name,
    required String time,
    required String distance,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.substring(0, 1),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: AppTheme.lightTheme.textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const CustomIconWidget(
              iconName: 'directions_walk',
              color: AppTheme.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              time,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '($distance)',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}