import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

/// Mirrors stitch_fasol_doctor_agriculture_app_design/diagnosis_result_high_confidence.
/// Renders both the high- and low-confidence briefs from one screen: layout
/// stays constant, copy and CTA set change based on [needsReview] — which
/// must always come from the API's `status` field, never inferred from the
/// confidence number alone.
class DiagnosisResultScreen extends StatefulWidget {
  const DiagnosisResultScreen({
    super.key,
    this.diseaseNameBn = 'ধানের ব্লাস্ট রোগের সম্ভাবনা বেশি',
    this.diseaseNameEn = '(Rice Blast Disease - Pyricularia oryzae)',
    this.cropLabelBn = 'ধান ফসল',
    this.confidencePercent = 94,
    this.needsReview = false,
  });

  final String diseaseNameBn;
  final String diseaseNameEn;
  final String cropLabelBn;
  final int confidencePercent;
  final bool needsReview;

  /// Builds the screen from a POST /diagnoses (or GET /diagnoses/:id)
  /// response — the real path, used once analyzing_screen.dart gets a
  /// result back. `status` decides [needsReview], never the raw confidence
  /// number alone, matching the backend's confidence_engine rule.
  factory DiagnosisResultScreen.fromApi(Map<String, dynamic> data) {
    final candidates = (data['candidates'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final topCandidate = candidates.isNotEmpty ? candidates.first : null;
    final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;
    final needsReview = data['status'] == 'NEEDS_REVIEW';

    return DiagnosisResultScreen(
      diseaseNameBn: needsReview
          ? 'নিশ্চিতভাবে রোগটি শনাক্ত করা যায়নি'
          : (topCandidate?['disease_name_bn'] as String? ?? 'অজানা সমস্যা'),
      diseaseNameEn: '',
      confidencePercent: (confidence * 100).round(),
      needsReview: needsReview,
    );
  }

  @override
  State<DiagnosisResultScreen> createState() => _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState extends State<DiagnosisResultScreen> {
  bool _reasonsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ফলাফল')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // Status banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primaryFixed, borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(widget.needsReview ? Icons.help : Icons.verified, color: AppColors.primary, size: 28),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.needsReview ? 'পর্যালোচনা প্রয়োজন' : 'সফল রোগ নির্ণয়', style: AppText.labelSm(color: AppColors.onPrimaryFixedVariant)),
                        Text('ফলাফল তৈরি সম্পন্ন হয়েছে', style: AppText.bodySm(color: AppColors.onPrimaryFixedVariant)),
                      ],
                    ),
                  ],
                ),
                Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(999)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.volume_up, color: AppColors.onSecondaryContainer, size: 22),
                      const SizedBox(width: 4),
                      Text('শুনুন', style: AppText.labelMd(color: AppColors.onSecondaryContainer)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Leaf preview
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 200,
              color: AppColors.surfaceContainerHighest,
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.image, size: 48, color: AppColors.onSurfaceVariant)),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(999)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.eco, size: 18, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(widget.cropLabelBn, style: AppText.labelMd(color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Main result card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.surfaceRaised, borderRadius: BorderRadius.circular(16), boxShadow: AppElevation.level1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(widget.needsReview ? Icons.help_outline : Icons.warning, size: 20, color: widget.needsReview ? AppColors.secondary : AppColors.error),
                    const SizedBox(width: 4),
                    Text(widget.needsReview ? 'অনিশ্চিত ফলাফল' : 'শনাক্তকৃত সমস্যা', style: AppText.labelMd(color: widget.needsReview ? AppColors.secondary : AppColors.error)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.needsReview ? 'নিশ্চিতভাবে রোগটি শনাক্ত করা যায়নি' : widget.diseaseNameBn,
                  style: AppText.headlineMd(),
                ),
                if (!widget.needsReview && widget.diseaseNameEn.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(widget.diseaseNameEn, style: AppText.bodySm(color: AppColors.onSurfaceVariant).copyWith(fontStyle: FontStyle.italic)),
                ],
                const SizedBox(height: 16),

                // Confidence tile
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('বিশ্বাসের মাত্রা', style: AppText.labelMd(color: AppColors.onSurfaceVariant)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: widget.needsReview ? AppColors.surfaceContainerHigh : AppColors.primary, borderRadius: BorderRadius.circular(999)),
                            child: Text(
                              widget.needsReview ? 'কম (${widget.confidencePercent}%)' : 'খুব বেশি (${widget.confidencePercent}%)',
                              style: AppText.labelMd(color: widget.needsReview ? AppColors.onSurface : Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (!widget.needsReview)
                        Row(
                          children: [
                            Row(children: List.generate(3, (_) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Container(width: 40, height: 36, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.eco, color: Colors.white, size: 22)),
                            ))),
                            const SizedBox(width: 8),
                            Text('লক্ষণ একদম সুস্পষ্ট', style: AppText.bodySm(color: AppColors.primary)),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (!widget.needsReview) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(color: AppColors.surfaceRaised, shape: BoxShape.circle),
                          child: const Icon(Icons.troubleshoot, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('রোগের সাধারণ লক্ষণ:', style: AppText.labelMd()),
                              Text('ছত্রাকের আক্রমণে পাতায় চোখের মতো দাগ ও শীষ শুকিয়ে যাওয়া।', style: AppText.bodyMd()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Reasons accordion
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Material(
                      color: AppColors.surfaceContainerLow,
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => setState(() => _reasonsExpanded = !_reasonsExpanded),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.help, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text('কেন এই রোগ মনে হচ্ছে?', style: AppText.labelLg()),
                                    ],
                                  ),
                                  Icon(_reasonsExpanded ? Icons.expand_less : Icons.expand_more, color: AppColors.onSurfaceVariant),
                                ],
                              ),
                            ),
                          ),
                          if (_reasonsExpanded)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                children: const [
                                  _ReasonTile(title: 'পাতার দাগের আকৃতি', body: 'পাতার কিনারা স্পষ্ট বাদামি ও কেন্দ্রের অংশ ছাই রঙের হয়ে রয়েছে।'),
                                  SizedBox(height: 8),
                                  _ReasonTile(title: 'আবহাওয়ার প্রভাব', body: 'বর্তমান স্যাঁতসেঁতে ও আর্দ্র আবহাওয়ায় এই ছত্রাকটি খুব দ্রুত ছড়ায়।'),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ] else
                  Text(
                    'আপনি চাইলে একজন কৃষি সহায়কের কাছে রিপোর্ট পাঠাতে পারেন।',
                    style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (!widget.needsReview)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.surfaceContainerHighest.withOpacity(0.6), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: AppColors.secondary, size: 26),
                  const SizedBox(width: 12),
                  Expanded(child: Text('ঘাবড়াবেন না! প্রাথমিক অবস্থায় সঠিক ছত্রাকনাশক স্প্রে করলে ফলন সম্পূর্ণ রক্ষা করা সম্ভব।', style: AppText.bodySm(color: AppColors.onSurface))),
                ],
              ),
            ),
          const SizedBox(height: 24),

          if (!widget.needsReview) ...[
            ElevatedButton.icon(
              onPressed: () => context.push('/treatment'),
              icon: const Icon(Icons.medication),
              label: const Text('চিকিৎসার সহজ পরামর্শ দেখুন'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.support_agent),
              label: const Text('কৃষি বিশেষজ্ঞের মতামত নিন'),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              icon: const Icon(Icons.support_agent),
              label: const Text('বিশেষজ্ঞের সাহায্য নিন'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
              icon: const Icon(Icons.replay),
              label: const Text('আরেকটি ছবি তুলুন'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surfaceRaised, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.labelMd()),
                Text(body, style: AppText.bodySm()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
