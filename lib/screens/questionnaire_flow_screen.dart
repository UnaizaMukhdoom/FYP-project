// lib/screens/questionnaire_flow_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/questionnaire_repo.dart';

class QuestionnaireFlowScreen extends StatefulWidget {
  const QuestionnaireFlowScreen({super.key});
  @override
  State<QuestionnaireFlowScreen> createState() => _QuestionnaireFlowScreenState();
}

class _QuestionnaireFlowScreenState extends State<QuestionnaireFlowScreen> {
  final _page = PageController();

  int _step = 0;

  String _name = '';

  bool _useFt = false;     // height units: false=cm, true=ft
  double _height = 165;    // stored in cm

  bool _useLb = false;     // weight units: false=kg, true=lb
  double _weight = 60;     // stored in kg

  String? _bodyType;
  String? _sizeRange;
  final Set<String> _fitPrefs = {};
  String? _styleGoal;

  QuestionnaireConfig? _cfg; // loaded once
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final cfg = await QuestionnaireRepo().fetch();
      setState(() {
        _cfg = cfg;
        // clamp defaults to config ranges
        _height = _height.clamp(cfg.heightMin, cfg.heightMax);
        _weight = _weight.clamp(cfg.weightMin, cfg.weightMax);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 6) {
      setState(() => _step++);
      _page.nextPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
    } else {
      _submitAnswersAndGo();
    }
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step--);
    _page.previousPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
  }

  Future<void> _submitAnswersAndGo() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      final doc = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('onboarding')
          .doc(); // auto id

      await doc.set({
        'name': _name,
        'useFt': _useFt,
        'heightCm': _height,
        'useLb': _useLb,
        'weightKg': _weight,
        'bodyType': _bodyType,
        'sizeRange': _sizeRange,
        'fitPrefs': _fitPrefs.toList(),
        'styleGoal': _styleGoal,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/selfie');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF101010),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _cfg == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF101010),
        body: Center(
          child: Text('Error loading questions: ${_error ?? "unknown"}',
              style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    final cfg = _cfg!;
    final pct = (_step + 1) / 7.0;

    return Scaffold(
      appBar: AppBar(
        leading: _step == 0 ? null : IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back),
        title: LinearProgressIndicator(value: pct, backgroundColor: Colors.black12, color: Colors.black87),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      backgroundColor: const Color(0xFF101010),
      body: SafeArea(
        child: PageView(
          controller: _page,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _NameStep(
              name: _name,
              onChanged: (v) => setState(() => _name = v),
              onContinue: _next,
            ),
            _HeightStep(
              useFt: _useFt,
              height: _height,
              min: cfg.heightMin,
              max: cfg.heightMax,
              onToggleUnit: (b) => setState(() => _useFt = b),
              onChanged: (v) => setState(() => _height = v),
              onContinue: _next,
            ),
            _WeightStep(
              useLb: _useLb,
              weight: _weight,
              min: cfg.weightMin,
              max: cfg.weightMax,
              onToggleUnit: (b) => setState(() => _useLb = b),
              onChanged: (v) => setState(() => _weight = v),
              onContinue: _next,
            ),
            _BodyTypeStep(
              options: cfg.bodyTypes,
              selected: _bodyType,
              onSelect: (v) => setState(() => _bodyType = v),
              onContinue: _next,
            ),
            _SizeRangeStep(
              options: cfg.sizeRanges,
              selected: _sizeRange,
              onSelect: (v) => setState(() => _sizeRange = v),
              onContinue: _next,
            ),
            _FitPrefStep(
              options: cfg.fitPrefs,
              selected: _fitPrefs,
              onToggle: (v) {
                setState(() => _fitPrefs.contains(v) ? _fitPrefs.remove(v) : _fitPrefs.add(v));
              },
              onContinue: _next,
            ),
            _StyleGoalStep(
              options: cfg.styleGoals,
              selected: _styleGoal,
              onSelect: (v) => setState(() => _styleGoal = v),
              onContinue: _submitAnswersAndGo,
            ),
          ],
        ),
      ),
    );
  }
}

/* ===========================
 * Step scaffolding + widgets
 * =========================== */

class _StepScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? imageWidget;
  final Widget body;
  final bool enabled;
  final VoidCallback onContinue;
  const _StepScaffold({
    required this.title,
    this.subtitle,
    this.imageWidget,
    required this.body,
    required this.enabled,
    required this.onContinue,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF101010),
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Image/Icon above title
                if (imageWidget != null) ...[
                  imageWidget!,
                  const SizedBox(height: 20),
                ],
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(subtitle!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: body)),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: enabled ? onContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameStep extends StatelessWidget {
  final String name;
  final ValueChanged<String> onChanged;
  final VoidCallback onContinue;
  const _NameStep({required this.name, required this.onChanged, required this.onContinue});
  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: "What would you like us\nto call you?",
      body: Center(
        child: TextField(
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Your name',
            hintStyle: TextStyle(color: Colors.white30),
          ),
          onChanged: onChanged,
        ),
      ),
      enabled: name.trim().isNotEmpty,
      onContinue: onContinue,
    );
  }
}

class _HeightStep extends StatelessWidget {
  final bool useFt;
  final double height, min, max;
  final ValueChanged<bool> onToggleUnit;
  final ValueChanged<double> onChanged;
  final VoidCallback onContinue;
  const _HeightStep({
    required this.useFt,
    required this.height,
    required this.min,
    required this.max,
    required this.onToggleUnit,
    required this.onChanged,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    // Make slider safe even if config has min>=max
    final double localMin = min;
    final double localMax = (max > min) ? max : (min + 1);
    final double clamped = height.clamp(localMin, localMax);
    final int? divs = (localMax - localMin) >= 1 ? (localMax - localMin).round() : null;

    final display = useFt ? (clamped / 30.48) : clamped; // stored cm -> ft display

    return _StepScaffold(
      title: "What's your\ncurrent height?",
      subtitle: 'Knowing your measurements helps us suggest\npersonalized outfits just for you!',
      body: Column(
        children: [
          _UnitSwitch(left: 'CM', right: 'FT', leftSelected: !useFt, onToggle: (isLeft) => onToggleUnit(!isLeft)),
          const SizedBox(height: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${display.toStringAsFixed(useFt ? 1 : 0)}${useFt ? ' FT' : ' CM'}',
                  style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: clamped,
                  min: localMin,
                  max: localMax,
                  divisions: divs, // null if the range is < 1 → no assertion
                  onChanged: onChanged,
                  activeColor: const Color(0xFF6B5CE7),
                  inactiveColor: Colors.white12,
                ),
              ],
            ),
          ),
        ],
      ),
      enabled: true,
      onContinue: onContinue,
    );
  }
}

class _WeightStep extends StatelessWidget {
  final bool useLb;
  final double weight, min, max;
  final ValueChanged<bool> onToggleUnit;
  final ValueChanged<double> onChanged;
  final VoidCallback onContinue;
  const _WeightStep({
    required this.useLb,
    required this.weight,
    required this.min,
    required this.max,
    required this.onToggleUnit,
    required this.onChanged,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    // Make slider safe even if config has min>=max
    final double localMin = min;
    final double localMax = (max > min) ? max : (min + 1);
    final double clamped = weight.clamp(localMin, localMax);
    final int? divs = (localMax - localMin) >= 1 ? (localMax - localMin).round() : null;

    final display = useLb ? (clamped * 2.20462) : clamped; // stored kg -> lb display

    return _StepScaffold(
      title: "What's your\ncurrent weight?",
      subtitle: 'Knowing your measurements helps us suggest\npersonalized outfits just for you!',
      body: Column(
        children: [
          _UnitSwitch(left: 'KG', right: 'LB', leftSelected: !useLb, onToggle: (isLeft) => onToggleUnit(!isLeft)),
          const SizedBox(height: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${display.toStringAsFixed(0)}${useLb ? ' LB' : ' KG'}',
                  style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: clamped,
                  min: localMin,
                  max: localMax,
                  divisions: divs, // null if the range is < 1
                  onChanged: onChanged,
                  activeColor: const Color(0xFF6B5CE7),
                  inactiveColor: Colors.white12,
                ),
              ],
            ),
          ),
        ],
      ),
      enabled: true,
      onContinue: onContinue,
    );
  }
}

class _BodyTypeStep extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onContinue;
  const _BodyTypeStep({
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.onContinue,
  });
  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Which body type best\ncharacterizes your shape?',
      body: ListView.separated(
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final t = options[i];
          final isSel = t == selected;
          return _DarkTile(
            label: t,
            selected: isSel,
            onTap: () => onSelect(t),
            imageWidget: _getBodyTypeIcon(t),
          );
        },
      ),
      enabled: selected != null,
      onContinue: onContinue,
    );
  }

  Widget? _getBodyTypeIcon(String bodyType) {
    final colorMap = {
      'Hourglass': const Color(0xFF90EE90), // Light green
      'Triangle': const Color(0xFFFFB6C1), // Light pink
      'Inverted triangle': const Color(0xFFFFA500), // Orange
      'Rectangle': const Color(0xFF90EE90), // Light green
      'Round': const Color(0xFF87CEEB), // Light blue
    };
    final color = colorMap[bodyType];
    if (color == null) return null;
    
    return Container(
      width: 50,
      height: 80,
      padding: const EdgeInsets.all(8),
      child: CustomPaint(
        painter: _BodyShapePainter(bodyType, color),
      ),
    );
  }
}

class _SizeRangeStep extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onContinue;
  const _SizeRangeStep({
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.onContinue,
  });
  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Which size range best\ndescribes you?',
      body: Column(
        children: [
          const SizedBox(height: 8),
          for (final t in options) ...[
            _DarkTile(
              label: t,
              selected: t == selected,
              onTap: () => onSelect(t),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
      enabled: selected != null,
      onContinue: onContinue,
    );
  }

}

class _FitPrefStep extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onContinue;
  const _FitPrefStep({
    required this.options,
    required this.selected,
    required this.onToggle,
    required this.onContinue,
  });
  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'How do you prefer\nyour clothes to fit?',
      subtitle: 'Select all options that fit you',
      body: ListView.separated(
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final t = options[i];
          final isSel = selected.contains(t);
          return _DarkTile(
            label: t,
            selected: isSel,
            onTap: () => onToggle(t),
            multi: true,
          );
        },
      ),
      enabled: selected.isNotEmpty,
      onContinue: onContinue,
    );
  }

}

class _StyleGoalStep extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onContinue;
  const _StyleGoalStep({
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.onContinue,
  });
  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: "What's your main\nstyle goal?",
      body: ListView.separated(
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final t = options[i];
          final isSel = t == selected;
          return _DarkTile(
            label: t,
            selected: isSel,
            onTap: () => onSelect(t),
          );
        },
      ),
      enabled: selected != null,
      onContinue: onContinue,
    );
  }

}

/* ===========================
 * UI helpers
 * =========================== */

class _UnitSwitch extends StatelessWidget {
  final String left, right;
  final bool leftSelected;
  final ValueChanged<bool> onToggle; // true => left, false => right
  const _UnitSwitch({required this.left, required this.right, required this.leftSelected, required this.onToggle});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.all(4),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _unitChip(left, leftSelected, () => onToggle(true)),
        const SizedBox(width: 6),
        _unitChip(right, !leftSelected, () => onToggle(false)),
      ]),
    );
  }

  Widget _unitChip(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18)),
        child: Text(
          text,
          style: TextStyle(color: selected ? Colors.black : Colors.white70, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _DarkTile extends StatelessWidget {
  final String label;
  final bool selected;
  final bool multi;
  final VoidCallback onTap;
  final Widget? imageWidget;
  const _DarkTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.multi = false,
    this.imageWidget,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1D1D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF6B5CE7) : Colors.transparent,
            width: selected ? 2 : 0,
          ),
        ),
        child: Row(
          children: [
            // Image/Icon on the left
            if (imageWidget != null) ...[
              imageWidget!,
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? const Color(0xFF6B5CE7) : Colors.white24,
                  width: 2,
                ),
                color: selected ? const Color(0xFF6B5CE7) : Colors.transparent,
              ),
              child: selected
                  ? Icon(
                      multi ? Icons.check : Icons.circle,
                      size: multi ? 14 : 8,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/* ===========================
 * Body Shape Custom Painter
 * =========================== */

class _BodyShapePainter extends CustomPainter {
  final String bodyType;
  final Color color;

  _BodyShapePainter(this.bodyType, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    const bodyTop = 0.0;
    final bodyHeight = size.height;
    final maxWidth = size.width;

    // Draw only torso (shoulders to hips) - no head, no neck
    switch (bodyType) {
      case 'Hourglass':
        _drawHourglass(canvas, paint, centerX, bodyTop, bodyHeight, maxWidth);
        break;
      case 'Triangle':
        _drawTriangle(canvas, paint, centerX, bodyTop, bodyHeight, maxWidth);
        break;
      case 'Inverted triangle':
        _drawInvertedTriangle(canvas, paint, centerX, bodyTop, bodyHeight, maxWidth);
        break;
      case 'Rectangle':
        _drawRectangle(canvas, paint, centerX, bodyTop, bodyHeight, maxWidth);
        break;
      case 'Round':
        _drawRound(canvas, paint, centerX, bodyTop, bodyHeight, maxWidth);
        break;
    }
  }

  void _drawHourglass(Canvas canvas, Paint paint, double centerX, double top, double height, double maxWidth) {
    // Hourglass: defined bust, narrower waist, proportional hips
    final shoulderWidth = maxWidth * 0.55;
    final waistWidth = maxWidth * 0.25;
    final hipWidth = maxWidth * 0.55;
    final waistY = top + height * 0.45;

    final path = Path();
    // Top (shoulders/bust)
    path.moveTo(centerX - shoulderWidth / 2, top);
    path.lineTo(centerX + shoulderWidth / 2, top);
    // Right side to waist
    path.lineTo(centerX + waistWidth / 2, waistY);
    // Right side to hips
    path.lineTo(centerX + hipWidth / 2, top + height);
    // Bottom (hips)
    path.lineTo(centerX - hipWidth / 2, top + height);
    // Left side to waist
    path.lineTo(centerX - waistWidth / 2, waistY);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawTriangle(Canvas canvas, Paint paint, double centerX, double top, double height, double maxWidth) {
    // Triangle: narrower shoulders/bust, wider hips
    final shoulderWidth = maxWidth * 0.3;
    final hipWidth = maxWidth * 0.65;

    final path = Path();
    // Top (narrow shoulders)
    path.moveTo(centerX - shoulderWidth / 2, top);
    path.lineTo(centerX + shoulderWidth / 2, top);
    // Right side (widening to hips)
    path.lineTo(centerX + hipWidth / 2, top + height);
    // Bottom (wide hips)
    path.lineTo(centerX - hipWidth / 2, top + height);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawInvertedTriangle(Canvas canvas, Paint paint, double centerX, double top, double height, double maxWidth) {
    // Inverted triangle: broader shoulders/bust, narrower hips
    final shoulderWidth = maxWidth * 0.65;
    final hipWidth = maxWidth * 0.3;

    final path = Path();
    // Top (wide shoulders)
    path.moveTo(centerX - shoulderWidth / 2, top);
    path.lineTo(centerX + shoulderWidth / 2, top);
    // Right side (narrowing to hips)
    path.lineTo(centerX + hipWidth / 2, top + height);
    // Bottom (narrow hips)
    path.lineTo(centerX - hipWidth / 2, top + height);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawRectangle(Canvas canvas, Paint paint, double centerX, double top, double height, double maxWidth) {
    // Rectangle: straight silhouette, minimal waist definition
    final width = maxWidth * 0.45;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, top + height / 2),
        width: width,
        height: height,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, paint);
  }

  void _drawRound(Canvas canvas, Paint paint, double centerX, double top, double height, double maxWidth) {
    // Round: fuller, rounded midsection
    final width = maxWidth * 0.55;
    final midY = top + height / 2;
    
    // Draw rounded/oval body shape
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, midY),
        width: width,
        height: height * 0.95,
      ),
      Radius.circular(width / 2.5),
    );
    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
