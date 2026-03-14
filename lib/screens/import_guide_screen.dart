import 'package:flutter/material.dart';

class ImportGuideScreen extends StatelessWidget {
  const ImportGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text('How to Export CSV from SQLyog'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Required CSV format ──────────────────────────────────────
          _InfoCard(
            icon: Icons.format_list_bulleted,
            title: 'Required CSV Column Order',
            color: const Color(0xFF1565C0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your CSV must have these columns in this exact order:',
                    style: TextStyle(fontSize: 14)),
                const SizedBox(height: 10),
                _col('1', 'itemNo',       'Item number / code',           Colors.purple),
                _col('2', 'Description',  'Product description (required)', Colors.blue),
                _col('3', 'quantity',     'Stock quantity on hand',       Colors.teal),
                _col('4', 'regularprice', 'Wholesale / cost price',       Colors.orange),
                _col('5', 'retailprice',  'Selling price to customer',    Colors.green),
                _col('6', 'vendor',       'Supplier / vendor name',       Colors.indigo),
                _col('7', 'encoded',      'Last update date',             Colors.grey),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Example:\nitemNo,Description,quantity,regularprice,retailprice,vendor,encoded\n'
                    '1001,Milo 300g,100,42.00,52.50,Nestle PH,2024-01-15\n'
                    '1002,Lucky Me Pancit,200,10.00,14.00,Monde Nissin,2024-01-20',
                    style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── SQL Query option ─────────────────────────────────────────
          _InfoCard(
            icon: Icons.code,
            title: 'Step 1A: Export Using SQL Query (Recommended)',
            color: Colors.indigo,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Run this query in SQLyog, then export the result as CSV:',
                    style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'SELECT\n'
                    '  itemNo,\n'
                    '  Description,\n'
                    '  quantity,\n'
                    '  regularprice,\n'
                    '  retailprice,\n'
                    '  vendor,\n'
                    '  encoded\n'
                    'FROM items\n'
                    'ORDER BY Description;',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Color(0xFF80CBC4),
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _note('After running the query, right-click the result grid '
                    '→ "Export" → "CSV" to save the file.'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── GUI Export ───────────────────────────────────────────────
          _InfoCard(
            icon: Icons.computer,
            title: 'Step 1B: Export via SQLyog GUI',
            color: Colors.green[700]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _Step('1', 'Open SQLyog and connect to your database'),
                _Step('2', 'Right-click the "items" table in the left panel'),
                _Step('3', 'Select "Backup/Export" → "Export Table Data as CSV"'),
                _Step('4', 'In the column list, make sure the order is:\nitemNo → Description → quantity → regularprice → retailprice → vendor → encoded'),
                _Step('5', 'Tick "Include column names" (adds header row)'),
                _Step('6', 'Click Export and save the file'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Transfer to phone ────────────────────────────────────────
          _InfoCard(
            icon: Icons.phone_android,
            title: 'Step 2: Transfer CSV to Your Phone',
            color: Colors.teal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _Step('A', 'Via USB cable — copy CSV to phone storage'),
                _Step('B', 'Via Messenger / Viber — send file to yourself, then download'),
                _Step('C', 'Via Email — email to yourself, open attachment on phone'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Import in app ────────────────────────────────────────────
          _InfoCard(
            icon: Icons.upload_file,
            title: 'Step 3: Import in App',
            color: Colors.orange[800]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Step('1', 'Tap ⋮ menu (top-right corner)'),
                const _Step('2', 'Tap "Import CSV"'),
                const _Step('3', 'Navigate to your CSV file and tap it'),
                const _Step('4', 'Done! Search is now available offline'),
                const SizedBox(height: 10),
                _note('Every import replaces all existing data.\n'
                    'Re-import whenever prices are updated in your system.'),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static Widget _col(String n, String col, String desc, Color c) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Container(
        width: 20, height: 20,
        decoration: BoxDecoration(color: c.withOpacity(0.15), shape: BoxShape.circle),
        child: Center(child: Text(n, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: c))),
      ),
      const SizedBox(width: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
        child: Text(col, style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: c, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(width: 6),
      Expanded(child: Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black54))),
    ]),
  );

  static Widget _note(String text) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.orange.shade50,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.orange.shade200),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.info_outline, color: Colors.orange, size: 15),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87))),
    ]),
  );
}

// ── reusable widgets ────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;
  const _InfoCard({required this.icon, required this.title, required this.color, required this.child});

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.grey.shade200),
    ),
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color))),
        ]),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        child,
      ]),
    ),
  );
}

class _Step extends StatelessWidget {
  final String number;
  final String text;
  const _Step(this.number, this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 22, height: 22,
        decoration: BoxDecoration(
          color: const Color(0xFF1565C0).withOpacity(0.1), shape: BoxShape.circle),
        child: Center(child: Text(number,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)))),
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(text,
          style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4))),
    ]),
  );
}
