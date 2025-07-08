// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kofyimages/constants/connection_listener.dart';
import 'package:kofyimages/screens/login_page.dart';
import 'package:kofyimages/services/auth_login.dart';
import 'package:kofyimages/services/endpoints.dart';
import 'package:http/http.dart' as http;

class ReviewBottomSheet extends StatefulWidget {
  final String cityName;
  final bool isReviewed;
  final Function(int newReviewCount)? onReviewCountChanged;
  final Function(bool isReviewed)? onReviewStatusChanged;

  const ReviewBottomSheet({
    super.key,
    required this.cityName,
    required this.isReviewed,
    this.onReviewCountChanged,
    this.onReviewStatusChanged,
  });

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoggedIn = false;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  bool _isPosting = false;
  bool _isReviewed = false;

  @override
  void initState() {
    super.initState();
    _isReviewed = widget.isReviewed;
    _loadUserState();
    _fetchReviews();
  }

  Future<void> _loadUserState() async {
    final loggedIn = await AuthLoginService.isLoggedIn();
    setState(() => _isLoggedIn = loggedIn);
  }

  Future<void> _fetchReviews() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.getCityReviews(widget.cityName)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _reviews = data.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _postReview() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    setState(() => _isPosting = true);

    try {
      final response = await AuthLoginService.makeAuthenticatedRequest(
        url: ApiEndpoints.postCityReviews(widget.cityName),
        method: 'POST',
        body: jsonEncode({'name': widget.cityName, 'content': content}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _controller.clear();

        // Update local state
        setState(() {
          _isReviewed = true;
          _isPosting = false;
        });

        // Notify parent about the review count change
        if (widget.onReviewCountChanged != null) {
          widget.onReviewCountChanged!(_reviews.length + 1);
        }

        // Notify parent about review status change
        if (widget.onReviewStatusChanged != null) {
          widget.onReviewStatusChanged!(true);
        }

        // Refresh reviews list
        await _fetchReviews();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Review posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _isPosting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post review')));
      }
    } catch (e) {
      setState(() => _isPosting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Something went wrong')));
    }
  }

    Widget _buildUserAvatar(String username) {
    final firstLetter = username.isNotEmpty ? username[0].toUpperCase() : 'U';
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    final color = colors[username.hashCode % colors.length];


    return CircleAvatar(
      radius: 18.r,
      backgroundColor: color,
      child: Text(
        firstLetter,
        style: GoogleFonts.montserrat(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16.h,
        left: 16.w,
        right: 16.w,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Reviews for ${widget.cityName}',
            style: GoogleFonts.montserrat(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),

          _isLoading
              ? Center(child: CircularProgressIndicator())
                    : _reviews.isEmpty
                    ? Container(
                        padding: EdgeInsets.all(32.h),
                        child: Column(
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              size: 48.sp,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Be the first to make a post!',
                              style: GoogleFonts.montserrat(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
              : SizedBox(
                  height: 300.h,
                  child: ListView.builder(
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      final username = _reviews[index]['user']['username'] ?? 'User';
                      return ListTile(
                        title: Text(
                          review['user']['username'] ?? 'User',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                          ),
                        
                        ),
                        leading:  _buildUserAvatar(username),
                        trailing: Text(timeAgo(review['created_at'])),
                        subtitle: Text(review['content']),
                      );
                    },
                  ),
                ),

          SizedBox(height: 12.h),

          // Show input field only if user is logged in AND hasn't reviewed yet
          if (_isLoggedIn && !_isReviewed) ...[
            Padding(
               padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      minLines: 1,
                      enabled: !_isPosting,
                      decoration: InputDecoration(
                        hintText: 'Write a review...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        contentPadding: EdgeInsets.all(12.w),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: _isPosting ? null : _postReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: _isPosting
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text('Send'),
                  ),
                ],
              ),
            ),
          ] else if (_isLoggedIn && _isReviewed) ...[
            // Show message when user has already reviewed
            Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'You have already reviewed this city',
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Show login button when user is not logged in
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ConnectionListener(child: LoginPage()),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Login to post a review',
                        style: GoogleFonts.montserrat(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    
                  ),
                ),
              ),
            ),
          ],
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
        
      ),
    );
  }
}
String timeAgo(String? isoDateString) {
  final now = DateTime.now().toUtc();
  final dateTime = DateTime.parse(isoDateString!).toUtc();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
  } else {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
