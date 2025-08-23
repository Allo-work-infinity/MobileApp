import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_finding/router_name.dart';
import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/utils/k_images.dart';

import 'component/search_custom_app_bar.dart';
import 'component/suggest_job_card_component.dart';

class SearchInitScreen extends StatelessWidget {
  const SearchInitScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const SearchCustomAppBar(),
            const SizedBox(height: 40),
            _buildSearchField(context),
            const SizedBox(height: 24),
            const Text(
              "Recent Search",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const SuggestJobCardComponent(),
            const SuggestJobCardComponent(),
            const SuggestJobCardComponent(),
            const SuggestJobCardComponent(),
            const SuggestJobCardComponent(),
            const SuggestJobCardComponent(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(context) {
    return TextFormField(
      style: const TextStyle(color: secondaryColor),
      decoration: InputDecoration(
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: boarderColor),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: boarderColor),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: boarderColor),
        ),
        fillColor: Colors.transparent,
        filled: true,
        hintText: "Rechercher ici…",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIconConstraints:
            const BoxConstraints(maxHeight: 40, maxWidth: 40),
        suffixIconConstraints:
            const BoxConstraints(maxHeight: 40, maxWidth: 40),
        prefixIcon: Container(
          height: 24,
          width: 24,
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: secondaryColor,
            shape: BoxShape.circle,
          ),
        ),
        suffixIconColor: secondaryColor,
        suffixIcon: GestureDetector(
          onTap: ()=> Navigator.pushNamed(context, Routes.searchResult),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            child: SvgPicture.asset(
              Kimages.filterIcon,
              height: 18,
              width: 18,
              color: secondaryColor,
            ),
          ),
        ),
        hintStyle: const TextStyle(color: secondaryColor),
      ),
    );
  }
}
