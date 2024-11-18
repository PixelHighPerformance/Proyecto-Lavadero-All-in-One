<?php
session_start(); // Iniciar la sesión del usuario
require_once('../bibliotecas/fpdf/fpdf.php'); // Importar la biblioteca FPDF para generar PDF

// Inicializar el carrito si no existe en la sesión
if (!isset($_SESSION['carrito'])) {
    $_SESSION['carrito'] = []; // Crear un array vacío para el carrito
}

// Manejar la eliminación de un elemento específico del carrito
if (isset($_GET['eliminar'])) {
    $index = $_GET['eliminar']; // Obtener el índice del elemento a eliminar
    if (isset($_SESSION['carrito'][$index])) {
        unset($_SESSION['carrito'][$index]); // Eliminar el elemento del carrito
        $_SESSION['carrito'] = array_values($_SESSION['carrito']); // Reindexar el array después de la eliminación
    }
    header("Location: carrito.php"); // Redirigir para evitar la re-eliminación al actualizar la página
    exit; // Salir del script
}

// Procesar la compra y generar la factura si se confirma la compra
if (isset($_POST['confirmar_compra'])) {
    // Conectar a la base de datos
    $conexion = new mysqli('localhost', 'root', 'Santanna123_', 'proyecto');
    if ($conexion->connect_errno) {
        echo "ERROR al conectar con la base de datos.";
        exit;
    }

    // Obtener información del cliente desde la sesión
    $cedula_cliente = $_SESSION['usuario'];
    $matricula_vehiculo = $conexion->query("SELECT Matricula FROM VEHICULO WHERE CI_Cliente = '$cedula_cliente'")->fetch_assoc()['Matricula'];

    // Calcular el costo total basado en la cantidad de cada ítem
    $total = 0;
    foreach ($_SESSION['carrito'] as $item) {
        $cantidad = isset($item['cantidad']) ? $item['cantidad'] : 1; // Verificar si se define una cantidad
        $total += $item['precio'] * $cantidad; // Calcular el subtotal para cada ítem
    }
    $fecha_factura = date('Y-m-d'); // Generar la fecha actual

    // Insertar los datos de la factura en la tabla FACTURA
    $stmt = $conexion->prepare("INSERT INTO FACTURA (Fecha_Factura, Costo_Total) VALUES (?, ?)");
    if ($stmt) {
        $stmt->bind_param("sd", $fecha_factura, $total); // Vincular los parámetros
        $stmt->execute(); // Ejecutar la consulta
        $id_factura = $stmt->insert_id; // Obtener el ID generado para la factura
        $stmt->close(); // Cerrar el statement
    }

    $conexion->close(); // Cerrar la conexión a la base de datos

    // Generar la factura en formato PDF
    generarPDF($id_factura, $fecha_factura, $total, $_SESSION['carrito'], $cedula_cliente, $matricula_vehiculo);

    // Vaciar el carrito después de confirmar la compra
    $_SESSION['carrito'] = []; 
    exit; // Salir del script
}

// Función para generar el PDF de la factura
function generarPDF($id_factura, $fecha_factura, $total, $items, $cedula_cliente, $matricula_vehiculo) {
    $pdf = new FPDF(); // Crear una instancia de FPDF
    $pdf->AddPage(); // Agregar una nueva página al PDF

    // Encabezado
    $pdf->SetFont('Arial', 'B', 16); // Fuente para el encabezado
    $pdf->SetTextColor(33, 37, 41); // Color del texto
    $pdf->Cell(0, 10, "Factura No: $id_factura", 0, 1, 'C'); // Número de factura centrado
    $pdf->SetFont('Arial', '', 12); // Fuente para subtítulos
    $pdf->Cell(0, 10, "Fecha: $fecha_factura", 0, 1, 'C'); // Fecha de la factura
    $pdf->Ln(10); // Salto de línea

    // Información del cliente
    $pdf->SetFont('Arial', 'B', 12);
    $pdf->Cell(40, 10, "Cédula Cliente:", 0, 0); // Etiqueta
    $pdf->SetFont('Arial', '', 12);
    $pdf->Cell(40, 10, $cedula_cliente, 0, 1); // Valor

    $pdf->SetFont('Arial', 'B', 12);
    $pdf->Cell(40, 10, "Matrícula Vehículo:", 0, 0); // Etiqueta
    $pdf->SetFont('Arial', '', 12);
    $pdf->Cell(40, 10, $matricula_vehiculo, 0, 1); // Valor
    $pdf->Ln(10); // Salto de línea

    // Encabezado de la tabla de servicios
    $pdf->SetFont('Arial', 'B', 12);
    $pdf->SetFillColor(230, 230, 230); // Fondo gris claro para el encabezado
    $pdf->Cell(60, 10, 'Servicio', 1, 0, 'C', true);
    $pdf->Cell(30, 10, 'Cantidad', 1, 0, 'C', true);
    $pdf->Cell(30, 10, 'Precio Unitario', 1, 0, 'C', true);
    $pdf->Cell(30, 10, 'Subtotal', 1, 1, 'C', true);

    // Contenido de la tabla de servicios
    $pdf->SetFont('Arial', '', 12);
    foreach ($items as $item) {
        $cantidad = isset($item['cantidad']) ? $item['cantidad'] : 1; // Verificar si se define la cantidad
        $subtotal = $item['precio'] * $cantidad; // Calcular subtotal
        $pdf->Cell(60, 10, $item['nombre'], 1); // Nombre del servicio
        $pdf->Cell(30, 10, $cantidad, 1, 0, 'C'); // Cantidad
        $pdf->Cell(30, 10, '$' . number_format($item['precio'], 2), 1, 0, 'C'); // Precio unitario
        $pdf->Cell(30, 10, '$' . number_format($subtotal, 2), 1, 1, 'C'); // Subtotal
    }

    // Total
    $pdf->SetFont('Arial', 'B', 12);
    $pdf->Cell(120, 10, '', 0); // Celda vacía para alineación
    $pdf->Cell(30, 10, 'Total:', 1, 0, 'C', true); // Etiqueta de total
    $pdf->Cell(30, 10, '$' . number_format($total, 2), 1, 1, 'C'); // Valor del total

    // Pie de página
    $pdf->Ln(10); // Salto de línea
    $pdf->SetFont('Arial', 'I', 10);
    $pdf->Cell(0, 10, "Gracias por su preferencia.", 0, 1, 'C'); // Mensaje de agradecimiento

    // Exportar el PDF
    $pdf->Output('D', 'Factura_' . $id_factura . '.pdf'); // Descargar el PDF con nombre específico
}
?>


<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Revisa y confirma las compras en tu carrito en All in One. Servicios, neumáticos y más a tu disposición.">
    <meta name="keywords" content="carrito de compras, confirmación de compras, All in One, servicios, neumáticos">
    <title>Carrito de Compras - All in One</title>
    <link rel="stylesheet" href="../css/style.css">
    <script>
        function confirmarEliminacion(url) {
            if (confirm("¿Está seguro que quiere eliminar este servicio y/o compra de tu carrito?")) {
                window.location.href = url;
            }
        }
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
    <section class="carrito">
        <h1>Carrito de Servicios</h1>
        <table>
            <thead>
                <tr>
                    <th>Servicio</th>
                    <th>Cantidad</th>
                    <th>Fecha</th>
                    <th>Hora</th>
                    <th>Precio Unitario</th>
                    <th>Subtotal</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
    <?php if (empty($_SESSION['carrito'])): ?>
        <tr><td colspan="7">El carrito está vacío.</td></tr>
    <?php else: ?>
        <?php foreach ($_SESSION['carrito'] as $index => $item): ?>
            <?php $cantidad = isset($item['cantidad']) ? $item['cantidad'] : 1; ?>
            <?php $subtotal = $item['precio'] * $cantidad; ?>
            <tr>
                <td><?php echo isset($item['nombre']) ? $item['nombre'] : 'N/A'; ?></td>
                <td><?php echo $cantidad; ?></td>
                <td><?php echo isset($item['fecha']) ? $item['fecha'] : 'N/A'; ?></td>
                <td><?php echo isset($item['hora']) ? $item['hora'] : 'N/A'; ?></td>
                <td><?php echo '$' . number_format($item['precio'], 2); ?></td>
                <td><?php echo '$' . number_format($subtotal, 2); ?></td>
                <td><a href="javascript:void(0);" onclick="confirmarEliminacion('carrito.php?eliminar=<?php echo $index; ?>')">Eliminar</a></td>
            </tr>
        <?php endforeach; ?>
        <tr>
            <td colspan="5" style="text-align:right"><strong>Total:</strong></td>
            <td><strong>$<?php echo number_format(array_sum(array_map(function($item) { return $item['precio'] * (isset($item['cantidad']) ? $item['cantidad'] : 1); }, $_SESSION['carrito'])), 2); ?></strong></td>
            <td></td>
        </tr>
    <?php endif; ?>
</tbody>
        </table>
        <br>
        <form method="post" action="">
            <button type="submit" name="confirmar_compra">Confirmar Compra</button>
            <a href="../../index.php"><button type="button">Volver</button></a>
        </form>
    </section>
</main>

<footer>
    <div class="social-media">
        <a href="#"><img src="../img/x.png" alt="Twitter"></a>
        <a href="#"><img src="../img/instagram.png" alt="Instagram"></a>
    </div>
    <p>&copy; 2024 Parking. Todos los derechos reservados.</p>
</footer>
</body>
</html>
