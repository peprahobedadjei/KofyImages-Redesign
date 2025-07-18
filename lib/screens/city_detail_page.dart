// pages/city_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kofyimages/constants/connection_listener.dart';
import 'package:kofyimages/constants/custom_appbar.dart';
import 'package:kofyimages/constants/sidedrawer.dart';
import 'package:kofyimages/models/city_details_model.dart';
import 'package:kofyimages/screens/category_detail_page.dart';
import 'package:kofyimages/screens/frameshop.dart';
import 'package:kofyimages/services/get_city_details.dart';
import 'package:kofyimages/widgets/footer/footer_widget.dart';

class CityDetailPage extends StatefulWidget {
  final String cityName;

  const CityDetailPage({super.key, required this.cityName});

  @override
  State<CityDetailPage> createState() => _CityDetailPageState();
}

class _CityDetailPageState extends State<CityDetailPage>
    with WidgetsBindingObserver {

      Future<void> _refreshCityDetails() async {
  await _loadCityDetails();
}
  CityDetail? cityDetail;
  bool isLoading = true;
  String errorMessage = '';
  bool _disposed = false;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposed = true;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // App moved to background - clean up resources
        break;
      case AppLifecycleState.resumed:
        // App resumed - reload if needed
        if (cityDetail == null && !isLoading) {
          _loadCityDetails();
        }
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCityDetails();
  }

  Future<void> _loadCityDetails() async {
    if (_disposed) return;
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final details = await GetCityDetailsService.getCityDetails(
        widget.cityName,
      );
      if (_disposed) return;

      setState(() {
        cityDetail = details;
        isLoading = false;
      });
    } catch (e) {
      if (_disposed) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: Colors.grey[50],
      drawer: const SideDrawer(),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          : errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : _buildCityDetailContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'Failed to load city details',
              style: GoogleFonts.montserrat(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please check your internet connection and try again',
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Error: $errorMessage',
              style: GoogleFonts.montserrat(
                fontSize: 12.sp,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: _loadCityDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityDetailContent() {
    if (cityDetail == null) return const SizedBox.shrink();

    return RefreshIndicator(
       onRefresh: _refreshCityDetails,
      child: CustomScrollView(
        slivers: [
          // Hero Section
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
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // City background image
                  cityDetail!.thumbnailUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: cityDetail!.thumbnailUrl,
                          fit: BoxFit.cover,
                          memCacheWidth: 800,
                          memCacheHeight: 600,
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
                              Icons.error,
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
                            size: 64.sp,
                          ),
                        ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromARGB(77, 0, 0, 0),
                          Color.fromARGB(179, 0, 0, 0),
                        ],
                      ),
                    ),
                  ),
                  // City information
                  Positioned(
                    bottom: 80.h,
                    left: 20.w,
                    right: 20.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cityDetail!.cityPart.isNotEmpty &&
                                  cityDetail!.countryPart.isNotEmpty
                              ? 'The City Of ${cityDetail!.cityPart}, ${cityDetail!.countryPart}'
                              : 'The City Of ${cityDetail!.name}',
                          style: GoogleFonts.montserrat(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Explore the city of ${cityDetail!.name.isNotEmpty ? cityDetail!.name : widget.cityName} through their foods, lifestyle and festivals.',
                          style: GoogleFonts.montserrat(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(230, 255, 255, 255),
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Categories Section
          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey[50],
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore Categories',
                    style: GoogleFonts.montserrat(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Discover different aspects of ${cityDetail!.name.isNotEmpty ? cityDetail!.name : widget.cityName}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Categories Grid or Empty State
                  cityDetail!.categories.isNotEmpty
                      ? _buildCategoriesGrid()
                      : _buildEmptyState(),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: FooterWidget()),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = cityDetail!.categories.values.toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: categories.length + 1, // Add 1 for FrameShop
      itemBuilder: (context, index) {
        if (index < categories.length) {
          final category = categories[index];
          return _buildCategoryCard(category);
        } else {
          // This is the FrameShop card
          return _buildFrameShopCard();
        }
      },
    );
  }

  Widget _buildFrameShopCard() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ConnectionListener(
              child: FrameShopPage(),
            ),
          ),
        );
      },
      child: Container(
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
              // FrameShop image from assets
              Image.asset(
                'assets/frame_card.jpeg', 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.photo_library,
                    color: Colors.grey[600],
                    size: 32.sp,
                  ),
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
              // FrameShop name and item count
              Positioned(
                bottom: 16.h,
                left: 16.w,
                right: 16.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FrameShop',
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '2 categories', 
                      style: GoogleFonts.montserrat(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Color.fromARGB(204, 255, 255, 255),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.category_outlined, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'No categories available',
            style: GoogleFonts.montserrat(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Categories for this city are coming soon',
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ConnectionListener(
              child: CategoryDetailPage(
                category: category,
                cityDetail: cityDetail,
              ),
            ),
          ),
        );
      },
      child: Container(
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
              // Category image
              category.thumbnailUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: category.thumbnailUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 800,
                      memCacheHeight: 600,
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
                          Icons.error,
                          color: Colors.grey[600],
                          size: 24.sp,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.category,
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
              // Category name and content count
              Positioned(
                bottom: 16.h,
                left: 16.w,
                right: 16.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.nameDisplay.isNotEmpty
                          ? category.nameDisplay
                          : category.name,
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${category.content.length} ${category.content.length == 1 ? 'item' : 'items'}',
                      style: GoogleFonts.montserrat(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Color.fromARGB(204, 255, 255, 255),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}