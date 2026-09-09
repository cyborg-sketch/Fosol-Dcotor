import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Follows the DESIGN.md "Agricultural Diagnostic Card" and button rules.
/// Only renders treatment content the backend marked `approved: true` and
/// already ranked deterministically — this screen never re-orders or
/// filters, so it can't silently disagree with the treatment_engine rules.
class TreatmentScreen extends StatelessWidget {
  const TreatmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ধানের ব্লাস্ট রোগ')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text('এখন কী করবেন?', style: AppText.headlineMd()),
          const SizedBox(height: 16),
          const _Step(number: 1, label: 'আক্রান্ত পাতা সরিয়ে ফেলুন'),
          const _Step(number: 2, label: 'জৈব ছত্রাকনাশক প্রয়োগ করুন'),
          const _Step(number: 3, label: '৫-৭ দিন পর আবার পরীক্ষা করুন'),
          const SizedBox(height: 20),
          const _TreatmentCategory(title: 'জৈব/কম রাসায়নিক', body: 'নিমতেল স্প্রে, সপ্তাহে ২ বার'),
          const SizedBox(height: 12),
          const _TreatmentCategory(title: 'প্রয়োজনে রাসায়নিক', body: 'ট্রাইসাইক্লাজল — লেবেল অনুযায়ী মাত্রা'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFFFDCC3), borderRadius: BorderRadius.circular(16)),
            child: Text(
              'সতর্কতা: রাসায়নিক প্রয়োগের আগে প্যাকেটের নির্দেশনা পড়ুন।',
              style: AppText.bodySm(color: const Color(0xFF6E3900)),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () {}, child: const Text('পরামর্শটি সংরক্ষণ করুন')),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.label});
  final int number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(radius: 14, backgroundColor: AppColors.primaryFixed, child: Text('$number', style: AppText.labelMd(color: AppColors.primary))),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppText.bodyMd())),
        ],
      ),
    );
  }
}

class _TreatmentCategory extends StatelessWidget {
  const _TreatmentCategory({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceRaised, borderRadius: BorderRadius.circular(16), boxShadow: AppElevation.level1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.labelLg()),
          const SizedBox(height: 6),
          Text(body, style: AppText.bodySm()),
        ],
      ),
    );
  }
}
