import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../core/services/supabase_service.dart';
import '../../theme/app_theme.dart';
import './widgets/empty_state_widget.dart';
import './widgets/profile_card_widget.dart';
import './widgets/skeleton_profile_card_widget.dart';

class UserProfilesBottomSheet extends StatefulWidget {
  const UserProfilesBottomSheet({super.key});

  @override
  State<UserProfilesBottomSheet> createState() => _UserProfilesBottomSheetState();
}

class _UserProfilesBottomSheetState extends State<UserProfilesBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  final SupabaseService _supabaseService = SupabaseService();
  
  // Data for nearby users
  final List<Map<String, dynamic>> _nearbyUsers = [];
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
    
    // Add scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200 && 
          !_isLoading && 
          _hasMoreData) {
        _loadMoreData();
      }
    });
    
    // Auto-refresh every 30 seconds
    _setupAutoRefresh();
  }
  
  void _setupAutoRefresh() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _refreshData();
        _setupAutoRefresh();
      }
    });
  }
  
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get nearby users from Supabase
      final nearbyUsers = await _supabaseService.getNearbyUsers(
        40.7128, // Hardcoded for demo, would normally come from user's current location
        -74.0060,
        3.0 // 3km radius
      );
      
      setState(() {
        _nearbyUsers.clear();
        _nearbyUsers.addAll(nearbyUsers);
        _isLoading = false;
        _currentPage = 1;
        _hasMoreData = nearbyUsers.length >= _itemsPerPage;
      });
    } catch (e) {
      print('Failed to load nearby users: $e');
      setState(() {
        _isLoading = false;
        _hasMoreData = false;
      });
    }
  }
  
  Future<void> _loadMoreData() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // In a real app with proper pagination from Supabase
      // This would use offset/limit or a cursor-based approach
      // For demo, we'll simulate reaching the end of data
      setState(() {
        _isLoading = false;
        _currentPage++;
        _hasMoreData = _currentPage < 3; // Only allow 2 pages for demo
      });
    } catch (e) {
      print('Failed to load more nearby users: $e');
      setState(() {
        _isLoading = false;
        _hasMoreData = false;
      });
    }
  }
  
  Future<void> _refreshData() async {
    await _loadInitialData();
  }
  
  void _showMeetingRequestDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Meeting Request',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Would you like to send a meeting request to ${user["name"]}?',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(user["avatar"]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user["name"],
                          style: AppTheme.lightTheme.textTheme.titleMedium,
                        ),
                        Text(
                          '${user["distance"]} km away',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (user["hobbies"] as List<dynamic>).map((hobby) {
                  return Chip(
                    label: Text(
                      '#$hobby',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.primary,
                      ),
                    ),
                    backgroundColor: AppTheme.primary.withAlpha(26),
                    padding: const EdgeInsets.all(4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
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
              onPressed: () async {
                Navigator.of(context).pop();
                
                try {
                  // Create a meeting request in Supabase
                  // Using hardcoded user IDs for demo purposes
                  await _supabaseService.createMeeting({
                    'user_a': '00000000-0000-0000-0000-000000000001', // Current user (hardcoded for demo)
                    'user_b': user['id'],
                    'status': 'requested'
                  });
                  
                  // Navigate to meeting coordination screen
                  Navigator.pushNamed(context, '/meeting-coordination-screen');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to send meeting request: $e'))
                  );
                }
              },
              child: const Text('Send Request'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4, // Half-expanded state
      minChildSize: 0.1, // Collapsed/peek state
      maxChildSize: 0.9, // Fully expanded state
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nearby Users',
                      style: AppTheme.lightTheme.textTheme.titleLarge,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(26),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_nearbyUsers.length} within 3km',
                        style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // User profiles list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  color: AppTheme.primary,
                  child: _isLoading && _nearbyUsers.isEmpty
                      ? _buildSkeletonList()
                      : _nearbyUsers.isEmpty
                          ? const EmptyStateWidget()
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _nearbyUsers.length + (_isLoading && _hasMoreData ? 3 : 0),
                              itemBuilder: (context, index) {
                                if (index < _nearbyUsers.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: ProfileCardWidget(
                                      user: _nearbyUsers[index],
                                      onTap: () => _showMeetingRequestDialog(_nearbyUsers[index]),
                                    ),
                                  );
                                } else {
                                  // Show skeleton loaders at the bottom while loading more
                                  return const Padding(
                                    padding: EdgeInsets.only(bottom: 12),
                                    child: SkeletonProfileCardWidget(),
                                  );
                                }
                              },
                            ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5, // Show 5 skeleton items initially
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: SkeletonProfileCardWidget(),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}