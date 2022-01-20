		var array_circle = new Array();		
		var circleselected = null;	
		var CIRCLE = 3;	
		
		function addCircle(){
			var flash = getFlash();
			var obj = flash.createCircle();
			obj.isNew = false;
			
			alert("Criando circle: " + obj.id);
			
			obj.fillColor = "000000"; 
			obj.lineColor = "000000";
			obj.fillTransparancy = "50";
			obj.lineTransparancy = "50";
			obj.lineSize = "5";
			obj.x = -23.531786111111;
			obj.y = -46.646747222222;	
			obj.radius = 30;		
			obj.invert = true;
			obj.onClick = "circleSelected";
			
			flash.addCircle(obj);
			array_circle.push(obj);
		}
		
		function createCircle(){
			var flash = getFlash();
			var obj = flash.createCircle();
			obj.isNew = true;
			
			alert("Criando Novo circle: " + obj.id);
			
			obj.fillColor = "0000FF"; 
			obj.lineColor = "0000FF";
			obj.fillTransparancy = "50";
			obj.lineTransparancy = "50";
			obj.lineSize = "5";
			obj.radius = 40;
			obj.invert = true;
			obj.onClick = "circleSelected";
			
			flash.newCircle(obj);
			array_circle.push(obj);
		}
		
		function circleSelected(obj){
			alert("Circle selecionado: " + obj.id);
			circleselected = obj;	
		}
		function saveCircle(){
			var flash = getFlash();
			var obj = flash.saveCircle();
			if ( obj != null )
				alert("Salvando circle: " + obj.id + " -- " + obj.x + " -- " + obj.y );
			else
				alert("Nenhum circle encontrado.");
		}
		
		function removeCircle(){
			var flash = getFlash();
			if ( circleselected != null ){
				alert("Removendo circle: " + circleselected.id);
			
				flash.removeCircle(circleselected);
			}else
				alert("Nenhum circle selecionado.");		
		}
		