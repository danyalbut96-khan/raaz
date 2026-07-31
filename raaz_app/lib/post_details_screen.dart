import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'data/models/post_model.dart';
import 'data/repositories/post_repository.dart';
import 'data/repositories/comment_repository.dart';
import 'data/models/comment_model.dart';
import 'share_post_preview_screen.dart';

class PostDetailsScreen extends StatefulWidget {
  final String postId;
  const PostDetailsScreen({super.key, required this.postId});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final _postRepo = PostRepository();
  final _commentRepo = CommentRepository();
  PostModel? _post;
  bool _isLoading = true;
  String? _error;

  // Inline comment state
  List<CommentModel> _comments = [];
  bool _commentsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPost();
    _loadComments();
  }

  Future<void> _loadPost() async {
    try {
      final post = await _postRepo.getPost(widget.postId);
      if (mounted) setState(() { _post = post; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Failed to load post.'; _isLoading = false; });
    }
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _commentRepo.getComments(widget.postId);
      if (mounted) setState(() { _comments = comments; _commentsLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _commentsLoading = false);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_post!.isBookmarked ? 'Bookmarked!' : 'Bookmark removed'),
          behavior: SnackBarBehavior.floating,
        ));
      }
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

  void _showReactionPicker() {
    final post = _post;
    if (post == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('React to this post', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildReactionPickerItem(Icons.favorite, 'Care', '❤️', 'care', post.myReactionType),
                  _buildReactionPickerItem(Icons.psychology, 'Insightful', '🧠', 'insightful', post.myReactionType),
                  _buildReactionPickerItem(Icons.volunteer_activism, 'Support', '🤝', 'support', post.myReactionType),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReactionPickerItem(IconData icon, String label, String emoji, String type, String? myReactionType) {
    final isActive = myReactionType == type;
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _toggleReaction(type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFd8e2ff) : const Color(0xFFf1f3ff),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? const Color(0xFF004ac6) : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                color: isActive ? const Color(0xFF004ac6) : const Color(0xFF434655))),
          ],
        ),
      ),
    );
  }

  void _showCommentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CommentInputSheet(
        postId: widget.postId,
        commentRepo: _commentRepo,
        onCommentAdded: (comment) {
          setState(() {
            _comments.insert(0, comment);
            if (_post != null) {
              _post = _post!.copyWith(commentCount: _post!.commentCount + 1);
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004ac6);
    const Color surfaceColor = Color(0xFFf9f9ff);
    const Color onSurfaceVariant = Color(0xFF434655);
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
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Post', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 20)),
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
      body: SingleChildScrollView(
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
                        child: const Icon(Icons.security, color: primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.pseudonym, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          Text(
                            '${timeago.format(post.createdAt)}${post.category != null ? ' • ${post.category!.name}' : ''}',
                            style: const TextStyle(fontSize: 12, color: onSurfaceVariant),
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

                  // Action row: reactions + share
                  Row(
                    children: [
                      // Reaction icon button — tap to open picker
                      GestureDetector(
                        onTap: _showReactionPicker,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: post.myReactionType != null ? const Color(0xFFd8e2ff) : const Color(0xFFf1f3ff),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _reactionIcon(post.myReactionType),
                                size: 18,
                                color: post.myReactionType != null ? primaryColor : onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${post.reactionCount}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: post.myReactionType != null ? primaryColor : onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Comment icon
                      GestureDetector(
                        onTap: _showCommentSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf1f3ff),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.chat_bubble_outline, size: 18, color: onSurfaceVariant),
                              const SizedBox(width: 6),
                              Text('${post.commentCount}', style: const TextStyle(fontSize: 13, color: onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Share button inline
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const SharePostPreviewScreen())),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf1f3ff),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.share_outlined, size: 18, color: onSurfaceVariant),
                              SizedBox(width: 6),
                              Text('Share', style: TextStyle(fontSize: 13, color: onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Comments section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Comments (${post.commentCount})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: _showCommentSheet,
                  child: const Text('Add comment', style: TextStyle(color: primaryColor)),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Inline comments list
            if (_commentsLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ))
            else if (_comments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No comments yet. Be the first!',
                      style: TextStyle(color: outlineVariant, fontSize: 14)),
                ),
              )
            else
              ..._comments.map((c) => _buildCommentCard(c, primaryColor)).toList(),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.9),
            border: Border(top: BorderSide(color: outlineVariant.withOpacity(0.2))),
          ),
          child: GestureDetector(
            onTap: _showCommentSheet,
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
      ),
    );
  }

  IconData _reactionIcon(String? type) {
    switch (type) {
      case 'care': return Icons.favorite;
      case 'insightful': return Icons.psychology;
      case 'support': return Icons.volunteer_activism;
      default: return Icons.favorite_border;
    }
  }

  Widget _buildCommentCard(CommentModel c, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFe9edff).withOpacity(0.6)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.person, size: 16, color: primaryColor),
                ),
                const SizedBox(width: 8),
                Text(c.pseudonym,
                    style: TextStyle(fontWeight: FontWeight.w600, color: primaryColor, fontSize: 14)),
                const Spacer(),
                Text(timeago.format(c.createdAt),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF737686))),
              ],
            ),
            const SizedBox(height: 8),
            Text(c.body, style: const TextStyle(fontSize: 15, height: 1.5)),
            if (c.replies.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('${c.replies.length} ${c.replies.length == 1 ? 'reply' : 'replies'}',
                  style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w500)),
            ],
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

/// Inline comment input sheet shown at the bottom
class _CommentInputSheet extends StatefulWidget {
  final String postId;
  final CommentRepository commentRepo;
  final void Function(CommentModel) onCommentAdded;

  const _CommentInputSheet({
    required this.postId,
    required this.commentRepo,
    required this.onCommentAdded,
  });

  @override
  State<_CommentInputSheet> createState() => _CommentInputSheetState();
}

class _CommentInputSheetState extends State<_CommentInputSheet> {
  final TextEditingController _ctrl = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    try {
      final comment = await widget.commentRepo.addComment(postId: widget.postId, body: text);
      widget.onCommentAdded(comment);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to post comment.'), behavior: SnackBarBehavior.floating));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final outlineVariant = const Color(0xFFc3c6d7);
    final primaryColor = const Color(0xFF004ac6);

    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Add a comment', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFf1f3ff),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: outlineVariant.withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: _ctrl,
                    autofocus: true,
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Add an anonymous thought...',
                      hintStyle: TextStyle(color: outlineVariant, fontSize: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                      color: _isSending ? Colors.grey : primaryColor, shape: BoxShape.circle),
                  child: _isSending
                      ? const Padding(padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
