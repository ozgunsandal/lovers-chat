import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_lovers/locator.dart';
import 'package:flutter_lovers/models/konusma.dart';
import 'package:flutter_lovers/models/mesaj.dart';
import 'package:flutter_lovers/models/user_model.dart';
import 'package:flutter_lovers/services/auth_base.dart';
import 'package:flutter_lovers/services/fake_auth_service.dart';
import 'package:flutter_lovers/services/firebase_auth_service.dart';
import 'package:flutter_lovers/services/firebase_storage_service.dart';
import 'package:flutter_lovers/services/firestore_db_service.dart';
import 'package:timeago/timeago.dart' as timeago;

enum AppMode { DEBUG, RELEASE }

class UserRepository implements AuthBase {
  final FirebaseAuthService _firebaseAuthService =
      locator<FirebaseAuthService>();
  final FakeAuthService _fakeAuthService = locator<FakeAuthService>();
  final FirestoreDBService _firestoreDBService = locator<FirestoreDBService>();
  final FirebaseStorageService _firebaseStorageService =
      locator<FirebaseStorageService>();

  AppMode appMode = AppMode
      .RELEASE; // Veri tabanını ayarlayacak olan arkadaş hala ayarlamamış bu yüzden biz debug modda çalışıyoruz.Öyle bir senaryo yazdık kendimizce.

  List<MyUser> tumKullaniciListesi = [];

  @override
  Future<MyUser?> currentUser() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthService.currentUser();
    } else {
      MyUser? _user = await _firebaseAuthService.currentUser();
      if (_user != null) {
        return await _firestoreDBService.readUser(_user.userID);
      } else {
        return null;
      }
    }
  }

  @override
  Future<MyUser?> signInAnonymously() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthService.signInAnonymously();
    } else {
      return await _firebaseAuthService.signInAnonymously();
    }
  }

  @override
  Future<bool?> signOut() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthService.signOut();
    } else {
      return await _firebaseAuthService.signOut();
    }
  }

  @override
  Future<MyUser?> signInWithGoogle() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthService.signInWithGoogle();
    } else {
      MyUser? _user = await _firebaseAuthService.signInWithGoogle();
      if (_user != null) {
        bool _sonuc = await _firestoreDBService.saveUser(_user);
        if (_sonuc) {
          return await _firestoreDBService.readUser(_user.userID);
        } else {
          await _firebaseAuthService.signOut();
          return null;
        }
      } else {
        return null;
      }
    }
  }

  @override
  Future<MyUser?> signInWithFacebook() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthService.signInWithFacebook();
    } else {
      MyUser? _user = await _firebaseAuthService.signInWithFacebook();
      if (_user != null) {
        bool _sonuc = await _firestoreDBService.saveUser(_user);
        if (_sonuc) {
          return await _firestoreDBService.readUser(_user.userID);
        } else {
          await _firebaseAuthService.signOut();
          return null;
        }
      } else {
        return null;
      }
    }
  }

  @override
  Future<MyUser?> createUserWithEmailAndPassword(
      String email, String sifre) async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthService.createUserWithEmailAndPassword(
          email, sifre);
    } else {
      MyUser? _user = await _firebaseAuthService.createUserWithEmailAndPassword(
          email, sifre);
      bool _sonuc = await _firestoreDBService.saveUser(_user!);
      if (_sonuc) {
        return await _firestoreDBService.readUser(_user.userID);
      } else {
        return null;
      }
    }
  }

  @override
  Future<MyUser?> signInWithEmailAndPassword(String email, String sifre) async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthService.signInWithEmailAndPassword(email, sifre);
    } else {
      MyUser? _user =
          await _firebaseAuthService.signInWithEmailAndPassword(email, sifre);
      return await _firestoreDBService.readUser(_user!.userID);
    }
  }

  Future<bool> updateUsername(String userID, String yeniUserName) async {
    if (appMode == AppMode.DEBUG) {
      return false;
    } else {
      return await _firestoreDBService.updateUsername(userID, yeniUserName);
    }
  }

  Future<String> uploadFile(String userID, String fileType, File file) async {
    if (appMode == AppMode.DEBUG) {
      return 'dosya_indirme_linki';
    } else {
      String fileURL =
          await _firebaseStorageService.uploadFile(userID, fileType, file);
      await _firestoreDBService.updateProfilFoto(userID, fileURL);
      return fileURL;
    }
  }

  Stream<List<Mesaj>> getMessages(
      String currentUserID, String sohbetEdilenUserID) {
    if (appMode == AppMode.DEBUG) {
      return Stream.empty();
    } else {
      return _firestoreDBService.getMessages(currentUserID, sohbetEdilenUserID);
    }
  }

  Future<bool> saveMessage(Mesaj kaydedilecekMesaj) async {
    if (appMode == AppMode.DEBUG) {
      return true;
    } else {
      return _firestoreDBService.saveMessage(kaydedilecekMesaj);
    }
  }

  Future<List<Konusma>> getAllConversations(String userID) async {
    if (appMode == AppMode.DEBUG) {
      return [];
    } else {
      DateTime _zaman = await _firestoreDBService.saatiGoster(userID);

      var konusmaListesi =
          await _firestoreDBService.getAllConversations(userID);
      for (var oankiKonusma in konusmaListesi) {
        var userListesindekiKullanici =
            listedeUserBul(oankiKonusma.kimle_konusuyor);
        if (userListesindekiKullanici != null) {
          debugPrint('VERİLER CACHEDEN OKUNDU');
          oankiKonusma.konusulanUserName = userListesindekiKullanici.userName!;
          oankiKonusma.konusulanUserProfilURL =
              userListesindekiKullanici.profilURL!;
        } else {
          debugPrint('VERİLER VERİTABANINDAN OKUNDU');
          debugPrint(
              'Aranılan user daha önceden veri tabanından getirilmemiştir, o yüzden veri tabanından bu değeri okumalıyız');
          var _veritabanindanOkunanUser =
              await _firestoreDBService.readUser(oankiKonusma.kimle_konusuyor);
          oankiKonusma.konusulanUserName = _veritabanindanOkunanUser.userName!;
          oankiKonusma.konusulanUserProfilURL =
              _veritabanindanOkunanUser.profilURL!;
        }

        timeagoHesapla(oankiKonusma, _zaman);
      }
      return konusmaListesi;
    }
  }

  MyUser? listedeUserBul(String userID) {
    for (int i = 0; i < tumKullaniciListesi.length; i++) {
      if (tumKullaniciListesi[i].userID == userID) {
        return tumKullaniciListesi[i];
      }
    }
    return null;
  }

  void timeagoHesapla(Konusma oankiKonusma, DateTime zaman) {
    oankiKonusma.sonOkumaZamani = zaman;
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    var _duration = zaman.difference(oankiKonusma.olusturulma_tarihi!.toDate());
    oankiKonusma.gecenZamanFarki =
        timeago.format(zaman.subtract(_duration), locale: 'tr');
  }

  Future<List<MyUser>> getUserWithPagination(
      MyUser? enSonGetirilenUser, int getirilecekElemanSayisi) async {
    if (appMode == AppMode.DEBUG) {
      return [];
    } else {
      List<MyUser> _userList = await _firestoreDBService.getUserWithPagination(
          enSonGetirilenUser, getirilecekElemanSayisi);
      tumKullaniciListesi.addAll(_userList);
      return _userList;
    }
  }

  Future<List<Mesaj>> getMessageWithPagination(
      String currentUserID,
      String sohbetEdilenUserID,
      Mesaj? enSonGetirilenMesaj,
      int getirilecekElemanSayisi) async {
    if (appMode == AppMode.DEBUG) {
      return [];
    } else {
      return await _firestoreDBService.getMessageWithPagination(currentUserID,
          sohbetEdilenUserID, enSonGetirilenMesaj, getirilecekElemanSayisi);
    }
  }
}
