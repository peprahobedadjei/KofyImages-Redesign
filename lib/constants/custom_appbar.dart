import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kofyimages/screens/cart.dart';
import 'package:kofyimages/constants/connection_listener.dart';
import 'package:kofyimages/screens/home.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ConnectionListener(child: MyHomePage()),
                    ),
                  );
                },
                child: SizedBox(
                  width: 100.w,
                  height: 150.h,
                  child: Image.asset(
                    'assets/logo_white.JPG',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Icons on the right
              Row(
                children: [
                  // Cart Icon
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ConnectionListener(child: CartPage()),
                        ),
                      );
                    },
                    child: Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.black,
                              size: 24.sp,
                            ),
                          ),
                          // Cart badge
                          Positioned(
                            right: 0.w,
                            top: 0.h,
                            child: Container(
                              height: 16.h,
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              decoration: BoxDecoration(
                                // color: Colors.red,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              // child: Center(
                              //   child: Text(
                              //     '0', // You can make this dynamic later
                              //     style: TextStyle(
                              //       color: Colors.white,
                              //       fontSize: 10.sp,
                              //       fontWeight: FontWeight.bold,
                              //     ),
                              //   ),
                              // ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Hamburger menu wrapped in Builder to access Scaffold
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.menu,
                          color: Colors.black,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(95.h);
}
