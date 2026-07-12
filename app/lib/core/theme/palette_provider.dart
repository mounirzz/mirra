import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../storage/hive_boxes.dart';
import 'palette.dart';
import 'theme_selection.dart';

class ThemeSelectionNotifier extends StateNotifier<ThemeSelection> {
  ThemeSelectionNotifier() : super(_initialSelection());

  /// A previously saved custom photo can go missing (app reinstall, user
  /// cleared storage, etc). Fall back to the default palette rather than
  /// pointing the UI at a file that no longer exists.
  static ThemeSelection _initialSelection() {
    final selection = ThemeSelection.decode(
      MirraBoxes.current.themeChoice,
      MirraBoxes.current.customPhotoPath,
    );
    if (selection.kind == ThemeKind.customPhoto &&
        !File(selection.customPhotoPath!).existsSync()) {
      return const ThemeSelection.color(MirraPalette.cabin);
    }
    return selection;
  }

  Future<void> selectPalette(MirraPalette palette) =>
      _select(ThemeSelection.color(palette));

  Future<void> selectPresetPhoto(ThemePhoto photo) =>
      _select(ThemeSelection.presetPhoto(photo));

  /// Opens the system photo picker and, if the user picks an image, copies
  /// it into app storage (picker cache paths aren't stable across launches)
  /// and makes it the active theme.
  Future<void> pickCustomPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final srcPath = picked.path;
    final dotIndex = srcPath.lastIndexOf('.');
    final ext = dotIndex != -1 ? srcPath.substring(dotIndex) : '.jpg';
    // A unique name per import matters: FileImage caches by path, so
    // reusing the same path would keep showing the previous photo even
    // after the file on disk changed.
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final dest = File('${dir.path}/theme_photo_$stamp$ext');
    await File(srcPath).copy(dest.path);

    final previousPath = MirraBoxes.current.customPhotoPath;
    await _select(ThemeSelection.customPhoto(dest.path));

    if (previousPath != null && previousPath != dest.path) {
      final previous = File(previousPath);
      if (await previous.exists()) await previous.delete();
    }
  }

  Future<void> _select(ThemeSelection selection) async {
    state = selection;
    await MirraBoxes.updatePrefs(
      (p) => p.copyWith(
        themeChoice: selection.encode(),
        customPhotoPath: selection.kind == ThemeKind.customPhoto
            ? selection.customPhotoPath
            : p.customPhotoPath,
      ),
    );
  }
}

final themePaletteProvider =
    StateNotifierProvider<ThemeSelectionNotifier, ThemeSelection>(
      (ref) => ThemeSelectionNotifier(),
    );
