import 'package:flutter/material.dart';
import '../core/app_theme.dart';

// ─── CARD ─────────────────────────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  const AppCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );
}

// ─── SECTION TITLE ────────────────────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const SectionTitle({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppColors.blue, size: 18),
      const SizedBox(width: 8),
      Text(title, style: AppText.sectionTitle),
    ],
  );
}

// ─── LINK ROW ─────────────────────────────────────────────────────────────────
class LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const LinkRow({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(
      children: [
        Icon(icon, size: 16, color: AppColors.blueLight),
        const SizedBox(width: 6),
        Text(label, style: AppText.link),
      ],
    ),
  );
}

// ─── TAG CHIP ─────────────────────────────────────────────────────────────────
class TagChip extends StatelessWidget {
  final String label;
  const TagChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.blueSurface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        color: AppColors.blueLight,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

// ─── BADGE ────────────────────────────────────────────────────────────────────
class AppBadge extends StatelessWidget {
  final String label;
  const AppBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.blueSurface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        color: AppColors.blueLight,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

// ─── PRIMARY BUTTON ───────────────────────────────────────────────────────────
class PrimaryBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  const PrimaryBtn({super.key, required this.label, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.blueLight,
      foregroundColor: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 6)],
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    ),
  );
}

// ─── SECONDARY BUTTON ─────────────────────────────────────────────────────────
class SecondaryBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  const SecondaryBtn({super.key, required this.label, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.blueLight,
      side: const BorderSide(color: AppColors.blueLight),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 6)],
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    ),
  );
}
