import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/transaction.dart';
import '../utils/currency_formatter.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<TransactionModel> _transactions = [];
  String _filterPeriod = 'Bulan ini';
  String _filterType = 'Semua';

  DateTime? _customStart;
  DateTime? _customEnd;

  final List<String> _periods = [
    'Semua', 'Hari ini', 'Minggu ini', 'Bulan ini', 'Tahun ini'
  ];
  final List<String> _types = ['Semua', 'Pemasukan', 'Pengeluaran'];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final now = DateTime.now();
    List<TransactionModel> result;
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (_filterPeriod == 'Hari ini') {
      final start = DateTime(now.year, now.month, now.day);
      _customStart = start;
      _customEnd = null;
      result = await DBHelper.instance.getTransactionsByPeriod(start, end);
    } else if (_filterPeriod == 'Minggu ini') {
      var start = now.subtract(Duration(days: now.weekday - 1));
      start = DateTime(start.year, start.month, start.day);
      _customStart = start;
      _customEnd = DateTime(now.year, now.month, now.day);
      result = await DBHelper.instance.getTransactionsByPeriod(start, end);
    } else if (_filterPeriod == 'Bulan ini') {
      final start = DateTime(now.year, now.month, 1);
      _customStart = start;
      _customEnd = DateTime(now.year, now.month, now.day);
      result = await DBHelper.instance.getTransactionsByPeriod(start, end);
    } else if (_filterPeriod == 'Tahun ini') {
      final start = DateTime(now.year, 1, 1);
      _customStart = start;
      _customEnd = DateTime(now.year, now.month, now.day);
      result = await DBHelper.instance.getTransactionsByPeriod(start, end);
    } else if (_filterPeriod == 'Custom') {
      if (_customStart == null) {
        result = await DBHelper.instance.getAllTransactions();
      } else {
        final start = DateTime(
            _customStart!.year, _customStart!.month, _customStart!.day);
        final customEnd = _customEnd != null
            ? DateTime(_customEnd!.year, _customEnd!.month, _customEnd!.day,
            23, 59, 59)
            : DateTime(_customStart!.year, _customStart!.month,
            _customStart!.day, 23, 59, 59);
        result =
        await DBHelper.instance.getTransactionsByPeriod(start, customEnd);
      }
    } else {
      // Semua
      _customStart = null;
      _customEnd = null;
      result = await DBHelper.instance.getAllTransactions();
    }

    // Filter tipe
    if (_filterType == 'Pemasukan') {
      result = result.where((t) => t.type == 'income').toList();
    } else if (_filterType == 'Pengeluaran') {
      result = result.where((t) => t.type == 'expense').toList();
    }

    setState(() => _transactions = result);
  }

  double get _totalIncome => _transactions
      .where((t) => t.type == 'income')
      .fold(0, (sum, t) => sum + t.amount);

  double get _totalExpense => _transactions
      .where((t) => t.type == 'expense')
      .fold(0, (sum, t) => sum + t.amount);

  Map<String, List<TransactionModel>> get _groupedTransactions {
    final Map<String, List<TransactionModel>> grouped = {};
    for (var t in _transactions) {
      final key = DateFormat('dd MMMM yyyy', 'id_ID').format(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Filter Periode
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _periods.map((period) {
                      final isSelected = _filterPeriod == period;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(period),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _filterPeriod = period);
                            _loadTransactions();
                          },
                          selectedColor: const Color(0xFF2E7D32),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 10),

                // 2 Kolom Tanggal
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _customStart ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            helpText: 'Tanggal Mulai',
                          );
                          if (picked != null) {
                            setState(() {
                              _customStart = picked;
                              _filterPeriod = 'Custom';
                              if (_customEnd != null &&
                                  _customEnd!.isBefore(picked)) {
                                _customEnd = picked;
                              }
                            });
                            _loadTransactions();
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Dari',
                            prefixIcon: const Icon(Icons.calendar_today,
                                size: 18),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          child: Text(
                            _customStart != null
                                ? DateFormat('dd/MM/yyyy')
                                .format(_customStart!)
                                : '-',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _customEnd ??
                                _customStart ??
                                DateTime.now(),
                            firstDate: _customStart ?? DateTime(2000),
                            lastDate: DateTime(2100),
                            helpText: 'Tanggal Akhir',
                          );
                          if (picked != null) {
                            setState(() {
                              _customEnd = picked;
                              _filterPeriod = 'Custom';
                            });
                            _loadTransactions();
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Sampai',
                            prefixIcon: const Icon(Icons.calendar_today,
                                size: 18),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          child: Text(
                            _customEnd != null
                                ? DateFormat('dd/MM/yyyy')
                                .format(_customEnd!)
                                : '-',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Filter Tipe
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _types.map((type) {
                      final isSelected = _filterType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _filterType = type);
                            _loadTransactions();
                          },
                          selectedColor: const Color(0xFF2E7D32),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Ringkasan
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: _buildSummary(
                      'Pemasukan', _totalIncome, Colors.green),
                ),
                Expanded(
                  child: _buildSummary(
                      'Pengeluaran', _totalExpense, Colors.red),
                ),
                Expanded(
                  child: _buildSummary(
                    'Selisih',
                    _totalIncome - _totalExpense,
                    _totalIncome - _totalExpense >= 0
                        ? Colors.blue
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // List Transaksi
          Expanded(
            child: _transactions.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Tidak ada transaksi',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _groupedTransactions.length,
              itemBuilder: (context, index) {
                final date =
                _groupedTransactions.keys.elementAt(index);
                final items = _groupedTransactions[date]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        date,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ...items.map((t) => TransactionCard(
                      transaction: t,
                      onDelete: () async {
                        await DBHelper.instance
                            .deleteTransaction(t.id!);
                        _loadTransactions();
                      },
                      onEdit: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddTransactionScreen(
                                    transaction: t),
                          ),
                        );
                        _loadTransactions();
                      },
                    )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(
          CurrencyFormatter.formatCompact(amount),
          style: TextStyle(
              fontWeight: FontWeight.bold, color: color, fontSize: 13),
        ),
      ],
    );
  }
}