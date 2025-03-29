# examenMySQL

![DiagramaERv1](https://github.com/user-attachments/assets/7bc8afa7-4e24-4a06-8acc-42d9f9e0b186)

## Base de datos

```mysql
-- Creación de la base de datos
CREATE DATABASE SeguimientoAcademico;
USE SeguimientoAcademico;

-- Tabla de Empresa
CREATE TABLE Empresa (
    id INT PRIMARY KEY AUTO_INCREMENT,
    NIT VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(50) NOT NULL
);

-- Tabla de Sede
CREATE TABLE Sede (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    ciudad_id INT NOT NULL,
    empresa_id INT UNIQUE NOT NULL,
    FOREIGN KEY (empresa_id) REFERENCES Empresa(id) ON DELETE CASCADE,
    FOREIGN KEY (ciudad_id) REFERENCES Ciudad(id) ON DELETE CASCADE
);

-- Normalización geográfica
CREATE TABLE Pais (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Estado (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    pais_id INT NOT NULL,
    FOREIGN KEY (pais_id) REFERENCES Pais(id) ON DELETE CASCADE
);

CREATE TABLE Ciudad (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    estado_id INT NOT NULL,
    FOREIGN KEY (estado_id) REFERENCES Estado(id) ON DELETE CASCADE
);

-- Tabla Direccion
CREATE TABLE Direccion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo_postal INT NOT NULL,
    direccion_detalle VARCHAR(255) NOT NULL,
    ciudad_id INT NOT NULL,
    FOREIGN KEY (ciudad_id) REFERENCES Ciudad(id) ON DELETE CASCADE
);

-- Tabla TipoDocumento
CREATE TABLE TipoDocumento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

-- Tabla Persona
CREATE TABLE Persona (
    id INT PRIMARY KEY AUTO_INCREMENT,
    identificacion VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(50) UNIQUE NOT NULL,
    tipo_documento_id INT NOT NULL,
    direccion_id INT NOT NULL,
    FOREIGN KEY (tipo_documento_id) REFERENCES TipoDocumento(id) ON DELETE CASCADE,
    FOREIGN KEY (direccion_id) REFERENCES Direccion(id) ON DELETE CASCADE
);

-- Tabla de Estado de Camper
CREATE TABLE EstadoCamper (
    id INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(50) UNIQUE NOT NULL
);

-- Tabla de Nivel de Riesgo de Camper
CREATE TABLE Riesgo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(50) UNIQUE NOT NULL
);

-- Tabla Camper
CREATE TABLE Camper (
    id INT PRIMARY KEY AUTO_INCREMENT,
    persona_id INT UNIQUE NOT NULL,
    estado_id INT NOT NULL,
    riesgo_id INT NOT NULL,
    FOREIGN KEY (persona_id) REFERENCES Persona(id) ON DELETE CASCADE,
    FOREIGN KEY (estado_id) REFERENCES EstadoCamper(id) ON DELETE CASCADE,
    FOREIGN KEY (riesgo_id) REFERENCES Riesgo(id) ON DELETE CASCADE
);

-- Tabla Acudiente
CREATE TABLE Acudiente (
    id INT PRIMARY KEY AUTO_INCREMENT,
    persona_id INT UNIQUE NOT NULL,
    camper_id INT UNIQUE NOT NULL,
    FOREIGN KEY (persona_id) REFERENCES Persona(id) ON DELETE CASCADE,
    FOREIGN KEY (camper_id) REFERENCES Camper(id) ON DELETE CASCADE
);

-- Tabla de Rutas de Entrenamiento
CREATE TABLE Ruta (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL
);

-- Tabla Trainer
CREATE TABLE Trainer (
    id INT PRIMARY KEY AUTO_INCREMENT,
    persona_id INT UNIQUE NOT NULL,
    ruta_id INT NOT NULL,
    letra_codigo CHAR(1) UNIQUE NOT NULL,
    FOREIGN KEY (persona_id) REFERENCES Persona(id) ON DELETE CASCADE,
    FOREIGN KEY (ruta_id) REFERENCES Ruta(id) ON DELETE CASCADE
);

-- Tabla TipoTelefono
CREATE TABLE TipoTelefono (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(20) UNIQUE NOT NULL
);

-- Teléfonos de Persona
CREATE TABLE Telefono (
    id INT PRIMARY KEY AUTO_INCREMENT,
    persona_id INT NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    tipo_telefono_id INT NOT NULL,
    FOREIGN KEY (persona_id) REFERENCES Persona(id) ON DELETE CASCADE,
    FOREIGN KEY (tipo_telefono_id) REFERENCES TipoTelefono(id) ON DELETE CASCADE
);

-- Tabla Horario
CREATE TABLE Horario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    hora TIME NOT NULL,
    codigo INT NOT NULL CHECK (codigo BETWEEN 1 AND 4)
);

-- Tabla Grupo
CREATE TABLE Grupo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    codigo VARCHAR(2) UNIQUE NOT NULL,
    capacidad INT NOT NULL CHECK (capacidad <= 33)
);

-- Relación Camper-Grupo
CREATE TABLE CamperGrupo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    camper_id INT NOT NULL,
    grupo_id INT NOT NULL,
    FOREIGN KEY (camper_id) REFERENCES Camper(id) ON DELETE CASCADE,
    FOREIGN KEY (grupo_id) REFERENCES Grupo(id) ON DELETE CASCADE
);

-- Tabla Área de Entrenamiento
CREATE TABLE AreaEntrenamiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    capacidad INT NOT NULL CHECK (capacidad <= 33),
    sede_id INT NOT NULL,
    FOREIGN KEY (sede_id) REFERENCES Sede(id) ON DELETE CASCADE
);

-- Tabla Asignación de Entrenamiento
CREATE TABLE AsignacionEntrenamiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    trainer_id INT NOT NULL,
    horario_id INT NOT NULL UNIQUE,
    area_id INT NOT NULL,
    salon VARCHAR(50) NOT NULL,
    grupo_id INT UNIQUE,
    UNIQUE (trainer_id, horario_id, area_id),
    FOREIGN KEY (trainer_id) REFERENCES Trainer(id) ON DELETE CASCADE,
    FOREIGN KEY (horario_id) REFERENCES Horario(id) ON DELETE CASCADE,
    FOREIGN KEY (area_id) REFERENCES AreaEntrenamiento(id) ON DELETE CASCADE,
    FOREIGN KEY (grupo_id) REFERENCES Grupo(id) ON DELETE CASCADE
);

-- Tabla Módulo
CREATE TABLE Modulo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    ruta_id INT NOT NULL,
    FOREIGN KEY (ruta_id) REFERENCES Ruta(id) ON DELETE CASCADE
);

-- Relación Ruta-Módulo
CREATE TABLE RutaModulo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ruta_id INT NOT NULL,
    modulo_id INT NOT NULL,
    FOREIGN KEY (ruta_id) REFERENCES Ruta(id) ON DELETE CASCADE,
    FOREIGN KEY (modulo_id) REFERENCES Modulo(id) ON DELETE CASCADE
);

-- Tabla TipoEvaluacion
CREATE TABLE TipoEvaluacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(50) NOT NULL
);

-- Tabla Evaluacion
CREATE TABLE Evaluacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    camper_id INT NOT NULL,
    modulo_id INT NOT NULL,
    tipo_evaluacion_id INT NOT NULL,
    nota DECIMAL(5,2) NOT NULL,
    FOREIGN KEY (camper_id) REFERENCES Camper(id) ON DELETE CASCADE,
    FOREIGN KEY (modulo_id) REFERENCES Modulo(id) ON DELETE CASCADE,
    FOREIGN KEY (tipo_evaluacion_id) REFERENCES TipoEvaluacion(id) ON DELETE CASCADE
);
```

## Inserts

```mysql
-- Insertar empresa
INSERT INTO Empresa (NIT, nombre) VALUES ('901628406', 'Campuslands');

-- Insertar país
INSERT INTO Pais (nombre) VALUES ('Colombia');

-- Insertar departamentos y ciudades capitales
INSERT INTO Estado (nombre, pais_id) VALUES
('Amazonas', 1),
('Antioquia', 1),
('Arauca', 1),
('Atlántico', 1),
('Bolívar', 1),
('Boyacá', 1),
('Caldas', 1),
('Caquetá', 1),
('Casanare', 1),
('Cauca', 1),
('Cesar', 1),
('Chocó', 1),
('Córdoba', 1),
('Cundinamarca', 1),
('Guainía', 1),
('Guaviare', 1),
('Huila', 1),
('La Guajira', 1),
('Magdalena', 1),
('Meta', 1),
('Nariño', 1),
('Norte de Santander', 1),
('Putumayo', 1),
('Quindío', 1),
('Risaralda', 1),
('San Andrés y Providencia', 1),
('Santander', 1),
('Sucre', 1),
('Tolima', 1),
('Valle del Cauca', 1),
('Vaupés', 1),
('Vichada', 1);

-- Insertar ciudades capitales
INSERT INTO Ciudad (nombre, estado_id) VALUES
('Leticia', 1),
('Medellín', 2),
('Arauca', 3),
('Barranquilla', 4),
('Cartagena de Indias', 5),
('Tunja', 6),
('Manizales', 7),
('Florencia', 8),
('Yopal', 9),
('Popayán', 10),
('Valledupar', 11),
('Quibdó', 12),
('Montería', 13),
('Bogotá', 14),
('Inírida', 15),
('San José del Guaviare', 16),
('Neiva', 17),
('Riohacha', 18),
('Santa Marta', 19),
('Villavicencio', 20),
('Pasto', 21),
('Cúcuta', 22),
('Mocoa', 23),
('Armenia', 24),
('Pereira', 25),
('San Andrés', 26),
('Bucaramanga', 27),
('Sincelejo', 28),
('Ibagué', 29),
('Cali', 30),
('Mitú', 31),
('Puerto Carreño', 32)

-- Inserción de sedes
INSERT INTO Sede (nombre, ciudad_id, empresa_id) VALUES 
('Campus Bucaramanga', 27, 1),
('Campus Bogotá', 14, 1),
('Campus Cúcuta', 22, 1);

-- Inserción de direcciones
INSERT INTO Direccion (codigo_postal, direccion_detalle, ciudad_id) VALUES 
(680003, 'Zona Franca Edificio Zenith Piso 6, Bucaramanga, Santander', 27);
(110111, 'Calle 45 #12-34, Bogotá', 14),
(110112, 'Carrera 7 #85-10, Bogotá', 14),
(680002, 'Calle 36 #29-18, Bucaramanga', 27),
(680001, 'Carrera 15 #30-05, Bucaramanga', 27),
(540001, 'Avenida 0 #12-45, Cúcuta', 22),
(540002, 'Calle 10 #5-60, Cúcuta', 22),
(680004, 'Diagonal 15 #45-90, Bucaramanga', 27),
(110113, 'Transversal 20 #50-40, Bogotá', 14),
(540003, 'Calle 23 #14-22, Cúcuta', 22),
(680005, 'Carrera 33 #48-12, Bucaramanga', 27);

-- Inserción de tipos de documentos
INSERT INTO TipoDocumento (nombre) VALUES ('Cédula de Ciudadanía'), ('Tarjeta de Identidad'), ('Cédula de Extranjería');

-- Inserción de estados de campers
INSERT INTO EstadoCamper (descripcion) VALUES 
('En proceso de ingreso'), ('Inscrito'), ('Aprobado'), ('Cursando'), ('Graduado'), ('Expulsado'), ('Retirado');

-- Inserción de niveles de riesgo
INSERT INTO Riesgo (descripcion) VALUES ('Bajo'), ('Medio'), ('Alto');

-- Inserción de rutas
INSERT INTO Ruta (nombre) VALUES ('NetCore'), ('Spring Boot'), ('Node.JS');

-- Inserción de módulos
INSERT INTO Modulo (nombre, ruta_id) VALUES 
('Introducción', 1), ('Python', 1), ('HTML', 1), ('CSS', 1), ('JavaScript', 1), ('C#', 1), ('MySQL', 1), ('PostgreSQL', 1),
('Introducción', 2), ('Python', 2), ('HTML', 2), ('CSS', 2), ('JavaScript', 2), ('Java', 2), ('MySQL', 2), ('PostgreSQL', 2),
('Introducción', 3), ('Python', 3), ('HTML', 3), ('CSS', 3), ('JavaScript', 3), ('JavaScript avanzado', 3), ('MySQL', 3), ('PostgreSQL', 3);

-- Inserción de relación Ruta-Modulo
INSERT INTO RutaModulo (ruta_id, modulo_id) VALUES 
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8),
(2, 9), (2, 10), (2, 11), (2, 12), (2, 13), (2, 14), (2, 15), (2, 16),
(3, 17), (3, 18), (3, 19), (3, 20), (3, 21), (3, 22), (3, 23), (3, 24);

-- Inserción de trainers
INSERT INTO Persona (identificacion, nombre, apellido, email, tipo_documento_id, direccion_id) VALUES 
-- Trainers
('123456789', 'Jholver', 'Pardo', 'jholver@campuslands.edu', 1, 1),
('987654321', 'Adrian', 'Amaya', 'adrian@campuslands.edu', 1, 1),
('456789123', 'Juan Carlos', 'Marino', 'juan@campuslands.edu', 1, 1);
-- Campers
('100000001', 'Carlos', 'Gomez', 'carlos.gomez@mail.com', 1, 2),
('100000002', 'Andrea', 'Perez', 'andrea.perez@mail.com', 1, 3),
('100000003', 'Luis', 'Martinez', 'luis.martinez@mail.com', 1, 4),
('100000004', 'Valentina', 'Rodriguez', 'valentina.rodriguez@mail.com', 1, 5),
('100000005', 'Juan', 'Hernandez', 'juan.hernandez@mail.com', 1, 6),
('100000006', 'Diana', 'Lopez', 'diana.lopez@mail.com', 1, 7),
('100000007', 'Felipe', 'Ramirez', 'felipe.ramirez@mail.com', 1, 8),
('100000008', 'Sofia', 'Torres', 'sofia.torres@mail.com', 1, 9),
('100000009', 'Camilo', 'Castro', 'camilo.castro@mail.com', 1, 10),
('100000010', 'Paola', 'Mejia', 'paola.mejia@mail.com', 1, 1),
-- Acudientes
('200000001', 'Jose', 'Gomez', 'jose.gomez@mail.com', 1, 2),
('200000002', 'Maria', 'Perez', 'maria.perez@mail.com', 1, 3),
('200000003', 'Pedro', 'Martinez', 'pedro.martinez@mail.com', 1, 4),
('200000004', 'Ana', 'Rodriguez', 'ana.rodriguez@mail.com', 1, 5),
('200000005', 'Miguel', 'Hernandez', 'miguel.hernandez@mail.com', 1, 6),
('200000006', 'Laura', 'Lopez', 'laura.lopez@mail.com', 1, 7),
('200000007', 'Carlos', 'Ramirez', 'carlos.ramirez@mail.com', 1, 8),
('200000008', 'Carmen', 'Torres', 'carmen.torres@mail.com', 1, 9),
('200000009', 'Oscar', 'Castro', 'oscar.castro@mail.com', 1, 10),
('200000010', 'Gloria', 'Mejia', 'gloria.mejia@mail.com', 1, 1);

INSERT INTO Trainer (persona_id, ruta_id, letra_codigo) VALUES 
(1, 1, 'J'),
(2, 3, 'A'),
(3, 2, 'U');

-- Inserción de tipos de teléfono
INSERT INTO TipoTelefono (tipo) VALUES ('Celular'), ('Fijo');

-- Inserción de horarios
INSERT INTO Horario (hora, codigo) VALUES 
('06:00:00', 1), ('10:00:00', 2), ('14:00:00', 3), ('18:00:00', 4);

-- Inserción de áreas de entrenamiento
INSERT INTO AreaEntrenamiento (nombre, capacidad, sede_id) VALUES 
('Apolo', 33, 27), ('Sputnik', 33, 27), ('Artemis', 33, 27);

-- Inserción de tipos de evaluación
INSERT INTO TipoEvaluacion (descripcion) VALUES ('Examen'), ('Proyecto'), ('Actividades');

-- Inserción de campers
INSERT INTO Camper (persona_id, estado_id, riesgo_id) VALUES 
(1, 2, 1), (2, 3, 2), (3, 4, 3), (4, 5, 1), (5, 2, 2), 
(6, 3, 3), (7, 4, 1), (8, 5, 2), (9, 2, 3), (10, 3, 1);

-- Inserción de acudientes
INSERT INTO Acudiente (persona_id, camper_id) VALUES 
(11, 1), (12, 2), (13, 3), (14, 4), (15, 5), 
(16, 6), (17, 7), (18, 8), (19, 9), (20, 10);

-- Inserción de grupos
INSERT INTO Grupo (nombre, codigo, capacidad) VALUES 
('Grupo J1', 'J1', 33), ('Grupo A2', 'A2', 33), ('Grupo U3', 'U3', 33);

-- Asignación de campers a grupos
INSERT INTO CamperGrupo (camper_id, grupo_id) VALUES 
(1, 1), (2, 1), (3, 1), (4, 2), (5, 2), (6, 2), (7, 3), (8, 3), (9, 3);

-- Inserción de notas para campers en distintos módulos
INSERT INTO Evaluacion (camper_id, modulo_id, tipo_evaluacion_id, nota) VALUES 
(1, 1, 1, 4.5), (1, 2, 2, 3.8), (1, 3, 3, 4.0),
(2, 4, 1, 4.2), (2, 5, 2, 3.9), (2, 6, 3, 4.1),
(3, 7, 1, 3.5), (3, 8, 2, 4.7), (3, 9, 3, 3.9),
(4, 10, 1, 4.8), (4, 11, 2, 3.7), (4, 12, 3, 4.6),
(5, 13, 1, 4.3), (5, 14, 2, 4.0), (5, 15, 3, 3.8),
(6, 16, 1, 3.9), (6, 17, 2, 4.4), (6, 18, 3, 4.1),
(7, 19, 1, 4.0), (7, 20, 2, 4.5), (7, 21, 3, 3.7),
(8, 22, 1, 4.2), (8, 23, 2, 4.3), (8, 24, 3, 4.1);

-- Inserción de teléfonos
INSERT INTO Telefono (persona_id, telefono, tipo_telefono_id) VALUES
(1, '3001234567', 1),
(2, '3019876543', 1),
(3, '3024567891', 1),
(4, '3036789123', 1),
(5, '3047891234', 1),
(6, '3053216548', 1),
(7, '3069873214', 1),
(8, '3076549871', 1),
(9, '3081597532', 1),
(10, '3098521473', 1),
(11, '3104567892', 1),
(12, '3116789541', 1),
(13, '3127896543', 1),
(14, '3138529637', 1),
(15, '3149632584', 1),
(16, '3157418529', 1),
(17, '3168529634', 1),
(18, '3179513576', 1),
(19, '3183579512', 1),
(20, '3196548523', 1);
```

