		var array_marks = new Array();
		var markselected = null;
		var MARKER = 1;

		function updateMarker(x, y, imagem, width, height, funcao, seq, msg){
			var flash = getFlash();
			var obj = null;
			for ( var cc = 0; cc < array_marks.length; cc++ ){
				var _obj = array_marks[cc];
				if ( _obj.seq == seq ){
					obj = _obj;
					break;
				}
			}
			if ( obj != null ){
				obj.label = msg;
				obj.label_x = -8;			
				obj.label_y = 15;						
				obj.image_position = 2;
				obj.icon_url = imagem;
				obj.width_icon = width;
				obj.height_icon = height;
				obj.funcJS = funcao;						
				obj.x = x;						
				obj.y = y;						
				obj.isModify = false;			
				obj.beginCenter = false;
				obj.canDragPoint = false;
				obj.processImage = "false";

				flash.updateMarker(obj);
			}
		}
		
		function addMarker(x, y, imagem, width, height, funcao, seq, msg){
			var flash = getFlash();
			var obj = flash.createMarker();
			obj.seq = seq;
			obj.label = msg;
			obj.label_x = -8;			
			obj.label_y = 15;						
			obj.image_position = 2;
			obj.icon_url = imagem;
			obj.width_icon = width;
			obj.height_icon = height;
			obj.funcJS = funcao;						
			obj.x = x;						
			obj.y = y;						
			obj.isModify = false;			
			obj.beginCenter = false;
			obj.canDragPoint = false;
			obj.processImage = "false";
			//alert("Criando marca: " + obj.id + " -- " + obj.invert);
			
			flash.addMarker(obj);
			
			array_marks.push(obj);
			
			return obj;
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

		function markSelected(obj){
			//alert("Marca selecionada: " + obj.id);
			markselected = obj;
		}
		function saveMarker(){
			var flash = getFlash();
			var obj = flash.saveMarker();
			var array = obj.array;
			if ( array.length == 0 ){
				alert("Nenhum ponto modificado.");
				return;
			}
			
			for ( var i = 0; i < array.length; i++ ){
				var p = array[i];
				if ( p != null )
					alert("Salvando pontos: " + p.id + " -- " + p.x + " -- " + p.y );
				else
					alert("Nenhum polígono encontrado.");
			}

			var resp = new Object();
			resp.array = array;
			resp.status = SUCESS;
			resp.msg = "Ponto atualizado com sucesso.";
			flash.commitMarker(resp);
		}		
		function removeMarker(){
			var flash = getFlash();
			if ( markselected != null ){
				alert("Removendo marca: " + markselected.id);
			
				flash.removeMarker(markselected);
				removeMarkerArray(markselected);
			}else
				alert("Nenhuma marca selecionada.");
		}
		
		function removeMarkerArray(objmark){
			var array = new Array();
			for ( var i = 0; i < array_marks.length; i++ ){
				var __objmark = array_marks[i];
				if ( __objmark == null )
					continue;
				if ( objmark.id != __objmark.id )
					array.push(array_marks[i]);
			}
			array_marks = array;
		}