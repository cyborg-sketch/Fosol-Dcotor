import 'package:flutter/material.dart';

import '../../features/offline/offline_cache.dart';
import '../theme/app_theme.dart';

Future<bool?> showServerSettingsDialog(BuildContext context) async {
  final current = OfflineCache.getServerUrl() ?? 'http://10.177.56.48:8000';
  final controller = TextEditingController(text: current);

  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.dns, color: AppColors.primary),
          SizedBox(width: 8),
          Text('সার্ভার সেটিংস'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'কম্পিউটারের হটস্পট/ওয়াইফাই আইপি এবং পোর্ট লিখুন:',
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'সার্ভার URL',
              hintText: 'http://10.177.56.48:8000',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  controller.text = 'http://10.177.56.48:8000';
                },
                child: const Text('হটস্পট ডিফল্ট (10.177.56.48)'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('বাতিল'),
        ),
        ElevatedButton(
          onPressed: () async {
            final val = controller.text.trim();
            if (val.isNotEmpty) {
              await OfflineCache.setServerUrl(val);
              if (ctx.mounted) Navigator.of(ctx).pop(true);
            }
          },
          child: const Text('সংরক্ষণ'),
        ),
      ],
    ),
  );
}
