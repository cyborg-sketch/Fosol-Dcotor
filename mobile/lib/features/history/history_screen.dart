import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const _items = [
    {'crop': 'ধান', 'date': '৫ সেপ্টেম্বর', 'diagnosis': 'ব্লাস্ট রোগ', 'status': 'পরামর্শ পাওয়া গেছে'},
    {'crop': 'পাট', 'date': '২ সেপ্টেম্বর', 'diagnosis': 'পাতা মরা রোগ', 'status': 'বিশেষজ্ঞ দেখছেন'},
    {'crop': 'ধান', 'date': '২৮ আগস্ট', 'diagnosis': 'কাণ্ড পচা', 'status': 'যাচাই হয়েছে'},
  ];

  Color _chipColor(String status) {
    switch (status) {
      case 'বিশেষজ্ঞ দেখছেন':
        return const Color(0xFFFFDCC3);
      default:
        return AppColors.primaryFixed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('আমার রিপোর্ট')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final item = _items[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surfaceRaised, borderRadius: BorderRadius.circular(16), boxShadow: AppElevation.level1),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item['crop']} — ${item['diagnosis']}', style: AppText.headlineSm()),
                      const SizedBox(height: 4),
                      Text(item['date']!, style: AppText.bodySm()),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: _chipColor(item['status']!), borderRadius: BorderRadius.circular(999)),
                  child: Text(item['status']!, style: AppText.labelSm()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
