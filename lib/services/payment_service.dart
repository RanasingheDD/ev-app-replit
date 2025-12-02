import '../models/payment.dart';
import 'api_service.dart';

class PaymentService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    String? bookingId,
  }) async {
    return await _api.post('/payments/intent', body: {
      'amount': amount,
      'currency': currency,
      'bookingId': bookingId,
    });
  }

  Future<Payment> confirmPayment(String paymentIntentId) async {
    final response = await _api.post('/payments/confirm', body: {
      'paymentIntentId': paymentIntentId,
    });

    return Payment.fromJson(response);
  }

  Future<Payment> getPaymentById(String paymentId) async {
    final response = await _api.get('/payments/$paymentId');
    return Payment.fromJson(response);
  }

  Future<List<Payment>> getPaymentHistory({int? limit, int? offset}) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final response = await _api.get('/payments', queryParams: queryParams);
    final paymentsJson = response['payments'] as List? ?? response['data'] as List? ?? [];
    return paymentsJson.map((json) => Payment.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Receipt> getReceipt(String sessionId) async {
    final response = await _api.get('/payments/receipts/$sessionId');
    return Receipt.fromJson(response);
  }

  Future<List<Receipt>> getReceiptHistory({int? limit, int? offset}) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final response = await _api.get('/payments/receipts', queryParams: queryParams);
    final receiptsJson = response['receipts'] as List? ?? response['data'] as List? ?? [];
    return receiptsJson.map((json) => Receipt.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> requestRefund({
    required String paymentId,
    required String reason,
  }) async {
    return await _api.post('/payments/$paymentId/refund', body: {
      'reason': reason,
    });
  }

  Future<List<Map<String, dynamic>>> getSavedPaymentMethods() async {
    final response = await _api.get('/payments/methods');
    return List<Map<String, dynamic>>.from(response['methods'] as List? ?? []);
  }

  Future<void> deletePaymentMethod(String methodId) async {
    await _api.delete('/payments/methods/$methodId');
  }
}
