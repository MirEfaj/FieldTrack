import 'package:flutter/material.dart';
import 'package:field_track/app.dart';
import 'package:field_track/config/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await initializeApp();
  runApp(const FieldTrackApp());
}
