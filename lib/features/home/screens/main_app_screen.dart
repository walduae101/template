import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/translation_extension.dart';
import '../../authentication/providers/auth_provider.dart';

class MainAppScreen extends ConsumerWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Sajaya brand colors
    const Color goldBackground = Color(0xFFC9AE5D);
    const Color darkRedText = Color(0xFF3F0707);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('app_name')),
        backgroundColor: goldBackground,
        foregroundColor: darkRedText,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              // Navigation back to login will happen automatically via auth state changes
            },
            tooltip: context.translate('sign_out'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${context.translate('welcome')}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: darkRedText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.displayName ?? user?.email ?? user?.phoneNumber ?? 'User',
                      style: const TextStyle(fontSize: 18, color: darkRedText),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              context.translate('home'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkRedText,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Text(
                  'This is a placeholder home screen.\nFull implementation coming soon.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: darkRedText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
