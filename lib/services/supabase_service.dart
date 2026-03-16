// https://ucmaywesliudwniojzgn.supabase.co
// anon: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVjbWF5d2VzbGl1ZHduaW9qemduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE5MTQyMTgsImV4cCI6MjA4NzQ5MDIxOH0.T4otBj6djhKs-HMOd517QODkjcYHEHAVB5erWaDpquU


import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;






// ================= PRODUCT MODEL =================

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String sellerId;
  final String sellerName;
  final String imageUrl;
  final bool isAvailable;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.sellerId,
    required this.sellerName,
    required this.imageUrl,
    required this.isAvailable,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      category: json['category'] ?? '',
      sellerId: json['seller_id'] ?? '',
      sellerName: json['seller_name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      isAvailable: json['is_available'] ?? true,
    );
  }
}






// ================= ORDER MODEL =================

class OrderModel {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final String status;
  final DateTime orderDate;
  final String buyerId;
  final String sellerId;

  OrderModel({
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

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      productImage: json['product_image'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? '',
      orderDate: DateTime.parse(json['created_at']),
      buyerId: json['buyer_id'] ?? '',
      sellerId: json['seller_id'] ?? '',
    );
  }
}






// ================= SUPABASE SERVICE =================

class SupabaseService {

  // ================= AUTH =================

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required bool isSeller,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'phone': phone,
        'is_seller': isSeller,
      },
    );
  }

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> logout() async {
    await supabase.auth.signOut();
  }

  static User? currentUser() {
    return supabase.auth.currentUser;
  }






  // ================= PRODUCTS =================

  static Future<List<ProductModel>> fetchProducts() async {
    final data = await supabase
        .from('products')
        .select()
        .eq('is_available', true)
        .order('created_at');

    return (data as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  static Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required String category,
    String? imageUrl,
  }) async {

    final user = supabase.auth.currentUser;

    await supabase.from('products').insert({
      'seller_id': user!.id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image_url': imageUrl,
    });
  }






  // ================= WISHLIST =================

  static Future<List<ProductModel>> fetchWishlist() async {

    final user = supabase.auth.currentUser;

    final data = await supabase
        .from('wishlist')
        .select('products(*)')
        .eq('user_id', user!.id);

    return (data as List)
        .map((item) => ProductModel.fromJson(item['products']))
        .toList();
  }

  static Future<void> addToWishlist(String productId) async {

    final user = supabase.auth.currentUser;

    await supabase.from('wishlist').insert({
      'user_id': user!.id,
      'product_id': productId,
    });
  }

  static Future<void> removeFromWishlist(String productId) async {

    final user = supabase.auth.currentUser;

    await supabase
        .from('wishlist')
        .delete()
        .eq('user_id', user!.id)
        .eq('product_id', productId);
  }






  // ================= CART =================

  static Future<void> addToCart(String productId, int quantity) async {

    final user = supabase.auth.currentUser;

    await supabase.from('cart').insert({
      'user_id': user!.id,
      'product_id': productId,
      'quantity': quantity,
    });
  }

  static Future<List<Map<String, dynamic>>> fetchCart() async {

    final user = supabase.auth.currentUser;

    final data = await supabase
        .from('cart')
        .select('quantity, products(*)')
        .eq('user_id', user!.id);

    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> removeFromCart(String productId) async {

    final user = supabase.auth.currentUser;

    await supabase
        .from('cart')
        .delete()
        .eq('user_id', user!.id)
        .eq('product_id', productId);
  }






  // ================= ORDERS =================

  static Future<void> createOrder({
    required String sellerId,
    required String productId,
    required int quantity,
    required double totalPrice,
  }) async {

    final user = supabase.auth.currentUser;

    await supabase.from('orders').insert({
      'buyer_id': user!.id,
      'seller_id': sellerId,
      'product_id': productId,
      'quantity': quantity,
      'total_price': totalPrice,
      'status': 'pending',
    });
  }

  static Future<List<OrderModel>> fetchOrders() async {

    final user = supabase.auth.currentUser;

    final data = await supabase
        .from('orders')
        .select()
        .eq('buyer_id', user!.id)
        .order('created_at');

    return (data as List)
        .map((json) => OrderModel.fromJson(json))
        .toList();
  }

}

