#----------------------------------------------------------------------------#
#   Modulo   : ctx27g00                                     abr/2007         #
#   Autor    : Carlos Ruiz                                                   #
#                                                                            #
#   Objetivo : Popup de menus disponiveis para consulta (Macro-Sistema)      #
#----------------------------------------------------------------------------#
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
# 27/11/08   Priscila                Liberar todos os macro-sistemas         #
#----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

   define m_prep_ctx27g00 smallint

#----------------------------------------#
 function ctx27g00_prepare()
#----------------------------------------#

   define l_sql char(500)
   let l_sql = ' select unique b.macsissgl '
              ,'   from issmnivnovo a, ibpkmacro b, ibpksist c '
              ,'  where a.usrtip  = "F" '
              ,'    and a.empcod  = ? '
              ,'    and a.usrcod  = ? '
              ,'    and a.sissgl  = c.sissgl '
              ,'    and b.macsissgl = c.macsissgl '
              ,'    and c.sisambcod  = 1 '
              ,'  order by b.macsissgl '
   prepare pctx27g00001 from l_sql
   declare cctx27g00001 cursor for pctx27g00001
   let m_prep_ctx27g00 = true
 end function

#-------------------------------------------------------------------------------
 function ctx27g00()
#-------------------------------------------------------------------------------
   define a_ctx27g00   array [100] of record
          macsissgl    like ibpksist.macsissgl
   end record

   define arr_aux  integer
   define w_codigo char(6)

   let int_flag = false
   if m_prep_ctx27g00 is null or
      m_prep_ctx27g00 <> true then
      call ctx27g00_prepare()
   end if

   open window win_ctx27g00 at 09,35 with form "ctx27g00"
        attribute (border, form line 1)

   display "---[ ctx27g00 ]---" at 10,09

  #--------------------------------------------------------
  #  Monta o array com os sistemas
  #
   let w_codigo = g_issk.usrcod using "&&&&&&"

   let arr_aux = 1
   open cctx27g00001 using g_issk.empcod
                          ,w_codigo
   foreach cctx27g00001 into a_ctx27g00[arr_aux].macsissgl
        #if  a_ctx27g00[arr_aux].macsissgl <> "Aceitacao"   and
        #    a_ctx27g00[arr_aux].macsissgl <> "Automovel"   and
        #    a_ctx27g00[arr_aux].macsissgl <> "Central24h"  and
        #    a_ctx27g00[arr_aux].macsissgl <> "Financeiro"  and
        #    a_ctx27g00[arr_aux].macsissgl <> "Ramos"       and
        #    a_ctx27g00[arr_aux].macsissgl <> "Sinistro"    then
        #    continue foreach
        #end if

       let arr_aux = arr_aux + 1

       if  arr_aux > 100 then
           error " Tabela excede limite de 100 linhas. "
           exit foreach
       end if
   end foreach
  #
  #--------------------------------------------------------
   message " <F8> Escolhe"

   call set_count(arr_aux-1)
   display array a_ctx27g00 to s_ctx27g00.*

      on key (interrupt,control-c)
         initialize a_ctx27g00 to null
         exit display

      on key (f8)
         let arr_aux = arr_curr()

         call ctx27g00_sistemas(a_ctx27g00[arr_aux].macsissgl)
   end display

   let int_flag = false
   close window win_ctx27g00

end function

#-----------------------------------------------------------------------------
function ctx27g00_sistemas(w_macsissgl)
#-----------------------------------------------------------------------------

   define w_macsissgl  like ibpksist.macsissgl

   define a_sist       array [100] of record
          sissgl       like issmnivnovo.sissgl
   end record
   define a_sistema    array [100] of record
          acsnivcod    like issmnivnovo.acsnivcod
   end record

   define arr_aux      integer

   let int_flag = false

  #--------------------------------------------------------
  #  Monta o array com os sistemas
  #
   let arr_aux = 1

   declare c_ctx27g00_001 cursor for
           select issmnivnovo.sissgl,
                  acsnivcod
             from ISSMNIVNOVO,
                  IBPKSIST
                  where usrtip = "F"
                    and empcod = g_issk.empcod
                    and usrcod = g_issk.usrcod
                    and ibpksist.sissgl = issmnivnovo.sissgl
                    and ibpksist.macsissgl = w_macsissgl

   foreach c_ctx27g00_001 into a_sist[arr_aux].sissgl,
                              a_sistema[arr_aux].acsnivcod
       let arr_aux = arr_aux + 1
       if  arr_aux > 100 then
           error " Tabela excede limite de 100 linhas. "
           exit foreach
       end if
   end foreach

   case arr_aux
      when 1
           error " Nao existem sistemas disponiveis para consulta. "
      when 2
          call ctx27g00_submenu( a_sist[1].sissgl,
                                 a_sistema[1].acsnivcod )
      otherwise
          open window win_ctx27g00a at 10,40 with form "ctx27g00"
               attribute (border, form line 1)
          display "---[ ctx27g00 ]---" at 10,09
          message " <F8> Escolhe"
          call set_count(arr_aux-1)
          display array a_sist     to s_ctx27g00.*
             on key (interrupt,control-c)
                initialize a_sist     to null
                exit display
             on key (f8)
                let arr_aux = arr_curr()
                call ctx27g00_submenu(a_sist[arr_aux].sissgl,
                                      a_sistema[arr_aux].acsnivcod)
          end display
          close window win_ctx27g00a

   end case

   let int_flag = false

end function
#------------------------------------------------------------------------------
function ctx27g00_submenu(w_sistema)
#------------------------------------------------------------------------------
   define w_sistema    record
          sissgl       like issmnivnovo.sissgl,
          acsnivcod    like issmnivnovo.acsnivcod
   end record

   define a_program    array[100] of record
          prgnom       like ibpkprog.prgnom
   end record

   define a_programa   array[100] of record
          prgsgl       like ibpkprog.prgsgl
   end record

   define w_param      char(300)
   define w_fglgo      char(1000)
   define w_ret        integer

   define arr_aux      integer

   let int_flag = false

  #--------------------------------------------------------
  #  Monta o array com os sistemas
  #
   let arr_aux = 1

   declare c_ctx27g00_002 cursor for
           select prgnom,
                  ibpkprog.prgsgl
             from IBPMSISTPROG,
                  IBPKPROG
                  where ibpmsistprog.sissgl = w_sistema.sissgl
                    and ibpkprog.prgsgl     = ibpmsistprog.prgsgl
                    and ibpkprog.acsnivcod <= w_sistema.acsnivcod
            order by ibpkprog.prgnom

   foreach c_ctx27g00_002 into a_program[arr_aux].prgnom,
                           a_programa[arr_aux].prgsgl

       let arr_aux = arr_aux + 1

       if  arr_aux > 100 then
           error " Tabela excede limite de 100 linhas. "
           exit foreach
       end if
   end foreach
  #
  #--------------------------------------------------------

   case arr_aux
   when 1
       error " Nao existem modulos disponiveis para consulta. "

   when 2
       call chama_prog( w_sistema.sissgl,
                        a_programa[1].prgsgl,
                        " "                        )
            returning w_ret

       if  w_ret = -1  then
           error " Modulo nao disponivel para consulta. "
       end if

   otherwise
       open window win_ctx27g00b at 11,45 with form "ctx27g00"
            attribute (border, form line 1)

       display "---[ ctx27g00 ]---" at 10,09
       message " <F8> Escolhe"

       call set_count(arr_aux-1)
       display array a_program  to s_ctx27g00.*

          on key (interrupt,control-c)
             initialize a_program  to null
             exit display

          on key (f8)
             let arr_aux = arr_curr()

             call chama_prog( w_sistema.sissgl,
                              a_programa[arr_aux].prgsgl,
                              " "                        )
                  returning w_ret

             if  w_ret = -1  then
                 error " Modulo nao disponivel para consulta. "
             end if

       end display
       close window win_ctx27g00b

   end case

   let int_flag = false

end function
