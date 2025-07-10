// pages/upload_lifestyle_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:kofyimages/constants/connection_listener.dart';
import 'package:kofyimages/constants/custom_appbar.dart';
import 'package:kofyimages/constants/login_modal.dart';
import 'package:kofyimages/constants/sidedrawer.dart';
import 'dart:convert';
import 'package:kofyimages/models/city_model.dart';
import 'package:kofyimages/screens/login_page.dart';
import 'package:kofyimages/screens/register.dart';
import 'package:kofyimages/services/auth_login.dart';
import 'package:kofyimages/services/endpoints.dart';

class UploadLifestylePage extends StatefulWidget {
  const UploadLifestylePage({super.key});

  @override
  State<UploadLifestylePage> createState() => _UploadLifestylePageState();
}

class _UploadLifestylePageState extends State<UploadLifestylePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _creatorNameController = TextEditingController();
  
  File? _selectedImage;
  City? _selectedCity;
  List<City> _cities = [];
  bool _isLoading = false;
  bool _isUploadingImage = false;
  bool _isLoadingCities = false;
  String? _uploadedImageUrl;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _checkAuthenticationAndLoadData();
  }

  Future<void> _checkAuthenticationAndLoadData() async {
    final isLoggedIn = await AuthLoginService.isLoggedIn();
    
    if (!isLoggedIn) {
      _showLoginDialog();
      return;
    }
    
    // Load cities
    await _loadCities();
  }

  Future<void> _loadCities() async {
    setState(() {
      _isLoadingCities = true;
    });

    try {
      final response = await AuthLoginService.makeAuthenticatedRequest(
        url: ApiEndpoints.getAllCities,
        method: 'GET',
      );

      if (response.statusCode == 200) {
        final List<dynamic> citiesJson = jsonDecode(response.body);
        setState(() {
          _cities = citiesJson.map((json) => City.fromJson(json)).toList();
        });
      } else {
        _showErrorSnackBar('Failed to load cities');
      }
    } catch (e) {
      if (e is TokenExpiredException) {
        _showLoginDialog();
      } else {
        _showErrorSnackBar('Error loading cities: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isLoadingCities = false;
      });
    }
  }

  void _showLoginDialog() {
    showLoginModal(
      context,
      cityName: 'Upload',
      onLoginPressed: () {
                        Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ConnectionListener(child: LoginPage()),
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
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _uploadedImageUrl = null; // Reset uploaded image URL
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: ${e.toString()}');
      print(e.toString());
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _uploadedImageUrl = null; // Reset uploaded image URL
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error taking photo: ${e.toString()}');
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Image Source',
          style: GoogleFonts.montserrat(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(
                'Gallery',
                style: GoogleFonts.montserrat(fontSize: 16.sp),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(
                'Camera',
                style: GoogleFonts.montserrat(fontSize: 16.sp),
              ),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadLifestylePhoto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      _showErrorSnackBar('Please select an image');
      return;
    }

    if (_selectedCity == null) {
      _showErrorSnackBar('Please select a city');
      return;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      // Get access token
      final accessToken = await AuthLoginService.getAccessToken();
      if (accessToken == null) {
        _showLoginDialog();
        return;
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.postphoto),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $accessToken';

      // Add form fields
      request.fields['title'] = _titleController.text.trim();
      request.fields['city'] = _selectedCity!.id.toString();
      request.fields['creator_name'] = _creatorNameController.text.trim();

      // Add image file
      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        _selectedImage!.path,
      );
      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _uploadedImageUrl = responseData['image'];
        });
        _showSuccessSnackBar('Lifestyle photo uploaded successfully!');
        _resetForm();
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        try {
          await AuthLoginService.refreshToken();
          // Retry the upload
          await _uploadLifestylePhoto();
          return;
        } catch (e) {
          _showLoginDialog();
        }
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Upload failed';
        
        if (errorData is Map<String, dynamic>) {
          final List<String> errors = [];
          errorData.forEach((key, value) {
            if (value is List) {
              errors.addAll(value.map((e) => '$key: $e'));
            } else {
              errors.add('$key: $value');
            }
          });
          errorMessage = errors.join('\n');
        }
        
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      _showErrorSnackBar('Error uploading image: ${e.toString()}');
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _selectedImage = null;
      _selectedCity = null;
      _uploadedImageUrl = null;
    });
    _titleController.clear();
    _formKey.currentState?.reset();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

                        Center(
                  child: Text(
                   'Upload Lifestyle Photo',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              // Image Selection Section
              _buildImageSection(),
              SizedBox(height: 24.h),
              
              // Form Fields
              _buildFormFields(),
              SizedBox(height: 24.h),
              
              // Upload Button
              _buildUploadButton(),
              SizedBox(height: 16.h),
              
              // Uploaded Image Preview
              if (_uploadedImageUrl != null) _buildUploadedImagePreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_selectedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.file(
                _selectedImage!,
                height: 200.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 200.h,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 48.sp,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Select an image',
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          Padding(
            padding: EdgeInsets.all(16.w),
            child: ElevatedButton.icon(
              onPressed: _showImageSourceDialog,
              icon: Icon(Icons.add_a_photo, size: 20.sp),
              label: Text(
                _selectedImage != null ? 'Change Image' : 'Select Image',
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Field
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              labelStyle: GoogleFonts.montserrat(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            style: GoogleFonts.montserrat(fontSize: 16.sp),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          
          // Creator Name Field
          TextFormField(
            controller: _creatorNameController,
            decoration: InputDecoration(
              labelText: 'Creator Name',
              labelStyle: GoogleFonts.montserrat(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            style: GoogleFonts.montserrat(fontSize: 16.sp),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter creator name';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          
          // City Dropdown
          _buildCityDropdown(),
        ],
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select City',
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
        
        if (_isLoadingCities)
          Container(
            height: 48.h,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        else
          DropdownButtonFormField<City>(
            value: _selectedCity,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            hint: Text(
              'Choose a city',
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            items: _cities.map((City city) {
              return DropdownMenuItem<City>(
                value: city,
                child: Text(
                  city.formattedName,
                  style: GoogleFonts.montserrat(fontSize: 16.sp),
                ),
              );
            }).toList(),
            onChanged: (City? newValue) {
              setState(() {
                _selectedCity = newValue;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a city';
              }
              return null;
            },
          ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return ElevatedButton(
      onPressed: _isUploadingImage ? null : _uploadLifestylePhoto,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: _isUploadingImage
          ? SizedBox(
              height: 20.h,
              width: 20.w,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              'Upload Lifestyle Photo',
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildUploadedImagePreview() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            'Upload Successful!',
            style: GoogleFonts.montserrat(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your lifestyle photo has been uploaded successfully.',
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              color: Colors.green[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: _resetForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Upload Another Photo',
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _creatorNameController.dispose();
    super.dispose();
  }
}