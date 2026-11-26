import 'package:flutter/material.dart';

void main() {
  runApp(const SouqAlJumlaLuxuryApp());
}

class SouqAlJumlaLuxuryApp extends StatelessWidget {
  const SouqAlJumlaLuxuryApp({super.key});

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
    required this.icon,
  });

  double get unitPrice => wholesalePrice / itemsPerCarton;
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
  final DateTime time;

  MarketOrder({
    required this.id,
    required this.shopName,
    required this.confirmedAddress,
    required this.totalAmount,
    required this.deliveryFee,
    this.status = 'قيد التجهيز',
    required this.time,
  });
}

// ==========================================
// 2. تسجيل الدخول (رقم الهاتف + كلمة المرور)
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

  void _signIn() {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رقم الهاتف العراقي')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LuxuryMainAppShell(
          userName: 'أحمد',
          shopOrMerchantName: 'سوق المنصورية المركزي',
          accountRole: 'صاحب سوق',
          phoneNumber: phone,
          initialAddress: 'الناصرية - المنصورية - قرب ملعب المنصورية',
          lat: 31.0437,
          lng: 46.2573,
        ),
      ),
    );
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
                            hintText: 'رقم الهاتف العراقي (مثال: 0780...)',
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
                                color: const Color(0xFF374151),
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
                              elevation: 2,
                            ),
                            onPressed: _signIn,
                            child: const Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
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
// 3. إنشاء حساب جديد (صاحب سوق أو تاجر جملة)
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

  void _createAccount() {
    final name = _nameCtrl.text.trim();
    final business = _businessCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال الاسم الكامل ورقم الهاتف')),
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LuxuryMainAppShell(
          userName: name,
          shopOrMerchantName:
              business.isEmpty ? 'سوق الناصرية التجاري' : business,
          accountRole: _selectedRole,
          phoneNumber: phone,
          initialAddress: 'الناصرية - المنصورية',
          lat: 31.0437,
          lng: 46.2573,
        ),
      ),
      (route) => false,
    );
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
                        'أرسل طلب الانضمام إلى سوق الجملة',
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
                          hintText: 'اسم المحل أو النشاط التجاري',
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
                              value: 'صاحب سوق', child: Text('صاحب سوق')),
                          DropdownMenuItem(
                              value: 'تاجر جملة', child: Text('تاجر جملة')),
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
                          onPressed: _createAccount,
                          child: const Text(
                            'إرسال طلب إنشاء الحساب',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
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
// 4. نافذة تحديد العنوان بالدبوس وتأكيد الموقع
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
  State<PinLocationConfirmSheet> createState() => _PinLocationConfirmSheetState();
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

  void _movePin(double dLat, double dLng) {
    setState(() {
      _lat += dLat;
      _lng += dLng;
    });
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'تحديد عنوان المحل بالدبوس وتأكيد الموقع',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // اختيار منطقة سريعة في الناصرية
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

          // لوحة الخريطة التفاعلية مع الدبوس وأزرار تحريكه
          Container(
            height: 175,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4EA),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF15803D).withOpacity(0.3)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: Color(0xFF15803D), size: 46),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'الدبوس: ${_lat.toStringAsFixed(4)}, ${_lng.toStringAsFixed(4)}',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Row(
                    children: [
                      _pinMoveBtn(Icons.arrow_upward, () => _movePin(0.0015, 0)),
                      const SizedBox(width: 4),
                      _pinMoveBtn(
                          Icons.arrow_downward, () => _movePin(-0.0015, 0)),
                      const SizedBox(width: 4),
                      _pinMoveBtn(
                          Icons.arrow_back, () => _movePin(0, -0.0015)),
                      const SizedBox(width: 4),
                      _pinMoveBtn(
                          Icons.arrow_forward, () => _movePin(0, 0.0015)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _addrCtrl,
            decoration: InputDecoration(
              labelText: 'تفاصيل العنوان (الشارع / أقرب نقطة دالة)',
              prefixIcon: const Icon(Icons.pin_drop_rounded,
                  color: Color(0xFF15803D)),
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
                final text = _addrCtrl.text.trim().isEmpty
                    ? 'الناصرية - $_selectedZone'
                    : _addrCtrl.text.trim();
                widget.onConfirm(text, _lat, _lng);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text(
                'تأكيد الموقع وحفظ العنوان',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pinMoveBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
          ],
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF15803D)),
      ),
    );
  }
}

// ==========================================
// 5. الهيكل الرئيسي للتطبيق (المشتري + التاجر)
// ==========================================
class LuxuryMainAppShell extends StatefulWidget {
  final String userName;
  final String shopOrMerchantName;
  final String accountRole;
  final String phoneNumber;
  final String initialAddress;
  final double lat;
  final double lng;

  const LuxuryMainAppShell({
    super.key,
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
  bool _locationConfirmed = true;

  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  final Set<String> _favorites = {};
  final Map<String, int> _cart = {};
  final List<MarketOrder> _orders = [];

  final List<String> _categories = [
    'الكل',
    'مواد غذائية',
    'مشروبات',
    'ألبان وأجبان',
    'منظفات',
  ];

  final List<WholesaleProduct> _products = [
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
      name: 'ملح مائدة ناعم - شدة 24 عبوة',
      category: 'مواد غذائية',
      badge: 'عروض 2',
      itemsPerCarton: 24,
      wholesalePrice: 12000,
      suggestedRetailPrice: 750,
      stock: 95,
      merchantName: 'مخازن الفرات للجملة',
      icon: Icons.grain_rounded,
    ),
    WholesaleProduct(
      id: 'P3',
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
    WholesaleProduct(
      id: 'P4',
      name: 'شاي ومرطبات - كرتون 24 علبة',
      category: 'مشروبات',
      badge: 'عروض 2',
      itemsPerCarton: 24,
      wholesalePrice: 110000,
      suggestedRetailPrice: 5500,
      stock: 28,
      merchantName: 'توزيع الجنوب',
      icon: Icons.local_drink_rounded,
    ),
    WholesaleProduct(
      id: 'P5',
      name: 'ألبان وأجبان - كرتون 18 عبوة',
      category: 'ألبان وأجبان',
      badge: 'عروض 3',
      itemsPerCarton: 18,
      wholesalePrice: 54000,
      suggestedRetailPrice: 3750,
      stock: 32,
      merchantName: 'مخازن الفرات للجملة',
      icon: Icons.egg_alt_rounded,
    ),
    WholesaleProduct(
      id: 'P6',
      name: 'منظفات ومطهرات - كرتون 12 عبوة',
      category: 'منظفات',
      badge: 'عروض 2',
      itemsPerCarton: 12,
      wholesalePrice: 42000,
      suggestedRetailPrice: 4500,
      stock: 45,
      merchantName: 'توزيع الجنوب',
      icon: Icons.cleaning_services_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _isMerchantView = widget.accountRole == 'تاجر جملة';
    _confirmedAddress = widget.initialAddress;
    _lat = widget.lat;
    _lng = widget.lng;
  }

  String _formatDinar(double value) {
    final formatted = value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '$formatted د.ع';
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
            _locationConfirmed = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تأكيد الموقع: $addr'),
              backgroundColor: const Color(0xFF15803D),
            ),
          );
        },
      ),
    );
  }

  void _addToCart(String productId) {
    setState(() {
      _cart[productId] = (_cart[productId] ?? 0) + 1;
    });
  }

  void _removeFromCart(String productId) {
    setState(() {
      if ((_cart[productId] ?? 0) > 1) {
        _cart[productId] = _cart[productId]! - 1;
      } else {
        _cart.remove(productId);
      }
    });
  }

  void _submitOrder() {
    if (_cart.isEmpty) return;

    double subtotal = 0;
    _cart.forEach((id, qty) {
      final prod = _products.firstWhere((item) => item.id == id);
      subtotal += prod.wholesalePrice * qty;
      prod.stock = (prod.stock - qty).clamp(0, 9999);
    });

    // أول 4 طلبات توصيل مجاني
    final double fee = _orders.length < 4 ? 0 : 5000;

    setState(() {
      _orders.insert(
        0,
        MarketOrder(
          id: 'ORD-${201 + _orders.length}',
          shopName: widget.shopOrMerchantName,
          confirmedAddress: _confirmedAddress,
          totalAmount: subtotal + fee,
          deliveryFee: fee,
          status: 'قيد التجهيز',
          time: DateTime.now(),
        ),
      );
      _cart.clear();
      _navIndex = 3;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تأكيد الطلب وإرساله إلى التاجر!'),
        backgroundColor: Color(0xFF15803D),
      ),
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
            _isMerchantView ? _buildMerchantView() : _buildHomeView(visibleProducts),
            _buildCategoriesView(),
            _buildCartView(),
            _buildOrdersView(),
            _buildAccountView(),
          ],
        ),
      ),
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
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: _isMerchantView ? 'التاجر' : 'الرئيسية',
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

  Widget _buildHomeView(List<WholesaleProduct> visibleProducts) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // الهيدر العلوي
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
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('رصيدك الترحيبي: 25,000 د.ع متاح')),
                    );
                  },
                  icon: const Icon(Icons.notifications_none_rounded,
                      color: Color(0xFF374151)),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('المفضلة: ${_favorites.length} صنف')),
                    );
                  },
                  icon: const Icon(Icons.favorite_border_rounded,
                      color: Color(0xFF374151)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // سطر العنوان وتأكيد الموقع بالدبوس
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _locationConfirmed ? 'مؤكد • تعديل' : 'تأكيد الموقع',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // البحث
        TextField(
          onChanged: (v) => setState(() => _searchQuery = v.trim()),
          decoration: InputDecoration(
            hintText: '...ابحث عن منتج أو صنف',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            prefixIcon:
                const Icon(Icons.search_rounded, color: Color(0xFF6B7280)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
        const SizedBox(height: 14),

        // الأقسام
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, idx) {
              final cat = _categories[idx];
              final selected = _selectedCategory == cat;
              final IconData icon = switch (cat) {
                'الكل' => Icons.grid_view_rounded,
                'مواد غذائية' => Icons.shopping_cart_outlined,
                'مشروبات' => Icons.local_cafe_outlined,
                'ألبان وأجبان' => Icons.local_drink_outlined,
                _ => Icons.clean_hands_outlined,
              };

              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF15803D)
                              : Colors.grey.shade200,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: selected
                            ? const Color(0xFF15803D)
                            : const Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                        color: selected
                            ? const Color(0xFF15803D)
                            : const Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // البنر الأخضر الفخم
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF15803D), Color(0xFF166534)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سوق الجملة • الناصرية',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
              SizedBox(height: 6),
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
        const SizedBox(height: 12),

        // شريط المزايا الثلاث
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BenefitBadge(
                icon: Icons.local_shipping_outlined,
                title: 'توصيل من التاجر',
                subtitle: 'إلى محلك',
              ),
              _BenefitBadge(
                icon: Icons.compare_arrows_rounded,
                title: 'قارن الأسعار',
                subtitle: 'قبل الشراء',
              ),
              _BenefitBadge(
                icon: Icons.payments_outlined,
                title: 'الدفع عند الاستلام',
                subtitle: 'نقداً',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // الأكثر طلباً
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'الأكثر طلباً',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827)),
            ),
            Text(
              'منتجات ${visibleProducts.length}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.70,
          ),
          itemBuilder: (context, idx) {
            final p = visibleProducts[idx];
            final qty = _cart[p.id] ?? 0;
            final fav = _favorites.contains(p.id);

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
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(p.icon,
                                size: 46, color: const Color(0xFF15803D)),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                p.badge,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (fav) {
                                    _favorites.remove(p.id);
                                  } else {
                                    _favorites.add(p.id);
                                  }
                                });
                              },
                              child: Icon(
                                fav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 18,
                                color: fav ? Colors.red : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                  const SizedBox(height: 3),
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
                            onPressed: () => _addToCart(p.id),
                            child: const Text('أضف للسلة',
                                style: TextStyle(fontSize: 11)),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => _removeFromCart(p.id),
                              child: const Icon(Icons.remove_circle,
                                  size: 22, color: Colors.red),
                            ),
                            Text('$qty',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            InkWell(
                              onTap: () => _addToCart(p.id),
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

  Widget _buildMerchantView() {
    final totalSales =
        _orders.fold<double>(0, (sum, item) => sum + item.totalAmount);

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text(
          'لوحة تحكم تاجر الجملة',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricBox('مبيعات اليوم', _formatDinar(totalSales),
                  const Color(0xFF15803D)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricBox('الطلبات الواردة', '${_orders.length} طلب',
                  const Color(0xFF0F2C59)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'الطلبات وحالة التجهيز',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_orders.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('لا توجد طلبات واردة حالياً'),
            ),
          )
        else
          ..._orders.map((order) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${order.id} • ${order.shopName}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(_formatDinar(order.totalAmount),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('العنوان المؤكد: ${order.confirmedAddress}',
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الحالة: ${order.status}',
                            style: const TextStyle(fontSize: 12)),
                        DropdownButton<String>(
                          value: order.status,
                          items: const [
                            DropdownMenuItem(
                                value: 'قيد التجهيز',
                                child: Text('قيد التجهيز')),
                            DropdownMenuItem(
                                value: 'خرج للتوصيل',
                                child: Text('خرج للتوصيل')),
                            DropdownMenuItem(
                                value: 'تم التسليم',
                                child: Text('تم التسليم')),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => order.status = v);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _metricBox(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          Text(val,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildCategoriesView() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text('الأقسام',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._categories.where((c) => c != 'الكل').map((cat) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading:
                  const Icon(Icons.category_rounded, color: Color(0xFF15803D)),
              title:
                  Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
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
      return const Center(
        child: Text('السلة فارغة — أضف منتجات الجملة للبدء'),
      );
    }

    double subtotal = 0;
    double expectedProfit = 0;
    _cart.forEach((id, qty) {
      final p = _products.firstWhere((item) => item.id == id);
      subtotal += p.wholesalePrice * qty;
      expectedProfit += p.expectedCartonProfit * qty;
    });
    final double delivery = _orders.length < 4 ? 0 : 5000;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text('سلة الطلبات',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListTile(
          tileColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          leading: const Icon(Icons.location_on_rounded,
              color: Color(0xFF15803D)),
          title: Text(_confirmedAddress,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          trailing: TextButton(
            onPressed: _openPinLocationModal,
            child: const Text('تغيير'),
          ),
        ),
        const SizedBox(height: 10),
        ..._cart.entries.map((e) {
          final p = _products.firstWhere((item) => item.id == e.key);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title:
                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle:
                  Text('${e.value} × ${_formatDinar(p.wholesalePrice)}'),
              trailing: Text(_formatDinar(p.wholesalePrice * e.value)),
            ),
          );
        }),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('الربح المتوقع:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_formatDinar(expectedProfit),
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, color: Color(0xFF15803D))),
            ],
          ),
        ),
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
              'تأكيد الطلب (${_formatDinar(subtotal + delivery)}) • توصيل ${delivery == 0 ? "مجاني" : _formatDinar(delivery)}',
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
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF15803D),
            foregroundColor: Colors.white,
          ),
          onPressed: _openPinLocationModal,
          icon: const Icon(Icons.pin_drop_rounded),
          label: const Text('تعديل وتأكيد موقع المحل بالدبوس'),
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          value: _isMerchantView,
          activeColor: const Color(0xFF15803D),
          title: const Text('التبديل إلى واجهة تاجر الجملة'),
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

class _BenefitBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitBadge({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF15803D), size: 22),
        const SizedBox(height: 4),
        Text(title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        Text(subtitle,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
      ],
    );
  }
}
