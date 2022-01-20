#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema       :                                                              #
# Modulo        :ctn56c00                                                      #
# Analista Resp.:                                                              #
# PSI           :PSI-2011-17008/PR Localizar CAPS por proximidade.             #
#                                                                              #
#                                                                              #
#                                                                              #
#..............................................................................#
# Desenvolvimento: Johnny Alves  BizTalking  em 07/02/2012                     #
# Liberacao      :                                                             #
#..............................................................................#
#                                                                              #
#                  * * * ALTERACOES * * *                                      #
#                                                                              #
# Data       Autor Fabrica     Origem     Alteracao                            #
# ---------- ----------------- ---------- -------------------------------------#
#                                                                              #
#------------------------------------------------------------------------------#

database porto

   define mr_datmlcl      record
   	  cidnom          like datmlcl.cidnom
   	 ,ufdcod          like datmlcl.ufdcod
   	 ,brrnom          like datmlcl.brrnom
         ,lgdcep          like datmlcl.lgdcep
         ,lgdcepcmp       like datmlcl.lgdcepcmp
         ,lgdtip          like datmlcl.lgdtip
         ,lgdnum          like datmlcl.lgdnum
         ,endcmp          like datmlcl.endcmp
   end record

   define mr_ctx25g05_pes record
          ret             integer            # 0 -> OK / <> 0 -> ERRO
         ,lclltt          like datmlcl.lclltt
         ,lcllgt          like datmlcl.lcllgt
         ,lgdtip          like datkmpalgd.lgdtip
         ,lgdnom          like datkmpalgd.lgdnom
         ,brrnom          char(65)
         ,lclbrrnom       char(65)
         ,lgdcep          like datmlcl.lgdcep
         ,c24lclpdrcod    like datmlcl.c24lclpdrcod
         ,lgdnum          like datmlcl.lgdnum
         ,lgdcepcmp       like datmlcl.lgdcepcmp
   end record

   define mr_glaklgd      record
   	  cidcod          like glaklgd.cidcod
   	 ,brrcod          like glaklgd.brrcod
   end record

   define mr_array        array[10] of record
   	  fantasma        char(1)
   	 ,codigo          dec(5,0)
   	 ,razao           char(20)
   	 ,cidade          char(17)
   	 ,bairro          char(16)
   	 ,distancia       char(07)
   end record

   define m_prep_sql      smallint
         ,m_tplougr       char(100)
         ,m_cabec         char(20)
         ,m_status        smallint

#------------------------------------------------------------------------------#
function ctn56c00_prepare()
#------------------------------------------------------------------------------#
# Objetivo: Preparar os cursores que serao utilizados no modulo                #
#------------------------------------------------------------------------------#
   define l_sql    char(1000)

   initialize l_sql to null

   let l_sql = " select ufdcod     "
              ,"   from glakest    "
              ,"  where ufdcod = ? "

   prepare pctn56c00001 from l_sql
   declare cctn56c00001 cursor for pctn56c00001

   let l_sql = " select ufdnom     "
              ,"   from glakest    "
              ,"  where ufdcod = ? "

   prepare pctn56c00002 from l_sql
   declare cctn56c00002 cursor for pctn56c00002

   let l_sql = " select lgdtip        "
              ,"       ,lgdnom        "
              ,"       ,cidcod        "
              ,"       ,brrcod        "
              ,"   from glaklgd       "
              ,"  where lgdcep    = ? "
              ,"    and lgdcepcmp = ? "

   prepare pctn56c00003 from l_sql
   declare cctn56c00003 cursor for pctn56c00003

   let l_sql = " select cidnom     "
              ,"       ,ufdcod     "
              ,"   from glakcid    "
              ,"  where cidcod = ? "

   prepare pctn56c00004 from l_sql
   declare cctn56c00004 cursor for pctn56c00004

   let l_sql = " select brrnom     "
              ,"   from glakbrr    "
              ,"  where cidcod = ? "
              ,"    and brrcod = ? "

   prepare pctn56c00005 from l_sql
   declare cctn56c00005 cursor for pctn56c00005

end function

#------------------------------------------------------------------------------#
function ctn56c00()
#------------------------------------------------------------------------------#
# Objetivo: Funcao principal onde temos as validacoes para localizar o endereco#
#          do cliente e localizar a longitude e latitude para calcular a       #
#          distancia.                                                          #
#------------------------------------------------------------------------------#

   define l_tplougr       char(100)

   let int_flag = false

   open window ctn56c00 at 3, 2 with form "ctn56c00"

   if m_prep_sql is null or
      m_prep_sql = false then
      let m_prep_sql = true
      call ctn56c00_prepare()
   end if

   let l_tplougr = null
   
   while true

      initialize mr_datmlcl.*, mr_ctx25g05_pes.*, l_tplougr, m_cabec
                 , m_status to null

      input by name mr_datmlcl.lgdcep
                   ,mr_datmlcl.lgdcepcmp
                   ,mr_datmlcl.ufdcod
                   ,mr_datmlcl.cidnom
                   ,mr_datmlcl.lgdtip
                   ,mr_datmlcl.endcmp
                   ,mr_datmlcl.lgdnum
                   ,mr_datmlcl.brrnom  without defaults

         before field lgdcep
            display by name mr_datmlcl.lgdcep attribute (reverse)

         after field lgdcep
            display by name mr_datmlcl.lgdcep attribute (normal)

         before field lgdcepcmp
            display by name mr_datmlcl.lgdcepcmp attribute (reverse)

         after field lgdcepcmp
            display by name mr_datmlcl.lgdcepcmp attribute (normal)

            if mr_datmlcl.lgdcep is not null and
               mr_datmlcl.lgdcepcmp is not null then
               open cctn56c00003 using mr_datmlcl.lgdcep
                                      ,mr_datmlcl.lgdcepcmp
               whenever error continue
               fetch cctn56c00003 into mr_datmlcl.lgdtip
                                      ,mr_datmlcl.endcmp
                                      ,mr_glaklgd.cidcod
                                      ,mr_glaklgd.brrcod
               whenever error stop
               if sqlca.sqlcode < 0 then
                  error "Problemas ao acesso do cursor cctn56c00003.Erro.:"
                        ,sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                        exit input
               else
                  if sqlca.sqlcode = 100 then
                  	  error "Cep nao cadastrado!" sleep 2
                  	  next field lgdcep
                  end if
               end if

               call cts06g06(mr_datmlcl.endcmp)
                  returning mr_datmlcl.endcmp

               open cctn56c00004 using mr_glaklgd.cidcod
               whenever error continue
               fetch cctn56c00004 into mr_datmlcl.cidnom
                                      ,mr_datmlcl.ufdcod
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  error "Problemas ao acesso do cursor cctn56c00004.Erro.:"
                        ,sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                        exit input
               end if

               open cctn56c00005 using mr_glaklgd.cidcod
                                      ,mr_glaklgd.brrcod
               whenever error continue
               fetch cctn56c00005 into mr_datmlcl.brrnom
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  error "Problemas ao acesso do cursor cctn56c00005.Erro.:"
                        ,sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                        exit input
               end if
            end if
               display by name mr_datmlcl.lgdtip, mr_datmlcl.endcmp
               display by name mr_datmlcl.cidnom, mr_datmlcl.ufdcod
               display by name mr_datmlcl.brrnom

         before field cidnom
            display by name mr_datmlcl.cidnom attribute (reverse)

         after field cidnom
            display by name mr_datmlcl.cidnom attribute (normal)
            if mr_datmlcl.cidnom is null then
               error "Digite o nome da cidade." sleep 2
               next field cidnom
            end if
            
            if not ctx25g05_existe_cid(1, # GUIA POSTAL        
                                       mr_datmlcl.ufdcod,        
                                       mr_datmlcl.cidnom) then   
               error " Cidade nao cadastrada!"                 
                                                               
               call cts06g04(mr_datmlcl.cidnom,                  
                             mr_datmlcl.ufdcod)                  
                                                               
                    returning m_status,                        
                              mr_datmlcl.cidnom,                 
                              mr_datmlcl.ufdcod                  
                                                               
               display mr_datmlcl.cidnom to cidnom         
               display mr_datmlcl.ufdcod to ufdcod         
            end if                                             
                                                               
            # -> VALIDA CIDADE NO CADASTRO DE MAPAS            
            if not ctx25g05_existe_cid(2, # CADASTRO DE MAPAS  
                                       mr_datmlcl.ufdcod,        
                                       mr_datmlcl.cidnom) then   
               error " Cidade nao cadastrada na base de mapas!"
               next field cidnom                         
            end if                                             	

         before field ufdcod
            display by name mr_datmlcl.ufdcod attribute (reverse)

         after field ufdcod
            display by name mr_datmlcl.ufdcod attribute (normal)
            if mr_datmlcl.ufdcod is null then
               error "Digite UF." sleep 2
               next field ufdcod
            end if
            
            open cctn56c00001 using mr_datmlcl.ufdcod                                    
            whenever error continue                                          
            fetch cctn56c00001 into mr_datmlcl.ufdcod                        
            whenever error stop                                              
            if sqlca.sqlcode < 0 then                                        
               error "Problemas ao acesso do cursor cctn56c00001.Erro.:"     
                     ,sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2             
                     exit input                                              
            else                                                             
               if sqlca.sqlcode = 100 then                                   
                  error "Sigla da unidade da federacao invalido !!! " sleep 2
                        next field ufdcod                                          
               end if                                                        
            end if                                                           
            
            if not ctx25g05_existe_cid(2, # CADASTRO DE MAPAS  
                                       mr_datmlcl.ufdcod,      
                                       mr_datmlcl.cidnom) then 
               error " Cidade nao cadastrada na base de mapas!"
               next field cidnom                               
            end if                                             

         before field lgdtip
            display by name mr_datmlcl.lgdtip attribute (reverse)
            if mr_datmlcl.lgdtip is null then
               call cta00m06_tipo_logradouro()
                    returning l_tplougr
              
 
               if l_tplougr is not null then
                  let m_cabec = "Tipo logradouro"

                  call ctx14g01_tipo_logradouro(m_cabec, l_tplougr)
                     returning mr_datmlcl.lgdtip

                  let mr_datmlcl.lgdtip = mr_datmlcl.lgdtip 
                 
               end if
            end if

         after field lgdtip
            display by name mr_datmlcl.lgdtip attribute (normal) 
            if fgl_lastkey() <> fgl_keyval("up")    and
               fgl_lastkey() <> fgl_keyval("left")  then
               if mr_datmlcl.lgdtip is null  then
                  error " Tipo do logradouro deve ser informado!" sleep 2
                  next field lgdtip
               end if
            end if

         before field endcmp
            display by name mr_datmlcl.endcmp attribute (reverse)

         after field endcmp
            display by name mr_datmlcl.endcmp attribute (normal)
            if fgl_lastkey() <> fgl_keyval("up")    and
               fgl_lastkey() <> fgl_keyval("left")  then
               if mr_datmlcl.endcmp is null then
                  error "Digite o Endereco." sleep 2
                  next field endcmp 
               end if
            end if

         before field lgdnum
            display by name mr_datmlcl.lgdnum attribute (reverse)

         after field lgdnum
            display by name mr_datmlcl.lgdnum attribute (normal)

         before field brrnom
            display by name mr_datmlcl.brrnom attribute (reverse)

         after field brrnom
            display by name mr_datmlcl.brrnom attribute (normal)
            if mr_datmlcl.brrnom is null then
               error "Digite nome do Bairro." sleep 2
               next field brrnom
            end if

      end input

   if int_flag then
      error "Consulta Cancelada" sleep 2
      let int_flag = false
      initialize mr_datmlcl.* to null
      exit while
      return
   end if

   if ctx25g05_rota_ativa() then
      call ctx25g05("C"
                   ," "
                   ,mr_datmlcl.ufdcod
                   ,mr_datmlcl.cidnom
                   ,mr_datmlcl.lgdtip
                   ,mr_datmlcl.endcmp
                   ,mr_datmlcl.lgdnum
                   ,mr_datmlcl.brrnom
                   ," "
                   ,mr_datmlcl.lgdcep
                   ,mr_datmlcl.lgdcepcmp
                   ," "
                   ," "
                   ," ")
         returning mr_ctx25g05_pes.lgdtip
                  ,mr_ctx25g05_pes.lgdnom
                  ,mr_ctx25g05_pes.lgdnum
                  ,mr_ctx25g05_pes.brrnom
                  ,mr_ctx25g05_pes.lclbrrnom
                  ,mr_ctx25g05_pes.lgdcep
                  ,mr_ctx25g05_pes.lgdcepcmp
                  ,mr_ctx25g05_pes.lclltt
                  ,mr_ctx25g05_pes.lcllgt
                  ,mr_ctx25g05_pes.c24lclpdrcod
                  ,mr_datmlcl.ufdcod
                  ,mr_datmlcl.cidnom
   end if

   if mr_ctx25g05_pes.lclltt is null or
      mr_ctx25g05_pes.lcllgt is null then
      continue while
   end if

   call retornapostoscaps(mr_ctx25g05_pes.lclltt
                         ,mr_ctx25g05_pes.lcllgt)
      returning mr_array[1].codigo
               ,mr_array[1].razao
               ,mr_array[1].bairro
               ,mr_array[1].cidade
               ,mr_array[1].distancia
               ,mr_array[2].codigo
               ,mr_array[2].razao
               ,mr_array[2].bairro
               ,mr_array[2].cidade
               ,mr_array[2].distancia
               ,mr_array[3].codigo
               ,mr_array[3].razao
               ,mr_array[3].bairro
               ,mr_array[3].cidade
               ,mr_array[3].distancia
               ,mr_array[4].codigo
               ,mr_array[4].razao
               ,mr_array[4].bairro
               ,mr_array[4].cidade
               ,mr_array[4].distancia
               ,mr_array[5].codigo
               ,mr_array[5].razao
               ,mr_array[5].bairro
               ,mr_array[5].cidade
               ,mr_array[5].distancia
               ,mr_array[6].codigo
               ,mr_array[6].razao
               ,mr_array[6].bairro
               ,mr_array[6].cidade
               ,mr_array[6].distancia
               ,mr_array[7].codigo
               ,mr_array[7].razao
               ,mr_array[7].bairro
               ,mr_array[7].cidade
               ,mr_array[7].distancia
               ,mr_array[8].codigo
               ,mr_array[8].razao
               ,mr_array[8].bairro
               ,mr_array[8].cidade
               ,mr_array[8].distancia
               ,mr_array[9].codigo
               ,mr_array[9].razao
               ,mr_array[9].bairro
               ,mr_array[9].cidade
               ,mr_array[9].distancia
               ,mr_array[10].codigo
               ,mr_array[10].razao
               ,mr_array[10].bairro
               ,mr_array[10].cidade
               ,mr_array[10].distancia

   call ctn56c00_carrega_array()

   continue while

   end while

   close window ctn56c00

end function     #-- Fim ctn56c00

#------------------------------------------------------------------------------#
function ctn56c00_carrega_array()
#------------------------------------------------------------------------------#
# Objetivo: Alimentar o array tanto da parte de distancia e a parte das obs.   #
#          dos CAPS.                                                           #
#------------------------------------------------------------------------------#


   define l_linha      smallint
         ,l_arr        smallint
         ,l_codigo     dec(5,0)
         ,l_retorno    smallint

   define lr_detalhecaps record
   	  endlgdtip      like avgmcappstend.endlgdtip
   	 ,cappstcod      like avgmcappstend.cappstcod
   	 ,endlgd         like avgmcappstend.endlgd
   	 ,endlgdnum      like avgmcappstend.endlgdnum
   	 ,endbrr         like avgmcappstend.endbrr
   	 ,ldgcid         like avgmcappstend.ldgcid
   	 ,pstenduf       like avgmcappstend.pstenduf
   	 ,cmctelddd      like avgmcappstend.cmctelddd
   	 ,pstcmltel      like avgmcappstend.pstcmltel
         ,horario        char(1000)
   	 ,c24obs         like avckposto.c24obs
   	 ,vstpstnom      like avckposto.vstpstnom
   end record

   define lr_tela      record
   	  fantasma     char(1)
   	 ,razao        char(40)
   	 ,codigo       dec(5,0)
   	 ,endcmp       char(45)
   	 ,brrnom       like datmlcl.brrnom
   	 ,cidnom       like datmlcl.cidnom
   	 ,ufdcod       like datmlcl.ufdcod
   	 ,cmctelddd    like avgmcappstend.cmctelddd
   	 ,pstcmltel    like avgmcappstend.pstcmltel
   	 ,horarios     char(1000)
   	 ,observacao1  char(50)
   	 ,observacao2  char(50)
   	 ,observacao3  char(50)
   end record

   initialize lr_detalhecaps.* to null

   input array mr_array without defaults from src_dados.*

       on key (interrupt,control-c,f17)
         initialize mr_array to null
         clear form
         let int_flag = false
         exit input

       for l_linha = 1 to 10
         display mr_array[l_linha].codigo to scr_dados[l_linha].codigo
         display mr_array[l_linha].razao to scr_dados[l_linha].razao
         display mr_array[l_linha].bairro to scr_dados[l_linha].bairro
         display mr_array[l_linha].cidade to scr_dados[l_linha].cidade
         display mr_array[l_linha].distancia to scr_dados[l_linha].distancia
       end for

       on key (f8)
        
        #call fvpic013_cria_temp()
        #   returning l_retorno

        let l_arr = arr_curr()
        let l_codigo = mr_array[l_arr].codigo
        
           call retornadetalhecaps(l_codigo)
              returning lr_detalhecaps.endlgdtip
                       ,lr_detalhecaps.cappstcod
                       ,lr_detalhecaps.endlgd
                       ,lr_detalhecaps.endlgdnum
                       ,lr_detalhecaps.endbrr
                       ,lr_detalhecaps.ldgcid
                       ,lr_detalhecaps.pstenduf
                       ,lr_detalhecaps.cmctelddd
                       ,lr_detalhecaps.pstcmltel
                       ,lr_detalhecaps.horario
                       ,lr_detalhecaps.c24obs
                       ,lr_detalhecaps.vstpstnom

          open window ctn56c00a at 3, 2 with form "ctn56c00a"

             let lr_tela.razao       = lr_detalhecaps.vstpstnom
             let lr_tela.codigo      = lr_detalhecaps.cappstcod
             let lr_tela.endcmp      = lr_detalhecaps.endlgdtip clipped," "
                                      ,lr_detalhecaps.endlgd clipped, ", "
                                      ,lr_detalhecaps.endlgdnum using "<<<<<" 
             let lr_tela.brrnom      = lr_detalhecaps.endbrr 
             let lr_tela.cidnom      = lr_detalhecaps.ldgcid
             let lr_tela.ufdcod      = lr_detalhecaps.pstenduf
             let lr_tela.cmctelddd   = lr_detalhecaps.cmctelddd
             let lr_tela.pstcmltel   = lr_detalhecaps.pstcmltel
             let lr_tela.horarios    = lr_detalhecaps.horario
             let lr_tela.observacao1 = lr_detalhecaps.c24obs[1,50]
             let lr_tela.observacao2 = lr_detalhecaps.c24obs[51,100]
             let lr_tela.observacao3 = lr_detalhecaps.c24obs[101,150]

             display by name lr_tela.razao
             display by name lr_tela.codigo
             display by name lr_tela.endcmp
             display by name lr_tela.brrnom
             display by name lr_tela.cidnom
             display by name lr_tela.ufdcod
             display by name lr_tela.cmctelddd
             display by name lr_tela.pstcmltel
             display by name lr_tela.horarios
             display by name lr_tela.observacao1
             display by name lr_tela.observacao2
             display by name lr_tela.observacao3

             input by name lr_tela.fantasma without defaults

                before field fantasma
                   display by name lr_tela.fantasma attribute (reverse)

                after field fantasma
                   display by name lr_tela.fantasma attribute (normal)
                   if fgl_lastkey() = fgl_keyval('up') or
                      fgl_lastkey() = fgl_keyval('left') or
                      fgl_lastkey() = fgl_keyval('down') or
                      fgl_lastkey() = fgl_keyval('right') then
                      next field fantasma
                   end if

                on key (interrupt,control-c,f17)
                   let int_flag = false
                   exit input
             end input
                          
             close window ctn56c00a

   end input

end function     #-- Fim ctn56c00_carrega_array                  
