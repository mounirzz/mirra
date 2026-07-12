import 'package:flutter/material.dart';

class MirraPalette {
  const MirraPalette({
    required this.id,
    required this.label,
    required this.accentA,
    required this.accentB,
    required this.accentC,
  });

  final String id;
  final String label;
  final Color accentA;
  final Color accentB;
  final Color accentC;

  LinearGradient get grad => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentA, Color.lerp(accentA, accentB, 0.5)!, accentB],
    stops: const [0.0, 0.5, 1.0],
  );

  LinearGradient get gradSoft => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentA.withValues(alpha: 0.35), accentB.withValues(alpha: 0.35)],
  );

  static const cabin = MirraPalette(
    id: 'cabin',
    label: 'Cabin',
    accentA: Color(0xFFB79DE8),
    accentB: Color(0xFFF0B2A3),
    accentC: Color(0xFFF8D2A8),
  );

  static const midnight = MirraPalette(
    id: 'midnight',
    label: 'Midnight',
    accentA: Color(0xFF6E8CF0),
    accentB: Color(0xFF7C6FE0),
    accentC: Color(0xFF4FD1C5),
  );

  static const blush = MirraPalette(
    id: 'blush',
    label: 'Blush',
    accentA: Color(0xFFF0A8C0),
    accentB: Color(0xFFF6C6A0),
    accentC: Color(0xFFE89ADB),
  );

  static const all = <MirraPalette>[cabin, midnight, blush];

  static MirraPalette byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => cabin);
}
