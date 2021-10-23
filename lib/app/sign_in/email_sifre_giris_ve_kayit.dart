import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lovers/app/hata_exceptions.dart';
import 'package:flutter_lovers/common_widget/platform_duyarli_alert_dialog.dart';
import 'package:flutter_lovers/common_widget/social_login_button.dart';
import 'package:flutter_lovers/models/user_model.dart';
import 'package:flutter_lovers/view_model/view_model.dart';
import 'package:provider/provider.dart';

enum FormType { Register, LogIn }

class EmailveSifreLoginPage extends StatefulWidget {
  const EmailveSifreLoginPage({Key? key}) : super(key: key);

  @override
  _EmailveSifreLoginPageState createState() => _EmailveSifreLoginPageState();
}

class _EmailveSifreLoginPageState extends State<EmailveSifreLoginPage> {
  late String _email, _sifre;
  late String _buttonText, _linkText;
  late FormType _formType = FormType.LogIn;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _buttonText = _formType == FormType.LogIn ? 'Giriş Yap' : 'Kayıt Ol';
    _linkText = _formType == FormType.LogIn
        ? 'Hesabınız yok mu? Kayıt Olun'
        : 'Hesabınız var mı? Giriş Yapın';

    final _viewModel = Provider.of<ViewModel>(context);

    if (_viewModel.user != null) {
      Future.delayed(Duration(milliseconds: 1), () {
        Navigator.of(context).popUntil(
            ModalRoute.withName('/')); //Kullanıcı giriş yap butonuna bastığında
        //bu sayfa kapanıyor ve kullanıcıyı home-page'e yönlendiriyor. Fakat bu sayfa sign-in-page'e ait bir sayfa
        //yani sign-in-page contextinde açıldığı için, bu sayfa göründüğünde arkada hala sign-in-page sayfası duruyor aslında.
        //O yüzden giriş yap butonuna basınca sadece bu sayfayı pop() edersek hata alırız. Çünkü giriş yap butonuna bastığımız anda
        // arkadaki sign-in-page home-page'e yönlenecek ve içinde bulunduğumuz sayfa da sign-in-page içinde açıldığından
        //içinde bulunduğumuz sayfa sahipsiz kalacak ve hata verecek. Bu yüzden giriş yap butonuna basınca popUntil() diyerek
        // root'a kadar bu sayfayı pop ediyoruz.
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Giriş / Kayıt'),
      ),
      body: _viewModel.viewState == ViewState.Idle
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (_) => true ? '' : null,
                        initialValue: 'ozgun@ozgun.com',
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.mail),
                          hintText: 'Email',
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          errorText: _viewModel.emailHataMesaji != null
                              ? _viewModel.emailHataMesaji
                              : '',
                        ),
                        onSaved: (girilenEmail) {
                          _email = girilenEmail!;
                        },
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      TextFormField(
                        initialValue: 'password',
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.password),
                          hintText: 'Şifre',
                          labelText: 'Şifre',
                          border: OutlineInputBorder(),
                          errorText: _viewModel.sifreHataMesaji != null
                              ? _viewModel.sifreHataMesaji
                              : '',
                        ),
                        onSaved: (girilenSifre) {
                          _sifre = girilenSifre!;
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      SocialLoginButton(
                        onPressed: () {
                          _formSubmit();
                        },
                        buttonText: _buttonText,
                        buttonColor: Theme.of(context).primaryColor,
                        borderRadius: 10,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextButton(
                        onPressed: () {
                          _degistir();
                        },
                        child: Text(_linkText),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  void _formSubmit() async {
    _formKey.currentState!.save();
    debugPrint('Email ' + _email + ' Şifre ' + _sifre);
    final _viewModel = Provider.of<ViewModel>(context,
        listen: false); // stateFullwidget'ta context'e direkt erişebiliriz.
    if (_formType == FormType.LogIn) {
      try {
        MyUser? _girisyapanUser =
            await _viewModel.signInWithEmailAndPassword(_email, _sifre);
        if (_girisyapanUser != null) {
          debugPrint('Oturum açan user id ' + _girisyapanUser.userID);
        }
      } on FirebaseAuthException catch (e) {
        PlatformDuyarliAlertDialog(
                baslikText: 'Oturum Açmada Hata',
                icerikText: Hatalar.goster(e.code),
                anaButtonText: 'Tamam')
            .goster(context);
      }
    } else {
      try {
        MyUser? _olusturulanUser =
            await _viewModel.createUserWithEmailAndPassword(_email, _sifre);
        debugPrint('Oluşturulan user id ' + _olusturulanUser!.userID);
      } on FirebaseAuthException catch (e) {
        debugPrint(
            'Widgettaki hata yakalndı. Email ve şifre içinde Kullanıcı oluştururken hata : ' +
                Hatalar.goster(e.code));

        PlatformDuyarliAlertDialog(
                baslikText: 'Kullanıcı Oluşturma Hata',
                icerikText: Hatalar.goster(e.code),
                anaButtonText: 'Tamam')
            .goster(context);
      }
    }
  }

  void _degistir() {
    setState(() {
      _formType =
          _formType == FormType.LogIn ? FormType.Register : FormType.LogIn;
    });
  }
}
