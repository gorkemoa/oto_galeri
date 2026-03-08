DEĞİŞTİRİLEMEZ KURALLAR (TARTIŞMASIZ)

1.1 Dummy Veri Kullanımı (GEÇİCİ)

Proje başlangıcında backend API henüz hazır olmadığı için geliştirme sürecinde
GEÇİCİ olarak dummy / mock veri kullanılmasına izin verilir.

Ancak aşağıdaki kurallar zorunludur:

Dummy veri yalnızca UI geliştirme ve ekran akışlarını test etmek için kullanılır.

Dummy veri:

• Service katmanında üretilir  
• Model yapısına birebir uygun olur  
• Gerçek API response formatını taklit eder  

View içinde:

Hardcoded veri yazmak YASAK.

Örnek YASAK:

Text("BMW 320i")
Text("120.000 km")
Text("1.200.000₺")

Dummy veri yalnızca:

Service → Model → ViewModel → View

akışı üzerinden gelir.

API hazır olduğunda:

Tüm dummy veri kaldırılır ve gerçek ASP.NET API endpointleri entegre edilir.

Dummy veri kalıcı çözüm değildir.

Production build içinde dummy veri bulunamaz.

---

1.2 API Response Eksiksiz Kullanılacak

Backend API hazır olduğunda:

Backend’in döndürdüğü tüm alanlar modele karşılık gelmek zorundadır.

Örnek response alanları:

data  
meta  
pagination  
status  
message  
errors  

vb.

Bu alanlar:

• atlanamaz  
• yok sayılmaz  
• “lazım değil” denilerek silinemez  

Gerekirse nullable olarak modele eklenir.

---

1.3 Kurumsal Disiplin

AI aşağıdakileri yapamaz:

• Feature ekleyemez  
• Field uyduramaz  
• Backend’de olmayan veriyi UI’da varmış gibi gösteremez  
• Onaysız mimari değiştiremez  

Emin değilse:

SORAR.

---

ZORUNLU MİMARİ

Bu proje sadece şu mimari ile geliştirilir:

Models → Views → ViewModels → Services → Core

Aşağıdaki mimariler önerilemez:

• Clean Architecture  
• Bloc-first mimari  
• Redux  
• MVC  
• farklı state management mimarileri

---

ZORUNLU KLASÖR YAPISI

lib/

app/  
app_constants.dart  
api_constants.dart  
app_theme.dart  

core/

network/  
api_client.dart  
api_result.dart  
api_exception.dart  

responsive/  
size_config.dart  
size_tokens.dart  

utils/  
logger.dart  
validators.dart  

models/

services/

viewmodels/

views/

home/  
home_view.dart  

widgets/

job_detail/  
job_detail_view.dart  

widgets/

profile/  
profile_view.dart  

widgets/

---

GLOBAL WIDGETS KLASÖRÜ YASAK

Aşağıdaki klasörler kesinlikle kullanılmaz:

core/widgets/  
common/widgets/  
shared/widgets/

Her ekranın widgetları kendi klasöründe bulunur:

views/<screen>/widgets/

---

RESPONSIVE / ÖLÇÜ SİSTEMİ (ZORUNLU)

4.1 Sabit pixel kullanmak YASAK

View içinde aşağıdakiler yazılamaz:

padding: 16  
fontSize: 14  
height: 52  
radius: 12  

Bu tarz sabit değerler yasaktır.

---

4.2 Token Bazlı Ölçü Sistemi

Tüm ölçüler aşağıdaki dosyalardan alınır:

core/responsive/size_config.dart  
core/responsive/size_tokens.dart  

Buradan gelen değerler kullanılır:

• Padding  
• Margin  
• Radius  
• Font size  
• Icon size  
• Container ölçüleri  

---

4.3 Theme Yönetimi

Renk, tipografi ve spacing yalnızca şu dosyalardan yönetilir:

app/app_theme.dart  
core/responsive/size_tokens.dart  

View içinde inline stil minimum tutulur.

---

4.4 Büyük Ekran Koruması (ZORUNLU)

Referans cihaz:

iPhone 13

Width: 390  
Height: 844

Bu referansın üstünde UI büyümesi engellenir.

Scaling Cap uygulanır.

---

Font Scaling Protection

main.dart içinde zorunlu ayar:

MediaQuery(
  textScaler: TextScaler.noScaling
)

---

MVVM AKIŞI

View → ViewModel → Service → ApiClient → HTTP

---

5.1 View

View yalnızca:

• UI render eder  
• ViewModel state dinler  
• event tetikler  

View içinde aşağıdakiler YASAK:

• API çağrısı  
• JSON parse  
• business logic  

---

5.2 ViewModel

Her ViewModel yalnızca bir ekrana hizmet eder.

Mega ViewModel YASAK.

Standart state:

bool isLoading  
String? errorMessage  
T? data veya List<T>

Pagination varsa:

page  
hasMore  
isLoadingMore

Zorunlu metodlar:

init()  
refresh()  
loadMore()  
onRetry()

---

5.3 Service

Service görevleri:

• Endpoint’e gider  
• Response’u modele map eder  
• ViewModel’e model döndürür  

Service içinde:

Endpoint string yazmak YASAK.

ApiConstants kullanılmalıdır.

Ham HTTP response döndürmek YASAK.

---

5.4 Model

Her model şu metodları içerir:

fromJson(Map<String, dynamic>)  
toJson()

Backend’den gelen unused alanlar bile modelde bulunur.

Silinmez.

Nullable olabilir.

UI state alanları modele yazılmaz.

Örnek YASAK:

isSelected  
isExpanded

Bu alanlar ViewModel state’idir.

---

API STANDARTLARI

6.1 Authorization Header

Tüm isteklerde:

Accept: application/json

header bulunmalıdır.

---

6.2 Endpoint Yönetimi

Service veya ViewModel içinde endpoint string yazmak YASAK.

Örnek YASAK:

"/v1/jobs"

Tüm endpointler:

app/api_constants.dart

dosyasında tanımlanır.

---

NETWORK STANDARDI

7.1 ApiClient

ApiClient tek noktadan yönetir:

• baseUrl  
• ortak header  
• timeout  
• error handling  
• logging  

---

7.2 ApiResult

Service dönüş tipi:

Success(data)  
Failure(error)

---

7.3 ApiException & Hata Yönetimi

Hata tipleri normalize edilir:

• network  
• timeout  
• 401  
• 403  
• 404  
• 500  
• parse error

Validation Error Yönetimi:

Backend’den gelen "errors" objesi içindeki mesajlar
kullanıcıya gösterilecek ana mesaj olarak kullanılmalıdır.

Örnek:

Input:

{
  "message": "Validation failed",
  "errors": {
    "timezone": ["The timezone field must be a valid timezone."]
  }
}

Output (UI):

The timezone field must be a valid timezone.

---

LOGLAMA STANDARTI

Tüm API istekleri ve cevapları loglanır.

Logger dosyası:

core/utils/logger.dart

Print kullanımı YASAK.

Log seviyeleri:

INFO  
ERROR  
WARNING  
DEBUG  
REQUEST  
RESPONSE

---

WIDGET TEKRAR KULLANIM KURALI

Bir widget 2 veya daha fazla ekranda kullanılacaksa:

AI önce sorar.

Onay alınırsa ortak klasöre taşınır:

core/ui_components/

---

DOSYA İSİMLENDİRME

Dosyalar:

snake_case.dart

Sınıflar:

PascalCase

Örnek:

home_view.dart  
home_view_model.dart  
vehicle_service.dart  
vehicle_detail_response.dart

---

TASARIM REFERANSI

Uygulama tasarım dili:

dryfix.com.tr

Renk, tipografi ve spacing sadece:

AppTheme  
SizeTokens

üzerinden yönetilir.

Keyfi UI/UX kararı YASAK.

---

AI İÇİN SON TALİMAT

AI:

• Bu dokümana %100 uyar  
• Dummy veriyi yalnızca geçici kullanır  
• API hazır olduğunda dummy kaldırır  
• Kafasına göre alan üretmez  
• Feature eklemez  
• Widgetları sadece ilgili ekran klasörüne koyar  
• Endpoint string yazmaz  
• Sadece ApiConstants kullanır  
• API response alanlarını eksiksiz modeller  

Emin olmadığı her noktada:

SORAR.