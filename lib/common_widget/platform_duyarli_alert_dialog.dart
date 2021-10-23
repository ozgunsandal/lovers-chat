import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_lovers/common_widget/platform_duyarli_widget.dart';

class PlatformDuyarliAlertDialog extends PlatformDuyarliWidget {
  final String baslikText;
  final String icerikText;
  final String anaButtonText;
  final String? ikincilButtonText;

  PlatformDuyarliAlertDialog(
      {required this.baslikText,
      required this.icerikText,
      required this.anaButtonText,
      this.ikincilButtonText});

  Future<bool?> goster(BuildContext context) async {
    return Platform.isIOS
        ? await showCupertinoDialog<bool>(
            context: context, builder: (context) => this)
        : await showDialog<bool>(
            context: context,
            builder: (context) => this,
            barrierDismissible: false);
  }

  @override
  Widget buildAndroidWidget(BuildContext context) {
    return AlertDialog(
      title: Text(baslikText),
      content: Text(icerikText),
      actions: _dialogButonlariniAyarla(context),
    );
  }

  @override
  Widget buildIOSWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(baslikText),
      content: Text(icerikText),
      actions: _dialogButonlariniAyarla(context),
    );
  }

  List<Widget> _dialogButonlariniAyarla(BuildContext context) {
    final tumButonlar = <Widget>[];
    if (Platform.isIOS) {
      if (ikincilButtonText != null) {
        tumButonlar.add(CupertinoDialogAction(
          child: Text(ikincilButtonText!),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ));
      }

      tumButonlar.add(
        CupertinoDialogAction(
          child: Text(anaButtonText),
          onPressed: () {
            Navigator.of(context).pop(
                true); // Bu dialog penceresini kullanırken butonlara bastığımızda
            // geriye değer döndürmek isteyebiliriz. Mesela Kullanıcı sign out olurken önce soruyoruz emin misin diye.
            // Eğer evet derse arka ekrana bir değer döndürüp ona göre işlem yaptırmamız lazım.
            // Evet derse signout yapıp login butonlarının olduğu sayfaya gönderiyorduk. Bunun kontrolü için.
          },
        ),
      );
    } else {
      if (ikincilButtonText != null) {
        tumButonlar.add(TextButton(
          child: Text(ikincilButtonText!),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ));
      }
      tumButonlar.add(TextButton(
        child: Text(anaButtonText),
        onPressed: () {
          Navigator.of(context).pop(true);
        },
      ));
    }
    return tumButonlar;
  }
}
