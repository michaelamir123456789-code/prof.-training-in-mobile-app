// auth_screen.dart - Login / Sign up screen.
// Topics used: StatefulWidget, setState, TextEditingController,
// Form + TextFormField, validation, show/hide password, Navigator.
import 'package:flutter/material.dart';
import 'Home_screen.dart';
 
// A Map (key -> value) that stores the accounts: email -> password.
// It lives in memory, so it resets when the app is closed.
final Map<String, String> users = {
  'test@test.com': '123456',
};

 
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
 
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}
 
class _AuthScreenState extends State<AuthScreen> {
  // The key lets us validate the whole form at once.
  final formKey = GlobalKey<FormState>();
 
  // Controllers read the text that the user typed.
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
 
  // State variables: when they change, the screen is rebuilt.
  bool isLogin = true; // true = Log in, false = Sign up
  bool hidePassword = true;
  String? error; // null means "no error" (Null Safety)
 
  // Always dispose controllers to free memory.
  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }
 
  // Runs when the user presses the main button.
  void submit() {
    // Stop if any validator returned an error message.
    if (!formKey.currentState!.validate()) return;
 
    String email = emailCtrl.text.trim().toLowerCase();
    String pass = passCtrl.text;
 
    if (isLogin) {
      // Log in: the account must exist and the password must match.
      if (!users.containsKey(email)) {
        setState(() => error = "No account found for this email.");
        return;
      }
      if (users[email] != pass) {
        setState(() => error = "Wrong password.");
        return;
      }
    } else {
      // Sign up: the email must not be used before.
      if (users.containsKey(email)) {
        setState(() => error = "This email is already registered.");
        return;
      }
      users[email] = pass; // add a new key-value pair to the Map
    }
 
    // Go to the home screen. pushReplacement removes the login screen,
    // so the back button will not return to it.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(email: email)),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          // Scroll when the keyboard is open.
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const Icon(Icons.movie_filter_rounded,
                      size: 80, color: Colors.deepPurpleAccent),
                  const SizedBox(height: 12),
                  const Text(
                    "WatchMate",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLogin
                        ? "Welcome back! Log in to continue."
                        : "Create your private watch diary.",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
 
                  // Email field
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // Validation: return a message if wrong, null if OK.
                    validator: (value) {
                      if (value == null || !value.contains("@")) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
 
                  // Password field with show / hide button
                  TextFormField(
                    controller: passCtrl,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(hidePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return "At least 6 characters";
                      }
                      return null;
                    },
                  ),
 
                  // Show the error message only if there is one.
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(error!, style: const TextStyle(color: Colors.redAccent)),
                  ],
                  const SizedBox(height: 24),
 
                  // Main button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: submit,
                      child: Text(isLogin ? "Log in" : "Create account"),
                    ),
                  ),
 
                  // Switch between Log in and Sign up
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                        error = null;
                      });
                    },
                    child: Text(isLogin
                        ? "Don't have an account? Sign up"
                        : "Already have an account? Log in"),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Demo account: test@test.com / 123456",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 