import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lovers/common_widget/tab_items.dart';

/*
      home_page.dart 'da  gerekli ayarlamalar devam ediyor!!!
*/

class MyCustomBottomNavigation extends StatelessWidget {
  const MyCustomBottomNavigation(
      {Key? key,
      required this.currentTab,
      required this.onSelectedTab,
      required this.sayfaOlusturucu,
      required this.navigatorKeys})
      : super(key: key);

  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectedTab;
  final Map<TabItem, Widget> sayfaOlusturucu;
  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          _navItemOlustur(TabItem.Kullanicilar),
          _navItemOlustur(TabItem.Konusmalarim),
          _navItemOlustur(TabItem.Profil),
        ],
        onTap: (index) => onSelectedTab(TabItem.values[index]),
      ),
      tabBuilder: (BuildContext context, int index) {
        var gosterilecekItem = TabItem.values[index];
        return CupertinoTabView(
          navigatorKey: navigatorKeys[gosterilecekItem],
          builder: (context) {
            return sayfaOlusturucu[gosterilecekItem] as Widget;
          },
        );
      },
    );
  }

  BottomNavigationBarItem _navItemOlustur(TabItem tabItem) {
    final olusturulacakTab = TabItemData.tumTablar[tabItem];
    return BottomNavigationBarItem(
        icon: Icon(olusturulacakTab!.icon), label: olusturulacakTab.title);
  }
}
