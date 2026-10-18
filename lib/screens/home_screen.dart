import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/media_item.dart';
import '../services/storage.dart';
import '../widgets/common_widgets.dart';
import '../widgets/item_editor_sheet.dart';
import 'auth_screen.dart';

//da el file el user beshof fieh their list of movies.
//_query and _filter: be5od text in the search bar and the selected filter chip.
//_visible: da el "getter". It filters your main list of movies.lw el title contains the search text AND matches the filter, it shows it.
//CustomScrollView and Slivers: A special way to scroll. It lets the header and the search bar scroll off the screen while the list keeps scrolling smoothly.
//_openEditor(): Shows a pop-up from the bottom of the screen (bottom sheet) to add a new movie.
//_delete(): If you swipe a card left, it removes the movie. Then it shows a snackbar with an "UNDO" button. If you click UNDO, it puts the movie back.

class HomeScreen extends StatefulWidget {
  final String email; // The email of the logged-in user.
  const HomeScreen({super.key, required this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MediaItem> _items = []; // The list of movies.
  bool _loading = true; // Shows a loading spinner while fetching data.
  String _query = ''; // The text typed into the search bar.
  WatchStatus? _filter; // The currently selected filter chip (null = All).

  @override
  void initState() {
    super.initState();
    _load(); // Fetch data when the screen first opens.
  }

  // Fetches the saved movies from the database.
  Future<void> _load() async {
    final items = await Storage.loadItems(widget.email);
    setState(() {
      _items = items;
      _loading = false; // Stop the loading spinner.
    });
  }

  // Saves the updated list to the database.
  Future<void> _commit(List<MediaItem> items) async {
    setState(() => _items = items); // Update the screen.
    await Storage.saveItems(widget.email, items); // Save to memory.
  }

  // Opens the bottom sheet to add or edit a movie.
  Future<void> _openEditor([MediaItem? existing]) async {
    // Show the sheet and wait for the user to finish.
    final result = await showModalBottomSheet<MediaItem>(
      context: context,
      isScrollControlled: true, // Allows the sheet to resize with the keyboard.
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => ItemEditorSheet(initial: existing),
    );
    
    if (result == null) return; // User closed the sheet without saving.

    if (existing == null) {
      // Adding a new item: put it at the top of the list.
      await _commit([result, ..._items]);
    } else {
      // Editing an item: replace the old version with the new version.
      await _commit([
        for (final i in _items) i.id == result.id ? result : i,
      ]);
    }
  }

  // Deletes an item.
  Future<void> _delete(MediaItem item) async {
    // Find where the item was so we can restore it if needed.
    final index = _items.indexWhere((i) => i.id == item.id);
    
    // Remove it from the list and save.
    await _commit(_items.where((i) => i.id != item.id).toList());
    if (!mounted) return;
    
    // Show a Snackbar with an UNDO button.
    ScaffoldMessenger.of(context)
      ..clearSnackBars() // Remove any old snackbars.
      ..showSnackBar(SnackBar(
        content: Text('"${item.title}" removed'),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.primary,
          onPressed: () {
            // Put the item back exactly where it was.
            final restored = [..._items]..insert(index, item);
            _commit(restored);
          },
        ),
      ));
  }

  // Logs the user out and returns to the login screen.
  Future<void> _logout() async {
    await Storage.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  // A getter that calculates which items to show based on search text and filters.
  List<MediaItem> get _visible {
    return _items.where((i) {
      // Check if the title matches the search bar text.
      final matchesSearch = i.title.toLowerCase().contains(_query.trim().toLowerCase());
      // Check if the status matches the filter chip (or if filter is "All").
      final matchesFilter = _filter == null || i.status == _filter;
      // Both must be true to show the item.
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Count items for the stats cards at the top.
    final planned = _items.where((i) => i.status == WatchStatus.watchlist).length;
    final watching = _items.where((i) => i.status == WatchStatus.watching).length;
    final watched = _items.where((i) => i.status == WatchStatus.watched).length;
    final visible = _visible; // Get the filtered list.

    return Scaffold(
      // Floating action button (Add Title).
      floatingActionButton: _AddButton(onPressed: () => _openEditor()),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator()) // Show spinner while loading.
            : CustomScrollView(
                slivers: [ // Slivers allow complex scrolling behaviors.
                  
                  // 1. Header (Title and Logout button).
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 18, 12, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('My Library',
                                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                                const SizedBox(height: 2),
                                Text(widget.email,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Log out',
                            onPressed: _logout,
                            icon: const Icon(Icons.logout_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Stats Cards (Watchlist, Watching, Watched).
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                      child: Row(
                        children: [
                          _StatCard(label: 'Watchlist', value: planned, color: AppColors.watchlist, icon: Icons.bookmark_add_outlined),
                          const SizedBox(width: 10),
                          _StatCard(label: 'Watching', value: watching, color: AppColors.watching, icon: Icons.play_circle_outline_rounded),
                          const SizedBox(width: 10),
                          _StatCard(label: 'Watched', value: watched, color: AppColors.watched, icon: Icons.check_circle_outline_rounded),
                        ],
                      ),
                    ),
                  ),

                  // 3. Search Bar.
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                      child: TextField(
                        onChanged: (v) => setState(() => _query = v), // Update search text on every keystroke.
                        decoration: const InputDecoration(
                          hintText: 'Search your titles...',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                    ),
                  ),

                  // 4. Filter Chips (All, Watchlist, Watching, Watched).
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 6),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          _FilterChip(label: 'All', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                          _FilterChip(label: 'Watchlist', selected: _filter == WatchStatus.watchlist, onTap: () => setState(() => _filter = WatchStatus.watchlist)),
                          _FilterChip(label: 'Watching', selected: _filter == WatchStatus.watching, onTap: () => setState(() => _filter = WatchStatus.watching)),
                          _FilterChip(label: 'Watched', selected: _filter == WatchStatus.watched, onTap: () => setState(() => _filter = WatchStatus.watched)),
                        ],
                      ),
                    ),
                  ),

                  // 5. The List of Movies OR the Empty State.
                  if (visible.isEmpty)
                    // If nothing matches, show the empty state graphic.
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(hasItems: _items.isNotEmpty),
                    )
                  else
                    // If there are items, list them using a SliverList.
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 110), // Extra bottom padding so FAB doesn't cover items.
                      sliver: SliverList.separated(
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12), // Space between items.
                        itemBuilder: (_, index) {
                          final item = visible[index];
                          // Dismissible allows swiping to delete.
                          return Dismissible(
                            key: ValueKey(item.id),
                            background: const _SwipeBackground(), // Background when swiping right.
                            secondaryBackground: const _SwipeBackground(alignRight: true), // Background when swiping left.
                            onDismissed: (_) => _delete(item),
                            child: MediaCard(
                              item: item,
                              onTap: () => _openEditor(item), // Edit item when tapped.
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

// A card showing one title in the list.
class MediaCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;
  const MediaCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSeries = item.type == MediaType.series;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Icon "poster" (movie vs series).
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: kBrandGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(isSeries ? Icons.tv_rounded : Icons.movie_rounded, color: Colors.white),
              ),
              const SizedBox(width: 14),
              // Title + details.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    // Show "Series - S2 E5" or just "Movie".
                    Text(
                      isSeries ? (item.progress.isEmpty ? 'Series' : 'Series · ${item.progress}') : 'Movie',
                      style: const TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                    // No stars for titles that are still on the watchlist.
                    if (item.status != WatchStatus.watchlist) ...[
                      const SizedBox(height: 8),
                      StarRating(rating: item.rating, size: 18),
                    ],
                  ],
                ),
              ),
              // The colored status badge on the right.
              StatusBadge(status: item.status),
            ],
          ),
        ),
      ),
    );
  }
}

// Floating "Add" button with the brand gradient.
class _AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: kBrandGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.45), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded),
                SizedBox(width: 8),
                Text('Add title', style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Stats card at the top ("Watching: 3").
class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  
  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text('$value', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// Rounded filter chip (All / Watching / Watched).
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.muted,
          fontWeight: FontWeight.w600),
    );
  }
}

// Red background shown while swiping a card to delete it.
class _SwipeBackground extends StatelessWidget {
  final bool alignRight;
  const _SwipeBackground({this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
    );
  }
}

// Shown when the list is empty (no titles yet, or no search results).
class _EmptyState extends StatelessWidget {
  final bool hasItems; // True means items exist, but search/filter hides them.
  const _EmptyState({required this.hasItems});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              hasItems ? Icons.search_off_rounded : Icons.video_library_outlined,
              size: 72,
              color: Colors.white24),
          const SizedBox(height: 16),
          Text(hasItems ? 'No matches' : 'Nothing here yet',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            hasItems
                ? 'Try a different search or filter.'
                : 'Tap "Add title" to log your first movie or series.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}