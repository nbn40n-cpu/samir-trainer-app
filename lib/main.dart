import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// ------------------- AppTheme -------------------
class AppTheme {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color secondary = Color(0xFFFF8F00);
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color purple = Color(0xFF7B1FA2);
  static const Color teal = Color(0xFF00897B);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surfaceColor = Colors.white;
  static const Color textDark = Color(0xFF263238);
  static const Color textMedium = Color(0xFF546E7A);
  static const Color textLight = Color(0xFF90A4AE);

  static const TextStyle heading1 = TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark);
  static const TextStyle heading2 = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark);
  static const TextStyle heading3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textDark);
  static const TextStyle heading4 = TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white);
  static const TextStyle bodyMedium = TextStyle(fontSize: 13, color: textMedium);
  static const TextStyle bodySmall = TextStyle(fontSize: 11, color: textLight);

  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(10));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(14));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(6));
  static const BoxShadow shadowMd = BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 3));
  static const BoxShadow shadowSm = BoxShadow(color: Color(0x0D000000), blurRadius: 3, offset: Offset(0, 2));

  static ThemeData get theme => ThemeData(
    useMaterial3: false,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(backgroundColor: primary, foregroundColor: Colors.white, centerTitle: true, titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), shape: RoundedRectangleBorder(borderRadius: radiusMd)),
    ),
  );
}

// ------------------- Models -------------------
class DailyWork {
  final String date;
  int shhnDars, shhnTest, khsosyDars, khsosyTest, basDars, basTest, trktrDars, trktrTest;
  String shhnResult, khsosyResult, basResult, trktrResult;
  double shhnAmount, khsosyAmount, basAmount, trktrAmount, expenses, paymentToday, dailyBalance;

  DailyWork({
    required this.date,
    this.shhnDars = 0,
    this.shhnTest = 0,
    this.shhnResult = 'غير محدد',
    this.shhnAmount = 0.0,
    this.khsosyDars = 0,
    this.khsosyTest = 0,
    this.khsosyResult = 'غير محدد',
    this.khsosyAmount = 0.0,
    this.basDars = 0,
    this.basTest = 0,
    this.basResult = 'غير محدد',
    this.basAmount = 0.0,
    this.trktrDars = 0,
    this.trktrTest = 0,
    this.trktrResult = 'غير محدد',
    this.trktrAmount = 0.0,
    this.expenses = 0.0,
    this.paymentToday = 0.0,
    this.dailyBalance = 0.0,
  });

  double get totalIncome => shhnAmount + khsosyAmount + basAmount + trktrAmount;

  Map<String, dynamic> toJson() => {
    'date': date,
    'shhnDars': shhnDars,
    'shhnTest': shhnTest,
    'shhnResult': shhnResult,
    'shhnAmount': shhnAmount,
    'khsosyDars': khsosyDars,
    'khsosyTest': khsosyTest,
    'khsosyResult': khsosyResult,
    'khsosyAmount': khsosyAmount,
    'basDars': basDars,
    'basTest': basTest,
    'basResult': basResult,
    'basAmount': basAmount,
    'trktrDars': trktrDars,
    'trktrTest': trktrTest,
    'trktrResult': trktrResult,
    'trktrAmount': trktrAmount,
    'expenses': expenses,
    'paymentToday': paymentToday,
    'dailyBalance': dailyBalance,
  };

  factory DailyWork.fromJson(Map<String, dynamic> json) => DailyWork(
    date: json['date'],
    shhnDars: json['shhnDars'] ?? 0,
    shhnTest: json['shhnTest'] ?? 0,
    shhnResult: json['shhnResult'] ?? 'غير محدد',
    shhnAmount: (json['shhnAmount'] ?? 0).toDouble(),
    khsosyDars: json['khsosyDars'] ?? 0,
    khsosyTest: json['khsosyTest'] ?? 0,
    khsosyResult: json['khsosyResult'] ?? 'غير محدد',
    khsosyAmount: (json['khsosyAmount'] ?? 0).toDouble(),
    basDars: json['basDars'] ?? 0,
    basTest: json['basTest'] ?? 0,
    basResult: json['basResult'] ?? 'غير محدد',
    basAmount: (json['basAmount'] ?? 0).toDouble(),
    trktrDars: json['trktrDars'] ?? 0,
    trktrTest: json['trktrTest'] ?? 0,
    trktrResult: json['trktrResult'] ?? 'غير محدد',
    trktrAmount: (json['trktrAmount'] ?? 0).toDouble(),
    expenses: (json['expenses'] ?? 0).toDouble(),
    paymentToday: (json['paymentToday'] ?? 0).toDouble(),
    dailyBalance: (json['dailyBalance'] ?? 0).toDouble(),
  );
}

class PriceSetting {
  final String id, name;
  double lessonPrice, testPrice;
  PriceSetting({required this.id, required this.name, required this.lessonPrice, required this.testPrice});
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'lessonPrice': lessonPrice, 'testPrice': testPrice};
  factory PriceSetting.fromJson(Map<String, dynamic> json) => PriceSetting(id: json['id'], name: json['name'], lessonPrice: (json['lessonPrice'] ?? 0).toDouble(), testPrice: (json['testPrice'] ?? 0).toDouble());
}

// ------------------- Firebase Service -------------------
class FirestoreService {
  final CollectionReference _dailyWorksRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('dailyWorks');
  final CollectionReference _pricesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('prices');

  Stream<List<DailyWork>> getDailyWorks() {
    return _dailyWorksRef.orderBy('date').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => DailyWork.fromJson(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Stream<List<PriceSetting>> getPrices() {
    return _pricesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => PriceSetting.fromJson(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> saveDailyWork(DailyWork work) async {
    await _dailyWorksRef.doc(work.date).set(work.toJson());
  }

  Future<void> savePrices(List<PriceSetting> prices) async {
    for (var p in prices) {
      await _pricesRef.doc(p.id).set(p.toJson());
    }
  }
}

// ------------------- Main App -------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }
  runApp(const SamirTrainerApp());
}

class SamirTrainerApp extends StatelessWidget {
  const SamirTrainerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام سمير',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
      locale: const Locale('ar', ''),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [const Locale('ar', '')],
    );
  }
}

// ------------------- SplashScreen (ثابت مع زر دخول) -------------------
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primary, AppTheme.primaryLight, AppTheme.surfaceColor],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [AppTheme.shadowMd],
                ),
                child: const Icon(Icons.account_balance_wallet, size: 80, color: AppTheme.primary),
              ),
              const SizedBox(height: 30),
              const Text(
                'برنامج سمير المحاسبي',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'إدارة مدارس القيادة',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLg),
                ),
                child: const Text('الدخول', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------- HomeScreen -------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الرئيسية')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                _buildBtn(context, 'الادخال اليومي', Icons.edit_note, AppTheme.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen()))),
                const SizedBox(width: 10),
                _buildBtn(context, 'تعديل يوم سابق', Icons.edit_calendar, AppTheme.warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => DashboardScreen(initialDate: DateTime.now())))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildBtn(context, 'التقارير', Icons.bar_chart, AppTheme.secondary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsMenuScreen()))),
                const SizedBox(width: 10),
                _buildBtn(context, 'إدارة الأسعار', Icons.attach_money, AppTheme.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PricesScreen()))),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildBtn(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: SizedBox(
        height: 90,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLg),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 6),
              Text(title, style: AppTheme.heading4.copyWith(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------- DashboardScreen -------------------
class DashboardScreen extends StatefulWidget {
  final DateTime? initialDate;
  const DashboardScreen({super.key, this.initialDate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestore = FirestoreService();
  late DateTime _selectedDate;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _results = {'shhn': 'غير محدد', 'khsosy': 'غير محدد', 'bas': 'غير محدد', 'trktr': 'غير محدد'};
  final List<String> _resultOptions = ['غير محدد', 'ناجح', 'راسب'];
  Map<String, PriceSetting> _prices = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _initControllers();
    _firestore.getPrices().listen((prices) {
      setState(() {
        for (var p in prices) { _prices[p.name] = p; }
      });
      _loadData();
    });
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
    _controllers['expenses'] = TextEditingController(text: '0');
    _controllers['payment'] = TextEditingController(text: '0');
  }

  Future<void> _loadData() async {
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    var doc = await _firestore._dailyWorksRef.doc(dateStr).get();
    if (doc.exists) {
      DailyWork w = DailyWork.fromJson(doc.data() as Map<String, dynamic>);
      _controllers['shhn_dars']!.text = w.shhnDars.toString();
      _controllers['shhn_test']!.text = w.shhnTest.toString();
      _results['shhn'] = w.shhnResult;
      _controllers['khsosy_dars']!.text = w.khsosyDars.toString();
      _controllers['khsosy_test']!.text = w.khsosyTest.toString();
      _results['khsosy'] = w.khsosyResult;
      _controllers['bas_dars']!.text = w.basDars.toString();
      _controllers['bas_test']!.text = w.basTest.toString();
      _results['bas'] = w.basResult;
      _controllers['trktr_dars']!.text = w.trktrDars.toString();
      _controllers['trktr_test']!.text = w.trktrTest.toString();
      _results['trktr'] = w.trktrResult;
      _controllers['expenses']!.text = w.expenses.toString();
      _controllers['payment']!.text = w.paymentToday.toString();
      setState(() {});
    } else {
      _resetFields();
    }
  }

  void _resetFields() {
    _controllers.forEach((k, c) { c.text = '0'; });
    _results.updateAll((k, v) => 'غير محدد');
    setState(() {});
  }

  double _calculateAmount(int dars, int test, PriceSetting? p) {
    return (p != null) ? (dars * p.lessonPrice + test * p.testPrice) : 0.0;
  }

  void _save() async {
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    DailyWork work = DailyWork(date: dateStr);
    work.shhnDars = int.tryParse(_controllers['shhn_dars']!.text) ?? 0;
    work.shhnTest = int.tryParse(_controllers['shhn_test']!.text) ?? 0;
    work.shhnResult = _results['shhn']!;
    work.shhnAmount = _calculateAmount(work.shhnDars, work.shhnTest, _prices['شحن']);
    work.khsosyDars = int.tryParse(_controllers['khsosy_dars']!.text) ?? 0;
    work.khsosyTest = int.tryParse(_controllers['khsosy_test']!.text) ?? 0;
    work.khsosyResult = _results['khsosy']!;
    work.khsosyAmount = _calculateAmount(work.khsosyDars, work.khsosyTest, _prices['خصوصي']);
    work.basDars = int.tryParse(_controllers['bas_dars']!.text) ?? 0;
    work.basTest = int.tryParse(_controllers['bas_test']!.text) ?? 0;
    work.basResult = _results['bas']!;
    work.basAmount = _calculateAmount(work.basDars, work.basTest, _prices['باص']);
    work.trktrDars = int.tryParse(_controllers['trktr_dars']!.text) ?? 0;
    work.trktrTest = int.tryParse(_controllers['trktr_test']!.text) ?? 0;
    work.trktrResult = _results['trktr']!;
    work.trktrAmount = _calculateAmount(work.trktrDars, work.trktrTest, _prices['تركتر']);
    work.expenses = double.tryParse(_controllers['expenses']!.text) ?? 0;
    work.paymentToday = double.tryParse(_controllers['payment']!.text) ?? 0;
    await _firestore.saveDailyWork(work);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم الحفظ'), backgroundColor: AppTheme.success));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الادخال اليومي'), actions: [
        IconButton(icon: const Icon(Icons.save), onPressed: _save),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030), locale: const Locale('ar'));
                if (picked != null) setState(() { _selectedDate = picked; _loadData(); });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: AppTheme.radiusMd),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(DateFormat('d-M-yyyy').format(_selectedDate), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const Icon(Icons.calendar_today, color: AppTheme.primary, size: 18),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextFormField(controller: _controllers['payment'], decoration: const InputDecoration(labelText: 'دفعة اليوم', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), isDense: true), keyboardType: TextInputType.number)),
              const SizedBox(width: 6),
              Expanded(child: TextFormField(controller: _controllers['expenses'], decoration: const InputDecoration(labelText: 'مسحوب اليوم', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), isDense: true), keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 10),
            _vehicleCard('شحن', AppTheme.primary, 'shhn'),
            const SizedBox(height: 6),
            _vehicleCard('خصوصي', AppTheme.purple, 'khsosy'),
            const SizedBox(height: 6),
            _vehicleCard('باص', AppTheme.teal, 'bas'),
            const SizedBox(height: 6),
            _vehicleCard('تركتر', AppTheme.warning, 'trktr'),
          ],
        ),
      ),
    );
  }

  Widget _vehicleCard(String title, Color color, String prefix) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: AppTheme.radiusSm,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Row(children: [
              Icon(Icons.directions_car, color: color, size: 18),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(child: TextFormField(controller: _controllers['${prefix}_dars'], decoration: const InputDecoration(labelText: 'دروس', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6), isDense: true), keyboardType: TextInputType.number)),
              const SizedBox(width: 6),
              Expanded(child: TextFormField(controller: _controllers['${prefix}_test'], decoration: const InputDecoration(labelText: 'اختبارات', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6), isDense: true), keyboardType: TextInputType.number)),
              const SizedBox(width: 6),
              Expanded(child: DropdownButtonFormField<String>(
                value: _results[prefix],
                items: _resultOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                onChanged: (val) => setState(() => _results[prefix] = val!),
                decoration: const InputDecoration(labelText: 'النتيجة', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6), isDense: true),
              )),
            ]),
          ],
        ),
      ),
    );
  }
}

// ------------------- PricesScreen -------------------
class PricesScreen extends StatefulWidget {
  const PricesScreen({super.key});
  @override
  State<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen> {
  final FirestoreService _firestore = FirestoreService();
  final Map<String, TextEditingController> _lesson = {};
  final Map<String, TextEditingController> _test = {};

  @override
  void initState() {
    super.initState();
    for (var name in ['شحن', 'خصوصي', 'باص', 'تركتر']) {
      _lesson[name] = TextEditingController();
      _test[name] = TextEditingController();
    }
    _firestore.getPrices().listen((prices) {
      for (var p in prices) {
        if (_lesson.containsKey(p.name)) {
          _lesson[p.name]!.text = p.lessonPrice.toString();
          _test[p.name]!.text = p.testPrice.toString();
        }
      }
      setState(() {});
    });
  }

  void _save() async {
    List<PriceSetting> prices = [];
    for (var name in ['شحن', 'خصوصي', 'باص', 'تركتر']) {
      prices.add(PriceSetting(id: name, name: name, lessonPrice: double.parse(_lesson[name]!.text), testPrice: double.parse(_test[name]!.text)));
    }
    await _firestore.savePrices(prices);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم حفظ الأسعار'), backgroundColor: AppTheme.success));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الأسعار'), actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)]),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          _priceCard('شحن', Icons.local_shipping, AppTheme.primary, _lesson['شحن']!, _test['شحن']!),
          _priceCard('خصوصي', Icons.directions_car, AppTheme.purple, _lesson['خصوصي']!, _test['خصوصي']!),
          _priceCard('باص', Icons.directions_bus, AppTheme.teal, _lesson['باص']!, _test['باص']!),
          _priceCard('تركتر', Icons.agriculture, AppTheme.warning, _lesson['تركتر']!, _test['تركتر']!),
        ],
      ),
    );
  }

  Widget _priceCard(String title, IconData icon, Color color, TextEditingController lessonCtrl, TextEditingController testCtrl) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSm),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 6), Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color))]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextFormField(controller: lessonCtrl, decoration: const InputDecoration(labelText: 'سعر الدرس', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), isDense: true), keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: testCtrl, decoration: const InputDecoration(labelText: 'سعر الاختبار', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), isDense: true), keyboardType: TextInputType.number)),
            ]),
          ],
        ),
      ),
    );
  }
}

// ------------------- Reports (بدون طباعة) -------------------
class ReportsMenuScreen extends StatelessWidget {
  const ReportsMenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _reportBtn(context, 'كشف حساب مفصل (كل الأنواع)', AppTheme.primary, 'main'),
            const SizedBox(height: 8),
            _reportBtn(context, 'تقرير شحن فقط', AppTheme.success, 'shhn'),
            const SizedBox(height: 8),
            _reportBtn(context, 'تقرير خصوصي فقط', AppTheme.purple, 'khsosy'),
            const SizedBox(height: 8),
            _reportBtn(context, 'تقرير باص فقط', AppTheme.teal, 'bas'),
            const SizedBox(height: 8),
            _reportBtn(context, 'تقرير تركتر فقط', AppTheme.warning, 'trktr'),
            const SizedBox(height: 8),
            _reportBtn(context, 'تقرير شحن + خصوصي', AppTheme.primaryLight, 'shhn_khsosy'),
            const SizedBox(height: 8),
            _reportBtn(context, 'تقرير باص + تركتر', AppTheme.secondary, 'bas_trktr'),
          ],
        ),
      ),
    );
  }
  Widget _reportBtn(BuildContext context, String title, Color color, String type) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsScreen(reportType: type))),
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10)),
        child: Text(title, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

class ReportsScreen extends StatefulWidget {
  final String reportType;
  const ReportsScreen({super.key, required this.reportType});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final FirestoreService _firestore = FirestoreService();
  int? _selectedMonth, _selectedYear;
  final List<int> _months = List.generate(12, (i) => i + 1);
  final List<int> _years = List.generate(10, (i) => DateTime.now().year - i);

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now().month;
    _selectedYear = DateTime.now().year;
  }

  List<DailyWork> _filterData(List<DailyWork> all) {
    return all.where((work) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(work.date);
      return date.year == _selectedYear && date.month == _selectedMonth;
    }).toList();
  }

  String _getTitle() {
    switch (widget.reportType) {
      case 'main': return 'كشف حساب مفصل';
      case 'shhn': return 'تقرير شحن';
      case 'khsosy': return 'تقرير خصوصي';
      case 'bas': return 'تقرير باص';
      case 'trktr': return 'تقرير تركتر';
      case 'shhn_khsosy': return 'تقرير شحن + خصوصي';
      case 'bas_trktr': return 'تقرير باص + تركتر';
      default: return 'تقرير';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_getTitle())),  // تم إزالة زر الطباعة
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(6),
            child: Row(children: [
              Expanded(child: DropdownButtonFormField<int>(
                value: _selectedMonth,
                items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m.toString()))).toList(),
                onChanged: (v) => setState(() => _selectedMonth = v),
                decoration: const InputDecoration(labelText: 'الشهر', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), isDense: true), style: const TextStyle(fontSize: 13),
              )),
              const SizedBox(width: 6),
              Expanded(child: DropdownButtonFormField<int>(
                value: _selectedYear,
                items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                onChanged: (v) => setState(() => _selectedYear = v),
                decoration: const InputDecoration(labelText: 'السنة', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), isDense: true), style: const TextStyle(fontSize: 13),
              )),
            ]),
          ),
          Expanded(child: StreamBuilder<List<DailyWork>>(
            stream: _firestore.getDailyWorks(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              var allWorks = snapshot.data!;
              var filtered = _filterData(allWorks);
              if (filtered.isEmpty) return const Center(child: Text('لا توجد بيانات', style: TextStyle(fontSize: 14)));
              return _buildReport(allWorks, filtered);
            },
          )),
        ],
      ),
    );
  }

  Widget _buildReport(List<DailyWork> allWorks, List<DailyWork> monthData) {
    // --- التقارير الفردية (شحن، خصوصي، باص، تركتر) ---
    if (widget.reportType == 'shhn' || widget.reportType == 'khsosy' || widget.reportType == 'bas' || widget.reportType == 'trktr') {
      String type = widget.reportType;
      double totalAmount = 0;
      int totalDars = 0, totalTest = 0;
      for (var work in monthData) {
        if (type == 'shhn') {
          totalAmount += work.shhnAmount;
          totalDars += work.shhnDars;
          totalTest += work.shhnTest;
        } else if (type == 'khsosy') {
          totalAmount += work.khsosyAmount;
          totalDars += work.khsosyDars;
          totalTest += work.khsosyTest;
        } else if (type == 'bas') {
          totalAmount += work.basAmount;
          totalDars += work.basDars;
          totalTest += work.basTest;
        } else if (type == 'trktr') {
          totalAmount += work.trktrAmount;
          totalDars += work.trktrDars;
          totalTest += work.trktrTest;
        }
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    _getTitle(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '${_selectedMonth!}-${_selectedYear!}',
                    style: TextStyle(fontSize: 14, color: AppTheme.textMedium),
                  ),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(flex: 2, child: const Text('النوع', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: const Text('الدروس', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: const Text('الاختبارات', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: const Text('المبلغ', textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: AppTheme.radiusSm),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(_getTitleForType(widget.reportType), style: const TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('$totalDars', textAlign: TextAlign.center)),
                      Expanded(child: Text('$totalTest', textAlign: TextAlign.center)),
                      Expanded(child: Text('${totalAmount.toStringAsFixed(0)} ₪', textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // --- التقارير المدمجة (شحن + خصوصي) و (باص + تركتر) ---
    if (widget.reportType == 'shhn_khsosy' || widget.reportType == 'bas_trktr') {
      Map<String, double> incomeMap = {};
      Map<String, int> darsMap = {}, testMap = {};
      for (var work in monthData) {
        if (widget.reportType == 'shhn_khsosy') {
          incomeMap['شحن'] = (incomeMap['شحن'] ?? 0) + work.shhnAmount;
          darsMap['شحن'] = (darsMap['شحن'] ?? 0) + work.shhnDars;
          testMap['شحن'] = (testMap['شحن'] ?? 0) + work.shhnTest;
          incomeMap['خصوصي'] = (incomeMap['خصوصي'] ?? 0) + work.khsosyAmount;
          darsMap['خصوصي'] = (darsMap['خصوصي'] ?? 0) + work.khsosyDars;
          testMap['خصوصي'] = (testMap['خصوصي'] ?? 0) + work.khsosyTest;
        } else {
          incomeMap['باص'] = (incomeMap['باص'] ?? 0) + work.basAmount;
          darsMap['باص'] = (darsMap['باص'] ?? 0) + work.basDars;
          testMap['باص'] = (testMap['باص'] ?? 0) + work.basTest;
          incomeMap['تركتر'] = (incomeMap['تركتر'] ?? 0) + work.trktrAmount;
          darsMap['تركتر'] = (darsMap['تركتر'] ?? 0) + work.trktrDars;
          testMap['تركتر'] = (testMap['تركتر'] ?? 0) + work.trktrTest;
        }
      }
      List<String> types = (widget.reportType == 'shhn_khsosy') ? ['شحن', 'خصوصي'] : ['باص', 'تركتر'];
      double totalIncome = types.fold(0.0, (sum, t) => sum + (incomeMap[t] ?? 0));
      int totalDars = types.fold(0, (sum, t) => sum + (darsMap[t] ?? 0));
      int totalTest = types.fold(0, (sum, t) => sum + (testMap[t] ?? 0));

      return SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    _getTitle(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '${_selectedMonth!}-${_selectedYear!}',
                    style: TextStyle(fontSize: 14, color: AppTheme.textMedium),
                  ),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(flex: 2, child: const Text('النوع', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: const Text('الدروس', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: const Text('الاختبارات', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: const Text('المبلغ', textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 8),
                ...types.map((t) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: AppTheme.radiusSm),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('${darsMap[t] ?? 0}', textAlign: TextAlign.center)),
                      Expanded(child: Text('${testMap[t] ?? 0}', textAlign: TextAlign.center)),
                      Expanded(child: Text('${(incomeMap[t] ?? 0).toStringAsFixed(0)} ₪', textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                )),
                const Divider(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: AppTheme.radiusSm),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: const Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('$totalDars', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('$totalTest', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('${totalIncome.toStringAsFixed(0)} ₪', textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // --- التقرير الرئيسي (كشف حساب مفصل) ---
    double totalIncome = 0, totalExpenses = 0, totalPayments = 0;
    int totalDars = 0, totalTest = 0;
    Map<String, double> incomeMap = {};
    Map<String, int> darsMap = {}, testMap = {};

    for (var work in monthData) {
      totalExpenses += work.expenses;
      totalPayments += work.paymentToday;
      for (var name in ['شحن', 'خصوصي', 'باص', 'تركتر']) {
        double amt = 0; int dars = 0, test = 0;
        if (name == 'شحن') { amt = work.shhnAmount; dars = work.shhnDars; test = work.shhnTest; }
        if (name == 'خصوصي') { amt = work.khsosyAmount; dars = work.khsosyDars; test = work.khsosyTest; }
        if (name == 'باص') { amt = work.basAmount; dars = work.basDars; test = work.basTest; }
        if (name == 'تركتر') { amt = work.trktrAmount; dars = work.trktrDars; test = work.trktrTest; }
        incomeMap[name] = (incomeMap[name] ?? 0) + amt;
        darsMap[name] = (darsMap[name] ?? 0) + dars;
        testMap[name] = (testMap[name] ?? 0) + test;
        totalIncome += amt;
        totalDars += dars;
        totalTest += test;
      }
    }

    DateTime startDate = DateTime(_selectedYear!, _selectedMonth!, 1);
    double previousBalance = 0.0;
    for (var work in allWorks) {
      DateTime wDate = DateFormat('yyyy-MM-dd').parse(work.date);
      if (wDate.isBefore(startDate)) {
        previousBalance += work.totalIncome - (work.expenses + work.paymentToday);
      }
    }
    double monthNet = totalIncome - (totalExpenses + totalPayments);
    double finalBalance = previousBalance + monthNet;
    String period = '${_selectedMonth!}-${_selectedYear!}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'برنامج سمير المحاسبي',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  period,
                  style: TextStyle(fontSize: 14, color: AppTheme.textMedium),
                ),
              ),
              const Divider(thickness: 1, height: 20),
              _buildRow('شحن', incomeMap['شحن']!, darsMap['شحن']!, testMap['شحن']!, Colors.blue.shade50),
              _buildRow('خصوصي', incomeMap['خصوصي']!, darsMap['خصوصي']!, testMap['خصوصي']!, Colors.purple.shade50),
              _buildRow('باص', incomeMap['باص']!, darsMap['باص']!, testMap['باص']!, Colors.teal.shade50),
              _buildRow('تركتر', incomeMap['تركتر']!, darsMap['تركتر']!, testMap['تركتر']!, Colors.orange.shade50),
              const Divider(height: 12),
              _buildSummaryLine('إجمالي الإيرادات:', totalIncome, Colors.blue.shade50),
              _buildSummaryLine('إجمالي المسحوبات (المصروفات):', totalExpenses, Colors.red.shade50),
              _buildSummaryLine('إجمالي الدفعات (القبض):', totalPayments, Colors.green.shade50),
              _buildSummaryLine('صافي الشهر (الإيرادات - المسحوبات - الدفعات):', monthNet, Colors.yellow.shade100, isBold: true),
              const Divider(height: 12),
              _buildSummaryLine('الرصيد السابق (الدين القديم):', previousBalance, Colors.orange.shade50, isBold: true),
              const Divider(height: 12),
              _buildSummaryLine('الرصيد النهائي:', finalBalance, Colors.teal.shade50, isBold: true, fontSize: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, double amount, int dars, int test, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(color: bgColor, borderRadius: AppTheme.radiusSm),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(child: Text('$dars درس', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
          Expanded(child: Text('$test اختبار', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
          Expanded(child: Text('${amount.toStringAsFixed(0)} ₪', textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String label, double value, Color bgColor, {bool isBold = false, double fontSize = 14}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(color: bgColor, borderRadius: AppTheme.radiusSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text('${value.toStringAsFixed(0)} ₪', style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        ],
      ),
    );
  }

  String _getTitleForType(String type) {
    switch (type) {
      case 'shhn': return 'شحن';
      case 'khsosy': return 'خصوصي';
      case 'bas': return 'باص';
      case 'trktr': return 'تركتر';
      default: return '';
    }
  }
}