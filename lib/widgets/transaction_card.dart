import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/currency_formatter.dart';
import 'package:intl/intl.dart';
import '../screens/detail_transaction_screen.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onDelete,
    this.onEdit,
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailTransactionScreen(
                transaction: transaction,
                onDelete: onDelete,
                onEdit: onEdit ?? () {},
              ),
            ),
          );
        },
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isIncome
                ? Colors.green.withOpacity(0.15)
                : Colors.red.withOpacity(0.15),
            child: Icon(
              _getCategoryIcon(transaction.category),
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
          title: Text(
            transaction.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(transaction.category,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(
                DateFormat('dd MMM yyyy', 'id_ID').format(transaction.date),
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${isIncome ? '+' : '-'} ${CurrencyFormatter.format(transaction.amount)}',
                style: TextStyle(
                  color: isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, size: 18),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Text('Edit', style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit?.call();
                  } else if (value == 'delete') {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Hapus Transaksi'),
                        content: const Text(
                            'Yakin ingin menghapus transaksi ini?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onDelete();
                            },
                            child: const Text('Hapus',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          isThreeLine: true,
        ),
      ),
    );
  }
}