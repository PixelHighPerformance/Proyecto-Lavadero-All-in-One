<?php
// Configura los parámetros de la base de datos
$servername = "localhost";  // Cambia esto si tu base de datos está en otro servidor
$username = "root";         // Usuario de la base de datos
$password = "Santanna123_";             // Contraseña de la base de datos
$dbname = "proyecto";  // Nombre de la base de datos

// Crear la conexión
$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar la conexión
if ($conn->connect_error) {
    die("Conexión fallida: " . $conn->connect_error);  // Muestra el error si la conexión falla
} else {
    echo "Conexión exitosa";  // Mensaje de éxito si la conexión es correcta
}

// Cerrar la conexión
$conn->close();
?>
