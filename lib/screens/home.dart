// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kofyimages/screens/city_detail_page.dart';
import 'package:kofyimages/widgets/footer/footer_widget.dart';
import 'package:kofyimages/widgets/home_widgets/buy_frame.dart';
import 'package:kofyimages/widgets/home_widgets/cities_widget.dart';
import 'package:kofyimages/constants/custom_appbar.dart';
import 'package:kofyimages/widgets/home_widgets/mainhero_section.dart';
import 'package:kofyimages/constants/sidedrawer.dart';
import 'package:kofyimages/constants/connection_listener.dart';
import 'package:kofyimages/widgets/home_widgets/photos_of_week_widget.dart';
import 'package:kofyimages/models/city_model.dart';
import 'package:kofyimages/services/get_all_cities.dart';
import 'package:kofyimages/widgets/home_widgets/popular_cities_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isRefreshing = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _citiesWidgetKey = GlobalKey();
  String _searchQuery = '';
  List<City> _allCities = []; // Store all cities for search comparison
  bool _citiesLoaded = false;
  final GlobalKey<CitiesWidgetState> _citiesWidgetStateKey =
      GlobalKey<CitiesWidgetState>();
  final GlobalKey<HeroSectionState> _heroSectionStateKey =
      GlobalKey<HeroSectionState>();
  final GlobalKey<PopularCitiesWidgetState> _popularCitiesWidgetStateKey =
      GlobalKey<PopularCitiesWidgetState>();
  final GlobalKey<PhotosOfWeekWidgetState> _photosOfWeekWidgetStateKey =
      GlobalKey<PhotosOfWeekWidgetState>();
  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      // Create a list of refresh operations
      List<Future> refreshOperations = [];

      // Add hero section refresh
      if (_heroSectionStateKey.currentState != null) {
        refreshOperations.add(
          _heroSectionStateKey.currentState!.refreshHeroImages(),
        );
      }

      // Add cities data refresh
      refreshOperations.add(_loadCities());

      // Add cities widget refresh
      if (_citiesWidgetStateKey.currentState != null) {
        refreshOperations.add(
          _citiesWidgetStateKey.currentState!.refreshCities(),
        );
      }

      // Add popular cities refresh
      if (_popularCitiesWidgetStateKey.currentState != null) {
        refreshOperations.add(
          _popularCitiesWidgetStateKey.currentState!.refreshPopularCities(),
        );
      }

      // Add photos of week refresh
      if (_photosOfWeekWidgetStateKey.currentState != null) {
        refreshOperations.add(
          _photosOfWeekWidgetStateKey.currentState!.refreshPhotos(),
        );
      }

      // Wait for all refresh operations to complete
      await Future.wait(refreshOperations);
    } catch (e) {
      // Handle error if needed
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  // Load cities for search comparison
  Future<void> _loadCities() async {
    try {
      final fetchedCities = await GetAllCitiesService.getAllCities();
      setState(() {
        _allCities = fetchedCities;
        _citiesLoaded = true;
      });
    } catch (e) {
      setState(() {
        _citiesLoaded = true;
      });
    }
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchQuery = '';
      });
      return;
    }

    final trimmedQuery = query.trim();

    // Check if cities are loaded
    if (!_citiesLoaded) {
      // If cities aren't loaded yet, just filter and scroll
      setState(() {
        _searchQuery = trimmedQuery;
      });
      _scrollToCitiesSection();
      return;
    }

    // Check for exact match with city name or cityPart (case-insensitive)
    City? exactMatch;
    try {
      exactMatch = _allCities.firstWhere(
        (city) =>
            city.formattedName.toLowerCase() == trimmedQuery.toLowerCase() ||
            city.cityPart.toLowerCase() == trimmedQuery.toLowerCase() ||
            city.name.toLowerCase() == trimmedQuery.toLowerCase(),
      );
    } catch (e) {
      exactMatch = null;
    }

    if (exactMatch != null) {
      // Show loading indicator briefly before navigation
      _showNavigationFeedback(exactMatch);
    } else {
      // No exact match found, scroll to cities and filter
      setState(() {
        _searchQuery = trimmedQuery;
      });
      _scrollToCitiesSection();
    }
  }

  void _showNavigationFeedback(City city) {
    // Show a brief loading/navigation feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening ${city.formattedName.isNotEmpty ? city.formattedName : city.name}...',
        ),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Colors.black87,
      ),
    );

    // Add a small delay for better UX
    Future.delayed(const Duration(milliseconds: 500), () {
      _navigateToCityDetails(city);
    });
  }

  void _navigateToCityDetails(City city) {
    // Navigate to CityDetailPage using the cityPart (as shown in your existing code)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConnectionListener(
          child: CityDetailPage(
            cityName: city.cityPart.isNotEmpty ? city.cityPart : city.name,
          ),
        ),
      ),
    );
  }

  void _scrollToCitiesSection() {
    final targetPosition = 400.h + 220.h + 190.h;
    _scrollController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionListener(
      child: Scaffold(
        appBar: const CustomAppBar(),
        backgroundColor: Colors.grey[50],
        drawer: const SideDrawer(),
        body: Stack(
          children: [
            // Scrollable content
            RefreshIndicator(
              onRefresh: _refreshData,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Hero Section
                  SliverToBoxAdapter(
                    child: HeroSection(
                      key: _heroSectionStateKey,
                      onSearchSubmitted: _onSearchSubmitted,
                    ),
                  ),
                  const SliverToBoxAdapter(child: BuyaFrameCard()),
                  SliverToBoxAdapter(
                    child: PopularCitiesWidget(
                      key: _popularCitiesWidgetStateKey,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: PhotosOfWeekWidget(key: _photosOfWeekWidgetStateKey),
                  ),
                  SliverToBoxAdapter(
                    child: CitiesWidget(
                      key: _citiesWidgetStateKey,
                      searchQuery: _searchQuery,
                      parentScrollController: _scrollController,
                    ),
                  ),
                  const SliverToBoxAdapter(child: FooterWidget()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
