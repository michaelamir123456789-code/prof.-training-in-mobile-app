import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/media_item.dart';
import 'common_widgets.dart';

//This is the pop-up that appears when you click "Add title".


// TextEditingController: be Holds el text you el enta bet tektebha into the text box. When you hit save, it reads _titleCtrl.text.
// _save():
//It creates a new MediaItem.
//lw e5tart "Watchlist", be force el rating eno yekon 0 (maynfa3sh te rate 7aga w enta mashofthash).
//lw e5tart "Series", it saves the episode progress.
//It uses Navigator.pop(item) to close the pop-up and send the new movie data back to the Home Screen.

class ItemEditorSheet extends StatefulWidget {
  final MediaItem? initial; // If null, we are adding. If not null, we are editing.
  const ItemEditorSheet({super.key, this.initial});

  @override
  State<ItemEditorSheet> createState() => _ItemEditorSheetState();
}

class _ItemEditorSheetState extends State<ItemEditorSheet> {
  final _formKey = GlobalKey<FormState>(); // Validates the text fields.
  
  // Controllers hold the text typed into the text boxes.
  late final TextEditingController _titleCtrl;
  late final TextEditingController _progressCtrl;
  
  // Variables to hold the current selections.
  late MediaType _type;
  late WatchStatus _status;
  late int _rating;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    // If we passed an existing item, fill the form with its data.
    // Otherwise, start with default empty values.
    final i = widget.initial;
    _titleCtrl = TextEditingController(text: i?.title ?? '');
    _progressCtrl = TextEditingController(text: i?.progress ?? '');
    _type = i?.type ?? MediaType.movie;
    _status = i?.status ?? WatchStatus.watchlist;
    _rating = i?.rating ?? 0;
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is closed to free memory.
    _titleCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  void _save() {
    // If a text field is empty, stop and show red error text.
    if (!_formKey.currentState!.validate()) return;

    // Create the new item.
    final item = MediaItem(
      // Generate a unique ID using the current time in microseconds.
      id: widget.initial?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      type: _type,
      status: _status,
      // If it's in the watchlist, it cannot have a rating.
      rating: _status == WatchStatus.watchlist ? 0 : _rating,
      // Only save progress if it's a series.
      progress: _type == MediaType.series ? _progressCtrl.text.trim() : '',
      addedAt: widget.initial?.addedAt ?? DateTime.now(),
    );
    
    // Close the popup and send the new item back to the HomeScreen.
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Add padding to the bottom equal to the keyboard height so it doesn't cover the form.
      padding: EdgeInsets.fromLTRB(24, 14, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView( // Allows the form to scroll if the screen is small.
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The little grey drag handle at the top.
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 18),
              
              // The title changes based on whether we are adding or editing.
              Text(_isEditing ? 'Edit title' : 'Add a title',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),

              // Title input box.
              TextFormField(
                controller: _titleCtrl,
                autofocus: !_isEditing, // Open keyboard automatically if adding.
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Title (e.g. Breaking Bad)',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 18),

              const _Label('Type'),
              // Segmented button for choosing Movie or Series.
              SegmentedButton<MediaType>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: MediaType.movie, icon: Icon(Icons.movie_outlined), label: Text('Movie')),
                  ButtonSegment(value: MediaType.series, icon: Icon(Icons.tv_rounded), label: Text('Series')),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 18),

              const _Label('Status'),
              // Segmented button for choosing Watchlist, Watching, or Watched.
              SegmentedButton<WatchStatus>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: WatchStatus.watchlist, label: Text('Watchlist')),
                  ButtonSegment(value: WatchStatus.watching, label: Text('Watching')),
                  ButtonSegment(value: WatchStatus.watched, label: Text('Watched')),
                ],
                selected: {_status},
                onSelectionChanged: (s) => setState(() => _status = s.first),
              ),

              // Only show progress box if the type is a Series.
              if (_type == MediaType.series) ...[
                const SizedBox(height: 18),
                const _Label('Where did you stop?'),
                TextFormField(
                  controller: _progressCtrl,
                  decoration: const InputDecoration(
                    hintText: 'e.g. S2 · E5',
                    prefixIcon: Icon(Icons.bookmark_outline_rounded),
                  ),
                ),
              ],
              const SizedBox(height: 18),

              // Only show the star rating if the status is NOT in the watchlist.
              if (_status != WatchStatus.watchlist) ...[
                const _Label('Your rating'),
                Center(
                  child: StarRating(
                    rating: _rating,
                    size: 40,
                    // If you tap the same star again, it clears the rating (sets to 0).
                    onChanged: (r) => setState(() => _rating = r == _rating ? 0 : r),
                  ),
                ),
              ],
              const SizedBox(height: 26),

              // The Save button.
              GradientButton(
                label: _isEditing
                    ? 'Save changes'
                    : (_status == WatchStatus.watchlist ? 'Add to watchlist' : 'Add to library'),
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// A small helper widget for the grey labels above the form fields.
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}