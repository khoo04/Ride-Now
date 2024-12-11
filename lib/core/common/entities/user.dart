class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? profilePicture;
  final double ratings;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profilePicture,
    required this.ratings,
  });
}
