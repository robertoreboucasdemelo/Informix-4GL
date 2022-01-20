var ACTION_MARKER = 1;

function createMarker(point, __msg) {
	var marker = null;
	if ( getValue("icon") != "" )
		marker = new GMarker(point, createIcon());
	else
		marker = new GMarker(point);
	
	if ( __msg != null && __msg != "" ){
		GEvent.addListener(marker, "click", function() {
			var myHtml = __msg;
				
			map.openInfoWindowHtml(point, myHtml);
		});
	}
	
	return marker;
}

function createMarkerIcon(point, icon, __msg) {
	var marker = new GMarker(point, icon);
	
	if ( __msg != null && __msg != "" ){
		GEvent.addListener(marker, "click", function() {
			var myHtml = __msg;
				
			map.openInfoWindowHtml(point, myHtml);
		});
	}
	
	return marker;
}

function createIcon(url){
	var tinyIcon = new GIcon();
	if ( url != null )
		tinyIcon.image = url;
	else
		tinyIcon.image = getValue("icon");
	//tinyIcon.shadow = "http://";
	tinyIcon.iconSize = new GSize(20, 20);
	//tinyIcon.shadowSize = new GSize(22, 20);
	tinyIcon.iconAnchor = new GPoint(6, 20);
	tinyIcon.infoWindowAnchor = new GPoint(5, 1);
	
	var markerOptions = { icon:tinyIcon };
	return markerOptions;
}

function getDirection(p){
			if ( p > 340 && p <= 360 )
				return "n";
			if ( p >= 0 && p <= 20 )
				return "n";
			if ( p > 20 && p <= 70 )
				return "nl";	
			if ( p > 70 && p <= 115 )
				return "l";					
			if ( p > 115 && p <= 160 )
				return "sl";							
			if ( p > 160 && p <= 205 )
				return "s";										
			if ( p > 205 && p <= 250 )
				return "sw";														
			if ( p > 250 && p <= 295 )
				return "w";																			
			if ( p > 295 && p <= 340 )
				return "nw";																			
			return "s";		
		}