import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class DefaultProfileAvatar extends StatelessWidget {
  final String displayName;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const DefaultProfileAvatar({
    Key? key,
    required this.displayName,
    required this.size,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  String get initials {
    final names = displayName.trim().split(' ');
    if (names.isEmpty) return '';
    if (names.length == 1) {
      return names[0].isNotEmpty ? names[0][0].toUpperCase() : '';
    }
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? FlutterFlowTheme.of(context).primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                color: textColor ?? Colors.white,
                fontSize: size * 0.4,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
