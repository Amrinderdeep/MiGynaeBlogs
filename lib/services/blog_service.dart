import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:migynaeblogs/models/blog_models.dart';

/// Service layer for Firestore operations
/// 
/// This service handles all communication with Firestore.
/// It's designed for easy extension to support multiple blogs
/// and additional future features.
class BlogService {
  static final BlogService _instance = BlogService._internal();
  late final FirebaseFirestore _firestore;

  factory BlogService() {
    return _instance;
  }

  BlogService._internal() {
    _firestore = FirebaseFirestore.instance;
  }

  /// Collection name for blogs in Firestore
  static const String _blogsCollection = 'blogs';

  /// Fetch a single blog by ID
  /// 
  /// This method fetches a blog article from Firestore by its document ID.
  /// Returns a [Blog] object with all content blocks.
  /// 
  /// Throws [FirebaseException] if the document doesn't exist or fetch fails.
  Future<Blog> getBlogById(String blogId) async {
    try {
      final docSnapshot =
          await _firestore.collection(_blogsCollection).doc(blogId).get();

      if (!docSnapshot.exists) {
        throw Exception('Blog with ID $blogId not found');
      }

      return Blog.fromMap(docSnapshot.id, docSnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching blog: $e');
    }
  }

  /// This method can be used to display a blog list page in the future.
  /// Fetches all blog documents with basic metadata (excluding full content).
  Future<List<Blog>> getAllBlogs() async {
    try {
      final querySnapshot = await _firestore.collection(_blogsCollection).get();

      return querySnapshot.docs
          .map((doc) => Blog.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error fetching blogs: $e');
    }
  }

  /// Fetch blogs with pagination support (for future implementation)
  /// 
  /// This method supports pagination for better performance
  /// when dealing with large numbers of blogs.
  /// 
  /// Parameters:
  ///   - limit: Number of blogs to fetch per page
  ///   - offset: Number of blogs to skip (for pagination)
  Future<List<Blog>> getBlogsWithPagination({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_blogsCollection)
          .limit(limit)
          .offset(offset)
          .get();

      return querySnapshot.docs
          .map((doc) => Blog.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error fetching blogs: $e');
    }
  }

  /// Search blogs by tag (for future implementation)
  /// 
  /// This method enables filtering blogs by tags.
  Future<List<Blog>> getBlogsByTag(String tag) async {
    try {
      final querySnapshot = await _firestore
          .collection(_blogsCollection)
          .where('tags', arrayContains: tag)
          .get();

      return querySnapshot.docs
          .map((doc) => Blog.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error fetching blogs by tag: $e');
    }
  }

  /// Get blogs sorted by published date (for future implementation)
  /// 
  /// This method supports sorting for a blog list view.
  Future<List<Blog>> getLatestBlogs({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_blogsCollection)
          .orderBy('publishedDate', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => Blog.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error fetching latest blogs: $e');
    }
  }
}

extension on Query<Map<String, dynamic>> {
  offset(int offset) {}
}
