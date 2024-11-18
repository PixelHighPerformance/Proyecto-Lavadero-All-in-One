<?php
session_start();
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Descubre All in One, el sistema de gestión de estacionamiento con servicios integrales para tu vehículo. Reserva, compra neumáticos y accede a nuestro taller.">
    <title>All in One - Servicios Integrales de Estacionamiento y Automóviles</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
<header>
    <nav>
        <a href="index.php">
            <img src="assets/img/Título secundario.svg" alt="Logo All in One - Servicios de Automóviles" class="nav-logo">
        </a>
        <h1>ALL <br>IN ONE</h1>
        <ul>
            <li><a href="index.php">
                <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-home-2" width="28" height="28" viewBox="0 0 24 24" stroke-width="1.5" stroke="#000000" fill="none" stroke-linecap="round" stroke-linejoin="round">
                    <path stroke="none" d="M0 0h24v24H0z" fill="none"/>
                    <path d="M5 12l-2 0l9 -9l9 9l-2 0" />
                    <path d="M5 12v7a2 2 0 0 0 2 2h10a2 2 0 0 0 2 -2v-7" />
                    <path d="M10 12h4v4h-4z" />
                </svg>Inicio
            </a></li>
            <li><a href="assets/pages/parking.php">
                <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-car-garage" width="28" height="28" viewBox="0 0 24 24" stroke-width="1.5" stroke="#000000" fill="none" stroke-linecap="round" stroke-linejoin="round">
                    <path stroke="none" d="M0 0h24v24H0z" fill="none"/>
                    <path d="M5 20a2 2 0 1 0 4 0a2 2 0 0 0 -4 0" />
                    <path d="M15 20a2 2 0 1 0 4 0a2 2 0 0 0 -4 0" />
                    <path d="M5 20h-2v-6l2 -5h9l4 5h1a2 2 0 0 1 2 2v4h-2m-4 0h-6m-6 -6h15m-6 0v-5" />
                    <path d="M3 6l9 -4l9 4" />
                </svg>Parking
            </a></li>
            <li><a href="assets/pages/taller.php">
                <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-assembly" width="28" height="28" viewBox="0 0 24 24" stroke-width="1.5" stroke="#000000" fill="none" stroke-linecap="round" stroke-linejoin="round">
                    <path stroke="none" d="M0 0h24v24H0z" fill="none"/>
                    <path d="M19.875 6.27a2.225 2.225 0 0 1 1.125 1.948v7.284c0 .809 -.443 1.555 -1.158 1.948l-6.75 4.27a2.269 2.269 0 0 1 -2.184 0l-6.75 -4.27a2.225 2.225 0 0 1 -1.158 -1.948v-7.285c0 -.809 .443 -1.554 1.158 -1.947l6.75 -3.98a2.33 2.33 0 0 1 2.25 0l6.75 3.98h-.033z" />
                    <path d="M15.5 9.422c.312 .18 .503 .515 .5 .876v3.277c0 .364 -.197 .7 -.515 .877l-3 1.922a1 1 0 0 1 -.97 0l-3 -1.922a1 1 0 0 1 -.515 -.876v-3.278c0 -.364 .197 -.7 .514 -.877l3 -1.79c.311 -.174 .69 -.174 1 0l3 1.79h-.014z" />
                </svg>Taller
            </a></li>
            <li><a href="assets/pages/neumaticos.php">
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
            <li><a href="assets/pages/lavadero.php">
                <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-droplet" width="28" height="28" viewBox="0 0 24 24" stroke-width="1.5" stroke="#000000" fill="none" stroke-linecap="round" stroke-linejoin="round">
                    <path stroke="none" d="M0 0h24v24H0z" fill="none"/>
                    <path d="M7.502 19.423c2.602 2.105 6.395 2.105 8.996 0c2.602 -2.105 3.262 -5.708 1.566 -8.546l-4.89 -7.26c-.42 -.625 -1.287 -.803 -1.936 -.397a1.376 1.376 0 0 0 -.41 .397l-4.893 7.26c-1.695 2.838 -1.035 6.441 1.567 8.546z" />
                </svg>Lavadero
            </a></li>
            <li><a href="assets/pages/trabaja.html">
                <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-phone" width="36" height="36" viewBox="0 0 24 24" stroke-width="1.5" stroke="#000000" fill="none" stroke-linecap="round" stroke-linejoin="round">
                    <path stroke="none" d="M0 0h24v24H0z" fill="none"/>
                    <path d="M5 4h4l2 5l-2.5 1.5a11 11 0 0 0 5 5l1.5 -2.5l5 2v4a2 2 0 0 1 -2 2a16 16 0 0 1 -15 -15a2 2 0 0 1 2 -2" />
                </svg>Trabaja con Nosotros
            </a></li>

           
            <li class="cart-menu">
                <a href="assets/pages/carrito.php">
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
            <?php if (isset($_SESSION['usuario'])): ?>
                <li class="user-menu">
                    <a href="assets/pages/logout.php">
                        <button id="logout-button">Cerrar sesión</button>
                    </a>
                </li>
            <?php else: ?>
                <li class="user-menu">
                    <a href="assets/pages/micuenta.html">
                        <button id="user-icon">
                            <img src="assets/img/perfil.png" alt="Perfil" class="icon">
                        </button>
                    </a>
                </li>
            <?php endif; ?>
        </ul>
    </nav>
</header>

<main>
        <section class="info">
           <div class="contact-info">
            <h2> All in One <br> Servicios Integrales para tu Vehículo</h2>
            <p>Bienvenidos a All in One Parking, donde ofrecemos una gama completa de servicios para el cuidado de tu vehículo. Disfruta de nuestros servicios de estacionamiento, lavado de autos, alineación y balanceo de ruedas, y venta de neumáticos. Nos comprometemos a brindar un servicio de alta calidad con la mayor comodidad y seguridad para tu vehículo.</p>
              <h3>Nuestra Ubicación</h3>
              <p>Luis Alberto de Herrera, Esquina Marne y Gualeguay, Montevideo</p>
             
              <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3273.5028552916783!2d-56.17146462507386!3d-34.86871707286039!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x959f807ab9ea155b%3A0x3b4edf63fa05987f!2sMarne%20%26%20Avenida%20Luis%20Alberto%20de%20Herrera%2C%2011600%20Montevideo%2C%20Departamento%20de%20Montevideo!5e0!3m2!1ses-419!2suy!4v1725938795694!5m2!1ses-419!2suy"  allowfullscreen="" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe>
        </section>
    </main>
    <footer>
        <div class="social-media">
            <a href="#"><img src="assets/img/x.png" alt="Twitter"></a>
            <a href="#"><img src="assets/img/instagram.png" alt="Instagram"></a>
        </div>
        <p>&copy; 2024 Parking. Todos los derechos reservados.</p>
    </footer>

<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&callback=initMap" async defer></script>
</body>
</html> 