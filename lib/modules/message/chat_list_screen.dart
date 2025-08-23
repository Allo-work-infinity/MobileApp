import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:job_finding/modules/message/model/user_model.dart';
import 'package:job_finding/router_name.dart';
import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/utils/utils.dart';

import 'component/message_custom_app_bar.dart';
import 'model/chat_dumy_data.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const MessageCustomAppBar(text: "Message"),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: chatList.length,
                  itemBuilder: (_, index) =>
                      _chatItem(context, chatList[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chatItem(context, UserModel userModel) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xffF5F5F5), width: 1)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, Routes.chatScreen);
        },
        child: IntrinsicHeight(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: userModel.avatar,
                  height: 40,
                  width: 40,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: labelColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userModel.name,
                        maxLines: 1,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xff2C2C2C)),
                      ),
                      Text(
                        userModel.lastMeg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 10, height: 1.8, color: labelColor),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (userModel.unSeenMsg > 0)
                    Container(
                      decoration: BoxDecoration(
                        color: blackColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      height: 24,
                      width: 24,
                      child: Center(
                        child: Text(
                          "${userModel.unSeenMsg}",
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ),
                  Text(
                    Utils.timeAgo(userModel.time),
                    style: const TextStyle(
                        fontSize: 10, height: 1.8, color: labelColor),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
