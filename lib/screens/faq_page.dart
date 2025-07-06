import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kofyimages/constants/custom_appbar.dart';
import 'package:kofyimages/constants/sidedrawer.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const SideDrawer(),
      body: Column(
        children: [

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
                  'FAQ',
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

     
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: ListView(
                children: [
                  _buildQuestion(
                    "What is KofyImages?",
                    "KofyImages is a platform to explore Cities through pictures. It gives first hand view of Cities and also gives the user an experience of various cities available on the platform.",
                  ),
                  _buildQuestion(
                    "How to place an order?",
                    "You can buy a frame by selecting from available cities, then place an order and checkout.",
                  ),
                  _buildQuestion(
                    "How do I create an account with KofyImages?",
                    "Create an account by signing up to become a user.",
                  ),
                  _buildQuestion(
                    "What payments methods can I use?",
                    "You can only pay by providing your card information at the checkout using either your Visa, Mastercard, debit cards.",
                  ),
                  _buildQuestion(
                    "Tracking my order",
                    "KofyImages will send tracking details once an item is shipped for delivery.",
                  ),
                  _buildQuestion(
                    "How many days does it take to receive an order?",
                    "For delivery, your product will be delivered between 1-7 days, at most 7 days.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(String title, String answer) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            answer,
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
