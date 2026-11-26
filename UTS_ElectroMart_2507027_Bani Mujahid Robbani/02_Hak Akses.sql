USE electromart;

-- 1. Pembuatan 4 Role
CREATE ROLE 'role_admin', 'role_penjualan', 'role_gudang', 'role_manajer';

-- 2. Pemberian Hak Akses (GRANT)
GRANT ALL PRIVILEGES ON electromart.* TO 'role_admin';

GRANT SELECT ON electromart.produk TO 'role_penjualan';
GRANT SELECT ON electromart.pelanggan TO 'role_penjualan';
GRANT SELECT ON electromart.pegawai TO 'role_penjualan';
GRANT SELECT, INSERT, UPDATE, DELETE ON electromart.penjualan TO 'role_penjualan';
GRANT SELECT, INSERT, UPDATE, DELETE ON electromart.detail_penjualan TO 'role_penjualan';
GRANT SELECT ON electromart.log_stok TO 'role_penjualan';

GRANT SELECT, INSERT, UPDATE (stok), DELETE ON electromart.produk TO 'role_gudang';
GRANT SELECT, INSERT ON electromart.log_stok TO 'role_gudang';

GRANT SELECT ON electromart.* TO 'role_manajer';

-- 3. Pencabutan Hak Akses Tertentu (REVOKE)
REVOKE DELETE ON electromart.penjualan FROM 'role_penjualan';
REVOKE DELETE ON electromart.detail_penjualan FROM 'role_penjualan';
REVOKE SELECT ON electromart.log_stok FROM 'role_penjualan';
REVOKE INSERT, DELETE ON electromart.produk FROM 'role_gudang';

-- 4. Pembuatan Akun Pengguna & Penetapan Role
CREATE USER 'user_andi'@'localhost' IDENTIFIED BY 'PasswordAdmin123';
CREATE USER 'user_maya'@'localhost' IDENTIFIED BY 'PasswordSales123';
CREATE USER 'user_eko'@'localhost' IDENTIFIED BY 'PasswordGudang123';
CREATE USER 'user_hendra'@'localhost' IDENTIFIED BY 'PasswordManajer123';

GRANT 'role_admin' TO 'user_andi'@'localhost';
GRANT 'role_penjualan' TO 'user_maya'@'localhost';
GRANT 'role_gudang' TO 'user_eko'@'localhost';
GRANT 'role_manajer' TO 'user_hendra'@'localhost';

-- Aktifkan role otomatis saat login (khusus MySQL 8.0+)
-- *Catatan: Jika menggunakan MariaDB, hapus bagian SET DEFAULT ROLE ini
SET DEFAULT ROLE ALL TO
    'user_andi'@'localhost',
    'user_maya'@'localhost',
    'user_eko'@'localhost',
    'user_hendra'@'localhost';

FLUSH PRIVILEGES;
-- -----------------------------------------------------------------

SHOW GRANTS FOR 'role_admin';
SHOW GRANTS FOR 'role_penjualan';
SHOW GRANTS FOR 'role_gudang';
SHOW GRANTS FOR 'role_manajer';

-- [PENGUJIAN: LOGIN SEBAGAI MASING-MASING USER DI KONEKSI BARU] ----
-- A. Login sebagai user_maya (role_penjualan)
SELECT id_produk, nama_produk, harga, stok FROM electromart.produk; -- Berhasil
ALTER TABLE electromart.produk ADD COLUMN berat INT; -- Ditolak (ERROR 1142)
SELECT * FROM electromart.log_stok; -- Ditolak (ERROR 1142)

-- B. Login sebagai user_eko (role_gudang)
UPDATE electromart.produk SET stok = 16 WHERE id_produk = 'PRD001'; -- Berhasil
INSERT INTO electromart.log_stok (id_produk, jumlah_perubahan, tipe_transaksi, keterangan)
VALUES ('PRD001', 1, 'MASUK', 'Penambahan stok retur supplier'); -- Berhasil
UPDATE electromart.produk SET harga = 14000000.00 WHERE id_produk = 'PRD001'; -- Ditolak (ERROR 1143)

-- C. Login sebagai user_hendra (role_manajer)
SELECT * FROM electromart.penjualan; -- Berhasil
DELETE FROM electromart.penjualan WHERE id_penjualan = 'TRX001'; -- Ditolak (ERROR 1142)