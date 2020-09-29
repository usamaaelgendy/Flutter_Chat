import 'package:chatting_ui_fun/provider/toggle_visibility_provider.dart';
import 'package:chatting_ui_fun/provider/user_auth_provider.dart';
import 'package:chatting_ui_fun/provider/user_chat.dart';
import 'package:chatting_ui_fun/ui/pages/auth/welcome_screen.dart';
import 'package:chatting_ui_fun/ui/pages/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'helper/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserAuthProvider.initialize(),
        ),
        ChangeNotifierProvider(
          create: (context) => ToggleVisibility(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserChat(),
        ),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Chat Elgindy',
          theme: ThemeData(
            primaryColor: kPrimaryColor,
            scaffoldBackgroundColor: Colors.white,
          ),
          home: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserAuthProvider>(context);
    switch (user.status) {
      case Status.Uninitialized:
        return CircularProgressIndicator();
      case Status.Unauthenticated:
        return WelcomeScreen();
      case Status.Authenticating:
        return WelcomeScreen();
      case Status.Authenticated:
        return HomeScreen();
      default:
        return MaterialApp(
          home: WelcomeScreen(),
        );
    }
  }
}
