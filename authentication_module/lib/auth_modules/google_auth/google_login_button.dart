import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/auth_state.dart';
import 'google_auth_provider.dart';

class GoogleLoginButton extends ConsumerWidget {
  const GoogleLoginButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(googleAuthProvider);
    final authNotifier = ref.read(googleAuthProvider.notifier);

    return ElevatedButton.icon(
      onPressed: authState.status == AuthStatus.loading 
          ? null 
          : () => authNotifier.signInWithGoogle(),
      icon: const Icon(Icons.login),
      label: authState.status == AuthStatus.loading
          ? const CircularProgressIndicator()
          : const Text('Sign in with Google'),
    );
  }
}