import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_PH');
    final isLow      = product.quantity > 0 && product.quantity <= 5;
    final isOutOfStock = product.quantity == 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: item no + description + stock badge ──────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: item no + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.itemNo.isNotEmpty)
                        Text(
                          '#${product.itemNo}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Right: stock badge
                _StockBadge(qty: product.quantity, isLow: isLow, isOut: isOutOfStock),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 10),

            // ── Row 2: prices ────────────────────────────────────────────
            Row(
              children: [
                // Retail price (big, prominent)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RETAIL PRICE',
                        style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₱${fmt.format(product.retailPrice)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                ),
                // Divider
                Container(width: 1, height: 36, color: Colors.grey.shade200),
                const SizedBox(width: 14),
                // Regular / wholesale price (smaller)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WHOLESALE',
                      style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₱${fmt.format(product.regularPrice)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF546E7A),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Row 3: vendor + last updated ─────────────────────────────
            Row(
              children: [
                if (product.vendor.isNotEmpty) ...[
                  const Icon(Icons.storefront_outlined, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      product.vendor,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),
                if (product.encoded.isNotEmpty) ...[
                  const Icon(Icons.update, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    product.encoded,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int qty;
  final bool isLow;
  final bool isOut;
  const _StockBadge({required this.qty, required this.isLow, required this.isOut});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;
    final IconData icon;

    if (isOut) {
      bg = Colors.red.shade50; fg = Colors.red.shade700;
      label = 'Out of Stock'; icon = Icons.remove_circle_outline;
    } else if (isLow) {
      bg = Colors.orange.shade50; fg = Colors.orange.shade700;
      label = 'Low: $qty left'; icon = Icons.warning_amber_outlined;
    } else {
      bg = Colors.green.shade50; fg = Colors.green.shade700;
      label = 'Qty: $qty'; icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
