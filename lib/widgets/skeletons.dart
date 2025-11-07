import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_constants.dart';

class HabitListSkeleton extends StatelessWidget {
  final int itemCount;

  const HabitListSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.paddingXXL),
      itemBuilder: (context, index) => _buildCard(colors),
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSizes.paddingL),
      itemCount: itemCount,
    );
  }

  Widget _buildCard(ColorScheme colors) {
    return Shimmer.fromColors(
      baseColor: colors.onSurface.withValues(alpha: 0.08),
      highlightColor: colors.onSurface.withValues(alpha: 0.02),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        ),
      ),
    );
  }
}
