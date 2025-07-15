// ignore_for_file: use_build_context_synchronously, deprecated_member_use, prefer_final_fields

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kofyimages/constants/connection_listener.dart';
import 'package:kofyimages/screens/login_page.dart';
import 'package:kofyimages/services/auth_login.dart';
import 'package:http/http.dart' as http;

class CommentsBottomSheet extends StatefulWidget {
  final String photoId;
  final String photoTitle;
  final Function(int newCommentCount)? onCommentCountChanged;

  const CommentsBottomSheet({
    super.key,
    required this.photoId,
    required this.photoTitle,
    this.onCommentCountChanged,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoggedIn = false;
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isPosting = false;
  String? _currentUsername;
  Set<int> _deletingComments = {}; // Track which comments are being deleted

  @override
  void initState() {
    super.initState();
    _loadUserState();
    _loadCurrentUser();
    _fetchComments();
  }

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

  Future<void> _showDeleteConfirmation(int commentId) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Delete Comment',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete this comment? This action cannot be undone.',
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
                style: GoogleFonts.montserrat(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(
                'Delete',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteComment(commentId);
    }
  }

  Future<void> _deleteComment(int commentId) async {
    if (_deletingComments.contains(commentId)) return; // Prevent multiple requests

    setState(() {
      _deletingComments.add(commentId);
    });

    try {
      final response = await AuthLoginService.makeAuthenticatedRequest(
        url: "https://kofyimages-9dae18892c9f.herokuapp.com/api/lifestyle-photos/${widget.photoId}/comments/$commentId/",
        method: 'DELETE',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Remove comment from local list
        setState(() {
          _comments.removeWhere((comment) => comment['id'] == commentId);
        });

        // Update comment count
        if (widget.onCommentCountChanged != null) {
          widget.onCommentCountChanged!(_comments.length);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Comment deleted successfully!',
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete comment',
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong',
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _deletingComments.remove(commentId);
      });
    }
  }

  Future<void> _loadUserState() async {
    final loggedIn = await AuthLoginService.isLoggedIn();
    setState(() => _isLoggedIn = loggedIn);
  }

  Future<void> _fetchComments() async {
    try {
      final response = await http.get(
        Uri.parse("https://kofyimages-9dae18892c9f.herokuapp.com/api/lifestyle-photos/${widget.photoId}/comments/"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _comments = data.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _postComment() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    setState(() => _isPosting = true);

    try {
      final response = await AuthLoginService.makeAuthenticatedRequest(
        url: "https://kofyimages-9dae18892c9f.herokuapp.com/api/lifestyle-photos/${widget.photoId}/comment/",
        method: 'POST',
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _controller.clear();

        // Refresh comments list
        await _fetchComments();

        // Update comment count
        if (widget.onCommentCountChanged != null) {
          widget.onCommentCountChanged!(_comments.length);
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Comment posted successfully!',
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to post comment',
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong',
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() => _isPosting = false);
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

  String _timeAgo(String? isoDateString) {
    if (isoDateString == null) return '';
    
    final now = DateTime.now().toUtc();
    final dateTime = DateTime.parse(isoDateString).toUtc();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} d';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[700]!),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16.h,
        left: 16.w,
        right: 16.w,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(
            'Comments',
            style: GoogleFonts.montserrat(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            widget.photoTitle,
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12.h),

          // Comments List
          _isLoading
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.h),
                    child: CircularProgressIndicator(),
                  ),
                )
              : _comments.isEmpty
                  ? Container(
                      padding: EdgeInsets.all(32.h),
                      child: Column(
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 48.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'No comments yet',
                            style: GoogleFonts.montserrat(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Be the first to comment!',
                            style: GoogleFonts.montserrat(
                              fontSize: 14.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      height: 300.h,
                      child: ListView.builder(
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          final username = comment['user']['username'] ?? 'User';
                          final canDelete = _currentUsername == username;
                          final isDeleting = _deletingComments.contains(comment['id']);

                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            child: ListTile(
                              leading: _buildUserAvatar(username),
                              title: Text(
                                username,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                ),
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Text(
                                  comment['content'] ?? '',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _timeAgo(comment['created_at']),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (canDelete) ...[
                                    SizedBox(height: 4.h),
                                    GestureDetector(
                                      onTap: isDeleting 
                                          ? null 
                                          : () => _showDeleteConfirmation(comment['id']),
                                      child: Container(
                                        padding: EdgeInsets.all(6.w),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: isDeleting
                                            ? SizedBox(
                                                width: 16.sp,
                                                height: 16.sp,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                                ),
                                              )
                                            : Icon(
                                                Icons.delete_outline,
                                                size: 16.sp,
                                                color: Colors.white,
                                              ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

          SizedBox(height: 12.h),

          // Input Section
          if (_isLoggedIn) ...[
            Padding(
              padding: EdgeInsets.only(bottom: 25.h),
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
                        hintText: 'Write a comment...',
                        hintStyle: GoogleFonts.montserrat(
                          color: Colors.grey[500],
                          fontSize: 14.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.black, width: 2.0),
                        ),
                        contentPadding: EdgeInsets.all(12.w),
                      ),
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: _isPosting ? null : _postComment,
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
                        : Text(
                            'Send',
                            style: GoogleFonts.montserrat(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Show login button when user is not logged in
            Padding(
              padding: EdgeInsets.only(bottom: 25.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConnectionListener(child: LoginPage()),
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
                        'Login to post a comment',
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}