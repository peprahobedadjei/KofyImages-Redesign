// lib/services/stripe_service.dart
import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  // Replace with your Stripe publishable key (test key)
  static const String publishableKey = 'pk_test_your_publishable_key_here';

  static init() {
    Stripe.publishableKey = publishableKey;
  }

  // Create a payment intent using Stripe's test endpoint
  static Future<Map<String, dynamic>> createPaymentIntent(
    String amount,
    String currency,
  ) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_your_secret_key_here', 
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      return jsonDecode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  static calculateAmount(String amount) {
    final price = double.parse(amount) * 100; // Convert to cents
    return price.toInt().toString();
  }
}
