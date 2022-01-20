var req;

function processAjax(url, freeze) {
    if (window.XMLHttpRequest) {
        req = new XMLHttpRequest();
    } else if (window.ActiveXObject) {
        req = new ActiveXObject("Microsoft.XMLHTTP");
    }

    req.open("GET", url, freeze);
    req.onreadystatechange = callback;
    req.send(null);
}

function callback() {
	//alert('callback' + req.readyState);
    if (req.readyState == 4) {
		//alert(req.status);
        if (req.status == 200) {
            // update the HTML DOM based on whether or not message is valid
			parseMessage();
        }
    }
}

var type_xml = false;

function parseMessage() {
    var message = req.responseXML.getElementsByTagName("message")[0];
    
    if ( type_xml ){
    	getAjaxXmlRequest(message);
	}else if ( message != null && message.childNodes[0] != null ){
		getAjaxRequest(message.childNodes[0].nodeValue);
	}else{
		getAjaxRequest("");
	}
}

