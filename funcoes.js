	//document.oncontextmenu=new Function("return false");
	
	function backpage(){
		
	}
	
	var message_on = false;
	
	function showMessage(){
		if ( message_on ){
			setInvisivel("message_box");
			message_on = false;
		}else{
			setVisivel("message_box");
			message_on = true;			
		}
	}	
	
	function checkLength(obj, len){
		if ( obj.value != "" ){
			if ( obj.value.length != len ){
				alert("Campo precisa ter " + len + " caracteres.");
				obj.value = "";
			}
		}
	}
	
	function textCounter(field, countfield, maxlimit) {
		if (field.value.length > maxlimit) 
			field.value = field.value.substring(0, maxlimit);
		else 
			countfield.value = field.value.length;
	}

	function textCounterArea(field, countfield, maxlimit) {
		if ( maxlimit == "" || maxlimit == null ){
			countfield.value = field.value.length;
			return;
		}
		if (field.value.length > maxlimit) 
			field.value = field.value.substring(0, maxlimit);
		else 
			countfield.value = field.value.length;
	}
	
	function setClazz(obj, clazz){
		obj.className = clazz;
	}
	
	function zoom_over(obj){
		if ( themepath != null
			&& themepath != "" )
			obj.src = themepath+"small_zoom_over.gif";
		else
			obj.src = "/img/small_zoom_over.gif";		
	}

	function zoom_out(obj){
		if ( themepath != null
			&& themepath != "" )
			obj.src = themepath+"small_zoom_on.gif";
		else
			obj.src = "/img/small_zoom_on.gif";		
	}
	
	function m_over_g(obj, img) {
		if ( themepath != null
			&& themepath != "" ){
			obj.src = themepath+img+"_on.gif";
		}else
			obj.src = "/img/"+img+"_on.gif";
	}
	
	function m_out_g(obj, img) {
		if ( themepath != null
			&& themepath != "" ){
			obj.src = themepath+img+"_off.gif";
		}else
			obj.src = "/img/"+img+"_off.gif";
	}
		
	function m_over_j(obj, img) {
		if ( themepath != null
			&& themepath != "" )
			obj.src = themepath+img+"_on.jpg";
		else
			obj.src = "/img/"+img+"_on.jpg";
	}
	
	function m_out_j(obj, img) {
		if ( themepath != null
			&& themepath != "" )	
			obj.src = themepath+img+"_off.jpg";
		else
			obj.src = "/img/"+img+"_off.jpg";
	}
	
	
	function showEsp(idarray, id){
		document.getElementById("espcificacao"+id).innerHTML="<div style=\"text-align: left;\">"+msg[idarray]+"</div>";
	}

	function showExp(id){
		document.getElementById("espcificacao"+id).innerHTML="<div style=\"text-align: left;\">"+termos[id-1]+"</div>";
	}
	
	function trim(st) {
	  if (st == null)
	    return "";
	  st = new String(st);
	  if (! st.length || st.length == 0)
	    return "";
	  var psi = 0;
	  // Procura a primeira ocorrencia de nao espaço
	  while (psi < st.length && st.charAt(psi) == ' ')
	    psi++;
	  // Procura a ultima ocorrencia de nao espaço
	  var psf = st.length;
	  while (psf > psi && st.charAt(psf-1) == ' ')
	    psf--;
	
	  // Retorna string nula
	  if (psi >= psf)
	    return "";
	
	  // Retorna substring
	  return st.substring(psi, psf);
	}

	function checkNumber(node, nome){
		var val = node.value;
		val = trim(val);
		if(val.length == 0)
			return false;
		if(val.length == 1 && val.substring(0,1) == "0")
			return false;	
		var zero = val.substring(0,1);
		if( zero == "0")
		{	var valor = "";
			for(var count = 1; count < val.length; count = count + 1  )
			{	var i = count+1;
				if( zero != val.substring(count,i) )
				{	valor = val.substring(count);
					count = val.length;
				} 	
			}
			val = trim(valor);
		}
		var n = parseInt(val);
		var nr = ""+n;
		if(nr.length < val.length || isNaN(n)){
			if ( nome != null && nome != "" )
				alert("Campo " + nome + " precisa ser númerico");				
			else
				alert("Campo informado precisa ser númerico");
			node.value="";
		}

	}
	
	function validaRg(node, nome){
		var val = node.value;
		val = trim(val);
		if(val.length == 0)
			return false;
		if(val.length == 1 && val.substring(0,1) == "0")
			return false;	
		var zero = val.substring(0,1);
		if( zero == "0")
		{	var valor = "";
			for(var count = 1; count < val.length; count = count + 1  )
			{	var i = count+1;
				if( zero != val.substring(count,i) )
				{	valor = val.substring(count);
					count = val.length;
				} 	
			}
			val = trim(valor);
		}
		var n = parseInt(val);
		var nr = ""+n;
		if(nr.length < val.length || isNaN(n)){
			if ( nome != null && nome != "" )
				alert("Campo " + nome + " inválido");				
			else
				alert("Campo informado precisa ser númerico");
			node.value="";
		}

	}
	
	function validaEmail(obj){
		var e = obj.value;		
		if ( e == "" ){
			obj.value = "";
			return false;
		}else if ( e.indexOf(".") == -1 ){
			alert("Email invalido!!");
			obj.value = "";
			return false;
		}else if ( e.indexOf("@") == -1 ){
			alert("Email invalido!!");		
			obj.value = "";
			return false;
		}	
		return true;
	}
	
	function setEnabled(id){
		var obj = document.getElementById(id);
		if ( obj != null ){
			obj.disabled = false;
			obj.style.backgroundColor='#FFFFFF';
		}
	}
	
	function setDisabled(id, bg){
		var obj = document.getElementById(id);
		if ( obj != null ){
			obj.disabled = true;
			if ( !bg )
				obj.style.backgroundColor='#CCCCCC';
		}
	}	
	
	function setReadonly(id, __yes){
		var obj = document.getElementById(id);
		if ( obj != null ){
			if ( __yes ){
				obj.readOnly = true;
				obj.className = "readonly";			
			}else{
				obj.readOnly = false;
				obj.className = "textfield";			
			}
		}
	}

	function setVisivel(id, type){
		var obj = document.getElementById(id);
		if ( obj != null ){
			if ( type != null && type != "" ){
				obj.className = "visivel_"+type;
			}else
				obj.className = "visivel";
		}		
	}
	
	/*function setVisivel(id){
		var obj = document.getElementById(id);
		if ( obj != null )
			obj.className = "visivel";
	}*/
	
	function setInvisivel(id){
		var obj = document.getElementById(id);
		if ( obj != null )
			obj.className = "invisivel";
	}	
	
	function getValue(field){
		var obj = document.getElementById(field);
		if ( obj != null )
			return obj.value;
		return "";
	}
	
	function setValue(field, value){
		var obj = document.getElementById(field);
		if ( obj != null ){
			if ( value != "null" )
				obj.value  = value;
			else
				obj.value  = "";
		}
	}	
	
	function setImg(field, value){
		var obj = document.getElementById(field);
		if ( obj != null ){
			if ( value != "null" )
				obj.src = value;
		}
	}	

	function postFrame(url){
		setVisivel("processando");
		document.getElementById("body_layout").src = url;
	}
	
	function post(url){
		window.location.href = url;
	}
	
	function getComponent(id){
		return document.getElementById(id);
	}