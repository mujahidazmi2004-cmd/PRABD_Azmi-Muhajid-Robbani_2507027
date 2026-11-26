USE electromart;

-- 1. View dari satu tabel
CREATE VIEW View_Produk AS
SELECT
    id_produk,
    nama_produk,
    kategori,
    harga
FROM produk;

-- 2. View menggabungkan beberapa tabel menggunakan JOIN
CREATE VIEW View_Transaksi AS
SELECT
    p.id_penjualan,
    p.tanggal,
    pl.nama_pelanggan,
    pg.nama_pegawai AS kasir,
    p.total_harga,
    p.diskon,
    p.total_bayar
FROM penjualan p
JOIN pelanggan pl ON p.id_pelanggan = pl.id_pelanggan
JOIN pegawai pg ON p.id_pegawai = pg.id_pegawai;

-- 3. View dengan fungsi agregasi COUNT(), SUM(), dan GROUP BY
CREATE VIEW View_Laporan_Penjualan AS
SELECT
    pr.kategori,
    COUNT(DISTINCT dp.id_penjualan) AS jumlah_transaksi,
    SUM(dp.jumlah) AS total_unit_terjual,
    SUM(dp.subtotal) AS total_penjualan
FROM detail_penjualan dp
JOIN produk pr ON dp.id_produk = pr.id_produk
GROUP BY pr.kategori;

-- 4. View dengan WITH CHECK OPTION (batas stok rendah < 5 unit)
CREATE VIEW View_Stok_Rendah AS
SELECT
    id_produk,
    nama_produk,
    kategori,
    stok
FROM produk
WHERE stok < 5
WITH CHECK OPTION;
-- -----------------------------------------------------------------

SELECT * FROM View_Produk;
SELECT * FROM View_Transaksi ORDER BY tanggal DESC;
SELECT * FROM View_Laporan_Penjualan;
SELECT * FROM View_Stok_Rendah;

-- Pengujian WITH CHECK OPTION
-- Berhasil (stok 4 masih < 5)
UPDATE View_Stok_Rendah SET stok = 4 WHERE id_produk = 'PRD003';

-- Gagal (ERROR 1369: CHECK OPTION failed)
UPDATE View_Stok_Rendah SET stok = 10 WHERE id_produk = 'PRD003';

-- Penghapusan salah satu View sesuai instruksi
DROP VIEW IF EXISTS View_Produk;
SHOW FULL TABLES WHERE Table_type = 'VIEW';