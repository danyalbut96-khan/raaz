import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'data/models/comment_model.dart';
import 'data/repositories/comment_repository.dart';

class ReplyThreadScreen extends StatefulWidget {
  final String postId;
  final String parentCommentId;
  const ReplyThreadScreen({super.key, required this.postId, required this.parentCommentId});

  @override
  State<ReplyThreadScreen> createState() => _ReplyThreadScreenState();
}

class _ReplyThreadScreenState extends State<ReplyThreadScreen> {
  final _commentRepo = CommentRepository();
  final TextEditingController _controller = TextEditingController();
  CommentModel? _rootComment;
  List<CommentModel> _replies = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadThread();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadThread() async {
    try {
      final replies = await _commentRepo.getReplies(widget.parentCommentId);
      if (mounted) setState(() { _replies = replies; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _postReply() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    try {
      final reply = await _commentRepo.addComment(
        postId: widget.postId,
        body: text,
        parentId: widget.parentCommentId,
      );
      _controller.clear();
      setState(() { _replies.add(reply); _isSending = false; });
    } catch (_) {
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to post reply.'), behavior: SnackBarBehavior.floating));
    }
  }

  Future<void> _toggleLike(int index) async {
    final r = _replies[index];
    try {
      await _commentRepo.toggleCommentLike(r.id);
      setState(() {
        _replies[index] = r.copyWith(
          likeCount: r.isLikedByMe ? r.likeCount - 1 : r.likeCount + 1,
          isLikedByMe: !r.isLikedByMe,
        );
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF004ac6);
    final Color surfaceColor = const Color(0xFFf9f9ff);
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
        title: Text('Reply Thread',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 20)),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadThread,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Replies
                        ..._replies.asMap().entries.map((e) => _buildReplyCard(e.key, e.value, primaryColor)),
                        if (_replies.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: Text('No replies yet. Start the thread!',
                                style: TextStyle(color: Color(0xFF737686)))),
                          ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
          ),
          // Reply input bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(0.95),
                border: Border(top: BorderSide(color: outlineVariant.withOpacity(0.2))),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf1f3ff),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: outlineVariant.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Add a reply...',
                              hintStyle: TextStyle(color: outlineVariant, fontSize: 14),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Icon(Icons.alternate_email, color: primaryColor, size: 20),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _postReply,
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

  Widget _buildReplyCard(int index, CommentModel reply, Color primaryColor) {
    final colors = [const Color(0xFF004ac6), const Color(0xFF006874), const Color(0xFF0058be)];
    final nameColor = colors[index % colors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 2, height: 80, color: primaryColor.withOpacity(0.2),
              margin: const EdgeInsets.only(right: 12, top: 4)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border(left: BorderSide(color: primaryColor.withOpacity(0.2), width: 3)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: nameColor.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.person, size: 14, color: nameColor),
                    ),
                    const SizedBox(width: 8),
                    Text(reply.pseudonym, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: nameColor)),
                    const Spacer(),
                    Text(timeago.format(reply.createdAt), style: const TextStyle(fontSize: 11, color: Color(0xFF737686))),
                  ]),
                  const SizedBox(height: 8),
                  Text(reply.body, style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF434655))),
                  const SizedBox(height: 8),
                  Row(children: [
                    GestureDetector(
                      onTap: () => _toggleLike(index),
                      child: Row(children: [
                        Icon(reply.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                            size: 14,
                            color: reply.isLikedByMe ? Colors.red : const Color(0xFF434655)),
                        const SizedBox(width: 4),
                        Text('${reply.likeCount}', style: const TextStyle(fontSize: 12)),
                      ]),
                    ),
                    const SizedBox(width: 16),
                    Text('Reply', style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w500)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
