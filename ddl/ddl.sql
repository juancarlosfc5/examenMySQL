-- Creación de la base de datos
CREATE DATABASE SeguimientoAcademico;
USE SeguimientoAcademico;

-- Tabla de Empresa
CREATE TABLE Empresa (
    id INT PRIMARY KEY AUTO_INCREMENT,
    NIT VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(50) NOT NULL
);

-- Tabla de Pais
CREATE TABLE Pais (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

-- Tabla de Estado
CREATE TABLE Estado (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    pais_id INT NOT NULL,
    FOREIGN KEY (pais_id) REFERENCES Pais(id) ON DELETE CASCADE
);

-- Tabla de Ciudad
CREATE TABLE Ciudad (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    estado_id INT NOT NULL,
    FOREIGN KEY (estado_id) REFERENCES Estado(id) ON DELETE CASCADE
);

-- Tabla de Direccion
CREATE TABLE Direccion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo_postal INT NOT NULL,
    direccion_detalle VARCHAR(255) NOT NULL,
    ciudad_id INT NOT NULL,
    FOREIGN KEY (ciudad_id) REFERENCES Ciudad(id) ON DELETE CASCADE
);

-- Tabla de Sede
CREATE TABLE Sede (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    ciudad_id INT NOT NULL,
    empresa_id INT NOT NULL,
    FOREIGN KEY (empresa_id) REFERENCES Empresa(id) ON DELETE CASCADE,
    FOREIGN KEY (ciudad_id) REFERENCES Ciudad(id) ON DELETE CASCADE
);

-- Tabla de Tipo de Documento
CREATE TABLE TipoDocumento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

-- Tabla de Persona
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

-- Tabla de Estado Camper
CREATE TABLE EstadoCamper (
    id INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(50) UNIQUE NOT NULL
);

-- Tabla de Nivel de Riesgo Camper
CREATE TABLE Riesgo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(50) UNIQUE NOT NULL
);

-- Tabla de Camper
CREATE TABLE Camper (
    id INT PRIMARY KEY AUTO_INCREMENT,
    persona_id INT UNIQUE NOT NULL,
    estado_id INT NOT NULL,
    riesgo_id INT NOT NULL,
    FOREIGN KEY (persona_id) REFERENCES Persona(id) ON DELETE CASCADE,
    FOREIGN KEY (estado_id) REFERENCES EstadoCamper(id) ON DELETE CASCADE,
    FOREIGN KEY (riesgo_id) REFERENCES Riesgo(id) ON DELETE CASCADE
);

-- Tabla de Acudiente
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

-- Tabla de Trainer
CREATE TABLE Trainer (
    id INT PRIMARY KEY AUTO_INCREMENT,
    persona_id INT UNIQUE NOT NULL,
    ruta_id INT NOT NULL,
    letra_codigo CHAR(1) UNIQUE NOT NULL,
    FOREIGN KEY (persona_id) REFERENCES Persona(id) ON DELETE CASCADE,
    FOREIGN KEY (ruta_id) REFERENCES Ruta(id) ON DELETE CASCADE
);

-- Tabla de Tipo de Telefono
CREATE TABLE TipoTelefono (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(20) UNIQUE NOT NULL
);

-- Tabla de Teléfonos
CREATE TABLE Telefono (
    id INT PRIMARY KEY AUTO_INCREMENT,
    persona_id INT NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    tipo_telefono_id INT NOT NULL,
    FOREIGN KEY (persona_id) REFERENCES Persona(id) ON DELETE CASCADE,
    FOREIGN KEY (tipo_telefono_id) REFERENCES TipoTelefono(id) ON DELETE CASCADE
);

-- Tabla de Horario
CREATE TABLE Horario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    hora TIME NOT NULL,
    codigo INT NOT NULL CHECK (codigo BETWEEN 1 AND 4)
);

-- Tabla de Grupo
CREATE TABLE Grupo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    codigo VARCHAR(2) UNIQUE NOT NULL,
    capacidad INT NOT NULL CHECK (capacidad <= 33)
);

-- Tabla de Relación Camper-Grupo
CREATE TABLE CamperGrupo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    camper_id INT NOT NULL,
    grupo_id INT NOT NULL,
    FOREIGN KEY (camper_id) REFERENCES Camper(id) ON DELETE CASCADE,
    FOREIGN KEY (grupo_id) REFERENCES Grupo(id) ON DELETE CASCADE
);

-- Tabla de Área de Entrenamiento
CREATE TABLE AreaEntrenamiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    capacidad INT NOT NULL CHECK (capacidad <= 33),
    sede_id INT NOT NULL,
    FOREIGN KEY (sede_id) REFERENCES Sede(id) ON DELETE CASCADE
);

-- Tabla de Asignación de Entrenamiento
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

-- Tabla de Módulo
CREATE TABLE Modulo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    ruta_id INT NOT NULL,
    FOREIGN KEY (ruta_id) REFERENCES Ruta(id) ON DELETE CASCADE
);

-- Tabla de Relación Ruta-Módulo
CREATE TABLE RutaModulo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ruta_id INT NOT NULL,
    modulo_id INT NOT NULL,
    FOREIGN KEY (ruta_id) REFERENCES Ruta(id) ON DELETE CASCADE,
    FOREIGN KEY (modulo_id) REFERENCES Modulo(id) ON DELETE CASCADE
);

-- Tabla de Tipo de Evaluacion
CREATE TABLE TipoEvaluacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(50) NOT NULL
);

-- Tabla de Evaluacion
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