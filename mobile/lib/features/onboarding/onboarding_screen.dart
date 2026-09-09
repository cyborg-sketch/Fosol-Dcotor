import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.primaryFixed, shape: BoxShape.circle),
                child: const Icon(Icons.eco, size: 64, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'আপনার ফসলের সমস্যা জানতে সাহায্য করি',
                textAlign: TextAlign.center,
                style: AppText.headlineLg(),
              ),
              const SizedBox(height: 12),
              Text(
                'ক্যামেরা ও মাইক্রোফোন ব্যবহারের অনুমতি দিন — শুধু রোগ শনাক্ত করতে',
                textAlign: TextAlign.center,
                style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('শুরু করুন'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
