import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

const _categoryLabelsBn = {
  'organic': 'জৈব পদ্ধতি',
  'low_chemical': 'কম রাসায়নিক',
  'chemical': 'রাসায়নিক',
};

/// Follows the DESIGN.md "Agricultural Diagnostic Card" and button rules.
/// Only renders treatment content the backend marked `approved: true` and
/// already ranked deterministically — this screen never re-orders or
/// filters, so it can't silently disagree with the treatment_engine rules.
class TreatmentScreen extends StatelessWidget {
  const TreatmentScreen({
    super.key,
    this.diseaseNameBn = 'ফসলের রোগ',
    this.treatments = const [],
    this.isTentative = false,
  });

  final String diseaseNameBn;
  final List<Map<String, dynamic>> treatments;
  final bool isTentative;

  /// Builds the screen from the `extra` map passed by DiagnosisResultScreen's
  /// treatment button — the live data path. [isTentative] is true when this
  /// came from a NEEDS_REVIEW result: the model's top guess, not a confirmed
  /// diagnosis, so the advice must stay visibly preliminary.
  factory TreatmentScreen.fromExtra(Map data) {
    return TreatmentScreen(
      diseaseNameBn: data['diseaseNameBn'] as String? ?? 'ফসলের রোগ',
      treatments: (data['treatments'] as List?)?.cast<Map<String, dynamic>>() ?? const [],
      isTentative: data['isTentative'] as bool? ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(diseaseNameBn)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text('এখন কী করবেন?', style: AppText.headlineMd()),
          const SizedBox(height: 16),
          if (isTentative) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFFFDCC3), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.help_outline, color: Color(0xFF6E3900)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'এটি একটি প্রাথমিক অনুমান, নিশ্চিত রোগ নির্ণয় নয় — নিচের পরামর্শ প্রয়োগের আগে একজন কৃষি বিশেষজ্ঞের মাধ্যমে যাচাই করে নিন।',
                      style: AppText.bodySm(color: const Color(0xFF6E3900)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (treatments.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surfaceRaised, borderRadius: BorderRadius.circular(16), boxShadow: AppElevation.level1),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(child: Text('গাছটি সুস্থ দেখাচ্ছে — এখনই কোনো চিকিৎসার প্রয়োজন নেই।', style: AppText.bodyMd())),
                ],
              ),
            )
          else ...[
            for (final treatment in treatments) ...[
              _TreatmentCategory(
                title: _categoryLabelsBn[treatment['category']] ?? 'পরামর্শ',
                body: treatment['action_bn'] as String? ?? '',
                safetyNoteBn: treatment['safety_notes_bn'] as String?,
              ),
              const SizedBox(height: 12),
            ],
          ],
          const SizedBox(height: 12),
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

class _TreatmentCategory extends StatelessWidget {
  const _TreatmentCategory({required this.title, required this.body, this.safetyNoteBn});
  final String title;
  final String body;
  final String? safetyNoteBn;

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
          if (safetyNoteBn != null && safetyNoteBn!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(safetyNoteBn!, style: AppText.labelSm(color: AppColors.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}
