-- Pruebas de Procedimientos Almacenados

-- 1. Registrar un nuevo camper
CALL RegistrarCamper(
    '123456789', 'Juan', 'Test', 'juan.test@mail.com', 
    1, 'Calle Test 123', 680001, 27, '3001234567', 1
);
-- Verificar:
SELECT p.*, c.estado_id, c.riesgo_id 
FROM Persona p 
JOIN Camper c ON p.id = c.persona_id 
WHERE p.identificacion = '123456789';

-- 2. Actualizar estado de camper
CALL ActualizarEstadoCamper(1, 2); -- Cambia estado a "Inscrito"
-- Verificar:
SELECT c.id, p.nombre, ec.estado 
FROM Camper c 
JOIN Persona p ON c.persona_id = p.id 
JOIN EstadoCamper ec ON c.estado_id = ec.id 
WHERE c.id = 1;

-- 3. Inscribir camper a ruta (a través de grupo)
CALL InscribirCamperRuta(1, 1); -- Inscribe al camper 1 en el grupo 1
-- Verificar:
SELECT c.id, p.nombre, g.nombre as grupo 
FROM Camper c 
JOIN Persona p ON c.persona_id = p.id 
JOIN CamperGrupo cg ON c.id = cg.camper_id 
JOIN Grupo g ON cg.grupo_id = g.id 
WHERE c.id = 1;

-- 4. Registrar evaluación completa
CALL RegistrarEvaluacionCompleta(1, 1, 80, 85, 90);
-- Verificar:
SELECT e.*, n.nota, te.nombre as tipo_evaluacion 
FROM Evaluacion e 
JOIN Nota n ON e.id = n.evaluacion_id 
JOIN TipoEvaluacion te ON n.tipoEvaluacion_id = te.id 
WHERE e.camper_id = 1 AND e.skill_id = 1;

-- 7. Asignar trainer a área
CALL AsignarTrainer(1, 1, 1, 1); -- Trainer 1, Horario 1, Área 1, Grupo 1
-- Verificar:
SELECT t.id, p.nombre, h.horaInicio, h.horaFin, ae.nombre as area 
FROM Trainer t 
JOIN Persona p ON t.persona_id = p.id 
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id 
JOIN Horario h ON aae.horario_id = h.id 
JOIN AreaEntrenamiento ae ON aae.area_id = ae.id 
WHERE t.id = 1;

-- 8. Registrar nueva ruta
CALL RegistrarNuevaRuta('Nueva Ruta Test', 1, 2);
-- Verificar:
SELECT * FROM Ruta WHERE nombre = 'Nueva Ruta Test';

-- 9. Registrar área de entrenamiento
CALL RegistrarAreaEntrenamiento('Nueva Área Test', 1);
-- Verificar:
SELECT * FROM AreaEntrenamiento WHERE nombre = 'Nueva Área Test';

-- 10. Consultar disponibilidad de área
CALL ConsultarDisponibilidadArea(1);

-- 11. Reasignar camper a otra ruta
CALL ReasignarCamperRuta(1, 2); -- Camper 1 al grupo 2
-- Verificar:
SELECT c.id, p.nombre, g.nombre as grupo 
FROM Camper c 
JOIN Persona p ON c.persona_id = p.id 
JOIN CamperGrupo cg ON c.id = cg.camper_id 
JOIN Grupo g ON cg.grupo_id = g.id 
WHERE c.id = 1;

-- 12. Graduar camper
CALL GraduarCamper(1);
-- Verificar:
SELECT c.id, p.nombre, ec.estado 
FROM Camper c 
JOIN Persona p ON c.persona_id = p.id 
JOIN EstadoCamper ec ON c.estado_id = ec.id 
WHERE c.id = 1;

-- 13. Consultar rendimiento de camper
CALL ConsultarRendimientoCamper(1);

-- 17. Cambiar horario de trainer
CALL CambiarHorarioTrainer(1, 1, 2); -- Trainer 1: del horario 1 al 2
-- Verificar:
SELECT t.id, p.nombre, h.horaInicio, h.horaFin 
FROM Trainer t 
JOIN Persona p ON t.persona_id = p.id 
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id 
JOIN Horario h ON aae.horario_id = h.id 
WHERE t.id = 1;

-- 18. Eliminar inscripción de camper
CALL EliminarInscripcionCamper(1);
-- Verificar:
SELECT c.id, p.nombre, ec.estado, cg.grupo_id 
FROM Camper c 
JOIN Persona p ON c.persona_id = p.id 
JOIN EstadoCamper ec ON c.estado_id = ec.id 
LEFT JOIN CamperGrupo cg ON c.id = cg.camper_id 
WHERE c.id = 1;

-- 19. Recalcular estado de campers
CALL RecalcularEstadoCampers();
-- Verificar:
SELECT c.id, p.nombre, r.nivel as nivel_riesgo 
FROM Camper c 
JOIN Persona p ON c.persona_id = p.id 
JOIN Riesgo r ON c.riesgo_id = r.id;

-- 20. Asignar horarios automáticamente
CALL AsignarHorariosAutomaticos();
-- Verificar:
SELECT t.id, p.nombre, h.horaInicio, h.horaFin, ae.nombre as area 
FROM Trainer t 
JOIN Persona p ON t.persona_id = p.id 
JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id 
JOIN Horario h ON aae.horario_id = h.id 
JOIN AreaEntrenamiento ae ON aae.area_id = ae.id; 