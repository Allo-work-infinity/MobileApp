import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:job_finding/modules/message/component/chat_custom_app_bar.dart';
import 'package:job_finding/modules/message/model/message_model.dart';
import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/utils/k_images.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mesagesList = [
      MessageModel(
        id: 0,
        date: DateTime.now().subtract(const Duration(days: 5)),
        msg: "hello therer how rer you",
        isSentByMe: true,
      ),
      MessageModel(
        id: 1,
        date: DateTime.now().subtract(const Duration(minutes: 4)),
        msg: "hello therer how rer you therer how rer you therer how rer you ",
        isSentByMe: false,
      ),
      MessageModel(
        id: 2,
        date: DateTime.now().subtract(const Duration(days: 4)),
        msg: "hello therer",
        isSentByMe: true,
      ),
      MessageModel(
        id: 3,
        date: DateTime.now().subtract(const Duration(minutes: 4)),
        msg: "therer how rer you therer",
        isSentByMe: true,
      ),
      MessageModel(
        id: 4,
        date: DateTime.now().subtract(const Duration(minutes: 3)),
        msg: "hello therer",
        isSentByMe: true,
      ),
      MessageModel(
        id: 5,
        date: DateTime.now().subtract(const Duration(days: 5)),
        msg: "hello therer how rer you",
        isSentByMe: true,
      ),
      MessageModel(
        id: 6,
        date: DateTime.now().subtract(const Duration(minutes: 3)),
        msg: "hello therer how rer you therer how rer you therer how rer you ",
        isSentByMe: false,
      ),
      MessageModel(
        id: 7,
        date: DateTime.now().subtract(const Duration(days: 4)),
        msg: "hello therer",
        isSentByMe: true,
      ),
      MessageModel(
        id: 8,
        date: DateTime.now().subtract(const Duration(minutes: 1)),
        msg: "therer how rer you therer",
        isSentByMe: true,
      ),
      MessageModel(
        id: 9,
        date: DateTime.now().subtract(const Duration(days: 2)),
        msg: "hello therer",
        isSentByMe: true,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ChatCustomAppBar(),
            Expanded(
              child: GroupedListView<MessageModel, DateTime>(
                padding: const EdgeInsets.all(8),
                elements: mesagesList,
                order: GroupedListOrder.DESC,
                useStickyGroupSeparators: true,
                floatingHeader: true,
                // reverse: true,
                sort: true,
                groupBy: (msg) => DateTime(
                  msg.date.year,
                  msg.date.month,
                  msg.date.day,
                ),
                groupHeaderBuilder: (msg) => const SizedBox(
                  height: 30,
                  // child: Center(
                  //   child: Text(
                  //     DateFormat.yMMMd().format(msg.date),
                  //     style: const TextStyle(fontSize: 10),
                  //   ),
                  // ),
                ),
                itemBuilder: (context, msg) => Align(
                  alignment: msg.isSentByMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: msg.isSentByMe
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: msg.isSentByMe ? secondaryColor : fillColor),
                        child: Text(msg.msg),
                      ),
                      const Text("10 am",
                          style:
                              TextStyle(color: paragraphColor, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.attach_file_outlined),
                          hintText: "your message ...",
                          fillColor: fillColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: blackColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: SvgPicture.asset(Kimages.sendIcon,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
