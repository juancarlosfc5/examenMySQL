-- Triggers SQL

-- 1. Al insertar una evaluación, calcular automáticamente la nota final.


-- 2. Al actualizar la nota final de un módulo, verificar si el camper aprueba o reprueba.


-- 3. Al insertar una inscripción, cambiar el estado del camper a "Inscrito".


-- 4. Al actualizar una evaluación, recalcular su promedio inmediatamente.


-- 5. Al eliminar una inscripción, marcar al camper como “Retirado”.


-- 6. Al insertar un nuevo módulo, registrar automáticamente su SGDB asociado.


-- 7. Al insertar un nuevo trainer, verificar duplicados por identificación.


-- 8. Al asignar un área, validar que no exceda su capacidad.


-- 9. Al insertar una evaluación con nota < 60, marcar al camper como “Bajo rendimiento”.


-- 10. Al cambiar de estado a “Graduado”, mover registro a la tabla de egresados.


-- 11. Al modificar horarios de trainer, verificar solapamiento con otros.


-- 12. Al eliminar un trainer, liberar sus horarios y rutas asignadas.


-- 13. Al cambiar la ruta de un camper, actualizar automáticamente sus módulos.


-- 14. Al insertar un nuevo camper, verificar si ya existe por número de documento.


-- 15. Al actualizar la nota final, recalcular el estado del módulo automáticamente.


-- 16. Al asignar un módulo, verificar que el trainer tenga ese conocimiento.


-- 17. Al cambiar el estado de un área a inactiva, liberar campers asignados.


-- 18. Al crear una nueva ruta, clonar la plantilla base de módulos y SGDBs.


-- 19. Al registrar la nota práctica, verificar que no supere 60% del total.


-- 20. Al modificar una ruta, notificar cambios a los trainers asignados.
