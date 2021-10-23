import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lovers/models/mesaj.dart';
import 'package:flutter_lovers/models/user_model.dart';
import 'package:flutter_lovers/view_model/chat_view_model.dart';
import 'package:flutter_lovers/view_model/view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SohbetPage extends StatefulWidget {
  const SohbetPage({Key? key}) : super(key: key);

  @override
  _SohbetPageState createState() => _SohbetPageState();
}

class _SohbetPageState extends State<SohbetPage> {
  final _mesajController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    _scrollController.addListener(_scrolllistener);
  }

  @override
  Widget build(BuildContext context) {
    ChatViewModel _chatModel = Provider.of<ChatViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Sohbet'),
      ),
      body: _chatModel.state == ChatViewState.Busy
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Column(
                children: [
                  _buildMesajListesi(),
                  _buildYeniMesajGir(),
                ],
              ),
            ),
    );
  }

  Widget _buildMesajListesi() {
    return Consumer<ChatViewModel>(
      builder: (context, chatModel, child) {
        return Expanded(
          child: ListView.builder(
            reverse: true,
            controller: _scrollController,
            itemBuilder: (context, index) {
              if (chatModel.hasMoreLoading &&
                  chatModel.mesajlarListesi!.length == index) {
                return _yeniElemanlarYukleniyorIndicator();
              } else {
                return _konusmaBalonuOlustur(chatModel.mesajlarListesi![index]);
              }
            },
            itemCount: chatModel.hasMoreLoading
                ? chatModel.mesajlarListesi!.length + 1
                : chatModel.mesajlarListesi!.length,
          ),
        );
      },
    );
  }

  Widget _buildYeniMesajGir() {
    final _chatModel = Provider.of<ChatViewModel>(context);
    return Container(
      padding: EdgeInsets.only(bottom: 8, left: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _mesajController,
              cursorColor: Colors.blueGrey,
              style: TextStyle(fontSize: 16, color: Colors.black),
              decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'Mesajınızı buraya yazınız',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  )),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: FloatingActionButton(
              elevation: 0,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.navigation,
                size: 35,
                color: Colors.white,
              ),
              onPressed: () async {
                if (_mesajController.text.trim().length > 0) {
                  Mesaj _kaydedilecekMesaj = Mesaj(
                    kimden: _chatModel.currentUser.userID,
                    kime: _chatModel.sohbetEdilenUser.userID,
                    bendenMi: true,
                    mesaj: _mesajController.text,
                  );
                  var sonuc = await _chatModel.saveMessage(_kaydedilecekMesaj);
                  if (sonuc) {
                    _mesajController.clear();

                    _scrollController.animateTo(0,
                        duration: Duration(milliseconds: 100),
                        curve: Curves.easeOut);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _konusmaBalonuOlustur(Mesaj mesaj) {
    Color _gelenMesajRenk = Colors.blue;
    Color _gidenMesajRenk = Theme.of(context).primaryColor;
    final _chatModel = Provider.of<ChatViewModel>(context);

    String _saatDakikaDegeri = '';
    // Saat dakika gösterme işine dikkat etmezsen biraz sıkıntılı.
    //Çünkü mesajı gönder butonuna bastıktan sonra mesaj firebase e yazılması için gönderiliyor.
    //mesajın içindeki 'date' değeri diğer kısımlardan çok az farkla da olsa geç yazılıyor
    //Biz mesajı gönderir göndermez ekranda göstermek için stream builder ile okumaya çalıştığımızda
    //firebase'deki 'date' değeri daha oluşturulmamış oluyor. O yüzden date format işini
    // try catch içinde yapıyoruz ki oluşan hata programın çalışmasını engellemesin çalışmaya devam etsin.
    try {
      _saatDakikaDegeri = _saatDakikaGoster(mesaj.date ?? Timestamp(1, 1));
    } catch (e) {
      debugPrint('hata var!');
    }

    bool _benimMesajimMi = mesaj.bendenMi;
    if (_benimMesajimMi) {
      return Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: _gidenMesajRenk,
                    ),
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(4),
                    child: Text(
                      mesaj.mesaj,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Text(_saatDakikaDegeri),
              ],
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.withAlpha(40),
                  backgroundImage:
                      NetworkImage(_chatModel.sohbetEdilenUser.profilURL!),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: _gelenMesajRenk,
                    ),
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(4),
                    child: Text(mesaj.mesaj),
                  ),
                ),
                Text(_saatDakikaDegeri),
              ],
            )
          ],
        ),
      );
    }
  }

  String _saatDakikaGoster(Timestamp? date) {
    var _formatter = DateFormat.Hm();
    var _formatlanmisSaat = _formatter.format(date!.toDate());
    return _formatlanmisSaat;
  }

  void _scrolllistener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      eskiMesajlariGetir();
    }
  }

  void eskiMesajlariGetir() async {
    final _chatModel = Provider.of<ChatViewModel>(context, listen: false);
    if (_isLoading == false) {
      _isLoading = true;
      await _chatModel.dahaFazlaMesajGetir();
      _isLoading = false;
    }
  }

  _yeniElemanlarYukleniyorIndicator() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
