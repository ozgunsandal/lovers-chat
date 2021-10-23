import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_lovers/app/sohbet.dart';
import 'package:flutter_lovers/models/user_model.dart';
import 'package:flutter_lovers/view_model/all_user_view_model.dart';
import 'package:flutter_lovers/view_model/chat_view_model.dart';
import 'package:flutter_lovers/view_model/view_model.dart';
import 'package:provider/provider.dart';

class KullanicilarPage extends StatefulWidget {
  const KullanicilarPage({Key? key}) : super(key: key);

  @override
  State<KullanicilarPage> createState() => _KullanicilarPageState();
}

class _KullanicilarPageState extends State<KullanicilarPage> {
  bool _isLoading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      //getUser();
    }); // getUser metodunun içindeki viewmodelde context kullandığımız için aşağıdaki build fonksiyonu çağırılmadan
    //(yani context oluşmadan) getUser metodunu çağıramayız hata verir. Fakat çağırmamız lazım ihtiyacımız var.
    //Bunun için SchedulerBinding kullandık. Aşağıdaki build metodu çağırıldığı ANDA(daha başında) bu method devreye giriyor
    //ve getUser metodu çağırılıyor. Kullanıcılar sistemini all-user-view-modele çevirdik sonradan, oyuzden
    //artık schedule a gerek kalmadı

    _scrollController.addListener(_listeScrollListener);
  }

  @override
  Widget build(BuildContext context) {
    final _tumKullanicilarViewModel = Provider.of<AllUserViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Kullanıcılar'),
      ),
      body: Consumer<AllUserViewModel>(
        builder: (context, model, child) {
          if (model.state == AllUserViewState.Busy) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (model.state == AllUserViewState.Loaded) {
            return RefreshIndicator(
              onRefresh: model.refresh,
              child: ListView.builder(
                controller: _scrollController,
                itemBuilder: (context, index) {
                  if (model.kullanicilarListesi!.isEmpty) {
                    return _kullaniciYokUi();
                  } else if (model.hasMoreLoading &&
                      index == model.kullanicilarListesi!.length) {
                    return _yeniElemanlarYukleniyorIndicator();
                  } else {
                    return _userListeElemaniOlustur(index);
                  }
                },
                itemCount: model.hasMoreLoading
                    ? model.kullanicilarListesi!.length + 1
                    : model.kullanicilarListesi!.length,
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget _kullaniciYokUi() {
    final _tumKullanicilarViewModel = Provider.of<AllUserViewModel>(context);
    return RefreshIndicator(
      onRefresh: _tumKullanicilarViewModel.refresh,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.supervised_user_circle,
                  color: Theme.of(context).primaryColor,
                  size: 120,
                ),
                Text(
                  'Henüz Başka Kullanıcı Yok',
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

  Widget _userListeElemaniOlustur(int index) {
    ViewModel _viewModel = Provider.of<ViewModel>(context, listen: false);
    AllUserViewModel _tumKullanicilarViewModel =
        Provider.of<AllUserViewModel>(context, listen: false);
    var _oankiUser = _tumKullanicilarViewModel.kullanicilarListesi![index];
    if (_oankiUser.userID == _viewModel.user!.userID) {
      return Container(); // Listede kendimizi görmememiz lazım. O yüzden boş bir container döndürüyoruz.
    }
    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider<ChatViewModel>(
              create: (context) => ChatViewModel(
                  currentUser: _viewModel.user!, sohbetEdilenUser: _oankiUser),
              child: SohbetPage(),
            ),
          ),
        );
      },
      child: Card(
        child: ListTile(
          title: Text(_oankiUser.userName!),
          subtitle: Text(_oankiUser.email!),
          leading: CircleAvatar(
            backgroundColor: Colors.grey.withAlpha(40),
            backgroundImage: NetworkImage(_oankiUser.profilURL!),
          ),
        ),
      ),
    );
  }

  _yeniElemanlarYukleniyorIndicator() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> dahaFazlaKullaniciGetir() async {
    if (_isLoading == false) {
      _isLoading = true;
      AllUserViewModel _tumKullanicilarViewModel =
          Provider.of<AllUserViewModel>(context, listen: false);
      await _tumKullanicilarViewModel.dahaFazlaUserGetir();
      _isLoading = false;
    }
  }

  void _listeScrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      debugPrint('listenin altındayız');
      dahaFazlaKullaniciGetir();
    }
  }
}
