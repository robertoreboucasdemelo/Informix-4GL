#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Porto Socorro                                             #
# Modulo.........: cts42m00                                                  #
# Objetivo.......: Consulta dos servicos da PortoSeg                         #
# Analista Resp. : Ligia Mattge                                              #
# PSI            : 211982                                                    #
#............................................................................#
# Desenvolvimento: Saulo Correa, META                                        #
# Liberacao      : 27/09/2007                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
#----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'


define mr_busca record
          atdsrvnum like datmservico.atdsrvnum
         ,atdsrvano like datmservico.atdsrvano
         ,atddatini like datmservico.atddat
         ,atddatfnl like datmservico.atddat
         ,total     integer
         ,nom       like datmservico.nom
         ,atdetpcod like datketapa.atdetpcod
         ,atdetpdes like datketapa.atdetpdes
         ,atznum    like datmsrvorc.atznum
end record

define am_servicos array[600] of record
          atdsrvnum2 like datmservico.atdsrvnum
         ,atdsrvano2 like datmservico.atdsrvano
         ,nom2       like datmservico.nom
         ,atdetpdes2 like datketapa.atdetpdes
         ,endereco   char(75)
end record

define m_prep_cts42m00 smallint

#--------------------#
 function cts42m00()
#--------------------#

   open window w_cts42m00 at 03,02 with form "cts42m00"
        attribute (form line 2)

   call cts42m00_input()

   close window w_cts42m00
   let int_flag = false

end function

#---------------------------#
 function cts42m00_input()
#---------------------------#

   define l_ok     smallint
         ,l_erro   smallint
         ,l_msgerr char(60)
         ,l_i      smallint

   define l_ciaempcod like datmservico.ciaempcod
         ,l_atdetpdes like datketapa.atdetpdes

   initialize mr_busca to null

   let l_ciaempcod = null
   let l_atdetpdes = null

   let l_ok     = true
   let l_erro   = null
   let l_msgerr = null
   let l_i      = 1

   let int_flag = false
   
   input by name mr_busca.atdsrvnum
                ,mr_busca.atdsrvano
                ,mr_busca.atddatini
                ,mr_busca.atddatfnl
                ,mr_busca.nom
                ,mr_busca.atdetpcod
                ,mr_busca.atznum without defaults

      before field atdsrvnum
         display by name mr_busca.atdsrvnum attribute(reverse)

      after field atdsrvnum
         display by name mr_busca.atdsrvnum

      before field atdsrvano
         display by name mr_busca.atdsrvano attribute(reverse)

      before field atznum
         display by name mr_busca.atznum attribute(reverse)

      after field atdsrvano
         display by name mr_busca.atdsrvano

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field atdsrvnum
         end if

         if (mr_busca.atdsrvano is not null  and
             mr_busca.atdsrvnum is null)     or
            (mr_busca.atdsrvano is null      and
             mr_busca.atdsrvnum is not null) then
             error 'Informe o numero e o ano do servico.'
             next field atdsrvnum
         end if

         if mr_busca.atdsrvano is not null and
            mr_busca.atdsrvnum is not null then
            call cts10g06_dados_servicos(10
                                        ,mr_busca.atdsrvnum
                                        ,mr_busca.atdsrvano)
               returning l_erro
                        ,l_msgerr
                        ,l_ciaempcod

            if l_erro <> 1 then
               error l_msgerr clipped
               next field atdsrvnum
            end if

            if l_ciaempcod <> g_documento.ciaempcod then
               error 'Servico nao e desta empresa.'
               next field atdsrvnum
            else
               exit input
            end if
         end if

      before field atddatini
         let mr_busca.atddatini = today
         display by name mr_busca.atddatini attribute(reverse)

      after field atddatini
         display by name mr_busca.atddatini

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field atdsrvano
         end if

         if mr_busca.atddatini is null then
            error 'informe a data inicial'
            next field atddatini
         end if

      before field atddatfnl
         display by name mr_busca.atddatfnl attribute(reverse)

      after field atddatfnl
         display by name mr_busca.atddatfnl
         
         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field atddatini
         end if

         if mr_busca.atddatfnl is null then
            let mr_busca.atddatfnl = today
         end if

         if mr_busca.atddatini > mr_busca.atddatfnl then
            error 'Data inicial deve ser menor que a data final.'
            next field atddatini
         end if

         display by name mr_busca.atddatfnl

      before field nom
         display by name mr_busca.nom attribute(reverse)

      after field nom
         display by name mr_busca.nom

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field atddatfnl
         end if

      before field atdetpcod
         display by name mr_busca.atdetpcod attribute(reverse)

      after field atdetpcod
         display by name mr_busca.atdetpcod

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field nom
         end if

         if mr_busca.atdetpcod is not null then
            call cts10g05_desc_etapa(3
                                    ,mr_busca.atdetpcod)
               returning l_erro
                        ,l_atdetpdes

            if l_erro = 0 then
               let mr_busca.atdetpdes = l_atdetpdes
            else
               if l_erro = 100 then
                  error 'Descricao do codigo da etapa nao encontrado'
                  next field atdetpcod
               else
                  let l_ok = false
                  exit input
               end if
            end if
         else
            error 'Etapa invalida.'

            let mr_busca.atdetpcod = ctn26c00(9)
            let int_flag = false

            if mr_busca.atdetpcod is not null then
               call cts10g05_desc_etapa(3
                                       ,mr_busca.atdetpcod)
                  returning l_erro
                           ,l_atdetpdes

               if l_erro = 0 then
                  let mr_busca.atdetpdes = l_atdetpdes
               else
                  if l_erro = 100 then
                     error 'Descricao do codigo da etapa nao encontrado'
                     next field atdetpcod
                  else
                     let l_ok = false
                     exit input
                  end if
               end if
            end if
         end if

         display by name mr_busca.atdetpcod
         display by name mr_busca.atdetpdes

      after field atznum
         display by name mr_busca.atznum

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field atdetpcod
         end if

   end input

   if int_flag = false then
         
      let l_i = cts42m00_servicos()

      if l_i > 0 then
         call cts42m00_mostra(l_i)
      else
         error 'Nenhum servico encontrado.'
      end if
   end if

end function

#-----------------------------#
 function cts42m00_servicos()
#-----------------------------#

   define l_sql    char(600)
         ,l_erro   smallint
         ,l_msgerr char(60)
         ,l_i      smallint

   define lr_cts10g06 record
             c24astcod like datmligacao.c24astcod
            ,c24funmat like datmligacao.c24funmat
            ,c24empcod like datmligacao.c24empcod
   end record  

   define l_atdetpcod    like datmsrvacp.atdetpcod
         ,l_atdetpdes    like datketapa.atdetpdes
         ,l_socntzcod    like datmsrvre.socntzcod
         ,l_espcod       like datmsrvre.espcod
         ,l_socntzdes    like datksocntz.socntzdes
         ,l_socntzgrpcod like datksocntz.socntzgrpcod
         ,l_cidnom       like datmlcl.cidnom
         ,l_ufdcod       like datmlcl.ufdcod
         ,l_brrnom       like datmlcl.brrnom
         ,l_atznum       like datmsrvorc.atznum

   initialize lr_cts10g06.*, am_servicos to null

   let l_atdetpcod    = null
   let l_atdetpdes    = null
   let l_socntzcod    = null
   let l_espcod       = null
   let l_socntzdes    = null
   let l_socntzgrpcod = null
   let l_cidnom       = null
   let l_ufdcod       = null
   let l_brrnom       = null
   let l_atznum       = null

   let l_erro   = null
   let l_msgerr = null
   let l_i      = 1

   let l_sql = ' select atdsrvnum '
               ,'      ,atdsrvano '
               ,'      ,nom '
               ,'  from datmservico '
               ,' where ciaempcod =  ',g_documento.ciaempcod

   if mr_busca.atddatini is not null and
      mr_busca.atddatfnl is not null then
      let l_sql = l_sql clipped
                  ,'   and atddat   >= "',mr_busca.atddatini,'"'
                  ,'   and atddat   <= "',mr_busca.atddatfnl,'"'
   end if

   if mr_busca.nom is not null and
      mr_busca.nom <> ' '      then
      let l_sql = l_sql clipped, ' and nom matches "*',mr_busca.nom clipped,'*"'
   end if

   if mr_busca.atdsrvnum is not null and
      mr_busca.atdsrvnum is not null then
      let l_sql = l_sql clipped,' and atdsrvnum = ',mr_busca.atdsrvnum
                               ,' and atdsrvano = ',mr_busca.atdsrvano
   end if

   let l_sql = l_sql clipped,' order by atdsrvnum '

   prepare pcts42m00001 from l_sql
   declare ccts42m00001 cursor for pcts42m00001

   open ccts42m00001
   foreach ccts42m00001 into am_servicos[l_i].atdsrvnum2
                            ,am_servicos[l_i].atdsrvano2
                            ,am_servicos[l_i].nom2

      let l_atdetpcod = cts10g04_ultima_etapa(am_servicos[l_i].atdsrvnum2
                                             ,am_servicos[l_i].atdsrvano2)

      if mr_busca.atdetpcod is not null then
         if mr_busca.atdetpcod <> l_atdetpcod then
            let am_servicos[l_i].atdsrvnum2 = null
            let am_servicos[l_i].atdsrvano2 = null
            let am_servicos[l_i].nom2       = null
            let am_servicos[l_i].atdetpdes2 = null
            let am_servicos[l_i].endereco   = null
            continue foreach
         end if
      end if


         call ctd09g00_sel_orc(3, am_servicos[l_i].atdsrvnum2,
                                  am_servicos[l_i].atdsrvano2)
              returning l_erro, l_msgerr, l_atznum

      if mr_busca.atznum is not null and mr_busca.atznum > 0 then
         if l_atznum is null or mr_busca.atznum <> l_atznum then
            continue foreach
         end if
      end if

      if mr_busca.atznum = 0 then
         if l_atznum is not null and l_atznum > 0 then
            continue foreach
         end if
      end if

      call cts10g05_desc_etapa(3 ,l_atdetpcod)
         returning l_erro
                  ,am_servicos[l_i].atdetpdes2

      call cts26g00_obter_natureza(am_servicos[l_i].atdsrvnum2
                                  ,am_servicos[l_i].atdsrvano2)
         returning l_erro
                  ,l_msgerr
                  ,l_socntzcod
                  ,l_espcod

      if l_erro <> 1 then
         let am_servicos[l_i].atdsrvnum2 = null
         let am_servicos[l_i].atdsrvano2 = null
         let am_servicos[l_i].nom2       = null
         let am_servicos[l_i].atdetpdes2 = null
         let am_servicos[l_i].endereco   = null
         continue foreach
      end if
 
      call cts10g06_assunto_servico(am_servicos[l_i].atdsrvnum2
                                   ,am_servicos[l_i].atdsrvano2)
         returning l_erro
                  ,l_msgerr
                  ,lr_cts10g06.c24astcod
                  ,lr_cts10g06.c24funmat
                  ,lr_cts10g06.c24empcod  

      let g_documento.c24astcod = lr_cts10g06.c24astcod

      call ctc16m03_inf_natureza(l_socntzcod
                                ,'A')
         returning l_erro
                  ,l_msgerr
                  ,l_socntzdes
                  ,l_socntzgrpcod


      call ctx04g00_brr_cid_uf(am_servicos[l_i].atdsrvnum2
                              ,am_servicos[l_i].atdsrvano2
                              ,1)
         returning l_erro
                  ,l_msgerr
                  ,l_cidnom
                  ,l_ufdcod
                  ,l_brrnom

      let am_servicos[l_i].endereco = l_socntzdes clipped, ' '
                                     ,l_ufdcod clipped,' / '
                                     ,l_cidnom clipped,' / '
                                     ,l_brrnom clipped

      let l_i = l_i + 1

      if l_i > 600 then
         error 'A busca atingiu o limite de 600 registros.'
         exit foreach
      end if

   end foreach

   let l_i = l_i - 1
   
   let mr_busca.total = l_i

   return l_i

end function

#------------------------------#
 function cts42m00_mostra(l_i)
#------------------------------#

   define l_i smallint

   define l_lin  smallint
         ,l_li2  smallint
         ,l_flag char(1)

   let l_lin  = null
   let l_li2  = null
   let l_flag = null

   display by name mr_busca.total

   call set_count(l_i)

   display array am_servicos to s_cts40m00.*

      on key(f7)
         let l_lin = arr_curr()
         let l_li2 = scr_line()
         display am_servicos[l_lin].* to s_cts40m00[l_li2].* attribute(reverse)
         call cts42m01(am_servicos[l_lin].atdsrvnum2,
                       am_servicos[l_lin].atdsrvano2)
         display am_servicos[l_lin].* to s_cts40m00[l_li2].*

      on key(f8)
         let l_lin = arr_curr()
         let g_documento.atdsrvnum = am_servicos[l_lin].atdsrvnum2
         let g_documento.atdsrvano = am_servicos[l_lin].atdsrvano2

         let l_flag = cts04g00("cts42m00")

      on key(interrupt, control-c, f17)
         clear form
         let int_flag = false
         exit display

   end display

end function

