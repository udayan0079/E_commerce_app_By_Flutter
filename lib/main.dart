import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/app_env.dart';

/// Entry point of the CraftyBay E-Commerce application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnv.load();
  runApp(const CraftyBayApp());
}
