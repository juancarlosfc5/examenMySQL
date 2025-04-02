-- JOINs con funciones de agregación

-- 1. Obtener el promedio de nota final por módulo.
SELECT 
    m.nombre as modulo,
    s.nombre as skill,
    r.nombre as ruta,
    COUNT(DISTINCT e.camper_id) as total_evaluados,
    ROUND(AVG(e.notaFinal), 2) as promedio_nota,
    MIN(e.notaFinal) as nota_minima,
    MAX(e.notaFinal) as nota_maxima,
    COUNT(CASE WHEN e.estado = 'Aprobado' THEN 1 END) as aprobados,
    COUNT(CASE WHEN e.estado = 'Reprobado' THEN 1 END) as reprobados
FROM Modulo m
JOIN Skill s ON m.skill_id = s.id
JOIN Ruta r ON s.ruta_id = r.id
LEFT JOIN Evaluacion e ON s.id = e.skill_id
GROUP BY m.id, m.nombre, s.nombre, r.nombre
ORDER BY AVG(e.notaFinal) DESC;

-- 2. Calcular la cantidad total de campers por ruta.
SELECT 
    r.nombre as ruta,
    COUNT(DISTINCT c.id) as total_campers,
    COUNT(DISTINCT CASE WHEN ec.estado = 'Cursando' THEN c.id END) as cursando,
    COUNT(DISTINCT CASE WHEN ec.estado = 'Graduado' THEN c.id END) as graduados,
    COUNT(DISTINCT CASE WHEN ri.nivel = 'Alto' THEN c.id END) as alto_riesgo,
    ROUND(AVG(e.notaFinal), 2) as promedio_general
FROM Ruta r
JOIN Trainer t ON r.id = t.ruta_id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN CamperGrupo cg ON aae.grupo_id = cg.grupo_id
JOIN Camper c ON cg.camper_id = c.id
JOIN EstadoCamper ec ON c.estado_id = ec.id
JOIN Riesgo ri ON c.riesgo_id = ri.id
LEFT JOIN Evaluacion e ON c.id = e.camper_id
GROUP BY r.id, r.nombre
ORDER BY COUNT(DISTINCT c.id) DESC;

-- 3. Mostrar la cantidad de evaluaciones realizadas por cada trainer (según las rutas que imparte).
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    r.nombre as ruta,
    COUNT(DISTINCT e.id) as total_evaluaciones,
    COUNT(DISTINCT e.camper_id) as campers_evaluados,
    ROUND(AVG(e.notaFinal), 2) as promedio_evaluaciones,
    COUNT(CASE WHEN e.estado = 'Aprobado' THEN 1 END) as aprobados
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
JOIN Ruta r ON t.ruta_id = r.id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN CamperGrupo cg ON aae.grupo_id = cg.grupo_id
JOIN Evaluacion e ON cg.camper_id = e.camper_id
GROUP BY t.id, p.nombre, p.apellido, r.nombre
ORDER BY COUNT(DISTINCT e.id) DESC;

-- 4. Consultar el promedio general de rendimiento por cada área de entrenamiento.
SELECT 
    ae.nombre as area,
    s.nombre as sede,
    COUNT(DISTINCT cg.camper_id) as total_campers,
    ROUND(AVG(e.notaFinal), 2) as promedio_general,
    COUNT(DISTINCT CASE WHEN e.estado = 'Aprobado' THEN e.id END) as evaluaciones_aprobadas,
    COUNT(DISTINCT CASE WHEN e.estado = 'Reprobado' THEN e.id END) as evaluaciones_reprobadas,
    ROUND(COUNT(DISTINCT CASE WHEN e.estado = 'Aprobado' THEN e.id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT e.id), 0), 2) as porcentaje_aprobacion
FROM AreaEntrenamiento ae
JOIN Sede s ON ae.sede_id = s.id
JOIN AsignacionAreaEntrenamiento aae ON ae.id = aae.area_id
JOIN Grupo g ON aae.grupo_id = g.id
JOIN CamperGrupo cg ON g.id = cg.grupo_id
JOIN Evaluacion e ON cg.camper_id = e.camper_id
GROUP BY ae.id, ae.nombre, s.nombre
ORDER BY AVG(e.notaFinal) DESC;

-- 5. Obtener la cantidad de módulos asociados a cada ruta de entrenamiento.
SELECT 
    r.nombre as ruta,
    COUNT(DISTINCT s.id) as total_skills,
    COUNT(DISTINCT m.id) as total_modulos,
    GROUP_CONCAT(DISTINCT m.nombre ORDER BY m.nombre) as modulos,
    COUNT(DISTINCT e.camper_id) as campers_evaluados,
    ROUND(AVG(e.notaFinal), 2) as promedio_general
FROM Ruta r
JOIN Skill s ON r.id = s.ruta_id
JOIN Modulo m ON s.id = m.skill_id
LEFT JOIN Evaluacion e ON s.id = e.skill_id
GROUP BY r.id, r.nombre
ORDER BY COUNT(DISTINCT m.id) DESC;

-- 6. Mostrar el promedio de nota final de los campers en estado "Cursando".
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    r.nombre as ruta,
    COUNT(DISTINCT e.id) as total_evaluaciones,
    ROUND(AVG(e.notaFinal), 2) as promedio_general,
    MIN(e.notaFinal) as nota_minima,
    MAX(e.notaFinal) as nota_maxima
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
JOIN EstadoCamper ec ON c.estado_id = ec.id
JOIN CamperGrupo cg ON c.id = cg.camper_id
JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
JOIN Trainer t ON aae.trainer_id = t.id
JOIN Ruta r ON t.ruta_id = r.id
JOIN Evaluacion e ON c.id = e.camper_id
WHERE ec.estado = 'Cursando'
GROUP BY c.id, p.nombre, p.apellido, r.nombre
ORDER BY AVG(e.notaFinal) DESC;

-- 7. Listar el número de campers evaluados en cada módulo.
SELECT 
    m.nombre as modulo,
    s.nombre as skill,
    r.nombre as ruta,
    COUNT(DISTINCT e.camper_id) as campers_evaluados,
    COUNT(DISTINCT CASE WHEN e.estado = 'Aprobado' THEN e.camper_id END) as aprobados,
    COUNT(DISTINCT CASE WHEN e.estado = 'Reprobado' THEN e.camper_id END) as reprobados,
    ROUND(AVG(e.notaFinal), 2) as promedio_modulo
FROM Modulo m
JOIN Skill s ON m.skill_id = s.id
JOIN Ruta r ON s.ruta_id = r.id
LEFT JOIN Evaluacion e ON s.id = e.skill_id
GROUP BY m.id, m.nombre, s.nombre, r.nombre
ORDER BY COUNT(DISTINCT e.camper_id) DESC;

-- 8. Consultar el porcentaje de ocupación actual por cada área de entrenamiento.
SELECT 
    ae.nombre as area,
    s.nombre as sede,
    SUM(g.capacidad) as capacidad_total,
    COUNT(DISTINCT cg.camper_id) as ocupacion_actual,
    ROUND(COUNT(DISTINCT cg.camper_id) * 100.0 / NULLIF(SUM(g.capacidad), 0), 2) as porcentaje_ocupacion,
    GROUP_CONCAT(DISTINCT CONCAT(p.nombre, ' ', p.apellido)) as trainers_asignados
FROM AreaEntrenamiento ae
JOIN Sede s ON ae.sede_id = s.id
JOIN AsignacionAreaEntrenamiento aae ON ae.id = aae.area_id
JOIN Grupo g ON aae.grupo_id = g.id
LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
JOIN Trainer t ON aae.trainer_id = t.id
JOIN Persona p ON t.persona_id = p.id
GROUP BY ae.id, ae.nombre, s.nombre, g.capacidad
ORDER BY porcentaje_ocupacion DESC;

-- 9. Mostrar cuántos trainers tiene asignados cada área.
SELECT 
    ae.nombre as area,
    s.nombre as sede,
    COUNT(DISTINCT t.id) as total_trainers,
    GROUP_CONCAT(DISTINCT CONCAT(p.nombre, ' ', p.apellido)) as trainers,
    COUNT(DISTINCT cg.camper_id) as total_campers,
    COUNT(DISTINCT g.id) as total_grupos
FROM AreaEntrenamiento ae
JOIN Sede s ON ae.sede_id = s.id
JOIN AsignacionAreaEntrenamiento aae ON ae.id = aae.area_id
JOIN Trainer t ON aae.trainer_id = t.id
JOIN Persona p ON t.persona_id = p.id
JOIN Grupo g ON aae.grupo_id = g.id
LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
GROUP BY ae.id, ae.nombre, s.nombre, g.capacidad
ORDER BY COUNT(DISTINCT t.id) DESC;

-- 10. Listar las rutas que tienen más campers en riesgo alto.
SELECT 
    r.nombre as ruta,
    COUNT(DISTINCT c.id) as total_campers,
    COUNT(DISTINCT CASE WHEN ri.nivel = 'Alto' THEN c.id END) as campers_alto_riesgo,
    ROUND(COUNT(DISTINCT CASE WHEN ri.nivel = 'Alto' THEN c.id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT c.id), 0), 2) as porcentaje_alto_riesgo,
    ROUND(AVG(e.notaFinal), 2) as promedio_general
FROM Ruta r
JOIN Trainer t ON r.id = t.ruta_id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN CamperGrupo cg ON aae.grupo_id = cg.grupo_id
JOIN Camper c ON cg.camper_id = c.id
JOIN Riesgo ri ON c.riesgo_id = ri.id
LEFT JOIN Evaluacion e ON c.id = e.camper_id
GROUP BY r.id, r.nombre
HAVING COUNT(DISTINCT CASE WHEN ri.nivel = 'Alto' THEN c.id END) > 0
ORDER BY COUNT(DISTINCT CASE WHEN ri.nivel = 'Alto' THEN c.id END) DESC;