#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema........: Central 24 Horas                                            #
# Modulo.........: cty41g00                                                    #
# Objetivo.......: Regras de Abertura de Assuntos Mercosul para a Azul         #
# Analista Resp. : Humberto Benedito                                           #
# PSI            :                                                             #
#..............................................................................#
# Desenvolvimento: R.Fornax                                                    #
# Liberacao      : 09/04/2015          Mercosul                                #
#..............................................................................#

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_prepare smallint


#----------------------------------------------#
 function cty41g00_prepare()
#----------------------------------------------#

  define l_sql char(500)

  let l_sql = ' select count(*)         '
          ,  '  from datkdominio        '
          ,  '  where cponom = ?        '
          ,  '  and   cpodes = ?        '
  prepare pcty41g00001 from l_sql
  declare ccty41g00001 cursor for pcty41g00001

  let l_sql =  ' select azlaplcod             '    
              ,' from datkazlapl              '
              ,' where succod     = ?         ' 
              ,' and   ramcod     = ?         '
              ,' and   aplnumdig  = ?         '
              ,' and   itmnumdig  = ?         '
              ,' and   edsnumdig  = ?         '           
   prepare pcty41g00002 from l_sql
   declare ccty41g00002 cursor for pcty41g00002


   let m_prepare = true

end function


#----------------------------------------------#
 function cty41g00(lr_param)
#----------------------------------------------#

define lr_param record
	c24astcod    like datkassunto.c24astcod,  
  succod       like datkazlapl.succod    ,       	
  ramcod    	 like datkazlapl.ramcod    ,
  aplnumdig 	 like datkazlapl.aplnumdig ,
  itmnumdig 	 like datkazlapl.itmnumdig ,
  edsnumdig 	 like datkazlapl.edsnumdig      
end record

define lr_retorno record
    confirma   char(01) ,
    doc_handle integer 
end record

initialize lr_retorno.* to null

    if m_prepare is null or
       m_prepare <> true then
       call cty41g00_prepare()
    end if

    if cty41g00_valida_assunto(lr_param.c24astcod) then

        call cty41g00_recupera_codigo(lr_param.succod    ,    
                                      lr_param.ramcod    ,
                                      lr_param.aplnumdig ,
                                      lr_param.itmnumdig ,
                                      lr_param.edsnumdig )
        returning lr_retorno.doc_handle 
        
        
        if not cty41g00_verifica_clausula(lr_retorno.doc_handle) then
        
            call cts08g01('A','N',''                     ,
                          'ATENDIMENTO NEGADO'           ,
                          'CONSULTE A COORDENACAO'       ,
                          'PARA O ENVIO DO ATENDIMENTO'  )
            returning lr_retorno.confirma
        
            return false
                   
  	    end if
  	    
  	end if
  	
  	return true

end function


#----------------------------------------------#
 function cty41g00_verifica_clausula(lr_param)
#----------------------------------------------#

define lr_param record
  doc_handle integer
end record

define lr_retorno record
	clscod     like abbmclaus.clscod ,
  cont       smallint              ,
  chave      char(20)              ,
  qtd        integer               ,
  tag        char(100)     
end record

define l_idx  integer

initialize lr_retorno.* to null

    
    let lr_retorno.chave = "cty41g00_clausula"  
    
    #--------------------------------------------------------                                        
    # Recupera os Dados da Clausula                                                                  
    #--------------------------------------------------------                                        
                                                                                                     
    let lr_retorno.qtd = figrc011_xpath(lr_param.doc_handle,"count(/APOLICE/CLAUSULAS/CLAUSULA)")

    for l_idx = 1 to lr_retorno.qtd

        let lr_retorno.tag = "/APOLICE/CLAUSULAS/CLAUSULA[", l_idx using "<<<<&","]/CODIGO"  
        let lr_retorno.clscod  = figrc011_xpath(lr_param.doc_handle,lr_retorno.tag)    
         
        #--------------------------------------------------------
        # Verifica se Clausula tem Permissao
        #--------------------------------------------------------
        
        open ccty41g00001  using  lr_retorno.chave  ,
                                  lr_retorno.clscod
        whenever error continue
        fetch ccty41g00001 into lr_retorno.cont
        whenever error stop
        
        if lr_retorno.cont > 0 then
        	 return true
        end if
    
    end for 

    return false


end function


#----------------------------------------------#
 function cty41g00_valida_assunto(lr_param)
#----------------------------------------------#

define lr_param record
	c24astcod    like datkassunto.c24astcod
end record


    if lr_param.c24astcod = "KM1" or 
       lr_param.c24astcod = "KM2" or
       lr_param.c24astcod = "KM3" then  
       return true   
    end if
   
    return false

end function

#----------------------------------------------#
 function cty41g00_recupera_codigo(lr_param)
#----------------------------------------------#

define lr_param record
	succod       like datkazlapl.succod    , 
  ramcod    	 like datkazlapl.ramcod    ,
  aplnumdig 	 like datkazlapl.aplnumdig ,
  itmnumdig 	 like datkazlapl.itmnumdig ,
  edsnumdig 	 like datkazlapl.edsnumdig
end record

define lr_retorno record
	azlaplcod  like datkazlapl.azlaplcod ,  
  doc_handle integer                    	
end record	

initialize lr_retorno.* to null
    
    #--------------------------------------------------------
    # Recupera Codigo do Segurado
    #--------------------------------------------------------

    open ccty41g00002  using lr_param.succod    ,    
                             lr_param.ramcod    ,
                             lr_param.aplnumdig ,
                             lr_param.itmnumdig ,
                             lr_param.edsnumdig                            
    whenever error continue
    fetch ccty41g00002 into lr_retorno.azlaplcod
    whenever error stop
    
    let lr_retorno.doc_handle = ctd02g00_agrupaXML(lr_retorno.azlaplcod)
   
    return lr_retorno.doc_handle

end function

