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
INSERT INTO Direccion (codigo_postal, direccion_detalle, ciudad_id) VALUES 
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
INSERT INTO EstadoCamper (descripcion) VALUES 
('En proceso de ingreso'),
('Inscrito'),
('Aprobado'),
('Cursando'),
('Graduado'),
('Expulsado'),
('Retirado');

-- Inserción de niveles de riesgo
INSERT INTO Riesgo (descripcion) VALUES
('Bajo'),
('Medio'),
('Alto');

-- Inserción de rutas
INSERT INTO Ruta (nombre) VALUES
('NetCore'),
('Spring Boot'),
('Node.JS');

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

-- Inserción de Personas
INSERT INTO Persona (identificacion, nombre, apellido, email, tipo_documento_id, direccion_id) VALUES 
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

INSERT INTO Trainer (persona_id, ruta_id, letra_codigo) VALUES 
(1, 1, 'J'),
(2, 3, 'A'),
(3, 2, 'U');

-- Inserción de tipos de teléfono
INSERT INTO TipoTelefono (tipo) VALUES
('Celular'),
('Fijo');

-- Inserción de horarios
INSERT INTO Horario (hora, codigo) VALUES 
('06:00:00', 1),
('10:00:00', 2),
('14:00:00', 3),
('18:00:00', 4);

-- Inserción de áreas de entrenamiento
INSERT INTO AreaEntrenamiento (nombre, capacidad, sede_id) VALUES 
('Apolo', 33, 1),
('Sputnik', 33, 1),
('Artemis', 33, 1);

-- Inserción de tipos de evaluación
INSERT INTO TipoEvaluacion (descripcion) VALUES
('Examen'),
('Proyecto'),
('Actividad');

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
INSERT INTO Grupo (nombre, codigo, capacidad) VALUES 
('Grupo J1', 'J1', 33),
('Grupo A2', 'A2', 33),
('Grupo U3', 'U3', 33);

-- Asignación de campers a grupos
INSERT INTO CamperGrupo (camper_id, grupo_id) VALUES 
(1, 1), (2, 1), (3, 1),
(4, 2), (5, 2), (6, 2),
(7, 3), (8, 3), (9, 3);

-- Inserción de notas para campers en distintos módulos
INSERT INTO Evaluacion (camper_id, modulo_id, tipo_evaluacion_id, nota) VALUES 
(1, 1, 1, 90), (1, 2, 2, 76), (1, 3, 3, 80),
(2, 4, 1, 84), (2, 5, 2, 78), (2, 6, 3, 82),
(3, 7, 1, 70), (3, 8, 2, 94), (3, 9, 3, 78),
(4, 10, 1, 96), (4, 11, 2, 74), (4, 12, 3, 92),
(5, 13, 1, 86), (5, 14, 2, 80), (5, 15, 3, 76),
(6, 16, 1, 78), (6, 17, 2, 88), (6, 18, 3, 82),
(7, 19, 1, 80), (7, 20, 2, 90), (7, 21, 3, 74),
(8, 22, 1, 84), (8, 23, 2, 86), (8, 24, 3, 82),
(9, 22, 1, 50), (9, 23, 2, 50), (9, 24, 3, 50);

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
(20, '3196548523', 1),
(21, '3132075504', 1),
(22, '3214180419', 1),
(23, '3143913746', 1),
(23, '3156717659', 1);