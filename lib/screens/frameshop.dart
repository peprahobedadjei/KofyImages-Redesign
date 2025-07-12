// screens/frameshop.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kofyimages/constants/cart_notifier.dart';
import 'package:kofyimages/constants/custom_appbar.dart';
import 'package:kofyimages/constants/sidedrawer.dart';
import 'package:kofyimages/models/frame_models.dart';
import 'package:kofyimages/services/get_all_frames.dart';
import 'package:provider/provider.dart';

class FrameShopPage extends StatefulWidget {
  const FrameShopPage({super.key});

  @override
  State<FrameShopPage> createState() => _FrameShopPageState();
}

class _FrameShopPageState extends State<FrameShopPage> {
  bool isPictureFramesSelected = true;
  List<FrameItem> pictureFrames = [];
  List<FrameItem> paintingFrames = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final futures = await Future.wait([
        ApiService.fetchPictureFrames(),
        ApiService.fetchPaintingFrames(),
      ]);

      setState(() {
        pictureFrames = futures[0];
        paintingFrames = futures[1];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<FrameItem> get currentFrames =>
      isPictureFramesSelected ? pictureFrames : paintingFrames;

  String get currentFrameType =>
      isPictureFramesSelected ? 'Picture' : 'Painting';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: Colors.grey[50],
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
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12.sp),
                SizedBox(width: 8.w),
                Text(
                  'Frame Shop',
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Toggle buttons
          Container(
            margin: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPictureFramesSelected = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: isPictureFramesSelected
                            ? Colors.black
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Center(
                        child: Text(
                          'Picture Frames',
                          style: GoogleFonts.montserrat(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: isPictureFramesSelected
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPictureFramesSelected = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: !isPictureFramesSelected
                            ? Colors.black
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Center(
                        child: Text(
                          'Painting Frames',
                          style: GoogleFonts.montserrat(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: !isPictureFramesSelected
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48.sp,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Error loading frames',
                          style: GoogleFonts.montserrat(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          errorMessage!,
                          style: GoogleFonts.montserrat(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: _fetchData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : currentFrames.isEmpty
                ? Center(
                    child: Text(
                      'No ${currentFrameType.toLowerCase()} frames available',
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(20.w),
                    itemCount: currentFrames.length,
                    itemBuilder: (context, index) {
                      return FrameCard(
                        frameItem: currentFrames[index],
                        frameType: currentFrameType,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class FrameCard extends StatefulWidget {
  final FrameItem frameItem;
  final String frameType;

  const FrameCard({
    super.key,
    required this.frameItem,
    required this.frameType,
  });

  @override
  State<FrameCard> createState() => _FrameCardState();
}

class _FrameCardState extends State<FrameCard> {
  String selectedColor = 'neutral';
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(0.r)),
            child: CachedNetworkImage(
              imageUrl: widget.frameItem.getImageUrl(selectedColor),
              height: 260.h,
              memCacheWidth: 800, // Add this
              memCacheHeight: 600, // Add this
              width: double.infinity,
              fit: BoxFit.contain,
              placeholder: (context, url) => Container(
                height: 200.h,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200.h,
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.error)),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.frameItem.name,
                        style: GoogleFonts.montserrat(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '\$${widget.frameItem.price}',
                      style: GoogleFonts.montserrat(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Frame Size
                Text(
                  'Size: ${widget.frameItem.frameSize}',
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),

                SizedBox(height: 16.h),

                // Color Selection
                Text(
                  'Frame Color:',
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 8.h),

                Row(
                  children: [
                    _buildColorOption('neutral', Colors.grey[300]!),
                    SizedBox(width: 12.w),
                    _buildColorOption('black', Colors.black),
                    SizedBox(width: 12.w),
                    _buildColorOption('brown', Colors.brown),
                  ],
                ),

                SizedBox(height: 16.h),

                // Quantity and Add to Cart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Qty:',
                          style: GoogleFonts.montserrat(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (quantity > 1) {
                                    setState(() {
                                      quantity--;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8.w),
                                  child: Icon(Icons.remove, size: 16.sp),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Text(
                                  quantity.toString(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    quantity++;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8.w),
                                  child: Icon(Icons.add, size: 16.sp),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Add to Cart Button
                    ElevatedButton(
                      onPressed: () {
                        final cartItem = CartItem(
                          productId: widget.frameItem.id,
                          productName: widget.frameItem.name,
                          productFrameColor: selectedColor,
                          productPrice: widget.frameItem.price,
                          productSize: widget.frameItem.frameSize,
                          productType: widget.frameType,
                          productQuantity: quantity,
                          imageUrl: widget.frameItem.getImageUrl(selectedColor),
                        );

                        context.read<CartNotifier>().addItem(cartItem);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added to cart!',
                              style: GoogleFonts.montserrat(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Add to Cart',
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(String color, Color displayColor) {
    final isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: displayColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: color == 'neutral' ? Colors.black : Colors.white,
                size: 20.sp,
              )
            : null,
      ),
    );
  }
}
