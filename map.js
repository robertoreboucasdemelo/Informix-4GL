		var SUCESS = 1;
		var ERROR = 2;
		var NO_ACTION = 3;				

		var __flash = null;

		function thisMovie(movieName) {
		    if (navigator.appName.indexOf("Microsoft") != -1) {
		        return window[movieName];
		    } else {
		    	return document.getElementById(movieName+"_moz");
		    }
		}	
		
		function getFlash(){
			if ( __flash != null )
				return __flash;
			return thisMovie("flashObject");
		}
		
		function setFlash(obj){
			__flash = obj;
		}
		
		var xml = null;
		var req_array = null;
		var req_string = null;
		
		function cleanVars(){
			xml = null;
			req_array = null;
			req_string = null;
		}
		
		function getAjaxXmlRequest(node){
			xml = node;
		}
		
		function getAjaxRequest(str){
			req_string = str;
		}
		
		var isLoad = false;
		var funcLoad = "onLoadFlash()";
		var checkLoad = setInterval(checkFlashLoad, 500);
		function checkFlashLoad(){
			try{
				var obj = getFlash().isLoadFlash();
				if ( obj.load ){
					isLoad = true;
					clearInterval(checkLoad);
					eval(funcLoad);					
				}
			}catch(e){
				
			}
		}					
		
		function setVisible(type, v){
			var obj = new Object();
			obj.type = type;
			obj.visible = v;
			getFlash().setVisible(obj);
		}		
