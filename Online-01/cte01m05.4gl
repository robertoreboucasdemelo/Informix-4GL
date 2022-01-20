###############################################################################
# Nome do Modulo: cte01m05                                           Raji     #
#                                                                             #
# Informacoes das alteracoes de status                               Set/2000 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 02/04/2001  PSI 12801-5  Wagner       Acesso iddkdominio 'c24pndsitcod'     #
###############################################################################

 database porto

 globals "/homedsa/projetos/geral/globals/glcte.4gl"

#--------------------------------------------------------------------
 function cte01m05(param)
#--------------------------------------------------------------------
 define param      record
    corlignum      like dacmatdpndsit.corlignum,
    corligano      like dacmatdpndsit.corligano,
    corligitmseq   like dacmatdpndsit.corligitmseq
 end record

 define d_cte01m05   record
    corasscod        like dackass.corasscod       ,
    corassdes        like dackass.corassdes
 end record

 define ws           record
    totqtd           smallint
 end record

 define a_cte01m05   array[10] of record
    c24pndsitcod     like dacmatdpndsit.c24pndsitcod,
    pndsitdes        char (15)                    ,
    caddat           like dacmatdpndsit.caddat    ,
    cadhor           like dacmatdpndsit.cadhor    ,
    cademp           like dacmatdpndsit.cademp    ,
    cadmat           like dacmatdpndsit.cadmat    ,
    responsavel      char (21)
 end record

 define arr_aux      smallint
 define scr_aux      smallint

 define sql_comando  char (900)


#--------------------------------------------------------------------
# Cursor para obtencao situacao da pendencia
#--------------------------------------------------------------------
 let sql_comando = "select c24pndsitcod  ,",
                   "       caddat        ,",
                   "       cadhor        ,",
                   "       cademp        ,",
                   "       cadmat         ",
                   "  from dacmatdpndsit  ",
                   " where corlignum = ?  ",
                   "   and corligano = ?  ",
                   "   and corligitmseq = ? ",
                   " order by caddat,cadhor"

 prepare select_sitrecl from sql_comando
 declare c_cte01m05 cursor with hold for select_sitrecl

#--------------------------------------------------------------------
# Cursor para obtencao da descricao do codigo de situacao
#--------------------------------------------------------------------
 let sql_comando = "select cpodes from iddkdominio",
                   " where cponom = 'c24pndsitcod'",
                   "   and cpocod = ?"

 prepare select_dominio from sql_comando
 declare c_cte01m05_dominio cursor with hold for select_dominio

#--------------------------------------------------------------------
# Cursor para obtencao do usuario responsavel pela mudanca da situacao
#--------------------------------------------------------------------
 let sql_comando = "select funnom from isskfunc",
                   " where empcod = ?      ",
                   "   and funmat = ?      "
 prepare select_fun from sql_comando
 declare c_cte01m05_fun cursor with hold for select_fun


 open window w_cte01m05 at 06,02 with form "cte01m05"
             attribute(form line 1)

#--------------------------------------------------------------------
# Inicializacao das variaveis
#--------------------------------------------------------------------
 initialize a_cte01m05    to null
 initialize ws.*          to null

 message " Aguarde, pesquisando..."  attribute(reverse)

#--------------------------------------------------------------------
# Busca codigo e descricao do assunto
#--------------------------------------------------------------------
 # CODIGO ASSUSNTO
 select corasscod
   into d_cte01m05.corasscod
   from dacmligass
  where corlignum = param.corlignum
    and corligano = param.corligano
    and corligitmseq = param.corligitmseq
 if sqlca.sqlcode <> 0  then
    initialize d_cte01m05.corasscod to null
 end if
 # DESCRICAO ASSUSNTO
 select corassdes
   into d_cte01m05.corassdes
   from dackass
  where corasscod = d_cte01m05.corasscod
 if sqlca.sqlcode <> 0  then
    initialize d_cte01m05.corassdes to null
 end if

 display by name param.corlignum
 display by name param.corligano
 display by name param.corligitmseq
 display by name d_cte01m05.corasscod
 display by name d_cte01m05.corassdes

 let ws.totqtd = 0
 let arr_aux   = 1

 open  c_cte01m05  using    param.corlignum,
                            param.corligano,
                            param.corligitmseq

 foreach c_cte01m05  into   a_cte01m05[arr_aux].c24pndsitcod,
                            a_cte01m05[arr_aux].caddat,
                            a_cte01m05[arr_aux].cadhor,
                            a_cte01m05[arr_aux].cademp,
                            a_cte01m05[arr_aux].cadmat

    open  c_cte01m05_fun  using  a_cte01m05[arr_aux].cademp,
                                 a_cte01m05[arr_aux].cadmat
    fetch c_cte01m05_fun  into   a_cte01m05[arr_aux].responsavel
    close c_cte01m05_fun

    open  c_cte01m05_dominio  using  a_cte01m05[arr_aux].c24pndsitcod
    fetch c_cte01m05_dominio  into   a_cte01m05[arr_aux].pndsitdes
    close c_cte01m05_dominio

    let arr_aux = arr_aux + 1
    if arr_aux  >  10   then
      error " Limite excedido. Foram encontradas mais de 10 mudancas de status!"
      exit foreach
    end if

 end foreach

 if arr_aux = 1  then
    message ""
    error " Nao existem situacoes para a pesquisa!"
 else
    message "(F17) Abandona"
    display array a_cte01m05 to s_cte01m05.*
       on key(interrupt)
          exit display
    end display
 end if

 let int_flag = false
 close window w_cte01m05

end function  ##-- cte01m05

