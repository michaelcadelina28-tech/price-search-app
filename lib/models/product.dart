class Product {
  final int? id;
  final String itemNo;
  final String description;
  final int quantity;
  final double regularPrice;
  final double retailPrice;
  final String vendor;
  final String encoded;

  Product({
    this.id,
    required this.itemNo,
    required this.description,
    required this.quantity,
    required this.regularPrice,
    required this.retailPrice,
    required this.vendor,
    required this.encoded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemNo': itemNo,
      'description': description,
      'quantity': quantity,
      'regularPrice': regularPrice,
      'retailPrice': retailPrice,
      'vendor': vendor,
      'encoded': encoded,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      itemNo: map['itemNo']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      quantity: (map['quantity'] ?? 0).toInt(),
      regularPrice: (map['regularPrice'] ?? 0).toDouble(),
      retailPrice: (map['retailPrice'] ?? 0).toDouble(),
      vendor: map['vendor']?.toString() ?? '',
      encoded: map['encoded']?.toString() ?? '',
    );
  }

  // CSV column order: itemNo, Description, quantity, regularprice, retailprice, vendor, encoded
  factory Product.fromCsvRow(List<dynamic> row) {
    return Product(
      itemNo:       row.length > 0 ? row[0].toString().trim() : '',
      description:  row.length > 1 ? row[1].toString().trim() : '',
      quantity:     row.length > 2 ? int.tryParse(row[2].toString().trim()) ?? 0 : 0,
      regularPrice: row.length > 3 ? double.tryParse(row[3].toString().trim()) ?? 0.0 : 0.0,
      retailPrice:  row.length > 4 ? double.tryParse(row[4].toString().trim()) ?? 0.0 : 0.0,
      vendor:       row.length > 5 ? row[5].toString().trim() : '',
      encoded:      row.length > 6 ? row[6].toString().trim() : '',
    );
  }
}
