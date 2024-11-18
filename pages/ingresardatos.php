<?php
session_start();

// Verificar si el usuario ha iniciado sesión y tiene un rol asignado
if (!isset($_SESSION['usuario']) || !isset($_SESSION['rol'])) {
    header("Location: login.php"); // Redirige al login si no está autenticado
    exit();
}

// Conexión a la base de datos
$conexion = new mysqli('localhost', 'root', 'Santanna123_', 'proyecto');
if ($conexion->connect_errno) {
    echo "<p>Error al conectar con la base de datos.</p>";
    exit();
}

// Procesar el ingreso de datos
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Insertar vehículo
    if (isset($_POST['add_vehiculo'])) {
        $matricula = $_POST['matricula_vehiculo'];
        $marca = $_POST['marca_vehiculo'];
        $modelo = $_POST['modelo_vehiculo'];
        $tipo = $_POST['tipo_vehiculo'];
        $ci_cliente = $_POST['ci_cliente_vehiculo'];

        // Verificar si el cliente existe
        $check_cliente = "SELECT CI_Cliente FROM CLIENTE WHERE CI_Cliente = ?";
        $stmt = $conexion->prepare($check_cliente);
        $stmt->bind_param("s", $ci_cliente);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            // El cliente existe, insertar el vehículo
            $insert_vehiculo = "INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) 
                                VALUES (?, ?, ?, ?, ?)";
            $stmt = $conexion->prepare($insert_vehiculo);
            $stmt->bind_param("sssss", $matricula, $marca, $modelo, $tipo, $ci_cliente);
            if ($stmt->execute()) {
                echo "<script>alert('Vehículo agregado exitosamente.');</script>";
            } else {
                echo "<script>alert('Error al agregar vehículo.');</script>";
            }
        } else {
            echo "<script>alert('El cliente con esa cédula no está registrado en el sistema.');</script>";
        }
    }

    // Insertar reserva
    if (isset($_POST['add_reserva'])) {
        $fecha = $_POST['fecha_reserva'];
        $hora_inicio = $_POST['hora_inicio_reserva'];
        $hora_fin = $_POST['hora_fin_reserva'];
        $estado = $_POST['estado_reserva'];
        $matricula = $_POST['matricula_reserva'];

        $insert_reserva = "INSERT INTO RESERVA (Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) 
                           VALUES (?, ?, ?, ?, ?)";
        $stmt = $conexion->prepare($insert_reserva);
        $stmt->bind_param("sssss", $fecha, $hora_inicio, $hora_fin, $estado, $matricula);
        if ($stmt->execute()) {
            echo "<script>alert('Reserva agregada exitosamente.');</script>";
        } else {
            echo "<script>alert('Error al agregar reserva.');</script>";
        }
    }

    // Insertar empleado
    if (isset($_POST['add_empleado'])) {
        $ci = $_POST['ci_empleado'];
        $nombre = $_POST['nombre_empleado'];
        $apellido = $_POST['apellido_empleado'];
        $celular = $_POST['celular_empleado'];
        $fecha_nac = $_POST['fecha_nac_empleado'];

        // Hashear la contraseña con MD5
        $contraseña = md5($_POST['contrasena_empleado']);

        $fecha_ingreso = $_POST['fecha_ingreso_empleado'];
        $tipo = $_POST['tipo_empleado'];

        // Consulta para insertar el empleado en la base de datos
        $insert_empleado = "INSERT INTO EMPLEADO (CI, Nombre, Apellido, Celular, Fecha_Nac, Contraseña, Fecha_Ingreso, Tipo) 
                            VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        $stmt = $conexion->prepare($insert_empleado);

        // Asociar los parámetros a la consulta
        $stmt->bind_param("ississss", $ci, $nombre, $apellido, $celular, $fecha_nac, $contraseña, $fecha_ingreso, $tipo);

        // Ejecutar la consulta
        if ($stmt->execute()) {
            echo "<script>alert('Empleado agregado exitosamente.');</script>";
        } else {
            echo "<script>alert('Error al agregar empleado: " . $stmt->error . "');</script>";
        }

        // Cerrar el statement
        $stmt->close();
    }
}
?>



<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Formulario para ingresar datos de clientes y usuarios en All in One. Registro y actualización de información.">
    <meta name="keywords" content="ingreso de datos, formulario de registro, clientes, usuarios, All in One">
    <title>Ingreso de Datos - All in One</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<header>
    <h1>Ingresar Datos</h1>
    <button onclick="window.location.href='tablero.php'">Volver al tablero</button>


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
    <!-- Ingresar Vehículo -->
    <h2>Ingresar Vehículo</h2>
    <form method="post">
        <label for="matricula_vehiculo">Matrícula:</label>
        <input type="text" id="matricula_vehiculo" name="matricula_vehiculo" required>
        <br>
        <label for="marca_vehiculo">Marca:</label>
        <input type="text" id="marca_vehiculo" name="marca_vehiculo" required>
        <br>
        <label for="modelo_vehiculo">Modelo:</label>
        <input type="text" id="modelo_vehiculo" name="modelo_vehiculo" required>
        <br>
        <label for="tipo_vehiculo">Tipo:</label>
        <select id="tipo_vehiculo" name="tipo_vehiculo" required>
            <option value="Auto">Auto</option>
            <option value="Moto">Moto</option>
            <option value="Camioneta">Camioneta</option>
            <option value="Pequeños Utilitarios">Pequeños Utilitarios</option>
            <option value="Pequeños Camiones">Pequeños Camiones</option>
        </select>
        <br>
        <label for="ci_cliente_vehiculo">Cédula del Cliente:</label>
        <input type="text" id="ci_cliente_vehiculo" name="ci_cliente_vehiculo" required>
        <br>
        <button type="submit" name="add_vehiculo">Agregar Vehículo</button>
    </form>

    <!-- Ingresar Reserva -->
    <h2>Ingresar Reserva</h2>
    <form method="post">
        <label for="fecha_reserva">Fecha:</label>
        <input type="date" id="fecha_reserva" name="fecha_reserva" required>
        <br>
        <label for="hora_inicio_reserva">Hora Inicio:</label>
        <input type="time" id="hora_inicio_reserva" name="hora_inicio_reserva" required>
        <br>
        <label for="hora_fin_reserva">Hora Fin:</label>
        <input type="time" id="hora_fin_reserva" name="hora_fin_reserva" required>
        <br>
        <label for="estado_reserva">Estado:</label>
        <select id="estado_reserva" name="estado_reserva" required>
            <option value="Confirmada">Confirmada</option>
            <option value="Cancelada a tiempo">Cancelada a tiempo</option>
            <option value="Cancelada tarde">Cancelada tarde</option>
            <option value="Completada">Completada</option>
            <option value="No asiste">No asiste</option>
        </select>
        <br>
        <label for="matricula_reserva">Matrícula:</label>
        <input type="text" id="matricula_reserva" name="matricula_reserva" required>
        <br>
        <button type="submit" name="add_reserva">Agregar Reserva</button>
    </form>

    <!-- Ingresar Empleado -->
    <h2>Ingresar Empleado</h2>
    <form method="post">
        <label for="ci_empleado">Cédula:</label>
        <input type="text" id="ci_empleado" name="ci_empleado" required>
        <br>
        <label for="nombre_empleado">Nombre:</label>
        <input type="text" id="nombre_empleado" name="nombre_empleado" required>
        <br>
        <label for="apellido_empleado">Apellido:</label>
        <input type="text" id="apellido_empleado" name="apellido_empleado" required>
        <br>
        <label for="celular_empleado">Celular:</label>
        <input type="text" id="celular_empleado" name="celular_empleado" required>
        <br>
        <label for="fecha_nac_empleado">Fecha de Nacimiento:</label>
        <input type="date" id="fecha_nac_empleado" name="fecha_nac_empleado" required>
        <br>
        <label for="contrasena_empleado">Contraseña:</label>
        <input type="password" id="contrasena_empleado" name="contrasena_empleado" required>
        <br>
        <label for="fecha_ingreso_empleado">Fecha de Ingreso:</label>
        <input type="date" id="fecha_ingreso_empleado" name="fecha_ingreso_empleado" required>
        <br>
        <label for="tipo_empleado">Tipo:</label>
        <select id="tipo_empleado" name="tipo_empleado" required>
            <option value="Cajero">Cajero</option>
            <option value="Operador de respaldos">Operador de respaldos</option>
        </select>
        <br>
        <button type="submit" name="add_empleado">Agregar Empleado</button>
    </form>

</main>

<footer>
    <p>&copy; 2024 Parking. Todos los derechos reservados.</p>
</footer>

</body>
</html>
