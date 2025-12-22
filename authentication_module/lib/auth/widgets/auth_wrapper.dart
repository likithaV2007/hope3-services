import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../models/auth_state.dart';

class AuthWrapper extends ConsumerWidget {
  final Widget authenticatedWidget;
  final Widget unauthenticatedWidget;

  const AuthWrapper({
    super.key,
    required this.authenticatedWidget,
    required this.unauthenticatedWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    switch (authState.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.authenticated:
        return authenticatedWidget;
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return unauthenticatedWidget;
    }
  }
}