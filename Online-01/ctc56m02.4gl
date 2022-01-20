###############################################################################
# Nome do Modulo: CTC56M02                                              Raji  #
#                                                                             #
# Exibe pop-up para selecao da clausula                              Fev/2002 #
###############################################################################
#                          MANUTENCOES
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
# 25/09/06   Ligia Mattge  PSI 202720 Implementando grupo/cartao saude        #
# 16/11/06   Ligia Mattge  PSI 205206 ciaempcod                               #
#-----------------------------------------------------------------------------#
# 17/08/2007 Ana Raquel,Meta PSI211915 Inclusao de Union na entidade          #
#                                      rgfkmrsapccls                          #
#-----------------------------------------------------------------------------#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
function ctc56m02(param)
#-----------------------------------------------------------
 define param record
    ciaempcod  like datkclstxt.ciaempcod,
    ramcod     like datkclstxt.ramcod,
    rmemdlcod  like datkclstxt.rmemdlcod,
    ramgrpcod  like gtakram.ramgrpcod
 end record

 define a_ctc56m02 array[200] of record
    clsdes     like aackcls.clsdes,
    clscod     like datkclstxt.clscod
 end    record

 define ws record
    autramflg  char(1),
    vidramflg  char(1),
    traramflg  char(1),
    sauramflg  char(1),
    comando    char(200)
 end record

 define ret_clscod like datkclstxt.clscod
 define l_flag smallint

 define arr_aux    integer


	define	w_pf1	integer

	let	ret_clscod  =  null
	let	arr_aux  =  null

	for	w_pf1  =  1  to  200
		initialize  a_ctc56m02[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 open window ctc56m02 at 08,12 with form "ctc56m02"
                      attribute(form line 1, border)

 let int_flag = false
 initialize  a_ctc56m02   to null
 initialize  ret_clscod   to null
 let l_flag = 0

 if param.ciaempcod = 1  or   ## psi 205206
    param.ciaempcod = 50 then ## Saude       

    #-----------------------------------------------------
    # Verifica se apolice e' de Auto, Vida ou de Transporte, Saude
    #-----------------------------------------------------
    let ws.autramflg = "n"
    if param.ramcod = 31    or 
       param.ramcod = 531   then
       let ws.autramflg = "s"
    end if
   
    let ws.vidramflg = "n"
    if param.ramcod = 57   or  param.ramcod = 457  or
       param.ramcod = 80   or  param.ramcod = 981  or
       param.ramcod = 81   or  param.ramcod = 982  or
       param.ramcod = 83   or  param.ramcod = 589  or
       param.ramcod = 91   or  param.ramcod = 991  or
       param.ramcod = 93   or  param.ramcod = 993  or  
       param.ramcod = 1391 or  param.ramcod = 1329 or
       param.ramcod = 977  or  param.ramcod = 980  or
       param.ramcod = 990 then
       let ws.vidramflg = "s"
    end if
   
    let ws.traramflg = "n"
    if param.ramcod = 21   or  param.ramcod = 621 or
       param.ramcod = 22   or  param.ramcod = 622 or
       param.ramcod = 24   or  param.ramcod = 632 or
       param.ramcod = 25   or  param.ramcod = 525 or
       param.ramcod = 33   or  param.ramcod = 433 or
       param.ramcod = 35   or  param.ramcod = 435 or
       param.ramcod = 52   or  param.ramcod = 652 or
       param.ramcod = 54   or  param.ramcod = 654 or
       param.ramcod = 55   or  param.ramcod = 655 or
       param.ramcod = 56   or  param.ramcod = 656 then
       let ws.traramflg = "s"
    end if
   
    let ws.sauramflg = "n"
    if param.ramgrpcod = 5 then ## Saude
       let ws.sauramflg = "s"
    end if
   
    if ws.autramflg  =  "s"    then
       let ws.comando = "select distinct clscod, clsdes",
                        "  from aackcls       ",
                        " where ramcod = ?    ",
                        "   and ramcod > ?    "
    else
       if ws.traramflg  =  "n"    then
   
          if ws.vidramflg  =  "s"   then
             let ws.comando = "select clscod, clsdes",
                              "  from rgfkclaus     ",
                              " where ramcod    = ? ",
                              "   and rmemdlcod = ? "
          else
             if ws.sauramflg = 's' then ### Saude   ### PSI 202720
                let ws.comando = "select plncod, plndes",
                                 "  from datkplnsau     ",
                                 "  order by 1     "
             else
                let l_flag = 1
                let ws.comando = "select clscod, clsdes",
                                  " from rgfkclaus2    ",
                                 " where ramcod    = ? ",
                                   " and rmemdlcod = ? ",
                                 " union ",
                                 "select clscod, clsdes ",
                                  " from rgfkmrsapccls ",
                                 " where ramcod = ? ",
                                   " and rmemdlcod = ? "
             end if
          end if
   
       else   
          let l_flag = 1
          let ws.comando = "select clscod, clsdes",
                            " from rgfkclaus2    ",
                           " where ramcod    = ? ",
                             " and rmemdlcod = ? ",
                           " union ",
                           "select clscod, clsdes ",
                            " from rgfkmrsapccls ",
                           " where ramcod = ? ",
                             " and rmemdlcod = ? "
       end if
    end if
   
    prepare comando_aux1      from  ws.comando
    declare c_ctc56m02 cursor for comando_aux1

    ### PSI 202720
    if ws.sauramflg = 's' then
       open c_ctc56m02
    else
       if l_flag = 0 then
          open c_ctc56m02 using param.ramcod,
                                param.rmemdlcod
       else
          open c_ctc56m02 using param.ramcod,
                                param.rmemdlcod,
                                param.ramcod,   
                                param.rmemdlcod
       end if
    end if
 
    let arr_aux  = 1
 
    foreach c_ctc56m02 into a_ctc56m02[arr_aux].clscod,
                            a_ctc56m02[arr_aux].clsdes
 
       let arr_aux = arr_aux + 1
       if arr_aux  >  200   then
          error "Limite excedido, tabela de textos para clausulas com mais de 200 itens!"
          exit foreach
       end if
 
    end foreach
 
 else
    if param.ciaempcod = 35 then  #psi 205206
       ## obter as clausulas da azul 
       declare c_datkgeral cursor for
        select grlchv[10,12], grlinf
          from datkgeral
         where grlchv[1,9] = "CLS.AZUL."
         order by 2

       let arr_aux = 1
    
       foreach c_datkgeral into a_ctc56m02[arr_aux].clscod,
                                a_ctc56m02[arr_aux].clsdes
      
          let arr_aux = arr_aux + 1
      
          if arr_aux > 100  then
             error " Limite excedido! Foram encontrados mais de 100 dominios!"
             exit foreach
          end if
      
       end foreach 
    end if
 end if

 message " (F17)Abandona, (F8)Seleciona"
 call set_count(arr_aux-1)

 display array a_ctc56m02 to s_ctc56m02.*

    on key (interrupt,control-c)
       initialize a_ctc56m02   to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       let ret_clscod = a_ctc56m02[arr_aux].clscod
       exit display

 end display

 close window ctc56m02
 let int_flag = false
 return ret_clscod

end function  #  ctc56m02

#---------------------------------------------#
function ctc56m02_popup_azul()
#---------------------------------------------#
 
 define lr_popup       record 
        lin            smallint   # Nro da linha
       ,col            smallint   # Nro da coluna
       ,titulo         char (054) # Titulo do Formulario
       ,tit2           char (012) # Titulo da 1a.coluna
       ,tit3           char (040) # Titulo da 2a.coluna
       ,tipcod         char (001) # Tipo do Codigo a retornar
                                  # 'N' - Numerico
                                  # 'A' - Alfanumerico
       ,cmd_sql        char (1999)# Comando SQL p/ pesquisa
       ,aux_sql        char (200) # Complemento SQL apos where
       ,tipo           char (001) # Tipo de Popup
                                  # 'D' Direto
                                  # 'E' Com entrada 
 end  record
 
 define lr_retorno     record
        erro           smallint,
        codigo         char(3),
        descricao      char(30)
 end record
 
 initialize lr_retorno.*  to  null
 initialize lr_popup.*    to  null
   
 let lr_popup.lin    = 6
 let lr_popup.col    = 2
 let lr_popup.titulo = "Azul"
 let lr_popup.tit2   = "Codigo"
 let lr_popup.tit3   = "Descricao"
 let lr_popup.tipcod = "N"
 let lr_popup.cmd_sql = "select grlchv[10,12], grlinf ",
                        "  from datkgeral ",
                        " where  grlchv[1,9] = 'CLS.AZUL.'" ,
                        " order by 1 "
 let lr_popup.tipo   = "D"
     
 call ofgrc001_popup(lr_popup.*)
      returning lr_retorno.*
      
 if lr_retorno.erro = 0 then
    let lr_retorno.erro = 1
 else
    if lr_retorno.erro = 1 then
       let lr_retorno.erro = 2
    else
       let lr_retorno.erro = 3
    end if
 end if
 
 let int_flag = false

 return lr_retorno.*
 
end function
