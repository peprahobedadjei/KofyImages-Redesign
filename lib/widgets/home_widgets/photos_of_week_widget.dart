import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kofyimages/models/photo_of_week_model.dart';
import 'package:kofyimages/services/get_all_photos_of_the_week.dart';

class PhotosOfWeekWidget extends StatefulWidget {
  const PhotosOfWeekWidget({super.key});

  @override
  State<PhotosOfWeekWidget> createState() => _PhotosOfWeekWidgetState();
}

class _PhotosOfWeekWidgetState extends State<PhotosOfWeekWidget> {
  List<PhotoOfWeek> photos = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  Future<void> _fetchPhotos() async {
    try {
      final response = await PhotoOfWeekService.getAllPhotosOfTheWeek();
      if (response != null && response.photos.isNotEmpty) {
        setState(() {
          photos = response.photos;
          isLoading = false;
          hasError = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  void _showPhotoDetails(PhotoOfWeek photo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Photo preview
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: photo.imageUrl,
                    height: 500.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    memCacheWidth: 800, // Add this
                    memCacheHeight: 600, // Add this
                    maxWidthDiskCache: 1000, // Add this
                    maxHeightDiskCache: 800, // Add this
                    placeholder: (context, url) => Container(
                      height: 200.h,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200.h,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Name
                _buildDetailRow('🏙️', 'Name', photo.title),
                SizedBox(height: 16.h),

                // City
                _buildDetailRow('🌍', 'City', photo.cityName),
                SizedBox(height: 16.h),

                // Creator
                _buildDetailRow('👤', 'Creator', photo.creatorName),
                SizedBox(height: 16.h),

                // Description
                _buildDetailRow(
                  '📝',
                  'Description',
                  photo.photoOfWeekDescription,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String emoji, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: TextStyle(fontSize: 16.sp)),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'Photos of the Week',
              style: GoogleFonts.montserrat(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Content
          SizedBox(
            height: 400.h,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 50.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Failed to load photos',
                          style: GoogleFonts.montserrat(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Please check your internet connection',
                          style: GoogleFonts.montserrat(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),

                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              hasError = false;
                            });
                            _fetchPhotos();
                          },
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
                  )
                : photos.isEmpty
                ? Center(
                    child: Text(
                      'No photos available',
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  )
                : Swiper(
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(26),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Stack(
                            children: [
                              // Photo
                              Hero(
                                tag: 'photo_${photo.id}',
                                child: CachedNetworkImage(
                                  imageUrl: photo.imageUrl,
                                  height: double.infinity,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 800, // Add this
                                  memCacheHeight: 600, // Add this
                                  maxWidthDiskCache: 1000, // Add this
                                  maxHeightDiskCache: 800, // Add this
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.error),
                                      ),
                                ),
                              ),

                              // Gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black],
                                  ),
                                ),
                              ),

                              // Content
                              Positioned(
                                bottom: 20.h,
                                left: 20.w,
                                right: 20.w,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      photo.title,
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      photo.cityName,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    // Details button
                                    ElevatedButton.icon(
                                      onPressed: () => _showPhotoDetails(photo),
                                      icon: const Icon(
                                        Icons.info_outline,
                                        size: 20,
                                      ),
                                      label: const Text('View Details'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 8.h,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20.r,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    pagination: SwiperPagination(
                      alignment: Alignment.bottomCenter,
                      margin: EdgeInsets.only(bottom: 10.h),
                      builder: DotSwiperPaginationBuilder(
                        activeColor: Colors.blue,
                        color: Colors.white,
                        size: 8.0,
                        activeSize: 10.0,
                      ),
                    ),
                    autoplay: true,
                    autoplayDelay: 5000,
                  ),
          ),
        ],
      ),
    );
  }
}
