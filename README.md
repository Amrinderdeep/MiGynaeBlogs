# MiGynae Blogs

A beautiful, scalable Flutter app for displaying blog articles fetched from Firebase Firestore. This app is designed to support multiple blogs with minimal code changes.

## Features

✨ **Key Features:**
- Fetch blog articles from Firebase Firestore
- Beautiful, responsive UI with Material Design 3
- Support for rich content blocks (headings, paragraphs, bullet points, images)
- Display blog metadata (published date, read time, author)
- Optimized for mobile devices
- Built for scalability with future features in mind

## Project Structure

```
lib/
├── main.dart                      # App entry point and Firebase initialization
├── firebase_options.dart          # Firebase configuration
├── models/
│   └── blog_models.dart           # Data models (Blog, ContentBlock)
├── services/
│   └── blog_service.dart          # Firestore service layer
├── pages/
│   └── blog_detail_page.dart      # Main blog detail page UI
```

## Architecture & Design Decisions

### 1. **Scalable Data Models**

The app uses flexible data models designed for future expansion:

- **ContentBlockType Enum**: Allows different types of content (heading, paragraph, bullets, images)
- **Flexible ContentBlock Structure**: Each block can have different properties based on its type
- **Blog Model**: Contains metadata and an array of content blocks

This design allows adding new content types without major refactoring.

### 2. **Service Layer Pattern**

The `BlogService` class abstracts all Firestore operations:

```dart
// Current implementation
- getBlogById(String blogId) // Fetch single blog
- getAllBlogs() // Get all blogs
- getBlogsWithPagination() // For future list view
- getBlogsByTag() // For filtering
- getLatestBlogs() // For sorting
```

**Benefits:**
- Easy to switch to different backend later
- Centralized error handling
- Mockable for testing
- Pre-built for future features

### 3. **Efficient UI Rendering**

The `BlogDetailPage` uses:

- **CustomScrollView with SliverAppBar**: Smooth scrolling with collapsible header
- **Lazy Content Block Building**: Only renders visible widgets
- **Image Error Handling**: Graceful fallbacks for failed image loads
- **Responsive Typography**: Uses Material Design 3 text styles

### 4. **Firebase Firestore Schema**

The schema is designed for easy querying and scaling:

```
Collection: blogs
├── Document: {blog_id}
│   ├── title: string
│   ├── description: string
│   ├── publishedDate: timestamp
│   ├── readTimeMinutes: number
│   ├── authorName: string (optional)
│   ├── authorImageUrl: string (optional)
│   ├── coverImageUrl: string (optional)
│   ├── tags: array (optional)
│   └── contentBlocks: array
│       └── [{type, content, bulletPoints?, imageUrl?, imageCaption?}]
```

**Schema Benefits:**
- Flat structure for fast reads
- Content blocks as array for flexible content
- Tags enable future filtering
- Optional fields reduce storage for simple blogs

## Getting Started

### Prerequisites

- Flutter SDK (3.10.7 or higher)
- Dart SDK
- iOS Simulator or Android Emulator
- Firebase account

### Installation

1. **Clone the repository**
   ```bash
   cd migynaeblogs
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase** (See [FIREBASE_SETUP.md](FIREBASE_SETUP.md))
   
   Quick start:
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```

4. **Create sample blog data in Firestore** (See FIREBASE_SETUP.md for detailed schema)

5. **Run the app**
   ```bash
   # iOS Simulator
   flutter run -d "iPhone 15 Pro"
   
   # Android Emulator
   flutter run -d emulator-5554
   ```

## Usage

### Displaying a Blog

The app currently displays a blog with ID `sample_blog`. To change it:

```dart
// In lib/main.dart
home: const BlogDetailPage(blogId: 'your_blog_id'),
```

### Adding a New Blog

1. Create a new document in Firestore `blogs` collection
2. Use any of the document ID as `blog_id`
3. Add blog data matching the schema (see FIREBASE_SETUP.md)
4. Reference it in the app

## Performance Optimizations

✅ **Speed & Efficiency:**

1. **Firestore Caching**: Cloud Firestore automatically caches data
2. **Network Optimization**: Only fetches data when needed
3. **Image Lazy Loading**: Images load when scrolled into view
4. **Efficient Widget Building**: CustomScrollView prevents rebuilding off-screen widgets
5. **Optimized Content Blocks**: Each block type only renders necessary fields

**Load Time Targets:**
- Initial load: < 2 seconds (with network)
- Cached load: < 500ms
- Image rendering: Progressive (shows as they load)

## Future Enhancements

The app is structured to easily support:

1. **Blog List View**
   ```dart
   // Use BlogService.getAllBlogs() or getLatestBlogs()
   // Create a BlogListPage widget
   ```

2. **Search & Filtering**
   ```dart
   // Use BlogService.getBlogsByTag(tag)
   // Add search/filter UI
   ```

3. **Comments & Reactions**
   ```dart
   // Add new collection: blogs/{blogId}/comments
   // Extend Blog model with engagement metrics
   ```

4. **User Authentication**
   ```dart
   // Add Firebase Auth
   // Track reading history and bookmarks
   ```

5. **Analytics**
   ```dart
   // Add Firebase Analytics
   // Track page views and user engagement
   ```

6. **Admin Dashboard**
   ```dart
   // Create web admin panel
   // Manage blogs and content
   ```

## Code Walkthrough

### Main Entry Point (lib/main.dart)

```dart
// Initializes Firebase before running the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### Data Models (lib/models/blog_models.dart)

Two main models:
- `ContentBlock`: Represents a single content item (heading, paragraph, etc.)
- `Blog`: Complete article with metadata and content blocks

Both include `fromMap()` factory constructors for easy Firestore integration.

### Service Layer (lib/services/blog_service.dart)

Singleton pattern ensures only one Firestore instance:

```dart
static final BlogService _instance = BlogService._internal();

factory BlogService() {
  return _instance;
}
```

Pre-built methods for common queries:
- `getBlogById()`: Fetch single blog
- `getAllBlogs()`: Get all blogs
- `getLatestBlogs()`: Sort by date
- `getBlogsByTag()`: Filter by tags

### UI Page (lib/pages/blog_detail_page.dart)

Uses `FutureBuilder` for async data loading with states:
- **Loading**: Shows spinner
- **Error**: Displays error with retry button
- **Success**: Renders blog content

Content rendering uses `_buildContentBlock()` method for type-specific formatting.

## Design Philosophy

🎨 **Design Principles:**

1. **Clean Typography**: Material Design 3 text hierarchy
2. **Whitespace**: Generous spacing for readability
3. **Responsive Design**: Adapts to different screen sizes
4. **Error Handling**: Graceful fallbacks for images and data
5. **Visual Hierarchy**: Important content stands out
6. **Accessibility**: Good contrast ratios and readable fonts

## Known Limitations

- Single blog display (by design for this task)
- Test mode Firestore (not production-ready)
- No offline support (could be added with local caching)
- Image loading from external URLs only (no local assets)

## Assumptions

1. **All blog URLs are publicly accessible** - Images and cover URLs should be CORS-enabled
2. **Firestore is in test mode** - For development only; production needs proper security rules
3. **Blog ID is known** - App currently hardcodes `sample_blog`; list view would add discovery
4. **Content blocks are well-formed** - No validation of malformed content in Firestore
5. **Images are JPEG/PNG** - Other formats might not load properly

## Testing

To test the app locally:

1. Create sample blog data (see FIREBASE_SETUP.md)
2. Run on simulator
3. Check that:
   - Blog title loads correctly
   - Published date displays
   - Read time shows correctly
   - Content blocks render with proper formatting
   - Cover image loads and scrolls with parallax
   - Metadata (author, tags) display correctly

## Troubleshooting

**App won't load?**
- Check Firebase is initialized (see console output)
- Verify Firestore database exists
- Check internet connection

**Images not showing?**
- Verify URLs are publicly accessible
- Test with placeholder URLs from placeholder.com
- Check browser console for CORS errors

**Slow loading?**
- Check internet connection
- Verify Firestore documents are small
- Consider adding pagination for large content blocks

## Dependencies

- `firebase_core: ^3.0.0` - Firebase initialization
- `cloud_firestore: ^5.0.0` - Firestore database access
- `intl: ^0.19.0` - Date formatting

## File Size & Performance

- App bundle: ~50MB (includes Flutter runtime)
- First load: ~2-3 seconds
- Cached load: <500ms
- Database document: ~10-50KB per blog (varies with images)

## License

This project is part of the MiGynae hiring task.

## Support

For issues or questions about setup, refer to:
1. [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Firebase configuration guide
2. [Flutter Documentation](https://flutter.dev/docs)
3. [Firebase Documentation](https://firebase.google.com/docs)


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
