import 'package:flutter/material.dart';

void main() {
  runApp(const JumlaMarketApp());
}

class JumlaMarketApp extends StatelessWidget {
  const JumlaMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سوق الجملة للمواد الغذائية',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0F2C59),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F2C59),
          primary: const Color(0xFF0F2C59),
          secondary: const Color(0xFF2E8B57),
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const MainNavigationScreen(),
    );
  }
}

// ==========================================
// 1. نماذج البيانات (Data Models)
// ==========================================
class Product {
  final String id;
  final String name;
  final String category;
  final String unitDetails;
  final int itemsPerCarton;
  final double wholesalePrice;
  final double suggestedRetailPrice;
  int stock;
  final IconData icon;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.unitDetails,
    required this.itemsPerCarton,
    required this.wholesalePrice,
    required this.suggestedRetailPrice,
    required this.stock,
    required this.icon,
  });

  double get unitWholesalePrice => wholesalePrice / itemsPerCarton;
  double get expectedCartonProfit =>
      (suggestedRetailPrice * itemsPerCarton) - wholesalePrice;
  double get profitMarginPercent =>
      (expectedCartonProfit / wholesalePrice) * 100;
}

class OrderItem {
  final Product product;
  int quantity;

  OrderItem({required this.product, required this.quantity});

  double get totalPrice => product.wholesalePrice * quantity;
  double get totalProfit => product.expectedCartonProfit * quantity;
}

class WholesaleOrder {
  final String orderId;
  final String marketName;
  final List<OrderItem> items;
  final double totalAmount;
  final String deliveryType;
  final String notes;
  String status;
  final DateTime createdAt;

  WholesaleOrder({
    required this.orderId,
    required this.marketName,
    required this.items,
    required this.totalAmount,
    required this.deliveryType,
    required this.notes,
    this.status = 'قيد التجهيز',
    required this.createdAt,
  });
}

// ==========================================
// 2. الشاشة الرئيسية (التبديل بين المشتري والتاجر)
// ==========================================
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  bool isMerchantMode = false; // false = صاحب السوق, true = تاجر الجملة
  int _selectedIndex = 0;

  final List<Product> _products = [
    Product(
      id: 'P1',
      name: 'زيت عافية - كرتون (12 عبوة)',
      category: 'زيوت',
      unitDetails: 'العبوة: 1 لتر | العدد: 12',
      itemsPerCarton: 12,
      wholesalePrice: 96000,
      suggestedRetailPrice: 9500,
      stock: 50,
      icon: Icons.water_drop_rounded,
    ),
    Product(
      id: 'P2',
      name: 'شاي الفاخر - كرتون (24 علبة)',
      category: 'مشروبات',
      unitDetails: 'العلبة: 500 غم | العدد: 24',
      itemsPerCarton: 24,
      wholesalePrice: 120000,
      suggestedRetailPrice: 6000,
      stock: 35,
      icon: Icons.local_cafe_rounded,
    ),
    Product(
      id: 'P3',
      name: 'أرز بسمتي درجة أولى - كيس 30 كغم',
      category: 'بقوليات',
      unitDetails: 'الوزن الصافي: 30 كغم',
      itemsPerCarton: 30,
      wholesalePrice: 48000,
      suggestedRetailPrice: 2000,
      stock: 80,
      icon: Icons.rice_bowl_rounded,
    ),
    Product(
      id: 'P4',
      name: 'معجون طماطم - كرتون (24 علبة)',
      category: 'معلبات',
      unitDetails: 'العلبة: 800 غم | العدد: 24',
      itemsPerCarton: 24,
      wholesalePrice: 36000,
      suggestedRetailPrice: 2000,
      stock: 14,
      icon: Icons.inventory_2_rounded,
    ),
  ];

  final Map<String, int> _cart = {};
  final List<WholesaleOrder> _orders = [
    WholesaleOrder(
      orderId: '#1045',
      marketName: 'أسواق البركة - المنصورية',
      items: [],
      totalAmount: 1250000,
      deliveryType: 'غداً صباحاً (مجاني)',
      notes: 'يرجى التأكد من تاريخ الإنتاج الجديد',
      status: 'قيد التجهيز',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

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

  void _placeOrder(String deliveryType, String notes) {
    if (_cart.isEmpty) return;

    List<OrderItem> orderItems = [];
    double total = 0;

    _cart.forEach((productId, qty) {
      final prod = _products.firstWhere((p) => p.id == productId);
      orderItems.add(OrderItem(product: prod, quantity: qty));
      total += prod.wholesalePrice * qty;
      prod.stock = (prod.stock - qty).clamp(0, 9999);
    });

    setState(() {
      _orders.insert(
        0,
        WholesaleOrder(
          orderId: '#${1046 + _orders.length}',
          marketName: 'سوق أحمد للمواد الغذائية',
          items: orderItems,
          totalAmount: total,
          deliveryType: deliveryType,
          notes: notes,
          status: 'قيد التجهيز',
          createdAt: DateTime.now(),
        ),
      );
      _cart.clear();
      _selectedIndex = 1; // الانتقال إلى تبويب الطلبات
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إرسال طلب الجملة بنجاح!'),
        backgroundColor: Color(0xFF2E8B57),
      ),
    );
  }

  String _formatIQD(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} IQD';
  }

  @override
  Widget build(BuildContext context) {
    final int totalCartItems =
        _cart.values.fold(0, (sum, count) => sum + count);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2C59),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMerchantMode
                  ? 'لوحة تحكم تاجر الجملة'
                  : 'سوق الجملة - مرحباً أحمد',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              isMerchantMode
                  ? 'إدارة المبيعات والمخزون والطلبات'
                  : 'توصيل مباشر للمحلات والأسواق',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  isMerchantMode = !isMerchantMode;
                  _selectedIndex = 0;
                });
              },
              child: Row(
                children: [
                  Icon(
                    isMerchantMode ? Icons.storefront : Icons.warehouse_rounded,
                    size: 16,
                    color: Colors.amberAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isMerchantMode ? 'وضع السوق' : 'وضع التاجر',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: isMerchantMode
          ? MerchantDashboardView(
              products: _products,
              orders: _orders,
              formatIQD: _formatIQD,
              onUpdateStatus: (order, newStatus) {
                setState(() {
                  order.status = newStatus;
                });
              },
              onAddProduct: (newProduct) {
                setState(() {
                  _products.insert(0, newProduct);
                });
              },
            )
          : _selectedIndex == 0
              ? MarketCatalogView(
                  products: _products,
                  cart: _cart,
                  formatIQD: _formatIQD,
                  onAdd: _addToCart,
                  onRemove: _removeFromCart,
                  onOpenCart: () => _showCartBottomSheet(context),
                )
              : MarketOrdersView(
                  orders: _orders,
                  formatIQD: _formatIQD,
                ),
      floatingActionButton: (!isMerchantMode && totalCartItems > 0)
          ? FloatingActionButton.extended(
              onPressed: () => _showCartBottomSheet(context),
              backgroundColor: const Color(0xFF2E8B57),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.shopping_cart_checkout),
              label: Text('السلة ($totalCartItems كرتون)'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF0F2C59),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: isMerchantMode
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  label: 'لوحة المبيعات والطلبات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_rounded),
                  label: 'المخزون والأسعار',
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.store_rounded),
                  label: 'تسوق الجملة',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_rounded),
                  label: 'طلباتي',
                ),
              ],
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    String selectedDelivery = 'غداً صباحاً (مجاني)';
    final TextEditingController notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            double totalWholesale = 0;
            double totalExpectedProfit = 0;

            _cart.forEach((id, qty) {
              final prod = _products.firstWhere((p) => p.id == id);
              totalWholesale += prod.wholesalePrice * qty;
              totalExpectedProfit += prod.expectedCartonProfit * qty;
            });

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'مراجعة طلب الجملة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ..._cart.entries.map((entry) {
                    final prod =
                        _products.firstWhere((p) => p.id == entry.key);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(prod.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          '${entry.value} × ${_formatIQD(prod.wholesalePrice)}'),
                      trailing: Text(
                        _formatIQD(prod.wholesalePrice * entry.value),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F2C59)),
                      ),
                    );
                  }),
                  const Divider(),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('صافي ربحك المتوقع عند البيع:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          _formatIQD(totalExpectedProfit),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E8B57),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedDelivery,
                    decoration: const InputDecoration(
                      labelText: 'خيار التوصيل',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'غداً صباحاً (مجاني)',
                        child: Text('غداً صباحاً (توصيل مجاني لأول 4 طلبات)'),
                      ),
                      DropdownMenuItem(
                        value: 'توصيل سريع خلال ساعتين (10,000 IQD)',
                        child: Text('توصيل سريع خلال ساعتين (10,000 IQD)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedDelivery = val);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات للتاجر (اختياري)',
                      hintText: 'مثال: يرجى التأكد من تاريخ الإنتاج...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F2C59),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _placeOrder(selectedDelivery, notesController.text);
                      },
                      child: Text(
                        'تأكيد الطلب (${_formatIQD(totalWholesale)})',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ==========================================
// 3. واجهة صاحب السوق (المشتري)
// ==========================================
class MarketCatalogView extends StatelessWidget {
  final List<Product> products;
  final Map<String, int> cart;
  final String Function(double) formatIQD;
  final Function(String) onAdd;
  final Function(String) onRemove;
  final VoidCallback onOpenCart;

  const MarketCatalogView({
    super.key,
    required this.products,
    required this.cart,
    required this.formatIQD,
    required this.onAdd,
    required this.onRemove,
    required this.onOpenCart,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // شريط العروض الترحيبية
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F2C59), Color(0xFF1E4D92)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.local_offer_rounded,
                  color: Colors.amberAccent, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عرض الترحيب لأصحاب الأسواق!',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    Text(
                      'توصيل مجاني لأول 4 طلبات + رصيد ترحيبي 25,000 دينار',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'أصناف الجملة المتوفرة اليوم',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...products.map((product) {
          final int qtyInCart = cart[product.id] ?? 0;

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F2C59).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(product.icon,
                            color: const Color(0xFF0F2C59), size: 30),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              product.unitDetails,
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 12),
                            ),
                            Text(
                              'متوفر بالمخزن: ${product.stock} كرتون',
                              style: TextStyle(
                                color: product.stock < 15
                                    ? Colors.red
                                    : Colors.green[700],
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatIQD(product.wholesalePrice),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F2C59),
                            ),
                          ),
                          Text(
                            'سعر القطعة بالجملة: ${formatIQD(product.unitWholesalePrice)}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'ربحك: +${formatIQD(product.expectedCartonProfit)}',
                              style: const TextStyle(
                                color: Color(0xFF2E8B57),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'هامش ربح ${product.profitMarginPercent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Color(0xFF2E8B57),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  qtyInCart == 0
                      ? SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E8B57),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => onAdd(product.id),
                            icon: const Icon(Icons.add_shopping_cart, size: 18),
                            label: const Text('أضف للسلة (1 كرتون)'),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => onRemove(product.id),
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                ),
                                Text(
                                  '$qtyInCart كرتون',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                IconButton(
                                  onPressed: () => onAdd(product.id),
                                  icon: const Icon(Icons.add_circle,
                                      color: Color(0xFF2E8B57)),
                                ),
                              ],
                            ),
                            Text(
                              'المجموع: ${formatIQD(product.wholesalePrice * qtyInCart)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
}

// ==========================================
// 4. شاشة تتبع الطلبات لصاحب السوق
// ==========================================
class MarketOrdersView extends StatelessWidget {
  final List<WholesaleOrder> orders;
  final String Function(double) formatIQD;

  const MarketOrdersView({
    super.key,
    required this.orders,
    required this.formatIQD,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'طلب ${order.orderId}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: order.status == 'تم التسليم'
                            ? Colors.green.withOpacity(0.15)
                            : Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status,
                        style: TextStyle(
                          color: order.status == 'تم التسليم'
                              ? Colors.green[800]
                              : Colors.orange[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('التوصيل: ${order.deliveryType}',
                    style: const TextStyle(fontSize: 13)),
                if (order.notes.isNotEmpty)
                  Text('ملاحظات: ${order.notes}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('إجمالي الفاتورة:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      formatIQD(order.totalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF0F2C59),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// 5. لوحة تحكم تاجر الجملة (المورد)
// ==========================================
class MerchantDashboardView extends StatelessWidget {
  final List<Product> products;
  final List<WholesaleOrder> orders;
  final String Function(double) formatIQD;
  final Function(WholesaleOrder, String) onUpdateStatus;
  final Function(Product) onAddProduct;

  const MerchantDashboardView({
    super.key,
    required this.products,
    required this.orders,
    required this.formatIQD,
    required this.onUpdateStatus,
    required this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    final double totalSales =
        orders.fold(0, (sum, order) => sum + order.totalAmount);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // ملخص الأداء اليومي
        Row(
          children: [
            Expanded(
              child: _statCard(
                'إجمالي المبيعات',
                formatIQD(totalSales),
                Icons.payments_rounded,
                const Color(0xFF0F2C59),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                'الطلبات النشطة',
                '${orders.length} طلب',
                Icons.local_shipping_rounded,
                const Color(0xFF2E8B57),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'الطلبات الواردة من أصحاب الأسواق',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...orders.map((order) {
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
                      Text('${order.orderId} - ${order.marketName}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(formatIQD(order.totalAmount),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E8B57))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('موعد التوصيل: ${order.deliveryType}',
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الحالة الحالية: ${order.status}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 12)),
                      DropdownButton<String>(
                        value: order.status,
                        items: const [
                          DropdownMenuItem(
                              value: 'قيد التجهيز', child: Text('قيد التجهيز')),
                          DropdownMenuItem(
                              value: 'خرج للتوصيل', child: Text('خرج للتوصيل')),
                          DropdownMenuItem(
                              value: 'تم التسليم', child: Text('تم التسليم')),
                        ],
                        onChanged: (val) {
                          if (val != null) onUpdateStatus(order, val);
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

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
