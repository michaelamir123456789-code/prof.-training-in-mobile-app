// home_screen.dart: the main screen that shows the user's list.
import 'package:flutter/material.dart';
import '../../../models/media_item.dart';
import 'Auth_screen.dart';
import 'add_item_screen.dart';

// statefulwidget: 3lshan el screen el 7agat el fieha bett8ayar  
class HomeScreen extends StatefulWidget {
  final String email; // the email of the logged-in user
  const HomeScreen({super.key, required this.email});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
 
class _HomeScreenState extends State<HomeScreen> {
  // el list of movies and series (kept in memory). w eh [] 3lshan heya empty lesa
  List<MediaItem> items = [];
 
  String query = ""; // text typed in the search bar
  String filter = "All"; // All, Watchlist, Watching or Watched
 
  // Open the add/edit screen.
  // If [item] is null we are adding, otherwise we are editing.
  Future<void> openEditor([MediaItem? item]) async {
    // push: be7ot screen fel top beta3 screen tanya (befta7 new screem) 
    MediaItem? result = await Navigator.push<MediaItem>(
      context,
      MaterialPageRoute(builder: (context) => AddItemScreen(item: item)),
    );
 
    // The user pressed back without saving.
    if (result == null) return;
 
    setState(() {
      if (item == null) {
        items.insert(0, result); // new items go to the top
      } else {
        int index = items.indexOf(item);
        items[index] = result; // replace the old one
      }
    });
  }
 
  // Remove one item from the list.
  void deleteItem(MediaItem item) {
    setState(() {
      items.remove(item);
    });
  }
 
  // Count how many items have a given status (uses a for loop).
  int countStatus(String status) {
    int count = 0;
    for (MediaItem item in items) {
      if (item.status == status) {
        count++;
      }
    }
    return count;
  }
 
  // Choose a color for each status.
  Color statusColor(String status) {
    if (status == "Watched") return Colors.green;
    if (status == "Watching") return Colors.lightBlue;
    return Colors.amber; // Watchlist
  }
 
  // A small card that shows a number and a label.
  Widget statCard(String label, int count, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(
                "$count",
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
              Text(label, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
 
  // A button used to filter the list.
  Widget filterButton(String name) {
    bool selected = filter == name;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? Colors.deepPurple : Colors.grey[850],
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          setState(() {
            filter = name;
          });
        },
        child: Text(name),
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    // Build the list that we will show (search + filter) with a loop.
    List<MediaItem> visible = [];
    for (MediaItem item in items) {
      bool matchesSearch =
          item.title.toLowerCase().contains(query.trim().toLowerCase());
      bool matchesFilter = filter == "All" || item.status == filter;
      if (matchesSearch && matchesFilter) {
        visible.add(item);
      }
    }
 
    return Scaffold(
      // Do not resize the page when the keyboard opens.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("My Library"),
        actions: [
          // Log out button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
          ),
        ],
      ),
 
      // Floating "Add" button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openEditor(),
        icon: const Icon(Icons.add),
        label: const Text("Add title"),
      ),
 
      body: Column(
        children: [
          // 1. Counters
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                statCard("Watchlist", countStatus("Watchlist"), Colors.amber),
                statCard("Watching", countStatus("Watching"), Colors.lightBlue),
                statCard("Watched", countStatus("Watched"), Colors.green),
              ],
            ),
          ),
 
          // 2. Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              // onChanged runs on every letter the user types.
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search your titles...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
 
          // 3. Filter buttons (scroll sideways if the screen is small)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                filterButton("All"),
                filterButton("Watchlist"),
                filterButton("Watching"),
                filterButton("Watched"),
              ],
            ),
          ),
 
          // 4. The list. Expanded gives it all the remaining space.
          Expanded(
            child: visible.isEmpty
                ? const Center(
                    child: Text(
                      "Nothing here yet.\nTap \"Add title\" to start.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      MediaItem item = visible[index];
 
                      // Text under the title: "Series - S2 E5" or "Movie".
                      String details = item.type;
                      if (item.type == "Series" && item.progress != "") {
                        details = "Series - ${item.progress}";
                      }
 
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: ListTile(
                          isThreeLine: true,
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            child: Icon(
                              item.type == "Series" ? Icons.tv : Icons.movie,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(details),
                              Text(
                                item.status,
                                style: TextStyle(
                                    color: statusColor(item.status),
                                    fontWeight: FontWeight.bold),
                              ),
                              // "★" * 3 gives "★★★"
                              if (item.rating > 0)
                                Text(
                                  "★" * item.rating,
                                  style: const TextStyle(color: Colors.amber),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => deleteItem(item),
                          ),
                          // Tap the card to edit it.
                          onTap: () => openEditor(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
 