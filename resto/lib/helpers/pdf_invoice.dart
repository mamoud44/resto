import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> buildThermalReceiptPdf(Map<String, dynamic> detail) async {
  final pdf = pw.Document();
  final currency = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  );
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  final items = List<Map<String, dynamic>>.from(detail['items'] ?? []);
  final user = detail['user'] ?? {};
  final status = detail['status'] ?? 'inconnu';
  final total = detail['total_price'] ?? 0;
  final restaurant = detail['restaurant'] ?? 'Restaurant';
  final orderNumber = detail['order_number'] ?? '#???';
  final createdAt = detail['created_at'] ?? '';

  pdf.addPage(
    pw.Page(
      pageFormat: const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                restaurant.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              "Commande : $orderNumber",
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              "Date : ${createdAt.isNotEmpty ? dateFormat.format(DateTime.parse(createdAt)) : '--'}",
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              "Client : ${user['full_name'] ?? '---'}",
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              "Téléphone : ${user['phone'] ?? '---'}",
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              "Statut : ${status.toUpperCase()}",
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.Divider(),

            pw.Text(
              "Articles",
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            ...items.map((item) {
              final menu = item['menu_item'] ?? {};
              final name = menu['name'] ?? 'Plat';
              final price = menu['price'] ?? 0;
              final quantity = item['quantity'] ?? 1;
              final supplements = List<Map<String, dynamic>>.from(
                item['supplements_avec'] ?? [],
              );
              final supplementTotal = supplements.fold<num>(
                0,
                (sum, s) => sum + (s['price'] ?? 0),
              );
              final totalItem = (price + supplementTotal) * quantity;

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "$quantity x $name",
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    "  Total : ${currency.format(totalItem)}",
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ],
              );
            }),

            pw.SizedBox(height: 8),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "Total : ${currency.format(total)}",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                "Merci pour votre commande",
                style: pw.TextStyle(fontSize: 10),
              ),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
