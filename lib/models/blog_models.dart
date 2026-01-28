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

/// Represents a tab in a blog article with test information
class BlogTab {
  final String title;
  final String icon; // Flutter icon name
  final String safeStatus; // "Safe to continue" message
  final String doText; // What to do
  final String dontText; // What not to do
  final String whoShouldAvoid; // Who should avoid this activity
  final String redFlags; // Warning signs to watch for

  BlogTab({
    required this.title,
    required this.icon,
    required this.safeStatus,
    required this.doText,
    required this.dontText,
    required this.whoShouldAvoid,
    required this.redFlags,
  });

  /// Factory constructor to create BlogTab from Firestore document
  factory BlogTab.fromMap(Map<String, dynamic> map) {
    return BlogTab(
      title: map['title'] as String? ?? '',
      icon: map['icon'] as String? ?? 'sports_volleyball',
      safeStatus: map['safeStatus'] as String? ?? '',
      doText: map['doText'] as String? ?? '',
      dontText: map['dontText'] as String? ?? '',
      whoShouldAvoid: map['whoShouldAvoid'] as String? ?? '',
      redFlags: map['redFlags'] as String? ?? '',
    );
  }

  /// Convert to map for potential future use
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'icon': icon,
      'safeStatus': safeStatus,
      'doText': doText,
      'dontText': dontText,
      'whoShouldAvoid': whoShouldAvoid,
      'redFlags': redFlags,
    };
  }
}

/// Represents a single content block in a blog article
class ContentBlock {
  final ContentBlockType type;
  final String content;
  final String title;
  final String icon;
  final List<String>? bulletPoints;
  final String? imageUrl;
  final String? imageCaption;
  final TestDetails? testDetails;

  ContentBlock({
    required this.type,
    required this.content,
    required this.title,
    required this.icon,
    this.bulletPoints,
    this.imageUrl,
    this.imageCaption,
    this.testDetails,
  });

  /// Factory constructor to create ContentBlock from Firestore document
  factory ContentBlock.fromMap(Map<String, dynamic> map) {
    final typeString = map['type'] as String;
    final type = ContentBlockType.values.firstWhere(
      (e) => e.toString().split('.').last == typeString,
      orElse: () => ContentBlockType.paragraph,
    );

    // Parse test details if present
    TestDetails? testDetails;
    if (map['testDetails'] != null) {
      testDetails = TestDetails.fromMap(map['testDetails'] as Map<String, dynamic>);
    }

    return ContentBlock(
      type: type,
      content: map['content'] as String? ?? '',
      title: map['title'] as String? ?? '',
      icon: map['icon'] as String? ?? 'sports_volleyball',
      bulletPoints: List<String>.from(map['bulletPoints'] as List? ?? []),
      imageUrl: map['imageUrl'] as String?,
      imageCaption: map['imageCaption'] as String?,
      testDetails: testDetails,
    );
  }

  /// Convert to map for potential future use
  Map<String, dynamic> toMap() {
    return {
      'type': type.toString().split('.').last,
      'content': content,
      'title': title,
      'icon': icon,
      'bulletPoints': bulletPoints,
      'imageUrl': imageUrl,
      'imageCaption': imageCaption,
      'testDetails': testDetails?.toMap(),
    };
  }
}

/// Represents test details with detailed information arrays
class TestDetails {
  final List<String> howToDo;
  final List<String> whenToDo;
  final List<String> whoIsThisTestFor;
  final List<String> precautions;
  final List<String> avoidIf;

  TestDetails({
    required this.howToDo,
    required this.whenToDo,
    required this.whoIsThisTestFor,
    required this.precautions,
    required this.avoidIf,
  });

  factory TestDetails.fromMap(Map<String, dynamic> map) {
    return TestDetails(
      howToDo: List<String>.from(map['howToDo'] as List? ?? []),
      whenToDo: List<String>.from(map['whenToDo'] as List? ?? []),
      whoIsThisTestFor: List<String>.from(map['whoIsThisTestFor'] as List? ?? []),
      precautions: List<String>.from(map['precautions'] as List? ?? []),
      avoidIf: List<String>.from(map['avoidIf'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'howToDo': howToDo,
      'whenToDo': whenToDo,
      'whoIsThisTestFor': whoIsThisTestFor,
      'precautions': precautions,
      'avoidIf': avoidIf,
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
  final List<BlogTab>? tabs; // Tabs with test information

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
    this.tabs,
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
      tabs: (map['tabs'] as List?)
              ?.map((item) => BlogTab.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
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
      'tabs': tabs?.map((t) => t.toMap()).toList(),
    };
  }
}
