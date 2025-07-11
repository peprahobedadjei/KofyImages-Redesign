// ignore_for_file: use_build_context_synchronously, unused_local_variable, prefer_final_fields

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kofyimages/constants/connection_listener.dart';
import 'package:kofyimages/constants/login_modal.dart';
import 'package:kofyimages/models/city_details_model.dart';
import 'package:kofyimages/screens/login_page.dart';
import 'package:kofyimages/screens/register.dart';
import 'package:kofyimages/services/auth_login.dart';
import 'package:kofyimages/services/ike_lifestyle_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoImageWidget extends StatefulWidget {
  final List<ContentItem> content;

  const VideoImageWidget({super.key, required this.content});

  @override
  State<VideoImageWidget> createState() => _VideoImageWidgetState();
}

class _VideoImageWidgetState extends State<VideoImageWidget> {
  // Keep track of content items and their loading states
  late List<ContentItem> _contentItems;
  Set<int> _likingItems = {}; // Track which items are currently being liked

  @override
  void initState() {
    super.initState();
    _contentItems = List.from(widget.content);
  }

  @override
  void didUpdateWidget(VideoImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _contentItems = List.from(widget.content);
    }
  }

String _formatCount(int? count) {
  if (count == null || count == 0) {
    return ''; // Show nothing if count is null or 0
  } else if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1)}M';
  } else if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}K';
  } else {
    return count.toString();
  }
}


  /// Handle like button tap for lifestyle images
  Future<void> _handleLikeTap(int index) async {
    final item = _contentItems[index];
    
    // Only allow liking for lifestyle images (not videos)
    final isVideo = item.youtubeUrl != null && item.youtubeUrl!.isNotEmpty;
    if (isVideo) return;

    // If image is already liked, show message and return
    if (item.likedByUser == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You have already liked this image!',
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if user is logged in
    final isLoggedIn = await AuthLoginService.isLoggedIn();
    
    if (!isLoggedIn) {
      // Show login modal if user is not logged in
      showLoginModal(
        context,
        cityName: item.cityName,
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
              builder: (_) => const ConnectionListener(child: RegistrationPage()),
            ),
          );
        },
      );
      return;
    }
    if (_likingItems.contains(index)) return; // Prevent multiple requests

    setState(() {
      _likingItems.add(index);
    });

    try {
      // Like the lifestyle image
      final likeResponse = await LikeLifestyleImageService.likeLifestyleImage(
        item.id.toString(),
      );
      // Update the content item with new like status
      final updatedItem = ContentItem(
        id: item.id,
        title: item.title,
        youtubeUrl: item.youtubeUrl,
        thumbnailUrl: item.thumbnailUrl,
        imageUrl: item.imageUrl,
        categoryName: item.categoryName,
        cityName: item.cityName,
        createdAt: item.createdAt,
        content: item.content,
        creatorName: item.creatorName,
        isPhotoOfWeek: item.isPhotoOfWeek,
        likesCount: (item.likesCount ?? 0) + 1,
        commentsCount: item.commentsCount,
        likedByUser: true,
      );

      setState(() {
        _contentItems[index] = updatedItem;
      });

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Image liked!',
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      // Handle "already liked" error specifically
      if (e.toString().contains('already liked') || e.toString().contains('Already liked')) {
        // Update local state to reflect that the image is already liked
        final updatedItem = ContentItem(
          id: item.id,
          title: item.title,
          youtubeUrl: item.youtubeUrl,
          thumbnailUrl: item.thumbnailUrl,
          imageUrl: item.imageUrl,
          categoryName: item.categoryName,
          cityName: item.cityName,
          createdAt: item.createdAt,
          content: item.content,
          creatorName: item.creatorName,
          isPhotoOfWeek: item.isPhotoOfWeek,
          likesCount: item.likesCount,
          commentsCount: item.commentsCount,
          likedByUser: true,
        );

        setState(() {
          _contentItems[index] = updatedItem;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You have already liked this image!',
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // Show generic error message for other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to like image. Please try again.',
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _likingItems.remove(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_contentItems.isEmpty) {
      return Center(
        child: Text(
          "No content available.",
          style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _contentItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isVideo = item.youtubeUrl != null && item.youtubeUrl!.isNotEmpty;
        final isLifestyleImage = !isVideo;

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image/Video Section
              GestureDetector(
                onTap: () {
                  if (isVideo) {
                    final videoId = YoutubePlayer.convertUrlToId(
                      item.youtubeUrl!,
                    );
                    if (videoId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConnectionListener(
                            child: YoutubePlayerPage(videoId: videoId),
                          ),
                        ),
                      );
                    }
                  } else if (item.imageUrl != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConnectionListener(
                          child: FullImagePage(imageUrl: item.imageUrl!),
                        ),
                      ),
                    );
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CachedNetworkImage(
                      imageUrl: isVideo
                          ? item.thumbnailUrl ?? ''
                          : item.imageUrl ?? '',
                      height: 250.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      memCacheWidth: 800,
                      memCacheHeight: 600,
                      placeholder: (_, __) => Container(
                        height: 250.h,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 250.h,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                    if (isVideo)
                      Icon(
                        Icons.play_circle_fill,
                        color: Colors.redAccent,
                        size: 64.sp,
                      ),
                  ],
                ),
              ),

              // Content Section (Title, Creator, and Actions)
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item.title,
                      style: GoogleFonts.montserrat(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),

                    // Creator name
                    Text(
                      isVideo
                          ? item.cityName
                          : 'By ${item.creatorName ?? 'Unknown'}',
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Actions Row (Like and Comment) - For images only
                    if (!isVideo) ...[
                      Row(
                        children: [
                          // Like button - Enhanced for lifestyle images
                          GestureDetector(
                            onTap: isLifestyleImage 
                                ? () => _handleLikeTap(index)
                                : null,
                            child: Row(
                              children: [
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 200),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return ScaleTransition(scale: animation, child: child);
                                  },
                                  child: _likingItems.contains(index)
                                      ? SizedBox(
                                          width: 26.sp,
                                          height: 26.sp,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.red,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          key: ValueKey('${item.id}_${item.likedByUser}'),
                                          item.likedByUser == true
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: item.likedByUser == true
                                              ? Colors.red
                                              : (isLifestyleImage ? Colors.black87 : Colors.grey),
                                          size: 26.sp,
                                        ),
                                ),
                                SizedBox(width: 6.w),
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  child: Text(
                                    key: ValueKey('${item.id}_${item.likesCount}'),
                                    // Use actual likesCount from API, fallback to 0 if null
                                    _formatCount(item.likesCount),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.w),

                          // Comment button
                          GestureDetector(
                            onTap: () {
                              // Handle comment action
                              // You can implement comment functionality here
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.message_sharp,
                                  color: Colors.black87,
                                  size: 26.sp,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  // Use actual commentsCount from API, fallback to 0 if null
                                  _formatCount(item.commentsCount),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class YoutubePlayerPage extends StatefulWidget {
  final String videoId;
  const YoutubePlayerPage({super.key, required this.videoId});

  @override
  State<YoutubePlayerPage> createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Force landscape orientation when video page opens
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    // Return to portrait orientation when leaving video page
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white, size: 12.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: YoutubePlayerBuilder(
          player: YoutubePlayer(controller: _controller),
          builder: (context, player) {
            return player;
          },
        ),
      ),
    );
  }
}

class FullImagePage extends StatelessWidget {
  final String imageUrl;

  const FullImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: PhotoView(
              imageProvider: CachedNetworkImageProvider(imageUrl),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
          Positioned(
            top: 40.h,
            left: 10.w,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}