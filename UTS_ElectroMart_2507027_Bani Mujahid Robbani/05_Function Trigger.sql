USE electromart;

DELIMITER //

CREATE FUNCTION hitung_total(p_harga DECIMAL(12,2), p_jumlah INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    RETURN p_harga * p_jumlah;
END //

CREATE FUNCTION hitung_diskon(p_total DECIMAL(12,2))
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    IF p_total >= 1000000.00 THEN
        RETURN p_total * 0.10;
    ELSE
        RETURN 0.00;
    END IF;
END //

CREATE TRIGGER validasi_penjualan
BEFORE INSERT ON detail_penjualan
FOR EACH ROW
BEGIN
    DECLARE v_stok INT DEFAULT NULL;

    IF NEW.jumlah <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validasi Gagal: Jumlah pembelian harus lebih besar dari 0';
    END IF;

    IF NEW.harga_satuan <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validasi Gagal: Harga satuan tidak boleh nol atau negatif';
    END IF;

    SELECT stok INTO v_stok
    FROM produk
    WHERE id_produk = NEW.id_produk;

    IF v_stok IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validasi Gagal: Produk tidak terdaftar dalam sistem';
    ELSEIF v_stok < NEW.jumlah THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validasi Gagal: Stok produk tidak mencukupi';
    END IF;

    SET NEW.subtotal = hitung_total(NEW.harga_satuan, NEW.jumlah);
END //

CREATE TRIGGER update_stok_penjualan
AFTER INSERT ON detail_penjualan
FOR EACH ROW
BEGIN
    DECLARE v_total DECIMAL(12,2);
    DECLARE v_diskon DECIMAL(12,2);

    UPDATE produk
    SET stok = stok - NEW.jumlah
    WHERE id_produk = NEW.id_produk;

    INSERT INTO log_stok (id_produk, jumlah_perubahan, tipe_transaksi, keterangan)
    VALUES (NEW.id_produk, -NEW.jumlah, 'KELUAR', CONCAT('Pengurangan stok otomatis dari ', NEW.id_penjualan));

    SELECT COALESCE(SUM(subtotal), 0.00) INTO v_total
    FROM detail_penjualan
    WHERE id_penjualan = NEW.id_penjualan;

    SET v_diskon = hitung_diskon(v_total);

    UPDATE penjualan
    SET total_harga = v_total,
        diskon = v_diskon,
        total_bayar = v_total - v_diskon
    WHERE id_penjualan = NEW.id_penjualan;
END //

DELIMITER ;
-- -----------------------------------------------------------------

-- Kasus Uji 1 & 5: Stok tersedia & memenuhi syarat diskon (>= Rp1.000.000)
INSERT INTO penjualan (id_penjualan, id_pelanggan, id_pegawai) VALUES ('TRX008', 'PLG003', 'PGW002');
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan)
VALUES ('TRX008', 'PRD004', 2, 3200000.00);

-- Kasus Uji 6: Stok tersedia & tidak memenuhi syarat diskon (< Rp1.000.000)
INSERT INTO penjualan (id_penjualan, id_pelanggan, id_pegawai) VALUES ('TRX009', 'PLG004', 'PGW002');
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan)
VALUES ('TRX009', 'PRD008', 5, 85000.00);

-- Verifikasi hasil perhitungan otomatis, stok, dan log_stok
SELECT * FROM penjualan WHERE id_penjualan IN ('TRX008', 'TRX009');
SELECT id_produk, nama_produk, stok FROM produk WHERE id_produk IN ('PRD004', 'PRD008');
SELECT * FROM log_stok ORDER BY id_log DESC LIMIT 4;

-- Kasus Uji 2: Jumlah melebihi stok 
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan)
VALUES ('TRX009', 'PRD006', 99, 8500000.00);

-- Kasus Uji 3: Jumlah nol atau negatif 
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan)
VALUES ('TRX009', 'PRD008', 0, 85000.00);

-- Kasus Uji 4: Produk tidak terdaftar 
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan)
VALUES ('TRX009', 'PRD999', 1, 100000.00);