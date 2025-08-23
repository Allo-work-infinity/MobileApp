// lib/modules/home/component/category_component.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_finding/utils/utils.dart';
import 'package:job_finding/widget/teg_text.dart';
import '../model/category_cart_model.dart';
import 'category_line_indicator_text.dart';

class CategoryComponent extends StatefulWidget {
  const CategoryComponent({
    Key? key,
    required this.categoryCartList,
    required this.catList,
  }) : super(key: key);
  final List<String> catList;
  final List<CategoryCartModel> categoryCartList;

  @override
  State<CategoryComponent> createState() => _CategoryComponentState();
}

class _CategoryComponentState extends State<CategoryComponent> {
  final controller = ScrollController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 34,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            scrollDirection: Axis.horizontal,
            itemCount: widget.catList.length,
            itemBuilder: (_, index) => CategoryLineIndecatorText(
              isCurrentItem: _currentIndex == index,
              text: widget.catList[index],
              index: index,
              onTap: (int i) => setState(() => _currentIndex = i),
            ),
          ),
        ),

        // ↑↑ Increase height a bit so inner content fits
        SizedBox(
          height: 180, // was 190
          child: ListView.builder(
            itemBuilder: (context, index) =>
                _categoryCartItem(widget.categoryCartList[index]),
            itemCount: widget.categoryCartList.length,
            itemExtent: (size.width * 0.66) + 24,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            scrollDirection: Axis.horizontal,
            controller: controller,
          ),
        ),
      ],
    );
  }

  Widget _categoryCartItem(CategoryCartModel item) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: item.onTap, // navigation if provided
        borderRadius: BorderRadius.circular(16),
        child: Container(
          // ↓↓ Slightly smaller vertical padding
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          margin: const EdgeInsets.only(left: 12, right: 12),
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: item.color.withOpacity(.4),
                offset: const Offset(4, 8),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // don't try to fill extra height
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader(item),
              const SizedBox(height: 10),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                item.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.6,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Keep tags on a single line to avoid growing height
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (item.tags.isNotEmpty)
                        TagText(text: item.tags.first, textColor: Colors.white),
                      if (item.tags.length > 1) const SizedBox(width: 6),
                      if (item.tags.length > 1)
                        TagText(text: item.tags[1], textColor: Colors.white),
                    ],
                  ),
                  const Icon(Icons.bookmark_border_outlined, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardHeader(CategoryCartModel item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // image / logo
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(child: _leadingImage(item)),
        ),
        // price (/mois in FR)
        Text.rich(
          TextSpan(
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            text: Utils.formatPrice(item.price),
            children: const [
              TextSpan(
                text: "/mois",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _leadingImage(CategoryCartModel item) {
    final img = item.image.trim();
    final isUrl = img.startsWith('http://') || img.startsWith('https://');

    if (isUrl) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          img,
          height: 24,
          width: 24,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.business),
        ),
      );
    }

    return SvgPicture.asset(img, height: 24, width: 24);
  }
}
