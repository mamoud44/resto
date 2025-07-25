import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:resto/models/cart_model.dart';
import 'package:resto/providers/cart_provider.dart';
import 'package:resto/providers/order_provider.dart';
import 'package:resto/screens/home/home_screen.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String deliveryType = 'livraison';
  String paymentMethod = 'cash';
  TimeOfDay? arrivalTime;

  Future<void> _selectArrivalTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        arrivalTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon panier"),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () async {
                cart.clearCart();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Panier vidé ❌")));
              },
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text("Votre panier est vide 🛒"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: item.item.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.item.imageUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.fastfood, size: 40),
                        title: Text(
                          "${item.quantity} x ${item.item.name}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "⏱ ${item.item.formattedPreparationTime}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _showEditSupplementsModal(context, cart, item),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((item.supplementsAvec ?? []).isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Suppléments :",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  ...item.item.supplementsAvec
                                      .where(
                                        (s) => (item.supplementsAvec ?? [])
                                            .contains(s.id),
                                      )
                                      .map(
                                        (s) => Text(
                                          "- ${s.name} (${s.price > 0 ? currencyFormat.format(s.price) : "gratuit"})",
                                        ),
                                      ),
                                ],
                              ),
                            if ((item.supplementsSans ?? []).isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  "Sans : ${item.item.supplementsSans.where((s) => (item.supplementsSans ?? []).contains(s.id)).map((s) => s.name).join(', ')}",
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: item.quantity > 1
                                          ? () async {
                                              await cart.updateQuantity(
                                                item: item,
                                                newQuantity: item.quantity - 1,
                                              );
                                            }
                                          : null,
                                    ),
                                    Text(
                                      item.quantity.toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onPressed: () async {
                                        await cart.updateQuantity(
                                          item: item,
                                          newQuantity: item.quantity + 1,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      currencyFormat.format(item.totalPrice),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _confirmDelete(context, cart, item),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text("Livraison : "),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: deliveryType,
                        items: const [
                          DropdownMenuItem(
                            value: 'livraison',
                            child: Text("Livraison"),
                          ),
                          DropdownMenuItem(
                            value: 'sur_place',
                            child: Text("Sur place"),
                          ),
                          DropdownMenuItem(
                            value: 'emporter',
                            child: Text("À emporter"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            deliveryType = value!;
                            arrivalTime = null;
                          });
                        },
                      ),
                    ],
                  ),
                  if (deliveryType == 'sur_place')
                    Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 8),
                        Text(
                          arrivalTime != null
                              ? "Heure d'arrivée : ${arrivalTime!.format(context)}"
                              : "Choisir une heure d'arrivée",
                        ),
                        TextButton(
                          onPressed: () => _selectArrivalTime(context),
                          child: const Text("Sélectionner"),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text("Paiement : "),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: paymentMethod,
                        items: const [
                          DropdownMenuItem(
                            value: 'cash',
                            child: Text("Espèces"),
                          ),
                          DropdownMenuItem(
                            value: 'mobile_money',
                            child: Text("Mobile Money"),
                          ),
                          DropdownMenuItem(
                            value: 'carte',
                            child: Text("Carte bancaire"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            paymentMethod = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final timeStr = arrivalTime != null
                          ? "${arrivalTime!.hour.toString().padLeft(2, '0')}:${arrivalTime!.minute.toString().padLeft(2, '0')}:00"
                          : null;

                      try {
                        final order = await orderProvider.submitOrder(
                          deliveryType: deliveryType,
                          arrivalTime: timeStr,
                          paymentMethod: paymentMethod,
                        );

                        if (order != null) {
                          await cart.clearCart();
                          if (!context.mounted) return;

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: const Text("Commande confirmée ✅"),
                              content: Text(
                                "Commande n°${order.orderNumber} enregistrée avec succès.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pop(); // Ferme le dialog
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) => const HomeScreen(
                                          initialIndex: 1,
                                        ), // 👈 onglet Menu
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  child: const Text(
                                    "OK",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Échec de la commande ❌"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        debugPrint("Erreur lors de la commande : $e");
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Une erreur est survenue ❌"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: Text(
                      "Commander pour ${currencyFormat.format(cart.totalPrice)}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _confirmDelete(BuildContext context, CartProvider cart, CartItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer cet article ?"),
        content: const Text("Cette action retirera l'article du panier."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              await cart.removeItem(item);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Article supprimé du panier 🗑️")),
              );
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditSupplementsModal(
    BuildContext context,
    CartProvider cart,
    CartItem cartItem,
  ) {
    final item = cartItem.item;
    final selectedAvec = Set<int>.from(cartItem.supplementsAvec ?? []);
    final selectedSans = Set<int>.from(cartItem.supplementsSans ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Suppléments (avec)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...item.supplementsAvec.map(
                      (s) => CheckboxListTile(
                        title: Text(
                          "${s.name} ${s.price > 0 ? "(+${s.price} FCFA)" : "(gratuit)"}",
                        ),
                        value: selectedAvec.contains(s.id),
                        onChanged: (val) {
                          setModalState(() {
                            val == true
                                ? selectedAvec.add(s.id)
                                : selectedAvec.remove(s.id);
                          });
                        },
                      ),
                    ),
                    const Divider(),
                    const Text(
                      "Suppléments à retirer",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...item.supplementsSans.map(
                      (s) => CheckboxListTile(
                        title: Text(s.name),
                        value: selectedSans.contains(s.id),
                        onChanged: (val) {
                          setModalState(() {
                            val == true
                                ? selectedSans.add(s.id)
                                : selectedSans.remove(s.id);
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await cart.removeItem(cartItem);
                        await cart.addToCart(
                          item: item,
                          quantity: cartItem.quantity,
                          supplementsAvec: selectedAvec.toList(),
                          supplementsSans: selectedSans.toList(),
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Suppléments mis à jour ✅"),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text(
                        "Appliquer les modifications",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
