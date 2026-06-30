class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String type; // 'income' atau 'expense'
  final String category;
  final String note;
  final DateTime date;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      type: map['type'],
      category: map['category'],
      note: map['note'],
      date: DateTime.parse(map['date']),
    );
  }
}