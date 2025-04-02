-- JOINs básicos

-- 1. Obtener los nombres completos de los campers junto con el nombre de la ruta a la que están inscritos.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    p.email,
    r.nombre as ruta,
    ec.estado as estado_actual
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
JOIN EstadoCamper ec ON c.estado_id = ec.id
JOIN CamperGrupo cg ON c.id = cg.camper_id
JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
JOIN Trainer t ON aae.trainer_id = t.id
JOIN Ruta r ON t.ruta_id = r.id
ORDER BY p.nombre, p.apellido;

-- 2. Mostrar los campers con sus evaluaciones (nota teórica, práctica, quizzes y nota final) por cada módulo.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    m.nombre as modulo,
    s.nombre as skill,
    MAX(CASE WHEN te.nombre = 'Examen' THEN n.nota END) as nota_teorica,
    MAX(CASE WHEN te.nombre = 'Proyecto' THEN n.nota END) as nota_practica,
    MAX(CASE WHEN te.nombre = 'Actividad' THEN n.nota END) as nota_quizzes,
    e.notaFinal,
    e.estado
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
JOIN Evaluacion e ON c.id = e.camper_id
JOIN Skill s ON e.skill_id = s.id
JOIN Modulo m ON s.id = m.skill_id
JOIN Nota n ON e.id = n.evaluacion_id
JOIN TipoEvaluacion te ON n.tipoEvaluacion_id = te.id
GROUP BY c.id, p.nombre, p.apellido, m.nombre, s.nombre, e.notaFinal, e.estado
ORDER BY p.nombre, p.apellido, m.nombre;

-- 3. Listar todos los módulos que componen cada ruta de entrenamiento.
SELECT 
    r.nombre as ruta,
    s.nombre as skill,
    m.nombre as modulo,
    COUNT(DISTINCT e.camper_id) as total_estudiantes,
    ROUND(AVG(e.notaFinal), 2) as promedio_modulo
FROM Ruta r
JOIN Skill s ON r.id = s.ruta_id
JOIN Modulo m ON s.id = m.skill_id
LEFT JOIN Evaluacion e ON s.id = e.skill_id
GROUP BY r.id, r.nombre, s.id, s.nombre, m.id, m.nombre
ORDER BY r.nombre, s.nombre, m.nombre;

-- 4. Consultar las rutas con sus trainers asignados y las áreas en las que imparten clases.
SELECT 
    r.nombre as ruta,
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    GROUP_CONCAT(DISTINCT ae.nombre) as areas_asignadas,
    COUNT(DISTINCT cg.camper_id) as total_campers
FROM Ruta r
JOIN Trainer t ON r.id = t.ruta_id
JOIN Persona p ON t.persona_id = p.id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN AreaEntrenamiento ae ON aae.area_id = ae.id
LEFT JOIN Grupo g ON aae.grupo_id = g.id
LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
GROUP BY r.id, r.nombre, t.id, p.nombre, p.apellido
ORDER BY r.nombre, p.nombre;

-- 5. Mostrar los campers junto con el trainer responsable de su ruta actual.
SELECT 
    CONCAT(pc.nombre, ' ', pc.apellido) as camper,
    CONCAT(pt.nombre, ' ', pt.apellido) as trainer,
    r.nombre as ruta,
    ae.nombre as area,
    g.nombre as grupo
FROM Camper c
JOIN Persona pc ON c.persona_id = pc.id
JOIN CamperGrupo cg ON c.id = cg.camper_id
JOIN Grupo g ON cg.grupo_id = g.id
JOIN AsignacionAreaEntrenamiento aae ON g.id = aae.grupo_id
JOIN Trainer t ON aae.trainer_id = t.id
JOIN Persona pt ON t.persona_id = pt.id
JOIN Ruta r ON t.ruta_id = r.id
JOIN AreaEntrenamiento ae ON aae.area_id = ae.id
ORDER BY pc.nombre, pc.apellido;

-- 6. Obtener el listado de evaluaciones realizadas con nombre de camper, módulo y ruta.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    r.nombre as ruta,
    m.nombre as modulo,
    e.notaFinal,
    e.estado,
    e.fechaEvaluacion
FROM Evaluacion e
JOIN Camper c ON e.camper_id = c.id
JOIN Persona p ON c.persona_id = p.id
JOIN Skill s ON e.skill_id = s.id
JOIN Modulo m ON s.id = m.skill_id
JOIN Ruta r ON s.ruta_id = r.id
ORDER BY e.fechaEvaluacion DESC;

-- 7. Listar los trainers y los horarios en que están asignados a las áreas de entrenamiento.
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
ORDER BY h.horaInicio;

-- 8. Consultar todos los campers junto con su estado actual y el nivel de riesgo.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    p.email,
    ec.estado as estado_actual,
    r.nivel as nivel_riesgo,
    rt.nombre as ruta
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
JOIN EstadoCamper ec ON c.estado_id = ec.id
JOIN Riesgo r ON c.riesgo_id = r.id
LEFT JOIN CamperGrupo cg ON c.id = cg.camper_id
LEFT JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
LEFT JOIN Trainer t ON aae.trainer_id = t.id
LEFT JOIN Ruta rt ON t.ruta_id = rt.id
ORDER BY r.nivel DESC, p.nombre;

-- 9. Obtener todos los módulos de cada ruta junto con su porcentaje teórico, práctico y de quizzes.
SELECT 
    r.nombre as ruta,
    m.nombre as modulo,
    COUNT(DISTINCT e.camper_id) as total_evaluados,
    ROUND(AVG(CASE WHEN te.nombre = 'Examen' THEN n.nota END), 2) as promedio_teorico,
    ROUND(AVG(CASE WHEN te.nombre = 'Proyecto' THEN n.nota END), 2) as promedio_practico,
    ROUND(AVG(CASE WHEN te.nombre = 'Actividad' THEN n.nota END), 2) as promedio_quizzes
FROM Ruta r
JOIN Skill s ON r.id = s.ruta_id
JOIN Modulo m ON s.id = m.skill_id
LEFT JOIN Evaluacion e ON s.id = e.skill_id
LEFT JOIN Nota n ON e.id = n.evaluacion_id
LEFT JOIN TipoEvaluacion te ON n.tipoEvaluacion_id = te.id
GROUP BY r.id, r.nombre, m.id, m.nombre
ORDER BY r.nombre, m.nombre;

-- 10. Mostrar los nombres de las áreas junto con los nombres de los campers que están asistiendo en esos espacios.
SELECT 
    ae.nombre as area,
    s.nombre as sede,
    GROUP_CONCAT(DISTINCT CONCAT(p.nombre, ' ', p.apellido)) as campers,
    COUNT(DISTINCT cg.camper_id) as total_campers,
    g.capacidad as capacidad_maxima
FROM AreaEntrenamiento ae
JOIN Sede s ON ae.sede_id = s.id
JOIN AsignacionAreaEntrenamiento aae ON ae.id = aae.area_id
JOIN Grupo g ON aae.grupo_id = g.id
LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
LEFT JOIN Camper c ON cg.camper_id = c.id
LEFT JOIN Persona p ON c.persona_id = p.id
GROUP BY ae.id, ae.nombre, s.nombre, g.capacidad
ORDER BY ae.nombre;