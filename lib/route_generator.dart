import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/group_details_screen.dart';
import 'package:flash_chat/screens/groups_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final args2 = settings.arguments;

    switch (settings.name) {
      case WelcomeScreen.id:
        return MaterialPageRoute(builder: (_) => WelcomeScreen());
      case RegistrationScreen.id:
        return MaterialPageRoute(builder: (_) => RegistrationScreen());
      case LoginScreen.id:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case GroupScreen.id:
        return MaterialPageRoute(builder: (_) => GroupScreen());
      case GroupDetailsScreen.id:
        return MaterialPageRoute(builder: (_) => GroupDetailsScreen(args));
      case ChatScreen.id:
        return MaterialPageRoute(builder: (_) => ChatScreen(args2));
        break;

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('ERROR'),
        ),
        body: Center(
          child: Text('Error'),
        ),
      );
    });
  }
}
