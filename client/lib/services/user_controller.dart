import 'package:get/get.dart';

class UserController extends GetxController {
  RxString? name = ''.obs;
  RxDouble? rate = 0.0.obs;
  RxString? imgurl = ''.obs;

  void setUserData(Map<String, dynamic> data) {
    name = (data['name'] ?? '').obs;
    rate = (data['rate'] ?? 0.0).obs;
    imgurl = (data['imgurl'] ?? '').obs;
  }
}

final userController = UserController();
