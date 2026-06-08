-- =======================================================
-- 1. CONFIGURACIÓN DE BASES DE DATOS Y PERMISOS
-- =======================================================
CREATE DATABASE IF NOT EXISTS despachosdb;
CREATE DATABASE IF NOT EXISTS ventasdb;

CREATE USER IF NOT EXISTS 'userdb'@'%' IDENTIFIED BY 'passdb';
GRANT ALL PRIVILEGES ON despachosdb.* TO 'userdb'@'%';
GRANT ALL PRIVILEGES ON ventasdb.* TO 'userdb'@'%';
FLUSH PRIVILEGES;

-- =======================================================
-- 2. POBLAR DATOS DE PRUEBA: TABLA DESPACHO
-- =======================================================
USE despachosdb;

-- Creamos la estructura básica en caso de que el script corra antes que las apps
CREATE TABLE IF NOT EXISTS despacho (
    id_despacho BIGINT NOT NULL AUTO_INCREMENT,
    fecha_despacho DATE,
    patente_camion VARCHAR(255),
    intento INT,
    id_compra BIGINT,
    direccion_compra VARCHAR(255),
    valor_compra BIGINT,
    despachado BOOLEAN,
    PRIMARY KEY (id_despacho)
);

INSERT INTO despacho (id_despacho, fecha_despacho, patente_camion, intento, id_compra, direccion_compra, valor_compra, despachado)
VALUES 
(1, '2026-06-04', 'AB-CD-12', 1, 10045, 'Av. Concha y Toro 3456, Puente Alto', 25000, true),
(2, '2026-06-05', 'XY-ZW-34', 0, 10046, 'Vicuña Mackenna 456, Santiago', 42990, false);

-- =======================================================
-- 3. POBLAR DATOS DE PRUEBA: TABLA VENTA
-- =======================================================
USE ventasdb;

CREATE TABLE IF NOT EXISTS venta (
    id_venta BIGINT NOT NULL AUTO_INCREMENT,
    direccion_compra VARCHAR(255),
    valor_compra INT,
    fecha_compra DATE,
    despacho_generado BOOLEAN,
    PRIMARY KEY (id_venta)
);

INSERT INTO venta (id_venta, direccion_compra, valor_compra, fecha_compra, despacho_generado)
VALUES 
(1, 'Av. Concha y Toro 3456, Puente Alto', 25000, '2026-06-04', true),
(2, 'Vicuña Mackenna 456, Santiago', 42990, '2026-06-04', false);