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

// Procesar la autorización si se envía el formulario
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['autorizar'])) {
    $id_reserva = $_POST['id_reserva'];
    $estado_autorizacion = $_POST['estado_autorizacion'];

    // Actualizar el estado de autorización en la base de datos
    $query_update = "UPDATE RESERVA SET Estado_Autorizacion = ? WHERE ID_Reserva = ?";
    $stmt = $conexion->prepare($query_update);
    $stmt->bind_param("si", $estado_autorizacion, $id_reserva);

    if ($stmt->execute()) {
        echo "<script>alert('Autorización actualizada correctamente para la entrega del vehículo.');</script>";
    } else {
        echo "<p>Error al autorizar el vehículo: " . $conexion->error . "</p>";
    }

    $stmt->close();
}

// Consulta para obtener reservas en estado 'Confirmada' o 'Completada'
$resultado = $conexion->query("SELECT * FROM RESERVA WHERE Estado IN ('Confirmada', 'Completada')");
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Página de autorización para la entrega de vehículos en el sistema All in One. Accede con tu cuenta y rol asignado.">
    <meta name="keywords" content="autorización, entrega de vehículos, All in One, sistema de gestión">
    <title>Autorización de Servicios - All in One</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<header>
    <h1>Autorización de entregas</h1>
    <a href="tablero.php" class="boton-volver">Volver al Tablero</a>
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
    <h2>Vehículos en Lavadero y Taller</h2>
    <form method="post">
        <table>
            <tr>
                <th>ID Reserva</th>
                <th>Fecha</th>
                <th>Hora Inicio</th>
                <th>Hora Fin</th>
                <th>Estado</th>
                <th>Autorizar</th>
            </tr>
            <?php if ($resultado && $resultado->num_rows > 0): ?>
                <?php while ($reserva = $resultado->fetch_assoc()): ?>
                    <tr>
                        <td><?php echo $reserva['ID_Reserva']; ?></td>
                        <td><?php echo $reserva['Fecha']; ?></td>
                        <td><?php echo $reserva['Hora_Inicio']; ?></td>
                        <td><?php echo $reserva['Hora_Fin']; ?></td>
                        <td><?php echo $reserva['Estado']; ?></td>
                        <td>
                            <input type="hidden" name="id_reserva" value="<?php echo $reserva['ID_Reserva']; ?>">
                            <select name="estado_autorizacion">
                                <option value="Autorizado">Autorizar</option>
                                <option value="No Autorizado">No Autorizar</option>
                            </select>
                            <button type="submit" name="autorizar">Enviar</button>
                        </td>
                    </tr>
                <?php endwhile; ?>
            <?php else: ?>
                <tr>
                    <td colspan="6">No hay vehículos en Lavadero o Taller.</td>
                </tr>
            <?php endif; ?>
        </table>
    </form>
</main>
</body>
</html>
