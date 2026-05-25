
CREATE DATABASE IF NOT EXISTS vallegrande_db_POO;
USE vallegrande_db_POO;

-- ============================================
-- TABLA: usuario
-- ============================================
CREATE TABLE IF NOT EXISTS usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre_usuario VARCHAR(50) NOT NULL UNIQUE,
    contrasena VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    rol ENUM('admin', 'consultor') DEFAULT 'admin',
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso DATETIME NULL,
    CONSTRAINT chk_nombre_usuario_long CHECK (LENGTH(nombre_usuario) >= 3)
);

-- Insertar usuario administrador por defecto
INSERT INTO usuario (nombre_usuario, contrasena, email, rol, activo)
VALUES ('admin', 'admin123', 'admin@vallegrande.edu.pe', 'admin', TRUE)
ON DUPLICATE KEY UPDATE id_usuario = id_usuario;

-- ============================================
-- TABLA: curso
-- ============================================
CREATE TABLE IF NOT EXISTS curso (
    id_curso INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    creditos TINYINT NOT NULL CHECK (creditos BETWEEN 1 AND 10),
    horas_semana TINYINT NOT NULL CHECK (horas_semana BETWEEN 1 AND 40),
    descripcion TEXT,
    fecha_registro DATE NOT NULL DEFAULT (CURDATE()),
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_codigo_formato CHECK (codigo REGEXP '^[A-Z0-9]{3,10}$'),  
    CONSTRAINT chk_nombre_no_vacio CHECK (nombre <> '')
);
-- opcional: solo letras mayúsculas y números
-- ============================================
-- TABLA: estudiante (con tipo_documento y numero_documento)
-- ============================================
CREATE TABLE IF NOT EXISTS estudiante (
    id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
    tipo_documento ENUM('DNI', 'CE', 'Pasaporte') NOT NULL DEFAULT 'DNI',
    numero_documento VARCHAR(20) NOT NULL UNIQUE,
    nombres VARCHAR(50) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefono VARCHAR(15),
    direccion VARCHAR(200),
    fecha_nacimiento DATE,
    genero ENUM('M', 'F') NOT NULL,   -- Solo M o F
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_numero_no_vacio CHECK (numero_documento <> ''),
    CONSTRAINT chk_email_valido CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_telefono_digitos CHECK (telefono IS NULL OR telefono REGEXP '^[0-9]{7,15}$')
);

-- ============================================
-- TABLA: matricula
-- ============================================
CREATE TABLE IF NOT EXISTS matricula (
    id_matricula INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_curso INT NOT NULL,
    fecha_matricula DATE NOT NULL DEFAULT (CURDATE()),
    ciclo VARCHAR(10) NOT NULL COMMENT 'Ej: 2025-I, 2025-II',
    nota_final DECIMAL(4,2) NULL CHECK (nota_final BETWEEN 0 AND 20),
    estado_matricula ENUM('activa', 'completada', 'anulada') DEFAULT 'activa',
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_curso) REFERENCES curso(id_curso) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT unique_matricula_estudiante_curso UNIQUE (id_estudiante, id_curso, ciclo)
);

-- Índices
CREATE INDEX idx_curso_activo ON curso(activo);
CREATE INDEX idx_estudiante_activo ON estudiante(activo);
CREATE INDEX idx_matricula_estudiante ON matricula(id_estudiante);
CREATE INDEX idx_matricula_curso ON matricula(id_curso);
CREATE INDEX idx_usuario_activo ON usuario(activo);

-- ============================================
-- Datos de ejemplo (cursos y estudiantes)
-- ============================================
INSERT INTO curso (codigo, nombre, creditos, horas_semana, descripcion) VALUES
('INF101', 'Programación I', 4, 5, 'Fundamentos de programación con Java'),
('INF102', 'Base de Datos', 4, 5, 'Diseño y administración de bases de datos relacionales'),
('MAT201', 'Matemática Aplicada', 3, 4, 'Álgebra y cálculo para informática');

-- Nota: ahora usamos tipo_documento y numero_documento, y género M/F
INSERT INTO estudiante (tipo_documento, numero_documento, nombres, apellidos, email, telefono, fecha_nacimiento, genero) VALUES
('DNI', '12345678', 'Juan Carlos', 'Pérez Gómez', 'juan.perez@example.com', '987654321', '2000-05-15', 'M'),
('CE', 'E87654321', 'María José', 'López Torres', 'maria.lopez@example.com', '912345678', '2001-08-22', 'F');

-- Matrículas de ejemplo (asegurar que los id_estudiante e id_curso existan)
INSERT INTO matricula (id_estudiante, id_curso, ciclo, fecha_matricula) VALUES
(1, 1, '2025-I', '2025-03-01'),
(1, 2, '2025-I', '2025-03-01'),
(2, 1, '2025-I', '2025-03-02')
ON DUPLICATE KEY UPDATE id_matricula = id_matricula;

-- Verificaciones
SELECT * FROM usuario;
SELECT * FROM curso;
SELECT * FROM estudiante;
SELECT * FROM matricula;

docker run --name mysql-vallegrande \
  -e MYSQL_ROOT_PASSWORD=981837328 \
  -e MYSQL_DATABASE=vallegrande_db_POO \
  -p 3306:3306 \
  -d mysql:latest

  docker run --name mysql-vallegrande -e MYSQL_ROOT_PASSWORD=981837328 -e MYSQL_DATABASE=vallegrande_db_POO -p 3306:3306 -d mysql:latest



  -- =============================================================
-- 10 REGISTROS PARA LA TABLA: curso
-- =============================================================
INSERT INTO curso (codigo, nombre, creditos, horas_semana, descripcion) VALUES
('INF201', 'Programación Orientada a Objetos', 4, 6, 'Conceptos de POO, clases, herencia y polimorfismo en Java y C#'),
('INF202', 'Desarrollo Web Backend', 4, 5, 'Creación de arquitecturas web escalables utilizando Flask y Express'),
('INF203', 'Análisis y Diseño de Sistemas', 3, 4, 'Modelado de software con UML, diagramas de clases y casos de uso'),
('INF204', 'Estructuras de Datos', 4, 5, 'Gestión de memoria, listas, árboles, grafos y optimización de algoritmos'),
('INF205', 'Desarrollo Web Frontend', 3, 4, 'Construcción de interfaces dinámicas con HTML5, Tailwind CSS y JavaScript'),
('INF206', 'Aseguramiento de la Calidad', 2, 3, 'Pruebas unitarias, automatización de testing y metodologías QA'),
('INF207', 'Gestión de Proyectos Ágiles', 3, 4, 'Administración de proyectos tecnológicos usando Scrum y Kanban'),
('INF208', 'Seguridad de la Información', 3, 4, 'Criptografía básica, OWASP Top 10 y protección de bases de datos'),
('INF209', 'Sistemas Operativos y Redes', 4, 5, 'Administración de servidores Linux, redes TCP/IP y Docker básico'),
('INF210', 'Proyecto Integrador POO', 4, 6, 'Desarrollo de una aplicación real aplicando POO y persistencia de datos');


-- =============================================================
-- 10 REGISTROS PARA LA TABLA: estudiante
-- =============================================================
INSERT INTO estudiante (tipo_documento, numero_documento, nombres, apellidos, email, telefono, direccion, fecha_nacimiento, genero) VALUES
('DNI', '70112233', 'Kevin Arnold', 'Chávez Palomino', 'kevin.chavez@vallegrande.edu.pe', '934567812', 'Av. Benavides 456 - Cañete', '2004-11-05', 'M'),
('DNI', '70445566', 'Rosa María', 'Flores Huamán', 'rosa.flores@vallegrande.edu.pe', '956781234', 'Jr. Bolognesi 789 - Imperial', '2005-01-30', 'F'),
('CE', '009876543', 'Jean Pierre', 'Dupond', 'jean.dupond@vallegrande.edu.pe', '978123456', 'Urb. Los Álamos Mz B Lote 4', '2003-07-14', 'M'),
('DNI', '70223344', 'Luis Alberto', 'Sánchez Díaz', 'luis.sanchez@vallegrande.edu.pe', '911223344', 'Calle Comercio 123 - Mala', '2006-03-18', 'M'),
('DNI', '70556677', 'Diana Carolina', 'Torres Gutiérrez', 'diana.torres@vallegrande.edu.pe', '955667788', 'Av. Mariscal Castilla 510', '2005-09-25', 'F'),
('DNI', '70998877', 'Mateo Sebastián', 'Ruiz Castillo', 'mateo.ruiz@vallegrande.edu.pe', '999888777', 'Jr. Grau 240 - San Vicente', '2004-06-11', 'M'),
('DNI', '70445511', 'Camila Belén', 'Espinoza Vega', 'camila.espinoza@vallegrande.edu.pe', '944556611', 'Calle Lima 832 - Nuevo Imperial', '2005-12-04', 'F'),
('DNI', '70223345', 'Diego Alonso', 'Castro Morales', 'diego.castro@vallegrande.edu.pe', '922334455', 'Av. Libertadores 150', '2006-01-15', 'M'),
('DNI', '70667788', 'Andrea Sofía', 'Navarro Ortiz', 'andrea.navarro@vallegrande.edu.pe', '966778899', 'Jr. Puno 365 - Quilmaná', '2005-05-29', 'F'),
('Pasaporte', 'PAS009876', 'Hans', 'Müller', 'hans.muller@vallegrande.edu.pe', '912987345', 'Malecón de la Marina 110', '2002-02-28', 'M');


-- =============================================================
-- 10 REGISTROS PARA LA TABLA: matricula
-- =============================================================
-- (Usa los IDs del 3 al 12 correspondientes a los nuevos estudiantes y cursos)
INSERT INTO matricula (id_estudiante, id_curso, ciclo, nota_final, estado_matricula) VALUES
(3, 4, '2026-I', 16.50, 'activa'),
(4, 4, '2026-I', 14.00, 'activa'),
(5, 5, '2026-I', 18.00, 'activa'),
(6, 6, '2026-I', 11.50, 'activa'),
(7, 7, '2026-I', 15.00, 'activa'),
(8, 8, '2026-I', 13.25, 'activa'),
(9, 9, '2026-I', 17.00, 'activa'),
(10, 10, '2026-I', 19.50, 'completada'),
(11, 11, '2026-I', 10.00, 'activa'),
(12, 12, '2026-I', NULL, 'activa');