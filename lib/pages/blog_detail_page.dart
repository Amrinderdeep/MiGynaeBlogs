import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migynaeblogs/models/blog_models.dart';
import 'package:migynaeblogs/services/blog_service.dart';

/// Blog detail page that displays a single blog article
/// 
/// This page fetches blog content from Firestore on load and renders it
/// with beautiful typography and layout.
/// 
/// The page is designed to be reusable for any blog ID passed as a parameter.
class BlogDetailPage extends StatefulWidget {
  final String blogId;

  const BlogDetailPage({
    Key? key,
    required this.blogId,
  }) : super(key: key);

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  final BlogService _blogService = BlogService();
  late Future<Blog> _blogFuture;

  @override
  void initState() {
    super.initState();
    _blogFuture = _blogService.getBlogById(widget.blogId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Blog>(
        future: _blogFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading blog',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _blogFuture =
                              _blogService.getBlogById(widget.blogId);
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final blog = snapshot.data;
          if (blog == null) {
            return const Center(
              child: Text('Blog not found'),
            );
          }

          return CustomScrollView(
            slivers: [
              // App bar with cover image
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: const Color(0xFFF06292),
                elevation: 4,
                shadowColor: const Color(0xFFF06292).withOpacity(0.4),
                flexibleSpace: FlexibleSpaceBar(
                  background: blog.coverImageUrl != null
                      ? Image.network(
                          blog.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.image_not_supported),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(
                              Icons.article,
                              size: 80,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                ),
              ),
              // Blog content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      // Title
                      Text(
                        blog.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                      ),
                      const SizedBox(height: 16),
                      // Metadata (date, read time, author)
                      _buildMetadata(context, blog),
                      const SizedBox(height: 24),
                      // Description with border
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFF06292),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFF06292).withOpacity(0.05),
                        ),
                        child: Text(
                          blog.description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[800],
                                height: 1.6,
                              ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              // Content blocks
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final block = blog.contentBlocks[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildContentBlock(context, block),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                  childCount: blog.contentBlocks.length,
                ),
              ),
              // Bottom padding
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      if (blog.tags != null && blog.tags!.isNotEmpty) ...[
                        Divider(color: Colors.grey[300], thickness: 2),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.label_outline,
                                    size: 18,
                                    color: const Color(0xFFF06292),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Topics',
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFF06292),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: blog.tags!
                                    .map((tag) => Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF06292).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFF06292),
                                          width: 2,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.tag,
                                            size: 12,
                                            color: const Color(0xFFF06292),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            tag,
                                            style: const TextStyle(
                                              color: Color(0xFFF06292),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build metadata section (date, read time, author)
  Widget _buildMetadata(BuildContext context, Blog blog) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Published date
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF06292).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFFF06292),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xFFF06292),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM d, yyyy').format(blog.publishedDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFF06292),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Read time
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF06292).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFFF06292),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 16,
                    color: Color(0xFFF06292),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${blog.readTimeMinutes} min read',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFF06292),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (blog.authorName != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF06292).withOpacity(0.08),
              border: Border.all(
                color: const Color(0xFFF06292),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Author avatar
                if (blog.authorImageUrl != null)
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(blog.authorImageUrl!),
                    onBackgroundImageError: (exception, stackTrace) {},
                  )
                else
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFF06292),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Author',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      blog.authorName!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF06292),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  Icons.verified,
                  color: const Color(0xFFF06292),
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Build individual content block based on type
  Widget _buildContentBlock(BuildContext context, ContentBlock block) {
    switch (block.type) {
      case ContentBlockType.heading:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF06292),
            border: Border(
              left: BorderSide(
                color: const Color(0xFFF06292),
                width: 5,
              ),
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.topic,
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  block.content,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        color: Colors.white,
                      ),
                ),
              ),
            ],
          ),
        );

      case ContentBlockType.paragraph:
        return Text(
          block.content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[800],
                height: 1.6,
              ),
        );

      case ContentBlockType.bulletPoints:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: block.bulletPoints
                  ?.map(
                    (point) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF06292).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.check_circle_outline,
                              size: 20,
                              color: const Color(0xFFF06292),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              point,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.grey[800],
                                    height: 1.6,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList() ??
              [],
        );

      case ContentBlockType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (block.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFAE5EA).withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.network(
                    block.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        height: 200,
                        child: const Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (block.imageCaption != null) ...[
              const SizedBox(height: 12),
              Text(
                block.imageCaption!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        );
    }
  }
}
