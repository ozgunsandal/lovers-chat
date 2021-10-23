import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_lovers/common_widget/platform_duyarli_alert_dialog.dart';
import 'package:flutter_lovers/common_widget/social_login_button.dart';
import 'package:flutter_lovers/view_model/view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  late TextEditingController _controllerUserName;
  XFile? _profilFoto;
  @override
  void initState() {
    super.initState();
    _controllerUserName = TextEditingController();
  }

  @override
  void dispose() {
    _controllerUserName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ViewModel _viewModel = Provider.of<ViewModel>(context);
    _controllerUserName.text = _viewModel.user!.userName!;
    debugPrint(
        'Profil sayfasındaki user degerleri :' + _viewModel.user.toString());
    //Bir kullanıcı signin sayfasından bir butona basıp login olduğunda
    // bu sayfaya(profil sayfası) gelirsek yukardaki print içindeki user değerleri
    // eksiksik görünür. Fakat signin olmuş bir kullanıcı varken, uygulamayı kapatıp
    // tekrar açınca (otomatik sign olacağı için) bu sayfaya(profil) gelirsek yukardaki
    // print içindeki user değerlerinin bazıları(çoğu) gelmeyecektir.
    // Çünkü biz butona basıp sign olduktan sonra aynı zamanda readUser diye bir metod
    // çalıştırıp _viewModel'deki user nesnemizi readUser'dan gelen değerlerle dolduruyoruz
    //zaten sign olmuş bir kullanıcı uygulamaya girerken bu readUser fonksiyonu çalıştırılmıyor
    //o yüzden değerleri null görüyoruz(duk).
    //user repo içindeki currentUser metodu içinde bu sorunu hallettik
    //Uygulama çalıştığında ViewModel'den bir nesne örneği oluşturuluyordu zaten.
    //ViewModel'in constructor'ında currentUser'ı çağırıp içini istediğimiz gibi user repo'da dolduruyoruz.
    return Scaffold(
        appBar: AppBar(
          title: Text('Profil'),
          actions: [
            TextButton(
              onPressed: () {
                _cikisIcinOnayIste(context);
              },
              child: Text('Çıkış',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Container(
                              height: 175,
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.camera),
                                    title: Text('Kameradan Çek'),
                                    onTap: () {
                                      _kameradanFotoCek();
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.image),
                                    title: Text('Galeriden Seç'),
                                    onTap: () {
                                      _galeridenFotoSec();
                                    },
                                  )
                                ],
                              ),
                            );
                          });
                    },
                    child: CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.white,
                      backgroundImage: _profilFoto == null
                          ? NetworkImage(_viewModel.user!.profilURL!)
                          : FileImage(
                              File(_profilFoto!.path),
                            ) as ImageProvider,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    initialValue: _viewModel.user!.email,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Emailiniz',
                      hintText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _controllerUserName,
                    decoration: InputDecoration(
                      labelText: 'Kullanıcı Adınız',
                      hintText: 'Kullanıcı Adı',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SocialLoginButton(
                    onPressed: () {
                      _userNameGuncelle(context);
                      _profilFotoGuncelle(context);
                    },
                    buttonText: 'Değişiklikleri Kaydet',
                    borderRadius: 10,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<bool> _cikisYap(BuildContext context) async {
    final _viewModel = Provider.of<ViewModel>(context, listen: false);
    bool? sonuc = await _viewModel.signOut();
    return sonuc!;
  }

  Future _cikisIcinOnayIste(BuildContext context) async {
    final bool? sonuc = await PlatformDuyarliAlertDialog(
            baslikText: 'Emin misiniz?',
            icerikText: 'Çıkmak istediğinizden emin misiniz?',
            anaButtonText: 'Evet',
            ikincilButtonText: 'Vazgeç')
        .goster(context);
    if (sonuc!) {
      _cikisYap(context);
    }
  }

  void _userNameGuncelle(BuildContext context) async {
    final _viewModel = Provider.of<ViewModel>(context, listen: false);
    if (_viewModel.user!.userName != _controllerUserName.text) {
      bool updateResult = await _viewModel.updateUserName(
          _viewModel.user!.userID, _controllerUserName.text);
      if (updateResult) {
        PlatformDuyarliAlertDialog(
          baslikText: 'Başarılı',
          icerikText: 'Kullanıcı adı değiştirildi',
          anaButtonText: 'Tamam',
        ).goster(context);
      } else {
        _controllerUserName.text = _viewModel.user!.userName!;
        PlatformDuyarliAlertDialog(
          baslikText: 'Hata',
          icerikText:
              'Kullanıcı adı zaten kullanımda, farklı bir kullanıcı adı deneyiniz',
          anaButtonText: 'Tamam',
        ).goster(context);
      }
    }
  }

  void _galeridenFotoSec() async {
    var _resim = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _profilFoto = _resim;
      Navigator.of(context).pop();
    });
  }

  void _kameradanFotoCek() async {
    var _resim = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      _profilFoto = _resim;
      Navigator.of(context).pop();
    });
  }

  void _profilFotoGuncelle(BuildContext context) async {
    final _viewModel = Provider.of<ViewModel>(context, listen: false);
    if (_profilFoto != null) {
      var url = await _viewModel.uploadFile(
        _viewModel.user!.userID,
        'profil_foto',
        File(_profilFoto!.path),
      );
      if (url != null) {
        PlatformDuyarliAlertDialog(
          baslikText: 'Başarılı',
          icerikText: 'Profil fotoğrafınız güncellendi',
          anaButtonText: 'Tamam',
        ).goster(context);
      }

      debugPrint('Image Download Link : ' + url);
    }
  }
}
