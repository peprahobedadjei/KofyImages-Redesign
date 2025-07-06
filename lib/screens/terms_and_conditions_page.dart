import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kofyimages/constants/custom_appbar.dart';
import 'package:kofyimages/constants/sidedrawer.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(),
      drawer: const SideDrawer(),
      body: Column(
        children: [
          // Breadcrumb navigation
          Container(
            width: double.infinity,
            color: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Home',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 12.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Terms & Conditions',
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Terms content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader("General Terms and Conditions of Use"),
                  _sectionText(
                      "By accessing and placing an order with KofyImages, you confirm that you are in agreement with and bound by the terms..."),

                  _sectionHeader("License"),
                  _sectionText(
                      "KofyImages grants you a revocable, non-exclusive, non-transferable license..."),

                  _sectionHeader("Definitions and Key Terms"),
                  _bulletList([
                    "Cookie: small data stored by your web browser.",
                    "Company: refers to KofyImages, United Kingdom.",
                    "Country: where KofyImages operates (UK).",
                    "Customer: user of KofyImages Service.",
                    "Device: any internet-connected device.",
                    "IP Address: used to identify internet location.",
                    "Personnel: employees or contractors of KofyImages.",
                    "Personal Data: any identifiable personal information.",
                    "Service: KofyImages services offered.",
                    "Website: kofyimages.com",
                    "You: the person using our Service.",
                  ]),

                  _sectionHeader("Restrictions"),
                  _bulletList([
                    "Do not sell, rent, lease, or distribute our service.",
                    "Do not modify, decrypt or reverse engineer the service.",
                    "Do not remove copyright or trademark notices.",
                  ]),

                  _sectionHeader("Payment"),
                  _sectionText(
                      "You agree to pay all fees in accordance with the billing terms..."),

                  _sectionHeader("Return & Refund Policy"),
                  _sectionText(
                      "If you're not satisfied with your purchase, contact us for assistance."),

                  _sectionHeader("Your Suggestions"),
                  _sectionText(
                      "Feedback and suggestions become our property."),

                  _sectionHeader("Your Consent"),
                  _sectionText(
                      "Using our services means you accept these Terms & Conditions."),

                  _sectionHeader("Cookies"),
                  _sectionText(
                      "Cookies help enhance functionality but can be disabled via your browser."),

                  _sectionHeader("Changes to Terms"),
                  _sectionText(
                      "We reserve the right to change these terms at any time."),

                  _sectionHeader("Intellectual Property"),
                  _sectionText(
                      "All content is owned by KofyImages or its licensors."),

                  _sectionHeader("Agreement to Arbitrate"),
                  _sectionText(
                      "Disputes will be resolved through binding arbitration."),

                  _sectionHeader("Contact Us"),
                  _sectionText("Email: info@KofyImages.com"),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 6.h),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _sectionText(String content) {
    return Text(
      content,
      style: GoogleFonts.montserrat(
        fontSize: 14.sp,
        color: Colors.black87,
        height: 1.5,
      ),
    );
  }

  Widget _bulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "• ",
                    style: GoogleFonts.montserrat(fontSize: 14.sp, height: 1.5),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
