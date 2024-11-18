<?php
session_start();

if (!isset($_SESSION['usuario']) || !isset($_SESSION['rol'])) {
    header("Location: login.php");
    exit();
}

$conexion = new mysqli('localhost', 'root', 'Santanna123_', 'proyecto');
if ($conexion->connect_errno) {
    echo "Error al conectar con la base de datos.";
    exit();
}

$mensaje = ""; // Variable para almacenar mensajes

// Procesar actualización de cliente
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update'])) {
    $ci_cliente = $_POST['ci_cliente'];
    $nombre = $_POST['nombre'];
    $apellido = $_POST['apellido'];
    $celular = $_POST['celular'];
    $fecha_nac = $_POST['fecha_nacimiento'];
    $telefono = $_POST['telefono'];
    $tipo = $_POST['tipo'];
    $descuento = floatval($_POST['descuento']); // Convertir a número decimal

    // Mostrar datos recibidos para depuración
    // echo "<pre>"; print_r($_POST); echo "</pre>";

    $tipos_validos = ['Mensual', 'Sistemático', 'Eventual', 'Extraordinario'];
    if (!in_array($tipo, $tipos_validos)) {
        $mensaje = "Error: Tipo no válido.";
    } else {
        $update_query = "UPDATE CLIENTE SET Nombre = ?, Apellido = ?, Celular = ?, Fecha_Nac = ?, Teléfono = ?, Tipo = ?, Descuento = ? WHERE CI_Cliente = ?";
        $stmt = $conexion->prepare($update_query);
        if ($stmt) {
            $stmt->bind_param("sssssdss", $nombre, $apellido, $celular, $fecha_nac, $telefono, $tipo, $descuento, $ci_cliente);
            if ($stmt->execute()) {
                $mensaje = "Cliente modificado con éxito.";
            } else {
                $mensaje = "Error al modificar el cliente: " . $stmt->error;
            }
            $stmt->close();
        } else {
            $mensaje = "Error en la preparación de la consulta.";
        }
    }
}

// Procesar agregado de nuevo cliente
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add'])) {
    $ci_cliente = $_POST['ci_cliente'];
    $nombre = $_POST['nombre'];
    $apellido = $_POST['apellido'];
    $celular = $_POST['celular'];
    $fecha_nac = $_POST['fecha_nacimiento'];
    $telefono = $_POST['telefono'];
    $contraseña = md5($_POST['contrasena']);
    $tipo = $_POST['tipo'];
    $descuento = floatval($_POST['descuento']);

    $tipos_validos = ['Mensual', 'Sistemático', 'Eventual', 'Extraordinario'];
    if (!in_array($tipo, $tipos_validos)) {
        $mensaje = "Error: Tipo no válido.";
    } else {
        $insert_query = "INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Fecha_Nac, Contraseña, Teléfono, Tipo, Descuento) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        $stmt = $conexion->prepare($insert_query);
        if ($stmt) {
            $stmt->bind_param("ssssssssd", $ci_cliente, $nombre, $apellido, $celular, $fecha_nac, $contraseña, $telefono, $tipo, $descuento);
            if ($stmt->execute()) {
                $mensaje = "Cliente añadido con éxito.";
            } else {
                $mensaje = "Error al añadir cliente: " . $stmt->error;
            }
            $stmt->close();
        } else {
            $mensaje = "Error en la preparación de la consulta.";
        }
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Clientes</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<header>
    <h1>Gestión de Clientes</h1>
    <button onclick="window.location.href='tablero.php'">Volver al tablero</button>
    <?php if (isset($_SESSION['usuario'])): ?>
        <li class="user-menu">
            <a href="logout.php">
                <button id="logout-button">Cerrar sesión</button>
            </a>
        </li>
    <?php endif; ?>
</header>
<main>
    <h2>Agregar Nuevo Cliente</h2>
    <form method="post" action="">
        <label for="ci_cliente">CI:</label>
        <input type="text" id="ci_cliente" name="ci_cliente" required>
        <br>
        <label for="nombre">Nombre:</label>
        <input type="text" id="nombre" name="nombre" required>
        <br>
        <label for="apellido">Apellido:</label>
        <input type="text" id="apellido" name="apellido" required>
        <br>
        <label for="celular">Celular:</label>
        <input type="text" id="celular" name="celular" required>
        <br>
        <label for="fecha_nacimiento">Fecha de Nacimiento:</label>
        <input type="date" id="fecha_nacimiento" name="fecha_nacimiento" required>
        <br>
        <label for="telefono">Teléfono:</label>
        <input type="text" id="telefono" name="telefono" required>
        <br>
        <label for="contrasena">Contraseña:</label>
        <input type="password" id="contrasena" name="contrasena" required>
        <br>
        <label for="tipo">Tipo:</label>
        <select id="tipo" name="tipo" required>
            <option value="Mensual">Mensual</option>
            <option value="Sistemático">Sistemático</option>
            <option value="Eventual">Eventual</option>
            <option value="Extraordinario">Extraordinario</option>
        </select>
        <br>
        <label for="descuento">Descuento:</label>
        <input type="number" id="descuento" name="descuento" step="0.01" min="0" max="10" required>
        <br>
        <button type="submit" name="add">Agregar</button>
    </form>
    <h2>Lista de Clientes</h2>
    <table>
        <thead>
            <tr>
                <th>CI</th>
                <th>Nombre</th>
                <th>Apellido</th>
                <th>Celular</th>
                <th>Teléfono</th>
                <th>Fecha de Nacimiento</th>
                <th>Tipo</th>
                <th>Descuento</th>
                <th>Acciones</th>
            </tr>
        </thead>
        <tbody>
            <?php
            $query = "SELECT * FROM CLIENTE";
            $result = $conexion->query($query);
            if ($result->num_rows > 0) {
                while ($cliente = $result->fetch_assoc()) {
                    echo '<tr>';
                    echo '<td>' . $cliente['CI_Cliente'] . '</td>';
                    echo '<td>' . $cliente['Nombre'] . '</td>';
                    echo '<td>' . $cliente['Apellido'] . '</td>';
                    echo '<td>' . $cliente['Celular'] . '</td>';
                    echo '<td>' . $cliente['Teléfono'] . '</td>';
                    echo '<td>' . $cliente['Fecha_Nac'] . '</td>';
                    echo '<td>' . $cliente['Tipo'] . '</td>';
                    echo '<td>' . $cliente['Descuento'] . '</td>';
                    echo '<td>';
                    echo '<form method="post" action="" style="display:inline-block;">';
                    echo '<input type="hidden" name="ci_cliente" value="' . $cliente['CI_Cliente'] . '">';
                    echo '<input type="text" name="nombre" value="' . htmlspecialchars($cliente['Nombre'], ENT_QUOTES) . '" required>';
                    echo '<input type="text" name="apellido" value="' . htmlspecialchars($cliente['Apellido'], ENT_QUOTES) . '" required>';
                    echo '<input type="text" name="celular" value="' . htmlspecialchars($cliente['Celular'], ENT_QUOTES) . '" required>';
                    echo '<input type="date" name="fecha_nacimiento" value="' . $cliente['Fecha_Nac'] . '" required>';
                    echo '<input type="text" name="telefono" value="' . htmlspecialchars($cliente['Teléfono'], ENT_QUOTES) . '" required>';
                    echo '<select name="tipo" required>';
                    echo '<option value="Mensual" ' . ($cliente['Tipo'] === 'Mensual' ? 'selected' : '') . '>Mensual</option>';
                    echo '<option value="Sistemático" ' . ($cliente['Tipo'] === 'Sistemático' ? 'selected' : '') . '>Sistemático</option>';
                    echo '<option value="Eventual" ' . ($cliente['Tipo'] === 'Eventual' ? 'selected' : '') . '>Eventual</option>';
                    echo '<option value="Extraordinario" ' . ($cliente['Tipo'] === 'Extraordinario' ? 'selected' : '') . '>Extraordinario</option>';
                    echo '</select>';
                    echo '<input type="number" name="descuento" value="' . htmlspecialchars($cliente['Descuento'], ENT_QUOTES) . '" step="0.01" required>';
                    echo '<button type="submit" name="update">Modificar</button>';
                    echo '</form>';
                    echo '</td>';
                    echo '</tr>';
                }
            } else {
                echo '<tr><td colspan="9">No hay clientes registrados.</td></tr>';
            }
            ?>
        </tbody>
    </table>
    <p><?php echo $mensaje; ?></p>
</main>
<footer>
    <p>&copy; 2024 Gestión de Clientes. Todos los derechos reservados.</p>
</footer>
</body>
</html>
<?php
$conexion->close();
?>
