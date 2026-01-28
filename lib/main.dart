import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/services/hive_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/location_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive
  await HiveService.init();

  // Set system UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Parallel initialization of other services
  await Future.wait([
    NotificationService.instance.initialize(),
    LocationService.instance.initialize(),
  ]);

  runApp(
    const ProviderScope(
      child: LoyaltyCardApp(),
    ),
  );
}
