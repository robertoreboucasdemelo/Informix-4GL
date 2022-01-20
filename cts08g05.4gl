###############################################################################
# Nome do Modulo: cts08g05                                           Andre    #
#                                                                    Pinto    #
# Janela para Inclusão de mensagens (para ser exibido com cts08g01)  Ago/2008 #
#-----------------------------------------------------------------------------#
#                   * * * Alteracoes * * *                                    #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 29/12/2009 Fabio Costa       PSI 198404 Tratar fim de linha windows Ctrl+M  #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_retorno   char(321)

#-----------------------------------------------------------------------------
function cts08g05(l_tit, l_msg)
#-----------------------------------------------------------------------------
 define cts08g05 record
    linha1           char (40),
    linha2           char (40),
    linha3           char (40),
    linha4           char (40)
 end record
 define l_tit char(40)
 define l_msg char(255)

 initialize  cts08g05.*  to  null
 let m_retorno = null
 open window w_cts08g05 at 11,19 with form "cts08g05"
           attribute(border, form line first, message line last - 1)
     display l_tit to tit
     if l_msg is not null then
          let cts08g05.linha1 = l_msg[1,40]
          let cts08g05.linha2 = l_msg[41,80]
          let cts08g05.linha3 = l_msg[81,120]
          let cts08g05.linha4 = l_msg[121,160]
     end if
     input by name cts08g05.linha1,
                   cts08g05.linha2,
                   cts08g05.linha3,
                   cts08g05.linha4 without defaults
     let m_retorno = cts08g05.linha1 ,
                     cts08g05.linha2 ,
                     cts08g05.linha3 ,
                     cts08g05.linha4
 let int_flag = false
 close window w_cts08g05

 return m_retorno clipped

end function


#-----------------------------------------------------------------------------
function cts08g05_61(l_tit, l_msg)
#-----------------------------------------------------------------------------
 define cts08g05 record
    linha1           char (40),
    linha2           char (40),
    linha3           char (40),
    linha4           char (40),
    linha5           char (40),
    linha6           char (40)
 end record
 define l_tit char(40)
 define l_msg char(255)

 initialize  cts08g05.*  to  null
 let m_retorno = null
 open window w_cts08g05 at 11,19 with form "cts08g05b"
          attribute(border, form line first, message line last - 1)
     display l_tit to tit
     if l_msg is not null then
          let cts08g05.linha1 = l_msg[1,40]
          let cts08g05.linha2 = l_msg[41,80]
          let cts08g05.linha3 = l_msg[81,120]
          let cts08g05.linha4 = l_msg[121,160]
          let cts08g05.linha5 = l_msg[161,200]
          let cts08g05.linha6 = l_msg[201,240]
     end if
     input by name cts08g05.linha1,
                   cts08g05.linha2,
                   cts08g05.linha3,
                   cts08g05.linha4,
                   cts08g05.linha5,
                   cts08g05.linha6  without defaults
     let m_retorno = cts08g05.linha1 ,
                     cts08g05.linha2 ,
                     cts08g05.linha3 ,
                     cts08g05.linha4 ,
                     cts08g05.linha5 ,
                     cts08g05.linha6
 let int_flag = false
 close window w_cts08g05

 return m_retorno clipped

end function

#-----------------------------------------------------------------------------
function cts08g05_81(l_tit, l_msg)
#-----------------------------------------------------------------------------
 define cts08g05 record
    linha1           char (40),
    linha2           char (40),
    linha3           char (40),
    linha4           char (40),
    linha5           char (40),
    linha6           char (40),
    linha7           char (40),
    linha8           char (40)
 end record
 define l_tit char(40)
 define l_msg char(321)

 initialize  cts08g05.*  to  null
 let m_retorno = null
 open window w_cts08g05 at 11,19 with form "cts08g05c"
           attribute(border, form line first, message line last - 1)
     display l_tit to tit
     if l_msg is not null then
          let cts08g05.linha1 = l_msg[1,40]
          let cts08g05.linha2 = l_msg[41,80]
          let cts08g05.linha3 = l_msg[81,120]
          let cts08g05.linha4 = l_msg[121,160]
          let cts08g05.linha5 = l_msg[161,200]
          let cts08g05.linha6 = l_msg[201,240]
          let cts08g05.linha7 = l_msg[241,280]
          let cts08g05.linha8 = l_msg[281,320]
     end if
     input by name cts08g05.linha1,
                   cts08g05.linha2,
                   cts08g05.linha3,
                   cts08g05.linha4,
                   cts08g05.linha5,
                   cts08g05.linha6,
                   cts08g05.linha7,
                   cts08g05.linha8  without defaults
     let m_retorno = cts08g05.linha1 ,
                     cts08g05.linha2 ,
                     cts08g05.linha3 ,
                     cts08g05.linha4 ,
                     cts08g05.linha5 ,
                     cts08g05.linha6 ,
                     cts08g05.linha7 ,
                     cts08g05.linha8
 let int_flag = false
 close window w_cts08g05

 return m_retorno clipped

end function
