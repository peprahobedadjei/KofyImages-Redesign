// providers/cart_notifier.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:kofyimages/models/frame_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartNotifier extends ChangeNotifier {
  final List<CartItem> _items = [];
  static const _cartKey = 'cart_items';

  CartNotifier() {
    _loadCart();
  }

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  int get totalItems =>
      _items.fold(0, (sum, item) => sum + item.productQuantity);

  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  void addItem(CartItem newItem) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.productId == newItem.productId &&
          item.productFrameColor == newItem.productFrameColor &&
          item.productType == newItem.productType,
    );

    if (existingIndex >= 0) {
      // Item already exists, increment quantity
      _items[existingIndex].productQuantity += newItem.productQuantity;
    } else {
      // Add new item
      _items.add(newItem);
    }
    _saveCart();
    notifyListeners();
  }

  void removeItem(int productId, String frameColor, String productType) {
    _items.removeWhere(
      (item) =>
          item.productId == productId &&
          item.productFrameColor == frameColor &&
          item.productType == productType,
    );
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(
    int productId,
    String frameColor,
    String productType,
    int newQuantity,
  ) {
    final index = _items.indexWhere(
      (item) =>
          item.productId == productId &&
          item.productFrameColor == frameColor &&
          item.productType == productType,
    );

    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].productQuantity = newQuantity;
      }
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    _saveCart();
  }

  void printCartItems() {
    print('=== CART ITEMS ===');
    for (var item in _items) {
      print(item.toJson());
    }
    print('Total Items: $totalItems');
    print('Total Price: \$${totalPrice.toStringAsFixed(2)}');
  }

  // ========== Persistence Logic ==========
  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString(_cartKey, encoded);
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_cartKey);
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      _items.clear();
      _items.addAll(decoded.map((e) => CartItem.fromJson(e)));
      notifyListeners();
    }
  }
}
