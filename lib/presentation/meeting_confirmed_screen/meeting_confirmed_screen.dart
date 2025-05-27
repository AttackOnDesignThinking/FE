import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../core/services/supabase_service.dart';
import './widgets/arrival_info_widget.dart';
import './widgets/conversation_topic_card_widget.dart';
import './widgets/map_view_widget.dart';

class MeetingConfirmedScreen extends StatefulWidget {
  const MeetingConfirmedScreen({super.key});

  @override
  State<MeetingConfirmedScreen> createState() => _MeetingConfirmedScreenState();
}

class _MeetingConfirmedScreenState extends State<MeetingConfirmedScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  String? activeMeetingId;
  
  // Conversation topics based on shared hobbies from Supabase
  List<Map<String, dynamic>> conversationTopics = [];

  // Meeting location and arrival times from Supabase
  Map<String, dynamic> meetingData = {
    "meetingPoint": {
      "name": "Central Park Café",
      "address": "5th Ave & E 72nd St, New York",
      "latitude": 40.7736,
      "longitude": -73.9712,
    },
    "userA": {
      "name": "You",
      "arrivalTime": "5 min",
      "distance": "0.4 km",
      "latitude": 40.7746,
      "longitude": -73.9732,
    },
    "userB": {
      "name": "Alex",
      "arrivalTime": "8 min",
      "distance": "0.7 km",
      "latitude": 40.7716,
      "longitude": -73.9692,
    },
  };

  bool _showConfirmationDialog = false;
  
  @override
  void initState() {
    super.initState();
    _loadMeetingData();
  }
  
  Future<void> _loadMeetingData() async {
    try {
      // In a real app, you would get the active meeting ID from navigation parameters
      // or from a state management solution
      
      // For the purpose of this demo, we'll find the most recent confirmed meeting
      // between the current user and the other user
      // This would be replaced with a proper query in a real app
      
      // Load conversation topics based on shared interests
      // In a real application, you would extract shared interests from both user profiles
      List<String> sharedInterests = ['Photography', 'Hiking', 'Coffee'];
      
      final topics = await _supabaseService.getConversationTopics(sharedInterests);
      
      setState(() {
        conversationTopics = topics;
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to load meeting data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meeting Confirmed',
          style: AppTheme.lightTheme.textTheme.headlineMedium,
        ),
        leading: IconButton(
          icon: const CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.textPrimary,
            size: 24,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/main-map-screen');
          },
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Map view showing meeting point and user locations
                      MapViewWidget(meetingData: meetingData),
                      
                      // Arrival information
                      ArrivalInfoWidget(meetingData: meetingData),
                      
                      // Conversation topics section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Conversation Topics',
                              style: AppTheme.lightTheme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Based on your shared interests',
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            
                            // Conversation topic cards
                            ...conversationTopics.map((topic) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: ConversationTopicCardWidget(
                                topic: topic["topic"],
                                description: topic["description"],
                                color: _getColorFromString(topic["color"]),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // "We Met" button at the bottom
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showConfirmationDialog = true;
                      });
                      _showMeetingConfirmationDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'We Met',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
  
  Color _getColorFromString(String? colorStr) {
    if (colorStr == null) return AppTheme.primary;
    
    try {
      // Parse hex color string, assuming format is '#RRGGBB'
      String hexCode = colorStr.replaceFirst('#', '');
      if (hexCode.length == 6) {
        return Color(int.parse('FF$hexCode', radix: 16));
      }
    } catch (e) {
      // If parsing fails, return default color
    }
    
    return AppTheme.primary;
  }

  void _showMeetingConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Meeting',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to confirm that you met with ${meetingData["userB"]["name"]}?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _showConfirmationDialog = false;
                });
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.lightTheme.colorScheme.secondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (activeMeetingId != null) {
                  try {
                    // Update meeting status to completed
                    await _supabaseService.updateMeetingStatus(activeMeetingId!, 'completed');
                  } catch (e) {
                    print('Failed to complete meeting: $e');
                  }
                }
                
                Navigator.of(context).pop();
                setState(() {
                  _showConfirmationDialog = false;
                });
                // Navigate back to main map screen
                Navigator.pushNamed(context, '/main-map-screen');
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}