package p2;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;
import java.net.*;
import javax.xml.parsers.*;
import javax.xml.xpath.*;
import org.w3c.dom.*;
import org.xml.sax.*;
import org.xml.sax.helpers.*;

@SuppressWarnings("serial")
public class Sint200P2 extends HttpServlet {

	/////////////////////////////////////////////////////////////////// STATIC
	/////////////////////////////////////////////////////////////////// VARIABLES

	final static private String rutaIML = "http://gssi.det.uvigo.es/users/agil/public_html/SINT/18-19/";
	final static private String rutaIMLini = rutaIML + "iml2001.xml";
	final static private String pass = "z3ny4tt46k";

	static private ArrayList<Document> documents = new ArrayList<Document>();
	static private ArrayList<String> processedIML = new ArrayList<String>();
	static private ArrayList<String> newIML = new ArrayList<String>();

	/////////////////////////////////////////////////////////////////// GLOBAL
	/////////////////////////////////////////////////////////////////// VARIABLES

	public boolean error = false;
	public Map<String, String> warnings = new HashMap<String, String>();
	public Map<String, String> errors = new HashMap<String, String>();
	public Map<String, String> fatalerrors = new HashMap<String, String>();

	/////////////////////////////////////////////////////////////////// PRIMARY
	/////////////////////////////////////////////////////////////////// METHODS

	public void init(ServletConfig conf) {

		try {
			super.init(conf);
		} catch (ServletException e) {
			System.err.println("ServletException when trying to call super builder");
		}

		ServletContext servCont = conf.getServletContext();
		String path = servCont.getRealPath("/p2/iml.xsd");
		File documento = new File(path);
		XPathFactory xPathfactory = XPathFactory.newInstance();
		XPath xpath = xPathfactory.newXPath();

		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		DocumentBuilder db = null;
		dbf.setNamespaceAware(true);
		dbf.setValidating(true);
		dbf.setAttribute("http://java.sun.com/xml/jaxp/properties/schemaLanguage", "http://www.w3.org/2001/XMLSchema");
		dbf.setAttribute("http://java.sun.com/xml/jaxp/properties/schemaSource", documento);
		try {
			db = dbf.newDocumentBuilder();
		} catch (ParserConfigurationException pce) {
			System.err.println("ParserConfigurationException when creating Document Builder");
		}

		ErrorHandler eh = new ErrorHandler();
		Document doc = null;
		try {
			db.setErrorHandler(eh);
			doc = db.parse(new URL(rutaIMLini).openStream());

		} catch (MalformedURLException mfe) {
			System.err.println("MalformedURLException when parsing initial IML");
		} catch (SAXException e) {
			System.err.println("SAXException when parsing initial IML, error variable set to 'true'");
			error = true;
		} catch (IOException ioe) {
			System.err.println("IOException when parsing initial IML");
		}

		documents.add(doc);
		processedIML.add(rutaIMLini);
		buscarIMLs(doc, xpath);

		for (int i = 0; i < newIML.size(); i++) {
			if (!processedIML.contains(newIML.get(i))) {
				try {
					doc = db.parse(rutaIML + newIML.get(i));
				} catch (SAXException e) {
					e.printStackTrace();
					error = true;
				} catch (IOException ioe) {
					ioe.printStackTrace();
				}
				if (!error) {
					documents.add(doc);
					buscarIMLs(doc, xpath);
				}
				error = false;
				processedIML.add(newIML.get(i));
			}
		}
	}

	public void doGet(HttpServletRequest req, HttpServletResponse res) {

		res.setContentType("text/html");
		res.setCharacterEncoding("utf-8");
		PrintWriter out = null;
		try {
			out = res.getWriter();
		} catch (IOException e) {
			System.err.println("IOException when trying to get writer");
		}

		String p = req.getParameter("p");
		String pfase = req.getParameter("pfase");
		String modo = req.getParameter("auto");
		String panio;
		String pidd;
		String pidc;

		if (modo == null)
		modo = "no";
		if (pfase == null)
		pfase = "01";

		if (p != null) {
			if (p.equalsIgnoreCase(pass)) {
				switch (pfase) {
					case "01":
					print01(out, res, modo, p);
					break;
					case "02":
					print02(out, res, modo, p);
					break;
					case "11":
					print11(out, res, modo, p);
					break;
					case "12":
					panio = req.getParameter("panio");
					if (panio != null) {
						print12(out, res, modo, panio, p);
					} else {
						printError(out, res, modo, "no param:panio", p);
					}
					break;
					case "13":
					panio = req.getParameter("panio");
					pidd = req.getParameter("pidd");
					if (panio != null) {
						if (pidd != null) {
							print13(out, res, modo, panio, pidd, p);
						} else {
							printError(out, res, modo, "no param:pidd", p);
						}
					} else {
						printError(out, res, modo, "no param:panio", p);
					}
					break;
					case "14":
					panio = req.getParameter("panio");
					pidd = req.getParameter("pidd");
					pidc = req.getParameter("pidc");
					if (panio != null) {
						if (pidd != null) {
							if (pidc != null) {
								print14(out, res, modo, panio, pidd, pidc, p);
							} else {
								printError(out, res, modo, "no param:pidc", p);
							}
						} else {
							printError(out, res, modo, "no param:pidd", p);
						}
					} else {
						printError(out, res, modo, "no param:panio", p);
					}
					break;
					default:
					break;
				}
			} else {
				printError(out, res, modo, "bad passwd", p);
			}
		} else {
			printError(out, res, modo, "no passwd", p);
		}
	}

	private void buscarIMLs(Document doc, XPath xpath) {

		Element raiz;
		try {
			for (int j = 0; j < documents.size(); j++) {
				raiz = documents.get(j).getDocumentElement();
				String busqueda = "//IML";
				NodeList nl = (NodeList) xpath.evaluate(busqueda, raiz, XPathConstants.NODESET);
				String nombreURL;
				for (int k = 0; k < nl.getLength(); k++) {
					nombreURL = nl.item(k).getFirstChild().getNodeValue();
					if (!newIML.contains(nombreURL) && !nombreURL.equals(rutaIMLini)
					&& !nombreURL.equals("iml2001.xml")) {
						newIML.add(nombreURL);
					}
				}
			}
		} catch (XPathExpressionException xpe) {
			xpe.printStackTrace();
		}

	}

	/////////////////////////////////////////////////////////////////// PROCESSING
	/////////////////////////////////////////////////////////////////// METHODS

	private ArrayList<String> getC1Anios() {

		XPathFactory xpathFactory = XPathFactory.newInstance();
		XPath xpath = xpathFactory.newXPath();
		ArrayList<String> anios = new ArrayList<String>();

		for (int k = 0; k < documents.size(); k++) {
			Element raiz = documents.get(k).getDocumentElement();
			try {
				NodeList nl = (NodeList) xpath.evaluate("/Songs/Anio", raiz, XPathConstants.NODESET);

				for (int i = 0; i < nl.getLength(); i++) {
					anios.add(nl.item(i).getTextContent());
				}
			} catch (XPathExpressionException e) {
				e.printStackTrace();
			}
		}
		Collections.sort(anios, new Comparator<String>() {
			public int compare(String s1, String s2) {
				return s1.compareTo(s2);
			}
		});
		return anios;
	}

	private ArrayList<Disco> getC1Discos(String anio) throws XPathExpressionException {

		XPathFactory xpathFactory = XPathFactory.newInstance();
		XPath xpath = xpathFactory.newXPath();
		ArrayList<Disco> discos = new ArrayList<Disco>();

		for (int k = 0; k < documents.size(); k++) {
			Element raiz = documents.get(k).getDocumentElement();
			try {
				NodeList paises = (NodeList) xpath.evaluate("/Songs[Anio='" + anio + "']/Pais", raiz,
				XPathConstants.NODESET);

				for (int i = 0; i < paises.getLength(); i++) {
					String pais = (String) xpath.evaluate("@pais", paises.item(i), XPathConstants.STRING);
					String lang = (String) xpath.evaluate("@lang", paises.item(i), XPathConstants.STRING);

					NodeList disk_pais = (NodeList) xpath.evaluate(
					"/Songs[Anio='" + anio + "']/Pais[@pais='" + pais + "']/Disco", raiz,
					XPathConstants.NODESET);

					for (int j = 0; j < disk_pais.getLength(); j++) {
						String titulo = (String) xpath.evaluate("Titulo", disk_pais.item(j), XPathConstants.STRING);
						String interprete = (String) xpath.evaluate("Interprete", disk_pais.item(j),
						XPathConstants.STRING);
						String idd = (String) xpath.evaluate("@idd", disk_pais.item(j), XPathConstants.STRING);
						String langs = (String) xpath.evaluate("@langs", disk_pais.item(j), XPathConstants.STRING);
						if (langs.length() < 2) {
							langs = lang;
						}
						Disco disk = new Disco(titulo,idd,interprete,langs);
						discos.add(disk);
					}
				}
			} catch (XPathExpressionException e) {
				e.printStackTrace();
			}
		}

		Collections.sort(discos, new Comparator<Disco>() {

			public int compare(Disco s1, Disco s2) {
				String s1_interprete = s1.getInterprete();
				String s2_interprete = s2.getInterprete();
				String s1_titulo = s1.getTitulo();
				String s2_titulo = s2.getTitulo();

				if (s1_interprete.equalsIgnoreCase(s2_interprete)) {
					return s1_titulo.compareTo(s2_titulo);
				} else {
					return s1_interprete.compareTo(s2_interprete);
				}

			}
		});
		return discos;

	}

	private ArrayList<Cancion> getC1Canciones(String anio, String idd) throws XPathExpressionException {
		XPathFactory xpathFactory = XPathFactory.newInstance();
		XPath xpath = xpathFactory.newXPath();
		ArrayList<Cancion> canciones = new ArrayList<Cancion>();

		for (int k = 0; k < documents.size(); k++) {
			Element raiz = documents.get(k).getDocumentElement();
			try {
				NodeList nl_cancion = (NodeList) xpath.evaluate(
				"/Songs[Anio='" + anio + "']/Pais/Disco[@idd='" + idd + "']/Cancion", raiz,
				XPathConstants.NODESET);
				for (int i = 0; i < nl_cancion.getLength(); i++) {

					String titulo = (String) xpath.evaluate("Titulo", nl_cancion.item(i), XPathConstants.STRING);
					String duracion = (String) xpath.evaluate("Duracion", nl_cancion.item(i), XPathConstants.STRING);
					String genero = (String) xpath.evaluate("Genero", nl_cancion.item(i), XPathConstants.STRING);
					String idc = (String) xpath.evaluate("@idc", nl_cancion.item(i), XPathConstants.STRING);
					Cancion song = new Cancion(titulo, idc, genero, duracion);
					canciones.add(song);
				}
			} catch (XPathExpressionException e) {
				e.printStackTrace();
			}
		}
		Collections.sort(canciones, new Comparator<Cancion>() {
			public int compare(Cancion s1, Cancion s2) {
				if (s1.getDuracion().equalsIgnoreCase(s2.getDuracion())) {
					return s1.getIdc().compareTo(s2.getIdc());
				} else {
					return s1.getDuracion().compareTo(s2.getDuracion());
				}

			}
		});
		return canciones;
	}

	private ArrayList<Cancion> getC1Resultado(String anio, String idd, String idc) throws XPathExpressionException {

		XPathFactory xpathFactory = XPathFactory.newInstance();
		XPath xpath = xpathFactory.newXPath();
		String interprete = "", duracion1 = "", longitud = "", premio="";
		ArrayList<Cancion> resultados = new ArrayList<Cancion>();

		for (int k = 0; k < documents.size(); k++) {
			Element raiz = documents.get(k).getDocumentElement();
			try {
				NodeList nl_disco = (NodeList) xpath.evaluate("/Songs[Anio='" + anio+ "']/Pais/Disco[@idd='" + idd + "']", raiz,	XPathConstants.NODESET);

				for (int i = 0; i < nl_disco.getLength(); i++) {
					interprete = (String) xpath.evaluate("/Songs[Anio='" + anio
					+ "']/Pais/Disco[@idd='" + idd + "']/Interprete", nl_disco.item(i),XPathConstants.STRING);

				}

				NodeList nl_duracion = (NodeList) xpath.evaluate("/Songs[Anio='" + anio
				+ "']/Pais/Disco[@idd='" + idd + "']/Cancion[@idc='" + idc + "']", raiz,
				XPathConstants.NODESET);
				for (int i = 0; i < nl_disco.getLength(); i++) {
					duracion1 = (String) xpath.evaluate("Duracion", nl_duracion.item(i), XPathConstants.STRING);
				}
			}catch (XPathExpressionException e) {
				e.printStackTrace();
			}
		}


		for(int k = 0; k < documents.size(); k++){
			Element raiz = documents.get(k).getDocumentElement();
			try{

				NodeList nl_titulo = (NodeList) xpath.evaluate(
				"/Songs/Pais/Disco[Interprete='"+interprete.trim()+"']/Cancion", raiz, XPathConstants.NODESET);

				for (int i = 0; i < nl_titulo.getLength(); i++) {
					String premios="";
					String titulo = (String) xpath.evaluate("Titulo", nl_titulo.item(i),XPathConstants.STRING);
					String descripcion =(String) xpath.evaluate("text()[normalize-space()]", nl_titulo.item(i),XPathConstants.STRING);
					premio = (String) xpath.evaluate("../Premios", nl_titulo.item(i),XPathConstants.STRING);

					String duracion2 = (String) xpath.evaluate("Duracion", nl_titulo.item(i), XPathConstants.STRING);
					descripcion = descripcion.trim();
					premio = premio.trim();
					if(premio.contains("Grammy")) premios+=" "+"Grammy";
					if(premio.contains("LamparaMinera")) premios+=" "+"LamparaMinera";
					if(premio.contains("DiscoDeOro")) premios+=" "+"DiscoDeOro";
					premios = premios.trim();
					int dur1=Integer.parseInt(duracion1);
					int dur2=Integer.parseInt(duracion2);

					if(dur2<dur1) {
						resultados.add(new Cancion(titulo,descripcion,premios));
					}
				}

			} catch (XPathExpressionException e) {
				e.printStackTrace();
			}

		}

		Collections.sort(resultados, new Comparator<Cancion>() {
			public int compare(Cancion s1, Cancion s2) {
				return s2.getTitulo().compareTo(s1.getTitulo());

			}
		});
		return resultados;

	}

	/////////////////////////////////////////////////////////////////// PRINTING
	/////////////////////////////////////////////////////////////////// METHODS

	private void print01(PrintWriter out, HttpServletResponse res, String mode, String p) {

		if (mode.equals("si")) {

			res.setContentType("text/xml");
			out.println("<?xml version='1.0' encoding='utf-8' ?>");
			out.println("<service>");
			out.println("<status>OK</status>");
			out.println("</service>");
		}

		else {

			out.println("<html>");
			out.println("<head>");
			out.println("<title> Servicio de consulta de informacion musical </title>");
			out.println("<link rel=\"stylesheet\" href=\"p2/iml.css\"> ");
			out.println("</head>");

			out.println("<body>");
			out.println("<form method=\"GET\" name=\"form01\">");
			out.println("<input type=\"hidden\" name=\"auto\" value=\"no\" >");
			out.println("<input type=\"hidden\" name=\"pfase\" value=\"\" >");
			out.println("<input type=\"hidden\" name=\"p\" value=\"" + p + "\" >");
			out.println("<h1>Servicio de consulta de informacion musical</h1>");
			out.println(
			"<input type=\"submit\" onClick ='document.forms.form01.pfase.value=\"02\"' value=\"Pulsa aqui para ver los ficheros erroneos\">");
			out.println("<h2> Selecciona una consulta:</h2>");
			out.println("<input type=\"radio\" value=\"next\" checked> Consulta 1: Canciones de un interprete");
			out.println(
			"<br><br><input type=\"submit\" onClick ='document.forms.form01.pfase.value=\"11\"' value=\"Enviar\"><br>");
			out.println("<br><hr> Manuel Canedo Tabares (Fin de Carrera 2019-2020)");
			out.println("</form>");
			out.println("</body>");
			out.println("</html>");
		}
	}

	private void print02(PrintWriter out, HttpServletResponse res, String mode, String p) {

		HashMap<String, String> map = new HashMap<String, String>();
		ValueComparator bvc_war = new ValueComparator(map);
		ValueComparator bvc_err = new ValueComparator(map);
		ValueComparator bvc_ferr = new ValueComparator(map);

		Map<String, String> sorted_war = new TreeMap<String, String>(bvc_war);
		Map<String, String> sorted_err = new TreeMap<String, String>(bvc_err);
		Map<String, String> sorted_ferr = new TreeMap<String, String>(bvc_ferr);

		sorted_war.putAll(warnings);
		sorted_err.putAll(errors);
		sorted_ferr.putAll(fatalerrors);

		if (mode.equals("si")) {
			res.setContentType("text/xml");
			out.println("<?xml version='1.0' encoding='utf-8'?>");
			out.println("<errores>");

			boolean inicio = true;
			String auxFile = "";
			String clave = "";

			out.println("<warnings>");
			Iterator<String> it = sorted_war.keySet().iterator();
			while (it.hasNext()) {
				clave = (String) it.next();
				if (!(warnings.get(clave)).equals(auxFile)) {
					if (!inicio) {
						out.println("</cause>");
						out.println("</warning>");
					}
					out.println("<warning>");
					out.println("<file>" + warnings.get(clave) + "</file>");
					out.println("<cause>");
				}
				out.println(clave);
				auxFile = warnings.get(clave);
				inicio = false;
			}
			if (!clave.equals("")) {
				out.println("</cause>");
				out.println("</warning>");
				inicio = true;
				auxFile = "";
			}
			out.println("</warnings>");

			out.println("<errors>");
			it = sorted_err.keySet().iterator();
			while (it.hasNext()) {
				clave = (String) it.next();
				if (!(errors.get(clave)).equals(auxFile)) {
					if (!inicio) {
						out.println("</cause>");
						out.println("</error>");
					}
					out.println("<error>");
					out.println("<file>" + errors.get(clave) + "</file>");
					out.println("<cause>");
				}
				out.println(clave);
				auxFile = errors.get(clave);
				inicio = false;
			}
			if (!clave.equals("")) {
				out.println("</cause>");
				out.println("</error>");
				inicio = true;
				auxFile = "";
			}
			out.println("</errors>");

			out.println("<fatalerrors>");
			it = sorted_ferr.keySet().iterator();
			while (it.hasNext()) {
				clave = (String) it.next();
				if (!(fatalerrors.get(clave)).equals(auxFile)) {
					if (!inicio) {
						out.println("</cause>");
						out.println("</fatalerror>");
					}
					out.println("<fatalerror>");
					out.println("<file>" + fatalerrors.get(clave) + "</file>");
					out.println("<cause>");
				}

				out.println(clave);
				auxFile = fatalerrors.get(clave);
				inicio = false;
			}
			if (!clave.equals("")) {
				out.println("</cause>");
				out.println("</fatalerror>");
				inicio = true;
				auxFile = "";
			}
			out.println("</fatalerrors>");
			out.println("</errores>");
		}

		else {
			out.println("<html>");
			out.println("<head>");
			out.println("<title> Servicio de consulta de informacion musical </title><br>");
			out.println("<link rel=\"stylesheet\" href=\"p2/iml.css\"> ");
			out.println("</head>");
			out.println("<body>");
			out.println("<form method=\"GET\" name=\"form02\">");
			out.println("<input type=\"hidden\" name=\"auto\" value=\"no\" >");
			out.println("<input type=\"hidden\" name=\"p\" value=\"" + p + "\" >");
			out.println("<h1> Servicio de consulta de informacion musical</h1>");
			out.println("<input type=\"hidden\" name=\"pfase\" value=\"\" >");

			out.println("<h4>Se han detectado " + sorted_war.size() + " ficheros con warnings: </h4>");
			Iterator<String> it = sorted_war.keySet().iterator();
			String actRoute = "";

			while (it.hasNext()) {
				String clave = (String) it.next();
				if (!actRoute.equals(warnings.get(clave))) {
					out.println("<h4> --> " + warnings.get(clave) + ":</h4>");
				}
				out.println("<h5> " + clave + "</h5>");
				actRoute = warnings.get(clave);
			}

			out.println("<h4>Se han detectado " + sorted_err.size() + " ficheros con errores: </h4>");
			it = sorted_err.keySet().iterator();
			actRoute = "";

			while (it.hasNext()) {
				String clave = (String) it.next();
				if (!actRoute.equals(errors.get(clave))) {
					out.println("<h4> --> " + errors.get(clave) + ":</h4>");
				}
				out.println("<h5> " + clave + "</h5>");
				actRoute = errors.get(clave);
			}

			out.println("<h4>Se han detectado " + sorted_ferr.size() + " ficheros con errores fatales: </h4>");
			Iterator<String> it3 = sorted_ferr.keySet().iterator();
			actRoute = "";

			while (it3.hasNext()) {
				String clave = (String) it3.next();
				if (!actRoute.equals(fatalerrors.get(clave))) {
					out.println("<h4> --> " + fatalerrors.get(clave) + ":</h4>");
				}
				out.println("<h5> " + clave + "</h5>");
				actRoute = fatalerrors.get(clave);
			}

			out.println(
			"<br><br><input type=\"submit\" onClick ='document.forms.form02.pfase.value=\"01\"' value=\"Atras\"><br>");
			out.println("<br><hr> Manuel Canedo Tabares (Fin de Carrera 2019-2020) ");
			out.println("</form>");
			out.println("</body>");
			out.println("</html>");
		}
	}

	private void print11(PrintWriter out, HttpServletResponse res, String mode, String p) {

		ArrayList<String> anios = getC1Anios();

		if (mode.equals("si")) {

			res.setContentType("text/xml");
			out.println("<?xml version='1.0' encoding='utf-8' ?>");
			out.println("<anios>");
			for (int i = 0; i < anios.size(); i++) {
				out.println("<anio>" + anios.get(i) + "</anio>");
			}
			out.println("</anios>");
		}

		else {

			out.println("<html>");
			out.println("<head>");
			out.println("<title> Servicio de consulta de informacion musical </title>");
			out.println("<link rel=\"stylesheet\" href=\"p2/iml.css\"> ");
			out.println("</head>");

			out.println("<body>");
			out.println("<form method=\"GET\" name=\"form11\">");
			out.println("<input type=\"hidden\" name=\"auto\" value=\"no\" >");
			out.println("<input type=\"hidden\" name=\"pfase\" value=\"\" >");
			out.println("<input type=\"hidden\" name=\"p\" value=\"" + p + "\" >");
			out.println("<h1> Servicio de consulta de informacion musical</h1>");
			out.println("<h2> Consulta 1</h2>");
			out.println("<h2> Seleccione un anio: </h2>");

			for (int i = 0; i < anios.size(); i++) {
				out.println("<input type=\"radio\" name=\"panio\" value= " + anios.get(i) + " checked > " + (i+1) + ".- " + anios.get(i)
				+ " <br>");
			}

			out.println(
			"<br><br><input type=\"submit\" onClick ='document.forms.form11.pfase.value=\"12\"' value=\"Enviar\" >");
			out.println("<input type=\"submit\" onClick ='document.forms.form11.pfase.value=\"01\"' value=\"Atras\" >");
			out.println("<br><hr> Manuel Canedo Tabares (Fin de Carrera 2019-2020)");
			out.println("</form>");
			out.println("</body>");
			out.println("</html>");
		}
	}

	private void print12(PrintWriter out, HttpServletResponse res, String mode, String panio, String p) { // Completar

		ArrayList<Disco> discos = null;

		try {
			discos = getC1Discos(panio);
		} catch (XPathExpressionException e) {
			e.printStackTrace();
		}

		if (mode.equals("si")) {

			res.setContentType("text/xml");
			out.println("<?xml version='1.0' encoding='utf-8' ?>");
			out.println("<discos>");

			for (int i = 0; i < discos.size(); i++) {
				out.println("<disco idd='" + discos.get(i).getIdd() + "' interprete='" + discos.get(i).getInterprete()
				+ "' langs='" + discos.get(i).getLangs() + "'>" + discos.get(i).getTitulo() + "</disco>");
			}
			out.println("</discos>");
		}

		else {

			out.println("<html>");
			out.println("<head>");
			out.println("<title> Servicio de consulta de informacion musical </title>");
			out.println("<link rel=\"stylesheet\" href=\"p2/iml.css\"> ");
			out.println("</head>");

			out.println("<body>");
			out.println("<form method=\"GET\" name=\"form12\">");
			out.println("<input type=\"hidden\" name=\"auto\" value=\"no\" >");
			out.println("<input type=\"hidden\" name=\"pfase\" value=\"\" >");
			out.println("<input type=\"hidden\" name=\"p\" value=\"" + p + "\" >");
			out.println("<input type=\"hidden\" name=\"panio\" value=\"" + panio + "\" >");
			out.println("<h1> Servicio de consulta de informacion musical</h1>");
			out.println("<h2> Consulta 1: Anio=" + panio + "</h2>");
			out.println("<h2> Selecciona un disco: </h2>");

			for (int i = 0; i < discos.size(); i++) {
				out.println("<div><input type='radio' name='pidd' value='" + discos.get(i).getIdd() + "'checked> "
				+ (i + 1) + ".- " + "Titulo=" + "'" + discos.get(i).getTitulo() + "'" + "---" + "IDD=" + "'"
				+ discos.get(i).getIdd() + "'" + "---" + "Interprete=" + "'" + discos.get(i).getInterprete()
				+ "'" + "---" + "Idiomas=" + "'" + discos.get(i).getLangs() + "'" + "</div>");
			}

			out.println(
			"<br><br><input type=\"submit\" onClick ='document.forms.form12.pfase.value=\"13\"' value=\"Enviar\" >");
			out.println("<input type=\"submit\" onClick ='document.forms.form12.pfase.value=\"11\"' value=\"Atras\" >");
			out.println(
			"<input type=\"submit\" onClick ='document.forms.form12.pfase.value=\"01\"' value=\"Inicio\" >");
			out.println("<br><hr> Manuel Canedo Tabares (Fin de Carrera 2019-2020) ");
			out.println("</form>");
			out.println("</body>");
			out.println("</html>");
		}
	}

	private void print13(PrintWriter out, HttpServletResponse res, String mode, String panio, String pidd, String p) { // Completar

		ArrayList<Cancion> canciones = new ArrayList<Cancion>();
		try {
			canciones = getC1Canciones(panio, pidd);
		} catch (XPathExpressionException e) {
			e.printStackTrace();
		}


		if (mode.equals("si")) {

			res.setContentType("text/xml");
			out.println("<?xml version='1.0' encoding='utf-8' ?>");
			out.println("<canciones>");

			for (int k = 0; k < canciones.size(); k++) {
				out.println("<cancion idc='" + canciones.get(k).getIdc() + "' genero='" + canciones.get(k).getGenero()
				+ "' duracion='" + canciones.get(k).getDuracion() + "'>" + canciones.get(k).getTitulo()
				+ "</cancion>");
			}
			out.println("</canciones>");
		}

		else {

			out.println("<html>");
			out.println("<head>");
			out.println("<title> Servicio de consulta de informacion musical </title>");
			out.println("<link rel=\"stylesheet\" href=\"p2/iml.css\"> ");
			out.println("</head>");

			out.println("<body>");
			out.println("<form method=\"GET\" name=\"form13\">");
			out.println("<input type=\"hidden\" name=\"auto\" value=\"no\" >");
			out.println("<input type=\"hidden\" name=\"pfase\" value=\"\" >");
			out.println("<input type=\"hidden\" name=\"p\" value=\"" + p + "\" >");
			out.println("<input type=\"hidden\" name=\"panio\" value=\"" + panio + "\" >");
			out.println("<input type=\"hidden\" name=\"pidd\" value=\"" + pidd + "\" >");
			out.println("<h1> Servicio de consulta de informacion musical</h1>");
			out.println(" Anio=" + panio + ", Disco=" + pidd + "");
			out.println("<h2> Seleccione una cancion: </h2>");

			for (int k = 0; k < canciones.size(); k++) {
				out.println("<div><input type='radio' name='pidc' value='" + canciones.get(k).getIdc() + "'checked> "
				+ (k + 1) + ".- " + "Título=" + "'" + canciones.get(k).getTitulo() + "'" + "---" + "IDC="
				+ "'" + canciones.get(k).getIdc() + "'" + "---" + "Género=" + "'"
				+ canciones.get(k).getGenero() + "'" + "---" + "Duración=" + "'"
				+ canciones.get(k).getDuracion() + "'" + "</div>");
			}

			out.println(
			"<br><br><input type=\"submit\" onClick ='document.forms.form13.pfase.value=\"14\"' value=\"Enviar\" >");
			out.println("<input type=\"submit\" onClick ='document.forms.form13.pfase.value=\"12\"' value=\"Atras\" >");
			out.println(
			"<input type=\"submit\" onClick ='document.forms.form13.pfase.value=\"01\"' value=\"Inicio\" >");
			out.println("<br><hr> Manuel Canedo Tabares (Fin de Carrera 2019-2020) ");
			out.println("</form>");
			out.println("</body>");
			out.println("</html>");
		}
	}

	private void print14(PrintWriter out, HttpServletResponse res, String mode, String panio, String pidd, String pidc, // Completar
	String p) {
		ArrayList<Cancion> resultados = null;
		try {
			resultados = getC1Resultado(panio, pidd, pidc);
		} catch (XPathExpressionException e) {
			e.printStackTrace();
		}


		if (mode.equals("si")) {

			res.setContentType("text/xml");
			out.println("<?xml version='1.0' encoding='utf-8' ?>");
			out.println("<songs>");
			for (int i = 0; i < resultados.size(); i++) {
				out.println("<song descripcion='" + resultados.get(i).getDescripcion() + "' premios='"
				+ resultados.get(i).getPremios() + "'>" + resultados.get(i).getTitulo() + "</song>");
			}
			out.println("</songs>");
		}

		else {

			out.println("<html>");
			out.println("<head>");
			out.println("<title> Servicio de consulta de informacion musical </title>");
			out.println("<link rel=\"stylesheet\" href=\"p2/iml.css\"> ");
			out.println("</head>");

			out.println("<body>");
			out.println("<form method=\"GET\" name=\"form14\">");
			out.println("<input type=\"hidden\" name=\"auto\" value=\"no\" >");
			out.println("<input type=\"hidden\" name=\"pfase\" value=\"\" >");
			out.println("<input type=\"hidden\" name=\"p\" value=\"" + p + "\" >");
			out.println("<input type=\"hidden\" name=\"panio\" value=\"" + panio + "\" >");
			out.println("<input type=\"hidden\" name=\"pidd\" value=\"" + pidd + "\" >");
			out.println("<input type=\"hidden\" name=\"pidc\" value=\"" + pidc + "\" >");
			out.println("<h1>Servicio de consulta de informacion musical</h1>");
			out.println("Anio=" + panio + ", Disco=" + pidd + ", Cancion=" + pidc + "");
			out.println("<h2> Estas son sus canciones: </h2>");

			for (int i = 0; i < resultados.size(); i++) {
				out.println("<li>" + (i + 1) + ".-<B>Título</B>=" + "'" + resultados.get(i).getTitulo() + "'"
				+ ",<B>Descripción</B>=" + "'" + resultados.get(i).getDescripcion() + "'" + ",<B>Premios</B>="
				+ "'" + resultados.get(i).getPremios() + "'" + "</li>");
			}

			out.println(
			"<br><br><input type=\"submit\" onClick ='document.forms.form14.pfase.value=\"13\"' value=\"Atras\" >");
			out.println(
			"<input type=\"submit\" onClick ='document.forms.form14.pfase.value=\"01\"' value=\"Inicio\" >");
			out.println("<br><hr> Manuel Canedo Tabares (Fin de Carrera 2019-2020) ");
			out.println("</form>");
			out.println("</body>");
			out.println("</html>");
		}
	}

	private void printError(PrintWriter out, HttpServletResponse res, String mode, String code, String p) {

		if (mode.equals("si")) {
			out.println("<?xml version='1.0' encoding='utf-8'?>");
			out.println("<wrongRequest>" + code + "</wrongRequest>");
		}

		else {

			out.println("<html>");
			out.println("<head>");
			out.println("<title> Servicio de consulta de informacion musical </title>");
			out.println("<link rel=\"stylesheet\" href=\"p2/iml.css\"> ");
			out.println("</head>");

			out.println("<body>");
			out.println("<form method=\"GET\" name=\"formErr\">");
			out.println("<input type=\"hidden\" name=\"auto\" value=\"no\" >");
			out.println("<input type=\"hidden\" name=\"pfase\" value=\"\" >");
			out.println("<input type=\"hidden\" name=\"p\" value=\"" + p + "\" >");
			out.println("<h1>Servicio de consulta de informacion musical</h1><br>");
			out.println("<h2> Error en la peticion</h2><br>");
			out.println(" " + code);
			out.println(
			"<br><br><input type=\"submit\" onClick ='document.forms.formErr.pfase.value=\"01\"' value=\"Inicio\" >");
			out.println("<br><hr> Manuel Canedo Tabares (Fin de Carrera 2019-2020) ");
			out.println("</form>");
			out.println("</body>");
			out.println("</html>");
		}
	}

	/////////////////////////////////////////////////////////////////// AUXILIAR
	/////////////////////////////////////////////////////////////////// CLASSES

	class ErrorHandler extends DefaultHandler {
		public void warning(SAXParseException saxpe) throws SAXException {
			error = true;
			String errorStr = (saxpe.toString()).trim();
			warnings.put(errorStr, saxpe.getSystemId());
		}

		public void error(SAXParseException saxpe) throws SAXException {
			error = true;
			String errorStr = (saxpe.toString()).trim();
			errors.put(errorStr, saxpe.getSystemId());
		}

		public void fatalError(SAXParseException saxpe) throws SAXException {
			error = true;
			String errorStr = (saxpe.toString()).trim();
			fatalerrors.put(errorStr, saxpe.getSystemId().trim());
		}
	}

	class ValueComparator implements Comparator<String> {

		Map<String, String> base;

		public ValueComparator(Map<String, String> warnings) {
			this.base = warnings;
		}

		public int compare(String a, String b) {
			if (a.compareToIgnoreCase(b) > 0) {
				return -1;
			} else {
				return 1;
			}
		}
	}

	class Disco {

		private String titulo;
		private String idd;
		private String interprete;
		private String langs;

		public Disco(String titulo, String idd, String interprete, String langs) {

			this.titulo = titulo;
			this.idd = idd;
			this.interprete = interprete;
			this.langs = langs;
		}

		public String getTitulo() {
			return titulo;
		}

		public String getIdd() {
			return idd;
		}

		public String getInterprete() {
			return interprete;
		}

		public String getLangs() {
			return langs;
		}
	}

	class Cancion {

		private String titulo;
		private String idc;
		private String genero;
		private String duracion;
		private String descripcion;
		private String premios;

		public Cancion(String titulo, String idc, String genero, String duracion) {

			this.titulo = titulo;
			this.idc = idc;
			this.genero = genero;
			this.duracion = duracion;
		}

		public Cancion(String titulo, String descripcion, String premios) {

			this.titulo = titulo;
			this.descripcion = descripcion;
			this.premios = premios;
		}

		public String getTitulo() {
			return titulo;
		}

		public String getIdc() {
			return idc;
		}

		public String getGenero() {
			return genero;
		}

		public String getDuracion() {
			return duracion;
		}

		public String getDescripcion() {
			return descripcion;
		}

		public String getPremios() {
			return premios;
		}

	}
}
