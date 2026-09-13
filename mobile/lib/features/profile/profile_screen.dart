import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/server_settings_dialog.dart';
import '../offline/offline_cache.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'ফিরে যান',
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('প্রোফাইল'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'হোম',
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: ListView(
        children: [
          const ListTile(leading: Icon(Icons.person_outline), title: Text('নাম'), subtitle: Text('কৃষক')),
          const ListTile(leading: Icon(Icons.phone_outlined), title: Text('ফোন নম্বর')),
          const ListTile(leading: Icon(Icons.language), title: Text('ভাষা'), subtitle: Text('বাংলা')),
          const ListTile(leading: Icon(Icons.grass_outlined), title: Text('আমার ফসল')),
          const ListTile(leading: Icon(Icons.notifications_outlined), title: Text('নোটিফিকেশন')),
          const ListTile(leading: Icon(Icons.help_outline), title: Text('সহায়তা')),
          const Divider(),
          // Staff-only entry points — not part of the farmer nav, kept here
          // for the demo so the field-worker/BRAC screens are reachable.
          ListTile(
            leading: const Icon(Icons.fact_check_outlined, color: AppColors.secondary),
            title: const Text('কৃষি কর্মকর্তা প্যানেল'),
            subtitle: const Text('যাচাইয়ের অপেক্ষায় থাকা কেসসমূহ'),
            onTap: () => context.push('/field-worker'),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart, color: AppColors.tertiary),
            title: const Text('BRAC আঞ্চলিক ড্যাশবোর্ড'),
            subtitle: const Text('জেলাভিত্তিক রোগের প্রবণতা'),
            onTap: () => context.push('/dashboard'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dns_outlined, color: AppColors.primary),
            title: const Text('সার্ভার সেটিংস'),
            subtitle: Text(OfflineCache.getServerUrl() ?? 'ডিফল্ট (http://10.177.56.48:8000)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final changed = await showServerSettingsDialog(context);
              if (changed == true && context.mounted) {
                (context as Element).markNeedsBuild();
              }
            },
          ),
          const Divider(),
          const ListTile(leading: Icon(Icons.logout), title: Text('লগআউট')),
        ],
      ),
    );
  }
}
