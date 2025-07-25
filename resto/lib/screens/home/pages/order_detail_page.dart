import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:resto/helpers/pdf_invoice.dart';
import 'package:resto/models/order_summary_model.dart';
import 'package:resto/services/order_service.dart';

class OrderDetailPage extends StatefulWidget {
  final OrderSummary order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final OrderService _orderService = OrderService();
  late Future<Map<String, dynamic>> _orderDetailFuture;

  @override
  void initState() {
    super.initState();
    _orderDetailFuture = _orderService.fetchOrderDetails(widget.order.id);
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'livre':
        return Colors.green;
      case 'en cours':
      case 'preparation':
      case 'accepte':
        return Colors.orange;
      case 'annule':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Commande n°${widget.order.orderNumber}"),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Télécharger le reçu",
            onPressed: () async {
              try {
                final detail = await _orderDetailFuture;
                final pdfData = await buildThermalReceiptPdf(detail);
                await Printing.layoutPdf(onLayout: (_) => pdfData);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erreur lors du téléchargement : $e")),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _orderDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erreur : ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final detail = snapshot.data!;
          final items = List<Map<String, dynamic>>.from(detail['items'] ?? []);
          final user = detail['user'] ?? {};
          final status = detail['status'] ?? 'inconnu';
          final total = detail['total_price'] ?? 0;
          final payment = detail['payment_method'] ?? 'inconnu';
          final delivery = detail['delivery_type'] ?? 'inconnu';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 🧾 En-tête
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Commande n°${widget.order.orderNumber}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Date : ${dateFormat.format(DateTime.parse(widget.order.date).toLocal())}",
                    ),
                    const SizedBox(height: 6),
                    Text("Paiement : ${payment.toUpperCase()}"),
                    Text("Livraison : ${delivery.toUpperCase()}"),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text(
                "Menus commandés",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),

              ...items.map((item) {
                final menu = item['menu_item'] ?? {};
                final name = menu['name'] ?? 'Plat';
                final price = menu['price'] ?? 0;
                final quantity = item['quantity'] ?? 1;

                final supplements = List<Map<String, dynamic>>.from(
                  item['supplements_avec'] ?? [],
                );
                final supplementsSansRaw = item['supplements_sans'] ?? [];
                final supplementsSans = supplementsSansRaw is List
                    ? supplementsSansRaw.map((s) {
                        if (s is String) return s;
                        if (s is Map && s.containsKey('name')) return s['name'];
                        return s.toString();
                      }).toList()
                    : [];

                final supplementTotal = supplements.fold<num>(
                  0,
                  (sum, s) => sum + (s['price'] ?? 0),
                );
                final totalItem = (price + supplementTotal) * quantity;

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 12),
                        // 📋 Détails du plat
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$quantity x $name",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Prix unitaire : ${currencyFormat.format(price)}",
                              ),

                              if (supplements.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                const Text(
                                  "Suppléments :",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                ...supplements.map(
                                  (s) => Text(
                                    "- ${s['name']} (${(s['price'] ?? 0) == 0 ? "gratuit" : currencyFormat.format(s['price'])})",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],

                              if (supplementsSans.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    "Sans : ${supplementsSans.join(', ')}",
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 6),
                              Text(
                                "Total article : ${currencyFormat.format(totalItem)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),
              // 📦 Statut + Total
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Statut",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor(status),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total commande",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          currencyFormat.format(total),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              // 🏠 Livraison
              Text(
                "Adresse de livraison",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['full_name'] ?? 'Nom inconnu',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(user['address'] ?? 'Adresse non renseignée'),
                    Text("Téléphone : ${user['phone'] ?? 'Non disponible'}"),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}
