import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../database/db_helper.dart';
import '../models/transaction.dart';
import '../utils/currency_formatter.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _selectedPeriod = 'Semua';
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  DateTime? _customStart;
  DateTime? _customEnd;

  final List<String> _periods = [
    'Semua', 'Hari ini', 'Minggu ini', 'Bulan ini', 'Tahun ini'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final now = DateTime.now();
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (_selectedPeriod == 'Semua') {
      final all = await DBHelper.instance.getAllTransactions();
      setState(() {
        _transactions = all;
        _isLoading = false;
      });
      return;
    }

    DateTime start;

    if (_selectedPeriod == 'Hari ini') {
      start = DateTime(now.year, now.month, now.day);
      _customStart = start;
      _customEnd = null;
    } else if (_selectedPeriod == 'Minggu ini') {
      start = now.subtract(Duration(days: now.weekday - 1));
      start = DateTime(start.year, start.month, start.day);
      _customStart = start;
      _customEnd = DateTime(now.year, now.month, now.day);
    } else if (_selectedPeriod == 'Bulan ini') {
      start = DateTime(now.year, now.month, 1);
      _customStart = start;
      _customEnd = DateTime(now.year, now.month, now.day);
    } else if (_selectedPeriod == 'Tahun ini') {
      start = DateTime(now.year, 1, 1);
      _customStart = start;
      _customEnd = DateTime(now.year, now.month, now.day);
    } else {
      if (_customStart == null) {
        setState(() => _isLoading = false);
        return;
      }
      start = DateTime(
          _customStart!.year, _customStart!.month, _customStart!.day);
      end = _customEnd != null
          ? DateTime(_customEnd!.year, _customEnd!.month, _customEnd!.day,
          23, 59, 59)
          : DateTime(_customStart!.year, _customStart!.month,
          _customStart!.day, 23, 59, 59);
    }

    final result =
    await DBHelper.instance.getTransactionsByPeriod(start, end);

    setState(() {
      _transactions = result;
      _isLoading = false;
    });
  }

  double get _totalIncome => _transactions
      .where((t) => t.type == 'income')
      .fold(0, (sum, t) => sum + t.amount);

  double get _totalExpense => _transactions
      .where((t) => t.type == 'expense')
      .fold(0, (sum, t) => sum + t.amount);

  Map<String, double> get _expenseByCategory {
    final Map<String, double> result = {};
    for (var t in _transactions.where((t) => t.type == 'expense')) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    final sorted = Map.fromEntries(
        result.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
    return sorted;
  }

  String get _periodLabel {
    if (_selectedPeriod == 'Semua') return 'Semua Waktu';
    if (_selectedPeriod != 'Custom') return _selectedPeriod;
    if (_customStart == null) return '-';
    final fmt = DateFormat('dd MMM yyyy');
    if (_customEnd == null) return fmt.format(_customStart!);
    return '${fmt.format(_customStart!)} - ${fmt.format(_customEnd!)}';
  }

  Future<void> _exportPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.green800,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Laporan Keuangan',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Periode: $_periodLabel',
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                  pw.Text(
                    'Dicetak: ${DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now())}',
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              children: [
                _buildPDFSummaryBox('Total Pemasukan',
                    CurrencyFormatter.format(_totalIncome), PdfColors.green),
                pw.SizedBox(width: 8),
                _buildPDFSummaryBox('Total Pengeluaran',
                    CurrencyFormatter.format(_totalExpense), PdfColors.red),
                pw.SizedBox(width: 8),
                _buildPDFSummaryBox(
                  'Saldo',
                  CurrencyFormatter.format(_totalIncome - _totalExpense),
                  _totalIncome - _totalExpense >= 0
                      ? PdfColors.blue
                      : PdfColors.orange,
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Detail Transaksi',
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration:
                  const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildPDFTableCell('Judul', isHeader: true),
                    _buildPDFTableCell('Kategori', isHeader: true),
                    _buildPDFTableCell('Tipe', isHeader: true),
                    _buildPDFTableCell('Nominal', isHeader: true),
                  ],
                ),
                ..._transactions.map(
                      (t) => pw.TableRow(
                    children: [
                      _buildPDFTableCell(t.title),
                      _buildPDFTableCell(t.category),
                      _buildPDFTableCell(t.type == 'income'
                          ? 'Pemasukan'
                          : 'Pengeluaran'),
                      _buildPDFTableCell(
                        '${t.type == 'income' ? '+' : '-'} ${CurrencyFormatter.format(t.amount)}',
                        color: t.type == 'income'
                            ? PdfColors.green
                            : PdfColors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            if (_expenseByCategory.isNotEmpty) ...[
              pw.Text(
                'Pengeluaran per Kategori',
                style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              ..._expenseByCategory.entries.map(
                    (e) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(e.key),
                      pw.Text(
                        CurrencyFormatter.format(e.value),
                        style: const pw.TextStyle(color: PdfColors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPDFSummaryBox(
      String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: const pw.TextStyle(
                    fontSize: 10, color: PdfColors.grey)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildPDFTableCell(String text,
      {bool isHeader = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : null,
          color: color,
          fontSize: 10,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Laporan Keuangan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: _transactions.isEmpty ? null : _exportPDF,
            tooltip: 'Export PDF',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Periode
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _periods.map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(period),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedPeriod = period);
                        _loadData();
                      },
                      selectedColor: const Color(0xFF2E7D32),
                      labelStyle: TextStyle(
                        color:
                        isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

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
                          _selectedPeriod = 'Custom';
                          if (_customEnd != null &&
                              _customEnd!.isBefore(picked)) {
                            _customEnd = picked;
                          }
                        });
                        _loadData();
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Dari',
                        prefixIcon: const Icon(
                            Icons.calendar_today,
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
                          _selectedPeriod = 'Custom';
                        });
                        _loadData();
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Sampai',
                        prefixIcon: const Icon(
                            Icons.calendar_today,
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

            const SizedBox(height: 16),

            // Kartu Ringkasan
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Pemasukan',
                    _totalIncome,
                    Colors.green,
                    Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    'Pengeluaran',
                    _totalExpense,
                    Colors.red,
                    Icons.arrow_upward,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Saldo Periode Ini',
                        style:
                        TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      CurrencyFormatter.format(
                          _totalIncome - _totalExpense),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _totalIncome - _totalExpense >= 0
                            ? Colors.blue
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_expenseByCategory.isNotEmpty) ...[
              const Text(
                'Pengeluaran per Kategori',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._expenseByCategory.entries.map(
                    (e) => Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key),
                        Text(
                          CurrencyFormatter.format(e.value),
                          style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _transactions.isEmpty ? null : _exportPDF,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.picture_as_pdf,
                    color: Colors.white),
                label: const Text(
                  'Export ke PDF',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String label, double amount, Color color, IconData icon) {
    return Card(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Text(label,
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.format(amount),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}