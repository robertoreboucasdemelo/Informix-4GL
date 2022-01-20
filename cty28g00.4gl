#----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                            #
#............................................................................#
# SISTEMA........: PORTO SOCORRO                                             #
# MODULO.........:                                                           #
# ANALISTA RESP..: JORGE MODENA                                              #
# PSI/OSF........:                                                           #
# OBJETIVO.......: CONTROLAR MECANISMOS DE SEGURANCA DE ACIONAMENTO DOS      #
#                   SERVICOS                                                 #
#............................................................................#
# DESENVOLVIMENTO: JORGE MODENA                                              #
# LIBERACAO......:   /  /                                                    #
#............................................................................#
#                                                                            #
#                        * * *  ALTERACOES  * * *                            #
#                                                                            #
# DATA        AUTOR FABRICA   PSI/OSF       ALTERACAO                        #
# ----------  -------------   ------------  -------------------------------- #
#                                                                            #
# -------------------------------------------------------------------------- #

database porto


#---------------------------#
function cty28g00_prepare()
#---------------------------#

  define l_sql char(1500)
  
  # Busca informações serviço 
    let l_sql = " select srvcbnhor     ",
                "       ,atdsrvorg      ",      
                "   from datmservico   ",
                "  where atdsrvnum = ? ",
                "    and atdsrvano = ? " 
    
    prepare pcty28g00_01 from l_sql
    declare ccty28g00_01 cursor for pcty28g00_01
  
  # Busca o valor de parametro
    let l_sql = " select grlinf       ",             
                "   from datkgeral    ",
                "  where grlchv = ?   "
             
    prepare pcty28g00_02 from l_sql
    declare ccty28g00_02 cursor for pcty28g00_02
  
  # Busca ligacao original do servico
   let l_sql = " select min(lignum) ",                   
              " from datmligacao ",       
             " where atdsrvnum = ? ",
             "  and  atdsrvano = ? "                   
          
    prepare pcty28g00_03 from l_sql              
    declare ccty28g00_03 cursor for pcty28g00_03 
    
    
   # Busca origens conforme empresa
   let l_sql = " select cpodes     ",                   
              " from iddkdominio   ",       
             " where cponom = ?    ",
             "  and  cpocod = ?    "                   
          
    prepare pcty28g00_04 from l_sql              
    declare ccty28g00_04 cursor for pcty28g00_04 
    
   let l_sql = "select c24astcod,",
                      " lignum    ",
                 " from datmligacao                     ",
                 " where lignum = (select min(lignum)   ",
                                   " from datmligacao   ",
                                   "where atdsrvnum = ? ",
                                   "  and atdsrvano = ?)"

    prepare pcty28g00_06 from l_sql              
    declare ccty28g00_06 cursor for pcty28g00_06 
    	
   let l_sql =  "select 1 ",
                  " from datkdominio ",
                 " where cponom = ? ",
                   " and cpodes = ? "
  prepare pcty28g00_07 from l_sql
  declare ccty28g00_07 cursor for pcty28g00_07    	
    	
end function  


#---------------------------
function cty28g00_exibe_endereco_senha(l_param)
#---------------------------  
  
  define l_param record                          
    atdsrvnum    like datmservico.atdsrvnum, 
    atdsrvano    like datmservico.atdsrvano         
  end record
  
  define flag_exibe        smallint # 0 --> false,  1 --> true
  
  define l_srvcbnhor       like datmservico.srvcbnhor,
         l_grlchv          char(15),
         l_atdsrvorg       like datmservico.atdsrvorg,
         l_horaini         datetime year to minute,     
         l_horafim         datetime year to minute,            
         l_qtdminexbini    smallint,
         l_qtdminexbfim    smallint      
  
  call cty28g00_prepare()
  
  let flag_exibe = 0 # --> iniciado como false
  
  let l_grlchv        = null
  let l_horaini       = null
  let l_horafim       = null
  let l_qtdminexbini  = null
  let l_qtdminexbfim  = null
  
  
  
  #busca hora combinada com cliente
      whenever error continue
         open ccty28g00_01 using l_param.atdsrvnum,                                
                                 l_param.atdsrvano
          fetch ccty28g00_01 into l_srvcbnhor, l_atdsrvorg  
          
          if sqlca.sqlcode <> 0 then
             let flag_exibe = 0
             return flag_exibe
          end if           
           
         close ccty28g00_01
      whenever error stop
      
      
      #busca quantidade de minutos para inicio e fim de exibicao
      
      let l_grlchv = "PSOEXBINIMINQTD"
             
      whenever error continue
         open ccty28g00_02 using l_grlchv     
          fetch ccty28g00_02 into l_qtdminexbini
          
          if sqlca.sqlcode <> 0 then
             let l_qtdminexbini = 30
          end if           
          
         close ccty28g00_02
      whenever error stop     
      
      
      #verifica fim
      
      
      let l_grlchv = "PSOEXBFIMMINQTD"             
                                             
      whenever error continue                      
         open ccty28g00_02 using l_grlchv          
          fetch ccty28g00_02 into l_qtdminexbfim   
                                                   
          if sqlca.sqlcode <> 0 then               
             let l_qtdminexbfim = 120               
          end if                                   
                                                   
         close ccty28g00_02                       
      whenever error stop  
      
      
      let l_horaini = l_srvcbnhor - l_qtdminexbini units minute
      let l_horafim = l_srvcbnhor + l_qtdminexbfim units minute
      
      if l_srvcbnhor is null or current < l_horaini or current > l_horafim then    
         let flag_exibe = 0
      else 
         let  flag_exibe = 1
      end if
    
      return flag_exibe
         
end function


#---------------------------
function cty28g00_consulta_senha(l_param)
#---------------------------

  define l_param record 
         atdsrvnum    like datmservico.atdsrvnum, 
         atdsrvano    like datmservico.atdsrvano  
  end record
  
  define lr_retorno record
     senha          char(04),  
     coderro        smallint,  
     msgerro        char(40)       
  end record
  
  define lr_cts29g00 record
         atdsrvnum    like datratdmltsrv.atdsrvnum,
         atdsrvano    like datratdmltsrv.atdsrvano,
         resultado    smallint,
         mensagem     char(100)
  end record
  
  
  
  define l_aux       smallint,    
         l_lignum    char(10), 
         l_atdsrvorg like datmservico.atdsrvorg, 
         l_srvcbnhor like datmservico.srvcbnhor
         
  
            
 call cty28g00_prepare() 
 
 initialize lr_retorno.* to null
  
 let l_aux     = null
 let l_lignum  = null
 
  whenever error continue
         open ccty28g00_01 using l_param.atdsrvnum,                                
                                 l_param.atdsrvano
          fetch ccty28g00_01 into l_srvcbnhor, l_atdsrvorg  
          
          if sqlca.sqlcode <> 0 then
             let lr_retorno.coderro = sqlca.sqlcode 
             let lr_retorno.msgerro = "Erro ao consultar servico. Modulo cty28g00. Codigo Erro", sqlca.sqlcode            
             return lr_retorno.*           
          end if  
         close ccty28g00_01
  whenever error stop
  
 
 if  l_atdsrvorg == 9 or
     l_atdsrvorg == 13 then
     
     call cts29g00_consistir_multiplo(l_param.atdsrvnum,
                                      l_param.atdsrvano)
         returning lr_cts29g00.resultado,
                   lr_cts29g00.mensagem,
                   lr_cts29g00.atdsrvnum,
                   lr_cts29g00.atdsrvano                   
                   
     # Servico Multiplo sistema considera senha a ligacao original do servico original                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
     if lr_cts29g00.resultado == 1 then   
        let l_param.atdsrvnum = lr_cts29g00.atdsrvnum
        let l_param.atdsrvano = lr_cts29g00.atdsrvano        
     end if
 end if
     
 #verifica numero ligacao 
 whenever error continue                                     
 open ccty28g00_03 using l_param.atdsrvnum, l_param.atdsrvano     
 fetch ccty28g00_03 into l_lignum 
 
 if sqlca.sqlcode <> 0 then        
    let lr_retorno.coderro = sqlca.sqlcode 
    let lr_retorno.msgerro = "Erro ao consultar senha. Modulo cty28g00. Codigo Erro", sqlca.sqlcode            
    return lr_retorno.*           
 end if                            
                             
 close ccty28g00_03    
 whenever error stop
                                        
                                                              
 #formata senha com 4 ultimos digitos                         
 let l_aux = length(l_lignum)                                 
 let l_lignum = l_lignum clipped                              
 let lr_retorno.senha  = l_lignum[l_aux - 3, l_aux]   
 let lr_retorno.coderro = 0 
                              
 return lr_retorno.* 
                                     
end function   


#---------------------------
function cty28g00_controla_mecanismo_seguranca(l_param)
#---------------------------  
  
  define l_param record                          
    atdsrvnum    like datmservico.atdsrvnum, 
    atdsrvano    like datmservico.atdsrvano,
    ciaempcod    like datmservico.ciaempcod         
  end record
  
  define flag_exibe        smallint # 0 --> false,  1 --> true
  
  define l_atdsrvorg       like datmservico.atdsrvorg,
         l_grlchv          char(15),
         l_dominio         char(30),
         l_sql             char(1000),
         l_c24astcod       like datmligacao.c24astcod,
         l_chavedominio    like datkdominio.cponom,
         l_status          smallint
         
  initialize l_c24astcod to null
  
  call cty28g00_prepare()
  
  let flag_exibe = 0 # --> iniciado como false
  
  let l_grlchv        = "EMPORGCTLSEG"    
    
  #busca origens que devem controlar mecanismo de seguranca
      whenever error continue
         open ccty28g00_04 using  l_grlchv , l_param.ciaempcod                          
                               
          fetch ccty28g00_04 into l_dominio  
          
          if sqlca.sqlcode <> 0 then
             let flag_exibe = 0
             return flag_exibe
          end if           
           
         close ccty28g00_01
      whenever error stop            
      
      
     #verifica se origem do servico esta contemplado na regra de mecanismos de seguranca
      let l_sql = " select atdsrvorg  ",             
                "   from datmservico  ",
                "  where atdsrvnum = ? ",
                "    and atdsrvano = ? ",
                "    and atdsrvorg in (", l_dominio clipped, ")"
     
             
      prepare pcty28g00_05 from l_sql
      declare ccty28g00_05 cursor for pcty28g00_05
      
      whenever error continue
         open ccty28g00_05 using  l_param.atdsrvnum,
                                  l_param.atdsrvano                                  
                                                            
                               
          fetch ccty28g00_05 into l_atdsrvorg  
          
          if sqlca.sqlcode <> 0 then
             let flag_exibe = 0
          else 
          	 if l_atdsrvorg = 9 or l_atdsrvorg = 13 then
          	    let flag_exibe = 1
          	 else
          	 	  # Valida Assunto que enviam para servicos nao RE

                # Obter o codio do assunto da ligacao
                whenever error continue
                  open ccty28g00_06 using l_param.atdsrvnum,
                                            l_param.atdsrvano 
                  fetch ccty28g00_06  into  l_c24astcod
                  close ccty28g00_06
                whenever error stop
                
                # Pesquisa se o assundo nao envia senha de seguranca
                whenever error continue
                let l_chavedominio   = "SENHA_ASSUNTO"
                open ccty28g00_07 using l_chavedominio, l_c24astcod
                fetch ccty28g00_07 into l_status
                if  sqlca.sqlcode = 100 then
                    let flag_exibe = 1
                end if
                close ccty28g00_07
                whenever error stop

          	 end if
          end if           
           
         close ccty28g00_01
      whenever error stop
    
      return flag_exibe
         
end function               
                              
