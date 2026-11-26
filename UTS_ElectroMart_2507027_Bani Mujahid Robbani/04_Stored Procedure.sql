USE electromart;

DELIMITER //

CREATE PROCEDURE SP_Tampil_Produk()
BEGIN
    SELECT id_produk, nama_produk, kategori, harga, stok
    FROM produk
    ORDER BY id_produk;
END //

CREATE PROCEDURE SP_Tambah_Produk(
    IN p_id_produk VARCHAR(10),
    IN p_nama_produk VARCHAR(100),
    IN p_kategori VARCHAR(50),
    IN p_harga DECIMAL(12,2),
    IN p_stok INT
)
BEGIN
    INSERT INTO produk (id_produk, nama_produk, kategori, harga, stok)
    VALUES (p_id_produk, p_nama_produk, p_kategori, p_harga, p_stok);
END //

CREATE PROCEDURE SP_Ubah_Harga(
    IN p_id_produk VARCHAR(10),
    IN p_harga_baru DECIMAL(12,2)
)
BEGIN
    UPDATE produk
    SET harga = p_harga_baru
    WHERE id_produk = p_id_produk;
END //

DELIMITER ;
-- -----------------------------------------------------------------

SHOW PROCEDURE STATUS WHERE Db = 'electromart';

CALL SP_Tampil_Produk();

CALL SP_Tambah_Produk('PRD011', 'SSD NVMe Samsung 1TB', 'Storage', 1650000.00, 15);
CALL SP_Tambah_Produk('PRD012', 'Router WiFi 6 TP-Link AX55', 'Networking', 1150000.00, 9);

CALL SP_Ubah_Harga('PRD002', 275000.00);
CALL SP_Ubah_Harga('PRD011', 1550000.00);

CALL SP_Tampil_Produk();

DROP PROCEDURE IF EXISTS SP_Ubah_Harga;
SHOW PROCEDURE STATUS WHERE Db = 'electromart';