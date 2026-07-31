import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'core/supabase_client.dart';
import 'data/models/post_model.dart';
import 'data/repositories/post_repository.dart';
import 'post_details_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final _postRepo = PostRepository();
  List<PostModel> _bookmarks = [];
  bool _isLoading = true;

  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);
  static const Color _outlineVariant = Color(0xFFc3c6d7);

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _postRepo.getBookmarks();
      if (mounted) setState(() { _bookmarks = posts; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _bookmarks = []; _isLoading = false; });
    }
  }

  Future<void> _removeBookmark(String postId) async {
    try {
      await _postRepo.toggleBookmark(postId);
      setState(() => _bookmarks.removeWhere((p) => p.id == postId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Bookmark removed'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (_) {}
  }

  Future<void> _clearAllBookmarks() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All Bookmarks'),
        content: const Text('Are you sure you want to remove all saved posts?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        final userId = supabase.auth.currentUser?.id;
        if (userId != null) {
          await supabase.from('bookmarks').delete().eq('user_id', userId);
          setState(() => _bookmarks = []);
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.security, color: _primary, size: 22),
            const SizedBox(width: 8),
            const Text('RAAZ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _primary, letterSpacing: -0.5)),
          ],
        ),
        actions: [
          const Icon(Icons.notifications_none_outlined, color: _onSurfaceVariant),
          const SizedBox(width: 4),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 36, height: 36,
            decoration: const BoxDecoration(color: Color(0xFFe9edf8), shape: BoxShape.circle),
            child: const Icon(Icons.person, color: _onSurfaceVariant, size: 18),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _primary,
        onRefresh: _loadBookmarks,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Bookmarks',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _onSurface)),
                    if (_bookmarks.isNotEmpty)
                      TextButton(
                        onPressed: _clearAllBookmarks,
                        child: const Text('Clear all', style: TextStyle(color: _primary, fontSize: 13)),
                      ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (_bookmarks.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildBookmarkCard(_bookmarks[i]),
                  childCount: _bookmarks.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarkCard(PostModel post) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => PostDetailsScreen(postId: post.id))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: _primary.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.security, size: 18, color: _primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.pseudonym,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _onSurface)),
                        Text(timeago.format(post.createdAt),
                            style: const TextStyle(fontSize: 12, color: _onSurfaceVariant)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark, color: _primary, size: 22),
                    onPressed: () => _removeBookmark(post.id),
                    tooltip: 'Remove bookmark',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.body,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, height: 1.55, color: _onSurface)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.favorite_border, size: 16, color: _onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${post.reactionCount}',
                          style: const TextStyle(fontSize: 13, color: _onSurfaceVariant)),
                      const SizedBox(width: 16),
                      const Icon(Icons.chat_bubble_outline, size: 16, color: _onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${post.commentCount}',
                          style: const TextStyle(fontSize: 13, color: _onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: _primary.withOpacity(0.08), shape: BoxShape.circle),
            child: const Icon(Icons.bookmark_border, size: 40, color: _primary),
          ),
          const SizedBox(height: 20),
          const Text('No saved posts yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _onSurface)),
          const SizedBox(height: 8),
          const Text('Bookmark posts to find them here later.',
              style: TextStyle(fontSize: 14, color: _onSurfaceVariant)),
        ],
      ),
    );
  }
}
