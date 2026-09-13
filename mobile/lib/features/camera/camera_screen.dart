import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';

/// Mirrors stitch_fasol_doctor_agriculture_app_design/camera_take_photo —
/// full-bleed viewfinder stage with organic aiming-corner brackets, a
/// high-contrast guidance pill, and the huge shutter button sitting in the
/// bottom 45% thumb zone alongside gallery/flash.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final _api = ApiClient();
  bool _flashOn = false;
  static final List<Map<String, dynamic>> _defaultCrops = [
    {'id': 'fb68f592-2b1e-4295-91e0-26d672c226cb', 'name_en': 'Rice', 'name_bn': 'ধান'},
    {'id': '5968c8c3-7a80-4ba3-b12f-98f608134f76', 'name_en': 'Jute', 'name_bn': 'পাট'},
    {'id': '8404d426-dba2-41ae-8ca3-095619a4a2cd', 'name_en': 'Tomato', 'name_bn': 'টমেটো'},
    {'id': '1c55ff3c-0dae-45c9-ae22-a224ac5cde51', 'name_en': 'Brinjal (Eggplant)', 'name_bn': 'বেগুন'},
    {'id': '4f3c4cc3-6987-4603-acd2-360e9f561bf1', 'name_en': 'Potato', 'name_bn': 'আলু'},
    {'id': 'eeafda52-128c-4216-9703-21cd6c6444f5', 'name_en': 'Corn (Maize)', 'name_bn': 'ভুট্টা'},
    {'id': '19712227-25c2-44d7-ae1e-9cb5aa5a2b6f', 'name_en': 'Bell Pepper', 'name_bn': 'ক্যাপসিকাম'},
    {'id': '322f226e-4196-4f4a-802a-72943ca9dc09', 'name_en': 'Apple', 'name_bn': 'আপেল'},
    {'id': 'e6c3292d-dfdf-46b1-b7e6-3ec8bf58edbc', 'name_en': 'Grape', 'name_bn': 'আঙুর'},
    {'id': 'a402c71b-3fac-4670-bafc-0c070557e4cc', 'name_en': 'Cherry', 'name_bn': 'চেরি'},
    {'id': '4fa46bea-332c-44d8-8361-92916a279fbe', 'name_en': 'Peach', 'name_bn': 'পীচ'},
    {'id': '46019a4c-d172-428d-8851-b0e16188912a', 'name_en': 'Strawberry', 'name_bn': 'স্ট্রবেরি'},
  ];

  bool _capturing = false;
  List<Map<String, dynamic>> _crops = List.from(_defaultCrops);
  String? _selectedCropId = 'fb68f592-2b1e-4295-91e0-26d672c226cb';

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops() async {
    try {
      final crops = await _api.getCrops();
      if (!mounted) return;
      if (crops.isNotEmpty) {
        setState(() {
          _crops = crops;
          if (!_crops.any((c) => c['id'] == _selectedCropId)) {
            _selectedCropId = _crops.first['id'] as String;
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      // Default crops are already loaded, so user is never blocked
    }
  }

  String? get _selectedCropNameBn {
    for (final crop in _crops) {
      if (crop['id'] == _selectedCropId) return crop['name_bn'] as String?;
    }
    return null;
  }

  Future<void> _capture(ImageSource source) async {
    if (_selectedCropId == null) return;
    if (source == ImageSource.camera) {
      setState(() => _capturing = true);
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _capturing = false);
    }
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    context.push('/analyzing', extra: {
      'type': 'image',
      'bytes': bytes,
      'filename': file.name,
      'contentType': _guessContentType(file.name),
      'cropId': _selectedCropId,
      'cropNameBn': _selectedCropNameBn,
    });
  }

  String _guessContentType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg'; // gallery/camera picks default to jpeg unless the source file was already png/webp
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceField,
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation header bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppElevation.level1,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                      tooltip: 'ফিরে যান',
                      onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                    ),
                  ),
                  const Spacer(),
                  Text('ছবি তুলে রোগ দেখুন', style: AppText.headlineSm()),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppElevation.level1,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.home_outlined, color: AppColors.onSurface),
                      tooltip: 'হোম',
                      onPressed: () => context.go('/home'),
                    ),
                  ),
                ],
              ),
            ),
            // Crop selector — must be chosen before capture/upload so the
            // diagnosis is restricted to the right crop's disease list.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  boxShadow: AppElevation.level1,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.eco, color: AppColors.primary, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedCropId,
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 28),
                          hint: const Text(
                            'ফসল নির্বাচন করুন',
                            style: TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamilyFallback: ['Noto Sans Bengali', 'Bangla', 'sans-serif'],
                            ),
                          ),
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamilyFallback: ['Noto Sans Bengali', 'Bangla', 'sans-serif'],
                          ),
                          selectedItemBuilder: (BuildContext context) {
                            return _crops.map<Widget>((crop) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  crop['name_bn'] as String,
                                  style: const TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontFamilyFallback: ['Noto Sans Bengali', 'Bangla', 'sans-serif'],
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          items: _crops.map((crop) {
                            final isSelected = crop['id'] == _selectedCropId;
                            return DropdownMenuItem<String>(
                              value: crop['id'] as String,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.eco,
                                      color: isSelected ? AppColors.primary : const Color(0xFF9CA3AF),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        crop['name_bn'] as String,
                                        style: TextStyle(
                                          color: isSelected ? AppColors.primary : const Color(0xFF111827),
                                          fontSize: 16,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                          fontFamilyFallback: const ['Noto Sans Bengali', 'Bangla', 'sans-serif'],
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(Icons.check, color: AppColors.primary, size: 20),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedCropId = value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Viewfinder stage
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: AppColors.surfaceContainer,
                    child: Stack(
                      children: [
                        // Ambient vignette to simulate the live camera feed backdrop.
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.black.withOpacity(0.55), Colors.transparent, Colors.black.withOpacity(0.65)],
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(999)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.eco, color: AppColors.primaryFixed, size: 18),
                                          const SizedBox(width: 8),
                                          Flexible(child: Text('পাতা বা ফসলটি ফ্রেমের মাঝে রাখুন', style: AppText.labelSm(color: Colors.white), overflow: TextOverflow.ellipsis)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const CircleAvatar(
                                    radius: 22,
                                    backgroundColor: AppColors.secondaryContainer,
                                    child: Icon(Icons.volume_up, color: AppColors.onSecondaryContainer),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Aiming reticle
                            SizedBox(
                              width: 220,
                              height: 220,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CustomPaint(size: const Size(220, 220), painter: _ReticleCornersPainter()),
                                  Container(
                                    width: 88,
                                    height: 88,
                                    decoration: BoxDecoration(color: AppColors.primaryFixed.withOpacity(0.2), shape: BoxShape.circle),
                                    child: Center(
                                      child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.primaryFixed, shape: BoxShape.circle)),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(999)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.check_circle, color: AppColors.primaryFixed, size: 16),
                                          const SizedBox(width: 6),
                                          Text('রোগের লক্ষণ শনাক্ত হয়েছে', style: AppText.labelSm(color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(999)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_capturing ? Icons.hourglass_top : Icons.verified, color: AppColors.primaryFixed, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      _capturing ? 'ছবি যাচাই করা হচ্ছে...' : 'ছবিটি পরিষ্কার ও স্পষ্ট আলোতে আছে',
                                      style: AppText.labelSm(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Bottom action panel (thumb zone)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Opacity(
                        opacity: _selectedCropId == null ? 0.4 : 1.0,
                        child: _RoundActionButton(
                          icon: Icons.photo_library,
                          iconColor: AppColors.primary,
                          label: 'গ্যালারি',
                          onTap: _selectedCropId == null ? () {} : () => _capture(ImageSource.gallery),
                        ),
                      ),
                      Opacity(
                        opacity: _selectedCropId == null ? 0.4 : 1.0,
                        child: GestureDetector(
                          onTap: _selectedCropId == null ? null : () => _capture(ImageSource.camera),
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: const BoxDecoration(color: AppColors.surfaceRaised, shape: BoxShape.circle, boxShadow: AppElevation.level2),
                            child: Center(
                              child: Container(
                                width: 62,
                                height: 62,
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                child: const Icon(Icons.photo_camera, color: Colors.white, size: 32),
                              ),
                            ),
                          ),
                        ),
                      ),
                      _RoundActionButton(
                        icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                        iconColor: AppColors.secondary,
                        label: 'ফ্ল্যাশ',
                        onTap: () => setState(() => _flashOn = !_flashOn),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(color: Color(0xFFFFDAD6), shape: BoxShape.circle),
                          child: const Icon(Icons.info, size: 20, color: Color(0xFF93000A)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('অস্পষ্ট বা দূরে থেকে ছবি তুলবেন না', style: AppText.labelMd()),
                              Text('সঠিক সমাধানের জন্য আক্রান্ত পাতার খুব কাছে আনুন', style: AppText.bodySm()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({required this.icon, required this.iconColor, required this.label, required this.onTap});

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 26),
              const SizedBox(height: 2),
              Text(label, style: AppText.labelSm()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws the four organic aiming-corner brackets from the Stitch SVG.
class _ReticleCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryFixed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const r = 12.0; // corner radius
    const len = 32.0; // arm length
    final w = size.width, h = size.height;

    void corner(Offset origin, double dx, double dy) {
      final path = Path()
        ..moveTo(origin.dx + dx * len, origin.dy)
        ..lineTo(origin.dx + dx * r, origin.dy)
        ..quadraticBezierTo(origin.dx, origin.dy, origin.dx, origin.dy + dy * r)
        ..lineTo(origin.dx, origin.dy + dy * len);
      canvas.drawPath(path, paint);
    }

    corner(const Offset(0, 0), 1, 1);
    corner(Offset(w, 0), -1, 1);
    corner(Offset(0, h), 1, -1);
    corner(Offset(w, h), -1, -1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
