USE electromart;

-- =================================================================
-- SKENARIO A: Transaksi Penjualan Berhasil (1 Laptop + 2 Mouse)
-- =================================================================
START TRANSACTION;

INSERT INTO penjualan (id_penjualan, id_pelanggan, id_pegawai, total_harga, diskon, total_bayar)
VALUES ('TRX005', 'PLG005', 'PGW002', 15000000.00, 1500000.00, 13500000.00);

INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES
('TRX005', 'PRD001', 1, 14500000.00, 14500000.00),
('TRX005', 'PRD002', 2, 250000.00, 500000.00);

UPDATE produk SET stok = stok - 1 WHERE id_produk = 'PRD001';
UPDATE produk SET stok = stok - 2 WHERE id_produk = 'PRD002';

INSERT INTO log_stok (id_produk, jumlah_perubahan, tipe_transaksi, keterangan)
VALUES
('PRD001', -1, 'KELUAR', 'Pengurangan stok dari TRX005'),
('PRD002', -2, 'KELUAR', 'Pengurangan stok dari TRX005');

COMMIT;

SELECT * FROM penjualan WHERE id_penjualan = 'TRX005';
SELECT id_produk, nama_produk, stok FROM produk WHERE id_produk IN ('PRD001', 'PRD002');


-- =================================================================
-- SKENARIO B: Transaksi Gagal (Pembelian Melebihi Stok -> ROLLBACK)
-- =================================================================
START TRANSACTION;

INSERT INTO penjualan (id_penjualan, id_pelanggan, id_pegawai, total_harga, diskon, total_bayar)
VALUES ('TRX006', 'PLG001', 'PGW002', 42500000.00, 4250000.00, 38250000.00);

-- Stok PRD006 hanya 2 unit, pelanggan mencoba membeli 5 unit
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX006', 'PRD006', 5, 8500000.00, 42500000.00);

-- Batalkan seluruh transaksi
ROLLBACK;

SELECT * FROM penjualan WHERE id_penjualan = 'TRX006';
SELECT id_produk, nama_produk, stok FROM produk WHERE id_produk = 'PRD006';


-- =================================================================
-- SKENARIO C: Pembatalan Sebagian Transaksi (SAVEPOINT)
-- =================================================================
START TRANSACTION;

INSERT INTO penjualan (id_penjualan, id_pelanggan, id_pegawai, total_harga, diskon, total_bayar)
VALUES ('TRX007', 'PLG002', 'PGW002', 950000.00, 0.00, 950000.00);

INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX007', 'PRD010', 1, 950000.00, 950000.00);

UPDATE produk SET stok = stok - 1 WHERE id_produk = 'PRD010';
INSERT INTO log_stok (id_produk, jumlah_perubahan, tipe_transaksi, keterangan)
VALUES ('PRD010', -1, 'KELUAR', 'Pengurangan stok dari TRX007');

SAVEPOINT sp_item_pertama;

-- Item kedua ditambahkan lalu dibatalkan
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX007', 'PRD007', 1, 4499000.00, 4499000.00);

UPDATE produk SET stok = stok - 1 WHERE id_produk = 'PRD007';

ROLLBACK TO SAVEPOINT sp_item_pertama;

SAVEPOINT sp_final;
RELEASE SAVEPOINT sp_final;

COMMIT;

SELECT * FROM detail_penjualan WHERE id_penjualan = 'TRX007';
SELECT id_produk, nama_produk, stok FROM produk WHERE id_produk IN ('PRD010', 'PRD007');