import 'package:ride_now_app/core/common/entities/user.dart';

class UserModel extends User {
  UserModel(
      {required super.id,
      required super.name,
      required super.email,
      required super.phone,
      required super.profilePicture,
      required super.ratings});

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map["id"],
      name: map["name"],
      email: map["email"],
      phone: map["telno"],
      profilePicture: map["profile_picture"],
      ratings: map["ratings"] ?? 0,
    );
  }

  @override
  String toString() {
    return 'User('
        'id: $id, '
        'name: $name, '
        'email: $email, '
        'phone: $phone, '
        'profile picture: $profilePicture, '
        'ratings: $ratings '
        ')';
  }
}
