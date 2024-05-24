class UserModel{
  final String? Id;
  final String? userName;
  final String userEmail;
  final String userPhoneNumber;
  final String userSkills;

  final String userPostOffice;
  final String userSubDistrict;
  final String userDistrict;

  UserModel({
    this.Id,
    this.userName,
    required this.userEmail,
    required this.userPhoneNumber,
    required this.userSkills,
    required this.userPostOffice,
    required this.userSubDistrict,
    required this.userDistrict});
}

