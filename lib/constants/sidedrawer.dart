import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kofyimages/constants/connection_listener.dart';
import 'package:kofyimages/screens/events.dart';
import 'package:kofyimages/screens/home.dart';
import 'package:kofyimages/screens/login_page.dart';
import 'package:kofyimages/screens/register.dart';
import 'package:kofyimages/screens/upload_lifestyle_picture.dart';
import 'package:kofyimages/services/auth_login.dart';
import 'package:kofyimages/models/login_model.dart';
import 'package:url_launcher/url_launcher.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthLoginService.isLoggedIn(),
      builder: (context, snapshot) {
        final isLoggedIn = snapshot.data ?? false;

        return Drawer(
          backgroundColor: Colors.white,
          child: Column(
            children: [
              // Header with Logo and Greeting
              Container(
                height: 200.h,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 300.w,
                          height: 120.h,
                          child: Image.asset(
                            'assets/logo_white.JPG',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(color: Colors.grey[300]),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: isLoggedIn
                      ? [
                          if (isLoggedIn)
                            FutureBuilder<User?>(
                              future: AuthLoginService.getSavedUser(),
                              builder: (context, userSnapshot) {
                                final username =
                                    userSnapshot.data?.username ?? '';
                                return Padding(
                                  padding: EdgeInsets.only(top: 10.h),
                                  child: _buildMenuItem(
                                    icon: Icons.person,
                                    title: 'Hi, $username',
                                    onTap: () {},
                                  ),
                                );
                              },
                            ),
                          _buildMenuItem(
                            icon: Icons.home_outlined,
                            title: 'Home',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ConnectionListener(
                                    child: MyHomePage(),
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildMenuItem(
                            icon: Icons.person_outline,
                            title: 'Profile',
                            onTap: () {
                              // Replace with actual profile screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Profile page coming soon!',
                                    style: GoogleFonts.montserrat(),
                                  ),
                                  backgroundColor: Colors.black,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          _buildMenuItem(
                            icon: Icons.event_outlined,
                            title: 'Events',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ConnectionListener(
                                    child: EventsPage(),
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildMenuItem(
                            icon: Icons.upload_outlined,
                            title: 'Upload Photo',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ConnectionListener(
                                    child: UploadLifestylePage(),
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildMenuItem(
                            icon: Icons.logout,
                            title: 'Logout',
                            onTap: () async {
                              await AuthLoginService.logout();
                              Navigator.pushAndRemoveUntil(
                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                        ]
                      : [
                          _buildMenuItem(
                            icon: Icons.home_outlined,
                            title: 'Home',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ConnectionListener(
                                    child: MyHomePage(),
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildMenuItem(
                            icon: Icons.event_outlined,
                            title: 'Events',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ConnectionListener(
                                    child: EventsPage(),
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildMenuItem(
                            icon: Icons.login_outlined,
                            title: 'Login',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ConnectionListener(
                                    child: LoginPage(),
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildMenuItem(
                            icon: Icons.person_add_outlined,
                            title: 'Create Account',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ConnectionListener(
                                    child: RegistrationPage(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                ),
              ),

              // Social Media Footer
              Container(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    Divider(color: Colors.grey[300]),
                    SizedBox(height: 15.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialIcon(FontAwesomeIcons.facebookF, () {
                          _launchURL(
                            'https://www.facebook.com/people/KofyImages/100088051583463/',
                          );
                        }),
                        SizedBox(width: 12.w),
                        _buildSocialIcon(FontAwesomeIcons.xTwitter, () {
                          _launchURL('https://x.com/KofyImages');
                        }),
                        SizedBox(width: 12.w),
                        _buildSocialIcon(FontAwesomeIcons.instagram, () {
                          _launchURL('https://www.instagram.com/kofy_images/');
                        }),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      '©${DateTime.now().year}.KofyImages.',
                      style: GoogleFonts.montserrat(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'All rights reserved',
                      style: GoogleFonts.montserrat(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700], size: 24.sp),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[700]!),
          borderRadius: BorderRadius.circular(6.r),
          color: Colors.black,
        ),
        child: Icon(icon, color: Colors.grey[300], size: 18.sp),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      try {
        final Uri uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e2) {
        // add error catching here
      }
    }
  }
}
