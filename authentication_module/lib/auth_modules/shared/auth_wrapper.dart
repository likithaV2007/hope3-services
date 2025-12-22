import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state.dart';

class AuthWrapper extends ConsumerWidget {
  final Widget authenticatedWidget;
  final Widget unauthenticatedWidget;
  final StateNotifierProvider<dynamic, AuthState> authProvider;

  const AuthWrapper({
    super.key,
    required this.authenticatedWidget,
    required this.unauthenticatedWidget,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    switch (authState.status) {
      case AuthStatus.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.authenticated:
        return authenticatedWidget;
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return unauthenticatedWidget;
      case AuthStatus.initial:
      default:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
    }
  }
}