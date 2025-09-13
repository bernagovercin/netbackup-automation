# NetBackup API Otomasyon Sistemi

## NetBackup yedekleme sistemleri için Python + Tkinter tabanlı GUI otomasyon aracı.  
## Katmanlı mimari (Layered Architecture) prensipleriyle geliştirilmiştir.
## 📊 Mimarisi
![Mimari](https://github.com/bernagovercin/netbackup-otomasyon/blob/master/assets/app-gorsell.jpg?raw=true)



### 🚀 Özellikler
#### ✅ Backup job’larını takip etme ve yönetme  
#### ✅ API anahtarı oluşturma ve listeleme  
#### ✅ Gerçek zamanlı dashboard ve istatistikler  
#### ✅ SQLite veritabanı entegrasyonu  
#### ✅ Otomatik güncelleme ve raporlama  
#### ✅ Kullanıcı dostu Tkinter arayüzü  

### ⚙️ Kurulum

#### Depoyu klonlayın:
##### git clone https://github.com/kullaniciadi/netbackup-otomasyon.git  
##### cd netbackup-otomasyon  

#### Gerekli bağımlılıkları yükleyin:
##### pip install -r requirements.txt  

#### Uygulamayı çalıştırın:
##### python main.py  

### 🔧 Yapılandırma
#### Uygulama config/nb_config.json dosyasından yapılandırılır:
##### {
######   "nb_server": "https://win-t89q8gl89g1:1556",
######   "username": "nbwebsvc",
######   "password": "********.master",
######   "update_interval": 30,
######   "api_timeout": 15,
######   "retry_attempts": 3
##### }

#### update_interval: Dashboard yenileme aralığı (saniye)  
#### api_timeout: API çağrıları için zaman aşımı (saniye)  
#### retry_attempts: API işlemlerinde yeniden deneme sayısı  

#### ⚠️ Güvenlik Uyarısı: Parolaları depoya commit etmeyin.  
#### Üretimde .env, Windows Credential Manager veya kasa hizmeti (Vault) kullanmanız önerilir.  

### 📊 Kullanım
#### Uygulama açıldığında ana pencereden şu işlemleri yapabilirsiniz:  

#### Login ve Token Alma: NetBackup API’ye bağlanıp token alır.  
#### API Key Oluşturma: 30 gün geçerli API anahtarı üretir.  
#### Job Yönetimi: Tüm backup job’larını SQLite veritabanına kaydeder ve görüntüler.  
#### İstatistikler: Çalışan/Başarılı/Uyarı/Başarısız job sayılarını ve toplamı gösterir.  
#### Raporlama: Detaylı backup raporları ve son başarısız işlerin listesi.  
#### Config Düzenleme: nb_config.json dosyasını düzenlemeniz için notepad ile açar.  

#### Veritabanı varsayılanı netbackup.db olup, ilgili batch dosyaları ve veri klasörleri çalışma dizininizde bulunmalıdır.  

### 🏗️ Teknik Mimari (Layered Architecture)

#### 1) Presentation (GUI):
##### Tkinter tabanlı arayüz, olay yönetimi, kullanıcı etkileşimi  
##### gui/app.py, gui/components/*  

#### 2) Business (Services):
##### İş kuralları, veri işleme, API entegrasyonları  
##### services/job_service.py  

#### 3) Data Access (Repository):
##### SQLite üzerinden CRUD, sorgular, rapor veri temini  
##### data/repository.py  

#### 4) Domain (Models):
##### Veri modelleri, entity/DTO’lar, temel kurallar  
##### models/job.py  

#### 5) Utils:
##### Ortak yardımcı fonksiyonlar (dosya işlemleri, doğrulama vb.)  
##### utils/file_utils.py, utils/validation.py  

#### Bu ayrım sayesinde test edilebilirlik, bakım kolaylığı ve genişletilebilirlik artar.



















