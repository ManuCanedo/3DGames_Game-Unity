function metodoGET() {
  document.getElementById("urlencoded").checked = true;
  document.getElementById("multipart").checked = false;
  document.getElementById("multipart").disabled = true;
}

function log(nombre) {
  checktexto(nombre.value);
}

function metodoPOST() {
  document.getElementById("multipart").disabled = false;
}

function checkall(source) {
  var checkboxes = document.querySelectorAll('input[type="checkbox"]');
  for (var i = 0; i < checkboxes.length; i++) {
    if (checkboxes[i] != source) checkboxes[i].checked = source.checked;
  }
}

function checktexto(texto) {
  if (texto.value.trim().length != 0 && texto.value.match(/[0-9]/)) {
    alert("Nombre/Apellidos no válidos"); //Contiene números
    return false;
  }
  return true;
}

function checkmail(email) {
  if (email.value.trim().length == 0) {
    return true;
  }
  tuEmail = email.value.toString();
  patron = /^[\w]+@{1}[\w]+\.+[a-z]{2,3}$/;
  respuesta = patron.test(tuEmail);
  if (!respuesta) {
    alert("Email no válido");
    return false;
  }
  return true;
}

function checkpass() {
  if (
    document.getElementById("pass1").value !=
    document.getElementById("pass2").value
  ) {
    alert("Las contraseñas no coinciden. Por favor, vuelva a escribirlas");
    document.getElementById("pass1").value = "";
    document.getElementById("pass2").value = "";
    return false;
  }
  return true;
}

function validarFormatoFecha(campo) {
  var RegExPattern = /^\d{1,2}\/\d{1,2}\/\d{2,4}$/;
  if (campo.match(RegExPattern) && campo != "") {
    return true;
  } else {
    return false;
  }
}

function existeFecha(fecha) {
  var fechaf = fecha.split("/");
  var day = fechaf[0];
  var month = fechaf[1];
  var year = fechaf[2];
  var date = new Date(year, month, "0");
  if (day - 0 > date.getDate() - 0) {
    return false;
  }
  return true;
}

function validarFecha(fechaIntroducida) {
  if (fechaIntroducida.value.trim().length == 0) {
    return true;
  }
  var fecha = fechaIntroducida.value.toString();
  if (validarFormatoFecha(fecha)) {
    if (existeFecha(fecha)) {
      return true;
    } else {
      alert("La fecha introducida no existe.");
      return false;
    }
  } else {
    alert("El formato de la fecha es incorrecto.");
    return false;
  }
}

function fechayhora() {
  var date = new Date();
  var horaSistema = "";
  if (date.getMinutes() < 10) {
    horaSistema =
      "La hora del sistema es: " + date.getHours() + ":0" + date.getMinutes();
  } else {
    horaSistema =
      "La hora del sistema es: " + date.getHours() + ":" + date.getMinutes();
  }
  document.getElementById("horaEnvio").value = horaSistema;
}

function navegador() {
  var navegador = navigator.userAgent;
  document.getElementById("navegador").value = navegador;
}

function metodoEnvio() {
  //Check método de envío
  if (document.getElementById("sendget").checked) {
    document.getElementById("formulario").method = "GET";
    checkedGET = true;
  }

  if (document.getElementById("sendpost").checked) {
    document.getElementById("formulario").method = "POST";
  }

  //Check codificación de envío
  if (document.getElementById("urlencoded").checked) {
    document.getElementById("formulario").enctype =
      "application/x-www-form-urlencoded";
  }

  if (document.getElementById("multipart").checked) {
    document.getElementById("formulario").enctype = "multipart/form-data";
  }

  //Check dirección de envío
  if (document.getElementById("phpinfo").checked) {
    document.getElementById("formulario").action = "./phpinfo.php";
  }

  if (document.getElementById("myphp").checked) {
    document.getElementById("formulario").action = "./p1.php";
  }
}

function enviarFormulario() {
  let flag = true;

  if (!document.getElementById("nombre").firstChild.value.trim().length == 0 && typeof document.getElementById("nombre") !== "undefined") {
    flag = flag && checktexto(document.getElementById("nombre").firstChild);
  } else {
      document.getElementById("nombre").value = "";
  }

  if (
    !document.getElementById("apellidos").firstChild.value.trim().length == 0 && typeof document.getElementById("apellidos") !== "undefined"
  ) {
    flag =
      flag &&
      checktexto(document.getElementById("apellidos").firstChild);
  }
    else {
      document.getElementById("apellidos").value = "";
  }

    if (
    !document.getElementById("fecha").firstChild.value.trim().length == 0 && typeof document.getElementById("fecha") !== "undefined"
  ) {
        flag = flag && validarFecha(document.getElementById("fecha").firstChild); 
  }
    else {
      document.getElementById("fecha").value = "";
  }
    if (
    !document.getElementById("email").firstChild.value.trim().length == 0 && typeof document.getElementById("email") !== "undefined"
  ) {
        flag = flag && checkmail(document.getElementById("email").firstChild);
  }
    else {
      document.getElementById("email").value = "";
  }

    flag = flag && checkpass(document.getElementById("pass1").firstChild);


  fechayhora();
  navegador();
  metodoEnvio();
  return flag;
}

// console.log("Fin de script");
