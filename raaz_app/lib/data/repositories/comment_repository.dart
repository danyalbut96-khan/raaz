import '../models/comment_model.dart';
import '../../core/supabase_client.dart';
import '../../core/pseudonym_generator.dart';

class CommentRepository {
  // ─── Get a single comment by ID ──────────────────────────────
  Future<CommentModel?> getComment(String commentId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      final res = await supabase
          .from('comments')
          .select('*')
          .eq('id', commentId)
          .maybeSingle();
      if (res == null) return null;
      final json = Map<String, dynamic>.from(res as Map);
      
      final likeCount = await _getLikeCount(commentId);
      bool isLikedByMe = false;
      if (userId != null) {
        final liked = await supabase
            .from('comment_likes')
            .select('id')
            .eq('comment_id', commentId)
            .eq('user_id', userId)
            .maybeSingle();
        isLikedByMe = liked != null;
      }
      json['like_count'] = likeCount;
      json['is_liked_by_me'] = isLikedByMe;
      return CommentModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  // ─── Get top-level comments for a post ───────────────────────
  Future<List<CommentModel>> getComments(String postId) async {
    final userId = supabase.auth.currentUser?.id;

    final res = await supabase
        .from('comments')
        .select('*')
        .eq('post_id', postId)
        .isFilter('parent_id', null)   // top-level only
        .eq('is_deleted', false)
        .order('created_at', ascending: true);

    final comments = <CommentModel>[];
    for (final row in (res as List)) {
      final json = Map<String, dynamic>.from(row as Map);
      final commentId = json['id'] as String;

      // Get like count and whether current user liked it
      final likeCount = await _getLikeCount(commentId);
      bool isLikedByMe = false;
      if (userId != null) {
        final liked = await supabase
            .from('comment_likes')
            .select('id')
            .eq('comment_id', commentId)
            .eq('user_id', userId)
            .maybeSingle();
        isLikedByMe = liked != null;
      }
      json['like_count'] = likeCount;
      json['is_liked_by_me'] = isLikedByMe;

      final comment = CommentModel.fromJson(json);

      // Load nested replies (1 level deep for display)
      final replies = await getReplies(commentId);
      comments.add(comment.copyWith(replies: replies));
    }
    return comments;
  }

  // ─── Get replies for a comment ───────────────────────────────
  Future<List<CommentModel>> getReplies(String parentId) async {
    final userId = supabase.auth.currentUser?.id;

    final res = await supabase
        .from('comments')
        .select('*')
        .eq('parent_id', parentId)
        .eq('is_deleted', false)
        .order('created_at', ascending: true);

    final replies = <CommentModel>[];
    for (final row in (res as List)) {
      final json = Map<String, dynamic>.from(row as Map);
      final commentId = json['id'] as String;

      final likeCount = await _getLikeCount(commentId);
      bool isLikedByMe = false;
      if (userId != null) {
        final liked = await supabase
            .from('comment_likes')
            .select('id')
            .eq('comment_id', commentId)
            .eq('user_id', userId)
            .maybeSingle();
        isLikedByMe = liked != null;
      }
      json['like_count'] = likeCount;
      json['is_liked_by_me'] = isLikedByMe;

      replies.add(CommentModel.fromJson(json));
    }
    return replies;
  }

  // ─── Add comment ─────────────────────────────────────────────
  Future<CommentModel> addComment({
    required String postId,
    required String body,
    String? parentId,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    final pseudonym = await PseudonymGenerator.generate();

    final res = await supabase
        .from('comments')
        .insert({
          'post_id': postId,
          'parent_id': parentId,
          'user_id': userId,
          'body': body,
          'pseudonym': pseudonym,
        })
        .select()
        .single();

    return CommentModel.fromJson(res);
  }

  // ─── Delete comment (soft delete) ────────────────────────────
  Future<void> deleteComment(String commentId) async {
    await supabase
        .from('comments')
        .update({'is_deleted': true})
        .eq('id', commentId);
  }

  // ─── Toggle comment like ─────────────────────────────────────
  Future<void> toggleCommentLike(String commentId) async {
    final userId = supabase.auth.currentUser!.id;
    final pseudonym = await PseudonymGenerator.generate();

    final existing = await supabase
        .from('comment_likes')
        .select('id')
        .eq('comment_id', commentId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      await supabase.from('comment_likes').delete().eq('id', existing['id']);
    } else {
      await supabase.from('comment_likes').insert({
        'comment_id': commentId,
        'user_id': userId,
        'pseudonym': pseudonym,
      });
    }
  }

  // ─── Realtime stream for comments ────────────────────────────
  Stream<List<Map<String, dynamic>>> watchComments(String postId) {
    return supabase
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .order('created_at', ascending: true)
        .map((rows) => rows
            .where((r) => r['is_deleted'] == false && r['parent_id'] == null)
            .toList());
  }

  // ─── Private helpers ─────────────────────────────────────────
  Future<int> _getLikeCount(String commentId) async {
    final res = await supabase
        .from('comment_likes')
        .select('id')
        .eq('comment_id', commentId);
    return (res as List).length;
  }
}
