import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';
import '../models/category_model.dart';
import '../../core/supabase_client.dart';
import '../../core/pseudonym_generator.dart';

class PostRepository {
  // ─── Categories ─────────────────────────────────────────────
  Future<List<CategoryModel>> getCategories() async {
    final res = await supabase
        .from('categories')
        .select()
        .order('sort_order');
    return (res as List).map((e) => CategoryModel.fromJson(e)).toList();
  }

  // ─── Feed (paginated, chronological) ────────────────────────
  Future<List<PostModel>> getFeed({
    int page = 0,
    int pageSize = 20,
    String? categoryId,
    bool trending = false,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    var query = supabase
        .from('posts')
        .select('''
          *,
          categories ( id, name, icon ),
          reactions ( count ),
          comments ( count )
        ''')
        .eq('is_deleted', false);

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    if (trending) {
      // Trending is handled server-side via the view
      final res = await supabase
          .from('posts_trending')
          .select('*, categories ( id, name, icon )')
          .range(from, to);
      return _mapPosts(res as List);
    }

    final res = await query
        .order('created_at', ascending: false)
        .range(from, to);

    return _mapPosts(res as List);
  }

  // ─── Featured Posts ──────────────────────────────────────────
  Future<List<PostModel>> getFeaturedPosts() async {
    final res = await supabase
        .from('posts')
        .select('*, categories ( id, name, icon )')
        .eq('is_featured', true)
        .eq('is_deleted', false)
        .order('created_at', ascending: false)
        .limit(10);
    return _mapPosts(res as List);
  }

  // ─── Single Post ─────────────────────────────────────────────
  Future<PostModel?> getPost(String postId) async {
    final userId = supabase.auth.currentUser?.id;

    final res = await supabase
        .from('posts')
        .select('''
          *,
          categories ( id, name, icon )
        ''')
        .eq('id', postId)
        .eq('is_deleted', false)
        .maybeSingle();

    if (res == null) return null;

    // Fetch counts separately for accuracy
    final reactionCount = await _getReactionCount(postId);
    final commentCount = await _getCommentCount(postId);
    String? myReactionType;
    bool isBookmarked = false;

    if (userId != null) {
      final myReaction = await supabase
          .from('reactions')
          .select('type')
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();
      myReactionType = myReaction?['type'] as String?;

      final bookmark = await supabase
          .from('bookmarks')
          .select('id')
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();
      isBookmarked = bookmark != null;
    }

    final json = Map<String, dynamic>.from(res as Map);
    json['reaction_count'] = reactionCount;
    json['comment_count'] = commentCount;
    json['my_reaction_type'] = myReactionType;
    json['is_bookmarked'] = isBookmarked;

    return PostModel.fromJson(json);
  }

  // ─── Create Post ─────────────────────────────────────────────
  Future<PostModel> createPost({
    required String body,
    required String categoryId,
    String? mood,
    bool ghostMode = false,
    bool allowComments = true,
    bool allowSharing = true,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    final pseudonym = await PseudonymGenerator.generate();

    final res = await supabase
        .from('posts')
        .insert({
          'user_id': userId,
          'category_id': categoryId,
          'body': body,
          'mood': mood,
          'pseudonym': pseudonym,
          'is_ghost_mode': ghostMode,
          'allow_comments': allowComments,
          'allow_sharing': allowSharing,
        })
        .select('*, categories ( id, name, icon )')
        .single();

    return PostModel.fromJson(res);
  }

  // ─── Update Post ─────────────────────────────────────────────
  Future<void> updatePost({
    required String postId,
    String? body,
    String? categoryId,
    String? mood,
    bool? ghostMode,
    bool? allowComments,
    bool? allowSharing,
  }) async {
    final updates = <String, dynamic>{};
    if (body != null) updates['body'] = body;
    if (categoryId != null) updates['category_id'] = categoryId;
    if (mood != null) updates['mood'] = mood;
    if (ghostMode != null) updates['is_ghost_mode'] = ghostMode;
    if (allowComments != null) updates['allow_comments'] = allowComments;
    if (allowSharing != null) updates['allow_sharing'] = allowSharing;

    await supabase.from('posts').update(updates).eq('id', postId);
  }

  // ─── Delete Post (soft delete) ────────────────────────────────
  Future<void> deletePost(String postId) async {
    await supabase
        .from('posts')
        .update({'is_deleted': true})
        .eq('id', postId);
  }

  // ─── Reactions ───────────────────────────────────────────────
  Future<void> toggleReaction(String postId, String reactionType) async {
    final userId = supabase.auth.currentUser!.id;

    // Check existing reaction
    final existing = await supabase
        .from('reactions')
        .select('id, type')
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      if (existing['type'] == reactionType) {
        // Same reaction — remove it (toggle off)
        await supabase.from('reactions').delete().eq('id', existing['id']);
      } else {
        // Different reaction — update it
        await supabase
            .from('reactions')
            .update({'type': reactionType})
            .eq('id', existing['id']);
      }
    } else {
      // No reaction yet — insert
      await supabase.from('reactions').insert({
        'post_id': postId,
        'user_id': userId,
        'type': reactionType,
      });
    }
  }

  // ─── Bookmarks ───────────────────────────────────────────────
  Future<void> toggleBookmark(String postId) async {
    final userId = supabase.auth.currentUser!.id;
    final existing = await supabase
        .from('bookmarks')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      await supabase.from('bookmarks').delete().eq('id', existing['id']);
    } else {
      await supabase.from('bookmarks').insert({
        'post_id': postId,
        'user_id': userId,
      });
    }
  }

  // ─── Search ──────────────────────────────────────────────────
  Future<List<PostModel>> searchPosts(String query) async {
    final res = await supabase
        .from('posts')
        .select('*, categories ( id, name, icon )')
        .eq('is_deleted', false)
        .textSearch('body', query, type: TextSearchType.websearch)
        .order('created_at', ascending: false)
        .limit(50);
    return _mapPosts(res as List);
  }

  // ─── Realtime stream ─────────────────────────────────────────
  Stream<List<PostModel>> watchFeed() {
    return supabase
        .from('posts')
        .stream(primaryKey: ['id'])
        .eq('is_deleted', false)
        .order('created_at', ascending: false)
        .limit(20)
        .map((rows) => _mapPosts(rows));
  }

  // ─── Report ──────────────────────────────────────────────────
  Future<void> reportPost(String postId, String reason) async {
    await supabase.from('reports').insert({
      'reporter_id': supabase.auth.currentUser!.id,
      'post_id': postId,
      'reason': reason,
    });
  }

  // ─── Private helpers ─────────────────────────────────────────
  Future<int> _getReactionCount(String postId) async {
    final res = await supabase
        .from('reactions')
        .select('id')
        .eq('post_id', postId);
    return (res as List).length;
  }

  Future<int> _getCommentCount(String postId) async {
    final res = await supabase
        .from('comments')
        .select('id')
        .eq('post_id', postId)
        .eq('is_deleted', false);
    return (res as List).length;
  }

  List<PostModel> _mapPosts(List rows) {
    return rows.map((e) {
      final json = Map<String, dynamic>.from(e as Map);
      // Flatten nested counts if present from select
      if (json['reactions'] is List) {
        json['reaction_count'] = (json['reactions'] as List).length;
        json.remove('reactions');
      }
      if (json['comments'] is List) {
        json['comment_count'] = (json['comments'] as List).length;
        json.remove('comments');
      }
      return PostModel.fromJson(json);
    }).toList();
  }
}
