import 'package:ride_now_app/core/common/entities/user.dart';

class UserModel extends User {
  UserModel(
      {required super.id,
      required super.name,
      required super.email,
      required super.phone});

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map["id"],
      name: map["name"],
      email: map["email"],
      phone: map["telno"],
    );
  }

  @override
  String toString() {
    return 'User('
        'id: $id, '
        'name: $name, '
        'email: $email, '
        'phone: $phone'
        ')';
  }
}
