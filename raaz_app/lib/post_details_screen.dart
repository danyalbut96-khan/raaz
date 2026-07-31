import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'data/models/post_model.dart';
import 'data/repositories/post_repository.dart';
import 'comments_screen.dart';
import 'share_post_preview_screen.dart';

class PostDetailsScreen extends StatefulWidget {
  final String postId;
  const PostDetailsScreen({super.key, required this.postId});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final _postRepo = PostRepository();
  PostModel? _post;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    try {
      final post = await _postRepo.getPost(widget.postId);
      if (mounted) setState(() { _post = post; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Failed to load post.'; _isLoading = false; });
    }
  }

  Future<void> _toggleReaction(String type) async {
    if (_post == null) return;
    try {
      await _postRepo.toggleReaction(widget.postId, type);
      final already = _post!.myReactionType == type;
      setState(() {
        _post = _post!.copyWith(
          reactionCount: already ? _post!.reactionCount - 1 : _post!.reactionCount + 1,
          myReactionType: already ? null : type,
          clearReaction: already,
        );
      });
    } catch (_) {}
  }

  Future<void> _toggleBookmark() async {
    if (_post == null) return;
    try {
      await _postRepo.toggleBookmark(widget.postId);
      setState(() => _post = _post!.copyWith(isBookmarked: !_post!.isBookmarked));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_post!.isBookmarked ? 'Bookmarked!' : 'Bookmark removed'),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (_) {}
  }

  Future<void> _reportPost() async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(children: [
          const ListTile(title: Text('Report this post', style: TextStyle(fontWeight: FontWeight.bold))),
          ListTile(leading: const Icon(Icons.block), title: const Text('Spam'), onTap: () => Navigator.pop(context, 'spam')),
          ListTile(leading: const Icon(Icons.warning_amber), title: const Text('Hate Speech'), onTap: () => Navigator.pop(context, 'hate_speech')),
          ListTile(leading: const Icon(Icons.person_off), title: const Text('Harassment'), onTap: () => Navigator.pop(context, 'harassment')),
          ListTile(leading: const Icon(Icons.info_outline), title: const Text('Misinformation'), onTap: () => Navigator.pop(context, 'misinformation')),
        ]),
      ),
    );
    if (reason != null) {
      await _postRepo.reportPost(widget.postId, reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Report submitted. Thank you.'), behavior: SnackBarBehavior.floating));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF004ac6);
    final Color surfaceColor = const Color(0xFFf9f9ff);
    final Color onSurfaceVariant = const Color(0xFF434655);
    final Color outlineVariant = const Color(0xFFc3c6d7);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: surfaceColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _post == null) {
      return Scaffold(
        backgroundColor: surfaceColor,
        appBar: AppBar(backgroundColor: surfaceColor, elevation: 0,
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
        body: Center(child: Text(_error ?? 'Post not found.')),
      );
    }

    final post = _post!;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceColor.withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Post', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 20)),
        actions: [
          IconButton(
            icon: Icon(post.isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: primaryColor),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: onSurfaceVariant),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Post Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                    border: Border.all(color: outlineVariant.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author row
                      Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                            child: Icon(Icons.security, color: primaryColor),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post.pseudonym, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              Text(
                                '${timeago.format(post.createdAt)}${post.category != null ? ' • ${post.category!.name}' : ''}',
                                style: TextStyle(fontSize: 12, color: onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Body
                      Text(post.body, style: const TextStyle(fontSize: 16, height: 1.65)),
                      if (post.mood != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: const Color(0xFFf1f3ff), borderRadius: BorderRadius.circular(12)),
                          child: Text(post.mood!, style: const TextStyle(fontSize: 13)),
                        ),
                      ],
                      Divider(color: outlineVariant.withOpacity(0.3), height: 32),
                      // Reactions
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildReactionChip(Icons.favorite, '${post.reactionCount} Care',
                                isActive: post.myReactionType == 'care',
                                onTap: () => _toggleReaction('care')),
                            const SizedBox(width: 8),
                            _buildReactionChip(Icons.psychology, 'Insightful',
                                isActive: post.myReactionType == 'insightful',
                                onTap: () => _toggleReaction('insightful')),
                            const SizedBox(width: 8),
                            _buildReactionChip(Icons.volunteer_activism, 'Support',
                                isActive: post.myReactionType == 'support',
                                onTap: () => _toggleReaction('support')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Comments header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Comments (${post.commentCount})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => CommentsScreen(postId: post.id)));
                      },
                      child: Text('View all', style: TextStyle(color: primaryColor)),
                    ),
                  ],
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),

          // Floating share button
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SharePostPreviewScreen())),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.share),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.9),
            border: Border(top: BorderSide(color: outlineVariant.withOpacity(0.2))),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => CommentsScreen(postId: post.id))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf1f3ff),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: outlineVariant.withOpacity(0.3)),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text('Add a comment...',
                        style: TextStyle(color: outlineVariant, fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReactionChip(IconData icon, String label,
      {required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFd8e2ff) : const Color(0xFFf1f3ff),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18,
                color: isActive ? const Color(0xFF004ac6) : const Color(0xFF434655)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: isActive ? const Color(0xFF004ac6) : const Color(0xFF434655))),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Bookmark'),
              onTap: () { Navigator.pop(context); _toggleBookmark(); }),
          ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Report'),
              onTap: () { Navigator.pop(context); _reportPost(); }),
        ]),
      ),
    );
  }
}
