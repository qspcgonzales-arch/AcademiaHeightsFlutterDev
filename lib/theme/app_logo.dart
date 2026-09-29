import 'package:flutter/material.dart';

import 'app_theme.dart';

/// The game's school crest and name, shared by the title and menu screens.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.iconSize = 72,
    this.textColor,
    this.showName = true,
  });

  /// Height of the icon art.
  final double iconSize;

  /// Text colour override, for use over a photo background (e.g. the title
  /// screen's splash art). Defaults to the theme's normal text colour.
  final Color? textColor;

  /// Whether to show the wordmark under the crest.
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: AppTheme.chalkboard,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.brass, width: 3),
          ),
          child: Icon(
            Icons.school_rounded,
            size: iconSize * 0.58,
            color: AppTheme.parchment,
          ),
        ),
        if (showName) ...[
          const SizedBox(height: AppTheme.gapS),
          Text(
            'Academia Heights',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ],
    );
  }
}
