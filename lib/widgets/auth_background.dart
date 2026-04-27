import 'dart:ui';
import 'package:flutter/material.dart';

/// A premium decorative background for authentication screens
/// Features blurred abstract shapes to provide depth and modern feel
class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Background Base Color
        Container(
          color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
        ),

        // Decorative Circle 1 (Top Right)
        Positioned(
          top: -size.height * 0.1,
          right: -size.width * 0.2,
          child: _buildOrnaments(
            size.width * 0.7,
            const Color(0xFFE53935).withValues(alpha: isDark ? 0.2 : 0.1),
          ),
        ),

        // Decorative Circle 2 (Bottom Left)
        Positioned(
          bottom: -size.height * 0.15,
          left: -size.width * 0.3,
          child: _buildOrnaments(
            size.width * 0.9,
            const Color(0xFFE53935).withValues(alpha: isDark ? 0.15 : 0.05),
          ),
        ),

        // Blurred Overlay for Glassmorphism Background Effect
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(color: Colors.transparent),
          ),
        ),

        // Content
        SafeArea(child: child),
      ],
    );
  }

  Widget _buildOrnaments(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
