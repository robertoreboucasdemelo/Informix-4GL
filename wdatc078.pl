#!/usr/bin/perl
####use CGI ":all";
####use strict;
####use ARG4GL;
#####use Date::format; 
####use Digest::MD5 qw(md5_hex);
####
####my (
####$user,
####$key,
####@lt,
####$date,
####$keymap,
####$prestador,
####$sec,
####$min,
####$hour,
####$mday,
####$mon,
####$year,
####$wday,
####$yday,
####$isdst,
####$minn);
####
####$user = "0783";
####$key = "f309b4dbeb5b912855866b6774308745006eb249";
####$minn = "";
####
####($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
####
####if ( $mday < 10 ){
####	$mday = "0" . $mday;
####}else{
####	$mday = "" . $mday;
####}
####
####$mon = $mon+1;
####if ( $mon < 10 ){
####	$mon = "0" . $mon;
####}else{
####	$mon = "" . $mon;
####}
####
####if ( $hour < 10 ){
####	$hour = "0" . $hour;
####}else{
####	$hour = "" . $hour;
####}
####
####if ( $min < 10 ){
####	$minn = "0" . $min;
####}else{
####	$minn = "" . $min;
####}
####
####$date = ($year+1900) . "-" . ($mon) . "-" . $mday . "-" . $hour . "-" . $minn;
####
####$keymap = md5_hex($date . "_" . $user . "_" . $key);
####
####$prestador = param("prestador");
####
####print '
####
####<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
####<head>
####	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
####	<title>DAF - Porto Seguro</title>
####	<script type="text/javascript" src="/ct24h/trs/simpleajax.js"></script>
####	<script type="text/javascript" src="/ct24h/trs/functions.js"></script>
####	<script type="text/javascript" src="/ct24h/trs/point.js"></script>
####	<script type="text/javascript" src="/ct24h/trs/marker.js"></script>
####	
####	<script src="http://maps.google.com/maps?file=api&v=2&key=ABQIAAAAEaUEHhns6t-QsQ0gd1iA7xSDbJDwd9mCMR9wpl77TOr9MhqDyBRCWnusviaxTIfYSJ-pq-PNxzSKhg"
####      			type="text/javascript"></script>
####	<script>
####		var app_page = "https://wwws.portoseguro.com.br/daf";
####		
####		var map = null;
####		
####		function load() {
####		       if (GBrowserIsCompatible()) {
####		        	map = new GMap2(document.getElementById("map"));
####			        map.addControl(new GLargeMapControl());
####			        map.addControl(new GMapTypeControl());
####			        map.setCenter(new GLatLng(-23.531786111111, -46.646747222222), 17);
####			}
####			loadPoints();
####		}
####	
####		function redirectPage(p){
####			window.open(p, "_top");
####		}
####		
####		var update = false;
####		var first = true;
####		var check_update = null;
####		
####		function updateAll(){
####			//check_update = setInterval(updateAllMarkers, 10000);
####			check_update = setInterval(updateAllMarkers, ((1000*60)*2));
####		}
####		
####		function updateAllMarkers(){
####			loadPoints();
####		}
####		
####		var url = app_page + "/jsp/map/portosocorro/ajaxProcessMap.jsp";
####		
####		var xml = null;
####		var req_array = null;
####		var req_string = null;
####		
####		var point_markers = new Array();
####		
####		function cleanVars(){
####			xml = null;
####			req_array = null;
####			req_string = null;
####		}
####		
####		function getAjaxXmlRequest(node){
####			xml = node;
####		}
####		
####		function getAjaxRequest(str){
####			req_string = str;
####		}
####		
####		function loadPoints(){
####			processAjax(url+"?action=1"
####					+"&userkey=portosocorromap"
####					+"&keymap=';
####print $keymap;
####print '"
####					+"&prestador=';
####print $prestador;
####print '", false);
####			
####			//https://wwws.portoseguro.com.br/daf/jsp/map/portosocorro/ajaxProcessMap.jsp?action=1&userkey=portosocorromap&keymap=&prestador=2248
####			
####			var _minx = 0.0;
####			var _miny = 0.0;
####			var _maxx = 0.0;
####			var _maxy = 0.0;	
####	
####			var points = req_string.split("++");
####			var loaded = false;
####			for ( var c = 0; c < points.length; c++ ){
####				var point = points[c].split("~");
####			
####				var _x = Number(point[4]);
####				var _y = Number(point[5]);				
####
####				if ( (_x >= 0 && _x <= 1)
####					|| (_y >= 0 && _y <= 1) )
####					continue;
####				
####				if ( !loaded ){
####					_minx = _x;
####					_miny = _y;
####					_maxx = _x;
####					_maxy = _y;
####					loaded = true;
####				}
####
####				if ( _x > _maxx)
####					_maxx = _x;
####				if ( _y > _maxy)
####					_maxy = _y;
####				if (_x < _minx)
####					_minx = _x;
####				if (_y < _miny)
####					_miny = _y;
####
####				var proa = Number(point[6]);
####	
####				var img_url = app_page + "/swf/imageSwf/point_"+getDirection(proa)+"_blue.png";
####				if ( "QRU" == point[1] || "REC" == point[1] || "INI" == point[1] || "FIM" == point[1] )
####					img_url = app_page + "/swf/imageSwf/point_"+getDirection(proa)+"_yellow.png";
####				else if ( "QRA" == point[1] )
####					img_url = app_page + "/swf/imageSwf/point_"+getDirection(proa)+"_blue.png";
####				else if ( "QRV" == point[1] )
####					img_url = app_page + "/swf/imageSwf/point_"+getDirection(proa)+"_green.png";				
####				else if ( "QRX" == point[1] )
####					img_url = app_page + "/swf/imageSwf/point_"+getDirection(proa)+"_red.png";				
####				else if ( "QTP" == point[1] )												
####					img_url = app_page + "/swf/imageSwf/point_"+getDirection(proa)+"_black.png";				
####				else if ( "NIL" == point[1] )																
####					img_url = app_page + "/swf/imageSwf/point_"+getDirection(proa)+"_grey.png";				
####				
####				if ( update && !first ){			
####					updateMarker(_y, _x, img_url, point[0], point[0], c);				
####				}else
####					addMarker(_y, _x, img_url, point[0], point[0]);
####			}
####			
####			var obj_env = new Object();
####			obj_env.maxx = _maxx;
####			obj_env.minx = _minx;			
####			obj_env.maxy = _maxy;	
####			obj_env.miny = _miny;		
####			
####			if ( first ){
####				var point_sw = new GLatLng(_miny, _minx);
####				var point_ne = new GLatLng(_maxy, _maxx);
####				
####				var __bounds = new GLatLngBounds(point_sw, point_ne);
####				var init_zoom = map.getBoundsZoomLevel(__bounds);
####				
####				map.setCenter(new GLatLng((_maxy+_miny)/2, (_maxx+_minx)/2), init_zoom);	
####			}
####						
####			first = false;
####			update = true;
####		}
####		
####		function addMarker(lat, lng, url, seq, msg){
####			var point = new GLatLng(parseFloat(lat), parseFloat(lng));
####
####			var icon = createIcon(url);
####			var marker = createMarkerIcon(point, icon, "");
####			
####			marker.myseq = seq;
####			marker.my_Html = "Carregando informações...";
####			
####			GEvent.addListener(marker, "click", function() {
####				var _msg = openMessage(marker.myseq);
####				map.openInfoWindowHtml(marker.getLatLng(), _msg);
####			});
####						
####			map.addOverlay(marker);
####			point_markers.push(marker);
####		}
####		
####		function updateMarker(lat, lng, url, seq, msg, c){
####			var __m = point_markers[c];
####			__m.setLatLng(new GLatLng(lat, lng));
####			__m.setPoint(new GLatLng(lat, lng));
####			__m.setImage(url);
####		}
####		
####		function openMessage(seq){
####		   var msg = "<span style=\"font-family: verdana; font-size: 11px\">";
####		   
####		   processAjax(url+"?action=2"
####					+"&userkey=portosocorromap"
####					+"&keymap=';
####print $keymap;
####print '"
####					+"&id="+seq
####					+"&prestador=';
####print $prestador;
####print '", false);
####		   
####		   var values = req_string.split("~");
####		   
####		   msg += "<b>Sigla: " + values[0] 
####		   				+ "<br>Atividade: " + values[1]
####		   				+ "<br>Socorrista: " + values[12] + " - " + values[11] + "</b>";
####		   msg += "<br><br>Celular Porto: " + values[13]
####						+ "<br>Celular Socorrista: " + values[14]
####						+ "<br>Data: " + values[2] + " - " + values[3]
####		   				+ "<br>Cidade: " + values[6]+ " - " + values[7]
####		   				+ "<br>Bairro: " + values[8]
####		   				+ "<br>Endereço: " + values[9]
####		   				+ "<br>CEP: " + values[10];
####		   				
####		   msg += "</span>";
####		   
####		   return msg;
####		}
####	</script>
####</head> 
####
####<body onload="load()" onunload="GUnload()" style="margin: 0px">
####<div id="ms">
####	<div id="map" style="width: 800px; height: 530px"></div>    
####</div>
####<table cellpadding="10" cellspacing="10" border="0" style="font-family: verdana; font-size: 10px; font-weight: bolder">
####	<tr>
####		<td><img src="https://wwws.portoseguro.com.br/daf/swf/imageSwf/point_yellow.png"> - QRU/REC/INI/FIM</td>	
####		<td><img src="https://wwws.portoseguro.com.br/daf/swf/imageSwf/point_blue.png"> - QRA</td>
####		<td><img src="https://wwws.portoseguro.com.br/daf/swf/imageSwf/point_green.png"> - QRV</td>		
####		<td><img src="https://wwws.portoseguro.com.br/daf/swf/imageSwf/point_red.png"> - QRX</td>	
####		<td><img src="https://wwws.portoseguro.com.br/daf/swf/imageSwf/point_black.png"> - QTP</td>
####		<td><img src="https://wwws.portoseguro.com.br/daf/swf/imageSwf/point_grey.png"> - NIL</td>		
####	</tr>	
####</table>
####<script>
####	updateAll();
####</script>
####</body>
####</html>';
