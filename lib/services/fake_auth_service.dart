import 'package:flutter_lovers/models/user_model.dart';
import 'package:flutter_lovers/services/auth_base.dart';

class FakeAuthService implements AuthBase {
  String userID = '3123123123322313';

  @override
  Future<MyUser> currentUser() async {
    return await Future.value(
        MyUser(userID: userID, email: 'fakeuser@fake.com'));
  }

  @override
  Future<MyUser> signInAnonymously() async {
    return await Future.delayed(Duration(seconds: 2),
        () => MyUser(userID: userID, email: 'fakeuser@fake.com'));
  }

  @override
  Future<bool> signOut() {
    return Future.value(true);
  }

  @override
  Future<MyUser?> signInWithGoogle() async {
    return await Future.delayed(
        Duration(seconds: 2),
        () => MyUser(
            userID: 'google_user_id_31321546', email: 'fakeuser@fake.com'));
  }

  @override
  Future<MyUser?> signInWithFacebook() async {
    return await Future.delayed(
        Duration(seconds: 2),
        () => MyUser(
            userID: 'facebook_user_id_9754654', email: 'fakeuser@fake.com'));
  }

  @override
  Future<MyUser?> createUserWithEmailAndPassword(
      String email, String sifre) async {
    return await Future.delayed(
        Duration(seconds: 2),
        () => MyUser(
            userID: 'created_user_id_654321', email: 'fakeuser@fake.com'));
  }

  @override
  Future<MyUser?> signInWithEmailAndPassword(String email, String sifre) async {
    return await Future.delayed(Duration(seconds: 2),
        () => MyUser(userID: 'SignIn_user_id_965', email: 'fakeuser@fake.com'));
  }
}
