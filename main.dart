// ben import flutter material package(buttons, colors, text, etc.) w el autth screen el ehna 3amlenha 
import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';

// el main 
void main() {
  runApp(const WatchMateApp());
}

// StatelessWidget: this widget mesh hatt8ayar (no state) w constructor It allows us to create the app
class WatchMateApp extends StatelessWidget {
  const WatchMateApp({super.key});

// build: most important function in Flutter. bet builds el ehna shayfeino 3ala el screen

// BuildContext context: context zay widget's GPS location. da be2ol el widget heya fein w maknha fein fel app (like the screen size or the theme colors)
  @override
  Widget build(BuildContext context) {
    // be sets up the navigation el be5aleny at7arak mabein el screens, theme, behavior
    return MaterialApp(
      title: 'WatchMate',
      // debugShowCheckedModeBanner: false: bet5aly el banner el red el fel corner ya5tafy
      debugShowCheckedModeBanner: false,
      // dark theme with a purple color.
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const AuthScreen(), // the first screen
    );
  }
}