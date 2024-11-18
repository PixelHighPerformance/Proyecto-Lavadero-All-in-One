<?php
$conexion = new mysqli('localhost', 'root', 'Santanna123_', 'proyecto');

if ($conexion->connect_errno) {
    echo "ERROR al conectar con la DB.";
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['registrar'])) { 
    $nombre = $_POST['nombre'];
    $apellido = $_POST['apellido'];
    $cedula = $_POST['cedula'];
    $pasaporte = $_POST['pasaporte'];
    $celular = $_POST['celular'];
    $telefono = $_POST['telefono'];
    $fecha_nacimiento = $_POST['fecha_nacimiento'];
    $contrasena = MD5($_POST['contrasena']); 

    // Insertar los datos del cliente
    $sql_insert_cliente = "INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Fecha_Nac) 
                           VALUES ('$cedula', '$nombre', '$apellido', '$celular', '$contrasena', '$telefono', '$pasaporte', '$fecha_nacimiento')";

    if ($conexion->query($sql_insert_cliente)) {
        // Insertar cada vehículo registrado
        $vehiculos = $_POST['vehiculos'];
        foreach ($vehiculos as $vehiculo) {
            $matricula = $vehiculo['matricula'];
            $marca = $vehiculo['marca'];
            $modelo = $vehiculo['modelo'];

            $sql_insert_vehiculo = "INSERT INTO VEHICULO (Matricula, Marca, Modelo, CI_Cliente) 
                                    VALUES ('$matricula', '$marca', '$modelo', '$cedula')";

            if (!$conexion->query($sql_insert_vehiculo)) {
                echo "<p>Error al guardar el vehículo con matrícula $matricula: " . $conexion->error . "</p>";
                error_log("Error al guardar el vehículo con matrícula $matricula: " . $conexion->error);
            }
        }

        // Mostrar mensaje de éxito y redirigir
        echo "<script>
                alert('Registro exitoso. Por favor, inicie sesión.');
                window.location.href = 'login.php';
              </script>";
        exit;
    } else {
        echo "<p>Error al guardar el cliente: " . $conexion->error . "</p>";
        error_log("Error al guardar el cliente: " . $conexion->error);
    }
}

$conexion->close();
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Regístrate en All in One para acceder a nuestros servicios integrales de estacionamiento y automóviles.">
    <meta name="keywords" content="registro de usuario, crear cuenta, All in One, servicios de automóviles">
    <link rel="stylesheet" href="../css/style.css">
    <title>Registro de Usuario - All in One</title>

    <style>
        .input-error {
            border: 2px solid red;
            background-color: #ffe5e5;
        }

        .input-success {
            border: 2px solid green;
            background-color: #e5ffe5;
        }
    </style>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const formulario = document.forms['registrationForm'];
            const inputs = formulario.querySelectorAll('input');

            const expresiones = {
                nombre: /^[a-zA-ZÀ-ÿ\s]+$/, // Solo letras y espacios
                apellido: /^[a-zA-ZÀ-ÿ\s]+$/, // Solo letras y espacios
                cedula: /^\d{7,8}$/, // 7 u 8 números
                celular: /^\d{7,14}$/, // 7 a 14 números
                telefono: /^\d{7,14}$/, // 7 a 14 números
                contrasena: /^[a-zA-Z0-9\_\-]{6,16}$/, // Letras, números, guion y guion bajo
            };

            const validarCampo = (expresion, input) => {
                if (expresion.test(input.value)) {
                    input.classList.remove('input-error');
                    input.classList.add('input-success');
                    return true;
                } else {
                    input.classList.remove('input-success');
                    input.classList.add('input-error');
                    return false;
                }
            };

            inputs.forEach((input) => {
                input.addEventListener('keyup', (e) => {
                    if (expresiones[e.target.name]) {
                        validarCampo(expresiones[e.target.name], e.target);
                    }
                });

                input.addEventListener('blur', (e) => {
                    if (expresiones[e.target.name]) {
                        validarCampo(expresiones[e.target.name], e.target);
                    }
                });
            });

            formulario.addEventListener('submit', (e) => {
                let valid = true;
                inputs.forEach((input) => {
                    if (expresiones[input.name]) {
                        valid = validarCampo(expresiones[input.name], input) && valid;
                    }
                });

                const contrasena = formulario['contrasena'].value;
                const confirmarContrasena = formulario['confirmar_contrasena']?.value;

                if (contrasena !== confirmarContrasena) {
                    alert('Las contraseñas no coinciden.');
                    valid = false;
                }

                if (!valid) {
                    e.preventDefault();
                    alert('Por favor, corrige los errores en el formulario.');
                }
            });
        });
    </script>
</head>
<body>

<main>
    <section class="lavadero">
        <div class="form-container" id="registro">
            <h2>Registrar</h2>
            <form name='registrationForm' method="post" action="<?php echo $_SERVER['PHP_SELF']; ?>">
                <label for="nombre">Nombre:</label>
                <input type="text" id="nombre" name="nombre" required>

                <label for="apellido">Apellido:</label>
                <input type="text" id="apellido" name="apellido" required>

                <label for="cedula">Cédula:</label>
                <input type="text" id="cedula" name="cedula" required>

                <label for="celular">Celular:</label>
                <input type="text" id="celular" name="celular" required>

                <label for="telefono">Teléfono:</label>
                <input type="text" id="telefono" name="telefono">

                <label for="fecha_nacimiento">Fecha de nacimiento:</label>
                <input type="date" id="fecha_nacimiento" name="fecha_nacimiento" required>

                <label for="contrasena">Contraseña:</label>
                <input type="password" id="contrasena" name="contrasena" required>

                <button type="button" id="toggle-password">Mostrar</button>

                <label for="confirmar_contrasena">Confirmar Contraseña:</label>
                <input type="password" id="confirmar_contrasena" name="confirmar_contrasena" required>

                <button type="button" id="toggle-password">Mostrar</button>

                <h3>Vehículos</h3>
                <div id="vehiculosContainer">
                    <div class="vehiculo">
                        <label for="matricula">Matrícula:</label>
                        <input type="text" name="vehiculos[][matricula]" required>
                        <br>
                        <label for="marca">Marca:</label>
                        <input type="text" name="vehiculos[][marca]" required>
                        <br>
                        <label for="modelo">Modelo:</label>
                        <input type="text" name="vehiculos[][modelo]" required>
                    </div>
                </div>
                <button type="button" onclick="agregarVehiculo()">Agregar otro vehículo</button>
                <br>
                <button type="submit" name="registrar">Registrar</button>
            </form>
        </div>
    </section>
</main>

</body>
</html>
