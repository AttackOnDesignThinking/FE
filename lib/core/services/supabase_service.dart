import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient _client;
  bool _isInitialized = false;
  final Future<void> _initFuture;

  // Singleton pattern
  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal() : _initFuture = _initializeSupabase();

  // Internal initialization logic
  static Future<void> _initializeSupabase() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    _instance._client = Supabase.instance.client;
    _instance._isInitialized = true;
  }

  // Client getter (async)
  Future<SupabaseClient> get client async {
    if (!_isInitialized) {
      await _initFuture;
    }
    return _client;
  }

  // User location methods
  Future<void> updateUserLocation(String userId, double latitude, double longitude) async {
    final client = await this.client;
    await client.from('user_locations').upsert({
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'updated_at': DateTime.now().toIso8601String()
    });
  }

  // Nearby users methods
  Future<List<Map<String, dynamic>>> getNearbyUsers(double latitude, double longitude, double radiusKm) async {
    final client = await this.client;
    final response = await client.rpc('get_nearby_users', params: {
      'user_lat': latitude,
      'user_lng': longitude,
      'radius_km': radiusKm
    });
    return List<Map<String, dynamic>>.from(response);
  }

  // User profile methods
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final client = await this.client;
    final response = await client
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .single();
    return response;
  }

  // Meeting methods
  Future<Map<String, dynamic>> createMeeting(Map<String, dynamic> meetingData) async {
    final client = await this.client;
    final response = await client
        .from('meetings')
        .insert(meetingData)
        .select()
        .single();
    return response;
  }

  Future<void> updateMeetingStatus(String meetingId, String status) async {
    final client = await this.client;
    await client.from('meetings').update({
      'status': status,
      'updated_at': DateTime.now().toIso8601String()
    }).eq('id', meetingId);
  }

  Future<Map<String, dynamic>?> getMeeting(String meetingId) async {
    final client = await this.client;
    final response = await client
        .from('meetings')
        .select()
        .eq('id', meetingId)
        .single();
    return response;
  }

  // Conversation topics methods
  Future<List<Map<String, dynamic>>> getConversationTopics(List<String> interests) async {
    final client = await this.client;
    final response = await client
        .from('conversation_topics')
        .select()
        .containedBy('tags', interests)
        .limit(3);
    return List<Map<String, dynamic>>.from(response);
  }
}
