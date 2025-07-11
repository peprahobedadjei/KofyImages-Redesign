
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:kofyimages/services/stripe_service.dart';

class PaymentService {
  static Future<bool> makePayment({
    required String amount,
    required String currency,
    required BuildContext context,
  }) async {
    try {
      // Step 1: Create payment intent
      Map<String, dynamic> paymentIntent = await StripeService.createPaymentIntent(
        amount,
        currency,
      );

      // Step 2: Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          style: ThemeMode.system,
          merchantDisplayName: 'KofyImages',
          customFlow: false,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.black,
            ),
          ),
        ),
      );

      // Step 3: Display payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment successful
      return true;
    } on StripeException catch (e) {
      // Handle Stripe-specific errors
      _showErrorDialog(context, 'Payment failed: ${e.error.localizedMessage}');
      return false;
    } catch (e) {
      // Handle other errors
      _showErrorDialog(context, 'An error occurred: ${e.toString()}');
      return false;
    }
  }

  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}