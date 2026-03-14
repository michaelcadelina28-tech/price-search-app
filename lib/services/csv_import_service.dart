import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../models/product.dart';
import 'database_service.dart';

class CsvImportService {
  final _db = DatabaseService();

  Future<ImportResult> importFromCsv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult(success: false, message: 'No file selected.');
      }

      final content = await File(result.files.single.path!).readAsString();
      final rows = const CsvToListConverter(eol: '\n').convert(content);

      if (rows.isEmpty) {
        return ImportResult(success: false, message: 'CSV file is empty.');
      }

      // Skip header row if first cell matches known header names
      final dataRows = _hasHeader(rows[0]) ? rows.sublist(1) : rows;

      if (dataRows.isEmpty) {
        return ImportResult(success: false, message: 'No data rows found.');
      }

      final products = <Product>[];
      final errors   = <String>[];

      for (int i = 0; i < dataRows.length; i++) {
        final row = dataRows[i];
        if (row.isEmpty || row.every((c) => c.toString().trim().isEmpty)) continue;
        try {
          final p = Product.fromCsvRow(row);
          if (p.description.isNotEmpty) products.add(p);
        } catch (e) {
          errors.add('Row ${i + 2}: $e');
        }
      }

      if (products.isEmpty) {
        return ImportResult(
          success: false,
          message: 'No valid items found.\n\nExpected column order:\n'
              'itemNo, Description, quantity, regularprice, retailprice, vendor, encoded',
        );
      }

      await _db.importProducts(products);

      String msg = '✅ Successfully imported ${products.length} items!';
      if (errors.isNotEmpty) msg += '\n\n⚠️ ${errors.length} rows skipped due to errors.';

      return ImportResult(success: true, message: msg, count: products.length);
    } catch (e) {
      return ImportResult(success: false, message: 'Import failed: $e');
    }
  }

  bool _hasHeader(List<dynamic> row) {
    if (row.isEmpty) return false;
    final first = row[0].toString().toLowerCase().trim();
    return ['itemno', 'item_no', 'item no', 'description', 'name'].contains(first);
  }
}

class ImportResult {
  final bool success;
  final String message;
  final int count;
  ImportResult({required this.success, required this.message, this.count = 0});
}
