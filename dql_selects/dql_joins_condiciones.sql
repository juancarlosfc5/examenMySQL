-- JOINs con condiciones específicas

-- 1. Listar los campers que han aprobado todos los módulos de su ruta (nota_final >= 60).
WITH ModulosPorRuta AS (
    SELECT r.id, COUNT(DISTINCT m.id) as total_modulos
    FROM Ruta r
    JOIN Skill s ON r.id = s.ruta_id
    JOIN Modulo m ON s.id = m.skill_id
    GROUP BY r.id
),
ModulosAprobadosPorCamper AS (
    SELECT 
        c.id as camper_id,
        t.ruta_id,
        COUNT(DISTINCT CASE WHEN e.notaFinal >= 60 THEN m.id END) as modulos_aprobados
    FROM Camper c
    JOIN CamperGrupo cg ON c.id = cg.camper_id
    JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
    JOIN Trainer t ON aae.trainer_id = t.id
    JOIN Evaluacion e ON c.id = e.camper_id
    JOIN Skill s ON e.skill_id = s.id
    JOIN Modulo m ON s.id = m.skill_id
    GROUP BY c.id, t.ruta_id
)
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    r.nombre as ruta,
    mac.modulos_aprobados,
    mpr.total_modulos,
    ROUND(AVG(e.notaFinal), 2) as promedio_general
FROM ModulosAprobadosPorCamper mac
JOIN ModulosPorRuta mpr ON mac.ruta_id = mpr.id
JOIN Camper c ON mac.camper_id = c.id
JOIN Persona p ON c.persona_id = p.id
JOIN Ruta r ON mac.ruta_id = r.id
JOIN Evaluacion e ON c.id = e.camper_id
WHERE mac.modulos_aprobados = mpr.total_modulos
GROUP BY c.id, p.nombre, p.apellido, r.nombre, mac.modulos_aprobados, mpr.total_modulos;

-- 2. Mostrar las rutas que tienen más de 10 campers inscritos actualmente.
SELECT 
    r.nombre as ruta,
    COUNT(DISTINCT c.id) as total_campers,
    GROUP_CONCAT(DISTINCT CONCAT(p.nombre, ' ', p.apellido)) as campers
FROM Ruta r
JOIN Trainer t ON r.id = t.ruta_id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN CamperGrupo cg ON aae.grupo_id = cg.grupo_id
JOIN Camper c ON cg.camper_id = c.id
JOIN Persona p ON c.persona_id = p.id
JOIN EstadoCamper ec ON c.estado_id = ec.id
WHERE ec.estado IN ('Inscrito', 'Cursando')
GROUP BY r.id, r.nombre
HAVING COUNT(DISTINCT c.id) > 10
ORDER BY COUNT(DISTINCT c.id) DESC;

-- 3. Consultar las áreas que superan el 80% de su capacidad con el número actual de campers asignados.
SELECT 
    ae.nombre as area,
    s.nombre as sede,
    SUM(g.capacidad) as capacidad_total,
    COUNT(DISTINCT cg.camper_id) as campers_actuales,
    ROUND(COUNT(DISTINCT cg.camper_id) * 100.0 / SUM(g.capacidad), 2) as porcentaje_ocupacion
FROM AreaEntrenamiento ae
JOIN Sede s ON ae.sede_id = s.id
JOIN AsignacionAreaEntrenamiento aae ON ae.id = aae.area_id
JOIN Grupo g ON aae.grupo_id = g.id
LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
GROUP BY ae.id, ae.nombre, s.nombre
HAVING porcentaje_ocupacion > 80
ORDER BY porcentaje_ocupacion DESC;

-- 4. Obtener los trainers que imparten más de una ruta diferente.
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
HAVING COUNT(DISTINCT r.id) > 1
ORDER BY COUNT(DISTINCT r.id) DESC;

-- 5. Listar las evaluaciones donde la nota práctica es mayor que la nota teórica.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    m.nombre as modulo,
    MAX(CASE WHEN te.nombre = 'Examen' THEN n.nota END) as nota_teorica,
    MAX(CASE WHEN te.nombre = 'Proyecto' THEN n.nota END) as nota_practica,
    e.notaFinal
FROM Evaluacion e
JOIN Camper c ON e.camper_id = c.id
JOIN Persona p ON c.persona_id = p.id
JOIN Skill s ON e.skill_id = s.id
JOIN Modulo m ON s.id = m.skill_id
JOIN Nota n ON e.id = n.evaluacion_id
JOIN TipoEvaluacion te ON n.tipoEvaluacion_id = te.id
GROUP BY e.id, p.nombre, p.apellido, m.nombre, e.notaFinal
HAVING nota_practica > nota_teorica
ORDER BY (nota_practica - nota_teorica) DESC;

-- 6. Mostrar campers que están en rutas cuyo SGDB principal es MySQL.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    r.nombre as ruta,
    b.nombre as sgbd_principal,
    ec.estado as estado_camper
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
JOIN EstadoCamper ec ON c.estado_id = ec.id
JOIN CamperGrupo cg ON c.id = cg.camper_id
JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
JOIN Trainer t ON aae.trainer_id = t.id
JOIN Ruta r ON t.ruta_id = r.id
JOIN Basedatos b ON r.SGBD1_id = b.id
WHERE b.nombre = 'MySQL'
ORDER BY p.nombre, p.apellido;

-- 7. Obtener los nombres de los módulos donde los campers han tenido bajo rendimiento.
SELECT 
    m.nombre as modulo,
    s.nombre as skill,
    r.nombre as ruta,
    COUNT(DISTINCT e.camper_id) as total_evaluados,
    ROUND(AVG(e.notaFinal), 2) as promedio,
    COUNT(CASE WHEN e.notaFinal < 60 THEN 1 END) as reprobados
FROM Modulo m
JOIN Skill s ON m.skill_id = s.id
JOIN Ruta r ON s.ruta_id = r.id
JOIN Evaluacion e ON s.id = e.skill_id
GROUP BY m.id, m.nombre, s.nombre, r.nombre
HAVING AVG(e.notaFinal) < 60
ORDER BY AVG(e.notaFinal);

-- 8. Consultar las rutas con más de 3 módulos asociados.
SELECT 
    r.nombre as ruta,
    COUNT(DISTINCT m.id) as total_modulos,
    GROUP_CONCAT(DISTINCT m.nombre) as modulos
FROM Ruta r
JOIN Skill s ON r.id = s.ruta_id
JOIN Modulo m ON s.id = m.skill_id
GROUP BY r.id, r.nombre
HAVING COUNT(DISTINCT m.id) > 3
ORDER BY COUNT(DISTINCT m.id) DESC;

-- 9. Listar las inscripciones realizadas en los últimos 30 días con sus respectivos campers y rutas.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    r.nombre as ruta,
    ec.estado,
    c.fechaIngreso
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
JOIN EstadoCamper ec ON c.estado_id = ec.id
JOIN CamperGrupo cg ON c.id = cg.camper_id
JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
JOIN Trainer t ON aae.trainer_id = t.id
JOIN Ruta r ON t.ruta_id = r.id
WHERE c.fechaIngreso >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)
ORDER BY c.fechaIngreso DESC;

-- 10. Obtener los trainers que están asignados a rutas con campers en estado de "Alto Riesgo"
SELECT DISTINCT
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    r.nombre as ruta,
    COUNT(DISTINCT c.id) as campers_alto_riesgo
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
JOIN Ruta r ON t.ruta_id = r.id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN CamperGrupo cg ON aae.grupo_id = cg.grupo_id
JOIN Camper c ON cg.camper_id = c.id
JOIN Riesgo ri ON c.riesgo_id = ri.id
WHERE ri.nivel = 'Alto'
GROUP BY t.id, p.nombre, p.apellido, r.nombre
ORDER BY COUNT(DISTINCT c.id) DESC;