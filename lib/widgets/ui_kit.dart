import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ResqBackground extends StatelessWidget {
  final Widget child;
  const ResqBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  C.bg,
                  C.surfaceLow,
                  C.surfaceMid,
                ],
              ),
            ),
          ),
        ),
        const _GlowOrb(
          alignment: Alignment(-0.9, -0.8),
          color: C.primary,
          size: 260,
          opacity: 0.14,
        ),
        const _GlowOrb(
          alignment: Alignment(0.9, -0.4),
          color: C.info,
          size: 220,
          opacity: 0.12,
        ),
        const _GlowOrb(
          alignment: Alignment(-0.8, 0.9),
          color: C.green,
          size: 240,
          opacity: 0.08,
        ),
        child,
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final double size;
  final double opacity;
  const _GlowOrb({
    required this.alignment,
    required this.color,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: opacity),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: opacity),
                blurRadius: 120,
                spreadRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResqPage extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double maxWidth;

  const ResqPage({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth = 1080,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final horizontal = isWide ? 48.0 : 24.0;
        final vertical = isWide ? 32.0 : 24.0;
        final resolvedPadding =
            padding ?? EdgeInsets.fromLTRB(horizontal, vertical, horizontal, vertical);

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: resolvedPadding,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class ResqCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const ResqCard({super.key, required this.child, this.padding = const EdgeInsets.all(24)});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class ResqFieldLabel extends StatelessWidget {
  final String text;
  const ResqFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium,
    );
  }
}

class ResqTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final bool obscureText;

  const ResqTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.keyboardType,
    this.suffixIcon,
    this.textInputAction,
    this.onSubmitted,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      obscureText: obscureText,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: C.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class ResqPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expand;
  final IconData? icon;

  const ResqPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: C.onPrimary),
          )
        : Text(label);

    final button = icon == null
        ? FilledButton(onPressed: onPressed, child: buttonChild)
        : FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: buttonChild,
          );

    if (!expand) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }
}
