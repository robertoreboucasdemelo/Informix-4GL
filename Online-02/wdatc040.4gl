#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema........: Ct24h                                                       #
# Modulo         : wdatc040.4gl                                                #
#                  Valida e atualiza sessao                                    #
# Analista Resp. : Carlos Pessoto                                              #
# PSI            : 163759 -                                                    #
# OSF            : 5289   -                                                    #
#..............................................................................#
# Desenvolvimento: Fabrica de Software - Ronaldo Marques                       #
# Liberacao      : 26/06/2003                                                  #
#..............................................................................#
#                                                                              #
#                          * * *  ALTERACOES  * * *                            #
#                                                                              #
# Data       Analista Resp/Autor Fabrica  PSI/Alteracao                        #
# ---------- ---------------------------- -------------------------------------#
# 05/10/2004 Carlos Zyon/META, Marcos MP  187801/Nao demonstrar a 'Placa' e    #
#                                         incluir as colunas 'Valor do Servico'#
#                                         e 'Valor do Pedagio'.                #
#------------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                           #
#                                                                              #
# Data       Autor Fabrica         PSI    Alteracoes                           #
# ---------- --------------------- ------ -------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias Incluida funcao fun_dba_abre_banco.  #
#------------------------------------------------------------------------------#
# 24/08/2006 Cristiane Silva   PSI197858  Visualizar Descontos da OP.          #
#------------------------------------------------------------------------------#
# 22/05/2012 Jose Kurihara     PSI-11-19199-PR Implementar Optante Simples     #
#------------------------------------------------------------------------------#
# 20/11/2012 Raul, BIZ         PSI-2012-23608  Retornar dados do endereco      #
#                                              localizado no tributos          #
################################################################################

database porto
globals "/homedsa/projetos/geral/globals/ffpgc370.4gl"   #Fornax-Quantum
globals "/homedsa/projetos/geral/globals/ffpgc361.4gl"  #Fornax-Quantum
define m_path char(100)

main

    call fun_dba_abre_banco("CT24HS")
    set isolation to dirty read
    set lock mode to wait 10
    let m_path = "/webserver/cgi-bin/ct24h/trs/wdatc040.log"
    call startlog(m_path)
    run "chmod 777 /webserver/cgi-bin/ct24h/trs/wdatc040.log "

    call wdatc040()
end main
------------------#
function wdatc040()
------------------#

 define lr_par_in   record     # PSI-11-19199
        etapa       char(01)
       ,optante     char(03)
       ,aliquota    char(10)
 end record

 define param       record
    usrtip          char (1),
    webusrcod       char (06),
    sesnum          char (10),
    macsissgl       char (10)
 end record

 define ws          record
   statusprc        dec  (1,0),
   sestblvardes1    char (256),
   sestblvardes2    char (256),
   sestblvardes3    char (256),
   sestblvardes4    char (256),
   sespcsprcnom     char (256),
   prgsgl           char (256),
   acsnivcod        dec  (1,0),
   webprscod        dec  (16,0)
 end record

 define l_servicos      record
        atdsrvorg       like datmservico.atdsrvorg,
        atdsrvnum       like dbsmopgitm.atdsrvnum,
        atdsrvano       like dbsmopgitm.atdsrvano,
        atddat          like datmservico.atddat,
        atdhor          like datmservico.atdhor,
        srrcoddig       like datmservico.srrcoddig,
        srrabvnom       like datksrr.srrabvnom,
        atdvclsgl       like datmservico.atdvclsgl,
        socvclcod       like datmservico.socvclcod,  # OSF 20370
        cidnom          like datmlcl.cidnom,
        lclbrrnom       like datmlcl.lclbrrnom,
        socopgitmvlr    like dbsmopgitm.socopgitmvlr,
        ciaempcod       like datmservico.ciaempcod
 end    record

 define l_impressao     record
        pstcoddig       like dbsmopg.pstcoddig,
        cgccpfnum       like dpaksocor.cgccpfnum,
        cgcord          like dpaksocor.cgcord,
        cgccpfdig       like dpaksocor.cgccpfdig,
        socfatentdat    like dbsmopg.socfatentdat,
        nomrazsoc       like dpaksocor.nomrazsoc,
        qldgrades    char(12),
        crnpgtdes    like dbsmcrnpgt.crnpgtdes,
        tipOP        char(20),
        socopgitmnum    like dbsmopgitm.socopgitmnum,
        incvlr          like dbsmsrvacr.incvlr,
        totvlr          dec(20,5),
        srvvlr          dec(20,5), #=> PSI.187801
        pdgvlr          dec(20,5), #=> PSI.187801
        pecvlr          dec(20,5),
        fnlvlr          like dbsmsrvacr.fnlvlr,
        nomrazemp       char(100),
        cnpjsuc         char(100),
        cnpjsucformat   char(100),
        endsuc          char(100),
        brrsuc          char(100),
        inscsuc         char(100),
        inscemp         char(100),
        nomatvpri       char(150),
        prmvlr          dec(20,5)
 end    record

 define l_totais        record
        incvlr          dec(20,5),
        totvlr          dec(20,5),
        srvvlr          dec(20,5), #=> PSI.187801
        pdgvlr          dec(20,5), #=> PSI.187801
        pecvlr          dec(20,5),
        fnlvlr          dec(20,5),
        prmvlr          dec(20,5),
        relacoes        integer,
        servicos        integer
 end    record


 define lr_cty10g00 record
        resultado   smallint
       ,mensagem    char(60)
       ,endufd      like gabksuc.endufd
       ,endcid      like gabksuc.endcid
       ,endbrr      like gabksuc.endbrr
       ,endlgd      like gabksuc.endlgd
       ,endnum      like gabksuc.endnum
       ,endcmp      like gabksuc.endcmp
       ,endcep      like gabksuc.endcep
       ,endcepcmp   like gabksuc.endcepcmp
       ,cgccpfnum   like gabksuc.cgccpfnum
       ,cgcord      like gabksuc.cgcord
       ,cgccpfdig   like gabksuc.cgccpfdig
       ,muninsnum   like gabksuc.muninsnum
 end record

#PSI197858 - inicio
 define l_desconto record
     dsctipdes    like dbsktipdsc.dsctipdes,
     dscvlr        like dbsropgdsc.dscvlr
 end record

 define l_obs like dbsmopgobs.socopgobs #Observacoes da OP

 define tamanho smallint

#PSI197858 - fim

   define lr_saida_801 record
  	      coderr       smallint
  	     ,msgerr       char(050)
  	     ,ppssucnum    like cglktrbetb.ppssucnum
  	     ,etbnom       like cglktrbetb.etbnom
  	     ,etbcpjnum    like cglktrbetb.etbcpjnum
  	     ,etblgddes    like cglktrbetb.etblgddes
  	     ,etblgdnum    like cglktrbetb.etblgdnum
  	     ,etbcpldes    like cglktrbetb.etbcpldes
  	     ,etbbrrnom    like cglktrbetb.etbbrrnom
  	     ,etbcepnum    like cglktrbetb.etbcepnum
  	     ,etbcidnom    like cglktrbetb.etbcidnom
  	     ,etbufdsgl    like cglktrbetb.etbufdsgl
  	     ,etbiesnum    like cglktrbetb.etbiesnum
  	     ,etbmuninsnum like cglktrbetb.etbmuninsnum
   end record

   define lr_retorno   record
          resultado    smallint,
          mensagem     char(100),
          cidcod       like glakcid.cidcod
   end record



 define l_tmp           smallint,
        l_psocopgnum    like dbsmopg.socopgnum,
        l_local         char(100),
        l_url           char(500),
        l_atdsrvnum_ant like datmservico.atdsrvnum,
        l_atdsrvano_ant like datmservico.atdsrvano,
        l_atdsrvorg_ant like datmservico.atdsrvorg,
        l_patdsrvorg    like datmservico.atdsrvorg,
        l_srvtipabvdes  like datksrvtip.srvtipabvdes,
        l_origens       char(1000),
        l_psituacao     char(20),
        l_pdataent      date,
        l_pdatapgt      date,
        l_pdatanfs      date,
        l_pqtdserv      integer,
        l_pvlrtot       dec(20,5),
        l_sql           char(1000),
        l_socopgitmcst  like dbsmopgcst.socopgitmcst,
        l_soccstcod     like dbsmopgcst.soccstcod, #=> PSI.187801
        l_crnpgtcod     like dpaksocor.crnpgtcod,  #-------------
        l_pcpatvcod     like dpaksocor.pcpatvcod,
        l_pstsuccod     like dpaksocor.succod,
        l_soctip        like dbsmopg.soctip,  # PSI.228032 |
        l_empcod        like dbsmopg.empcod,
        l_qldgracod     like dpaksocor.qldgracod,   #-------------
        l_estinsnum     like gabkemp.estinsnum  ,
        l_res           smallint,
        l_status        smallint,
        l_pestip        like dpaksocor.pestip,      # ini PSI-11-19199
        l_socopgsitcod  like dbsmopg.socopgsitcod,
        l_infissalqvlr  like dbsmopg.infissalqvlr,
        l_newissalqvlr  dec(10,2),
        l_simoptpstflg  like dpaksocor.simoptpstflg,
        l_opgempcod     like dbsmopg.empcod,
        l_codres        smallint,
        l_msgerr        char(100),
        l_historico     char(070),
        l_auxflg        char(001),
        l_marcarlid     smallint,
        l_dbsseqcod     like dbsmhstprs.dbsseqcod,
        l_origem        char(010),
        l_socopgobsseq  like dbsmopgobs.socopgobsseq  # fim PSI-11-19199

 define l_aux_cnpjcpf   char(20)   #Fornax-Quantum
 define l_corpoemail    char(1000) #Fornax-Quantum
 define l_assunto       char(100)  #Fornax-Quantum
 define l_erro          smallint   #Fornax-Quantum
 define l_texto_html char(32000)   #Fornax-Quantum


 define lr_ret record
         stt    integer
        ,msg    char(100)
 end record



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

    initialize    l_obs  to  null
    initialize    l_tmp  to  null
    initialize    l_psocopgnum  to  null
    initialize    l_local  to  null
    initialize    l_url  to  null
    initialize    l_atdsrvnum_ant  to  null
    initialize    l_atdsrvano_ant  to  null
    initialize    l_atdsrvorg_ant  to  null
    initialize    l_patdsrvorg  to  null
    initialize    l_srvtipabvdes  to  null
    initialize    l_origens  to  null
    initialize    l_psituacao  to  null
    initialize    l_pdataent  to  null
    initialize    l_pdatapgt  to  null
    initialize    l_pdatanfs  to  null
    initialize    l_pqtdserv  to  null
    initialize    l_pvlrtot  to  null
    initialize    l_sql  to  null
    initialize    l_socopgitmcst  to  null
    initialize    l_soccstcod  to  null
    initialize    l_pestip       to  null
    initialize    l_socopgsitcod to null
    initialize    l_infissalqvlr to null
    initialize    l_newissalqvlr to null
    initialize    l_simoptpstflg to null
    initialize    l_opgempcod    to null
    initialize    l_codres       to null
    initialize    l_msgerr       to null
    initialize    l_historico    to null
    initialize    l_auxflg       to null
    initialize    l_marcarlid    to null
    initialize    l_dbsseqcod    to null
    initialize    l_origem       to null
    initialize    l_socopgobsseq to null

    initialize l_aux_cnpjcpf   to null
    initialize l_corpoemail    to null
    initialize l_assunto       to null
    initialize l_erro          to null
    initialize l_texto_html to null

    let    l_atdsrvnum_ant  =  0
    let    l_atdsrvano_ant  =  0
    let    l_atdsrvorg_ant  =  0

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

    initialize  param.*  to  null
    initialize  lr_par_in.*  to  null
    initialize  ws.*  to  null
    initialize  l_servicos.*  to  null
    initialize  l_impressao.*  to  null
    initialize  l_totais.*  to  null
    initialize  l_desconto.*  to  null
    initialize lr_cty10g00.* to null
    initialize lr_saida_801.* to null         #Raul BIZ
    initialize lr_retorno.* to null           #Raul BIZ
    initialize lr_ret.* to null           #Raul BIZ

 initialize param.*      to null
 initialize ws.*         to null
 initialize l_servicos.* to null
 initialize l_impressao.* to null
 initialize l_totais.* to null
 initialize l_desconto.* to null
 initialize l_obs to null
 initialize l_res, l_status to null

 let param.usrtip    = arg_val(1)
 let param.webusrcod = arg_val(2)
 let param.sesnum    = arg_val(3)
 let param.macsissgl = arg_val(4)
 let l_psocopgnum    = arg_val(5)
 let l_origem        = arg_val(6)
 let l_psituacao     = arg_val(7)
 let l_pdataent      = arg_val(8)
 let l_pdatapgt      = arg_val(9)
 let l_pdatanfs      = arg_val(10)
 let l_pqtdserv      = arg_val(11)
 let l_pvlrtot       = arg_val(12)
 let lr_par_in.etapa     = arg_val(13)
 let lr_par_in.optante   = arg_val(14)
 let lr_par_in.aliquota  = arg_val(15)

 if l_origem is not null    and
    l_origem <> "undefined" then
    let l_patdsrvorg = l_origem
 else
    let l_patdsrvorg = 0
 end if

 --[Prepara sql loop]--

 let l_sql = " select srvtipabvdes   ",
             "   from datksrvtip     ",
             "  where atdsrvorg =  ? "
 prepare pwdatc040001 from l_sql
 declare cwdatc040002 cursor for pwdatc040001

 let l_sql = " select sum(e.incvlr),                           ",
             "        sum((f.socadccstqtd * f.socadccstvlr)),  ",
             "        sum(e.fnlvlr)                            ",
             "   from dbsmsrvacr e, dbsmsrvcst f               ",
             "  where e.atdsrvnum = ?                          ",
             "    and e.atdsrvano = ?                          ",
             "    and e.atdsrvnum = f.atdsrvnum                ",
             "    and e.atdsrvano = f.atdsrvano                "
 prepare pwdatc040002 from l_sql
 declare cwdatc040003 cursor for pwdatc040002

 # OSF 20370
 let l_sql = null
 let l_sql = " select atdvclsgl     "
            ,"   from datkveiculo   "
            ,"  where socvclcod = ? "

 prepare pwdatc040003 from l_sql
 declare cwdatc040004 cursor for pwdatc040003

 let l_sql = " select socopgitmcst, soccstcod ", #=> PSI.187801
             "   from dbsmopgcst        ",
             "  where socopgnum    = ?  ",
             "    and socopgitmnum = ?  "
 prepare pwdatc040004 from l_sql
 declare cwdatc040005 cursor for pwdatc040004

 let l_sql = " select srrabvnom ",
               " from datksrr ",
              " where srrcoddig = ? "

 prepare pwdatc040005 from l_sql
 declare cwdatc040006 cursor for pwdatc040005

#PSI197858 - inicio
 let l_sql = " select tip.dsctipdes, dsc.dscvlr ",
          " from dbsktipdsc tip, dbsropgdsc dsc ",
          " where tip.dsctipcod = dsc.dsctipcod ",
          " and dsc.socopgnum = ? "
 prepare pwdatc040006 from l_sql
 declare cwdatc040007 cursor for pwdatc040006

 let l_sql = " select socopgobs,socopgobsseq "
            ,"   from dbsmopgobs where socopgnum = ? "
            ,"  order by socopgobsseq "
 prepare pwdatc040007 from l_sql
 declare cwdatc040008 cursor for pwdatc040007

 #---> Nome Empresa
 let l_sql = " select empnom     ",
             "   from gabkemp    ",
             "  where empcod = ? "
 prepare pwdatc040008 from l_sql
 declare cwdatc040009 cursor for pwdatc040008

let l_sql = " select endufd,                ",
            "        endcid,                ",
            "        endbrr,                ",
            "        endlgd,                ",
            "        endnum,                ",
            "        endcmp,                ",
            "        endcep,                ",
            "        endcepcmp,             ",
            "        cgccpfnum,             ",
            "        cgcord,                ",
            "        cgccpfdig,             ",
            "        muninsnum,             ",
            "        estinsnum              ",
            " from gabksuc                  ",
            " where succod = ?              "
 prepare p_suc_sel from l_sql
 declare c_suc_sel cursor with hold for p_suc_sel

 let l_sql = " select endufd,                ",
             "        endcid,                ",
             "        endbrr,                ",
             "        endlgd,                ",
             "        endnum,                ",
             "        endcmp,                ",
             "        endcep,                ",
             "        endcepcmp,             ",
             "        cgccpfnum,             ",
             "        cgcord,                ",
             "        cgccpfdig              ",
             " from gabkfilial               ",
             " where empcod = ?              ",
             "   and filcod = ?              "
  prepare p_filial_sel from l_sql
  declare c_filial_sel cursor with hold for p_filial_sel

  let l_sql = " select endufd,                ",
              "        endcid,                ",
              "        endbrr,                ",
              "        endlgd,                ",
              "        endnum,                ",
              "        endcmp,                ",
              "        endcep,                ",
              "        endcepcmp,             ",
              "        cgccpfnum,             ",
              "        cgcord,                ",
              "        cgccpfdig,             ",
              "        estinsnum              ",
              " from gabkemp                  ",
              " where empcod = ?              "
   prepare p_emp_sel from l_sql
   declare c_emp_sel cursor with hold for p_emp_sel

  let l_sql = "select endcid, ufdsgl ",
               " from dpakpstend ",
              " where pstcoddig = ? ",
                " and endtipcod = 2 "
   prepare p_endfsc from l_sql
   declare c_endfsc cursor with hold for p_endfsc


#PSI197858 - fim

 -- [ Fim prepara ]--

 call wdatc002(param.*)
      returning ws.*

 if ws.statusprc then
      display "ERRO@@Por questões de segurança seu tempo de<BR> ",
              "permanência nesta página atingiu seu limite máximo.@@LOGIN"
      exit program(0)
 end if

#PSI197858 - inicio

display "PADRAO@@6@@1@@B@@C@@0@@2@@100%@@Valores de Desconto@@@@"

display "PADRAO@@6@@2@@N@@C@@0@@1@@50%@@Tipo Desconto@@@@",
                       "N@@C@@0@@1@@50%@@Valor Desconto@@@@"

open cwdatc040007 using l_psocopgnum
foreach cwdatc040007 into l_desconto.dsctipdes, l_desconto.dscvlr
    display "PADRAO@@6@@2@@",
               "N@@C@@1@@1@@50%@@", l_desconto.dsctipdes clipped, "@@@@",
                           "N@@C@@1@@1@@50%@@", l_desconto.dscvlr using "<<<<<<<<<<<<<<<<<<<&.&&","@@@@"
end foreach
close cwdatc040007

display "PADRAO@@6@@1@@B@@C@@0@@2@@100%@@Observações@@@@"
open cwdatc040008 using l_psocopgnum
foreach cwdatc040008 into l_obs
                        , l_socopgobsseq
    display "PADRAO@@6@@1@@",
               "N@@L@@1@@1@@100%@@", l_obs clipped, "@@@@"
end foreach
close cwdatc040008

 display "PADRAO@@6@@1@@B@@C@@0@@2@@100%@@Informações Detalhadas@@@@"

 display "PADRAO@@6@@8@@N@@C@@0@@1@@40@@Origem@@@@",
                       "N@@C@@0@@1@@70@@Nr. Serviço@@@@",
                       "N@@C@@0@@1@@65@@Data@@@@",
                       "N@@C@@0@@1@@60@@Hora@@@@",
                       "N@@C@@0@@1@@78@@Socorrista@@@@",
                       "N@@C@@0@@1@@78@@Viatura@@@@",
                       "N@@C@@0@@1@@78@@Local@@@@",
                       "N@@C@@0@@1@@78@@Valor total@@@@"
#PSI197858 - fim

 declare cwdatc040001 cursor for
  select b.atdsrvorg,
         a.atdsrvnum,
         a.atdsrvano,
         b.atddat,
         b.atdhor,
         b.srrcoddig,
         b.atdvclsgl,
         b.socvclcod, #OSF 20370
         c.cidnom,
         c.lclbrrnom,
         a.socopgitmvlr,
         a.socopgitmnum,
         b.ciaempcod
    from dbsmopgitm a, datmservico b, datmlcl c
   where a.socopgnum = l_psocopgnum
     and a.atdsrvnum = b.atdsrvnum
     and a.atdsrvano = b.atdsrvano
     and b.atdsrvnum = c.atdsrvnum
     and b.atdsrvano = c.atdsrvano
     and c.c24endtip = 1
  order by b.atdsrvorg, a.atdsrvnum, a.atdsrvano, a.socopgitmnum

 -- [ Dados para impressao ]--

 select a.pstcoddig,
        b.cgccpfnum,
        b.cgcord,
        b.cgccpfdig,
        b.nomrazsoc,
        b.qldgracod,
        b.crnpgtcod,
        a.soctip,
        a.socfatentdat,
        b.pestip,
        b.simoptpstflg,
        a.empcod,
        a.infissalqvlr,
        a.socopgsitcod
   into l_impressao.pstcoddig,
        l_impressao.cgccpfnum,
        l_impressao.cgcord,
        l_impressao.cgccpfdig,
        l_impressao.nomrazsoc,
        l_qldgracod,
        l_crnpgtcod,
        l_soctip,
        l_impressao.socfatentdat,
        l_pestip,                              # ini PSI-11-19199
        l_simoptpstflg,
        l_opgempcod,
        l_infissalqvlr,
        l_socopgsitcod                         # fim PSI-11-19199
   from dbsmopg a, dpaksocor b
  where a.socopgnum = l_psocopgnum
    and a.pstcoddig = b.pstcoddig

  if l_simoptpstflg is null or
     l_simoptpstflg <> "S"  then
     let l_simoptpstflg = "N"
  end if

  select crnpgtdes
      into l_impressao.crnpgtdes
   from dbsmcrnpgt
   where crnpgtcod = l_crnpgtcod

  select cpodes
      into l_impressao.qldgrades
   from iddkdominio
   where cponom = "qldgracod"
   and      cpocod = l_qldgracod

  if l_impressao.qldgrades <> "PADRAO PORTO" then
     let l_impressao.qldgrades = "NAO PADRAO PORTO"
  end if

  if l_soctip = 1 then
      let l_impressao.tipOP = l_soctip, " - AUTO"
  else if l_soctip = 2 then
      let l_impressao.tipOP = l_soctip, " - CARRO EXTRA"
  else if l_soctip = 3 then
      let l_impressao.tipOP = l_soctip, " - RE"
  else
      let l_impressao.tipOP = l_soctip, " - Indefinido"
  end if
  end if
  end if

 -- [ Recupera origem do servico] --
 open cwdatc040002 using l_patdsrvorg
 fetch cwdatc040002 into l_srvtipabvdes
 close cwdatc040002


#let l_impressao.cgccpfnum = "382934818"
 -- [Impressao ] --

 display "PADRAO@@10@@1@@23@@1@@",
             "B@@C@@M@@4@@3@@2@@100%@@Relação de serviços@@@@"

 display "PADRAO@@10@@2@@23@@0@@",
             "N@@L@@M@@4@@3@@1@@30%@@Código do prestador@@@@",
             "N@@L@@M@@4@@3@@1@@70%@@",
                             l_impressao.pstcoddig using "<<<<<<<&", "@@@@"
 display "PADRAO@@10@@2@@23@@0@@",
             "N@@L@@M@@4@@3@@1@@30%@@CGC/CPF@@@@",
             "N@@L@@M@@4@@3@@1@@70%@@", l_impressao.cgccpfnum using "<<<<<<<<<<<<<<<&",
                                        "/",
                                        l_impressao.cgcord using "&&&&",
                                        "-",
                                        l_impressao.cgccpfdig using "&&","@@@@"
 display "PADRAO@@10@@2@@23@@0@@",
             "N@@L@@M@@4@@3@@1@@30%@@Razão social@@@@",
             "N@@L@@M@@4@@3@@1@@70%@@", l_impressao.nomrazsoc clipped, "@@@@"
 display "PADRAO@@10@@2@@23@@0@@",
             "N@@L@@M@@4@@3@@1@@30%@@Número da OP@@@@",
             "N@@L@@M@@4@@3@@1@@70%@@", l_psocopgnum using "<<<<<<<<<&", "@@@@"
 display "PADRAO@@10@@2@@23@@0@@",
             "N@@L@@M@@4@@3@@1@@30%@@Origem dos serviços@@@@",
             "N@@L@@M@@4@@3@@1@@70%@@",
                        l_patdsrvorg using "<<<<<<<<<&&"
                       ," - ", l_srvtipabvdes,"@@@@"

#=> PSI.187801
 display "PADRAO@@10@@11@@46@@1@@",
         "B@@C@@M@@4@@3@@1@@39@@Item@@@@",
         "B@@C@@M@@4@@3@@1@@67@@Nr. Serviço@@@@",
         "B@@C@@M@@4@@3@@1@@39@@Ano@@@@",
         "B@@C@@M@@4@@3@@1@@66@@Valor Porto@@@@",
         "B@@C@@M@@4@@3@@1@@67@@Valores adicionais@@@@",
         "B@@C@@M@@4@@3@@1@@67@@Valor do Serviço@@@@",
         "B@@C@@M@@4@@3@@1@@67@@Valor Pedágio@@@@",
         "B@@C@@M@@4@@3@@1@@67@@Valor Peças@@@@",
         "B@@C@@M@@4@@3@@1@@67@@Mes Servico@@@@",
         "B@@C@@M@@4@@3@@1@@67@@Premio@@@@",
         "B@@C@@M@@4@@3@@1@@67@@Valor total@@@@"

 --[ Fim impressao ]--


 let l_tmp = false
 let l_atdsrvnum_ant = 0
 let l_atdsrvano_ant = 0

 let l_totais.incvlr = 0
 let l_totais.totvlr = 0
 let l_totais.srvvlr = 0
 let l_totais.pdgvlr = 0
 let l_totais.pecvlr = 0
 let l_totais.fnlvlr = 0
 let l_totais.prmvlr = 0

 let l_totais.relacoes = 0
 let l_totais.servicos = 0

 foreach cwdatc040001 into  l_servicos.atdsrvorg,
                            l_servicos.atdsrvnum,
                            l_servicos.atdsrvano,
                            l_servicos.atddat,
                            l_servicos.atdhor,
                            l_servicos.srrcoddig,
                            l_servicos.atdvclsgl,
                            l_servicos.socvclcod,
                            l_servicos.cidnom,
                            l_servicos.lclbrrnom,
                            l_servicos.socopgitmvlr,
                            l_impressao.socopgitmnum,
                            l_servicos.ciaempcod

   # ---> BUSCA srrabvnom
   open cwdatc040006 using l_servicos.srrcoddig
   fetch cwdatc040006 into l_servicos.srrabvnom
   close cwdatc040006

   let l_tmp = true

   let l_local = l_servicos.cidnom clipped, "-",
                 l_servicos.lclbrrnom clipped
   let l_local = l_local[1,10]

   let l_url = "wdatc041.pl?usrtip=", param.usrtip clipped,
               "&webusrcod=", param.webusrcod clipped,
               "&sesnum=", param.sesnum using "<<<<<<<<&",
               "&macsissgl=", param.macsissgl clipped,
             # "&numserv=", l_servicos.atdsrvnum using "<<<<<<<<&", "-",
             #              l_servicos.atdsrvano using "&&" ,
               "&atdsrvnum=", l_servicos.atdsrvnum using "<<<<<<<<&",
               "&atdsrvano=", l_servicos.atdsrvano using "&&",
               "&acao=1",
               "&numop=", l_psocopgnum using "<<<<<<<<&",
               "&situacao=", l_psituacao clipped,
               "&dataent=", l_pdataent,
               "&datapgt=", l_pdatapgt,
               "&datanfs=", l_pdatanfs,
               "&qtdserv=", l_pqtdserv,
               "&vlrtot=", l_pvlrtot using "<<<<<<<<<<<<<<<<<&.&&"

   if l_servicos.atdsrvnum <> l_atdsrvnum_ant or
      l_servicos.atdsrvano <> l_atdsrvano_ant then

      let l_totais.servicos =
                 l_totais.servicos + 1

      # OSF 20370
      if l_servicos.atdvclsgl is null or
         l_servicos.atdvclsgl = " "   then

         open cwdatc040004 using l_servicos.socvclcod
         fetch cwdatc040004 into l_servicos.atdvclsgl
         close cwdatc040004

      end if

      #-- HPN --INI--

#=>   PSI.187801
      if l_servicos.socopgitmvlr is not null then
         let l_impressao.incvlr = l_servicos.socopgitmvlr # Valor Porto
      else
         let l_impressao.incvlr = 0
      end if
      let l_impressao.totvlr = 0 # Valores adicionais
      let l_impressao.pdgvlr = 0 # Valor Pedagio
      let l_impressao.pecvlr = 0 # Valor Peças
      let l_impressao.prmvlr = 0 # Valor Bonificacao

      open cwdatc040005 using l_psocopgnum,
                              l_impressao.socopgitmnum
      foreach cwdatc040005 into l_socopgitmcst,
                                l_soccstcod
         if l_socopgitmcst is not null then
            if l_soccstcod = 12 or
               l_soccstcod = 18 then
               let l_impressao.pdgvlr = l_impressao.pdgvlr + l_socopgitmcst
            else
                if l_soccstcod = 10 then
                    let l_impressao.pecvlr = l_impressao.pecvlr + l_socopgitmcst
                else
                   if l_soccstcod = 23 or l_soccstcod = 24 then
                      let l_impressao.prmvlr = l_impressao.prmvlr + l_socopgitmcst
                   else
                       let l_impressao.totvlr = l_impressao.totvlr + l_socopgitmcst
                   end if
                end if
            end if
         end if
      end foreach

      let l_impressao.srvvlr = l_impressao.incvlr + #=> Valor do Servico
                               l_impressao.totvlr

      let l_impressao.fnlvlr = l_impressao.srvvlr + # Valor total
                               l_impressao.pdgvlr +
                               l_impressao.pecvlr +
                               l_impressao.prmvlr


      let l_servicos.socopgitmvlr = l_impressao.fnlvlr

      #-- HPN --FIM--

      display "PADRAO@@6@@8@@N@@C@@1@@1@@40@@",
                           l_servicos.atdsrvorg using "<<<<<<<&&", "@@@@",
                           "N@@C@@1@@1@@70@@",
                           l_servicos.atdsrvnum using "<<<<<<<<&", "/",
                           l_servicos.atdsrvano using "&&", "@@",
                           l_url clipped, "@@",
                           "N@@C@@1@@1@@65@@",
                           l_servicos.atddat using "dd/mm/yyyy", "@@@@",
                           "N@@C@@1@@1@@60@@",
                           l_servicos.atdhor, "@@@@",
                           "N@@C@@1@@1@@78@@",
                           l_servicos.srrcoddig using "<<<<<<<<<&", "-",
                           l_servicos.srrabvnom clipped, "@@@@",
                           "N@@C@@1@@1@@78@@",
                           l_servicos.atdvclsgl clipped, "@@@@",
                           "N@@C@@1@@1@@78@@",
                           l_local,   "@@@@",
                           "N@@C@@1@@1@@78@@",
                           l_servicos.socopgitmvlr using "<<<<<<<<<<&.&&","@@@@"
   end if

   if l_servicos.atdsrvorg <> l_atdsrvorg_ant then

      let l_totais.relacoes =  l_totais.relacoes + 1

      let l_srvtipabvdes = null
      open cwdatc040002 using l_servicos.atdsrvorg
      fetch cwdatc040002 into l_srvtipabvdes
      close cwdatc040002

      let l_origens = l_origens clipped,
                      "@@", l_servicos.atdsrvorg using "<<<<<<<<&&", "-",
                            l_srvtipabvdes clipped,
                      "@@0",
                      "@@", l_servicos.atdsrvorg using "<<<<<<<<<&"
   end if

   if l_patdsrvorg = l_servicos.atdsrvorg then

{
      let l_impressao.incvlr = 0
      let l_impressao.totvlr = 0
      let l_impressao.fnlvlr = 0

      open cwdatc040003 using l_servicos.atdsrvnum,
                              l_servicos.atdsrvano
      fetch cwdatc040003 into l_impressao.incvlr,
                              l_impressao.totvlr,
                              l_impressao.fnlvlr
      close cwdatc040003
}

#=>   PSI.187801
      let l_totais.incvlr = l_totais.incvlr + l_impressao.incvlr
      let l_totais.totvlr = l_totais.totvlr + l_impressao.totvlr
      let l_totais.srvvlr = l_totais.srvvlr + l_impressao.srvvlr
      let l_totais.pdgvlr = l_totais.pdgvlr + l_impressao.pdgvlr
      let l_totais.pecvlr = l_totais.pecvlr + l_impressao.pecvlr
      let l_totais.fnlvlr = l_totais.fnlvlr + l_impressao.fnlvlr
      let l_totais.prmvlr = l_totais.prmvlr + l_impressao.prmvlr

      display
      "PADRAO@@10@@11@@23@@0@@",
      "N@@C@@M@@4@@3@@1@@39@@",l_impressao.socopgitmnum using "<<<<&&&&","@@@@",
      "N@@C@@M@@4@@3@@1@@67@@",l_servicos.atdsrvnum using "<<<<<<<<<<","@@@@",
      "N@@C@@M@@4@@3@@1@@39@@",l_servicos.atdsrvano using "<<<<<<<<&&","@@@@",
      "N@@C@@M@@4@@3@@1@@66@@",l_impressao.incvlr using "<<<<<<<<<&.&&","@@@@",
      "N@@C@@M@@4@@3@@1@@67@@",l_impressao.totvlr using "<<<<<<<<<&.&&","@@@@",
      "N@@C@@M@@4@@3@@1@@67@@",l_impressao.srvvlr using "<<<<<<<<<&.&&","@@@@",
      "N@@C@@M@@4@@3@@1@@67@@",l_impressao.pdgvlr using "<<<<<<<<<&.&&","@@@@",
      "N@@C@@M@@4@@3@@1@@70@@",l_impressao.pecvlr using "<<<<<<<<<&.&&","@@@@",
      "N@@C@@M@@4@@3@@1@@67@@",l_servicos.atddat  using "mm/yyyy","@@@@",
      "N@@C@@M@@4@@3@@1@@67@@",l_impressao.prmvlr using "<<<<<<<<<&.&&","@@@@",
      "N@@C@@M@@4@@3@@1@@67@@",l_impressao.fnlvlr using "<<<<<<<<<&.&&","@@@@"


   end if

   let l_atdsrvnum_ant = l_servicos.atdsrvnum
   let l_atdsrvano_ant = l_servicos.atdsrvano
   let l_atdsrvorg_ant = l_servicos.atdsrvorg
 end foreach

 let l_empcod = l_servicos.ciaempcod

 #---> Nome da empresa
  open cwdatc040009 using l_empcod
  fetch cwdatc040009 into l_impressao.nomrazemp
  close cwdatc040009

 #PSI 208264 - Display para informar qual logo deve ser utilizado
 display "PADRAO@@12@@", l_servicos.ciaempcod, "@@"

 if not l_tmp then
    display "ERRO@@Não foram encontrados registros em nosso banco de dados.@@BACK"
 else
    display "PADRAO@@6@@1@@B@@C@@0@@2@@100%@@Seleção de origem para impressão@@@@"
    display "PADRAO@@2@@origem@@Selecione uma origem@@0@@@@@@0@@0",
                                     l_origens clipped

    display "PADRAO@@10@@9@@23@@1@@",
            "B@@R@@M@@4@@3@@1@@146@@Totais@@@@",
            "B@@C@@M@@4@@3@@1@@66@@", l_totais.incvlr using "<<<<<<<<<<<<<&.&&", "@@@@",
            "B@@C@@M@@4@@3@@1@@67@@", l_totais.totvlr using "<<<<<<<<<<<<<&.&&", "@@@@",
            "B@@C@@M@@4@@3@@1@@67@@", l_totais.srvvlr using "<<<<<<<<<<<<<&.&&", "@@@@",
            "B@@C@@M@@4@@3@@1@@67@@", l_totais.pdgvlr using "<<<<<<<<<<<<<&.&&", "@@@@",
            "B@@C@@M@@4@@3@@1@@67@@", l_totais.pecvlr using "<<<<<<<<<<<<<&.&&", "@@@@",
            "B@@C@@M@@4@@3@@1@@67@@  N/A   @@@@",
            "B@@C@@M@@4@@3@@1@@67@@", l_totais.prmvlr using "<<<<<<<<<<<<<&.&&", "@@@@",
            "B@@C@@M@@4@@3@@1@@67@@", l_totais.fnlvlr using "<<<<<<<<<<<<<&.&&", "@@@@"


    select pcpatvcod, succod
      into l_pcpatvcod, l_pstsuccod
      from dpaksocor
     where pstcoddig = l_impressao.pstcoddig

    case l_pcpatvcod
        when 1
            let l_impressao.nomatvpri = 'Prestação de Serviços de Transporte de Veículos dentro do municipio'
        when 2
            let l_impressao.nomatvpri = 'Prestação de Serviços de Chaveiros dentro do municipio'
        when 3
            let l_impressao.nomatvpri = 'Prestação de Serviços de Transporte Por Taxi dentro do municipio'
        when 4
            let l_impressao.nomatvpri = 'Prestação de Serviços Funerais dentro do municipio'
        when 5
            let l_impressao.nomatvpri = 'Locação de veiculos dentro do municipio'
        when 6
            let l_impressao.nomatvpri = 'Prestação de Serviços de Transporte de Pessoas dentro do municipio'
        when 7
            let l_impressao.nomatvpri = 'Prestação de Serviços de Manutenção e instalação de equipamento de informática dentro do municipio'
        when 8
            let l_impressao.nomatvpri = 'Prestação de Serviços de Manutenção de Maquinas, Aparelhos, Equipamentos e Motores dentro do municipio'
        when 9
            let l_impressao.nomatvpri = 'Prestação de Serviços de Transporte Por Taxi dentro do municipio'
        when 11
            let l_impressao.nomatvpri = 'Prestação de Serviços de Limpeza, Manutenção e Conservação de Imóveis'
        when 12
            let l_impressao.nomatvpri = 'Prestação de Serviços de Despachantes dentro do municipio'
        when 13
            let l_impressao.nomatvpri = 'Prestação de Serviços de Agente organizador de hospedagens dentro do municipio'
        when 14
            let l_impressao.nomatvpri = 'Prestação de Serviços de Vigilancia, Segurança de bens e pessoas dentro do municipio'
        when 15
            let l_impressao.nomatvpri = 'Prestação de Serviços de Medicina Veterinária'
    end case


   open c_endfsc using l_impressao.pstcoddig
   fetch c_endfsc into lr_cty10g00.endcid, lr_cty10g00.endufd

   #Raul BIZ
   call cty10g00_obter_cidcod(lr_cty10g00.endcid, lr_cty10g00.endufd)
   returning lr_retorno.resultado,
             lr_retorno.mensagem,
             lr_retorno.cidcod

   if lr_retorno.resultado = 0 then

      #Fornax-Quantum - Inicio

     call ffpgc377_verificarIntegracaoAtivaEmpresaRamo("054PTSOC",today,l_empcod, 0)
              returning  lr_ret.stt
                        ,lr_ret.msg


      if lr_ret.stt = 0 then

         call fcgtc801(l_empcod, lr_retorno.cidcod)
         returning lr_saida_801.coderr
                  ,lr_saida_801.msgerr
                  ,lr_saida_801.ppssucnum
                  ,l_impressao.nomrazemp
                  ,l_impressao.cnpjsuc
                  ,lr_saida_801.etblgddes
                  ,lr_saida_801.etblgdnum
                  ,lr_saida_801.etbcpldes
                  ,lr_saida_801.etbbrrnom
                  ,lr_saida_801.etbcepnum
                  ,lr_saida_801.etbcidnom
                  ,lr_saida_801.etbufdsgl
                  ,l_impressao.inscemp
                  ,l_impressao.inscsuc
         if lr_saida_801.coderr <> 0 then
            display 'ERRO@@',lr_saida_801.msgerr clipped,'@@LOGIN'
            exit program(0)
         end if

         let l_impressao.endsuc    = lr_saida_801.etblgddes clipped, ', ', lr_saida_801.etblgdnum,
                                     ', CEP. ', lr_saida_801.etbcepnum clipped
         let l_impressao.brrsuc    = lr_saida_801.etbbrrnom clipped, ' - ', lr_saida_801.etbcidnom clipped
                                     , ' - ', lr_saida_801.etbufdsgl clipped
      else

          initialize gr_054_req_v1.*
                    ,gr_054_res_v1.*
                    ,gr_aci_req_head.* to null

          let gr_aci_req_head.id_integracao   = "054PTSOC" # ID do sistema de origem da requisicao.

          #Entrada
          let gr_054_req_v1.empresa          = l_empcod using "&&&"      #Empresa
          let gr_054_req_v1.cod_municipio    = lr_retorno.cidcod         #Codigo Municipio
          let gr_054_req_v1.sucursal         = l_pstsuccod               #Codigo Sucursal


          call ffpgc375_cons_filial()

          let l_impressao.endsuc    = gr_054_res_v1.end_centro clipped, #', ', lr_saida_801.etblgdnum,
                                      ', CEP:  ', gr_054_res_v1.cep_centro clipped
          let l_impressao.brrsuc    =  gr_054_res_v1.cid_centro clipped #lr_saida_801.etbbrrnom clipped, ' - ', lr_saida_801.etbcidnom clipped

          let l_impressao.nomrazemp = gr_054_res_v1.rzo_soc_centro clipped

          let l_impressao.cnpjsuc = gr_054_res_v1.cnpj_centro

          let l_impressao.inscsuc = gr_054_res_v1.ins_mun_centro

          let l_impressao.inscemp = gr_054_res_v1.ins_est_centro

      end if #Fornax-Quantum - fim
   else
   	  display 'ERRO@@',lr_retorno.mensagem clipped, '@@LOGIN'
      exit program(0)
   end if

    let tamanho = length(l_impressao.cnpjsuc)

    if tamanho = 15 then
       let l_impressao.cnpjsucformat = l_impressao.cnpjsuc[1,3] using '&&&', ".", l_impressao.cnpjsuc[4,6], ".",
                                       l_impressao.cnpjsuc[7,9],"/", l_impressao.cnpjsuc[10,13], "-",
                                       l_impressao.cnpjsuc[14,15] clipped
    else
       if tamanho = 14 then
          let l_impressao.cnpjsucformat = l_impressao.cnpjsuc[1,2] using '&&&', ".", l_impressao.cnpjsuc[3,5], ".",
                                          l_impressao.cnpjsuc[6,8],"/", l_impressao.cnpjsuc[9,12], "-",
                                          l_impressao.cnpjsuc[13,14] clipped
       else
          let l_impressao.cnpjsucformat = l_impressao.cnpjsuc[1,1] using '&&&', ".", l_impressao.cnpjsuc[2,4], ".",
                                          l_impressao.cnpjsuc[5,7],"/", l_impressao.cnpjsuc[8,11], "-",
                                          l_impressao.cnpjsuc[12,13] clipped
       end if
    end if
    display "PROTOCOLO@@", l_impressao.pstcoddig using "<<<<<<<<&", "@@",
                           l_impressao.cgccpfnum using "<<<<<<<<<<<<<<<&", "/",
                           l_impressao.cgcord using "&&&&", "-",
                           l_impressao.cgccpfdig using "&&","@@",
                           l_impressao.nomrazsoc clipped, "@@",
                           l_impressao.qldgrades clipped, "@@",
                           l_impressao.crnpgtdes clipped, "@@",
                           l_impressao.tipOP clipped, "@@",
                           l_totais.servicos using "<<<<<<<<<<&", "@@",
                           l_totais.relacoes using "<<<<<<<<<<&", "@@",
                           l_impressao.nomrazemp clipped, "@@",
                           "CNPJ - ",  l_impressao.cnpjsucformat clipped, "@@",
                           l_impressao.endsuc    clipped, "@@",
                           l_impressao.brrsuc    clipped, "@@",
                           "Inscrição Municipal - ", l_impressao.inscsuc   clipped, "@@",
                           "Inscrição Estadual - ", l_impressao.inscemp   clipped, "@@",
                           l_impressao.nomatvpri clipped, "@@",
                           l_impressao.socfatentdat
 end if

 #-- ini PSI-2011-19199-PR - atualizar flag Optante e aliquota ISS
 call wdatc040_indicarParamOptante( l_psocopgnum     # PSI-11-19199
                                  , l_impressao.pstcoddig
                                  , l_pestip
                                  , l_opgempcod
                                  , l_socopgsitcod
                                  , l_infissalqvlr
                                  , l_simoptpstflg )
      returning l_marcarlid

 if lr_par_in.etapa is not null and
    lr_par_in.etapa  = "3"      then

    begin work

    if lr_par_in.optante is null  or
       lr_par_in.optante <> "Sim" then
       let l_auxflg = "N"
    else
       let l_auxflg = "S"
    end if

    if l_auxflg <> l_simoptpstflg or
       l_marcarlid = true         then

       call ctc00m24_alterarOptantePrest( l_impressao.pstcoddig
                                        , l_auxflg               # simoptpstflg
                                        , "01"                   # empcod
                                        , "F"                    # usrtip
                                        , "999999"             ) # funmat
            returning l_codres
                    , l_msgerr

       if l_msgerr is not null then
          rollback work
          display "ERRO@@Não foi possível gravar o campo de Optante Simples@@LOGIN"
          exit program(0)
       end if

       if l_auxflg <> l_simoptpstflg then
          let l_historico = "Alteração Optante Simples"
                           ," de "  , l_simoptpstflg
                           ," para ", l_auxflg

          #Fornax-Quantum - criar envio de e-mail - inicio
             let l_aux_cnpjcpf = l_impressao.cgccpfnum using '&&&&&&&&&'

             if l_pestip = "J" then
                let l_aux_cnpjcpf =       l_aux_cnpjcpf[1,3]
                                     ,'.',l_aux_cnpjcpf[4,6]
                                     ,'.',l_aux_cnpjcpf[7,9]
                                     ,'/',l_impressao.cgcord using '&&&&'
                                     ,'-',l_impressao.cgccpfdig using '&&'
             else
                let l_aux_cnpjcpf =      l_aux_cnpjcpf[1,3]
                                    ,'.',l_aux_cnpjcpf[4,6]
                                    ,'.',l_aux_cnpjcpf[7,9]
                                    ,'-',l_impressao.cgccpfdig using '&&'
             end if

             let l_assunto = 'Divergencia no cadastro do optante simples'

              if l_auxflg = "N" then
                 let l_corpoemail = "Prezado, <br/><br/> O prestador <b>", l_impressao.pstcoddig clipped, "-",l_impressao.nomrazsoc clipped, "</b>, registrado com o <b>CPF/CNPJ:",l_aux_cnpjcpf clipped,
                                    "</b> alterou sua opcao de optante simples na OP da empresa ",l_empcod clipped, "-Porto Seguro.<br/><br/> ",
                                    "O Prestador alterou de Optante Simples: <b><font color=blue>SIM</font></b> para Optante Simples: <b><font color=red>NAO</font></b>. <br/><br/>",
                                    "<b><i>Favor conferir o cadastro deste prestador no SAP, para que nao tenhamos problema com o pagamento do imposto para este prestador.</i></b>"

              else
                  let l_corpoemail = "Prezado, <br/><br/> O prestador <b>", l_impressao.pstcoddig clipped, "-",l_impressao.nomrazsoc clipped, "</b>, registrado com o <b>CPF/CNPJ:",l_aux_cnpjcpf clipped,
                                    "</b> alterou sua opcao de optante simples na OP da empresa ",l_empcod clipped, "-Porto Seguro.<br/><br/> ",
                                    "O Prestador alterou de Optante Simples: <b><font color=red>NAO</font></b> para Optante Simples: <b><font color=blue>SIM</font></b>. <br/><br/>",
                                    "<b><i>Favor conferir o cadastro deste prestador no SAP, para que nao tenhamos problema com o pagamento do imposto para este prestador.</i></b>"

              end if

                let l_texto_html = "<html>",
                                       "<body>",
                                          "<br><font face=arial size=2>",l_corpoemail clipped,
                                           "<br><br>Porto Seguro Seguros<br>Porto Socorro"

                        let l_erro = ctx22g00_envia_email_html("WDATC040" ,
                                                               l_assunto,
                                                               l_texto_html clipped)
          #Fornax-Quantum - criar envio de e-mail - final
       else
          let l_historico = "Assinatura digital termo aceite de Optante Simples"
       end if

       call ctc00m24_logarHistoricoPrest( l_impressao.pstcoddig
                                        , l_historico
                                        , "01"                   # empcod
                                        , "F"                    # usrtip
                                        , "999999"               # funmat
                                        , "Per"                ) # funnom
            returning l_codres
                    , l_msgerr
                    , l_dbsseqcod

       if l_msgerr is not null then
          rollback work
          display "ERRO@@Não foi possível gravar observação no histórico do Prestador@@LOGIN"
          exit program(0)
       end if
    end if

    #--> Historico da aliquota da OP
    #
    if l_auxflg = "N" then
       let l_newissalqvlr = null
    else
       let l_newissalqvlr = lr_par_in.aliquota
       if l_newissalqvlr > 100 then
          let l_newissalqvlr = l_newissalqvlr / 100
       end if
    end if

    let l_historico = null

    if l_newissalqvlr is null     and
       l_infissalqvlr is not null then
       let l_historico = "Alteração aliquota ISS de ", l_infissalqvlr using "-<<<<<<<<&.&&", " para 0.00"
    else
       if l_infissalqvlr is null     and
          l_newissalqvlr is not null then
          let l_historico = "nao gravar"     # conf. Sergio Burini
       else
          if l_infissalqvlr <> l_newissalqvlr then
             let l_historico = "Alteração aliquota ISS de ", l_infissalqvlr using "-<<<<<<<<&.&&", " para ", l_newissalqvlr using "-<<<<<<<<&.&&"
          end if
       end if
    end if

    if l_historico is not null then

       #--> Atualizar a aliquota do ISS para a OP
       #
       call ctc00m24_alterarAliqIssOrdPg( l_psocopgnum
                                        , l_newissalqvlr
                                        , "01"                   # empcod
                                        , "F"                    # usrtip
                                        , "999999"             ) # funmat
            returning l_codres
                    , l_msgerr

       if l_msgerr is not null then
          rollback work
          display "ERRO@@Não foi possível atualizar a aliquota na Ordem de Pagamento@@LOGIN"
          exit program(0)
       end if

       #--> Logar Historico da OP
       #
       if l_historico <> "nao gravar" then  # conf. Sergio Burini
          call ctc00m24_logarHistoricoOrdPg( l_psocopgnum
                                           , l_historico
                                           , "01"                   # empcod
                                           , "F"                    # usrtip
                                           , "999999"               # funmat
                                           , "Per"                ) # funnom
               returning l_codres
                       , l_msgerr
                       , l_dbsseqcod

          if l_msgerr is not null then
             rollback work
             display "ERRO@@Não foi possível registrar o histórico com a nova aliquota de ISS para a Ordem de Pagamento@@LOGIN"
             exit program(0)
          end if
       end if
    end if

    commit work
 end if

 if wdatc003(param.*, ws.*) then
      display "ERRO@@Não foi possivel atualizar a sessão.@@LOGIN"
      exit program(0)
 end if

end function

#------------------------------------ PSI-11-19199
# Objetivo: Indicar Se Prestador e OP deve apresentar pagina Optante Simples
#------------------------------------
function wdatc040_indicarParamOptante( lr_par_in )      # PSI-11-19199

  define lr_par_in       record
         socopgnum       like dbsmopg.socopgnum
        ,pstcoddig       like dbsmopg.pstcoddig
        ,pestip          like dpaksocor.pestip
        ,empcod          like dbsmopg.empcod
        ,socopgsitcod    like dbsmopg.socopgsitcod
        ,infissalqvlr    like dbsmopg.infissalqvlr
        ,simoptpstflg    like dpaksocor.simoptpstflg
  end record

  define l_assinaflg     char(01),
         l_aceiteflg     char(01),
         l_saida         char(500),
         l_empflg        char(001),
         l_cponom        like iddkdominio.cponom,
         l_cpodes        like iddkdominio.cpodes,
         l_cpocod        like iddkdominio.cpocod,
         l_codres        smallint,
         l_msgerr        char(100),
         l_issalqaux     char(020),
         l_issqtd        integer,
         l_marcarlid     smallint

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let    l_assinaflg    = null
  let    l_aceiteflg    = null
  let    l_saida        = null
  let    l_empflg       = null
  let    l_cponom       = null
  let    l_cpodes       = null
  let    l_cpocod       = null
  let    l_codres       = null
  let    l_msgerr       = null
  let    l_issalqaux    = null
  let    l_issqtd       = null
  let    l_marcarlid    = null

  if lr_par_in.infissalqvlr is null or
     lr_par_in.infissalqvlr  = 0.0  then
     let l_issalqaux = "0.00"
  else
     let l_issalqaux = lr_par_in.infissalqvlr using "<<<<<<&.&&"
  end if

  let l_assinaflg = "N"
  let l_marcarlid = false

  #--> Verificar se OP do Prestador é Optante Simples
  #
  if lr_par_in.pestip = "J" then          # Juridica

     if lr_par_in.socopgsitcod <> 6 and   # 6 OK PARA EMISSAO
        lr_par_in.socopgsitcod <> 7 and   # 7 EMITIDA
        lr_par_in.socopgsitcod <> 8 then  # 8 CANCELADA

        #--> Verificar se Empresa OP pode optar Simples
        let l_cponom = "empsolopcissptl"
        call ctc00m24_obterDescIddkDominio( l_cponom
                                          , lr_par_in.empcod )
             returning l_codres, l_msgerr, l_cpodes

        if l_codres = 0 then
           let l_empflg = "S"
        else
           if l_codres = 2 then
              let l_empflg = "N"
           else
              let l_saida = "Não foi possível verificar se a Empresa permite optar pelo Simples"
              display "ERRO@@", l_saida clipped, "@@LOGIN"
              let l_saida = l_saida clipped, " OP ", lr_par_in.socopgnum, " Empresa ", lr_par_in.empcod
              exit program(0)
           end if
        end if

        if l_empflg = "S" then
           let l_assinaflg = "S"
        end if
     end if
  end if

  #--> Verificar se marcou lido no Termo de Aceite Optante
  #
  let l_aceiteflg = "N"

  if l_assinaflg = "S" then
     call ctc00m24_leuTermoOptante( lr_par_in.pstcoddig )
          returning l_codres
                  , l_msgerr

     if l_msgerr is not null then
        display "ERRO@@", l_msgerr clipped, "@@LOGIN"
        exit program(0)
     end if

     if l_codres = 0 then
        let l_aceiteflg = "S"
     else
        let l_marcarlid = true
     end if
  end if

  let l_saida = "PERSON@@1"
              , "@@", l_assinaflg clipped
              , "@@", l_aceiteflg    clipped
              , "@@", lr_par_in.simoptpstflg clipped
              , "@@", l_issalqaux clipped
              , "@@"

  display l_saida clipped

  #--> Obter lista de Percentuais ISS
  #
  if l_assinaflg = "S" then
     let l_cponom = "psoaliquotasiss"
     let l_codres = 0                          # First
     let l_msgerr = null
     let l_issqtd = 0

     let l_saida = "PERSON@@2"
                 , "@@Alíquotas"
                 , "@@0"
                 , "@@"
     display l_saida clipped

     while l_codres <> 2
        call ctc00m24_obterListaDominio( l_cponom, l_codres )
             returning l_codres
                     , l_msgerr
                     , l_cpodes
                     , l_cpocod
        if l_codres = 0 then
           let l_saida = "PERSON@@2"
                       , "@@", l_cpodes clipped
                       , "@@", l_cpodes clipped
                       , "@@"
           display l_saida clipped
           let l_issqtd = l_issqtd + 1
           let l_codres = 1                 # Next
        else
           if l_msgerr is not null then
              exit while
           end if
        end if
     end while

     if l_msgerr is not null then
        display "ERRO@@", l_msgerr clipped, "@@LOGIN"
        exit program(0)
     end if
     if l_issqtd = 0 then
        let l_saida = "Não foi possível montar a lista de aliquotas de ISS"
        display "ERRO@@", l_saida clipped, "@@LOGIN"

        exit program(0)
     end if
  end if

  return l_marcarlid

end function  #--> wdatc040_indicarParamOptante()
