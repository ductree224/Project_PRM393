abstract class CommentEvent {}

class CommentLoad extends CommentEvent {
  final String trackExternalId;
  CommentLoad(this.trackExternalId);
}

class CommentLoadMore extends CommentEvent {
  final String trackExternalId;
  CommentLoadMore(this.trackExternalId);
}

class CommentAdd extends CommentEvent {
  final String trackExternalId;
  final String content;
  CommentAdd({required this.trackExternalId, required this.content});
}

class CommentDelete extends CommentEvent {
  final String commentId;
  CommentDelete(this.commentId);
}
