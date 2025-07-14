// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kofyimages/constants/connection_listener.dart';
import 'package:kofyimages/constants/login_modal.dart';
import 'package:kofyimages/models/city_model.dart';
import 'package:kofyimages/screens/city_detail_page.dart';
import 'package:kofyimages/screens/login_page.dart';
import 'package:kofyimages/screens/register.dart';
import 'package:kofyimages/widgets/review_widget/review_bottom_sheet.dart';
import 'package:kofyimages/services/auth_login.dart';
import 'package:kofyimages/services/like_city.dart';

class VerticalCityCard extends StatefulWidget {
  final City city;
  const VerticalCityCard({super.key, required this.city});

  @override
  State<VerticalCityCard> createState() => _VerticalCityCardState();
}

class _VerticalCityCardState extends State<VerticalCityCard> {
  late City _city;
  bool _isLiking = false;

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

  /// Handle like button tap - only supports liking (no unliking)
  void _handleLikeTap() async {
    // Check if user is logged in
    final isLoggedIn = await AuthLoginService.isLoggedIn();
    if (!isLoggedIn) {
      // Show login modal if user is not logged in
      showLoginModal(
        context,
        cityName: _city.cityPart,
        onLoginPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ConnectionListener(child: LoginPage()),
            ),
          );
        },
        onRegisterPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const ConnectionListener(child: RegistrationPage()),
            ),
          );
        },
      );
      return;
    }

    if (_isLiking) return; // Prevent multiple requests

    setState(() {
      _isLiking = true;
    });

    // Capture the original state before toggling
    final bool wasLiked = _city.isLiked;

    try {
      // Like/Unlike the city
      final likeResponse = await LikeCityService.likeCity(_city.cityPart);

      // Update UI with successful toggle
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
          likesCount: wasLiked ? _city.likesCount - 1 : _city.likesCount + 1,
          isLiked: !wasLiked,
          isReviewed: _city.isReviewed,
          createdAt: _city.createdAt,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasLiked ? 'City unliked!' : 'City liked!',
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: wasLiked ? Colors.red : Colors.green,
        ),
      );
    } catch (e) {
      // Show generic error message for other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update city. Please try again.',
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLiking = false;
      });
    }
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: _city.thumbnailUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 800,
                      memCacheHeight: 600,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
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
                    Container(color: Colors.black.withAlpha(30)),
                    Positioned(
                      bottom: 100.h,
                      left: 35.w,
                      child: DefaultTextStyle(
                        style: GoogleFonts.montserrat(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black45,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        child: AnimatedTextKit(
                          repeatForever: true,
                          pause: Duration(milliseconds: 1000),
                          animatedTexts: [
                            RotateAnimatedText('Explore ${_city.cityPart} →'),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                      // Like button (only liking, no unliking)
                      GestureDetector(
                        onTap: _handleLikeTap,
                        child: Row(
                          children: [
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                    return ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    );
                                  },
                              child: _isLiking
                                  ? SizedBox(
                                      width: 26.sp,
                                      height: 26.sp,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.red,
                                            ),
                                      ),
                                    )
                                  : Icon(
                                      key: ValueKey(_city.isLiked),
                                      _city.isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: _city.isLiked
                                          ? Colors.red
                                          : Colors.black87,
                                      size: 26.sp,
                                    ),
                            ),
                            if (_city.likesCount > 0) ...[
                              SizedBox(width: 6.w),
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 300),
                                child: Text(
                                  key: ValueKey(_city.likesCount),
                                  _formatCount(_city.likesCount),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),

                      // Comment button
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
