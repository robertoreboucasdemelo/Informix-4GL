#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Porto Socorro                                             #
# Modulo.........: cts40m00                                                  #
# Objetivo.......: Exibir os servicos pendentes de orcamento da empresa      #
#                  40 (Portoseg).                                            #
# Analista Resp. : Ligia Mattge                                              #
# PSI            : 211982                                                    #
#............................................................................#
# Desenvolvimento: Saulo Correa, META                                        #
# Liberacao      : 13/09/2007                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
# 02/04/2009 Burini                  Mostrar somente os serviços que nao     #
#                                    foram pagos pelo Porto Socorro          #
#----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'

define am_cts40m00 array[600] of record
          nom          char(030)
         ,local        char(022)
         ,atendimento  char(011)
         ,atdetpdes    char(010)
         ,servicos     char(047)
end record

define am_cts40m00_aux array[600] of record
          atdsrvnum    like datmservico.atdsrvnum
         ,atdsrvano    like datmservico.atdsrvano
end record

define m_prep_cts40m00 smallint
define m_ciaempcod     like datmservico.ciaempcod

#----------------------------#
 function cts40m00_prepare()
#----------------------------#

   define l_sql char(600)

   let l_sql = ' select nom '
                    ,' ,atdlibdat '
                    ,' ,atdlibhor '
                    ,' ,atdsrvnum '
                    ,' ,atdsrvano '
               ,'  from datmservico '
               ,' where atdsrvorg = ? '
               ,'   and atdlibflg = "S" '
               ##,'   and atdfnlflg = "N" '
               ,'   and ciaempcod = ? '
               ,' order by 2,3 '

   prepare pcts40m00001 from l_sql
   declare ccts40m00001 cursor for pcts40m00001
   
   let l_sql = " select 1 ",
                 " from datmservico ",
                " where atdsrvnum = ? ",
                  " and atdsrvano = ? ",
                  " and pgtdat is not null "

   prepare pcts40m00002 from l_sql
   declare ccts40m00002 cursor for pcts40m00002   

   let m_prep_cts40m00 = true

end function

#-------------------------------------#
 function cts40m00_servicos(lr_param)
#-------------------------------------#

   define lr_param record
             ciaempcod like datmservico.ciaempcod
   end record

   define l_i      smallint
         ,l_erro   char(60)

   let l_i = null
   let l_erro = null

   let m_ciaempcod = lr_param.ciaempcod

   if m_prep_cts40m00 is null or
      m_prep_cts40m00 <> true then
      call cts40m00_prepare()
   end if

   open window w_cts40m00 at 03,02 with form "cts40m00"

   while int_flag = false

      call cts40m00_seleciona(lr_param.ciaempcod) 
           returning l_erro, l_i
   
      error ''

      if not l_erro then
         if l_i > 0 then
            call cts40m00_mostra(l_i)
         else
            error 'Nenhum servico pendente foi encontrado'
            exit while
         end if
      else
         error 'Erro ao buscar os servicos pendentes'
         exit while
      end if

   end while 

   close window w_cts40m00
   let int_flag = false

end function

#-------------------------------------#
 function cts40m00_seleciona(lr_param)
#-------------------------------------#

   define lr_param record
             ciaempcod like datmservico.ciaempcod
   end record

   define al_datmservico array[600] of record
             nom       like datmservico.nom
            ,atdlibdat like datmservico.atdlibdat
            ,atdlibhor like datmservico.atdlibhor
            ,atdsrvnum like datmservico.atdsrvnum
            ,atdsrvano like datmservico.atdsrvano
   end record

   define lr_cts10g06 record
             c24astcod like datmligacao.c24astcod
            ,c24funmat like datmligacao.c24funmat
            ,c24empcod like datmligacao.c24empcod
   end record

   define al_cts29g00 array[10] of record
             atdmltsrvnum like datratdmltsrv.atdmltsrvnum
            ,atdmltsrvano like datratdmltsrv.atdmltsrvano
            ,socntzdes    like datksocntz.socntzdes
            ,espdes       like dbskesp.espdes
            ,atddfttxt    like datmservico.atddfttxt
   end record

   define l_i         smallint
         ,l_coderro   smallint
         ,l_msgerro   char(60)
         ,l_atdsrvorg like datmservico.atdsrvorg
         ,l_atmacnflg char(01)
         ,l_cidnom    like datmlcl.cidnom
         ,l_ufdcod    like datmlcl.ufdcod
         ,l_atdsrvnum like datmservico.atdsrvnum
         ,l_atdsrvano like datmservico.atdsrvano
         ,l_atdetpcod like datmsrvacp.atdetpcod
         ,l_atdetpdes like datketapa.atdetpdes
         ,l_cont      smallint
         ,l_erro      smallint
         ,l_status    smallint

   initialize al_datmservico
             ,lr_cts10g06
             ,al_cts29g00
             ,am_cts40m00
             ,am_cts40m00_aux to null

   let l_i         = 1
   let l_coderro   = null
   let l_msgerro   = null
   let l_atdsrvorg = 9
   let l_atmacnflg = null
   let l_cidnom    = null
   let l_ufdcod    = null
   let l_atdsrvnum = null
   let l_atdsrvano = null
   let l_atdetpcod = null
   let l_atdetpdes = null
   let l_cont      = 1
   let l_erro      = false
   let l_status    = false

   open ccts40m00001 using l_atdsrvorg
                          ,lr_param.ciaempcod
   foreach ccts40m00001 into al_datmservico[l_i].nom
                            ,al_datmservico[l_i].atdlibdat
                            ,al_datmservico[l_i].atdlibhor
                            ,al_datmservico[l_i].atdsrvnum
                            ,al_datmservico[l_i].atdsrvano

      call cts10g04_ultima_etapa(al_datmservico[l_i].atdsrvnum
                                ,al_datmservico[l_i].atdsrvano)
         returning l_atdetpcod

      if l_atdetpcod = 5 or l_atdetpcod = 8 then
         continue foreach
      end if
      
      # Burini - Alteracao solicitada por Lenadro PS.
      call cts40m00_verifica_pagamento(al_datmservico[l_i].atdsrvnum,
                                       al_datmservico[l_i].atdsrvano) 
                             returning l_status
          
      if l_status then    
          continue foreach
      end if

      call cts10g05_desc_etapa(3,l_atdetpcod)
         returning l_coderro
                  ,l_atdetpdes

      let am_cts40m00[l_i].atdetpdes = l_atdetpdes


      let am_cts40m00_aux[l_i].atdsrvnum = al_datmservico[l_i].atdsrvnum
      let am_cts40m00_aux[l_i].atdsrvano = al_datmservico[l_i].atdsrvano

      let am_cts40m00[l_i].nom = al_datmservico[l_i].nom
      
      let am_cts40m00[l_i].atendimento = al_datmservico[l_i].atdlibdat using 'dd/mm'
      let am_cts40m00[l_i].atendimento = am_cts40m00[l_i].atendimento clipped,' '
                                        ,al_datmservico[l_i].atdlibhor

      call cts10g06_assunto_servico(al_datmservico[l_i].atdsrvnum
                                   ,al_datmservico[l_i].atdsrvano)
         returning l_coderro
                  ,l_msgerro
                  ,lr_cts10g06.c24astcod
                  ,lr_cts10g06.c24funmat
                  ,lr_cts10g06.c24empcod

      if l_coderro <> 1 then
         #error l_msgerro clipped sleep 1
         if l_coderro = 3 then
            let l_erro = true
            exit foreach
         else
            continue foreach
         end if
      end if

      let g_documento.c24astcod = lr_cts10g06.c24astcod  

      call cts25g00_dados_assunto(4,lr_cts10g06.c24astcod)
         returning l_coderro
                  ,l_msgerro
                  ,l_atmacnflg

      if l_coderro <> 1 then
         #error l_msgerro clipped sleep 1
         if l_coderro = 3 then
            let l_erro = true
            exit foreach
         else
            continue foreach
         end if
      end if

      if l_atmacnflg = 'S' then
         continue foreach
      end if

      call ctx04g00_cidade_uf(al_datmservico[l_i].atdsrvnum
                             ,al_datmservico[l_i].atdsrvano
                             ,1)
         returning l_coderro
                  ,l_msgerro
                  ,l_cidnom
                  ,l_ufdcod

      if l_coderro <> 1 then
         #error l_msgerro clipped sleep 1
         if l_coderro = 3 then
            let l_erro = true
            exit foreach
         else
            continue foreach
         end if
      end if

      let am_cts40m00[l_i].local = l_cidnom clipped,'/'
                                  ,l_ufdcod clipped

      call cts29g00_consistir_multiplo(al_datmservico[l_i].atdsrvnum
                                      ,al_datmservico[l_i].atdsrvano)
         returning l_coderro
                  ,l_msgerro
                  ,l_atdsrvnum
                  ,l_atdsrvano

      if l_coderro = 1 then
         continue foreach
      else
         if l_coderro = 3 then
            let l_erro = true
            exit foreach
         end if
      end if

      call cts29g00_obter_multiplo(1
                                  ,al_datmservico[l_i].atdsrvnum
                                  ,al_datmservico[l_i].atdsrvano)
         returning l_coderro
                  ,l_msgerro
                  ,al_cts29g00[1].*
                  ,al_cts29g00[2].*
                  ,al_cts29g00[3].*
                  ,al_cts29g00[4].*
                  ,al_cts29g00[5].*
                  ,al_cts29g00[6].*
                  ,al_cts29g00[7].*
                  ,al_cts29g00[8].*
                  ,al_cts29g00[9].*
                  ,al_cts29g00[10].*

      let am_cts40m00[l_i].servicos = l_atdsrvorg using '&&' ,'/'
                                ,al_datmservico[l_i].atdsrvnum using '&&&&&&&'
                                ,'-', al_datmservico[l_i].atdsrvano using '&&'
      if l_coderro = 1 then
         for l_cont = 1 to 10
            if al_cts29g00[l_cont].atdmltsrvnum is not null and
               al_cts29g00[l_cont].atdmltsrvano is not null then
               let am_cts40m00[l_i].servicos = am_cts40m00[l_i].servicos clipped
                                              ,' '
                                              ,al_cts29g00[l_cont].atdmltsrvnum using '&&&&&&&'
                                              ,'-'
                                              ,al_cts29g00[l_cont].atdmltsrvano using '&&'
            else
               exit for
            end if
         end for
      else
      	 if l_coderro = 3 then
            let l_erro = true
            exit foreach
         end if
      end if

      let l_i = l_i + 1

      if l_i > 600 then
         error 'A busca atingiu o limite.'
         exit foreach
      end if

   end foreach

   let l_i = l_i - 1

   return l_erro, l_i

end function

#------------------------------#
 function cts40m00_mostra(l_i)
#------------------------------#

   define l_i smallint

   define l_lin smallint

   let l_lin = null

   call set_count(l_i)

   display array am_cts40m00 to s_cts40m00.*

      on key(f6)
         error 'Aguarde, pesquisando ...'
         let int_flag = false
         exit display
      
      on key(f8)
         let l_lin = arr_curr()
         call cts41m00(am_cts40m00_aux[l_lin].atdsrvnum
                      ,am_cts40m00_aux[l_lin].atdsrvano)
         let int_flag = false
         exit display

      on key(interrupt, control-c, f17)
         let int_flag = true
         exit display

   end display

end function

#-------------------------------------------#
 function cts40m00_verifica_pagamento(param)
#-------------------------------------------#

   define param record
                   atdsrvnum like datmservico.atdsrvnum,
                   atdsrvano like datmservico.atdsrvano
                end record
   
   define l_status smallint

   open ccts40m00002 using  param.atdsrvnum,
                            param.atdsrvano
   fetch ccts40m00002 into l_status                       
                            
   if  sqlca.sqlcode = 0 then
       return true
   end if         

   return false                
                            
 end function 