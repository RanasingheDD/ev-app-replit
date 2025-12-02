enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  partialRefund,
}

enum PaymentMethod {
  card,
  mobileWallet,
  bankTransfer,
}

class Payment {
  final String id;
  final String userId;
  final String? bookingId;
  final String? sessionId;
  final PaymentMethod method;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String? providerResponse;
  final String? transactionRef;
  final DateTime createdAt;
  final DateTime? completedAt;

  Payment({
    required this.id,
    required this.userId,
    this.bookingId,
    this.sessionId,
    required this.method,
    required this.amount,
    required this.currency,
    required this.status,
    this.providerResponse,
    this.transactionRef,
    required this.createdAt,
    this.completedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      bookingId: json['bookingId'] as String?,
      sessionId: json['sessionId'] as String?,
      method: _parseMethod(json['method'] as String),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'LKR',
      status: _parseStatus(json['status'] as String),
      providerResponse: json['providerResponse'] as String?,
      transactionRef: json['transactionRef'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  static PaymentMethod _parseMethod(String method) {
    switch (method.toLowerCase()) {
      case 'card':
        return PaymentMethod.card;
      case 'mobile_wallet':
      case 'mobilewallet':
        return PaymentMethod.mobileWallet;
      case 'bank_transfer':
      case 'banktransfer':
        return PaymentMethod.bankTransfer;
      default:
        return PaymentMethod.card;
    }
  }

  static PaymentStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'partial_refund':
      case 'partialrefund':
        return PaymentStatus.partialRefund;
      default:
        return PaymentStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'bookingId': bookingId,
      'sessionId': sessionId,
      'method': methodString,
      'amount': amount,
      'currency': currency,
      'status': statusString,
      'providerResponse': providerResponse,
      'transactionRef': transactionRef,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  String get methodString {
    switch (method) {
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.mobileWallet:
        return 'mobile_wallet';
      case PaymentMethod.bankTransfer:
        return 'bank_transfer';
    }
  }

  String get statusString {
    switch (status) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.processing:
        return 'processing';
      case PaymentStatus.completed:
        return 'completed';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.refunded:
        return 'refunded';
      case PaymentStatus.partialRefund:
        return 'partial_refund';
    }
  }

  String get amountDisplay => 'Rs. ${amount.toStringAsFixed(2)}';

  String get methodDisplayName {
    switch (method) {
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.mobileWallet:
        return 'Mobile Wallet';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
    }
  }
}

class Receipt {
  final String id;
  final String sessionId;
  final String userId;
  final String stationName;
  final String chargerName;
  final DateTime sessionStart;
  final DateTime sessionEnd;
  final double energyDelivered;
  final double totalCost;
  final String currency;
  final Payment? payment;
  final DateTime createdAt;
  final String? pdfUrl;

  Receipt({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.stationName,
    required this.chargerName,
    required this.sessionStart,
    required this.sessionEnd,
    required this.energyDelivered,
    required this.totalCost,
    required this.currency,
    this.payment,
    required this.createdAt,
    this.pdfUrl,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      userId: json['userId'] as String,
      stationName: json['stationName'] as String,
      chargerName: json['chargerName'] as String,
      sessionStart: DateTime.parse(json['sessionStart'] as String),
      sessionEnd: DateTime.parse(json['sessionEnd'] as String),
      energyDelivered: (json['energyDelivered'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'LKR',
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      pdfUrl: json['pdfUrl'] as String?,
    );
  }

  Duration get sessionDuration => sessionEnd.difference(sessionStart);

  String get durationDisplay {
    final hours = sessionDuration.inHours;
    final minutes = sessionDuration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get totalCostDisplay => 'Rs. ${totalCost.toStringAsFixed(2)}';
}
