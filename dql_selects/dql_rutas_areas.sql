-- Rutas y áreas de entrenamiento

-- 1. Mostrar todas las rutas de entrenamiento disponibles.
SELECT 
    r.nombre as ruta,
    COUNT(DISTINCT s.id) as total_skills,
    COUNT(DISTINCT m.id) as total_modulos,
    GROUP_CONCAT(DISTINCT t.codigo) as trainers_asignados
FROM Ruta r
LEFT JOIN Skill s ON r.id = s.ruta_id
LEFT JOIN Modulo m ON s.id = m.skill_id
LEFT JOIN Trainer t ON r.id = t.ruta_id
GROUP BY r.id, r.nombre;

-- 2. Obtener las rutas con su SGDB principal y alternativo.
SELECT 
    r.nombre as ruta,
    b1.nombre as sgbd_principal,
    b2.nombre as sgbd_alternativo
FROM Ruta r
JOIN Basedatos b1 ON r.SGBD1_id = b1.id
JOIN Basedatos b2 ON r.SGBD2_id = b2.id;

-- 3. Listar los módulos asociados a cada ruta.
SELECT 
    r.nombre as ruta,
    s.nombre as skill,
    m.nombre as modulo
FROM Ruta r
JOIN Skill s ON r.id = s.ruta_id
JOIN Modulo m ON s.id = m.skill_id
GROUP BY r.id, r.nombre, s.id, s.nombre, m.id, m.nombre
ORDER BY r.nombre, s.nombre, m.nombre;

-- 4. Consultar cuántos campers hay en cada ruta.
SELECT 
    r.nombre as ruta,
    COUNT(DISTINCT cg.camper_id) as total_campers
FROM Ruta r
JOIN Trainer t ON r.id = t.ruta_id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN Grupo g ON aae.grupo_id = g.id
LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
GROUP BY r.id, r.nombre
ORDER BY total_campers DESC;

-- 5. Mostrar las áreas de entrenamiento y su capacidad máxima.
SELECT 
    ae.nombre AS area,
    s.nombre AS sede,
    COUNT(DISTINCT g.id) AS grupos_asignados,
    SUM(DISTINCT g.capacidad) AS capacidad_total,
    COUNT(DISTINCT cg.camper_id) AS campers_actuales
FROM AreaEntrenamiento ae
JOIN Sede s ON ae.sede_id = s.id
LEFT JOIN AsignacionAreaEntrenamiento aae ON ae.id = aae.area_id
LEFT JOIN Grupo g ON aae.grupo_id = g.id
LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
GROUP BY ae.id, ae.nombre, s.nombre;

-- 6. Obtener las áreas que están ocupadas al 100%.
SELECT 
    ae.nombre as area,
    s.nombre as sede,
    COUNT(DISTINCT cg.camper_id) as campers_actuales,
    SUM(g.capacidad) as capacidad_total,
    ROUND((COUNT(DISTINCT cg.camper_id) * 100.0 / SUM(g.capacidad)), 2) as porcentaje_ocupacion
FROM AreaEntrenamiento ae
JOIN Sede s ON ae.sede_id = s.id
JOIN AsignacionAreaEntrenamiento aae ON ae.id = aae.area_id
JOIN Grupo g ON aae.grupo_id = g.id
LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
GROUP BY ae.id, ae.nombre, s.nombre
HAVING porcentaje_ocupacion >= 100
ORDER BY porcentaje_ocupacion DESC;

-- 7. Verificar la ocupación actual de cada área.
SELECT 
    ae.nombre as area,
    h.horaInicio,
    h.horaFin,
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    g.nombre as grupo,
    COUNT(DISTINCT cg.camper_id) as campers_presentes,
    g.capacidad as capacidad_maxima
FROM AreaEntrenamiento ae
JOIN AsignacionAreaEntrenamiento aae ON ae.id = aae.area_id
JOIN Horario h ON aae.horario_id = h.id
JOIN Trainer t ON aae.trainer_id = t.id
JOIN Persona p ON t.persona_id = p.id
JOIN Grupo g ON aae.grupo_id = g.id
LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
GROUP BY ae.id, ae.nombre, h.horaInicio, h.horaFin, p.nombre, p.apellido, g.nombre, g.capacidad
ORDER BY ae.nombre, h.horaInicio;

-- 8. Consultar los horarios disponibles por cada área.
SELECT 
    ae.nombre as area,
    h.horaInicio,
    h.horaFin,
    CASE 
        WHEN aae.id IS NULL THEN 'Disponible'
        ELSE 'Ocupado'
    END as estado
FROM AreaEntrenamiento ae
CROSS JOIN Horario h
LEFT JOIN AsignacionAreaEntrenamiento aae ON ae.id = aae.area_id 
    AND h.id = aae.horario_id
ORDER BY ae.nombre, h.horaInicio;

-- 9. Mostrar las áreas con más campers asignados.
SELECT 
    ae.nombre as area,
    s.nombre as sede,
    COUNT(DISTINCT cg.camper_id) as total_campers,
    COUNT(DISTINCT g.id) as total_grupos,
    GROUP_CONCAT(DISTINCT CONCAT(p.nombre, ' ', p.apellido)) as trainers
FROM AreaEntrenamiento ae
JOIN Sede s ON ae.sede_id = s.id
JOIN AsignacionAreaEntrenamiento aae ON ae.id = aae.area_id
JOIN Grupo g ON aae.grupo_id = g.id
JOIN CamperGrupo cg ON g.id = cg.grupo_id
JOIN Trainer t ON aae.trainer_id = t.id
JOIN Persona p ON t.persona_id = p.id
GROUP BY ae.id, ae.nombre, s.nombre
ORDER BY COUNT(DISTINCT cg.camper_id) DESC;

-- 10. Listar las rutas con sus respectivos trainers y áreas asignadas.
SELECT 
    r.nombre as ruta,
    GROUP_CONCAT(DISTINCT CONCAT(p.nombre, ' ', p.apellido)) as trainers,
    GROUP_CONCAT(DISTINCT ae.nombre) as areas_asignadas,
    COUNT(DISTINCT cg.camper_id) as total_campers
FROM Ruta r
JOIN Trainer t ON r.id = t.ruta_id
JOIN Persona p ON t.persona_id = p.id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN AreaEntrenamiento ae ON aae.area_id = ae.id
LEFT JOIN Grupo g ON aae.grupo_id = g.id
LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
GROUP BY r.id, r.nombre
ORDER BY COUNT(DISTINCT cg.camper_id) DESC;