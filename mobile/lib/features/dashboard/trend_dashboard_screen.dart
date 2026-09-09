import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';

/// Journey F: dashboard → regional disease trend → crop/disease filters →
/// anonymized counts. Per the Stitch brief this is for BRAC staff, not
/// farmers — kept executive and readable, no per-farmer identifiers beyond
/// what /dashboard/trends already aggregates away.
class TrendDashboardScreen extends StatefulWidget {
  const TrendDashboardScreen({super.key});

  @override
  State<TrendDashboardScreen> createState() => _TrendDashboardScreenState();
}

class _TrendDashboardScreenState extends State<TrendDashboardScreen> {
  final _api = ApiClient();
  late Future<Map<String, dynamic>> _trends;

  @override
  void initState() {
    super.initState();
    _trends = _api.getDashboardTrends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('আঞ্চলিক প্রবণতা')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _trends,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('ডেটা লোড করা যায়নি', style: AppText.bodyMd()));
          }
          final data = snapshot.data!;
          final byRegion = (data['by_region'] as List).cast<Map<String, dynamic>>();
          final topDiseases = (data['top_diseases'] as List).cast<Map<String, dynamic>>();
          final maxRegionCount = byRegion.isEmpty ? 1 : byRegion.map((r) => r['count'] as int).reduce((a, b) => a > b ? a : b);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: 'মোট নির্ণয়',
                      value: '${data['total_diagnoses']}',
                      icon: Icons.fact_check,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      label: 'কম বিশ্বাসযোগ্য কেস',
                      value: '${data['needs_review']}',
                      icon: Icons.help_outline,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('জেলাভিত্তিক নির্ণয়', style: AppText.headlineSm()),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surfaceRaised, borderRadius: BorderRadius.circular(16), boxShadow: AppElevation.level1),
                child: Column(
                  children: byRegion.isEmpty
                      ? [Text('কোনো তথ্য নেই', style: AppText.bodySm())]
                      : byRegion.map((r) {
                          final count = r['count'] as int;
                          final ratio = count / maxRegionCount;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(r['district'] as String, style: AppText.labelMd()),
                                    Text('$count', style: AppText.labelMd(color: AppColors.primary)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    minHeight: 8,
                                    backgroundColor: AppColors.surfaceContainer,
                                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Text('প্রধান রোগসমূহ', style: AppText.headlineSm()),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.surfaceRaised, borderRadius: BorderRadius.circular(16), boxShadow: AppElevation.level1),
                child: Column(
                  children: topDiseases.isEmpty
                      ? [Padding(padding: const EdgeInsets.all(12), child: Text('কোনো তথ্য নেই', style: AppText.bodySm()))]
                      : topDiseases.map((d) {
                          return ListTile(
                            leading: const Icon(Icons.coronavirus_outlined, color: AppColors.pestNotice),
                            title: Text(d['disease_name_bn'] as String, style: AppText.bodyMd()),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(999)),
                              child: Text('${d['count']}', style: AppText.labelMd()),
                            ),
                          );
                        }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceRaised, borderRadius: BorderRadius.circular(16), boxShadow: AppElevation.level1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value, style: AppText.headlineLg()),
          Text(label, style: AppText.bodySm()),
        ],
      ),
    );
  }
}
