var img_default = "/daf/swf/imageSwf/point_s_blue.png";

function checkValue(val){
	if ( val != null && val != "" )
		return val;
	return "";
}

function initMap(a, data, px, py){
	if ( a == 0 || a == 42 ){
		processMarkerDaf(data, px, py);
	}else if ( a == 6 ){
		AjaxMarkerDaf.startRequest(data);
	}	
}

function createDafOnlineAndPlot(lat, lng, daf, centerpoint, color){
	var point = new GLatLng(lat, lng);
	var icon = createIcon(img_default);
	var marker = createMarkerIcon(point, icon, "");
	
	marker.codigodaf = daf;
	if ( color != null && color != "" )
		marker.colormarker = color;
	else
		marker.colormarker = "blue";
	marker.my_Html = "<b>Código DAF: </b>" + daf + "<br/><br/><b>Aguarde, processando informações...</b>";
	
	GEvent.addListener(marker, "click", function() {
		map.openInfoWindowHtml(marker.getLatLng(), marker.my_Html);
		setValue("codigodaf_routedaf", marker.codigodaf); 
	});
	
	addDaf(marker);
	
	enableTimerRefresh();
	
	plotPoint(point, marker, centerpoint);
	
	return marker;
}

function createDafAndPlot(lat, lng, daf){
	var point = new GLatLng(lat, lng);
	var icon = createIcon(img_default);
	var marker = createMarkerIcon(point, icon, "");
	
	marker.codigodaf = daf;
	marker.myHtml = "<b>Código DAF: </b>" + daf + "<br/>";

	GEvent.addListener(marker, "click", function() {
		map.openInfoWindowHtml(marker.getLatLng(), marker.myHtml);
		setValue("codigodaf_routedaf", marker.codigodaf);
	});
	
	plotPoint(point, marker);
	
	return marker;
}

function createAndPlot(lat, lng){
	if ( lat == "0" && lng == "0" )
		return;

	var point = new GLatLng(lat, lng);
	plotPoint(point, createMarker(point, ""));
}

function plotPoint(point, marker, centerpoint){
	if ( centerpoint != "false" )
		map.setCenter(point, 17);		
	
	map.addOverlay(marker);
}