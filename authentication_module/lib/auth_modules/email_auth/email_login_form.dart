import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/auth_state.dart';
import 'email_auth_provider.dart';

class EmailLoginForm extends ConsumerStatefulWidget {
  const EmailLoginForm({super.key});

  @override
  ConsumerState<EmailLoginForm> createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends ConsumerState<EmailLoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(emailAuthProvider);
    final authNotifier = ref.read(emailAuthProvider.notifier);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) => value?.isEmpty == true ? 'Enter email' : null,
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) => value?.isEmpty == true ? 'Enter password' : null,
          ),
          const SizedBox(height: 16),
          if (authState.status == AuthStatus.loading)
            const CircularProgressIndicator()
          else
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (_isSignUp) {
                    authNotifier.signUpWithEmail(
                      _emailController.text,
                      _passwordController.text,
                    );
                  } else {
                    authNotifier.signInWithEmail(
                      _emailController.text,
                      _passwordController.text,
                    );
                  }
                }
              },
              child: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
            ),
          TextButton(
            onPressed: () => setState(() => _isSignUp = !_isSignUp),
            child: Text(_isSignUp ? 'Already have account? Sign In' : 'Create account'),
          ),
          if (!_isSignUp)
            TextButton(
              onPressed: () {
                if (_emailController.text.isNotEmpty) {
                  authNotifier.sendPasswordResetEmail(_emailController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset email sent')),
                  );
                }
              },
              child: const Text('Forgot Password?'),
            ),
          if (authState.error != null)
            Text(authState.error!, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}