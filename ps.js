/* 
	@franklinjavier 
	15/03/2011 

	CTRL + L = Lista das janelas abertas
	CTRL + N = Maximiza/Minimiza janela
	CTRL + 0 = Fecha todas janelas
	Ctrl + Shift + M = Minimiza todas janelas
	Ctrl + Shift + S = Atalhos
	Ctrl + M = Mosaico

    edited on Vim - 22/08/2011

*/

// Porto Seguro - PS Class
var PS = (PS) ? PS : {};  // if exist
var date = new Date();
var active = -1;
var tmp;
var g_usrcod = null;
var g_empcod = null;
var g_sesnum = null;
var g_usrtip = null;
var g_portal = 3;
var g_id_focus = null;
var g_ctrl_window = new Array();


PS = {

	init: function(){

		$('.date em').html(PS.getDate());
				
		// set up time	
		var clock = function(){
			var d = new Date();
			$('.time em').html(PS.getTime(d)); // passagem de param com a data atualizada a cada 1s
		}		
		clock(); setInterval(clock, 1000 );
	
		// set up tooltip
		$("#header [title]").tooltip({effect: 'fade',  offset: [60, -10], tipClass: 'tooltip-top'});
		//$("#dock [title]").tooltip({effect: 'fade'});

		$('.ui-dialog-titlebar').live('dblclick', function(){
			var id = $(this).next().attr('id');
			PS.maximize(id);
		});

		$('.list').bind('click', function (){
			PS.list();
		});

		$('.mosaic').bind('click', function (){
			PS.mosaic();
		});

		PS.setShortcut();

/*
		var tpl =   '<p><span class="key">Ctrl</span> + <span class="key">L</span> = Lista das janelas abertas </p>'+
					'<p><span class="key">Ctrl</span> + <span class="key">N</span> = Maximiza/Minimiza janela </p>'+
					'<p><span class="key">Ctrl</span> + <span class="key">0</span> = Fecha todas janelas </p>'+
					'<p><span class="key">Ctrl</span> + <span class="key">Shift</span> + <span class="key">M</span> = Minimiza todas janelas</p>'+
					'<p><span class="key">Ctrl</span> + <span class="key">M</span> = Mosaico</p>'+
					'<p><span class="key">Ctrl</span> + <span class="key">Shift</span> + <span class="key">S</span> = Atalhos (esta janela)'

		var $dlgShort = $('<div id="shortcut"></div>').html(tpl);
*/

	},

	getDate: function(){
	
		var month = date.getMonth() + 1;

		// set up date
		return  date.getDate() + "/" + // day
				( (month <= 9) ? "0"+month : month ) + "/" + // month
				date.getFullYear(); // year
	},

	getTime: function(date){

		return  date.getHours() + ":" + // hours
				( (date.getMinutes()<10) ? "0"+date.getMinutes() : date.getMinutes() ) // minutes
	},

	create: function(dlgId, dlgURL, dlgTitle, iconText, isSession, isMinimized){

        if (isSession || isSession == undefined) {
            if (dlgURL.indexOf("sesnum=") == -1) { 
                dlgURL += "&sesnum=" + g_sesnum +
                    "&usrcod=" + g_usrcod + 
                    "&empcod=" + g_empcod + 
                    "&usrtip=" + g_usrtip +
                    "&portal=" + g_portal ;
            }
        }

        var v_width = $(window).width()-30;
        var v_height = $(window).height()-190;
        var v_left = 10;
        var v_top = 50;

        var v_cookies = readCookieWithId();

        var objCookie = v_cookies[dlgId];

        if (objCookie) {
            v_width =  parseInt(objCookie.width);
            v_height =  parseInt(objCookie.height);
            v_left =  parseInt(objCookie.left);
            v_top =  parseInt(objCookie.top);
        }

        g_ctrl_window[dlgId] = {isClose:false, 
            objCookie:objCookie,
            dlgURL:dlgURL,
            dlgTitle:dlgTitle,
            iconText:iconText,
            isSession:isSession};

        var v_retorna = false;
        $('.ui-dialog').each(function(i) {
            var id = $(this).find('.ui-dialog-content').attr('id');

            if (dlgId == id) {
                $('#'+id).html('<iframe src="'+ dlgURL +'" width=100% height=99%  frameborder=0 id=frame_' + dlgId + '  onload="window.parent.PS.setShortcut(window.frames[\'frame_' + dlgId + '\'].document);"></iframe>');

                if (!isMinimized) 
                    $('#'+id).dialog('moveToTop').dialog('restore');
                else
                    PS.minimize(id);

                v_retorna = true;
                $("#icon_text_"  + dlgId).html(iconText);
                $('a[rel="'+dlgId+'"]').attr('data-title', dlgTitle );
            }
        });

        if (v_retorna) {
            return;
        }

        var $dock = $('#dock'),
            idx = ( $dock.find('a').length == 0 ) ? 1 : parseInt($dock.find('a').last().attr('data-title-tmp')),
            tpl = '<a id="li_' + dlgId + '" class="dock-item" href="'+ dlgURL +'" rel="'+ dlgId +'" data-title="'+ dlgTitle +'" title="CTRL+'+idx+'" data-title-tmp="'+(idx+1)+'"><span>'+ iconText +'</span><img src="#" alt="'+ iconText +'" /></a>'; 
            //tpl =  [>'<li id="li_' + dlgId + '">'+<]
                //'<a id="li_' + dlgId + '" href="'+ dlgURL +'" class="dock-item" rel="'+ dlgId +'" data-title="'+ dlgTitle +'" title="CTRL+'+idx+'" data-title-tmp="'+(idx+1)+'">'+
                //'<span id="icon_text_' + dlgId + '">'+ iconText +'</span>' +
                //'<img src="/ct24h/trs/resources/img/as.png" alt="iconText" /></a>';

        $dock.find('.dock-container').append(tpl);

        var $addedItem = $('a[rel="'+dlgId+'"]'),
            $dialog = $('<div id="'+ dlgId +'"></div>'),			

            $link = $addedItem.one('click', function() {
                $dialog.html('<iframe src="'+ dlgURL +'" width=100% height=99%  frameborder=0 id=frame_' + dlgId + ' onload="window.parent.PS.setShortcut(window.frames[\'frame_' + dlgId + '\'].document);"></iframe>')
                .dialog({
                    closeOnEscape: false,
                    title: $link.attr('data-title'),
                    width: v_width,
                    minWidth: 250,
                    height: v_height,
                    position: [v_left,v_top],
                    maximized:false,
                    minimized:true,
                    print: true,
                    show: 'fade',
                    hide: "bouncy",
                    focus: function(event,ui) {
                        g_id_focus  = dlgId;
                    },
                    close: function(event, ui) { 
                        g_ctrl_window[dlgId].isClose = true ;
                        if (g_unclosable) {
                            var v_ret = false;
                            for (var x = 0; x < g_unclosable.length ; x++) {
                                if (g_unclosable[x] == dlgId) {
                                    v_ret =true;
                                    break;	
                                }                                                             
                            }
                        }
                        if (v_ret) 
                            return;
                        $(this).dialog('destroy').remove();
                        $link.parent().remove();
                        $('#list li[rel="'+dlgId+'"]').remove();
                    }

                });

            $link.click(function() {
                if (g_ctrl_window[dlgId].isClose) {
                    PS.create(dlgId, 
                        dlgURL, 
                        dlgTitle, 
                        iconText, 
                        isSession);
                }
                g_ctrl_window[dlgId].isClose = false ;

                $dialog.dialog('moveToTop').dialog('restore');
                return false;
            });

            $(document).unbind('keydown', 'Ctrl+'+idx).bind('keydown', 'Ctrl+'+idx,function (evt){
                evt.preventDefault();

                if ($dialog.is(':visible'))
                $dialog.dialog('minimize');
                else
                $dialog.dialog('moveToTop').dialog('restore');

            });			
            });	    

        $('a[rel="'+dlgId+'"]').trigger('click');

        $('.prev').addClass('disabled');

        // Atribui icone
        var v_icon = (g_iconeId[dlgId]) ? g_iconeId[dlgId] : "/ct24h/trs/resources/img/icon2.png" ;
        changeIcon(dlgId, v_icon); 

        $('#dock').Fisheye({
            maxWidth: 50,
            items: 'a',
            itemsText: 'span',
            container: '.dock-container',
            itemWidth: 45,
            proximity: 60,
            halign : 'center'
        });

        $('#carousel').tinycarousel();

        var list = $('#list');
        list.fadeOut(250)
            .find('ul').append('<li rel="'+dlgId+'"><span class="left">'+dlgTitle+'</span> <span class="shortcut">Ctrl+'+idx+'</span></li>');


        $(document).bind('mouseup', function(){
            if (list.is(':visible')){
                $('#list li').removeClass('list-active');
                list.fadeOut(300); // hide list
                active = -1; // reset navigation
            }
        });

        if (isMinimized) {
            PS.minimize(dlgId);
        }

	},

	createPost: function(dlgId, dlgURL, dlgTitle, iconText, isSession, isMinimized){

        if (isSession || isSession == undefined) {
            if (dlgURL.indexOf("sesnum=") == -1) { 
                dlgURL += "&sesnum=" + g_sesnum +
                    "&usrcod=" + g_usrcod + 
                    "&empcod=" + g_empcod + 
                    "&usrtip=" + g_usrtip +
                    "&portal=" + g_portal ;
            }
        }
		
		var form = $('<form></form>');
		form.attr("method","post");
		form.attr("target","frame_" + dlgId);
		form.attr("action",dlgURL.split('?')[0]);
		
		$('body').append(form);

		// Parameters
		var parametros = dlgURL.split('?')[1];
		var paramArray = parametros.split('&');
		var paramLength = paramArray.length;
		var paramWithValue  = "";
		var paramName = "";
		var paramValue = "";		

		for(var i=0; i<paramLength; i++){
			paramWithValue = paramArray[i];
			paramName = paramWithValue.split('=')[0]
			paramValue = paramWithValue.split('=')[1];

			var hiddenField = $('<input></input>');
			hiddenField.attr("type","hidden");
			hiddenField.attr("value",paramValue);
			hiddenField.attr("id",paramName);
			hiddenField.attr("name",paramName);
			form.append(hiddenField);
		}

		
        var v_width = $(window).width()-30;
        var v_height = $(window).height()-190;
        var v_left = 10;
        var v_top = 50;

        var v_cookies = readCookieWithId();

        var objCookie = v_cookies[dlgId];

        if (objCookie) {
            v_width =  parseInt(objCookie.width);
            v_height =  parseInt(objCookie.height);
            v_left =  parseInt(objCookie.left);
            v_top =  parseInt(objCookie.top);
        }

        g_ctrl_window[dlgId] = {isClose:false, 
            objCookie:objCookie,
            dlgURL:dlgURL,
            dlgTitle:dlgTitle,
            iconText:iconText,
            isSession:isSession};

        var v_retorna = false;
        $('.ui-dialog').each(function(i) {
            var id = $(this).find('.ui-dialog-content').attr('id');

            if (dlgId == id) {
                $('#'+id).html('<iframe width=100% height=99%  frameborder=0 name=frame_' + dlgId + ' id=frame_' + dlgId + '  onload="window.parent.PS.setShortcut(window.frames[\'frame_' + dlgId + '\'].document);"></iframe>');
				form.submit();
				
                if (!isMinimized) 
                    $('#'+id).dialog('moveToTop').dialog('restore');
                else
                    PS.minimize(id);

                v_retorna = true;
                $("#icon_text_"  + dlgId).html(iconText);
                $('a[rel="'+dlgId+'"]').attr('data-title', dlgTitle );
            }
        });

        if (v_retorna) {
            return;
        }

        var $dock = $('#dock'),
            idx = ( $dock.find('a').length == 0 ) ? 1 : parseInt($dock.find('a').last().attr('data-title-tmp')),
            tpl = '<a id="li_' + dlgId + '" class="dock-item" href="'+ dlgURL +'" rel="'+ dlgId +'" data-title="'+ dlgTitle +'" title="CTRL+'+idx+'" data-title-tmp="'+(idx+1)+'"><span>'+ iconText +'</span><img src="#" alt="'+ iconText +'" /></a>'; 
            //tpl =  [>'<li id="li_' + dlgId + '">'+<]
                //'<a id="li_' + dlgId + '" href="'+ dlgURL +'" class="dock-item" rel="'+ dlgId +'" data-title="'+ dlgTitle +'" title="CTRL+'+idx+'" data-title-tmp="'+(idx+1)+'">'+
                //'<span id="icon_text_' + dlgId + '">'+ iconText +'</span>' +
                //'<img src="/ct24h/trs/resources/img/as.png" alt="iconText" /></a>';

        $dock.find('.dock-container').append(tpl);

        var $addedItem = $('a[rel="'+dlgId+'"]'),
            $dialog = $('<div id="'+ dlgId +'"></div>'),			

            $link = $addedItem.one('click', function() {
                $dialog.html('<iframe width=100% height=99%  frameborder=0 name=frame_' + dlgId + ' id=frame_' + dlgId + ' onload="window.parent.PS.setShortcut(window.frames[\'frame_' + dlgId + '\'].document);"></iframe>')
                .dialog({
                    closeOnEscape: false,
                    title: $link.attr('data-title'),
                    width: v_width,
                    minWidth: 250,
                    height: v_height,
                    position: [v_left,v_top],
                    maximized:false,
                    minimized:true,
                    print: true,
                    show: 'fade',
                    hide: "bouncy",
                    focus: function(event,ui) {
                        g_id_focus  = dlgId;
                    },
					
                    close: function(event, ui) { 
                        g_ctrl_window[dlgId].isClose = true ;
                        if (g_unclosable) {
                            var v_ret = false;
                            for (var x = 0; x < g_unclosable.length ; x++) {
                                if (g_unclosable[x] == dlgId) {
                                    v_ret =true;
                                    break;	
                                }                                                             
                            }
                        }
                        if (v_ret) 
                            return;
                        $(this).dialog('destroy').remove();
                        $link.parent().remove();
                        $('#list li[rel="'+dlgId+'"]').remove();
                    }

                });

            $link.click(function() {
                if (g_ctrl_window[dlgId].isClose) {
                    PS.createPost(dlgId, 
                        dlgURL, 
                        dlgTitle, 
                        iconText, 
                        isSession);
                }
                g_ctrl_window[dlgId].isClose = false ;

                $dialog.dialog('moveToTop').dialog('restore');
                return false;
			});

            $(document).unbind('keydown', 'Ctrl+'+idx).bind('keydown', 'Ctrl+'+idx,function (evt){
                evt.preventDefault();

                if ($dialog.is(':visible'))
                $dialog.dialog('minimize');
                else
                $dialog.dialog('moveToTop').dialog('restore');

				});			
			});    
		
        $('a[rel="'+dlgId+'"]').trigger('click');

        $('.prev').addClass('disabled');

        // Atribui icone
        var v_icon = (g_iconeId[dlgId]) ? g_iconeId[dlgId] : "/ct24h/trs/resources/img/icon2.png" ;
        changeIcon(dlgId, v_icon); 

        $('#dock').Fisheye({
            maxWidth: 50,
            items: 'a',
            itemsText: 'span',
            container: '.dock-container',
            itemWidth: 45,
            proximity: 60,
            halign : 'center'
        });

        $('#carousel').tinycarousel();

        var list = $('#list');
        list.fadeOut(250)
            .find('ul').append('<li rel="'+dlgId+'"><span class="left">'+dlgTitle+'</span> <span class="shortcut">Ctrl+'+idx+'</span></li>');


        $(document).bind('mouseup', function(){
            if (list.is(':visible')){
                $('#list li').removeClass('list-active');
                list.fadeOut(300); // hide list
                active = -1; // reset navigation
            }
        });

        if (isMinimized) {
            PS.minimize(dlgId);
        }
		
		form.submit();
	},	
	
    minimize: function(id) {
        $('#'+id).dialog("minimize");
    },
    maximize: function(id) {

        $('#'+id).dialog({
            height: $(window).height()-140,
        width: $(window).width()-30,
        position: [10, 50]
        }).dialog('moveToTop').dialog('restore');

    },

    close: function (v_id) {

        // nao sera mais fechado - ate alterar abre e fecha
        return;
        /*
            $(this).dialog('
            destroy').remove();
            $link.parent().r
            emove();
            $('#list li[rel=
            "'+dlgId+'"]').remove();
            */

        $('.ui-dialog').each(function(i) {
            var id = $(this).find('.ui-dialog-content').attr('id');

            if (v_id == id) {
                $('#'+id).dialog('close');
                //$(document).unbind('keydown');
                //PS.setShortcut();
                //active = -1; // reset navigation

                //alert('teste');
            }
        });

    },

	list: function() {
	
		var tpl = '<ul>',
			list = $('#list')

		list.fadeIn('300');

		list.find('li').hover(
				function() { $(this).removeClass("list-hover"); $(this).addClass("list-hover"); active = $("#list li").indexOf($(this).get(0)); },
				function() { $(this).removeClass("list-hover"); });

		$('#list li').live('click', function(){
			PS.maximize( $(this).attr('rel') );
			$('#list li').removeClass('list-active');
			list.fadeOut(300); // hide list
			active = -1; // reset navigation
		});

        /*
        // hide list when mouse leave
        list.mouseleave(function(){
			$('#list li').removeClass('list-active');
			list.fadeOut(300); // hide list
			active = -1; // reset navigation
        });
        */
			
	},

	setShortcut: function(v_document) {

                if (!v_document) {
                    v_document = document;
                } else {
/*
                   $("<A HREF='Javascript:window.print()'>Imprimir</a>").
                      appendTo(v_document.body);
*/
                }
		var list = $('#list');

		$(v_document).bind('keydown', 'down', function(){			
			if(list.is(':visible') === true) PS.moveSelect(1);
		});

		$(v_document).bind('keydown', 'up', function(){			
			if(list.is(':visible') === true) PS.moveSelect(-1);
		});

		$(v_document).bind('keydown', 'return', function(){ 
			var id = list.find('.list-active').attr('rel');
			PS.maximize(id);
			$('#list li').removeClass('list-active');
			list.fadeOut(300); // hide list
			active = -1; // reset navigation			
		});

		$(v_document).bind('keydown', 'Ctrl+M',function (evt){
			evt.preventDefault();
			PS.mosaic();
		});

		$(v_document).bind('keydown', 'Ctrl+L',function (evt){
			evt.preventDefault();
			PS.list();
		});

		$(v_document).bind('keydown', 'ESC',function (evt){
			evt.preventDefault();
			if (list.is(':visible')) {				
				$('#list li').removeClass('list-active');
				list.fadeOut(300); // hide list
				active = -1; // reset navigation
			}
		});

/*
		$(v_document).bind('keydown', 'Ctrl+I',function (evt){
			evt.preventDefault();
			PS.create('cadastro'+($('#dock li').size()*54), 'app.html', 'Cadastro de cliente', 'Cadastro de cliente');
		});
*/
		$(v_document).bind('keydown', 'Ctrl+Shift+M',function (evt){
			evt.preventDefault();
			$('.ui-dialog').each(function(i){
				var id = $(this).find('.ui-dialog-content').attr('id');
				$('#'+id).dialog('minimize');
			});
		});

		$(v_document).bind('keydown', 'Ctrl+Shift+S',function (evt){
			evt.preventDefault();

			var tpl =   '<p><span class="key">Ctrl</span> + <span class="key">L</span> = Lista das janelas abertas </p>'+
			'<p><span class="key">Ctrl</span> + <span class="key">N</span> = Maximiza/Minimiza janela </p>'+
			'<p><span class="key">Ctrl</span> + <span class="key">0</span> = Fecha todas janelas </p>'+
			'<p><span class="key">Ctrl</span> + <span class="key">M</span> = Mosaico</p>'+
			'<p><span class="key">Ctrl</span> + <span class="key">Shift</span> + <span class="key">M</span> = Minimiza todas janelas</p>'+
			'<p><span class="key">Ctrl</span> + <span class="key">Shift</span> + <span class="key">S</span> = Atalhos (esta janela)'

			var $dlgShort = $('<div id="shortcut"></div>');
			$dlgShort.html(tpl);
			
			$dlgShort.dialog({
				resizable: false,
				maximized: false,
				minimized: false,
				height: 200,
				width: 400,
				modal: true,
				title: 'Atalhos',
				close: function(){
					//$(this).dialog('close').dialog('destroy');
					$('#shortcut').remove();
				}

			});

		});
			
		
		$(v_document).bind('keydown', 'Ctrl+0',function (evt){
			evt.preventDefault();

			var $dialog = $('<div id="dialog-confirm"></div>').html('<p>Deseja realmente fechar todas janelas?</p>');

			$dialog.dialog({
				resizable: false,
				maximized: false,
				minimized: false,
				height: 140,
				modal: true,
				title: 'Confirma&ccedil;&atilde;o?',
				buttons: {
					"Sim": function() {
						$('.ui-dialog').each(function(i){
							var id = $(this).find('.ui-dialog-content').attr('id');
							$('#'+id).dialog('close').remove();
							$(document).unbind('keydown');
							PS.setShortcut();
						});
						$(this).dialog('destroy').remove();
						
					},
					"Nao": function() {
						$(this).dialog('destroy').remove();
					}
				}
			});
			
		});

        $(v_document).bind('keydown', 'Ctrl+right',function (evt){
            evt.preventDefault();
            nextPreviousWindow(1);
        });


        $(v_document).bind('keydown', 'Ctrl+left',function (evt){
            evt.preventDefault();
            nextPreviousWindow(-1);
        });                      




		
	},

	moveSelect: function(step) {

		var lis = $("#list li");
		if (!lis) return;

		active += step;

		if (active < 0) {
			active = 0;
		} else if (active >= lis.size()) {
			active = lis.size() - 1;
		}

		lis.removeClass("list-active");

		$(lis[active]).addClass("list-active");

	},

        isMosaic: function() {
                return true;
        },
	mosaic: function(){
	
		var c,l=[];

		var pLeft = ($(window).width() - 850) / 2,
			pTop = 70;

		var dlg1 = [];
		dlg1[0] = pLeft;
	    dlg1[1] = pTop;

		var dlg2 = [];
		dlg2[0] = pLeft+300;
	    dlg2[1] = pTop;

		var dlg3 = [];
		dlg3[0] = pLeft+600;
	    dlg3[1] = pTop;

		var dlg4 = [];
		dlg4[0] = pLeft;
	    dlg4[1] = pTop+200;

		var dlg5 = [];
		dlg5[0] = pLeft+300;
	    dlg5[1] = pTop+200;

		var dlg6 = [];
		dlg6[0] = pLeft+600;
	    dlg6[1] = pTop+200;

	    var pos = [];
	    pos [0] = dlg1;
	    pos [1] = dlg2;
	    pos [2] = dlg3;
	    pos [3] = dlg4;
	    pos [4] = dlg5;
	    pos [5] = dlg6;

		$('.ui-dialog').each(function(i){

			var id = $(this).find('.ui-dialog-content').attr('id');
			
			$('#'+id).dialog({
				height: 150,
				//width: ($(window).width()-30)/3,
				width: 250,
				position: pos[i]
			}).dialog('restore');
			
		});
		
	}

};


;$(function(){

	PS.init();


});

function restaurarPerspectiva() {
 $('.ui-dialog').each(function(i){

    var id = $(this).find('.ui-dialog-content').attr('id');

    var v_cookies = readCookieWithId();

    var objCookie = v_cookies[id];

    if (objCookie) {
        v_width =  parseInt(objCookie.width);
        v_height =  parseInt(objCookie.height);
        v_left =  parseInt(objCookie.left);
        v_top =  parseInt(objCookie.top);
        $("#"+id).dialog("option","width", v_width);
        $("#"+id).dialog("option","height", v_height);
        $("#"+id).dialog("option","position",[v_left,v_top]);
    }


    /*

    var v_c = makeCookie( id,
                          $(this).width(),
                          $(this).height(),
                          $(this).position().left,
                          $(this).position().top);
    */


  });
}
function salvarPerspectiva() {
 var v_cookie = new Array();
 $('.ui-dialog').each(function(i){

    var id = $(this).find('.ui-dialog-content').attr('id');

    var v_c = makeCookie( id,
                          $(this).width(),
                          $(this).height(),
                          $(this).position().left,
                          $(this).position().top);


    v_cookie.push(v_c);
  });
  $.cookie("perspectiva", v_cookie.join("\n"), { expires: 999999});

  alert("Perspectiva Salva Com Sucesso");
}
function readCookieWithId() {
    var v_ret = new Array();
    var v_cookies = $.cookie("perspectiva");

    if (!v_cookies) {
        return v_ret;
    }

    var v_c = v_cookies.split("\n");

    for (var i=0;i<v_c.length;i++) {
        var v_linha = v_c[i].split("|");
        v_ret[v_linha[0]] = {width: v_linha[1],
                             height: v_linha[2],
                             left: v_linha[3],
                             top: v_linha[4]};
    }

    return v_ret;
}
function makeCookie(v_id, v_w, v_h, v_x, v_y) {
   var v_cookie = new Array();

    v_cookie.push(v_id);
    v_cookie.push(v_w);
    v_cookie.push(v_h);
    v_cookie.push(v_x);
    v_cookie.push(v_y);

   return v_cookie.join("|");
}
function setSessao(v_usrtip, v_empcod, v_usrcod, v_sesnum) {
    g_usrtip = v_usrtip;
    g_empcod = v_empcod;
    g_usrcod = v_usrcod;
    g_sesnum = v_sesnum;
}
function nextPreviousWindow(np) {
    var v_arr = new Array();
    $('.ui-dialog').each(function(i) {
        var id = $(this).find('.ui-dialog-content').attr('id');
        v_arr.push(id);
    });

    for (var i=0;i<v_arr.length;i++) {
         if (g_id_focus == v_arr[i]) {
             i+=np;

             if (i>=0 && i<v_arr.length) {
                 $("#"+ v_arr[i] ) .dialog("moveToTop");
             }
             break;
         }
    }
}
function changeIcon(v_id, v_newIcon) {

    // Atribui icone
    $('#li_' + v_id).find('img').attr('src', v_newIcon);

}

function formatDate(v_date) {
	var v_year = v_date.getFullYear();
	var v_month = v_date.getMonth()+1;
	var v_day = v_date.getDate();

	if (v_month < 10) {
		v_month = "0" + v_month ;
	}
	if (v_day < 10) {
		v_day = "0" + v_day ;
	}

	return v_day + "/" + v_month + "/" + v_year;

}



