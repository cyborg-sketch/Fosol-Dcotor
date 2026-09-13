import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';

/// Detail/review step of journey E: farmer/crop context, image/symptoms, the
/// AI suggestion, and approve/edit → submit verified guidance. Resolving here
/// flips the diagnosis to VERIFIED server-side (app/api/routes/field_worker.py),
/// which is what unblocks the farmer's "যাচাই হয়েছে" status.
class FieldWorkerReviewScreen extends StatefulWidget {
  const FieldWorkerReviewScreen({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  State<FieldWorkerReviewScreen> createState() => _FieldWorkerReviewScreenState();
}

class _FieldWorkerReviewScreenState extends State<FieldWorkerReviewScreen> {
  final _api = ApiClient();
  late final TextEditingController _notesController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final suggested = widget.item['top_disease_name_bn'] as String?;
    _notesController = TextEditingController(
      text: suggested != null ? '$suggested — পরামর্শ অনুমোদিত। জৈব চিকিৎসা দিয়ে শুরু করুন।' : '',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await _api.resolveReview(widget.item['diagnosis_id'] as String, _notesController.text.trim());
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('কৃষককে যাচাইকৃত পরামর্শ পাঠানো হয়েছে')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ব্যর্থ: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final confidence = (item['confidence'] as num).toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('কেস পর্যালোচনা')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surfaceRaised, borderRadius: BorderRadius.circular(16), boxShadow: AppElevation.level1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(radius: 20, backgroundColor: AppColors.surfaceContainer, child: Icon(Icons.person, color: AppColors.onSurfaceVariant)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['farmer_name'] as String, style: AppText.labelLg()),
                        Text(item['farmer_phone'] as String, style: AppText.bodySm()),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 28),
                _KeyValueRow(label: 'ফসল', value: item['crop_name_bn'] as String),
                _KeyValueRow(label: 'AI পরামর্শ', value: item['top_disease_name_bn'] as String? ?? 'অজানা'),
                _KeyValueRow(label: 'বিশ্বাসের মাত্রা', value: '${(confidence * 100).round()}%'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 180,
              width: double.infinity,
              color: AppColors.surfaceContainerHighest,
              child: item['image_ref'] != null && (item['image_ref'] as String).isNotEmpty
                  ? Image.network(
                      '${ApiClient().baseUrl}/images/${item['image_ref']}',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 180,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.image, size: 40, color: AppColors.onSurfaceVariant)),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                      },
                    )
                  : const Center(child: Icon(Icons.image, size: 40, color: AppColors.onSurfaceVariant)),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: AppColors.secondary),
                const SizedBox(width: 12),
                Expanded(child: Text('বিশ্বাসের মাত্রা কম হওয়ায় এই কেসটি স্বয়ংক্রিয়ভাবে সমাধান করা হয়নি — নিশ্চিত করার পর কৃষক ফলাফল পাবেন।', style: AppText.bodySm())),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('যাচাইকৃত পরামর্শ', style: AppText.labelLg()),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'কৃষকের জন্য চূড়ান্ত পরামর্শ লিখুন',
              filled: true,
              fillColor: AppColors.surfaceRaised,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.borderSoft)),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_circle),
            label: Text(_submitting ? 'পাঠানো হচ্ছে...' : 'কৃষককে পাঠান'),
          ),
        ],
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.bodySm()),
          Text(value, style: AppText.labelMd()),
        ],
      ),
    );
  }
}
