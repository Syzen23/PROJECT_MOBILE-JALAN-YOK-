import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.light_mode_outlined),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Login to your\nAccount',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              
              // Email Field
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email, color: Colors.black87),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black87),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 20),
              
              // Password Field
              TextFormField(
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock, color: Colors.black87),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black87),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 20),
              
              // Remember me
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Text('Remember me', style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 30),
              
              // Sign in button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Text(
                    'Sign in',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Or continue with
              const Center(
                child: Text('or continue with', style: TextStyle(fontSize: 16, color: Colors.black87)),
              ),
              const SizedBox(height: 24),
              
              // Social login buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: _buildSocialButton(
                      SvgPicture.asset('assets/images/Google.svg', width: 24, height: 24),
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: _buildSocialButton(
                      SvgPicture.asset('assets/images/Handphone.svg', width: 24, height: 24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account? ', style: TextStyle(color: Colors.black54)),
                  GestureDetector(
                    onTap: () {
                      context.pushReplacement('/register');
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Color(0xFF007AFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(Widget iconWidget) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: iconWidget,
    );
  }
}
