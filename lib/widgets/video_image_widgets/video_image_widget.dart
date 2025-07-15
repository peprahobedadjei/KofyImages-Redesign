// ignore_for_file: prefer_final_fields, use_build_context_synchronously, deprecated_member_use

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
import 'package:kofyimages/services/delete_lifestyle.dart';
import 'package:kofyimages/services/ike_lifestyle_image.dart';
import 'package:kofyimages/widgets/comments/comment.dart';
import 'package:photo_view/photo_view.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoImageWidget extends StatefulWidget {
  final List<ContentItem> content;
  final VoidCallback? onContentUpdated; // Add callback for content updates
  final Future<void> Function()? onRefresh; // Add this line

  const VideoImageWidget({
    super.key,
    required this.content,
    this.onContentUpdated,
    this.onRefresh, // Add this new parameter
  });
  @override
  State<VideoImageWidget> createState() => VideoImageWidgetState();
}

class VideoImageWidgetState extends State<VideoImageWidget> {
  // Add this method to your VideoImageWidgetState class:
  void _showCommentsBottomSheet(BuildContext context, ContentItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(
        photoId: item.id.toString(),
        photoTitle: item.title,
        onCommentCountChanged: (newCount) {
          // Update the comment count in the current item
          final index = _contentItems.indexWhere(
            (content) => content.id == item.id,
          );
          if (index != -1) {
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
              commentsCount: newCount, // Update with new count
              likedByUser: item.likedByUser,
              user: item.user,
            );

            setState(() {
              _contentItems[index] = updatedItem;
            });
          }
        },
      ),
    );
  }

  /// Refresh the content by reloading from the original source
  Future<void> refreshContent() async {
    // If there's an onRefresh callback, call it
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    }

    // Reload current user in case auth state changed
    await _loadCurrentUser();

    // Reset content to original
    setState(() {
      _contentItems = List.from(widget.content);
    });
  }

  // Keep track of content items and their loading states
  late List<ContentItem> _contentItems;
  Set<int> _likingItems = {}; // Track which items are currently being liked
  Set<int> _deletingItems = {}; // Track which items are currently being deleted
  String? _currentUsername; // Store current user's username

  @override
  void initState() {
    super.initState();
    _contentItems = List.from(widget.content);
    _loadCurrentUser();
  }

  @override
  void didUpdateWidget(VideoImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _contentItems = List.from(widget.content);
    }
  }

  /// Load current user's username
  Future<void> _loadCurrentUser() async {
    try {
      final username = await AuthLoginService.getUserDisplayName();
      setState(() {
        _currentUsername = username;
      });
    } catch (e) {
      // User not logged in or error getting username
      _currentUsername = null;
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

  /// Handle like/unlike button tap for lifestyle images
  Future<void> _handleLikeTap(int index) async {
    final item = _contentItems[index];

    // Only allow liking for lifestyle images (not videos)
    final isVideo = item.youtubeUrl != null && item.youtubeUrl!.isNotEmpty;
    if (isVideo) return;

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
              builder: (_) =>
                  const ConnectionListener(child: RegistrationPage()),
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
      // Toggle like/unlike the lifestyle image
      final response = await LikeLifestyleImageService.toggleLikeLifestyleImage(
        item.id.toString(),
      );

      final action = response['action'];
      final isLiked = action == 'liked';

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
        likesCount: isLiked
            ? (item.likesCount ?? 0) + 1
            : (item.likesCount ?? 1) - 1,
        commentsCount: item.commentsCount,
        likedByUser: isLiked,
        user: item.user,
      );

      setState(() {
        _contentItems[index] = updatedItem;
      });

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isLiked ? 'Image liked!' : 'Image unliked!',
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          duration: Duration(seconds: 1),
          backgroundColor: isLiked ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update like status. Please try again.',
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _likingItems.remove(index);
      });
    }
  }

  /// Handle delete button tap for lifestyle images
  Future<void> _handleDeleteTap(int index) async {
    final item = _contentItems[index];

    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Delete Image',
          style: GoogleFonts.montserrat(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${item.title}"? This action cannot be undone.',
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    if (_deletingItems.contains(index)) return; // Prevent multiple requests

    setState(() {
      _deletingItems.add(index);
    });

    try {
      // Delete the lifestyle image
      await DeleteLifestyleImageService.deleteLifestyleImage(
        item.id.toString(),
      );

      // Remove the item from the list
      setState(() {
        _contentItems.removeAt(index);
      });

      // Call the callback to notify parent widget
      if (widget.onContentUpdated != null) {
        widget.onContentUpdated!();
      }

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Image deleted successfully!',
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete image: ${e.toString()}',
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _deletingItems.remove(index);
      });
    }
  }

  /// Check if current user can delete this image
  bool _canDeleteImage(ContentItem item) {
    if (_currentUsername == null || item.user == null) return false;
    return _currentUsername == item.user!.username;
  }

  /// Get list of image URLs and their corresponding indices (excluding videos)
  List<Map<String, dynamic>> _getImageList() {
    List<Map<String, dynamic>> imageList = [];
    for (int i = 0; i < _contentItems.length; i++) {
      final item = _contentItems[i];
      final isVideo = item.youtubeUrl != null && item.youtubeUrl!.isNotEmpty;
      if (!isVideo && item.imageUrl != null) {
        imageList.add({
          'imageUrl': item.imageUrl!,
          'originalIndex': i,
          'title': item.title,
          'creatorName': item.creatorName,
        });
      }
    }
    return imageList;
  }

  @override
  Widget build(BuildContext context) {
    if (_contentItems.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.category_outlined, size: 64.sp, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              'No content available',
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Contents for this category is coming soon',
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
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
        final canDelete = _canDeleteImage(item);

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
              // Image/Video Section with delete button overlay
              Stack(
                children: [
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
                        // Get the list of images and find the current image index
                        final imageList = _getImageList();
                        final currentImageIndex = imageList.indexWhere(
                          (img) => img['originalIndex'] == index,
                        );

                        if (currentImageIndex != -1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConnectionListener(
                                child: ImageGalleryPage(
                                  imageList: imageList,
                                  initialIndex: currentImageIndex,
                                ),
                              ),
                            ),
                          );
                        }
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
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
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

                  // Delete button - only show for lifestyle images that belong to current user
                  if (isLifestyleImage && canDelete)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: GestureDetector(
                        onTap: () => _handleDeleteTap(index),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: _deletingItems.contains(index)
                              ? SizedBox(
                                  width: 20.sp,
                                  height: 20.sp,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                        ),
                      ),
                    ),
                ],
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
                                  transitionBuilder:
                                      (
                                        Widget child,
                                        Animation<double> animation,
                                      ) {
                                        return ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        );
                                      },
                                  child: _likingItems.contains(index)
                                      ? SizedBox(
                                          width: 26.sp,
                                          height: 26.sp,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.red,
                                                ),
                                          ),
                                        )
                                      : Icon(
                                          key: ValueKey(
                                            '${item.id}_${item.likedByUser}',
                                          ),
                                          item.likedByUser == true
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: item.likedByUser == true
                                              ? Colors.red
                                              : (isLifestyleImage
                                                    ? Colors.black87
                                                    : Colors.grey),
                                          size: 26.sp,
                                        ),
                                ),
                                SizedBox(width: 6.w),
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  child: Text(
                                    key: ValueKey(
                                      '${item.id}_${item.likesCount}',
                                    ),
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
                            onTap: () =>
                                _showCommentsBottomSheet(context, item),
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

class ImageGalleryPage extends StatefulWidget {
  final List<Map<String, dynamic>> imageList;
  final int initialIndex;

  const ImageGalleryPage({
    super.key,
    required this.imageList,
    required this.initialIndex,
  });

  @override
  State<ImageGalleryPage> createState() => _ImageGalleryPageState();
}

class _ImageGalleryPageState extends State<ImageGalleryPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextImage() {
    if (_currentIndex < widget.imageList.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousImage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PageView for images
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageList.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imageData = widget.imageList[index];
              return Center(
                child: PhotoView(
                  imageProvider: CachedNetworkImageProvider(
                    imageData['imageUrl'],
                  ),
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  loadingBuilder: (context, event) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2.0,
                ),
              );
            },
          ),

          // Close button
          Positioned(
            top: 40.h,
            left: 10.w,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Image counter
          Positioned(
            top: 50.h,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.imageList.length}',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Image title and creator (bottom overlay)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.imageList[_currentIndex]['title'],
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'By ${widget.imageList[_currentIndex]['creatorName'] ?? 'Unknown'}',
                    style: GoogleFonts.montserrat(
                      color: Colors.white70,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Previous arrow
          if (_currentIndex > 0)
            Positioned(
              left: 20.w,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _goToPreviousImage,
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
            ),

          // Next arrow
          if (_currentIndex < widget.imageList.length - 1)
            Positioned(
              right: 20.w,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _goToNextImage,
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
