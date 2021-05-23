<!DOCTYPE HTML>
<html lang="es-ES">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link href="p1.css" rel="stylesheet" type="text/css"/>
        <title>Filmafinidad</title>
    </head>

    <body>
        <h1>Datos formulario</h1>

        <table>
            <tr>
                <th>Nombre</th>
                <td><?php echo htmlspecialchars($_REQUEST['nombre']) ?></td>
            </tr>
            <tr>
                <th>Apellidos</th>
                <td> <?php echo htmlspecialchars($_REQUEST['apellidos']) ?></td>
            </tr>
            <tr>
                <th>Fecha nacimiento</th>
                <td> <?php echo htmlspecialchars($_REQUEST['fechaIntroducida']) ?> </td>
            </tr>
            <tr>
                <th>G&eacute;nero</th>
                <td><?php echo htmlspecialchars(array_key_exists('gender', $_REQUEST)? $_REQUEST['gender']:'') ?></td>
            </tr>
            <tr>
                <th>Archivo</th>
                <td> <?php echo htmlspecialchars($_REQUEST['archivo']) ?> </td>
            </tr>
            <tr>
                <th>Correo Electrónico</th>
                <td><?php echo htmlspecialchars($_REQUEST['email']) ?></td> 
            </tr>
            <tr>
                <th>Contraseña</th>
                <td> <?php echo htmlspecialchars($_REQUEST['pass1']) ?> </td>
            </tr>

            <tr>
                <th>Acci&oacute;n</th>
                <td> <?php echo htmlspecialchars(array_key_exists('cbiaccion', $_REQUEST)? $_REQUEST['cbiaccion']:'') ?> </td>
            </tr>
            <tr>
                <th>Comedia</th>
                <td> <?php echo htmlspecialchars(array_key_exists('cbicomedia', $_REQUEST)? $_REQUEST['cbicomedia']:'') ?> </td>
            </tr>
            <tr>
                <th>Drama</th>
                <td> <?php echo htmlspecialchars(array_key_exists('cbidrama', $_REQUEST)? $_REQUEST['cbidrama']:'') ?> </td>
            </tr>
            <tr>
                <th>Terror</th>
                <td> <?php echo htmlspecialchars(array_key_exists('cbiterror', $_REQUEST)? $_REQUEST['cbiterror']:'') ?> </td>
            </tr>
            <tr>
                <th>Suspense</th>
                <td> <?php echo htmlspecialchars(array_key_exists('cbisuspense', $_REQUEST)? $_REQUEST['cbisuspense']:'') ?> </td>
            </tr>
            <tr>
                <th>Animaci&oacute;n</th>
                <td> <?php echo htmlspecialchars(array_key_exists('cbianimacion', $_REQUEST)? $_REQUEST['cbianimacion']:'') ?> </td>
            </tr>
            <tr>
                <th>Frecuencia de contacto</th>
                <td> <?php echo htmlspecialchars($_REQUEST['frecuencia']) ?> </td>
            </tr>
            <tr>
                <th>Comentario</th>
                <td> <?php echo htmlspecialchars($_REQUEST['comentario']) ?> </td>
            </tr>
        </table>
        
        <h1>Variables de entorno</h1>
        <table>
            <tr>
                <th>IP del Servidor</th>
                <td><?php echo htmlspecialchars($_SERVER['SERVER_ADDR']) ?></td>
            </tr>
            <tr>
                <th>Nombre del Servidor</th>
                <td><?php echo htmlspecialchars($_SERVER['SERVER_NAME']) ?></td>
            </tr>
            <tr>
                <th>Puerto</th>
                <td><?php echo htmlspecialchars($_SERVER['SERVER_PORT']) ?></td>
            </tr>
            <tr>
                <th>IP del Cliente</th>
                <td><?php echo htmlspecialchars($_SERVER['REMOTE_ADDR']) ?></td>
            </tr>
            <tr>
                <th>Software del Servidor</th>
                <td><?php echo htmlspecialchars($_SERVER['SERVER_SOFTWARE']) ?></td>
            </tr>
            <tr>
                <th>Codificación</th>
                <td><?php echo htmlspecialchars($_REQUEST['codif']) ?></td>
            </tr>
            <tr>
                <th>Método de envío</th>
                <td><?php echo htmlspecialchars($_REQUEST['metodo']) ?></td>
            </tr>
            <tr>
                <th>Hora de envío</th>
                <td><?php echo htmlspecialchars($_REQUEST['horaEnvio']) ?></td>
            </tr>
            <tr>
                <th>Navegador del usuario</th>
                <td><?php echo htmlspecialchars($_REQUEST['navegador']) ?></td>
            </tr>
        </table>
    </body>
</html>