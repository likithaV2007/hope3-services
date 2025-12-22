import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/auth_state.dart';
import 'phone_auth_provider.dart';

class PhoneLoginForm extends ConsumerStatefulWidget {
  const PhoneLoginForm({super.key});

  @override
  ConsumerState<PhoneLoginForm> createState() => _PhoneLoginFormState();
}

class _PhoneLoginFormState extends ConsumerState<PhoneLoginForm> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _codeSent = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(phoneAuthProvider);
    final authNotifier = ref.read(phoneAuthProvider.notifier);

    return Column(
      children: [
        if (!_codeSent) ...[
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone Number'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: authState.status == AuthStatus.loading
                ? null
                : () {
                    authNotifier.signInWithPhone(_phoneController.text);
                    setState(() => _codeSent = true);
                  },
            child: authState.status == AuthStatus.loading
                ? const CircularProgressIndicator()
                : const Text('Send OTP'),
          ),
        ] else ...[
          TextFormField(
            controller: _otpController,
            decoration: const InputDecoration(labelText: 'OTP Code'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: authState.status == AuthStatus.loading
                ? null
                : () => authNotifier.verifyOTP(_otpController.text),
            child: authState.status == AuthStatus.loading
                ? const CircularProgressIndicator()
                : const Text('Verify OTP'),
          ),
        ],
        if (authState.error != null)
          Text(authState.error!, style: const TextStyle(color: Colors.red)),
      ],
    );
  }
}