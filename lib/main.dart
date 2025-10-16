import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
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
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
      ),
      home: const LoginPage(),
    );
  }
}

// صفحة تسجيل الدخول
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  void _login() {
    if (_userController.text.isNotEmpty && _passController.text.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SalaryHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: 'اسم المستخدم'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: 'كلمة المرور'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('تسجيل الدخول'),
            ),
          ],
        ),
      ),
    );
  }
}

// الصفحة الرئيسية
class SalaryHomePage extends StatefulWidget {
  const SalaryHomePage({super.key});

  @override
  State<SalaryHomePage> createState() => _SalaryHomePageState();
}

class _SalaryHomePageState extends State<SalaryHomePage> {
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _expensesController = TextEditingController();
  List<Map<String, dynamic>> salaryRecords = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('salary_records', jsonEncode(salaryRecords));
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('salary_records');
    if (data != null) {
      setState(() {
        salaryRecords = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  void _addRecord() {
    if (_salaryController.text.isEmpty ||
        _taxController.text.isEmpty ||
        _expensesController.text.isEmpty) return;

    final double salary = double.tryParse(_salaryController.text) ?? 0;
    final double tax = double.tryParse(_taxController.text) ?? 0;
    final double expenses = double.tryParse(_expensesController.text) ?? 0;
    final double remaining = salary - tax - expenses;

    setState(() {
      salaryRecords.add({
        "salary": salary,
        "tax": tax,
        "expenses": expenses,
        "remaining": remaining,
        "date": DateTime.now().toString(),
      });
    });

    _saveRecords();
    _salaryController.clear();
    _taxController.clear();
    _expensesController.clear();
  }

  void _editRecord(int index) {
    final record = salaryRecords[index];
    _salaryController.text = record["salary"].toString();
    _taxController.text = record["tax"].toString();
    _expensesController.text = record["expenses"].toString();

    setState(() {
      salaryRecords.removeAt(index);
    });
  }

  void _deleteRecord(int index) {
    setState(() {
      salaryRecords.removeAt(index);
    });
    _saveRecords();
  }

  double get totalRemaining =>
      salaryRecords.fold(0, (sum, item) => sum + item['remaining']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 تطبيق الرواتب'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Center(
                child: Text(
                  'إعدادات التطبيق',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('الضرائب والمصروفات'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.savings),
              title: const Text('الادخار اليومي'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('مشاركة رابط التحميل'),
              onTap: () {
                Share.share(
                  '📱 يمكنك تحميل تطبيق الرواتب من هنا:\nhttps://github.com/Amgdgody/salaries_appa/releases/latest/download/salaries_app.apk',
                  subject: 'تطبيق الرواتب - Amjad Issa',
                );
              },
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.person),
              title: Text('المطور: Amjad Issa'),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('تسجيل الخروج'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _salaryController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'الراتب', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _taxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'الضرائب', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _expensesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'المصروفات', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addRecord,
                  child: const Text('إضافة'),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: salaryRecords.isEmpty
                  ? const Center(child: Text("لا توجد سجلات بعد"))
                  : ListView.builder(
                      itemCount: salaryRecords.length,
                      itemBuilder: (context, index) {
                        final record = salaryRecords[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                                "الراتب: ${record['salary']} | الباقي: ${record['remaining']}"),
                            subtitle: Text(
                                "الضرائب: ${record['tax']} | المصروفات: ${record['expenses']}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editRecord(index),
                                ),
                                IconButton(
                                  icon:
                                      const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteRecord(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('إجمالي الباقي:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${totalRemaining.toStringAsFixed(2)} د.ل',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
