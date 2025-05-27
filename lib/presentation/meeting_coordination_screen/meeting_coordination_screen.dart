import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../core/services/supabase_service.dart';
import './widgets/map_interaction_widget.dart';
import './widgets/pin_placement_widget.dart';
import './widgets/timeout_dialog_widget.dart';
import './widgets/turn_indicator_widget.dart';

class MeetingCoordinationScreen extends StatefulWidget {
  const MeetingCoordinationScreen({super.key});

  @override
  State<MeetingCoordinationScreen> createState() => _MeetingCoordinationScreenState();
}

class _MeetingCoordinationScreenState extends State<MeetingCoordinationScreen> with TickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();
  // User data that will be populated from Supabase
  Map<String, dynamic> userData = {
    "currentUser": {
      "id": "00000000-0000-0000-0000-000000000001", // Hardcoded for demo
      "name": "You",
      "latitude": 40.7128,
      "longitude": -74.0060,
    },
    "otherUser": {
      "id": "00000000-0000-0000-0000-000000000002", // Will be replaced with actual other user
      "name": "Alex",
      "latitude": 40.7138,
      "longitude": -74.0055,
    },
  };

  // State variables
  bool isCurrentUserTurn = false; // Initially, the other user (recipient) places the pin first
  bool isPinPlaced = false;
  bool isOtherUserPinPlaced = false;
  bool isMeetingConfirmed = false;
  bool isTimeoutDialogVisible = false;
  String? activeMeetingId;
  
  // Pin locations
  Map<String, dynamic>? currentUserPin;
  Map<String, dynamic>? otherUserPin;
  
  // Animation controllers
  late AnimationController _pinAnimationController;
  late AnimationController _confirmationAnimationController;
  
  // Timeout timer
  DateTime? lastActivityTime;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _pinAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _confirmationAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    // Start tracking activity time for timeout
    lastActivityTime = DateTime.now();
    
    // Start timeout check timer
    _startTimeoutTimer();
    
    // Load meeting data from Supabase
    _loadMeetingData();
  }
  
  Future<void> _loadMeetingData() async {
    try {
      // In a real app, you would get the current meeting ID from navigation arguments
      // or from a state management solution. For this demo, we'll simulate a new meeting.
      
      // Get the most recent meeting for the current user
      final meeting = await _supabaseService.createMeeting({
        'user_a': userData["currentUser"]["id"],
        'user_b': userData["otherUser"]["id"],
        'status': 'coordinating'
      });
      
      activeMeetingId = meeting['id'];
      
      // In a real app, you would fetch the other user's profile here
      // For demo purposes, we'll use the hardcoded data
    } catch (e) {
      print('Failed to load meeting data: $e');
    }
  }
  
  @override
  void dispose() {
    _pinAnimationController.dispose();
    _confirmationAnimationController.dispose();
    super.dispose();
  }
  
  // Method to start the timeout timer
  void _startTimeoutTimer() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        final currentTime = DateTime.now();
        final difference = currentTime.difference(lastActivityTime!);
        
        // If inactive for 2 minutes (120 seconds), show timeout dialog
        if (difference.inSeconds >= 120 && !isTimeoutDialogVisible && !isMeetingConfirmed) {
          setState(() {
            isTimeoutDialogVisible = true;
          });
          _showTimeoutDialog();
        } else {
          // Continue checking if not timed out
          _startTimeoutTimer();
        }
      }
    });
  }
  
  // Method to handle pin placement
  void _handlePinPlacement(double latitude, double longitude) async {
    if (!isCurrentUserTurn && !isPinPlaced) {
      // Not user's turn yet
      _showNotYourTurnSnackBar();
      return;
    }
    
    if (isCurrentUserTurn && !isPinPlaced) {
      // Update activity time
      lastActivityTime = DateTime.now();
      
      // Provide haptic feedback
      HapticFeedback.mediumImpact();
      
      setState(() {
        // Place pin
        currentUserPin = {
          "latitude": latitude,
          "longitude": longitude,
        };
        isPinPlaced = true;
        
        // Animate pin placement
        _pinAnimationController.forward(from: 0.0);
      });
      
      // Update the meeting in Supabase
      if (activeMeetingId != null) {
        try {
          await _supabaseService.createMeeting({
            'id': activeMeetingId,
            'user_a_pin': {
              'latitude': latitude,
              'longitude': longitude
            }
          });
          
          // Simulate other user's response after a delay
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              _simulateOtherUserResponse();
            }
          });
        } catch (e) {
          print('Failed to update meeting with pin: $e');
        }
      }
    }
  }
  
  // Method to simulate other user's response (for demo purposes)
  void _simulateOtherUserResponse() async {
    // Update activity time
    lastActivityTime = DateTime.now();
    
    setState(() {
      if (!isOtherUserPinPlaced) {
        // First pin placement by other user
        otherUserPin = {
          "latitude": currentUserPin!["latitude"] + (Math.Random().nextDouble() * 0.001 - 0.0005),
          "longitude": currentUserPin!["longitude"] + (Math.Random().nextDouble() * 0.001 - 0.0005),
        };
        isOtherUserPinPlaced = true;
        
        // Check if pins are close enough to be considered the same location
        final distance = _calculateDistance(
          currentUserPin!["latitude"], 
          currentUserPin!["longitude"],
          otherUserPin!["latitude"], 
          otherUserPin!["longitude"]
        );
        
        if (distance < 0.0005) { // Approximately 50 meters
          // Both users selected the same location
          _handleMeetingConfirmation();
        } else {
          // Different locations, switch turns
          isCurrentUserTurn = true;
          isPinPlaced = false;
        }
      } else {
        // Second pin placement by other user (accepting user's suggestion)
        otherUserPin = {
          "latitude": currentUserPin!["latitude"],
          "longitude": currentUserPin!["longitude"],
        };
        
        // Both users selected the same location
        _handleMeetingConfirmation();
      }
    });
    
    // Update the meeting in Supabase with the other user's pin
    if (activeMeetingId != null) {
      try {
        await _supabaseService.createMeeting({
          'id': activeMeetingId,
          'user_b_pin': {
            'latitude': otherUserPin!["latitude"],
            'longitude': otherUserPin!["longitude"]
          }
        });
      } catch (e) {
        print('Failed to update meeting with other user pin: $e');
      }
    }
  }
  
  // Method to handle meeting confirmation
  void _handleMeetingConfirmation() async {
    setState(() {
      isMeetingConfirmed = true;
    });
    
    // Play confirmation animation
    _confirmationAnimationController.forward(from: 0.0);
    
    // Update the meeting status in Supabase
    if (activeMeetingId != null) {
      try {
        await _supabaseService.updateMeetingStatus(activeMeetingId!, 'confirmed');
        
        // Update the meeting point in Supabase (average of both pins or the agreed point)
        await _supabaseService.createMeeting({
          'id': activeMeetingId,
          'meeting_point': {
            'latitude': currentUserPin!["latitude"],
            'longitude': currentUserPin!["longitude"],
            'name': 'Meeting Point', // This would be a geocoded address in a real app
            'address': 'Generated Address' // This would be a geocoded address in a real app
          }
        });
        
        // Navigate to meeting confirmed screen after animation
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pushNamed(context, '/meeting-confirmed-screen');
          }
        });
      } catch (e) {
        print('Failed to confirm meeting: $e');
      }
    }
  }
  
  // Method to calculate distance between two coordinates (simplified)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // This is a simplified distance calculation for demo purposes
    // In a real app, you would use the Haversine formula or a geospatial library
    return Math.sqrt(Math.pow(lat2 - lat1, 2) + Math.pow(lon2 - lon1, 2));
  }
  
  // Method to show timeout dialog
  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TimeoutDialogWidget(
        onContinue: () {
          setState(() {
            isTimeoutDialogVisible = false;
            lastActivityTime = DateTime.now();
          });
          Navigator.pop(context);
          _startTimeoutTimer();
        },
        onCancel: () async {
          // Update meeting status to cancelled in Supabase
          if (activeMeetingId != null) {
            try {
              await _supabaseService.updateMeetingStatus(activeMeetingId!, 'cancelled');
            } catch (e) {
              print('Failed to cancel meeting: $e');
            }
          }
          
          Navigator.pop(context);
          Navigator.pushNamed(context, '/main-map-screen');
        },
      ),
    );
  }
  
  // Method to show not your turn snackbar
  void _showNotYourTurnSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "It's ${userData["otherUser"]["name"]}'s turn to place a pin",
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.textPrimary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Method to show exit confirmation dialog
  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Leave Coordination?',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to leave? Your meeting coordination progress will be lost.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Stay',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.secondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Update meeting status to cancelled in Supabase
              if (activeMeetingId != null) {
                try {
                  await _supabaseService.updateMeetingStatus(activeMeetingId!, 'cancelled');
                } catch (e) {
                  print('Failed to cancel meeting: $e');
                }
              }
              
              Navigator.pop(context);
              Navigator.pushNamed(context, '/main-map-screen');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showExitConfirmationDialog();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Meeting with ${userData["otherUser"]["name"]}',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          leading: IconButton(
            icon: const CustomIconWidget(
              iconName: 'close',
              color: AppTheme.textPrimary,
              size: 24,
            ),
            onPressed: _showExitConfirmationDialog,
          ),
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Turn indicator
              TurnIndicatorWidget(
                isCurrentUserTurn: isCurrentUserTurn,
                currentUserName: userData["currentUser"]["name"],
                otherUserName: userData["otherUser"]["name"],
                isPinPlaced: isPinPlaced,
                isOtherUserPinPlaced: isOtherUserPinPlaced,
                isMeetingConfirmed: isMeetingConfirmed,
              ),
              
              // Map with user locations and pins
              Expanded(
                child: MapInteractionWidget(
                  currentUserLocation: {
                    "latitude": userData["currentUser"]["latitude"],
                    "longitude": userData["currentUser"]["longitude"],
                  },
                  otherUserLocation: {
                    "latitude": userData["otherUser"]["latitude"],
                    "longitude": userData["otherUser"]["longitude"],
                  },
                  currentUserPin: currentUserPin,
                  otherUserPin: otherUserPin,
                  pinAnimationController: _pinAnimationController,
                  confirmationAnimationController: _confirmationAnimationController,
                  isMeetingConfirmed: isMeetingConfirmed,
                  onMapTap: _handlePinPlacement,
                ),
              ),
              
              // Pin placement instructions
              PinPlacementWidget(
                isCurrentUserTurn: isCurrentUserTurn,
                isPinPlaced: isPinPlaced,
                isOtherUserPinPlaced: isOtherUserPinPlaced,
                isMeetingConfirmed: isMeetingConfirmed,
                otherUserName: userData["otherUser"]["name"],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Math utility class for calculations
class Math {
  static double sqrt(double value) {
    return value.sqrt();
  }
  
  static double pow(double a, double b) {
    return a.pow(b);
  }
  
  static math.Random random = math.Random();
  
  static math.Random Random() {
    return random;
  }
}

// Extensions for math operations
extension MathExtensions on double {
  double sqrt() {
    return math.sqrt(this);
  }
  
  double pow(double exponent) {
    return math.pow(this, exponent).toDouble();
  }
}

// Import for math operations
extension RandomExtension on math.Random {
  double nextDouble() {
    return this.nextDouble();
  }
}