import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Opens the share sheet anchored to [context]'s widget. iOS requires a
/// non-zero sharePositionOrigin (popover anchor); falling back to a small
/// rect at screen center when the render box isn't usable.
Future<void> shareAnchored(BuildContext context, String text) {
  final box = context.findRenderObject() as RenderBox?;
  Rect origin;
  if (box != null && box.hasSize && !box.size.isEmpty) {
    origin = box.localToGlobal(Offset.zero) & box.size;
  } else {
    final size = MediaQuery.of(context).size;
    origin = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 1,
      height: 1,
    );
  }
  return Share.share(text, sharePositionOrigin: origin);
}
