# Shipping Logistics Analysis 2023–2025

Proyek analisis data pengiriman logistik menggunakan Microsoft SQL Server dan Python, mencakup dokumentasi data cleaning, data preparation, exploratory data analysis, visualisasi, dan laporan hasil analisis.

## Tujuan Proyek

Mengevaluasi kinerja pengiriman, biaya logistik, dan pengalaman pelanggan berdasarkan tren bulanan, status pengiriman, carrier, jenis layanan, warehouse, rute, kota tujuan, serta driver.

## Isi Repositori

| Lokasi | Isi dan fungsi |
| --- | --- |
| [data/source/LogistikPengiriman.csv](data/source/LogistikPengiriman.csv) | Salinan file sumber yang dilampirkan; bukan bukti dataset mentah sebelum cleaning. |
| [data/processed/ShippingLogisticsCleaned.csv](data/processed/ShippingLogisticsCleaned.csv) | Dataset hasil cleaning yang dilampirkan. |
| [data/processed/TableAnalysis.csv](data/processed/TableAnalysis.csv) | Dataset ekspor untuk analisis. |
| [sql/01_TableCleaning.sql](sql/01_TableCleaning.sql) | Skrip T-SQL untuk pemeriksaan kualitas data, imputasi, deduplikasi, dan standardisasi. |
| [sql/02_TableAnalysis.sql](sql/02_TableAnalysis.sql) | Membuat salinan tabel cleaned menjadi tabel analysis; perhitungan analitis dilakukan dalam notebook. |
| [notebooks/Shipping_Logistics_Analysis.ipynb](notebooks/Shipping_Logistics_Analysis.ipynb) | Notebook asli `Analysis(5).ipynb`, beserta output tabel dan grafik yang tersimpan. |
| [reports/Laporan_Data_Cleaning_Shipping_Logistics.pdf](reports/Laporan_Data_Cleaning_Shipping_Logistics.pdf) | Dokumentasi cleaning dan preparation. |
| [reports/Laporan_Analisis_Data_Shipping_Logistics_2023_2025.pdf](reports/Laporan_Analisis_Data_Shipping_Logistics_2023_2025.pdf) | Laporan analisis pengiriman logistik. |
| [requirements.txt](requirements.txt) | Dependensi Python untuk menjalankan notebook. |

## Catatan Sumber Data

Ketiga CSV yang dilampirkan identik secara byte, masing-masing memiliki 6.000 baris data, 24 kolom, dan 6.000 OrderID unik. Ketiganya dipertahankan sesuai nama asal untuk menjaga keterlacakan. Folder `data/source` menunjukkan file sumber yang diterima, bukan jaminan kondisi data sebelum cleaning. Dataset mentah yang berbeda dari versi cleaned tidak tersedia dalam lampiran ini.

Analisis notebook menggunakan tabel `dbo.ShippingLogistics_Cleaned`. CSV yang disediakan belum memuat kolom turunan notebook seperti `TotalShippingCostIDR`, `DeliveredStatus`, `Route`, `CostPerKM`, `CostPerKG`, `DelayDays`, `Year`, dan `Month`; kolom tersebut dibuat ketika notebook dijalankan.

Delapan lampiran dipertahankan tanpa perubahan isi; hanya lokasi dan beberapa nama file disesuaikan. README, requirements, dan gitignore ditambahkan untuk dokumentasi dan pengelolaan proyek.

## Alur Pengerjaan

1. Pemeriksaan struktur, missing values, dan duplikasi menggunakan SQL Server.
2. Penanganan kategori tidak diketahui, imputasi median fuel surcharge, serta standardisasi kota.
3. Pembentukan tabel cleaned dan salinan tabel analysis.
4. Pemrosesan data dan pembuatan kolom analisis menggunakan pandas dan NumPy.
5. Agregasi KPI, perbandingan antarkelompok, visualisasi, dan korelasi Pearson.
6. Penyusunan laporan cleaning dan laporan analisis.

Skrip cleaning mempertahankan nilai NULL tertentu, misalnya waktu pengiriman untuk barang hilang dan rating yang tidak tersedia. Skrip juga memilih biaya pengiriman terendah ketika melakukan deduplikasi OrderID; ini merupakan aturan cleaning proyek, bukan aturan umum untuk semua dataset.

## Cakupan Analisis

- KPI jumlah pengiriman, proporsi status, total dan rata-rata biaya, jarak, berat, serta rating.
- Tren volume, biaya, dan durasi pengiriman bulanan.
- Status pengiriman, keterlambatan pada pengiriman Delivered, dan alasan masalah.
- Performa carrier, jenis layanan, warehouse, rute, tujuan, dan driver.
- Biaya per kilometer dan per kilogram.
- Hubungan antara keterlambatan dan rating, jarak dan durasi, serta jarak dan biaya.

## Ringkasan Output Notebook

Angka berikut disalin dari output KPI yang tersimpan dalam notebook, bukan hasil eksekusi ulang pada lingkungan ini.

| Metrik | Nilai |
| --- | ---: |
| Total pengiriman | 6.000 |
| Total biaya pengiriman | Rp672.858.255,32 |
| Rata-rata biaya pengiriman | Rp112.143,04 |
| Rata-rata jarak | 1.328,48 km |
| Rata-rata berat | 16,96 kg |
| Rata-rata rating | 3,42 |

Total biaya pengiriman dihitung sebagai `ShippingCostIDR + FuelSurchargeIDR`; angka ini bukan revenue atau laba.

## Definisi yang Perlu Diperhatikan

- `Delivered Rate` adalah proporsi baris berstatus Delivered dari seluruh pengiriman; metrik ini bukan on-time delivery rate.
- `Delayed Rate` menghitung status Delayed, bukan seluruh pengiriman yang melewati durasi rencana.
- `DeliveredStatus` mengelompokkan pengiriman Delivered menjadi Late atau Ontime berdasarkan perbandingan ActualDeliveryDays dan PlannedDeliveryDays.
- `DelayDays` dihitung sebagai ActualDeliveryDays dikurangi PlannedDeliveryDays. Nilai negatif berarti durasi aktual lebih pendek dari rencana; nilai ini tidak dibatasi minimum nol oleh notebook.
- Imputasi `DelayReason = 'No Delay'` pada status Delivered tidak membuktikan pengiriman tepat waktu. Gunakan perbandingan durasi untuk mengevaluasi keterlambatan.
- Korelasi menunjukkan hubungan statistik dan tidak membuktikan sebab-akibat.

## Menjalankan Notebook

### Persiapan Python

Dari folder utama proyek:

```bash
python -m venv .venv
```

Aktivasi pada Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

Aktivasi pada Linux/macOS:

```bash
source .venv/bin/activate
```

Kemudian:

```bash
python -m pip install -r requirements.txt
python -m jupyterlab
```

Versi dependensi belum dikunci karena lingkungan Python asli tidak disertakan. Repositori ini mengarsipkan analisis yang tersedia, bukan lingkungan eksekusi yang telah direproduksi sepenuhnya.

### Opsi A: SQL Server seperti Notebook Asli

1. Siapkan SQL Server, database `LogistikDB`, dan ODBC Driver 18 for SQL Server. Driver ODBC merupakan dependensi sistem terpisah dari paket `pyodbc`.
2. Untuk langsung menganalisis data cleaned, impor `data/processed/ShippingLogisticsCleaned.csv` sebagai `dbo.ShippingLogistics_Cleaned`, dengan tipe data angka dan tanggal yang sesuai.
3. Jika ingin meninjau alur cleaning, skrip `sql/01_TableCleaning.sql` mengharapkan tabel awal `dbo.ShippingLogistics`. Dataset mentah sebelum cleaning tidak tersedia terpisah dalam paket ini. Skrip berisi DROP, UPDATE, dan DELETE; jalankan pada database kerja khusus proyek.
4. Skrip `sql/02_TableAnalysis.sql` opsional untuk membuat `dbo.ShippingLogistics_Analysis`. Notebook tetap membaca tabel cleaned.
5. Buka notebook dan sesuaikan `server`, `database`, serta metode autentikasi. Konfigurasi asli menggunakan `localhost` dan Windows trusted authentication.
6. Pada sel pemuatan data, ubah tujuan ekspor CSV yang masih memakai lokasi Windows pribadi menjadi `../data/processed/TableAnalysis.csv` jika kernel berjalan dari folder `notebooks`. Ekspor ini akan menimpa file tujuan.
7. Jalankan sel secara berurutan.

### Opsi B: Menggunakan CSV Tanpa SQL Server

Pada salinan kerja notebook, ganti bagian koneksi dan daftar tabel SQL dengan impor berikut:

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import pearsonr
```

Ganti sel pemuatan SQL dan ekspor CSV dengan:

```python
from pathlib import Path

root = Path.cwd()
if root.name == 'notebooks':
    root = root.parent

df = pd.read_csv(root / 'data/processed/TableAnalysis.csv')
pd.set_option('display.max_columns', None)
print('Jumlah baris:', len(df))
print('Jumlah kolom:', len(df.columns))
df.head()
```

Lanjutkan dari sel `df.info()` dan pembuatan kolom turunan. Jalankan kernel dari folder utama proyek atau folder `notebooks` agar contoh path tersebut sesuai. Notebook yang disimpan dalam repositori tetap mempertahankan kode dan output asli.


