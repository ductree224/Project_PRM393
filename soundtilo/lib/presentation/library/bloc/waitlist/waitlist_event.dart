import 'package:equatable/equatable.dart';

import '../../../../domain/entities/track_entity.dart';

abstract class WaitlistEvent extends Equatable {
  const WaitlistEvent();

  @override
  List<Object?> get props => [];
}

// Gọi API GET /api/waitlist
class WaitlistLoad extends WaitlistEvent {}

// Gọi API POST /api/waitlist/tracks
class WaitlistAddTrack extends WaitlistEvent {
  final String trackExternalId;
  const WaitlistAddTrack(this.trackExternalId);

  @override
  List<Object?> get props => [trackExternalId];
}

// Gọi API DELETE /api/waitlist/tracks/{id}
class WaitlistRemoveTrack extends WaitlistEvent {
  final String trackExternalId;
  const WaitlistRemoveTrack(this.trackExternalId);

  @override
  List<Object?> get props => [trackExternalId];
}


// Event khi bài hát vừa nghe xong (Chuyển thành mờ)
class WaitlistMarkTrackAsPlayed extends WaitlistEvent {
  final String trackExternalId;
  const WaitlistMarkTrackAsPlayed(this.trackExternalId);
  @override List<Object?> get props => [trackExternalId];
}

// Event khi ấn vào bài hoặc vuốt phải bài mờ (Đưa lên đầu danh sách Active)
class WaitlistMoveToTopActive extends WaitlistEvent {
  final String trackExternalId;
  const WaitlistMoveToTopActive(this.trackExternalId);
  @override List<Object?> get props => [trackExternalId];
}
// Gọi API PUT /api/waitlist/tracks/reorder
// Cập nhật lại Event Reorder để mang theo số lượng bài mờ mới (nếu kéo mờ xuống active)
class WaitlistReorderTracks extends WaitlistEvent {
  final List<String> trackExternalIds;
  final int fadedCount; // Thêm dòng này
  const WaitlistReorderTracks(this.trackExternalIds, this.fadedCount);
  @override List<Object?> get props => [trackExternalIds, fadedCount];
}
class WaitlistInsertAndPlay extends WaitlistEvent {
  final TrackEntity track;
  const WaitlistInsertAndPlay(this.track);
  @override List<Object?> get props => [track];
}
