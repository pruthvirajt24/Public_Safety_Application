import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:women_safety_app/res/const/firebase_const.dart';
import 'package:women_safety_app/view_model/police_distress_actions/police_distress_handler.dart';
import 'package:women_safety_app/views/police/police_dashboard.dart';
import 'package:women_safety_app/views/selection/auth_selection_screen.dart';

class PoliceRegisterModel extends GetxController {
  var isPassword = true.obs;
  var isCPassword = true.obs;
  var isLoading = false.obs;
  // final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final formkey1 = GlobalKey<FormState>();
  final formdata = <String, Object>{};

  Future<void> signUp() async {
    if (formkey1.currentState!.validate()) {
      formkey1.currentState!.save();

      if (formdata['password'] != formdata['cpassword']) {
        showError('Confirm password does not match');
      } else {
        try {
          isLoading(true);
          // String? token = await _fcm.getToken();
          await auth
              .createUserWithEmailAndPassword(
                  email: formdata['email'].toString(),
                  password: formdata['password'].toString())
              .then((val) async {
            var db = firestore.collection(usercollection).doc(val.user!.uid);
            PoliceModel policeModel = PoliceModel(
              name: formdata['name'].toString(),
              phone: formdata['phone'].toString(),
              email: formdata['email'].toString(),
              badgeNumber: formdata['badgeNumber'].toString(),
              imageUrl:
                  'https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small/default-avatar-icon-of-social-media-user-vector.jpg',
              id: auth.currentUser!.uid,
              type: 'police',
              fcmToken: "token!",
            );

            await db.set(policeModel.toJson()).whenComplete(() {
              Get.off(() => const AuthSelectionScreen());
              isLoading(false);
            });
            // PoliceDistressHandler().registerPoliceLocation();
          });
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            showError('The password provided is too weak.');
          } else if (e.code == 'email-already-in-use') {
            showError('The account already exists for that email.');
          }
          isLoading(false);
        } catch (error) {
          isLoading(false);
          showError(error.toString());
        } finally {
          isLoading(false);
        }
      }
    }
  }

  void showError(String message) {
    Get.snackbar('Error', message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white);
  }
}

class PoliceModel {
  String name;
  String phone;
  String email;
  String badgeNumber;
  String imageUrl;
  String id;
  String type;
  String fcmToken;

  PoliceModel({
    required this.name,
    required this.fcmToken,
    required this.phone,
    required this.email,
    required this.badgeNumber,
    required this.imageUrl,
    required this.id,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'badgeNumber': badgeNumber,
      'imageUrl': imageUrl,
      'id': id,
      'type': type,
      'fcmToken': fcmToken,
    };
  }

  factory PoliceModel.fromJson(Map<String, dynamic> json) {
    return PoliceModel(
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      badgeNumber: json['badgeNumber'],
      imageUrl: json['imageUrl'],
      id: json['id'],
      type: json['type'],
      fcmToken: json['fcmToken'],
    );
  }
}
