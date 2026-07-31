/// Data model for a Comment (supports nested replies via parent_id)
class CommentModel {
  final String id;
  final String postId;
  final String? parentId;
  final String userId;
  final String body;
  final String pseudonym;
  final bool isDeleted;
  final DateTime createdAt;

  // Aggregated
  final int likeCount;
  final bool isLikedByMe;

  // Nested replies (populated on demand)
  final List<CommentModel> replies;

  const CommentModel({
    required this.id,
    required this.postId,
    this.parentId,
    required this.userId,
    required this.body,
    required this.pseudonym,
    this.isDeleted = false,
    required this.createdAt,
    this.likeCount = 0,
    this.isLikedByMe = false,
    this.replies = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      parentId: json['parent_id'] as String?,
      userId: json['user_id'] as String,
      body: json['body'] as String,
      pseudonym: json['pseudonym'] as String,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      likeCount: json['like_count'] as int? ?? 0,
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
    );
  }

  CommentModel copyWith({int? likeCount, bool? isLikedByMe, List<CommentModel>? replies}) {
    return CommentModel(
      id: id,
      postId: postId,
      parentId: parentId,
      userId: userId,
      body: body,
      pseudonym: pseudonym,
      isDeleted: isDeleted,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      replies: replies ?? this.replies,
    );
  }
}
