import 'category_model.dart';

/// Data model for a Post
class PostModel {
  final String id;
  final String userId;
  final String? categoryId;
  final CategoryModel? category;
  final String body;
  final String? mood;
  final String pseudonym;
  final bool isFeatured;
  final bool isGhostMode;
  final bool allowComments;
  final bool allowSharing;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Aggregated counts (from join or separate query)
  final int reactionCount;
  final int commentCount;
  // Current user's reaction type (null if no reaction)
  final String? myReactionType;
  // Is bookmarked by current user
  final bool isBookmarked;

  const PostModel({
    required this.id,
    required this.userId,
    this.categoryId,
    this.category,
    required this.body,
    this.mood,
    required this.pseudonym,
    this.isFeatured = false,
    this.isGhostMode = false,
    this.allowComments = true,
    this.allowSharing = true,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.reactionCount = 0,
    this.commentCount = 0,
    this.myReactionType,
    this.isBookmarked = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Supabase returns embedded counts as [{"count": N}] when using reactions(count)
    int _parseCount(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is List && val.isNotEmpty) {
        final first = val.first;
        if (first is Map) return (first['count'] as int?) ?? 0;
      }
      return 0;
    }

    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String?,
      category: json['categories'] != null
          ? CategoryModel.fromJson(json['categories'] as Map<String, dynamic>)
          : null,
      body: json['body'] as String,
      mood: json['mood'] as String?,
      pseudonym: json['pseudonym'] as String,
      isFeatured: json['is_featured'] as bool? ?? false,
      isGhostMode: json['is_ghost_mode'] as bool? ?? false,
      allowComments: json['allow_comments'] as bool? ?? true,
      allowSharing: json['allow_sharing'] as bool? ?? true,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      reactionCount: json['reaction_count'] as int?
          ?? _parseCount(json['reactions']),
      commentCount: json['comment_count'] as int?
          ?? _parseCount(json['comments']),
      myReactionType: json['my_reaction_type'] as String?,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toInsertJson({
    required String userId,
    required String pseudonym,
  }) => {
    'user_id': userId,
    'category_id': categoryId,
    'body': body,
    'mood': mood,
    'pseudonym': pseudonym,
    'is_ghost_mode': isGhostMode,
    'allow_comments': allowComments,
    'allow_sharing': allowSharing,
  };

  PostModel copyWith({
    int? reactionCount,
    int? commentCount,
    String? myReactionType,
    bool? isBookmarked,
    bool clearReaction = false,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      categoryId: categoryId,
      category: category,
      body: body,
      mood: mood,
      pseudonym: pseudonym,
      isFeatured: isFeatured,
      isGhostMode: isGhostMode,
      allowComments: allowComments,
      allowSharing: allowSharing,
      isDeleted: isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
      reactionCount: reactionCount ?? this.reactionCount,
      commentCount: commentCount ?? this.commentCount,
      myReactionType: clearReaction ? null : (myReactionType ?? this.myReactionType),
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
