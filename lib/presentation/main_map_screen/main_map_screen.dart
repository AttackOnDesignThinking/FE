import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/services/naver_map_service.dart'; 

import '../../core/app_export.dart';
import '../../core/services/supabase_service.dart';
import './widgets/connection_error_widget.dart';
import './widgets/location_permission_dialog.dart';
import './widgets/map_loading_indicator.dart';
import './widgets/nearby_users_counter.dart';

class MainMapScreen extends StatefulWidget {
  const MainMapScreen({super.key});

  @override
  State<MainMapScreen> createState() => _MainMapScreenState();
}

class _MainMapScreenState extends State<MainMapScreen> {
  bool _isLoading = true;
  bool _hasLocationPermission = false;
  bool _hasConnectionError = false;
  int _nearbyUsersCount = 0;
  Timer? _locationUpdateTimer;
  Timer? _nearbyUsersUpdateTimer;
  final SupabaseService _supabaseService = SupabaseService();

  // User location data
  final Map<String, dynamic> _userLocation = {
    "latitude": 37.5547,   //서울역
    "longitude": 126.9706,
  };

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _nearbyUsersUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    // Simulate loading time
    await Future.delayed(const Duration(seconds: 2));
    
    // Check for location permission (mock implementation)
    bool hasPermission = await _checkLocationPermission();
    
    if (hasPermission) {
      setState(() {
        _hasLocationPermission = true;
        _isLoading = false;
      });
      
      // Start periodic updates
      _startLocationUpdates();
      _fetchNearbyUsers();
    } else {
      setState(() {
        _isLoading = false;
      });
      
      // Show permission dialog
      _showLocationPermissionDialog();
    }
  }

  Future<bool> _checkLocationPermission() async {
    // Mock implementation - in a real app, this would check actual device permissions
    return true;
  }

  void _startLocationUpdates() {
    // In a real app, this would use a location plugin to get real GPS updates
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      // Mock location update with slight variations to simulate movement
      setState(() {
        _userLocation["latitude"] = _userLocation["latitude"]! + (0.0001 * (DateTime.now().millisecond % 10 - 5));
        _userLocation["longitude"] = _userLocation["longitude"]! + (0.0001 * (DateTime.now().millisecond % 10 - 5));
      });
      
      try {
        // Get the current user ID (using a temporary mock user ID for now)
        // In a real app, this would be the authenticated user's ID
        String userId = '00000000-0000-0000-0000-000000000001';
        
        // Update the user's location in Supabase
        await _supabaseService.updateUserLocation(
          userId,
          _userLocation["latitude"]!,
          _userLocation["longitude"]!
        );
      } catch (e) {
        print('Failed to update location: $e');
      }
    });
  }

  void _fetchNearbyUsers() {
    // Fetch nearby users from Supabase
    _nearbyUsersUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final nearbyUsers = await _supabaseService.getNearbyUsers(
          _userLocation["latitude"]!,
          _userLocation["longitude"]!,
          3.0 // 3km radius
        );
        
        setState(() {
          _hasConnectionError = false;
          _nearbyUsersCount = nearbyUsers.length;
        });
      } catch (e) {
        setState(() {
          _hasConnectionError = true;
        });
        
        // Auto-retry after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            _fetchNearbyUsers();
          }
        });
      }
    });
    
    // Initial fetch
    _initialFetchNearbyUsers();
  }
  
  Future<void> _initialFetchNearbyUsers() async {
    try {
      final nearbyUsers = await _supabaseService.getNearbyUsers(
        _userLocation["latitude"]!,
        _userLocation["longitude"]!,
        3.0 // 3km radius
      );
      
      if (mounted) {
        setState(() {
          _nearbyUsersCount = nearbyUsers.length;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasConnectionError = true;
        });
      }
    }
  }

  void _showLocationPermissionDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationPermissionDialog(
        onRetry: () {
          Navigator.of(context).pop();
          _requestLocationPermission();
        },
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    // Simulate permission request
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock successful permission grant
    setState(() {
      _hasLocationPermission = true;
      _isLoading = false;
    });
    
    // Start periodic updates
    _startLocationUpdates();
    _fetchNearbyUsers();
  }

  void _showUserProfilesBottomSheet() {
    Navigator.pushNamed(context, '/user-profiles-bottom-sheet');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map view
          _buildMapView(),
          
          // Loading indicator
          if (_isLoading)
            const MapLoadingIndicator(),
          
          // Connection error notification
          if (_hasConnectionError)
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: ConnectionErrorWidget(
                onRetry: () {
                  setState(() {
                    _hasConnectionError = false;
                  });
                  _fetchNearbyUsers();
                },
              ),
            ),
          
          // Nearby users counter
          if (_hasLocationPermission && !_isLoading)
            Positioned(
              bottom: 32,
              right: 16,
              child: NearbyUsersCounter(
                count: _nearbyUsersCount,
                onTap: _showUserProfilesBottomSheet,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    if (!_hasLocationPermission || _isLoading) {
      return Container(
        color: AppTheme.surface,
      );
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(
        NaverMapService.generateMapHtml(
          clientId: '1u7j3pzwnv', // 여기에 네이버 API 콘솔에서 발급한 clientId 넣어
        ),
      );

    return SizedBox.expand(
      child: WebViewWidget(controller: controller),
    );

  }
}