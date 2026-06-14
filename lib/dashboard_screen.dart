import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'app_theme.dart';

class DashboardScreen extends StatefulWidget {
  final DateTime? initialDate;
  const DashboardScreen({super.key, this.initialDate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _results = {
    'shhn': 'غير محدد',
    'khsosy': 'غير محدد',
    'bas': 'غير محدد',
    'trktr': 'غير محدد',
  };
  final List<String> _resultOptions = ['غير محدد', 'ناجح', 'راسب'];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _initControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _initControllers() {
    _controllers['shhn_dars'] = TextEditingController(text: '0');
    _controllers['shhn_test'] = TextEditingController(text: '0');
    _controllers['khsosy_dars'] = TextEditingController(text: '0');
    _controllers['khsosy_test'] = TextEditingController(text: '0');
    _controllers['bas_dars'] = TextEditingController(text: '0');
    _controllers['bas_test'] = TextEditingController(text: '0');
    _controllers['trktr_dars'] = TextEditingController(text: '0');
    _controllers['trktr_test'] = TextEditingController(text: '0');
    _controllers['payment'] = TextEditingController(text: '0');
    _controllers['withdrawal'] = TextEditingController(text: '0');
  }

  void _loadData() {
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    DailyWork? work;
    try { work = dailyWorks.firstWhere((w) => w.date == dateStr); } catch (e) { work = null; }
    if (work != null) {
      _controllers['shhn_dars']!.text = work.shhnDars.toString();
      _controllers['shhn_test']!.text = work.shhnTest.toString();
      _results['shhn'] = work.shhnTestResult;
      _controllers['khsosy_dars']!.text = work.khsosyDars.toString();
      _controllers['khsosy_test']!.text = work.khsosyTest.toString();
      _results['khsosy'] = work.khsosyTestResult;
      _controllers['bas_dars']!.text = work.basDars.toString();
      _controllers['bas_test']!.text = work.basTest.toString();
      _results['bas'] = work.basTestResult;
      _controllers['trktr_dars']!.text = work.trktrDars.toString();
      _controllers['trktr_test']!.text = work.trktrTest.toString();
      _results['trktr'] = work.trktrTestResult;
      _controllers['payment']!.text = work.paymentToday.toString();
      _controllers['withdrawal']!.text = work.withdrawalToday.toString();
    }
    setState(() {});
  }

  PriceSetting? _findPrice(String name) {
    try { return pricesList.firstWhere((p) => p.name == name); } catch (e) { return null; }
  }

  void _calculateAmounts(DailyWork work) {
    final shhnP = _findPrice('شحن');
    final khsosyP = _findPrice('خصوصي');
    final basP = _findPrice('باص');
    final trktrP = _findPrice('تركتر');
    if (shhnP != null) work.shhnAmount = work.shhnDars * shhnP.lessonPrice + work.shhnTest * shhnP.testPrice;
    if (khsosyP != null) work.khsosyAmount = work.khsosyDars * khsosyP.lessonPrice + work.khsosyTest * khsosyP.testPrice;
    if (basP != null) work.basAmount = work.basDars * basP.lessonPrice + work.basTest * basP.testPrice;
    if (trktrP != null) work.trktrAmount = work.trktrDars * trktrP.lessonPrice + work.trktrTest * trktrP.testPrice;
  }

  void _saveData() async {
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    DailyWork work = dailyWorks.firstWhere((w) => w.date == dateStr, orElse: () => DailyWork(date: dateStr));
    if (!dailyWorks.any((w) => w.date == dateStr)) dailyWorks.add(work);
    work.shhnDars = int.tryParse(_controllers['shhn_dars']!.text) ?? 0;
    work.shhnTest = int.tryParse(_controllers['shhn_test']!.text) ?? 0;
    work.shhnTestResult = _results['shhn']!;
    work.khsosyDars = int.tryParse(_controllers['khsosy_dars']!.text) ?? 0;
    work.khsosyTest = int.tryParse(_controllers['khsosy_test']!.text) ?? 0;
    work.khsosyTestResult = _results['khsosy']!;
    work.basDars = int.tryParse(_controllers['bas_dars']!.text) ?? 0;
    work.basTest = int.tryParse(_controllers['bas_test']!.text) ?? 0;
    work.basTestResult = _results['bas']!;
    work.trktrDars = int.tryParse(_controllers['trktr_dars']!.text) ?? 0;
    work.trktrTest = int.tryParse(_controllers['trktr_test']!.text) ?? 0;
    work.trktrTestResult = _results['trktr']!;
    work.paymentToday = double.tryParse(_controllers['payment']!.text) ?? 0;
    work.withdrawalToday = double.tryParse(_controllers['withdrawal']!.text) ?? 0;
    _calculateAmounts(work);
    _recalculateBalances();
    await saveData();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم الحفظ'), backgroundColor: AppTheme.success),
    );
  }

  void _addNewDay() => setState(() { _selectedDate = DateTime.now(); _loadData(); });

  void _deleteCurrentDay() async {
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    if (!dailyWorks.any((w) => w.date == dateStr)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا توجد بيانات'), backgroundColor: AppTheme.warning));
      return;
    }
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف اليوم'),
        content: Text('حذف يوم ${DateFormat('yyyy/MM/dd').format(_selectedDate)}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        dailyWorks.removeWhere((w) => w.date == dateStr);
        _loadData();
      });
      _recalculateBalances();
      await saveData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم الحذف'), backgroundColor: AppTheme.success));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الادخال اليومي'),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle), onPressed: _addNewDay, tooltip: 'يوم جديد'),
          IconButton(icon: const Icon(Icons.delete_forever), onPressed: _deleteCurrentDay, tooltip: 'حذف اليوم'),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveData, tooltip: 'حفظ'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                InkWell(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      locale: const Locale('ar'),
                    );
                    if (picked != null) setState(() { _selectedDate = picked; _loadData(); });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: AppTheme.radiusMd,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('d-M-yyyy').format(_selectedDate), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        const Icon(Icons.calendar_today, color: AppTheme.primary, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextFormField(controller: _controllers['payment'], decoration: const InputDecoration(labelText: 'دفعة اليوم', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _controllers['withdrawal'], decoration: const InputDecoration(labelText: 'مسحوب اليوم', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                ]),
                const SizedBox(height: 8),
                _vehicleCard('شحن', AppTheme.primary, 'shhn'),
                const SizedBox(height: 6),
                _vehicleCard('خصوصي', AppTheme.purple, 'khsosy'),
                const SizedBox(height: 6),
                _vehicleCard('باص', AppTheme.teal, 'bas'),
                const SizedBox(height: 6),
                _vehicleCard('تركتر', AppTheme.warning, 'trktr'),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _saveData,
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('حفظ البيانات', style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _vehicleCard(String title, Color color, String prefix) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Row(children: [
              Icon(Icons.directions_car, color: color, size: 20),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(child: TextFormField(controller: _controllers['${prefix}_dars'], decoration: const InputDecoration(labelText: 'دروس', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
              const SizedBox(width: 6),
              Expanded(child: TextFormField(controller: _controllers['${prefix}_test'], decoration: const InputDecoration(labelText: 'اختبارات', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
              const SizedBox(width: 6),
              Expanded(child: DropdownButtonFormField<String>(
                value: _results[prefix],
                items: _resultOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                onChanged: (val) => setState(() => _results[prefix] = val!),
                decoration: const InputDecoration(labelText: 'النتيجة', border: OutlineInputBorder()),
              )),
            ]),
          ],
        ),
      ),
    );
  }
}