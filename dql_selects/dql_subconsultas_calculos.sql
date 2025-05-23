-- Consultas con subconsultas y calculos avanzados

-- 1. Obtener los campers con la nota más alta en cada módulo.
SELECT 
    m.nombre as modulo,
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    e.notaFinal as nota_final,
    r.nombre as ruta
FROM Evaluacion e
JOIN Skill s ON e.skill_id = s.id
JOIN Modulo m ON s.id = m.skill_id
JOIN Camper c ON e.camper_id = c.id
JOIN Persona p ON c.persona_id = p.id
JOIN Ruta r ON s.ruta_id = r.id
WHERE e.notaFinal = (
    SELECT MAX(e_sub.notaFinal)
    FROM Evaluacion e_sub
    WHERE e_sub.skill_id = e.skill_id
)
ORDER BY m.nombre, e.notaFinal DESC;

-- 2. Mostrar el promedio general de notas por ruta y comparar con el promedio global.
SELECT 
    r.nombre as ruta,
    COUNT(DISTINCT e.camper_id) as total_campers,
    ROUND(AVG(e.notaFinal), 2) as promedio_ruta,
    ROUND((SELECT AVG(notaFinal) FROM Evaluacion), 2) as promedio_global,
    ROUND(AVG(e.notaFinal) - (SELECT AVG(notaFinal) FROM Evaluacion), 2) as diferencia
FROM Evaluacion e
JOIN Skill s ON e.skill_id = s.id
JOIN Ruta r ON s.ruta_id = r.id
GROUP BY r.id, r.nombre
ORDER BY AVG(e.notaFinal) DESC;

-- 3. Listar las áreas con más del 80% de ocupación.
SELECT 
    ae.nombre,
    COUNT(DISTINCT cg.camper_id) as campers_actuales,
    SUM(g.capacidad) as capacidad_total,
    ROUND(COUNT(DISTINCT cg.camper_id) * 100.0 / SUM(g.capacidad), 2) as porcentaje_ocupacion
FROM AreaEntrenamiento ae
JOIN AsignacionAreaEntrenamiento aae ON ae.id = aae.area_id
JOIN Grupo g ON aae.grupo_id = g.id
LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
GROUP BY ae.id, ae.nombre
HAVING porcentaje_ocupacion > 80
ORDER BY porcentaje_ocupacion DESC;

-- 4. Mostrar los trainers con menos del 70% de rendimiento promedio.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    COUNT(DISTINCT e.camper_id) as total_evaluados,
    ROUND(AVG(e.notaFinal), 2) as promedio_notas,
    ROUND(COUNT(CASE WHEN e.estado = 'Aprobado' THEN 1 END) * 100.0 / COUNT(e.id), 2) as porcentaje_aprobacion
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN CamperGrupo cg ON aae.grupo_id = cg.grupo_id
JOIN Evaluacion e ON cg.camper_id = e.camper_id
GROUP BY t.id, p.nombre, p.apellido
HAVING porcentaje_aprobacion < 70
ORDER BY porcentaje_aprobacion;

-- 5. Consultar los campers cuyo promedio está por debajo del promedio general.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    ROUND(AVG(e.notaFinal), 2) as promedio_individual,
    (SELECT ROUND(AVG(notaFinal), 2) FROM Evaluacion) as promedio_general
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
JOIN Evaluacion e ON c.id = e.camper_id
GROUP BY c.id, p.nombre, p.apellido
HAVING promedio_individual < promedio_general
ORDER BY promedio_individual;

-- 6. Obtener los módulos con la menor tasa de aprobación.
SELECT 
    m.nombre as modulo,
    s.nombre as skill,
    r.nombre as ruta,
    COUNT(DISTINCT e.camper_id) as total_evaluados,
    COUNT(CASE WHEN e.estado = 'Aprobado' THEN 1 END) as aprobados,
    COUNT(CASE WHEN e.estado = 'Reprobado' THEN 1 END) as reprobados,
    ROUND(COUNT(CASE WHEN e.estado = 'Aprobado' THEN 1 END) * 100.0 / COUNT(e.id), 2) as porcentaje_aprobacion
FROM Modulo m
JOIN Skill s ON m.skill_id = s.id
JOIN Ruta r ON s.ruta_id = r.id
JOIN Evaluacion e ON s.id = e.skill_id
GROUP BY m.id, m.nombre, s.nombre, r.nombre
HAVING COUNT(e.id) > 0
ORDER BY porcentaje_aprobacion ASC
LIMIT 5;

-- 7. Listar los campers que han aprobado todos los módulos de su ruta.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    r.nombre as ruta,
    COUNT(DISTINCT CASE WHEN e.estado = 'Aprobado' THEN m.id END) as modulos_aprobados,
    COUNT(DISTINCT m.id) as total_modulos,
    ROUND(AVG(e.notaFinal), 2) as promedio_general
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
JOIN CamperGrupo cg ON c.id = cg.camper_id
JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
JOIN Trainer t ON aae.trainer_id = t.id
JOIN Ruta r ON t.ruta_id = r.id
JOIN Skill s ON r.id = s.ruta_id
JOIN Modulo m ON s.id = m.skill_id
JOIN Evaluacion e ON c.id = e.camper_id
GROUP BY c.id, p.nombre, p.apellido, r.id, r.nombre
HAVING modulos_aprobados = total_modulos;

-- 8. Mostrar rutas con más de 10 campers en bajo rendimiento.
SELECT 
    r.nombre as ruta,
    COUNT(DISTINCT CASE WHEN e.estado = 'Reprobado' THEN c.id END) as campers_bajo_rendimiento,
    COUNT(DISTINCT m.id) as total_modulos,
    GROUP_CONCAT(DISTINCT CONCAT(p.nombre, ' ', p.apellido)) as trainers
FROM Ruta r
JOIN Trainer t ON r.id = t.ruta_id
JOIN Persona p ON t.persona_id = p.id
JOIN Skill s ON r.id = s.ruta_id
JOIN Modulo m ON s.id = m.skill_id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN CamperGrupo cg ON aae.grupo_id = cg.grupo_id
JOIN Camper c ON cg.camper_id = c.id
JOIN Evaluacion e ON c.id = e.camper_id
GROUP BY r.id, r.nombre
HAVING campers_bajo_rendimiento > 10;

-- 9. Calcular el promedio de rendimiento por SGDB principal.
SELECT 
    b.nombre as sgbd,
    COUNT(DISTINCT r.id) as total_rutas,
    COUNT(DISTINCT e.camper_id) as total_campers,
    ROUND(AVG(e.notaFinal), 2) as promedio_notas,
    ROUND(COUNT(CASE WHEN e.estado = 'Aprobado' THEN 1 END) * 100.0 / COUNT(e.id), 2) as porcentaje_aprobacion
FROM Basedatos b
JOIN Ruta r ON b.id = r.SGBD1_id
JOIN Skill s ON r.id = s.ruta_id
JOIN Evaluacion e ON s.id = e.skill_id
GROUP BY b.id, b.nombre
ORDER BY AVG(e.notaFinal) DESC;

-- 10. Listar los módulos con al menos un 30% de campers reprobados.
SELECT 
    m.nombre as modulo,
    s.nombre as skill,
    r.nombre as ruta,
    COUNT(DISTINCT e.camper_id) as total_evaluados,
    COUNT(DISTINCT CASE WHEN e.estado = 'Reprobado' THEN e.camper_id END) as reprobados,
    ROUND(COUNT(DISTINCT CASE WHEN e.estado = 'Reprobado' THEN e.camper_id END) * 100.0 / 
        COUNT(DISTINCT e.camper_id), 2) as porcentaje_reprobados
FROM Modulo m
JOIN Skill s ON m.skill_id = s.id
JOIN Ruta r ON s.ruta_id = r.id
JOIN Evaluacion e ON s.id = e.skill_id
GROUP BY m.id, m.nombre, s.nombre, r.nombre
HAVING porcentaje_reprobados >= 30
ORDER BY porcentaje_reprobados DESC;

-- 11. Mostrar el módulo más cursado por campers con riesgo alto.
SELECT 
    m.nombre as modulo,
    s.nombre as skill,
    r.nombre as ruta,
    ri.nivel as nivel_riesgo,
    COUNT(DISTINCT c.id) as total_campers,
    ROUND(AVG(e.notaFinal), 2) as promedio_notas
FROM Modulo m
JOIN Skill s ON m.skill_id = s.id
JOIN Ruta r ON s.ruta_id = r.id
JOIN Evaluacion e ON s.id = e.skill_id
JOIN Camper c ON e.camper_id = c.id
JOIN Riesgo ri ON c.riesgo_id = ri.id
WHERE ri.nivel = 'Alto'
GROUP BY m.id, m.nombre, s.nombre, r.nombre, ri.nivel
ORDER BY COUNT(DISTINCT c.id) DESC
LIMIT 1;

-- 12. Consultar los trainers con más de 3 rutas asignadas.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    COUNT(DISTINCT r.id) as total_rutas,
    GROUP_CONCAT(DISTINCT r.nombre) as rutas_asignadas
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN CamperGrupo cg ON aae.grupo_id = cg.grupo_id
JOIN Evaluacion e ON cg.camper_id = e.camper_id
JOIN Skill s ON e.skill_id = s.id
JOIN Ruta r ON s.ruta_id = r.id
GROUP BY t.id, p.nombre, p.apellido
HAVING total_rutas > 3;

-- 13. Listar los horarios más ocupados por áreas.
SELECT 
    h.horaInicio,
    h.horaFin,
    ae.nombre as area,
    COUNT(DISTINCT cg.camper_id) as total_campers,
    GROUP_CONCAT(DISTINCT CONCAT(p.nombre, ' ', p.apellido)) as trainers
FROM Horario h
JOIN AsignacionAreaEntrenamiento aae ON h.id = aae.horario_id
JOIN AreaEntrenamiento ae ON aae.area_id = ae.id
JOIN Grupo g ON aae.grupo_id = g.id
JOIN CamperGrupo cg ON g.id = cg.grupo_id
JOIN Trainer t ON aae.trainer_id = t.id
JOIN Persona p ON t.persona_id = p.id
GROUP BY h.id, h.horaInicio, h.horaFin, ae.id, ae.nombre
ORDER BY COUNT(DISTINCT cg.camper_id) DESC;

-- 14. Consultar las rutas con el mayor número de módulos.
SELECT 
    r.nombre as ruta,
    COUNT(DISTINCT s.id) as total_skills,
    COUNT(DISTINCT m.id) as total_modulos,
    GROUP_CONCAT(DISTINCT m.nombre) as modulos
FROM Ruta r
JOIN Skill s ON r.id = s.ruta_id
JOIN Modulo m ON s.id = m.skill_id
GROUP BY r.id, r.nombre
ORDER BY COUNT(DISTINCT m.id) DESC;

-- 15. Obtener los campers que han cambiado de estado más de una vez.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    COUNT(DISTINCT e.estado) as total_cambios_estado,
    r.nombre as ruta_actual,
    ec.estado as estado_actual
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
JOIN Evaluacion e ON c.id = e.camper_id
JOIN EstadoCamper ec ON c.estado_id = ec.id
JOIN CamperGrupo cg ON c.id = cg.camper_id
JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
JOIN Trainer t ON aae.trainer_id = t.id
JOIN Ruta r ON t.ruta_id = r.id
GROUP BY c.id, p.nombre, p.apellido, r.nombre, ec.estado
HAVING total_cambios_estado > 1
ORDER BY total_cambios_estado DESC;

-- 16. Mostrar las evaluaciones donde la nota teórica sea mayor a la práctica.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    m.nombre as modulo,
    MAX(CASE WHEN te.nombre = 'Examen' THEN n.nota END) as nota_teorica,
    MAX(CASE WHEN te.nombre = 'Proyecto' THEN n.nota END) as nota_practica,
    (MAX(CASE WHEN te.nombre = 'Examen' THEN n.nota END) - 
     MAX(CASE WHEN te.nombre = 'Proyecto' THEN n.nota END)) as diferencia
FROM Evaluacion e
JOIN Camper c ON e.camper_id = c.id
JOIN Persona p ON c.persona_id = p.id
JOIN Skill s ON e.skill_id = s.id
JOIN Modulo m ON s.id = m.skill_id
JOIN Nota n ON e.id = n.evaluacion_id
JOIN TipoEvaluacion te ON n.tipoEvaluacion_id = te.id
GROUP BY e.id, p.nombre, p.apellido, m.nombre
HAVING nota_teorica > nota_practica
ORDER BY diferencia DESC;

-- 17. Listar los módulos donde la media de quizzes supera el 9.
SELECT 
    m.nombre as modulo,
    s.nombre as skill,
    r.nombre as ruta,
    COUNT(DISTINCT e.camper_id) as total_evaluados,
    ROUND(AVG(CASE WHEN te.nombre = 'Actividad' THEN n.nota END), 2) as promedio_quizzes
FROM Modulo m
JOIN Skill s ON m.skill_id = s.id
JOIN Ruta r ON s.ruta_id = r.id
JOIN Evaluacion e ON s.id = e.skill_id
JOIN Nota n ON e.id = n.evaluacion_id
JOIN TipoEvaluacion te ON n.tipoEvaluacion_id = te.id
GROUP BY m.id, m.nombre, s.nombre, r.nombre
HAVING promedio_quizzes > 9
ORDER BY promedio_quizzes DESC;

-- 18. Consultar la ruta con mayor tasa de graduación.
SELECT 
    r.nombre as ruta,
    COUNT(DISTINCT c.id) as total_campers,
    COUNT(DISTINCT CASE WHEN ec.estado = 'Graduado' THEN c.id END) as graduados,
    ROUND(COUNT(DISTINCT CASE WHEN ec.estado = 'Graduado' THEN c.id END) * 100.0 / 
        COUNT(DISTINCT c.id), 2) as tasa_graduacion
FROM Ruta r
JOIN Trainer t ON r.id = t.ruta_id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN CamperGrupo cg ON aae.grupo_id = cg.grupo_id
JOIN Camper c ON cg.camper_id = c.id
JOIN EstadoCamper ec ON c.estado_id = ec.id
GROUP BY r.id, r.nombre
ORDER BY tasa_graduacion DESC
LIMIT 1;

-- 19. Mostrar los módulos cursados por campers de nivel de riesgo medio o alto.
SELECT 
    m.nombre as modulo,
    s.nombre as skill,
    r.nombre as ruta,
    ri.nivel as nivel_riesgo,
    COUNT(DISTINCT c.id) as total_campers,
    ROUND(AVG(e.notaFinal), 2) as promedio_notas
FROM Modulo m
JOIN Skill s ON m.skill_id = s.id
JOIN Ruta r ON s.ruta_id = r.id
JOIN Evaluacion e ON s.id = e.skill_id
JOIN Camper c ON e.camper_id = c.id
JOIN Riesgo ri ON c.riesgo_id = ri.id
WHERE ri.nivel IN ('Medio', 'Alto')
GROUP BY m.id, m.nombre, s.nombre, r.nombre, ri.nivel
ORDER BY ri.nivel, AVG(e.notaFinal);

-- 20. Obtener la diferencia entre capacidad y ocupación en cada área.
SELECT 
    ae.nombre as area,
    s.nombre as sede,
    SUM(g.capacidad) as capacidad_total,
    COUNT(DISTINCT cg.camper_id) as ocupacion_actual,
    SUM(g.capacidad) - COUNT(DISTINCT cg.camper_id) as espacios_disponibles,
    ROUND(COUNT(DISTINCT cg.camper_id) * 100.0 / SUM(g.capacidad), 2) as porcentaje_ocupacion
FROM AreaEntrenamiento ae
JOIN Sede s ON ae.sede_id = s.id
JOIN AsignacionAreaEntrenamiento aae ON ae.id = aae.area_id
JOIN Grupo g ON aae.grupo_id = g.id
LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
GROUP BY ae.id, ae.nombre, s.nombre
ORDER BY porcentaje_ocupacion DESC;