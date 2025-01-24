CREATE DATABASE TallerDB;

USE TallerDB;

CREATE TABLE Estudiantes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    edad INT,
    calificacion INT,
    genero CHAR(1)
);
