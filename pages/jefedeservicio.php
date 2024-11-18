<?php
session_start(); // Iniciar la sesión del usuario

// Verificar si el usuario ha iniciado sesión y tiene un rol asignado
if (!isset($_SESSION['usuario']) || !isset($_SESSION['rol'])) {
    header("Location: login.php"); // Redirigir al login si no está autenticado
    exit(); // Finalizar la ejecución del script
}

// Conectar a la base de datos
$conexion = new mysqli('localhost', 'root', 'Santanna123_', 'proyecto');
if ($conexion->connect_errno) {
    echo "<p>Error al conectar con la base de datos.</p>";
    exit();
}

// Manejar la acción de eliminar un empleado
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['delete'])) {
    $ci_empleado = $_POST['ci_empleado']; // Obtener el CI del empleado a eliminar
    $delete_query = "DELETE FROM EMPLEADO WHERE CI = ?";
    $stmt = $conexion->prepare($delete_query);
    $stmt->bind_param("i", $ci_empleado);
    if (!$stmt->execute()) {
        echo "<p>Error al eliminar el empleado: " . $stmt->error . "</p>";
    }
}

// Manejar la acción de actualizar un empleado

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update'])) {
    $ci_empleado = $_POST['ci_empleado'];
    $nombre = $_POST['nombre'];
    $apellido = $_POST['apellido'];
    $celular = $_POST['celular'];
    $fecha_nac = $_POST['fecha_nac'] ?? ''; // Valor predeterminado si no se proporciona
    $contraseña = $_POST['contraseña'] ?? ''; // Obtener la contraseña en texto plano
    $fecha_ingreso = $_POST['fecha_ingreso'] ?? '';
    $tipo = $_POST['tipo'];

    // Verificar si se proporciona una nueva contraseña
    if (!empty($contraseña)) {
        // Aplicar hash MD5 a la nueva contraseña
        $contraseña = md5($contraseña);
    } else {
        // Si no se proporciona nueva contraseña, mantener la actual
        // Consulta para obtener la contraseña actual del empleado
        $select_query = "SELECT Contraseña FROM EMPLEADO WHERE CI = ?";
        $select_stmt = $conexion->prepare($select_query);
        $select_stmt->bind_param("i", $ci_empleado);
        $select_stmt->execute();
        $select_stmt->bind_result($contraseña_actual);
        $select_stmt->fetch();
        $contraseña = $contraseña_actual;
        $select_stmt->close();
    }

    // Consulta para actualizar los datos del empleado
    $update_query = "UPDATE EMPLEADO SET Nombre = ?, Apellido = ?, Celular = ?, Fecha_Nac = ?, Contraseña = ?, Fecha_Ingreso = ?, Tipo = ? WHERE CI = ?";
    $stmt = $conexion->prepare($update_query);
    $stmt->bind_param("ssissssi", $nombre, $apellido, $celular, $fecha_nac, $contraseña, $fecha_ingreso, $tipo, $ci_empleado);

    // Ejecutar la consulta y manejar errores
    if ($stmt->execute()) {
        echo "<p>Empleado actualizado con éxito.</p>";
    } else {
        echo "<p>Error al actualizar el empleado: " . $stmt->error . "</p>";
    }

    // Cerrar el statement
    $stmt->close();
}


// Manejar la acción de agregar un nuevo empleado
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add'])) {
    $ci_empleado = (int)$_POST['ci_empleado'];
    $nombre = $_POST['nombre'];
    $apellido = $_POST['apellido'];
    $celular = (int)$_POST['celular'];
    $fecha_nac = $_POST['fecha_nacimiento'] ?? '';
    $contraseña = $_POST['contrasena'] ?? '';
    $fecha_ingreso = $_POST['fecha_ingreso'] ?? '';
    $tipo = $_POST['tipo'];

    // Verificar si se proporcionó una contraseña antes de aplicar el hash MD5
    if (!empty($contraseña)) {
        $contraseña_hash = md5($contraseña); // Aplicar hash MD5
    } else {
        $contraseña_hash = ''; // Dejar vacío si no hay contraseña
    }

    // Preparar la consulta INSERT
    $add_query = "INSERT INTO EMPLEADO (CI, Nombre, Apellido, Celular, Fecha_Nac, Contraseña, Fecha_Ingreso, Tipo) 
                  VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    $stmt = $conexion->prepare($add_query);

    // Asociar los parámetros con los valores
    $stmt->bind_param("ississss", $ci_empleado, $nombre, $apellido, $celular, $fecha_nac, $contraseña_hash, $fecha_ingreso, $tipo);

    // Ejecutar la consulta y manejar errores si ocurren
    if (!$stmt->execute()) {
        echo "<p>Error al agregar el empleado: " . $stmt->error . "</p>";
    } else {
        echo "<p>Empleado agregado exitosamente.</p>";
    }

    // Cerrar el statement
    $stmt->close();
}
?>


<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Funciones para el jefe de servicio en All in One. Gestiona operaciones y autorizaciones de servicio.">
    <meta name="keywords" content="jefe de servicio, gestión de operaciones, autorizaciones, All in One">
    <title>Jefe de Servicio - All in One</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<header>
    <h1>Gestión de Jefes de Servicio</h1>
    <button onclick="window.location.href='tablero.php'">Volver al tablero</button>

    <!-- Mostrar botón de cerrar sesión -->
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
    <h2>Lista de Jefes de Servicio</h2>
    <table>
        <thead>
            <tr>
                <th>CI</th>
                <th>Nombre</th>
                <th>Apellido</th>
                <th>Celular</th>
                <th>Fecha de Nacimiento</th>
                <th>Fecha de Ingreso</th>
                <th>Tipo</th>
                <th>Acciones</th>
            </tr>
        </thead>
        <tbody>
            <?php
            // Consulta para obtener los jefes de servicio
            $query = "SELECT * FROM EMPLEADO WHERE Tipo IN ('Jefe de servicio de lavadero', 'Jefe de servicio de balanceo y alineación')";
            $result = $conexion->query($query);
            if ($result->num_rows > 0) {
                while ($jefe = $result->fetch_assoc()) {
                    echo '<tr>';
                    echo '<td>' . $jefe['CI'] . '</td>';
                    echo '<td>' . $jefe['Nombre'] . '</td>';
                    echo '<td>' . $jefe['Apellido'] . '</td>';
                    echo '<td>' . $jefe['Celular'] . '</td>';
                    echo '<td>' . $jefe['Fecha_Nac'] . '</td>';
                    echo '<td>' . $jefe['Fecha_Ingreso'] . '</td>';
                    echo '<td>' . $jefe['Tipo'] . '</td>';
                    echo '<td>';
                    // Formulario para eliminar un jefe
                    echo '<form method="post" action="" style="display:inline-block;">';
                    echo '<input type="hidden" name="ci_empleado" value="' . $jefe['CI'] . '">';
                    echo '<button type="submit" name="delete">Eliminar</button>';
                    echo '</form>';
                    // Formulario para actualizar un jefe
                    echo '<form method="post" action="" style="display:inline-block;">';
                    echo '<input type="hidden" name="ci_empleado" value="' . $jefe['CI'] . '">';
                    echo '<input type="text" name="nombre" value="' . $jefe['Nombre'] . '" required>';
                    echo '<input type="text" name="apellido" value="' . $jefe['Apellido'] . '" required>';
                    echo '<input type="text" name="celular" value="' . $jefe['Celular'] . '" required>';
                    echo '<input type="date" name="fecha_nac" value="' . $jefe['Fecha_Nac'] . '" required>';
                    echo '<input type="text" name="contraseña" value="' . $jefe['Contraseña'] . '" required>';
                    echo '<input type="date" name="fecha_ingreso" value="' . $jefe['Fecha_Ingreso'] . '" required>';
                    echo '<select name="tipo">';
                    echo '<option value="Jefe de servicio de lavadero"' . ($jefe['Tipo'] == 'Jefe de servicio de lavadero' ? ' selected' : '') . '>Jefe de servicio de lavadero</option>';
                    echo '<option value="Jefe de servicio de balanceo y alineación"' . ($jefe['Tipo'] == 'Jefe de servicio de balanceo y alineación' ? ' selected' : '') . '>Jefe de servicio de balanceo y alineación</option>';
                    echo '</select>';
                    echo '<button type="submit" name="update">Modificar</button>';
                    echo '</form>';
                    echo '</td>';
                    echo '</tr>';
                }
            } else {
                echo '<tr><td colspan="8">No hay jefes de servicio registrados.</td></tr>';
            }
            ?>
        </tbody>
    </table>

    <h2>Agregar Nuevo Jefe de Servicio</h2>
    <form method="post" action="">
        <label for="ci_empleado">CI:</label>
        <input type="text" id="ci_empleado" name="ci_empleado" required>
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
        <label for="contrasena">Contraseña:</label>
        <input type="password" id="contrasena" name="contrasena" required>
        <br>
        <label for="fecha_ingreso">Fecha de Ingreso:</label>
        <input type="date" id="fecha_ingreso" name="fecha_ingreso" required>
        <br>
        <label for="tipo">Tipo:</label>
        <select id="tipo" name="tipo" required>
            <option value="Jefe de servicio de lavadero">Jefe de servicio de lavadero</option>
            <option value="Jefe de servicio de balanceo y alineación">Jefe de servicio de balanceo y alineación</option>
        </select>
        <br>
        <button type="submit" name="add">Agregar</button>
    </form>
</main>
<footer>
    <p>&copy; 2024 Parking. Todos los derechos reservados.</p>
</footer>
</body>
</html>
