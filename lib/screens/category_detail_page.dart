import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kofyimages/constants/custom_appbar.dart';
import 'package:kofyimages/constants/sidedrawer.dart';
import 'package:kofyimages/models/city_details_model.dart';
import 'package:kofyimages/services/get_city_photo.dart';
import 'package:kofyimages/widgets/article_widgets/article_widget.dart';
import 'package:kofyimages/widgets/footer/footer_widget.dart';
import 'dart:async';

class CategoryDetailPage extends StatefulWidget {
  final Category category;
  final CityDetail? cityDetail;

  const CategoryDetailPage({
    super.key,
    required this.category,
    required this.cityDetail,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  List<String> _cityPhotos = [];
  bool _isLoading = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// Initialize the page by fetching city photos
  Future<void> _initializePage() async {
    await _fetchCityPhotos();
    _startAutoScroll();
  }

  /// Fetch city photos from API
  Future<void> _fetchCityPhotos() async {
    if (widget.cityDetail?.name == null) {
      _setFallbackPhoto();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await CityPhotoService.getCityPhotosWithRetry(
        widget.cityDetail!.name,
        maxRetries: 3,
      );

      if (CityPhotoService.isValidResponse(response)) {
        final photoUrls = CityPhotoService.getPhotoUrls(response);
        setState(() {
          _cityPhotos = photoUrls;
          _isLoading = false;
        });
      } else {
        _setFallbackPhoto();
      }
    } catch (e) {
      _setFallbackPhoto();
    }
  }

  /// Set fallback photo when API fails
  void _setFallbackPhoto() {
    setState(() {
      _cityPhotos = widget.cityDetail?.thumbnailUrl != null
          ? [widget.cityDetail!.thumbnailUrl]
          : [];
      _isLoading = false;
    });
  }

  /// Start auto-scroll timer for carousel
  void _startAutoScroll() {
    if (_cityPhotos.length > 1) {
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_pageController.hasClients && mounted) {
          _currentPage = (_currentPage + 1) % _cityPhotos.length;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  /// Stop auto-scroll timer
  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  /// Resume auto-scroll timer
  void _resumeAutoScroll() {
    _stopAutoScroll();
    _startAutoScroll();
  }

  /// Get category-specific content
  Map<String, String> _getCategoryContent() {
    final cityName = widget.cityDetail?.name ?? 'this city';
    final countryName = widget.cityDetail?.country ?? 'this country';

    switch (widget.category.name.toLowerCase()) {
      case 'food':
        return {
          'title': 'Explore cities through restaurants and their foods',
          'subtitle': 'Best restaurants and their meals in $cityName , $countryName',
        };
      case 'lifestyle':
        return {
          'title': 'Explore cities through lifestyle',
          'subtitle': 'Different lifestyles in $cityName, $countryName',
        };
      case 'transport':
        return {
          'title': 'Discover The World With Our Guide.',
          'subtitle': 'Travel Guide for $cityName, $countryName',
        };
      case 'videography':
        return {
          'title': 'Eclectic Street View Videos of $cityName.',
          'subtitle': 'Explore through diverse videos for $cityName, $countryName',
        };
      case 'articles':
        return {
          'title':
              'Discovering $cityName through Articles.',
          'subtitle': 'In-depth articles about $cityName, $countryName',
        };
      default:
        return {
          'title': 'Explore $cityName',
          'subtitle': 'Discover amazing content about $cityName, $countryName',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: Colors.grey[50],
      drawer: const SideDrawer(),
      body: _buildCategoryDetailContent(context),
    );
  }

  Widget _buildCategoryDetailContent(BuildContext context) {
    final categoryContent = _getCategoryContent();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 400.h,
          floating: false,
          pinned: true,
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
            onPressed: () => Navigator.of(context).pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: _buildCarouselSection(categoryContent),
          ),
        ),
        // Categories Section
        SliverToBoxAdapter(
          child: Container(
            color: Colors.grey[50],
            child: Column(
              children: [
                if (widget.category.name.toLowerCase() == 'articles') ...[
                  ArticleWidget(
                    content: widget.category.content,
                  ),
                ] else ...[
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Placeholder for other categories
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: FooterWidget()),
      ],
    );
  }

  Widget _buildCarouselSection(Map<String, String> categoryContent) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Carousel or Loading State
        _buildCarouselContent(),

        // Gradient overlay
        _buildGradientOverlay(),

        // Title and subtitle
        _buildTitleSection(categoryContent),
      ],
    );
  }

  Widget _buildCarouselContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_cityPhotos.isEmpty) {
      return _buildEmptyState();
    }

    return _buildPhotoCarousel();
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              strokeWidth: 3.w,
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey[600],
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'No photos available',
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCarousel() {
    return GestureDetector(
      onPanStart: (_) => _stopAutoScroll(),
      onPanEnd: (_) => _resumeAutoScroll(),
      child: PageView.builder(
        controller: _pageController,
        itemCount: _cityPhotos.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          return _buildPhotoItem(_cityPhotos[index]);
        },
      ),
    );
  }

  Widget _buildPhotoItem(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            strokeWidth: 2.w,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_outlined,
                color: Colors.grey[600],
                size: 32.sp,
              ),
              SizedBox(height: 8.h),
              Text(
                'Image failed to load',
                style: GoogleFonts.montserrat(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
           const Color.fromARGB(77, 0, 0, 0),
            const Color.fromARGB(179, 0, 0, 0)
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(Map<String, String> categoryContent) {
    return Positioned(
      bottom: 60.h,
      left: 20.w,
      right: 20.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            categoryContent['title']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
              shadows: [
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  color: const Color.fromARGB(128, 0, 0, 0),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            categoryContent['subtitle']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color.fromARGB(230, 255, 255, 255),
              height: 1.3,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3,
                  color: const Color.fromARGB(230, 255, 255, 255)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
