-- Campers

-- 1. Obtener todos los campers inscritos actualmente.
SELECT 
    p.identificacion,
    p.nombre,
    p.apellido,
    p.email,
    ec.estado
FROM
    Camper c
    JOIN Persona p ON c.persona_id = p.id
    JOIN EstadoCamper ec ON c.estado_id = ec.id
WHERE
    ec.estado = 'Inscrito';

-- 2. Listar los campers con estado "Aprobado".
SELECT 
    p.identificacion,
    p.nombre,
    p.apellido,
    p.email,
    ec.estado
FROM
    Camper c
    JOIN Persona p ON c.persona_id = p.id
    JOIN EstadoCamper ec ON c.estado_id = ec.id
WHERE
    ec.estado = 'Aprobado';

-- 3. Mostrar los campers que ya están cursando alguna ruta.
SELECT DISTINCT
    p.identificacion,
    p.nombre,
    p.apellido,
    r.nombre as ruta,
    ec.estado
FROM
    Camper c
    JOIN Persona p ON c.persona_id = p.id
    JOIN EstadoCamper ec ON c.estado_id = ec.id
    JOIN CamperGrupo cg ON c.id = cg.camper_id
    JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
    JOIN Trainer t ON aae.trainer_id = t.id
    JOIN Ruta r ON t.ruta_id = r.id
WHERE
    ec.estado = 'Cursando';

-- 4. Consultar los campers graduados por cada ruta.
SELECT
    r.nombre as ruta,
    COUNT(c.id) as total_graduados,
    GROUP_CONCAT( CONCAT(p.nombre, ' ', p.apellido)) as campers_graduados
FROM
    Camper c
    JOIN Persona p ON c.persona_id = p.id
    JOIN EstadoCamper ec ON c.estado_id = ec.id
    JOIN CamperGrupo cg ON c.id = cg.camper_id
    JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
    JOIN Trainer t ON aae.trainer_id = t.id
    JOIN Ruta r ON t.ruta_id = r.id
WHERE
    ec.estado = 'Graduado'
GROUP BY
    r.id,
    r.nombre;

-- 5. Obtener los campers que se encuentran en estado "Expulsado" o "Retirado".
SELECT 
    p.identificacion,
    p.nombre,
    p.apellido,
    ec.estado,
    r.nivel as nivel_riesgo
FROM
    Camper c
    JOIN Persona p ON c.persona_id = p.id
    JOIN EstadoCamper ec ON c.estado_id = ec.id
    JOIN Riesgo r ON c.riesgo_id = r.id
WHERE
    ec.estado IN ('Expulsado', 'Retirado');

-- 6. Listar campers con nivel de riesgo "Alto".
SELECT 
    p.identificacion,
    p.nombre,
    p.apellido,
    ec.estado,
    r.nivel as nivel_riesgo
FROM
    Camper c
    JOIN Persona p ON c.persona_id = p.id
    JOIN EstadoCamper ec ON c.estado_id = ec.id
    JOIN Riesgo r ON c.riesgo_id = r.id
WHERE
    r.nivel = 'Alto';

-- 7. Mostrar el total de campers por cada nivel de riesgo.
SELECT 
    r.nivel as nivel_riesgo,
    COUNT(c.id) as total_campers
FROM Camper c
    JOIN Riesgo r ON c.riesgo_id = r.id
GROUP BY
    r.id,
    r.nivel
ORDER BY COUNT(c.id) DESC;

-- 8. Obtener campers con más de un número telefónico registrado.
SELECT
    p.identificacion,
    p.nombre,
    p.apellido,
    COUNT(t.id) as total_telefonos,
    GROUP_CONCAT(t.telefono) as telefonos
FROM
    Camper c
    JOIN Persona p ON c.persona_id = p.id
    JOIN Telefono t ON p.id = t.persona_id
GROUP BY
    c.id,
    p.identificacion,
    p.nombre,
    p.apellido
HAVING
    COUNT(t.id) > 1;

-- 9. Listar los campers y sus respectivos acudientes y teléfonos.
SELECT
    p.identificacion as camper_id,
    p.nombre as camper_nombre,
    p.apellido as camper_apellido,
    pa.nombre as acudiente_nombre,
    pa.apellido as acudiente_apellido,
    GROUP_CONCAT(DISTINCT t1.telefono) as telefonos_camper,
    GROUP_CONCAT(DISTINCT t2.telefono) as telefonos_acudiente
FROM
    Camper c
    JOIN Persona p ON c.persona_id = p.id
    JOIN Acudiente a ON c.id = a.camper_id
    JOIN Persona pa ON a.persona_id = pa.id
    LEFT JOIN Telefono t1 ON p.id = t1.persona_id
    LEFT JOIN Telefono t2 ON pa.id = t2.persona_id
GROUP BY
    c.id,
    p.identificacion,
    p.nombre,
    p.apellido,
    pa.nombre,
    pa.apellido;

-- 10. Mostrar campers que aún no han sido asignados a una ruta.
SELECT 
    p.identificacion,
    p.nombre,
    p.apellido,
    ec.estado
FROM
    Camper c
    JOIN Persona p ON c.persona_id = p.id
    JOIN EstadoCamper ec ON c.estado_id = ec.id
    LEFT JOIN CamperGrupo cg ON c.id = cg.camper_id
    LEFT JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
WHERE
    cg.id IS NULL;