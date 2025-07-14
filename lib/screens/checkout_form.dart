// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';
import 'package:kofyimages/services/stripe_service.dart';
import 'package:kofyimages/models/frame_models.dart';

class CheckoutFormScreen extends ConsumerStatefulWidget {
  final double totalAmount;
  final int totalItems;
  final List<CartItem> cartItems;

  const CheckoutFormScreen({
    super.key,
    required this.totalAmount,
    required this.totalItems,
    required this.cartItems,
  });

  @override
  ConsumerState<CheckoutFormScreen> createState() => _CheckoutFormScreenState();
}

class _CheckoutFormScreenState extends ConsumerState<CheckoutFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Billing Address Controllers
  final _billingLine1Controller = TextEditingController();
  final _billingLine2Controller = TextEditingController();
  final _billingCityController = TextEditingController();
  final _billingStateController = TextEditingController();
  final _billingPostalController = TextEditingController();

  // Shipping Address Controllers
  final _shippingLine1Controller = TextEditingController();
  final _shippingLine2Controller = TextEditingController();
  final _shippingCityController = TextEditingController();
  final _shippingStateController = TextEditingController();
  final _shippingPostalController = TextEditingController();

  // Country selections
  Country? _selectedBillingCountry;
  Country? _selectedShippingCountry;

  bool _sameAsShipping = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Set default country to US
    _selectedBillingCountry = Country.parse('US');
    _selectedShippingCountry = Country.parse('US');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _billingLine1Controller.dispose();
    _billingLine2Controller.dispose();
    _billingCityController.dispose();
    _billingStateController.dispose();
    _billingPostalController.dispose();
    _shippingLine1Controller.dispose();
    _shippingLine2Controller.dispose();
    _shippingCityController.dispose();
    _shippingStateController.dispose();
    _shippingPostalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: GoogleFonts.montserrat(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary
                    _buildOrderSummary(),
                    SizedBox(height: 24.h),

                    // Contact Information
                    _buildSectionTitle('Contact Information'),
                    SizedBox(height: 16.h),
                    _buildContactFields(),
                    SizedBox(height: 24.h),

                    // Billing Address
                    _buildSectionTitle('Billing Address'),
                    SizedBox(height: 16.h),
                    _buildAddressFields(isBilling: true),
                    SizedBox(height: 24.h),

                    // Shipping Address Toggle
                    _buildShippingToggle(),
                    SizedBox(height: 16.h),

                    // Shipping Address (if different)
                    if (!_sameAsShipping) ...[
                      _buildSectionTitle('Shipping Address'),
                      SizedBox(height: 16.h),
                      _buildAddressFields(isBilling: false),
                      SizedBox(height: 24.h),
                    ],
                  ],
                ),
              ),
            ),

            // Payment Button
            _buildPaymentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.montserrat(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Items (${widget.totalItems})',
                style: GoogleFonts.montserrat(fontSize: 14.sp),
              ),
              Text(
                '\$${widget.totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.montserrat(fontSize: 14.sp),
              ),
            ],
          ),
          Divider(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.montserrat(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${widget.totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.montserrat(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildContactFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _emailController,
          label: 'Email Address',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          keyboardType: TextInputType.phone,
                    validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAddressFields({required bool isBilling}) {
    final line1Controller = isBilling
        ? _billingLine1Controller
        : _shippingLine1Controller;
    final line2Controller = isBilling
        ? _billingLine2Controller
        : _shippingLine2Controller;
    final cityController = isBilling
        ? _billingCityController
        : _shippingCityController;
    final stateController = isBilling
        ? _billingStateController
        : _shippingStateController;
    final postalController = isBilling
        ? _billingPostalController
        : _shippingPostalController;

    return Column(
      children: [
        _buildTextField(
          controller: line1Controller,
          label: 'Street Address',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter street address';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: line2Controller,
          label: 'Apartment, suite, etc.',
                    validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your Apartment, suite, etc number';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: cityController,
                label: 'City',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter city';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildTextField(
                controller: stateController,
                label: 'State',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter state';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: postalController,
                label: 'ZIP Code',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ZIP code';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildCountryPicker(isBilling: isBilling),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCountryPicker({required bool isBilling}) {
    final selectedCountry = isBilling ? _selectedBillingCountry : _selectedShippingCountry;
    
    return GestureDetector(
      onTap: () {
        showCountryPicker(
          context: context,
          showPhoneCode: false,
          onSelect: (Country country) {
            setState(() {
              if (isBilling) {
                _selectedBillingCountry = country;
              } else {
                _selectedShippingCountry = country;
              }
            });
          },
          countryListTheme: CountryListThemeData(
            borderRadius: BorderRadius.circular(8.r),
            inputDecoration: InputDecoration(
              labelText: 'Search',
              hintText: 'Start typing to search',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8.r),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Text(
              selectedCountry?.flagEmoji ?? '🇺🇸',
              style: TextStyle(fontSize: 18.sp),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                selectedCountry?.name ?? 'United States',
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingToggle() {
    return Row(
      children: [
        Checkbox(
          value: _sameAsShipping,
          onChanged: (value) {
            setState(() {
              _sameAsShipping = value ?? true;
            });
          },
        ),
        Expanded(
          child: Text(
            'Shipping address is the same as billing address',
            style: GoogleFonts.montserrat(fontSize: 14.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPaymentButton() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          onPressed: _isProcessing ? null : _processPayment,
          child: _isProcessing
              ? SizedBox(
                  height: 20.h,
                  width: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Complete Payment - \$${widget.totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.montserrat(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate country selections
    if (_selectedBillingCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a billing country')),
      );
      return;
    }

    if (!_sameAsShipping && _selectedShippingCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a shipping country')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final stripeService = ref.read(stripePaymentProvider);

      // Create customer details
      final customerDetails = CustomerDetails(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        billingAddress: CustomerAddress(
          line1: _billingLine1Controller.text,
          line2: _billingLine2Controller.text.isEmpty
              ? null
              : _billingLine2Controller.text,
          city: _billingCityController.text,
          state: _billingStateController.text,
          postalCode: _billingPostalController.text,
          country: _selectedBillingCountry!.countryCode, // This returns the 2-letter code
        ),
        shippingAddress: _sameAsShipping
            ? null
            : CustomerAddress(
                line1: _shippingLine1Controller.text,
                line2: _shippingLine2Controller.text.isEmpty
                    ? null
                    : _shippingLine2Controller.text,
                city: _shippingCityController.text,
                state: _shippingStateController.text,
                postalCode: _shippingPostalController.text,
                country: _selectedShippingCountry!.countryCode, // This returns the 2-letter code
              ),
      );

      // Process payment and get result
      final result = await stripeService.processPayment(
        amount: widget.totalAmount.toStringAsFixed(0),
        currency: 'usd',
        merchantName: 'KofyImages',
        customerDetails: customerDetails,
        cartItems: widget.cartItems,
      );

      if (mounted) {
        if (result.success) {
          // Payment successful - show success dialog with order details
          _showSuccessDialog(result.orderData!);
        } else {
          // Payment failed or cancelled - show appropriate message
          _showErrorDialog(result);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          PaymentResult(
            success: false,
            message: 'Unexpected error: ${e.toString()}',
            errorCode: 'unexpected_error',
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showSuccessDialog(Map<String, dynamic> orderData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 16.h),

              // Title
              Text(
                'Payment Successful!',
                style: GoogleFonts.montserrat(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              // Description
              Text(
                'Your order has been placed successfully. We will reach out to confirm the order details.',
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              // OK Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(
                      context,
                    ).pop(true); // Return to previous screen with success
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(PaymentResult result) {
    Color iconColor = Colors.red;
    IconData icon = Icons.error;
    String title = 'Payment Failed';
    String message =
        result.message ?? 'An error occurred during payment processing.';

    // Customize based on error type
    if (result.errorCode == 'payment_cancelled') {
      iconColor = Colors.orange;
      icon = Icons.cancel;
      title = 'Payment Cancelled';
      message =
          'No worries! Your payment was cancelled. You can try again whenever you\'re ready.';
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error/Cancel Icon
              Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 32.sp),
              ),
              SizedBox(height: 16.h),

              // Title
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              // Description
              Text(
                message,
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              // OK Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}