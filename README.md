# Trabajo-Grupal-2

# Taller: Gestión de estudiantes con Scala y MySQL

## Descripción
Este proyecto utiliza Scala para cargar datos de estudiantes desde un archivo CSV a una base de datos MySQL. También permite obtener y mostrar todos los registros almacenados.

## Requisitos
- Scala 2.13.x o superior
- MySQL
- Dependencias:
  - [mysql-connector-java](https://mvnrepository.com/artifact/mysql/mysql-connector-java)
  - [scala-csv](https://github.com/tototoshi/scala-csv)

## Configuración
1. Crea la base de datos y tabla ejecutando el script SQL en `script.sql`.
2. Asegúrate de configurar tus credenciales de MySQL en `Main.scala`.
3. Coloca el archivo `estudiantes.csv` en el directorio raíz del proyecto.
