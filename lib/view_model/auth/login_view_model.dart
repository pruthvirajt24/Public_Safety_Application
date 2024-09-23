import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:women_safety_app/data/global/appdata.dart';
import 'package:women_safety_app/data/shared_preferences/shared_preferences.dart';
import 'package:women_safety_app/res/const/firebase_const.dart';
import 'package:women_safety_app/res/utils/utils.dart';
import 'package:women_safety_app/view_model/police_distress_actions/police_distress_handler.dart';
import 'package:women_safety_app/views/child/bottom_nav_bar.dart';
import 'package:women_safety_app/views/parents/parent_home_screen.dart';
import 'package:women_safety_app/views/police/police_dashboard.dart';
import 'package:women_safety_app/views/selection/auth_selection_screen.dart';

Future<void> updateUserData(String userID) async {
  try {
    firestore.collection(usercollection).doc(userID).get().then((value) {
      log("User data: ${value.data()}");
      if (value.exists) {
        if (value['type'] == 'child') {
          // Handling Child Login
          // Saving userdata
          MySharedPrefernces().saveUserData(value.data()!);
        } else if (value['type'] == 'police') {
          // Handling police Login
          // Saving userdata
          MySharedPrefernces().saveUserData(value.data()!);
        } else {
          // Handling parent Login
          // Saving userdata
          MySharedPrefernces().saveUserData(value.data()!);
        }
      } else {
        showError('No user found for that email.');
      }
    });
    userData = await MySharedPrefernces().getUserData();
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      showError('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      showError('Wrong password provided for that user.');
    } else if (e.code == 'invalid-email') {
      showError('Invalid email format.');
    } else {
      showError('An error occurred while logging in.');
    }
  } catch (error) {
    showError(error.toString());
  } finally {}
}

class LoginViewModel extends GetxController {
  var isPassword = false.obs;
  var isLoading = false.obs;

  final formkey = GlobalKey<FormState>();
  final formdata = <String, Object>{};

  onSaveValue() async {
    if (formkey.currentState!.validate()) {
      formkey.currentState!.save();

      try {
        isLoading(true);
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
            email: formdata['email'].toString(),
            password: formdata['password'].toString());

        if (userCredential.user != null) {
          firestore
              .collection(usercollection)
              .doc(auth.currentUser!.uid)
              .get()
              .then((value) {
            log("User data: ${value.data()}");
            if (value.exists) {
              if (value['type'] == 'child') {
                isLoading.value = true;
                // Handling Child Login
                // Saving identifier
                MySharedPrefernces.userSaveType('child');
                // Saving userdata
                MySharedPrefernces().saveUserData(value.data()!);
                userData = value.data()!;
                isLoading.value = false;
                Get.off(() => const BottomNavPagesScreen());
              } else if (value['type'] == 'police') {
                isLoading.value = true;
                // Handling police Login
                // Saving identifier

                MySharedPrefernces.userSaveType('police');
                // Saving userdata
                MySharedPrefernces().saveUserData(value.data()!);
                userData = value.data()!;
                PoliceDistressHandler().registerPoliceLocation();
                isLoading.value = false;
                Get.off(() => const PoliceDashboard());
              } else {
                isLoading.value = true;
                // Handling parent Login
                // Saving identifier
                MySharedPrefernces.userSaveType('parent');
                // Saving userdata
                MySharedPrefernces().saveUserData(value.data()!);
                userData = value.data()!;
                isLoading.value = false;
                Get.off(() => const ParentHomeScreen());
              }
            } else {
              showError('No user found for that email.');
            }
          });
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          showError('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          showError('Wrong password provided for that user.');
        } else if (e.code == 'invalid-email') {
          showError('Invalid email format.');
        } else {
          showError('An error occurred while logging in.');
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

  Future<void> signOut() async {
    await auth.signOut();
    MySharedPrefernces.userSaveType('');
    await MySharedPrefernces().deleteUserData(userData);
    Get.offAll(() => const AuthSelectionScreen());
  }
}
