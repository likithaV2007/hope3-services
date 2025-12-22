import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../models/auth_state.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isSignUp = false;
  bool _obscurePassword = true;
  String? _verificationId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 20),
                _buildAuthCard(authState, authNotifier),
                if (authState.error != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorCard(authState.error!, authNotifier),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_outline, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text(
          'Welcome',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Text(
          'Sign in to continue',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildAuthCard(AuthState authState, authNotifier) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF667eea),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF667eea),
              tabs: const [
                Tab(text: 'Email'),
                Tab(text: 'Phone'),
              ],
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildEmailForm(authState, authNotifier),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildPhoneForm(authState, authNotifier),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailForm(AuthState authState, authNotifier) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Email is required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Password is required';
              if (value!.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: authState.status == AuthStatus.loading ? null : () => _handleEmailAuth(authNotifier),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: authState.status == AuthStatus.loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_isSignUp ? 'Sign Up' : 'Sign In', style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _isSignUp = !_isSignUp),
            child: Text(_isSignUp ? 'Already have an account? Sign In' : 'Don\'t have an account? Sign Up'),
          ),
          if (!_isSignUp)
            TextButton(
              onPressed: () => _handlePasswordReset(authNotifier),
              child: const Text('Forgot Password?'),
            ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: authState.status == AuthStatus.loading ? null : () => authNotifier.signInWithGoogle(),
              icon: Image.network(
                'https://developers.google.com/identity/images/g-logo.png',
                height: 20,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.login),
              ),
              label: const Text('Continue with Google'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneForm(AuthState authState, authNotifier) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_verificationId == null) ...[
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: const Icon(Icons.phone_outlined),
              hintText: '+1234567890',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: authState.status == AuthStatus.loading ? null : () => _handlePhoneAuth(authNotifier),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: authState.status == AuthStatus.loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Send OTP', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ] else ...[
          const Text('Enter the OTP sent to your phone', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _otpController,
            decoration: InputDecoration(
              labelText: 'OTP Code',
              prefixIcon: const Icon(Icons.sms_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: authState.status == AuthStatus.loading ? null : () => _handleOTPVerification(authNotifier),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: authState.status == AuthStatus.loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verify OTP', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _verificationId = null),
            child: const Text('Change Phone Number'),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorCard(String error, authNotifier) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(child: Text(error, style: TextStyle(color: Colors.red.shade700))),
            IconButton(
              onPressed: () => authNotifier.clearError(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }

  void _handleEmailAuth(authNotifier) {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isSignUp) {
        authNotifier.signUpWithEmail(_emailController.text, _passwordController.text);
      } else {
        authNotifier.signInWithEmail(_emailController.text, _passwordController.text);
      }
    }
  }

  void _handlePhoneAuth(authNotifier) {
    if (_phoneController.text.isNotEmpty) {
      authNotifier.signInWithPhone(_phoneController.text, (verificationId) {
        setState(() => _verificationId = verificationId);
      });
    }
  }

  void _handleOTPVerification(authNotifier) {
    if (_otpController.text.isNotEmpty && _verificationId != null) {
      authNotifier.verifyOTP(_verificationId!, _otpController.text);
    }
  }

  void _handlePasswordReset(authNotifier) {
    if (_emailController.text.isNotEmpty) {
      authNotifier.sendPasswordResetEmail(_emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent!')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}