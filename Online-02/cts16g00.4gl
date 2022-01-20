#############################################################################
# Nome do Modulo: CTS16G00                                         Marcelo  #
#                                                                  Gilberto #
#                                                                  Wagner   #
# Verifica outros servicos da mesma apolice                        Jun/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 24/06/1999  PSI 7547-7   Wagner       Substituicao da situacao pela ulti- #
#                                       ma etapa do servico.                #
#---------------------------------------------------------------------------#
# 10/08/1999  Sup.Tecnico  Gilberto     Impedir acesso caso documento/placa #
#                                       nao sejam informados e especificar  #
#                                       periodo (data inicial/final) para   #
#                                       pesquisa.                           #
#---------------------------------------------------------------------------#
# 06/07/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.   #
#---------------------------------------------------------------------------#
# 21/03/2001  PSi 12768-0  Wagner       Receber nr de dias para a pesquisa  #
#                                       pelo parametro.                     #
#---------------------------------------------------------------------------#
#                     **** Alteracoes Meta ****                             #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- ----------------------------------#
# 12/04/2004 Paulo, Meta       PSI 182559 Reestruturar a funcao cts16g00,   #
#                              OSF 34371  criando a funcao cts16g00_servicos#
#                                         para carregar o array com os      #
#                                         servicos e tambem retornar uma    #
#                                         string com todos estes servicos, a#
#                                         a qual sera utilizada por outro   #
#                                         modulo.                           #
#---------------------------------------------------------------------------#
# 27/05/2004 Marcio (FSW)      CT-213004  Alteracao nas condições do if     #
#---------------------------------------------------------------------------#
# 28/09/2012  Raul Biztalking          Retirar empresa 1 fixa p/ funcionario#
#############################################################################

 database porto

### Inicio PSI182559 - Paulo
#
define m_prep_sql   smallint
      ,m_array      smallint

define am_cts16g00  array[50]  of record
       atddat           like datmservico.atddat
      ,atdhor           like datmservico.atdhor
      ,atdsrvorg        like datmservico.atdsrvorg
      ,atdsrvnum        like datmservico.atdsrvnum
      ,atdsrvano        like datmservico.atdsrvano
      ,srvtipabvdes     like datksrvtip.srvtipabvdes
      ,atendente        char (10)
      ,c24solnom        like datmservico.c24solnom
end record

#-----------------------------------------------------------------------------
function cts16g00_prepare()
#-----------------------------------------------------------------------------
 define l_sql     char(500)

 let l_sql = 'select a.atdetpcod '
            ,'  from datmsrvacp a '
            ,' where a.atdsrvnum = ? '
              ,' and a.atdsrvano = ? '
              ,' and a.atdsrvseq = (select max(b.atdsrvseq) '
                                ,'  from datmsrvacp b '
                                ,' where b.atdsrvnum = a.atdsrvnum '
                                  ,' and b.atdsrvano = a.atdsrvano)'

 prepare p_cts16g00_001 from l_sql
 declare c_cts16g00_001 cursor for p_cts16g00_001

 let l_sql = 'select srvtipabvdes '
            ,'  from datksrvtip '
            ,' where atdsrvorg = ? '

 prepare p_cts16g00_002 from l_sql
 declare c_cts16g00_002 cursor for p_cts16g00_002

 let l_sql = 'select funnom '
            ,'  from isskfunc '
            ,' where empcod = ? '
              ,' and funmat = ? '

 prepare p_cts16g00_003 from l_sql
 declare c_cts16g00_003 cursor for p_cts16g00_003

 let m_prep_sql = true

end function
#
### Final PSI182559 - Paulo

#-----------------------------------------------------------------------------
 function cts16g00(param)
#-----------------------------------------------------------------------------

 define param        record
    succod           like datrservapol.succod,
    ramcod           like datrservapol.ramcod,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    atdsrvorg        like datmservico.atdsrvorg,
    vcllicnum        like datmservico.vcllicnum,
    nrdias           integer,
    crtsaunum        like datrligsau.crtnum
 end record

 ### Inicio PSI182559 - Paulo
 #
 define l_str        char(5000)

 define lr_dados     record
        str          char(5000),
        atdsrvnum    like datmservico.atdsrvnum,
        atdsrvano    like datmservico.atdsrvano
 end record

 initialize am_cts16g00   to null
 initialize lr_dados.*  to  null

 let m_array = 1

 if param.succod    is null   or
    param.ramcod    is null   or
    param.aplnumdig is null   or
    param.itmnumdig is null   then
    if param.crtsaunum is null then
       return  am_cts16g00[m_array].atdsrvnum,
               am_cts16g00[m_array].atdsrvano,
               am_cts16g00[m_array].atdsrvorg
    end if
 end if

 set isolation to dirty read

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts16g00_prepare()
 end if

 let int_flag  = false

 call cts16g00_servicos(param.succod,
                	param.ramcod,
			param.aplnumdig,
			param.itmnumdig,
			param.atdsrvorg,
			param.vcllicnum,
			param.nrdias,
			param.crtsaunum)
  returning lr_dados.*


### Final PSI182559 - Paulo

#------------------------------------------------------------------------
# Exibe servicos solicitados
#------------------------------------------------------------------------

 if m_array  >  0   then           #CT-213004
    open window w_cts16g00 at 10,05 with form "cts16g00"
         attribute(form line 1, border, message line last - 1)

    display param.nrdias to nrdias

    message " (F17)Abandona, (F8)Seleciona"

    call set_count(m_array)

    display array am_cts16g00 to s_cts16g00.*

       on key (interrupt)
          initialize am_cts16g00   to null
          let m_array = 1
          exit display

       on key (F8)
          let m_array = arr_curr()
          exit display

    end display

    close window  w_cts16g00
 else
    error " Nao existe servicos anteriores para pesquisa!"
    initialize am_cts16g00   to null
    let m_array = 1
    let am_cts16g00[m_array].atdsrvorg = 0
 end if

 let int_flag = false

 set isolation to committed read

 return am_cts16g00[m_array].atdsrvnum,
        am_cts16g00[m_array].atdsrvano,
        am_cts16g00[m_array].atdsrvorg

end function  ###  cts16g00


#-----------------------------------------------------------------------------
 function cts16g00_atendimento(param)   #  tabela datmservico
#-----------------------------------------------------------------------------

 define param        record
    atdsrvnum        like datmservicocmp.atdsrvnum,
    atdsrvano        like datmservicocmp.atdsrvano
 end record

 define retorno      record
    nom              like datmservico.nom,
    vclcorcod        like datmservico.vclcorcod,
    vclcordes        char(20)
 end record

 define ws           record
    sql              char(250)
 end record




	initialize  retorno.*  to  null

	initialize  ws.*  to  null

 initialize retorno.* to null
 initialize ws.*      to null

 let ws.sql = "select nom, vclcorcod ",
              "  from datmservico    ",
              " where datmservico.atdsrvnum = ? ",
              "   and datmservico.atdsrvano = ? "

 prepare p_cts16g00_004  from ws.sql
 declare c_cts16g00_004 cursor for p_cts16g00_004

 open  c_cts16g00_004 using  param.atdsrvnum,
                        param.atdsrvano
 fetch c_cts16g00_004 into   retorno.nom, retorno.vclcorcod
 close c_cts16g00_004

 if sqlca.sqlcode = 0 then
    let retorno.vclcordes = "NAO EXISTE!"
    select cpodes
      into retorno.vclcordes
      from iddkdominio
     where cponom = "vclcorcod"
       and cpocod = retorno.vclcorcod
 end if

 return retorno.*

end function  ###  cts16g00_atendimento

#-----------------------------------------------------------------------------
 function cts16g00_complemento(param)   #  tabela datmservicocmp (COMPLEMENTO)
#-----------------------------------------------------------------------------

 define param        record
    atdsrvnum        like datmservicocmp.atdsrvnum,
    atdsrvano        like datmservicocmp.atdsrvano
 end record

 define retorno      record
    sinvitflg        like datmservicocmp.sinvitflg,
    bocnum           like datmservicocmp.bocnum,
    bocemi           like datmservicocmp.bocemi,
    vcllibflg        like datmservicocmp.vcllibflg,
    roddantxt        like datmservicocmp.roddantxt,
    sindat           like datmservicocmp.sindat,
    sinhor           like datmservicocmp.sinhor
 end record

 define ws           record
    sql              char(400)
 end record




	initialize  retorno.*  to  null

	initialize  ws.*  to  null

 initialize retorno.* to null
 initialize ws.*      to null

 let ws.sql = "select datmservicocmp.sinvitflg   , ",
              "       datmservicocmp.bocnum      , ",
              "       datmservicocmp.bocemi      , ",
              "       datmservicocmp.vcllibflg   , ",
              "       datmservicocmp.roddantxt   , ",
              "       datmservicocmp.sindat      , ",
              "       datmservicocmp.sinhor        ",
              "  from datmservicocmp               ",
              " where datmservicocmp.atdsrvnum = ? ",
              "   and datmservicocmp.atdsrvano = ? "

 prepare p_cts16g00_005  from ws.sql
 declare c_cts16g00_005 cursor for p_cts16g00_005

 open  c_cts16g00_005 using  param.atdsrvnum,
                               param.atdsrvano
 fetch c_cts16g00_005 into   retorno.sinvitflg , retorno.bocnum    ,
                               retorno.bocemi    , retorno.vcllibflg ,
                               retorno.roddantxt , retorno.sindat    ,
                               retorno.sinhor
 close c_cts16g00_005

 return retorno.*

end function  ###  cts16g00_atendimento

### Inicio PSI182559 - Paulo
#
#----------------------------------
function cts16g00_servicos(lr_par)
#----------------------------------
 define lr_par       record
        succod       like datrservapol.succod
       ,ramcod       like datrservapol.ramcod
       ,aplnumdig    like datrservapol.aplnumdig
       ,itmnumdig    like datrservapol.itmnumdig
       ,atdsrvorg    like datmservico.atdsrvorg
       ,vcllicnum    like datmservico.vcllicnum
       ,nrdias       integer
       ,crtsaunum    like datrligsau.crtnum
 end record

 define l_sql        char(800)
       ,l_x          smallint
       ,l_dtini      date
       ,l_dtfim      date
       ,l_funmat     like datmservico.funmat
       ,l_atdetpcod  like datmsrvacp.atdetpcod
       ,l_erro       smallint
       ,l_empcod     like datmservico.empcod                          #Raul, Biz
 define lr_ret       record
        str          char(5000),
        atdsrvnum    like datmservico.atdsrvnum,
        atdsrvano    like datmservico.atdsrvano
 end record
 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts16g00_prepare()
 end if

 initialize lr_ret.*  to  null

 if lr_par.succod    is not null and
    lr_par.ramcod    is not null and
    lr_par.aplnumdig is not null and
    lr_par.itmnumdig is not null then
    let l_sql = 'select b.atddat, b.atdhor, b.atdsrvnum, b.atdsrvano, b.funmat, '
                     ,' b.c24solnom, b.atdsrvorg, b.empcod '          #Raul, Biz
               ,'  from datrservapol a, datmservico b '
               ,' where a.succod     =  ? '
                 ,' and a.ramcod     =  ? '
                 ,' and a.aplnumdig  =  ? '
                 ,' and a.itmnumdig  =  ? '
                 ,' and a.edsnumref >=  0 '
                 ,' and b.atdsrvnum = a.atdsrvnum '
                 ,' and b.atdsrvano = a.atdsrvano '
               ,' order by atddat desc, atdhor asc '
 else
    if lr_par.vcllicnum is not null then
       let l_sql = 'select atddat, atdhor, atdsrvnum, atdsrvano, funmat, c24solnom, atdsrvorg, '
                  ,'empcod '                                          #Raul, Biz
                  ,'  from datmservico '
                  ,' where atddat between  ?  and  ?   '
                    ,' and atdsrvorg in (1,2,3,4,5,6,8,9,13) '
                    ,' and vcllicnum   =  ? '
                  ,' order by atddat desc, atdhor asc '
    else
       if lr_par.crtsaunum is not null then
          let l_sql =  ' select b.atddat, b.atdhor, b.atdsrvnum, b.atdsrvano, '
                      ,' b.funmat, b.c24solnom, b.atdsrvorg,'
                      ,' b.empcod '                                   #Raul, Biz
                      ,' from datrsrvsau a, datmservico b '
                      ,' where a.crtnum     =  ? '
                      ,' and b.atdsrvnum = a.atdsrvnum '
                      ,' and b.atdsrvano = a.atdsrvano '
                      ,' order by atddat desc, atdhor asc '

       else
          let lr_ret.str = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                     ,"<servicos>ERRO</servicos>"
          return lr_ret.*
       end if
    end if
 end if

 prepare pcts16g00001 from l_sql
 declare ccts16g00001 cursor for pcts16g00001

 let l_dtini = today - lr_par.nrdias units day
 let l_dtfim = today

 if lr_par.succod    is not null and
    lr_par.ramcod    is not null and
    lr_par.aplnumdig is not null and
    lr_par.itmnumdig is not null then
    open ccts16g00001 using lr_par.succod
                           ,lr_par.ramcod
                           ,lr_par.aplnumdig
                           ,lr_par.itmnumdig
  else
     if lr_par.vcllicnum  is not null then
        open ccts16g00001 using l_dtini ,l_dtfim ,lr_par.vcllicnum
     else
        open ccts16g00001 using lr_par.crtsaunum
     end if
 end if

 initialize am_cts16g00   to null
 let m_array = 1
 let l_erro  = false
 foreach ccts16g00001 into am_cts16g00[m_array].atddat
                          ,am_cts16g00[m_array].atdhor
                          ,am_cts16g00[m_array].atdsrvnum
                          ,am_cts16g00[m_array].atdsrvano
                          ,l_funmat
                          ,am_cts16g00[m_array].c24solnom
                          ,am_cts16g00[m_array].atdsrvorg
                          ,l_empcod                                   #Raul, Biz

    if am_cts16g00[m_array].atddat < l_dtini or
       am_cts16g00[m_array].atddat > l_dtfim then
       continue foreach
    end if

#  CT-213004 - inicio
#   if am_cts16g00[m_array].atdsrvorg < 1    or
#      am_cts16g00[m_array].atdsrvorg = 7    or
#     (am_cts16g00[m_array].atdsrvorg > 9    and
#      am_cts16g00[m_array].atdsrvorg <> 13) then
#      continue foreach
#   end if

    if am_cts16g00[m_array].atdsrvorg = 1    or
       am_cts16g00[m_array].atdsrvorg = 2    or
       am_cts16g00[m_array].atdsrvorg = 3    or
       am_cts16g00[m_array].atdsrvorg = 4    or
       am_cts16g00[m_array].atdsrvorg = 5    or
       am_cts16g00[m_array].atdsrvorg = 6    or
       am_cts16g00[m_array].atdsrvorg = 8    or
       am_cts16g00[m_array].atdsrvorg = 9    or
       am_cts16g00[m_array].atdsrvorg = 13   then
    else
       continue foreach
    end if
#  CT-213004 - fim

    open c_cts16g00_001 using am_cts16g00[m_array].atdsrvnum
                           ,am_cts16g00[m_array].atdsrvano
    whenever error continue
    fetch c_cts16g00_001 into l_atdetpcod
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          continue foreach
       else
          error 'Erro SELECT c_cts16g00_001 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
          error 'CTS16G00 / cts16g00_servicos() / ',am_cts16g00[m_array].atdsrvnum,' / '
                                                   ,am_cts16g00[m_array].atdsrvano  sleep 2
          let l_erro  = true
          exit foreach
       end if
    end if

    if l_atdetpcod = 5  or    ### Servico CANCELADO
       l_atdetpcod = 6  then  ### Servico EXCLUIDO
       continue foreach
    end if

    open c_cts16g00_002 using am_cts16g00[m_array].atdsrvorg
    whenever error continue
    fetch c_cts16g00_002 into am_cts16g00[m_array].srvtipabvdes
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let am_cts16g00[m_array].srvtipabvdes = null
       else
          error 'Erro SELECT c_cts16g00_002 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
          error 'CTS16G00 / cts16g00_servicos() / ',am_cts16g00[m_array].srvtipabvdes  sleep 2
          let l_erro  = true
          exit foreach
       end if
    end if

    open c_cts16g00_003 using l_empcod, l_funmat
    whenever error continue
    fetch c_cts16g00_003 into am_cts16g00[m_array].atendente
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let am_cts16g00[m_array].atendente = null
       else
          error 'Erro SELECT c_cts16g00_003 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
          error 'CTS16G00 / cts16g00_servicos() / ',l_funmat  sleep 2
          let l_erro  = true
          exit foreach
       end if
    end if

    let am_cts16g00[m_array].atendente = upshift(am_cts16g00[m_array].atendente)

    let m_array = m_array + 1

    if m_array > 50 then
       error " Limite excedido, pesquisa com mais de 50 servicos solicitados!"
       exit foreach
    end if

 end foreach

 let m_array = m_array - 1

 if l_erro then
    let lr_ret.str = "<?xml version='1.0' encoding='ISO-8859-1'?>"
               ,"<servicos>ERRO</servicos>"
    initialize am_cts16g00  to null
    return lr_ret.*
 end if
 initialize lr_ret.* to null
 let lr_ret.str = "<?xml version='1.0' encoding='ISO-8859-1'?>"
 let lr_ret.str = lr_ret.str  clipped, "<servicos><ServicoObrigatorio>S</ServicoObrigatorio>"
 let lr_ret.str = lr_ret.str  clipped, "<servicoqtd>", m_array using '<<<<<', "</servicoqtd>"

 for l_x = 1 to m_array
     let lr_ret.str = lr_ret.str  clipped
                ,"<servico",       l_x  using '<<<<<'                            ,">"
                ,"<atddat>",       am_cts16g00[l_x].atddat     using 'dd/mm/yyyy',"</atddat>"
                ,"<atdhor>",       am_cts16g00[l_x].atdhor                       ,"</atdhor>"
                ,"<atdsrvorg>",    am_cts16g00[l_x].atdsrvorg  using '<<<<<<'    ,"</atdsrvorg>"
                ,"<atdsrvnum>",    am_cts16g00[l_x].atdsrvnum  using '<<<<<<<<<<',"</atdsrvnum>"
                ,"<atdsrvano>",    am_cts16g00[l_x].atdsrvano  using '<<'        ,"</atdsrvano>"
                ,"<srvtipabvdes>", am_cts16g00[l_x].srvtipabvdes  clipped        ,"</srvtipabvdes>"
                ,"<atendente>",    am_cts16g00[l_x].atendente     clipped        ,"</atendente>"
                ,"<c24solnom>",    am_cts16g00[l_x].c24solnom     clipped        ,"</c24solnom>"
                ,"</servico",      l_x  using '<<<<'                             ,">"
 end for

 let lr_ret.str = lr_ret.str  clipped, "</servicos>"
 if m_array = 1 then
    let lr_ret.atdsrvnum = am_cts16g00[1].atdsrvnum
    let lr_ret.atdsrvano = am_cts16g00[1].atdsrvano
 end if

 return lr_ret.*

end function
#
### Final PSI182559 - Paulo)
