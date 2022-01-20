#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Seguro Residencia - Itau Seguros                          #
# Modulo.........: cty25g00                                                  #
# Objetivo.......: Atendimento Itau Seguros para Seguro Residencia           #
# Analista Resp. : Junior (FORNAX)                                           #
# PSI            :                                                           #
#............................................................................#
# Desenvolvimento: Junior (FORNAX)                                           #
# Liberacao      :   /  /                                                    #
#............................................................................#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_cty25g00_prepare  smallint

define mr_array array[1000] of record
       itaaplitmnum  like datmitaaplitm.itaaplitmnum 
end record

define mr_array2 array[500] of record
       seta              smallint                        ,
       segnom            like datmitaapl.segnom          ,
       itaaplvigincdat   like datmitaapl.itaaplvigincdat ,
       itaaplvigfnldat   like datmitaapl.itaaplvigfnldat 
end record

define mr_array_aux array[500] of record
       sitdoc            char(10)                        ,
       adniclhordat      date                            ,
       documento         char(20)                       
end record

define mr_retorno array[500] of record
       itaciacod     like datmitaapl.itaciacod       ,
       itaramcod     like datmitaapl.itaramcod       ,
       itaaplnum     like datmitaapl.itaaplnum       ,
       aplseqnum     like datmitaapl.aplseqnum       ,
       itaaplitmnum  like datmitaaplitm.itaaplitmnum ,
       succod        like datmitaapl.succod          ,
       cgccpfnum     like datkitavippes.cgccpfnum    ,
       cgccpford     like datkitavippes.cgccpford    ,
       cgccpfdig     like datkitavippes.cgccpfdig
end record

define m_index integer
define m_segnom like datmitaapl.segnom

#------------------------------------------------------------------------------
function cty25g00_prepare()
#------------------------------------------------------------------------------

define l_sql char(2000)

   let l_sql = " select count(*)     ",
	       " from datmresitaapl   ",
	       " where itaciacod = ? ",
	       " and   itaramcod = ? ",
	       " and   aplnum    = ? "
   prepare p_cty25g00_001  from l_sql
   declare c_cty25g00_001  cursor for p_cty25g00_001

   let l_sql = " select  a.aplitmnum, " ,
	       "         b.succod        " ,
	       " from datmresitaaplitm a, datmresitaapl b ",
	       " where a.itaciacod = b.itaciacod        ",
	       " and   a.itaramcod = b.itaramcod        ",
	       " and   a.aplnum    = b.aplnum           ",
	       " and   a.aplseqnum = b.aplseqnum        ",
	       " and   a.itaciacod = ? "  ,
	       " and   a.itaramcod = ? "  ,
	       " and   a.aplnum    = ? "  ,
	       " and   a.aplseqnum = ? "
   prepare p_cty25g00_002  from l_sql
   declare c_cty25g00_002  cursor for p_cty25g00_002

   let l_sql = " select a.aplitmnum, " ,
	       "        b.succod        " ,
	       " from datmresitaaplitm a,  " ,
	       "      datmresitaapl b      " ,
	       " where a.itaciacod = b.itaciacod    "  ,
	       " and   a.itaramcod = b.itaramcod    "  ,
	       " and   a.aplnum    = b.aplnum       "  ,
	       " and   a.aplseqnum = b.aplseqnum    "  ,
	       " and   a.itaciacod    = ? " ,
	       " and   a.itaramcod    = ? " ,
	       " and   a.aplnum       = ? " ,
	       " and   a.aplseqnum    = ? " ,
	       " and   a.aplitmnum    = ? "
   prepare p_cty25g00_003  from l_sql
   declare c_cty25g00_003  cursor for p_cty25g00_003

   let l_sql = " select a.itaciacod  ,                      ",
	       "        a.itaramcod  ,                      ",
	       "        a.aplnum     ,                      ",
	       "        a.aplseqnum  ,                      ",
	       "        a.succod     ,                      ",
	       "  a.incvigdat        ,                      ",
	       "  a.fnlvigdat        ,                      ",
	       "     a.adnicldat     ,                      ",
	       "     a.segnom                               ",
	       " from datmresitaapl a                       ",
	       " where a.segnom matches '", m_segnom ,"'    ",
	       " and a.aplseqnum = (select max(b.aplseqnum) ",
	       " from datmresitaapl b                       ",
	       " where a.itaciacod = b.itaciacod            ",
	       " and   a.itaramcod = b.itaramcod            ",
	       " and   a.aplnum    = b.aplnum)              ",
	       " order by a.segnom, a.fnlvigdat desc        "

   prepare p_cty25g00_004  from l_sql
   declare c_cty25g00_004  cursor for p_cty25g00_004 

   let l_sql = " select aplitmnum " ,
	       " from datmresitaaplitm " ,
	       " where itaciacod = ? "  ,
	       " and   itaramcod = ? "  ,
	       " and   aplnum    = ? "  ,
	       " and   aplseqnum = ? "  ,
	       " order by aplitmnum "
   prepare p_cty25g00_005  from l_sql
   declare c_cty25g00_005  cursor for p_cty25g00_005


   let l_sql = " select max(aplseqnum) " ,
	       " from datmresitaapl " ,
	       " where itaciacod = ?   " ,
	       " and   itaramcod = ?   " ,
	       " and   aplnum    = ?   "
   prepare p_cty25g00_006  from l_sql
   declare c_cty25g00_006  cursor for p_cty25g00_006

   let l_sql = " select incvigdat, " ,
	       "        fnlvigdat  " ,
	       " from datmresitaapl       " ,
	       " where itaciacod = ?     " ,
	       " and   itaramcod = ?     " ,
	       " and   aplnum    = ?     " ,
	       " and   aplseqnum = ?     "
   prepare p_cty25g00_007  from l_sql
   declare c_cty25g00_007  cursor for p_cty25g00_007

   let l_sql = " select a.itaciacod  ,                    ",
	       "        a.itaramcod  ,                    ",
	       "        a.aplnum     ,                    ",
	       "        a.aplseqnum  ,                    ",
	       "        a.succod                          ",
	       " from datmresitaapl a                     ",
	       " where a.prpnum = ?                       ",
	       " and aplseqnum = (select max(b.aplseqnum) ",
	       " from datmresitaapl b           ",
	       " where a.prpnum = b.prpnum)         "
   prepare p_cty25g00_008 from l_sql
   declare c_cty25g00_008 cursor for p_cty25g00_008
   
   let l_sql = " select grpivcqtd, ntzivcqtd ",             
                  " from datrntzasipln where asiplncod = ?  "              
   prepare p_cty25g00_010  from l_sql                  
   declare c_cty25g00_010  cursor for p_cty25g00_010     
   
   let l_sql = "  select cornom               ",
               "  from gcaksusep a,           ",                         
               "       gcakcorr b             ",                         
               "where a.corsus  = ?           ",                         
               "and a.corsuspcp = b.corsuspcp "                          
   prepare p_cty25g00_011  from l_sql                                    
   declare c_cty25g00_011  cursor for p_cty25g00_011
   
   let l_sql = " select itmsttcod ",	       
	       " from datmresitaaplitm  " ,
	       " where itaciacod = ?    " ,
	       " and   itaramcod = ?    " ,
	       " and   aplnum    = ?    " ,
         " and   aplitmnum = ?    " ,	       
	       " and   aplseqnum = ?    "
   prepare p_cty25g00_012  from l_sql
   declare c_cty25g00_012  cursor for p_cty25g00_012 
   
   
   let m_cty25g00_prepare = true
                                                          
   
end function
#------------------------------------------------------------------------------
function cty25g00_qtd_apolice(lr_param)
#------------------------------------------------------------------------------

 define lr_param record
    itaciacod     like datmitaapl.itaciacod,
    itaramcod     like datmitaapl.itaramcod,
    aplnum        like datmresitaapl.aplnum
 end record

 define lr_retorno integer

 if m_cty25g00_prepare is null or
    m_cty25g00_prepare <> true then
    call cty25g00_prepare()
 end if

 initialize lr_retorno to null

 let lr_retorno = 0

 open c_cty25g00_001 using lr_param.itaciacod ,
			   lr_param.itaramcod ,
			   lr_param.aplnum
      whenever error continue
 fetch c_cty25g00_001 into lr_retorno
       whenever error stop
 close c_cty25g00_001

 return lr_retorno

end function
#------------------------------------------------------------------------------
function cty25g00_itm_apolice(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaciacod     like datmitaapl.itaciacod       ,
   itaramcod     like datmitaapl.itaramcod       ,
   aplnum        like datmresitaapl.aplnum          ,
   aplseqnum     like datmitaapl.aplseqnum       ,
   aplitmnum     like datmresitaaplitm.aplitmnum
end record

define lr_retorno record
   aplitmnum     like datmresitaaplitm.aplitmnum    ,
   succod        like datmitaapl.succod          ,
   erro          integer                         ,
   mensagem      char(50)
end record

initialize lr_retorno.* to null

 for  m_index  =  1  to  1000
    initialize  mr_array[m_index].* to  null
 end  for

 let lr_retorno.erro = 0

 if lr_param.aplitmnum is null then

    let m_index = 1

    open  c_cty25g00_002 using lr_param.itaciacod,
			       lr_param.itaramcod,
			       lr_param.aplnum   ,
			       lr_param.aplseqnum


    foreach c_cty25g00_002 into mr_array[m_index].itaaplitmnum ,
				lr_retorno.succod

	    let m_index = m_index + 1


	    if m_index > 1000 then

	       message "Limite excedido. Foram Encontrados mais de 1000 Itens!"
                    
               exit foreach

            end if

    end foreach

    if m_index > 2 then
       call cty25g00_display()
       returning lr_retorno.aplitmnum

       if lr_retorno.aplitmnum is null then
          let lr_retorno.erro     = 1
       end if
    else
       let lr_retorno.aplitmnum = mr_array[m_index - 1].itaaplitmnum
    end if
 else
    open c_cty25g00_003 using lr_param.itaciacod   ,
			      lr_param.itaramcod   ,
			      lr_param.aplnum      ,
			      lr_param.aplseqnum   ,
			      lr_param.aplitmnum

         whenever error continue
    fetch c_cty25g00_003 into lr_retorno.aplitmnum,
			      lr_retorno.succod
          whenever error stop

	  if sqlca.sqlcode <> 0  then

	     if sqlca.sqlcode = notfound  then

	        let lr_retorno.mensagem = "Item da Apolice nao Encontrada!"

	        let lr_retorno.erro     = 1

             else

		let lr_retorno.mensagem =  "Erro ao selecionar o cursor c_cta25g00_003 ", sqlca.sqlcode
                let lr_retorno.erro     =  sqlca.sqlcode

	     end if

          end if

	  close c_cty25g00_003

 end if
 
 return lr_retorno.aplitmnum ,
        lr_retorno.succod    ,
	lr_retorno.erro      ,
        lr_retorno.mensagem

end function
#------------------------------------------------------------------------------
function cty25g00_display()
#------------------------------------------------------------------------------

   define lr_retorno record
             aplitmnum  like datmresitaaplitm.aplitmnum
   end record

   initialize lr_retorno.* to null

   open window cta00m29 at 08,14 with form "cta00m29"
        attribute (border,form line 1)

   message " (F17)Abandona, (F8)Seleciona"
   call set_count(m_index-1)
   display array mr_array to s_cta00m29.*

     on key (interrupt,control-c)
        initialize mr_array to null
        let lr_retorno.aplitmnum = null
        exit display
										     on key (f8)
	let m_index = arr_curr()
	let lr_retorno.aplitmnum = mr_array[m_index].itaaplitmnum
        exit display
   end display

   close window cta00m29
   let int_flag = false
   return lr_retorno.aplitmnum

end function

#------------------------------------------------------------------------------
function cty25g00_rec_ult_sequencia(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaciacod     like datmitaapl.itaciacod,
   itaramcod     like datmitaapl.itaramcod,
   itaaplnum     like datmitaapl.itaaplnum
end record

define lr_retorno record
    aplseqnum     like datmitaapl.aplseqnum,
    erro          integer                  ,
    mensagem      char(50)
end record

   if m_cty25g00_prepare is null or
      m_cty25g00_prepare <> true then
      call cty25g00_prepare()
   end if

   initialize lr_retorno.* to null
   let lr_retorno.erro = 0

   
   open c_cty25g00_006 using lr_param.itaciacod ,
			     lr_param.itaramcod ,
		             lr_param.itaaplnum
	     whenever error continue
   fetch c_cty25g00_006 into lr_retorno.aplseqnum

         whenever error stop
         if sqlca.sqlcode <> 0  then
	    if sqlca.sqlcode = notfound  then
	       let lr_retorno.mensagem = "Sequencia da Apolice nao Encontrada!"
	       let lr_retorno.erro     = 1
	    else
	       let lr_retorno.mensagem = "Erro ao selecionar o cursor c_cty25g00_002 ", sqlca.sqlcode
               let lr_retorno.erro     = sqlca.sqlcode
	    end if
         end if
   close c_cty25g00_006

   return lr_retorno.aplseqnum,
          lr_retorno.erro     ,
	  lr_retorno.mensagem

end function			
#------------------------------------------------------------------------------
function cty25g00_ver_vigencia_apolice(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaciacod     like datmitaaplitm.itaciacod ,
   itaramcod     like datmitaaplitm.itaramcod ,
   aplnum        like datmresitaapl.aplnum    ,
   aplseqnum     like datmitaaplitm.aplseqnum
end record

define lr_retorno record
   incvigdat        like datmresitaapl.incvigdat ,
   fnlvigdat        like datmresitaapl.fnlvigdat ,
   linha1           char(40)                     ,
   linha2           char(40)                     ,
   linha3           char(40)                     ,
   linha4           char(40)                     ,
   confirma         char(01)
end record

  if m_cty25g00_prepare is null or
     m_cty25g00_prepare <> true then
     call cty25g00_prepare()
  end if 

  initialize lr_retorno.* to null


     open c_cty25g00_007 using lr_param.itaciacod,
			       lr_param.itaramcod,
			       lr_param.aplnum   ,
			       lr_param.aplseqnum
          whenever error continue
     fetch c_cty25g00_007 into lr_retorno.incvigdat,
			       lr_retorno.fnlvigdat

	  whenever error stop
          if sqlca.sqlcode = notfound  then
	     error "Segurado nao encontrado"
	     return false
          else 
             if sqlca.sqlcode <> 0  then
	        error "Erro ao Selecionar o Cursor c_cty25g00_007 ", sqlca.sqlcode
	        return false
	     end if
	  end if
	  close c_cty25g00_007

        if lr_retorno.incvigdat <= today and
           lr_retorno.fnlvigdat  >= today then
           return true
        else
	          
	         let lr_retorno.linha1 = "ESTA APOLICE ESTA VENCIDA"
           let lr_retorno.linha1 = "ESTA APOLICE ESTA VENCIDA"
           let lr_retorno.linha2 = "PROCURE UMA APOLICE VIGENTE"
           let lr_retorno.linha3 = "OU CONSULTE A SUPERVISAO."
           let lr_retorno.linha4 = "DESEJA PROSSEGUIR?"
   
           call cts08g01("C","S",lr_retorno.linha1,
			         lr_retorno.linha2,
			         lr_retorno.linha3,
			         lr_retorno.linha4)
	        returning lr_retorno.confirma
   
	        if lr_retorno.confirma = "S" then
	           return true
	        else
	           return false
	        end if
        end if

end function
#------------------------------------------------------------------------------
function cty25g00_rec_apolice_por_proposta(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   prpnum        like datmresitaapl.prpnum
end record

define lr_retorno record
   itaciacod     like datmitaaplitm.itaciacod ,
   itaramcod     like datmitaaplitm.itaramcod ,
   aplnum        like datmresitaapl.aplnum    ,
   aplseqnum     like datmresitaapl.aplseqnum ,
   aplitmnum     like datmresitaaplitm.aplitmnum ,
   succod        like datmresitaapl.succod       ,
   erro          integer                      ,
   mensagem      char(50)
end record

   if m_cty25g00_prepare is null or
      m_cty25g00_prepare <> true then
      call cty25g00_prepare()
   end if

   initialize lr_retorno.* to null
   let lr_retorno.erro = 0

      open c_cty25g00_008 using lr_param.prpnum
      whenever error continue
      fetch c_cty25g00_008 into lr_retorno.itaciacod  ,
			        lr_retorno.itaramcod  ,
			        lr_retorno.aplnum     ,
			        lr_retorno.aplseqnum  ,
				lr_retorno.succod

      whenever error stop
      if sqlca.sqlcode <> 0  then
         if sqlca.sqlcode = notfound  then
	    let lr_retorno.mensagem = "Proposta nao Encontrada!"
	    let lr_retorno.erro     = 1
         else
            let lr_retorno.mensagem = "Erro ao Selecionar o Cursor c_cty25g00_008", sqlca.sqlcode
	    let lr_retorno.erro     = sqlca.sqlcode
         end if
      end if

      close c_cty25g00_008

      return lr_retorno.itaciacod    ,
             lr_retorno.itaramcod    ,
	     lr_retorno.aplnum       ,
	     lr_retorno.aplseqnum    ,
	     lr_retorno.succod       ,
	     lr_retorno.erro         ,
	     lr_retorno.mensagem

end function
#------------------------------------------------------------------------------#
function cty25g00_rec_plano_assistencia(lr_param)
#------------------------------------------------------------------------------#

   define lr_param     record
          asiplncod like datkresitaasipln.asiplncod    
   end record
   
   define lr_retorno   record
          grpivcqtd    like datrntzasipln.grpivcqtd ,   
          ntzivcqtd    like datrntzasipln.ntzivcqtd , 
          erro         integer                         ,
          mensagem     char(50)
   end record
   
   if m_cty25g00_prepare is null or
      m_cty25g00_prepare <> true then
      call cty25g00_prepare()
   end if
   
   initialize lr_retorno.* to null
   
   let lr_retorno.erro = 0
   
      open c_cty25g00_010 using lr_param.asiplncod  
      whenever error continue
      fetch c_cty25g00_010 into lr_retorno.grpivcqtd ,
                                lr_retorno.ntzivcqtd   
      whenever error stop
      
      if sqlca.sqlcode <> 0  then
         if sqlca.sqlcode = notfound  then
            let lr_retorno.mensagem = "Plano de Assistencia Nao Cadastrada!"
            let lr_retorno.erro     = 1
         else
            let lr_retorno.mensagem = "Erro ao selecionar o cursor c_cty25g00_010 ", sqlca.sqlcode
            let lr_retorno.erro     = sqlca.sqlcode
         end if
      end if
      close c_cty25g00_010
   
      return lr_retorno.grpivcqtd ,
             lr_retorno.ntzivcqtd ,
             lr_retorno.erro      ,
             lr_retorno.mensagem
   
end function #--> cty25g00_rec_plano_assistencia(lr_param)
#========================================================================
function cty25g00_busca_nome_corretor()
#========================================================================
 define lr_cornom like gcakcorr.cornom 
 
 if m_cty25g00_prepare is null or     
    m_cty25g00_prepare = false then   
    call cty25g00_prepare()  
 end if                      
 
 let lr_cornom = null 

 open c_cty25g00_011 using g_doc_itau[1].corsus
 whenever error continue                             
 fetch c_cty25g00_011 into lr_cornom        
 whenever error stop                                 

 if sqlca.sqlcode = notfound  then                   
    let lr_cornom = "Corretor nao Cadastrado!"  
 end if 

close c_cty25g00_011

return lr_cornom 

#========================================================================
end function 
#========================================================================
#-----------------------------------------------------------------------------
function cty25g00_conta_corrente_itau(lr_param)
#-----------------------------------------------------------------------------

define lr_param record
     c24astcod       like datmligacao.c24astcod       ,
     asiplncod       like datkresitaasipln.asiplncod        ,
     itaaplvigincdat like datmitaapl.itaaplvigincdat  ,
     itaaplvigfnldat like datmitaapl.itaaplvigfnldat  ,
     itaciacod       like datmitaapl.itaciacod        ,
     itaramcod       like datmitaapl.itaramcod        ,
     aplnum          like datmresitaapl.aplnum           ,
     aplitmnum       like datmresitaaplitm.aplitmnum     ,
     acesso          smallint
end record

define lr_retorno record
       pansoclmtqtd     like datkitaasipln.pansoclmtqtd       ,
       socqlmqtd        like datkitaasipln.socqlmqtd          ,
       itaasiplntipcod  like datritaasiplnast.itaasiplntipcod ,
       qtd              integer                               ,
       flag             smallint                              ,
       mens             char(50)                              ,
       erro             smallint
end record

initialize lr_retorno.* to null

let lr_retorno.flag = true
let lr_retorno.qtd  = 0


 while true


    # Verifica se o Assunto e do Tipo Servigo

    call cty22g00_recupera_tipo_assunto(lr_param.c24astcod)

       returning lr_retorno.erro,
                 lr_retorno.mens,
	         lr_retorno.itaasiplntipcod

    # Verifica se Tipo de Assunto e Servico

    if lr_retorno.itaasiplntipcod <> 2 then
       exit while
    end if

    # Verifica se o Assunto tem permissco de ser atendido pelo Plano
    call cty22g00_verifica_plano_assunto(lr_param.c24astcod ,
					 lr_param.asiplncod ,
				         lr_param.acesso    )
			  returning lr_retorno.flag,
				    lr_retorno.mens

    case lr_retorno.flag
         when 0
	    let lr_retorno.flag = true
         when 1
	    let lr_retorno.flag = true
	    exit while
	 when 2
	    let lr_retorno.flag = false
	    exit while
    end case

    # Recupera a Quantidade de Servigos Ja Prestados

    call cty22g00_qtd_ligacoes_itau(lr_param.asiplncod   ,
				    lr_param.itaaplvigincdat,
				    lr_param.itaaplvigfnldat,
                 		    lr_param.itaciacod      ,
                                    lr_param.itaramcod      ,
				    lr_param.aplnum         ,
				    lr_param.aplitmnum   )

         returning lr_retorno.qtd

    # Recupera a Quantidade de Limites
    
    if lr_param.itaramcod = 31 then
        #    call cty25g00_rec_plano_assistencia(lr_param.asiplncod)
        #       returning lr_retorno.pansoclmtqtd ,
	#	       lr_retorno.socqlmqtd    ,
	#	       lr_retorno.flag         ,
	#               lr_retorno.mens
   # else
       call cty22g00_rec_plano_assistencia(lr_param.asiplncod)
          returning lr_retorno.pansoclmtqtd ,
		    lr_retorno.socqlmqtd    ,
	            lr_retorno.flag         ,
	            lr_retorno.mens
    end if
  
    if lr_retorno.flag <> 0 then
       let lr_retorno.flag = false
       exit while
    else
       let lr_retorno.flag = true
    end if

   if lr_retorno.qtd >= lr_retorno.pansoclmtqtd then
      let lr_retorno.mens = "Limite Esgotado!|Limite: "      ,
      lr_retorno.pansoclmtqtd using '&&&',
      " Utilizado: ", lr_retorno.qtd using '&&&'
      let lr_retorno.flag = false
      exit while
   end if
   exit while
 end while

 return lr_retorno.flag,
        lr_retorno.mens

end function

#------------------------------------------------------------------------------
function cty25g00_status_apolice(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaciacod     like datmresitaapl.itaciacod ,
   itaramcod     like datmresitaapl.itaramcod ,
   aplnum        like datmresitaapl.aplnum    ,
   aplitmnum     like datmresitaaplitm.aplitmnum ,
   aplseqnum     like datmresitaapl.aplseqnum
end record

define lr_retorno record
   itmsttcod        like datmresitaaplitm.itmsttcod ,
   linha1           char(40)                     ,
   linha2           char(40)                     ,
   linha3           char(40)                     ,
   linha4           char(40)                     ,
   confirma         char(01)
end record

  if m_cty25g00_prepare is null or
     m_cty25g00_prepare <> true then
     call cty25g00_prepare()
  end if 

  initialize lr_retorno.* to null


     open c_cty25g00_012 using lr_param.itaciacod,
			                         lr_param.itaramcod,
			                         lr_param.aplnum   ,
                               lr_param.aplitmnum,			                         
			                         lr_param.aplseqnum
          whenever error continue
     fetch c_cty25g00_012 into lr_retorno.itmsttcod			                         

	  whenever error stop
          if sqlca.sqlcode = notfound  then
	     error "Segurado nao encontrado"
	     return false
          else 
             if sqlca.sqlcode <> 0  then
	        error "Erro ao Selecionar o Cursor c_cty25g00_012 ", sqlca.sqlcode
	        return false
	     end if
	  end if
	  close c_cty25g00_007

        if lr_retorno.itmsttcod <> "C" then
           return true
        else
	          
	         let lr_retorno.linha1 = "ESTA APOLICE ESTA CANCELADA"           
           let lr_retorno.linha2 = "PROCURE UMA APOLICE VIGENTE"
           let lr_retorno.linha3 = "OU CONSULTE A SUPERVISAO."
           let lr_retorno.linha4 = "DESEJA PROSSEGUIR?"
   
           call cts08g01("C","S",lr_retorno.linha1,
			         lr_retorno.linha2,
			         lr_retorno.linha3,
			         lr_retorno.linha4)
	        returning lr_retorno.confirma
   
	        if lr_retorno.confirma = "S" then
	           return true
	        else
	           return false
	        end if
        end if

end function






#========================================================================
    
                
