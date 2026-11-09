// add_item_screen.dart - screen used to add or edit a movie / series.
// Topics used: StatefulWidget, Form, TextFormField, validation,
// TextEditingController, setState, Navigator.pop (send data back).
import 'package:flutter/material.dart';
import '../../../models/media_item.dart';
 
class AddItemScreen extends StatefulWidget {
  // null = we are adding a new title, not null = we are editing it.
  final MediaItem? item;
  const AddItemScreen({super.key, this.item});
 
  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}
 
class _AddItemScreenState extends State<AddItemScreen> {
  final formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final progressCtrl = TextEditingController();
 
  // The user's choices (state variables).
  String type = "Movie";
  String status = "Watchlist";
  int rating = 0;
 
  // initState runs once, when the screen opens.
  // If we are editing, fill the form with the old data.
  // "??" gives a default value when the left side is null.
  @override
  void initState() {
    super.initState();
    titleCtrl.text = widget.item?.title ?? "";
    progressCtrl.text = widget.item?.progress ?? "";
    type = widget.item?.type ?? "Movie";
    status = widget.item?.status ?? "Watchlist";
    rating = widget.item?.rating ?? 0;
  }
 
  @override
  void dispose() {
    titleCtrl.dispose();
    progressCtrl.dispose();
    super.dispose();
  }
 
  // Create the item and send it back to the home screen.
  void save() {
    if (!formKey.currentState!.validate()) return;
 
    MediaItem newItem = MediaItem(
      title: titleCtrl.text.trim(),
      type: type,
      status: status,
      // A title on the watchlist cannot have a rating.
      rating: status == "Watchlist" ? 0 : rating,
      // Progress is only saved for series.
      progress: type == "Series" ? progressCtrl.text.trim() : "",
    );
 
    Navigator.pop(context, newItem); // pop = go back + return data
  }
 
  // A button used for choosing a value (Movie / Series / status).
  Widget optionButton(String text, bool selected, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: selected ? Colors.deepPurple : Colors.grey[850],
            foregroundColor: Colors.white,
          ),
          onPressed: onTap,
          child: Text(text),
        ),
      ),
    );
  }
 
  // Build the 5 stars with a loop.
  List<Widget> buildStars() {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      stars.add(
        IconButton(
          iconSize: 38,
          color: Colors.amber,
          icon: Icon(i <= rating ? Icons.star : Icons.star_border),
          onPressed: () {
            setState(() {
              // Tapping the same star again clears the rating.
              rating = (rating == i) ? 0 : i;
            });
          },
        ),
      );
    }
    return stars;
  }
 
  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.item != null;
 
    return Scaffold(
      // The AppBar automatically shows a back arrow (it calls pop).
      appBar: AppBar(
        title: Text(isEditing ? "Edit title" : "Add a title"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              TextFormField(
                controller: titleCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: "Title (e.g. Breaking Bad)",
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter a title";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
 
              // Type: Movie or Series
              const Text("Type", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                children: [
                  optionButton("Movie", type == "Movie", () {
                    setState(() => type = "Movie");
                  }),
                  optionButton("Series", type == "Series", () {
                    setState(() => type = "Series");
                  }),
                ],
              ),
              const SizedBox(height: 24),
 
              // Status: Watchlist, Watching or Watched
              const Text("Status", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                children: [
                  optionButton("Watchlist", status == "Watchlist", () {
                    setState(() => status = "Watchlist");
                  }),
                  optionButton("Watching", status == "Watching", () {
                    setState(() => status = "Watching");
                  }),
                  optionButton("Watched", status == "Watched", () {
                    setState(() => status = "Watched");
                  }),
                ],
              ),
 
              // Only for series: where did the user stop?
              if (type == "Series") ...[
                const SizedBox(height: 24),
                TextFormField(
                  controller: progressCtrl,
                  decoration: InputDecoration(
                    labelText: "Where did you stop? (e.g. S2 E5)",
                    prefixIcon: const Icon(Icons.bookmark_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
 
              // Stars: hidden for titles that are still on the watchlist.
              if (status != "Watchlist") ...[
                const SizedBox(height: 24),
                const Text("Your rating",
                    style: TextStyle(color: Colors.grey)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: buildStars(),
                ),
              ],
              const SizedBox(height: 32),
 
              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: save,
                  child: Text(isEditing ? "Save changes" : "Add to library"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 