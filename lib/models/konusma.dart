import 'package:cloud_firestore/cloud_firestore.dart';

class Konusma {
  final String konusma_sahibi;
  final String kimle_konusuyor;
  final bool konusma_goruldu;
  final Timestamp? olusturulma_tarihi;
  final String son_yollanan_mesaj;
  final Timestamp? gorulme_tarihi;
  late String konusulanUserName;
  late String konusulanUserProfilURL;
  late DateTime sonOkumaZamani;
  late String gecenZamanFarki;

  Konusma({
    required this.konusma_sahibi,
    required this.kimle_konusuyor,
    required this.konusma_goruldu,
    required this.gorulme_tarihi,
    required this.son_yollanan_mesaj,
    this.olusturulma_tarihi,
  });

  Map<String, dynamic> toMap() {
    return {
      'konusma_sahibi': konusma_sahibi,
      'kimle_konusuyor': kimle_konusuyor,
      'konusma_goruldu': konusma_goruldu,
      'olusturulma_tarihi': olusturulma_tarihi ?? FieldValue.serverTimestamp(),
      'son_yollanan_mesaj': son_yollanan_mesaj,
      'gorulme_tarihi': gorulme_tarihi ?? FieldValue.serverTimestamp(),
    };
  }

  Konusma.fromMap(Map<String, dynamic> map)
      : konusma_sahibi = map['konusma_sahibi'],
        kimle_konusuyor = map['kimle_konusuyor'],
        konusma_goruldu = map['konusma_goruldu'],
        olusturulma_tarihi = map['olusturulma_tarihi'],
        son_yollanan_mesaj = map['son_yollanan_mesaj'],
        gorulme_tarihi = map['gorulme_tarihi'];

  @override
  String toString() {
    return 'Konusma{konusma_sahibi: $konusma_sahibi, kimle_konusuyor: $kimle_konusuyor, konusma_goruldu: $konusma_goruldu, olusturulma_tarihi: $olusturulma_tarihi, son_yollanan_mesaj: $son_yollanan_mesaj, gorulme_tarihi: $gorulme_tarihi}';
  }
}
