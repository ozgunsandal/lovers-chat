// Arayüzü güncellemek için bizi setstate'ten kurtaracak olan yapı burası.
// Provider yani.
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lovers/locator.dart';
import 'package:flutter_lovers/models/konusma.dart';
import 'package:flutter_lovers/models/mesaj.dart';
import 'package:flutter_lovers/models/user_model.dart';
import 'package:flutter_lovers/repository/user_repository.dart';
import 'package:flutter_lovers/services/auth_base.dart';

enum ViewState {
  Idle,
  Busy
} // ya boştayızdır ya da internetten veri çekiyoruzdur ya da başka işlemler yaptırıyoruzdur.

class ViewModel with ChangeNotifier implements AuthBase {
  late ViewState _viewState = ViewState.Idle;
  final UserRepository _userRepository = locator<UserRepository>();
  MyUser? _user;
  String emailHataMesaji = '';
  String sifreHataMesaji = '';

  MyUser? get user => _user;

  ViewState get viewState => _viewState;

  set viewState(ViewState value) {
    _viewState = value;
    notifyListeners();
  }

  ViewModel() {
    currentUser(); // Uygulama açıldığında oturum açmış kullanıcı var mı yok mu anlamak için constructorda currentUser'ı çağırıyoruz. Açık bir oturum varsa _user değişkeni dolsun.
  }

  @override
  Future<MyUser?> currentUser() async {
    try {
      viewState = ViewState.Busy;
      _user = await _userRepository.currentUser();
      if (_user != null) {
        return _user;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('ViewModeldeki current userda HATA ' + e.toString());
      return null;
    } finally {
      viewState = ViewState.Idle;
    }
  }

  @override
  Future<MyUser?> signInAnonymously() async {
    try {
      viewState = ViewState.Busy;
      _user = await _userRepository.signInAnonymously();
      return _user;
    } catch (e) {
      debugPrint('ViewModeldeki signin anonymousta HATA ' + e.toString());
      return null;
    } finally {
      viewState = ViewState.Idle;
    }
  }

  @override
  Future<bool?> signOut() async {
    try {
      viewState = ViewState.Busy;
      bool? sonuc = await _userRepository.signOut();
      _user = null;
      return sonuc;
    } catch (e) {
      debugPrint('ViewModeldeki sign outda HATA ' + e.toString());
      return false;
    } finally {
      viewState = ViewState.Idle;
    }
  }

// Login olurken malformed ya da expired gibi bir hata alırsan cihazın saatini kontrol et.
  @override
  Future<MyUser?> signInWithGoogle() async {
    try {
      viewState = ViewState.Busy;
      _user = await _userRepository.signInWithGoogle();
      if (_user != null) {
        return _user;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('ViewModeldeki signInWithGoogleda HATA ' + e.toString());
      return null;
    } finally {
      viewState = ViewState.Idle;
    }
  }

  @override
  Future<MyUser?> signInWithFacebook() async {
    try {
      viewState = ViewState.Busy;
      _user = await _userRepository.signInWithFacebook();
      if (_user != null) {
        return _user;
      } else {
        return null;
      }
    } finally {
      viewState = ViewState.Idle;
    }
  }

  @override
  Future<MyUser?> createUserWithEmailAndPassword(
      String email, String sifre) async {
    if (_emailSifreKontrol(email, sifre)) {
      try {
        viewState = ViewState.Busy;
        _user =
            await _userRepository.createUserWithEmailAndPassword(email, sifre);

        return _user;
      } finally {
        viewState = ViewState.Idle;
      }
    } else
      return null;
  }

  @override
  Future<MyUser?> signInWithEmailAndPassword(String email, String sifre) async {
    try {
      if (_emailSifreKontrol(email, sifre)) {
        viewState = ViewState.Busy;
        _user = await _userRepository.signInWithEmailAndPassword(email, sifre);
        return _user;
      } else
        return null;
    } finally {
      viewState = ViewState.Idle;
    }
  }

  bool _emailSifreKontrol(String email, String sifre) {
    var sonuc = true;
    if (sifre.length < 6) {
      sifreHataMesaji = 'En az 6 karakter olmalı';
      sonuc = false;
    } else {
      sifreHataMesaji = '';
    }
    if (!email.contains('@')) {
      emailHataMesaji = 'Geçersiz email adresi';
      sonuc = false;
    } else {
      emailHataMesaji = '';
    }
    return sonuc;
  }

  Future<bool> updateUserName(String userID, String yeniUserName) async {
    bool sonuc = await _userRepository.updateUsername(userID, yeniUserName);
    if (sonuc) {
      _user!.userName = yeniUserName;
    }
    return sonuc;
  }

  Future<String> uploadFile(String userID, String fileType, File file) async {
    String indirmeLinki =
        await _userRepository.uploadFile(userID, fileType, file);
    return indirmeLinki;
  }

  Stream<List<Mesaj>> getMessages(
      String currentUserID, String sohbetEdilenUserID) {
    return _userRepository.getMessages(currentUserID, sohbetEdilenUserID);
  }

  Future<List<Konusma>> getAllConversations(String userID) async {
    return await _userRepository.getAllConversations(userID);
  }

  Future<List<MyUser>> getUserWithPagination(
      MyUser? enSonGetirilenUser, int getirilecekElemanSayisi) async {
    return await _userRepository.getUserWithPagination(
        enSonGetirilenUser, getirilecekElemanSayisi);
  }
}
