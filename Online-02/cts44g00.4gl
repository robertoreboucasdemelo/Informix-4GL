#############################################################################
# Nome do Modulo: CTS44g00                                         Ruiz     #
#                                                                  Sergio   #
# Validação de Clausulas por Apolice - Azul Seguros                DEZ/2006 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 14/12/2006  psi 205206   Sergio       Validação de Clausulas por Apolice. #
#---------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep_sql smallint
#------------------------------------------
function cts44g00_prepare()
#------------------------------------------
 define l_sql char(500)
 let l_sql  = ' select 1 '
             ,'  from datrasitipsrv '
             ,' where asitipcod = ? '
 prepare pcts44g0001 from l_sql
 declare ccts44g0001 cursor for pcts44g0001
 let l_sql = "select atdsrvorg from datrasitipsrv",
              " where atdsrvorg = ?  and       ",
              "       asitipcod = ?            "
 prepare pcts44g0002 from l_sql
 declare ccts44g0002 cursor for pcts44g0002
 let m_prep_sql = true
end function
#----------------------------------------#
 function cts44g00(lr_par)
#----------------------------------------#

     define lr_par    record
            succod    like datrligapol.succod,
            ramcod    like datrligapol.ramcod,
            aplnumdig like datrligapol.aplnumdig,
            itmnumdig like datrligapol.itmnumdig,
            edsnumref like datrligapol.edsnumref,
            clscod    like abbmclaus.clscod
     end record

     define l_par        smallint,
            l_qtd_end    smallint,
            l_ind        smallint,
            l_clscod     like abbmclaus.clscod,
            l_resultado  smallint,
            l_azlaplcod  integer,
            l_doc_handle integer,
            l_aux_char   char(50),
            l_mensagem   char(50)

     let l_par        = null
     let l_qtd_end    = null
     let l_ind        = null
     let l_clscod     = null
     let l_resultado  = null
     let l_azlaplcod  = null
     let l_doc_handle = null
     let l_aux_char   = null
     let l_mensagem   = null

     if lr_par.aplnumdig is not null then
        call ctd02g01_azlaplcod(lr_par.succod,
                                lr_par.ramcod,
                                lr_par.aplnumdig,
                                lr_par.itmnumdig,
                                lr_par.edsnumref)

             returning l_resultado,
                       l_mensagem,
                       l_azlaplcod

        # -> BUSCA O XML DA APOLICE
        let l_doc_handle = ctd02g00_agrupaXML(l_azlaplcod)

        if l_doc_handle is null then
           error "Nao encontrou o XML da apolice. AVISE A INFORMATICA ! " sleep 4
        end if

        let l_qtd_end = figrc011_xpath(l_doc_handle,"count(/APOLICE/CLAUSULAS/CLAUSULA)")

        for l_ind = 1 to l_qtd_end

            let l_aux_char = "/APOLICE/CLAUSULAS/CLAUSULA[", l_ind using "<<<<&","]/CODIGO"
            let l_clscod = figrc011_xpath(l_doc_handle, l_aux_char)

            if  l_clscod = lr_par.clscod then
                return true
            end if
        end for
     end if

   return false

end function
#----------------------------------------#
 function cts44g00_assunto_kmp(lr_par)
#----------------------------------------#
     define lr_par    record
            succod    like datrligapol.succod,
            ramcod    like datrligapol.ramcod,
            aplnumdig like datrligapol.aplnumdig,
            itmnumdig like datrligapol.itmnumdig,
            edsnumref like datrligapol.edsnumref,
            clscod    like abbmclaus.clscod
    end record
     define l_par        smallint,
            l_qtd_end    smallint,
            l_ind        smallint,
            l_clscod     like abbmclaus.clscod,
            l_resultado  smallint,
            l_azlaplcod  integer,
            l_doc_handle integer,
            l_aux_char   char(50),
            l_mensagem   char(50)
     let l_par        = null
     let l_qtd_end    = null
     let l_ind        = null
     let l_clscod     = null
     let l_resultado  = null
     let l_azlaplcod  = null
     let l_doc_handle = null
     let l_aux_char   = null
     let l_mensagem   = null
     if lr_par.aplnumdig is not null then
        call ctd02g01_azlaplcod(lr_par.succod,
                                lr_par.ramcod,
                                lr_par.aplnumdig,
                                lr_par.itmnumdig,
                                lr_par.edsnumref)
             returning l_resultado,
                       l_mensagem,
                       l_azlaplcod
        # -> BUSCA O XML DA APOLICE
        let l_doc_handle = ctd02g00_agrupaXML(l_azlaplcod)
        if l_doc_handle is null then
           error "Nao encontrou o XML da apolice. AVISE A INFORMATICA ! " sleep 4
        end if
        let l_qtd_end = figrc011_xpath(l_doc_handle,"count(/APOLICE/CLAUSULAS/CLAUSULA)")
        for l_ind = 1 to l_qtd_end
            let l_aux_char = "/APOLICE/CLAUSULAS/CLAUSULA[", l_ind using "<<<<&","]/CODIGO"
            let l_clscod = figrc011_xpath(l_doc_handle, l_aux_char)
            if  l_clscod = lr_par.clscod then
                return true
            end if
        end for
     end if
   return false
end function
#-----------------------------------------------------------
 function cts44g00_assistencia_azul(param)
#-----------------------------------------------------------
 define param      record
        atdsrvorg  like datksrvtip.atdsrvorg
 end record
 define a_cts44g00 array[50] of record
        asitipdes  like datkasitip.asitipdes,
        asitipcod  like datkasitip.asitipcod
 end record
 define arr_aux smallint
 define ws         record
       sql         char (100),
       atdsrvorg   like datksrvtip.atdsrvorg,
       asitipcod   like datkasitip.asitipcod
 end record
	define	w_pf1	integer
	let	arr_aux  =  null
	for	w_pf1  =  1  to  50
		initialize  a_cts44g00[w_pf1].*  to  null
	end	for
	initialize  ws.*  to  null
 let int_flag = false
 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts44g00_prepare()
 end if
 let arr_aux  = 1
 initialize a_cts44g00   to null
 declare ccts44g0003 cursor for
    select asitipdes, asitipcod
      from datkasitip
     where asitipstt = "A"
     order by asitipdes
 foreach ccts44g0003 into a_cts44g00[arr_aux].asitipdes,
                          a_cts44g00[arr_aux].asitipcod
   if g_documento.ciaempcod = 35 then  # Azul Seguros
       if a_cts44g00[arr_aux].asitipcod = 63 or
          a_cts44g00[arr_aux].asitipcod = 80 then # Lei Seca
          continue foreach
       end if
   end if
    ------------------------------------------------------------------
    if param.atdsrvorg is not null  then
       if param.atdsrvorg <> 0 then
          open  ccts44g0002 using param.atdsrvorg,
                                  a_cts44g00[arr_aux].asitipcod
          fetch ccts44g0002
	          if sqlca.sqlcode = notfound  then
	             continue foreach
	          end if
          close ccts44g0002
       else
          open ccts44g0001 using a_cts44g00[arr_aux].asitipcod
          fetch ccts44g0001
          if sqlca.sqlcode = 100 then
             continue foreach
          end if
       end if
    end if
    let arr_aux = arr_aux + 1
    if arr_aux > 50  then
       error " Limite excedido. Foram encontrados mais de 50 tipos de assistencia!"
       exit foreach
    end if
 end foreach
 if arr_aux > 1  then
    if arr_aux = 2  then
       let ws.asitipcod = a_cts44g00[arr_aux - 1].asitipcod
    else
       open window cts44g00 at 12,52 with form "ctn25c00"
                            attribute(form line 1, border)
       message " (F8)Seleciona"
       call set_count(arr_aux-1)
       display array a_cts44g00 to s_ctn25c00.*
          on key (interrupt,control-c)
             initialize a_cts44g00     to null
             initialize ws.asitipcod to null
             exit display
          on key (F8)
             let arr_aux = arr_curr()
             let ws.asitipcod = a_cts44g00[arr_aux].asitipcod
             exit display
       end display
       let int_flag = false
       close window cts44g00
    end if
 else
    initialize ws.asitipcod to null
    error " Nao foi encontrado nenhum tipo de assistencia!"
 end if
 return ws.asitipcod
end function  ###  cts44g00
#----------------------------------------
function cts44g00_motivos_clau_azul(lr_param)
#----------------------------------------
define lr_param   record
       asitipcod  like datmservico.asitipcod,
       clscod     like aackcls.clscod
end record
define l_motivos char(400)
      ,l_cabec   char(60)
      ,l_opcao   like datkasimtv.asimtvcod
   let l_motivos  = null
   let l_cabec    = "MOTIVOS"
   let l_opcao    = null
   if lr_param.clscod = "37E" or
      lr_param.clscod = "37G" then
      if lr_param.asitipcod = 5 then
         let l_motivos = "1 - RETORNO A DOMICILIO|2 - CONTINUACAO DE VIAGEM|3 - RECUPERACAO DE VEICULO|4 - OUTROS|9 - TAXI CID. DOMICILIO|13 - FURTO E ROUBO"
      end if
      if lr_param.asitipcod = 10 then
         let l_motivos = "1 - RETORNO A DOMICILIO|2 - CONTINUACAO DE VIAGEM|3 - RECUPERACAO DE VEICULO|13 - FURTO E ROUBO"
      end if
      if lr_param.asitipcod = 11 then
         let l_motivos = "4 - OUTROS|6 - SOLICITACAO MEDICA"
      end if
      if lr_param.asitipcod = 12 then
         let l_motivos = "4 - OUTROS|7 - OBITO"
      end if
      if lr_param.asitipcod = 16 then
         let l_motivos = "1 - RETORNO A DOMICILIO|2 - CONTINUACAO DE VIAGEM|3 - RECUPERACAO DE VEICULO|13 - FURTO E ROUBO"
      end if
   end if
   
   
   if lr_param.clscod = "37F" or
      lr_param.clscod = "37D" then
      
      
      if lr_param.asitipcod = 5 then
         let l_motivos = "1 - RETORNO A DOMICILIO|2 - CONTINUACAO DE VIAGEM|3 - RECUPERACAO DE VEICULO|4 - OUTROS|13 - FURTO E ROUBO"
      end if
      if lr_param.asitipcod = 10 then
         let l_motivos = "1 - RETORNO A DOMICILIO|2 - CONTINUACAO DE VIAGEM|3 - RECUPERACAO DE VEICULO|13 - FURTO E ROUBO"
      end if
      if lr_param.asitipcod = 11 then
         let l_motivos = "4 - OUTROS|6 - SOLICITACAO MEDICA"
      end if
      if lr_param.asitipcod = 12 then
         let l_motivos = "4 - OUTROS|7 - OBITO"
      end if
      if lr_param.asitipcod = 16 then
         let l_motivos = "1 - RETORNO A DOMICILIO|2 - CONTINUACAO DE VIAGEM|3 - RECUPERACAO DE VEICULO|13 - FURTO E ROUBO"
      end if
   end if
   
   if lr_param.clscod = "37H" then
     if lr_param.asitipcod = 5 then
        let l_motivos = "1 - RETORNO A DOMICILIO|2 - CONTINUACAO DE VIAGEM|3 - RECUPERACAO DE VEICULO|13 - FURTO E ROUBO"
     end if    
     if lr_param.asitipcod = 10 then                                                                                         
        let l_motivos = "1 - RETORNO A DOMICILIO|2 - CONTINUACAO DE VIAGEM|3 - RECUPERACAO DE VEICULO|13 - FURTO E ROUBO"   
     end if                                                                                                                 
     if lr_param.asitipcod = 11 then                       
        let l_motivos = "4 - OUTROS|6 - SOLICITACAO MEDICA"
     end if     
     if lr_param.asitipcod = 16 then                                                                                                                                 
        let l_motivos = "1 - RETORNO A DOMICILIO|2 - CONTINUACAO DE VIAGEM|3 - RECUPERACAO DE VEICULO|13 - FURTO E ROUBO" 
     end if
     if lr_param.asitipcod = 12 then                                                                                                                                     
        let l_motivos = "4 - OUTROS|7 - OBITO"            
     end if                                                 
   end if
   
   
   call ctx14g01_motivos_azul(l_cabec,l_motivos)
         returning l_opcao    
      
  return l_opcao
end function