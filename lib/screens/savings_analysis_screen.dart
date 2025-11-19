import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../models/savings_category.dart';
import '../models/savings_entry.dart';
import '../models/savings_filter.dart';
import '../models/savings_goal.dart';
import '../providers/savings_providers.dart';
import '../theme/app_theme.dart';
import '../dialogs/add_savings_entry_dialog.dart';
import '../dialogs/add_category_dialog.dart';
import '../dialogs/set_goal_dialog.dart';
import '../widgets/savings_charts/savings_pie_chart.dart';
import '../widgets/savings_charts/savings_line_chart.dart';
import '../widgets/savings_charts/savings_bar_chart.dart';

class SavingsAnalysisScreen extends ConsumerStatefulWidget {
  const SavingsAnalysisScreen({super.key});

  @override
  ConsumerState<SavingsAnalysisScreen> createState() =>
      _SavingsAnalysisScreenState();
}

class _SavingsAnalysisScreenState extends ConsumerState<SavingsAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('Tasarruf Analizi', style: textStyles.titlePage),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrele',
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_category',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline),
                    SizedBox(width: AppSizes.paddingS),
                    Text('Kategori Ekle'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'set_goal',
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined),
                    SizedBox(width: AppSizes.paddingS),
                    Text('Hedef Belirle'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'add_category') {
                _showAddCategoryDialog();
              } else if (value == 'set_goal') {
                _showSetGoalDialog();
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Özet'),
            Tab(text: 'Grafikler'),
            Tab(text: 'Kayıtlar'),
            Tab(text: 'Hedefler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(),
          _ChartsTab(),
          _EntriesTab(),
          _GoalsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEntryDialog(),
        backgroundColor: colors.textPrimary,
        foregroundColor: colors.surface,
        icon: const Icon(Icons.add),
        label: Text('Tasarruf Ekle', style: textStyles.buttonLabel),
      ),
    );
  }

  Future<void> _showAddEntryDialog({SavingsEntry? entry}) async {
    await showDialog(
      context: context,
      builder: (_) => AddSavingsEntryDialog(entryToEdit: entry),
    );
  }

  Future<void> _showAddCategoryDialog({SavingsCategory? category}) async {
    await showDialog(
      context: context,
      builder: (_) => AddCategoryDialog(categoryToEdit: category),
    );
  }

  Future<void> _showSetGoalDialog() async {
    await showDialog(
      context: context,
      builder: (_) => const SetGoalDialog(),
    );
  }

  Future<void> _showFilterDialog() async {
    final filter = ref.read(savingsFilterProvider);
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filtrele', style: textStyles.titleSection),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tümü'),
              leading: Radio<SavingsTimeFilter>(
                value: SavingsTimeFilter.all,
                groupValue: filter.timeFilter,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(savingsFilterProvider.notifier).reset();
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Bugün'),
              leading: Radio<SavingsTimeFilter>(
                value: SavingsTimeFilter.today,
                groupValue: filter.timeFilter,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(savingsFilterProvider.notifier).setFilter(
                        SavingsFilter(timeFilter: value));
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Bu Hafta'),
              leading: Radio<SavingsTimeFilter>(
                value: SavingsTimeFilter.thisWeek,
                groupValue: filter.timeFilter,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(savingsFilterProvider.notifier).setFilter(
                        SavingsFilter(timeFilter: value));
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Bu Ay'),
              leading: Radio<SavingsTimeFilter>(
                value: SavingsTimeFilter.thisMonth,
                groupValue: filter.timeFilter,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(savingsFilterProvider.notifier).setFilter(
                        SavingsFilter(timeFilter: value));
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _OverviewTab() {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final todayTotal = ref.watch(todaySavingsProvider);
    final weeklyTotal = ref.watch(weeklySavingsProvider);
    final monthlyTotal = ref.watch(monthlySavingsProvider);
    final total = ref.watch(totalSavingsProvider);
    final average = ref.watch(averageDailySavingsProvider);
    final streak = ref.watch(savingsStreakProvider);
    final topCategory = ref.watch(topCategoryProvider);
    final categories = ref.watch(savingsCategoriesProvider);
    final avoidedLoss = ref.watch(totalAvoidedLossProvider);
    final cumulativeLoss = ref.watch(cumulativeLossProvider);
    final netBenefit = ref.watch(netBenefitProvider);
    final profitMargin = ref.watch(profitMarginProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Özet kartları
          _buildSummaryCards(colors, textStyles, todayTotal, weeklyTotal,
              monthlyTotal, total, average, streak, topCategory),
          const SizedBox(height: AppSizes.paddingL),
          
          // Zarar/Kar Analizi
          if (cumulativeLoss > 0) ...[
            _buildLossAnalysisCards(colors, textStyles, avoidedLoss, cumulativeLoss, netBenefit, profitMargin),
            const SizedBox(height: AppSizes.paddingL),
          ],
          
          // Hızlı ekleme
          Text('Hızlı Ekleme', style: textStyles.titleSection),
          const SizedBox(height: AppSizes.paddingM),
          _buildQuickAddChips(categories),
          const SizedBox(height: AppSizes.paddingL),
          
          // Kategori istatistikleri
          Text('Kategori İstatistikleri', style: textStyles.titleSection),
          const SizedBox(height: AppSizes.paddingM),
          _buildCategoryStats(categories),
        ],
      ),
    );
  }

  Widget _ChartsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        children: [
          const SavingsPieChart(),
          const SizedBox(height: AppSizes.paddingL),
          const SavingsLineChart(),
          const SizedBox(height: AppSizes.paddingL),
          const SavingsBarChart(),
        ],
      ),
    );
  }

  Widget _EntriesTab() {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final entries = ref.watch(filteredSavingsEntriesProvider);
    final categories = ref.watch(savingsCategoriesProvider);

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: colors.textTertiary),
            const SizedBox(height: AppSizes.paddingL),
            Text(
              'Henüz tasarruf kaydı yok',
              style: textStyles.bodyBold,
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'İlk tasarrufunuzu eklemek için + butonuna basın',
              style: textStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[entries.length - 1 - index]; // Reverse order
        SavingsCategory category;
        try {
          category = categories.firstWhere((c) => c.id == entry.categoryId);
        } catch (_) {
          if (categories.isEmpty) {
            category = SavingsCategory(
              name: 'Bilinmeyen',
              defaultAmount: 0,
              icon: Icons.category,
              color: const Color(0xFFC9A882),
            );
          } else {
            category = categories.first;
          }
        }
        return _buildEntryCard(entry, category);
      },
    );
  }

  Widget _GoalsTab() {
    final goal = ref.watch(savingsGoalProvider);
    final monthlyTotal = ref.watch(monthlySavingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (goal != null && goal.isCurrentMonth())
            _buildGoalCard(goal, monthlyTotal)
          else
            _buildNoGoalCard(),
          const SizedBox(height: AppSizes.paddingL),
          _buildGoalStats(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    AppColors colors,
    AppTextStyles textStyles,
    double today,
    double weekly,
    double monthly,
    double total,
    double average,
    int streak,
    SavingsCategory? topCategory,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Bugün', today, colors, textStyles,
                  icon: Icons.today),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: _buildStatCard('Bu Hafta', weekly, colors, textStyles,
                  icon: Icons.calendar_view_week),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Bu Ay', monthly, colors, textStyles,
                  icon: Icons.calendar_month),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: _buildStatCard('Toplam', total, colors, textStyles,
                  icon: Icons.account_balance_wallet),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Ortalama', average, colors, textStyles,
                  icon: Icons.trending_up),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: _buildStatCard('Streak', streak.toDouble(), colors,
                  textStyles,
                  icon: Icons.local_fire_department,
                  suffix: ' gün'),
            ),
          ],
        ),
        if (topCategory != null) ...[
          const SizedBox(height: AppSizes.paddingM),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: colors.elevatedSurface,
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
              boxShadow: AppShadows.cardSoft(null),
            ),
            child: Row(
              children: [
                Icon(topCategory.icon, color: topCategory.color, size: 32),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('En Çok Tasarruf', style: textStyles.caption),
                      const SizedBox(height: 4),
                      Text(topCategory.name, style: textStyles.bodyBold),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLossAnalysisCards(
    AppColors colors,
    AppTextStyles textStyles,
    double avoidedLoss,
    double cumulativeLoss,
    double netBenefit,
    double profitMargin,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Zarar/Kar Analizi', style: textStyles.titleSection),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Önlenen Zarar', avoidedLoss, colors, textStyles,
                  icon: Icons.shield, suffix: '₺', color: colors.success),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: _buildStatCard('Kumulatif Zarar', cumulativeLoss, colors, textStyles,
                  icon: Icons.trending_down, suffix: '₺', color: colors.statusIncomplete),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Net Kazanç', netBenefit, colors, textStyles,
                  icon: Icons.account_balance, suffix: '₺', color: colors.success),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: _buildStatCard('Kar Marjı', profitMargin, colors, textStyles,
                  icon: Icons.percent, suffix: '%', color: colors.primary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, double value, AppColors colors,
      AppTextStyles textStyles,
      {required IconData icon, String suffix = '₺', Color? color}) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
        boxShadow: AppShadows.cardSoft(null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color ?? colors.textSecondary),
              const SizedBox(width: AppSizes.paddingS),
              Expanded(
                child: Text(label, style: textStyles.caption),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '$suffix${value.toStringAsFixed(color != null ? 1 : 0)}',
            style: textStyles.titleCard.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddChips(List<SavingsCategory> categories) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: AppSizes.paddingS,
      runSpacing: AppSizes.paddingS,
      children: categories.map((category) {
        return ActionChip(
          avatar: Icon(category.icon, size: 18, color: category.color),
          label: Text('${category.name} (₺${category.defaultAmount.toStringAsFixed(0)})'),
          onPressed: () => _showAddEntryDialog(),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryStats(List<SavingsCategory> categories) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final distribution = ref.watch(categoryDistributionProvider);
    final total = distribution.values.fold(0.0, (sum, value) => sum + value);

    if (distribution.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color: colors.elevatedSurface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
        ),
        child: Center(
          child: Text('Henüz veri yok', style: textStyles.bodySecondary),
        ),
      );
    }

    return Column(
      children: distribution.entries.map((entry) {
        SavingsCategory category;
        try {
          category = categories.firstWhere((c) => c.id == entry.key);
        } catch (_) {
          if (categories.isEmpty) return const SizedBox.shrink();
          category = categories.first;
        }
        final percentage = total > 0 ? (entry.value / total * 100) : 0;
        return Container(
          margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: BoxDecoration(
            color: colors.elevatedSurface,
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
            boxShadow: AppShadows.cardSoft(null),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(category.icon, color: category.color),
                  const SizedBox(width: AppSizes.paddingS),
                  Expanded(
                    child: Text(category.name, style: textStyles.bodyBold),
                  ),
                  Text('₺${entry.value.toStringAsFixed(0)}',
                      style: textStyles.bodyBold),
                ],
              ),
              const SizedBox(height: AppSizes.paddingS),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 6,
                  backgroundColor: colors.outline.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(category.color),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '%${percentage.toStringAsFixed(1)}',
                style: textStyles.caption,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEntryCard(SavingsEntry entry, SavingsCategory category) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.paddingL),
        decoration: BoxDecoration(
          color: colors.statusIncomplete,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sil'),
            content: const Text('Bu kaydı silmek istediğinize emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sil'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        ref.read(savingsEntriesProvider.notifier).removeEntry(entry.id);
        HapticFeedback.mediumImpact();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
        decoration: BoxDecoration(
          color: colors.elevatedSurface,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
          boxShadow: AppShadows.cardSoft(null),
        ),
        child: InkWell(
          onTap: () => _showAddEntryDialog(entry: entry),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Icon(category.icon, color: category.color),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name, style: textStyles.bodyBold),
                      const SizedBox(height: 4),
                      if (entry.note != null)
                        Text(entry.note!, style: textStyles.bodySecondary),
                      if (entry.alternativeSpending != null)
                        Text(
                          'Alternatif: ${entry.alternativeSpending}',
                          style: textStyles.caption,
                        ),
                      if (entry.wouldHaveSpent != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.statusIncomplete.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          ),
                          child: Text(
                            'Önlenen zarar: ₺${entry.avoidedLoss.toStringAsFixed(0)}',
                            style: textStyles.caption.copyWith(
                              color: colors.statusIncomplete,
                            ),
                          ),
                        ),
                      ],
                      if (entry.location != null || entry.mood != null || entry.difficulty != null) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            if (entry.location != null)
                              Chip(
                                label: Text(entry.location!, style: const TextStyle(fontSize: 10)),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            if (entry.mood != null)
                              Chip(
                                label: Text(entry.mood!, style: const TextStyle(fontSize: 10)),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            if (entry.difficulty != null)
                              Chip(
                                label: Text(entry.difficulty!, style: const TextStyle(fontSize: 10)),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '${dateFormat.format(entry.date)} • ${timeFormat.format(entry.date)}',
                        style: textStyles.caption,
                      ),
                    ],
                  ),
                ),
                Text(
                  '₺${entry.amount.toStringAsFixed(0)}',
                  style: textStyles.titleCard.copyWith(
                    color: colors.success,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(SavingsGoal goal, double current) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final progress = goal.targetAmount > 0 ? (current / goal.targetAmount) : 0.0;
    final remaining = goal.targetAmount - current;
    final daysRemaining = goal.endDate.difference(DateTime.now()).inDays;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
        boxShadow: AppShadows.cardSoft(null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Aylık Hedef', style: textStyles.titleSection),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _showSetGoalDialog,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hedef', style: textStyles.caption),
                  Text('₺${goal.targetAmount.toStringAsFixed(0)}',
                      style: textStyles.titleCard),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Şu Ana Kadar', style: textStyles.caption),
                  Text('₺${current.toStringAsFixed(0)}',
                      style: textStyles.titleCard),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            child: LinearProgressIndicator(
              value: progress > 1.0 ? 1.0 : progress,
              minHeight: 12,
              backgroundColor: colors.outline.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? colors.success : colors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '%${(progress * 100).toStringAsFixed(0)} tamamlandı',
                style: textStyles.bodySecondary,
              ),
              Text(
                remaining > 0
                    ? '₺${remaining.toStringAsFixed(0)} kaldı'
                    : 'Hedef aşıldı! 🎉',
                style: textStyles.bodyBold.copyWith(
                  color: remaining > 0 ? colors.textSecondary : colors.success,
                ),
              ),
            ],
          ),
          if (daysRemaining > 0) ...[
            const SizedBox(height: AppSizes.paddingS),
            Text(
              '$daysRemaining gün kaldı',
              style: textStyles.caption,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoGoalCard() {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
        boxShadow: AppShadows.cardSoft(null),
      ),
      child: Column(
        children: [
          Icon(Icons.flag_outlined, size: 64, color: colors.textTertiary),
          const SizedBox(height: AppSizes.paddingL),
          Text('Henüz hedef belirlenmemiş', style: textStyles.titleSection),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            'Bu ay için bir hedef belirleyerek motivasyonunuzu artırın',
            style: textStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingL),
          ElevatedButton.icon(
            onPressed: _showSetGoalDialog,
            icon: const Icon(Icons.add),
            label: const Text('Hedef Belirle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.textPrimary,
              foregroundColor: colors.surface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStats() {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final monthlyTotal = ref.watch(monthlySavingsProvider);
    final average = ref.watch(averageDailySavingsProvider);
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysPassed = now.day;
    final projectedMonthly = average * daysInMonth;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
        boxShadow: AppShadows.cardSoft(null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('İstatistikler', style: textStyles.titleSection),
          const SizedBox(height: AppSizes.paddingL),
          _buildStatRow('Bu Ay', '₺${monthlyTotal.toStringAsFixed(0)}', colors, textStyles),
          _buildStatRow('Günlük Ortalama', '₺${average.toStringAsFixed(0)}', colors, textStyles),
          _buildStatRow('Geçen Günler', '$daysPassed / $daysInMonth', colors, textStyles),
          if (projectedMonthly > 0)
            _buildStatRow('Tahmini Aylık', '₺${projectedMonthly.toStringAsFixed(0)}', colors, textStyles),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, AppColors colors, AppTextStyles textStyles) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyles.body),
          Text(value, style: textStyles.bodyBold),
        ],
      ),
    );
  }
}
