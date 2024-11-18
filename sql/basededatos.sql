CREATE TABLE CLIENTE (
    CI_Cliente INT PRIMARY KEY CHECK (CI_Cliente > 999999 AND CI_Cliente < 70000000),
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    Celular INT CHECK (Celular >= 90000000 AND Celular <= 99999999) NULL,
    Contraseña VARCHAR(100) NOT NULL,
    Teléfono VARCHAR(15) CHECK (Teléfono >= '20000000' AND Teléfono <= '99999999') NULL,
    Pasaporte VARCHAR(20) NULL,
    Tipo ENUM('Mensual', 'Sistemático', 'Eventual', 'Extraordinario') NULL ,
    Descuento DECIMAL(5, 2) CHECK (Descuento >= 0 AND Descuento <= 10),
    Fecha_Nac DATE
);

DELIMITER //

CREATE TRIGGER cliente_fecha_nac_check
BEFORE INSERT ON CLIENTE
FOR EACH ROW
BEGIN
    IF NEW.Fecha_Nac > (CURDATE() - INTERVAL 18 YEAR) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente debe tener al menos 18 años.';
    END IF;
END//

DELIMITER ;


CREATE TABLE VEHICULO (
    Matricula VARCHAR(10) PRIMARY KEY,
    Marca VARCHAR(50) NOT NULL,
    Modelo VARCHAR(50) NOT NULL,
    Tipo ENUM('Auto', 'Moto', 'Camioneta', 'Pequeños Utilitarios', 'Pequeños Camiones') NOT NULL,
    CI_Cliente INT,
    FOREIGN KEY (CI_Cliente) REFERENCES CLIENTE(CI_Cliente)
);


CREATE TABLE RESERVA (
    ID_Reserva INT PRIMARY KEY AUTO_INCREMENT,
    Fecha DATE NOT NULL,
    Hora_Inicio TIME NOT NULL,
    Hora_Fin TIME NOT NULL CHECK (Hora_Fin > Hora_Inicio),
    Estado ENUM('Confirmada', 'Cancelada a tiempo', 'Cancelada tarde', 'Completada', 'No asiste') NOT NULL,
    Estado_Autorizacion ENUM('Autorizado', 'No Autorizado') DEFAULT 'No Autorizado',
    Matricula VARCHAR(10),
    FOREIGN KEY (Matricula) REFERENCES VEHICULO(Matricula)
);

DELIMITER //

CREATE TRIGGER reserva_fecha_check
BEFORE INSERT ON RESERVA
FOR EACH ROW
BEGIN
    IF NEW.Fecha < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha de la reserva debe ser en el futuro.';
    END IF;
END//

DELIMITER ;


CREATE TABLE FACTURA (
    ID_Factura INT PRIMARY KEY,
    Fecha_Factura DATE NOT NULL,
    Costo_Total DECIMAL(10, 2) CHECK (Costo_Total >= 0)
);

DELIMITER //

CREATE TRIGGER factura_fecha_check
BEFORE INSERT ON FACTURA
FOR EACH ROW
BEGIN
    IF NEW.Fecha_Factura > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha de la factura no puede ser en el futuro.';
    END IF;
END//

DELIMITER ;


CREATE TABLE SERVICIO (
    ID_Servicio INT PRIMARY KEY
);


CREATE TABLE BALANCEO_ALINEACION (
    ID_Servicio INT PRIMARY KEY,
    Precio DECIMAL(10, 2) CHECK (Precio > 0),
    Tipo ENUM('Montaje neumático', 'Alineación 1 tren desde R17', 'Alineación', 'Balanceo auto + válvula', 'Alineación 2 trenes', 'Pack alineación y 4 balanceos para camioneta + válvulas', 'Balanceo de camioneta + válvula') NOT NULL,
    FOREIGN KEY (ID_Servicio) REFERENCES SERVICIO(ID_Servicio)
);


CREATE TABLE LAVADERO (
    ID_Servicio INT PRIMARY KEY,
    Tipo_vehiculo ENUM('Auto', 'Moto', 'Camioneta', 'Pequeños Utilitarios', 'Pequeños Camiones') NOT NULL,
    Precio DECIMAL(10, 2) CHECK (Precio >= 0),
    FOREIGN KEY (ID_Servicio) REFERENCES SERVICIO(ID_Servicio)
);


CREATE TABLE NEUMATICO (
    ID_Neumatico INT PRIMARY KEY,
    Precio DECIMAL(10, 2) CHECK (Precio >= 0),
    Marca ENUM('Michelin', 'Bridgestone', 'Pirelli') NOT NULL,
    Stock INT CHECK (Stock >= 0)
);


CREATE TABLE PARKING (
    ID_Servicio INT PRIMARY KEY,
    ID_Plaza INT PRIMARY KEY,
    Tipo_plaza ENUM('1 plaza de auto', '1 plaza de moto', '1 plaza y media de auto') NOT NULL,
    Estado_plaza ENUM('Disponible', 'Ocupado') NOT NULL
    FOREIGN KEY (ID_Servicio) REFERENCES SERVICIO(ID_Servicio)
);


CREATE TABLE COSTO_PARKING (
    Tipo_vehiculo ENUM('Auto', 'Moto', 'Camioneta', 'Pequeños Utilitarios', 'Pequeños Camiones') PRIMARY KEY,
    Costo_por_hora DECIMAL(10, 2) CHECK (Costo_por_hora IN (50, 100, 120, 150))
);


CREATE TABLE EMPLEADO (
    CI INT PRIMARY KEY CHECK (CI > 999999 AND CI < 80000000),
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    Celular INT CHECK (Celular >= 90000000 AND Celular <= 99999999),
    Fecha_Nac DATE NOT NULL,
    Contraseña VARCHAR(100) NOT NULL,
    Fecha_Ingreso DATE NOT NULL,
    Tipo ENUM('Gerente', 'Cajero', 'Jefe de servicio de lavadero', 'Jefe de servicio de balanceo y alineación', 'Operador de respaldos', 'Ejecutivo de servicio de lavadero', 'Ejecutivo de servicio de balanceo y alineación', 'Ejecutivo de servicio de neumáticos') NOT NULL
);

DELIMITER //

CREATE TRIGGER empleado_fecha_ingreso_check
BEFORE INSERT ON EMPLEADO
FOR EACH ROW
BEGIN
    IF NEW.Fecha_Ingreso > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha de ingreso del empleado no puede ser en el futuro.';
    END IF;
END//

DELIMITER ;


CREATE TABLE COMPRA (
    ID_Servicio INT,
    ID_Neumatico INT,
    PRIMARY KEY (ID_Servicio, ID_Neumatico),
    FOREIGN KEY (ID_Servicio) REFERENCES SERVICIO(ID_Servicio),
    FOREIGN KEY (ID_Neumatico) REFERENCES NEUMATICO(ID_Neumatico)
);


CREATE TABLE CONTIENE (
    ID_Reserva INT,
    ID_Servicio INT,
    Tipo_vehiculo ENUM('Auto', 'Moto', 'Camioneta', 'Pequeños Utilitarios', 'Pequeños Camiones') NOT NULL,
    PRIMARY KEY (ID_Reserva, ID_Servicio),
    FOREIGN KEY (ID_Reserva) REFERENCES RESERVA(ID_Reserva),
    FOREIGN KEY (ID_Servicio) REFERENCES SERVICIO(ID_Servicio),
    FOREIGN KEY (Tipo_vehiculo) REFERENCES COSTO_PARKING(Tipo_vehiculo)
);


CREATE TABLE BRINDA (
    ID_Servicio INT,
    CI_Empleado INT,
    PRIMARY KEY (ID_Servicio, CI_Empleado),
    FOREIGN KEY (ID_Servicio) REFERENCES SERVICIO(ID_Servicio),
    FOREIGN KEY (CI_Empleado) REFERENCES EMPLEADO(CI)
);


CREATE TABLE CORRESPONDE (
    ID_Servicio INT,
    ID_Factura INT,
    PRIMARY KEY (ID_Servicio, ID_Factura),
    FOREIGN KEY (ID_Servicio) REFERENCES SERVICIO(ID_Servicio),
    FOREIGN KEY (ID_Factura) REFERENCES FACTURA(ID_Factura)
);

-- Inserciones para CLIENTE

INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000005, 'Pedro', 'Sánchez', 95678901, 'pass7890', '25123460', 'C8765432', 1, 10.00, '1978-09-30');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000006, 'Julia', 'Fernández', 91234561, 'password6', '21123461', 'D1234567', 1, 10.00, '1988-01-15');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000007, 'Carlos', 'Gutiérrez', 92345679, 'pass7890', '22123462', NULL, 2, 7.00, '1981-05-22');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000008, 'Marta', 'Lopez', 93456782, 'securepassword', '23123463', 'E9876543', 3, 0.00, '1992-12-01');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000009, 'José', 'Ramírez', 94567895, 'mypassword9', '24123464', NULL, 4, 0.00, '1979-03-10');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000010, 'Andrea', 'Suarez', 95678913, 'password10', '25123465', 'F1230987', 1, 10.00, '1985-04-18');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000011, 'Mario', 'Alvarez', 91234562, 'password11', '26123466', 'G9871234', 2, 7.00, '1978-07-12');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000012, 'Luisa', 'Sosa', 92345670, 'pass12', '27123467', NULL, 3, 0.00, '1989-09-25');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000013, 'Patricia', 'Castro', 93456783, 'secure13', '28123468', 'H6543210', 1, 10.00, '1991-11-20');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000014, 'Roberto', 'Silva', 94567891, 'mypassword14', '29123469', NULL, 4, 0.00, '1980-02-14');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000015, 'Lucía', 'Morales', 95678914, 'password15', '30123460', 'I9081723', 2, 7.00, '1993-08-09');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000016, 'Eduardo', 'Rojas', 91234563, 'password16', '31123461', 'J1234568', 1, 10.00, '1987-09-17');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000017, 'Cristina', 'Pérez', 92345671, 'pass17', '32123462', 'K8765432', 3, 0.00, '1994-06-30');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000018, 'María', 'Domínguez', 93456784, 'secure18', '33123463', NULL, 4, 0.00, '1983-03-18');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000019, 'Gabriel', 'Rodríguez', 94567892, 'mypassword19', '34123464', 'L7890123', 1, 10.00, '1992-05-25');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000020, 'Silvia', 'Vega', 95678915, 'password20', '35123465', NULL, 2, 7.00, '1986-11-15');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000021, 'Ernesto', 'García', 91234564, 'password21', '36123466', 'M3456789', 3, 0.00, '1989-12-11');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000022, 'Alicia', 'Ramirez', 92345672, 'pass22', '37123467', 'N2345678', 4, 0.00, '1991-07-07');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000023, 'Daniel', 'Serrano', 93456785, 'secure23', '38123468', 'O1234567', 1, 10.00, '1985-04-05');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000024, 'Rosa', 'Herrera', 94567893, 'mypassword24', '39123469', NULL, 2, 7.00, '1993-08-22');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000025, 'Oscar', 'Díaz', 95678916, 'password25', '40123460', 'P5678901', 3, 0.00, '1987-09-30');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000026, 'Felipe', 'Castillo', 91234565, 'password26', '41123461', NULL, 4, 0.00, '1982-03-15');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000027, 'Graciela', 'Benítez', 92345673, 'pass27', '42123462', 'Q6789012', 1, 10.00, '1990-06-18');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000028, 'Jorge', 'Alonso', 93456786, 'secure28', '43123463', 'R8901234', 2, 7.00, '1984-09-09');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000029, 'Carolina', 'Ibáñez', 94567894, 'mypassword29', '44123464', NULL, 3, 0.00, '1995-12-02');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000030, 'Luis', 'Figueroa', 95678917, 'password30', '45123465', 'S2345678', 1, 10.00, '1981-07-12');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000031, 'Mónica', 'Salinas', 91234566, 'password31', '46123466', 'T0987654', 4, 0.00, '1989-10-01');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000032, 'Raúl', 'Vidal', 92345674, 'pass32', '47123467', NULL, 2, 7.00, '1990-03-12');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000033, 'Carmen', 'Zambrano', 93456787, 'secure33', '48123468', 'U1234567', 3, 0.00, '1992-08-20');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000034, 'Elena', 'Maldonado', 94567895, 'mypassword34', '49123469', NULL, 1, 10.00, '1983-02-16');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000035, 'Julio', 'Cáceres', 95678918, 'password35', '50123460', 'V0987654', 4, 0.00, '1986-11-24');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000036, 'Valeria', 'Palacios', 91234567, 'password36', '51123461', 'W1230987', 2, 7.00, '1991-05-19');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000037, 'Enrique', 'Peralta', 92345675, 'pass37', '52123462', NULL, 3, 0.00, '1987-06-22');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000038, 'Beatriz', 'Bustamante', 93456788, 'secure38', '53123463', 'X6789012', 1, 10.00, '1984-07-31');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000039, 'Alberto', 'Cruz', 94567896, 'mypassword39', '54123464', NULL, 2, 7.00, '1982-10-15');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000040, 'Esther', 'Aguilar', 95678919, 'password40', '55123465', 'Y3456789', 4, 0.00, '1995-01-17');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000041, 'Miguel', 'Quiroga', 91234568, 'password41', '56123466', 'Z1234567', 1, 10.00, '1985-05-11');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000042, 'Susana', 'Lara', 92345676, 'pass42', '57123467', NULL, 2, 7.00, '1992-02-14');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000043, 'Pablo', 'Espinoza', 93456789, 'secure43', '58123468', 'A9876543', 3, 0.00, '1980-09-28');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000044, 'Mariana', 'Paredes', 94567897, 'mypassword44', '59123469', NULL, 4, 0.00, '1993-12-05');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000045, 'Rafael', 'Navarro', 95678920, 'password45', '60123460', 'B5678901', 1, 10.00, '1988-04-17');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000046, 'Teresa', 'Santana', 91234569, 'password46', '61123461', NULL, 2, 7.00, '1987-11-22');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000047, 'Héctor', 'Villalobos', 92345677, 'pass47', '62123462', 'C3456789', 3, 0.00, '1986-01-13');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000048, 'Daniela', 'Medina', 93456790, 'secure48', '63123463', 'D1230987', 4, 0.00, '1991-03-19');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000049, 'Gonzalo', 'Mora', 94567898, 'mypassword49', '64123464', NULL, 1, 10.00, '1984-08-07');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000050, 'Liliana', 'Delgado', 95678921, 'password50', '65123465', 'E6789012', 2, 7.00, '1989-10-23');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000051, 'Esteban', 'Moreno', 91234570, 'password51', '66123466', NULL, 3, 0.00, '1985-12-09');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000052, 'Claudia', 'Ortega', 92345678, 'pass52', '67123467', 'F9081723', 4, 0.00, '1990-09-12');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000053, 'Raquel', 'Campos', 93456791, 'secure53', '68123468', NULL, 1, 10.00, '1988-06-28');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000054, 'Emilio', 'Salazar', 94567899, 'mypassword54', '69123469', 'G2345678', 2, 7.00, '1993-07-25');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000055, 'Beatriz', 'Romero', 95678922, 'password55', '70123460', NULL, 3, 0.00, '1982-05-03');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000056, 'Ignacio', 'León', 91234571, 'password56', '71123461', 'H3456789', 4, 0.00, '1987-02-17');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000057, 'Marcela', 'Ramos', 92345679, 'pass57', '72123462', NULL, 1, 10.00, '1986-08-14');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000058, 'Arturo', 'Miranda', 93456792, 'secure58', '73123463', 'I0987654', 2, 7.00, '1984-10-20');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000059, 'Soledad', 'Mejía', 94567900, 'mypassword59', '74123464', NULL, 3, 0.00, '1983-11-04');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000060, 'Aníbal', 'Escobar', 95678923, 'password60', '75123465', 'J9871234', 4, 0.00, '1990-01-18');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000061, 'Ana', 'González', 91234572, 'password61', '76123466', NULL, 1, 10.00, '1989-04-27');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000062, 'Rodrigo', 'Guzmán', 92345680, 'pass62', '77123467', 'K8765432', 2, 7.00, '1991-06-10');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000063, 'Laura', 'Arroyo', 93456793, 'secure63', '78123468', NULL, 3, 0.00, '1986-11-30');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000064, 'Diana', 'Cornejo', 94567901, 'mypassword64', '79123469', 'L7890123', 4, 0.00, '1994-08-16');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000065, 'Javier', 'López', 95678924, 'password65', '80123460', NULL, 1, 10.00, '1983-09-15');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000066, 'Natalia', 'Jiménez', 91234573, 'password66', '81123461', 'M6789012', 2, 7.00, '1988-05-11');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000067, 'Camilo', 'Valdez', 92345681, 'pass67', '82123462', NULL, 3, 0.00, '1981-12-25');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000068, 'Alma', 'Saavedra', 93456794, 'secure68', '83123463', 'N3456789', 1, 10.00, '1985-02-05');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000069, 'Oscar', 'Blanco', 94567902, 'mypassword69', '84123464', NULL, 2, 7.00, '1987-07-22');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000070, 'Yolanda', 'Pinto', 95678925, 'password70', '85123465', 'O1234567', 3, 0.00, '1989-10-13');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000141, 'Amparo', 'Reyes', 92345691, 'pass141', '95123468', 'S1234567', 4, 0.00, '1981-11-30');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000142, 'Manuel', 'Del Valle', 93456800, 'secure142', '96123469', NULL, 1, 10.00, '1985-09-27');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000143, 'Adriana', 'Martinez', 94567910, 'mypassword143', '97123460', 'T1230987', 2, 7.00, '1990-06-24');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000144, 'Nicolás', 'Rincón', 95678934, 'password144', '98123461', NULL, 3, 0.00, '1986-12-11');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000145, 'Leticia', 'Lara', 91234583, 'password145', '99123462', 'U3456789', 4,0.00, '1988-07-18');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000146, 'Álvaro', 'Ramos', 92345692, 'pass146', '99123463', NULL, 1, 4.25, '1989-04-13');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000147, 'Lorena', 'Salas', 93456801, 'secure147', '99123464', 'V7890123', 2, 7.00, '1991-01-29');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000148, 'Iván', 'Melendez', 94567911, 'mypassword148', '99123465', NULL, 3, 0.00, '1983-05-04');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000149, 'Elisa', 'Méndez', 95678935, 'password149', '99123466', 'W9871234', 4, 0.00, '1987-10-31');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000150, 'Victor', 'Naranjo', 91234584, 'password150', '99123467', NULL, 1,10.00, '1982-09-21');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000151, 'Cecilia', 'Espinosa', 91234585, 'password151', '21123470', 'X1234567', 1, 10.00, '1985-02-10');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000152, 'Andrés', 'Zúñiga', 92345693, 'pass152', '22123471', NULL, 2, 7.00, '1983-09-30');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000153, 'Blanca', 'Herrera', 93456802, 'secure153', '23123472', 'Y8765432', 3, 0.00, '1992-11-05');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000154, 'Felipe', 'Maldonado', 94567912, 'mypassword154', '24123473', NULL, 4,0.00, '1989-07-16');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000155, 'Vanessa', 'Arias', 95678936, 'password155', '25123474', 'Z6543210', 1, 10.00, '1984-04-12');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000156, 'Martín', 'Salazar', 91234586, 'password156', '26123475', NULL, 2, 7.00, '1988-06-14');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000157, 'Elena', 'Mora', 92345694, 'pass157', '27123476', 'A1239087', 3, 0.00, '1985-10-10');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000158, 'Raúl', 'Cardenas', 93456803, 'secure158', '28123477', NULL, 4, 0.00, '1991-02-20');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000159, 'Sandra', 'Navarro', 94567913, 'mypassword159', '29123478', 'B6789012', 1,10.00, '1982-12-15');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000160, 'Diego', 'Palacios', 95678937, 'password160', '30123479', NULL, 2, 7.00, '1990-01-03');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000161, 'Graciela', 'Rojas', 91234587, 'password161', '31123480', 'C9871234', 3,0.00, '1987-05-21');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000162, 'Hugo', 'Mejía', 92345695, 'pass162', '32123481', NULL, 4, 0.00, '1985-11-09');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000163, 'Beatriz', 'Pérez', 93456804, 'secure163', '33123482', 'D1234567', 1, 10.00, '1986-03-14');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000164, 'Ramiro', 'Álvarez', 94567914, 'mypassword164', '34123483', NULL, 2, 7.00, '1993-07-19');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000165, 'Victoria', 'Medina', 95678938, 'password165', '35123484', 'E0987654', 3, 0.00, '1984-09-23');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000166, 'Cristian', 'Ortega', 91234588, 'password166', '36123485', NULL, 4, 0.00, '1989-05-11');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000167, 'Silvia', 'González', 92345696, 'pass167', '37123486', 'F3456789', 1, 10.00, '1982-08-04');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000168, 'Luis', 'Morales', 93456805, 'secure168', '38123487', NULL, 2, 7.00, '1990-04-01');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000169, 'Teresa', 'Duarte', 94567915, 'mypassword169', '39123488', 'G9081723', 3, 0.00, '1991-12-18');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000170, 'Ricardo', 'Herrera', 95678939, 'password170', '40123489', NULL, 4,0.00, '1987-03-05');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000171, 'Ana', 'Sandoval', 91234589, 'password171', '41123490', 'H3456789', 1, 10.00, '1988-06-13');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000172, 'Julio', 'Cáceres', 92345697, 'pass172', '42123491', NULL, 2, 7.00, '1993-11-29');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000173, 'Lorena', 'Salas', 93456806, 'secure173', '43123492', 'I9871234', 3, 2.50, '1986-12-25');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000174, 'Nicolás', 'Gómez', 94567916, 'mypassword174', '44123493', NULL, 4, 0.00, '1984-10-10');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000175, 'Patricia', 'Velasco', 95678940, 'password175', '45123494', 'J2345678', 1, 10.00, '1991-01-12');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000176, 'Óscar', 'Del Valle', 91234590, 'password176', '46123495', NULL, 2, 7.00, '1989-08-30');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000177, 'Rita', 'Meléndez', 92345698, 'pass177', '47123496', NULL, 3, 0.00, '1985-07-07');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000178, 'Mario', 'Luna', 93456807, 'secure178', '48123497', 'K6789012', 4, 0.00, '1983-05-18');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000179, 'Luz', 'Cruz', 94567917, 'mypassword179', '49123498', NULL, 1, 10.00, '1990-10-21');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000180, 'Daniel', 'Ramos', 95678941, 'password180', '50123499', 'L3456789', 2, 7.00, '1987-02-28');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000181, 'Verónica', 'Castillo', 91234591, 'password181', '51123500', NULL, 3, 0.00, '1982-12-05');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000182, 'Hernán', 'García', 92345699, 'pass182', '52123501', 'M7890123', 4, 3.25, '1984-09-17');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000183, 'Estela', 'Guerrero', 93456808, 'secure183', '53123502', NULL, 1,10.00, '1993-06-29');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000184, 'Tomas', 'Ferrer', 94567918, 'mypassword184', '54123503', 'N9081723', 2, 7.00, '1986-05-11');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000185, 'Aída', 'Muñoz', 95678942, 'password185', '55123504', NULL, 3, 0.00, '1990-10-01');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000186, 'Pedro', 'Vázquez', 91234592, 'password186', '56123505', 'O5678901', 4, 0.00, '1983-07-30');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000187, 'Cristina', 'Soto', 92345700, 'pass187', '57123506', NULL, 1, 10.00, '1987-03-09');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000188, 'Armando', 'Vega', 93456809, 'secure188', '58123507', 'P2345678', 2, 7.00, '1992-08-06');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000189, 'Lucía', 'Peña', 94567919, 'mypassword189', '59123508', NULL, 3, 0.00, '1991-11-19');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000190, 'Carlos', 'Galindo', 95678943, 'password190', '60123509', 'Q3456789', 4, 0.00, '1984-12-03');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000191, 'Nancy', 'Mendoza', 91234593, 'password191', '61123510', NULL, 1,10.00, '1986-01-23');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000192, 'Miguel', 'Villanueva', 92345701, 'pass192', '62123511', 'R7890123', 2, 7.00, '1985-04-20');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000193, 'Carmen', 'Ruiz', 93456810, 'secure193', '63123512', NULL, 3, 0.00, '1983-06-12');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000194, 'Francisco', 'Reyes', 94567920, 'mypassword194', '64123513', 'S9081723', 4, 0.00, '1991-09-30');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000195, 'Laura', 'Cano', 95678944, 'password195', '65123514', NULL, 1, 10.00, '1987-10-18');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000196, 'Juan', 'Bustamante', 91234594, 'password196', '66123515', 'T1234567', 2, 7.00, '1989-07-24');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000197, 'Daniela', 'Páez', 92345702, 'pass197', '67123516', NULL, 3, 0.00, '1982-11-16');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000198, 'Oscar', 'Benítez', 93456811, 'secure198', '68123517', 'U6789012', 4, 0.00, '1985-08-11');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000199, 'Valeria', 'Ibáñez', 94567921, 'mypassword199', '69123518', NULL, 1, 10.00, '1990-02-08');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000200, 'Antonio', 'Villalobos', 95678945, 'password200', '70123519', 'V3456789', 2, 7.00, '1991-01-29');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000201, 'Fernanda', 'Pineda', 91234595, 'password201', '21123520', 'X0987654', 1, 10.00, '1985-07-18');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000202, 'José', 'Barrios', 92345703, 'pass202', '22123521', NULL, 2, 7.00, '1983-03-02');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000203, 'María', 'Araya', 93456812, 'secure203', '23123522', 'Y5678901', 3,0.00, '1992-11-05');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000204, 'Javier', 'Olivares', 94567922, 'mypassword204', '24123523', NULL, 4,0.00, '1989-01-16');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000205, 'Gloria', 'Mendoza', 95678946, 'password205', '25123524', 'Z1234567', 1, 10.00, '1984-04-22');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000206, 'Eduardo', 'Peña', 91234596, 'password206', '26123525', NULL, 2, 7.00, '1988-05-14');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000207, 'Fabiola', 'Román', 92345704, 'pass207', '27123526', 'A6789012', 3, 2.00, '1985-10-20');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000208, 'Raúl', 'Zapata', 93456813, 'secure208', '28123527', NULL, 4, 0.00, '1991-08-18');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000209, 'Daniela', 'Ríos', 94567923, 'mypassword209', '29123528', 'B0987654', 1, 10.00, '1982-03-15');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000210, 'Emilio', 'Castro', 95678947, 'password210', '30123529', NULL, 2, 7.00, '1990-06-03');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000211, 'Carolina', 'Vargas', 91234597, 'password211', '31123530', 'C5678901', 3, 0.00, '1987-09-21');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000212, 'Armando', 'Pérez', 92345705, 'pass212', '32123531', NULL, 4, 0.00, '1985-02-11');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000213, 'Paola', 'Molina', 93456814, 'secure213', '33123532', 'D1234567', 1, 10.00, '1986-08-13');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000214, 'Carlos', 'Alonso', 94567924, 'mypassword214', '34123533', NULL, 2, 7.00, '1993-01-12');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000215, 'Sofía', 'León', 95678948, 'password215', '35123534', 'E9876543', 3, 0.00, '1984-04-23');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000216, 'Victor', 'Martínez', 91234598, 'password216', '36123535', NULL, 4, 0.00, '1989-03-11');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000217, 'Beatriz', 'Santos', 92345706, 'pass217', '37123536', 'F1239087', 1, 10.00, '1982-07-20');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000218, 'Rodrigo', 'Hernández', 93456815, 'secure218', '38123537', NULL, 2, 7.00, '1990-05-19');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (1000219, 'Juan', 'Pérez', 91234567, 'password123', '21123456', 'A1234567', 1, 10.00, '1985-05-10');
INSERT INTO CLIENTE (CI_Cliente, Nombre, Apellido, Celular, Contraseña, Teléfono, Pasaporte, Tipo, Descuento, Fecha_Nac) VALUES (12345678,	'Juan',	'Pérez'	,98765432	,'482c811da5d5b4bc6d497ffa98491e38',	'23456789',	NULL ,0, 10.00,	'1990-01-15	');
-- Inserciones para VEHICULO
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('ABC1234', 'Toyota', 'Corolla', 'Auto', 10000001);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('ABC102', 'Honda', 'Civic', 'Auto', 1000002);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('DEF103', 'Ford', 'Focus', 'Auto', 1000003);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('JKL105', 'Mazda', '3', 'Auto', 1000004);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('MNO106', 'Nissan', 'Sentra', 'Auto', 1000005);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('PQR107', 'Hyundai', 'Elantra', 'Auto', 1000006);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('STU108', 'Kia', 'Optima', 'Auto', 1000007);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('VWX109', 'Volkswagen', 'Jetta', 'Auto', 1000008);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('YZA110', 'Renault', 'Logan', 'Auto', 1000009);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('BCD111', 'Chevrolet', 'Onix', 'Auto', 1000010);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('EFG112', 'Toyota', 'Hilux', 'Camioneta', 1000011);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('HIJ113', 'Ford', 'Ranger', 'Camioneta', 1000012);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('LMN114', 'Chevrolet', 'S10', 'Camioneta', 1000012);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('OPQ115', 'Volkswagen', 'Amarok', 'Camioneta', 1000013);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('RST116', 'Nissan', 'Frontier', 'Camioneta', 1000014);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('UVW117', 'Mazda', 'BT-50', 'Camioneta', 1000015);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('XYZ118', 'Hyundai', 'Santa Cruz', 'Camioneta', 1000016);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('ABC119', 'Renault', 'Duster Oroch', 'Camioneta', 1000017);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('DEF120', 'Fiat', 'Toro', 'Camioneta', 1000018);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('GHI121', 'Jeep', 'Gladiator', 'Camioneta', 1000018);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('JKL122', 'Yamaha', 'YZF-R3', 'Moto', 1000019);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('MNO123', 'Honda', 'CB500', 'Moto', 1000020);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('PQR124', 'Suzuki', 'GSX-R600', 'Moto', 1000021);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('STU125', 'BMW', 'G310R', 'Moto', 1000022);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('VWX126', 'Kawasaki', 'Ninja 400', 'Moto', 1000023);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('YZA127', 'Harley-Davidson', 'Iron 883', 'Moto', 1000024);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('BCD128', 'Ducati', 'Panigale V2', 'Moto', 1000024);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('EFG129', 'Triumph', 'Street Triple', 'Moto', 1000025);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('HIJ130', 'Royal Enfield', 'Interceptor 650', 'Moto', 1000026);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('LMN131', 'Aprilia', 'RS 660', 'Moto', 1000027);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('OPQ132', 'Ford', 'Transit', 'Pequeños Utilitarios', 1000028);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('RST133', 'Chevrolet', 'Express', 'Pequeños Utilitarios', 1000029);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('UVW134', 'Ram', 'ProMaster', 'Pequeños Utilitarios', 1000030);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('XYZ135', 'Mercedes-Benz', 'Sprinter', 'Pequeños Utilitarios', 1000031);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('ABC136', 'Nissan', 'NV200', 'Pequeños Utilitarios', 1000032);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('DEF137', 'Hyundai', 'H-100', 'Pequeños Utilitarios', 1000033);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('GHI138', 'Fiat', 'Ducato', 'Pequeños Utilitarios', 1000034);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('JKL139', 'Volkswagen', 'Caddy', 'Pequeños Utilitarios', 1000035);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('MNO140', 'Peugeot', 'Expert', 'Pequeños Utilitarios', 1000036);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('PQR141', 'Renault', 'Kangoo', 'Pequeños Utilitarios', 1000037);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('STU142', 'Mercedes-Benz', 'Actros', 'Pequeños Camiones', 1000038);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('VWX143', 'MAN', 'TGL', 'Pequeños Camiones', 1000039);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('YZA144', 'Volvo', 'FL', 'Pequeños Camiones', 1000040);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('BCD145', 'Scania', 'P Series', 'Pequeños Camiones', 1000041);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('EFG146', 'Iveco', 'Eurocargo', 'Pequeños Camiones', 1000042);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('HIJ147', 'DAF', 'LF', 'Pequeños Camiones', 1000043);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('LMN148', 'Hino', '300 Series', 'Pequeños Camiones', 1000044);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('OPQ149', 'Foton', 'Aumark', 'Pequeños Camiones', 1000045);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('RST150', 'Hyundai', 'Mighty', 'Pequeños Camiones', 1000046);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('UVW151', 'Isuzu', 'N Series', 'Pequeños Camiones', 1000047);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('XYZ152', 'Toyota', 'Highlander', 'Auto', 1000048);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('ABC153', 'Honda', 'CR-V', 'Camioneta', 1000049);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('DEF154', 'Ford', 'Explorer', 'Camioneta', 1000050);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('GHI155', 'Chevrolet', 'Traverse', 'Camioneta', 1000051);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('JKL156', 'Mazda', 'CX-5', 'Camioneta', 1000052);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('MNO157', 'Nissan', 'Rogue', 'Camioneta', 1000053);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('PQR158', 'Hyundai', 'Tucson', 'Camioneta', 1000054);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('STU159', 'Kia', 'Sportage', 'Camioneta', 1000055);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('VWX160', 'Volkswagen', 'Tiguan', 'Camioneta', 1000056);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('YZA161', 'Renault', 'Captur', 'Camioneta', 1000057);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('BCD162', 'Toyota', 'Sienna', 'Pequeños Utilitarios', 1000058);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('EFG163', 'Honda', 'Odyssey', 'Pequeños Utilitarios', 1000059);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('HIJ164', 'Ford', 'Transit Connect', 'Pequeños Utilitarios', 1000060);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('LMN165', 'Chevrolet', 'City Express', 'Pequeños Utilitarios', 1000061);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('OPQ166', 'Ram', 'C/V', 'Pequeños Utilitarios', 1000062);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('RST167', 'Mercedes-Benz', 'Metris', 'Pequeños Utilitarios', 1000063);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('UVW168', 'Nissan', 'NV3500', 'Pequeños Utilitarios', 1000064);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('XYZ169', 'Hyundai', 'Starex', 'Pequeños Utilitarios', 1000065);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('ABC170', 'Fiat', 'Doblo', 'Pequeños Utilitarios', 1000066);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('DEF171', 'Volkswagen', 'Transporter', 'Pequeños Utilitarios', 1000067);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('GHI172', 'Subaru', 'Forester', 'Camioneta', 1000068);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('JKL173', 'BMW', 'X3', 'Camioneta', 1000069);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('MNO174', 'Audi', 'Q5', 'Camioneta', 1000070);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('PQR175', 'Toyota', 'Land Cruiser', 'Camioneta', 1000071);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('STU176', 'Hyundai', 'Palisade', 'Camioneta', 1000072);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('VWX177', 'Kia', 'Telluride', 'Camioneta', 1000073);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('YZA178', 'Volkswagen', 'Atlas', 'Camioneta', 1000074);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('BCD179', 'Mazda', 'CX-9', 'Camioneta', 1000141);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('EFG180', 'Ford', 'Expedition', 'Camioneta', 1000142);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('HIJ181', 'Chevrolet', 'Tahoe', 'Camioneta', 1000143);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('LMN182', 'Dodge', 'Durango', 'Camioneta', 1000144);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('OPQ183', 'Nissan', 'Pathfinder', 'Camioneta', 1000145);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('RST184', 'Honda', 'Pilot', 'Camioneta', 1000146);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('UVW185', 'Mercedes-Benz', 'GLC', 'Camioneta', 1000147);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('XYZ186', 'Lexus', 'RX', 'Camioneta', 1000148);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('ABC187', 'BMW', 'X5', 'Camioneta', 1000149);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('DEF188', 'Audi', 'Q7', 'Camioneta', 1000150);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('GHI189', 'Volkswagen', 'Touareg', 'Camioneta', 1000151);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('JKL190', 'Jeep', 'Grand Cherokee', 'Camioneta', 1000152);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('MNO191', 'Toyota', '4Runner', 'Camioneta', 1000153);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('PQR192', 'Ford', 'Edge', 'Camioneta', 1000154);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('STU193', 'Hyundai', 'Santa Fe', 'Camioneta', 1000155);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('VWX194', 'Kia', 'Sorento', 'Camioneta', 1000156);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('YZA195', 'Mazda', 'CX-8', 'Camioneta', 1000157);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('BCD196', 'Nissan', 'Murano', 'Camioneta', 1000158);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('EFG197', 'Subaru', 'Ascent', 'Camioneta', 1000159);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('HIJ198', 'Chevrolet', 'Blazer', 'Camioneta', 1000160);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('LMN199', 'Volkswagen', 'Tiguan', 'Camioneta', 1000161);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('OPQ200', 'Toyota', 'Venza', 'Camioneta', 1000162);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('RST201', 'Ford', 'Bronco', 'Camioneta', 1000163);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('UVW202', 'Honda', 'Passport', 'Camioneta', 1000164);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('XYZ203', 'Lexus', 'GX', 'Camioneta', 1000165);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('ABC204', 'Mercedes-Benz', 'GLE', 'Camioneta', 1000166);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('DEF205', 'BMW', 'X6', 'Camioneta', 1000167);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('GHI206', 'Audi', 'Q8', 'Camioneta', 1000168);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('JKL207', 'Land Rover', 'Discovery', 'Camioneta', 1000169);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('MNO208', 'Jeep', 'Wrangler', 'Camioneta', 1000170);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('PQR209', 'Toyota', 'Sequoia', 'Camioneta', 1000171);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('STU210', 'Ford', 'Explorer', 'Camioneta', 1000172);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('VWX211', 'Chevrolet', 'Suburban', 'Camioneta', 1000173);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('YZA212', 'Toyota', 'Tacoma', 'Pequeños Camiones', 1000174);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('BCD213', 'Nissan', 'Titan', 'Pequeños Camiones', 1000175);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('EFG214', 'Ford', 'F-150', 'Pequeños Camiones', 1000176);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('HIJ215', 'Chevrolet', 'Silverado', 'Pequeños Camiones', 1000177);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('LMN216', 'Ram', '1500', 'Pequeños Camiones', 1000178);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('OPQ217', 'GMC', 'Sierra', 'Pequeños Camiones', 1000179);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('RST218', 'Honda', 'Ridgeline', 'Pequeños Camiones', 1000180);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('UVW219', 'Hyundai', 'Santa Cruz', 'Pequeños Camiones', 1000181);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('XYZ220', 'Mazda', 'BT-50', 'Pequeños Camiones', 1000182);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('ABC221', 'Toyota', 'Hilux', 'Pequeños Camiones', 1000183);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('DEF222', 'Nissan', 'Navara', 'Pequeños Camiones', 1000184);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('GHI223', 'Ford', 'Ranger', 'Pequeños Camiones', 1000185);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES ('JKL224', 'Chevrolet', 'Colorado', 'Pequeños Camiones', 1000186);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL226', 'Toyota', 'Hilux', 'Pequeños Camiones', 1000188);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL227', 'Nissan', 'Frontier', 'Pequeños Camiones', 1000189);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL228', 'Mitsubishi', 'L200', 'Pequeños Camiones', 1000190);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL229', 'Volkswagen', 'Amarok', 'Pequeños Camiones', 1000191);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL230', 'Mazda', 'BT-50', 'Pequeños Camiones', 1000192);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL231', 'Isuzu', 'D-Max', 'Pequeños Camiones', 1000193);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL232', 'Chevrolet', 'S10', 'Pequeños Camiones', 1000194);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL233', 'RAM', '1500', 'Pequeños Camiones', 1000195);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL234', 'GMC', 'Canyon', 'Pequeños Camiones', 1000196);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL235', 'Honda', 'Ridgeline', 'Pequeños Camiones', 1000197);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL236', 'Jeep', 'Gladiator', 'Pequeños Camiones', 1000198);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL237', 'Hyundai', 'Santa Cruz', 'Pequeños Camiones', 1000199);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL238', 'Chevrolet', 'Colorado', 'Pequeños Camiones', 1000200);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL239', 'Ford', 'Maverick', 'Pequeños Camiones', 1000201);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL240', 'Toyota', 'Tacoma', 'Pequeños Camiones', 1000202);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL241', 'Nissan', 'Navara', 'Pequeños Camiones', 1000203);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL242', 'Mitsubishi', 'Triton', 'Pequeños Camiones', 1000204);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL243', 'Volkswagen', 'Saveiro', 'Pequeños Camiones', 1000205);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL244', 'Mazda', 'B-Series', 'Pequeños Camiones', 1000206);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL245', 'Isuzu', 'Rodeo', 'Pequeños Camiones', 1000207);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL246', 'Chevrolet', 'LUV', 'Pequeños Camiones', 1000208);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL247', 'RAM', '2500', 'Pequeños Camiones', 1000209);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL248', 'GMC', 'Sierra', 'Pequeños Camiones', 1000210);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL249', 'Honda', 'Acty', 'Pequeños Camiones', 1000211);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL250', 'Jeep', 'Comanche', 'Pequeños Camiones', 1000212);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL251', 'Hyundai', 'Porter', 'Pequeños Camiones', 1000213);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL252', 'Chevrolet', 'Montana', 'Pequeños Camiones', 1000214);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL253', 'Ford', 'Courier', 'Pequeños Camiones', 1000215);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL254', 'Toyota', 'Tundra', 'Pequeños Camiones', 1000216);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL255', 'Nissan', 'Titan', 'Pequeños Camiones', 1000217);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL256', 'Mitsubishi', 'Outlander', 'Camioneta', 1000218);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL257', 'Volkswagen', 'Touareg', 'Camioneta', 1000219);
INSERT INTO VEHICULO (Matricula, Marca, Modelo, Tipo, CI_Cliente) VALUES('JKL258', 'Volkswagen', 'Touareg', 'Camioneta', 12345678);

-- Inserciones para RESERVA

INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(1,	'2024-09-10','10:00:00'	, '11:00:00',	'Confirmada'	,'ABC1234');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(2, '2024-11-04', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'XYZ456');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(3, '2024-11-05', '12:00:00', '14:00:00', 'Completada', 'LMN789');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(4, '2024-11-06', '15:00:00', '17:00:00', 'No asiste', 'JKL012');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(5, '2024-11-07', '10:00:00', '12:00:00', 'Cancelada tarde', 'QRS345');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(1, '2024-11-03', '08:00:00', '10:00:00', 'Confirmada', 'ABC123');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(2, '2024-11-04', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'XYZ456');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(3, '2024-11-05', '12:00:00', '14:00:00', 'Completada', 'LMN789');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(4, '2024-11-06', '15:00:00', '17:00:00', 'No asiste', 'JKL012');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(5, '2024-11-07', '10:00:00', '12:00:00', 'Cancelada tarde', 'QRS345');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(6, '2024-11-08', '08:00:00', '10:00:00', 'Confirmada', 'DEF678');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(7, '2024-11-09', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'UVW901');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(8, '2024-11-10', '12:00:00', '14:00:00', 'Completada', 'TUV234');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(9, '2024-11-11', '15:00:00', '17:00:00', 'No asiste', 'YZA567');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(10, '2024-11-12', '10:00:00', '12:00:00', 'Cancelada tarde', 'MNO890');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(11, '2024-11-13', '08:00:00', '10:00:00', 'Confirmada', 'RST123');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(12, '2024-11-14', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'JKL345');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(13, '2024-11-15', '12:00:00', '14:00:00', 'Completada', 'DEF678');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(14, '2024-11-16', '15:00:00', '17:00:00', 'No asiste', 'ABC567');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(15, '2024-11-17', '10:00:00', '12:00:00', 'Cancelada tarde', 'UVW678');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(16, '2024-11-18', '08:00:00', '10:00:00', 'Confirmada', 'XYZ890');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(17, '2024-11-19', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'LMN234');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(18, '2024-11-20', '12:00:00', '14:00:00', 'Completada', 'JKL678');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(19, '2024-11-21', '15:00:00', '17:00:00', 'No asiste', 'DEF890');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(20, '2024-11-22', '10:00:00', '12:00:00', 'Cancelada tarde', 'RST456');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(21, '2024-11-23', '08:00:00', '10:00:00', 'Confirmada', 'JKL122');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(22, '2024-11-24', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'MNO123');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(23, '2024-11-25', '12:00:00', '14:00:00', 'Completada', 'PQR124');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(24, '2024-11-26', '15:00:00', '17:00:00', 'No asiste', 'STU125');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(25, '2024-11-27', '10:00:00', '12:00:00', 'Cancelada tarde', 'VWX126');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(26, '2024-11-28', '08:00:00', '10:00:00', 'Confirmada', 'YZA127');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(27, '2024-11-29', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'BCD128');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(28, '2024-11-30', '12:00:00', '14:00:00', 'Completada', 'EFG129');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(29, '2024-12-01', '15:00:00', '17:00:00', 'No asiste', 'HIJ130');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(30, '2024-12-02', '10:00:00', '12:00:00', 'Cancelada tarde', 'LMN131');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(31, '2024-12-03', '08:00:00', '10:00:00', 'Confirmada', 'OPQ132');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(32, '2024-12-04', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'RST133');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(33, '2024-12-05', '12:00:00', '14:00:00', 'Completada', 'UVW134');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(34, '2024-12-06', '15:00:00', '17:00:00', 'No asiste', 'XYZ135');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(35, '2024-12-07', '10:00:00', '12:00:00', 'Cancelada tarde', 'ABC136');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(36, '2024-12-08', '08:00:00', '10:00:00', 'Confirmada', 'DEF137');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(37, '2024-12-09', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'GHI138');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(38, '2024-12-10', '12:00:00', '14:00:00', 'Completada', 'JKL139');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(39, '2024-12-11', '15:00:00', '17:00:00', 'No asiste', 'MNO140');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(40, '2024-12-12', '10:00:00', '12:00:00', 'Cancelada tarde', 'PQR141');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(41, '2024-12-13', '08:00:00', '10:00:00', 'Confirmada', 'STU142');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(42, '2024-12-14', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'VWX143');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(43, '2024-12-15', '12:00:00', '14:00:00', 'Completada', 'YZA144');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(44, '2024-12-16', '15:00:00', '17:00:00', 'No asiste', 'BCD145');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(45, '2024-12-17', '10:00:00', '12:00:00', 'Cancelada tarde', 'EFG146');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(46, '2024-12-18', '08:00:00', '10:00:00', 'Confirmada', 'HIJ147');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(47, '2024-12-19', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'LMN148');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(48, '2024-12-20', '12:00:00', '14:00:00', 'Completada', 'OPQ149');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(49, '2024-12-21', '15:00:00', '17:00:00', 'No asiste', 'RST150');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(50, '2024-12-22', '10:00:00', '12:00:00', 'Cancelada tarde', 'UVW151');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(51, '2024-12-23', '08:00:00', '10:00:00', 'Confirmada', 'XYZ152');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(52, '2024-12-24', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'ABC153');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(53, '2024-12-25', '12:00:00', '14:00:00', 'Completada', 'DEF154');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(54, '2024-12-26', '15:00:00', '17:00:00', 'No asiste', 'GHI155');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(55, '2024-12-27', '10:00:00', '12:00:00', 'Cancelada tarde', 'JKL156');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(56, '2024-12-28', '08:00:00', '10:00:00', 'Confirmada', 'MNO157');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(57, '2024-12-29', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'PQR158');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(58, '2024-12-30', '12:00:00', '14:00:00', 'Completada', 'STU159');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(59, '2024-12-31', '15:00:00', '17:00:00', 'No asiste', 'VWX160');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(60, '2025-01-01', '10:00:00', '12:00:00', 'Cancelada tarde', 'YZA161');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(61, '2025-01-02', '08:00:00', '10:00:00', 'Confirmada', 'BCD162');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(62, '2025-01-03', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'EFG163');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(63, '2025-01-04', '12:00:00', '14:00:00', 'Completada', 'HIJ164');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(64, '2025-01-05', '15:00:00', '17:00:00', 'No asiste', 'LMN165');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(65, '2025-01-06', '10:00:00', '12:00:00', 'Cancelada tarde', 'OPQ166');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(66, '2025-01-07', '08:00:00', '10:00:00', 'Confirmada', 'RST167');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(67, '2025-01-08', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'UVW168');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(68, '2025-01-09', '12:00:00', '14:00:00', 'Completada', 'XYZ169');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(69, '2025-01-10', '15:00:00', '17:00:00', 'No asiste', 'ABC170');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(70, '2025-01-11', '10:00:00', '12:00:00', 'Cancelada tarde', 'DEF171');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(71, '2025-01-12', '08:00:00', '10:00:00', 'Confirmada', 'GHI172');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(72, '2025-01-13', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'JKL173');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(73, '2025-01-14', '12:00:00', '14:00:00', 'Completada', 'MNO174');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(74, '2025-01-15', '15:00:00', '17:00:00', 'No asiste', 'PQR175');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(75, '2025-01-16', '10:00:00', '12:00:00', 'Cancelada tarde', 'STU176');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(76, '2025-01-17', '08:00:00', '10:00:00', 'Confirmada', 'VWX177');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(77, '2025-01-18', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'YZA178');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(78, '2025-01-19', '12:00:00', '14:00:00', 'Completada', 'BCD179');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(79, '2025-01-20', '15:00:00', '17:00:00', 'No asiste', 'EFG180');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(80, '2025-01-21', '10:00:00', '12:00:00', 'Cancelada tarde', 'HIJ181');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(81, '2025-01-22', '08:00:00', '10:00:00', 'Confirmada', 'LMN182');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(82, '2025-01-23', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'OPQ183');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(83, '2025-01-24', '12:00:00', '14:00:00', 'Completada', 'RST184');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(84, '2025-01-25', '15:00:00', '17:00:00', 'No asiste', 'UVW185');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(85, '2025-01-26', '10:00:00', '12:00:00', 'Cancelada tarde', 'XYZ186');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(86, '2025-01-27', '08:00:00', '10:00:00', 'Confirmada', 'ABC187');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(87, '2025-01-28', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'DEF188');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(88, '2025-01-29', '12:00:00', '14:00:00', 'Completada', 'GHI189');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(89, '2025-01-30', '15:00:00', '17:00:00', 'No asiste', 'JKL190');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(90, '2025-01-31', '10:00:00', '12:00:00', 'Cancelada tarde', 'MNO191');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(91, '2025-02-01', '08:00:00', '10:00:00', 'Confirmada', 'PQR192');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(92, '2025-02-02', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'STU193');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(93, '2025-02-03', '12:00:00', '14:00:00', 'Completada', 'VWX194');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(94, '2025-02-04', '15:00:00', '17:00:00', 'No asiste', 'YZA195');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(95, '2025-02-05', '10:00:00', '12:00:00', 'Cancelada tarde', 'BCD196');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(96, '2025-02-06', '08:00:00', '10:00:00', 'Confirmada', 'EFG197');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(97, '2025-02-07', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'HIJ198');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(98, '2025-02-08', '12:00:00', '14:00:00', 'Completada', 'LMN199');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(99, '2025-02-09', '15:00:00', '17:00:00', 'No asiste', 'OPQ200');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(100, '2025-02-10', '10:00:00', '12:00:00', 'Cancelada tarde', 'RST201');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(101, '2025-02-11', '08:00:00', '10:00:00', 'Confirmada', 'UVW202');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(102, '2025-02-12', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'XYZ203');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(103, '2025-02-13', '12:00:00', '14:00:00', 'Completada', 'ABC204');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(104, '2025-02-14', '15:00:00', '17:00:00', 'No asiste', 'DEF205');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(105, '2025-02-15', '10:00:00', '12:00:00', 'Cancelada tarde', 'GHI206');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(106, '2025-02-16', '08:00:00', '10:00:00', 'Confirmada', 'JKL207');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(107, '2025-02-17', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'MNO208');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(108, '2025-02-18', '12:00:00', '14:00:00', 'Completada', 'PQR209');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(109, '2025-02-19', '15:00:00', '17:00:00', 'No asiste', 'STU210');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(110, '2025-02-20', '10:00:00', '12:00:00', 'Cancelada tarde', 'VWX211');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(111, '2025-02-21', '08:00:00', '10:00:00', 'Confirmada', 'YZA212');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(112, '2025-02-22', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'BCD213');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(113, '2025-02-23', '12:00:00', '14:00:00', 'Completada', 'EFG214');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(114, '2025-02-24', '15:00:00', '17:00:00', 'No asiste', 'HIJ215');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(115, '2025-02-25', '10:00:00', '12:00:00', 'Cancelada tarde', 'LMN216');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(116, '2025-02-26', '08:00:00', '10:00:00', 'Confirmada', 'OPQ217');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(117, '2025-02-27', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'RST218');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(118, '2025-02-28', '12:00:00', '14:00:00', 'Completada', 'UVW219');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(119, '2025-03-01', '15:00:00', '17:00:00', 'No asiste', 'XYZ220');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(120, '2025-03-02', '10:00:00', '12:00:00', 'Cancelada tarde', 'ABC221');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(121, '2025-03-03', '08:00:00', '10:00:00', 'Confirmada', 'DEF222');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(122, '2025-03-04', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'GHI223');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(123, '2025-03-05', '12:00:00', '14:00:00', 'Completada', 'JKL224');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(124, '2025-03-06', '15:00:00', '17:00:00', 'No asiste', 'JKL226');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(125, '2025-03-07', '10:00:00', '12:00:00', 'Cancelada tarde', 'JKL227');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(126, '2025-03-08', '08:00:00', '10:00:00', 'Confirmada', 'JKL228');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(127, '2025-03-09', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'JKL229');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(128, '2025-03-10', '12:00:00', '14:00:00', 'Completada', 'JKL230');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(129, '2025-03-11', '15:00:00', '17:00:00', 'No asiste', 'JKL231');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(130, '2025-03-12', '10:00:00', '12:00:00', 'Cancelada tarde', 'JKL232');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(131, '2025-03-13', '08:00:00', '10:00:00', 'Confirmada', 'JKL233');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(132, '2025-03-14', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'JKL234');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(133, '2025-03-15', '12:00:00', '14:00:00', 'Completada', 'JKL235');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(134, '2025-03-16', '15:00:00', '17:00:00', 'No asiste', 'JKL236');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(135, '2025-03-17', '10:00:00', '12:00:00', 'Cancelada tarde', 'JKL237');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(136, '2025-03-18', '08:00:00', '10:00:00', 'Confirmada', 'JKL238');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(137, '2025-03-19', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'JKL239');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(138, '2025-03-20', '12:00:00', '14:00:00', 'Completada', 'JKL240');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(139, '2025-03-21', '15:00:00', '17:00:00', 'No asiste', 'JKL241');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(140, '2025-03-22', '10:00:00', '12:00:00', 'Cancelada tarde', 'JKL242');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(141, '2025-03-23', '08:00:00', '10:00:00', 'Confirmada', 'JKL243');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(142, '2025-03-24', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'JKL244');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(143, '2025-03-25', '12:00:00', '14:00:00', 'Completada', 'JKL245');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(144, '2025-03-26', '15:00:00', '17:00:00', 'No asiste', 'JKL246');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(145, '2025-03-27', '10:00:00', '12:00:00', 'Cancelada tarde', 'JKL247');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(146, '2025-03-28', '08:00:00', '10:00:00', 'Confirmada', 'JKL248');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(147, '2025-03-29', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'JKL249');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(148, '2025-03-30', '12:00:00', '14:00:00', 'Completada', 'JKL250');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(149, '2025-03-31', '15:00:00', '17:00:00', 'No asiste', 'JKL251');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(150, '2025-04-01', '10:00:00', '12:00:00', 'Cancelada tarde', 'JKL252');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(151, '2025-04-02', '08:00:00', '10:00:00', 'Confirmada', 'JKL253');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(152, '2025-04-03', '09:00:00', '11:00:00', 'Cancelada a tiempo', 'JKL254');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(153, '2025-04-04', '12:00:00', '14:00:00', 'Completada', 'JKL255');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(154, '2025-04-05', '15:00:00', '17:00:00', 'No asiste', 'JKL256');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(155, '2025-04-06', '10:00:00', '12:00:00', 'Cancelada tarde', 'JKL257');
INSERT INTO RESERVA (ID_Reserva, Fecha, Hora_Inicio, Hora_Fin, Estado, Matricula) VALUES(156, '2025-04-07', '08:00:00', '10:00:00', 'Confirmada', 'JKL258');

-- Inserciones para FACTURA
INSERT INTO FACTURA (ID_Factura, Fecha_Factura, Costo_Total) VALUES 
(2, '2024-01-01', 100.50),
(3, '2024-01-02', 120.75),
(4, '2024-01-03', 150.30),
(5, '2024-01-04', 175.00),
(6, '2024-01-05', 200.40),
(7, '2024-01-06', 125.60),
(8, '2024-01-07', 160.00),
(9, '2024-01-08', 210.75),
(10, '2024-01-09', 130.90),
(11, '2024-01-10', 145.20),
(12, '2024-01-11', 180.60),
(13, '2024-01-12', 195.30),
(14, '2024-01-13', 110.40),
(15, '2024-01-14', 170.50),
(16, '2024-01-15', 140.75),
(17, '2024-01-16', 220.80),
(18, '2024-01-17', 150.60),
(19, '2024-01-18', 180.30),
(20, '2024-01-19', 210.50),
(21, '2024-01-20', 130.80),
(22, '2024-01-21', 160.45),
(23, '2024-01-22', 140.70),
(24, '2024-01-23', 150.10),
(25, '2024-01-24', 190.40),
(26, '2024-01-25', 220.50),
(27, '2024-01-26', 120.60),
(28, '2024-01-27', 200.75),
(29, '2024-01-28', 175.30),
(30, '2024-01-29', 180.90),
(31, '2024-01-30', 195.10),
(32, '2024-01-31', 135.50),
(33, '2024-02-01', 210.20),
(34, '2024-02-02', 170.75),
(35, '2024-02-03', 140.90),
(36, '2024-02-04', 190.80),
(37, '2024-02-05', 160.20),
(38, '2024-02-06', 200.50),
(39, '2024-02-07', 125.40),
(40, '2024-02-08', 210.30),
(41, '2024-02-09', 130.60),
(42, '2024-02-10', 175.00),
(43, '2024-02-11', 150.90),
(44, '2024-02-12', 180.75),
(45, '2024-02-13', 195.20),
(46, '2024-02-14', 135.40),
(47, '2024-02-15', 150.60),
(48, '2024-02-16', 180.10),
(49, '2024-02-17', 160.45),
(50, '2024-02-18', 210.75),
(51, '2024-02-19', 120.90),
(52, '2024-02-20', 150.30),
(53, '2024-02-21', 190.20),
(54, '2024-02-22', 175.40),
(55, '2024-02-23', 135.60),
(56, '2024-02-24', 180.75),
(57, '2024-02-25', 200.10),
(58, '2024-02-26', 210.80),
(59, '2024-02-27', 160.45),
(60, '2024-02-28', 130.60),
(61, '2024-02-29', 145.20),
(62, '2024-03-01', 175.50),
(63, '2024-03-02', 120.80),
(64, '2024-03-03', 150.45),
(65, '2024-03-04', 195.00),
(66, '2024-03-05', 140.75),
(67, '2024-03-06', 200.60),
(68, '2024-03-07', 160.30),
(69, '2024-03-08', 130.90),
(70, '2024-03-09', 175.40),
(71, '2024-03-10', 140.20),
(72, '2024-03-11', 150.60),
(73, '2024-03-12', 210.90),
(74, '2024-03-13', 125.40),
(75, '2024-03-14', 170.20),
(76, '2024-03-15', 160.60),
(77, '2024-03-16', 200.30),
(78, '2024-03-17', 150.10),
(79, '2024-03-18', 180.75),
(80, '2024-03-19', 190.30),
(81, '2024-03-20', 130.20),
(82, '2024-03-21', 160.45),
(83, '2024-03-22', 210.00),
(84, '2024-03-23', 150.75),
(85, '2024-03-24', 180.20),
(86, '2024-03-25', 145.60),
(87, '2024-03-26', 190.40),
(88, '2024-03-27', 120.30),
(89, '2024-03-28', 170.80),
(90, '2024-03-29', 125.75),
(91, '2024-03-30', 150.10),
(92, '2024-03-31', 180.60),
(93, '2024-04-01', 190.30),
(94, '2024-04-02', 135.50),
(95, '2024-04-03', 210.60),
(96, '2024-04-04', 140.30),
(97, '2024-04-05', 160.80),
(98, '2024-04-06', 130.20),
(99, '2024-04-07', 180.90),
(100, '2024-04-08', 195.20),
(101, '2024-04-09', 145.75),
(102, '2024-04-10', 125.40),
(103, '2024-04-11', 170.30),
(104, '2024-04-12', 140.80),
(105, '2024-04-13', 210.20),
(106, '2024-04-14', 135.60),
(107, '2024-04-15', 180.40),
(108, '2024-04-16', 160.50),
(109, '2024-04-17', 200.10),
(110, '2024-04-18', 150.30),
(111, '2024-04-19', 130.70),
(112, '2024-04-20', 160.75),
(113, '2024-04-21', 190.20),
(114, '2024-04-22', 180.10),
(115, '2024-04-23', 145.30),
(116, '2024-04-24', 210.50),
(117, '2024-04-25', 175.90),
(118, '2024-04-26', 135.20),
(119, '2024-04-27', 140.80),
(120, '2024-04-28', 150.10),
(121, '2024-04-29', 160.40),
(122, '2024-04-30', 130.90),
(123, '2024-05-01', 190.60),
(124, '2024-05-02', 180.50),
(125, '2024-05-03', 175.30),
(126, '2024-05-04', 150.75),
(127, '2024-05-05', 120.60),
(128, '2024-05-06', 200.40),
(129, '2024-05-07', 140.50),
(130, '2024-05-08', 210.10),
(131, '2024-05-09', 190.60),
(132, '2024-05-10', 125.50),
(133, '2024-05-11', 130.90),
(134, '2024-05-12', 160.20),
(135, '2024-05-13', 180.30),
(136, '2024-05-14', 120.60),
(137, '2024-05-15', 210.75),
(138, '2024-05-16', 135.10),
(139, '2024-05-17', 170.80),
(140, '2024-05-18', 150.40),
(141, '2024-05-19', 140.75),
(142, '2024-05-20', 195.30),
(143, '2024-05-21', 160.40),
(144, '2024-05-22', 190.60),
(145, '2024-05-23', 210.20),
(146, '2024-05-24', 140.10),
(147, '2024-05-25', 150.90),
(148, '2024-05-26', 180.60),
(149, '2024-05-27', 130.80),
(150, '2024-05-28', 195.50);


-- Inserciones para SERVICIO
INSERT INTO SERVICIO (ID_Servicio) VALUES
(1),
(2),
(3),
(4),
(5),
(6),
(7),
(8),
(9),
(10),
(11),
(12),
(16),
(17),
(18),
(19),
(20),
(21),
(22),
(23),
(24),
(25),
(26),
(27),
(28),
(29),
(30),
(31),
(32),
(33),
(34),
(35),
(36),
(37),
(38),
(39),
(40),
(41),
(42),
(43),
(44),
(45),
(46),
(47),
(48),
(49),
(50),
(51),
(52),
(53),
(54),
(55),
(56),
(57),
(58),
(59),
(60),
(61),
(62),
(63),
(64),
(65),
(66),
(67),
(68),
(69),
(70),
(71),
(72),
(73),
(74),
(75),
(76),
(77),
(78),
(79),
(80),
(81),
(82),
(83),
(84),
(85),
(86),
(87),
(88),
(89),
(90),
(91),
(92),
(93),
(94),
(95),
(96),
(97),
(98),
(99),
(100),
(101),
(102),
(103),
(104),
(105);

-- Inserciones para BALANCEO_ALINEACION
INSERT INTO BALANCEO_ALINEACION (ID_Servicio, Precio, Tipo) VALUES(1, 200.00, 'Montaje neumático');
INSERT INTO BALANCEO_ALINEACION (ID_Servicio, Precio, Tipo) VALUES(2, 1850.00, 'Alineación 1 tren desde R17');
INSERT INTO BALANCEO_ALINEACION (ID_Servicio, Precio, Tipo) VALUES(3, 1650.00, 'Alineación');
INSERT INTO BALANCEO_ALINEACION (ID_Servicio, Precio, Tipo) VALUES(4, 385.00, 'Balanceo auto + válvula');
INSERT INTO BALANCEO_ALINEACION (ID_Servicio, Precio, Tipo) VALUES(5, 2475.00, 'Alineación 2 trenes');
INSERT INTO BALANCEO_ALINEACION (ID_Servicio, Precio, Tipo) VALUES(6, 3510.00, 'Pack alineación y 4 balanceos para camioneta + válvulas');
INSERT INTO BALANCEO_ALINEACION (ID_Servicio, Precio, Tipo) VALUES(7, 415.00, 'Balanceo de camioneta + válvula');

-- Inserciones para LAVADERO
INSERT INTO LAVADERO (ID_Servicio, Tipo_vehiculo, Precio) VALUES(8, 'Moto', 200.00);
INSERT INTO LAVADERO (ID_Servicio, Tipo_vehiculo, Precio) VALUES(9, 'Auto', 400.00);
INSERT INTO LAVADERO (ID_Servicio, Tipo_vehiculo, Precio) VALUES(10, 'Camioneta', 460.00);
INSERT INTO LAVADERO (ID_Servicio, Tipo_vehiculo, Precio) VALUES(11, 'Pequeños camiones', 500.00);
INSERT INTO LAVADERO (ID_Servicio, Tipo_vehiculo, Precio) VALUES(12, 'Pequeños utilitarios', 500.00);


-- Inserciones para NEUMATICO
INSERT INTO NEUMATICO (ID_Neumatico, Precio, Marca, Stock) VALUES
INSERT INTO NEUMATICO (ID_Neumatico, Precio, Marca, Stock) VALUES(1, 120.00, 'Michelin', 20);
INSERT INTO NEUMATICO (ID_Neumatico, Precio, Marca, Stock) VALUES(2, 150.00, 'Bridgestone', 15);
INSERT INTO NEUMATICO (ID_Neumatico, Precio, Marca, Stock) VALUES(3, 130.00, 'Pirelli', 10);

-- Inserciones para PARKING

INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(16, 1, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(17, 2, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(18, 3, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(19, 4, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(20, 5, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(21, 6, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(22, 7, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(23, 8, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(24, 9, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(25, 10, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(26, 11, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(27, 12, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(28, 13, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(29, 14, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(30, 15, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(31, 16, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(32, 17, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(33, 18, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(34, 19, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(35, 20, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(36, 21, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(37, 22, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(38, 23, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(39, 24, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(40, 25, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(41, 26, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(42, 27, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(43, 28, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(44, 29, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(45, 30, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(46, 31, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(47, 32, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(48, 33, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(49, 34, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(50, 35, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(51, 36, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(52, 37, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(53, 38, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(54, 39, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(55, 40, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(56, 41, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(57, 42, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(58, 43, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(59, 44, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(60, 45, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(61, 46, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(62, 47, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(63, 48, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(64, 49, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(65, 50, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(66, 51, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(67, 52, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(68, 53, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(69, 54, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(70, 55, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(71, 56, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(72, 57, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(73, 58, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(74, 59, '1 plaza de auto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(75, 60, '1 plaza de auto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(76, 61, '1 plaza de moto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(77, 62, '1 plaza de moto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(78, 63, '1 plaza de moto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(79, 64, '1 plaza de moto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(80, 65, '1 plaza de moto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(81, 66, '1 plaza de moto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(82, 67, '1 plaza de moto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(83, 68, '1 plaza de moto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(84, 69, '1 plaza de moto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(85, 70, '1 plaza de moto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(86, 71, '1 plaza de moto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(87, 72, '1 plaza de moto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(88, 73, '1 plaza de moto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(89, 74, '1 plaza de moto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(90, 75, '1 plaza de moto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(91, 76, '1 plaza de moto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(92, 77, '1 plaza de moto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(93, 78, '1 plaza de moto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(94, 79, '1 plaza de moto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(95, 80, '1 plaza de moto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(96, 81, '1 plaza de moto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(97, 82, '1 plaza de moto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(98, 83, '1 plaza de moto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(99, 84, '1 plaza de moto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(100, 85, '1 plaza de moto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(101, 86, '1 plaza de moto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(102, 87, '1 plaza de moto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(103, 88, '1 plaza de moto', 'Ocupado');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(104, 89, '1 plaza de moto', 'Disponible');
INSERT INTO PARKING (ID_Servicio, ID_Plaza, Tipo_plaza, Estado_plaza) VALUES(105, 90, '1 plaza de moto', 'Disponible');

-- Inserciones para COSTO_PARKING
INSERT INTO COSTO_PARKING (Tipo_vehiculo, Costo_por_hora) VALUES('Moto', 50.00);
INSERT INTO COSTO_PARKING (Tipo_vehiculo, Costo_por_hora) VALUES('Auto', 100.00);
INSERT INTO COSTO_PARKING (Tipo_vehiculo, Costo_por_hora) VALUES('Camioneta', 120.00);
INSERT INTO COSTO_PARKING (Tipo_vehiculo, Costo_por_hora) VALUES('Pequeños Camiones', 150.00);
INSERT INTO COSTO_PARKING (Tipo_vehiculo, Costo_por_hora) VALUES('Pequeños Utilitarios', 150.00);

-- Inserciones para EMPLEADO

INSERT INTO EMPLEADO (CI, Nombre, Apellido, Celular, Fecha_Nac, Contraseña, Fecha_Ingreso, Tipo) VALUES
(21000001, 'Carlos', 'González', 91234567, '1980-02-14', MD5('contraseña123'), '2023-03-10', 'Gerente');

INSERT INTO EMPLEADO (CI, Nombre, Apellido, Celular, Fecha_Nac, Contraseña, Fecha_Ingreso, Tipo) VALUES
(22000002, 'Laura', 'Muñoz', 92345678, '1991-06-22', MD5('cajero987'), '2023-04-15', 'Cajero');

INSERT INTO EMPLEADO (CI, Nombre, Apellido, Celular, Fecha_Nac, Contraseña, Fecha_Ingreso, Tipo) VALUES
(23000003, 'Antonio', 'Ramírez', 93456789, '1975-08-12', MD5('lavadero123'), '2021-06-30', 'Jefe de servicio de lavadero');

INSERT INTO EMPLEADO (CI, Nombre, Apellido, Celular, Fecha_Nac, Contraseña, Fecha_Ingreso, Tipo) VALUES
(24000004, 'Elena', 'Hernández', 94567890, '1985-09-03', MD5('alineacion321'), '2024-02-20', 'Jefe de servicio de balanceo y alineación');

INSERT INTO EMPLEADO (CI, Nombre, Apellido, Celular, Fecha_Nac, Contraseña, Fecha_Ingreso, Tipo) VALUES
(25000005, 'Marcos', 'Ortiz', 95678901, '1992-12-10', MD5('respaldos456'), '2022-07-18', 'Operador de respaldos');

INSERT INTO EMPLEADO (CI, Nombre, Apellido, Celular, Fecha_Nac, Contraseña, Fecha_Ingreso, Tipo) VALUES
(26000006, 'Claudia', 'Reyes', 96789012, '1990-11-15', MD5('lavadero789'), '2024-03-10', 'Ejecutivo de servicio de lavadero');

INSERT INTO EMPLEADO (CI, Nombre, Apellido, Celular, Fecha_Nac, Contraseña, Fecha_Ingreso, Tipo) VALUES
(27000007, 'Luis', 'Flores', 97890123, '1983-01-22', MD5('balanceo654'), '2023-09-25', 'Ejecutivo de servicio de balanceo y alineación');

INSERT INTO EMPLEADO (CI, Nombre, Apellido, Celular, Fecha_Nac, Contraseña, Fecha_Ingreso, Tipo) VALUES
(28000008, 'Ana', 'García', 98901234, '1987-05-07', MD5('neumaticos159'), '2022-12-05', 'Ejecutivo de servicio de neumáticos');


-- Consulta 1: Realizar una consulta distinta por cada servicio que obtenga todos los precios disponibles.

SELECT Precio, Tipo
FROM BALANCEO_ALINEACION;

SELECT Precio, Tipo_vehiculo
FROM LAVADERO;

SELECT Precio, Marca
FROM NEUMATICO;

SELECT Costo_por_hora, Tipo_vehiculo
FROM COSTO_PARKING;

-- Consulta 2: Obtener las facturas realizadas en un período de tiempo mostrando para cada cliente/vehículo cantidad de facturas, mayor costo total y promedio del costo total.

SELECT 
    C.Nombre AS Nombre_Cliente, 
    C.Apellido AS Apellido_Cliente,
    V.Matricula,
    COUNT(F.ID_Factura) AS Cantidad_Facturas,
    MAX(F.Costo_Total) AS Mayor_Costo_Total,
    AVG(F.Costo_Total) AS Promedio_Costo_Total
FROM 
    FACTURA F
JOIN 
    CORRESPONDE C1 ON F.ID_Factura = C1.ID_Factura
JOIN 
    SERVICIO S ON C1.ID_Servicio = S.ID_Servicio
JOIN 
    RESERVA R ON S.ID_Servicio = R.ID_Reserva
JOIN 
    VEHICULO V ON R.Matricula = V.Matricula
JOIN 
    CLIENTE C ON V.CI_Cliente = C.CI_Cliente
WHERE 
    F.Fecha_Factura BETWEEN '2024-01-01' AND '2024-12-31' 
GROUP BY 
    C.Nombre, C.Apellido, V.Matricula;

-- Consulta 3: Mostrar 2 consultas implementadas en la aplicación informática preferentemente para obtener datos estadísticos. Para estas consultas se piden los siguientes requerimientos:
-- Las consultas deben incluir al menos 2 tablas combinadas.
-- Debe incluir una explicación de su funcionamiento y para que se utiliza en el sistema.
-- Mostrar una captura de los datos obtenidos con el juego de datos de prueba solicitado que incluya la base de datos.

--Esta consulta calcula la cantidad de reservas agrupadas por su estado. Lo cual es útil para el sistema para monitorear el comportamiento de las reservas, permitiendo ver cuántas reservas son canceladas, completadas, canceladas a tiempo, et. Proporcionando así información valiosa para el manejo del servicio.
SELECT 
    Estado, 
    COUNT(ID_Reserva) AS Cantidad_Reservas
FROM 
    RESERVA
GROUP BY 
    Estado;

--La consulta brinda información detallada de las reservas por cliente y vehículo en un rango de fechas, agrupando los datos y obteniendo la fecha de la última reserva . Este dato es útil para identificar clientes que no han reservado recientemente, permitiéndoles enviarles correos recordatorios, ofertas o descuentos, con el fin de incentivar su retorno y mejorar la fidelización. La consulta no solo gestiona reservas, sino que también apoya estrategias de marketing y retención de clientes.
SELECT 
    CL.Nombre AS Nombre_Cliente,
    CL.Apellido AS Apellido_Cliente,
    V.Matricula AS Matricula_Vehiculo,
    COUNT(R.ID_Reserva) AS Cantidad_Reservas,
    MAX(R.Fecha) AS Ultima_Reserva
FROM 
    RESERVA R
JOIN 
    VEHICULO V ON R.Matricula = V.Matricula
JOIN 
    CLIENTE CL ON V.CI_Cliente = CL.CI_Cliente
WHERE 
    R.Fecha BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY 
    CL.Nombre, CL.Apellido, V.Matricula;




-- Crear usuario Gerente 
CREATE USER 'gerente'@'localhost' IDENTIFIED BY '123456';
GRANT SELECT, SHOW VIEW, INSERT, UPDATE, DELETE, CREATE USER, GRANT OPTION ON proyecto.* TO 'gerente'@'localhost';


-- Crear usuario Jefe de Servicio 
CREATE VIEW proyecto.EJECUTIVOS_SERVICIO AS
SELECT * FROM proyecto.EMPLEADO
WHERE Tipo IN ('Ejecutivo de servicio de lavadero', 'Ejecutivo de servicio de balanceo y alineación', 'Ejecutivo de servicio de neumáticos');

CREATE USER 'jefe_servicio'@'localhost' IDENTIFIED BY '78910';
GRANT SELECT, SHOW VIEW ON proyecto.* TO 'jefe_servicio'@'localhost';
GRANT SELECT, INSERT ON proyecto.* TO 'jefe_servicio'@'localhost';
GRANT SELECT, UPDATE ON proyecto.CLIENTE TO 'jefe_servicio'@'localhost';
GRANT SELECT, UPDATE, DELETE ON proyecto.EJECUTIVOS_SERVICIO TO 'jefe_servicio'@'localhost';

-- Crear usuario Ejecutivo de Servicio 
CREATE USER 'ejecutivo_servicio'@'localhost' IDENTIFIED BY '111213';
GRANT SELECT, SHOW VIEW ON proyecto.* TO 'ejecutivo_servicio'@'localhost';
GRANT SELECT, INSERT ON proyecto.* TO 'ejecutivo_servicio'@'localhost';
GRANT SELECT, UPDATE ON proyecto.CLIENTE TO 'ejecutivo_servicio'@'localhost';

-- Crear usuario Cajero 
CREATE USER 'cajero'@'localhost' IDENTIFIED BY '141516';
GRANT SELECT, SHOW VIEW ON proyecto.* TO 'cajero'@'localhost';

-- Crear usuario Operador de Respaldo 
CREATE USER 'operador_respaldo'@'localhost' IDENTIFIED BY '171819';
GRANT SELECT, LOCK TABLES, SHOW VIEW ON proyecto.* TO 'operador_respaldo'@'localhost';

