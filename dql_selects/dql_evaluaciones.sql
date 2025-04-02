-- Evaluaciones

-- 1. Obtener las notas teóricas, prácticas y quizzes de cada camper por módulo.
SELECT
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    s.nombre as skill,
    m.nombre as modulo,
    te.nombre as tipo_evaluacion,
    n.nota
FROM
    Evaluacion e
    JOIN Camper c ON e.camper_id = c.id
    JOIN Persona p ON c.persona_id = p.id
    JOIN Skill s ON e.skill_id = s.id
    JOIN Modulo m ON s.id = m.skill_id
    JOIN Nota n ON e.id = n.evaluacion_id
    JOIN TipoEvaluacion te ON n.tipoEvaluacion_id = te.id
ORDER BY p.nombre, p.apellido, s.nombre, m.nombre, te.nombre;

-- 2. Calcular la nota final de cada camper por módulo.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    s.nombre as skill,
    m.nombre as modulo,
    n1.nota as nota_examen,
    n2.nota as nota_proyecto,
    n3.nota as nota_actividad,
    ROUND( (n1.nota * 0.30) + (n2.nota * 0.60) + (n3.nota * 0.10), 2) as nota_final,
    CASE 
        WHEN (n1.nota * 0.30 + n2.nota * 0.60 + n3.nota * 0.10) >= 60 THEN 'Aprobado'
        ELSE 'Reprobado'
    END as estado
FROM Evaluacion e
JOIN Camper c ON e.camper_id = c.id
JOIN Persona p ON c.persona_id = p.id
JOIN Skill s ON e.skill_id = s.id
JOIN Modulo m ON s.id = m.skill_id
JOIN Nota n1 ON e.id = n1.evaluacion_id AND n1.tipoEvaluacion_id = 1
JOIN Nota n2 ON e.id = n2.evaluacion_id AND n2.tipoEvaluacion_id = 2
JOIN Nota n3 ON e.id = n3.evaluacion_id AND n3.tipoEvaluacion_id = 3
ORDER BY p.nombre, p.apellido, s.nombre, m.nombre;

-- 3. Mostrar los campers que reprobaron algún módulo (nota < 60).
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    s.nombre as skill,
    m.nombre as modulo,
    n1.nota as nota_examen,
    n2.nota as nota_proyecto,
    n3.nota as nota_actividad,
    ROUND((n1.nota * 0.30) + (n2.nota * 0.60) + (n3.nota * 0.10), 2) as nota_final
FROM Evaluacion e
JOIN Camper c ON e.camper_id = c.id
JOIN Persona p ON c.persona_id = p.id
JOIN Skill s ON e.skill_id = s.id
JOIN Modulo m ON s.id = m.skill_id
JOIN Nota n1 ON e.id = n1.evaluacion_id AND n1.tipoEvaluacion_id = 1
JOIN Nota n2 ON e.id = n2.evaluacion_id AND n2.tipoEvaluacion_id = 2
JOIN Nota n3 ON e.id = n3.evaluacion_id AND n3.tipoEvaluacion_id = 3
HAVING nota_final < 60
ORDER BY nota_final ASC;

-- 4. Listar los módulos con más campers en bajo rendimiento.
SELECT 
    m.nombre as modulo,
    s.nombre as skill,
    COUNT(e.id) as campers_reprobados,
    ROUND(
        AVG(
            (n1.nota * 0.30) + 
            (n2.nota * 0.60) + 
            (n3.nota * 0.10)
        ), 2) as promedio_notas
FROM Evaluacion e
JOIN Skill s ON e.skill_id = s.id
JOIN Modulo m ON s.id = m.skill_id
JOIN Nota n1 ON e.id = n1.evaluacion_id AND n1.tipoEvaluacion_id = 1
JOIN Nota n2 ON e.id = n2.evaluacion_id AND n2.tipoEvaluacion_id = 2
JOIN Nota n3 ON e.id = n3.evaluacion_id AND n3.tipoEvaluacion_id = 3
GROUP BY m.id, m.nombre, s.nombre
HAVING promedio_notas < 60
ORDER BY campers_reprobados DESC;

-- 5. Obtener el promedio de notas finales por cada módulo.
SELECT 
    m.nombre as modulo,
    s.nombre as skill,
    COUNT(DISTINCT e.camper_id) as total_campers,
    ROUND(
        AVG(
            (n1.nota * 0.30) + 
            (n2.nota * 0.60) + 
            (n3.nota * 0.10)
        ), 2) as promedio_nota,
    ROUND(
        MIN(
            (n1.nota * 0.30) + 
            (n2.nota * 0.60) + 
            (n3.nota * 0.10)
        ), 2) as nota_minima,
    ROUND(
        MAX(
            (n1.nota * 0.30) + 
            (n2.nota * 0.60) + 
            (n3.nota * 0.10)
        ), 2) as nota_maxima
FROM Evaluacion e
JOIN Skill s ON e.skill_id = s.id
JOIN Modulo m ON s.id = m.skill_id
JOIN Nota n1 ON e.id = n1.evaluacion_id AND n1.tipoEvaluacion_id = 1
JOIN Nota n2 ON e.id = n2.evaluacion_id AND n2.tipoEvaluacion_id = 2
JOIN Nota n3 ON e.id = n3.evaluacion_id AND n3.tipoEvaluacion_id = 3
GROUP BY m.id, m.nombre, s.nombre
ORDER BY promedio_nota DESC;

-- 6. Consultar el rendimiento general por ruta de entrenamiento.
SELECT 
    r.nombre as ruta,
    COUNT(DISTINCT e.camper_id) as total_campers,
    ROUND(
        AVG(
            (n1.nota * 0.30) + 
            (n2.nota * 0.60) + 
            (n3.nota * 0.10)
        ), 2) as promedio_general,
    COUNT(
        CASE WHEN ((n1.nota * 0.30) + (n2.nota * 0.60) + (n3.nota * 0.10)) >= 60 
        THEN 1 END
    ) as modulos_aprobados,
    COUNT(
        CASE WHEN ((n1.nota * 0.30) + (n2.nota * 0.60) + (n3.nota * 0.10)) < 60 
        THEN 1 END
    ) as modulos_reprobados
FROM Evaluacion e
JOIN Skill s ON e.skill_id = s.id
JOIN Ruta r ON s.ruta_id = r.id
JOIN Nota n1 ON e.id = n1.evaluacion_id AND n1.tipoEvaluacion_id = 1
JOIN Nota n2 ON e.id = n2.evaluacion_id AND n2.tipoEvaluacion_id = 2
JOIN Nota n3 ON e.id = n3.evaluacion_id AND n3.tipoEvaluacion_id = 3
GROUP BY r.id, r.nombre
ORDER BY promedio_general DESC;

-- 7. Mostrar los trainers responsables de campers con bajo rendimiento.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    r.nombre as ruta,
    COUNT(DISTINCT e.camper_id) as campers_bajo_rendimiento,
    ROUND(
        AVG(
            (n1.nota * 0.30) + 
            (n2.nota * 0.60) + 
            (n3.nota * 0.10)
        ), 2) as promedio_notas
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
JOIN Ruta r ON t.ruta_id = r.id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN CamperGrupo cg ON aae.grupo_id = cg.grupo_id
JOIN Evaluacion e ON cg.camper_id = e.camper_id
JOIN Nota n1 ON e.id = n1.evaluacion_id AND n1.tipoEvaluacion_id = 1
JOIN Nota n2 ON e.id = n2.evaluacion_id AND n2.tipoEvaluacion_id = 2
JOIN Nota n3 ON e.id = n3.evaluacion_id AND n3.tipoEvaluacion_id = 3
GROUP BY t.id, p.nombre, p.apellido, r.nombre
HAVING promedio_notas < 60
ORDER BY campers_bajo_rendimiento DESC;

-- 8. Comparar el promedio de rendimiento por trainer.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    r.nombre as ruta,
    COUNT(DISTINCT e.camper_id) as total_campers,
    ROUND(
        AVG(
            (n1.nota * 0.30) + 
            (n2.nota * 0.60) + 
            (n3.nota * 0.10)
        ), 2) as promedio_notas,
    ROUND(
        MIN(
            (n1.nota * 0.30) + 
            (n2.nota * 0.60) + 
            (n3.nota * 0.10)
        ), 2) as nota_minima,
    ROUND(
        MAX(
            (n1.nota * 0.30) + 
            (n2.nota * 0.60) + 
            (n3.nota * 0.10)
        ), 2) as nota_maxima
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
JOIN Ruta r ON t.ruta_id = r.id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN CamperGrupo cg ON aae.grupo_id = cg.grupo_id
JOIN Evaluacion e ON cg.camper_id = e.camper_id
JOIN Nota n1 ON e.id = n1.evaluacion_id AND n1.tipoEvaluacion_id = 1
JOIN Nota n2 ON e.id = n2.evaluacion_id AND n2.tipoEvaluacion_id = 2
JOIN Nota n3 ON e.id = n3.evaluacion_id AND n3.tipoEvaluacion_id = 3
GROUP BY t.id, p.nombre, p.apellido, r.nombre
ORDER BY promedio_notas DESC;

-- 9. Listar los mejores 5 campers por nota final en cada ruta.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    r.nombre as ruta,
    ROUND(
        AVG(
            (n1.nota * 0.30) + 
            (n2.nota * 0.60) + 
            (n3.nota * 0.10)
        ), 2) as promedio_final
FROM Evaluacion e
JOIN Camper c ON e.camper_id = c.id
JOIN Persona p ON c.persona_id = p.id
JOIN Skill s ON e.skill_id = s.id
JOIN Ruta r ON s.ruta_id = r.id
JOIN Nota n1 ON e.id = n1.evaluacion_id AND n1.tipoEvaluacion_id = 1
JOIN Nota n2 ON e.id = n2.evaluacion_id AND n2.tipoEvaluacion_id = 2
JOIN Nota n3 ON e.id = n3.evaluacion_id AND n3.tipoEvaluacion_id = 3
GROUP BY r.id, r.nombre, c.id, p.nombre, p.apellido
ORDER BY r.nombre, promedio_final DESC
LIMIT 5;

-- 10. Mostrar cuántos campers pasaron cada módulo por ruta.
SELECT 
    r.nombre as ruta,
    m.nombre as modulo,
    SUM(IF((n1.nota * 0.30 + n2.nota * 0.60 + n3.nota * 0.10) >= 60, 1, 0)) as aprobados,
    SUM(IF((n1.nota * 0.30 + n2.nota * 0.60 + n3.nota * 0.10) < 60, 1, 0)) as reprobados,
    ROUND(
        (SUM(IF((n1.nota * 0.30 + n2.nota * 0.60 + n3.nota * 0.10) >= 60, 1, 0)) * 100.0) /
        COUNT(DISTINCT e.camper_id), 2
    ) as porcentaje_aprobacion
FROM Evaluacion e
JOIN Skill s ON e.skill_id = s.id
JOIN Ruta r ON s.ruta_id = r.id
JOIN Modulo m ON s.id = m.skill_id
JOIN Nota n1 ON e.id = n1.evaluacion_id AND n1.tipoEvaluacion_id = 1
JOIN Nota n2 ON e.id = n2.evaluacion_id AND n2.tipoEvaluacion_id = 2
JOIN Nota n3 ON e.id = n3.evaluacion_id AND n3.tipoEvaluacion_id = 3
GROUP BY r.id, r.nombre, m.id, m.nombre
ORDER BY r.nombre, porcentaje_aprobacion DESC;