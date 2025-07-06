import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyCartWidget extends StatelessWidget {
  const EmptyCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200.w,
              height: 200.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80.sp,
                color: Colors.grey[400],
              ),
            ),
            
            SizedBox(height: 40.h),
            
            // Main message
            Text(
              'Your cart is empty',
              style: GoogleFonts.montserrat(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 12.h),
            
            // Subtitle
            Text(
              'Explore our cities and shop for different frames.',
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 40.h),
            
            // Shop now button
            ElevatedButton(
              onPressed: () {
                // Add your navigation logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Explore Cities',
                    style: GoogleFonts.montserrat(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}