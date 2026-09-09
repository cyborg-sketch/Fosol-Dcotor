import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';

/// Reassuring loading state while the real pipeline runs — no fake technical
/// details or meaningless percentages. [input] is a typed payload from
/// CameraScreen (`{'type': 'image', 'bytes', 'filename', 'contentType'}`) or
/// VoiceScreen (`{'type': 'symptoms', 'text'}`); an image is uploaded to
/// /images/upload first (EfficientNet-B0 runs server-side on the stored
/// file), symptom text is sent straight to /diagnoses for BanglaBERT
/// similarity matching against this crop's seeded diseases.
class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({super.key, this.input});

  final Object? input;

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  final _api = ApiClient();
  String? _error;

  @override
  void initState() {
    super.initState();
    _runDiagnosis();
  }

  Future<void> _runDiagnosis() async {
    setState(() => _error = null);
    try {
      final demoContext = await _api.getDemoContext();
      final input = widget.input;

      String? imageRef;
      Map<String, dynamic>? symptomsPayload;

      if (input is Map && input['type'] == 'image') {
        imageRef = await _api.uploadImage(
          input['bytes'] as Uint8List,
          filename: input['filename'] as String,
          contentType: input['contentType'] as String,
        );
      } else if (input is Map && input['type'] == 'symptoms') {
        symptomsPayload = {
          'crop': demoContext['crop_name_bn'],
          'symptoms': [input['text'] as String],
        };
      }

      final result = await _api.createDiagnosis(
        farmerId: demoContext['farmer_id'] as String,
        cropId: demoContext['crop_id'] as String,
        imageRef: imageRef,
        symptoms: symptomsPayload,
        source: 'online',
      );

      if (mounted) context.go('/diagnosis/${result['id']}', extra: result);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off, size: 48, color: AppColors.onSurfaceVariant),
                const SizedBox(height: 16),
                Text('পরীক্ষা করা যায়নি — সংযোগ পরীক্ষা করুন', textAlign: TextAlign.center, style: AppText.bodyMd()),
                const SizedBox(height: 8),
                Text(_error!, textAlign: TextAlign.center, style: AppText.labelSm()),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _runDiagnosis, child: const Text('আবার চেষ্টা করুন')),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: () => context.pop(), child: const Text('ফিরে যান')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco, size: 64, color: AppColors.primary),
            const SizedBox(height: 20),
            Text('আপনার ফসলটি পরীক্ষা করছি…', style: AppText.bodyMd()),
            const SizedBox(height: 16),
            const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
