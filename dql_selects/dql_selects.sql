-- Campers

-- 1. Obtener todos los campers inscritos actualmente.
SELECT 
    p.identificacion,
    p.nombre,
    p.apellido,
    p.email,
    ec.estado
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
JOIN EstadoCamper ec ON c.estado_id = ec.id
WHERE ec.estado = 'Inscrito';

-- 2. Listar los campers con estado "Aprobado".
SELECT 
    p.identificacion,
    p.nombre,
    p.apellido,
    p.email,
    ec.estado
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
JOIN EstadoCamper ec ON c.estado_id = ec.id
WHERE ec.estado = 'Aprobado';

-- 3. Mostrar los campers que ya están cursando alguna ruta.
SELECT DISTINCT
    p.identificacion,
    p.nombre,
    p.apellido,
    r.nombre as ruta,
    ec.estado
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
JOIN EstadoCamper ec ON c.estado_id = ec.id
JOIN CamperGrupo cg ON c.id = cg.camper_id
JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
JOIN Trainer t ON aae.trainer_id = t.id
JOIN Ruta r ON t.ruta_id = r.id
WHERE ec.estado = 'Cursando';

-- 4. Consultar los campers graduados por cada ruta.
SELECT 
    r.nombre as ruta,
    COUNT(c.id) as total_graduados,
    GROUP_CONCAT(CONCAT(p.nombre, ' ', p.apellido)) as campers_graduados
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
JOIN EstadoCamper ec ON c.estado_id = ec.id
JOIN CamperGrupo cg ON c.id = cg.camper_id
JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
JOIN Trainer t ON aae.trainer_id = t.id
JOIN Ruta r ON t.ruta_id = r.id
WHERE ec.estado = 'Graduado'
GROUP BY r.id, r.nombre;

-- 5. Obtener los campers que se encuentran en estado "Expulsado" o "Retirado".
SELECT 
    p.identificacion,
    p.nombre,
    p.apellido,
    ec.estado,
    r.nivel as nivel_riesgo
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
JOIN EstadoCamper ec ON c.estado_id = ec.id
JOIN Riesgo r ON c.riesgo_id = r.id
WHERE ec.estado IN ('Expulsado', 'Retirado');

-- 6. Listar campers con nivel de riesgo "Alto".
SELECT 
    p.identificacion,
    p.nombre,
    p.apellido,
    ec.estado,
    r.nivel as nivel_riesgo
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
JOIN EstadoCamper ec ON c.estado_id = ec.id
JOIN Riesgo r ON c.riesgo_id = r.id
WHERE r.nivel = 'Alto';

-- 7. Mostrar el total de campers por cada nivel de riesgo.
SELECT 
    r.nivel as nivel_riesgo,
    COUNT(c.id) as total_campers
FROM Camper c
JOIN Riesgo r ON c.riesgo_id = r.id
GROUP BY r.id, r.nivel
ORDER BY COUNT(c.id) DESC;

-- 8. Obtener campers con más de un número telefónico registrado.
SELECT 
    p.identificacion,
    p.nombre,
    p.apellido,
    COUNT(t.id) as total_telefonos,
    GROUP_CONCAT(t.telefono) as telefonos
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
JOIN Telefono t ON p.id = t.persona_id
GROUP BY c.id, p.identificacion, p.nombre, p.apellido
HAVING COUNT(t.id) > 1;

-- 9. Listar los campers y sus respectivos acudientes y teléfonos.
SELECT 
    p.identificacion as camper_id,
    p.nombre as camper_nombre,
    p.apellido as camper_apellido,
    pa.nombre as acudiente_nombre,
    pa.apellido as acudiente_apellido,
    GROUP_CONCAT(DISTINCT t1.telefono) as telefonos_camper,
    GROUP_CONCAT(DISTINCT t2.telefono) as telefonos_acudiente
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
JOIN Acudiente a ON c.id = a.camper_id
JOIN Persona pa ON a.persona_id = pa.id
LEFT JOIN Telefono t1 ON p.id = t1.persona_id
LEFT JOIN Telefono t2 ON pa.id = t2.persona_id
GROUP BY c.id, p.identificacion, p.nombre, p.apellido, pa.nombre, pa.apellido;

-- 10. Mostrar campers que aún no han sido asignados a una ruta.
SELECT 
    p.identificacion,
    p.nombre,
    p.apellido,
    ec.estado
FROM Camper c
JOIN Persona p ON c.persona_id = p.id
JOIN EstadoCamper ec ON c.estado_id = ec.id
WHERE c.id NOT IN (
    SELECT DISTINCT cg.camper_id 
    FROM CamperGrupo cg
    JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
);

-- Evaluaciones

-- 1. Obtener las notas teóricas, prácticas y quizzes de cada camper por módulo.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    s.nombre as skill,
    m.nombre as modulo,
    MAX(CASE WHEN te.nombre = 'Examen' THEN n.nota END) as nota_teorica,
    MAX(CASE WHEN te.nombre = 'Proyecto' THEN n.nota END) as nota_practica,
    MAX(CASE WHEN te.nombre = 'Actividad' THEN n.nota END) as nota_quizzes
FROM Evaluacion e
JOIN Camper c ON e.camper_id = c.id
JOIN Persona p ON c.persona_id = p.id
JOIN Skill s ON e.skill_id = s.id
JOIN Modulo m ON s.id = m.skill_id
JOIN Nota n ON e.id = n.evaluacion_id
JOIN TipoEvaluacion te ON n.tipoEvaluacion_id = te.id
GROUP BY p.nombre, p.apellido, s.nombre, m.nombre;

-- 2. Calcular la nota final de cada camper por módulo.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    s.nombre as skill,
    m.nombre as modulo,
    e.notaFinal,
    e.estado
FROM Evaluacion e
JOIN Camper c ON e.camper_id = c.id
JOIN Persona p ON c.persona_id = p.id
JOIN Skill s ON e.skill_id = s.id
JOIN Modulo m ON s.id = m.skill_id
WHERE e.notaFinal IS NOT NULL;

-- 3. Mostrar los campers que reprobaron algún módulo (nota < 60).
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    s.nombre as skill,
    m.nombre as modulo,
    e.notaFinal
FROM Evaluacion e
JOIN Camper c ON e.camper_id = c.id
JOIN Persona p ON c.persona_id = p.id
JOIN Skill s ON e.skill_id = s.id
JOIN Modulo m ON s.id = m.skill_id
WHERE e.estado = 'Reprobado'
ORDER BY e.notaFinal ASC;

-- 4. Listar los módulos con más campers en bajo rendimiento.
SELECT 
    m.nombre as modulo,
    s.nombre as skill,
    COUNT(*) as campers_reprobados,
    AVG(e.notaFinal) as promedio_notas
FROM Evaluacion e
JOIN Skill s ON e.skill_id = s.id
JOIN Modulo m ON s.id = m.skill_id
WHERE e.estado = 'Reprobado'
GROUP BY m.id, m.nombre, s.nombre
ORDER BY COUNT(*) DESC;

-- 5. Obtener el promedio de notas finales por cada módulo.
SELECT 
    m.nombre as modulo,
    s.nombre as skill,
    COUNT(DISTINCT e.camper_id) as total_campers,
    ROUND(AVG(e.notaFinal), 2) as promedio_nota,
    MIN(e.notaFinal) as nota_minima,
    MAX(e.notaFinal) as nota_maxima
FROM Evaluacion e
JOIN Skill s ON e.skill_id = s.id
JOIN Modulo m ON s.id = m.skill_id
WHERE e.notaFinal IS NOT NULL
GROUP BY m.id, m.nombre, s.nombre
ORDER BY AVG(e.notaFinal) DESC;

-- 6. Consultar el rendimiento general por ruta de entrenamiento.
SELECT 
    r.nombre as ruta,
    COUNT(DISTINCT e.camper_id) as total_campers,
    ROUND(AVG(e.notaFinal), 2) as promedio_general,
    COUNT(CASE WHEN e.estado = 'Aprobado' THEN 1 END) as modulos_aprobados,
    COUNT(CASE WHEN e.estado = 'Reprobado' THEN 1 END) as modulos_reprobados
FROM Evaluacion e
JOIN Skill s ON e.skill_id = s.id
JOIN Ruta r ON s.ruta_id = r.id
GROUP BY r.id, r.nombre
ORDER BY AVG(e.notaFinal) DESC;

-- 7. Mostrar los trainers responsables de campers con bajo rendimiento.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    r.nombre as ruta,
    COUNT(DISTINCT e.camper_id) as campers_bajo_rendimiento,
    ROUND(AVG(e.notaFinal), 2) as promedio_notas
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
JOIN Ruta r ON t.ruta_id = r.id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN CamperGrupo cg ON aae.grupo_id = cg.grupo_id
JOIN Evaluacion e ON cg.camper_id = e.camper_id
WHERE e.estado = 'Reprobado'
GROUP BY t.id, p.nombre, p.apellido, r.nombre
ORDER BY COUNT(DISTINCT e.camper_id) DESC;

-- 8. Comparar el promedio de rendimiento por trainer.
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) as trainer,
    r.nombre as ruta,
    COUNT(DISTINCT e.camper_id) as total_campers,
    ROUND(AVG(e.notaFinal), 2) as promedio_notas,
    ROUND(MIN(e.notaFinal), 2) as nota_minima,
    ROUND(MAX(e.notaFinal), 2) as nota_maxima
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
JOIN Ruta r ON t.ruta_id = r.id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN CamperGrupo cg ON aae.grupo_id = cg.grupo_id
JOIN Evaluacion e ON cg.camper_id = e.camper_id
GROUP BY t.id, p.nombre, p.apellido, r.nombre
ORDER BY AVG(e.notaFinal) DESC;

-- 9. Listar los mejores 5 campers por nota final en cada ruta.
WITH RankedCampers AS (
    SELECT 
        CONCAT(p.nombre, ' ', p.apellido) as camper,
        r.nombre as ruta,
        ROUND(AVG(e.notaFinal), 2) as promedio,
        ROW_NUMBER() OVER (PARTITION BY r.id ORDER BY AVG(e.notaFinal) DESC) as ranking
    FROM Evaluacion e
    JOIN Camper c ON e.camper_id = c.id
    JOIN Persona p ON c.persona_id = p.id
    JOIN Skill s ON e.skill_id = s.id
    JOIN Ruta r ON s.ruta_id = r.id
    GROUP BY c.id, p.nombre, p.apellido, r.id, r.nombre
)
SELECT *
FROM RankedCampers
WHERE ranking <= 5
ORDER BY ruta, ranking;

-- 10. Mostrar cuántos campers pasaron cada módulo por ruta.
SELECT 
    r.nombre as ruta,
    m.nombre as modulo,
    COUNT(DISTINCT CASE WHEN e.estado = 'Aprobado' THEN e.camper_id END) as aprobados,
    COUNT(DISTINCT CASE WHEN e.estado = 'Reprobado' THEN e.camper_id END) as reprobados,
    ROUND(COUNT(DISTINCT CASE WHEN e.estado = 'Aprobado' THEN e.camper_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT e.camper_id), 0), 2) as porcentaje_aprobacion
FROM Evaluacion e
JOIN Skill s ON e.skill_id = s.id
JOIN Ruta r ON s.ruta_id = r.id
JOIN Modulo m ON s.id = m.skill_id
GROUP BY r.id, r.nombre, m.id, m.nombre
ORDER BY r.nombre, porcentaje_aprobacion DESC;

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
    m.nombre as modulo,
    COUNT(DISTINCT e.camper_id) as total_estudiantes,
    ROUND(AVG(e.notaFinal), 2) as promedio_modulo
FROM Ruta r
JOIN Skill s ON r.id = s.ruta_id
JOIN Modulo m ON s.id = m.skill_id
LEFT JOIN Evaluacion e ON s.id = e.skill_id
GROUP BY r.id, r.nombre, s.id, s.nombre, m.id, m.nombre
ORDER BY r.nombre, s.nombre, m.nombre;

-- 4. Consultar cuántos campers hay en cada ruta.
SELECT 
    r.nombre as ruta,
    COUNT(DISTINCT cg.camper_id) as total_campers,
    g.capacidad as capacidad_maxima,
    ROUND((COUNT(DISTINCT cg.camper_id) * 100.0 / g.capacidad), 2) as porcentaje_ocupacion
FROM Ruta r
JOIN Trainer t ON r.id = t.ruta_id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN Grupo g ON aae.grupo_id = g.id
LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
GROUP BY r.id, r.nombre, g.capacidad
ORDER BY total_campers DESC;

-- 5. Mostrar las áreas de entrenamiento y su capacidad máxima.
SELECT 
    ae.nombre as area,
    s.nombre as sede,
    COUNT(DISTINCT g.id) as grupos_asignados,
    SUM(g.capacidad) as capacidad_total,
    COUNT(DISTINCT cg.camper_id) as campers_actuales
FROM AreaEntrenamiento ae
JOIN Sede s ON ae.sede_id = s.id
LEFT JOIN AsignacionAreaEntrenamiento aae ON ae.id = aae.area_id
LEFT JOIN Grupo g ON aae.grupo_id = g.id
LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
GROUP BY ae.id, ae.nombre, s.nombre;

-- 6. Obtener las áreas que están ocupadas al 100%.
WITH OcupacionArea AS (
    SELECT 
        ae.id,
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
)
SELECT *
FROM OcupacionArea
WHERE porcentaje_ocupacion >= 100;

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
WITH TrainerRutas AS (
    SELECT 
        t.id,
        CONCAT(p.nombre, ' ', p.apellido) as trainer,
        COUNT(DISTINCT t.ruta_id) as total_rutas,
        GROUP_CONCAT(DISTINCT r.nombre) as rutas_asignadas
    FROM Trainer t
    JOIN Persona p ON t.persona_id = p.id
    JOIN Ruta r ON t.ruta_id = r.id
    GROUP BY t.id, p.nombre, p.apellido
)
SELECT *
FROM TrainerRutas
WHERE total_rutas > 1;

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
    ROUND(AVG(e.notaFinal), 2) as promedio_notas,
    COUNT(DISTINCT CASE WHEN e.estado = 'Aprobado' THEN e.camper_id END) as campers_aprobados
FROM Trainer t
JOIN Persona p ON t.persona_id = p.id
JOIN Ruta r ON t.ruta_id = r.id
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
JOIN Grupo g ON aae.grupo_id = g.id
JOIN CamperGrupo cg ON g.id = cg.grupo_id
JOIN Evaluacion e ON cg.camper_id = e.camper_id
GROUP BY t.id, p.nombre, p.apellido, r.nombre
HAVING COUNT(DISTINCT e.camper_id) > 0
ORDER BY AVG(e.notaFinal) DESC
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

-- Consultas con subconsultas y calculos avanzados

-- 1. Obtener los campers con la nota más alta en cada módulo.
WITH NotasMaximas AS (
    SELECT 
        s.id as skill_id,
        m.nombre as modulo,
        MAX(e.notaFinal) as nota_maxima
    FROM Evaluacion e
    JOIN Skill s ON e.skill_id = s.id
    JOIN Modulo m ON s.id = m.skill_id
    GROUP BY s.id, m.nombre
)
SELECT 
    m.nombre as modulo,
    CONCAT(p.nombre, ' ', p.apellido) as camper,
    e.notaFinal,
    r.nombre as ruta
FROM NotasMaximas nm
JOIN Evaluacion e ON e.notaFinal = nm.nota_maxima
JOIN Skill s ON e.skill_id = s.id AND s.id = nm.skill_id
JOIN Modulo m ON s.id = m.skill_id
JOIN Camper c ON e.camper_id = c.id
JOIN Persona p ON c.persona_id = p.id
JOIN CamperGrupo cg ON c.id = cg.camper_id
JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
JOIN Trainer t ON aae.trainer_id = t.id
JOIN Ruta r ON t.ruta_id = r.id
ORDER BY m.nombre;

-- 2. Mostrar el promedio general de notas por ruta y comparar con el promedio global.
WITH PromedioGlobal AS (
    SELECT AVG(notaFinal) as promedio_global
    FROM Evaluacion
    WHERE notaFinal IS NOT NULL
)
SELECT 
    r.nombre as ruta,
    COUNT(DISTINCT e.camper_id) as total_campers,
    ROUND(AVG(e.notaFinal), 2) as promedio_ruta,
    ROUND((SELECT promedio_global FROM PromedioGlobal), 2) as promedio_global,
    ROUND(AVG(e.notaFinal) - (SELECT promedio_global FROM PromedioGlobal), 2) as diferencia
FROM Evaluacion e
JOIN Skill s ON e.skill_id = s.id
JOIN Ruta r ON s.ruta_id = r.id
GROUP BY r.id, r.nombre
ORDER BY AVG(e.notaFinal) DESC;

-- 3. Listar las áreas con más del 80% de ocupación.
WITH OcupacionArea AS (
    SELECT 
        ae.id,
        ae.nombre,
        COUNT(DISTINCT cg.camper_id) as campers_actuales,
        SUM(g.capacidad) as capacidad_total,
        ROUND(COUNT(DISTINCT cg.camper_id) * 100.0 / SUM(g.capacidad), 2) as porcentaje_ocupacion
    FROM AreaEntrenamiento ae
    JOIN AsignacionAreaEntrenamiento aae ON ae.id = aae.area_id
    JOIN Grupo g ON aae.grupo_id = g.id
    LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
    GROUP BY ae.id, ae.nombre
)
SELECT *
FROM OcupacionArea
WHERE porcentaje_ocupacion > 80
ORDER BY porcentaje_ocupacion DESC;

-- 4. Mostrar los trainers con menos del 70% de rendimiento promedio.
WITH RendimientoTrainer AS (
    SELECT 
        t.id,
        CONCAT(p.nombre, ' ', p.apellido) as trainer,
        COUNT(DISTINCT e.camper_id) as total_evaluados,
        ROUND(AVG(e.notaFinal), 2) as promedio_notas,
        ROUND(COUNT(CASE WHEN e.estado = 'Aprobado' THEN 1 END) * 100.0 / 
            NULLIF(COUNT(e.id), 0), 2) as porcentaje_aprobacion
    FROM Trainer t
    JOIN Persona p ON t.persona_id = p.id
    JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
    JOIN CamperGrupo cg ON aae.grupo_id = cg.grupo_id
    JOIN Evaluacion e ON cg.camper_id = e.camper_id
    GROUP BY t.id, p.nombre, p.apellido
)
SELECT *
FROM RendimientoTrainer
WHERE porcentaje_aprobacion < 70
ORDER BY porcentaje_aprobacion;

-- 5. Consultar los campers cuyo promedio está por debajo del promedio general.
WITH PromediosCamper AS (
    SELECT 
        c.id,
        CONCAT(p.nombre, ' ', p.apellido) as camper,
        ROUND(AVG(e.notaFinal), 2) as promedio_individual,
        (SELECT ROUND(AVG(notaFinal), 2) FROM Evaluacion) as promedio_general
    FROM Camper c
    JOIN Persona p ON c.persona_id = p.id
    JOIN Evaluacion e ON c.id = e.camper_id
    GROUP BY c.id, p.nombre, p.apellido
)
SELECT *
FROM PromediosCamper
WHERE promedio_individual < promedio_general
ORDER BY promedio_individual;

-- 6. Obtener los módulos con la menor tasa de aprobación.
SELECT 
    m.nombre as modulo,
    s.nombre as skill,
    r.nombre as ruta,
    COUNT(DISTINCT e.camper_id) as total_evaluados,
    COUNT(CASE WHEN e.estado = 'Aprobado' THEN 1 END) as aprobados,
    COUNT(CASE WHEN e.estado = 'Reprobado' THEN 1 END) as reprobados,
    ROUND(COUNT(CASE WHEN e.estado = 'Aprobado' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(e.id), 0), 2) as porcentaje_aprobacion
FROM Modulo m
JOIN Skill s ON m.skill_id = s.id
JOIN Ruta r ON s.ruta_id = r.id
JOIN Evaluacion e ON s.id = e.skill_id
GROUP BY m.id, m.nombre, s.nombre, r.nombre
HAVING COUNT(e.id) > 0
ORDER BY porcentaje_aprobacion ASC
LIMIT 5;

-- 7. Listar los campers que han aprobado todos los módulos de su ruta.
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

-- 8. Mostrar rutas con más de 10 campers en bajo rendimiento.
WITH CampersBajoRendimiento AS (
    SELECT 
        t.ruta_id,
        COUNT(DISTINCT CASE WHEN e.notaFinal < 60 THEN c.id END) as campers_bajo_rendimiento
    FROM Camper c
    JOIN CamperGrupo cg ON c.id = cg.camper_id
    JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
    JOIN Trainer t ON aae.trainer_id = t.id
    JOIN Evaluacion e ON c.id = e.camper_id
    GROUP BY t.ruta_id
)
SELECT 
    r.nombre as ruta,
    cbr.campers_bajo_rendimiento,
    COUNT(DISTINCT m.id) as total_modulos,
    GROUP_CONCAT(DISTINCT CONCAT(p.nombre, ' ', p.apellido)) as trainers
FROM CampersBajoRendimiento cbr
JOIN Ruta r ON cbr.ruta_id = r.id
JOIN Trainer t ON r.id = t.ruta_id
JOIN Persona p ON t.persona_id = p.id
JOIN Skill s ON r.id = s.ruta_id
JOIN Modulo m ON s.id = m.skill_id
WHERE cbr.campers_bajo_rendimiento > 10
GROUP BY r.id, r.nombre, cbr.campers_bajo_rendimiento;

-- 9. Calcular el promedio de rendimiento por SGDB principal.
SELECT 
    b.nombre as sgbd,
    COUNT(DISTINCT r.id) as total_rutas,
    COUNT(DISTINCT e.camper_id) as total_campers,
    ROUND(AVG(e.notaFinal), 2) as promedio_notas,
    ROUND(COUNT(CASE WHEN e.estado = 'Aprobado' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(e.id), 0), 2) as porcentaje_aprobacion
FROM Basedatos b
JOIN Ruta r ON b.id = r.SGBD1_id
JOIN Skill s ON r.id = s.ruta_id
JOIN Evaluacion e ON s.id = e.skill_id
GROUP BY b.id, b.nombre
ORDER BY AVG(e.notaFinal) DESC;

-- 10. Listar los módulos con al menos un 30% de campers reprobados.
WITH EstadisticasModulo AS (
    SELECT 
        m.id,
        m.nombre,
        COUNT(DISTINCT e.camper_id) as total_evaluados,
        COUNT(DISTINCT CASE WHEN e.estado = 'Reprobado' THEN e.camper_id END) as reprobados,
        ROUND(COUNT(DISTINCT CASE WHEN e.estado = 'Reprobado' THEN e.camper_id END) * 100.0 / 
            NULLIF(COUNT(DISTINCT e.camper_id), 0), 2) as porcentaje_reprobados
    FROM Modulo m
    JOIN Skill s ON m.skill_id = s.id
    JOIN Evaluacion e ON s.id = e.skill_id
    GROUP BY m.id, m.nombre
)
SELECT 
    em.*,
    s.nombre as skill,
    r.nombre as ruta
FROM EstadisticasModulo em
JOIN Modulo m ON em.id = m.id
JOIN Skill s ON m.skill_id = s.id
JOIN Ruta r ON s.ruta_id = r.id
WHERE em.porcentaje_reprobados >= 30
ORDER BY em.porcentaje_reprobados DESC;

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
WITH RutasPorTrainer AS (
    SELECT 
        t.id,
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
)
SELECT *
FROM RutasPorTrainer
WHERE total_rutas > 3;

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
WITH CambiosEstado AS (
    SELECT 
        c.id,
        CONCAT(p.nombre, ' ', p.apellido) as camper,
        COUNT(DISTINCT e.estado_id) as total_cambios_estado
    FROM Camper c
    JOIN Persona p ON c.persona_id = p.id
    JOIN Evaluacion e ON c.id = e.camper_id
    GROUP BY c.id, p.nombre, p.apellido
)
SELECT 
    ce.*,
    r.nombre as ruta_actual,
    ec.estado as estado_actual
FROM CambiosEstado ce
JOIN Camper c ON ce.id = c.id
JOIN EstadoCamper ec ON c.estado_id = ec.id
JOIN CamperGrupo cg ON c.id = cg.camper_id
JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
JOIN Trainer t ON aae.trainer_id = t.id
JOIN Ruta r ON t.ruta_id = r.id
WHERE ce.total_cambios_estado > 1
ORDER BY ce.total_cambios_estado DESC;

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
WITH EstadisticasRuta AS (
    SELECT 
        r.id,
        r.nombre,
        COUNT(DISTINCT c.id) as total_campers,
        COUNT(DISTINCT CASE WHEN ec.estado = 'Graduado' THEN c.id END) as graduados,
        ROUND(COUNT(DISTINCT CASE WHEN ec.estado = 'Graduado' THEN c.id END) * 100.0 / 
            NULLIF(COUNT(DISTINCT c.id), 0), 2) as tasa_graduacion
    FROM Ruta r
    JOIN Trainer t ON r.id = t.ruta_id
    JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
    JOIN CamperGrupo cg ON aae.grupo_id = cg.grupo_id
    JOIN Camper c ON cg.camper_id = c.id
    JOIN EstadoCamper ec ON c.estado_id = ec.id
    GROUP BY r.id, r.nombre
)
SELECT *
FROM EstadisticasRuta
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
    ROUND(COUNT(DISTINCT cg.camper_id) * 100.0 / NULLIF(SUM(g.capacidad), 0), 2) as porcentaje_ocupacion
FROM AreaEntrenamiento ae
JOIN Sede s ON ae.sede_id = s.id
JOIN AsignacionAreaEntrenamiento aae ON ae.id = aae.area_id
JOIN Grupo g ON aae.grupo_id = g.id
LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
GROUP BY ae.id, ae.nombre, s.nombre
ORDER BY porcentaje_ocupacion DESC;

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