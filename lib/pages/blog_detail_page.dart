import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migynaeblogs/models/blog_models.dart';
import 'package:migynaeblogs/services/blog_service.dart';

/// COLOR THEME
const kPrimaryPink = Color(0xFFCF3476);
const kSoftPink = Color(0xFFFCD5D4);
const kLavender = Color(0xFFE5CEE8);
const kDarkGrey = Color(0xFF696969);
const kLightCream = Color(0xFFFEF9F7);

class BlogDetailPage extends StatefulWidget {
  final String blogId;

  const BlogDetailPage({Key? key, required this.blogId}) : super(key: key);

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
      backgroundColor: kLightCream,
      body: FutureBuilder<Blog>(
        future: _blogFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading blog'));
          }

          final blog = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,

                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                shadowColor: Colors.transparent,
                forceMaterialTransparency: true,

                leading: _circleButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),

                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _circleButton(
                      icon: Icons.share,
                      onTap: () {
                        // TODO: implement share later
                      },
                    ),
                  ),
                ],

                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Image.network(
                    blog.coverImageUrl ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: kSoftPink,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image,
                        size: 60,
                        color: kPrimaryPink,
                      ),
                    ),
                  ),
                ),
              ),


              /// CONTENT
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      /// TITLE
                      Text(
                        blog.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: kDarkGrey,
                              height: 1.3,
                            ),
                      ),

                      const SizedBox(height: 12),

                      /// META
                      Row(
                        children: [
                          _metaChip(
                            Icons.calendar_today,
                            DateFormat('MMM d, yyyy')
                                .format(blog.publishedDate),
                          ),
                          const SizedBox(width: 12),
                          _metaChip(
                            Icons.schedule,
                            '${blog.readTimeMinutes} min read',
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// DESCRIPTION
                      Text(
                        blog.description,
                        style:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: kDarkGrey,
                                  height: 1.7,
                                ),
                      ),

                      const SizedBox(height: 32),

                      /// SECTION TITLE
                      Text(
                        'Check what/how much can you do?',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: kDarkGrey,
                                ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              /// GRID TILES
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.05,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final block = blog.contentBlocks[index];
                      return _buildTile(context, block);
                    },
                    childCount: blog.contentBlocks.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          );
        },
      ),
    );
  }

  /// META CHIP
  Widget _metaChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: kSoftPink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: kPrimaryPink),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: kDarkGrey,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// TILE
  Widget _buildTile(BuildContext context, ContentBlock block) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TestDetailPage(block: block),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _iconMap[block.icon] ?? Icons.favorite,
              size: 42,
              color: kPrimaryPink,
            ),
            const SizedBox(height: 14),
            Text(
              block.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kDarkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CIRCLE BUTTON
  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, color: kPrimaryPink, size: 20),
      ),
    );
  }
}

/// ICON MAP
final Map<String, IconData> _iconMap = {
  'restaurant': Icons.restaurant,
  'directions_walk': Icons.directions_walk,
  'directions_run': Icons.directions_run,
  'stairs': Icons.stairs,
  'fitness_center': Icons.fitness_center,
  'spa': Icons.spa,
};

/// TEST DETAIL PAGE (UNCHANGED LOGIC – POLISHED APPBAR)
class TestDetailPage extends StatelessWidget {
  final ContentBlock block;

  const TestDetailPage({Key? key, required this.block}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final details = block.testDetails;

    return Scaffold(
      backgroundColor: kLightCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          block.title,
          style: const TextStyle(
            color: kDarkGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: _circleButton(
          icon: Icons.arrow_back,
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: details == null
            ? const SizedBox()
            : Column(
                children: [
                  if (details.howToDo.isNotEmpty)
                    _detailCard(
                      bg: const Color(0xFFE9F6EA),
                      border: const Color(0xFF9FD3A7),
                      icon: Icons.check_circle,
                      iconColor: const Color(0xFF4CAF50),
                      title: 'How to do',
                      text: details.howToDo.join('\n• '),
                    ),
                  if (details.whenToDo.isNotEmpty)
                    _detailCard(
                      bg: const Color(0xFFE9F6EA),
                      border: const Color(0xFF9FD3A7),
                      icon: Icons.thumb_up,
                      iconColor: const Color(0xFF4CAF50),
                      title: 'When to do',
                      text: details.whenToDo.join('\n• '),
                    ),
                  if (details.whoIsThisTestFor.isNotEmpty)
                    _detailCard(
                      bg: const Color(0xFFFFEFEF),
                      border: const Color(0xFFF3B5C0),
                      icon: Icons.person,
                      iconColor: kPrimaryPink,
                      title: 'Who is it for',
                      text: details.whoIsThisTestFor.join('\n• '),
                    ),
                  if (details.precautions.isNotEmpty)
                    _detailCard(
                      bg: const Color(0xFFFFEFEF),
                      border: const Color(0xFFF3B5C0),
                      icon: Icons.warning_amber_rounded,
                      iconColor: kPrimaryPink,
                      title: 'Precautions',
                      text: details.precautions.join('\n• '),
                    ),
                  if (details.avoidIf.isNotEmpty)
                    _detailCard(
                      bg: const Color(0xFFFFEFEF),
                      border: const Color(0xFFF3B5C0),
                      icon: Icons.person_off,
                      iconColor: kPrimaryPink,
                      title: 'Avoid if',
                      text: details.avoidIf.join('\n• '),
                    ),
                ],
              ),
      ),
    );
  }

  /// CARD
  Widget _detailCard({
    required Color bg,
    required Color border,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '• $text'.replaceAll('\n• •', '\n•'), // fix double bullets
            style: const TextStyle(
              color: kDarkGrey,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// BACK BUTTON
  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, color: kDarkGrey),
      ),
    );
  }
}
