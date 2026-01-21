/// Data models for blog articles
/// 
/// These models are designed to support scalability:
/// - Multiple content block types allow flexible content creation
/// - Firestore document structure mirrors these models
/// - Easy to extend with new block types or blog metadata

/// Enum for different types of content blocks
enum ContentBlockType {
  heading,
  paragraph,
  bulletPoints,
  image,
}

/// Represents a single content block in a blog article
class ContentBlock {
  final ContentBlockType type;
  final String content;
  final List<String>? bulletPoints;
  final String? imageUrl;
  final String? imageCaption;

  ContentBlock({
    required this.type,
    required this.content,
    this.bulletPoints,
    this.imageUrl,
    this.imageCaption,
  });

  /// Factory constructor to create ContentBlock from Firestore document
  factory ContentBlock.fromMap(Map<String, dynamic> map) {
    final typeString = map['type'] as String;
    final type = ContentBlockType.values.firstWhere(
      (e) => e.toString().split('.').last == typeString,
      orElse: () => ContentBlockType.paragraph,
    );

    return ContentBlock(
      type: type,
      content: map['content'] as String? ?? '',
      bulletPoints: List<String>.from(map['bulletPoints'] as List? ?? []),
      imageUrl: map['imageUrl'] as String?,
      imageCaption: map['imageCaption'] as String?,
    );
  }

  /// Convert to map for potential future use
  Map<String, dynamic> toMap() {
    return {
      'type': type.toString().split('.').last,
      'content': content,
      'bulletPoints': bulletPoints,
      'imageUrl': imageUrl,
      'imageCaption': imageCaption,
    };
  }
}

/// Represents a complete blog article
class Blog {
  final String id;
  final String title;
  final String description;
  final DateTime publishedDate;
  final int readTimeMinutes;
  final String? authorName;
  final String? authorImageUrl;
  final String? coverImageUrl;
  final List<ContentBlock> contentBlocks;
  final List<String>? tags;

  Blog({
    required this.id,
    required this.title,
    required this.description,
    required this.publishedDate,
    required this.readTimeMinutes,
    this.authorName,
    this.authorImageUrl,
    this.coverImageUrl,
    required this.contentBlocks,
    this.tags,
  });

  /// Factory constructor to create Blog from Firestore document
  factory Blog.fromMap(String docId, Map<String, dynamic> map) {
    return Blog(
      id: docId,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      publishedDate: _parseDate(map['publishedDate']),
      readTimeMinutes: map['readTimeMinutes'] as int? ?? 0,
      authorName: map['authorName'] as String?,
      authorImageUrl: map['authorImageUrl'] as String?,
      coverImageUrl: map['coverImageUrl'] as String?,
      contentBlocks: (map['contentBlocks'] as List?)
              ?.map((item) => ContentBlock.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      tags: List<String>.from(map['tags'] as List? ?? []),
    );
  }

  /// Helper method to parse date from Firestore
  static DateTime _parseDate(dynamic date) {
    if (date is DateTime) {
      return date;
    }
    if (date is String) {
      return DateTime.parse(date);
    }
    return DateTime.now();
  }

  /// Convert to map for potential future use
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'publishedDate': publishedDate.toIso8601String(),
      'readTimeMinutes': readTimeMinutes,
      'authorName': authorName,
      'authorImageUrl': authorImageUrl,
      'coverImageUrl': coverImageUrl,
      'contentBlocks': contentBlocks.map((c) => c.toMap()).toList(),
      'tags': tags,
    };
  }
}
