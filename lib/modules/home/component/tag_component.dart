// lib/modules/home/component/tag_component.dart
import 'package:flutter/material.dart';
import 'package:job_finding/modules/home/filtered_offers_screen.dart';
import 'package:job_finding/router_name.dart';
import 'package:job_finding/utils/constants.dart';

class TagListComponent extends StatelessWidget {
  const TagListComponent({
    Key? key,
    required this.item,
    this.padding = const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
  }) : super(key: key);

  /// Tags to display (e.g. ["Toute", "Populaires", ...])
  final List<String> item;

  /// List padding
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        padding: padding,
        scrollDirection: Axis.horizontal,
        itemCount: item.length,
        itemBuilder: (context, index) => _buildItem(context, index),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final tag = item[index];

    void handleTap() {
      final t = tag.trim().toLowerCase();

      // Known “filter” chips
      String? filterKey;
      if (t == 'toute' || t == 'toutes' || t == 'all') filterKey = 'all';
      else if (t.startsWith('pop')) filterKey = 'popular';
      else if (t == 'à la une' || t == 'featured') filterKey = 'featured';
      else if (t == 'télétravail' || t == 'remote') filterKey = 'remote';
      else if (t == 'fermées' || t == 'fermée' || t == 'closed') filterKey = 'closed';
      else if (t == 'ouvertes' || t == 'ouverte' || t == 'open') filterKey = 'open';

      // If not a known filter, treat it as a CATEGORY by passing the tag itself.
      final keyToSend = filterKey ?? tag;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FilteredOffersScreen(
            filterKey: keyToSend,
            title: null,          // <<< IMPORTANT: never pass title here
            // params: {}          // no 'q' here; category is independent of search
          ),
        ),
      );
    }


    final radius = BorderRadius.circular(14);

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: handleTap,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(color: boarderColor, borderRadius: radius),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Center(
              child: Text(
                tag,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Map the visible chip label to the API/controller filter key.
String _filterFromTag(String tag) {
  final t = tag.trim().toLowerCase();
  if (t == 'toute' || t == 'toutes' || t == 'all') return 'all';
  if (t.startsWith('pop')) return 'popular'; // "Populaires"/"Popular"
  if (t == 'à la une' || t == 'featured') return 'featured';
  if (t == 'télétravail' || t == 'remote') return 'remote';
  if (t == 'fermées' || t == 'fermée' || t == 'closed') return 'closed';
  if (t == 'ouvertes' || t == 'ouverte' || t == 'open') return 'open';
  // default fallback
  return 'popular';
}
