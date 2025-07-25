import 'package:flutter/material.dart';
import 'package:resto/models/order_model.dart';
import 'package:resto/services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  Future<Order?> submitOrder({
    required String deliveryType,
    String? arrivalTime,
    required String paymentMethod,
  }) async {
    final payload = {
      "delivery_type": deliveryType,
      "arrival_time": arrivalTime,
      "payment_method": paymentMethod,
    };

    try {
      final data = await _orderService.submitOrder(payload);
      return Order.fromJson(data);
    } catch (e) {
      debugPrint("Erreur lors de la commande : $e");
      return null;
    }
  }
}
