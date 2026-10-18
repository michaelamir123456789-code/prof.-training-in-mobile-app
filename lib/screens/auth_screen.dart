import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/storage.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';

// This is the Login and Sign-up page.

//StatefulWidget: el screen momken tet8ayar while it's running (like switching from Login to Sign-up mode).
//_isLogin: A boolean. true: it shows the Login button. false: it shows Register.
//_submit(): When the user clicks "Log in":
//be check if the email has an @ and a ".".
//be check if the password is at least 6 letters.
//be call Storage.login().
//If successful, it uses Navigator.pushReplacement to take the user to the Home Screen.



class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // _formKey helps validate the whole form at once.
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _isLogin = true; // Toggles between Login mode and Register mode.
  bool _hidePass = true; // Toggles password visibility.
  bool _loading = false; // Shows a spinner on the button while waiting.
  String? _error; // Holds an error message if login fails.

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // The function that runs when the Login/Register button is pressed.
  Future<void> _submit() async {
    // Check if email/password are valid. If not, stop.
    if (!_formKey.currentState!.validate()) return;

    // Show loading spinner.
    setState(() {
      _loading = true;
      _error = null;
    });

    final email = _emailCtrl.text.trim().toLowerCase();
    final pass = _passCtrl.text;

    // Call the database. It returns null if successful, or an error string if it fails.
    final error = _isLogin
        ? await Storage.login(email, pass)
        : await Storage.register(email, pass);

    if (!mounted) return; // Safety check: make sure the screen is still on display.

    if (error != null) {
      // Show the error message.
      setState(() {
        _error = error;
        _loading = false;
      });
      return;
    }

    // Success! Go to the Home Screen.
    // pushReplacement means the user can't press the back button to return to login.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(email: email)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A nice radial glow behind the form.
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.9),
            radius: 1.2,
            colors: [
              AppColors.primary.withValues(alpha: 0.28), // Purple glow with transparency.
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea( // Prevents overlapping with phone notches.
          child: Center(
            child: SingleChildScrollView( // Allows scrolling if the keyboard pops up.
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // The App Logo (A rounded square with a gradient).
                    Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          gradient: kBrandGradient,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [ // Glow effect behind the logo.
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.45),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.movie_filter_rounded, size: 44, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'WatchMate',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 6),
                    
                    // Changes text based on whether it's login or sign up mode.
                    Text(
                      _isLogin
                          ? 'Welcome back! Pick up where you left off.'
                          : 'Create your private watch diary.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 34),

                    // Email Input.
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      // Validation: Must contain '@' and '.' to be a valid email.
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Password Input.
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _hidePass, // Hides the text (shows dots).
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        // Eye icon to toggle visibility.
                        suffixIcon: IconButton(
                          icon: Icon(_hidePass ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          onPressed: () => setState(() => _hidePass = !_hidePass),
                        ),
                      ),
                      // Validation: Must be at least 6 characters.
                      validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                      onFieldSubmitted: (_) => _submit(), // Submits if user presses "Enter".
                    ),

                    // Error message display (if any).
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
                    ],
                    const SizedBox(height: 24),

                    // The Main Button.
                    GradientButton(
                      label: _isLogin ? 'Log in' : 'Create account',
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 14),

                    // Toggle between Login and Register.
                    TextButton(
                      onPressed: () => setState(() {
                        _isLogin = !_isLogin;
                        _error = null; // Clear errors when switching modes.
                      }),
                      child: Text(
                        _isLogin ? "Don't have an account? Sign up" : 'Already have an account? Log in',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}