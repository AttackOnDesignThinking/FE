import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class MapInteractionWidget extends StatelessWidget {
  final Map<String, dynamic> currentUserLocation;
  final Map<String, dynamic> otherUserLocation;
  final Map<String, dynamic>? currentUserPin;
  final Map<String, dynamic>? otherUserPin;
  final AnimationController pinAnimationController;
  final AnimationController confirmationAnimationController;
  final bool isMeetingConfirmed;
  final Function(double latitude, double longitude) onMapTap;

  const MapInteractionWidget({
    super.key,
    required this.currentUserLocation,
    required this.otherUserLocation,
    this.currentUserPin,
    this.otherUserPin,
    required this.pinAnimationController,
    required this.confirmationAnimationController,
    required this.isMeetingConfirmed,
    required this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    // Create animations for pin placement and confirmation
    final pinScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: pinAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    
    final confirmationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: confirmationAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    return GestureDetector(
      onTapUp: (details) {
        // Convert tap position to map coordinates (simplified for demo)
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        
        // Map the tap position to latitude and longitude (simplified)
        // In a real app, you would use proper map projection calculations
        final width = box.size.width;
        final height = box.size.height;
        
        // Center of the map (simplified)
        final centerLat = (currentUserLocation["latitude"] + otherUserLocation["latitude"]) / 2;
        final centerLng = (currentUserLocation["longitude"] + otherUserLocation["longitude"]) / 2;
        
        // Calculate latitude and longitude based on tap position
        // This is a simplified calculation for demo purposes
        final latitude = centerLat + (localPosition.dy - height / 2) / height * 0.01;
        final longitude = centerLng + (localPosition.dx - width / 2) / width * 0.01;
        
        onMapTap(latitude, longitude);
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Map background
              CustomImageWidget(
                imageUrl: "https://images.unsplash.com/photo-1569336415962-a4bd9f69c07a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2069&q=80",
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              
              // Current user location marker
              Positioned(
                left: MediaQuery.of(context).size.width * 0.4,
                top: MediaQuery.of(context).size.height * 0.3,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowLight,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Other user location marker
              Positioned(
                left: MediaQuery.of(context).size.width * 0.45,
                top: MediaQuery.of(context).size.height * 0.28,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.info,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowLight,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Current user pin (if placed)
              if (currentUserPin != null)
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.42,
                  top: MediaQuery.of(context).size.height * 0.25,
                  child: ScaleTransition(
                    scale: pinScaleAnimation,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.shadowLight,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const CustomIconWidget(
                            iconName: 'place',
                            color: AppTheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.shadowLight,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Your suggestion',
                            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Other user pin (if placed)
              if (otherUserPin != null && !isMeetingConfirmed)
                Positioned(
                  right: MediaQuery.of(context).size.width * 0.35,
                  top: MediaQuery.of(context).size.height * 0.35,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.shadowLight,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const CustomIconWidget(
                          iconName: 'place',
                          color: AppTheme.info,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.shadowLight,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Their suggestion',
                          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Confirmed meeting point (when both agree)
              if (isMeetingConfirmed)
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.42,
                  top: MediaQuery.of(context).size.height * 0.25,
                  child: AnimatedBuilder(
                    animation: confirmationAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + confirmationAnimation.value * 0.3,
                        child: Opacity(
                          opacity: confirmationAnimation.value,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.shadowLight,
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const CustomIconWidget(
                                  iconName: 'check_circle',
                                  color: AppTheme.success,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.shadowLight,
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Meeting Point Confirmed!',
                                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              
              // Map attribution
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(204),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Map data',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}