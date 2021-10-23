import 'package:flutter/cupertino.dart';
import 'package:flutter_lovers/models/konusma.dart';
import 'package:flutter_lovers/models/mesaj.dart';
import 'package:flutter_lovers/models/user_model.dart';
import 'package:flutter_lovers/services/database_base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDBService implements DBBase {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<bool> saveUser(MyUser user) async {
    DocumentSnapshot _okunanUser =
        await FirebaseFirestore.instance.doc('users/${user.userID}').get();

    if (_okunanUser.data() == null) {
      await _firebaseFirestore
          .collection('users')
          .doc(user.userID)
          .set(user.tomap());
      return true;
    } else {
      return true;
    }
  }

  @override
  Future<MyUser> readUser(String userID) async {
    DocumentSnapshot _okunanUser =
        await _firebaseFirestore.collection('users').doc(userID).get();
    Map<String, dynamic> _okunanUserBilgileriMap =
        _okunanUser.data() as Map<String, dynamic>;
    MyUser _okunanUserNesnesi = MyUser.fromMap(_okunanUserBilgileriMap);
    return _okunanUserNesnesi;
  }

  @override
  Future<bool> updateUsername(String userID, String yeniUserName) async {
    QuerySnapshot users = await _firebaseFirestore
        .collection('users')
        .where('userName', isEqualTo: yeniUserName)
        .get();
    if (users.docs.isNotEmpty) {
      // Kullanıcı adları unic olmasını istiyoruz, o yüzden bizim databasede kullanıcının yeni yazdığı username var mı yok mu ona bakıyoruz.
      return false;
    } else {
      await _firebaseFirestore
          .collection('users')
          .doc(userID)
          .update({'userName': yeniUserName});
      return true;
    }
  }

  @override
  Future<bool> updateProfilFoto(String userID, String fileURL) async {
    await _firebaseFirestore
        .collection('users')
        .doc(userID)
        .update({'profilURL': fileURL});
    return true;
  }

  @override
  Future<List<Konusma>> getAllConversations(String userID) async {
    QuerySnapshot querySnapshot = await _firebaseFirestore
        .collection('konusmalar')
        .where('konusma_sahibi', isEqualTo: userID)
        .orderBy('olusturulma_tarihi', descending: true)
        .get();

    /*
    Yukarıdaki sorgu gibi, hem where komutunu hem orderby komutunu hem de orderby içinde
    descending komutunu çalıştırmaya çalışınca bu, firebase tarafından composite yani bileşik
    sorgu olarak algılanıp consoleda hata veriyor. Consoledaki hatayı incelersen orada sana bir link
    veriyor ve linke tıkladığında seni firebase'de bu sorguya ait bir 'index' oluşturman için
    yönlendiriyor. index oluşturup oradaki status bölümünün enabled olmasını bekledikten sonra
    tekrar denersen hatasız çalışır.
    * */

    List<Konusma> tumKonusmalar = [];
    for (DocumentSnapshot tekKonusma in querySnapshot.docs) {
      Konusma _tekKonusma =
          Konusma.fromMap(tekKonusma.data() as Map<String, dynamic>);
      tumKonusmalar.add(_tekKonusma);
    }

    return tumKonusmalar;
  }

  @override
  Stream<List<Mesaj>> getMessages(
      String currentUserID, String sohbetEdilenUserID) {
    var snapshot = _firebaseFirestore
        .collection('konusmalar')
        .doc(currentUserID + '--' + sohbetEdilenUserID)
        .collection('mesajlar')
        .orderBy('date', descending: true)
        .limit(
            1) // en son mesajı getirip ondan sonra yeni mesaj var mı diye dinlemeye başlıyoruz
        .snapshots();
    return snapshot.map((mesajlarListesi) => mesajlarListesi.docs
        .map((mesaj) => Mesaj.fromMap(mesaj.data()))
        .toList());
  }

  @override
  Future<bool> saveMessage(Mesaj kaydedilecekMesaj) async {
    var mesajID = _firebaseFirestore
        .collection('konusmalar')
        .doc()
        .id; //Kaydetme yada okuma işlemi yapmadan sadece doc id oluşturuyoruz. Daha sonra bu id ile kayededeceğiz.

    var _benimDokumanID = kaydedilecekMesaj.kimden +
        '--' +
        kaydedilecekMesaj
            .kime; //Benim sohbetlerimin tutulacağı dokumanın id'si.
    var _karsidakininDokumanID = kaydedilecekMesaj.kime +
        '--' +
        kaydedilecekMesaj
            .kimden; //Sohbet ettiğim kişinin sohbetlerinin tutulduğu dokumanın id'si.

    var _kaydedilecekMesajMapYapisi = kaydedilecekMesaj.toMap();

    await _firebaseFirestore
        .collection('konusmalar')
        .doc(_benimDokumanID)
        .collection('mesajlar')
        .doc(mesajID)
        .set(_kaydedilecekMesajMapYapisi);

    await _firebaseFirestore.collection('konusmalar').doc(_benimDokumanID).set({
      'konusma_sahibi': kaydedilecekMesaj.kimden,
      'kimle_konusuyor': kaydedilecekMesaj.kime,
      'son_yollanan_mesaj': kaydedilecekMesaj.mesaj,
      'konusma_goruldu': false,
      'olusturulma_tarihi': FieldValue.serverTimestamp(),
    });

    _kaydedilecekMesajMapYapisi.update('bendenMi', (deger) => false);

    await _firebaseFirestore
        .collection('konusmalar')
        .doc(_karsidakininDokumanID)
        .collection('mesajlar')
        .doc(mesajID)
        .set(_kaydedilecekMesajMapYapisi);

    await _firebaseFirestore
        .collection('konusmalar')
        .doc(_karsidakininDokumanID)
        .set({
      'konusma_sahibi': kaydedilecekMesaj.kime,
      'kimle_konusuyor': kaydedilecekMesaj.kimden,
      'son_yollanan_mesaj': kaydedilecekMesaj.mesaj,
      'konusma_goruldu': false,
      'olusturulma_tarihi': FieldValue.serverTimestamp(),
    });

    return true;
  }

  @override
  Future<DateTime> saatiGoster(String userID) async {
    await _firebaseFirestore.collection('server').doc(userID).set({
      'saat': FieldValue.serverTimestamp(),
    });
    var okunanMap =
        await _firebaseFirestore.collection('server').doc(userID).get();
    Timestamp okunanTarih = okunanMap.data()!['saat'];
    return okunanTarih.toDate();
  }

  @override
  Future<List<MyUser>> getUserWithPagination(
      MyUser? enSonGetirilenUser, int getirilecekElemanSayisi) async {
    QuerySnapshot _querySnapshot;
    List<MyUser> _tumKullanicilar = [];
    if (enSonGetirilenUser == null) {
      debugPrint('ILk defa kullanıcılar getiriliyor');
      _querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('userName')
          .limit(getirilecekElemanSayisi)
          .get();
    } else {
      debugPrint('Sonraki kullanıcılar getiriliyor');
      _querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('userName')
          .startAfter([enSonGetirilenUser.userName])
          .limit(getirilecekElemanSayisi)
          .get();

      await Future.delayed(const Duration(milliseconds: 250));
    }
    for (DocumentSnapshot snap in _querySnapshot.docs) {
      MyUser _tekUser = MyUser.fromMap(snap.data() as Map<String, dynamic>);
      _tumKullanicilar.add(_tekUser);
      debugPrint('Getirilen user name: ' + _tekUser.userName!);
    }
    return _tumKullanicilar;
  }

  Future<List<Mesaj>> getMessageWithPagination(
      String currentUserID,
      String sohbetEdilenUserID,
      Mesaj? enSonGetirilenMesaj,
      int getirilecekElemanSayisi) async {
    QuerySnapshot _querySnapshot;
    List<Mesaj> _tumMesajlar = [];
    if (enSonGetirilenMesaj == null) {
      debugPrint('ILk defa mesajlar getiriliyor');
      _querySnapshot = await FirebaseFirestore.instance
          .collection('konusmalar')
          .doc(currentUserID + '--' + sohbetEdilenUserID)
          .collection('mesajlar')
          .orderBy('date', descending: true)
          .limit(getirilecekElemanSayisi)
          .get();
    } else {
      debugPrint('Sonraki mesajlar getiriliyor');
      _querySnapshot = await FirebaseFirestore.instance
          .collection('konusmalar')
          .doc(currentUserID + '--' + sohbetEdilenUserID)
          .collection('mesajlar')
          .orderBy('date', descending: true)
          .startAfter([enSonGetirilenMesaj.date])
          .limit(getirilecekElemanSayisi)
          .get();

      await Future.delayed(const Duration(milliseconds: 250));
    }
    for (DocumentSnapshot snap in _querySnapshot.docs) {
      Mesaj _tekMesaj = Mesaj.fromMap(snap.data() as Map<String, dynamic>);
      _tumMesajlar.add(_tekMesaj);
    }
    return _tumMesajlar;
  }
}
