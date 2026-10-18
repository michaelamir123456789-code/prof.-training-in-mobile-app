// Import the Flutter Material library to use UI components.
import 'package:flutter/material.dart';
// Import our custom theme, storage, and screen files.
import 'theme.dart';
import 'services/storage.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

// da el main function is the entry point of the app. It runs when the app starts.
// async: 3lshan nestana el database te load.
void main() async {
  // to use the phone's storage before we draw the screen.
  WidgetsFlutterBinding.ensureInitialized();
  
  // be ask el db if a user is already logged in. 
  // If no one is logged in, this will be null.
  final savedUser = await Storage.getSession();
  
  // Start the app, passing the saved user to the main App widget. (turns the app on.)
  runApp(WatchMateApp(initialUser: savedUser)); 
}

// The root widget of our application.
class WatchMateApp extends StatelessWidget {
  final String? initialUser; // Can be a String (email) or null.
  
  // Constructor requires the initialUser variable.
  const WatchMateApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    // MaterialApp sets up the overall app configuration.
    return MaterialApp(
      title: 'WatchMate',
      debugShowCheckedModeBanner: false, // Hides the red "DEBUG" banner in the corner.
      theme: AppTheme.dark, // Applies our custom dark theme from theme.dart
      
      // lw el initialUser is null (nobody logged in), show the Login screen. Otherwise, go straight to Home.
      home: initialUser == null
          ? const AuthScreen()
          : HomeScreen(email: initialUser!),
    );
  }
}