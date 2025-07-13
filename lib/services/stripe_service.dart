// services/stripe_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kofyimages/models/frame_models.dart';

// Create the Riverpod provider for StripePaymentService
final stripePaymentProvider = Provider<StripePaymentService>((ref) {
  return StripePaymentService();
});

class CustomerDetails {
  final String name;
  final String email;
  final String? phone;
  final CustomerAddress billingAddress;
  final CustomerAddress? shippingAddress;

  CustomerDetails({
    required this.name,
    required this.email,
    this.phone,
    required this.billingAddress,
    this.shippingAddress,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      'address': billingAddress.toMap(),
    };
  }

  CustomerAddress get effectiveShippingAddress =>
      shippingAddress ?? billingAddress;
}

class CustomerAddress {
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  CustomerAddress({
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  Map<String, dynamic> toMap() {
    return {
      'line1': line1,
      if (line2 != null && line2!.isNotEmpty) 'line2': line2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
    };
  }
}

// Payment result classes
class PaymentResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? orderData;
  final String? errorCode;

  PaymentResult({
    required this.success,
    this.message,
    this.orderData,
    this.errorCode,
  });
}

String buildPrettyOrderSummary(List<CartItem> items) {
  return items
      .asMap()
      .entries
      .map((entry) {
        final i = entry.key + 1;
        final itm = entry.value;
        return '''
Item $i:
Name: ${itm.productName}
Qty : ${itm.productQuantity}
Price: \$${itm.productPrice}
Size : ${itm.productSize}
Color: ${itm.productFrameColor}
Type : ${itm.productType}
'''
            .trim();
      })
      .join('\n\n');
}

class StripePaymentService {
  final Dio _dio = Dio();

  // Your backend API base URL
  static const String _baseUrl =
      'https://kofyimages-9dae18892c9f.herokuapp.com/api';
  static final String _apiKey = dotenv.env['API_KEY']!;

  // Store the order data from create-payment-intent response
  Map<String, dynamic>? _currentOrderData;

  Future<PaymentResult> processPayment({
    required String amount,
    required String currency,
    required String merchantName,
    required CustomerDetails customerDetails,
    required List<CartItem> cartItems,
  }) async {
    try {
      // Step 1: Initialize payment sheet
      await initPaymentSheet(
        amount: amount,
        currency: currency,
        merchantName: merchantName,
        customerDetails: customerDetails,
        cartItems: cartItems,
      );

      // Step 2: Present payment sheet
      await presentPaymentSheet();

      // Step 3: Payment successful - return the order data
      return PaymentResult(
        success: true,
        message: 'Payment completed successfully!',
        orderData: _currentOrderData,
      );
    } catch (e) {
      // Handle different types of errors
      if (e is StripeException) {
        print(e.toString());
        return _handleStripeError(e);
      } else {
        return PaymentResult(
          success: false,
          message: 'Payment failed: ${e.toString()}',
          errorCode: 'unknown_error',
        );
      }
    }
  }

  PaymentResult _handleStripeError(StripeException e) {
    switch (e.error.code) {
      case FailureCode.Canceled:
        return PaymentResult(
          success: false,
          message: 'Payment was cancelled',
          errorCode: 'payment_cancelled',
        );
      case FailureCode.Failed:
        return PaymentResult(
         
          success: false,
          message: 'Payment failed: ${e.error.message}',
          errorCode: 'payment_failed',
        );
      case FailureCode.Timeout:
        return PaymentResult(
          success: false,
          message: 'Payment timed out. Please try again.',
          errorCode: 'payment_timeout',
        );
      default:
        return PaymentResult(
          success: false,
          message: 'Payment error: ${e.error.message}',
          errorCode: e.error.code.toString(),
        );
    }
  }

  Future<void> initPaymentSheet({
    required String amount,
    required String currency,
    required String merchantName,
    required CustomerDetails customerDetails,
    required List<CartItem> cartItems,
  }) async {
    try {
      // Call your backend to create payment intent
      final paymentData = await _createPaymentIntentViaBackend(
        amount,
        currency,
        customerDetails,
        merchantName,
        cartItems,
      );

      // Store the order data for later use
      _currentOrderData = paymentData;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentData['client_secret'],
          merchantDisplayName: merchantName,
          customerId:
              paymentData['customer']['email'], // Use customer email or ID
          style: ThemeMode.light,
          billingDetails: BillingDetails(
            name: customerDetails.name,
            email: customerDetails.email,
            phone: customerDetails.phone,
            address: Address(
              line1: customerDetails.billingAddress.line1,
              line2: customerDetails.billingAddress.line2,
              city: customerDetails.billingAddress.city,
              state: customerDetails.billingAddress.state,
              postalCode: customerDetails.billingAddress.postalCode,
              country: customerDetails.billingAddress.country,
            ),
          ),
        ),
      );
    } catch (e) {
      throw Exception('Failed to initialize payment sheet: $e');
    }
  }

  Future<void> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      // Re-throw StripeException to be handled by processPayment
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntentViaBackend(
    String amount,
    String currency,
    CustomerDetails customerDetails,
    String merchantName,
    List<CartItem> cartItems,
  ) async {
    try {
      // Convert amount to cents (multiply by 100)
      final amountInCents = (double.parse(amount) * 100).toInt();

      // Create order summary
      final orderSummary = buildPrettyOrderSummary(cartItems);

      final requestBody = {
        'amount': amountInCents,
        'currency': currency,
        'merchant_name': merchantName,
        'customer_details': {
          'name': customerDetails.name,
          'email': customerDetails.email,
          'phone': customerDetails.phone,
          'billing_address': {
            'line1': customerDetails.billingAddress.line1,
            'line2': customerDetails.billingAddress.line2,
            'city': customerDetails.billingAddress.city,
            'state': customerDetails.billingAddress.state,
            'postal_code': customerDetails.billingAddress.postalCode,
            'country': customerDetails.billingAddress.country,
          },
          if (customerDetails.shippingAddress != null)
            'shipping_address': {
              'line1': customerDetails.shippingAddress!.line1,
              'line2': customerDetails.shippingAddress!.line2,
              'city': customerDetails.shippingAddress!.city,
              'state': customerDetails.shippingAddress!.state,
              'postal_code': customerDetails.shippingAddress!.postalCode,
              'country': customerDetails.shippingAddress!.country,
            },
        },
        'order_items': cartItems.map((item) => item.toJson()).toList(),
        'order_summary': orderSummary,
      };

      final response = await _dio.post(
        '$_baseUrl/create-payment-intent/',
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Backend error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Backend error: ${e.response!.statusCode} - ${e.response!.data}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get the current order data
  Map<String, dynamic>? getCurrentOrderData() {
    return _currentOrderData;
  }

  // Clear the current order data
  void clearCurrentOrderData() {
    _currentOrderData = null;
  }
}
