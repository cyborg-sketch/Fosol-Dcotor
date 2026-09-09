import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/theme/app_theme.dart';

/// Mirrors stitch_fasol_doctor_agriculture_app_design/voice_input — big
/// pulsing mic target, waveform strip, editable live-transcription card,
/// and the dominant/secondary action stack.
class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  final _speech = stt.SpeechToText();
  bool _listening = false;
  String _transcript = '';

  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    final available = await _speech.initialize();
    if (!available) return;
    setState(() => _listening = true);
    _speech.listen(
      localeId: 'bn_BD',
      onResult: (result) => setState(() => _transcript = result.recognizedWords),
    );
  }

  void _editTranscript() async {
    final controller = TextEditingController(text: _transcript);
    final updated = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('লক্ষণ সংশোধন করুন'),
        content: TextField(controller: controller, maxLines: 3, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('সংরক্ষণ')),
        ],
      ),
    );
    if (updated != null && updated.trim().isNotEmpty) {
      setState(() => _transcript = updated.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasTranscript = _transcript.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mic, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('ভয়েস সহকারী সক্রিয়', style: AppText.labelSm(color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('কথা বলে রোগের লক্ষণ বলুন', textAlign: TextAlign.center, style: AppText.headlineLg()),
              const SizedBox(height: 8),
              Text('আপনার আঞ্চলিক ভাষায় সহজ করে বলুন', textAlign: TextAlign.center, style: AppText.bodyMd(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 24),

              // Pulsing mic target
              SizedBox(
                width: 224,
                height: 224,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _PulsingRing(size: 192, color: AppColors.primaryFixed.withOpacity(0.35)),
                    Container(width: 160, height: 160, decoration: BoxDecoration(color: AppColors.primaryFixedDim.withOpacity(0.4), shape: BoxShape.circle)),
                    GestureDetector(
                      onTap: _toggleListening,
                      child: Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(color: _listening ? AppColors.primary : AppColors.surfaceContainerHigh, shape: BoxShape.circle, boxShadow: AppElevation.level2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mic, size: 40, color: _listening ? Colors.white : AppColors.onSurface),
                            const SizedBox(height: 4),
                            Text(_listening ? 'শুনছি...' : 'শুরু করুন', style: AppText.labelSm(color: _listening ? Colors.white : AppColors.onSurface)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Waveform strip
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 320),
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: AppColors.surfaceRaised, borderRadius: BorderRadius.circular(999), boxShadow: AppElevation.level1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [16.0, 28.0, 32.0, 20.0, 30.0, 22.0, 12.0]
                      .map((h) => Container(width: 6, height: h, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(999))))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Live transcription card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.surfaceRaised, borderRadius: BorderRadius.circular(16), boxShadow: AppElevation.level1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.record_voice_over, size: 20, color: AppColors.secondary),
                            const SizedBox(width: 8),
                            Text('আপনার বিবরণ', style: AppText.labelMd()),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: _editTranscript, // always available — typed text is a real fallback, not just an edit
                          icon: const Icon(Icons.edit, size: 16),
                          label: Text('সংশোধন করুন', style: AppText.labelSm(color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasTranscript ? '"$_transcript"' : '"বলুন, আমরা মনোযোগ দিয়ে শুনছি..."',
                      style: AppText.bodyLg(),
                    ),
                    if (hasTranscript) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.verified, size: 18, color: AppColors.tertiary),
                                const SizedBox(width: 8),
                                Text('লক্ষণ স্পষ্টভাবে শনাক্ত হয়েছে', style: AppText.labelSm(color: AppColors.tertiary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(color: Color(0xFFFFDCC3), shape: BoxShape.circle),
                      child: const Icon(Icons.hearing, size: 22, color: Color(0xFF6E3900)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('পরামর্শ: কথা বলার সময় ফোনটি মুখের কাছে রাখুন ও চারপাশের আওয়াজ কমিয়ে নিন', style: AppText.bodySm()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: hasTranscript
                    ? () => context.push('/analyzing', extra: {'type': 'symptoms', 'text': _transcript})
                    : null,
                icon: const Icon(Icons.check_circle),
                label: const Text('এই তথ্যে রোগ দেখুন'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => setState(() => _transcript = ''),
                icon: const Icon(Icons.replay, color: AppColors.secondary),
                label: const Text('আবার বলুন'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.support_agent, size: 18, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text('বুঝে উঠতে সমস্যা হলে সরাসরি বিশেষজ্ঞের সাথে কথা বলুন', style: AppText.labelSm()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingRing extends StatefulWidget {
  const _PulsingRing({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  State<_PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<_PulsingRing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final scale = 0.85 + (_controller.value * 0.3);
        final opacity = (1 - _controller.value).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(width: widget.size, height: widget.size, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)),
          ),
        );
      },
    );
  }
}
