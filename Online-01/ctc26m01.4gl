#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: CT24h                                                     #
# Modulo.........: ctc26m01.4gl                                              #
# Analista Resp..: Glauce Lima                                               #
# PSI/OSF........: 180.475 / 30228                                           #
# Objetivo.......: Popup de Motivos.                                         #
#............................................................................#
# Desenvolvimento: Meta, Bruno Gama                                          #
# Liberacao......: 19/12/2003                                                #
#............................................................................#
#                                                                            #
#                        * * *  ALTERACOES  * * *                            #
#                                                                            #
# Data        Autor Fabrica   PSI/OSF       Alteracao                        #
# ----------  -------------   ------------  -------------------------------- #
# 13/01/2004 ivone, Meta      PSI180475  alterar select para apresentacao    #
#                             OSF030228  na tela,                            #
#                                        retirar da tela o codigo e status do#
#                                        motivo                              #
#............................................................................#

 #globals '/homedsa/fontes/ct24h/producao/glct.4gl'

 #globals 'glct.4gl'

 globals '/homedsa/projetos/geral/globals/glct.4gl'

 define m_prep_sql          smallint

#==============================================================================
 function ctc26m01_prepare()
#==============================================================================

    define l_sql               char(200)

    let l_sql = " select rcuccsmtvcod,      ",
                "        rcuccsmtvdes       ",
                "   from datkrcuccsmtv      ",
                "  where rcuccsmtvstt = 'A' ",
                "  and   c24astcod = ?      ",           #psi180475    ivone
                "  order by 2,1             "
    prepare pctc26m01001    from l_sql
    declare cctc26m01001    cursor for pctc26m01001

    let m_prep_sql = true

 end function

#==============================================================================
 function ctc26m01()
#==============================================================================

    define al_ctc26m01         array[150] of record
           rcuccsmtvdes        like datkrcuccsmtv.rcuccsmtvdes,
           rcuccsmtvcod        like datkrcuccsmtv.rcuccsmtvcod
    end record

    define l_cont              smallint
    define l_arr               smallint
    define l_rcuccsmtvcod      like datkrcuccsmtv.rcuccsmtvcod

      for l_cont  = 1  to 150
          initialize al_ctc26m01[l_cont].* to null
      end for


    if m_prep_sql is null or m_prep_sql <> true then
       call ctc26m01_prepare()
    end if

    let l_cont = 1

    open    cctc26m01001  using g_documento.c24astcod                      #psi180475    ivone

    foreach cctc26m01001   into al_ctc26m01[l_cont].rcuccsmtvcod,
                                al_ctc26m01[l_cont].rcuccsmtvdes

        let l_cont = l_cont + 1

    end foreach

    let l_rcuccsmtvcod = null

    if l_cont = 1 then
       let l_rcuccsmtvcod = 0               #psi180475  ivone
    else
       call set_count(l_cont - 1)

       open window w_ctc26m01 at 4,6 with form "ctc26m01" attribute (form line 1)

       display array al_ctc26m01 to s_ctc26m01.*           #psi180475  ivone
            on key (f8)
               let l_arr = arr_curr()
               let l_rcuccsmtvcod = al_ctc26m01[l_arr].rcuccsmtvcod
               exit display

            on key (f17, control-c, interrupt)
               exit display
       end display

       let int_flag = false

       close window w_ctc26m01
    end if

    return l_rcuccsmtvcod

 end function
