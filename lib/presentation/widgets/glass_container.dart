import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Border? border;
  final double? width;
  final double? height;
  final BoxShape shape;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.borderRadius = 20.0,
    this.padding,
    this.margin,
    this.color,
    this.border,
    this.width,
    this.height,
    this.shape = BoxShape.rectangle,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Translucent glass backgrounds
    final defaultGlassColor = isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.65);

    // Specular highlight border
    final defaultBorder = border ??
        Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.8),
          width: 1.2,
        );

    final defaultShadow = boxShadow ??
        [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ];

    Widget content = ClipRRect(
      borderRadius: shape == BoxShape.circle
          ? BorderRadius.circular(999)
          : BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            shape: shape,
            borderRadius: shape == BoxShape.circle
                ? null
                : BorderRadius.circular(borderRadius),
            color: color ?? defaultGlassColor,
            border: defaultBorder,
            boxShadow: defaultShadow,
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: shape == BoxShape.circle
              ? BorderRadius.circular(999)
              : BorderRadius.circular(borderRadius),
          child: content,
        ),
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}
