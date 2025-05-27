import 'package:flutter/material.dart';
import '../presentation/meeting_confirmed_screen/meeting_confirmed_screen.dart';
import '../presentation/main_map_screen/main_map_screen.dart';
import '../presentation/meeting_coordination_screen/meeting_coordination_screen.dart';
import '../presentation/user_profiles_bottom_sheet/user_profiles_bottom_sheet.dart';

class AppRoutes {
  static const String initial = '/';
  static const String meetingConfirmedScreen = '/meeting-confirmed-screen';
  static const String mainMapScreen = '/main-map-screen';
  static const String userProfilesBottomSheet = '/user-profiles-bottom-sheet';
  static const String meetingCoordinationScreen = '/meeting-coordination-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const MainMapScreen(), // Changed to a proper screen
    meetingConfirmedScreen: (context) => const MeetingConfirmedScreen(),
    mainMapScreen: (context) => const MainMapScreen(),
    userProfilesBottomSheet: (context) => const UserProfilesBottomSheet(),
    meetingCoordinationScreen: (context) => const MeetingCoordinationScreen(),
  };
}