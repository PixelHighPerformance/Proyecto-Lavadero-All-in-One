<?php
session_start();

// Conexión a la base de datos
$conexion = new mysqli('localhost', 'root', 'Santanna123_', 'proyecto');
if ($conexion->connect_errno) {
    echo "ERROR al conectar con la base de datos.";
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['login'])) {
    // Capturamos los datos del formulario
    $cedula = $_POST['usuario'];

    // Validamos que el campo no esté vacío
    if (empty($cedula)) {
        echo "<script>alert('Error: cédula vacía!');</script>";
    } else {
        // Consulta para verificar en la tabla CLIENTE
        $stmt_cliente = $conexion->prepare("SELECT Nombre, Apellido FROM CLIENTE WHERE CI_Cliente = ?");
        $stmt_cliente->bind_param("s", $cedula);
        $stmt_cliente->execute();
        $resultado_cliente = $stmt_cliente->get_result();

        if ($resultado_cliente->num_rows > 0) {
            // Autenticación exitosa en la tabla CLIENTE
            $datos_cliente = $resultado_cliente->fetch_assoc();
            $nombreCompleto = $datos_cliente['Nombre'] . ' ' . $datos_cliente['Apellido'];
            $_SESSION['usuario'] = $cedula;
            $_SESSION['nombre_completo'] = $nombreCompleto;
            $_SESSION['rol'] = 'Cliente'; // Establecemos el rol como Cliente

            // Redirigir a la página almacenada en 'redirect_to' o a index.html si no está definida
            $redirect_url = isset($_SESSION['redirect_to']) ? $_SESSION['redirect_to'] : '../../index.php';
            unset($_SESSION['redirect_to']); // Limpiar la variable de sesión después de redirigir
            echo "<script>
                    alert('$nombreCompleto, has iniciado sesión con éxito');
                    window.location.href='$redirect_url';
                  </script>";
            exit;
        } else {
            // Verificar en la tabla EMPLEADO
            $stmt_empleado = $conexion->prepare("SELECT Nombre, Apellido, Tipo FROM EMPLEADO WHERE CI = ?");
            $stmt_empleado->bind_param("s", $cedula);
            $stmt_empleado->execute();
            $resultado_empleado = $stmt_empleado->get_result();

            if ($resultado_empleado->num_rows > 0) {
                // Autenticación exitosa en la tabla EMPLEADO
                $datos_empleado = $resultado_empleado->fetch_assoc();
                $nombreCompleto = $datos_empleado['Nombre'] . ' ' . $datos_empleado['Apellido'];
                $_SESSION['usuario'] = $cedula;
                $_SESSION['rol'] = $datos_empleado['Tipo']; // Establecer el rol según el tipo de empleado
                $_SESSION['nombre_completo'] = $nombreCompleto;

                // Redirigir al tablero (dashboard) del empleado
                echo "<script>
                        alert('$nombreCompleto, has iniciado sesión con éxito');
                        window.location.href='tablero.php';
                      </script>";
                exit;
            } else {
                // Error de autenticación
                echo "<script>alert('Error: cédula incorrecta!');</script>";
            }
        }
    }
}

// Cerrar la conexión
$conexion->close();
?>



<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Accede a tu cuenta en All in One para gestionar tus servicios y reservas de estacionamiento.">
    <meta name="keywords" content="iniciar sesión, acceso a cuenta, All in One">
    <link rel="stylesheet" href="../css/style.css">
    <title>Iniciar Sesión - All in One</title>
</head>
<body>
    <div class="form-container" id="login">
        <h2>Iniciar Sesión</h2>
        <p>Por favor, ingrese sus datos para acceder a su cuenta:</p>
        <form name='loginForm' onsubmit='return validateLoginForm()' method="post" action="<?php echo $_SERVER['PHP_SELF']; ?>">
            <label for="usuario">Cédula:</label>
            <input type="text" id="usuario" name="usuario" required>

            <label for="contrasena">Contraseña:</label>
            <input type="password" id="contrasena" name="contrasena" required>
            <button type="button" id="toggle-password">Mostrar</button>

            <button type="submit" name="login">Ingresar</button>
            <p>¿No tienes una cuenta? <a href="registro.php">Regístrate aquí</a></p>
                </form>
                <script src="../js/validaciones.js"></script>
                <script src="../js/ocultarcontra.js"></script>

    </div>
</body>
</html>
