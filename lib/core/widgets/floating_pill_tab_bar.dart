import 'package:adaptive_commerce/core/icons/app_icons.dart';
import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/theme/styles/app_colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Floating pill-style **main tab bar** (top): light surface, burgundy sliding pill, clay inactive.
///
/// Sits below [AppBrandHeader]; no drop shadow (flat on scaffold).
///
/// Uses [AppColors] only — no ad-hoc palette values.
/// On **web**, labels and icons are larger for comfortable desktop/browser reading.
class FloatingPillTabBar extends StatelessWidget {
  const FloatingPillTabBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  static const Duration _slideDuration = Duration(milliseconds: 300);
  static const Curve _slideCurve = Curves.easeInOutCubic;

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    final labelFontSize = isWeb ? 15.0 : 12.0;
    final iconSize = isWeb ? 28.0 : 24.0;
    final barHeight = isWeb ? 100.0 : 88.0;
    final iconLabelGap = isWeb ? 6.0 : 4.0;
    final lineHeight = isWeb ? 1.2 : 1.15;

    final labelStyleInactive = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: labelFontSize,
          height: lineHeight,
          color: AppColors.navBarInactive,
          fontWeight: FontWeight.w500,
        );
    final labelStyleActive = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: labelFontSize,
          height: lineHeight,
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        );

    // Food / Vet / Toys — Material Symbols rounded where available.
    final tabs = <({IconData outlined, IconData filled, String label})>[
      (
        outlined: Symbols.pet_supplies_rounded,
        filled: Symbols.pet_supplies_rounded,
        label: AppStrings.navFood,
      ),
      (
        outlined: Symbols.pets_rounded,
        filled: Symbols.pets_rounded,
        label: AppStrings.navVeterinary,
      ),
      (
        outlined: Symbols.toys_rounded,
        filled: Symbols.toys_rounded,
        label: AppStrings.navToys,
      ),
    ];

    final index = currentIndex.clamp(0, tabs.length - 1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: SizedBox(
        height: barHeight,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.navBarBackground,
            borderRadius: BorderRadius.circular(_pillRadius(isWeb)),
            border: Border.all(color: AppColors.divider),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 8 : 6,
              vertical: isWeb ? 10 : 8,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final segmentW = constraints.maxWidth / tabs.length;
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    AnimatedPositioned(
                      duration: _slideDuration,
                      curve: _slideCurve,
                      left: segmentW * index,
                      top: 0,
                      width: segmentW,
                      height: constraints.maxHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.navBarActive,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < tabs.length; i++)
                          Expanded(
                            child: _TabCell(
                              selected: index == i,
                              iconOutlined: tabs[i].outlined,
                              iconFilled: tabs[i].filled,
                              label: tabs[i].label,
                              labelStyleInactive: labelStyleInactive,
                              labelStyleActive: labelStyleActive,
                              iconSize: iconSize,
                              iconLabelGap: iconLabelGap,
                              onTap: () => onItemSelected(i),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  static double _pillRadius(bool isWeb) => isWeb ? 30 : 28;
}

class _TabCell extends StatelessWidget {
  const _TabCell({
    required this.selected,
    required this.iconOutlined,
    required this.iconFilled,
    required this.label,
    required this.labelStyleInactive,
    required this.labelStyleActive,
    required this.iconSize,
    required this.iconLabelGap,
    required this.onTap,
  });

  final bool selected;
  final IconData iconOutlined;
  final IconData iconFilled;
  final String label;
  final TextStyle? labelStyleInactive;
  final TextStyle? labelStyleActive;
  final double iconSize;
  final double iconLabelGap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = selected ? iconFilled : iconOutlined;
    final color = selected ? AppColors.white : AppColors.navBarInactive;
    final textStyle = selected ? labelStyleActive : labelStyleInactive;

    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: iconSize, color: color),
                SizedBox(height: iconLabelGap),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: textStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
