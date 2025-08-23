import 'package:flutter/material.dart';
import 'package:job_finding/modules/home/model/dumy_data.dart';
import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/widget/teg_text.dart';

class FilteringBottomSheetBody extends StatelessWidget {
  const FilteringBottomSheetBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Category", style: TextStyle(color: labelColor)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            isDense: true,
            decoration: const InputDecoration(
              fillColor: fillColor,
              hintText: "Select category",
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            icon: const Icon(Icons.keyboard_arrow_down_outlined),
            items: categoryList.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (_) {},
          ),
          const SizedBox(height: 28),
          const Text("Sub - Category", style: TextStyle(color: labelColor)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            isDense: true,
            decoration: const InputDecoration(
              fillColor: fillColor,
              hintText: "Select Sub - Category",
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            icon: const Icon(Icons.keyboard_arrow_down_outlined),
            items: categoryList.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (_) {},
          ),
          const SizedBox(height: 28),
          const Text("Location", style: TextStyle(color: labelColor)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            isDense: true,
            decoration: const InputDecoration(
              fillColor: fillColor,
              hintText: "Select Location",
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            icon: const Icon(Icons.keyboard_arrow_down_outlined),
            items: categoryList.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (_) {},
          ),
          const SizedBox(height: 28),
          const Text("Salary", style: TextStyle(color: labelColor)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            isDense: true,
            decoration: const InputDecoration(
              fillColor: fillColor,
              hintText: "Select Salary",
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            icon: const Icon(Icons.keyboard_arrow_down_outlined),
            items: categoryList.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (_) {},
          ),
          const SizedBox(height: 24),
          const Text(
            "Job Type",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tagList.length,
              itemBuilder: (context, index) => TagText(
                text: tagList[index],
                textColor: blackColor,
                bgColor: boarderColor,
                fontSize: 14,
                marginRight: 12,
                borderRadius: 14,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
          const SizedBox(height: 55),
          ElevatedButton(onPressed: () {}, child: const Text("Apply Filter")),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
