import 'package:flutter/material.dart';

/// Use these getters so text and muted colors follow [AppTheme] / [ColorScheme].
extension AppThemeContext on BuildContext {
  ColorScheme get appColors => Theme.of(this).colorScheme;

  TextTheme get appText => Theme.of(this).textTheme;

  /// Secondary labels, captions, app bar subtitles.
  Color get appOnSurfaceMuted => Theme.of(this).colorScheme.onSurfaceVariant;

  /// Surfaces for chips, breadcrumbs, search fields (light: lilac tint; dark: elevated surface).
  Color get appSurfaceContainer => Theme.of(this).colorScheme.surfaceContainerHighest;
}
