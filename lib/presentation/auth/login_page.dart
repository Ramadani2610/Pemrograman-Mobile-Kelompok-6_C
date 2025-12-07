import 'package:flutter/material.dart';
import 'package:spareapp_unhas/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFFD32F2F);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remember = prefs.getBool('remember_me') ?? false;
      if (remember) {
        final savedUsername = prefs.getString('saved_username') ?? '';
        final savedPassword = prefs.getString('saved_password') ?? '';
        setState(() {
          _rememberMe = true;
          _usernameController.text = savedUsername;
          _passwordController.text = savedPassword;
        });
      }
    } catch (e) {
      // ignore errors silently for now
    }
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    // Simulasi delay
    await Future.delayed(const Duration(seconds: 1));

    final result = AuthService.validateLogin(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      // Persist credentials if requested
      _saveOrClearCredentials();

      // Navigate based on userType
      if (mounted) {
        final userType = result['userType'] as String?;
        if (userType == 'admin') {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Navigator.of(context).pushReplacementNamed('/home_user');
        }
      }
    } else {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _saveOrClearCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setBool('remember_me', true);
        await prefs.setString('saved_username', _usernameController.text);
        await prefs.setString('saved_password', _passwordController.text);
      } else {
        await prefs.remove('remember_me');
        await prefs.remove('saved_username');
        await prefs.remove('saved_password');
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          child: Column(
            children: [
              // Header dengan SPARE dan Logo UNHAS
              Container(
                width: double.infinity,
                height: screenHeight * 0.45,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [primaryColor, Colors.red.shade300],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo UNHAS utuh
                      Image.asset(
                        'lib/assets/icons/Logo-Resmi-Unhas-1.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 120,
                            color: Colors.white.withOpacity(0.2),
                            child: const Icon(
                              Icons.school,
                              size: 60,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'SPARE',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ) ??
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Space & Property Allocation & Reservation',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ) ??
                            const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // Form Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome!',
                          style:
                              Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ) ??
                              const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please Log In to Your Account',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                                fontFamily: 'Poppins',
                              ) ??
                              TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontFamily: 'Poppins',
                              ),
                        ),
                        const SizedBox(height: 30),

                        // Username Field
                        Text(
                          'Username',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Masukkan NIM atau admin1',
                            hintStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 0,
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[400]!),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[400]!),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          style: const TextStyle(fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 24),

                        // Password Field
                        Text(
                          'Password',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Masukkan password',
                            hintStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 0,
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[400]!),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[400]!),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          style: const TextStyle(fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 16),

                        // Remember Me Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              activeColor: primaryColor,
                              onChanged: (val) {
                                setState(() {
                                  _rememberMe = val ?? false;
                                });
                              },
                            ),
                            Text(
                              'Remember Me?',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Log In',
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.labelLarge?.copyWith(
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                        ) ??
                                        const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                        ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Forgot Password Link
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/forgot_password');
                            },
                            child: Text(
                              'Forgot Password?',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                    fontFamily: 'Poppins',
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
