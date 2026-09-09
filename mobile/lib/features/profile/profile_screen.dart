import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('প্রোফাইল')),
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
          const ListTile(leading: Icon(Icons.logout), title: Text('লগআউট')),
        ],
      ),
    );
  }
}
