// screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/budget_provider.dart';
import '../../utils/constants.dart';
import '../expenses/add_transaction_screen.dart';
import '../expenses/transaction_list_screen.dart';
import '../budget/budget_screen.dart';
import '../analytics/analytics_screen.dart';
import '../../widgets/transaction_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _pages = const [
    _DashboardPage(),
    TransactionListScreen(),
    BudgetScreen(),
    AnalyticsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
      context.read<BudgetProvider>().loadBudgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Icon(Icons.list_alt),
              label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline),
              activeIcon: Icon(Icons.pie_chart),
              label: 'Budget'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Analytics'),
        ],
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final txnProvider = context.watch<TransactionProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final fmt = NumberFormat('#,###', 'en_US');

    final monthExpense = txnProvider.thisMonthExpense;
    final totalBudget = budgetProvider.totalBudget;
    final budgetPct = totalBudget != null && totalBudget.limit > 0
        ? (monthExpense / totalBudget.limit).clamp(0.0, 1.0)
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.primary,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${auth.currentUser?.name.split(' ').first ?? 'User'} 👋',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Here\'s your finance summary',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout,
                                color: Colors.white70),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Sign Out'),
                                  content: const Text(
                                      'Are you sure you want to sign out?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text('Sign Out',
                                            style: TextStyle(
                                                color: AppColors.expense))),
                                  ],
                                ),
                              );
                              if (confirm == true && context.mounted) {
                                context.read<AuthProvider>().logout();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('Total Balance',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        'Rs ${fmt.format(txnProvider.balance)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        _StatChip(
                          label: 'Income',
                          value:
                          'Rs ${fmt.format(txnProvider.thisMonthIncome)}',
                          icon: Icons.arrow_downward,
                          iconColor: const Color(0xFF9FECCA),
                        ),
                        const SizedBox(width: 12),
                        _StatChip(
                          label: 'Expenses',
                          value:
                          'Rs ${fmt.format(txnProvider.thisMonthExpense)}',
                          icon: Icons.arrow_upward,
                          iconColor: const Color(0xFFFFB3B3),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Budget warning
                if (totalBudget != null &&
                    budgetPct != null &&
                    budgetPct >= 0.9)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(12),
                      border:
                      Border.all(color: const Color(0xFFFAC775)),
                    ),
                    child: Row(children: [
                      Icon(Icons.warning_amber,
                          color: AppColors.warning),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Budget alert! You\'ve used ${(budgetPct * 100).round()}% of your monthly budget.',
                          style: TextStyle(
                              color: AppColors.warning, fontSize: 13),
                        ),
                      ),
                    ]),
                  ),

                // Budget bar
                if (totalBudget != null && budgetPct != null) ...[
                  _SectionHeader(
                      title: 'Monthly Budget',
                      action: 'View',
                      onAction: () {}),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rs ${fmt.format(monthExpense)} spent',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                            Text(
                              'of Rs ${fmt.format(totalBudget.limit)}',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: budgetPct,
                            minHeight: 8,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation(
                              budgetPct >= 0.9
                                  ? AppColors.expense
                                  : budgetPct >= 0.7
                                  ? AppColors.warning
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${(budgetPct * 100).round()}% used · Rs ${fmt.format(totalBudget.limit - monthExpense)} remaining',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Recent Transactions
                _SectionHeader(
                    title: 'Recent Transactions',
                    action: 'See all',
                    onAction: () {}),
                if (txnProvider.isLoading)
                  Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary),
                  )
                else if (txnProvider.recentTransactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Column(children: [
                        Icon(Icons.receipt_long,
                            size: 48, color: AppColors.textHint),
                        const SizedBox(height: 12),
                        Text('No transactions yet',
                            style: TextStyle(
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          'Tap + to add your first transaction',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint),
                        ),
                      ]),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                      txnProvider.recentTransactions.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: AppColors.border),
                      itemBuilder: (ctx, i) {
                        final t =
                        txnProvider.recentTransactions[i];
                        return TransactionTile(
                          transaction: t,
                          onDelete: () {
                            context
                                .read<TransactionProvider>()
                                .deleteTransaction(t.id);
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const AddTransactionScreen()),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(38),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 11)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ]),
        ]),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textPrimary)),
          GestureDetector(
            onTap: onAction,
            child: Text(action,
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}