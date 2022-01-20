		var array_polygons = new Array();		
		var polygonselected = null;		
		var POLYGON = 2;
		
		function addPolygon(line){
			var flash = getFlash();
			var obj = flash.createPolygon();
			obj.isPolygon = true;
			obj.isNew = false;
			
			type_xml = false;
			cleanVars();
			
			processAjax("/daf/jsp/map/ajaxProcessMap.jsp?action=3&xml=false", false);
			
			alert("Criando polígono: " + obj.id + " -- " + req_string);
			obj.patternx = "/";
			obj.patterny = "~";			
			obj.patternp = "|";
			obj.fillColor = "000000"; 
			obj.lineColor = "000000";
			obj.fillTransparancy = "50";
			obj.lineTransparancy = "50";
			obj.lineSize = "5";
			obj.polygons = req_string;
			obj.invert = false;
			obj.onClick = "polygonSelected";
			if ( line )
				obj.isPolygon = false;
			
			flash.addPolygon(obj);
			array_polygons.push(obj);
		}
		
		/*function createPolygon(line){
			var flash = getFlash();
			var obj = flash.createPolygon();
			obj.isPolygon = true;
			obj.isNew = true;
			
			alert("Criando Novo polígono: " + obj.id);
			
			obj.patternx = "/";
			obj.patterny = "~";			
			obj.patternp = "|";
			obj.fillColor = "0000FF"; 
			obj.lineColor = "0000FF";
			obj.fillTransparancy = "50";
			obj.lineTransparancy = "50";
			obj.lineSize = "5";
			obj.polygons = "";
			obj.invert = false;
			obj.onClick = "polygonSelected";
			if ( line )
				obj.isPolygon = false;
			
			flash.newPolygon(obj);
			array_polygons.push(obj);
		}*/

		function createPolygon(line, posicoes, cor, espessura){
			var flash = getFlash();
			var obj = flash.createPolygon();
			obj.isPolygon = line;
			obj.isNew = false;
			
			//alert('cor=' + posicoes);
			
			obj.patternx = "/";
			obj.patterny = ",";			
			obj.patternp = "|";
			obj.fillColor = cor; 
			obj.lineColor = cor;
			obj.fillTransparancy = "50";
			obj.lineTransparancy = "50";
			obj.lineSize = espessura;
			obj.polygons = posicoes;
			obj.invert = true;
			obj.onClick = "polygonSelected";
			
			array_polygons.push(obj);
			
			return obj;
		}

		
		function polygonSelected(obj){
			alert("Polígono selecionado: " + obj.id);
			polygonselected = obj;	
		}
		function savePolygon(){
			var flash = getFlash();
			var obj = flash.savePolygon();
			if ( obj != null )
				alert("Salvando polígono: " + obj.id + " -- " + obj.polygons );
			else
				alert("Nenhum polígono encontrado.");
		}
		
		function removePolygon(){
			var flash = getFlash();
			if ( polygonselected != null ){
				alert("Removendo polígono: " + polygonselected.id);
			
				flash.removePolygon(polygonselected);
			}else
				alert("Nenhuma polígono selecionada.");		
		}
		