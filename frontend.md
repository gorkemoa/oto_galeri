# OTO GALERİ YÖNETİM SİSTEMİ – MOBİL UYGULAMA
# AI GELİŞTİRME PROMPT / TEKNİK DÖKÜMAN

Bu doküman, oto galeriler için geliştirilecek **mobil yönetim uygulamasının UI/UX ve fonksiyonel gereksinimlerini** tanımlar.  
Uygulama müşteriler için değil, **oto galeri sahibi ve çalışanlarının iç kullanımı için tasarlanacaktır.**

Amaç:  
Araç stok yönetimi, araç maliyet takibi, satış takibi ve kar/zarar analizini mobil üzerinden yönetmek.

---

# 1. HEDEF KULLANICI

- Oto galeri sahibi
- Galeri çalışanları

Sistem **BMW / Mercedes gibi büyük showroomlar için değil**,  
daha çok **2. el araç satan küçük ve orta ölçekli galeriler için tasarlanacaktır.**

---

# 2. PLATFORM

Mobil Uygulama

Önerilen teknoloji:

Flutter (iOS + Android)

---

# 3. UYGULAMA NAVİGASYONU

Uygulama **Bottom Navigation** yapısı ile çalışacaktır.

Tab sayısı: 5

- Ana Sayfa
- Araçlar
- Giderler
- Raporlar
- Profil

Navigation yapısı:

BottomNavigationBar

[ Ana Sayfa ] [ Araçlar ] [ Giderler ] [ Rapor ] [ Profil ]

---

# 4. ANA SAYFA (DASHBOARD)

Amaç:  
Galerinin durumunu tek bakışta göstermek.

## Header

Gösterilecek bilgiler:

- Kullanıcı adı
- Galeri adı
- Günün tarihi

Örnek:

Merhaba Görkem  
Fikret Auto Gallery  
6 Mart 2026

---

## Özet Kartları

4 adet istatistik kartı bulunacaktır.

Kartlar:

- Toplam Araç
- Stoktaki Araç
- Satılan Araç
- Toplam Kar

Örnek:

Toplam Araç: 34  
Stokta: 12  
Satıldı: 22  
Toplam Kar: 1.240.000₺

---

## Son Eklenen Araçlar

Liste şeklinde gösterilir.

Her kart:

- araç adı
- model yılı
- km
- alış fiyatı

Örnek:

BMW 320i  
2018 • 145000 KM  
Alış: 1.120.000₺

---

## Yaklaşan Sigorta / Muayene

Uyarı sistemi.

Örnek:

BMW 320i  
Sigorta bitmesine 12 gün

Tofaş Şahin  
Muayene bitmesine 5 gün

---

## Hızlı İşlem Butonları

+ Araç Ekle  
+ Masraf Ekle  
+ Araç Sat

---

# 5. ARAÇLAR SAYFASI

Galerideki tüm araçlar listelenir.

## Üst Alan

- Arama
- Filtre

Filtre seçenekleri:

- Marka
- Satıldı
- Stokta

---

## Araç Kart Tasarımı

Kart içeriği:

Araç adı  
Model yılı  
KM

Alış fiyatı  
Toplam masraf

Durum

Durum seçenekleri:

- STOKTA
- SATILDI

---

# 6. ARAÇ DETAY SAYFASI

Bu sayfa aracın tüm bilgilerini içerir.

Sayfa bölümleri:

---

## Araç Bilgileri

- Marka
- Model
- Yıl
- KM
- Yakıt
- Renk
- Plaka

---

## Alış Bilgileri

- Alış fiyatı
- Alış tarihi
- Ödeme yöntemi

Ödeme türleri:

- Nakit
- Çek
- Vadeli
- Vadesiz

---

## Araç Giderleri

Liste şeklinde gösterilir.

Gider türleri:

- Noter
- Servis
- Lastik
- Tamir
- Yakıt
- Yıkama
- Ekspertiz

Her gider:

- gider türü
- tutar
- tarih
- açıklama

---

## Sigorta / Kasko / Muayene

Alanlar:

- Trafik sigortası tarihi
- Kasko tarihi
- Muayene tarihi

Sistem **kalan gün sayısını hesaplayacaktır.**

---

## Araç Kullanım Bilgisi

- Galeride kalma süresi
- Yapılan KM
- Yakıt gideri

---

## Satış Bilgisi (Eğer araç satıldıysa)

- satış fiyatı
- ödeme yöntemi
- müşteri adı
- müşteri telefonu
- müşteri bakiyesi

---

## Kar / Zarar Hesabı

Formül:

Kar/Zarar = Satış Fiyatı - (Alış Fiyatı + Toplam Masraf)

Ekranda gösterilecek:

- Alış fiyatı
- Toplam gider
- Satış fiyatı
- Net kar veya zarar

---

# 7. ARAÇ EKLE SAYFASI

Form ekranı.

## Araç Bilgileri

- Marka
- Model
- Yıl
- KM
- Yakıt tipi
- Renk
- Plaka

---

## Alış Bilgileri

- alış fiyatı
- alış tarihi
- ödeme yöntemi

Seçenekler:

- Nakit
- Çek
- Vadeli

---

## Sigorta Bilgileri

- Sigorta tarihi
- Kasko tarihi
- Muayene tarihi

---

Buton:

Araç Kaydet

---

# 8. MASRAF EKLE SAYFASI

Önce araç seçilir.

Araç seç  
BMW 320i

---

Masraf türü:

- Noter
- Servis
- Lastik
- Yakıt
- Tamir
- Temizlik

---

Alanlar:

- Tutar
- Tarih
- Açıklama

---

# 9. ARAÇ SATIŞ SAYFASI

Araç satıldığında doldurulur.

Alanlar:

- Satış fiyatı
- Ödeme yöntemi
- Müşteri adı
- Telefon
- Müşteri bakiyesi

---

# 10. GİDERLER SAYFASI

Tüm giderlerin listesi.

Örnek:

BMW 320i  
Lastik  
12.000₺

Tofaş Şahin  
Servis  
3.200₺

Filtreler:

- araç
- tarih
- masraf türü

---

# 11. RAPORLAR SAYFASI

Grafik ekranı.

Gösterilecek raporlar:

- aylık kar grafiği
- toplam gider dağılımı
- en karlı araçlar
- en çok masraf yapılan araçlar

---

# 12. PROFİL / AYARLAR

- Galeri adı
- Telefon
- Adres
- Kullanıcı yönetimi
- Çıkış yap

---

# 13. UI / UX TASARIM KURALLARI

Tasarım stili:

modern CRM arayüzü  
minimal  
kart tabanlı

---

## Renk Paleti

Primary

#111111

Accent

#2E7DFF

Background

#F5F6F8

---

## Font

Inter  
veya  
SF Pro

---

## Icon Set

Material Symbols

---

# 14. MOBİL UYGULAMA SAYFA LİSTESİ

Toplam ekran sayısı:

Login  
Dashboard  
Araçlar  
Araç Detay  
Araç Ekle  
Masraf Ekle  
Araç Satış  
Giderler  
Raporlar  
Profil

Toplam: 10 ekran

---

