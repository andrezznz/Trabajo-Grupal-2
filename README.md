# Taller Grupal 2: Persistencia de Datos en Archivos y Base de Datos

## Informe sobre el Código y su Funcionalidad

Este trabajo se centra en el manejo de datos de estudiantes utilizando **Scala**, la biblioteca **Doobie** para la interacción con **MySQL**, y un archivo CSV para almacenar datos iniciales.

---

## 1. CSV de Estudiantes

El archivo `estudiantes.csv` contiene información de los estudiantes con las siguientes columnas:
- **nombre**: el nombre del estudiante.
- **edad**: la edad del estudiante.
- **calificación**: la calificación obtenida por el estudiante.
- **género**: el género del estudiante (M para masculino, F para femenino).

### **Datos incluidos en el archivo:**

```csv
nombre,edad,calificacion,genero
Andrés,10,20,M
Ana,11,19,F
Luis,9,18,M
Cecilia,9,18,F
Katy,11,15,F
Jorge,8,17,M
Rosario,11,18,F
Nieves,10,20,F
Pablo,9,19,M
Daniel,10,20,M
```

### Configuración de Conexión a Base de Datos

La configuración de la conexión a la base de datos está incluida en un archivo `db.conf` que contiene los siguientes parámetros:
```scala
db {
  driver = "com.mysql.cj.jdbc.Driver"
  url = "jdbc:mysql://localhost:3306/TallerDB"
  user = "root"
  password = "UTPL"
}
```

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

El objeto `TemperaturaDAO` contiene métodos que permiten insertar datos en la base de datos y obtenerlos:
- **insert**: inserta un solo estudiante en la base de datos.
- **insertAll**: inserta múltiples estudiantes a la vez, utilizando un `IO` para manejar efectos asíncronos.
- **getAll**: obtiene todos los estudiantes de la base de datos y los devuelve como una lista.

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


### Requisitos

Para ejecutar este proyecto, se necesitan los siguientes requisitos:
- **Scala** y **SBT** instalados.
- **MySQL** en el servidor local o remoto.
- **Doobie** para la interacción con la base de datos.



