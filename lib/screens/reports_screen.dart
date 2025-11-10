import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habit_providers.dart';
import '../services/report_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

/// Screen for viewing and exporting weekly/monthly reports
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime _selectedWeek = DateTime.now();
  DateTime _selectedMonth = DateTime.now();
  String _weeklyReport = '';
  String _monthlyReport = '';

  @override
  void initState() {
    super.initState();
    _generateReports();
  }

  void _generateReports() {
    final habitsAsync = ref.read(habitsProvider);
    habitsAsync.whenData((habits) {
      setState(() {
        _weeklyReport = ReportService.generateWeeklyReport(
          habits,
          _getWeekStart(_selectedWeek),
        );
        _monthlyReport = ReportService.generateMonthlyReport(
          habits,
          _selectedMonth,
        );
      });
    });
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  Future<void> _exportData() async {
    HapticFeedback.lightImpact();
    ref.read(soundServiceProvider).playClick();
    
    final habitsAsync = ref.read(habitsProvider);
    await habitsAsync.when(
      loading: () async {},
      error: (_, _) async {},
      data: (habits) async {
        final action = await showModalBottomSheet<String>(
          context: context,
          builder: (context) => _ExportOptionsSheet(),
        );
        
        if (action == 'json') {
          await ReportService.exportToJson(habits);
        } else if (action == 'csv') {
          await ReportService.exportToCsv(habits);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text('Reports', style: textStyles.titlePage),
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: colors.textPrimary),
            onPressed: _exportData,
            tooltip: 'Export Data',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        children: [
          // Weekly Report
          _ReportCard(
            title: 'Weekly Report',
            report: _weeklyReport,
            colors: colors,
            textStyles: textStyles,
            onDateChanged: (date) {
              setState(() => _selectedWeek = date);
              _generateReports();
            },
            selectedDate: _selectedWeek,
            isWeekly: true,
          ),
          const SizedBox(height: AppSizes.paddingL),
          // Monthly Report
          _ReportCard(
            title: 'Monthly Report',
            report: _monthlyReport,
            colors: colors,
            textStyles: textStyles,
            onDateChanged: (date) {
              setState(() => _selectedMonth = date);
              _generateReports();
            },
            selectedDate: _selectedMonth,
            isWeekly: false,
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String report;
  final AppColors colors;
  final AppTextStyles textStyles;
  final Function(DateTime) onDateChanged;
  final DateTime selectedDate;
  final bool isWeekly;

  const _ReportCard({
    required this.title,
    required this.report,
    required this.colors,
    required this.textStyles,
    required this.onDateChanged,
    required this.selectedDate,
    required this.isWeekly,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: textStyles.titleCard),
              IconButton(
                icon: Icon(Icons.calendar_today, size: 18, color: colors.textSecondary),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    onDateChanged(date);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: SelectableText(
              report.isEmpty ? 'No data available' : report,
              style: textStyles.body.copyWith(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportOptionsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.code, color: colors.primary),
            title: const Text('Export as JSON'),
            onTap: () => Navigator.pop(context, 'json'),
          ),
          ListTile(
            leading: Icon(Icons.table_chart, color: colors.primary),
            title: const Text('Export as CSV'),
            onTap: () => Navigator.pop(context, 'csv'),
          ),
        ],
      ),
    );
  }
}

