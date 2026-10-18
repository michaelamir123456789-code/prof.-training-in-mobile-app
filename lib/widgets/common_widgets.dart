import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/media_item.dart';

//el file da fieh el reusable pieces of UI that are used in multiple places.

// A row of 5 stars. Can be read-only or interactive.
class StarRating extends StatelessWidget {
  final int rating;
  final double size;
  final ValueChanged<int>? onChanged; // If null, stars are read-only.

  const StarRating({super.key, required this.rating, this.size = 24, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      // Generate 5 stars using a loop.
      children: List.generate(5, (index) {
        final filled = index < rating; // If index is 0 and rating is 3, it's filled.
        
        final star = Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: filled ? AppColors.gold : Colors.white24,
        );
        
        if (onChanged == null) return star; // Read-only star.
        
        // Interactive star.
        return GestureDetector(
          onTap: () => onChanged!(index + 1), // index 0 -> rating 1.
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: star,
          ),
        );
      }),
    );
  }
}

// A small colored pill that shows Watchlist, Watching, or Watched.
class StatusBadge extends StatelessWidget {
  final WatchStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String text;
    
    // Choose color and text based on the status.
    switch (status) {
      case WatchStatus.watchlist:
        color = AppColors.watchlist;
        text = 'Watchlist';
        break;
      case WatchStatus.watching:
        color = AppColors.watching;
        text = 'Watching';
        break;
      case WatchStatus.watched:
        color = AppColors.watched;
        text = 'Watched';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15), // 15% opacity of the color.
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// A big button with the purple/pink gradient.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool loading;

  const GradientButton({super.key, required this.label, required this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: kBrandGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [ // Drop shadow effect.
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: loading ? null : onPressed, // Disable click if loading.
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}