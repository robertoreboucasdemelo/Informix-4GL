#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cty02g01.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 183.431                                                    #
# OSF           : 036.439                                                    #
#                 Chamar metodo opacc156                                     #
#............................................................................#
# Desenvolvimento: Meta, Robson Inocencio                                    #
# Liberacao      : 20/07/2004                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 02/07/2008 Amilton, Meta     Psi 223689 Alterar chamada da função opacc156 #
#                                         para a função cta00m17_chama_prog  #
#----------------------------------------------------------------------------#
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


function cty02g01_prepare()
 define l_sql char(500)
 let l_sql = " select grlinf ",
             "   from datkgeral ",
             "  where grlchv = ? "

 prepare p_cty02g01001 from l_sql
 declare c_cty02g01001 cursor for p_cty02g01001

end function

#---------------------------#
function cty02g01_opacc156()
#---------------------------#
  define l_prporg    like papmhist.prporg
  define l_prpnumdig like papmhist.prpnumdig
  define l_hora2     datetime hour to minute,
         l_hora1     datetime hour to second,
         l_data      date,
         w_ct24      char(04),
         w_grlchv    like datkgeral.grlchv,
         w_grlinf    like datkgeral.grlinf,
         w_empcod    char(02),
         w_funmat    char(06),
         l_msg       char(100)
  define lr_retorno    record
         resultado     smallint
        ,mensagem      char(60)
        ,cvnnum        like abamapol.cvnnum
  end record

  define l_grlchv   like datkgeral.grlchv,
         l_grlinf   like datkgeral.grlinf,
         l_status   smallint,
         m_prep_sql  smallint,
         w_log     char(30)
  let l_prporg    = null
  let l_prpnumdig = null
  let l_hora2     = null
  let l_hora1     = null
  let l_data      = null
  let w_ct24      = null
  let w_grlchv    = null
  let w_grlinf    = null
  let w_empcod    = null
  let w_funmat    = null
  let l_msg       = null
  let m_prep_sql  = null
  let l_status    = null
  initialize lr_retorno.* to null

  call cts40g03_data_hora_banco(1)
       returning l_data, l_hora1
    let w_empcod = g_issk.empcod
    let w_funmat = g_issk.funmat using "&&&&&&"
    let w_grlchv[1,6]  = w_funmat
    let w_grlchv[7,14] = l_hora1
    let w_ct24   = "ct24h"
    let l_grlinf = null
    let l_grlchv = w_grlchv
    initialize lr_retorno to null
     ##-- Selecionar datkgeral --##
    call cta12m00_seleciona_datkgeral(w_grlchv)
         returning lr_retorno.resultado
                  ,lr_retorno.mensagem
                  ,l_grlinf
     if lr_retorno.resultado = 1 then
      ##-- Remove de datkgeral --##
        call cta12m00_remove_datkgeral(w_grlchv)
             returning lr_retorno.resultado
                      ,lr_retorno.mensagem
        if lr_retorno.resultado <> 1 then
           let l_msg = lr_retorno.mensagem
           return l_prporg, l_prpnumdig,l_msg
        else
           ##-- inclui na datkgeral
          call cta12m00_inclui_datkgeral(w_grlchv,
                                         w_ct24,
                                         l_data,
                                         l_hora1,
                                         w_empcod,
                                         w_funmat)
               returning lr_retorno.resultado
                        ,lr_retorno.mensagem
               if lr_retorno.resultado <> 1 then
                  let l_msg = lr_retorno.mensagem
                  return l_prporg, l_prpnumdig,l_msg
               end if
        end if
     else
        ##-- inclui na datkgeral
      call cta12m00_inclui_datkgeral(w_grlchv,
                                     w_ct24,
                                     l_data,
                                     l_hora1,
                                     w_empcod,
                                     w_funmat)
           returning lr_retorno.resultado
                    ,lr_retorno.mensagem
           if lr_retorno.resultado <> 1 then
                 let l_msg = lr_retorno.mensagem
                 return l_prporg, l_prpnumdig,l_msg
           end if
     end if
        call cta00m17_chama_prog("opacm140",
                                 "opacc156",
                                 w_grlchv," "," ")
               returning l_status
       if l_status = 0 then
          if m_prep_sql <> true or
             m_prep_sql is null then
             call cty02g01_prepare()
          end if
          open c_cty02g01001 using w_grlchv
          whenever error continue
           fetch c_cty02g01001 into l_grlinf
          whenever error stop
         if sqlca.sqlcode = 0 then
            let  l_prporg    = l_grlinf[7,8]
            let  l_prpnumdig  = l_grlinf[9,16]                 	
            ## -- remove da datkgeral
            call cta12m00_remove_datkgeral(w_grlchv)
                 returning lr_retorno.resultado
                          ,lr_retorno.mensagem
               if lr_retorno.resultado = 1 then
                 let l_msg = lr_retorno.mensagem
                 return l_prporg, l_prpnumdig,l_msg
               end if
         else
          if sqlca.sqlcode = notfound  then
            let l_msg = " Nenhum registro selecionado.", sqlca.sqlcode,"|",sqlca.sqlerrd[2]
            return l_prporg, l_prpnumdig,l_msg
          else
            let l_msg = " Problema SELECT na tabela datkgeral", sqlca.sqlcode,"|",sqlca.sqlerrd[2]
            return l_prporg, l_prpnumdig,l_msg
          end if
         end if
         close c_cty02g01001
       else
         let l_msg = "Sistema indisponivel no momento !"
             return l_prporg, l_prpnumdig,l_msg
       end if

  {call opacc156()
  returning l_prporg, l_prpnumdig

  return l_prporg, l_prpnumdig}

end function




