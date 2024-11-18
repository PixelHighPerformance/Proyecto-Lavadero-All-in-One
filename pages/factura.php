<?php
session_start();
require_once('../bibliotecas/fpdf/fpdf.php');

// Conexión a la base de datos
$conexion = new mysqli('localhost', 'root', 'Santanna123_', 'proyecto');
if ($conexion->connect_errno) {
    echo "ERROR al conectar con la base de datos.";
    exit;
}

if (isset($_GET['descargar_factura'])) {
    $id_reserva = $_GET['descargar_factura'];
    
    // Obtener los detalles de la reserva: cédula del cliente y matrícula del vehículo
    $query_reserva = "SELECT CI_Cliente FROM RESERVA WHERE ID_Reserva = ?";
    $stmt_reserva = $conexion->prepare($query_reserva);
    $stmt_reserva->bind_param("i", $id_reserva);
    $stmt_reserva->execute();
    $reserva_result = $stmt_reserva->get_result();

    if ($reserva_result->num_rows > 0) {
        $reserva = $reserva_result->fetch_assoc();
        $cedula_cliente = $reserva['CI_Cliente'];

        // Obtener matrícula del vehículo asociado
        $query_vehiculo = "SELECT Matricula FROM VEHICULO WHERE CI_Cliente = ?";
        $stmt_vehiculo = $conexion->prepare($query_vehiculo);
        $stmt_vehiculo->bind_param("i", $cedula_cliente);
        $stmt_vehiculo->execute();
        $vehiculo_result = $stmt_vehiculo->get_result();
        $matricula_vehiculo = $vehiculo_result->fetch_assoc()['Matricula'];

        // Obtener los detalles de la factura (fecha y costo total)
        $query_factura = "SELECT * FROM FACTURA WHERE ID_Reserva = ?";
        $stmt_factura = $conexion->prepare($query_factura);
        $stmt_factura->bind_param("i", $id_reserva);
        $stmt_factura->execute();
        $factura_result = $stmt_factura->get_result();

        if ($factura_result->num_rows > 0) {
            $factura = $factura_result->fetch_assoc();
            $fecha_factura = $factura['Fecha_Factura'];
            $total = $factura['Costo_Total'];

            // Generar el PDF de la factura
            $pdf = new FPDF();
            $pdf->AddPage();
            $pdf->SetFont('Arial', 'B', 16);
            $pdf->Cell(0, 10, "Factura No: $id_reserva", 0, 1, 'C');
            $pdf->SetFont('Arial', '', 12);
            $pdf->Cell(0, 10, "Fecha: $fecha_factura", 0, 1, 'C');
            $pdf->Ln(10);
            $pdf->Cell(40, 10, "Cedula Cliente:", 0, 0);
            $pdf->Cell(40, 10, $cedula_cliente, 0, 1);
            $pdf->Cell(40, 10, "Matricula Vehiculo:", 0, 0);
            $pdf->Cell(40, 10, $matricula_vehiculo, 0, 1);
            $pdf->Ln(10);

            // Encabezado de la tabla de servicios
            $pdf->SetFont('Arial', 'B', 12);
            $pdf->SetFillColor(230, 230, 230);
            $pdf->Cell(60, 10, 'Servicio', 1, 0, 'C', true);
            $pdf->Cell(30, 10, 'Cantidad', 1, 0, 'C', true);
            $pdf->Cell(30, 10, 'Precio Unitario', 1, 0, 'C', true);
            $pdf->Cell(30, 10, 'Subtotal', 1, 1, 'C', true);

            // Obtener los servicios de la factura (relacionados con la reserva)
            $query_servicios = "SELECT * FROM SERVICIO WHERE ID_Reserva = ?";
            $stmt_servicios = $conexion->prepare($query_servicios);
            $stmt_servicios->bind_param("i", $id_reserva);
            $stmt_servicios->execute();
            $servicios_result = $stmt_servicios->get_result();

            // Contenido de la tabla de servicios
            $pdf->SetFont('Arial', '', 12);
            while ($servicio = $servicios_result->fetch_assoc()) {
                $cantidad = $servicio['Cantidad'];
                $subtotal = $servicio['Precio_Unitario'] * $cantidad;
                $pdf->Cell(60, 10, $servicio['Nombre'], 1);
                $pdf->Cell(30, 10, $cantidad, 1, 0, 'C');
                $pdf->Cell(30, 10, '$' . number_format($servicio['Precio_Unitario'], 2), 1, 0, 'C');
                $pdf->Cell(30, 10, '$' . number_format($subtotal, 2), 1, 1, 'C');
            }

            // Total
            $pdf->SetFont('Arial', 'B', 12);
            $pdf->Cell(120, 10, '', 0);
            $pdf->Cell(30, 10, 'Total:', 1, 0, 'C', true);
            $pdf->Cell(30, 10, '$' . number_format($total, 2), 1, 1, 'C');

            // Footer
            $pdf->Ln(10);
            $pdf->SetFont('Arial', 'I', 10);
            $pdf->Cell(0, 10, "Gracias por su preferencia.", 0, 1, 'C');

            // Output the PDF to the browser for download
            $pdf->Output('D', 'Factura_' . $id_reserva . '.pdf');
        } else {
            echo "Factura no encontrada.";
        }
    } else {
        echo "Reserva no encontrada.";
    }
} else {
    echo "No se ha recibido el ID de la reserva.";
}

exit;
?>
