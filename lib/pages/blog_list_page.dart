import 'package:flutter/material.dart';
import 'package:migynaeblogs/models/blog_models.dart';
import 'package:migynaeblogs/services/blog_service.dart';
import 'package:migynaeblogs/pages/blog_detail_page.dart';

class BlogListPage extends StatefulWidget {
  const BlogListPage({Key? key}) : super(key: key);

  @override
  State<BlogListPage> createState() => _BlogListPageState();
}

class _BlogListPageState extends State<BlogListPage> {
  final BlogService _blogService = BlogService();
  late Future<List<Blog>> _blogsFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _blogsFuture = _blogService.getAllBlogs();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F7),
      body: SafeArea(
        child: FutureBuilder<List<Blog>>(
          future: _blogsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Error loading blogs',
                  style: TextStyle(color: Color(0xFF696969)),
                ),
              );
            }

            final blogs = snapshot.data ?? [];

            final query = _searchController.text.toLowerCase();
            final filteredBlogs = query.isEmpty
                ? blogs
                : blogs.where((blog) {
                    return blog.title.toLowerCase().contains(query) ||
                        blog.description.toLowerCase().contains(query);
                  }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// PAGE TITLE
                  const Text(
                    'Pregnancy Blogs',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF696969),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Expert advice for your journey',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF696969).withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// SEARCH BAR 
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      // ❌ removed borderColor
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search blogs...',
                        hintStyle: const TextStyle(color: Color(0xFF696969)),
                        prefixIcon: const Icon(Icons.search),

                        // 👇 THESE TWO LINES FIX THE PINK BORDER
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),

                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),


                  const SizedBox(height: 24),

                  /// BLOG LIST
                  Column(
                    children: filteredBlogs.map((blog) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildBlogCard(context, blog),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBlogCard(BuildContext context, Blog blog) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlogDetailPage(blogId: blog.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGE
              Image.network(
                blog.coverImageUrl ?? '',
                height: 190,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 190,
                  color: const Color(0xFFFCD5D4),
                ),
              ),

              /// CONTENT + ARROW (CENTER ALIGNED)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// TEXT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blog.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF696969),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            blog.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF696969)
                                  .withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// RIGHT ARROW 
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFFcf3476),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
