// widgets/popular_cities_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kofyimages/models/popular_cities_model.dart';
import 'package:kofyimages/services/popular_cities_service.dart';
import 'package:kofyimages/screens/city_detail_page.dart';
import 'package:kofyimages/screens/all_popular_cities_page.dart';
import 'package:kofyimages/constants/connection_listener.dart';

class PopularCitiesWidget extends StatefulWidget {
  const PopularCitiesWidget({super.key});

  @override
  State<PopularCitiesWidget> createState() => _PopularCitiesWidgetState();
}

class _PopularCitiesWidgetState extends State<PopularCitiesWidget> {
  List<PopularCity> _popularCities = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPopularCities();
  }

  String formatLikes(int count) {
    if (count == 0) return '';
    if (count >= 1000) {
      double value = count / 1000;
      return '${value.toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Future<void> _loadPopularCities() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final cities = await PopularCitiesService.getPopularCities();
      if (mounted) {
        setState(() {
          _popularCities = cities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Popular Cities',
                      style: GoogleFonts.montserrat(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Explore the world\'s most loved destinations',
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (_popularCities.length > 6)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ConnectionListener(
                            child: AllPopularCitiesPage(cities: _popularCities),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View All',
                            style: GoogleFonts.montserrat(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Content Section
          _isLoading
              ? _buildLoadingState()
              : _errorMessage.isNotEmpty
              ? _buildErrorState()
              : _popularCities.isEmpty
              ? _buildEmptyState()
              : _buildCitiesContent(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200.h,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 200.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.grey[400]),
            SizedBox(height: 12.h),
            Text(
              'Failed to load popular cities',
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please check your internet connection',
              style: GoogleFonts.montserrat(
                fontSize: 12.sp,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadPopularCities,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.montserrat(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_city_outlined,
              size: 48.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 12.h),
            Text(
              'No popular cities found',
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Popular cities will appear here',
              style: GoogleFonts.montserrat(
                fontSize: 12.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCitiesContent() {
    // Show maximum 6 cities in the home page
    final displayCities = _popularCities.take(6).toList();

    return Column(
      children: [
        Container(
          height: 200.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: displayCities.length,
            itemBuilder: (context, index) {
              final city = displayCities[index];
              return _buildCityCard(city, index);
            },
          ),
        ),

        // Show "View All" button at bottom if there are more than 6 cities
        if (_popularCities.length > 6)
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ConnectionListener(
                      child: AllPopularCitiesPage(cities: _popularCities),
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All ${_popularCities.length} Cities',
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.arrow_forward, color: Colors.black, size: 16.sp),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCityCard(PopularCity city, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                ConnectionListener(child: CityDetailPage(cityName: city.name)),
          ),
        );
      },
      child: Container(
        width: 160.w,
        margin: EdgeInsets.only(right: index == 5 ? 0 : 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(26, 0, 0, 0),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // City image
              city.thumbnailUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: city.thumbnailUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 400,
                      memCacheHeight: 300,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.location_city,
                          color: Colors.grey[600],
                          size: 32.sp,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.location_city,
                        color: Colors.grey[600],
                        size: 32.sp,
                      ),
                    ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color.fromARGB(179, 0, 0, 0)],
                  ),
                ),
              ),

              // City information
              Positioned(
                bottom: 16.h,
                left: 12.w,
                right: 12.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.cityPart.isNotEmpty ? city.cityPart : city.name,
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      city.countryPart.isNotEmpty
                          ? city.countryPart
                          : city.country,
                      style: GoogleFonts.montserrat(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Color.fromARGB(204, 255, 255, 255),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Popularity indicator
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(150, 255, 255, 255),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, color: Colors.red, size: 12.sp),
                      SizedBox(width: 4.w),
                      city.likesCount > 0
                          ? Text(
                              formatLikes(city.likesCount),
                              style: GoogleFonts.montserrat(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
