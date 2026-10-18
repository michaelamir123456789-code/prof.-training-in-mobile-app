// This file defines what a "Movie" or "Series" actually is.
 
enum MediaType { movie, series } // A list of allowed types. It can only be a movie or a series.

/// watchlist = "I want to watch this later"
/// watching  = "I'm in the middle of it"
/// watched   = "I finished it"
enum WatchStatus { watchlist, watching, watched }

/// kol item fel user's library leiha shwayet 7agat (movie aw series).
class MediaItem {
  final String id; // unique id 
  final String title;
  final MediaType type;
  final WatchStatus status;
  final int rating; // 0 = not rated yet, 1-5 stars
  final String progress; // e.g. "S2 · E5" (useful for series, optional)
  final DateTime addedAt;

  // The constructor requires all these fields to be passed in.
  const MediaItem({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.rating,
    required this.progress,
    required this.addedAt,
  });
  
 // A helper method to create a *copy* of an item with updated values.
  // For example, if you only want to change the rating, you use this.
  MediaItem copyWith({
    String? title,
    MediaType? type,
    WatchStatus? status,
    int? rating,
    String? progress,
  }) {
    return MediaItem(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      progress: progress ?? this.progress,
      addedAt: addedAt,
    );
  }

//  toJson(): be converts the Dart object into text (JSON) so it can be saved in the phone's memory, and turns it back into a Dart object when loading.
// Converts the Dart object into a JSON Map so we can save it as text.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
        'status': status.name,
        'rating': rating,
        'progress': progress,
        'addedAt': addedAt.toIso8601String(),
      };
  // fromJson(): 3aks toJson: da cbe onverts a saved JSON Map back into a Dart object.

  factory MediaItem.fromJson(Map<String, dynamic> json) => MediaItem(
        id: json['id'] as String,
        title: json['title'] as String,
        type: MediaType.values.byName(json['type'] as String),
        status: WatchStatus.values.byName(json['status'] as String),
        rating: json['rating'] as int,
        progress: (json['progress'] as String?) ?? '',
        addedAt: DateTime.parse(json['addedAt'] as String),
      );
}