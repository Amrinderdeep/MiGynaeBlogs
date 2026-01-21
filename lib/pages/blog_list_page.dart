import 'package:flutter/material.dart';
import 'package:migynaeblogs/models/blog_models.dart';
import 'package:migynaeblogs/services/blog_service.dart';
import 'package:migynaeblogs/pages/blog_detail_page.dart';

/// Health articles and guides page
/// 
/// Displays all women's health articles with:
/// - Search functionality
/// - Category filtering
/// - Beautiful card layout
class BlogListPage extends StatefulWidget {
  const BlogListPage({Key? key}) : super(key: key);

  @override
  State<BlogListPage> createState() => _BlogListPageState();
}

class _BlogListPageState extends State<BlogListPage> {
  final BlogService _blogService = BlogService();
  late Future<List<Blog>> _blogsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _selectedTag = 'All';
  List<Blog> _allBlogs = [];
  List<Blog> _filteredBlogs = [];

  final List<String> _availableTags = [
    'All',
    'male-factor',
    'female-factor',
    'basic-test',
    'advanced-test',
    'blood-test',
    'ultrasound',
    'invasive-procedure',
  ];

  @override
  void initState() {
    super.initState();
    _blogsFuture = _blogService.getLatestBlogs(limit: 100);
    _blogsFuture.then((blogs) {
      setState(() {
        _allBlogs = blogs;
        _filteredBlogs = blogs;
      });
    });
    _searchController.addListener(_filterBlogs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBlogs() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredBlogs = _allBlogs.where((blog) {
        bool matchesQuery = blog.title.toLowerCase().contains(query) ||
            blog.description.toLowerCase().contains(query);

        bool matchesTag = _selectedTag == 'All' ||
            (blog.tags != null && blog.tags!.contains(_selectedTag));

        return matchesQuery && matchesTag;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.favorite, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text('MiGynae Blogs', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        elevation: 4,
        centerTitle: false,
        shadowColor: const Color(0xFFF06292).withOpacity(0.4),
      ),
      body: FutureBuilder<List<Blog>>(
        future: _blogsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading articles: ${snapshot.error}'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _blogsFuture =
                            _blogService.getLatestBlogs(limit: 100);
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Ask about any health topic...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFF06292)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterBlogs();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFF06292),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFF06292),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFF06292),
                        width: 2.5,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ),
              // Popular Topics header and filter
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(
                        Icons.label,
                        size: 20,
                        color: const Color(0xFFF06292),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Popular Topics',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Tag filter
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _availableTags.length,
                  itemBuilder: (context, index) {
                    final tag = _availableTags[index];
                    final isSelected = _selectedTag == tag;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTag = tag;
                            _filterBlogs();
                          });
                        },
                        backgroundColor: Colors.grey[100],
                        selectedColor: const Color(0xFFF06292),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFFF06292) : Colors.grey[300]!,
                          width: isSelected ? 2.5 : 2,
                        ),
                        labelStyle: TextStyle(
                          color: Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Blog list
              Expanded(
                child: _filteredBlogs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No articles found',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredBlogs.length,
                        itemBuilder: (context, index) {
                          final blog = _filteredBlogs[index];
                          return _buildBlogCard(context, blog);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBlogCard(BuildContext context, Blog blog) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFF06292),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlogDetailPage(blogId: blog.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF06292).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.article,
                        size: 24,
                        color: Color(0xFFF06292),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blog.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            blog.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey[200]),
                const SizedBox(height: 8),
                // Metadata with icons
                Row(
                  children: [
                    Icon(Icons.schedule,
                        size: 16, color: const Color(0xFFF06292)),
                    const SizedBox(width: 6),
                    Text(
                      '${blog.readTimeMinutes} min read',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
  
                    const Spacer(),
                    Icon(Icons.arrow_forward,
                        size: 16, color: const Color(0xFFF06292)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
