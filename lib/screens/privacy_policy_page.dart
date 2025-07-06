import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kofyimages/constants/custom_appbar.dart';
import 'package:kofyimages/constants/sidedrawer.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const SideDrawer(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      'Privacy Policy',
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader("Updated at 2022-08-25"),
                    _sectionText(
                      "KofyImages (\"we,\" \"our,\" or \"us\") is committed to protecting your privacy. This Privacy Policy explains how your personal information is collected, used, and disclosed.",
                    ),
                    _sectionHeader("Definitions and key terms"),
                    _bulletList([
                      "Cookie: Small data saved by your web browser.",
                      "Company: Refers to KofyImages, United Kingdom.",
                      "Device: Internet-connected devices like phones or tablets.",
                      "IP address: Identifies your internet connection location.",
                      "Personal Data: Information that can identify a person.",
                    ]),
                    _sectionHeader("What Information Do We Collect?"),
                    _bulletList([
                      "Name / Username",
                      "Phone Numbers",
                      "Email Addresses",
                      "Mailing and Billing Addresses",
                      "Password",
                    ]),
                    _sectionHeader("How Do We Use The Information?"),
                    _bulletList([
                      "To personalize your experience",
                      "To improve our service and support",
                      "To process transactions",
                      "To send updates, surveys, or newsletters",
                    ]),
                    _sectionHeader("Third-party Information and Sharing"),
                    _sectionText(
                      "We may share collected information with trusted providers, affiliates, or during legal obligations, mergers, etc.",
                    ),
                    _sectionHeader("Security and Storage"),
                    _sectionText(
                      "We use SSL, encryption, and other security measures but cannot guarantee 100% data safety.",
                    ),
                    _sectionHeader("GDPR Compliance"),
                    _sectionText(
                      "We comply with GDPR and allow EU users to request access, deletion, or updates of their data.",
                    ),
                    _sectionHeader("CCPA and CalOPPA"),
                    _sectionText(
                      "California residents have the right to access, delete, or restrict use of their personal information.",
                    ),
                    _sectionHeader("Children's Privacy"),
                    _sectionText(
                      "We do not knowingly collect information from users under 13 years old.",
                    ),
                    _sectionHeader("Changes to This Policy"),
                    _sectionText(
                      "We may update this Privacy Policy. Continued use of our service confirms your acceptance.",
                    ),
                    _sectionHeader("Contact Us"),
                    _sectionText("Email: info@KofyImages.com"),
                  ],
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
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
