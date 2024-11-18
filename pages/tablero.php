<?php
session_start();

// Verificar si el usuario ha iniciado sesión y tiene un rol asignado
if (!isset($_SESSION['usuario']) || !isset($_SESSION['rol'])) {
    header("Location: login.php"); // Redirige al login si no está autenticado
    exit();
}

// Obtener el rol del usuario desde la sesión
$rol = $_SESSION['rol'];
$actualizacionExitosa = false;

// Conexión a la base de datos
$conexion = new mysqli('localhost', 'root', 'Santanna123_', 'proyecto');
if ($conexion->connect_errno) {
    echo "<p>Error al conectar con la base de datos.</p>";
} else {
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_reserva'])) {
        $id_reserva = $_POST['id_reserva'];
        $estado = $_POST['estado']; // Obtener el estado actualizado desde el formulario
        
        // Consulta para actualizar solo el estado
        $update_query = "UPDATE RESERVA SET estado = ? WHERE ID_Reserva = ?";
        $stmt = $conexion->prepare($update_query);
        $stmt->bind_param("si", $estado, $id_reserva);

        if ($stmt->execute()) {
            $actualizacionExitosa = true; // Indicar que la actualización fue exitosa
        } else {
            echo "Error al actualizar el estado: " . $stmt->error;
        }
    }
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - <?php echo $rol; ?></title>
    <link rel="stylesheet" href="../css/style.css">
    <script>
        function mostrarAlertaActualizacion() {
            <?php if ($actualizacionExitosa): ?>
                alert('Reserva actualizada con éxito.');
                document.getElementById('reservas').style.display = 'block';
            <?php endif; ?>
        }
    </script>
</head>
<body onload="mostrarAlertaActualizacion()">
    <header>
        <h1>Bienvenido al Dashboard <?php echo $rol; ?></h1>
        <button onclick="mostrarReservas()">Ver Reservas</button>
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

    <main class="dashboard-grid">
        <section class="dashboard-card">
            <?php if ($rol == 'Gerente'): ?>
                <h2>Opciones para Gerente</h2>
                <ul>
                    <li><a href="modificarprecios.php">Modificar Precios</a></li>
                    <li><a href="jefedeservicio.php">Jefe de Servicio</a></li>
                    <li><a href="neumaticosbaja.php">Neumáticos</a></li>
                    <li><a href="ejecutivodeservicio.php">Ejecutivos</a></li>
                    <li><a href="ingresardatos.php">Ingresar Datos</a></li>
                    <li><a href="crud_cliente.php">Clientes</a></li>
                    <li><a href="servicios.php">Servicios</a></li>
                </ul>
            <?php elseif ($rol == 'Cajero'): ?>
                <h2>Opciones para Cajero</h2>
                <ul>
                    <li><a href="autorizacion.php">Autorización de entrega de vehículo</a></li>
                </ul>
            <?php elseif ($rol == 'Jefe de servicio de lavadero' || $rol == 'Jefe de servicio de balanceo y alineación'): ?>
                <h2>Opciones para Jefe de Servicio</h2>
                <ul>
                    <li><a href="ejecutivodeservicio.php">Ejecutivos</a></li>
                    <li><a href="crud_cliente.php">Clientes</a></li>
                    <li><a href="ingresardatos.php">Ingresar Datos</a></li>
                    <li><a href="servicios.php">Servicios</a></li>
                </ul>
            <?php elseif ($rol == 'Ejecutivo de servicio de lavadero' || $rol == 'Ejecutivo de servicio de balanceo y alineación' || $rol == 'Ejecutivo de servicio de neumáticos'): ?>
                <h2>Opciones para Ejecutivo de Servicio</h2>
                <ul>
                    <li><a href="crud_cliente.php">Clientes</a></li>
                    <li><a href="ingresardatos.php">Ingresar Datos</a></li>
                    <li><a href="servicios.php">Servicios</a></li>
                </ul>
            <?php else: ?>
                <p>No tienes permisos para acceder a este dashboard.</p>
            <?php endif; ?>
        </section>
    </main>

    <section id="reservas" class="dashboard-grid" style="display: <?php echo $actualizacionExitosa ? 'block' : 'none'; ?>;">
        <h2>Reservas</h2>
        <div class="reservas-grid">
            <?php
            if ($conexion) {
                $resultado = $conexion->query("SELECT * FROM RESERVA");
                if ($resultado->num_rows > 0) {
                    while ($reserva = $resultado->fetch_assoc()) {
                        echo '<div class="dashboard-card reserva-card">';
                        echo '<h3>Reserva #' . $reserva['ID_Reserva'] . '</h3>';
                        echo '<p><strong>Fecha:</strong> ' . $reserva['Fecha'] . '</p>';
                        echo '<p><strong>Hora Inicio:</strong> ' . (isset($reserva['Hora_Inicio']) ? $reserva['Hora_Inicio'] : 'No definido') . '</p>';
                        echo '<p><strong>Estado de Autorización:</strong> ' . ($reserva['Estado_Autorizacion'] ?? 'No Autorizado') . '</p>';
                        
                        // Generar el formulario con el estado correcto
                        echo '<form method="post" action="">';
                        echo '<input type="hidden" name="id_reserva" value="' . $reserva['ID_Reserva'] . '">';
                        echo '<label for="estado">Estado:</label>';
                        echo '<select name="estado">';
                        $estados = ['Pendiente', 'Confirmada', 'Cancelada a tiempo', 'Cancelada tarde', 'Completada', 'No asiste'];
                        foreach ($estados as $opcion) {
                            $selected = ($reserva['estado'] === $opcion) ? ' selected' : ''; // Usar correctamente 'estado'
                            echo '<option value="' . $opcion . '"' . $selected . '>' . $opcion . '</option>';
                        }
                        echo '</select>';
                        echo '<button type="submit" name="update_reserva">Actualizar</button>';
                        echo '</form>';
                        echo '</div>';
                    }
                } else {
                    echo '<p>No hay reservas registradas.</p>';
                }
                $conexion->close();
            }
            ?>
        </div>
    </section>

    <footer>
        <div class="social-media">
            <a href="#"><img src="../img/x.png" alt="Twitter"></a>
            <a href="#"><img src="../img/instagram.png" alt="Instagram"></a>
        </div>
        <p>&copy; 2024 Parking. Todos los derechos reservados.</p>
    </footer>

    <script>
        function mostrarReservas() {
            const reservasSection = document.getElementById('reservas');
            reservasSection.style.display = reservasSection.style.display === 'none' ? 'block' : 'none';
        }
    </script>
</body>
</html>
