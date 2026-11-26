import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

const double appContentMaxWidth = AppSpacing.content;

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
  const AppPage({super.key, required this.children, this.padding});

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
                final horizontal = constraints.maxWidth >= 700
                    ? 28.0
                    : AppSpacing.page;
                return ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding:
                      padding ??
                      EdgeInsets.fromLTRB(horizontal, 20, horizontal, 112),
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
              Text(meta, style: AppText.small(context.appMuted), maxLines: 2),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 14), trailing!],
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
        Expanded(child: Text(title, style: AppText.section(context.appInk))),
        if (trailing != null)
          Padding(padding: const EdgeInsets.only(left: 12), child: trailing)
        else if (action != null && onAction != null)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 14,
                ),
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
    this.radius = AppRadii.card,
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
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
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
    final solid = value == 5 && !muted;
    final base = value <= 2
        ? context.appError
        : muted
        ? context.appMuted
        : context.appInk;
    return Semantics(
      label: 'Оценка $value',
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: solid ? context.appInk : context.appSurfaceAlt,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: value == 3
              ? Border.all(color: context.appBorderStrong)
              : null,
        ),
        child: Text(
          '$value',
          style:
              AppText.small(
                solid ? context.appOnInk : base,
                weight: FontWeight.w700,
              ).copyWith(
                fontSize: size * 0.44,
                height: 1,
                fontFeatures: AppText.tabular,
              ),
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
    final tint = context.appInk;
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
  const StatusLabel({super.key, required this.label, required this.color});

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
        Text(label, style: AppText.small(color, weight: FontWeight.w600)),
      ],
    );
  }
}

/// Neutral monogram button linking to the student profile.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size = AppSpacing.touch,
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
      decoration: BoxDecoration(
        color: context.appSurfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: context.appBorder),
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: AppText.displayFamily,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
          color: context.appInk,
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
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.sheet),
        ),
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
                  style: AppText.body(context.appInk, weight: FontWeight.w600),
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
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
