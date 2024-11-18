<?php
session_start();

// Verificar si el usuario ha iniciado sesión
if (!isset($_SESSION['usuario']) || !isset($_SESSION['rol'])) {
    header("Location: login.php"); // Redirige al login si no está autenticado
    exit();
}

// Conexión a la base de datos
$conexion = new mysqli('localhost', 'root', 'Santanna123_', 'proyecto');
if ($conexion->connect_errno) {
    die("<p>Error al conectar con la base de datos: " . $conexion->connect_error . "</p>");
}

// Variables para manejar mensajes
$insercionExitosa = false;
$mensaje = "";

// Procesar inserción de datos
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Mostrar los valores recibidos para depuración
    echo "<pre>";
    echo "POST Data: ";
    print_r($_POST);
    echo "</pre>";

    if (isset($_POST['id_servicio']) && !empty($_POST['id_servicio'])) {
        $idServicio = $_POST['id_servicio']; // Capturar el ID Servicio
        $tipoServicio = $_POST['tipo_servicio']; // Tipo del servicio

        // Lógica para insertar dependiendo del tipo de servicio
        if ($tipoServicio == 'Lavadero' && isset($_POST['agregar_lavadero'])) {
            $tipoVehiculo = $_POST['tipo_vehiculo'];
            $precio = $_POST['precio_lavadero'];

            // Insertar en la tabla LAVADERO
            $insert_query = "INSERT INTO LAVADERO (ID_Servicio, Tipo_vehiculo, Precio) VALUES (?, ?, ?)";
            $stmt = $conexion->prepare($insert_query);
            if ($stmt) {
                $stmt->bind_param("isd", $idServicio, $tipoVehiculo, $precio);
                if ($stmt->execute()) {
                    $insercionExitosa = true;
                    $mensaje = "Servicio Lavadero agregado con éxito.";
                } else {
                    $mensaje = "Error al agregar Lavadero: " . $stmt->error;
                }
                $stmt->close();
            } else {
                $mensaje = "Error preparando la consulta para Lavadero.";
            }

        } elseif ($tipoServicio == 'Parking' && isset($_POST['agregar_parking'])) {
            $precioPorHora = $_POST['precio_parking'];
            $tipoPlaza = $_POST['tipo_plaza'];

            // Insertar en la tabla COSTO_PARKING
            $insert_query = "INSERT INTO COSTO_PARKING (ID_Servicio, Tipo_vehiculo, Costo_por_hora) VALUES (?, ?, ?)";
            $stmt = $conexion->prepare($insert_query);
            if ($stmt) {
                $stmt->bind_param("isd", $idServicio, $tipoPlaza, $precioPorHora);
                if ($stmt->execute()) {
                    $insercionExitosa = true;
                    $mensaje = "Servicio Parking agregado con éxito.";
                } else {
                    $mensaje = "Error al agregar Parking: " . $stmt->error;
                }
                $stmt->close();
            } else {
                $mensaje = "Error preparando la consulta para Parking.";
            }

        } elseif ($tipoServicio == 'Taller' && isset($_POST['agregar_taller'])) {
            $tipoTaller = $_POST['tipo_taller'];
            $precio = $_POST['precio_taller'];

            // Insertar en la tabla BALANCEO_ALINEACION
            $insert_query = "INSERT INTO BALANCEO_ALINEACION (ID_Servicio, Precio, Tipo) VALUES (?, ?, ?)";
            $stmt = $conexion->prepare($insert_query);
            if ($stmt) {
                $stmt->bind_param("ids", $idServicio, $precio, $tipoTaller);
                if ($stmt->execute()) {
                    $insercionExitosa = true;
                    $mensaje = "Servicio Taller agregado con éxito.";
                } else {
                    $mensaje = "Error al agregar Taller: " . $stmt->error;
                }
                $stmt->close();
            } else {
                $mensaje = "Error preparando la consulta para Taller.";
            }

        } elseif ($tipoServicio == 'Neumáticos' && isset($_POST['agregar_neumaticos'])) {
            $precioNeumatico = $_POST['precio_neumatico'];
            $marcaNeumatico = $_POST['marca_neumatico'];
            $stock = $_POST['stock_neumatico'];

            // Insertar en la tabla NEUMATICO
            $insert_query = "INSERT INTO NEUMATICO (ID_Servicio, Precio, Marca, Stock) VALUES (?, ?, ?, ?)";
            $stmt = $conexion->prepare($insert_query);
            if ($stmt) {
                $stmt->bind_param("idss", $idServicio, $precioNeumatico, $marcaNeumatico, $stock);
                if ($stmt->execute()) {
                    $insercionExitosa = true;
                    $mensaje = "Servicio Neumáticos agregado con éxito.";
                } else {
                    $mensaje = "Error al agregar Neumáticos: " . $stmt->error;
                }
                $stmt->close();
            } else {
                $mensaje = "Error preparando la consulta para Neumáticos.";
            }
        }
    } else {
        $mensaje = "Error: ID Servicio no proporcionado.";
    }
}

$conexion->close();
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Explora los servicios de automóviles que ofrece All in One, incluyendo lavado, mantenimiento y más.">
    <meta name="keywords" content="servicios de automóviles, lavado, mantenimiento, All in One">
    <title>Servicios de Automóviles - All in One</title>
    <link rel="stylesheet" href="../css/style.css">
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            // Ocultar todas las secciones inicialmente
            document.getElementById('lavadero_section').style.display = 'none';
            document.getElementById('parking_section').style.display = 'none';
            document.getElementById('taller_section').style.display = 'none';
            document.getElementById('neumaticos_section').style.display = 'none';

            // Mostrar la sección correspondiente según la selección
            document.getElementById('tipo_servicio').addEventListener('change', function () {
                document.getElementById('lavadero_section').style.display = 'none';
                document.getElementById('parking_section').style.display = 'none';
                document.getElementById('taller_section').style.display = 'none';
                document.getElementById('neumaticos_section').style.display = 'none';

                if (this.value === 'Lavadero') {
                    document.getElementById('lavadero_section').style.display = 'block';
                } else if (this.value === 'Parking') {
                    document.getElementById('parking_section').style.display = 'block';
                } else if (this.value === 'Taller') {
                    document.getElementById('taller_section').style.display = 'block';
                } else if (this.value === 'Neumáticos') {
                    document.getElementById('neumaticos_section').style.display = 'block';
                }
            });
        });
    </script>
</head>
<body>
<header>
    <h1>Gestión de Servicios</h1>
    <a href="tablero.php" class="boton-volver">Volver al Tablero</a>
</header>
<main>
  

    <form method="post">
        <label for="tipo_servicio">Tipo de Servicio:</label>
        <select id="tipo_servicio" name="tipo_servicio" required>
            <option value="">Seleccione un servicio</option>
            <option value="Lavadero">Lavadero</option>
            <option value="Parking">Parking</option>
            <option value="Taller">Taller</option>
            <option value="Neumáticos">Neumáticos</option>
        </select>

        <!-- Sección para Lavadero -->
        <div id="lavadero_section">
            <label for="id_servicio_lavadero">ID Servicio:</label>
            <input type="text" id="id_servicio_lavadero" name="id_servicio" required>
            <label for="tipo_vehiculo">Tipo de Vehículo:</label>
            <input type="text" id="tipo_vehiculo" name="tipo_vehiculo" required>
            <label for="precio_lavadero">Precio Lavadero:</label>
            <input type="number" id="precio_lavadero" name="precio_lavadero" step="0.01" required>
            <button type="submit" name="agregar_lavadero">Agregar Lavadero</button>
        </div>

        <!-- Sección para Parking -->
        <div id="parking_section">
            <label for="id_servicio_parking">ID Servicio:</label>
            <input type="text" id="id_servicio_parking" name="id_servicio" required>
            <label for="tipo_plaza">Tipo de Plaza:</label>
            <input type="text" id="tipo_plaza" name="tipo_plaza" required>
            <label for="precio_parking">Precio por Hora:</label>
            <input type="number" id="precio_parking" name="precio_parking" step="0.01" required>
            <button type="submit" name="agregar_parking">Agregar Parking</button>
        </div>

        <!-- Sección para Taller -->
        <div id="taller_section">
            <label for="id_servicio_taller">ID Servicio:</label>
            <input type="text" id="id_servicio_taller" name="id_servicio" required>
            <label for="tipo_taller">Tipo de Servicio de Taller:</label>
            <input type="text" id="tipo_taller" name="tipo_taller" required>
            <label for="precio_taller">Precio Servicio de Taller:</label>
            <input type="number" id="precio_taller" name="precio_taller" step="0.01" required>
            <button type="submit" name="agregar_taller">Agregar Taller</button>
        </div>

        <!-- Sección para Neumáticos -->
        <div id="neumaticos_section">
            <label for="id_servicio_neumaticos">ID Servicio:</label>
            <input type="text" id="id_servicio_neumaticos" name="id_servicio" required>
            <label for="precio_neumatico">Precio Neumático:</label>
            <input type="number" id="precio_neumatico" name="precio_neumatico" step="0.01" required>
            <label for="marca_neumatico">Marca Neumático:</label>
            <input type="text" id="marca_neumatico" name="marca_neumatico" required>
            <label for="stock_neumatico">Stock:</label>
            <input type="number" id="stock_neumatico" name="stock_neumatico" required>
            <button type="submit" name="agregar_neumaticos">Agregar Neumáticos</button>
        </div>
    </form>
</main>
</body>
</html>
