import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id, unSeenMsg;
  final String avatar, name, lastMeg, time;

  const UserModel({
    required this.id,
    required this.unSeenMsg,
    required this.avatar,
    required this.name,
    required this.lastMeg,
    required this.time,
  });

  @override
  List<Object> get props => [id, time, avatar];
}
