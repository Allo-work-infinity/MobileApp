import 'package:flutter/material.dart';
import 'package:job_finding/modules/job_details/controllers/company_controller.dart';
import 'package:job_finding/modules/job_details/model/company.dart';
import 'package:provider/provider.dart';
import 'package:job_finding/utils/constants.dart';
 // for Company model

class CompanyComponent extends StatefulWidget {
  final int companyId;
  const CompanyComponent({Key? key, required this.companyId}) : super(key: key);

  @override
  State<CompanyComponent> createState() => _CompanyComponentState();
}

class _CompanyComponentState extends State<CompanyComponent> {
  @override
  void initState() {
    super.initState();
    // Fetch once when the widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyController>().fetchCompanyById(
        widget.companyId,
        usePost: true, // set to false if you prefer GET ?id=
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CompanyController>();

    Widget body;
    switch (ctrl.state) {
      case LoadState.loading:
        body = const Center(child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ));
        break;
      case LoadState.notFound:
        body = const Padding(
          padding: EdgeInsets.all(20),
          child: Text('Entreprise non trouvée', style: TextStyle(color: secondaryColor)),
        );
        break;
      case LoadState.error:
        body = Padding(
          padding: const EdgeInsets.all(20),
          child: Text(ctrl.errorMessage ?? 'Error',
              style: const TextStyle(color: secondaryColor)),
        );
        break;
      case LoadState.loaded:
        final Company c = ctrl.company!;
        body = _buildCompanyContent(c);
        break;
      case LoadState.idle:
      default:
        body = const SizedBox.shrink();
    }

    return body;
  }

  Widget _buildCompanyContent(Company c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfile(c),
          const SizedBox(height: 24),
          Container(color: boarderColor, height: 1),
          const SizedBox(height: 24),
          _infoAddress(c),
          const SizedBox(height: 24),
          Text(
            'À propos ${c.name}',
            style: const TextStyle(fontSize: 20, height: 1.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            (c.description?.trim().isNotEmpty ?? false)
                ? c.description!
                : 'Aucune description fournie.',
            style: const TextStyle(fontSize: 14, height: 1.8, color: paragraphColor),
          ),
          const SizedBox(height: 16),
          // (Optional) gallery placeholder
          // SizedBox(
          //   height: 162,
          //   child: ListView.builder(
          //     padding: const EdgeInsets.symmetric(vertical: 16),
          //     itemCount: 3,
          //     scrollDirection: Axis.horizontal,
          //     itemBuilder: (context, index) => Container(
          //       width: 205,
          //       margin: const EdgeInsets.only(right: 16),
          //       decoration: BoxDecoration(
          //         color: circleColor,
          //         borderRadius: BorderRadius.circular(16),
          //       ),
          //     ),
          //   ),
          // ),
          // Row(
          //   children: const [
          //     CircleAvatar(radius: 2),
          //     SizedBox(width: 4),
          //     Text('Emplois pour cette entreprise',
          //         style: TextStyle(fontWeight: FontWeight.w600, height: 1.5)),
          //     Spacer(),
          //     Text(
          //       'Voir les offres d\'emploi',
          //       style: TextStyle(
          //         decoration: TextDecoration.underline,
          //         fontWeight: FontWeight.w600,
          //         height: 1.5,
          //         color: secondaryColor,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Row _infoAddress(Company c) {
    final phone = c.contactPhone ?? '-';
    final email = c.contactEmail ?? '-';
    final address = [
      if ((c.address ?? '').isNotEmpty) c.address,
      if ((c.city ?? '').isNotEmpty) c.city,
      if ((c.governorate ?? '').isNotEmpty) c.governorate,
    ].whereType<String>().join(', ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.call, size: 14, color: secondaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      phone,
                      style: const TextStyle(
                          height: 1.5, fontSize: 12, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.email, size: 14, color: secondaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      email,
                      style: const TextStyle(
                          height: 1.5, fontSize: 12, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.edit_location_sharp, color: secondaryColor, size: 14),
              const SizedBox(height: 6),
              Text(
                address.isNotEmpty ? address : '—',
                style: const TextStyle(fontSize: 12, height: 1.5, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfile(Company c) {
    final hasLogo = (c.logoUrl ?? '').isNotEmpty;
    final industry = c.industry ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 100,
          width: 100,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            border: Border.all(color: paragraphColor, width: .2),
            borderRadius: BorderRadius.circular(32),
            color: circleColor,
          ),
          child: hasLogo
              ? Image.network(
            c.logoUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
          )
              : const Icon(Icons.business, size: 40, color: paragraphColor),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                  fontSize: 20,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (industry.isNotEmpty)
                Text(
                  industry,
                  style: const TextStyle(
                    color: paragraphColor,
                    height: 1.9,
                    fontSize: 12,
                  ),
                ),
              const SizedBox(height: 10),
              // Simple badge row (replace with rating/reviews if you have real data)
              Row(
                children: const [
                  Icon(Icons.verified, color: secondaryColor, size: 14),
                  SizedBox(width: 6),
                  Text('Entreprise vérifiée',
                      style: TextStyle(fontSize: 12, color: secondaryColor)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
