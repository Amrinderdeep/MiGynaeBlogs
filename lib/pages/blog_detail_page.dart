import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migynaeblogs/models/blog_models.dart';
import 'package:migynaeblogs/services/blog_service.dart';

/// Blog detail page that displays a single blog article with expandable test cards
/// 
/// This page fetches blog content from Firestore on load and renders it
/// with expandable content blocks representing different tests/activities.
/// 
/// The page displays:
/// - Cover image
/// - Title and description
/// - Expandable cards for each test/activity
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
              // Blog content - Title and Description
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
                      // Metadata (date, read time)
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
                      // Tests Header
                      Text(
                        'Available Tests',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              // Content blocks as grid tiles
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final block = blog.contentBlocks[index];
                      return _buildTestTile(context, block, index);
                    },
                    childCount: blog.contentBlocks.length,
                  ),
                ),
              ),
              // Bottom padding
              SliverToBoxAdapter(
                child: const SizedBox(height: 32),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build metadata section (date, read time)
  Widget _buildMetadata(BuildContext context, Blog blog) {
    return Row(
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
    );
  }

  /// Build test tile for grid display
  Widget _buildTestTile(BuildContext context, ContentBlock block, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestDetailPage(block: block),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFF06292),
            width: 1.5,
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF06292).withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getIconFromName(block.icon),
            const SizedBox(height: 12),
            Text(
              block.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Convert icon name to Flutter icon
  Widget _getIconFromName(String iconName) {
    final iconMap = {
      // Pregnancy activities
      'directions_walk': Icons.directions_walk,
      'restaurant': Icons.restaurant,
      'directions_run': Icons.directions_run,
      'stairs': Icons.stairs,
      'cleaning_services': Icons.cleaning_services,
      'favorite': Icons.favorite,
      'directions_car': Icons.directions_car,
      'hotel': Icons.hotel,
      'sports_volleyball': Icons.sports_volleyball,
      'shopping_cart': Icons.shopping_cart,
      'work': Icons.work,
      'sports_gymnastics': Icons.sports_gymnastics,
      'fitness_center': Icons.fitness_center,
      'ac_unit': Icons.ac_unit,
      'agriculture': Icons.agriculture,
      'spa': Icons.spa,
      // Fertility tests
      'science': Icons.science,
      'medical_services': Icons.medical_services,
      'visibility': Icons.visibility,
      'healing': Icons.healing,
      'bloodtype': Icons.bloodtype,
      'vaccines': Icons.vaccines,
      'psychology': Icons.psychology,
      'health_and_safety': Icons.health_and_safety,
      'monitor_heart': Icons.monitor_heart,
      'favorite_border': Icons.favorite_border,
      'info': Icons.info,
      'dataset': Icons.dataset,
      'analytics': Icons.analytics,
      'assignment': Icons.assignment,
    };

    return Icon(
      iconMap[iconName] ?? Icons.science,
      size: 24,
      color: const Color(0xFFF06292),
    );
  }
}

/// Test Detail Page - Shows detailed information for a specific test
class TestDetailPage extends StatelessWidget {
  final ContentBlock block;

  const TestDetailPage({Key? key, required this.block}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final details = block.testDetails;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF06292),
        title: Text(block.title),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Test Icon and Title
              Center(
                child: Column(
                  children: [
                    _getIconFromNameStatic(block.icon, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      block.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              if (details != null) ...[
                // How to Do
                _buildDetailSection(
                  context,
                  'How to Do',
                  details.howToDo,
                  Icons.check_circle,
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 20),

                // When to Do
                _buildDetailSection(
                  context,
                  'When to Do',
                  details.whenToDo,
                  Icons.access_time,
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 20),

                // Who is This Test For
                _buildDetailSection(
                  context,
                  'Who is This Test For',
                  details.whoIsThisTestFor,
                  Icons.people,
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 20),

                // Precautions
                _buildDetailSection(
                  context,
                  'Precautions',
                  details.precautions,
                  Icons.warning,
                  const Color(0xFFFF9800),
                ),
                const SizedBox(height: 20),

                // Avoid If
                _buildDetailSection(
                  context,
                  'Avoid If',
                  details.avoidIf,
                  Icons.flag,
                  const Color(0xFFF44336),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context,
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.05),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 36),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Icon _getIconFromNameStatic(String iconName, {double size = 24}) {
    final iconMap = {
      'directions_walk': Icons.directions_walk,
      'restaurant': Icons.restaurant,
      'directions_run': Icons.directions_run,
      'stairs': Icons.stairs,
      'cleaning_services': Icons.cleaning_services,
      'favorite': Icons.favorite,
      'directions_car': Icons.directions_car,
      'hotel': Icons.hotel,
      'sports_volleyball': Icons.sports_volleyball,
      'shopping_cart': Icons.shopping_cart,
      'work': Icons.work,
      'sports_gymnastics': Icons.sports_gymnastics,
      'fitness_center': Icons.fitness_center,
      'ac_unit': Icons.ac_unit,
      'agriculture': Icons.agriculture,
      'spa': Icons.spa,
      'science': Icons.science,
      'medical_services': Icons.medical_services,
      'visibility': Icons.visibility,
      'healing': Icons.healing,
      'bloodtype': Icons.bloodtype,
      'vaccines': Icons.vaccines,
      'psychology': Icons.psychology,
      'health_and_safety': Icons.health_and_safety,
      'monitor_heart': Icons.monitor_heart,
      'favorite_border': Icons.favorite_border,
      'info': Icons.info,
      'dataset': Icons.dataset,
      'analytics': Icons.analytics,
      'assignment': Icons.assignment,
    };

    return Icon(
      iconMap[iconName] ?? Icons.science,
      size: size,
      color: const Color(0xFFF06292),
    );
  }
}
