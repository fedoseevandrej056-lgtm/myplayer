class Track {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? artworkUrl;
  final String? uri;
  final String? youtubeId;
  final Duration? duration;
  final DateTime? addedAt;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.artworkUrl,
    this.uri,
    this.youtubeId,
    this.duration,
    this.addedAt,
  });

  factory Track.fromLocalFile({
    required String id,
    required String title,
    required String artist,
    String? album,
    String? artworkUrl,
    required String uri,
    Duration? duration,
  }) {
    return Track(
      id: id,
      title: title,
      artist: artist,
      album: album,
      artworkUrl: artworkUrl,
      uri: uri,
      duration: duration,
      addedAt: DateTime.now(),
    );
  }

  factory Track.fromYouTube({
    required String id,
    required String title,
    required String artist,
    String? album,
    String? artworkUrl,
    required String youtubeId,
    Duration? duration,
  }) {
    return Track(
      id: id,
      title: title,
      artist: artist,
      album: album,
      artworkUrl: artworkUrl,
      youtubeId: youtubeId,
      duration: duration,
      addedAt: DateTime.now(),
    );
  }

  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? artworkUrl,
    String? uri,
    String? youtubeId,
    Duration? duration,
    DateTime? addedAt,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      uri: uri ?? this.uri,
      youtubeId: youtubeId ?? this.youtubeId,
      duration: duration ?? this.duration,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Track &&
        other.id == id &&
        other.title == title &&
        other.artist == artist;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ artist.hashCode;

  @override
  String toString() {
    return 'Track{id: $id, title: $title, artist: $artist}';
  }
}
