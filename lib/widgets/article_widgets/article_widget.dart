import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kofyimages/models/city_details_model.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ArticleWidget extends StatelessWidget {
  final List<ContentItem> content;

  const ArticleWidget({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(20.w),
        child: Center(
          child: Text(
            'No articles available.',
            style: GoogleFonts.montserrat(fontSize: 16.sp),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: content.length,
      itemBuilder: (context, index) {
        final article = content[index];

        return GestureDetector(
          onTap: () => _showArticleContent(context, article),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color.fromARGB(255, 213, 213, 213)),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      article.title,
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // City Name
                    Text(
                      'City: ${article.cityName}',
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showArticleContent(BuildContext context, ContentItem article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          initialChildSize: 0.8,
          builder: (_, scrollController) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 50.w,
                      height: 5.h,
                      margin: EdgeInsets.only(bottom: 20.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Markdown content
                  if (article.content != null && article.content!.isNotEmpty)
                    MarkdownBody(
                      data: article.content!,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                        p: GoogleFonts.montserrat(fontSize: 14.sp, height: 1.6),
                        h1: GoogleFonts.montserrat(fontSize: 22.sp, fontWeight: FontWeight.bold),
                        h2: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.bold),
                        h3: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.w600),
                      ),
                    )
                  else
          Center(
      child: Column(
        children: [
          Icon(Icons.category_outlined, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'No articles available',
            style: GoogleFonts.montserrat(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Articles for this city is coming soon',
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
