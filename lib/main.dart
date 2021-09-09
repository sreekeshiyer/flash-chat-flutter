import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: WelcomeScreen.id,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
