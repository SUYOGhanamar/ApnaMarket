import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ApnaMarketApp());
}

// ============= THEME & COLORS =============
class AppColors {
  static const primary = Color(0xFF3B7C93); // Green for fresh/organic feel
  static const primaryLight = Color(0xFF39A3A6);
  static const primaryDark = Color(0xFF1B5E20);
  static const secondary = Color(0xFFFF6F00);
  static const secondaryLight = Color(0xFFFF9800);
  static const accent = Color(0xFFFFC107);
  static const background = Color(0xFFF5F5F5);
  static const cardBg = Colors.white;
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const error = Color(0xFFD32F2F);
  static const success = Color(0xFF388E3C);
  static const warning = Color(0xFFF57C00);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.cardBg,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}

// ============= MODELS =============
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final bool isSeller;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.isSeller = false,
    this.isVerified = false,
  });
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String sellerId;
  final String sellerName;
  final String imageUrl;
  final bool isRental;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final bool isFoodItem;
  final bool hasFSSAI;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.sellerId,
    required this.sellerName,
    required this.imageUrl,
    this.isRental = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
    this.isFoodItem = false,
    this.hasFSSAI = false,
  });
}

class Order {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final String status;
  final DateTime orderDate;
  final String buyerId;
  final String sellerId;

  Order({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.status,
    required this.orderDate,
    required this.buyerId,
    required this.sellerId,
  });
}

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  double get total => product.price * quantity;
}

// ============= STATE MANAGEMENT =============
class AppState extends ChangeNotifier {
  User? _currentUser;
  List<Product> _products = [];
  List<Product> _wishlist = [];
  List<Order> _orders = [];
  List<CartItem> _cart = [];
  int _currentIndex = 0;

  User? get currentUser => _currentUser;
  List<Product> get products => _products;
  List<Product> get wishlist => _wishlist;
  List<Order> get orders => _orders;
  List<CartItem> get cart => _cart;
  int get currentIndex => _currentIndex;
  bool get isLoggedIn => _currentUser != null;

  double get cartTotal {
    return _cart.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  int get cartItemCount {
    return _cart.fold(0, (sum, item) => sum + item.quantity);
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void login(User user) {
    _currentUser = user;
    _loadMockData();
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _products = [];
    _wishlist = [];
    _orders = [];
    notifyListeners();
  }

  void toggleWishlist(Product product) {
    if (_wishlist.any((p) => p.id == product.id)) {
      _wishlist.removeWhere((p) => p.id == product.id);
    } else {
      _wishlist.add(product);
    }
    notifyListeners();
  }

  bool isInWishlist(String productId) {
    return _wishlist.any((p) => p.id == productId);
  }

  void addOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _cart[existingIndex] = CartItem(
        product: _cart[existingIndex].product,
        quantity: _cart[existingIndex].quantity + quantity,
      );
    } else {
      _cart.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateCartQuantity(String productId, int quantity) {
    final index = _cart.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index] = CartItem(
          product: _cart[index].product,
          quantity: quantity,
        );
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart = [];
    notifyListeners();
  }

  void _loadMockData() {
    _products = [
      // ========== HOMEMAKER PRODUCTS - HOMEMADE FOOD ==========
      Product(
        id: '1',
        name: 'Traditional Mango Pickle (500g)',
        description: 'Authentic homemade mango pickle made with traditional recipe and fresh spices',
        price: 199.0,
        category: 'Homemade Food',
        sellerId: 'seller1',
        sellerName: 'Amma\'s Kitchen',
        imageUrl: 'https://images.unsplash.com/photo-1623428187969-5da2dcea5ebf?w=500',
        rating: 4.8,
        reviewCount: 234,
        isFoodItem: true,
        hasFSSAI: true,
      ),
      Product(
        id: '2',
        name: 'Crispy Rice Papad (200g)',
        description: 'Handmade crispy papads, sun-dried and preservative-free',
        price: 120.0,
        category: 'Homemade Food',
        sellerId: 'seller2',
        sellerName: 'Lakshmi Homemade',
        imageUrl: 'https://images.unsplash.com/photo-1626082910578-9fe5f2d0c6e6?w=500',
        rating: 4.6,
        reviewCount: 189,
        isFoodItem: true,
        hasFSSAI: true,
      ),
      Product(
        id: '3',
        name: 'Besan Ladoo (500g)',
        description: 'Fresh homemade besan laddoos made with pure ghee and love',
        price: 280.0,
        category: 'Homemade Food',
        sellerId: 'seller1',
        sellerName: 'Amma\'s Kitchen',
        imageUrl: 'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=500',
        rating: 4.9,
        reviewCount: 312,
        isFoodItem: true,
        hasFSSAI: true,
      ),
      Product(
        id: '4',
        name: 'Chakli & Murukku Mix (300g)',
        description: 'Crispy traditional snacks perfect for tea time',
        price: 150.0,
        category: 'Homemade Food',
        sellerId: 'seller3',
        sellerName: 'Savory Delights',
        imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500',
        rating: 4.7,
        reviewCount: 178,
        isFoodItem: true,
        hasFSSAI: true,
      ),
      Product(
        id: '5',
        name: 'Home Baked Cookies (250g)',
        description: 'Freshly baked butter cookies with no preservatives',
        price: 180.0,
        category: 'Homemade Food',
        sellerId: 'seller4',
        sellerName: 'Baker\'s Paradise',
        imageUrl: 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=500',
        rating: 4.8,
        reviewCount: 256,
        isFoodItem: true,
        hasFSSAI: true,
      ),
      Product(
        id: '6',
        name: 'Homemade Garam Masala (100g)',
        description: 'Freshly ground garam masala with traditional spices',
        price: 85.0,
        category: 'Homemade Food',
        sellerId: 'seller1',
        sellerName: 'Amma\'s Kitchen',
        imageUrl: 'https://images.unsplash.com/photo-1596040033229-a0b00b1c0c77?w=500',
        rating: 4.9,
        reviewCount: 334,
        isFoodItem: true,
        hasFSSAI: true,
      ),

      // ========== HOMEMAKER PRODUCTS - HANDMADE ITEMS ==========
      Product(
        id: '7',
        name: 'Handcrafted Terracotta Jewelry Set',
        description: 'Beautiful handmade terracotta necklace and earrings set',
        price: 450.0,
        category: 'Handmade Items',
        sellerId: 'seller5',
        sellerName: 'Priya Crafts',
        imageUrl: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=500',
        rating: 4.7,
        reviewCount: 156,
      ),
      Product(
        id: '8',
        name: 'Hand-Painted Clay Pots (Set of 3)',
        description: 'Colorful hand-painted decorative pots for plants',
        price: 550.0,
        category: 'Handmade Items',
        sellerId: 'seller5',
        sellerName: 'Priya Crafts',
        imageUrl: 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=500',
        rating: 4.8,
        reviewCount: 98,
      ),
      Product(
        id: '9',
        name: 'Handmade Scented Candles (Set of 6)',
        description: 'Aromatic soy wax candles in decorative holders',
        price: 399.0,
        category: 'Handmade Items',
        sellerId: 'seller6',
        sellerName: 'Aromatics by Sneha',
        imageUrl: 'https://images.unsplash.com/photo-1602874801006-96f1f7ef9f96?w=500',
        rating: 4.9,
        reviewCount: 201,
      ),
      Product(
        id: '10',
        name: 'Embroidered Wall Hanging',
        description: 'Traditional embroidered wall decor with mirror work',
        price: 650.0,
        category: 'Handmade Items',
        sellerId: 'seller7',
        sellerName: 'Creative Threads',
        imageUrl: 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=500',
        rating: 4.6,
        reviewCount: 87,
      ),
      Product(
        id: '11',
        name: 'Handmade Greeting Cards (Set of 10)',
        description: 'Beautifully crafted cards for all occasions',
        price: 250.0,
        category: 'Handmade Items',
        sellerId: 'seller7',
        sellerName: 'Creative Threads',
        imageUrl: 'https://images.unsplash.com/photo-1527525443983-6e60c75fff46?w=500',
        rating: 4.7,
        reviewCount: 123,
      ),

      // ========== HOMEMAKER PRODUCTS - TAILORING ==========
      Product(
        id: '12',
        name: 'Custom Blouse Stitching',
        description: 'Professional blouse stitching with custom designs',
        price: 350.0,
        category: 'Tailoring',
        sellerId: 'seller8',
        sellerName: 'Tailor Madhavi',
        imageUrl: 'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=500',
        rating: 4.9,
        reviewCount: 267,
      ),
      Product(
        id: '13',
        name: 'Reusable Cloth Bags (Set of 5)',
        description: 'Eco-friendly cotton shopping bags',
        price: 250.0,
        category: 'Tailoring',
        sellerId: 'seller8',
        sellerName: 'Tailor Madhavi',
        imageUrl: 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=500',
        rating: 4.6,
        reviewCount: 143,
      ),
      Product(
        id: '14',
        name: 'Cushion Covers (Set of 4)',
        description: 'Hand-stitched decorative cushion covers',
        price: 480.0,
        category: 'Tailoring',
        sellerId: 'seller8',
        sellerName: 'Tailor Madhavi',
        imageUrl: 'https://images.unsplash.com/photo-1615529182904-14819c35db37?w=500',
        rating: 4.7,
        reviewCount: 98,
      ),

      // ========== FARMER PRODUCTS - FRESH PRODUCE ==========
      Product(
        id: '15',
        name: 'Fresh Organic Vegetables (5kg Mix)',
        description: 'Farm-fresh seasonal vegetables - tomatoes, onions, potatoes, leafy greens',
        price: 350.0,
        category: 'Fresh Produce',
        sellerId: 'seller9',
        sellerName: 'Raju Organic Farm',
        imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500',
        rating: 4.7,
        reviewCount: 445,
        isFoodItem: true,
        hasFSSAI: true,
      ),
      Product(
        id: '16',
        name: 'Seasonal Fruits Basket (3kg)',
        description: 'Hand-picked fresh fruits - mangoes, bananas, papayas',
        price: 280.0,
        category: 'Fresh Produce',
        sellerId: 'seller9',
        sellerName: 'Raju Organic Farm',
        imageUrl: 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=500',
        rating: 4.8,
        reviewCount: 378,
        isFoodItem: true,
        hasFSSAI: true,
      ),
      Product(
        id: '17',
        name: 'Fresh Leafy Greens Bundle',
        description: 'Spinach, coriander, mint, and curry leaves',
        price: 80.0,
        category: 'Fresh Produce',
        sellerId: 'seller9',
        sellerName: 'Raju Organic Farm',
        imageUrl: 'https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=500',
        rating: 4.6,
        reviewCount: 234,
        isFoodItem: true,
        hasFSSAI: true,
      ),

      // ========== FARMER PRODUCTS - DAIRY ==========
      Product(
        id: '18',
        name: 'Fresh A2 Cow Milk (1 Liter)',
        description: 'Pure A2 cow milk from local dairy, daily delivery',
        price: 80.0,
        category: 'Dairy',
        sellerId: 'seller10',
        sellerName: 'Gau Seva Dairy',
        imageUrl: 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=500',
        rating: 4.9,
        reviewCount: 567,
        isFoodItem: true,
        hasFSSAI: true,
      ),
      Product(
        id: '19',
        name: 'Pure Desi Ghee (500g)',
        description: 'Traditional hand-churned ghee from A2 milk',
        price: 550.0,
        category: 'Dairy',
        sellerId: 'seller10',
        sellerName: 'Gau Seva Dairy',
        imageUrl: 'https://images.unsplash.com/photo-1630409346283-4274949fca14?w=500',
        rating: 5.0,
        reviewCount: 423,
        isFoodItem: true,
        hasFSSAI: true,
      ),
      Product(
        id: '20',
        name: 'Fresh Paneer (250g)',
        description: 'Soft and fresh paneer made daily',
        price: 90.0,
        category: 'Dairy',
        sellerId: 'seller10',
        sellerName: 'Gau Seva Dairy',
        imageUrl: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500',
        rating: 4.7,
        reviewCount: 289,
        isFoodItem: true,
        hasFSSAI: true,
      ),
      Product(
        id: '21',
        name: 'Fresh Curd (500g)',
        description: 'Thick and creamy homemade curd',
        price: 50.0,
        category: 'Dairy',
        sellerId: 'seller10',
        sellerName: 'Gau Seva Dairy',
        imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=500',
        rating: 4.8,
        reviewCount: 345,
        isFoodItem: true,
        hasFSSAI: true,
      ),
      Product(
        id: '22',
        name: 'Farm Fresh Eggs (12 pcs)',
        description: 'Free-range chicken eggs, naturally fed',
        price: 84.0,
        category: 'Dairy',
        sellerId: 'seller10',
        sellerName: 'Gau Seva Dairy',
        imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=500',
        rating: 4.7,
        reviewCount: 198,
        isFoodItem: true,
        hasFSSAI: true,
      ),

      // ========== FARMER PRODUCTS - GRAINS & STAPLES ==========
      Product(
        id: '23',
        name: 'Organic Ragi (Finger Millet) - 1kg',
        description: 'Nutrient-rich organic ragi, pesticide-free',
        price: 85.0,
        category: 'Grains & Staples',
        sellerId: 'seller11',
        sellerName: 'Organic Grains Co.',
        imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500',
        rating: 4.6,
        reviewCount: 167,
        isFoodItem: true,
        hasFSSAI: true,
      ),
      Product(
        id: '24',
        name: 'Traditional Sona Masoori Rice (5kg)',
        description: 'Premium quality aromatic rice, aged perfectly',
        price: 320.0,
        category: 'Grains & Staples',
        sellerId: 'seller11',
        sellerName: 'Organic Grains Co.',
        imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500',
        rating: 4.8,
        reviewCount: 234,
        isFoodItem: true,
        hasFSSAI: true,
      ),
      Product(
        id: '25',
        name: 'Organic Jowar (Sorghum) - 1kg',
        description: 'Gluten-free jowar for healthy rotis',
        price: 75.0,
        category: 'Grains & Staples',
        sellerId: 'seller11',
        sellerName: 'Organic Grains Co.',
        imageUrl: 'https://images.unsplash.com/photo-1599909393780-37f3d96b9f9a?w=500',
        rating: 4.7,
        reviewCount: 145,
        isFoodItem: true,
        hasFSSAI: true,
      ),
      Product(
        id: '26',
        name: 'Mixed Pulses Pack (1kg)',
        description: 'Assorted lentils - toor, moong, masoor, urad',
        price: 180.0,
        category: 'Grains & Staples',
        sellerId: 'seller11',
        sellerName: 'Organic Grains Co.',
        imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500',
        rating: 4.8,
        reviewCount: 201,
        isFoodItem: true,
        hasFSSAI: true,
      ),

      // ========== ORGANIC & NATURAL PRODUCTS ==========
      Product(
        id: '27',
        name: 'Pure Organic Honey (500g)',
        description: 'Raw, unprocessed honey from forest flowers',
        price: 380.0,
        category: 'Organic Products',
        sellerId: 'seller12',
        sellerName: 'Nature\'s Best',
        imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784acc?w=500',
        rating: 4.9,
        reviewCount: 512,
        isFoodItem: true,
        hasFSSAI: true,
      ),
      Product(
        id: '28',
        name: 'Cold-Pressed Coconut Oil (1L)',
        description: 'Pure cold-pressed oil, chemical-free',
        price: 450.0,
        category: 'Organic Products',
        sellerId: 'seller12',
        sellerName: 'Nature\'s Best',
        imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500',
        rating: 4.8,
        reviewCount: 345,
        isFoodItem: true,
        hasFSSAI: true,
      ),
      Product(
        id: '29',
        name: 'Natural Jaggery (1kg)',
        description: 'Pure sugarcane jaggery, no chemicals',
        price: 120.0,
        category: 'Organic Products',
        sellerId: 'seller12',
        sellerName: 'Nature\'s Best',
        imageUrl: 'https://images.unsplash.com/photo-1604085792782-8d92ff7c6f8c?w=500',
        rating: 4.7,
        reviewCount: 198,
        isFoodItem: true,
        hasFSSAI: true,
      ),
      Product(
        id: '30',
        name: 'Herbal Green Tea (100g)',
        description: 'Organic herbal tea blend for wellness',
        price: 250.0,
        category: 'Organic Products',
        sellerId: 'seller12',
        sellerName: 'Nature\'s Best',
        imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=500',
        rating: 4.6,
        reviewCount: 167,
        isFoodItem: true,
        hasFSSAI: true,
      ),
    ];

    _orders = [
      Order(
        id: 'order1',
        productId: '1',
        productName: 'Traditional Mango Pickle (500g)',
        productImage: 'https://images.unsplash.com/photo-1623428187969-5da2dcea5ebf?w=500',
        price: 199.0,
        status: 'Delivered',
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        buyerId: _currentUser!.id,
        sellerId: 'seller1',
      ),
      Order(
        id: 'order2',
        productId: '15',
        productName: 'Fresh Organic Vegetables (5kg Mix)',
        productImage: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500',
        price: 350.0,
        status: 'In Transit',
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        buyerId: _currentUser!.id,
        sellerId: 'seller9',
      ),
      Order(
        id: 'order3',
        productId: '18',
        productName: 'Fresh A2 Cow Milk (1 Liter)',
        productImage: 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=500',
        price: 80.0,
        status: 'Pending',
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        buyerId: _currentUser!.id,
        sellerId: 'seller10',
      ),
    ];
  }
}

// ============= MAIN APP =============
class ApnaMarketApp extends StatelessWidget {
  const ApnaMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'ApnaMarket',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

// ============= SPLASH SCREEN =============
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LandingScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight, AppColors.secondary],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shopping_bag_rounded,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              Text(
                'ApnaMarket',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Fair Price, Direct Benefits',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============= LANDING SCREEN =============
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scooterController;
  late Animation<double> _scooterAnimation;

  @override
  void initState() {
    super.initState();
    _scooterController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _scooterAnimation = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(parent: _scooterController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scooterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Animated Scooter/Delivery Icon
                      AnimatedBuilder(
                        animation: _scooterAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _scooterAnimation.value),
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delivery_dining_rounded,
                                size: 100,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Welcome to',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'ApnaMarket',
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Empowering Local Producers',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      _buildFeatureCard(
                        icon: Icons.verified_user_rounded,
                        title: 'Verified Sellers',
                        description: 'FSSAI certified and trusted',
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureCard(
                        icon: Icons.local_shipping_rounded,
                        title: 'Direct Delivery',
                        description: 'From producer to your doorstep',
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureCard(
                        icon: Icons.account_balance_wallet_rounded,
                        title: 'Fair Pricing',
                        description: 'Minimal commission, maximum value',
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: const Text('Get Started'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AboutScreen()),
                        );
                      },
                      child: Text(
                        'Learn More About Us',
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============= ABOUT SCREEN =============
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About ApnaMarket'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.shopping_bag_rounded,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Our Mission',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ApnaMarket is designed to empower homemakers, farmers, and small-scale producers by enabling them to sell or rent products directly to customers through a managed digital ecosystem.',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Key Features',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem('Fair pricing with minimal commission'),
            _buildFeatureItem('FSSAI verified food sellers'),
            _buildFeatureItem('Direct connection with local producers'),
            _buildFeatureItem('Secure payment processing'),
            _buildFeatureItem('Transparent transaction management'),
            _buildFeatureItem('Quality and hygiene standards maintained'),
            const SizedBox(height: 24),
            Text(
              'Supporting Local Communities',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We believe in creating a sustainable ecosystem where producers get fair value for their products and customers get authentic, quality goods. By reducing intermediaries, we ensure everyone benefits.',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============= LOGIN SCREEN =============
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      final user = User(
        id: 'user123',
        name: 'Rajesh Kumar',
        email: _emailController.text,
        phone: '+91 9876543210',
        isSeller: false,
        isVerified: true,
      );

      Provider.of<AppState>(context, listen: false).login(user);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_rounded,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to continue shopping',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password reset link sent to email')),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.poppins(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignupScreen()),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============= SIGNUP SCREEN =============
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSeller = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please login.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Join ApnaMarket',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start buying or selling today',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isSeller ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isSeller,
                        onChanged: (value) {
                          setState(() {
                            _isSeller = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Register as Seller',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Sell your products on ApnaMarket',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _signup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text('Create Account'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: GoogleFonts.poppins(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Login',
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============= MAIN SCREEN WITH BOTTOM NAVIGATION =============
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          body: IndexedStack(
            index: state.currentIndex,
            children: const [
              HomeScreen(),
              CategoriesScreen(),
              OrdersScreen(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: state.currentIndex,
            onTap: (index) => state.setCurrentIndex(index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category_outlined),
                activeIcon: Icon(Icons.category_rounded),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                activeIcon: Icon(Icons.shopping_bag_rounded),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============= HOME SCREEN =============
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, state, _) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${state.currentUser?.name.split(' ').first ?? "User"}!',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'What are you looking for?',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: Stack(
                        children: [
                          const Icon(Icons.favorite_outline, color: AppColors.primary),
                          if (state.wishlist.isNotEmpty)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '${state.wishlist.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WishlistScreen()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                      onPressed: () {},
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: AppColors.textSecondary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Search products...',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Banner
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryLight],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: 20,
                                bottom: 0,
                                child: Icon(
                                  Icons.shopping_cart_rounded,
                                  size: 120,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Special Offers!',
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Get up to 30% off on\nfresh products',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: const Text('Shop Now'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Categories
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Categories',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Provider.of<AppState>(context, listen: false).setCurrentIndex(1);
                              },
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildCategoryCard(context, 'Homemade Food', Icons.restaurant_menu_rounded, AppColors.secondary),
                              _buildCategoryCard(context, 'Handmade', Icons.palette_rounded, Colors.purple),
                              _buildCategoryCard(context, 'Fresh Produce', Icons.grass_rounded, AppColors.success),
                              _buildCategoryCard(context, 'Dairy', Icons.water_drop_rounded, Colors.blue),
                              _buildCategoryCard(context, 'Grains', Icons.grain_rounded, Colors.brown),
                              _buildCategoryCard(context, 'Organic', Icons.eco_rounded, AppColors.primary),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Featured Products
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Featured Products',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final product = state.products[index];
                        return ProductCard(product: product);
                      },
                      childCount: state.products.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String name, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryProductsScreen(
              categoryName: name,
              categoryColor: color,
              categoryIcon: icon,
            ),
          ),
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============= PRODUCT CARD =============
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    product.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<AppState>(
                    builder: (context, state, _) {
                      final isWishlisted = state.isInWishlist(product.id);
                      return GestureDetector(
                        onTap: () => state.toggleWishlist(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            color: isWishlisted ? Colors.red : Colors.grey,
                            size: 18,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (product.isFoodItem && product.hasFSSAI)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'FSSAI',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          ' (${product.reviewCount})',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '₹${product.price.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============= PRODUCT DETAIL SCREEN =============
class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 100, color: Colors.grey),
                ),
              ),
            ),
            actions: [
              Consumer<AppState>(
                builder: (context, state, _) {
                  final isWishlisted = state.isInWishlist(product.id);
                  return IconButton(
                    icon: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      color: isWishlisted ? Colors.red : Colors.white,
                    ),
                    onPressed: () => state.toggleWishlist(product),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (product.isFoodItem && product.hasFSSAI)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified, color: AppColors.success, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'FSSAI Verified',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.category,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.store_rounded, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          product.sellerName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < product.rating.floor()
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${product.rating} (${product.reviewCount} reviews)',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This product is sold directly by local producers with minimal commission',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.primary,
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
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '₹${product.price.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final order = Order(
                      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
                      productId: product.id,
                      productName: product.name,
                      productImage: product.imageUrl,
                      price: product.price,
                      status: 'Pending',
                      orderDate: DateTime.now(),
                      buyerId: Provider.of<AppState>(context, listen: false).currentUser!.id,
                      sellerId: product.sellerId,
                    );

                    Provider.of<AppState>(context, listen: false).addOrder(order);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order placed successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart),
                      const SizedBox(width: 8),
                      Text(
                        'Buy Now',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============= CATEGORY PRODUCTS SCREEN =============
class CategoryProductsScreen extends StatelessWidget {
  final String categoryName;
  final Color categoryColor;
  final IconData categoryIcon;

  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: Colors.white,
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          // Filter products by category
          final categoryProducts = state.products
              .where((product) => product.category == categoryName)
              .toList();

          if (categoryProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    categoryIcon,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products in this category yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back soon for new items!',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Category Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [categoryColor.withOpacity(0.1), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        categoryIcon,
                        size: 32,
                        color: categoryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryName,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${categoryProducts.length} ${categoryProducts.length == 1 ? 'product' : 'products'} available',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Products Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: categoryProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: categoryProducts[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============= CATEGORIES SCREEN =============
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Homemade Food', 'icon': Icons.restaurant_menu_rounded, 'color': AppColors.secondary},
      {'name': 'Handmade Items', 'icon': Icons.palette_rounded, 'color': Colors.purple},
      {'name': 'Tailoring', 'icon': Icons.checkroom_rounded, 'color': Colors.pink},
      {'name': 'Fresh Produce', 'icon': Icons.grass_rounded, 'color': AppColors.success},
      {'name': 'Dairy', 'icon': Icons.water_drop_rounded, 'color': Colors.blue},
      {'name': 'Grains & Staples', 'icon': Icons.grain_rounded, 'color': Colors.brown},
      {'name': 'Organic Products', 'icon': Icons.eco_rounded, 'color': AppColors.primary},
      {'name': 'Rental Services', 'icon': Icons.agriculture_rounded, 'color': Colors.orange},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryProductsScreen(
                    categoryName: category['name'] as String,
                    categoryColor: category['color'] as Color,
                    categoryIcon: category['icon'] as IconData,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: (category['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (category['color'] as Color).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 48,
                    color: category['color'] as Color,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category['name'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: category['color'] as Color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============= ORDERS SCREEN =============
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (state.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start shopping to see your orders here',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.orders.length,
            itemBuilder: (context, index) {
              final order = state.orders[index];
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    Color statusColor;
    IconData statusIcon;

    switch (order.status.toLowerCase()) {
      case 'delivered':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'in transit':
        statusColor = AppColors.warning;
        statusIcon = Icons.local_shipping;
        break;
      case 'pending':
        statusColor = AppColors.secondary;
        statusIcon = Icons.access_time;
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusIcon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    order.productImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order ID: ${order.id}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '₹${order.price.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        order.status,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

// ============= WISHLIST SCREEN =============
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (state.wishlist.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No items in wishlist',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add products you like to your wishlist',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: state.wishlist.length,
            itemBuilder: (context, index) {
              return ProductCard(product: state.wishlist[index]);
            },
          );
        },
      ),
    );
  }
}

// ============= PROFILE SCREEN =============
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          final user = state.currentUser;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Profile Header
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    user?.name.substring(0, 1).toUpperCase() ?? 'U',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'User',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.phone ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Menu Items
                _buildMenuItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {},
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.location_on_outlined,
                  title: 'Manage Addresses',
                  onTap: () {},
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.payment_outlined,
                  title: 'Payment Methods',
                  onTap: () {},
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.store_outlined,
                  title: 'Become a Seller',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SellerRegistrationScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.support_agent_outlined,
                  title: 'Customer Support',
                  onTap: () {},
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'About ApnaMarket',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'Logout',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                        content: Text(
                          'Are you sure you want to logout?',
                          style: GoogleFonts.poppins(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Provider.of<AppState>(context, listen: false).logout();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LandingScreen()),
                                    (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                  },
                  isDestructive: true,
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        bool isDestructive = false,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.primary,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}

// ============= SELLER REGISTRATION SCREEN =============
class SellerRegistrationScreen extends StatefulWidget {
  const SellerRegistrationScreen({super.key});

  @override
  State<SellerRegistrationScreen> createState() => _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState extends State<SellerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _fssaiController = TextEditingController();
  bool _isFoodBusiness = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _fssaiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Seller'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.store_rounded,
                      size: 60,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Start Selling on ApnaMarket',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join thousands of sellers and reach millions of customers',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(
                  labelText: 'Business Name',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your business name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isFoodBusiness,
                      onChanged: (value) {
                        setState(() {
                          _isFoodBusiness = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        'I sell food/consumable products',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isFoodBusiness) ...[
                const SizedBox(height: 20),
                TextFormField(
                  controller: _fssaiController,
                  decoration: const InputDecoration(
                    labelText: 'FSSAI License Number',
                    prefixIcon: Icon(Icons.verified_user),
                    helperText: 'Required for food businesses',
                  ),
                  validator: (value) {
                    if (_isFoodBusiness && (value == null || value.isEmpty)) {
                      return 'FSSAI license is required for food businesses';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Seller registration submitted! We will verify your details and get back to you.',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text('Submit Application'),
              ),
              const SizedBox(height: 16),
              Text(
                'By registering as a seller, you agree to our terms and conditions. Your application will be reviewed within 2-3 business days.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}