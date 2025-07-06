import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kofyimages/widgets/home_widgets/cities_widget.dart';
import 'package:kofyimages/constants/custom_appbar.dart';
import 'package:kofyimages/widgets/home_widgets/mainhero_section.dart';
import 'package:kofyimages/constants/sidedrawer.dart';
import 'package:kofyimages/constants/connection_listener.dart';
import 'package:kofyimages/widgets/home_widgets/photos_of_week_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _citiesWidgetKey = GlobalKey();
  String _searchQuery = '';

  void _onSearchSubmitted(String query) {
    setState(() {
      _searchQuery = query;
    });

    // Scroll to cities section
    _scrollToCitiesSection();
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
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Hero Section
                SliverToBoxAdapter(
                  child: HeroSection(onSearchSubmitted: _onSearchSubmitted),
                ),
                const SliverToBoxAdapter(child: PhotosOfWeekWidget()),
                SliverToBoxAdapter(
                  child: CitiesWidget(
                    key: _citiesWidgetKey,
                    searchQuery: _searchQuery,
                    parentScrollController:
                        _scrollController, // Pass the scroll controller
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
