# Taller Grupal 2: Persistencia de Datos en Archivos y Base de Datos

#### Datos:
```
nombre  edad  calificacion  genero
Andrés  10    20            M
Ana     11    19            F
Luis    9     18            M
Cecilia 9     18            F
Katy    11    15            F
Jorge   8     17            M
Rosario 11    18            F
Nieves  10    20            F
Pablo   9     19            M
Daniel  10    20            M
```

### Configuración de Conexión a Base de Datos

La configuración de la conexión a la base de datos está incluida en un archivo `db.conf` que contiene los siguientes parámetros:
```scala
db {
  driver = "com.mysql.cj.jdbc.Driver"
  url = "jdbc:mysql://localhost:3306/trabajoGrupo2"
  user = "root"
  password = "UTPL"
}
```
Aquí se establece:
- **driver**: el controlador JDBC necesario para conectar con MySQL.
- **url**: la URL de la base de datos (en este caso, se conecta a un servidor local con la base de datos `trabajoGrupo2`).
- **user** y **password**: las credenciales de acceso a la base de datos.

![WhatsApp Image 2025-01-31 at 20 47 19_7e6f3c28](https://github.com/user-attachments/assets/b2a3fe04-6836-415a-968c-c90e4c0dbfcb)

### Gestión de Conexiones con Doobie

En el objeto `Database`, se configura la conexión a la base de datos utilizando el transactor de Doobie:
```scala
def transactor: Resource[IO, HikariTransactor[IO]] = {
  val config = ConfigFactory.load().getConfig("db")
  HikariTransactor.newHikariTransactor[IO](
    config.getString("driver"),
    config.getString("url"),
    config.getString("user"),
    config.getString("password"),
    connectEC
  )
}
```
Esto crea un transactor que facilita la ejecución de consultas SQL en un contexto de efectos en Scala, garantizando que las conexiones a la base de datos se gestionen adecuadamente.

### DAO (Data Access Object)

# TemperaturaDAO

El objeto `TemperaturaDAO` contiene métodos que permiten interactuar con la base de datos para manejar los datos de estudiantes. A continuación, se detallan las funcionalidades proporcionadas junto con los fragmentos de código correspondientes:

---

### 1. Método `insert`

El método `insert` permite insertar un solo estudiante en la base de datos. Este método utiliza una consulta SQL parametrizada para asegurar la seguridad frente a inyecciones de SQL.

```scala
def insert(estudiantes: Estudiantes): ConnectionIO[Int] = {
  sql"""
   INSERT INTO estudiantes (nombre, edad, calificacion, genero)
   VALUES (
     ${estudiantes.nombre},
     ${estudiantes.edad},
     ${estudiantes.calificacion},
     ${estudiantes.genero}
   )
 """.update.run
}
```
### 2. Método `insertAll`

El método `insertAll` permite insertar múltiples estudiantes de una sola vez. Se utiliza traverse para procesar cada estudiante individualmente y realizar las inserciones en la base de datos.

```scala
def insertAll(estudiantes: List[Estudiantes]): IO[List[Int]] = {
  Database.transactor.use { xa =>
    estudiantes.traverse(t => insert(t).transact(xa))
  }
}
```
### 3. Método `getAll`

El método `getAll` permite recuperar todos los registros de la tabla estudiantes en la base de datos. Los registros se mapean a objetos del tipo Estudiantes.

```scala
def getAll: IO[List[Estudiantes]] = {
  val query = sql"""
    SELECT nombre, edad, calificacion, genero
    FROM estudiantes
  """.query[Estudiantes] // Mapear resultado a objetos Estudiantes

  Database.transactor.use { xa =>
    query.to[List].transact(xa) // Ejecutar la consulta y devolver la lista
  }
}
```
Explicación:
Utiliza una consulta SQL simple para seleccionar todas las columnas de la tabla estudiantes.

Usa el método `query[Estudiantes]` de doobie para mapear los resultados de la consulta a objetos Estudiantes.

Devuelve un efecto `IO[List[Estudiantes]]` que contiene la lista de estudiantes obtenidos.

### Modelo `Estudiantes`

El caso de clase `Estudiantes` define los campos que se utilizarán para mapear los datos obtenidos de la base de datos:
```scala
case class Estudiantes(
  nombre: String,
  edad: Int,
  calificacion: Double,
  genero: String
)
```
# Main Program: Procesamiento y Gestión de Estudiantes
---

## Características Principales

1. **Lectura de datos desde un archivo CSV**:
   - El programa utiliza la biblioteca `kantan.csv` para leer los datos desde un archivo llamado `estudiantes.csv`.
   - Los datos se procesan y convierten en objetos de tipo `Estudiantes`.

2. **Inserción de datos en la base de datos**:
   - Los registros leídos del archivo CSV se insertan en una base de datos utilizando el método `insertAll` del objeto `TemperaturaDAO`.

3. **Recuperación de registros desde la base de datos**:
   - Una vez insertados, el programa utiliza el método `getAll` del objeto `TemperaturaDAO` para obtener todos los registros almacenados en la base de datos y los imprime en la consola.

---

## Estructura del Programa

### 1. **Lectura de Datos desde CSV**

El archivo CSV se encuentra en la ruta `src/main/resources/data/estudiantes.csv`. El programa utiliza `kantan.csv` para leer y mapear los datos en una lista de objetos `Estudiantes`.

#### Código:
```scala
val path2DataFile2 = "src/main/resources/data/estudiantes.csv"

val dataSource = new File(path2DataFile2)
  .readCsv[List, Estudiantes](rfc.withHeader.withCellSeparator(','))

val estudiantes = dataSource.collect {
  case Right(estudiantes) => estudiantes
}
```
### 2. Inserción de Datos en la Base de Datos

Los registros procesados del CSV se insertan en la base de datos mediante el método insertAll del objeto TemperaturaDAO.

```scala
inserted <- TemperaturaDAO.insertAll(estudiantes)
_ <- IO.println(s"Registros insertados: ${inserted.size}")
```

### 3. Obtención de Registros desde la Base de Datos
```scala
allEstudiantes <- TemperaturaDAO.getAll
_ <- IO.println("Registros actuales en la base de datos:")
_ <- IO.println(allEstudiantes.mkString("\n"))
```

![WhatsApp Image 2025-01-31 at 20 46 52_5e36a1aa](https://github.com/user-attachments/assets/19261dc5-4d7c-476a-8d43-c5c8a6a0f1e4)


### Requisitos

Para ejecutar este proyecto, se necesitan los siguientes requisitos:
- **Scala** y **SBT** instalados.
- **MySQL** en el servidor local o remoto.
- **Doobie** para la interacción con la base de datos.

### Instalación

1. Clonar el repositorio.
2. Configurar la base de datos MySQL con la tabla `estudiantes`.
3. Actualizar el archivo `db.conf` con las credenciales correctas.
4. Ejecutar el proyecto usando SBT.

### Dependencias

El proyecto utiliza las siguientes dependencias de Scala:
- **Doobie**: Para interactuar con la base de datos.
- **Cats Effect**: Para manejar efectos asíncronos.
- **HikariCP**: Para gestionar las conexiones de la base de datos.
```Scala
import scala.collection.immutable.Seq

ThisBuild / version := "0.1.0-SNAPSHOT"
ThisBuild / scalaVersion := "2.13.12"
lazy val root = (project in file("."))
  .settings(
    name := "untitled1",
    libraryDependencies ++= Seq("io.reactivex" %% "rxscala" % "0.27.0",            // Última versión compatible
      "com.lihaoyi" %% "scalarx" % "0.4.3",              // Actualización de scalarx
      "com.nrinaudo" %% "kantan.csv" % "0.6.1",          // Actualización de kantan.csv
      "com.nrinaudo" %% "kantan.csv-generic" % "0.6.1",  // Actualización de kantan.csv-generic
      "com.typesafe.play" %% "play-json" % "2.9.2",       // Librerías para trabajar con JSON
      "org.scalikejdbc" %% "scalikejdbc" % "4.0.0",
      "ch.qos.logback" % "logback-classic" % "1.2.3",
      "org.tpolecat" %% "doobie-core" % "1.0.0-RC5",      // Dependencias de doobie
      "org.tpolecat" %% "doobie-hikari" % "1.0.0-RC5",    // Para gestión de conexiones
      "com.mysql" % "mysql-connector-j" % "8.0.31",       // Driver para MySQL
      "com.typesafe" % "config"           % "1.4.2",
      "ch.qos.logback" % "logback-classic" % "1.2.3"// Para gestión de archivos de configuración
    )
  )
```
