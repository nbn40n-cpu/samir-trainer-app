import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'main.dart';
import 'app_theme.dart';

class ReportsMenuScreen extends StatelessWidget {
  const ReportsMenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.primary, borderRadius: AppTheme.radiusLg),
            child: Column(children: [
              const Text('تقرير سنوي للكل', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen(reportType: 'yearly_all'))), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary), child: const Text('عرض التقرير السنوي')),
            ]),
          ),
          const SizedBox(height: 16),
          const Text('التقارير الشهرية', style: AppTheme.heading2),
          const SizedBox(height: 8),
          Expanded(child: ListView(children: [
            Row(children: [Expanded(child: _btn(context, 'تقرير رئيسي', AppTheme.teal, 'main_month')), const SizedBox(width: 8), Expanded(child: _btn(context, 'شحن وخصوصي', AppTheme.primary, 'shhn_khsosy_month'))]),
            const SizedBox(height: 6),
            Row(children: [Expanded(child: _btn(context, 'باص وتركتر', AppTheme.secondary, 'bas_trktr_month')), const SizedBox(width: 8), Expanded(child: _btn(context, 'تقرير شحن', AppTheme.success, 'shhn_month'))]),
            const SizedBox(height: 6),
            Row(children: [Expanded(child: _btn(context, 'تقرير خصوصي', AppTheme.purple, 'khsosy_month')), const SizedBox(width: 8), Expanded(child: _btn(context, 'تقرير باص', AppTheme.teal, 'bas_month'))]),
            const SizedBox(height: 6),
            _btn(context, 'تقرير تركتر', AppTheme.warning, 'trktr_month'),
          ])),
        ]),
      ),
    );
  }
  Widget _btn(BuildContext context, String title, Color color, String type) {
    return ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsScreen(reportType: type))), style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 8)), child: Text(title));
  }
}

class ReportsScreen extends StatefulWidget {
  final String reportType;
  const ReportsScreen({super.key, required this.reportType});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int? _selectedMonth;
  int? _selectedYear;
  final List<int> _months = List.generate(12, (i) => i + 1);
  final List<int> _years  = List.generate(10, (i) => DateTime.now().year - i);
  static const List<String> _monthNames = ['','يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now().month;
    _selectedYear  = DateTime.now().year;
  }

  // حساب الرصيد قبل بداية الفترة
  double _getPreviousBalance(DateTime startDate) {
    dailyWorks.sort((a,b) => a.date.compareTo(b.date));
    DailyWork? lastBefore;
    for (var work in dailyWorks) {
      DateTime wDate = DateFormat('yyyy-MM-dd').parse(work.date);
      if (wDate.isBefore(startDate)) {
        lastBefore = work;
      } else {
        break;
      }
    }
    return lastBefore?.dailyBalance ?? oldBalance;
  }

  List<DailyWork> _filterData() {
    return dailyWorks.where((work) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(work.date);
      if (widget.reportType == 'yearly_all') return date.year == _selectedYear;
      return date.year == _selectedYear && date.month == _selectedMonth;
    }).toList();
  }

  String _getReportTitle() {
    switch (widget.reportType) {
      case 'main_month':        return 'التقرير الرئيسي الشهري';
      case 'yearly_all':        return 'التقرير السنوي الكامل';
      case 'shhn_khsosy_month': return 'تقرير شحن وخصوصي';
      case 'bas_trktr_month':   return 'تقرير باص وتركتر';
      case 'shhn_month':        return 'تقرير شحن';
      case 'khsosy_month':      return 'تقرير خصوصي';
      case 'bas_month':         return 'تقرير باص';
      case 'trktr_month':       return 'تقرير تركتر';
      default:                  return 'تقرير';
    }
  }

  void _calculateTotals(List<DailyWork> data, {
    required Function(double) setTotalIncome,
    required Function(double) setTotalPayments,
    required Function(double) setTotalWithdrawals,
    required Function(double) setMonthNet,
  }) {
    double income = data.fold(0.0, (s,w) => s + w.totalIncome);
    double payments = data.fold(0.0, (s,w) => s + w.paymentToday);
    double withdrawals = data.fold(0.0, (s,w) => s + w.withdrawalToday);
    double net = income - (payments + withdrawals);
    setTotalIncome(income);
    setTotalPayments(payments);
    setTotalWithdrawals(withdrawals);
    setMonthNet(net);
  }

  Future<void> _printReport() async {
    final data = _filterData();
    if (data.isEmpty) return;
    final doc = pw.Document();
    final font = await PdfGoogleFonts.cairoRegular();
    final bold = await PdfGoogleFonts.cairoBold();
    String period;
    if (widget.reportType == 'yearly_all') {
      period = '$_selectedYear';
    } else {
      period = '$_selectedMonth-$_selectedYear';
    }
    List<_VehicleInfo> vehicles = _buildVehicleList(data);
    double totalIncome=0, totalPayments=0, totalWithdrawals=0, monthNet=0;
    _calculateTotals(data,
      setTotalIncome: (v) => totalIncome = v,
      setTotalPayments: (v) => totalPayments = v,
      setTotalWithdrawals: (v) => totalWithdrawals = v,
      setMonthNet: (v) => monthNet = v,
    );
    DateTime startDate;
    if (widget.reportType == 'yearly_all') {
      startDate = DateTime(_selectedYear!, 1, 1);
    } else {
      startDate = DateTime(_selectedYear!, _selectedMonth!, 1);
    }
    double previousBalance = _getPreviousBalance(startDate);
    double finalBalance = previousBalance + monthNet;

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
        pw.Container(padding: const pw.EdgeInsets.all(12), color: PdfColors.blue800,
          child: pw.Column(children: [
            pw.Text('نظام سمير المحاسبي', style: pw.TextStyle(font: bold, fontSize: 20, color: PdfColors.white)),
            pw.SizedBox(height: 4),
            pw.Text(_getReportTitle(), style: pw.TextStyle(font: font, fontSize: 12, color: PdfColor(1,1,1,0.7))),
            pw.Text('الفترة: $period', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColor(1,1,1,0.7))),
          ]),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {0: pw.FlexColumnWidth(2),1: pw.FlexColumnWidth(1),2: pw.FlexColumnWidth(1),3: pw.FlexColumnWidth(1),4: pw.FlexColumnWidth(1)},
          children: [
            pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.blue100), children: ['النوع','الدروس','الاختبارات','المبلغ','النتيجة'].map((h)=>pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(h, style: pw.TextStyle(font: bold, fontSize: 11)))).toList()),
            ...vehicles.map((v)=>pw.TableRow(children: [ _cell(v.name,font), _cell(v.dars.toString(),font), _cell(v.test.toString(),font), _cell('${v.amount.toStringAsFixed(0)} ₪',bold), _cell(v.result,font) ])),
            pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.grey100), children: [ _cell('المجموع',bold), _cell(vehicles.fold(0,(s,v)=>s+v.dars).toString(),bold), _cell(vehicles.fold(0,(s,v)=>s+v.test).toString(),bold), _cell('${vehicles.fold(0.0,(s,v)=>s+v.amount).toStringAsFixed(0)} ₪',bold), _cell('',font) ]),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Container(padding: const pw.EdgeInsets.all(8), decoration: pw.BoxDecoration(color: PdfColors.grey100), child: pw.Column(children: [
          _printRow('المبلغ المطلوب (إجمالي الإيرادات):', '${totalIncome.toStringAsFixed(0)} ₪', bold, font),
          _printRow('المسحوبات:', '${totalWithdrawals.toStringAsFixed(0)} ₪', bold, font),
          _printRow('الدفعات:', '${totalPayments.toStringAsFixed(0)} ₪', bold, font),
          _printRow('مبلغ الشهر (صافي الإيرادات):', '${monthNet.toStringAsFixed(0)} ₪', bold, font),
          _printRow('الرصيد السابق (آخر رصيد قبل الفترة):', '${previousBalance.toStringAsFixed(0)} ₪', bold, font, color: PdfColors.orange),
          pw.SizedBox(height: 4),
          _printRow('الرصيد النهائي:', '${finalBalance.toStringAsFixed(0)} ₪', bold, font, color: PdfColors.green, isFinal: true),
        ])),
        pw.Spacer(),
        pw.Text('تاريخ الطباعة: ${DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now())}', style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey500)),
      ]),
    ));
    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  pw.Widget _printRow(String label, String value, pw.Font bold, pw.Font font, {PdfColor? color, bool isFinal = false}) {
    return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Text(label, style: pw.TextStyle(font: bold, fontSize: 11, color: color ?? PdfColors.black)),
      pw.Text(value, style: pw.TextStyle(font: isFinal ? bold : font, fontSize: isFinal ? 14 : 11, color: color ?? PdfColors.black)),
    ]);
  }

  pw.Widget _cell(String text, pw.Font font) => pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 10), textAlign: pw.TextAlign.center));

  List<_VehicleInfo> _buildVehicleList(List<DailyWork> data) {
    return [
      _VehicleInfo('شحن', Icons.local_shipping, AppTheme.primary, data.fold(0,(s,w)=>s+w.shhnDars), data.fold(0,(s,w)=>s+w.shhnTest), data.fold(0.0,(s,w)=>s+w.shhnAmount), ''),
      _VehicleInfo('خصوصي', Icons.directions_car, AppTheme.purple, data.fold(0,(s,w)=>s+w.khsosyDars), data.fold(0,(s,w)=>s+w.khsosyTest), data.fold(0.0,(s,w)=>s+w.khsosyAmount), ''),
      _VehicleInfo('باص', Icons.directions_bus, AppTheme.teal, data.fold(0,(s,w)=>s+w.basDars), data.fold(0,(s,w)=>s+w.basTest), data.fold(0.0,(s,w)=>s+w.basAmount), ''),
      _VehicleInfo('تركتر', Icons.agriculture, AppTheme.warning, data.fold(0,(s,w)=>s+w.trktrDars), data.fold(0,(s,w)=>s+w.trktrTest), data.fold(0.0,(s,w)=>s+w.trktrAmount), ''),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getReportTitle()),
        titleTextStyle: const TextStyle(fontSize: 18),
        actions: [
          IconButton(icon: const Icon(Icons.print), onPressed: _filterData().isEmpty ? null : _printReport),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          Row(children: [
            if (!widget.reportType.contains('yearly'))
              Expanded(child: DropdownButtonFormField<int>(
                value: _selectedMonth,
                items: _months.map((m)=>DropdownMenuItem(value: m, child: Text(m.toString()))).toList(),
                onChanged: (v) => setState(() => _selectedMonth = v),
                decoration: const InputDecoration(labelText: 'الشهر', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                style: const TextStyle(fontSize: 12),
              )),
            if (!widget.reportType.contains('yearly')) const SizedBox(width: 6),
            Expanded(child: DropdownButtonFormField<int>(
              value: _selectedYear,
              items: _years.map((y)=>DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
              onChanged: (v) => setState(() => _selectedYear = v),
              decoration: const InputDecoration(labelText: 'السنة', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
              style: const TextStyle(fontSize: 12),
            )),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('تحديث'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
            ),
          ]),
          const SizedBox(height: 8),
          Expanded(child: _buildReportContent()),
        ]),
      ),
    );
  }

  Widget _buildReportContent() {
    final data = _filterData();
    if (data.isEmpty) return const Center(child: Text('لا توجد بيانات', style: TextStyle(fontSize: 14)));
    final vehicles = _buildVehicleList(data);
    double totalIncome=0, totalPayments=0, totalWithdrawals=0, monthNet=0;
    _calculateTotals(data,
      setTotalIncome: (v) => totalIncome = v,
      setTotalPayments: (v) => totalPayments = v,
      setTotalWithdrawals: (v) => totalWithdrawals = v,
      setMonthNet: (v) => monthNet = v,
    );
    DateTime startDate;
    if (widget.reportType == 'yearly_all') {
      startDate = DateTime(_selectedYear!, 1, 1);
    } else {
      startDate = DateTime(_selectedYear!, _selectedMonth!, 1);
    }
    double previousBalance = _getPreviousBalance(startDate);
    double finalBalance = previousBalance + monthNet;

    final List<Color> rowColors = [
      Colors.blue.shade50,
      Colors.green.shade50,
      Colors.orange.shade50,
      Colors.purple.shade50,
      Colors.teal.shade50,
      Colors.pink.shade50,
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          ...vehicles.map((v)=>Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(color: v.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Expanded(child: Text(v.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              Text('دروس: ${v.dars}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(width: 8),
              Text('اختبارات: ${v.test}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(width: 8),
              Text('${v.amount.toStringAsFixed(0)} ₪', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ]),
          )),
          const Divider(thickness: 1, height: 16),
          _summaryRow('المبلغ المطلوب (إجمالي الإيرادات):', '${totalIncome.toStringAsFixed(0)} ₪', isBold: true, color: rowColors[0]),
          _summaryRow('المسحوبات:', '${totalWithdrawals.toStringAsFixed(0)} ₪', color: rowColors[1]),
          _summaryRow('الدفعات:', '${totalPayments.toStringAsFixed(0)} ₪', color: rowColors[2]),
          _summaryRow('مبلغ الشهر (صافي الإيرادات):', '${monthNet.toStringAsFixed(0)} ₪', isBold: true, color: rowColors[3]),
          _summaryRow('الرصيد السابق (آخر رصيد قبل الفترة):', '${previousBalance.toStringAsFixed(0)} ₪', isBold: true, color: rowColors[4], textColor: Colors.orange),
          const Divider(thickness: 1, height: 16),
          _summaryRow('الرصيد النهائي:', '${finalBalance.toStringAsFixed(0)} ₪', isBold: true, isTotal: true, color: rowColors[5], textColor: AppTheme.success),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false, bool isTotal = false, Color? color, Color? textColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color ?? Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isBold ? 14 : 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: FontWeight.bold, color: textColor ?? AppTheme.textDark)),
        ],
      ),
    );
  }
}

class _VehicleInfo {
  final String name; final IconData icon; final Color color; final int dars, test; final double amount; final String result;
  _VehicleInfo(this.name, this.icon, this.color, this.dars, this.test, this.amount, this.result);
}