import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lovers/app/konusmalarim.dart';
import 'package:flutter_lovers/app/kullanicilar.dart';
import 'package:flutter_lovers/common_widget/my_custom_bottom_navi.dart';
import 'package:flutter_lovers/app/profil.dart';
import 'package:flutter_lovers/common_widget/platform_duyarli_alert_dialog.dart';
import 'package:flutter_lovers/common_widget/tab_items.dart';
import 'package:flutter_lovers/models/user_model.dart';
import 'package:flutter_lovers/view_model/all_user_view_model.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.user}) : super(key: key);
  final MyUser user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  TabItem _currentTab = TabItem.Kullanicilar;

  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.Kullanicilar: GlobalKey<NavigatorState>(),
    TabItem.Konusmalarim: GlobalKey<NavigatorState>(),
    TabItem.Profil: GlobalKey<NavigatorState>(),
  };

  @override
  void initState() {
    super.initState();
    _setFCM();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !await navigatorKeys[_currentTab]!
          .currentState!
          .maybePop(), //WillPopScope Kullanımı => derslerdeki başlık **********
      // Cihazda geri butonuna basınca currentStage'ten önce bir sayfa var mı ona bakar, varsa
      // pop edip oraya gider. Sayfa yoksa uygulamadan çıkar. await'ten önce kullandığımız ! işaretine
      // dikkat et. maybePop() true veya false döndürüyor.
      child: MyCustomBottomNavigation(
        currentTab: _currentTab,
        sayfaOlusturucu: tumSayfalar(),
        navigatorKeys: navigatorKeys,
        onSelectedTab: (secilenTab) {
          if (secilenTab == _currentTab) {
            //Diyelim ki Kullanıcılar sayfasından tıklaya tıklaya OrnekPage2 sayfasına
            //(şu an bu sayfa yok. Deneme için basit bi şekilde OrnekPage1 ve OrnekPage2
            // sayfası oluşturmuştuk navigotor işlemleri için sonra sildik. OrnekPage2 sayfasına
            // OrnakPage1 içinden gidiyorduk. Kullanıcılar > Ornekpage1 > Ornekpage2)
            // kadar geldin ve bottom bardaki kullanıcılar tabına tekrar bastın.
            //Ornek page'leri kapatıp Kullanıcılar sayfasına geri dönmek içi kontrol yazıyoruz.
            navigatorKeys[secilenTab]!
                .currentState!
                .popUntil((route) => route.isFirst);
          } else {
            setState(() {
              _currentTab = secilenTab;
            });
            //Konuşmalarım tabına tıklayınca yeniliyor
            if (_currentTab == TabItem.Konusmalarim) {
              (context as Element).reassemble();
            }
          }
        },
      ),
    );
  }

  Map<TabItem, Widget> tumSayfalar() {
    return {
      TabItem.Kullanicilar: ChangeNotifierProvider(
        create: (context) => AllUserViewModel(),
        child: KullanicilarPage(),
      ),
      TabItem.Konusmalarim: KonusmalarimPage(),
      TabItem.Profil: ProfilPage(),
    };
  }

  void _setFCM() async {
    //////
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
    //////
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');
      debugPrint('Message data: $message');

      if (message.notification != null) {
        debugPrint(
            'Message also contained a notification: ${message.notification}');
      }
    });
    await FirebaseMessaging.instance.subscribeToTopic('spor');
    String? token = await FirebaseMessaging.instance.getToken();
    debugPrint('TOKEENNN : ' + token!);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    //Uygulama kapalıyken gelen bildirime tıklayınca uygulama açıldığında göstermek istediğin widgetlar varsa alttaki
    // fonksiyon ile yapılıyor ve onBackgroundMessage'ın altında olsun.
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      PlatformDuyarliAlertDialog(
        baslikText:
            message != null ? message.notification!.title! : 'Mesaj başlık',
        icerikText:
            message != null ? message.notification!.body! : 'Mesaj body',
        anaButtonText: 'tamam',
      ).goster(context);
    });
    ////////
  }
}

// bu fonksiyon sınıfın dışında olmalı bu şekilde. Bu fonksiyonun amacı sadece
//uygulamayı, uygulama kapalıyken bildirim alır hale getirmek, başka numarası yok.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
      'Uygulamala kapalıyken mesaj geldi : ${message.notification!.title}');
}
