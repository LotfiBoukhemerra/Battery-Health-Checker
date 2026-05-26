import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/constants/app_colors.dart';

/// Animated wave/liquid battery indicator.
/// Shows battery percentage inside a circular container
/// with a sine-wave surface that animates like liquid water.
class WaveBatteryIndicator extends StatefulWidget {
  final int level;
  final bool isCharging;
  final double size;

  /// Whether the animation should be running.
  /// Set to `false` when the widget is off-screen to
  /// avoid wasting CPU on invisible frames.
  final bool isActive;

  const WaveBatteryIndicator({
    super.key,
    required this.level,
    this.isCharging = false,
    this.size = 200,
    this.isActive = true,
  });

  @override
  State<WaveBatteryIndicator> createState() => _WaveBatteryIndicatorState();
}

class _WaveBatteryIndicatorState extends State<WaveBatteryIndicator>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _levelController;
  late Animation<double> _levelAnimation;
  double _currentLevel = 0;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.isActive) _waveController.repeat();

    _levelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _levelAnimation = Tween<double>(begin: 0, end: widget.level / 100.0)
        .animate(
          CurvedAnimation(parent: _levelController, curve: Curves.easeInOut),
        );

    _currentLevel = widget.level / 100.0;
    _levelController.forward();
  }

  @override
  void didUpdateWidget(WaveBatteryIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Start or stop wave based on visibility.
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _waveController.repeat();
      } else {
        _waveController.stop();
      }
    }

    if (oldWidget.level != widget.level) {
      _levelAnimation =
          Tween<double>(
            begin: _currentLevel,
            end: widget.level / 100.0,
          ).animate(
            CurvedAnimation(parent: _levelController, curve: Curves.easeInOut),
          );
      _currentLevel = widget.level / 100.0;
      _levelController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getBatteryColor(widget.level);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_waveController, _levelAnimation]),
        builder: (context, child) {
          return CustomPaint(
            painter: _WavePainter(
              wavePhase: _waveController.value,
              level: _levelAnimation.value,
              color: color,
              isCharging: widget.isCharging,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isCharging)
                    Icon(
                      // Icons.bolt,
                      HugeIcons.strokeRoundedFlash,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: widget.size * 0.12,
                    ),
                  Text(
                    '${widget.level}%',
                    style: TextStyle(
                      fontSize: widget.size * 0.22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double wavePhase;
  final double level;
  final Color color;
  final bool isCharging;

  _WavePainter({
    required this.wavePhase,
    required this.level,
    required this.color,
    required this.isCharging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw outer ring with glow
    final outerGlow = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, radius + 4, outerGlow);

    // Draw background circle
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw border ring
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, borderPaint);

    // Clip to circle for wave
    canvas.save();
    final clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius - 2));
    canvas.clipPath(clipPath);

    // Draw wave fill
    final waterLevel = size.height * (1 - level);
    final waveAmplitude = isCharging ? 8.0 : 6.0;
    final waveFrequency = isCharging ? 2.5 : 2.0;

    // First wave (darker, behind)
    final wave1Path = Path();
    wave1Path.moveTo(0, size.height);

    for (var x = 0.0; x <= size.width; x += 2) {
      final normalizedX = x / size.width;
      final y =
          waterLevel +
          sin(
                (normalizedX * waveFrequency * 2 * pi) +
                    (wavePhase * 2 * pi) +
                    pi,
              ) *
              waveAmplitude *
              0.6;
      wave1Path.lineTo(x, y);
    }

    wave1Path.lineTo(size.width, size.height);
    wave1Path.close();

    final wave1Paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawPath(wave1Path, wave1Paint);

    // Second wave (main, in front)
    final wave2Path = Path();
    wave2Path.moveTo(0, size.height);

    for (var x = 0.0; x <= size.width; x += 2) {
      final normalizedX = x / size.width;
      final y =
          waterLevel +
          sin((normalizedX * waveFrequency * 2 * pi) + (wavePhase * 2 * pi)) *
              waveAmplitude;
      wave2Path.lineTo(x, y);
    }

    wave2Path.lineTo(size.width, size.height);
    wave2Path.close();

    // Gradient from top of water to bottom
    final wavePaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.7), color],
          ).createShader(
            Rect.fromLTWH(0, waterLevel, size.width, size.height - waterLevel),
          )
      ..style = PaintingStyle.fill;
    canvas.drawPath(wave2Path, wavePaint);

    canvas.restore();

    // Re-draw the border ring on top
    canvas.drawCircle(center, radius - 1, borderPaint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.wavePhase != wavePhase ||
      oldDelegate.level != level ||
      oldDelegate.color != color;
}
