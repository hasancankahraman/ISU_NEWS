// ignore_for_file: prefer_const_constructors

import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/initialScreen.dart';
import '../screens/user/login_screen.dart';
import '../screens/user/profile_screen.dart';
import '../screens/user/register_screen.dart';
import '../screens/user/ticket_screen.dart';
import '../screens/user/welcome_screen.dart';
import '../static_screens/setting.screen.dart';

final routes = GoRouter(
  initialLocation: '/',
  routes: [
    // Loader Screen
    GoRoute(
      path: '/',
      builder: (context, state) => InitialScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => WelcomeScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(),
    ),
    // User Screens
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => ProfileScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterScreen(),
    ),
    GoRoute(
      path: '/tickets',
      builder: (context, state) => TicketScreen(),
    ),
    GoRoute(
      path: '/ticket-add',
      builder: (context, state) => AddTicketScreen(),
    ),
    // Static Screen
    GoRoute(
      path: '/settings',
      builder: (context, state) => SettingScreen(),
    ),
  ],
);
