
document.addEventListener('DOMContentLoaded', function () {
    const passwordInput = document.getElementById('contrasena');
    const togglePassword = document.getElementById('toggle-password');

    togglePassword.addEventListener('click', function () {
        if (passwordInput.type === 'password') {
            passwordInput.type = 'text';
            togglePassword.textContent = 'Ocultar'; // Cambia el texto a "Ocultar"
        } else {
            passwordInput.type = 'password';
            togglePassword.textContent = 'Mostrar'; // Cambia el texto a "Mostrar"
        }
    });
});

