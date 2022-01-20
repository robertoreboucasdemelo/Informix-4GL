###############################################################################
# Nome do Modulo: ctp01m06                                              Pedro #
#                                                                     Marcelo #
# Mostra todos os servicos da apolice que nao foram pesquisados      Mai/1995 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 04/07/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.     #
# 22/09/06   Ligia Mattge  PSI 202720   Implementacao do cartao Saude         # 
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
function ctp01m06(par)
#------------------------------------------------------------
   define par           record
      succod            like datrservapol.succod   ,
      ramcod            like datrservapol.ramcod   ,
      aplnumdig         like datrservapol.aplnumdig,
      itmnumdig         like datrservapol.itmnumdig,
      atdsrvnum         like datmservico.atdsrvnum,
      crtsaunum         like datrligsau.crtnum
   end record

   define a_ctp01m06 array[12] of record
      atdsrvorg         like datmservico.atdsrvorg,
      atdsrvnum         like datmservico.atdsrvnum,
      atddat            like datmservico.atddat   ,
      psqcod            like datmpesquisa.psqcod
   end record

   define ws            record
      atdsrvnum         like datmservico.atdsrvnum,
      atdsrvano         like datmservico.atdsrvano,
      atdsrvorg         like datmservico.atdsrvorg,
      atddat            like datmservico.atddat   ,
      psqcod            like datmpesquisa.psqcod
   end record

   define arr_aux       integer,
          l_sql         char(1000)

open window w_ctp01m06 at  10,48 with form "ctp01m06"
            attribute(form line first, border)

initialize a_ctp01m06  to null
initialize ws.*        to null
let arr_aux = 1
let l_sql = null

### PSI 202720
if par.crtsaunum is not null then
   let l_sql =  ' select datrsrvsau.atdsrvnum, datrsrvsau.atdsrvano,  ',
                ' datmpesquisa.psqcod from datrsrvsau, outer datmpesquisa ',
                ' where datrsrvsau.crtnum  = ', par.crtsaunum,
                ' and datmpesquisa.atdsrvnum = datrsrvsau.atdsrvnum ',
                ' and datmpesquisa.atdsrvano = datrsrvsau.atdsrvano '
else
   let l_sql =  ' select datrservapol.atdsrvnum, datrservapol.atdsrvano,  ',
                ' datmpesquisa.psqcod from datrservapol, outer datmpesquisa ',
                ' where datrservapol.succod  = ', par.succod,
                ' and datrservapol.ramcod    = ', par.ramcod,
                ' and datrservapol.aplnumdig = ', par.aplnumdig,
                ' and datrservapol.itmnumdig = ', par.itmnumdig,
                ' and datmpesquisa.atdsrvnum = datrservapol.atdsrvnum ',
                ' and datmpesquisa.atdsrvano = datrservapol.atdsrvano '
end if

prepare pctp01m06001 from l_sql
declare c_ctp01m06  cursor for pctp01m06001

foreach  c_ctp01m06  into  ws.atdsrvnum,
                           ws.atdsrvano,
                           ws.psqcod

   if ws.atdsrvnum  =  par.atdsrvnum   then
      continue foreach
   else
      if ws.psqcod  is null   then
         let ws.psqcod = "P00"
      end if
   end if

   select atddat, atdsrvorg
     into ws.atddat, ws.atdsrvorg
     from datmservico
    where atdsrvnum = ws.atdsrvnum   and
          atdsrvano = ws.atdsrvano

   if ws.atdsrvorg <>  4    and
      ws.atdsrvorg <>  6    and
      ws.atdsrvorg <>  1    then
      continue foreach
   end if
   let a_ctp01m06[arr_aux].atdsrvorg = ws.atdsrvorg
   let a_ctp01m06[arr_aux].atdsrvnum = ws.atdsrvnum
   let a_ctp01m06[arr_aux].atddat    = ws.atddat
   let a_ctp01m06[arr_aux].psqcod    = ws.psqcod

   let arr_aux = arr_aux + 1
   if arr_aux > 12  then
      error " Limite excedido, apolice c/ mais de 12 servicos a serem pesquisados"
      exit foreach
   end if

end foreach

if arr_aux  >  1   then
   message " (F17)Abandona"
   call set_count(arr_aux-1)

   display array  a_ctp01m06 to s_ctp01m06.*
      on key(interrupt)
         exit display
   end display
else
   error " Nao existem outros servicos a serem pesquisados"
end if

let int_flag = false
close window  w_ctp01m06

end function  #  ctp01m06

