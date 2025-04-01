-- Procedimientos almacenados

-- 1. Registrar un nuevo camper con toda su información personal y estado inicial.
DELIMITER //
CREATE PROCEDURE RegistrarCamper(
    IN p_identificacion VARCHAR(20),
    IN p_nombre VARCHAR(50),
    IN p_apellido VARCHAR(50),
    IN p_email VARCHAR(50),
    IN p_tipoDoc_id INT,
    IN p_direccion_descripcion VARCHAR(255),
    IN p_codigoPostal INT,
    IN p_ciudad_id INT,
    IN p_telefono VARCHAR(20),
    IN p_tipoTel_id INT
)
BEGIN
    DECLARE v_persona_id INT;
    DECLARE v_camper_id INT;
    
    START TRANSACTION;
    
    -- Insertar dirección
    INSERT INTO Direccion (descripcion, codigoPostal, ciudad_id)
    VALUES (p_direccion_descripcion, p_codigoPostal, p_ciudad_id);
    
    -- Insertar persona
    INSERT INTO Persona (identificacion, nombre, apellido, email, tipoDoc_id, direccion_id)
    VALUES (p_identificacion, p_nombre, p_apellido, p_email, p_tipoDoc_id, LAST_INSERT_ID());
    
    SET v_persona_id = LAST_INSERT_ID();
    
    -- Insertar teléfono
    INSERT INTO Telefono (telefono, persona_id, tipoTel_id)
    VALUES (p_telefono, v_persona_id, p_tipoTel_id);
    
    -- Insertar camper con estado inicial "En proceso de ingreso" y riesgo "Bajo"
    INSERT INTO Camper (persona_id, estado_id, riesgo_id)
    VALUES (v_persona_id, 1, 1);
    
    COMMIT;
END //
DELIMITER ;

-- 2. Actualizar el estado de un camper luego de completar el proceso de ingreso.
DELIMITER //
CREATE PROCEDURE ActualizarEstadoCamper(
    IN p_camper_id INT,
    IN p_nuevo_estado_id INT
)
BEGIN
    UPDATE Camper
    SET estado_id = p_nuevo_estado_id
    WHERE id = p_camper_id;
END //
DELIMITER ;

-- 3. Procesar la inscripción de un camper a una ruta específica.
DELIMITER //
CREATE PROCEDURE InscribirCamperRuta(
    IN p_camper_id INT,
    IN p_grupo_id INT
)
BEGIN
    -- Verificar si el grupo tiene capacidad
    DECLARE v_capacidad_actual INT;
    DECLARE v_capacidad_maxima INT;
    
    SELECT COUNT(*) INTO v_capacidad_actual
    FROM CamperGrupo
    WHERE grupo_id = p_grupo_id;
    
    SELECT capacidad INTO v_capacidad_maxima
    FROM Grupo
    WHERE id = p_grupo_id;
    
    IF v_capacidad_actual < v_capacidad_maxima THEN
        INSERT INTO CamperGrupo (camper_id, grupo_id)
        VALUES (p_camper_id, p_grupo_id);
        
        -- Actualizar estado del camper a "Inscrito"
        UPDATE Camper
        SET estado_id = 2
        WHERE id = p_camper_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El grupo ha alcanzado su capacidad máxima';
    END IF;
END //
DELIMITER ;

-- 4. Registrar una evaluación completa (teórica, práctica y quizzes) para un camper.
DELIMITER //
CREATE PROCEDURE RegistrarEvaluacionCompleta(
    IN p_camper_id INT,
    IN p_skill_id INT,
    IN p_nota_examen DECIMAL(5,1),
    IN p_nota_proyecto DECIMAL(5,1),
    IN p_nota_actividad DECIMAL(5,1)
)
BEGIN
    DECLARE v_evaluacion_id INT;
    
    -- Crear la evaluación
    INSERT INTO Evaluacion (camper_id, skill_id)
    VALUES (p_camper_id, p_skill_id);
    
    SET v_evaluacion_id = LAST_INSERT_ID();
    
    -- Registrar notas por tipo
    INSERT INTO Nota (nota, evaluacion_id, tipoEvaluacion_id)
    VALUES 
        (p_nota_examen, v_evaluacion_id, 1),    -- Examen
        (p_nota_proyecto, v_evaluacion_id, 2),   -- Proyecto
        (p_nota_actividad, v_evaluacion_id, 3);  -- Actividad
END //
DELIMITER ;

-- 5. Calcular y registrar automáticamente la nota final de un módulo.
DELIMITER //
CREATE PROCEDURE CalcularNotaFinal(
    IN p_evaluacion_id INT
)
BEGIN
    DECLARE v_nota_final DECIMAL(5,1);
    
    SELECT SUM(n.nota * te.porcentaje / 100) INTO v_nota_final
    FROM Nota n
    JOIN TipoEvaluacion te ON n.tipoEvaluacion_id = te.id
    WHERE n.evaluacion_id = p_evaluacion_id;
    
    UPDATE Evaluacion
    SET notaFinal = v_nota_final,
        estado = CASE 
            WHEN v_nota_final >= 60 THEN 'Aprobado'
            ELSE 'Reprobado'
        END
    WHERE id = p_evaluacion_id;
END //
DELIMITER ;

-- 6. Asignar campers aprobados a una ruta de acuerdo con la disponibilidad del área.
DELIMITER //
CREATE PROCEDURE AsignarCampersRuta(
    IN p_ruta_id INT,
    IN p_area_id INT
)
BEGIN
    DECLARE v_capacidad_disponible INT;
    
    -- Obtener capacidad disponible del área
    SELECT (g.capacidad - COUNT(cg.camper_id)) INTO v_capacidad_disponible
    FROM Grupo g
    LEFT JOIN CamperGrupo cg ON g.id = cg.grupo_id
    JOIN AsignacionAreaEntrenamiento aae ON g.id = aae.grupo_id
    WHERE aae.area_id = p_area_id
    GROUP BY g.id;
    
    -- Asignar campers aprobados que no están asignados
    INSERT INTO CamperGrupo (camper_id, grupo_id)
    SELECT DISTINCT c.id, g.id
    FROM Camper c
    JOIN Evaluacion e ON c.id = e.camper_id
    JOIN Grupo g
    JOIN AsignacionAreaEntrenamiento aae ON g.id = aae.grupo_id
    WHERE e.estado = 'Aprobado'
    AND c.id NOT IN (SELECT camper_id FROM CamperGrupo)
    AND aae.area_id = p_area_id
    LIMIT v_capacidad_disponible;
END //
DELIMITER ;

-- 7. Asignar un trainer a una ruta y área específica, validando el horario.
DELIMITER //
CREATE PROCEDURE AsignarTrainer(
    IN p_trainer_id INT,
    IN p_horario_id INT,
    IN p_area_id INT,
    IN p_grupo_id INT
)
BEGIN
    -- Verificar si el trainer ya está asignado en ese horario
    IF EXISTS (
        SELECT 1 FROM AsignacionAreaEntrenamiento
        WHERE trainer_id = p_trainer_id
        AND horario_id = p_horario_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El trainer ya está asignado en este horario';
    ELSE
        INSERT INTO AsignacionAreaEntrenamiento (trainer_id, horario_id, area_id, grupo_id)
        VALUES (p_trainer_id, p_horario_id, p_area_id, p_grupo_id);
    END IF;
END //
DELIMITER ;

-- 8. Registrar una nueva ruta con sus módulos y SGDB asociados.
DELIMITER //
CREATE PROCEDURE RegistrarNuevaRuta(
    IN p_nombre VARCHAR(100),
    IN p_sgbd1_id INT,
    IN p_sgbd2_id INT
)
BEGIN
    INSERT INTO Ruta (nombre, SGBD1_id, SGBD2_id)
    VALUES (p_nombre, p_sgbd1_id, p_sgbd2_id);
END //
DELIMITER ;

-- 9. Registrar una nueva área de entrenamiento con su capacidad y horarios.
DELIMITER //
CREATE PROCEDURE RegistrarAreaEntrenamiento(
    IN p_nombre VARCHAR(100),
    IN p_sede_id INT
)
BEGIN
    INSERT INTO AreaEntrenamiento (nombre, sede_id)
    VALUES (p_nombre, p_sede_id);
END //
DELIMITER ;

-- 10. Consultar disponibilidad de horario en un área determinada.
DELIMITER //
CREATE PROCEDURE ConsultarDisponibilidadArea(
    IN p_area_id INT
)
BEGIN
    SELECT h.*, 
           CASE WHEN aae.id IS NULL THEN 'Disponible' ELSE 'Ocupado' END as estado
    FROM Horario h
    LEFT JOIN AsignacionAreaEntrenamiento aae ON h.id = aae.horario_id
    AND aae.area_id = p_area_id;
END //
DELIMITER ;

-- 11. Reasignar a un camper a otra ruta en caso de bajo rendimiento.
DELIMITER //
CREATE PROCEDURE ReasignarCamperRuta(
    IN p_camper_id INT,
    IN p_nuevo_grupo_id INT
)
BEGIN
    UPDATE CamperGrupo
    SET grupo_id = p_nuevo_grupo_id
    WHERE camper_id = p_camper_id;
END //
DELIMITER ;

-- 12. Cambiar el estado de un camper a "Graduado" al finalizar todos los módulos.
DELIMITER //
CREATE PROCEDURE GraduarCamper(
    IN p_camper_id INT
)
BEGIN
    -- Verificar que todas las evaluaciones estén aprobadas
    IF NOT EXISTS (
        SELECT 1 FROM Evaluacion
        WHERE camper_id = p_camper_id
        AND (estado = 'Reprobado' OR estado IS NULL)
    ) THEN
        UPDATE Camper
        SET estado_id = 5 -- Estado "Graduado"
        WHERE id = p_camper_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El camper aún tiene módulos pendientes o reprobados';
    END IF;
END //
DELIMITER ;

-- 13. Consultar y exportar todos los datos de rendimiento de un camper.
DELIMITER //
CREATE PROCEDURE ConsultarRendimientoCamper(
    IN p_camper_id INT
)
BEGIN
    SELECT 
        p.nombre,
        p.apellido,
        s.nombre as skill,
        e.notaFinal,
        e.estado,
        n.nota,
        te.nombre as tipo_evaluacion
    FROM Camper c
    JOIN Persona p ON c.persona_id = p.id
    JOIN Evaluacion e ON c.id = e.camper_id
    JOIN Skill s ON e.skill_id = s.id
    JOIN Nota n ON e.id = n.evaluacion_id
    JOIN TipoEvaluacion te ON n.tipoEvaluacion_id = te.id
    WHERE c.id = p_camper_id;
END //
DELIMITER ;

-- 14. Registrar la asistencia a clases por área y horario.
DELIMITER //
CREATE PROCEDURE RegistrarAsistencia(
    IN p_camper_id INT,
    IN p_area_id INT,
    IN p_horario_id INT,
    IN p_fecha DATE,
    IN p_asistio BOOLEAN
)
BEGIN
    INSERT INTO Asistencia (camper_id, area_id, horario_id, fecha, asistio)
    VALUES (p_camper_id, p_area_id, p_horario_id, p_fecha, p_asistio);
END //
DELIMITER ;

-- 15. Generar reporte mensual de notas por ruta.
DELIMITER //
CREATE PROCEDURE ReporteNotasRuta(
    IN p_ruta_id INT,
    IN p_mes INT,
    IN p_año INT
)
BEGIN
    SELECT 
        r.nombre as ruta,
        s.nombre as skill,
        AVG(e.notaFinal) as promedio_notas,
        COUNT(CASE WHEN e.estado = 'Aprobado' THEN 1 END) as aprobados,
        COUNT(CASE WHEN e.estado = 'Reprobado' THEN 1 END) as reprobados
    FROM Ruta r
    JOIN Skill s ON r.id = s.ruta_id
    JOIN Evaluacion e ON s.id = e.skill_id
    WHERE r.id = p_ruta_id
    AND MONTH(e.fecha) = p_mes
    AND YEAR(e.fecha) = p_año
    GROUP BY r.id, s.id;
END //
DELIMITER ;

-- 16. Validar y registrar la asignación de un salón a una ruta sin exceder la capacidad.
DELIMITER //
CREATE PROCEDURE AsignarSalonRuta(
    IN p_grupo_id INT,
    IN p_area_id INT
)
BEGIN
    DECLARE v_capacidad_salon INT;
    DECLARE v_estudiantes_grupo INT;
    
    -- Obtener capacidad del salón (área)
    SELECT capacidad INTO v_capacidad_salon
    FROM Grupo WHERE id = p_grupo_id;
    
    -- Contar estudiantes en el grupo
    SELECT COUNT(*) INTO v_estudiantes_grupo
    FROM CamperGrupo WHERE grupo_id = p_grupo_id;
    
    IF v_estudiantes_grupo <= v_capacidad_salon THEN
        -- Asignar el salón al grupo
        UPDATE AsignacionAreaEntrenamiento
        SET area_id = p_area_id
        WHERE grupo_id = p_grupo_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La capacidad del salón es insuficiente para el grupo';
    END IF;
END //
DELIMITER ;

-- 17. Registrar cambio de horario de un trainer.
DELIMITER //
CREATE PROCEDURE CambiarHorarioTrainer(
    IN p_trainer_id INT,
    IN p_antiguo_horario_id INT,
    IN p_nuevo_horario_id INT
)
BEGIN
    UPDATE AsignacionAreaEntrenamiento
    SET horario_id = p_nuevo_horario_id
    WHERE trainer_id = p_trainer_id
    AND horario_id = p_antiguo_horario_id;
END //
DELIMITER ;

-- 18. Eliminar la inscripción de un camper a una ruta (en caso de retiro).
DELIMITER //
CREATE PROCEDURE EliminarInscripcionCamper(
    IN p_camper_id INT
)
BEGIN
    -- Eliminar asignación a grupo
    DELETE FROM CamperGrupo
    WHERE camper_id = p_camper_id;
    
    -- Actualizar estado a "Retirado"
    UPDATE Camper
    SET estado_id = 7 -- Estado "Retirado"
    WHERE id = p_camper_id;
END //
DELIMITER ;

-- 19. Recalcular el estado de todos los campers según su rendimiento acumulado.
DELIMITER //
CREATE PROCEDURE RecalcularEstadoCampers()
BEGIN
    UPDATE Camper c
    JOIN (
        SELECT 
            e.camper_id,
            CASE 
                WHEN AVG(e.notaFinal) < 60 THEN 3 -- Alto riesgo
                WHEN AVG(e.notaFinal) < 80 THEN 2 -- Medio riesgo
                ELSE 1 -- Bajo riesgo
            END as nuevo_riesgo
        FROM Evaluacion e
        GROUP BY e.camper_id
    ) calc ON c.id = calc.camper_id
    SET c.riesgo_id = calc.nuevo_riesgo;
END //
DELIMITER ;

-- 20. Asignar horarios automáticamente a trainers disponibles según sus áreas.
DELIMITER //
CREATE PROCEDURE AsignarHorariosAutomaticos()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_trainer_id, v_area_id, v_horario_id INT;
    
    -- Cursor para trainers sin horario asignado
    DECLARE cur CURSOR FOR
        SELECT t.id, aae.area_id, h.id
        FROM Trainer t
        CROSS JOIN Horario h
        LEFT JOIN AsignacionAreaEntrenamiento aae ON t.id = aae.trainer_id
        WHERE aae.id IS NULL;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_trainer_id, v_area_id, v_horario_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Intentar asignar horario
        INSERT IGNORE INTO AsignacionAreaEntrenamiento (trainer_id, horario_id, area_id)
        VALUES (v_trainer_id, v_horario_id, v_area_id);
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
