import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_lovers/app/hata_exceptions.dart';
import 'package:flutter_lovers/app/sign_in/email_sifre_giris_ve_kayit.dart';
import 'package:flutter_lovers/common_widget/platform_duyarli_alert_dialog.dart';
import 'package:flutter_lovers/common_widget/social_login_button.dart';
import 'package:flutter_lovers/view_model/view_model.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';

FirebaseAuthException? myHata;

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      if (myHata != null) {
        PlatformDuyarliAlertDialog(
                baslikText: 'Facebook giriş hatası',
                icerikText: Hatalar.goster(myHata!.code),
                anaButtonText: 'Tamam')
            .goster(
                context); // facebook giriş yaparken facebook penceresi açıldığı için context değişiyor ve
        // burada hata alıyorduk(aşağıda _facebookIleGiris fonsiyonunun içinde yapmıştık).
        // Daha sonra en tepeye exception değişkeni oluşturup _facebookIleGiris'te buna atamayı yaptık
        // Daha sonra sign-in-page'i statefull yaptık ve initstate fonsiyonunu oluşturup içine bunları yazdık.

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Lover'),
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade200,
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Oturum Açın',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
            ),
            SizedBox(height: 8),
            SocialLoginButton(
              buttonText: 'Gmail ile Giriş Yap',
              borderRadius: 16,
              buttonColor: Colors.white,
              textColor: Colors.black87,
              buttonIcon: Image.asset('images/google-logo.png'),
              yukseklik: 40,
              onPressed: () {
                _googleIleGiris(context);
              },
            ),
            SocialLoginButton(
              buttonText: 'Facebook ile Giriş Yap',
              borderRadius: 16,
              buttonColor: Color(0xFF334D92),
              textColor: Colors.white,
              buttonIcon: Image.asset('images/facebook-logo.png'),
              yukseklik: 40,
              onPressed: () {
                _facebookIleGiris(context);
              },
            ),
            SocialLoginButton(
              buttonText: 'Email ve Şifre ile Giriş Yap',
              borderRadius: 16,
              buttonColor: Colors.purple,
              textColor: Colors.white,
              buttonIcon: Icon(
                Icons.email,
                size: 35,
              ),
              yukseklik: 40,
              onPressed: () {
                _emailVeSifreGiris(context);
              },
            ),
            /*SocialLoginButton(
              buttonText: 'Misafir Olarak Giriş Yap',
              borderRadius: 16,
              buttonColor: Colors.teal,
              textColor: Colors.white,
              buttonIcon: Icon(
                Icons.account_circle_sharp,
                size: 35,
              ),
              yukseklik: 40,
              onPressed: () {
                _misafirGirisi(context);
              },
            ),*/
          ],
        ),
      ),
    );
  }

  void _googleIleGiris(BuildContext context) async {
    final _viewModel = Provider.of<ViewModel>(context, listen: false);
    MyUser? _user = await _viewModel.signInWithGoogle();
    debugPrint('Google ile Oturum açan user id ' + _user!.userID.toString());
  }

  void _facebookIleGiris(BuildContext context) async {
    final _viewModel = Provider.of<ViewModel>(context, listen: false);

    try {
      MyUser? _user = await _viewModel.signInWithFacebook();
      if (_user != null) debugPrint('Oluşturulan user id ' + _user.userID);
    } on FirebaseAuthException catch (e) {
      myHata = e;
      debugPrint('Facebook giriş hata yakalandı : ' + Hatalar.goster(e.code));
    }
  }

  void _emailVeSifreGiris(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => EmailveSifreLoginPage(),
      ),
    );
  }
}
