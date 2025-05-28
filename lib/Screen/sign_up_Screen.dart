import 'package:flutter/material.dart';
import '../Services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0), // Dreamy cream background
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 60), // Push content a bit below the back button
                  Image.asset(
                    'assets/welcome-2.jpg',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Oh, so you're our new traveler!\n"
                    "Welcome once again.\n"
                    "Hope you will stay long on this journey.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFD4AF37), // Gold text
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildStyledTextField(
                    controller: nameController,
                    labelText: 'Name',
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 20),
                  _buildStyledTextField(
                    controller: mobileController,
                    labelText: 'Mobile Number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  _buildStyledTextField(
                    controller: ageController,
                    labelText: 'Age',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  _buildStyledTextField(
                    controller: emailController,
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  _buildStyledTextField(
                    controller: passwordController,
                    labelText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  _buildStyledTextField(
                    controller: confirmPasswordController,
                    labelText: 'Confirm Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final mobile = mobileController.text.trim();
                        final age = ageController.text.trim();
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();
                        final confirmPassword = confirmPasswordController.text.trim();

                        if (password != confirmPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Passwords do not match')),
                          );
                          return;
                        }

                        if (name.isEmpty || mobile.isEmpty || age.isEmpty || email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill all fields')),
                          );
                          return;
                        }

                        try {
                          await authService.signUpWithEmail(email, password);

                          // TODO: Save extra fields (name, mobile, age) in your backend/db

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Account created successfully!')),
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Sign up failed: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5E1A4), // Light gold
                        foregroundColor: const Color(0xFFFFF9F0), // Cream text
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Positioned custom back button at top left, safe area respected
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5E1A4), // Light gold background
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: const Color(0xFFD4AF37), // Gold icon color
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFFD4AF37)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFD4AF37)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFF5E1A4)),
          borderRadius: BorderRadius.circular(12),
        ),
        fillColor: Colors.white.withOpacity(0.7),
        filled: true,
      ),
      style: const TextStyle(color: Color(0xFFD4AF37)),
    );
  }
}
