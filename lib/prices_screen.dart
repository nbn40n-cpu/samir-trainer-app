import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'app_theme.dart';

class PricesScreen extends StatefulWidget {
  const PricesScreen({super.key});
  @override
  State<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen> {
  final TextEditingController _shhnLesson = TextEditingController();
  final TextEditingController _shhnTest  = TextEditingController();
  final TextEditingController _khsosyLesson = TextEditingController();
  final TextEditingController _khsosyTest  = TextEditingController();
  final TextEditingController _basLesson = TextEditingController();
  final TextEditingController _basTest  = TextEditingController();
  final TextEditingController _trktrLesson = TextEditingController();
  final TextEditingController _trktrTest  = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  void _loadPrices() {
    try {
      PriceSetting? shhn   = pricesList.firstWhere((p) => p.name == 'شحن');
      _shhnLesson.text   = shhn.lessonPrice.toString();
      _shhnTest.text     = shhn.testPrice.toString();
    } catch (e) {}
    try {
      PriceSetting? khsosy = pricesList.firstWhere((p) => p.name == 'خصوصي');
      _khsosyLesson.text = khsosy.lessonPrice.toString();
      _khsosyTest.text   = khsosy.testPrice.toString();
    } catch (e) {}
    try {
      PriceSetting? bas    = pricesList.firstWhere((p) => p.name == 'باص');
      _basLesson.text    = bas.lessonPrice.toString();
      _basTest.text      = bas.testPrice.toString();
    } catch (e) {}
    try {
      PriceSetting? trktr  = pricesList.firstWhere((p) => p.name == 'تركتر');
      _trktrLesson.text  = trktr.lessonPrice.toString();
      _trktrTest.text    = trktr.testPrice.toString();
    } catch (e) {}
  }

  void _savePrices() async {
    pricesList = [
      PriceSetting(id: '1', name: 'شحن',    description: '', lessonPrice: double.parse(_shhnLesson.text),   testPrice: double.parse(_shhnTest.text)),
      PriceSetting(id: '2', name: 'خصوصي',  description: '', lessonPrice: double.parse(_khsosyLesson.text), testPrice: double.parse(_khsosyTest.text)),
      PriceSetting(id: '3', name: 'باص',    description: '', lessonPrice: double.parse(_basLesson.text),   testPrice: double.parse(_basTest.text)),
      PriceSetting(id: '4', name: 'تركتر',  description: '', lessonPrice: double.parse(_trktrLesson.text), testPrice: double.parse(_trktrTest.text)),
    ];
    await saveData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم حفظ جميع الأسعار'), backgroundColor: AppTheme.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الأسعار')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: AppTheme.radiusMd),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline, color: AppTheme.primary),
                        SizedBox(width: 10),
                        Expanded(child: Text('المبلغ = عدد الدروس × سعر الدرس + عدد الاختبارات × سعر الاختبار', style: TextStyle(color: AppTheme.primary, fontSize: 14))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPriceCard('شحن',   Icons.local_shipping, AppTheme.primary, _shhnLesson, _shhnTest),
                  const SizedBox(height: 12),
                  _buildPriceCard('خصوصي', Icons.directions_car, AppTheme.purple,  _khsosyLesson, _khsosyTest),
                  const SizedBox(height: 12),
                  _buildPriceCard('باص',   Icons.directions_bus, AppTheme.teal,    _basLesson, _basTest),
                  const SizedBox(height: 12),
                  _buildPriceCard('تركتر', Icons.agriculture,    AppTheme.warning, _trktrLesson, _trktrTest),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _savePrices,
                icon: const Icon(Icons.save),
                label: const Text('حفظ جميع الأسعار', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(String title, IconData icon, Color color, TextEditingController lessonCtrl, TextEditingController testCtrl) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: AppTheme.radiusSm),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Text(title, style: AppTheme.heading3.copyWith(color: color)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: lessonCtrl,
                    decoration: AppTheme.inputDecoration(label: 'سعر الدرس (شيكل)', prefix: Icon(Icons.school, color: color)),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => (double.tryParse(v ?? '') == null) ? 'رقم غير صحيح' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: testCtrl,
                    decoration: AppTheme.inputDecoration(label: 'سعر الاختبار (شيكل)', prefix: Icon(Icons.quiz, color: color)),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => (double.tryParse(v ?? '') == null) ? 'رقم غير صحيح' : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}