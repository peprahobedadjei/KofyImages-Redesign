// screens/all_popular_cities_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kofyimages/models/popular_cities_model.dart';
import 'package:kofyimages/screens/city_detail_page.dart';
import 'package:kofyimages/constants/connection_listener.dart';

class AllPopularCitiesPage extends StatefulWidget {
  final List<PopularCity> cities;

  const AllPopularCitiesPage({
    super.key,
    required this.cities,
  });

  @override
  State<AllPopularCitiesPage> createState() => _AllPopularCitiesPageState();
}

class _AllPopularCitiesPageState extends State<AllPopularCitiesPage> {
  List<PopularCity> _filteredCities = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCities = widget.cities;
    _searchController.addListener(_filterCities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCities = widget.cities
          .where((city) =>
              city.name.toLowerCase().contains(query) ||
              city.country.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Popular Cities',
          style: GoogleFonts.montserrat(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search cities...',
                hintStyle: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  color: Colors.grey[500],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[500],
                  size: 20.sp,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                color: Colors.black,
              ),
            ),
          ),
          
          // Cities Grid
          Expanded(
            child: _filteredCities.isEmpty
                ? _buildEmptyState()
                : Padding(
                    padding: EdgeInsets.all(16.w),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                      ),
                      itemCount: _filteredCities.length,
                      itemBuilder: (context, index) {
                        final city = _filteredCities[index];
                        return _buildCityCard(city);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'No cities found',
            style: GoogleFonts.montserrat(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your search criteria',
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityCard(PopularCity city) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ConnectionListener(
              child: CityDetailPage(cityName: city.name),
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
              // City image
              city.thumbnailUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: city.thumbnailUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 400,
                      memCacheHeight: 400,
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
                    colors: [
                      Colors.transparent,
                      Color.fromARGB(179, 0, 0, 0),
                    ],
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
                      city.countryPart.isNotEmpty ? city.countryPart : city.country,
                      style: GoogleFonts.montserrat(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Color.fromARGB(204, 255, 255, 255),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Stats overlay
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(150, 255, 255, 255),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${city.likesCount}',
                        style: GoogleFonts.montserrat(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
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