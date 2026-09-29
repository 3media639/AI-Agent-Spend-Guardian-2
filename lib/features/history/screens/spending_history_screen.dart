import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class SpendingHistoryScreen extends StatefulWidget {
  const SpendingHistoryScreen({super.key});

  @override
  State<SpendingHistoryScreen> createState() => _SpendingHistoryScreenState();
}

class _SpendingHistoryScreenState extends State<SpendingHistoryScreen> {
  int _selectedFilterIndex = 0; // 0: Daily, 1: Weekly, 2: Monthly
  final _currency = NumberFormat.currency(symbol: '\$');

  final List<Map<String, dynamic>> _mockHistory = [
    {
      'date': 'Today, Sep 29',
      'total': 8.50,
      'calls': 412,
      'items': [
        {'model': 'gpt-4o', 'provider': 'OpenAI', 'cost': 3.40, 'tokens': '124,000'},
        {'model': 'claude-3-5-sonnet', 'provider': 'Anthropic', 'cost': 4.15, 'tokens': '160,000'},
        {'model': 'gemini-1.5-pro', 'provider': 'Google', 'cost': 0.95, 'tokens': '85,000'},
      ],
    },
    {
      'date': 'Yesterday, Sep 28',
      'total': 7.30,
      'calls': 340,
      'items': [
        {'model': 'gpt-4o', 'provider': 'OpenAI', 'cost': 3.10, 'tokens': '110,000'},
        {'model': 'claude-3-5-sonnet', 'provider': 'Anthropic', 'cost': 3.40, 'tokens': '130,000'},
        {'model': 'gemini-1.5-pro', 'provider': 'Google', 'cost': 0.80, 'tokens': '72,000'},
      ],
    },
    {
      'date': 'Friday, Sep 27',
      'total': 11.20,
      'calls': 610,
      'items': [
        {'model': 'claude-3-5-sonnet', 'provider': 'Anthropic', 'cost': 7.20, 'tokens': '280,000'},
        {'model': 'gpt-4o', 'provider': 'OpenAI', 'cost': 2.80, 'tokens': '98,000'},
        {'model': 'gemini-1.5-pro', 'provider': 'Google', 'cost': 1.20, 'tokens': '112,000'},
      ],
    },
    {
      'date': 'Thursday, Sep 26',
      'total': 8.40,
      'calls': 390,
      'items': [
        {'model': 'gpt-4o', 'provider': 'OpenAI', 'cost': 4.50, 'tokens': '170,000'},
        {'model': 'claude-3-5-sonnet', 'provider': 'Anthropic', 'cost': 2.90, 'tokens': '105,000'},
        {'model': 'gemini-1.5-pro', 'provider': 'Google', 'cost': 1.00, 'tokens': '90,000'},
      ],
    },
    {
      'date': 'Wednesday, Sep 25',
      'total': 5.10,
      'calls': 240,
      'items': [
        {'model': 'gpt-4o-mini', 'provider': 'OpenAI', 'cost': 1.80, 'tokens': '620,000'},
        {'model': 'claude-3-5-sonnet', 'provider': 'Anthropic', 'cost': 2.40, 'tokens': '88,000'},
        {'model': 'gemini-1.5-pro', 'provider': 'Google', 'cost': 0.90, 'tokens': '80,000'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Export CSV',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Spending report exported to CSV.'),
                  backgroundColor: AppColors.primaryEmerald,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
            child: Row(
              children: [
                _buildFilterChip('Daily', 0, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Weekly', 1, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Monthly', 2, isDark),
              ],
            ),
          ),

          // Total Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total in Selected View',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedFilterIndex == 0
                            ? '\$40.50'
                            : (_selectedFilterIndex == 1 ? '\$82.50' : '\$248.90'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryEmerald.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '1,992 calls',
                      style: TextStyle(
                        color: AppColors.primaryEmerald,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // History List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
              itemCount: _mockHistory.length,
              itemBuilder: (context, index) {
                final day = _mockHistory[index];
                final items = day['items'] as List<Map<String, dynamic>>;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: index == 0,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Text(
                        day['date'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: Text(
                        '${day['calls']} API requests',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      trailing: Text(
                        _currency.format(day['total']),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.primaryEmerald,
                        ),
                      ),
                      children: items.map((m) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m['model'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  Text(
                                    '${m['provider']} • ${m['tokens']} tokens',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                _currency.format(m['cost']),
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, bool isDark) {
    final isSelected = _selectedFilterIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilterIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryEmerald
                : (isDark ? AppColors.darkCard : AppColors.lightCard),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryEmerald
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
