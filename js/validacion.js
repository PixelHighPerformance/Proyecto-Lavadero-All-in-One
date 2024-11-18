// Validación de formulario de inicio de sesión
function validateLoginForm() {
    let cedula = document.forms["loginForm"]["usuario"].value;
    let contrasena = document.forms["loginForm"]["contrasena"].value;

    // Validar campos vacíos
    if (cedula === "" || contrasena === "") {
        alert("Todos los campos son obligatorios.");
        return false;
    }

    // Validar cédula
    if (cedula.length < 7 || cedula.length > 8 || isNaN(cedula)) {
        alert("Ingrese una cédula válida (7 u 8 dígitos numéricos).");
        return false;
    }

    // Validar contraseña
    if (contrasena.length < 6) {
        alert("La contraseña debe tener al menos 6 caracteres.");
        return false;
    }

    return true;
}

// Validación de formulario de registro
function validateRegistrationForm() {
    let cedula = document.forms["registrationForm"]["cedula"].value;
    let contrasena = document.forms["registrationForm"]["contrasena"].value;
    let confirmPassword = document.forms["registrationForm"]["confirmar_contrasena"].value;

    // Validar campos obligatorios
    if (cedula === "" || contrasena === "" || confirmPassword === "") {
        alert("Todos los campos son obligatorios.");
        return false;
    }

    // Validar cédula
    if (cedula.length < 7 || cedula.length > 8 || isNaN(cedula)) {
        alert("Ingrese una cédula válida (7 u 8 dígitos numéricos).");
        return false;
    }

    // Validar contraseña
    if (contrasena.length < 6) {
        alert("La contraseña debe tener al menos 6 caracteres.");
        return false;
    }

    // Validar confirmación de contraseña
    if (contrasena !== confirmPassword) {
        alert("Las contraseñas no coinciden.");
        return false;
    }

    return true;
}

// Función para mostrar/ocultar contraseñas
function togglePasswordVisibility() {
    const passwordFields = document.querySelectorAll('input[type="password"]');
    passwordFields.forEach(field => {
        field.type = field.type === 'password' ? 'text' : 'password';
    });
}
