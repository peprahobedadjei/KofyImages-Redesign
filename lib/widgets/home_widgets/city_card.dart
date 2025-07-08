import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kofyimages/constants/connection_listener.dart';
import 'package:kofyimages/models/city_model.dart';
import 'package:kofyimages/screens/city_detail_page.dart';
import 'package:kofyimages/widgets/review_widget/review_bottom_sheet.dart';

// Import your ReviewBottomSheet here
// import 'package:kofyimages/widgets/review_bottom_sheet.dart';

class VerticalCityCard extends StatefulWidget {
  final City city;
  const VerticalCityCard({super.key, required this.city});

  @override
  State<VerticalCityCard> createState() => _VerticalCityCardState();
}

class _VerticalCityCardState extends State<VerticalCityCard> {
  late City _city;

  @override
  void initState() {
    super.initState();
    _city = widget.city;
  }

  @override
  void didUpdateWidget(VerticalCityCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.city != widget.city) {
      _city = widget.city;
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  void _showReviewBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReviewBottomSheet(
        cityName: _city.cityPart,
        isReviewed: _city.isReviewed,
        onReviewCountChanged: (newCount) {
          setState(() {
            _city = City(
              id: _city.id,
              name: _city.name,
              country: _city.country,
              formattedName: _city.formattedName,
              thumbnailUrl: _city.thumbnailUrl,
              cityPart: _city.cityPart,
              countryPart: _city.countryPart,
              reviewsCount: newCount,
              likesCount: _city.likesCount,
              isLiked: _city.isLiked,
              isReviewed: _city.isReviewed,
              createdAt: _city.createdAt,
            );
          });
        },
        onReviewStatusChanged: (isReviewed) {
          setState(() {
            _city = City(
              id: _city.id,
              name: _city.name,
              country: _city.country,
              formattedName: _city.formattedName,
              thumbnailUrl: _city.thumbnailUrl,
              cityPart: _city.cityPart,
              countryPart: _city.countryPart,
              reviewsCount: _city.reviewsCount,
              likesCount: _city.likesCount,
              isLiked: _city.isLiked,
              isReviewed: isReviewed,
              createdAt: _city.createdAt,
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConnectionListener(
              child: CityDetailPage(cityName: _city.cityPart),
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
                  imageUrl: _city.thumbnailUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 800,
                  memCacheHeight: 600,
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
            // City name and interactions
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // City name
                  Text(
                    _city.formattedName,
                    style: GoogleFonts.montserrat(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),
                  // Like and comment section
                  Row(
                    children: [
                      // Like button (Instagram style)
                      GestureDetector(
                        onTap: () {
                          // Handle like action
                        },
                        child: Row(
                          children: [
                            Icon(
                              _city.isLiked ? Icons.favorite : Icons.favorite_border,
                              color: _city.isLiked ? Colors.red : Colors.black87,
                              size: 26.sp,
                            ),
                            if (_city.likesCount > 0) ...[
                              SizedBox(width: 6.w),
                              Text(
                                _formatCount(_city.likesCount),
                                style: GoogleFonts.montserrat(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      
                      // Comment button (Instagram style)
                      GestureDetector(
                        onTap: _showReviewBottomSheet,
                        child: Row(
                          children: [
                            Icon(
                              Icons.message_sharp,
                              color: Colors.black87,
                              size: 26.sp,
                            ),
                            if (_city.reviewsCount > 0) ...[
                              SizedBox(width: 6.w),
                              Text(
                                _formatCount(_city.reviewsCount),
                                style: GoogleFonts.montserrat(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
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