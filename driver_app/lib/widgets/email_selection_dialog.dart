import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../constants/app_colors.dart';

class EmailSelectionDialog extends StatelessWidget {
  final List<GoogleSignInAccount> accounts;
  final Function(GoogleSignInAccount) onAccountSelected;

  const EmailSelectionDialog({
    Key? key,
    required this.accounts,
    required this.onAccountSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 16),
            ...accounts.map((account) => _buildAccountTile(context, account)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTile(BuildContext context, GoogleSignInAccount account) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: account.photoUrl != null 
              ? NetworkImage(account.photoUrl!) 
              : null,
          backgroundColor: AppColors.primary,
          child: account.photoUrl == null 
              ? Text(
                  account.email[0].toUpperCase(),
                  style: const TextStyle(color: AppColors.white),
                )
              : null,
        ),
        title: Text(
          account.displayName ?? account.email,
          style: const TextStyle(color: AppColors.black, fontSize: 14),
        ),
        subtitle: Text(
          account.email,
          style: const TextStyle(color: AppColors.grey, fontSize: 12),
        ),
        onTap: () {
          Navigator.pop(context);
          onAccountSelected(account);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.primary, width: 0.5),
        ),
      ),
    );
  }
}