<?php
session_start();

// Verificar si el usuario ha iniciado sesión y tiene un rol asignado
if (!isset($_SESSION['usuario']) || !isset($_SESSION['rol'])) {
    header("Location: login.php"); // Redirigir al login si no está autenticado
    exit();
}

// Conexión a la base de datos
$conexion = new mysqli('localhost', 'root', 'Santanna123_', 'proyecto');
if ($conexion->connect_errno) {
    echo "<p>Error al conectar con la base de datos.</p>";
    exit();
}

// Procesar solicitud para eliminar un neumático
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['delete'])) {
    $id_neumatico = $_POST['id_neumatico']; // Obtener el ID del neumático a eliminar
    $delete_query = "DELETE FROM NEUMATICO WHERE ID_Neumatico = ?";
    $stmt = $conexion->prepare($delete_query);
    $stmt->bind_param("i", $id_neumatico); // Vincular parámetros
    $stmt->execute(); // Ejecutar la consulta
}

// Procesar solicitud para añadir un nuevo neumático
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_tire'])) {
    $id_neumatico = $_POST['id_neumatico']; // ID del nuevo neumático
    $marca = $_POST['marca']; // Marca del neumático
    $precio = $_POST['precio']; // Precio del neumático
    $stock = $_POST['stock']; // Stock del neumático

    $add_query = "INSERT INTO NEUMATICO (ID_Neumatico, Marca, Precio, Stock) VALUES (?, ?, ?, ?)";
    $stmt = $conexion->prepare($add_query);
    $stmt->bind_param("isdi", $id_neumatico, $marca, $precio, $stock); // Vincular parámetros
    if ($stmt->execute()) {
        // Mensaje de éxito y redirección
        echo "<script>alert('Neumático añadido con éxito.'); window.location.href = 'neumaticosbaja.php';</script>";
    } else {
        // Mostrar mensaje de error
        echo "<p style='color: red;'>Error al añadir neumático: " . $stmt->error . "</p>";
    }
}

// Procesar solicitud para actualizar un neumático existente
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_tire'])) {
    $id_neumatico = $_POST['id_neumatico']; // ID del neumático a actualizar
    $marca = $_POST['marca']; // Nueva marca
    $precio = $_POST['precio']; // Nuevo precio
    $stock = $_POST['stock']; // Nuevo stock

    $update_query = "UPDATE NEUMATICO SET Marca = ?, Precio = ?, Stock = ? WHERE ID_Neumatico = ?";
    $stmt = $conexion->prepare($update_query);
    $stmt->bind_param("sdii", $marca, $precio, $stock, $id_neumatico); // Vincular parámetros
    if ($stmt->execute()) {
        // Mensaje de éxito y redirección
        echo "<script>alert('Neumático actualizado con éxito.'); window.location.href = 'neumaticosbaja.php';</script>";
    } else {
        // Mostrar mensaje de error
        echo "<p style='color: red;'>Error al actualizar neumático: " . $stmt->error . "</p>";
    }
}
?>


<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Da de baja neumáticos y ajusta el inventario en All in One. Gestión de productos actualizada.">
    <meta name="keywords" content="baja de neumáticos, gestión de inventario, All in One">  
    <title>Gestión de Neumáticos - All in One</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<header>
    <h1>Gestión de Neumáticos</h1>
    <!-- Botón para volver al tablero -->
    <button onclick="window.location.href='tablero.php'">Volver al tablero</button>
    <!-- Verificar si el usuario está autenticado para mostrar el botón de cerrar sesión -->
    <?php if (isset($_SESSION['usuario'])): ?>
        <li class="user-menu">
            <a href="logout.php">
                <button id="logout-button">Cerrar sesión</button>
            </a>
        </li>
    <?php endif; ?>
</header>

<main>
    <h2>Lista de Neumáticos</h2>
    <table>
        <thead>
            <tr>
                <th>ID Neumático</th>
                <th>Precio</th>
                <th>Marca</th>
                <th>Stock</th>
                <th>Acciones</th>
            </tr>
        </thead>
        <tbody>
            <?php
            // Consulta para obtener todos los neumáticos
            $query = "SELECT * FROM NEUMATICO";
            $result = $conexion->query($query);
            if ($result->num_rows > 0) {
                while ($neumatico = $result->fetch_assoc()) {
                    echo '<tr>';
                    echo '<td>' . $neumatico['ID_Neumatico'] . '</td>';
                    echo '<td>' . $neumatico['Precio'] . '</td>';
                    echo '<td>' . $neumatico['Marca'] . '</td>';
                    echo '<td>' . $neumatico['Stock'] . '</td>';
                    echo '<td>';
                    // Formulario para eliminar neumático
                    echo '<form method="post" action="" style="display:inline-block;">';
                    echo '<input type="hidden" name="id_neumatico" value="' . $neumatico['ID_Neumatico'] . '">';
                    echo '<button type="submit" name="delete">Dar de Baja</button>';
                    echo '</form>';
                    // Formulario para actualizar neumático
                    echo '<form method="post" action="" style="display:inline-block;">';
                    echo '<input type="hidden" name="id_neumatico" value="' . $neumatico['ID_Neumatico'] . '">';
                    echo '<input type="text" name="marca" value="' . $neumatico['Marca'] . '" required>';
                    echo '<input type="number" name="precio" value="' . $neumatico['Precio'] . '" step="0.01" required>';
                    echo '<input type="number" name="stock" value="' . $neumatico['Stock'] . '" required>';
                    echo '<button type="submit" name="update_tire">Actualizar</button>';
                    echo '</form>';
                    echo '</td>';
                    echo '</tr>';
                }
            } else {
                // Mostrar mensaje si no hay neumáticos registrados
                echo '<tr><td colspan="5">No hay neumáticos registrados.</td></tr>';
            }
            ?>
        </tbody>
    </table>

    <h2>Añadir Nuevo Neumático</h2>
    <form method="post" action="">
        <!-- Formulario para añadir un nuevo neumático -->
        <label for="id_neumatico">ID Neumático:</label>
        <input type="number" id="id_neumatico" name="id_neumatico" required>
        <label for="marca">Marca:</label>
        <input type="text" id="marca" name="marca" required>
        <label for="precio">Precio:</label>
        <input type="number" id="precio" name="precio" step="0.01" required>
        <label for="stock">Stock:</label>
        <input type="number" id="stock" name="stock" required>
        <button type="submit" name="add_tire">Añadir Neumático</button>
    </form>
</main>

<footer>
    <p>&copy; 2024 Parking. Todos los derechos reservados.</p>
</footer>
</body>
</html>
