
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const SouqAlJumlaApp());
}

// ======================================================
// الهوية البصرية
// ======================================================

const Color navy = Color(0xFF102B35);
const Color navyLight = Color(0xFF183D47);
const Color emerald = Color(0xFF16836B);
const Color gold = Color(0xFFC6A66B);
const Color pageBg = Color(0xFFF4F6F4);
const Color ink = Color(0xFF172B32);
const Color muted = Color(0xFF829096);

class SouqAlJumlaApp extends StatelessWidget {
  const SouqAlJumlaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سوق الجملة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: pageBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: emerald,
          primary: emerald,
          secondary: gold,
          surface: Colors.white,
        ),
        fontFamily: 'Arial',
        appBarTheme: const AppBarTheme(
          backgroundColor: pageBg,
          foregroundColor: ink,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF3F6F5),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: const LoginScreen(),
    );
  }
}

// ======================================================
// نماذج البيانات
// ======================================================

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

// ======================================================
// أدوات واجهة
// ======================================================

Widget brandMark({double size = 48}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [emerald, navy],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: emerald.withOpacity(.18),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Icon(
      Icons.shopping_basket_rounded,
      color: Colors.white,
      size: size * .53,
    ),
  );
}

Widget sectionTitle(String title, {String? subtitle}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w900,
          color: ink,
        ),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: muted, fontSize: 12)),
      ],
    ],
  );
}

Widget primaryButton({
  required String title,
  required VoidCallback onPressed,
  IconData? icon,
}) {
  return SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.arrow_forward_rounded),
      label: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),
  );
}

String formatIQD(double value) {
  return '${value.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  )} د.ع';
}

// ======================================================
// شاشة تسجيل الدخول
// ======================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phone = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;

  void login() {
    if (phone.text.trim().isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رقم الهاتف وكلمة المرور')),
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
          phone: phone.text.trim(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [navy, navyLight, Color(0xFF22584F)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(19),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.09),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        brandMark(size: 76),
                        const SizedBox(height: 17),
                        const Text(
                          'سوق الجملة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 31,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'من الجملة إلى السوق',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          height: 2,
                          width: 65,
                          color: gold,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'منصة تجمع تجار الجملة وأصحاب الأسواق في مكان واحد',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(21),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'مرحباً بعودتك',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'سجّل الدخول إلى حسابك',
                          style: TextStyle(color: muted),
                        ),
                        const SizedBox(height: 22),
                        TextField(
                          controller: phone,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'رقم الهاتف العراقي',
                            prefixIcon: Icon(Icons.phone_android, color: emerald),
                          ),
                        ),
                        const SizedBox(height: 13),
                        TextField(
                          controller: password,
                          obscureText: obscure,
                          decoration: InputDecoration(
                            hintText: 'كلمة المرور',
                            prefixIcon: const Icon(Icons.lock_outline, color: emerald),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => obscure = !obscure),
                              icon: Icon(
                                obscure ? Icons.visibility : Icons.visibility_off,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        primaryButton(
                          title: 'تسجيل الدخول',
                          onPressed: login,
                          icon: Icons.login_rounded,
                        ),
                        const SizedBox(height: 10),
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
                            child: const Text(
                              'ليس لديك حساب؟ أنشئ حساباً جديداً',
                              style: TextStyle(
                                color: emerald,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'التوصيل متاح داخل الناصرية حالياً',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
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

// ======================================================
// إنشاء حساب
// ======================================================

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final shop = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();

  String accountType = 'صاحب سوق';
  LatLng? shopLocation;
  String shopAddress = '';
  bool obscure = true;

  Future<void> chooseLocation() async {
    final result = await Navigator.push<MapPickerResult>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initialLocation: shopLocation,
          initialAddress: shopAddress,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        shopLocation = result.location;
        shopAddress = result.address;
      });
    }
  }

  void submit() {
    if (name.text.trim().isEmpty ||
        phone.text.trim().isEmpty ||
        password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إكمال الاسم والهاتف وكلمة المرور')),
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => HomeShellScreen(
          userName: name.text.trim(),
          shopName: shop.text.trim().isEmpty ? 'نشاط تجاري' : shop.text.trim(),
          accountType: accountType,
          phone: phone.text.trim(),
          initialLocation: shopLocation,
          initialAddress: shopAddress,
        ),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    name.dispose();
    shop.dispose();
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          brandMark(size: 58),
          const SizedBox(height: 15),
          sectionTitle('انضم إلى سوق الجملة', subtitle: 'أنشئ حسابك وابدأ التعامل'),
          const SizedBox(height: 22),
          TextField(
            controller: name,
            decoration: const InputDecoration(
              hintText: 'الاسم الكامل',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: shop,
            decoration: const InputDecoration(
              hintText: 'اسم المحل أو النشاط التجاري',
              prefixIcon: Icon(Icons.storefront_outlined),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: accountType,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'صاحب سوق', child: Text('صاحب سوق')),
              DropdownMenuItem(value: 'تاجر جملة', child: Text('تاجر جملة')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => accountType = v);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'رقم الهاتف العراقي',
              prefixIcon: Icon(Icons.phone_android),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: password,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: 'كلمة المرور',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () => setState(() => obscure = !obscure),
                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: const Color(0xFFE1E8E4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on, color: emerald),
                    SizedBox(width: 8),
                    Text(
                      'عنوان المحل على الخريطة',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  shopAddress.isEmpty ? 'لم يتم تحديد عنوان المحل بعد' : shopAddress,
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: chooseLocation,
                  icon: const Icon(Icons.map_outlined),
                  label: Text(
                    shopLocation == null ? 'حدد موقع محلك على الخريطة' : 'تعديل موقع المحل',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          primaryButton(title: 'إنشاء الحساب', onPressed: submit),
        ],
      ),
    );
  }
}

// ======================================================
// نتيجة تحديد الموقع
// ======================================================

class MapPickerResult {
  final LatLng location;
  final String address;

  MapPickerResult(this.location, this.address);
}

// ======================================================
// خريطة تحديد عنوان المحل
// ======================================================

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;
  final String initialAddress;

  const MapPickerScreen({
    super.key,
    this.initialLocation,
    this.initialAddress = '',
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng selectedLocation;
  late final MapController mapController;
  final addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.initialLocation ??
        const LatLng(31.0578, 46.2573);
    addressController.text = widget.initialAddress;
    mapController = MapController();
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  void confirm() {
    final address = addressController.text.trim().isEmpty
        ? 'موقع المحل المحدد على الخريطة'
        : addressController.text.trim();

    Navigator.pop(
      context,
      MapPickerResult(selectedLocation, address),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حدد عنوان محلك'),
        actions: [
          IconButton(
            onPressed: () => mapController.move(
              const LatLng(31.0578, 46.2573),
              14,
            ),
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: selectedLocation,
              initialZoom: 14,
              onTap: (tapPosition, point) {
                setState(() => selectedLocation = point);
              },
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && position.center != null) {
                  setState(() => selectedLocation = position.center!);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.souq.aljumla.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: selectedLocation,
                    width: 55,
                    height: 60,
                    child: const Icon(
                      Icons.location_pin,
                      color: Color(0xFFD94B43),
                      size: 50,
                    ),
                  ),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          Positioned(
            top: 15,
            right: 15,
            left: 15,
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.1),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.touch_app, color: emerald),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'اضغط على الخريطة لتحديد موقع محلك بدقة',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 15,
            left: 15,
            bottom: 18,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.12),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تفاصيل عنوان المحل',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      hintText: 'مثلاً: الناصرية، شارع الحبوبي...',
                      prefixIcon: Icon(Icons.edit_location_alt_outlined),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'الإحداثيات: ${selectedLocation.latitude.toStringAsFixed(6)}, ${selectedLocation.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 10, color: muted),
                  ),
                  const SizedBox(height: 12),
                  primaryButton(
                    title: 'تأكيد موقع المحل',
                    onPressed: confirm,
                    icon: Icons.check_circle_outline,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// التطبيق الرئيسي والتنقل
// ======================================================

class HomeShellScreen extends StatefulWidget {
  final String userName;
  final String shopName;
  final String accountType;
  final String phone;
  final LatLng? initialLocation;
  final String initialAddress;

  const HomeShellScreen({
    super.key,
    required this.userName,
    required this.shopName,
    required this.accountType,
    required this.phone,
    this.initialLocation,
    this.initialAddress = '',
  });

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int navIndex = 0;
  String selectedCategory = 'الكل';
  String searchQuery = '';

  LatLng? shopLocation;
  String shopAddress = '';

  final Set<String> favorites = {};
  final Map<String, int> cart = {};
  final List<OrderRecord> orders = [];

  final categories = [
    'الكل',
    'مواد غذائية',
    'مشروبات',
    'ألبان وأجبان',
    'منظفات',
  ];

  final products = <ProductItem>[
    ProductItem(
      id: '1',
      name: 'أرز بسمتي فاخر - كيس 30 كغم',
      category: 'مواد غذائية',
      badgeText: 'عرض مميز',
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
      badgeText: 'الأكثر طلباً',
      itemsPerCarton: 24,
      wholesalePrice: 12000,
      suggestedRetailPrice: 750,
      merchantName: 'مخازن الفرات',
      icon: Icons.grain_rounded,
    ),
    ProductItem(
      id: '3',
      name: 'زيت طعام نقي - كرتون 12 عبوة',
      category: 'مواد غذائية',
      badgeText: 'سعر خاص',
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
      badgeText: 'عرض',
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
      badgeText: 'طازج',
      itemsPerCarton: 18,
      wholesalePrice: 54000,
      suggestedRetailPrice: 3750,
      merchantName: 'مخازن الفرات',
      icon: Icons.egg_alt_rounded,
    ),
    ProductItem(
      id: '6',
      name: 'منظفات ومطهرات - كرتون 12 عبوة',
      category: 'منظفات',
      badgeText: 'عرض',
      itemsPerCarton: 12,
      wholesalePrice: 42000,
      suggestedRetailPrice: 4500,
      merchantName: 'توزيع الجنوب',
      icon: Icons.cleaning_services_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    shopLocation = widget.initialLocation;
    shopAddress = widget.initialAddress;
  }

  void addToCart(String id) {
    setState(() => cart[id] = (cart[id] ?? 0) + 1);
  }

  void removeFromCart(String id) {
    setState(() {
      if ((cart[id] ?? 0) > 1) {
        cart[id] = cart[id]! - 1;
      } else {
        cart.remove(id);
      }
    });
  }

  void checkout() {
    if (cart.isEmpty) return;

    double total = 0;
    cart.forEach((id, qty) {
      final p = products.firstWhere((e) => e.id == id);
      total += p.wholesalePrice * qty;
    });

    setState(() {
      orders.insert(
        0,
        OrderRecord(
          id: 'ORD-${101 + orders.length}',
          dateLabel: 'اليوم • الدفع عند الاستلام',
          total: total,
          status: 'قيد التجهيز',
        ),
      );
      cart.clear();
      navIndex = 3;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تسجيل الطلب بنجاح'),
        backgroundColor: emerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = cart.values.fold(0, (a, b) => a + b);

    final filteredProducts = products.where((p) {
      final cat = selectedCategory == 'الكل' ||
          p.category == selectedCategory;
      final search = searchQuery.isEmpty ||
          p.name.contains(searchQuery) ||
          p.merchantName.contains(searchQuery);
      return cat && search;
    }).toList();

    final pages = [
      _homeTab(filteredProducts),
      _categoriesTab(),
      _cartTab(),
      _ordersTab(),
      _accountTab(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: navIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: navIndex,
          backgroundColor: Colors.white,
          indicatorColor: emerald.withOpacity(.12),
          onDestinationSelected: (i) => setState(() => navIndex = i),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'الرئيسية',
            ),
            const NavigationDestination(
              icon: Icon(Icons.grid_view_rounded),
              label: 'الأقسام',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              label: 'السلة',
            ),
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              label: 'طلباتي',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }

  // ====================================================
  // الرئيسية
  // ====================================================

  Widget _homeTab(List<ProductItem> filteredProducts) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 25),
      children: [
        Row(
          children: [
            brandMark(),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'سوق الجملة',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 19,
                      color: navy,
                    ),
                  ),
                  Text(
                    'من الجملة إلى السوق',
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('لا توجد إشعارات جديدة')),
                );
              },
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            IconButton(
              onPressed: () => setState(() => navIndex = 4),
              icon: const Icon(Icons.person_outline_rounded),
            ),
          ],
        ),
        const SizedBox(height: 17),
        InkWell(
          onTap: () => setState(() => navIndex = 4),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE5EBE8)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: emerald),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    shopAddress.isEmpty
                        ? 'التوصيل إلى الناصرية'
                        : shopAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: muted),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          onChanged: (v) => setState(() => searchQuery = v.trim()),
          decoration: const InputDecoration(
            hintText: 'ابحث عن منتج أو تاجر أو صنف...',
            prefixIcon: Icon(Icons.search_rounded, color: emerald),
          ),
        ),
        const SizedBox(height: 17),
        SizedBox(
          height: 94,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final active = selectedCategory == cat;

              final icon = switch (cat) {
                'الكل' => Icons.apps_rounded,
                'مواد غذائية' => Icons.shopping_basket_outlined,
                'مشروبات' => Icons.local_drink_outlined,
                'ألبان وأجبان' => Icons.egg_alt_outlined,
                _ => Icons.cleaning_services_outlined,
              };

              return GestureDetector(
                onTap: () => setState(() => selectedCategory = cat),
                child: Container(
                  width: 75,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: active ? navy : Colors.white,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: active ? navy : const Color(0xFFE5EBE8),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: active ? gold : emerald,
                        size: 25,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        cat,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 10,
                          color: active ? Colors.white : ink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 17),
        Container(
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [navy, Color(0xFF20594F)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(23),
            boxShadow: [
              BoxShadow(
                color: navy.withOpacity(.16),
                blurRadius: 15,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: -10,
                bottom: -20,
                child: Icon(
                  Icons.shopping_basket_rounded,
                  size: 115,
                  color: Colors.white.withOpacity(.07),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'سوق الجملة • الناصرية',
                    style: TextStyle(color: gold, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'اشتري بسعر الجملة\nواربح أكثر',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 25,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    'قارن عروض التجار واختر السعر الأنسب لمتجرك',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: gold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'تسوّق الآن',
                      style: TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _FeatureItem(
                icon: Icons.local_shipping_outlined,
                title: 'توصيل',
                subtitle: 'إلى محلك',
              ),
              _FeatureItem(
                icon: Icons.compare_arrows_rounded,
                title: 'مقارنة',
                subtitle: 'بين الأسعار',
              ),
              _FeatureItem(
                icon: Icons.payments_outlined,
                title: 'دفع',
                subtitle: 'عند الاستلام',
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            sectionTitle('منتجات الجملة'),
            Text(
              '${filteredProducts.length} منتج',
              style: const TextStyle(color: muted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (filteredProducts.isEmpty)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: Text('لا توجد منتجات مطابقة للبحث')),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: .66,
            ),
            itemBuilder: (context, index) {
              final p = filteredProducts[index];
              final qty = cart[p.id] ?? 0;
              final fav = favorites.contains(p.id);

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: const Color(0xFFE8EDEA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEAF2EF), Color(0xFFF7F8F6)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                p.icon,
                                color: emerald,
                                size: 54,
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: gold,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  p.badgeText,
                                  style: const TextStyle(
                                    color: navy,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 3,
                              left: 3,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (fav) {
                                      favorites.remove(p.id);
                                    } else {
                                      favorites.add(p.id);
                                    }
                                  });
                                },
                                icon: Icon(
                                  fav ? Icons.favorite : Icons.favorite_border,
                                  color: fav ? Colors.red : muted,
                                  size: 19,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      p.merchantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: muted, fontSize: 9),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatIQD(p.wholesalePrice),
                      style: const TextStyle(
                        color: emerald,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'ربح متوقع: ${formatIQD(p.expectedProfit)}',
                      maxLines: 1,
                      style: const TextStyle(
                        color: emerald,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (qty == 0)
                      SizedBox(
                        height: 34,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => addToCart(p.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navy,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'أضف للسلة',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            onPressed: () => removeFromCart(p.id),
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            visualDensity: VisualDensity.compact,
                          ),
                          Text(
                            '$qty',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () => addToCart(p.id),
                            icon: const Icon(Icons.add_circle, color: emerald),
                            visualDensity: VisualDensity.compact,
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

  // ====================================================
  // الأقسام
  // ====================================================

  Widget _categoriesTab() {
    final icons = [
      Icons.shopping_basket_outlined,
      Icons.local_drink_outlined,
      Icons.egg_alt_outlined,
      Icons.cleaning_services_outlined,
    ];

    return ListView(
      padding: const EdgeInsets.all(17),
      children: [
        sectionTitle('أقسام سوق الجملة', subtitle: 'اختر القسم الذي تبحث عنه'),
        const SizedBox(height: 18),
        ...List.generate(categories.length - 1, (index) {
          final cat = categories[index + 1];
          final count = products.where((p) => p.category == cat).length;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(13),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: emerald.withOpacity(.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icons[index], color: emerald),
              ),
              title: Text(
                cat,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('$count منتجات'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 15),
              onTap: () {
                setState(() {
                  selectedCategory = cat;
                  navIndex = 0;
                });
              },
            ),
          );
        }),
      ],
    );
  }

  // ====================================================
  // السلة
  // ====================================================

  Widget _cartTab() {
    if (cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            brandMark(size: 75),
            const SizedBox(height: 18),
            const Text(
              'سلتك فارغة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 7),
            const Text(
              'ابدأ بإضافة منتجات الجملة إلى سلتك',
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () => setState(() => navIndex = 0),
              child: const Text('تصفح المنتجات'),
            ),
          ],
        ),
      );
    }

    double total = 0;
    double profit = 0;

    cart.forEach((id, qty) {
      final p = products.firstWhere((e) => e.id == id);
      total += p.wholesalePrice * qty;
      profit += p.expectedProfit * qty;
    });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        sectionTitle('سلة المشتريات', subtitle: 'راجع منتجاتك قبل إتمام الطلب'),
        const SizedBox(height: 15),
        ...cart.entries.map((entry) {
          final p = products.firstWhere((e) => e.id == entry.key);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2EF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(p.icon, color: emerald, size: 30),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        maxLines: 2,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        formatIQD(p.wholesalePrice),
                        style: const TextStyle(
                          color: emerald,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => removeFromCart(p.id),
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                ),
                Text('${entry.value}'),
                IconButton(
                  onPressed: () => addToCart(p.id),
                  icon: const Icon(Icons.add_circle_outline, color: emerald),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: navy,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            children: [
              _summaryRow('المجموع', formatIQD(total), Colors.white),
              const SizedBox(height: 10),
              _summaryRow('الربح المتوقع', formatIQD(profit), gold),
            ],
          ),
        ),
        const SizedBox(height: 16),
        primaryButton(
          title: 'إتمام الطلب • ${formatIQD(total)}',
          onPressed: checkout,
          icon: Icons.shopping_bag_rounded,
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'الدفع نقداً عند الاستلام',
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  // ====================================================
  // الطلبات
  // ====================================================

  Widget _ordersTab() {
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 65, color: muted),
            SizedBox(height: 12),
            Text(
              'لا توجد طلبات حتى الآن',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text('ستظهر طلباتك هنا بعد إتمام الشراء',
                style: TextStyle(color: muted, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        sectionTitle('طلباتي', subtitle: 'تابع حالة مشترياتك'),
        const SizedBox(height: 15),
        ...orders.map((o) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      o.id,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: navy,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: gold.withOpacity(.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        o.status,
                        style: const TextStyle(
                          color: navy,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 22),
                Text(o.dateLabel, style: const TextStyle(color: muted)),
                const SizedBox(height: 9),
                Text(
                  formatIQD(o.total),
                  style: const TextStyle(
                    color: emerald,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ====================================================
  // الحساب والعنوان
  // ====================================================

  Future<void> editShopLocation() async {
    final result = await Navigator.push<MapPickerResult>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initialLocation: shopLocation,
          initialAddress: shopAddress,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        shopLocation = result.location;
        shopAddress = result.address;
      });
    }
  }

  Widget _accountTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [navy, navyLight],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 29,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 34, color: Colors.white),
              ),
              const SizedBox(height: 13),
              Text(
                widget.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.shopName,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.accountType,
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        sectionTitle('بيانات الحساب'),
        const SizedBox(height: 10),
        _accountTile(Icons.phone_android, 'رقم الهاتف', widget.phone),
        _accountTile(Icons.storefront_outlined, 'اسم النشاط', widget.shopName),
        _accountTile(Icons.badge_outlined, 'نوع الحساب', widget.accountType),
        const SizedBox(height: 15),
        sectionTitle('عنوان المحل'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on, color: emerald),
                  SizedBox(width: 8),
                  Text(
                    'موقع نشاطك التجاري',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                shopAddress.isEmpty
                    ? 'لم تحدد موقع محلك بعد'
                    : shopAddress,
                style: const TextStyle(color: muted, fontSize: 12),
              ),
              if (shopLocation != null) ...[
                const SizedBox(height: 5),
                Text(
                  '${shopLocation!.latitude.toStringAsFixed(6)}, ${shopLocation!.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 10, color: muted),
                ),
              ],
              const SizedBox(height: 13),
              OutlinedButton.icon(
                onPressed: editShopLocation,
                icon: const Icon(Icons.map_outlined),
                label: Text(
                  shopLocation == null
                      ? 'حدد عنوان محلك على الخريطة'
                      : 'تعديل عنوان المحل',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text(
            'تسجيل الخروج',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 49),
            side: const BorderSide(color: Color(0xFFF0D7D7)),
          ),
        ),
      ],
    );
  }

  Widget _accountTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: emerald),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(color: muted)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// عناصر المزايا
// ======================================================

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
        Icon(icon, color: emerald, size: 25),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: ink,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 10, color: muted),
        ),
      ],
    );
  }
}
