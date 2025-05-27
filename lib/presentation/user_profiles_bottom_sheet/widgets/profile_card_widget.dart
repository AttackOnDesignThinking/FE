import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class ProfileCardWidget extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;

  const ProfileCardWidget({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primary.withAlpha(51),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: CustomImageWidget(
                    imageUrl: user["avatar"],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            user["name"],
                            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CustomIconWidget(
                                iconName: 'place',
                                color: AppTheme.locationPin,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${user["distance"]} km',
                                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                                  color: AppTheme.locationPin,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Hobbies as hashtags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (user["hobbies"] as List<String>).map((hobby) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getRandomColor(hobby).withAlpha(26),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '#$hobby',
                            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                              color: _getRandomColor(hobby),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getRandomColor(String seed) {
    final List<Color> colors = [
      AppTheme.primary,
      AppTheme.info,
      AppTheme.success,
      AppTheme.locationPin,
      AppTheme.warning,
    ];
    
    // Use a deterministic approach to assign colors based on the hobby name
    int hashCode = seed.hashCode;
    return colors[hashCode.abs() % colors.length];
  }
}