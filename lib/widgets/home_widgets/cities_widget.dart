import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kofyimages/models/city_model.dart';
import 'package:kofyimages/services/get_all_cities.dart';
import 'package:kofyimages/widgets/home_widgets/city_card.dart';

class CitiesWidget extends StatefulWidget {
  final String searchQuery;
  final ScrollController? parentScrollController; // Add this parameter

  const CitiesWidget({
    super.key,
    this.searchQuery = '',
    this.parentScrollController, // Add this parameter
  });

  @override
  State<CitiesWidget> createState() => CitiesWidgetState();
}

class CitiesWidgetState extends State<CitiesWidget> {

Future<void> refreshCities() async {
  setState(() {
    isLoading = true;
    errorMessage = '';
  });
  await _loadCities();
}
  List<City> allCities = [];
  List<City> filteredCities = [];
  bool isLoading = true;
  String errorMessage = '';


  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  @override
  void didUpdateWidget(CitiesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _filterCities();
    }
  }

  Future<void> _loadCities() async {
    try {
      final fetchedCities = await GetAllCitiesService.getAllCities();
      setState(() {
        allCities = fetchedCities;
        _filterCities();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _filterCities() {
    setState(() {
      if (widget.searchQuery.isEmpty) {
        filteredCities = List.from(allCities);
      } else {
        filteredCities = allCities.where((city) {
          return city.formattedName.toLowerCase().contains(
            widget.searchQuery.toLowerCase(),
          );
        }).toList();
      }
    });
  }


  // // Add this method to scroll to cities section
  // void _scrollToCitiesSection() {
  //   if (widget.parentScrollController != null) {
  //     final targetPosition =
  //         400.h + 1400.h + 190.h; // Same position as in MyHomePage

  //     widget.parentScrollController!.animateTo(
  //       targetPosition,
  //       duration: const Duration(milliseconds: 600),
  //       curve: Curves.easeInOut,
  //     );
  //   }
  // }


    void _scrollawayCitiesSection() {
    if (widget.parentScrollController != null) {
      final targetPosition =
          400.h - 150.h - 190.h; // Same position as in MyHomePage

      widget.parentScrollController!.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }





  Widget _buildSearchResultsHeader() {
    if (widget.searchQuery.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Icon(Icons.search, size: 20.sp, color: Colors.grey[600]),
          SizedBox(width: 8.w),
          Text(
            '${filteredCities.length} ${filteredCities.length == 1 ? 'city' : 'cities'}',
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and subtitle
            Text(
              'Curated cities collections',
              style: GoogleFonts.montserrat(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              'Explore diverse collections of cities, their foods, lifestyle and festivals',
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),

            SizedBox(height: 24.h),

            // Search results header
            _buildSearchResultsHeader(),

            // Cities list - Vertical layout with pagination
            isLoading
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.h),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
                  )
                : errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 50.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Failed to load cities',
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
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                                errorMessage = '';
                              });
                              _loadCities();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
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
                  )
                : filteredCities.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.h),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            widget.searchQuery.isEmpty
                                ? 'No cities available'
                                : 'City not found for "${widget.searchQuery}"',
                            style: GoogleFonts.montserrat(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (widget.searchQuery.isNotEmpty) ...[
                            SizedBox(height: 8.h),
ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          onPressed:() {
            _scrollawayCitiesSection();
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 0, left: 8, right: 8),
            child: Text(
                    'Search for another city',
                    style: GoogleFonts.montserrat(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
    
                          ],
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      // Current page cities
                      Column(
                        children: filteredCities.map((city) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: VerticalCityCard(city: city,),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
