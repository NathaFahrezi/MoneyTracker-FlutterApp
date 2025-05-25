class UserModel {
  String name;
  String email;
  String address;
  String job;
  String maritalStatus;
  String? profileImage; // path atau URL, optional

  UserModel({
    required this.name,
    required this.email,
    required this.address,
    required this.job,
    required this.maritalStatus,
    this.profileImage,
  });
}
