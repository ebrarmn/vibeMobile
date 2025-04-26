# Üniversite Kulüpleri Yönetim Platformu 🎓

Bu platform, üniversite kulüplerinin etkinlik yönetimini dijitalleştirmek, üyelerle iletişimi artırmak ve tüm organizasyon süreçlerini tek bir platformda toplamak amacıyla geliştirilmiştir.

## 🚀 Özellikler

- Kulüp yönetimi ve üyelik sistemi
- Etkinlik oluşturma ve yönetimi
- Duyuru paylaşımı
- Mesajlaşma sistemi
- Kullanıcı profil yönetimi
- Etkinlik katılım takibi

## 🛠 Teknolojiler

### Web Uygulaması
- Frontend: React.js
- Backend: Node.js, Express.js
- Veritabanı: PostgreSQL

### Mobil Uygulama
- React Native
- Expo

## 💻 Kurulum

### Ön Gereksinimler
- Node.js (v22.14.0 veya üzeri)
- PostgreSQL
- npm veya yarn

### Backend Kurulumu
```bash
cd web/server
npm install
# .env dosyasını oluşturun ve gerekli değişkenleri ayarlayın
npm start
```

### Frontend Kurulumu
```bash
cd web/client
npm install
# .env dosyasını oluşturun ve gerekli değişkenleri ayarlayın
npm start
```

### Mobil Uygulama Kurulumu
```bash
cd mobile
npm install
npm start
```

## 🌐 Ortam Değişkenleri

### Backend (.env)
```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=university_clubs
DB_USER=postgres
DB_PASSWORD=your_password
PORT=5001
JWT_SECRET=your_jwt_secret
```

### Frontend (.env)
```
REACT_APP_API_URL=http://localhost:5001/api
```

## 📱 Portlar

- Backend: 5001
- Frontend: 3000 (veya 3005)
- Mobil Expo: 19000

## 👥 Kullanım

1. Sisteme kayıt olun veya giriş yapın
2. Kulüpleri keşfedin ve üye olun
3. Etkinliklere katılın
4. Duyuruları takip edin
5. Diğer üyelerle iletişime geçin

## 🔒 Güvenlik

- JWT tabanlı kimlik doğrulama
- Şifrelenmiş kullanıcı bilgileri
- Rol tabanlı yetkilendirme sistemi

## 🤝 Katkıda Bulunma

1. Bu repository'yi fork edin
2. Feature branch'i oluşturun (`git checkout -b feature/AmazingFeature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Branch'inizi push edin (`git push origin feature/AmazingFeature`)
5. Pull Request oluşturun

## 📝 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Daha fazla bilgi için `LICENSE` dosyasına bakın.

## 📞 İletişim

Ebrar Mangan - [@ebrarmn](https://github.com/ebrarmn)

<<<<<<< HEAD
Proje Linki: [https://github.com/ebrarmn/VibeWebV.1.0](https://github.com/ebrarmn/vibeMobile) 
=======
Proje Linki: [https://github.com/ebrarmn/VibeWebV.1.0](https://github.com/ebrarmn/vibeMobile)
>>>>>>> bb7b02ba90ac627ce7aafa46eaab6a2fd69c4525
