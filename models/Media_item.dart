// media_item.dart: a simple class (Dart Fundamentals: Classes & Objects).

// ay media item leiha: title, type(film aw series), status (watchlist, watching, watched), rating(0-5), progress(lel series ehna we2fna fi anhy Season w Episode) 
class MediaItem {
  String title;
  String type; // "Movie" or "Series"
  String status; // "Watchlist", "Watching", "Watched"
  int rating; // 0-5 stars 
  String progress; // example: "S2 E5" (only for series)
 
  // Constructor: gives the object its first data. 3lshan ne7ot el data w required 
  MediaItem({
    required this.title,
    required this.type,
    required this.status,
    this.rating = 0, // default value
    this.progress = "", // default value
  });
}