import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../offline/offline_banner.dart';

/// Mirrors stitch_fasol_doctor_agriculture_app_design/fasol_doctor_home —
/// greeting card, one dominant primary CTA, one amber-tinted secondary CTA,
/// an offline-readiness ribbon, and a short recent-reports list. No
/// analytics/statistics/weather cards belong here — those live on the BRAC
/// dashboard, never on the farmer's home screen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.eco, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('ফসল ডাক্তার', style: AppText.headlineSm(color: AppColors.primary)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'ভয়েস সহায়তা',
            onPressed: () {},
            icon: const Icon(Icons.volume_up, color: AppColors.secondary),
          ),
          const CircleAvatar(radius: 16, backgroundColor: AppColors.surfaceContainer, child: Icon(Icons.person, size: 18, color: AppColors.onSurfaceVariant)),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  // Greeting & status card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppElevation.level1,
                      border: const Border.fromBorderSide(AppElevation.level1Border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('আসসালামু আলাইকুম', style: AppText.headlineMd(color: AppColors.primary)),
                              const SizedBox(height: 4),
                              Text('রহমত আলী', style: AppText.headlineSm()),
                              const SizedBox(height: 8),
                              Text('আজ আপনার ফসলের অবস্থা কেমন?', style: AppText.bodyMd(color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.primaryFixed, borderRadius: BorderRadius.circular(999)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text('অনলাইন', style: AppText.labelSm(color: AppColors.onPrimaryFixedVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Primary CTA — Take Leaf Photo
                  Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push('/camera'),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 92),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                              child: const Icon(Icons.photo_camera, color: Colors.white, size: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ছবি তুলে রোগ দেখুন', style: AppText.headlineMd(color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text('পাতার ছবি তুলে সাথে সাথে সমাধান পান', style: AppText.bodySm(color: AppColors.primaryFixed)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Secondary CTA — Voice
                  Material(
                    color: AppColors.secondaryContainer.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push('/voice'),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 76),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(color: AppColors.secondaryContainer, shape: BoxShape.circle),
                              child: const Icon(Icons.mic, color: AppColors.onSecondaryContainer, size: 26),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('কথা বলে জানান', style: AppText.headlineSm()),
                                  const SizedBox(height: 4),
                                  Text('মুখে বলুন কী সমস্যা দেখছেন', style: AppText.bodySm(color: AppColors.secondary)),
                                ],
                              ),
                            ),
                            const Icon(Icons.graphic_eq, color: AppColors.secondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Offline readiness ribbon
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user, color: AppColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('ইন্টারনেট সংযোগ চালু আছে • অফলাইনেও কাজ করবে', style: AppText.bodySm()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Recent reports
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('সাম্প্রতিক রিপোর্ট', style: AppText.headlineSm()),
                      TextButton(
                        onPressed: () => context.push('/history'),
                        child: Row(
                          children: [
                            Text('সব দেখুন', style: AppText.labelMd(color: AppColors.primary)),
                            const Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const _RecentReportTile(
                    title: 'আমনের পাতা পোড়া রোগ',
                    date: 'গতকাল',
                    statusLabel: 'পরামর্শ সংরক্ষিত',
                    statusHighlighted: true,
                    footnote: 'স্প্রে ও যত্ন সংক্রান্ত গাইড',
                    footnoteIcon: Icons.check_circle,
                  ),
                  const SizedBox(height: 12),
                  const _RecentReportTile(
                    title: 'বেগুন ক্ষেত পরীক্ষণ',
                    date: '৩ দিন আগে',
                    statusLabel: 'সুস্থ ফসল',
                    statusHighlighted: false,
                    footnote: 'কোনো ক্ষতিকর পোকা নেই',
                    footnoteIcon: Icons.eco,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          if (i == 1) context.push('/history');
          if (i == 2) context.push('/profile');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'হোম'),
          NavigationDestination(icon: Icon(Icons.history_edu_outlined), selectedIcon: Icon(Icons.history_edu), label: 'রিপোর্ট'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'প্রোফাইল'),
        ],
      ),
    );
  }
}

class _RecentReportTile extends StatelessWidget {
  const _RecentReportTile({
    required this.title,
    required this.date,
    required this.statusLabel,
    required this.statusHighlighted,
    required this.footnote,
    required this.footnoteIcon,
  });

  final String title;
  final String date;
  final String statusLabel;
  final bool statusHighlighted;
  final String footnote;
  final IconData footnoteIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceRaised, borderRadius: BorderRadius.circular(16), boxShadow: AppElevation.level1),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.image, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(date, style: AppText.labelSm()),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusHighlighted ? AppColors.primaryFixed : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(statusLabel, style: AppText.labelSm(color: statusHighlighted ? AppColors.onPrimaryFixedVariant : AppColors.onSurface)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(title, style: AppText.headlineSm(), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(footnoteIcon, size: 16, color: statusHighlighted ? AppColors.primary : AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(child: Text(footnote, style: AppText.bodySm(color: statusHighlighted ? AppColors.primary : AppColors.onSurfaceVariant))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
