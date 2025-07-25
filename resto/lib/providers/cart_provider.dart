import 'package:flutter/material.dart';
import 'package:resto/models/cart_model.dart';
import 'package:resto/models/menu_model.dart';
import 'package:resto/services/cart_service.dart';
import 'package:dio/dio.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  final CartService _cartService = CartService();

  List<CartItem> get items => List.unmodifiable(_items);

  /// ➕ Ajoute un nouvel article à chaque appel, et récupère l'ID du backend
  Future<void> addToCart({
    required MenuItem item,
    required int quantity,
    List<int>? supplementsAvec,
    List<int>? supplementsSans,
    BuildContext? context, // facultatif pour SnackBar
  }) async {
    final newItem = CartItem(
      item: item,
      quantity: quantity,
      supplementsAvec: supplementsAvec,
      supplementsSans: supplementsSans,
    );

    final payload = newItem.toJson();
    debugPrint("📦 Payload envoyé : $payload");

    try {
      final id = await _cartService.addCartItem(payload);
      final newItemWithId = newItem.copyWith(id: id);
      _items.add(newItemWithId);
      notifyListeners();
      debugPrint("✅ Article ajouté avec succès (ID: $id)");

      // Optionnel : afficher un SnackBar de succès
      // if (context != null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text("Article ajouté au panier ✅")),
      //   );
      // }
    } catch (e) {
      if (e is DioException) {
        debugPrint("❌ Erreur backend : ${e.response?.data}");
        debugPrint("❌ Statut HTTP : ${e.response?.statusCode}");

        // Optionnel : afficher un SnackBar d'erreur
        // if (context != null) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text("Erreur : ${e.response?.data}")),
        //   );
        // }
      } else {
        debugPrint("❌ Erreur inconnue : $e");
      }
    }
  }

  Future<void> updateQuantity({
    required CartItem item,
    required int newQuantity,
  }) async {
    final updatedItem = item.copyWith(quantity: newQuantity);

    final index = _items.indexOf(item);
    if (index != -1) {
      _items[index] = updatedItem;
      notifyListeners();
    }

    try {
      if (item.id != null) {
        await _cartService.updateCartItem(item.id!, updatedItem.toJson());
      }
    } catch (e) {
      debugPrint("Erreur mise à jour quantité : $e");
    }
  }

  Future<void> removeItem(CartItem cartItem) async {
    if (cartItem.id != null) {
      try {
        await _cartService.deleteCartItem(cartItem.id!);
      } catch (e) {
        debugPrint("Erreur suppression backend : $e");
      }
    }
    _items.remove(cartItem);
    notifyListeners();
  }

  Future<void> clearCart() async {
    try {
      await _cartService.clearCart();
    } catch (e) {
      debugPrint("Erreur vidage backend : $e");
    }
    _items.clear();
    notifyListeners();
  }

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> syncFromBackend() async {
    try {
      final data = await _cartService.fetchCartItems();
      _items.clear();

      for (var item in data) {
        final menu = MenuItem.fromJson(item['menu_item']);
        _items.add(
          CartItem(
            id: item['id'],
            item: menu,
            quantity: item['quantity'],
            supplementsAvec: List<int>.from(
              item['supplements_avec'].map((s) => s['id']),
            ),
            supplementsSans: List<int>.from(
              item['supplements_sans'].map((s) => s['id']),
            ),
          ),
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Erreur chargement panier : $e");
    }
  }
}
