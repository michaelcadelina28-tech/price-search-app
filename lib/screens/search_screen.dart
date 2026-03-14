import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import '../services/csv_import_service.dart';
import '../widgets/product_card.dart';
import 'import_guide_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _db  = DatabaseService();
  final _csv = CsvImportService();

  List<Product> _products      = [];
  List<String>  _vendors       = ['All'];
  String        _selectedVendor = 'All';
  bool  _isLoading   = false;
  bool  _isImporting = false;
  int   _totalItems  = 0;
  String _query      = '';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    await _refreshVendors();
    await _doSearch();
    final count = await _db.getProductCount();
    setState(() { _totalItems = count; _isLoading = false; });
  }

  Future<void> _refreshVendors() async {
    final v = await _db.getVendors();
    setState(() => _vendors = ['All', ...v]);
  }

  Future<void> _doSearch() async {
    setState(() => _isLoading = true);
    final results = _query.isEmpty
        ? await _db.getAllProducts(vendor: _selectedVendor)
        : await _db.searchProducts(_query, vendor: _selectedVendor);
    setState(() { _products = results; _isLoading = false; });
  }

  Future<void> _importCsv() async {
    setState(() => _isImporting = true);
    final result = await _csv.importFromCsv();
    setState(() => _isImporting = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result.message),
      backgroundColor: result.success ? Colors.green[700] : Colors.red[700],
      duration: const Duration(seconds: 4),
    ));

    if (result.success) await _loadAll();
  }

  void _onQueryChanged(String v) {
    setState(() => _query = v);
    _doSearch();
  }

  void _onVendorChanged(String v) {
    setState(() => _selectedVendor = v);
    _doSearch();
  }

  // ── build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text('Price Search', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_isImporting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            )
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (v) {
                if (v == 'import') _importCsv();
                if (v == 'guide') Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ImportGuideScreen()));
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'import', child: Row(children: [
                  Icon(Icons.upload_file, color: Color(0xFF1565C0)), SizedBox(width: 8),
                  Text('Import CSV'),
                ])),
                const PopupMenuItem(value: 'guide', child: Row(children: [
                  Icon(Icons.help_outline, color: Colors.grey), SizedBox(width: 8),
                  Text('How to Export CSV'),
                ])),
              ],
            ),
        ],
      ),

      body: Column(
        children: [
          // ── blue sub-header ────────────────────────────────────────────
          Container(
            color: const Color(0xFF1565C0),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              _totalItems == 0
                  ? 'No items yet — import a CSV to start'
                  : '$_totalItems items in database',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),

          // ── search bar ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller: _searchController,
              onChanged: _onQueryChanged,
              decoration: InputDecoration(
                hintText: 'Search by description or item number...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1565C0)),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () { _searchController.clear(); _onQueryChanged(''); })
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // ── vendor filter chips ────────────────────────────────────────
          if (_vendors.length > 1) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _vendors.length,
                itemBuilder: (_, i) {
                  final v = _vendors[i];
                  final selected = v == _selectedVendor;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(v),
                      selected: selected,
                      onSelected: (_) => _onVendorChanged(v),
                      selectedColor: const Color(0xFF1565C0),
                      backgroundColor: Colors.white,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 10),

          // ── results ────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)))
                : _totalItems == 0
                    ? _buildEmptyState()
                    : _products.isEmpty
                        ? _buildNoResults()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                            itemCount: _products.length,
                            itemBuilder: (_, i) => ProductCard(product: _products[i]),
                          ),
          ),
        ],
      ),

      floatingActionButton: _totalItems == 0
          ? FloatingActionButton.extended(
              onPressed: _importCsv,
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.upload_file),
              label: const Text('Import CSV'),
            )
          : null,
    );
  }

  Widget _buildEmptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No Items Yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Import a CSV exported from your\nMySQL database to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ImportGuideScreen())),
            icon: const Icon(Icons.help_outline),
            label: const Text('How to Export from SQLyog'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildNoResults() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
        const SizedBox(height: 12),
        Text('No results for "$_query"',
            style: const TextStyle(fontSize: 16, color: Colors.black54)),
      ],
    ),
  );
}
