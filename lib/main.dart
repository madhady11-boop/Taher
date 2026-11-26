import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// ==========================================
// إعدادات مشروع Supabase
// ==========================================
class SouqConfig {
  static const String supabaseUrl = 'https://uaaxwivqzafevvqowdrx.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_PJ9gxCPkXIfbpkYphPh-Wg_MYGyL59Z';
}

void main() {
  runApp(const SouqAlJumlaOnlineApp());
}

class SouqAlJumlaOnlineApp extends StatelessWidget {
  const SouqAlJumlaOnlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سوق الجملة - الناصرية',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF15803D),
        scaffoldBackgroundColor: const Color(0xFFF5F8F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF15803D),
          primary: const Color(0xFF15803D),
          secondary: const Color(0xFF0F2C59),
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const LuxuryLoginScreen(),
    );
  }
}

// ==========================================
// خدمة الاتصال مع Supabase
// ==========================================
class SupabaseService {
  static Map<String, String> _headers({String? accessToken}) {
    return {
      'apikey': SouqConfig.supabaseAnonKey,
      'Authorization': 'Bearer ${accessToken ?? SouqConfig.supabaseAnonKey}',
      'Content-Type': 'application/json',
      'Prefer': 'return=representation',
    };
  }

  static String _phoneToInternalEmail(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return 'iq_$digits@souqaljumla.iq';
  }

  static Future> signUp({
    required String fullName,
    required String businessName,
    required String accountType,
    required String phone,
    required String password,
  }) async {
    final email = _phoneToInternalEmail(phone);
    final url = Uri.parse('${SouqConfig.supabaseUrl}/auth/v1/signup');

    final res = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
        'data': {
          'full_name': fullName,
          'business_name': businessName,
          'account_type': accountType,
          'phone': phone,
          'city': 'الناصرية',
        },
      }),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      throw Exception(
          data['msg'] ?? data['error_description'] ?? 'فشل إنشاء الحساب');
    }

    final token = data['access_token'] as String?;
    final userId = data['user']?['id'] as String?;

    if (userId != null) {
      try {
        await http.post(
          Uri.parse('${SouqConfig.supabaseUrl}/rest/v1/profiles'),
          headers: _headers(accessToken: token),
          body: jsonEncode({
            'id': userId,
            'full_name': fullName,
            'business_name': businessName,
            'account_type': accountType,
            'phone': phone,
            'city': 'الناصرية',
            'address': 'الناصرية - المنصورية',
          }),
        );
      } catch (_) {}
    }

    return {
      'token': token ?? SouqConfig.supabaseAnonKey,
      'userId': userId ?? '',
      'fullName': fullName,
      'businessName': businessName,
      'accountType': accountType,
      'phone': phone,
    };
  }

  static Future> signIn({
    required String phone,
    required String password,
  }) async {
    final email = _phoneToInternalEmail(phone);
    final url = Uri.parse(
        '${SouqConfig.supabaseUrl}/auth/v1/token?grant_type=password');

    final res = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      throw Exception(data['error_description'] ??
          data['msg'] ??
          'بيانات الدخول غير صحيحة');
    }

    final token = data['access_token'] as String;
    final meta =
        (data['user']?['user_metadata'] as Map<String, dynamic>?) ?? {};

    return {
      'token': token,
      'userId': data['user']?['id'] ?? '',
      'fullName': meta['full_name'] ?? 'مستخدم سوق الجملة',
      'businessName': meta['business_name'] ?? 'سوق الناصرية',
      'accountType': meta['account_type'] ?? 'صاحب سوق',
      'phone': meta['phone'] ?? phone,
    };
  }

  static Future<List<WholesaleProduct>> fetchProducts(String token) async {
    final url = Uri.parse('${SouqConfig.supabaseUrl}/rest/v1/products?select=*');
    final res = await http.get(url, headers: _headers(accessToken: token));
    if (res.statusCode != 200) return [];

    final List<dynamic> list = jsonDecode(res.body);
    return list.map((row) {
      return WholesaleProduct(
        id: row['id'].toString(),
        name: (row['name'] ?? 'منتج جملة').toString(),
        category: (row['category'] ?? 'مواد غذائية').toString(),
        badge: (row['badge'] ?? 'عرض الجملة').toString(),
        itemsPerCarton: int.tryParse(row['items_per_carton'].toString()) ?? 12,
        wholesalePrice: double.tryParse(row['wholesale_price'].toString()) ?? 0,
        suggestedRetailPrice:
            double.tryParse(row['suggested_retail_price'].toString()) ?? 0,
        stock: int.tryParse(row['stock'].toString()) ?? 20,
        merchantName: (row['merchant_name'] ?? 'تاجر جملة - الناصرية').toString(),
        imageBase64: row['image_base64']?.toString(),
        icon: Icons.inventory_2_rounded,
      );
    }).toList();
  }

  static Future<void> addProduct({
    required String token,
    required WholesaleProduct product,
  }) async {
    final url = Uri.parse('${SouqConfig.supabaseUrl}/rest/v1/products');
    await http.post(
      url,
      headers: _headers(accessToken: token),
      body: jsonEncode({
        'name': product.name,
        'category': product.category,
        'badge': product.badge,
        'items_per_carton': product.itemsPerCarton,
        'wholesale_price': product.wholesalePrice,
        'suggested_retail_price': product.suggestedRetailPrice,
        'stock': product.stock,
        'merchant_name': product.merchantName,
        if (product.imageBase64 != null) 'image_base64': product.imageBase64,
      }),
    );
  }

  static Future<void> createOrder({
    required String token,
    required String userId,
    required String shopName,
    required String address,
    required double lat,
    required double lng,
    required double totalAmount,
  }) async {
    final url = Uri.parse('${SouqConfig.supabaseUrl}/rest/v1/orders');
    await http.post(
      url,
      headers: _headers(accessToken: token),
      body: jsonEncode({
        if (userId.isNotEmpty) 'user_id': userId,
        'shop_name': shopName,
        'delivery_address': address,
        'latitude': lat,
        'longitude': lng,
        'total_amount': totalAmount,
        'status': 'قيد التجهيز',
      }),
    );
  }
}

// ==========================================
// 1. نماذج البيانات (Models)
// ==========================================
class WholesaleProduct {
  final String id;
  String name;
  String category;
  String badge;
  int itemsPerCarton;
  double wholesalePrice;
  double suggestedRetailPrice;
  int stock;
  String merchantName;
  String? localImagePath;
  String? imageBase64;
  IconData icon;

  WholesaleProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.badge,
    required this.itemsPerCarton,
    required this.wholesalePrice,
    required this.suggestedRetailPrice,
    required this.stock,
    required this.merchantName,
    this.localImagePath,
    this.imageBase64,
    required this.icon,
  });

  double get unitPrice =>
      itemsPerCarton > 0 ? wholesalePrice / itemsPerCarton : wholesalePrice;
  double get expectedCartonProfit =>
      (suggestedRetailPrice * itemsPerCarton) - wholesalePrice;
}

class MarketOrder {
  final String id;
  final String shopName;
  final String confirmedAddress;
  final double totalAmount;
  final double deliveryFee;
  String status;

  MarketOrder({
    required this.id,
    required this.shopName,
    required this.confirmedAddress,
    required this.totalAmount,
    required this.deliveryFee,
    this.status = 'قيد التجهيز',
  });
}

// ==========================================
// 2. تسجيل الدخول
// ==========================================
class LuxuryLoginScreen extends StatefulWidget {
  const LuxuryLoginScreen({super.key});

  @override
  State<LuxuryLoginScreen> createState() => _LuxuryLoginScreenState();
}

class _LuxuryLoginScreenState extends State<LuxuryLoginScreen> {
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _hidePass = true;
  bool _isLoading = false;

  Future<void> _signIn() async {
    final phone = _phoneCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (phone.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رقم الهاتف وكلمة المرور')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final session =
          await SupabaseService.signIn(phone: phone, password: pass);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LuxuryMainAppShell(
            accessToken: session['token'],
            userId: session['userId'],
            userName: session['fullName'],
            shopOrMerchantName: session['businessName'],
            accountRole: session['accountType'],
            phoneNumber: session['phone'],
            initialAddress: 'الناصرية - المنصورية',
            lat: 31.0437,
            lng: 46.2573,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFECFDF5), Color(0xFFF5F8F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const _LuxuryBrandMark(),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF15803D).withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'مرحباً بعودتك',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'سجّل الدخول باستخدام رقم هاتفك وكلمة المرور',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'رقم الهاتف العراقي',
                            prefixIcon: const Icon(Icons.phone_android_rounded,
                                color: Color(0xFF15803D)),
                            filled: true,
                            fillColor: const Color(0xFFF3F6F4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passCtrl,
                          obscureText: _hidePass,
                          decoration: InputDecoration(
                            hintText: 'كلمة المرور',
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                                color: Color(0xFF15803D)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _hidePass
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () =>
                                  setState(() => _hidePass = !_hidePass),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F6F4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF15803D),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: _isLoading ? null : _signIn,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LuxuryRegisterScreen(),
                                ),
                              );
                            },
                            child: const Text.rich(
                              TextSpan(
                                text: 'ليس لديك حساب؟ ',
                                style: TextStyle(color: Color(0xFF6B7280)),
                                children: [
                                  TextSpan(
                                    text: 'أنشئ حساباً جديداً',
                                    style: TextStyle(
                                      color: Color(0xFF15803D),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'التوصيل متاح داخل الناصرية حالياً',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
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
// 3. إنشاء حساب جديد
// ==========================================
class LuxuryRegisterScreen extends StatefulWidget {
  const LuxuryRegisterScreen({super.key});

  @override
  State<LuxuryRegisterScreen> createState() => _LuxuryRegisterScreenState();
}

class _LuxuryRegisterScreenState extends State<LuxuryRegisterScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _businessCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  String _selectedRole = 'صاحب سوق';
  bool _hidePass = true;
  bool _isLoading = false;

  Future<void> _createAccount() async {
    final name = _nameCtrl.text.trim();
    final business = _businessCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty || pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('أدخل الاسم ورقم الهاتف وكلمة مرور (6 أحرف فأكثر)')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final session = await SupabaseService.signUp(
        fullName: name,
        businessName: business.isEmpty ? 'سوق الناصرية التجاري' : business,
        accountType: _selectedRole,
        phone: phone,
        password: pass,
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => LuxuryMainAppShell(
            accessToken: session['token'],
            userId: session['userId'],
            userName: session['fullName'],
            shopOrMerchantName: session['businessName'],
            accountRole: session['accountType'],
            phoneNumber: session['phone'],
            initialAddress: 'الناصرية - المنصورية',
            lat: 31.0437,
            lng: 46.2573,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const _LuxuryBrandMark(),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF15803D).withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إنشاء حساب جديد',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'اختر نوع حسابك (صاحب سوق أو تاجر جملة)',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          hintText: 'الاسم الكامل',
                          prefixIcon: const Icon(Icons.person_outline_rounded,
                              color: Color(0xFF15803D)),
                          filled: true,
                          fillColor: const Color(0xFFF3F6F4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _businessCtrl,
                        decoration: InputDecoration(
                          hintText: 'اسم المحل أو شركة الجملة',
                          prefixIcon: const Icon(Icons.storefront_outlined,
                              color: Color(0xFF15803D)),
                          filled: true,
                          fillColor: const Color(0xFFF3F6F4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'نوع الحساب',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF374151)),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.badge_outlined,
                              color: Color(0xFF15803D)),
                          filled: true,
                          fillColor: const Color(0xFFF3F6F4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'صاحب سوق', child: Text('صاحب سوق (مشتري)')),
                          DropdownMenuItem(
                              value: 'تاجر جملة',
                              child: Text('تاجر جملة (مورد بضاعة)')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedRole = v);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'رقم الهاتف العراقي',
                          prefixIcon: const Icon(Icons.phone_android_rounded,
                              color: Color(0xFF15803D)),
                          filled: true,
                          fillColor: const Color(0xFFF3F6F4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _hidePass,
                        decoration: InputDecoration(
                          hintText: 'كلمة المرور (6 أحرف فأكثر)',
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              color: Color(0xFF15803D)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _hidePass
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _hidePass = !_hidePass),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF3F6F4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15803D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: _isLoading ? null : _createAccount,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'إرسال طلب إنشاء الحساب',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text.rich(
                            TextSpan(
                              text: 'لديك حساب؟ ',
                              style: TextStyle(color: Color(0xFF6B7280)),
                              children: [
                                TextSpan(
                                  text: 'سجّل الدخول',
                                  style: TextStyle(
                                    color: Color(0xFF15803D),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LuxuryBrandMark extends StatelessWidget {
  const _LuxuryBrandMark();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 175,
          height: 84,
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Icon(Icons.shopping_cart_rounded,
                size: 42, color: Color(0xFF15803D)),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'سوق الجملة',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF15803D),
          ),
        ),
        const Text(
          'من الجملة إلى السوق',
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

// ==========================================
// 4. نافذة التاجر لإضافة منتج جديد مع صورة وقسم وتفاصيل
// ==========================================
class AddProductBottomSheet extends StatefulWidget {
  final String merchantName;
  final List<String> categories;
  final Future<void> Function(WholesaleProduct newProduct) onProductAdded;

  const AddProductBottomSheet({
    super.key,
    required this.merchantName,
    required this.categories,
    required this.onProductAdded,
  });

  @override
  State<AddProductBottomSheet> createState() => _AddProductBottomSheetState();
}

class _AddProductBottomSheetState extends State<AddProductBottomSheet> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _wholesaleCtrl = TextEditingController();
  final TextEditingController _piecesCtrl = TextEditingController(text: '12');
  final TextEditingController _retailCtrl = TextEditingController();
  final TextEditingController _stockCtrl = TextEditingController(text: '50');
  late String _selectedCategory;
  File? _pickedImage;
  String? _imageBase64;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categories.firstWhere(
      (c) => c != 'الكل',
      orElse: () => 'مواد غذائية',
    );
  }

  Future<void> _pickProductImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      imageQuality: 70,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _pickedImage = File(file.path);
        _imageBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final wholesale = double.tryParse(_wholesaleCtrl.text.trim()) ?? 0;
    final pieces = int.tryParse(_piecesCtrl.text.trim()) ?? 1;
    final retail = double.tryParse(_retailCtrl.text.trim()) ?? 0;
    final stock = int.tryParse(_stockCtrl.text.trim()) ?? 20;

    if (name.isEmpty || wholesale <= 0 || pieces <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('يرجى إدخال اسم المنتج وسعر الجملة وعدد القطع')),
      );
      return;
    }

    setState(() => _saving = true);

    final product = WholesaleProduct(
      id: 'P_${DateTime.now().millisecondsSinceEpoch}',
      name: '$name ($pieces قطعة)',
      category: _selectedCategory,
      badge: 'جديد',
      itemsPerCarton: pieces,
      wholesalePrice: wholesale,
      suggestedRetailPrice: retail > 0 ? retail : (wholesale / pieces) * 1.15,
      stock: stock,
      merchantName: widget.merchantName,
      localImagePath: _pickedImage?.path,
      imageBase64: _imageBase64,
      icon: Icons.inventory_2_rounded,
    );

    await widget.onProductAdded(product);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final double wholesale = double.tryParse(_wholesaleCtrl.text.trim()) ?? 0;
    final int pieces = int.tryParse(_piecesCtrl.text.trim()) ?? 1;
    final double unitCost = pieces > 0 ? wholesale / pieces : 0;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        top: 18,
        left: 18,
        right: 18,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'إضافة منتج جديد للسوق',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // اختيار صورة المنتج
            GestureDetector(
              onTap: _pickProductImage,
              child: Container(
                height: 130,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF15803D).withOpacity(0.4)),
                ),
                child: _pickedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_pickedImage!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_rounded,
                              size: 36, color: Color(0xFF15803D)),
                          SizedBox(height: 6),
                          Text(
                            'اضغط لرفع صورة المنتج من الجهاز',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D)),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'اسم المنتج (مثال: زيت عافية 1 لتر)',
                filled: true,
                fillColor: const Color(0xFFF3F6F4),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),

            // اختيار القسم
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'القسم',
                filled: true,
                fillColor: const Color(0xFFF3F6F4),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
              items: widget.categories
                  .where((c) => c != 'الكل')
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCategory = v);
              },
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _wholesaleCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'سعر الكرتون بالجملة (د.ع)',
                      filled: true,
                      fillColor: const Color(0xFFF3F6F4),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _piecesCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'عدد القطع بالداخل',
                      filled: true,
                      fillColor: const Color(0xFFF3F6F4),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _retailCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'سعر بيع القطعة المقترح',
                      filled: true,
                      fillColor: const Color(0xFFF3F6F4),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _stockCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'الكمية بالمخزن (كرتون)',
                      filled: true,
                      fillColor: const Color(0xFFF3F6F4),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (unitCost > 0)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'سعر القطعة الواحدة على صاحب السوق: ${unitCost.toStringAsFixed(0)} د.ع',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF15803D)),
                ),
              ),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15803D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.publish_rounded),
                label: Text(
                  _saving ? 'جاري النشر...' : 'نشر المنتج في سوق الجملة',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. تحديد عنوان المحل بالدبوس وتأكيد الموقع
// ==========================================
class PinLocationConfirmSheet extends StatefulWidget {
  final String currentAddress;
  final double initialLat;
  final double initialLng;
  final void Function(String address, double lat, double lng) onConfirm;

  const PinLocationConfirmSheet({
    super.key,
    required this.currentAddress,
    required this.initialLat,
    required this.initialLng,
    required this.onConfirm,
  });

  @override
  State<PinLocationConfirmSheet> createState() =>
      _PinLocationConfirmSheetState();
}

class _PinLocationConfirmSheetState extends State<PinLocationConfirmSheet> {
  late double _lat;
  late double _lng;
  late TextEditingController _addrCtrl;
  String _selectedZone = 'المنصورية';

  final Map<String, List<double>> _nasiriyahZones = {
    'المنصورية': [31.0437, 46.2573],
    'الصوب الكبير': [31.0580, 46.2511],
    'الشامية': [31.0312, 46.2690],
    'الإدارة المحلية': [31.0510, 46.2620],
  };

  @override
  void initState() {
    super.initState();
    _lat = widget.initialLat;
    _lng = widget.initialLng;
    _addrCtrl = TextEditingController(text: widget.currentAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        top: 18,
        left: 18,
        right: 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تحديد عنوان المحل بالدبوس وتأكيد الموقع',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _nasiriyahZones.keys.map((zone) {
                final active = _selectedZone == zone;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(zone),
                    selected: active,
                    selectedColor: const Color(0xFF15803D),
                    labelStyle: TextStyle(
                      color: active ? Colors.white : const Color(0xFF111827),
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedZone = zone;
                        _lat = _nasiriyahZones[zone]![0];
                        _lng = _nasiriyahZones[zone]![1];
                        _addrCtrl.text = 'الناصرية - $zone';
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4EA),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: Color(0xFF15803D), size: 44),
                  Text(
                    'الدبوس: ${_lat.toStringAsFixed(4)}, ${_lng.toStringAsFixed(4)}',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addrCtrl,
            decoration: InputDecoration(
              labelText: 'تفاصيل العنوان',
              filled: true,
              fillColor: const Color(0xFFF3F6F4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                widget.onConfirm(_addrCtrl.text.trim(), _lat, _lng);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('تأكيد الموقع وحفظ العنوان'),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 6. الشاشة الرئيسية (المشتري + قسم التاجر المتكامل)
// ==========================================
class LuxuryMainAppShell extends StatefulWidget {
  final String accessToken;
  final String userId;
  final String userName;
  final String shopOrMerchantName;
  final String accountRole;
  final String phoneNumber;
  final String initialAddress;
  final double lat;
  final double lng;

  const LuxuryMainAppShell({
    super.key,
    required this.accessToken,
    required this.userId,
    required this.userName,
    required this.shopOrMerchantName,
    required this.accountRole,
    required this.phoneNumber,
    required this.initialAddress,
    required this.lat,
    required this.lng,
  });

  @override
  State<LuxuryMainAppShell> createState() => _LuxuryMainAppShellState();
}

class _LuxuryMainAppShellState extends State<LuxuryMainAppShell> {
  int _navIndex = 0;
  late bool _isMerchantView;
  late String _confirmedAddress;
  late double _lat;
  late double _lng;

  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  final Map<String, int> _cart = {};
  final List<MarketOrder> _orders = [];

  final List<String> _categories = [
    'الكل',
    'مواد غذائية',
    'مشروبات',
    'ألبان وأجبان',
    'منظفات',
    'بقوليات',
  ];

  List<WholesaleProduct> _products = [
    WholesaleProduct(
      id: 'P1',
      name: 'أرز بسمتي فاخر - كيس 30 كغم',
      category: 'مواد غذائية',
      badge: 'عروض 3',
      itemsPerCarton: 30,
      wholesalePrice: 48000,
      suggestedRetailPrice: 2000,
      stock: 60,
      merchantName: 'تاجر جملة - الناصرية',
      icon: Icons.rice_bowl_rounded,
    ),
    WholesaleProduct(
      id: 'P2',
      name: 'زيت طعام نقي - كرتون 12 عبوة',
      category: 'مواد غذائية',
      badge: 'عروض 4',
      itemsPerCarton: 12,
      wholesalePrice: 96000,
      suggestedRetailPrice: 9500,
      stock: 40,
      merchantName: 'تاجر جملة - الناصرية',
      icon: Icons.water_drop_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _isMerchantView = widget.accountRole == 'تاجر جملة';
    _confirmedAddress = widget.initialAddress;
    _lat = widget.lat;
    _lng = widget.lng;
    _loadRemoteProducts();
  }

  Future<void> _loadRemoteProducts() async {
    try {
      final remote = await SupabaseService.fetchProducts(widget.accessToken);
      if (remote.isNotEmpty && mounted) {
        setState(() => _products = remote);
      }
    } catch (_) {}
  }

  String _formatDinar(double value) {
    final formatted = value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '$formatted د.ع';
  }

  void _openAddProductSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddProductBottomSheet(
        merchantName: widget.shopOrMerchantName,
        categories: _categories,
        onProductAdded: (newProduct) async {
          try {
            await SupabaseService.addProduct(
              token: widget.accessToken,
              product: newProduct,
            );
          } catch (_) {}
          if (mounted) {
            setState(() {
              _products.insert(0, newProduct);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تمت إضافة المنتج ونشره لأصحاب الأسواق بنجاح!'),
                backgroundColor: Color(0xFF15803D),
              ),
            );
          }
        },
      ),
    );
  }

  void _openAddCategoryDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة قسم جديد'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'اسم القسم (مثال: حلويات)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF15803D),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final text = ctrl.text.trim();
              if (text.isNotEmpty && !_categories.contains(text)) {
                setState(() => _categories.add(text));
              }
              Navigator.pop(ctx);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _openPinLocationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PinLocationConfirmSheet(
        currentAddress: _confirmedAddress,
        initialLat: _lat,
        initialLng: _lng,
        onConfirm: (addr, newLat, newLng) {
          setState(() {
            _confirmedAddress = addr;
            _lat = newLat;
            _lng = newLng;
          });
        },
      ),
    );
  }

  Future<void> _submitOrder() async {
    if (_cart.isEmpty) return;

    double subtotal = 0;
    _cart.forEach((id, qty) {
      final prod = _products.firstWhere((item) => item.id == id);
      subtotal += prod.wholesalePrice * qty;
      prod.stock = (prod.stock - qty).clamp(0, 9999);
    });

    final double fee = _orders.length < 4 ? 0 : 5000;
    final double total = subtotal + fee;

    try {
      await SupabaseService.createOrder(
        token: widget.accessToken,
        userId: widget.userId,
        shopName: widget.shopOrMerchantName,
        address: _confirmedAddress,
        lat: _lat,
        lng: _lng,
        totalAmount: total,
      );
    } catch (_) {}

    setState(() {
      _orders.insert(
        0,
        MarketOrder(
          id: 'ORD-${201 + _orders.length}',
          shopName: widget.shopOrMerchantName,
          confirmedAddress: _confirmedAddress,
          totalAmount: total,
          deliveryFee: fee,
          status: 'قيد التجهيز',
        ),
      );
      _cart.clear();
      _navIndex = 3;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إرسال الطلب بنجاح!'),
        backgroundColor: Color(0xFF15803D),
      ),
    );
  }

  Widget _buildProductThumbnail(WholesaleProduct p) {
    if (p.localImagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(p.localImagePath!),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
    if (p.imageBase64 != null && p.imageBase64!.isNotEmpty) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            base64Decode(p.imageBase64!),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {}
    }
    return Center(
      child: Icon(p.icon, size: 46, color: const Color(0xFF15803D)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int cartCount = _cart.values.fold(0, (a, b) => a + b);

    final visibleProducts = _products.where((p) {
      final matchesCat =
          _selectedCategory == 'الكل' || p.category == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty || p.name.contains(_searchQuery);
      return matchesCat && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),
      body: SafeArea(
        child: IndexedStack(
          index: _navIndex,
          children: [
            _isMerchantView
                ? _buildMerchantDashboard()
                : _buildMarketHome(visibleProducts),
            _buildCategoriesView(),
            _buildCartView(),
            _buildOrdersView(),
            _buildAccountView(),
          ],
        ),
      ),
      floatingActionButton: _isMerchantView
          ? FloatingActionButton.extended(
              onPressed: _openAddProductSheet,
              backgroundColor: const Color(0xFF15803D),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_a_photo_rounded),
              label: const Text('إضافة منتج + صورة',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF15803D),
        unselectedItemColor: const Color(0xFF6B7280),
        backgroundColor: Colors.white,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (idx) => setState(() => _navIndex = idx),
        items: [
          BottomNavigationBarItem(
            icon: Icon(_isMerchantView
                ? Icons.storefront_outlined
                : Icons.home_outlined),
            activeIcon: Icon(
                _isMerchantView ? Icons.storefront_rounded : Icons.home_rounded),
            label: _isMerchantView ? 'قسم التاجر' : 'الرئيسية',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'الأقسام',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_bag_rounded),
            ),
            label: 'السلة',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'طلباتي',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }

  // ==========================================
  // قسم التاجر المتكامل (إضافة منتجات + أقسام + إدارة الطلبات)
  // ==========================================
  Widget _buildMerchantDashboard() {
    final totalSales =
        _orders.fold<double>(0, (sum, item) => sum + item.totalAmount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.shopOrMerchantName,
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w900),
                ),
                const Text(
                  'قسم تاجر الجملة • إدارة البضاعة والأسعار',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: _openAddCategoryDialog,
              icon: const Icon(Icons.create_new_folder_outlined,
                  size: 18, color: Color(0xFF15803D)),
              label: const Text('إضافة قسم',
                  style: TextStyle(color: Color(0xFF15803D), fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF15803D),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('إجمالي المبيعات',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(_formatDinar(totalSales),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2C59),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('منتجاتك المعروضة',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text('${_products.length} صنف',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'منتجاتي في سوق الجملة',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._products.map((p) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: SizedBox(
                width: 52,
                height: 52,
                child: _buildProductThumbnail(p),
              ),
              title: Text(p.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(
                'القسم: ${p.category} • العدد: ${p.itemsPerCarton} قطعة\nسعر الكرتون: ${_formatDinar(p.wholesalePrice)} (القطعة: ${_formatDinar(p.unitPrice)})',
                style: const TextStyle(fontSize: 11),
              ),
              isThreeLine: true,
              trailing: Text(
                'مخزون:\n${p.stock}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Color(0xFF15803D)),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // واجهة صاحب السوق (المشتري)
  // ==========================================
  Widget _buildMarketHome(List<WholesaleProduct> visibleProducts) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF15803D),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.shopping_cart_rounded,
                      color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سوق الجملة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      'من الجملة إلى السوق',
                      style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ],
            ),
            IconButton(
              onPressed: _loadRemoteProducts,
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF15803D)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _openPinLocationModal,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    color: Color(0xFF15803D), size: 19),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'التوصيل إلى: $_confirmedAddress',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const Text(
                  'تعديل الموقع',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15803D)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (v) => setState(() => _searchQuery = v.trim()),
          decoration: InputDecoration(
            hintText: '...ابحث عن منتج أو صنف',
            prefixIcon:
                const Icon(Icons.search_rounded, color: Color(0xFF6B7280)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final cat = _categories[idx];
              final selected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: selected,
                selectedColor: const Color(0xFF15803D),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF111827),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                onSelected: (_) => setState(() => _selectedCategory = cat),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF15803D), Color(0xFF166534)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'وربح أكبر..\nمشتريات أذكى',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'قارن عروض التجار واختر السعر الأنسب',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, idx) {
            final p = visibleProducts[idx];
            final qty = _cart[p.id] ?? 0;

            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F6F4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildProductThumbnail(p),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'القطعة: ${_formatDinar(p.unitPrice)} • ${p.itemsPerCarton} قطعة',
                    style:
                        const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDinar(p.wholesalePrice),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF15803D),
                    ),
                  ),
                  Text(
                    'ربحك: +${_formatDinar(p.expectedCartonProfit)}',
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF15803D),
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  qty == 0
                      ? SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF15803D),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => setState(() => _cart[p.id] = 1),
                            child: const Text('أضف للسلة',
                                style: TextStyle(fontSize: 11)),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => setState(() {
                                if ((_cart[p.id] ?? 0) > 1) {
                                  _cart[p.id] = _cart[p.id]! - 1;
                                } else {
                                  _cart.remove(p.id);
                                }
                              }),
                              child: const Icon(Icons.remove_circle,
                                  size: 22, color: Colors.red),
                            ),
                            Text('$qty',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            InkWell(
                              onTap: () => setState(
                                  () => _cart[p.id] = (_cart[p.id] ?? 0) + 1),
                              child: const Icon(Icons.add_circle,
                                  size: 22, color: Color(0xFF15803D)),
                            ),
                          ],
                        ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoriesView() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('الأقسام',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            if (_isMerchantView)
              TextButton.icon(
                onPressed: _openAddCategoryDialog,
                icon: const Icon(Icons.add, color: Color(0xFF15803D)),
                label: const Text('قسم جديد',
                    style: TextStyle(color: Color(0xFF15803D))),
              ),
          ],
        ),
        const SizedBox(height: 10),
        ..._categories.where((c) => c != 'الكل').map((cat) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading:
                  const Icon(Icons.category_rounded, color: Color(0xFF15803D)),
              title: Text(cat,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                  _navIndex = 0;
                });
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCartView() {
    if (_cart.isEmpty) {
      return const Center(child: Text('السلة فارغة — أضف منتجات الجملة للبدء'));
    }

    double subtotal = 0;
    _cart.forEach((id, qty) {
      final p = _products.firstWhere((item) => item.id == id);
      subtotal += p.wholesalePrice * qty;
    });
    final double delivery = _orders.length < 4 ? 0 : 5000;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text('سلة الطلبات',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._cart.entries.map((e) {
          final p = _products.firstWhere((item) => item.id == e.key);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(p.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle:
                  Text('${e.value} × ${_formatDinar(p.wholesalePrice)}'),
              trailing: Text(_formatDinar(p.wholesalePrice * e.value)),
            ),
          );
        }),
        const SizedBox(height: 14),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF15803D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _submitOrder,
            child: Text(
              'تأكيد الطلب (${_formatDinar(subtotal + delivery)})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersView() {
    if (_orders.isEmpty) {
      return const Center(child: Text('لا توجد طلبات حتى الآن'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _orders.length,
      itemBuilder: (context, idx) {
        final o = _orders[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text('${o.id} • ${o.status}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('العنوان: ${o.confirmedAddress}'),
            trailing: Text(_formatDinar(o.totalAmount),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
          ),
        );
      },
    );
  }

  Widget _buildAccountView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.userName,
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('النشاط: ${widget.shopOrMerchantName}'),
              Text('نوع الحساب: ${widget.accountRole}'),
              Text('الهاتف: ${widget.phoneNumber}'),
              Text('العنوان المؤكد: $_confirmedAddress'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: _isMerchantView,
          activeColor: const Color(0xFF15803D),
          title: const Text('تفعيل قسم التاجر (رفع منتجات وأقسام)'),
          onChanged: (val) => setState(() => _isMerchantView = val),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LuxuryLoginScreen()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.logout_rounded, color: Colors.red),
          label:
              const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
