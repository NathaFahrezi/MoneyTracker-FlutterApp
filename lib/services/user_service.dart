import '../models/user_model.dart';

class UserService {
  static UserModel currentUser = UserModel(
    name: 'Natha Fahrezi',
    email: 'nathagobez@gmail.com',
    address: 'Padang, Indonesia',
    job: 'Mahasiswa',
    maritalStatus: 'Belum Menikah',
    profileImage: null,
  );

  static UserModel getUser() {
    return currentUser;
  }

  static void updateUser(UserModel user) {
    currentUser = user;
  }
}
