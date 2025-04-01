-- Inserción de empresa
INSERT INTO Empresa (NIT, nombre) VALUES
('901628406', 'Campuslands');

-- Inserción de país
INSERT INTO Pais (nombre) VALUES
('Colombia');

-- Inserción de departamentos
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

-- Inserción de ciudades capitales
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
('Puerto Carreño', 32);

-- Inserción de direcciones
INSERT INTO Direccion (codigoPostal, descripcion, ciudad_id) VALUES 
(680003, 'Zona Franca Edificio Zenith Piso 6, Bucaramanga, Santander', 27),
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

-- Inserción de sedes
INSERT INTO Sede (nombre, ciudad_id, empresa_id) VALUES 
('Campus Bucaramanga', 27, 1),
('Campus Bogotá', 14, 1),
('Campus Cúcuta', 22, 1);

-- Inserción de tipos de documentos
INSERT INTO TipoDocumento (nombre) VALUES
('Cédula de Ciudadanía'),
('Tarjeta de Identidad'),
('Cédula de Extranjería');

-- Inserción de estados de campers
INSERT INTO EstadoCamper (estado) VALUES 
('En proceso de ingreso'),
('Inscrito'),
('Aprobado'),
('Cursando'),
('Graduado'),
('Expulsado'),
('Retirado');

-- Inserción de niveles de riesgo
INSERT INTO Riesgo (nivel) VALUES
('Bajo'),
('Medio'),
('Alto');

-- Inserción de rutas
INSERT INTO Ruta (nombre) VALUES
('NetCore'),
('Spring Boot'),
('Node.JS');

-- Inserción de skills
INSERT INTO Skill (nombre, ruta_id) VALUES
-- Ruta NetCore
('Introducción a la programación', 1),
('Python', 1),
('HTML + CSS', 1),
('Scrum y Metodologías ágiles', 1),
('GitHub y Control de versiones', 1),
('JavaScript básico', 1),
('introducción al Backend y Bases de datos', 1),
('MySQL I', 1),
('MySQL II', 1),
('C#', 1),
-- Ruta Spring Boot
('Introducción a la programación', 2),
('Python', 2),
('HTML + CSS', 2),
('Scrum y Metodologías ágiles', 2),
('GitHub y Control de versiones', 2),
('JavaScript básico', 2),
('introducción al Backend y Bases de datos', 2),
('MySQL I', 2),
('MySQL II', 2),
('Java', 2),
-- Ruta Node.JS
('Introducción a la programación', 3),
('Python', 3),
('HTML + CSS', 3),
('Scrum y Metodologías ágiles', 3),
('GitHub y Control de versiones', 3),
('JavaScript básico', 3),
('introducción al Backend y Bases de datos', 3),
('MySQL I', 3),
('MySQL II', 3),
('JavaScript avanzado', 3);

-- Inserción de relación Ruta-Modulo
INSERT INTO RutaSkill (ruta_id, skill_id) VALUES 
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10),
(2, 11), (2, 12), (2, 13), (2, 14), (2, 15), (2, 16), (2, 17), (2, 18), (2, 19), (2, 20),
(3, 21), (3, 22), (3, 23), (3, 24), (3, 25), (3, 26), (3, 27), (3, 28), (3, 29), (3, 30);

-- Inserción de Modulos
INSERT INTO Modulo (nombre, skill_id) VALUES
-- Ruta NetCore
('Modulo 1: Fundamentos de Algoritmos', 1),
('Modulo 2: Resolución de Problemas', 1),
('Modulo 1: Sintaxis de Python', 2),
('Modulo 2: Estructuras de Control', 2),
('Modulo 1: Maquetación con HTML', 3),
('Modulo 2: Estilos con CSS', 3),
('Modulo 1: Fundamentos de Scrum', 4),
('Modulo 2: Roles en Scrum', 4),
('Modulo 1: Uso de Git', 5),
('Modulo 2: Flujo de Trabajo en GitHub', 5),
('Modulo 1: Sintaxis Básica de JavaScript', 6),
('Modulo 2: Manipulación del DOM', 6),
('Modulo 1: Conceptos de Bases de Datos', 7),
('Modulo 2: Modelo Relacional', 7),
('Modulo 1: Consultas Básicas en MySQL', 8),
('Modulo 2: Funciones y Procedimientos', 8),
('Modulo 1: Normalización en MySQL', 9),
('Modulo 2: Optimización de Consultas', 9),
('Modulo 1: Sintaxis de C#', 10),
('Modulo 2: Programación Orientada a Objetos en C#', 10),
-- Ruta Spring Boot
('Modulo 1: Fundamentos de Algoritmos', 11),
('Modulo 2: Resolución de Problemas', 11),
('Modulo 1: Sintaxis de Python', 12),
('Modulo 2: Estructuras de Control', 12),
('Modulo 1: Maquetación con HTML', 13),
('Modulo 2: Estilos con CSS', 13),
('Modulo 1: Fundamentos de Scrum', 14),
('Modulo 2: Roles en Scrum', 14),
('Modulo 1: Uso de Git', 15),
('Modulo 2: Flujo de Trabajo en GitHub', 15),
('Modulo 1: Sintaxis Básica de JavaScript', 16),
('Modulo 2: Manipulación del DOM', 16),
('Modulo 1: Conceptos de Bases de Datos', 17),
('Modulo 2: Modelo Relacional', 17),
('Modulo 1: Consultas Básicas en MySQL', 18),
('Modulo 2: Funciones y Procedimientos', 18),
('Modulo 1: Normalización en MySQL', 19),
('Modulo 2: Optimización de Consultas', 19),
('Modulo 1: Sintaxis de Java', 20),
('Modulo 2: Programación Orientada a Objetos en Java', 20),
-- Ruta Node.JS
('Modulo 1: Fundamentos de Algoritmos', 21),
('Modulo 2: Resolución de Problemas', 21),
('Modulo 1: Sintaxis de Python', 22),
('Modulo 2: Estructuras de Control', 22),
('Modulo 1: Maquetación con HTML', 23),
('Modulo 2: Estilos con CSS', 23),
('Modulo 1: Fundamentos de Scrum', 24),
('Modulo 2: Roles en Scrum', 24),
('Modulo 1: Uso de Git', 25),
('Modulo 2: Flujo de Trabajo en GitHub', 25),
('Modulo 1: Sintaxis Básica de JavaScript', 26),
('Modulo 2: Manipulación del DOM', 26),
('Modulo 1: Conceptos de Bases de Datos', 27),
('Modulo 2: Modelo Relacional', 27),
('Modulo 1: Consultas Básicas en MySQL', 28),
('Modulo 2: Funciones y Procedimientos', 28),
('Modulo 1: Normalización en MySQL', 29),
('Modulo 2: Optimización de Consultas', 29),
('Modulo 1: JavaScript Avanzado', 30),
('Modulo 2: Desarrollo con Node.js', 30);

-- Inserción de Sesiones
INSERT INTO Sesion (nombre, modulo_id) VALUES 
-- Ruta NetCore
('Sesion 1: Introducción a Fundamentos de Algoritmos', 1),
('Sesion 2: Aplicación de Fundamentos de Algoritmos', 1),
('Sesion 1: Introducción a Resolución de Problemas', 2),
('Sesion 2: Aplicación de Resolución de Problemas', 2),
('Sesion 1: Introducción a Sintaxis de Python', 3),
('Sesion 2: Aplicación de Sintaxis de Python', 3),
('Sesion 1: Introducción a Estructuras de Control', 4),
('Sesion 2: Aplicación de Estructuras de Control', 4),
('Sesion 1: Introducción a Maquetación con HTML', 5),
('Sesion 2: Aplicación de Maquetación con HTML', 5),
('Sesion 1: Introducción a Estilos con CSS', 6),
('Sesion 2: Aplicación de Estilos con CSS', 6),
('Sesion 1: Introducción a Fundamentos de Scrum', 7),
('Sesion 2: Aplicación de Fundamentos de Scrum', 7),
('Sesion 1: Introducción a Roles en Scrum', 8),
('Sesion 2: Aplicación de Roles en Scrum', 8),
('Sesion 1: Introducción a Uso de Git', 9),
('Sesion 2: Aplicación de Uso de Git', 9),
('Sesion 1: Introducción a Flujo de Trabajo en GitHub', 10),
('Sesion 2: Aplicación de Flujo de Trabajo en GitHub', 10),
('Sesion 1: Introducción a Sintaxis Básica de JavaScript', 11),
('Sesion 2: Aplicación de Sintaxis Básica de JavaScript', 11),
('Sesion 1: Introducción a Manipulación del DOM', 12),
('Sesion 2: Aplicación de Manipulación del DOM', 12),
('Sesion 1: Introducción a Conceptos de Bases de Datos', 13),
('Sesion 2: Aplicación de Conceptos de Bases de Datos', 13),
('Sesion 1: Introducción a Modelo Relacional', 14),
('Sesion 2: Aplicación de Modelo Relacional', 14),
('Sesion 1: Introducción a Consultas Básicas en MySQL', 15),
('Sesion 2: Aplicación de Consultas Básicas en MySQL', 15),
('Sesion 1: Introducción a Funciones y Procedimientos', 16),
('Sesion 2: Aplicación de Funciones y Procedimientos', 16),
('Sesion 1: Introducción a Normalización en MySQL', 17),
('Sesion 2: Aplicación de Normalización en MySQL', 17),
('Sesion 1: Introducción a Optimización de Consultas', 18),
('Sesion 2: Aplicación de Optimización de Consultas', 18),
('Sesion 1: Introducción a Sintaxis de C#', 19),
('Sesion 2: Aplicación de Sintaxis de C#', 19),
('Sesion 1: Introducción a Programación Orientada a Objetos en C#', 20),
('Sesion 2: Aplicación de Programación Orientada a Objetos en C#', 20),
-- Ruta Spring Boot
('Sesion 1: Introducción a Fundamentos de Algoritmos', 21),
('Sesion 2: Aplicación de Fundamentos de Algoritmos', 21),
('Sesion 1: Introducción a Resolución de Problemas', 22),
('Sesion 2: Aplicación de Resolución de Problemas', 22),
('Sesion 1: Introducción a Sintaxis de Python', 23),
('Sesion 2: Aplicación de Sintaxis de Python', 23),
('Sesion 1: Introducción a Estructuras de Control', 24),
('Sesion 2: Aplicación de Estructuras de Control', 24),
('Sesion 1: Introducción a Maquetación con HTML', 25),
('Sesion 2: Aplicación de Maquetación con HTML', 25),
('Sesion 1: Introducción a Estilos con CSS', 26),
('Sesion 2: Aplicación de Estilos con CSS', 26),
('Sesion 1: Introducción a Fundamentos de Scrum', 27),
('Sesion 2: Aplicación de Fundamentos de Scrum', 27),
('Sesion 1: Introducción a Roles en Scrum', 28),
('Sesion 2: Aplicación de Roles en Scrum', 28),
('Sesion 1: Introducción a Uso de Git', 29),
('Sesion 2: Aplicación de Uso de Git', 29),
('Sesion 1: Introducción a Flujo de Trabajo en GitHub', 30),
('Sesion 2: Aplicación de Flujo de Trabajo en GitHub', 30),
('Sesion 1: Introducción a Sintaxis Básica de JavaScript', 31),
('Sesion 2: Aplicación de Sintaxis Básica de JavaScript', 31),
('Sesion 1: Introducción a Manipulación del DOM', 32),
('Sesion 2: Aplicación de Manipulación del DOM', 32),
('Sesion 1: Introducción a Conceptos de Bases de Datos', 33),
('Sesion 2: Aplicación de Conceptos de Bases de Datos', 33),
('Sesion 1: Introducción a Modelo Relacional', 34),
('Sesion 2: Aplicación de Modelo Relacional', 34),
('Sesion 1: Introducción a Consultas Básicas en MySQL', 35),
('Sesion 2: Aplicación de Consultas Básicas en MySQL', 35),
('Sesion 1: Introducción a Funciones y Procedimientos', 36),
('Sesion 2: Aplicación de Funciones y Procedimientos', 36),
('Sesion 1: Introducción a Normalización en MySQL', 37),
('Sesion 2: Aplicación de Normalización en MySQL', 37),
('Sesion 1: Introducción a Optimización de Consultas', 38),
('Sesion 2: Aplicación de Optimización de Consultas', 38),
('Sesion 1: Introducción a Sintaxis de Java', 39),
('Sesion 2: Aplicación de Sintaxis de Java', 39),
('Sesion 1: Introducción a Programación Orientada a Objetos en Java', 40),
('Sesion 2: Aplicación de Programación Orientada a Objetos en Java', 40),
-- Ruta Node.JS
('Sesion 1: Introducción a Fundamentos de Algoritmos', 41),
('Sesion 2: Aplicación de Fundamentos de Algoritmos', 41),
('Sesion 1: Introducción a Resolución de Problemas', 42),
('Sesion 2: Aplicación de Resolución de Problemas', 42),
('Sesion 1: Introducción a Sintaxis de Python', 43),
('Sesion 2: Aplicación de Sintaxis de Python', 43),
('Sesion 1: Introducción a Estructuras de Control', 44),
('Sesion 2: Aplicación de Estructuras de Control', 44),
('Sesion 1: Introducción a Maquetación con HTML', 45),
('Sesion 2: Aplicación de Maquetación con HTML', 45),
('Sesion 1: Introducción a Estilos con CSS', 46),
('Sesion 2: Aplicación de Estilos con CSS', 46),
('Sesion 1: Introducción a Fundamentos de Scrum', 47),
('Sesion 2: Aplicación de Fundamentos de Scrum', 47),
('Sesion 1: Introducción a Roles en Scrum', 48),
('Sesion 2: Aplicación de Roles en Scrum', 48),
('Sesion 1: Introducción a Uso de Git', 49),
('Sesion 2: Aplicación de Uso de Git', 49),
('Sesion 1: Introducción a Flujo de Trabajo en GitHub', 50),
('Sesion 2: Aplicación de Flujo de Trabajo en GitHub', 50),
('Sesion 1: Introducción a Sintaxis Básica de JavaScript', 51),
('Sesion 2: Aplicación de Sintaxis Básica de JavaScript', 51),
('Sesion 1: Introducción a Manipulación del DOM', 52),
('Sesion 2: Aplicación de Manipulación del DOM', 52),
('Sesion 1: Introducción a Conceptos de Bases de Datos', 53),
('Sesion 2: Aplicación de Conceptos de Bases de Datos', 53),
('Sesion 1: Introducción a Modelo Relacional', 54),
('Sesion 2: Aplicación de Modelo Relacional', 54),
('Sesion 1: Introducción a Consultas Básicas en MySQL', 55),
('Sesion 2: Aplicación de Consultas Básicas en MySQL', 55),
('Sesion 1: Introducción a Funciones y Procedimientos', 56),
('Sesion 2: Aplicación de Funciones y Procedimientos', 56),
('Sesion 1: Introducción a Normalización en MySQL', 57),
('Sesion 2: Aplicación de Normalización en MySQL', 57),
('Sesion 1: Introducción a Optimización de Consultas', 58),
('Sesion 2: Aplicación de Optimización de Consultas', 58),
('Sesion 1: Introducción a JavaScript Avanzado', 59),
('Sesion 2: Aplicación de JavaScript Avanzado', 59),
('Sesion 1: Introducción a Desarrollo con Node.js', 60),
('Sesion 2: Aplicación de Desarrollo con Node.js', 60);

-- Inserción de Personas
INSERT INTO Persona (identificacion, nombre, apellido, email, tipoDoc_id, direccion_id) VALUES 
-- Trainers
('123456789', 'Jholver', 'Pardo', 'jholver@campuslands.edu', 1, 1),
('987654321', 'Adrian', 'Amaya', 'adrian@campuslands.edu', 1, 1),
('456789123', 'Juan Carlos', 'Marino', 'juan@campuslands.edu', 1, 1),
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
('100000010', 'Paola', 'Mejia', 'paola.mejia@mail.com', 1, 11),
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
('200000010', 'Gloria', 'Mejia', 'gloria.mejia@mail.com', 1, 11);

INSERT INTO Trainer (persona_id, ruta_id, codigo) VALUES 
(1, 1, 'J'),
(2, 3, 'A'),
(3, 2, 'U');

-- Inserción de tipos de teléfono
INSERT INTO TipoTelefono (tipoTel) VALUES
('Celular'),
('Fijo');

-- Inserción de horarios
INSERT INTO Horario (horaInicio, horaFin) VALUES 
('06:00:00', '09:00:00'),
('10:00:00', '13:00:00'),
('14:00:00', '17:00:00'),
('18:00:00', '21:00:00');

-- Inserción de áreas de entrenamiento
INSERT INTO AreaEntrenamiento (nombre, sede_id) VALUES 
('Apolo', 1),
('Sputnik', 1),
('Artemis', 1);

-- Inserción de campers
INSERT INTO Camper (persona_id, estado_id, riesgo_id) VALUES 
(4, 2, 1),
(5, 3, 2),
(6, 4, 3),
(7, 5, 1),
(8, 2, 2), 
(9, 3, 3),
(10, 4, 1),
(11, 5, 2),
(12, 2, 3),
(13, 3, 1);

-- Inserción de acudientes
INSERT INTO Acudiente (persona_id, camper_id) VALUES 
(14, 1),
(15, 2),
(16, 3),
(17, 4),
(18, 5), 
(19, 6),
(20, 7),
(21, 8),
(22, 9),
(23, 10);

-- Inserción de grupos
INSERT INTO Grupo (nombre, capacidad) VALUES 
('J1', 33),
('A2', 33),
('U3', 33);

-- Asignación de campers a grupos
INSERT INTO CamperGrupo (camper_id, grupo_id) VALUES 
(1, 1), (2, 1), (3, 1),
(4, 2), (5, 2), (6, 2),
(7, 3), (8, 3), (9, 3);

-- Tabla de Asignación de Entrenamiento
INSERT INTO AsignacionEntrenamiento (trainer_id, horario_id, area_id, grupo_id) VALUES 
(1, 1, 1, 1),
(2, 2, 2, 2),
(3, 3, 3, 3);

-- Inserción de notas para campers en distintos skills
INSERT INTO Notas (camper_id, skill_id, notaExamen, notaProyecto, notaActividad) VALUES 
(1, 1, 100, 100, 100),
(2, 4, 93, 94,95),
(3, 7, 80, 83, 87),
(4, 10, 70, 78, 70),
(5, 13, 73, 72, 79),
(6, 16, 68, 65, 69),
(7, 21, 62, 63, 65),
(8, 23, 56, 58, 59),
(9, 26, 50, 50, 50);

-- Inserción de teléfonos
INSERT INTO Telefono (persona_id, telefono, tipoTel_id) VALUES
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
(20, '3196548523', 1),
(21, '3132075504', 1),
(22, '3214180419', 1),
(23, '3143913746', 1),
(23, '3156717659', 1);
