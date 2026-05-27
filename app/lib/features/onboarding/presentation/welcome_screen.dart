import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/ios_status_bar.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _AmbientGradient(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: MirraSpace.lg),
              child: Column(
                children: [
                  const IosStatusSpacer(height: 24),
                  const Spacer(),
                  Text(
                    'Welcome to Mirra',
                    style: MirraType.serif(
                      size: 36,
                      color: Colors.white,
                      style: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Reflect daily. Reshape gently.',
                    style: MirraType.ui(
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.78),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.go('/onboarding'),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      children: [
                        Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 30,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Swipe up',
                          style: MirraType.ui(
                            size: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                            weight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientGradient extends StatelessWidget {
  const _AmbientGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1F2438),
            Color(0xFF2A2440),
            Color(0xFF3A2B45),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.4),
                  radius: 0.9,
                  colors: [
                    MirraColors.accentA.withValues(alpha: 0.45),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.5, 0.6),
                  radius: 1.0,
                  colors: [
                    MirraColors.accentB.withValues(alpha: 0.32),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
