// ignore_for_file: unused_local_variable, use_build_context_synchronously, deprecated_member_use

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kofyimages/constants/connection_listener.dart';
import 'package:kofyimages/screens/frameshop.dart';

class BuyaFrameCard extends StatefulWidget {
  const BuyaFrameCard({super.key});

  @override
  State<BuyaFrameCard> createState() => _BuyaFrameCardState();
}

class _BuyaFrameCardState extends State<BuyaFrameCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.h, top: 20.h,right: 20.h,bottom: 0.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConnectionListener(child: FrameShopPage()),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Frame image with asset loader
              Container(
                height: 150.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Asset image
                      Image.asset(
                        'assets/frame.jpeg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_camera_outlined,
                                  color: Colors.grey[400],
                                  size: 32.sp,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Frame image not found',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // Dark overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                      // Animated text
                      Center(
                        child: DefaultTextStyle(
                          style: GoogleFonts.montserrat(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          child: AnimatedTextKit(
                            repeatForever: true,
                            pause: Duration(milliseconds: 2000),
                            animatedTexts: [
                              FadeAnimatedText(
                                'Buy A Painting Frame',
                                duration: Duration(milliseconds: 3000),
                              ),
                              ScaleAnimatedText(
                                'Buy A Picture Frame',
                                duration: Duration(milliseconds: 3000),
                              ),
                              TypewriterAnimatedText(
                                'Frame Your Memories',
                                speed: Duration(milliseconds: 100),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Optional: Add some bottom padding or content
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}