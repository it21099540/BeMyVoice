class User {
  String id;
  String email;
  String displayName;
  int? age;
  String? address;
  String? gender;
  String? profileImage;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.age,
    this.address,
    this.gender,
    this.profileImage,
  });
}
