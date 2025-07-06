import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kofyimages/constants/custom_appbar.dart';
import 'package:kofyimages/constants/sidedrawer.dart';
import 'package:kofyimages/widgets/cart_widgets/empty_cart_widget.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

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
                  'Cart Page',
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Cart content
          const Expanded(
            child: EmptyCartWidget(),
          ),
        ],
      ),
    );
  }
}