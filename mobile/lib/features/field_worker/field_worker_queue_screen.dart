import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import 'field_worker_review_screen.dart';

/// Journey E from IMPLEMENTATION_PLAN.md: login → pending cases → farmer/crop
/// context → image/symptoms → AI suggestion → approve/edit → submit verified
/// guidance. Tablet/desktop-responsive per the design brief — denser than
/// the farmer screens is expected here.
class FieldWorkerQueueScreen extends StatefulWidget {
  const FieldWorkerQueueScreen({super.key});

  @override
  State<FieldWorkerQueueScreen> createState() => _FieldWorkerQueueScreenState();
}

class _FieldWorkerQueueScreenState extends State<FieldWorkerQueueScreen> {
  final _api = ApiClient();
  late Future<List<Map<String, dynamic>>> _queue;

  @override
  void initState() {
    super.initState();
    _queue = _api.getFieldWorkerQueue();
  }

  Future<void> _refresh() async {
    setState(() => _queue = _api.getFieldWorkerQueue());
    await _queue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'ফিরে যান',
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('যাচাইয়ের অপেক্ষায়'),
        actions: [
          IconButton(
            tooltip: 'অঞ্চলভিত্তিক প্রবণতা',
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.push('/dashboard'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _queue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (snapshot.hasError) {
              return _ErrorState(error: snapshot.error.toString(), onRetry: _refresh);
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 48, color: AppColors.primary),
                        const SizedBox(height: 12),
                        Text('পর্যালোচনার জন্য কোনো কেস নেই', style: AppText.bodyMd()),
                      ],
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final item = items[i];
                final confidence = (item['confidence'] as num).toDouble();
                return Material(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => FieldWorkerReviewScreen(item: item)),
                    ).then((_) => _refresh()),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: AppElevation.level1),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(color: Color(0xFFFFDCC3), shape: BoxShape.circle),
                            child: const Icon(Icons.priority_high, color: Color(0xFF6E3900)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${item['farmer_name']} • ${item['crop_name_bn']}', style: AppText.labelLg()),
                                const SizedBox(height: 4),
                                Text(item['top_disease_name_bn'] as String? ?? 'অজানা সমস্যা', style: AppText.bodyMd()),
                                const SizedBox(height: 4),
                                Text('বিশ্বাসের মাত্রা: ${(confidence * 100).round()}%', style: AppText.bodySm()),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});
  final String error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, size: 40, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 12),
          Text('তালিকা লোড করা যায়নি', style: AppText.bodyMd()),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('আবার চেষ্টা করুন')),
        ],
      ),
    );
  }
}
