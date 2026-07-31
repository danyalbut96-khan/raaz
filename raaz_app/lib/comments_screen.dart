import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'data/models/comment_model.dart';
import 'data/repositories/comment_repository.dart';
import 'reply_thread_screen.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentRepo = CommentRepository();
  final TextEditingController _controller = TextEditingController();
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _commentRepo.getComments(widget.postId);
      if (mounted) setState(() { _comments = comments; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Could not load comments.'; _isLoading = false; });
    }
  }

  Future<void> _postComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      final comment = await _commentRepo.addComment(
          postId: widget.postId, body: text);
      _controller.clear();
      setState(() {
        _comments.insert(0, comment);
        _isSending = false;
      });
    } catch (_) {
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to post comment.'), behavior: SnackBarBehavior.floating));
    }
  }

  Future<void> _toggleLike(int index) async {
    final c = _comments[index];
    try {
      await _commentRepo.toggleCommentLike(c.id);
      setState(() {
        _comments[index] = c.copyWith(
          likeCount: c.isLikedByMe ? c.likeCount - 1 : c.likeCount + 1,
          isLikedByMe: !c.isLikedByMe,
        );
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF004ac6);
    final Color surfaceColor = const Color(0xFFF8FAFC);
    final Color outlineVariant = const Color(0xFFc3c6d7);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceColor.withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Comments', style: TextStyle(
            color: primaryColor, fontWeight: FontWeight.w700, fontSize: 22, letterSpacing: -0.5)),
        actions: [
          Icon(Icons.security, color: primaryColor),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : RefreshIndicator(
                        onRefresh: _loadComments,
                        child: _comments.isEmpty
                            ? ListView(children: const [
                                SizedBox(height: 120),
                                Center(child: Text('No comments yet. Be the first!',
                                    style: TextStyle(color: Color(0xFF737686)))),
                              ])
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _comments.length,
                                itemBuilder: (_, i) => _buildCommentCard(i, primaryColor),
                              ),
                      ),
          ),
          // Input bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(0.95),
                border: Border(top: BorderSide(color: outlineVariant.withOpacity(0.2))),
              ),
              child: Row(
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
                        controller: _controller,
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
                    onTap: _postComment,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(int index, Color primaryColor) {
    final c = _comments[index];
    final colors = [
      const Color(0xFF004ac6), const Color(0xFF006874),
      const Color(0xFF0058be), const Color(0xFF334AC0),
    ];
    final nameColor = colors[index % colors.length];

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
                  decoration: BoxDecoration(color: nameColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.person, size: 16, color: nameColor),
                ),
                const SizedBox(width: 8),
                Text(c.pseudonym,
                    style: TextStyle(fontWeight: FontWeight.w600, color: nameColor, fontSize: 14)),
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
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleLike(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: c.isLikedByMe ? const Color(0xFFd8e2ff) : const Color(0xFFf1f3ff),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(children: [
                      Icon(c.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                          size: 14,
                          color: c.isLikedByMe ? Colors.red : const Color(0xFF434655)),
                      const SizedBox(width: 4),
                      Text('${c.likeCount}', style: const TextStyle(fontSize: 12)),
                    ]),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ReplyThreadScreen(
                          postId: widget.postId, parentCommentId: c.id))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: const Color(0xFFf1f3ff), borderRadius: BorderRadius.circular(20)),
                    child: const Row(children: [
                      Icon(Icons.reply, size: 14, color: Color(0xFF434655)),
                      SizedBox(width: 4),
                      Text('Reply', style: TextStyle(fontSize: 12)),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
