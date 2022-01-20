#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema..: Porto Socorro                                                   #
# Modulo...: cts56g00                                                        #
# Objetivo.: Lista de serviços disponíveis para apólice (problemas)          #
# Analista.: Fabio Costa                                                     #
# PSI      : 246174 - iPhone                                                 #
# Liberacao: 17/11/2009                                                      #
#............................................................................#
# Observacoes                                                                #
#............................................................................#
# Alteracoes                                                                 #
#----------------------------------------------------------------------------#
database porto

define m_cts56g00_prep smallint

#----------------------------------------------------------------
function cts56g00_prepare()
#----------------------------------------------------------------

  define l_sql char(300)

  whenever error continue
  let l_sql = ' select p.c24pbmcod, p.remrquflg ',
              '      , p.sphpbmdes, p.webpbmdes, p.c24pbmdes ',
              '      , p.c24astcod, p.asitipcod ',
              ' from datkpbm p, datkpbmgrp g ',
              ' where p.c24pbmgrpcod = g.c24pbmgrpcod ',
              '   and p.c24pbmstt = "A" ',
              '   and g.atdsrvorg in (1,4) ',
              '   and p.sphpbmdes is not null ',
              '   and p.c24astcod is not null '
  prepare p_pbm_auto_sel from l_sql
  declare c_pbm_auto_sel cursor for p_pbm_auto_sel
  whenever error stop
  
  let m_cts56g00_prep = true

end function

#----------------------------------------------------------------
function cts56g00_sel_pbm_smart(l_param)
#----------------------------------------------------------------

  define l_param record
         ramcod     smallint               ,
         succod     like abbmitem.succod   ,
         aplnumdig  like abbmitem.aplnumdig,
         itmnumdig  like abbmitem.itmnumdig
  end record

  define l_pbm_auto_sel record
         c24pbmcod  like datkpbm.c24pbmcod ,
         remrquflg  like datkpbm.remrquflg ,
         sphpbmdes  like datkpbm.sphpbmdes ,
         webpbmdes  like datkpbm.webpbmdes ,
         c24pbmdes  like datkpbm.c24pbmdes ,
         c24astcod  like datkpbm.c24astcod ,
         asitipcod  like datkpbm.asitipcod
  end record

  define l_cty05g02  record
         resultado    integer ,
         mensagem     char(80),
         flag_limite  char(1)
  end record

  define l_retorno record
         errcod  smallint,
         errmsg  char(60),
         xml     char(32000)
  end record

  define l_aux  char(1000),
         l_ctt  smallint

  initialize l_pbm_auto_sel.* to null
  initialize l_cty05g02.* to null
  initialize l_retorno.* to null
  initialize l_aux to null

  let l_retorno.xml = "<?xml version='1.0' encoding='ISO-8859-1' ?>",
                      "<RESPONSE><LISTAPROBLEMAS>"

  # verificar limite de utilizacao dos servicos da apolice
  call cty05g02_envio_socorro(l_param.ramcod   ,
                              l_param.succod   ,
                              l_param.aplnumdig,
                              l_param.itmnumdig )
                    returning l_cty05g02.resultado,
                              l_cty05g02.mensagem ,
                              l_cty05g02.flag_limite

  if l_cty05g02.resultado is not null and 
     l_cty05g02.resultado = 2
     then
     let l_retorno.xml = l_retorno.xml clipped, "</LISTAPROBLEMAS></RESPONSE>"
     let l_retorno.errcod = 21
     let l_retorno.errmsg = "Erro na selecao da apolice"
     return l_retorno.*
  end if
  
  if l_cty05g02.flag_limite is not null and
     l_cty05g02.flag_limite = "S"
     then
     let l_retorno.xml = l_retorno.xml clipped, "</LISTAPROBLEMAS></RESPONSE>"
     let l_retorno.errcod = 22
     let l_retorno.errmsg = "Limite excedido"
     return l_retorno.*
  end if
  
  if m_cts56g00_prep = false
     then
     call cts56g00_prepare()
  end if

  let l_ctt = 0

  whenever error continue
  foreach c_pbm_auto_sel into l_pbm_auto_sel.*

     initialize l_aux to null
     let l_ctt = l_ctt + 1

     if l_pbm_auto_sel.c24pbmcod is null
        then
        continue foreach
     end if

     let l_aux = '<PROBLEMA><codigoProblema>', l_pbm_auto_sel.c24pbmcod using "<<<<<",
                 '</codigoProblema>'         ,
                 '<descricaoProblemaSmart>'  , l_pbm_auto_sel.sphpbmdes clipped,
                 '</descricaoProblemaSmart>' ,
                 '<descricaoProblemaWeb>'    , l_pbm_auto_sel.webpbmdes clipped,
                 '</descricaoProblemaWeb>'   ,
                 '<descricaoProblema>'       , l_pbm_auto_sel.c24pbmdes clipped,
                 '</descricaoProblema>'      ,
                 '<flagRequerRemocao>'       , l_pbm_auto_sel.remrquflg clipped,
                 '</flagRequerRemocao>'      ,
                 '<codigoAssunto>'           , l_pbm_auto_sel.c24astcod clipped,
                 '</codigoAssunto>'          ,
                 '<codigoAssistencia>'       , l_pbm_auto_sel.asitipcod using "<<<<<",
                 '</codigoAssistencia>'      ,
                 '</PROBLEMA>'              

     if length(l_retorno.xml) > 31000  # limitar tamanho para nao estourar a string
        then
        exit foreach
     end if

     let l_retorno.xml = l_retorno.xml clipped, l_aux clipped

  end foreach
  whenever error stop
  
  let l_retorno.xml = l_retorno.xml clipped, "</LISTAPROBLEMAS></RESPONSE>"
  
  if l_ctt = 0
     then
     let l_retorno.errcod = 100
     let l_retorno.errmsg = "Erro SQL"
  else
     let l_retorno.errcod = 0
     let l_retorno.errmsg = ''
  end if

  return l_retorno.*

end function
