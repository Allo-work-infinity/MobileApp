import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  final int id;
  final String msg;
  final DateTime date;
  final bool isSentByMe;

  const MessageModel({
    required this.id,
    required this.date,
    required this.isSentByMe,
    required this.msg,
  });

  @override
  List<Object?> get props => throw UnimplementedError();
}
