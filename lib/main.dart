import 'package:flutter/material.dart';

void main() {
  runApp(const SouqAlJumlaApp());
}

class SouqAlJumlaApp extends StatelessWidget {
  const SouqAlJumlaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سوق الجملة - من الجملة إلى السوق',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF166534),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF166534),
          primary: const Color(0xFF166534),
          secondary: const Color(0xFF15803D),
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const LoginScreen(),
    );
  }
}

// ==========================================
// 1. نماذج البيانات (Models)
// ==========================================
class ProductItem {
  final String id;
  final String name;
  final String category;
  final String badgeText;
  final int itemsPerCarton;
  final double wholesalePrice;
  final double suggestedRetailPrice;
  final String merchantName;
  final IconData icon;

  ProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.badgeText,
    required this.itemsPerCarton,
    required this.wholesalePrice,
    required this.suggestedRetailPrice,
    required this.merchantName,
    required this.icon,
  });

  double get unitPrice => wholesalePrice / itemsPerCarton;
  double get expectedProfit =>
      (suggestedRetailPrice * itemsPerCarton) - wholesalePrice;
}

class OrderRecord {
  final String id;
  final String dateLabel;
  final double total;
  final String status;

  OrderRecord({
    required this.id,
    required this.dateLabel,
    required this.total,
    required this.status,
  });
}

// ==========================================
// 2. صفحة تسجيل الدخول (رقم الهاتف + كلمة المرور)
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _login() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رقم الهاتف العراقي')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeShellScreen(
          userName: 'أحمد',
          shopName: 'أسواق الناصرية',
          accountType: 'صاحب سوق',
          phone: phone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                _BrandHeaderCard(),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'مرحباً بعودتك',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'سجّل الدخول باستخدام رقم هاتفك',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'رقم الهاتف العراقي',
                          prefixIcon: const Icon(Icons.phone_android_rounded,
                              color: Color(0xFF166534)),
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              color: Color(0xFF166534)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF374151),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF166534),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _login,
                          child: const Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
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
                                    color: Color(0xFF166534),
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
                const SizedBox(height: 18),
                const Text(
                  'التوصيل متاح داخل الناصرية حالياً',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. صفحة إنشاء حساب جديد (صاحب سوق أو تاجر جملة)
// ==========================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shopController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _accountType = 'صاحب سوق';
  bool _obscurePassword = true;

  void _submitRegistration() {
    final name = _nameController.text.trim();
    final shop = _shopController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال الاسم الكامل ورقم الهاتف')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'تم إرسال طلب إنشاء الحساب',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF166534)),
        ),
        content: Text(
          'مرحباً $name، تم تسجيل طلبك كـ ($_accountType) باسم (${shop.isEmpty ? "نشاط تجاري" : shop}). سيتم مراجعة الحساب وتفعيله داخل الناصرية.',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => HomeShellScreen(
                    userName: name,
                    shopName: shop.isEmpty ? 'سوق الناصرية' : shop,
                    accountType: _accountType,
                    phone: phone,
                  ),
                ),
                (route) => false,
              );
            },
            child: const Text('متابعة إلى سوق الجملة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                _BrandHeaderCard(),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إنشاء حساب جديد',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'أرسل طلب الانضمام إلى سوق الجملة',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'الاسم الكامل',
                          prefixIcon: const Icon(Icons.person_outline_rounded,
                              color: Color(0xFF166534)),
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _shopController,
                        decoration: InputDecoration(
                          hintText: 'اسم المحل أو النشاط',
                          prefixIcon: const Icon(Icons.storefront_outlined,
                              color: Color(0xFF166534)),
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'نوع الحساب',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _accountType,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.badge_outlined,
                              color: Color(0xFF166534)),
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'صاحب سوق',
                            child: Text('صاحب سوق'),
                          ),
                          DropdownMenuItem(
                            value: 'تاجر جملة',
                            child: Text('تاجر جملة'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _accountType = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'رقم الهاتف العراقي',
                          prefixIcon: const Icon(Icons.phone_android_rounded,
                              color: Color(0xFF166534)),
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              color: Color(0xFF166534)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF374151),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF166534),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _submitRegistration,
                          child: const Text(
                            'إرسال طلب إنشاء الحساب',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
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
                                    color: Color(0xFF166534),
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

class _BrandHeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 170,
          height: 82,
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(
            child: Icon(
              Icons.shopping_cart_rounded,
              size: 42,
              color: Color(0xFF166534),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'سوق الجملة',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF166534),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'من الجملة إلى السوق',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 4. الشاشة الرئيسية والتنقل السفلي (5 تبويبات)
// ==========================================
class HomeShellScreen extends StatefulWidget {
  final String userName;
  final String shopName;
  final String accountType;
  final String phone;

  const HomeShellScreen({
    super.key,
    required this.userName,
    required this.shopName,
    required this.accountType,
    required this.phone,
  });

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _navIndex = 0;
  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  final Set<String> _favorites = {};
  final Map<String, int> _cart = {};
  final List<OrderRecord> _orders = [];

  final List<String> _categories = [
    'الكل',
    'مواد غذائية',
    'مشروبات',
    'ألبان وأجبان',
    'منظفات',
  ];

  final List<ProductItem> _products = [
    ProductItem(
      id: '1',
      name: 'أرز بسمتي فاخر - كيس 30 كغم',
      category: 'مواد غذائية',
      badgeText: 'عروض 3',
      itemsPerCarton: 30,
      wholesalePrice: 48000,
      suggestedRetailPrice: 2000,
      merchantName: 'تاجر جملة - الناصرية',
      icon: Icons.rice_bowl_rounded,
    ),
    ProductItem(
      id: '2',
      name: 'ملح مائدة ناعم - شدة 24 عبوة',
      category: 'مواد غذائية',
      badgeText: 'عروض 2',
      itemsPerCarton: 24,
      wholesalePrice: 12000,
      suggestedRetailPrice: 750,
      merchantName: 'مخازن الفرات للجملة',
      icon: Icons.grain_rounded,
    ),
    ProductItem(
      id: '3',
      name: 'زيت طعام نقي - كرتون 12 عبوة',
      category: 'مواد غذائية',
      badgeText: 'عروض 4',
      itemsPerCarton: 12,
      wholesalePrice: 96000,
      suggestedRetailPrice: 9500,
      merchantName: 'تاجر جملة - الناصرية',
      icon: Icons.water_drop_rounded,
    ),
    ProductItem(
      id: '4',
      name: 'شاي ومرطبات - كرتون 24 علبة',
      category: 'مشروبات',
      badgeText: 'عروض 2',
      itemsPerCarton: 24,
      wholesalePrice: 110000,
      suggestedRetailPrice: 5500,
      merchantName: 'توزيع الجنوب',
      icon: Icons.local_drink_rounded,
    ),
    ProductItem(
      id: '5',
      name: 'ألبان وأجبان طازجة - كرتون 18 قطعة',
      category: 'ألبان وأجبان',
      badgeText: 'عروض 3',
      itemsPerCarton: 18,
      wholesalePrice: 54000,
      suggestedRetailPrice: 3750,
      merchantName: 'مخازن الفرات للجملة',
      icon: Icons.egg_alt_rounded,
    ),
    ProductItem(
      id: '6',
      name: 'منظفات ومطهرات - كرتون 12 عبوة',
      category: 'منظفات',
      badgeText: 'عروض 2',
      itemsPerCarton: 12,
      wholesalePrice: 42000,
      suggestedRetailPrice: 4500,
      merchantName: 'توزيع الجنوب',
      icon: Icons.cleaning_services_rounded,
    ),
  ];

  String _iqd(double val) {
    final s = val.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '$s د.ع';
  }

  void _addToCart(String id) {
    setState(() {
      _cart[id] = (_cart[id] ?? 0) + 1;
    });
  }

  void _removeFromCart(String id) {
    setState(() {
      if ((_cart[id] ?? 0) > 1) {
        _cart[id] = _cart[id]! - 1;
      } else {
        _cart.remove(id);
      }
    });
  }

  void _checkout() {
    if (_cart.isEmpty) return;
    double sum = 0;
    _cart.forEach((id, qty) {
      final p = _products.firstWhere((item) => item.id == id);
      sum += p.wholesalePrice * qty;
    });

    setState(() {
      _orders.insert(
        0,
        OrderRecord(
          id: 'ORD-${101 + _orders.length}',
          dateLabel: 'اليوم • الدفع عند الاستلام',
          total: sum,
          status: 'قيد التجهيز',
        ),
      );
      _cart.clear();
      _navIndex = 3; // طلباتي
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إرسال طلبك بنجاح! الدفع عند الاستلام نقداً'),
        backgroundColor: Color(0xFF166534),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int cartCount = _cart.values.fold(0, (a, b) => a + b);

    final filteredProducts = _products.where((p) {
      final matchesCat =
          _selectedCategory == 'الكل' || p.category == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty || p.name.contains(_searchQuery);
      return matchesCat && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        child: IndexedStack(
          index: _navIndex,
          children: [
            _buildHomeTab(filteredProducts),
            _buildCategoriesTab(),
            _buildCartTab(),
            _buildOrdersTab(),
            _buildAccountTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF166534),
        unselectedItemColor: const Color(0xFF6B7280),
        backgroundColor: Colors.white,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (i) => setState(() => _navIndex = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
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

  Widget _buildHomeTab(List<ProductItem> filteredProducts) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // الهيدر العلوي: شعار + اسم سوق الجملة + إشعارات ومفضلة
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF166534),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shopping_cart_rounded,
                      color: Colors.white, size: 24),
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
                          content: Text('لا توجد إشعارات جديدة حالياً')),
                    );
                  },
                  icon: const Icon(Icons.notifications_none_rounded,
                      color: Color(0xFF374151)),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'عدد المنتجات المفضلة: ${_favorites.length}'),
                      ),
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

        // سطر التوصيل إلى الناصرية
        Row(
          children: [
            const Icon(Icons.location_on_outlined,
                color: Color(0xFF166534), size: 18),
            const SizedBox(width: 4),
            const Text(
              'التوصيل إلى ',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const Text(
              'الناصرية',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: Colors.grey[600]),
          ],
        ),
        const SizedBox(height: 12),

        // شريط البحث
        TextField(
          onChanged: (val) => setState(() => _searchQuery = val.trim()),
          decoration: InputDecoration(
            hintText: '...ابحث عن منتج أو صنف',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6B7280)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // شريط الأقسام
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat;
              final IconData catIcon = switch (cat) {
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
                          color: isSelected
                              ? const Color(0xFF166534)
                              : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        catIcon,
                        color: isSelected
                            ? const Color(0xFF166534)
                            : const Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xFF166534)
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
            borderRadius: BorderRadius.circular(18),
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
              _FeatureItem(
                icon: Icons.local_shipping_outlined,
                title: 'توصيل من التاجر',
                subtitle: 'إلى محلك',
              ),
              _FeatureItem(
                icon: Icons.compare_arrows_rounded,
                title: 'قارن الأسعار',
                subtitle: 'قبل الشراء',
              ),
              _FeatureItem(
                icon: Icons.payments_outlined,
                title: 'الدفع عند الاستلام',
                subtitle: 'نقداً',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // عنوان الأكثر طلباً
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'الأكثر طلباً',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            Text(
              'منتجات ${filteredProducts.length}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // شبكة منتجات الأكثر طلباً
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final item = filteredProducts[index];
            final qty = _cart[item.id] ?? 0;
            final isFav = _favorites.contains(item.id);

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
                  // صورة/أيقونة المنتج + شارة العروض
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              item.icon,
                              size: 46,
                              color: const Color(0xFF166534),
                            ),
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
                                item.badgeText,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF166534),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isFav) {
                                    _favorites.remove(item.id);
                                  } else {
                                    _favorites.add(item.id);
                                  }
                                });
                              },
                              child: Icon(
                                isFav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 18,
                                color: isFav
                                    ? Colors.red
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _iqd(item.wholesalePrice),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF166534),
                    ),
                  ),
                  Text(
                    'ربحك: +${_iqd(item.expectedProfit)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF15803D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  qty == 0
                      ? SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF166534),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => _addToCart(item.id),
                            child: const Text(
                              'أضف للسلة',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => _removeFromCart(item.id),
                              child: const Icon(Icons.remove_circle,
                                  size: 22, color: Colors.red),
                            ),
                            Text(
                              '$qty',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            InkWell(
                              onTap: () => _addToCart(item.id),
                              child: const Icon(Icons.add_circle,
                                  size: 22, color: Color(0xFF166534)),
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

  Widget _buildCategoriesTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text(
          'أقسام سوق الجملة',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._categories.where((c) => c != 'الكل').map((cat) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.category_rounded,
                  color: Color(0xFF166534)),
              title: Text(cat,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildCartTab() {
    if (_cart.isEmpty) {
      return const Center(
        child: Text(
          'السلة فارغة حالياً — أضف منتجات الجملة من الرئيسية',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    double total = 0;
    double profit = 0;
    _cart.forEach((id, qty) {
      final p = _products.firstWhere((item) => item.id == id);
      total += p.wholesalePrice * qty;
      profit += p.expectedProfit * qty;
    });

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text(
          'سلة المشتريات',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._cart.entries.map((entry) {
          final p = _products.firstWhere((item) => item.id == entry.key);
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: Text(p.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle:
                  Text('${entry.value} × ${_iqd(p.wholesalePrice)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.red),
                    onPressed: () => _removeFromCart(p.id),
                  ),
                  Text('${entry.value}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: Color(0xFF166534)),
                    onPressed: () => _addToCart(p.id),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
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
              Text(
                _iqd(profit),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF166534),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _checkout,
            child: Text(
              'إتمام الطلب (${_iqd(total)}) - الدفع عند الاستلام',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersTab() {
    if (_orders.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد طلبات مسجلة بعد',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final o = _orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text('طلب ${o.id}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${o.dateLabel} • ${o.status}'),
            trailing: Text(
              _iqd(o.total),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF166534),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountTab() {
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
              Text(
                widget.userName,
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('النشاط: ${widget.shopName}'),
              Text('نوع الحساب: ${widget.accountType}'),
              Text('رقم الهاتف: ${widget.phone}'),
              const Text('المنطقة: الناصرية'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.logout_rounded, color: Colors.red),
          label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF166534), size: 22),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}
