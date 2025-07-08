import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kofyimages/constants/connection_listener.dart';
import 'package:kofyimages/models/city_details_model.dart';
import 'package:photo_view/photo_view.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoImageWidget extends StatelessWidget {
  final List<ContentItem> content;

  const VideoImageWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return Center(
        child: Text(
          "No content available.",
          style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content.map((item) {
        final isVideo = item.youtubeUrl != null && item.youtubeUrl!.isNotEmpty;

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
                    final videoId = YoutubePlayer.convertUrlToId(item.youtubeUrl!);
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
                    
                    // Actions Row (Like and Comment) - Only for images
                    if (!isVideo) ...[
                      Row(
                        children: [
                          // Like button (Instagram style)
                          GestureDetector(
                            onTap: () {
                              // Handle like action
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  color: Colors.black87,
                                  size: 26.sp,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  '23K',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.w),
                          
                          // Comment button (Instagram style)
                          GestureDetector(
                            onTap: () {
                              // Handle comment action
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
                                  '961',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Spacer to push bookmark icon to the right
                          // const Spacer(),
                          
    
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