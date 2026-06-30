import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../utils/currency_formatter.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';
import 'history_screen.dart';
import 'report_screen.dart';
import '../widgets/transaction_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _totalIncome = 0;
  double _totalExpense = 0;
  List<TransactionModel> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final income = await DBHelper.instance.getTotalIncome();
    final expense = await DBHelper.instance.getTotalExpense();
    final transactions = await DBHelper.instance.getAllTransactions();

    setState(() {
      _totalIncome = income;
      _totalExpense = expense;
      _recentTransactions = transactions.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final balance = _totalIncome - _totalExpense;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'CatatKas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
              _loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kartu Saldo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo Saat Ini',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.format(balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            icon: Icons.arrow_downward,
                            label: 'Pemasukan',
                            amount: _totalIncome,
                            color: Colors.greenAccent,
                          ),
                        ),
                        Expanded(
                          child: _buildSummaryItem(
                            icon: Icons.arrow_upward,
                            label: 'Pengeluaran',
                            amount: _totalExpense,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Transaksi Terakhir
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transaksi Terakhir',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      );
                      _loadData();
                    },
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              _recentTransactions.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada transaksi',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentTransactions.length,
                itemBuilder: (context, index) {
                  return TransactionCard(
                    transaction: _recentTransactions[index],
                    onDelete: () async {
                      await DBHelper.instance.deleteTransaction(
                          _recentTransactions[index].id!);
                      _loadData();
                    },
                    onEdit: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddTransactionScreen(
                            transaction: _recentTransactions[index],
                          ),
                        ),
                      );
                      _loadData();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
          _loadData();
        },
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(
              CurrencyFormatter.formatCompact(amount),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}