-- Triggers SQL

-- 1. Al insertar una evaluación, calcular automáticamente la nota final.

DELIMITER //
CREATE TRIGGER calcular_nota_final_after_insert
AFTER INSERT ON Nota
FOR EACH ROW
BEGIN
    DECLARE nota_final DECIMAL(5,1);
    -- Calcular la nota final ponderada
    SELECT SUM(n.nota * te.porcentaje / 100)
    INTO nota_final
    FROM Nota n
    JOIN TipoEvaluacion te ON n.tipoEvaluacion_id = te.id
    WHERE n.evaluacion_id = NEW.evaluacion_id;
    -- Actualizar la nota final en la tabla Evaluacion
    UPDATE Evaluacion 
    SET notaFinal = nota_final,
        estado = CASE 
            WHEN nota_final >= 60 THEN 'Aprobado'
            ELSE 'Reprobado'
        END
    WHERE id = NEW.evaluacion_id;
END //
DELIMITER ;

-- 2. Al actualizar la nota final de un módulo, verificar si el camper aprueba o reprueba.

DELIMITER //
CREATE TRIGGER verificar_estado_after_nota_update
AFTER UPDATE ON Evaluacion
FOR EACH ROW
BEGIN
    IF NEW.notaFinal IS NOT NULL AND OLD.notaFinal != NEW.notaFinal THEN
        UPDATE Evaluacion
        SET estado = CASE 
            WHEN NEW.notaFinal >= 60 THEN 'Aprobado'
            ELSE 'Reprobado'
        END
        WHERE id = NEW.id;
    END IF;
END //
DELIMITER ;

-- 3. Al insertar una inscripción, cambiar el estado del camper a "Inscrito".

DELIMITER //
CREATE TRIGGER actualizar_estado_camper_after_inscripcion
AFTER INSERT ON CamperGrupo
FOR EACH ROW
BEGIN
    UPDATE Camper
    SET estado_id = (SELECT id FROM EstadoCamper WHERE estado = 'Inscrito')
    WHERE id = NEW.camper_id;
END //
DELIMITER ;

-- 4. Al actualizar una evaluación, recalcular su promedio inmediatamente.

DELIMITER //
CREATE TRIGGER recalcular_promedio_after_nota_update
AFTER UPDATE ON Nota
FOR EACH ROW
BEGIN
    DECLARE nueva_nota_final DECIMAL(5,1);
    -- Calcular nueva nota final
    SELECT SUM(n.nota * te.porcentaje / 100)
    INTO nueva_nota_final
    FROM Nota n
    JOIN TipoEvaluacion te ON n.tipoEvaluacion_id = te.id
    WHERE n.evaluacion_id = NEW.evaluacion_id;
    -- Actualizar evaluación
    UPDATE Evaluacion 
    SET notaFinal = nueva_nota_final
    WHERE id = NEW.evaluacion_id;
END //
DELIMITER ;

-- 5. Al eliminar una inscripción, marcar al camper como "Retirado".

DELIMITER //
CREATE TRIGGER marcar_camper_retirado_after_delete
AFTER DELETE ON CamperGrupo
FOR EACH ROW
BEGIN
    UPDATE Camper
    SET estado_id = (SELECT id FROM EstadoCamper WHERE estado = 'Retirado')
    WHERE id = OLD.camper_id;
END //
DELIMITER ;

-- 6. Al insertar un nuevo módulo, registrar automáticamente su SGDB asociado.

DELIMITER //
CREATE TRIGGER registrar_sgbd_after_modulo_insert
AFTER INSERT ON Modulo
FOR EACH ROW
BEGIN
    DECLARE ruta_id INT;
    -- Obtener la ruta asociada al skill del módulo
    SELECT ruta_id INTO ruta_id
    FROM Skill
    WHERE id = NEW.skill_id;
    -- Registrar en una tabla de auditoría (necesitarías crearla)
    INSERT INTO ModuloSGBD (modulo_id, sgbd_id, ruta_id)
    SELECT NEW.id, SGBD1_id, ruta_id
    FROM Ruta
    WHERE id = ruta_id;
    INSERT INTO ModuloSGBD (modulo_id, sgbd_id, ruta_id)
    SELECT NEW.id, SGBD2_id, ruta_id
    FROM Ruta
    WHERE id = ruta_id;
END //
DELIMITER ;

-- 7. Al insertar un nuevo trainer, verificar duplicados por identificación.

DELIMITER //
CREATE TRIGGER verificar_duplicados_trainer_before_insert
BEFORE INSERT ON Trainer
FOR EACH ROW
BEGIN
    DECLARE existe INT;
    -- Verificar si ya existe un trainer con la misma identificación
    SELECT COUNT(*) INTO existe
    FROM Trainer t
    JOIN Persona p ON t.persona_id = p.id
    WHERE p.identificacion = (
        SELECT identificacion 
        FROM Persona 
        WHERE id = NEW.persona_id
    );
    IF existe > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un trainer con esta identificación';
    END IF;
END //
DELIMITER ;

-- 8. Al asignar un área, validar que no exceda su capacidad.

DELIMITER //
CREATE TRIGGER validar_capacidad_area_before_insert
BEFORE INSERT ON AsignacionAreaEntrenamiento
FOR EACH ROW
BEGIN
    DECLARE capacidad_actual INT;
    DECLARE capacidad_maxima INT;
    -- Obtener la capacidad actual del área
    SELECT COUNT(*) INTO capacidad_actual
    FROM AsignacionAreaEntrenamiento
    WHERE area_id = NEW.area_id;
    -- Obtener la capacidad máxima del grupo
    SELECT g.capacidad INTO capacidad_maxima
    FROM Grupo g
    WHERE g.id = NEW.grupo_id;
    IF capacidad_actual >= capacidad_maxima THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El área ha excedido su capacidad máxima';
    END IF;
END //
DELIMITER ;

-- 9. Al insertar una evaluación con nota < 60, marcar al camper como "Bajo rendimiento".

DELIMITER //
CREATE TRIGGER marcar_bajo_rendimiento_after_nota_insert
AFTER INSERT ON Nota
FOR EACH ROW
BEGIN
    DECLARE nota_final DECIMAL(5,1);
    -- Calcular nota final
    SELECT SUM(n.nota * te.porcentaje / 100)
    INTO nota_final
    FROM Nota n
    JOIN TipoEvaluacion te ON n.tipoEvaluacion_id = te.id
    WHERE n.evaluacion_id = NEW.evaluacion_id;
    -- Si la nota es menor a 60, actualizar el riesgo del camper
    IF nota_final < 60 THEN
        UPDATE Camper c
        JOIN Evaluacion e ON c.id = e.camper_id
        SET c.riesgo_id = (SELECT id FROM Riesgo WHERE nivel = 'Alto')
        WHERE e.id = NEW.evaluacion_id;
    END IF;
END //
DELIMITER ;

-- 10. Al cambiar de estado a "Graduado", mover registro a la tabla de egresados.

DELIMITER //
CREATE TRIGGER mover_a_egresados_after_estado_update
AFTER UPDATE ON Camper
FOR EACH ROW
BEGIN
    IF NEW.estado_id = (SELECT id FROM EstadoCamper WHERE estado = 'Graduado') 
    AND OLD.estado_id != NEW.estado_id THEN
        -- Insertar en tabla de egresados (necesitarías crearla)
        INSERT INTO Egresados (
            camper_id, 
            persona_id, 
            fecha_graduacion, 
            ruta_id
        )
        SELECT 
            c.id,
            c.persona_id,
            CURDATE(),
            t.ruta_id
        FROM Camper c
        JOIN CamperGrupo cg ON c.id = cg.camper_id
        JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
        JOIN Trainer t ON aae.trainer_id = t.id
        WHERE c.id = NEW.id;
    END IF;
END //
DELIMITER ;

-- 11. Al modificar horarios de trainer, verificar solapamiento con otros.

DELIMITER //
CREATE TRIGGER verificar_solapamiento_horarios_before_insert
BEFORE INSERT ON AsignacionAreaEntrenamiento
FOR EACH ROW
BEGIN
    DECLARE existe_solapamiento INT;
    -- Verificar si existe solapamiento de horarios para el mismo trainer
    SELECT COUNT(*) INTO existe_solapamiento
    FROM AsignacionAreaEntrenamiento aae
    JOIN Horario h1 ON aae.horario_id = h1.id
    JOIN Horario h2 ON NEW.horario_id = h2.id
    WHERE aae.trainer_id = NEW.trainer_id
    AND (
        (h1.horaInicio <= h2.horaFin AND h1.horaFin >= h2.horaInicio)
    );
    IF existe_solapamiento > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Existe solapamiento de horarios para este trainer';
    END IF;
END //
DELIMITER ;

-- 12. Al eliminar un trainer, liberar sus horarios y rutas asignadas.

DELIMITER //
CREATE TRIGGER liberar_recursos_after_trainer_delete
AFTER DELETE ON Trainer
FOR EACH ROW
BEGIN
    -- Liberar horarios asignados
    UPDATE AsignacionAreaEntrenamiento
    SET trainer_id = NULL
    WHERE trainer_id = OLD.id;
    -- Liberar grupos asignados
    UPDATE AsignacionAreaEntrenamiento
    SET grupo_id = NULL
    WHERE trainer_id = OLD.id;
END //
DELIMITER ;

-- 13. Al cambiar la ruta de un camper, actualizar automáticamente sus módulos.

DELIMITER //
CREATE TRIGGER actualizar_modulos_after_ruta_change
AFTER UPDATE ON CamperGrupo
FOR EACH ROW
BEGIN
    DECLARE nueva_ruta_id INT;
    -- Obtener la nueva ruta del trainer
    SELECT t.ruta_id INTO nueva_ruta_id
    FROM AsignacionAreaEntrenamiento aae
    JOIN Trainer t ON aae.trainer_id = t.id
    WHERE aae.grupo_id = NEW.grupo_id;
    -- Actualizar las evaluaciones con las nuevas skills de la ruta
    UPDATE Evaluacion e
    JOIN Skill s ON e.skill_id = s.id
    SET e.skill_id = (
        SELECT id FROM Skill 
        WHERE ruta_id = nueva_ruta_id
    )
    WHERE e.skill_id = (
        SELECT id FROM Skill 
        WHERE ruta_id = OLD.ruta_id
    );
END //
DELIMITER ;

-- 14. Al insertar un nuevo camper, verificar si ya existe por número de documento.

DELIMITER //
CREATE TRIGGER verificar_duplicados_camper_before_insert
BEFORE INSERT ON Camper
FOR EACH ROW
BEGIN
    DECLARE existe INT;
    -- Verificar si ya existe un camper con el mismo número de documento
    SELECT COUNT(*) INTO existe
    FROM Camper c
    JOIN Persona p ON c.persona_id = p.id
    WHERE p.identificacion = (
        SELECT identificacion 
        FROM Persona 
        WHERE id = NEW.persona_id
    );
    IF existe > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un camper con este número de documento';
    END IF;
END //
DELIMITER ;

-- 15. Al actualizar la nota final, recalcular el estado del módulo automáticamente.

DELIMITER //
CREATE TRIGGER actualizar_estado_modulo_after_nota_update
AFTER UPDATE ON Evaluacion
FOR EACH ROW
BEGIN
    IF NEW.notaFinal IS NOT NULL AND OLD.notaFinal != NEW.notaFinal THEN
        UPDATE Evaluacion
        SET estado = CASE 
            WHEN NEW.notaFinal >= 60 THEN 'Aprobado'
            ELSE 'Reprobado'
        END
        WHERE id = NEW.id;
    END IF;
END //
DELIMITER ;

-- 16. Al asignar un módulo, verificar que el trainer tenga ese conocimiento.

DELIMITER //
CREATE TRIGGER verificar_conocimiento_before_insert
BEFORE INSERT ON AsignacionAreaEntrenamiento
FOR EACH ROW
BEGIN
    DECLARE conocimiento_existente INT;
    -- Verificar si el trainer tiene el conocimiento del módulo
    SELECT COUNT(*) INTO conocimiento_existente
    FROM Trainer t
    JOIN Conocimiento c ON t.id = c.trainer_id
    WHERE t.id = NEW.trainer_id
    AND c.skill_id = (
        SELECT skill_id 
        FROM Skill 
        WHERE id = NEW.skill_id
    );
    IF conocimiento_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El trainer no tiene el conocimiento necesario para este módulo';
    END IF;
END //
DELIMITER ;

-- 17. Al cambiar el estado de un área a inactiva, liberar campers asignados.

DELIMITER //
CREATE TRIGGER liberar_campers_after_area_deactivate
AFTER UPDATE ON AreaEntrenamiento
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Inactivo' AND OLD.estado = 'Activo' THEN
        UPDATE CamperGrupo cg
        JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
        SET cg.estado_id = (SELECT id FROM EstadoCamper WHERE estado = 'Retirado')
        WHERE aae.area_id = NEW.id;
    END IF;
END //
DELIMITER ;

-- 18. Al crear una nueva ruta, clonar la plantilla base de módulos y SGDBs.

DELIMITER //
CREATE TRIGGER clonar_plantilla_after_ruta_insert
AFTER INSERT ON Ruta
FOR EACH ROW
BEGIN
    DECLARE ruta_id INT;
    -- Obtener la ruta asociada al skill del módulo
    SELECT ruta_id INTO ruta_id
    FROM Skill
    WHERE id = NEW.skill_id;
    -- Registrar en una tabla de auditoría (necesitarías crearla)
    INSERT INTO ModuloSGBD (modulo_id, sgbd_id, ruta_id)
    SELECT NEW.id, SGBD1_id, ruta_id
    FROM Ruta
    WHERE id = ruta_id;
    INSERT INTO ModuloSGBD (modulo_id, sgbd_id, ruta_id)
    SELECT NEW.id, SGBD2_id, ruta_id
    FROM Ruta
    WHERE id = ruta_id;
END //
DELIMITER ;

-- 19. Al registrar la nota práctica, verificar que no supere 60% del total.

DELIMITER //
CREATE TRIGGER verificar_nota_practica_before_insert
BEFORE INSERT ON Nota
FOR EACH ROW
BEGIN
    DECLARE nota_practica DECIMAL(5,1);
    -- Calcular la nota práctica
    SELECT SUM(n.nota * te.porcentaje / 100)
    INTO nota_practica
    FROM Nota n
    JOIN TipoEvaluacion te ON n.tipoEvaluacion_id = te.id
    WHERE n.evaluacion_id = NEW.evaluacion_id
    AND te.tipo = 'Práctica';
    IF nota_practica > 60 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La nota práctica no puede superar el 60% del total';
    END IF;
END //
DELIMITER ;

-- 20. Al modificar una ruta, notificar cambios a los trainers asignados.

DELIMITER //
CREATE TRIGGER notificar_cambios_after_ruta_update
AFTER UPDATE ON Ruta
FOR EACH ROW
BEGIN
    UPDATE AsignacionAreaEntrenamiento aae
    JOIN Trainer t ON aae.trainer_id = t.id
    SET t.ruta_id = NEW.id
    WHERE aae.ruta_id = OLD.id;
END //
DELIMITER ;
