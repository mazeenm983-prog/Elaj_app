import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة قاعدة البيانات مع معالجة الاستثناءات لضمان عمل التطبيق محلياً في حال عدم وجود اتصال
  await DatabaseService.init();

  runApp(const ElajApp());
}

// ==========================================
// 1. نظام إدارة البيانات وقاعدة بيانات Supabase
// ==========================================
class DatabaseService {
  static bool useSupabaseFallback = false;

  // قيم افتراضية ومحاكاة البيانات المحلية لضمان تجربة تطبيق سلسة فور التشغيل
  static final List<Map<String, dynamic>> _mockOrders = [
    {
      'id': '1',
      'med_name': 'بنادول ساينس (البديل المتاح)',
      'quantity': 2,
      'is_fatish_li': false,
      'distance': 5.0,
      'fare': 2500.0,
      'has_prescription': true,
      'status': 'pending',
    },
    {
      'id': '2',
      'med_name': 'حقنة أنسولين لانتوس (نادر)',
      'quantity': 1,
      'is_fatish_li': true,
      'distance': 14.0,
      'fare': 7000.0,
      'has_prescription': true,
      'status': 'pending',
    }
  ];

  static final List<Map<String, dynamic>> _mockCaptains = [
    {'id': 'c1', 'name': 'أحمد ياسر', 'phone': '0912345678', 'is_approved': false},
    {'id': 'c2', 'name': 'محمد الفاتح', 'phone': '0922446688', 'is_approved': false},
  ];

  static Future<void> init() async {
    try {
      // يمكنك استبدال الرابط و المفتاح لاحقاً عند ربط مشروع Supabase الحقيقي
      await Supabase.initialize(
        url: 'https://xyzcompany.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRlc3QiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTY3MjgxNDQwMCwiZXhwIjoyMDE4MzkwNDAwfQ.test',
      );
      useSupabaseFallback = true;
    } catch (e) {
      debugPrint("تنبيه: تم الانتقال التلقائي للوضع المحلي الافتراضي لعدم توفر معطيات Supabase.");
      useSupabaseFallback = false;
    }
  }

  // جلب الطلبات
  static Future<List<Map<String, dynamic>>> getOrders() async {
    if (useSupabaseFallback) {
      try {
        final response = await Supabase.instance.client
            .from('orders')
            .select()
            .order('created_at', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      } catch (e) {
        debugPrint("خطأ في جلب بيانات Supabase: $e");
      }
    }
    return Future.value(List<Map<String, dynamic>>.from(_mockOrders));
  }

  // إضافة طلب جديد
  static Future<void> createOrder(Map<String, dynamic> order) async {
    if (useSupabaseFallback) {
      try {
        await Supabase.instance.client.from('orders').insert(order);
        return;
      } catch (e) {
        debugPrint("خطأ في إضافة الطلب لـ Supabase: $e");
      }
    }
    _mockOrders.add(order);
  }

  // قبول الكابتن للطلب
  static Future<void> acceptOrder(String orderId) async {
    if (useSupabaseFallback) {
      try {
        await Supabase.instance.client
            .from('orders')
            .update({'status': 'accepted'})
            .eq('id', orderId);
        return;
      } catch (e) {
        debugPrint("خطأ في تحديث حالة الطلب على Supabase: $e");
      }
    }
    final index = _mockOrders.indexWhere((o) => o['id'] == orderId);
    if (index != -1) {
      _mockOrders[index]['status'] = 'accepted';
    }
  }

  // جلب الكباتن قيد المراجعة للمدير
  static Future<List<Map<String, dynamic>>> getPendingCaptains() async {
    if (useSupabaseFallback) {
      try {
        final response = await Supabase.instance.client
            .from('captains')
            .select()
            .eq('is_approved', false);
        return List<Map<String, dynamic>>.from(response);
      } catch (e) {
        debugPrint("خطأ في جلب الكباتن: $e");
      }
    }
    return Future.value(_mockCaptains.where((c) => c['is_approved'] == false).toList());
  }

  // اعتماد وقبول الكابتن من المدير
  static Future<void> approveCaptain(String captainId) async {
    if (useSupabaseFallback) {
      try {
        await Supabase.instance.client
            .from('captains')
            .update({'is_approved': true})
            .eq('id', captainId);
        return;
      } catch (e) {
        debugPrint("خطأ في اعتماد الكابتن: $e");
      }
    }
    final index = _mockCaptains.indexWhere((c) => c['id'] == captainId);
    if (index != -1) {
      _mockCaptains[index]['is_approved'] = true;
    }
  }
}

// ==========================================
// 2. إعدادات التصميم والواجهة الرئيسية
// ==========================================
class ElajApp extends StatelessWidget {
  const ElajApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق علاج الدوائي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Cairo',
        primaryColor: const Color(0xFF00A86B),
        scaffoldBackgroundColor: const Color(0xFFF4F9F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A86B),
          primary: const Color(0xFF00A86B),
          secondary: const Color(0xFF00C885),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: LoginScreen(),
      ),
    );
  }
}

// ==========================================
// 3. شاشة تسجيل الدخول والتوجيه الذكي
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'customer';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال البريد الإلكتروني وكلمة المرور')),
      );
      return;
    }

    if (email.toLowerCase() == 'admin@elaj.com') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Directionality(
          textDirection: TextDirection.rtl,
          child: AdminDashboardScreen(),
        )),
      );
      return;
    }

    if (_selectedRole == 'customer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Directionality(
          textDirection: TextDirection.rtl,
          child: CustomerHomeScreen(),
        )),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Directionality(
          textDirection: TextDirection.rtl,
          child: CaptainOrdersScreen(),
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.health_and_safety, size: 80, color: Color(0xFF00A86B)),
                  const SizedBox(height: 12),
                  const Text(
                    'عِــلاج للخدمات الدوائية',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00A86B)),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text('الدخول كـ:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('عميل'),
                          value: 'customer',
                          groupValue: _selectedRole,
                          onChanged: (val) => setState(() => _selectedRole = val!),
                          activeColor: const Color(0xFF00A86B),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('كابتن'),
                          value: 'captain',
                          groupValue: _selectedRole,
                          onChanged: (val) => setState(() => _selectedRole = val!),
                          activeColor: const Color(0xFF00A86B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A86B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _handleLogin,
                      child: const Text('دخول', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      _emailController.text = 'admin@elaj.com';
                      _passwordController.text = '123456';
                    },
                    child: const Text('استخدم بيانات المسؤول التجريبية (Admin)', style: TextStyle(color: Colors.grey)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. شاشة العميل (طلب دواء + فتش لي وحساب الأجرة)
// ==========================================
class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  bool _isFatishLi = false;
  final _medNameController = TextEditingController();
  int _quantity = 1;
  double _distance = 1.0;
  bool _hasPrescription = false;
  final double _pricePerKm = 500.0;

  @override
  void dispose() {
    _medNameController.dispose();
    super.dispose();
  }

  double get _calculatedFare => _distance * _pricePerKm;

  void _submitOrder() async {
    final medName = _medNameController.text.trim();
    if (medName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء كتابة اسم الدواء المطلوبة')),
      );
      return;
    }

    final newOrder = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'med_name': medName,
      'quantity': _isFatishLi ? 1 : _quantity,
      'is_fatish_li': _isFatishLi,
      'distance': _distance,
      'fare': _calculatedFare,
      'has_prescription': _hasPrescription,
      'status': 'pending',
    };

    await DatabaseService.createOrder(newOrder);

    _medNameController.clear();
    setState(() {
      _quantity = 1;
      _distance = 1.0;
      _hasPrescription = false;
    });

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تم إرسال طلبك بنجاح ✅'),
        content: Text('لقد تم نشر طلبك للكباتن المتاحين في محيطك.\nالأجرة المحسوبة: $_calculatedFare جنيه سوداني.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة العميل - عِـلاج'),
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Directionality(textDirection: TextDirection.rtl, child: LoginScreen())),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isFatishLi ? const Color(0xFF00A86B) : Colors.grey[300],
                      foregroundColor: !_isFatishLi ? Colors.white : Colors.black,
                    ),
                    onPressed: () => setState(() => _isFatishLi = false),
                    icon: const Icon(Icons.medication),
                    label: const Text('طلب دواء عادي'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFatishLi ? const Color(0xFF00A86B) : Colors.grey[300],
                      foregroundColor: _isFatishLi ? Colors.white : Colors.black,
                    ),
                    onPressed: () => setState(() => _isFatishLi = true),
                    icon: const Icon(Icons.search),
                    label: const Text('خدمة فتش لي'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isFatishLi ? 'اسم الدواء النادر للبحث عنه:' : 'اسم الدواء المطلوب:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _medNameController,
                      decoration: const InputDecoration(
                        hintText: 'مثال: أسبرين، أنسولين...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (!_isFatishLi) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الكمية المطلوبة:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                                onPressed: () {
                                  if (_quantity > 1) setState(() => _quantity--);
                                },
                              ),
                              Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Color(0xFF00A86B)),
                                onPressed: () => setState(() => _quantity++),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('المسافة التقديرية للصيدلية (كم):', style: TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: _distance,
                      min: 1,
                      max: 30,
                      divisions: 29,
                      label: '${_distance.round()} كم',
                      activeColor: const Color(0xFF00A86B),
                      onChanged: (val) => setState(() => _distance = val),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('المسافة المحددة: ${_distance.toStringAsFixed(1)} كم', style: const TextStyle(color: Colors.grey)),
                        Text(
                          'التكلفة: ${(_distance * 500).toStringAsFixed(0)} جنيه',
                          style: const TextStyle(color: Color(0xFF00A86B), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('تحميل صورة الروشتة:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _hasPrescription = !_hasPrescription);
                          },
                          icon: Icon(_hasPrescription ? Icons.check : Icons.cloud_upload),
                          label: Text(_hasPrescription ? 'تم الإرفاق' : 'إرفاق الصورة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hasPrescription ? Colors.green : Colors.grey[700],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A86B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _submitOrder,
                child: const Text('إرسال الطلب الآن 🚀', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. شاشة الكابتن (عرض وقبول الطلبات)
// ==========================================
class CaptainOrdersScreen extends StatefulWidget {
  const CaptainOrdersScreen({super.key});

  @override
  State<CaptainOrdersScreen> createState() => _CaptainOrdersScreenState();
}

class _CaptainOrdersScreenState extends State<CaptainOrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    final data = await DatabaseService.getOrders();
    if (!mounted) return;
    setState(() {
      _orders = data;
      _isLoading = false;
    });
  }

  void _accept(String id) async {
    await DatabaseService.acceptOrder(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم قبول الطلب وبدء تتبع التوصيل 🛵')),
    );
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final pendingOrders = _orders.where((o) => o['status'] == 'pending').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الكابتن - طلبات التوصيل'),
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchOrders),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Directionality(textDirection: TextDirection.rtl, child: LoginScreen())),
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A86B)))
          : pendingOrders.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'لا توجد طلبات توصيل متاحة حالياً.\nيرجى التحديث أو الانتظار.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pendingOrders.length,
                  itemBuilder: (context, index) {
                    final order = pendingOrders[index];
                    final isFatish = order['is_fatish_li'] ?? false;
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(isFatish ? 'خدمة فتش لي 🔍' : 'طلب دواء 💊'),
                                  backgroundColor: isFatish ? Colors.amber[100] : Colors.green[100],
                                ),
                                Text(
                                  'أجرة: ${order['fare']} جنيه',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00A86B), fontSize: 16),
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'الدواء: ${order['med_name']}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text('الكمية: ${order['quantity']}'),
                            Text('المسافة التقديرية: ${order['distance']} كم'),
                            if (order['has_prescription'] == true)
                              const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green, size: 18),
                                  SizedBox(width: 4),
                                  Text('الروشتة الطبية مرفقة', style: TextStyle(color: Colors.green, fontSize: 13)),
                                ],
                              ),
                            const Divider(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00A86B),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => _accept(order['id'].toString()),
                                icon: const Icon(Icons.motorcycle),
                                label: const Text('قبول هذا الطلب وتأكيده'),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ==========================================
// 6. شاشة المسؤول والمدير (Admin Dashboard)
// ==========================================
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _pendingCaptains = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    setState(() => _isLoading = true);
    final orders = await DatabaseService.getOrders();
    final captains = await DatabaseService.getPendingCaptains();
    if (!mounted) return;
    setState(() {
      _orders = orders;
      _pendingCaptains = captains;
      _isLoading = false;
    });
  }

  void _approve(String id) async {
    await DatabaseService.approveCaptain(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم اعتماد الكابتن بنظام علاج بنجاح 👥')),
    );
    _fetchAdminData();
  }

  @override
  Widget build(BuildContext context) {
    final int totalCount = _orders.length;
    final int pendingCount = _orders.where((o) => o['status'] == 'pending').length;
    final int acceptedCount = _orders.where((o) => o['status'] == 'accepted').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإدارة الشاملة (Admin)'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchAdminData),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Directionality(textDirection: TextDirection.rtl, child: LoginScreen())),
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A86B)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('إحصائيات النظام اليومية:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard('إجمالي الطلبات', '$totalCount', Colors.blueGrey, Icons.assessment),
                      _buildStatCard('طلبات معلقة', '$pendingCount', Colors.orange, Icons.hourglass_empty),
                      _buildStatCard('طلبات قيد التوصيل', '$acceptedCount', Colors.green, Icons.delivery_dining),
                      _buildStatCard('كباتن قيد التدقيق', '${_pendingCaptains.length}', Colors.red, Icons.admin_panel_settings),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  const Text('الكباتن بانتظار المراجعة والاعتماد:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  _pendingCaptains.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Text('لا يوجد كباتن جدد قيد المراجعة حالياً.', style: TextStyle(color: Colors.grey)),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _pendingCaptains.length,
                          itemBuilder: (context, index) {
                            final cap = _pendingCaptains[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFF00A86B),
                                  child: Icon(Icons.person, color: Colors.white),
                                ),
                                title: Text(cap['name'] ?? ''),
                                subtitle: Text('الهاتف: ${cap['phone']}'),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A86B)),
                                  onPressed: () => _approve(cap['id'].toString()),
                                  child: const Text('اعتماد الكابتن', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String val, Color col, IconData icon) {
    return Card(
      color: col.withAlpha(25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: col.withAlpha(75)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: col),
                Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: col)),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
