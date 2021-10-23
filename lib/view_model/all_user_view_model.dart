import 'package:flutter/material.dart';
import 'package:flutter_lovers/locator.dart';
import 'package:flutter_lovers/models/user_model.dart';
import 'package:flutter_lovers/repository/user_repository.dart';

enum AllUserViewState { Idle, Loaded, Busy }

class AllUserViewModel with ChangeNotifier {
  late AllUserViewState _state = AllUserViewState.Idle;
  List<MyUser>? _tumKullanicilar;
  MyUser? _enSonGetirilenUser;
  static const sayfaBasinaGonderiSaiyisi = 10;
  bool _hasMore = true;
  bool get hasMoreLoading => _hasMore;
  final UserRepository _userRepository = locator<UserRepository>();

  List<MyUser>? get kullanicilarListesi => _tumKullanicilar;

  AllUserViewState get state => _state;

  set state(AllUserViewState value) {
    _state = value;
    notifyListeners();
  }

  AllUserViewModel() {
    _tumKullanicilar = [];
    _enSonGetirilenUser = null;
    getUserWithpagination(_enSonGetirilenUser, false);
  }
  getUserWithpagination(
      MyUser? enSonGetirilenUser, bool yeniElemanlarGetiriliyor) async {
    if (_tumKullanicilar!.length > 0) {
      _enSonGetirilenUser = _tumKullanicilar!.last;
      debugPrint(
          'en son getirilen user name : ' + _enSonGetirilenUser!.userName!);
    }
    if (yeniElemanlarGetiriliyor) {
    } else {
      state = AllUserViewState.Busy;
    }

    var yeniListe = await _userRepository.getUserWithPagination(
        _enSonGetirilenUser, sayfaBasinaGonderiSaiyisi);

    if (yeniListe.length < sayfaBasinaGonderiSaiyisi) {
      _hasMore = false;
    }

    yeniListe.forEach((usr) {
      debugPrint('getirilen user name : ' + usr.userName!);
    });

    _tumKullanicilar!.addAll(yeniListe);
    state = AllUserViewState.Loaded;
  }

  Future<void> dahaFazlaUserGetir() async {
    debugPrint('daha fazla user getir tetiklendi - all-user-view-modeledyiz');
    if (_hasMore)
      getUserWithpagination(_enSonGetirilenUser, true);
    else
      debugPrint('daha fazla eleman yok o yüzden çağırılmıyor');
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> refresh() async {
    _hasMore = true;
    _enSonGetirilenUser = null;
    _tumKullanicilar = [];
    getUserWithpagination(_enSonGetirilenUser,
        true); // refresh yaparken circleindicator görünmesin diye true yaptık.
    //Normalde ilk açılışta false, yeni elemanlar istediğimizde true yapıyorduk. Bu şekilde de kullanabiliriz.
  }
}
