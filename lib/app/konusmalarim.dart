import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lovers/app/sohbet.dart';
import 'package:flutter_lovers/models/konusma.dart';
import 'package:flutter_lovers/models/user_model.dart';
import 'package:flutter_lovers/view_model/chat_view_model.dart';
import 'package:flutter_lovers/view_model/view_model.dart';
import 'package:provider/provider.dart';

class KonusmalarimPage extends StatefulWidget {
  const KonusmalarimPage({Key? key}) : super(key: key);

  @override
  _KonusmalarimPageState createState() => _KonusmalarimPageState();
}

class _KonusmalarimPageState extends State<KonusmalarimPage> {
  @override
  Widget build(BuildContext context) {
    ViewModel _viewModel = Provider.of<ViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Konuşmalarım'),
      ),
      body: FutureBuilder<List<Konusma>>(
        future: _viewModel.getAllConversations(_viewModel.user!.userID),
        builder: (context, konusmaListesi) {
          if (!konusmaListesi.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var tumKonusmalar = konusmaListesi.data;

            if (tumKonusmalar!.isNotEmpty) {
              return RefreshIndicator(
                onRefresh: _konusmalarimNesnesiniYenile,
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    var oankiKonusma = tumKonusmalar[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          //rootNavigator false olduğunda Konusma sayfasına gittiğinde
                          //alttaki bottomNavi kontrolleri göstermeye devam eder.
                          //Konusma sayfasında onun görünmesini istemedik
                          MaterialPageRoute(
                            builder: (context) =>
                                ChangeNotifierProvider<ChatViewModel>(
                              create: (context) => ChatViewModel(
                                  currentUser: _viewModel.user!,
                                  sohbetEdilenUser: MyUser.idVeResim(
                                      userID: oankiKonusma.kimle_konusuyor,
                                      profilURL:
                                          oankiKonusma.konusulanUserProfilURL)),
                              child: SohbetPage(),
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(oankiKonusma.son_yollanan_mesaj),
                        subtitle: Text(oankiKonusma.konusulanUserName +
                            '  ' +
                            oankiKonusma.gecenZamanFarki),
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.withAlpha(40),
                          backgroundImage:
                              NetworkImage(oankiKonusma.konusulanUserProfilURL),
                        ),
                      ),
                    );
                  },
                  itemCount: tumKonusmalar.length,
                ),
              );
            } else {
              return RefreshIndicator(
                onRefresh: _konusmalarimNesnesiniYenile,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat,
                            color: Theme.of(context).primaryColor,
                            size: 120,
                          ),
                          Text(
                            'Henüz Konuşma Yok',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 36),
                          ),
                        ],
                      ),
                    ),
                    height: MediaQuery.of(context).size.height - 150,
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _konusmalarimNesnesiniYenile() async {
    setState(() {});
    await Future.delayed(Duration(seconds: 1));
  }
}
