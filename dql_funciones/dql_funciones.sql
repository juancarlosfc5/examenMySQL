-- Funciones SQL

-- 1. Calcular el promedio ponderado de evaluaciones de un camper.
DELIMITER //
CREATE FUNCTION CalcularPromedioPonderado(p_camper_id INT) 
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);
    SELECT AVG(e.notaFinal) INTO promedio
    FROM Evaluacion e
    WHERE e.camper_id = p_camper_id;
    RETURN COALESCE(promedio, 0);
END //
DELIMITER ;

-- 2. Determinar si un camper aprueba o no un módulo específico.
DELIMITER //
CREATE FUNCTION DeterminarAprobacionModulo(p_camper_id INT, p_modulo_id INT) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE nota_final DECIMAL(5,1);
    SELECT e.notaFinal INTO nota_final
    FROM Evaluacion e
    JOIN Skill s ON e.skill_id = s.id
    JOIN Modulo m ON s.id = m.skill_id
    WHERE e.camper_id = p_camper_id 
    AND m.id = p_modulo_id;
    RETURN CASE 
        WHEN nota_final >= 60 THEN 'Aprobado'
        WHEN nota_final < 60 THEN 'Reprobado'
        ELSE 'No Evaluado'
    END;
END //
DELIMITER ;

-- 3. Evaluar el nivel de riesgo de un camper según su rendimiento promedio.
DELIMITER //
CREATE FUNCTION EvaluarNivelRiesgo(p_camper_id INT) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);
    SELECT AVG(notaFinal) INTO promedio
    FROM Evaluacion
    WHERE camper_id = p_camper_id;
    RETURN CASE 
        WHEN promedio >= 80 THEN 'Bajo'
        WHEN promedio >= 60 THEN 'Medio'
        ELSE 'Alto'
    END;
END //
DELIMITER ;

-- 4. Obtener el total de campers asignados a una ruta específica.
DELIMITER //
CREATE FUNCTION ObtenerTotalCampersRuta(p_ruta_id INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(DISTINCT cg.camper_id) INTO total
    FROM CamperGrupo cg
    JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
    JOIN Trainer t ON aae.trainer_id = t.id
    WHERE t.ruta_id = p_ruta_id;
    RETURN COALESCE(total, 0);
END //
DELIMITER ;

-- 5. Consultar la cantidad de módulos que ha aprobado un camper.
DELIMITER //
CREATE FUNCTION ContarModulosAprobados(p_camper_id INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM Evaluacion e
    WHERE e.camper_id = p_camper_id 
    AND e.estado = 'Aprobado';
    RETURN COALESCE(total, 0);
END //
DELIMITER ;

-- 6. Validar si hay cupos disponibles en una determinada área.
DELIMITER //
CREATE FUNCTION ValidarCuposDisponibles(p_area_id INT) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE ocupados INT;
    DECLARE capacidad INT;
    SELECT COUNT(cg.camper_id) INTO ocupados
    FROM CamperGrupo cg
    JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
    WHERE aae.area_id = p_area_id;
    SELECT g.capacidad INTO capacidad
    FROM Grupo g
    JOIN AsignacionAreaEntrenamiento aae ON g.id = aae.grupo_id
    WHERE aae.area_id = p_area_id
    LIMIT 1;
    
    RETURN ocupados < COALESCE(capacidad, 33);
END //
DELIMITER ;

-- 7. Calcular el porcentaje de ocupación de un área de entrenamiento.
DELIMITER //
CREATE FUNCTION CalcularPorcentajeOcupacion(p_area_id INT) 
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE ocupados INT;
    DECLARE capacidad INT;
    SELECT COUNT(cg.camper_id) INTO ocupados
    FROM CamperGrupo cg
    JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
    WHERE aae.area_id = p_area_id;
    SELECT g.capacidad INTO capacidad
    FROM Grupo g
    JOIN AsignacionAreaEntrenamiento aae ON g.id = aae.grupo_id
    WHERE aae.area_id = p_area_id
    LIMIT 1;
    RETURN (ocupados * 100.0) / NULLIF(capacidad, 0);
END //
DELIMITER ;

-- 8. Determinar la nota más alta obtenida en un módulo.
DELIMITER //
CREATE FUNCTION ObtenerNotaMasAlta(p_modulo_id INT) 
RETURNS DECIMAL(5,1)
DETERMINISTIC
BEGIN
    DECLARE nota_maxima DECIMAL(5,1);
    SELECT MAX(e.notaFinal) INTO nota_maxima
    FROM Evaluacion e
    JOIN Skill s ON e.skill_id = s.id
    JOIN Modulo m ON s.id = m.skill_id
    WHERE m.id = p_modulo_id;
    RETURN COALESCE(nota_maxima, 0);
END //
DELIMITER ;

-- 9. Calcular la tasa de aprobación de una ruta.
DELIMITER //
CREATE FUNCTION CalcularTasaAprobacion(p_ruta_id INT) 
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE total_evaluaciones INT;
    DECLARE aprobadas INT;
    SELECT COUNT(*) INTO total_evaluaciones
    FROM Evaluacion e
    JOIN Skill s ON e.skill_id = s.id
    WHERE s.ruta_id = p_ruta_id;
    SELECT COUNT(*) INTO aprobadas
    FROM Evaluacion e
    JOIN Skill s ON e.skill_id = s.id
    WHERE s.ruta_id = p_ruta_id 
    AND e.estado = 'Aprobado';
    RETURN (aprobadas * 100.0) / NULLIF(total_evaluaciones, 0);
END //
DELIMITER ;

-- 10. Verificar si un trainer tiene horario disponible.
DELIMITER //
CREATE FUNCTION TrainerTieneHorarioDisponible(p_trainer_id INT, p_horario_id INT) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE ocupado INT;
    SELECT COUNT(*) INTO ocupado
    FROM AsignacionAreaEntrenamiento
    WHERE trainer_id = p_trainer_id 
    AND horario_id = p_horario_id;
    RETURN ocupado = 0;
END //
DELIMITER ;

-- 11. Obtener el promedio de notas por ruta.
DELIMITER //
CREATE FUNCTION ObtenerPromedioRuta(p_ruta_id INT) 
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);
    SELECT AVG(e.notaFinal) INTO promedio
    FROM Evaluacion e
    JOIN Skill s ON e.skill_id = s.id
    WHERE s.ruta_id = p_ruta_id;
    RETURN COALESCE(promedio, 0);
END //
DELIMITER ;

-- 12. Calcular cuántas rutas tiene asignadas un trainer.
DELIMITER //
CREATE FUNCTION ContarRutasTrainer(p_trainer_id INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(DISTINCT r.id) INTO total
    FROM Trainer t
    JOIN Ruta r ON t.ruta_id = r.id
    WHERE t.id = p_trainer_id;
    RETURN COALESCE(total, 0);
END //
DELIMITER ;

-- 13. Verificar si un camper puede ser graduado.
DELIMITER //
CREATE FUNCTION PuedeSerGraduado(p_camper_id INT) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE modulos_totales INT;
    DECLARE modulos_aprobados INT;
    SELECT COUNT(DISTINCT m.id) INTO modulos_totales
    FROM Modulo m
    JOIN Skill s ON m.skill_id = s.id
    JOIN RutaSkill rs ON s.id = rs.skill_id
    JOIN CamperGrupo cg ON 1=1
    WHERE cg.camper_id = p_camper_id;
    SELECT COUNT(DISTINCT m.id) INTO modulos_aprobados
    FROM Modulo m
    JOIN Skill s ON m.skill_id = s.id
    JOIN Evaluacion e ON s.id = e.skill_id
    WHERE e.camper_id = p_camper_id 
    AND e.estado = 'Aprobado';
    RETURN modulos_aprobados >= modulos_totales;
END //
DELIMITER ;

-- 14. Obtener el estado actual de un camper en función de sus evaluaciones.
DELIMITER //
CREATE FUNCTION ObtenerEstadoCamper(p_camper_id INT) 
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);
    SELECT AVG(notaFinal) INTO promedio
    FROM Evaluacion
    WHERE camper_id = p_camper_id;
    RETURN CASE 
        WHEN promedio IS NULL THEN 'Sin Evaluaciones'
        WHEN promedio >= 80 THEN 'Excelente'
        WHEN promedio >= 60 THEN 'En Progreso'
        ELSE 'En Riesgo'
    END;
END //
DELIMITER ;

-- 15. Calcular la carga horaria semanal de un trainer.
DELIMITER //
CREATE FUNCTION CalcularCargaHoraria(p_trainer_id INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_horas INT;
    SELECT COUNT(*) * 3 INTO total_horas
    FROM AsignacionAreaEntrenamiento
    WHERE trainer_id = p_trainer_id;
    RETURN COALESCE(total_horas, 0);
END //
DELIMITER ;

-- 16. Determinar si una ruta tiene módulos pendientes por evaluación.
DELIMITER //
CREATE FUNCTION TieneModulosPendientes(p_ruta_id INT) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE total_modulos INT;
    DECLARE modulos_evaluados INT;
    SELECT COUNT(DISTINCT m.id) INTO total_modulos
    FROM Modulo m
    JOIN Skill s ON m.skill_id = s.id
    WHERE s.ruta_id = p_ruta_id;
    SELECT COUNT(DISTINCT m.id) INTO modulos_evaluados
    FROM Modulo m
    JOIN Skill s ON m.skill_id = s.id
    JOIN Evaluacion e ON s.id = e.skill_id
    WHERE s.ruta_id = p_ruta_id;
    RETURN modulos_evaluados < total_modulos;
END //
DELIMITER ;

-- 17. Calcular el promedio general del programa.
DELIMITER //
CREATE FUNCTION CalcularPromedioGeneral() 
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);
    SELECT AVG(notaFinal) INTO promedio
    FROM Evaluacion
    WHERE notaFinal IS NOT NULL;
    RETURN COALESCE(promedio, 0);
END //
DELIMITER ;

-- 18. Verificar si un horario choca con otros entrenadores en el área.
DELIMITER //
CREATE FUNCTION HorarioChocaEnArea(p_area_id INT, p_horario_id INT) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE ocupado INT;
    SELECT COUNT(*) INTO ocupado
    FROM AsignacionAreaEntrenamiento
    WHERE area_id = p_area_id 
    AND horario_id = p_horario_id;
    RETURN ocupado > 0;
END //
DELIMITER ;

-- 19. Calcular cuántos campers están en riesgo en una ruta específica.
DELIMITER //
CREATE FUNCTION ContarCampersEnRiesgo(p_ruta_id INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(DISTINCT c.id) INTO total
    FROM Camper c
    JOIN CamperGrupo cg ON c.id = cg.camper_id
    JOIN AsignacionAreaEntrenamiento aae ON cg.grupo_id = aae.grupo_id
    JOIN Trainer t ON aae.trainer_id = t.id
    WHERE t.ruta_id = p_ruta_id 
    AND c.riesgo_id = 3;
    RETURN COALESCE(total, 0);
END //
DELIMITER ;

-- 20. Consultar el número de módulos evaluados por un camper.
DELIMITER //
CREATE FUNCTION ContarModulosEvaluados(p_camper_id INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(DISTINCT m.id) INTO total
    FROM Modulo m
    JOIN Skill s ON m.skill_id = s.id
    JOIN Evaluacion e ON s.id = e.skill_id
    WHERE e.camper_id = p_camper_id;
    RETURN COALESCE(total, 0);
END //
DELIMITER ;
