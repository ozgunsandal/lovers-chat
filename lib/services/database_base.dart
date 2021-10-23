import 'package:flutter_lovers/models/konusma.dart';
import 'package:flutter_lovers/models/mesaj.dart';
import 'package:flutter_lovers/models/user_model.dart';

abstract class DBBase {
  Future<bool> saveUser(MyUser user);
  Future<MyUser> readUser(String userID);
  Future<bool> updateUsername(String userID, String yeniUserName);
  Future<bool> updateProfilFoto(String userID, String fileURL);
  Future<List<MyUser>> getUserWithPagination(
      MyUser? enSonGetirilenUser, int getirilecekElemanSayisi);
  Future<List<Konusma>> getAllConversations(String userID);
  Stream<List<Mesaj>> getMessages(
      String currentUserID, String sohbetEdilenUserID);
  Future<bool> saveMessage(Mesaj kaydedilecekMesaj);
  Future<DateTime> saatiGoster(String userID);
}
