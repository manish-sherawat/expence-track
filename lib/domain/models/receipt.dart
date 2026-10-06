import 'money.dart';

class ReceiptLineItem {
  const ReceiptLineItem({
    required this.id,
    required this.receiptId,
    required this.name,
    this.quantity = 1,
    required this.price,
  });

  final String id;
  final String receiptId;
  final String name;
  final int quantity;
  final Money price;

  ReceiptLineItem copyWith({
    String? id,
    String? receiptId,
    String? name,
    int? quantity,
    Money? price,
  }) {
    return ReceiptLineItem(
      id: id ?? this.id,
      receiptId: receiptId ?? this.receiptId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptLineItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Receipt {
  const Receipt({
    required this.id,
    required this.transactionId,
    required this.merchantName,
    required this.timestamp,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.rawOcrText,
    this.imageUrl,
  });

  final String id;
  final String transactionId;
  final String merchantName;
  final DateTime timestamp;
  final List<ReceiptLineItem> items;
  final Money subtotal;
  final Money tax;
  final Money total;
  final String? rawOcrText;
  final String? imageUrl;

  Receipt copyWith({
    String? id,
    String? transactionId,
    String? merchantName,
    DateTime? timestamp,
    List<ReceiptLineItem>? items,
    Money? subtotal,
    Money? tax,
    Money? total,
    String? rawOcrText,
    String? imageUrl,
  }) {
    return Receipt(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      merchantName: merchantName ?? this.merchantName,
      timestamp: timestamp ?? this.timestamp,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Receipt &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
