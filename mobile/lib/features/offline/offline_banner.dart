import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// "ইন্টারনেট নেই — অফলাইন রোগ শনাক্তকরণ চালু আছে" — shown as a normal banner,
/// not an error page, per the offline-mode screen brief.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final offline = snapshot.data?.every((r) => r == ConnectivityResult.none) ?? false;
        if (!offline) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          color: const Color(0xFFFFDCC3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.wifi_off, size: 18, color: AppColors.onSecondaryContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ইন্টারনেট নেই — অফলাইন রোগ শনাক্তকরণ চালু আছে',
                  style: AppText.bodySm(color: AppColors.onSecondaryContainer),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
