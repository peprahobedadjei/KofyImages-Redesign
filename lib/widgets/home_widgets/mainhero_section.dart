import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kofyimages/services/get_all_hero_images.dart';
import 'dart:async';

class HeroSection extends StatefulWidget {
  final Function(String) onSearchSubmitted;
  
  const HeroSection({super.key, required this.onSearchSubmitted});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  
  List<String> _heroImages = [];
  int _currentIndex = 0;
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHeroImages();
  }

  Future<void> _loadHeroImages() async {
    try {
      final images = await HeroImagesService.getAllPhotosUrls();
      if (mounted) {
        setState(() {
          _heroImages = images;
          _isLoading = false;
        });
        
        // Start auto-scroll if images are loaded
        if (_heroImages.isNotEmpty) {
          _startAutoScroll();
        }
      }
    } catch (e) {
      print('Error loading hero images: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Fallback to default image if API fails
          _heroImages = ['assets/landing.jpg'];
        });
      }
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_heroImages.isNotEmpty) {
        _currentIndex = (_currentIndex + 1) % _heroImages.length;
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _handleSearch() {
    final query = _searchController.text.trim();
    widget.onSearchSubmitted(query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildImageCarousel() {
    if (_isLoading) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    if (_heroImages.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/landing.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemCount: _heroImages.length,
          itemBuilder: (context, index) {
            final imageUrl = _heroImages[index];
            
            // Use CachedNetworkImage for network URLs, AssetImage for local assets
            if (imageUrl.startsWith('http')) {
              return CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 800,
                memCacheHeight: 600,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.error,
                    color: Colors.grey[600],
                    size: 32.sp,
                  ),
                ),
              );
            } else {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400.h,
      width: double.infinity,
      child: Stack(
        children: [
          // Background carousel
          Positioned.fill(
            child: _buildImageCarousel(),
          ),
          
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withAlpha(204),
                    Colors.black.withAlpha(153),
                    Colors.black.withAlpha(102),
                    Colors.black.withAlpha(51),
                  ],
                ),
              ),
            ),
          ),

          // Main content - Centered
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Main headline
                  Text(
                    'Experience different cultures through their food, lifestyle and festivals',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Search box with attached button
                  Container(
                    width: double.infinity,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Text input field
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: (_) => _handleSearch(),
                            decoration: InputDecoration(
                              hintText: 'Search for Cities',
                              hintStyle: GoogleFonts.montserrat(
                                fontSize: 16.sp,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 12.h,
                              ),
                            ),
                            style: GoogleFonts.montserrat(
                              fontSize: 16.sp,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        // Search button
                        GestureDetector(
                          onTap: _handleSearch,
                          child: Container(
                            width: 80.w,
                            height: 50.h,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10.r),
                                bottomRight: Radius.circular(10.r),
                              ),
                            ),
                            child: Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}