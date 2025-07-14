// screens/user_profile_screen.dart

// ignore_for_file: unused_field, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kofyimages/constants/connection_listener.dart';
import 'package:kofyimages/constants/custom_appbar.dart';
import 'package:kofyimages/constants/login_modal.dart';
import 'package:kofyimages/constants/sidedrawer.dart';
import 'package:kofyimages/models/profile_model.dart';
import 'package:kofyimages/screens/login_page.dart';
import 'package:kofyimages/services/auth_login.dart';
import 'dart:convert';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;
  bool _isSubscribed = false;
  bool _showPassword = false;
  String? _errorMessage;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Initialize screen by checking login status and loading user data
  Future<void> _initializeScreen() async {
    final bool loggedIn = await AuthLoginService.isLoggedIn();
    if (!loggedIn) {
      if (mounted) {
        _showLoginModal();
      }
      return;
    }

    await _loadUserProfile();
    await _checkSubscriptionStatus();
  }

  /// Show login modal if user is not logged in
  void _showLoginModal() {
    showLoginModal(
      context,
      cityName: 'Profile',
      onLoginPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ConnectionListener(child: LoginPage()),
          ),
        );
      },
      onRegisterPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ConnectionListener(child: LoginPage()),
          ),
        );
      },
    );
  }

  /// Load user profile data
  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await AuthLoginService.makeAuthenticatedRequest(
        url: 'https://kofyimages-9dae18892c9f.herokuapp.com/api/auth/profile/',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        _currentUser = User.fromJson(userData);

        // Populate form fields
        _usernameController.text = _currentUser!.username;
        _emailController.text = _currentUser!.email;
        _firstNameController.text = _currentUser!.firstName;
        _lastNameController.text = _currentUser!.lastName ;
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Check if user is subscribed to newsletter
  Future<void> _checkSubscriptionStatus() async {
    try {
      final response = await AuthLoginService.makeAuthenticatedRequest(
        url: 'https://kofyimages-9dae18892c9f.herokuapp.com/api/subscribe/',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> subscribers = data['data'];

        // Check if current user's email is in the subscriber list
        final userEmail = _currentUser?.email;
        if (userEmail != null) {
          final isSubscribed = subscribers.any(
            (sub) => sub['email'] == userEmail,
          );
          setState(() {
            _isSubscribed = isSubscribed;
          });
        }
      }
    } catch (e) {
      // Silently handle subscription check errors
    }
  }

  /// Update user profile
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final updateData = {
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
      };

      final response = await AuthLoginService.makeAuthenticatedRequest(
        url: 'https://kofyimages-9dae18892c9f.herokuapp.com/api/auth/update/',
        method: 'PUT',
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _currentUser = User.fromJson(responseData['user']);

        setState(() {
          _isEditing = false;
        });

        _showSnackBar('Profile updated successfully!');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating profile: ${e.toString()}';
      });
      _showSnackBar(_errorMessage!, isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Unsubscribe from newsletter
  Future<void> _unsubscribe() async {
    try {
      final response = await AuthLoginService.makeAuthenticatedRequest(
        url: 'https://kofyimages-9dae18892c9f.herokuapp.com/api/unsubscribe/',
        method: 'POST',
        body: json.encode({'email': _currentUser!.email}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isSubscribed = false;
        });
        _showSnackBar('Successfully unsubscribed from newsletter');
      } else {
        throw Exception('Failed to unsubscribe');
      }
    } catch (e) {
      _showSnackBar('Error unsubscribing: ${e.toString()}', isError: true);
    }
  }

  /// Show delete account confirmation modal
  void _showDeleteAccountModal() {
    showDialog(
      context: context,
      builder: (context) => _DeleteAccountModal(onConfirm: _deleteAccount),
    );
  }

  /// Delete user account
  Future<void> _deleteAccount(String password) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await AuthLoginService.makeAuthenticatedRequest(
        url: 'https://kofyimages-9dae18892c9f.herokuapp.com/api/auth/delete/',
        method: 'DELETE',
        body: json.encode({'password': password, 'confirm_deletion': true}),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final message = responseData['message'];

        // Clear authentication
        await AuthLoginService.logout();

        // Navigate to login and show success message
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const ConnectionListener(child: LoginPage()),
            ),
            (route) => false,
          );

          // Show success message after navigation
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          });
        }
      } else {
        final errorData = json.decode(response.body);
        String errorMessage = 'Failed to delete account';

        if (errorData['password'] != null) {
          errorMessage = errorData['password'][0];
        } else if (errorData['confirm_deletion'] != null) {
          errorMessage = errorData['confirm_deletion'][0];
        }

        throw (errorMessage);
      }
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Show snackbar with message
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: Colors.grey[50],
      drawer: const SideDrawer(),
      body: SafeArea(
        child: _isLoading && _currentUser == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20.h),

                      // Profile Header
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50.r,
                              backgroundColor: Colors.grey[300],
                              child: Icon(
                                Icons.person,
                                size: 60.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              _currentUser?.username ?? 'User',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Member since ${_formatDate(_currentUser?.dateJoined)}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Error Message Display
                      if (_errorMessage != null) ...[
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],

                      // Username Field
                      _buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your username';
                          }
                          if (value.trim().length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16.h),

                      // Email Field
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!_isValidEmail(value.trim())) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16.h),

                      // First Name Field
                      _buildTextField(
                        controller: _firstNameController,
                        label: 'First Name',
                        prefixIcon: Icons.badge_outlined,
                        required: false,
                      ),

                      SizedBox(height: 16.h),

                      // Last Name Field
                      _buildTextField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        prefixIcon: Icons.badge_outlined,
                        required: false,
                      ),

                      SizedBox(height: 20.h),

                      // Newsletter Subscription Status
                      if (_isSubscribed) ...[
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.email,
                                color: Colors.blue,
                                size: 20.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Newsletter Subscription',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'You are subscribed to our newsletter',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.blue.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: _unsubscribe,
                                child: Text(
                                  'Unsubscribe',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],

                      // Action Buttons
                      if (_isEditing) ...[
                        // Save and Cancel buttons
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                    _errorMessage = null;
                                  });
                                  // Reset form fields
                                  _usernameController.text =
                                      _currentUser!.username;
                                  _emailController.text = _currentUser!.email;
                                  _firstNameController.text =
                                      _currentUser!.firstName ?? '';
                                  _lastNameController.text =
                                      _currentUser!.lastName ?? '';
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _updateProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 2,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        width: 20.w,
                                        height: 20.h,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Update Profile button
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                              _errorMessage = null;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Update Profile',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: 10.h),

                      // Delete Account Button
                      ElevatedButton(
                        onPressed: _showDeleteAccountModal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Delete Account',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// Build text field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: !_isEditing,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: true,
        fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
      ),
      keyboardType: keyboardType,
      validator: required ? validator : null,
    );
  }

  /// Validate email format
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Format date for display
  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Delete Account Confirmation Modal
class _DeleteAccountModal extends StatefulWidget {
  final Function(String password) onConfirm;

  const _DeleteAccountModal({required this.onConfirm});

  @override
  State<_DeleteAccountModal> createState() => _DeleteAccountModalState();
}

class _DeleteAccountModalState extends State<_DeleteAccountModal> {
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _confirmDeletion = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning, color: Colors.red, size: 32.sp),
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              'Delete Account',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.h),

            // Warning message
            Text(
              'This action cannot be undone. All your data will be permanently deleted.',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Enter Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),

            // Confirmation checkbox
            Row(
              children: [
                Checkbox(
                  value: _confirmDeletion,
                  onChanged: (value) {
                    setState(() {
                      _confirmDeletion = value ?? false;
                    });
                  },
                  activeColor: Colors.red,
                ),
                Expanded(
                  child: Text(
                    'I understand that this action cannot be undone',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _confirmDeletion && _passwordController.text.isNotEmpty
                        ? () {
                            Navigator.of(context).pop();
                            widget.onConfirm(_passwordController.text);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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
