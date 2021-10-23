import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_lovers/locator.dart';
import 'package:flutter_lovers/models/mesaj.dart';
import 'package:flutter_lovers/models/user_model.dart';
import 'package:flutter_lovers/repository/user_repository.dart';

enum ChatViewState { Idle, Loaded, Busy }

class ChatViewModel with ChangeNotifier {
  List<Mesaj>? _tumMesajlar;
  Mesaj? _enSonGetirilenMesaj;
  Mesaj? _listeyeIlkEklenenMesaj;
  ChatViewState _state = ChatViewState.Idle;
  static const sayfaBasinaGonderiSayisi = 10;
  UserRepository _userRepository = locator<UserRepository>();
  final MyUser currentUser;
  final MyUser sohbetEdilenUser;
  bool _hasMore = true;
  bool _yeniMesajDinleListener = false;

  bool get hasMoreLoading => _hasMore;

  late StreamSubscription
      _streamSubscription; // Bir konuşmaya girip, geri çıkıp, tekrar girip mesaj göndermeye çalışınca
  // console'da hata veriyor. Çünkü chat-view-model dispose oluyor. Onun için böyle bir subscription oluşturup
  //aşağıda biyerde atamasını yapıyoruz. Daha sonra konuşmadan çıkınca dispose fonsiyonu tetiklendiği için o fonksiyonda
  //subscription işlemini iptal ediyoruz.Bu şekilde hata vermiyor.

  ChatViewModel({required this.currentUser, required this.sohbetEdilenUser}) {
    _tumMesajlar = [];
    getMessageWithPagination(false);
  }
  @override
  dispose() {
    debugPrint('chat-view-model dispose edildi');
    _streamSubscription.cancel();
    super.dispose();
  }

  List<Mesaj>? get mesajlarListesi => _tumMesajlar;

  ChatViewState get state => _state;

  set state(ChatViewState value) {
    _state = value;
    notifyListeners();
  }

  Future<bool> saveMessage(Mesaj kaydedilecekMesaj) async {
    return await _userRepository.saveMessage(kaydedilecekMesaj);
  }

  void getMessageWithPagination(bool yeniMesajlarGetiriliyor) async {
    if (!yeniMesajlarGetiriliyor) {
      state = ChatViewState.Busy;
    }
    if (_tumMesajlar!.isNotEmpty) {
      _enSonGetirilenMesaj = _tumMesajlar!
          .last; // en son getirilen mesaj ekranın en üstündeki mesaj. Çünkü mesajları getirken
      // reverse yaptık.
    }

    var getirilenMesajlar = await _userRepository.getMessageWithPagination(
        currentUser.userID,
        sohbetEdilenUser.userID,
        _enSonGetirilenMesaj,
        sayfaBasinaGonderiSayisi);
    if (getirilenMesajlar.length < sayfaBasinaGonderiSayisi) {
      _hasMore = false;
    }

    for (var msj in getirilenMesajlar) {
      debugPrint('getirilen mesajlar : ' + msj.mesaj);
    }

    _tumMesajlar!.addAll(getirilenMesajlar);
    if (_tumMesajlar!.length > 0) {
      _listeyeIlkEklenenMesaj = _tumMesajlar!
          .first; // Aşağıda yaptığımız date kontrolünün alternatifi olarak yaptık bunu.
      debugPrint(
          'Listeye eklnen ilk mesaj : ' + _listeyeIlkEklenenMesaj!.mesaj);
    }
    state = ChatViewState.Loaded;
    if (_yeniMesajDinleListener == false) {
      _yeniMesajDinleListener = true;
      debugPrint('Listener yok o yüzden atanacak');
      yeniMesajListenerAta();
    }
  }

  Future<void> dahaFazlaMesajGetir() async {
    debugPrint('daha fazla mesaj getir tetiklendi - all-user-view-modeledyiz');
    if (_hasMore)
      getMessageWithPagination(true);
    else
      debugPrint('daha fazla mesaj yok o yüzden çağırılmıyor');
    await Future.delayed(Duration(seconds: 1));
  }

  void yeniMesajListenerAta() {
    debugPrint('Yeni mesajlar için listener atandı');
    _streamSubscription = _userRepository
        .getMessages(currentUser.userID, sohbetEdilenUser.userID)
        .listen((anlikData) {
      //mesajla gelen değeri dinliyoruz. Biz mesaj gönderdiğimizde ya da bize mesaj gönderildiğinde
      //henüz onu sayfada göremiyoruz sadece gelen giden mesaj var mı diye dinliyoruz. Varsa o mesajı
      //mesaj listesine ekleyip sayfada göstereceğiz.
      if (anlikData.isNotEmpty) {
        debugPrint('Listener tetiklendi ve son getirilen veri : ' +
            anlikData[0].toString());

        if (anlikData[0].date != null) {
          if (_listeyeIlkEklenenMesaj == null) {
            _tumMesajlar!.insert(0, anlikData[0]);
          } else if (_listeyeIlkEklenenMesaj!.date!.millisecondsSinceEpoch !=
              anlikData[0].date!.millisecondsSinceEpoch)
            _tumMesajlar!.insert(
                0,
                anlikData[
                    0]); //insert ilk değerinin 0 olmasının nedeni, bizim gelen mesajları reverse olarak almamız
        }
        // Yukardaki date kontrolünü yapmazsak bir sıkıntı
        //oluşuyor ve aynı mesajı 2 defa gönderiyor ve 2 defa alıcı alıyor. Bunun nedeni yine firebase'e yazılan timestamp değeri.
        //Mesajı gönderdiğimiz anda mesaj saveMessage ile firebase'e kaydediliyor. Mesajın içinde FieldValue timestamp de var.
        //Timestampin firebase'de oluşturulması milisaniyede olsa gecikiyor(Bunu daha önce de bi yerde yaşadık). Gecikmeden
        //sonra timestamp oluşuyor firebase'de ve bu bizim taraftaki stream'de(_userRepository.getMessages bir stream) güncelleme
        //olarak algılanıp( stream verisi anlık okunur ) aynı document verisini tekrar okuyor ve bi daha ekrana yazıyor.
        //böyle bir durum yüzünden İLK gönderdiğimiz mesajın date değeri null olarak oluşuyor. date oluştuğu anda tekrar
        //tekrar veriyi gönderdiği için İKİNCİ mesajın date değeri var.
        //Bu yüzden insert işlemi yapmadan önce streamden gelen verinin date kontrolünü yapıp ondan sonra insert yapıyoruz.
        state = ChatViewState.Loaded;
      }
    });
  }
}
