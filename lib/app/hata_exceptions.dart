class Hatalar {
  static String goster(String hataKodu) {
    switch (hataKodu) {
      case 'email-already-in-use':
        return 'Bu mail adresi zaten kullanımda, lütfen farklı bir mail kullanınız';
      case 'user-not-found':
        return 'Bu kullanıcı sistemde bulunmamaktadır. Lütfen önce kayıt olunuz';
      case 'account-exists-with-different-credential':
        return 'Facebook hesabınızdaki mail adresi daha önce Gmail veya Mail yöntemi ile sisteme kaydedilmiş. Lütfen bu mail ile giriş yapınız.';
      default:
        return 'Kontrol ettiğimiz hatalar dışında bir hata oluştu - hata_exception.dart dosyasından bak';
    }
  }
}
