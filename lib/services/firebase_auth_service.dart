import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter_lovers/models/user_model.dart';
import 'package:flutter_lovers/services/auth_base.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService implements AuthBase {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Future<MyUser?> currentUser() async {
    try {
      User? user = await _firebaseAuth.currentUser;
      if (user != null) {
        return _userFromFirebase(user);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('HATA CURRENT USER ' + e.toString());
    }
    return null;
  }

  @override
  Future<MyUser?> signInAnonymously() async {
    try {
      UserCredential credential = await _firebaseAuth.signInAnonymously();
      return _userFromFirebase(credential.user!);
    } catch (e) {
      debugPrint('Sign in Anonymously HATA ' + e.toString());
      return null;
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      final _googleSignIn = GoogleSignIn();
      await _googleSignIn.signOut();

      final _facebookLogin = FacebookLogin();
      await _facebookLogin.logOut();
      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      debugPrint('Sign out HATA ' + e.toString());
      return false;
    }
  }

  MyUser _userFromFirebase(User user) {
    return MyUser(userID: user.uid, email: user.email);
  }

  @override
  Future<MyUser?> signInWithGoogle() async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    GoogleSignInAccount? _googleUser = await _googleSignIn.signIn();

    if (_googleUser != null) {
      GoogleSignInAuthentication _googleAuth = await _googleUser.authentication;
      if (_googleAuth.idToken != null && _googleAuth.accessToken != null) {
        UserCredential credential = await _firebaseAuth.signInWithCredential(
          GoogleAuthProvider.credential(
              idToken: _googleAuth.idToken,
              accessToken: _googleAuth.accessToken),
        );
        User _user = credential.user!;
        return _userFromFirebase(_user);
      }
    }
    return null;
  }

  @override
  Future<MyUser?> signInWithFacebook() async {
    final FacebookLogin _facebookLogin = FacebookLogin();
    FacebookLoginResult _facebookLoginResult =
        await _facebookLogin.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);
    switch (_facebookLoginResult.status) {
      case FacebookLoginStatus.success:
        if (_facebookLoginResult.accessToken != null) {
          UserCredential credential = await _firebaseAuth.signInWithCredential(
              FacebookAuthProvider.credential(
                  _facebookLoginResult.accessToken!.token));

          User _user = credential.user!;
          return _userFromFirebase(_user);
        }

        break;
      case FacebookLoginStatus.cancel:
        debugPrint('Kullanıcı facebook girişi iptal etti');
        break;
      case FacebookLoginStatus.error:
        debugPrint('Facebook login olurken hata ' +
            _facebookLoginResult.error.toString());
        break;
    }
    return null;
  }

//////////////account-exists-with-different-credential
  @override
  Future<MyUser?> createUserWithEmailAndPassword(
      String email, String sifre) async {
    UserCredential credential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: sifre);
    return _userFromFirebase(credential.user!);
  }

  @override
  Future<MyUser?> signInWithEmailAndPassword(String email, String sifre) async {
    UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: sifre);
    return _userFromFirebase(credential.user!);
  }
}
