import 'package:flutter_lovers/models/user_model.dart';

abstract class AuthBase {
  Future<MyUser?> currentUser();
  Future<MyUser?> signInAnonymously();
  Future<bool?> signOut();
  Future<MyUser?> signInWithGoogle();
  Future<MyUser?> signInWithFacebook();
  Future<MyUser?> signInWithEmailAndPassword(String email, String sifre);
  Future<MyUser?> createUserWithEmailAndPassword(String email, String sifre);
}
