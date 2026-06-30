import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../utils/currency_formatter.dart';
import '../database/db_helper.dart';
import 'add_transaction_screen.dart';

class DetailTransactionScreen extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const DetailTransactionScreen({
    super.key,
    required this.transaction,
    required this.onDelete,
    required this.onEdit,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Makanan & Minuman': return Icons.restaurant;
      case 'Transportasi': return Icons.directions_car;
      case 'Belanja': return Icons.shopping_bag;
      case 'Kesehatan': return Icons.medical_services;
      case 'Pendidikan': return Icons.school;
      case 'Hiburan': return Icons.movie;
      case 'Tagihan': return Icons.receipt;
      case 'Gaji': return Icons.work;
      case 'Usaha': return Icons.store;
      case 'Investasi': return Icons.trending_up;
      default: return Icons.attach_money;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Transaksi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Hapus Transaksi'),
                  content:
                  const Text('Yakin ingin menghapus transaksi ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        onDelete();
                      },
                      child: const Text('Hapus',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header nominal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isIncome
                      ? [const Color(0xFF2E7D32), const Color(0xFF43A047)]
                      : [Colors.red.shade700, Colors.red.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      _getCategoryIcon(transaction.category),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${isIncome ? '+' : '-'} ${CurrencyFormatter.format(transaction.amount)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isIncome ? 'Pemasukan' : 'Pengeluaran',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Detail info
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.category,
                      label: 'Kategori',
                      value: transaction.category,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Tanggal',
                      value: DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                          .format(transaction.date),
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.note,
                      label: 'Catatan',
                      value: transaction.note.isEmpty
                          ? '-'
                          : transaction.note,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}