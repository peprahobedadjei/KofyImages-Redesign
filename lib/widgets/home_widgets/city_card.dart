import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kofyimages/constants/connection_listener.dart';
import 'package:kofyimages/models/city_model.dart';
import 'package:kofyimages/screens/city_detail_page.dart';

class VerticalCityCard extends StatelessWidget {
  final City city;

  const VerticalCityCard({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConnectionListener(
              child: CityDetailPage(cityName: city.cityPart),
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // City image with CachedNetworkImage
            Container(
              height: 250.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: city.thumbnailUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 800, // Add this
                  memCacheHeight: 600, // Add this
                  //  // maxWidthDiskCache: 1000, // Add this // Add this
                  // maxHeightDiskCache: 800, // Add this
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.grey[400],
                          size: 32.sp,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Image not available',
                          style: GoogleFonts.montserrat(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // City name and country
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                city.formattedName,
                style: GoogleFonts.montserrat(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
