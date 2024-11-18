<?php
session_start();

// Conexión a la base de datos
$conexion = new mysqli('localhost', 'root', 'Santanna123_', 'proyecto');
if ($conexion->connect_errno) {
    echo "ERROR al conectar con la base de datos.";
    exit;
}

// Procesar la reserva si se ha enviado el formulario
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Verificar si el usuario ha iniciado sesión y tiene el rol de "Cliente"
    if (!isset($_SESSION['usuario']) || !isset($_SESSION['rol']) || $_SESSION['rol'] !== 'Cliente') {
        $_SESSION['redirect_to'] = 'taller.php';
        header("Location: login.php");
        exit();
    }

    // Obtener el CI del cliente desde la sesión
    $cedulaCliente = $_SESSION['usuario'];
    
    $servicio = $_POST['servicio'];
    $fecha = $_POST['fecha'];
    $hora_inicio = $_POST['hora_inicio'];
    $estado = 'Pendiente'; // Estado inicial de la reserva
    $hora_fin = date("H:i:s", strtotime($hora_inicio) + 3600);

    // Definir nombre y precio según el servicio seleccionado
    $nombres_servicios = [
        1 => "Montaje neumático",
        2 => "Alineación 1 tren desde R17",
        3 => "Alineación",
        4 => "Balanceo auto + válvula",
        5 => "Alineación 2 trenes",
        6 => "Pack alineación y 4 balanceos para camioneta + válvulas",
        7 => "Balanceo de camioneta + válvula"
    ];
    $precios_servicios = [
        1 => 200,
        2 => 1850,
        3 => 1650,
        4 => 385,
        5 => 2475,
        6 => 3510,
        7 => 415
    ];
    
    $nombre_servicio = $nombres_servicios[$servicio] ?? "Servicio desconocido";
    $precio = $precios_servicios[$servicio] ?? 0;

    // Iniciar una transacción para asegurar que ambas inserciones ocurran juntas
    $conexion->begin_transaction();

    try {
        // Insertar en la tabla RESERVA
        $stmt_reserva = $conexion->prepare("INSERT INTO RESERVA (Fecha, Hora_Inicio, Hora_Fin, Estado) VALUES (?, ?, ?, ?)");
        $stmt_reserva->bind_param("ssss", $fecha, $hora_inicio, $hora_fin, $estado);
        
        if (!$stmt_reserva->execute()) {
            throw new Exception("Error al insertar en RESERVA: " . $stmt_reserva->error);
        }

        // Obtener el ID de la reserva recién insertada
        $id_reserva = $conexion->insert_id;

        // Insertar en la tabla CONTIENE para asociar la reserva con el servicio
        $stmt_contiene = $conexion->prepare("INSERT INTO CONTIENE (ID_Reserva, ID_Servicio) VALUES (?, ?)");
        $stmt_contiene->bind_param("ii", $id_reserva, $servicio);

        if (!$stmt_contiene->execute()) {
            throw new Exception("Error al insertar en CONTIENE: " . $stmt_contiene->error);
        }

        // Confirmar la transacción
        $conexion->commit();
        
        // Guardar la reserva en el carrito de la sesión
        if (!isset($_SESSION['carrito'])) {
            $_SESSION['carrito'] = [];
        }
        $_SESSION['carrito'][] = [
            'nombre' => $nombre_servicio,
            'fecha' => $fecha,
            'hora' => $hora_inicio,
            'precio' => $precio
        ];

        // Mostrar alerta de éxito con JavaScript
        echo "<script>alert('Reserva realizada con éxito y añadida al carrito.'); window.location.href = 'taller.php';</script>";
    } catch (Exception $e) {
        // Revertir la transacción en caso de error
        $conexion->rollback();
        echo "<p style='color: red;'>Error al realizar la reserva: " . $e->getMessage() . "</p>";
    }

    $stmt_reserva->close();
    $stmt_contiene->close();
}

$conexion->close();
?>





<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Reserva tu cita en el taller de All in One para el mantenimiento de tu vehículo con técnicos calificados.">
    <meta name="keywords" content="taller de mantenimiento, cita de taller, All in One, técnicos calificados">
    <title>Taller de Mantenimiento - All in One</title>
    <link rel="stylesheet" href="../css/style.css">
    <script>
        function actualizarPrecio() {
            const servicioSelect = document.getElementById('servicio');
            const precio = servicioSelect.options[servicioSelect.selectedIndex].dataset.precio;
            document.getElementById('precio').textContent = 'Precio: $' + precio;
        }

        document.addEventListener('DOMContentLoaded', function() {
            actualizarPrecio();
        });
    </script>
</head>
<body>
<header>
        <nav>
            <a href="../../index.php">
                <img src="../img/Título secundario.svg" alt="Logo" class="nav-logo">
            </a>
            <h1>ALL <br>IN ONE</h1>
            <ul>
                <li><a href="../../index.php">
                    <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-home-2" width="28" height="28" viewBox="0 0 24 24" stroke-width="1.5" stroke="#000000" fill="none" stroke-linecap="round" stroke-linejoin="round">
                        <path stroke="none" d="M0 0h24v24H0z" fill="none"/>
                        <path d="M5 12l-2 0l9 -9l9 9l-2 0" />
                        <path d="M5 12v7a2 2 0 0 0 2 2h10a2 2 0 0 0 2 -2v-7" />
                        <path d="M10 12h4v4h-4z" />
                    </svg>Inicio
                </a></li>
                <li><a href="../pages/parking.php">
                    <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-car-garage" width="28" height="28" viewBox="0 0 24 24" stroke-width="1.5" stroke="#000000" fill="none" stroke-linecap="round" stroke-linejoin="round">
                        <path stroke="none" d="M0 0h24v24H0z" fill="none"/>
                        <path d="M5 20a2 2 0 1 0 4 0a2 2 0 0 0 -4 0" />
                        <path d="M15 20a2 2 0 1 0 4 0a2 2 0 0 0 -4 0" />
                        <path d="M5 20h-2v-6l2 -5h9l4 5h1a2 2 0 0 1 2 2v4h-2m-4 0h-6m-6 -6h15m-6 0v-5" />
                        <path d="M3 6l9 -4l9 4" />
                    </svg>Parking
                </a></li>
                <li><a href="../pages/taller.php">
                    <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-assembly" width="28" height="28" viewBox="0 0 24 24" stroke-width="1.5" stroke="#000000" fill="none" stroke-linecap="round" stroke-linejoin="round">
                        <path stroke="none" d="M0 0h24v24H0z" fill="none"/>
                        <path d="M19.875 6.27a2.225 2.225 0 0 1 1.125 1.948v7.284c0 .809 -.443 1.555 -1.158 1.948l-6.75 4.27a2.269 2.269 0 0 1 -2.184 0l-6.75 -4.27a2.225 2.225 0 0 1 -1.158 -1.948v-7.285c0 -.809 .443 -1.554 1.158 -1.947l6.75 -3.98a2.33 2.33 0 0 1 2.25 0l6.75 3.98h-.033z" />
                        <path d="M15.5 9.422c.312 .18 .503 .515 .5 .876v3.277c0 .364 -.197 .7 -.515 .877l-3 1.922a1 1 0 0 1 -.97 0l-3 -1.922a1 1 0 0 1 -.515 -.876v-3.278c0 -.364 .197 -.7 .514 -.877l3 -1.79c.311 -.174 .69 -.174 1 0l3 1.79h-.014z" />
                    </svg>Taller
                </a></li>
                <li><a href="../pages/neumaticos.php">
                    <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-wheel" width="28" height="28" viewBox="0 0 24 24" stroke-width="1.5" stroke="#000000" fill="none" stroke-linecap="round" stroke-linejoin="round">
                        <path stroke="none" d="M0 0h24v24H0z" fill="none"/>
                        <path d="M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0" />
                        <path d="M12 12m-3 0a3 3 0 1 0 6 0a3 3 0 1 0 -6 0" />
                        <path d="M3 12h6" />
                        <path d="M15 12h6" />
                        <path d="M13.6 9.4l3.4 -4.8" />
                        <path d="M10.4 14.6l-3.4 4.8" />
                        <path d="M7 4.6l3.4 4.8" />
                        <path d="M13.6 14.6l3.4 4.8" />
                    </svg>Neumáticos
                </a></li>
                <li><a href="../pages/lavadero.php">
                    <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-droplet" width="28" height="28" viewBox="0 0 24 24" stroke-width="1.5" stroke="#000000" fill="none" stroke-linecap="round" stroke-linejoin="round">
                        <path stroke="none" d="M0 0h24v24H0z" fill="none"/>
                        <path d="M7.502 19.423c2.602 2.105 6.395 2.105 8.996 0c2.602 -2.105 3.262 -5.708 1.566 -8.546l-4.89 -7.26c-.42 -.625 -1.287 -.803 -1.936 -.397a1.376 1.376 0 0 0 -.41 .397l-4.893 7.26c-1.695 2.838 -1.035 6.441 1.567 8.546z" />
                    </svg>Lavadero
                </a></li>
                <li><a href="../pages/trabaja.html">
                    <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-phone" width="36" height="36" viewBox="0 0 24 24" stroke-width="1.5" stroke="#000000" fill="none" stroke-linecap="round" stroke-linejoin="round">
                        <path stroke="none" d="M0 0h24v24H0z" fill="none"/>
                        <path d="M5 4h4l2 5l-2.5 1.5a11 11 0 0 0 5 5l1.5 -2.5l5 2v4a2 2 0 0 1 -2 2a16 16 0 0 1 -15 -15a2 2 0 0 1 2 -2" />
                    </svg>Trabaja con Nosotros
                </a></li>
    
                <!-- Ícono de carrito -->
                <li class="cart-menu">
                    <a href="../pages/carrito.php">
                        <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-shopping-cart" width="36" height="36" viewBox="0 0 24 24" stroke-width="1.5" stroke="#000000" fill="none" stroke-linecap="round" stroke-linejoin="round">
                            <path stroke="none" d="M0 0h24v24H0z" fill="none"/>
                            <circle cx="6" cy="19" r="2" />
                            <circle cx="17" cy="19" r="2" />
                            <path d="M17 17h-11v-14h-2" />
                            <path d="M6 5l14 1l-1 7h-13" />
                        </svg>Carrito
                    </a>
                </li>
    
                <!-- Ícono de usuario -->
                <?php if (isset($_SESSION['usuario']) && !empty($_SESSION['usuario'])): ?>
                    <li class="user-menu">
                        <a href="logout.php">
                            <button id="logout-button">Cerrar sesión</button>
                        </a>
                    </li>
                <?php else: ?>
                    <li class="user-menu">
                        <a href="micuenta.html">
                            <button id="user-icon">
                                <img src="../img/perfil.png" alt="Perfil" class="icon">
                            </button>
                        </a>
                    </li>
                <?php endif; ?>
            </ul>
        </nav>
    </header>
<main>
    <section class="taller-alineacion">
        <div class="form-container" id="reserva-alineacion">
            <h2>Reserva tu servicio</h2>
            
            <form method="post" action="">
                <label for="servicio">Tipo de Reparación:</label>
                <select id="servicio" name="servicio" required onchange="actualizarPrecio()">
                    <option value="1" data-precio="200">Montaje neumático</option>
                    <option value="2" data-precio="1850">Alineación 1 tren desde R17</option>
                    <option value="3" data-precio="1650">Alineación</option>
                    <option value="4" data-precio="385">Balanceo auto + válvula</option>
                    <option value="5" data-precio="2475">Alineación 2 trenes</option>
                    <option value="6" data-precio="3510">Pack alineación y 4 balanceos para camioneta + válvulas</option>
                    <option value="7" data-precio="415">Balanceo de camioneta + válvula</option>
                </select>

                <p id="precio">Precio: $200</p>

                <label for="fecha">Fecha de Reserva:</label>
                <input type="date" id="fecha" name="fecha" required min="<?php echo date('Y-m-d'); ?>">

                <label for="hora_inicio">Hora de Inicio:</label>
                <input type="time" id="hora_inicio" name="hora_inicio" required>

                <button type="submit">Reservar</button>
            </form>
        </div>
    </section>
</main>

<footer>
    <div class="social-media">
        <a href="#"><img src="../img/x.png" alt="Twitter"></a>
        <a href="#"><img src="../img/instagram.png" alt="Instagram"></a>
    </div>
    <p>&copy; 2023 Parking. Todos los derechos reservados.</p>
</footer>
</body>
</html>
