<?php
session_start();

// Verificar si el usuario ha iniciado sesión y tiene un rol asignado
if (!isset($_SESSION['usuario']) || !isset($_SESSION['rol'])) {
    header("Location: login.php"); // Redirige al login si no está autenticado
    exit();
}

// Obtener el rol del usuario desde la sesión
$rol = $_SESSION['rol'];

// Variable para mostrar el mensaje de éxito en JavaScript
$actualizacionExitosa = false;

// Conexión a la base de datos
$conexion = new mysqli('localhost', 'root', 'Santanna123_', 'proyecto');
if ($conexion->connect_errno) {
    echo "<p>Error al conectar con la base de datos.</p>";
} else {
    // Procesar actualizaciones de precio si se envía el formulario
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_precio'])) {
        $id_servicio = $_POST['id_servicio'];
        $nuevo_precio = $_POST['nuevo_precio'];

        $update_query = "UPDATE BALANCEO_ALINEACION SET Precio = ? WHERE ID_Servicio = ?";
        $stmt = $conexion->prepare($update_query);
        $stmt->bind_param("di", $nuevo_precio, $id_servicio);

        // Ejecutar la actualización y verificar si fue exitosa
        if ($stmt->execute()) {
            $actualizacionExitosa = true;
        }
    }
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Modifica y ajusta los precios de servicios en All in One para mantener las tarifas actualizadas.">
    <meta name="keywords" content="modificar precios, ajustes de tarifas, servicios, All in One">
    <title>Modificar Precios - All in One</title>
    <link rel="stylesheet" href="../css/style.css">
    <script>
        // Mostrar alerta de éxito si se actualizó con éxito
        function mostrarAlertaActualizacion() {
            <?php if ($actualizacionExitosa): ?>
                alert('Precio actualizado con éxito.');
            <?php endif; ?>
        }
    </script>
</head>
<body onload="mostrarAlertaActualizacion()">
<header>
        <h1>Gestión de Precios</h1>
        <button onclick="window.location.href='tablero.php'">Volver al tablero</button>
         <!-- Ícono de usuario -->
         <?php if (isset($_SESSION['usuario'])): ?>
                <li class="user-menu">
                    <a href="logout.php">
                        <button id="logout-button">Cerrar sesión</button>
                    </a>
                </li>
            <?php else: ?>
                <li class="user-menu">
                    <a href="assets/pages/micuenta.html">
                        <button id="user-icon">
                            <img src="../img/perfil.png" alt="Perfil" class="icon">
                        </button>
                    </a>
                </li>
            <?php endif; ?>
    </header>
    <main>
        <table>
            <thead>
                <tr>
                    <th>ID Servicio</th>
                    <th>Tipo</th>
                    <th>Precio Actual</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                <?php
                // Consulta para obtener los servicios y sus precios
                $query = "SELECT s.ID_Servicio, ba.Tipo, ba.Precio FROM BALANCEO_ALINEACION ba INNER JOIN SERVICIO s ON ba.ID_Servicio = s.ID_Servicio
                          UNION ALL
                          SELECT s.ID_Servicio, l.Tipo_vehiculo, l.Precio FROM LAVADERO l INNER JOIN SERVICIO s ON l.ID_Servicio = s.ID_Servicio";
                
                $result = $conexion->query($query);
                if ($result->num_rows > 0) {
                    while ($servicio = $result->fetch_assoc()) {
                        echo '<tr>';
                        echo '<td>' . $servicio['ID_Servicio'] . '</td>';
                        echo '<td>' . $servicio['Tipo'] . '</td>';
                        echo '<td>' . number_format($servicio['Precio'], 2) . '</td>';
                        echo '<td>';
                        echo '<form method="post" action="">';
                        echo '<input type="hidden" name="id_servicio" value="' . $servicio['ID_Servicio'] . '">';
                        echo '<input type="number" name="nuevo_precio" step="0.01" required>';
                        echo '<button type="submit" name="update_precio">Actualizar Precio</button>';
                        echo '</form>';
                        echo '</td>';
                        echo '</tr>';
                    }
                } else {
                    echo '<tr><td colspan="4">No hay servicios registrados.</td></tr>';
                }
                ?>
            </tbody>
        </table>
        <br>

    </main>
    <footer>
        <p>&copy; 2024 Parking. Todos los derechos reservados.</p>
    </footer>
</body>
</html>
