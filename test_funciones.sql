-- Pruebas de Funciones SQL

-- 1. Calcular promedio ponderado de un camper
SELECT 
    p.nombre,
    p.apellido,
    CalcularPromedioPonderado(c.id) as promedio
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
WHERE c.id = 1;

-- 2. Determinar aprobación de módulo
SELECT 
    p.nombre,
    p.apellido,
    m.nombre as modulo,
    DeterminarAprobacionModulo(c.id, m.id) as estado
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
JOIN Evaluacion e ON c.id = e.camper_id
JOIN Skill s ON e.skill_id = s.id
JOIN Modulo m ON s.id = m.skill_id
WHERE c.id = 1 AND m.id = 1;

-- 3. Evaluar nivel de riesgo
SELECT 
    p.nombre,
    p.apellido,
    EvaluarNivelRiesgo(c.id) as nivel_riesgo
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
WHERE c.id = 1;

-- 4. Total de campers en una ruta
SELECT 
    r.nombre as ruta,
    ObtenerTotalCampersRuta(r.id) as total_campers
FROM Ruta r
WHERE r.id = 1;

-- 5. Contar módulos aprobados
SELECT 
    p.nombre,
    p.apellido,
    ContarModulosAprobados(c.id) as modulos_aprobados
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
WHERE c.id = 1;

-- 6. Validar cupos disponibles
SELECT 
    ae.nombre as area,
    CASE 
        WHEN ValidarCuposDisponibles(ae.id) = 1 THEN 'Disponible'
        ELSE 'Lleno'
    END as estado
FROM AreaEntrenamiento ae
WHERE ae.id = 1;

-- 7. Calcular porcentaje de ocupación
SELECT 
    ae.nombre as area,
    CalcularPorcentajeOcupacion(ae.id) as porcentaje_ocupacion
FROM AreaEntrenamiento ae
WHERE ae.id = 1;

-- 8. Obtener nota más alta de un módulo
SELECT 
    m.nombre as modulo,
    ObtenerNotaMasAlta(m.id) as nota_maxima
FROM Modulo m
WHERE m.id = 1;

-- 9. Calcular tasa de aprobación
SELECT 
    r.nombre as ruta,
    CalcularTasaAprobacion(r.id) as tasa_aprobacion
FROM Ruta r
WHERE r.id = 1;

-- 10. Verificar disponibilidad de horario
SELECT 
    p.nombre,
    p.apellido,
    h.horaInicio,
    CASE 
        WHEN TrainerTieneHorarioDisponible(t.id, h.id) = 1 THEN 'Disponible'
        ELSE 'Ocupado'
    END as estado
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
CROSS JOIN Horario h
WHERE t.id = 1 AND h.id = 1;

-- 11. Promedio de notas por ruta
SELECT 
    r.nombre as ruta,
    ObtenerPromedioRuta(r.id) as promedio
FROM Ruta r
WHERE r.id = 1;

-- 12. Contar rutas por trainer
SELECT 
    p.nombre,
    p.apellido,
    ContarRutasTrainer(t.id) as total_rutas
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
WHERE t.id = 1;

-- 13. Verificar si puede graduarse
SELECT 
    p.nombre,
    p.apellido,
    CASE 
        WHEN PuedeSerGraduado(c.id) = 1 THEN 'Puede graduarse'
        ELSE 'Aún no cumple requisitos'
    END as estado
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
WHERE c.id = 1;

-- 14. Obtener estado actual
SELECT 
    p.nombre,
    p.apellido,
    ObtenerEstadoCamper(c.id) as estado
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
WHERE c.id = 1;

-- 15. Calcular carga horaria
SELECT 
    p.nombre,
    p.apellido,
    CalcularCargaHoraria(t.id) as horas_semanales
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
WHERE t.id = 1;

-- 16. Verificar módulos pendientes
SELECT 
    r.nombre as ruta,
    CASE 
        WHEN TieneModulosPendientes(r.id) = 1 THEN 'Tiene pendientes'
        ELSE 'Todo evaluado'
    END as estado
FROM Ruta r
WHERE r.id = 1;

-- 17. Promedio general del programa
SELECT CalcularPromedioGeneral() as promedio_general;

-- 18. Verificar choque de horarios
SELECT 
    ae.nombre as area,
    h.horaInicio,
    CASE 
        WHEN HorarioChocaEnArea(ae.id, h.id) = 1 THEN 'Ocupado'
        ELSE 'Disponible'
    END as estado
FROM AreaEntrenamiento ae
CROSS JOIN Horario h
WHERE ae.id = 1 AND h.id = 1;

-- 19. Contar campers en riesgo
SELECT 
    r.nombre as ruta,
    ContarCampersEnRiesgo(r.id) as campers_en_riesgo
FROM Ruta r
WHERE r.id = 1;

-- 20. Contar módulos evaluados
SELECT 
    p.nombre,
    p.apellido,
    ContarModulosEvaluados(c.id) as modulos_evaluados
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
WHERE c.id = 1; 