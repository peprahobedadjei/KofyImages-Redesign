import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kofyimages/constants/connection_listener.dart';
import 'package:kofyimages/screens/cart.dart';
import 'package:kofyimages/screens/faq_page.dart';
import 'package:kofyimages/screens/home.dart';
import 'package:kofyimages/screens/privacy_policy_page.dart';
import 'package:kofyimages/screens/terms_and_conditions_page.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo and contact info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              SizedBox(
                width: 60.w,
                height: 60.h,
                child: Center(
                  child: SizedBox(
                    width: 100.w,
                    height: 150.h,
                    child: Image.asset(
                      'assets/logo_black.JPG',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 16.w),

              // Contact info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Got a burning question?',
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Reach us 24/7',
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[300],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'info@kofyimages.com',
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 32.h),

          // Links sections
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Company',
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildFooterLink('Cities', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ConnectionListener(child: MyHomePage()),
                        ),
                      );
                    }),
                    SizedBox(height: 8.h),
                    _buildFooterLink('FAQ', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ConnectionListener(child: FaqPage()),
                        ),
                      );
                    }),
                    SizedBox(height: 8.h),
                    _buildFooterLink('Contact Us', () {
                      // Handle contact navigation
                    }),
                  ],
                ),
              ),

              // Customer section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer',
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildFooterLink('View Cart', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ConnectionListener(child: CartPage()),
                        ),
                      );
                    }),
                    SizedBox(height: 8.h),
                    _buildFooterLink('Terms and condition', () {
                                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ConnectionListener(child: TermsAndConditionsPage()),
                        ),
                      );
                    }),
                    SizedBox(height: 8.h),
                    _buildFooterLink('Privacy Policy', () {
                                            Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ConnectionListener(child: PrivacyPolicyPage()),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 32.h),

          // Subscribe section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Subscribe',
                style: GoogleFonts.montserrat(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'We update our catalog regularly,\nSubscribe to stay updated.',
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[300],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16.h),

              // Email subscription
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey[700]!, width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter Your Email',
                          hintStyle: GoogleFonts.montserrat(
                            fontSize: 14.sp,
                            color: Colors.grey[400],
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(4.w),
                      child: IconButton(
                        onPressed: () {
                          // Handle email subscription
                        },
                        icon: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          padding: EdgeInsets.all(8.w),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 32.h),

          // Social media and copyright
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Copyright
Expanded(
  child: Text(
    '©${DateTime.now().year}.KofyImages.All rights reserved',
    style: GoogleFonts.montserrat(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: Colors.grey[400],
    ),
  ),
),

              Row(
                children: [
                  _buildSocialIcon(FontAwesomeIcons.facebookF, () {
                    _launchURL(
                      'https://www.facebook.com/people/KofyImages/100088051583463/',
                    );
                  }),
                  SizedBox(width: 12.w),
                  _buildSocialIcon(FontAwesomeIcons.xTwitter, () {
                    _launchURL('https://x.com/KofyImages');
                  }),
                  SizedBox(width: 12.w),
                  _buildSocialIcon(FontAwesomeIcons.instagram, () {
                    _launchURL('https://www.instagram.com/kofy_images/');
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[700]!),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(icon, color: Colors.grey[300], size: 18.sp),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      try {
        final Uri uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e2) {
        //add error catching here 
      }
    }
  }
}
