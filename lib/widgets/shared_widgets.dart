import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

const double appContentMaxWidth = 760;

/// Returns a motion duration that collapses when the OS asks for less motion.
Duration appMotion(
  BuildContext context, [
  Duration duration = const Duration(milliseconds: 200),
]) {
  final disableAnimations =
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  return disableAnimations ? Duration.zero : duration;
}

/// Standard page body: safe area, readable max width and dismissal on scroll.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.children,
    this.padding,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: appContentMaxWidth),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth >= 700 ? 28.0 : 20.0;
                return ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: padding ??
                      EdgeInsets.fromLTRB(horizontal, 20, horizontal, 36),
                  children: children,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Large editorial page title with one supporting line.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.meta,
    this.trailing,
  });

  final String title;
  final String meta;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.pageTitle(context.appInk)),
              const SizedBox(height: 8),
              Text(
                meta,
                style: AppText.small(context.appMuted),
                maxLines: 2,
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 14),
          trailing!,
        ],
      ],
    );
  }
}

/// Section title with an optional plain text action or count on the right.
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final action = actionLabel;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(title, style: AppText.section(context.appInk)),
        ),
        if (trailing != null)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: trailing,
          )
        else if (action != null && onAction != null)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      action,
                      style: AppText.small(
                        context.appPrimary,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: context.appPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Flat bordered surface. No shadows, no nested elevation.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.color,
    this.borderColor,
    this.radius = 22,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    return Material(
      color: color ?? context.appSurface,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: borderColor ?? context.appBorder),
      ),
      child: onTap == null
          ? content
          : InkWell(onTap: onTap, child: content),
    );
  }
}

/// Square grade mark used in lists and sheets.
class GradeMark extends StatelessWidget {
  const GradeMark({
    super.key,
    required this.value,
    this.size = 34,
    this.muted = false,
  });

  final int value;
  final double size;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final base = muted ? context.appMuted : AppColors.forGrade(value);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: base.withValues(alpha: context.isDark ? 0.2 : 0.11),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: base.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$value',
        style: AppText.small(
          base,
          weight: FontWeight.w700,
        ).copyWith(
          fontSize: size * 0.44,
          height: 1,
          fontFeatures: AppText.tabular,
        ),
      ),
    );
  }
}

/// Subject identity block: a restrained tinted square with the subject icon.
class SubjectMark extends StatelessWidget {
  const SubjectMark({
    super.key,
    required this.color,
    required this.icon,
    this.size = 40,
  });

  final Color color;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tint = context.isDark
        ? Color.lerp(color, Colors.white, 0.35)!
        : color;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: context.isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, size: size * 0.48, color: tint),
    );
  }
}

/// Plain icon and label. Used instead of decorative pills.
class MetaLine extends StatelessWidget {
  const MetaLine({
    super.key,
    required this.icon,
    required this.text,
    this.color,
  });

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.appMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: tint),
        const SizedBox(width: 5),
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.small(tint),
        ),
      ],
    );
  }
}

/// Semantic status text with a dot, not a background chip.
class StatusLabel extends StatelessWidget {
  const StatusLabel({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppText.small(color, weight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Student initials disc backed by the highlighter accent.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size = 44,
    this.onTap,
  });

  final String initials;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: AppText.displayFamily,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
          color: AppColors.accentInk,
        ),
      ),
    );

    if (onTap == null) return avatar;
    return Semantics(
      button: true,
      label: 'Открыть профиль',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatar,
      ),
    );
  }
}

/// Linear progress with a restrained 220ms fill animation.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 7,
  });

  final double value;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final fill = color ?? context.appPrimary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: context.appSurfaceAlt),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: clamped),
              duration: appMotion(context, const Duration(milliseconds: 220)),
              curve: Curves.easeOutCubic,
              builder: (context, animated, child) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: animated,
                    heightFactor: 1,
                    child: ColoredBox(color: fill),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Small trend chart with a soft fill and a single endpoint marker.
class SparklineChart extends StatelessWidget {
  const SparklineChart({
    super.key,
    required this.values,
    this.height = 46,
    this.color,
    this.semanticLabel = 'Динамика среднего балла',
  });

  final List<double> values;
  final double height;
  final Color? color;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return SizedBox(height: height);
    final line = color ?? context.appPrimary;
    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return CustomPaint(
              size: Size(constraints.maxWidth, height),
              painter: _SparklinePainter(
                values: values,
                line: line,
                dot: context.appAccent,
                dotBorder: context.appSurface,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.line,
    required this.dot,
    required this.dotBorder,
  });

  final List<double> values;
  final Color line;
  final Color dot;
  final Color dotBorder;

  @override
  void paint(Canvas canvas, Size size) {
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final span = math.max(maxValue - minValue, 0.001);
    final stepX = size.width / (values.length - 1);
    const verticalInset = 5.0;
    final usableHeight = math.max(size.height - verticalInset * 2, 1.0);

    Offset pointAt(int index) {
      final normalized = (values[index] - minValue) / span;
      return Offset(
        stepX * index,
        verticalInset + (1 - normalized) * usableHeight,
      );
    }

    final path = Path();
    final first = pointAt(0);
    path.moveTo(first.dx, first.dy);
    for (var i = 1; i < values.length; i++) {
      final previous = pointAt(i - 1);
      final current = pointAt(i);
      final midX = (previous.dx + current.dx) / 2;
      path.cubicTo(
        midX,
        previous.dy,
        midX,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            line.withValues(alpha: 0.18),
            line.withValues(alpha: 0.01),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final last = pointAt(values.length - 1);
    canvas.drawCircle(last, 4.6, Paint()..color = dotBorder);
    canvas.drawCircle(last, 3.2, Paint()..color = dot);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.line != line ||
        oldDelegate.dot != dot ||
        oldDelegate.dotBorder != dotBorder;
  }
}

/// Bottom sheet surface with a grab handle and bounded scroll area.
class AppSheet extends StatelessWidget {
  const AppSheet({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.92;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: context.appBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sheet heading with a close action.
class SheetHeader extends StatelessWidget {
  const SheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 12)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.section(context.appInk)),
              if (subtitle != null) ...[
                const SizedBox(height: 5),
                Text(subtitle!, style: AppText.small(context.appMuted)),
              ],
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Закрыть',
          icon: Icon(Icons.close_rounded, color: context.appMuted, size: 22),
        ),
      ],
    );
  }
}

/// Two-column detail row used by profile and lesson sheets.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(label, style: AppText.small(context.appMuted)),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: AppText.body(
                    context.appInk,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) Divider(color: context.appBorder, height: 1),
      ],
    );
  }
}

/// Empty result state with an optional reset action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 28, color: context.appMuted),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.body(context.appInk, weight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppText.small(context.appMuted),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
