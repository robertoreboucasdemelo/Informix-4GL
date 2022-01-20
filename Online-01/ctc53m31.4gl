#-----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                             # 
#.............................................................................# 
# Sistema........: Cadastro Central                                           # 
# Modulo.........: ctc53m31                                                   # 
# Objetivo.......: Consulta Segmento Auto                                     # 
# Analista Resp. : Carlos Ruiz                                                # 
# PSI            :                                                            # 
#.............................................................................# 
# Desenvolvimento: R.Fornax                                                   # 
# Liberacao      : 07/09/2015                                                 # 
#.............................................................................# 
# ST-2015-00075                                                               #



 globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define ma_ctc53m31 array[500] of record
       segcod        like iddkdominio.cpocod
     , segdes        like iddkdominio.cpodes 
     , cod_depara    integer
 end record


 define m_operacao  char(1)
 define arr_aux     smallint
 define scr_aux     smallint

 define  m_sql  char(1)

#===============================================================================
 function ctc53m31_prepare()
#===============================================================================

define l_sql char(10000)

 let l_sql = ' select cpocod                     '
          ,  '      , cpodes                     '
          ,  '  from datkdominio                 '
          ,  '  where cponom    = "dctsgmcod"    '
          ,  '  order by cpocod                  '
 prepare p_ctc53m31_001 from l_sql
 declare c_ctc53m31_001 cursor for p_ctc53m31_001

 let l_sql =  ' insert into datkdominio   '       
           ,  '   (cpocod                 '       
           ,  '   ,cpodes                 '       
           ,  '   ,cponom                 '       
           ,  '   ,atlult)                '       
           ,  ' values(?,?,?,?)           '       
 prepare p_ctc53m31_002 from l_sql                


 let l_sql = ' update datkdominio           '
            ,' set cpodes = ?, atlult = ?   '
            ,' where cponom =  ?            '
            ,' and   cpocod = ?             '
 prepare p_ctc53m31_003 from l_sql


 let l_sql = ' select count(*)        '
           , ' from datkdominio       '
           , ' where cponom =  ?      '
           , ' and   cpodes = ?       '   
           , ' and   cpocod <> ?      '     
 prepare p_ctc53m31_004 from l_sql
 declare c_ctc53m31_004 cursor for p_ctc53m31_004  
 	
 let l_sql = ' select cpodes          '            	
           , ' from datkdominio       '            	
           , ' where cponom =  ?      '            	      	
           , ' and   cpocod =  ?      '            	
 prepare p_ctc53m31_005 from l_sql                 	
 declare c_ctc53m31_005 cursor for p_ctc53m31_005  	

 


let m_sql = 'S'


end function

#===============================================================================
 function ctc53m31()
#===============================================================================


 define l_ret                smallint
 define m_cod_depara_aux     integer
 define l_flag               smallint




 if m_sql is null or
    m_sql <> 'S' then
    call ctc53m31_prepare()
 end if 
 
 
 for	arr_aux  =  1  to  500                     
 	initialize  ma_ctc53m31[arr_aux].*  to  null    
 end	for                                      
 
 
 let arr_aux = 1

 open window w_ctc53m31 at 6,2 with form 'ctc53m31'
 attribute(form line 1)


  
  open c_ctc53m31_001  
  foreach c_ctc53m31_001 into ma_ctc53m31[arr_aux].segcod
                            , ma_ctc53m31[arr_aux].segdes

        
       call ctc53m31_recupera_segmento() 
             
       let arr_aux = arr_aux + 1

       if arr_aux > 500 then
          error " Limite excedido! Foram encontrados mais de 500 Segmentos Auto!"
          exit foreach
       end if

  end foreach


  if arr_aux = 1  then
       error "Nao Foi encontrado Nenhum Registro!"
    end if

 let m_operacao = " "

 call set_count(arr_aux - 1 )

 input array ma_ctc53m31 without defaults from s_ctc53m31.*

      #---------------------------------------------
       before row
      #---------------------------------------------
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

          if fgl_lastkey() = fgl_keyval ("down")     or
             fgl_lastkey() = fgl_keyval ("return")   then
            
             if ma_ctc53m31[arr_aux].cod_depara is null then
                let m_operacao = 'i'
             end if
          
          end if

    

          #---------------------------------------------
           before field cod_depara
          #---------------------------------------------
              if ma_ctc53m31[arr_aux].cod_depara is null then
                display ma_ctc53m31[arr_aux].cod_depara to s_ctc53m31[scr_aux].cod_depara attribute(reverse)
                let m_operacao = 'i'
             else
               let m_cod_depara_aux  = ma_ctc53m31[arr_aux].cod_depara
               display ma_ctc53m31[arr_aux].* to s_ctc53m31[scr_aux].* attribute(reverse)
             end if
              
              
          #---------------------------------------------
           after  field cod_depara
          #---------------------------------------------
             display ma_ctc53m31[arr_aux].cod_depara   to s_ctc53m31[scr_aux].cod_depara
          
             if m_operacao = ' '   or
             	  m_operacao is null then
                                                                       
             	  display ma_ctc53m31[arr_aux].* to s_ctc53m31[scr_aux].*   
             end if  
             
             if ma_ctc53m31[arr_aux].cod_depara is null   then
                error "Por Favor Informe o Codigo De-Para"
                next field cod_depara
             end if
             
             if ctc53m31_valida_segmento() then
                error "Codigo De-Para ja Cadastrado em Outro Segmento"
                next field cod_depara
             end if	   
              
           
             if m_operacao = 'i' then
          
                let m_operacao = ' '
          
                call ctc53m31_inclui()
          
             else
                
                if ma_ctc53m31[arr_aux].cod_depara <> m_cod_depara_aux then 
                   call ctc53m31_altera()
                end if
             end if
          
          
         #---------------------------------------------
          on key (interrupt)
         #---------------------------------------------
            exit input


  

  end input

 close window w_ctc53m31

 if l_flag = 1 then
    call ctc53m31()
 end if


end function



#========================================================================
 function ctc53m31_altera()
#========================================================================


define lr_retorno record
	cponom     like datkdominio.cponom ,
	data_atual date                    ,
  atlult     like datkdominio.atlult
end record

initialize lr_retorno.* to null

    let lr_retorno.cponom     = "ctc53m31_depara"
    let lr_retorno.data_atual = today
    let lr_retorno.atlult     = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&"
    
    whenever error continue
    execute p_ctc53m31_003 using ma_ctc53m31[arr_aux].cod_depara
                               , lr_retorno.atlult
                               , lr_retorno.cponom
                               , ma_ctc53m31[arr_aux].segcod
                               
    whenever error stop

    
    if sqlca.sqlcode = 0 then
       error 'Dados Alterados com Sucesso!'
    else
       error 'ERRO(',sqlca.sqlcode,') na Alteracao do Dado!'
    end if
    
    let m_operacao = ' '
        
end function




#---------------------------------------------------------
 function ctc53m31_valida_segmento()
#---------------------------------------------------------


define lr_retorno  record
	 cponom     like datkdominio.cponom ,
   cont       smallint
end record

if m_sql is null or
   m_sql <> true then
   call ctc53m31_prepare()
end if

initialize lr_retorno.* to null


         let lr_retorno.cponom = "ctc53m31_depara"

         #--------------------------------------------------------
         # Valida Se o Segmento Ja Existe
         #-------------------------------------------------------- 
         

         open c_ctc53m31_004 using lr_retorno.cponom               ,
                                   ma_ctc53m31[arr_aux].cod_depara ,
                                   ma_ctc53m31[arr_aux].segcod 

         whenever error continue
         fetch c_ctc53m31_004 into lr_retorno.cont
         whenever error stop
        
         if lr_retorno.cont >  0 then
            return true
         else
         	  return false
         end if


end function

#========================================================================
 function ctc53m31_inclui()
#========================================================================


define lr_retorno record
	cponom     like datkdominio.cponom ,
	data_atual date                    ,
  atlult     like datkdominio.atlult
end record

initialize lr_retorno.* to null

    let lr_retorno.cponom     = "ctc53m31_depara"
    let lr_retorno.data_atual = today
    let lr_retorno.atlult     = lr_retorno.data_atual,"|", g_issk.funmat using "&&&&&&"
    
    whenever error continue
    execute p_ctc53m31_002 using ma_ctc53m31[arr_aux].segcod
                               , ma_ctc53m31[arr_aux].cod_depara
                               , lr_retorno.cponom
                               , lr_retorno.atlult
    whenever error stop

    
    if sqlca.sqlcode = 0 then
       error 'Dados Incluidos com Sucesso!'
       let m_operacao = ' '
    else
       error 'ERRO(',sqlca.sqlcode,') na Insercao da Associacao!'
    end if
    
        
end function

#---------------------------------------------------------
 function ctc53m31_recupera_segmento()
#---------------------------------------------------------


define lr_retorno  record
	 cponom     like datkdominio.cponom 
end record

if m_sql is null or
   m_sql <> true then
   call ctc53m31_prepare()
end if

initialize lr_retorno.* to null


         let lr_retorno.cponom = "ctc53m31_depara"

         #--------------------------------------------------------
         # Recupera o Segmento
         #-------------------------------------------------------- 
         

         open c_ctc53m31_005 using lr_retorno.cponom                ,
                                   ma_ctc53m31[arr_aux].segcod 

         whenever error continue
         fetch c_ctc53m31_005 into ma_ctc53m31[arr_aux].cod_depara
         whenever error stop
        

end function