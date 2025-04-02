-- Trainers

-- 1. Listar todos los entrenadores registrados.
SELECT 
    t.codigo,
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    p.email,
    r.nombre as ruta_asignada,
    COUNT(DISTINCT aae.area_id) as areas_asignadas,
    COUNT(DISTINCT cg.camper_id) as campers_asignados
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
JOIN Ruta r ON t.ruta_id = r.id
LEFT JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
LEFT JOIN Grupo g ON aae.grupo_id = g.id
LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
GROUP BY t.id, t.codigo, p.nombre, p.apellido, p.email, r.nombre;

-- 2. Mostrar los trainers con sus horarios asignados.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    r.nombre as ruta,
    ae.nombre as area,
    h.horaInicio,
    h.horaFin,
    g.nombre as grupo,
    COUNT(DISTINCT cg.camper_id) as campers_en_grupo
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
JOIN Ruta r ON t.ruta_id = r.id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN AreaEntrenamiento ae ON aae.area_id = ae.id
JOIN Horario h ON aae.horario_id = h.id
JOIN Grupo g ON aae.grupo_id = g.id
LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
GROUP BY t.id, p.nombre, p.apellido, r.nombre, ae.nombre, h.horaInicio, h.horaFin, g.nombre
ORDER BY p.nombre, h.horaInicio;

-- 3. Consultar los trainers asignados a más de una ruta.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    COUNT(DISTINCT t.ruta_id) as total_rutas,
    GROUP_CONCAT(DISTINCT r.nombre) as rutas_asignadas
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
JOIN Ruta r ON t.ruta_id = r.id
GROUP BY t.id, p.nombre, p.apellido
HAVING total_rutas > 1
ORDER BY total_rutas DESC;

-- 4. Obtener el número de campers por trainer.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    r.nombre as ruta,
    COUNT(DISTINCT cg.camper_id) as total_campers,
    GROUP_CONCAT(DISTINCT g.nombre) as grupos_asignados
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
JOIN Ruta r ON t.ruta_id = r.id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN Grupo g ON aae.grupo_id = g.id
LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
GROUP BY t.id, p.nombre, p.apellido, r.nombre
ORDER BY COUNT(DISTINCT cg.camper_id) DESC;

-- 5. Mostrar las áreas en las que trabaja cada trainer.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    GROUP_CONCAT(DISTINCT ae.nombre) as areas_asignadas,
    GROUP_CONCAT(DISTINCT CONCAT(h.horaInicio, ' - ', h.horaFin)) as horarios
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN AreaEntrenamiento ae ON aae.area_id = ae.id
JOIN Horario h ON aae.horario_id = h.id
GROUP BY t.id, p.nombre, p.apellido;

-- 6. Listar los trainers sin asignación de área o ruta.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    p.email,
    r.nombre as ruta_asignada,
    'Sin área asignada' as estado
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
LEFT JOIN Ruta r ON t.ruta_id = r.id
LEFT JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
WHERE aae.id IS NULL;

-- 7. Mostrar cuántos módulos están a cargo de cada trainer.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    r.nombre as ruta,
    COUNT(DISTINCT m.id) as total_modulos,
    GROUP_CONCAT(DISTINCT m.nombre) as modulos_asignados
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
JOIN Ruta r ON t.ruta_id = r.id
JOIN Skill s ON r.id = s.ruta_id
JOIN Modulo m ON s.id = m.skill_id
GROUP BY t.id, p.nombre, p.apellido, r.nombre
ORDER BY COUNT(DISTINCT m.id) DESC;

-- 8. Obtener el trainer con mejor rendimiento promedio de campers.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    r.nombre as ruta,
    COUNT(DISTINCT e.camper_id) as total_campers_evaluados,
    AVG(e.notaFinal) as promedio_notas,
    COUNT(DISTINCT CASE 
        WHEN e.estado = 'Aprobado'
        THEN e.camper_id 
    END) as campers_aprobados
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
JOIN Ruta r ON t.ruta_id = r.id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN Grupo g ON aae.grupo_id = g.id
JOIN CamperGrupo cg ON g.id = cg.grupo_id
JOIN Evaluacion e ON cg.camper_id = e.camper_id
GROUP BY t.id, p.nombre, p.apellido, r.nombre
HAVING COUNT(DISTINCT e.camper_id) > 0
ORDER BY promedio_notas DESC
LIMIT 1;

-- 9. Consultar los horarios ocupados por cada trainer.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    COUNT(DISTINCT aae.horario_id) as total_horarios_asignados,
    GROUP_CONCAT(DISTINCT CONCAT(h.horaInicio, ' - ', h.horaFin)) as horarios_ocupados
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN Horario h ON aae.horario_id = h.id
GROUP BY t.id, p.nombre, p.apellido
ORDER BY COUNT(DISTINCT aae.horario_id) DESC;

-- 10. Mostrar la disponibilidad semanal de cada trainer.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    h.horaInicio,
    h.horaFin,
    CASE 
        WHEN aae.id IS NULL THEN 'Disponible'
        ELSE 'Ocupado'
    END as estado,
    CASE 
        WHEN aae.id IS NOT NULL THEN ae.nombre
        ELSE NULL
    END as area_asignada
FROM Trainer t
CROSS JOIN Horario h
JOIN Persona p ON t.persona_id = p.id
LEFT JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id 
    AND h.id = aae.horario_id
LEFT JOIN AreaEntrenamiento ae ON aae.area_id = ae.id
ORDER BY p.nombre, h.horaInicio;