// lib/modules/search/component/job_card_component.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_finding/router_name.dart';
import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/utils/k_images.dart';
import 'package:job_finding/widget/teg_text.dart';

class JobCardComponent extends StatelessWidget {
  const JobCardComponent({
    Key? key,
    required this.address,
    required this.title,
    required this.tags,
    this.id,
    this.logoUrl,
    this.salaryMin,
    this.salaryMax,
    this.currency,
    this.onTap,
  }) : super(key: key);

  final int? id;
  final List<String> tags;
  final String title;
  final String address;

  /// Optional company logo URL (network). If null, falls back to the SVG icon.
  final String? logoUrl;

  /// Salary range (optional)
  final double? salaryMin;
  final double? salaryMax;

  /// Currency code/text (e.g., 'TND', 'USD')
  final String? currency;

  /// Optional custom navigation
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ,
          //     () => Navigator.pushNamed(
          //   context,
          //   Routes.jobDetailsScreen,
          //   arguments: {'id': id},
          // ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: boarderColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLogoBox(),
                  const SizedBox(width: 12),

                  // Expanded so long titles don't push the bookmark off-screen.
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2c2c2c),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xff939393),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  const Align(
                    alignment: Alignment.topRight,
                    child: Icon(Icons.bookmark_outline_outlined),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ==== FIXED ROW (no overflow; same-line as your first screenshot) ====
            Row(
              children: [
                // Tags: keep on a single row; allow slight horizontal scroll if tight.
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: tags.take(3).map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: TagText(
                            text: e,
                            textColor: blackColor,
                            bgColor: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Salary: stays on the same line; scales down slightly if space is tight.
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: _buildSalaryText(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoBox() {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: (logoUrl != null && logoUrl!.trim().isNotEmpty)
            ? Image.network(
          logoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Center(child: SvgPicture.asset(Kimages.uiLeadIcon)),
        )
            : Center(child: SvgPicture.asset(Kimages.uiLeadIcon)),
      ),
    );
  }

  /// Build dynamic salary text:
  /// - shows currency + min or min–max
  /// - keeps your "/m" suffix (monthly) like the original
  Widget _buildSalaryText() {
    final text = _salaryText();
    return Text.rich(
      TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: secondaryColor,
        ),
        children: const [
          TextSpan(
            text: "/m",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xff939393),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  String _salaryText() {
    final cur = (currency ?? '').trim().isEmpty ? '' : '${currency!.trim()} ';
    if (salaryMin != null && salaryMax != null && salaryMin != salaryMax) {
      return '$cur${_fmt(salaryMin!)}–${_fmt(salaryMax!)}';
    }
    final v = salaryMin ?? salaryMax;
    if (v != null) return '$cur${_fmt(v)}';
    return '$cur—';
  }

  String _fmt(double v) {
    // simple formatting: drop decimals if .00
    final asInt = v.truncateToDouble() == v;
    return asInt ? v.toInt().toString() : v.toStringAsFixed(2);
    // You can improve with NumberFormat if you use intl.
  }
}
