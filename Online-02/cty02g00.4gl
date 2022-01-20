#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : CENTRAL 24 HORAS                                           #
# Modulo        : cty02g00                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : 183431                                                     #
# OSF           : 036439                                                     #
#                 Chamada do metodo opacc149.                                #
#............................................................................#
# Desenvolvimento: Robson, META                                              #
# Liberacao      : 20/07/2004                                                #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 02/07/2008 Amilton, Meta     Psi 223689 Alterar chamada da função opacc149 #
#                                         para a função cta00m17_chama_prog  #
#----------------------------------------------------------------------------#


database porto

define m_prep_sql  smallint


globals "/homedsa/projetos/geral/globals/glct.4gl"

function cty02g00_prepare()
 define l_sql char(500)
 let l_sql = " select grlinf ",
             "   from datkgeral ",
             "  where grlchv = ? "

 prepare p_cty02g00001 from l_sql
 declare c_cty02g00001 cursor for p_cty02g00001

 let m_prep_sql = true

end function



#----------------------------------#
function cty02g00_opacc149(lr_parm)
#----------------------------------#
 define lr_parm        record
        prporg         like papmhist.prporg
       ,prpnumdig      like papmhist.prpnumdig
 end record

 define l_hora1     datetime hour to second,
        l_data      date,
        w_ct24      char(04),
        w_grlchv    like datkgeral.grlchv,
        w_grlinf    like datkgeral.grlinf,
        w_empcod    char(02),
        w_funmat    char(06),
        l_msg       char(100)
  define l_grlchv   like datkgeral.grlchv,
         l_grlinf   like datkgeral.grlinf,
         l_status   smallint
  define lr_retorno    record
         resultado     smallint
        ,mensagem      char(60)
        ,cvnnum        like abamapol.cvnnum
  end record
 define l_flag         char(01)
  let l_hora1     = null
  let l_data      = null
  let w_ct24      = null
  let w_grlchv    = null
  let w_grlinf    = null
  let w_funmat    = null
  let l_msg       = null
  let m_prep_sql  = null

   call cty02g00_prepare()

    call cts40g03_data_hora_banco(1)
       returning l_data, l_hora1
    let w_empcod = g_issk.empcod
    let w_funmat = g_issk.funmat using "&&&&&&"
    let w_grlchv[1,6]  = w_funmat
    let w_grlchv[7,14] = l_hora1
    let w_ct24   = "ct24h"
    let l_grlinf = null
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
           return l_flag,l_msg
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
                  return l_flag,l_msg
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
                 return l_flag,l_msg
           end if
     end if
        call cta00m17_chama_prog("opacm140",
                                 "opacc149",
                                 w_grlchv, lr_parm.prporg,lr_parm.prpnumdig)
               returning l_status
       if l_status = 0 then
          if m_prep_sql <> true or
             m_prep_sql is null then
             call cty02g01_prepare()
          end if
          open c_cty02g00001 using w_grlchv
             whenever error continue
               fetch c_cty02g00001 into l_grlinf
             whenever error stop
         if sqlca.sqlcode = 0 then
            let  l_flag    = l_grlinf[7]
            ## -- remove da datkgeral
            call cta12m00_remove_datkgeral(w_grlchv)
                 returning lr_retorno.resultado
                          ,lr_retorno.mensagem
               if lr_retorno.resultado = 1 then
                 let l_msg = lr_retorno.mensagem
                 return l_flag,l_msg
               end if
         else
          if sqlca.sqlcode = notfound  then
            let l_msg = " Nenhum registro selecionado.", sqlca.sqlcode,"|",sqlca.sqlerrd[2]
            return l_flag,l_msg
          else
            let l_msg = " Problema SELECT na tabela datkgeral", sqlca.sqlcode,"|",sqlca.sqlerrd[2]
            return l_flag,l_msg
          end if
         end if
         close c_cty02g00001
       else
         let l_msg = "Sistema indisponivel no momento !"
             return l_flag,l_msg
       end if
{
 let l_flag = null

 if lr_parm.prporg is not null and
    lr_parm.prpnumdig is not null then
    let l_flag = opacc149(lr_parm.*)
 end if

 return l_flag}

end function

