// lib/helpers/navigation_helpers.dart

import 'package:flutter/material.dart';
import 'package:resto/routes/app_routes.dart';

void navigateToOrderDetail(BuildContext context, Map<String, dynamic> order) {
  Navigator.pushNamed(context, AppRoutes.orderDetail, arguments: order);
}
