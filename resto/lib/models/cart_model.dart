import 'package:collection/collection.dart';
import 'package:resto/models/menu_model.dart';

class CartItem {
  final int? id;
  final MenuItem item;
  final int quantity;
  final List<int>? supplementsAvec;
  final List<int>? supplementsSans;

  CartItem({
    this.id,
    required this.item,
    required this.quantity,
    this.supplementsAvec,
    this.supplementsSans,
  });

  /// 🔁 Pour l’API Django — noms corrigés + champs optionnels
  Map<String, dynamic> toJson() {
    return {
      'menu_item_id': item.id,
      'quantity': quantity,
      'supplements_avec_ids': supplementsAvec ?? [],
      'supplements_sans_ids': supplementsSans ?? [],
    };
  }

  /// 💰 Prix total local
  int get totalPrice {
    final base = item.price;
    final supplements = item.supplementsAvec
        .where((s) => (supplementsAvec ?? []).contains(s.id))
        .fold(0, (sum, s) => sum + s.price);
    return (base + supplements) * quantity;
  }

  /// 🧬 Comparaison
  @override
  bool operator ==(Object other) =>
      other is CartItem &&
      other.id == id &&
      other.item.id == item.id &&
      other.quantity == quantity &&
      const ListEquality().equals(other.supplementsAvec, supplementsAvec) &&
      const ListEquality().equals(other.supplementsSans, supplementsSans);

  @override
  int get hashCode =>
      id.hashCode ^
      item.id.hashCode ^
      quantity.hashCode ^
      supplementsAvec.hashCode ^
      supplementsSans.hashCode;

  /// 🧱 Copie modifiable
  CartItem copyWith({
    int? id,
    MenuItem? item,
    int? quantity,
    List<int>? supplementsAvec,
    List<int>? supplementsSans,
  }) {
    return CartItem(
      id: id ?? this.id,
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      supplementsAvec: supplementsAvec ?? this.supplementsAvec,
      supplementsSans: supplementsSans ?? this.supplementsSans,
    );
  }
}
