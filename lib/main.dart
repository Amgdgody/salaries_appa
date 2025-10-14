import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const SalariesApp());
}

class SalariesApp extends StatelessWidget {
  const SalariesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق الرواتب',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Roboto',
      ),
      home: const AuthPage(),
    );
  }
}

// صفحة الدخول
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoginMode = true;
  String? savedUser;
  String? savedPass;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedUser = prefs.getString('username');
      savedPass = prefs.getString('password');
    });
  }

  Future<void> _register() async {
    if (_username.text.isEmpty || _password.text.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _username.text);
    await prefs.setString('password', _password.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم إنشاء الحساب بنجاح ✅")),
    );
    setState(() {
      isLoginMode = true;
    });
  }

  Future<void> _login() async {
    if (_username.text == savedUser && _password.text == savedPass) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SalaryHomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ اسم المستخدم أو كلمة المرور غير صحيحة")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLoginMode ? "تسجيل الدخول" : "مستخدم جديد"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _username,
              decoration: const InputDecoration(
                labelText: 'اسم المستخدم',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoginMode ? _login : _register,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: Text(isLoginMode ? "تسجيل الدخول" : "إنشاء حساب"),
            ),
            TextButton(
              onPressed: () {
                setState(() => isLoginMode = !isLoginMode);
              },
              child: Text(isLoginMode
                  ? "إنشاء حساب جديد"
                  : "العودة إلى تسجيل الدخول"),
            ),
          ],
        ),
      ),
    );
  }
}

// الصفحة الرئيسية (مع القائمة الجانبية)
class SalaryHomePage extends StatefulWidget {
  const SalaryHomePage({super.key});

  @override
  State<SalaryHomePage> createState() => _SalaryHomePageState();
}

class _SalaryHomePageState extends State<SalaryHomePage> {
  int selectedPage = 0; // 0=رواتب 1=ضرائب 2=مصروفات 3=ادخار
  List<Map<String, dynamic>> salaryRecords = [];
  List<Map<String, dynamic>> taxRecords = [];
  List<Map<String, dynamic>> expenseRecords = [];
  List<Map<String, dynamic>> savingRecords = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      salaryRecords = _decode(prefs.getString('salary_records'));
      taxRecords = _decode(prefs.getString('tax_records'));
      expenseRecords = _decode(prefs.getString('expense_records'));
      savingRecords = _decode(prefs.getString('saving_records'));
    });
  }

  List<Map<String, dynamic>> _decode(String? data) {
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  Future<void> _saveData(String key, List<Map<String, dynamic>> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(records));
  }

  void _logout() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (selectedPage) {
      case 1:
        content = RecordsPage(
          title: "الضرائب",
          keyName: 'tax_records',
          records: taxRecords,
          onChanged: (r) => setState(() => taxRecords = r),
          onSave: _saveData,
        );
        break;
      case 2:
        content = RecordsPage(
          title: "المصروفات",
          keyName: 'expense_records',
          records: expenseRecords,
          onChanged: (r) => setState(() => expenseRecords = r),
          onSave: _saveData,
        );
        break;
      case 3:
        content = RecordsPage(
          title: "الادخار",
          keyName: 'saving_records',
          records: savingRecords,
          onChanged: (r) => setState(() => savingRecords = r),
          onSave: _saveData,
        );
        break;
      default:
        content = RecordsPage(
          title: "الرواتب",
          keyName: 'salary_records',
          records: salaryRecords,
          onChanged: (r) => setState(() => salaryRecords = r),
          onSave: _saveData,
        );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 تطبيق الرواتب'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Center(
                child: Text(
                  'القائمة الرئيسية',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('الرواتب'),
              onTap: () => setState(() => selectedPage = 0),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('الضرائب'),
              onTap: () => setState(() => selectedPage = 1),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('المصروفات'),
              onTap: () => setState(() => selectedPage = 2),
            ),
            ListTile(
              leading: const Icon(Icons.savings),
              title: const Text('الادخار'),
              onTap: () => setState(() => selectedPage = 3),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('تسجيل الخروج'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: content,
    );
  }
}

// صفحة الجداول العامة
class RecordsPage extends StatefulWidget {
  final String title;
  final String keyName;
  final List<Map<String, dynamic>> records;
  final Function(List<Map<String, dynamic>>) onChanged;
  final Function(String, List<Map<String, dynamic>>) onSave;

  const RecordsPage({
    super.key,
    required this.title,
    required this.keyName,
    required this.records,
    required this.onChanged,
    required this.onSave,
  });

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _note = TextEditingController();

  void _add() {
    if (_amount.text.isEmpty) return;
    final double value = double.tryParse(_amount.text) ?? 0;
    setState(() {
      widget.records.add({
        "amount": value,
        "note": _note.text,
        "date": DateTime.now().toString(),
      });
    });
    widget.onChanged(widget.records);
    widget.onSave(widget.keyName, widget.records);
    _amount.clear();
    _note.clear();
  }

  double get total => widget.records.fold(0, (sum, item) => sum + item['amount']);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(widget.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'القيمة',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _note,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظة (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _add, child: const Text("إضافة")),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: widget.records.isEmpty
                ? const Center(child: Text("لا توجد بيانات بعد"))
                : ListView.builder(
                    itemCount: widget.records.length,
                    itemBuilder: (context, index) {
                      final r = widget.records[index];
                      return Card(
                        child: ListTile(
                          title: Text("${r['amount']} د.ل"),
                          subtitle: Text(r['note']),
                          trailing: Text(r['date'].substring(0, 10)),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإجمالي:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${total.toStringAsFixed(2)} د.ل',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
