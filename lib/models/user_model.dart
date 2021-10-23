import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  MyUser({required this.userID, this.email});
  final String userID;
  String? email;
  String? userName;
  String? profilURL;
  DateTime? createdAt;
  DateTime? updatedAt;
  int?
      seviye; // Kullanıcının Yönetici mi ya da Sıradan bir kullanıcı mı olduğunu atırt etmek için

  Map<String, dynamic> tomap() {
    return {
      'userID': userID,
      'email': email,
      'userName': userName ??
          email!.substring(0, email!.indexOf('@')) + randomSayiUret(),
      'profilURL': profilURL ??
          'https://www.happykidgames.com/assets/img/fakeProfil.png',
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
      'seviye': seviye ?? 1,
    };
  }

  // farklı bir syntax ile yaptık şaşırtmasın. Diğer uygulamalarda yaptığımızın aynısı aslında
  MyUser.fromMap(Map<String, dynamic> map)
      : userID = map['userID'],
        email = map['email'],
        userName = map['userName'],
        profilURL = map['profilURL'],
        createdAt = (map['createdAt'] as Timestamp).toDate(),
        updatedAt = (map['updatedAt'] as Timestamp).toDate(),
        seviye = map['seviye'];

  MyUser.idVeResim({required this.userID, this.profilURL});

  @override
  String toString() {
    return 'MyUser{userID: $userID, email: $email, userName: $userName, profilURL: $profilURL, createdAt: $createdAt, updatedAt: $updatedAt, seviye: $seviye}';
  }

  String randomSayiUret() {
    int rastgeleSayi = Random().nextInt(999999);
    return rastgeleSayi.toString();
  }
}
