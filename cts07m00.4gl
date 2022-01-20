#############################################################################
# Nome do Modulo: CTS07M00                                         Marcelo  #
#                                                                  Gilberto #
# Inclusao da placa do veiculo na apolice                          Jul/1997 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 23/11/1998  PSI 7214-1   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00), passando parametros #
#                                       de registro via formulario.         #
#---------------------------------------------------------------------------#
# 07/12/1998  PSI 6478-5   Gilberto     Alteracao na chamada da funcao de   #
#                                       cabecalho (CTS05G00), inclusao do   #
#                                       parametro RAMO.                     #
#---------------------------------------------------------------------------#
# 02/07/1999  PSI 8247-3   Gilberto     Substituicao da tabela APAM2VIA pe- #
#                                       la tabela ABAM2VIA.                 #
#---------------------------------------------------------------------------#
# 26/07/1999  PSI 8247-3   Wagner       Acesso ao modulo apgt2vfnc_ct24h    #
#                                       para verificacao da ABAM2VIA.       #
#---------------------------------------------------------------------------#
# 20/08/1999  PSI 5591-3   Gilberto     Retirada dos campos de DDD e tele-  #
#                                       ne do segurado.                     #
#---------------------------------------------------------------------------#
# 20/10/1999  PSI 9118-9   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00) para gravar as tabe- #
#                                       las de relacionamento.              #
#---------------------------------------------------------------------------#
# 07/12/1999  PSI 7263-0   Gilberto     Gravar tabela de relacionamento de  #
#                                       ligacoes x propostas.               #
#---------------------------------------------------------------------------#
# 13/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 23/06/2000  PSI 108650   Akio         Inclusao da funcao CTS10G03         #
#---------------------------------------------------------------------------#
# 08/05/2003  PSI 168920   Aguinaldo   Adaptacao a Resolucao 86             #
#---------------------------------------------------------------------------#
# 19/11/2003  PSI 172421 OSF.28886   Aguinaldo Gravar endereco no historico #
#                                              da ligacao                   #
#---------------------------------------------------------------------------#
# 09/01/2004  PSI 172421 OSF.30937   Sonia     Adendo da alteracao efetuada #
#                                              OSF 28886.                   #
#---------------------------------------------------------------------------#
# 02/02/2006  Zeladoria    Priscila  Buscar data e hora do banco de dados   #
#---------------------------------------------------------------------------#
# 21/12/2006  Priscila         CT         Chamar funcao especifica para     #
#                                         insercao em datmlighist           #
#---------------------------------------------------------------------------#
# 14/10/2008  PSI 223689  Roberto         Inclusao da funcao figrc072():    #
#                                         essa funcao evita que o programa  #
#                                         caia devido ha uma queda da       #
#                                         instancia da tabela de origem para#
#                                         a tabela de replica               #
# ---------- ------------- ---------      ----------------------------------#
# 04/01/2010               Amilton        Projeto sucursal Smallint         #
#                                                                           #
#############################################################################
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI       Alteracao                              #
# ---------- ------------- --------- ---------------------------------------#
# 14/02/2007 Saulo,Meta    AS130087  Migracao para a versao 7.32            #
#---------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"
globals  "/homedsa/projetos/geral/globals/figrc072.4gl"

define m_prepare     char(1)
#---------------------------------------------------
function cts07m00_prepare()
#---------------------------------------------------
define  l_sql    char(1000)

  let l_sql = "select a.lgdtip "
             ,"      ,a.lgdnom "
             ,"      ,b.cidnom "
             ,"      ,b.ufdcod "
             ,"      ,c.brrnom "
             ,"  from glaklgd a,glakcid b,glakbrr c "
             ,"  where a.lgdcep = ? "
             ,"    and a.lgdcepcmp = ? "
             ,"    and b.cidcod    = a.cidcod "
             ,"    and c.cidcod    = a.cidcod "
             ,"    and c.brrcod    = a.brrcod "
      prepare p_cts07m00_001 from l_sql
      declare c_cts07m00_001 cursor for p_cts07m00_001

  let l_sql = "select cidcod   "
             ,"  from glakcid  "
             ,"  where cidnom  = ? "
             ,"    and ufdcod  = ? "
      prepare p_cts07m00_002 from l_sql
      declare c_cts07m00_002 cursor for p_cts07m00_002

  let l_sql = "insert into datmsegviaend "
             ," (segnumdig "
             ," ,endlgdtip "
             ," ,endlgd    "
             ," ,endnum    "
             ," ,endcmp    "
             ," ,endcep    "
             ," ,endcepcmp "
             ," ,endcid    "
             ," ,endufd    "
             ," ,endbrr)   "
             ," values "
             ," (?,?,?,?,?,?,?,?,?,?) "
      prepare p_cts07m00_003 from l_sql

   let l_sql = "update datmsegviaend set "
             ,"  endlgdtip = ? "
             ," ,endlgd    = ? "
             ," ,endnum    = ? "
             ," ,endcmp    = ? "
             ," ,endcep    = ? "
             ," ,endcepcmp = ? "
             ," ,endcid    = ? "
             ," ,endufd    = ? "
             ," ,endbrr    = ? "
             ," where segnumdig = ? "
      prepare p_cts07m00_004 from l_sql

     let m_prepare = "S"

end function #--> cts07m00_prepare
#--------------------------------------------------------------------
 function cts07m00()
#--------------------------------------------------------------------

 define d_cts07m00  record
    c24solnom       like datmligacao.c24solnom,
    nom             like datmservico.nom,
    doctxt          char (32),
    corsus          like datmservico.corsus,
    cornom          like datmservico.cornom,
    cvnnom          char (19),
    vclcoddig       like datmservico.vclcoddig,
    vcldes          like datmservico.vcldes,
    vclanomdl       like datmservico.vclanomdl,
    vclcordes       char (11),
    c24astcod       like datkassunto.c24astcod,
    c24astdes       char (55),
    endcep          like gsakend.endcep,
    endcepcmp       like gsakend.endcepcmp,
    endlgdtip       like gsakend.endlgdtip,
    endtxt          char (65),
    endnum          like gsakend.endnum,
    endcmp          like gsakend.endcmp,
    endbrr          like gsakend.endbrr,
    endcid          like gsakend.endcid,
    endufd          like gsakend.endufd,
    vcllicnum       like datmservico.vcllicnum,
    confirma        char (01)
 end record

 define ws              record
        prompt_key      char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        codigosql       integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                ,

    segnumdig       like gsakseg.segnumdig     ,
    aplstt          like abamapol.aplstt       ,
    itmstt          like abbmdoc.itmstt        ,
    vigfnl          like abamapol.vigfnl       ,
    endlgdtip       like gsakend.endlgdtip     ,
    endlgd          like gsakend.endlgd        ,
    endnum          like gsakend.endnum        ,
    endcmp          like gsakend.endcmp        ,
    vclchsinc       like abbmveic.vclchsinc    ,
    vclchsfnl       like abbmveic.vclchsfnl    ,
    itmsttatu       like abbmitem.itmsttatu    ,
    soldat          like apam2via.soldat       ,
    extdat          like apam2via.extdat       ,
    confirma        char (01)                  ,
    retflg          smallint                   ,
    msgtxt          char (40)                  ,
    msglog          char(80)
 end record

 define l_oldendcep     like gsakend.endcep
 define l_oldendcepcmp  like gsakend.endcepcmp
 define l_oldendtxt     char (65)
 define l_cidcod        like glaklgd.cidcod
 define l_endaux        char(70)
 define l_tabname       char(30)
 define l_status        smallint

 define l_data          date,
        l_hora2         datetime hour to minute
#--------------------------------------------------------------------
# Inicializacao das variaveis
#--------------------------------------------------------------------

 call cts08g01("A","N",
               "*******  ASSUNTO BLOQUEADO *******  ",
               "ORIENTE O SEGURADO A PROCURAR       ",
               "O SEU CORRETOR                      ",
               "")
      returning ws.confirma
 return

 if g_documento.succod     is null   or
    g_documento.aplnumdig  is null   or
    g_documento.itmnumdig  is null   then
    error " Parametros nao informados. AVISE A INFORMATICA!"
    return
 end if

 initialize d_cts07m00.*   to null
 initialize ws.*           to null

#--------------------------------------------------------------------
# Busca informacoes sobre o item/segurado
#--------------------------------------------------------------------

 if m_prepare is null then
    call cts07m00_prepare()
 end if

 select itmsttatu
   into ws.itmsttatu
   from abbmitem
  where succod    = g_documento.succod       and
        aplnumdig = g_documento.aplnumdig    and
        itmnumdig = g_documento.itmnumdig

 if sqlca.sqlcode <> 0   then
    error " Erro (", sqlca.sqlcode, ") na leitura do item. AVISE A INFORMATICA!"
    return
 end if

 select segnumdig, itmstt
   into ws.segnumdig,
        ws.itmstt
   from abbmdoc
  where succod    = g_documento.succod       and
        aplnumdig = g_documento.aplnumdig    and
        itmnumdig = g_documento.itmnumdig    and
        dctnumseq = g_funapol.dctnumseq

 if sqlca.sqlcode <> 0   then
    error "Erro (", sqlca.sqlcode, ") na leitura do documento. AVISE A INFORMATICA!"
    return
 end if

#--------------------------------------------------------------------
# Busca informacoes sobre a apolice
#--------------------------------------------------------------------

 select vigfnl, aplstt
   into ws.vigfnl,
        ws.aplstt
   from abamapol
  where succod    = g_documento.succod     and
        aplnumdig = g_documento.aplnumdig

 if sqlca.sqlcode <> 0   then
    error " Erro (", sqlca.sqlcode, ") na leitura da apolice. AVISE INFORMATICA!"
    return
 end if

#--------------------------------------------------------------------
# Busca endereco do segurado
#--------------------------------------------------------------------

 select endlgd,
        endnum,
        endcmp,
        endbrr,
        endcid,
        endufd,
        endcep,
        endcepcmp,
        endlgdtip
   into d_cts07m00.endtxt,
        d_cts07m00.endnum,
        d_cts07m00.endcmp,
        d_cts07m00.endbrr,
        d_cts07m00.endcid,
        d_cts07m00.endufd,
        d_cts07m00.endcep,
        d_cts07m00.endcepcmp,
        d_cts07m00.endlgdtip
   from gsakend
  where gsakend.segnumdig = ws.segnumdig    and
        gsakend.endfld    = "1"


 if sqlca.sqlcode <> 0   then
    error " Erro (", sqlca.sqlcode, ") na leitura do endereco. AVISE A INFORMATICA!"
    return
 end if

 if   d_cts07m00.endtxt is null
 then
      let  d_cts07m00.endtxt = " "
 end  if

 let l_oldendtxt          = d_cts07m00.endtxt
 let d_cts07m00.c24solnom = g_documento.solnom
 let d_cts07m00.c24astcod = g_documento.c24astcod

 let d_cts07m00.doctxt = "Apolice.: ", g_documento.succod    using "<<<&&",#"&&", projeto succod
                                  " ", g_documento.ramcod    using "&&&&",
                                  " ", g_documento.aplnumdig using "<<<<<<<& &"

 call c24geral8(d_cts07m00.c24astcod) returning d_cts07m00.c24astdes

 call cts05g00 (g_documento.succod,
                g_documento.ramcod   ,
                g_documento.aplnumdig,
                g_documento.itmnumdig)
      returning d_cts07m00.nom,
                d_cts07m00.corsus,
                d_cts07m00.cornom,
                d_cts07m00.cvnnom,
                d_cts07m00.vclcoddig,
                d_cts07m00.vcldes,
                d_cts07m00.vclanomdl,
                d_cts07m00.vcllicnum,
                ws.vclchsinc,
                ws.vclchsfnl,
                d_cts07m00.vclcordes

#--------------------------------------------------------------------
# Exibe dados na tela
#--------------------------------------------------------------------

 open window cts07m00 at 04,02 with form "cts07m00"
             attribute(form line 1, comment line last, message line last - 2)

 message " (F1)Help  (F5)Espelho"

 display by name d_cts07m00.*
 display by name d_cts07m00.c24solnom attribute (reverse)
 display by name d_cts07m00.cvnnom    attribute (reverse)


 input by name d_cts07m00.endcep,
               d_cts07m00.endcepcmp,
               d_cts07m00.endlgdtip,
               d_cts07m00.endtxt,
               d_cts07m00.endnum,
               d_cts07m00.endcmp,
               d_cts07m00.endbrr,
               d_cts07m00.endcid,
               d_cts07m00.endufd,
               d_cts07m00.vcllicnum,
               d_cts07m00.confirma without defaults

    before field endcep
          let l_oldendcep = d_cts07m00.endcep
          display by name d_cts07m00.endcep  attribute (reverse)

    after field endcep
          display by name d_cts07m00.endcep

    before field endcepcmp
          let l_oldendcepcmp = d_cts07m00.endcepcmp
          display by name d_cts07m00.endcepcmp  attribute (reverse)

    after field endcepcmp
          if l_oldendcepcmp <> d_cts07m00.endcepcmp   or
             l_oldendcep    <> d_cts07m00.endcep      then
             whenever error continue
              open c_cts07m00_001 using d_cts07m00.endcep
                                     ,d_cts07m00.endcepcmp

              fetch c_cts07m00_001 into d_cts07m00.endlgdtip
                                     ,d_cts07m00.endtxt
                                     ,d_cts07m00.endcid
                                     ,d_cts07m00.endufd
                                     ,d_cts07m00.endbrr
             whenever error stop

             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                   error"CEP nao cadastrado!"
                   next field endcep
                else
                   error"Problemas ao acessar GLAKLGD <cts07m00> "
                                     ," Erro.: ",sqlca.sqlcode
                   let int_flag = true
                   exit input
                end if
             end if

             call cts06g06(d_cts07m00.endtxt)
                  returning d_cts07m00.endtxt

          end if
          display by name d_cts07m00.endlgdtip
          display by name d_cts07m00.endtxt
          display by name d_cts07m00.endufd
          display by name d_cts07m00.endbrr
          display by name d_cts07m00.endcepcmp

    before field endlgdtip
          display by name d_cts07m00.endlgdtip attribute (reverse)

    after field endlgdtip
         if d_cts07m00.endlgdtip is null or
            d_cts07m00.endlgdtip = " " then
            error"Campo deve ser Preenchido."
            next field endlgdtip
         end if
         display by name d_cts07m00.endlgdtip

    before field endtxt
          display by name d_cts07m00.endtxt attribute (reverse)

    after field endtxt
         if d_cts07m00.endtxt is null or
            d_cts07m00.endtxt = " " then
            error"Campo deve ser Preenchido."
            next field endtxt
         end if
         display by name d_cts07m00.endtxt

     before field endnum
        display by name d_cts07m00.endnum attribute (reverse)

     after field endnum
        if d_cts07m00.endnum is null or
           d_cts07m00.endnum =  " " then
           error"Campo deve ser Preenchido."
           next field endnum
        end if
        display by name d_cts07m00.endnum

     before field endcmp
        display by name d_cts07m00.endcmp attribute (reverse)

     after field endcmp
        display by name d_cts07m00.endcmp

     before field endbrr
        display by name d_cts07m00.endbrr attribute (reverse)

     after field endbrr
         if d_cts07m00.endbrr is null or
            d_cts07m00.endbrr =  " " then
            error"Campo deve ser Preenchido."
            next field endbrr
         end if
        display by name d_cts07m00.endbrr

    before field endcid
       display by name d_cts07m00.endcid attribute (reverse)

    after field endcid
       if d_cts07m00.endcid is null or
          d_cts07m00.endcid =  " " then
          error"Campo deve ser Preenchido."
          next field endcid
       end if
       display by name d_cts07m00.endcid

    before field endufd
       display by name d_cts07m00.endufd attribute (reverse)

    after field endufd
       if d_cts07m00.endufd is null or
          d_cts07m00.endufd =  " " then
          error"Campo deve ser Preenchido."
          next field endufd
       end if
       display by name d_cts07m00.endufd

    before field vcllicnum
       if d_cts07m00.vcllicnum is not null  and
          d_cts07m00.vcllicnum <> " "       then
          error " Substituicao de placa do veiculo so' e' possivel atraves de endosso!"
          let d_cts07m00.confirma = "N"
          exit input
       else
          display by name d_cts07m00.vcllicnum  attribute (reverse)
       end if

    after field vcllicnum
       display by name d_cts07m00.vcllicnum

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          initialize d_cts07m00.vcllicnum to null
          next field vcllicnum
       end if

       if d_cts07m00.vcllicnum is null  then
          error " Placa do veiculo deve ser informada!"
          next field vcllicnum
       end if

       if tem_bloqueio_placa (31,"","","","",d_cts07m00.vcllicnum)  then
          error " A placa ", d_cts07m00.vcllicnum clipped, " esta' bloqueada!"
          initialize d_cts07m00.vcllicnum  to null
          next field vcllicnum
       end if

       if not srp1415(d_cts07m00.vcllicnum)  then
          error " Placa invalida! Informe novamente."
          initialize d_cts07m00.vcllicnum  to null
          next field vcllicnum
       end if

    before field confirma
       whenever error continue
         open c_cts07m00_002 using d_cts07m00.endcid
                                ,d_cts07m00.endufd
         fetch c_cts07m00_002 into l_cidcod
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = 100 then
             call cts06g04(d_cts07m00.endcid,d_cts07m00.endufd)
                  returning l_cidcod
                           ,d_cts07m00.endcid
                           ,d_cts07m00.endufd

             display by name d_cts07m00.endcid
             display by name d_cts07m00.endufd
          else
             error"Problemas ao acessar GLAKLGD <cts07m00> "
                                 ," Erro.: ",sqlca.sqlcode
             let int_flag = true
             exit input
          end if
       end if


#--------- Alteracao da consistencia de mudanca dos dados do endereco
#          Solicitado por Ligia Mattge p/ PSI: 172421
#
       if d_cts07m00.endcep    is null
       or d_cts07m00.endcep    <> l_oldendcep
       or d_cts07m00.endcepcmp is null
       or d_cts07m00.endcepcmp <> l_oldendcepcmp
       or d_cts07m00.endtxt    <> l_oldendtxt
       then
          call cts06g05(d_cts07m00.endlgdtip
                       ,d_cts07m00.endtxt
                       ,d_cts07m00.endnum
                       ,d_cts07m00.endbrr
                       ,l_cidcod
                       ,d_cts07m00.endufd)
               returning d_cts07m00.endlgdtip
                        ,d_cts07m00.endtxt
                        ,d_cts07m00.endbrr
                        ,d_cts07m00.endcep
                        ,d_cts07m00.endcepcmp
                        ,l_status

           display by name d_cts07m00.endlgdtip
           display by name d_cts07m00.endtxt
           display by name d_cts07m00.endbrr
           display by name d_cts07m00.endcep
           display by name d_cts07m00.endcepcmp
       end if

       display by name d_cts07m00.confirma attribute (reverse)

    after field confirma
       display by name d_cts07m00.confirma

       if d_cts07m00.confirma is null  then
          error " Confirma solicitacao: (S)im ou (N)ao!"
          next field confirma
       end if

       if d_cts07m00.confirma <> "S"  and
          d_cts07m00.confirma <> "N"  then
          error " Confirmacao deve ser (S)im ou (N)ao!"
          next field confirma
       end if

       if d_cts07m00.confirma = "N"  then
          error " Inclusao de placa nao confirmada!"
          next field endcep
       else
          call cts08g01("A","N","O ENDERECO INFORMADO NAO IRA ALTERAR",
                                "A BASE DE DADOS DO SEGURADO, FAVOR",
                                "SOLICITAR CONTATO COM O CORRETOR PARA",
                                "ALTERACAO DEFINITIVA")
                  returning ws.confirma
       end if

       if ws.itmstt = 1  then
          error " Operacao nao realizada! Item cancelado!"
          let d_cts07m00.confirma = "N"
          exit input
       end if

       if ws.itmsttatu is null  or
          ws.itmsttatu <> "A"   then
          error " Operacao nao realizada! Item cancelado!"
          let d_cts07m00.confirma = "N"
          exit input
       end if

       if ws.aplstt = "C"  then
          error " Operacao nao realizada! Apolice cancelada!"
          let d_cts07m00.confirma = "N"
          exit input
       end if

       call cts40g03_data_hora_banco(2)
           returning l_data, l_hora2
       if ws.vigfnl < l_data  then
          error " Operacao nao realizada! Documento vencido!"
          let d_cts07m00.confirma = "N"
          exit input
       end if

   on key (interrupt)
      if cts08g01("C","S","","ABANDONA O PREENCHIMENTO ?","","") = "S"  then
         let int_flag = true
         exit input
      end if

   on key (F1)
      if g_documento.c24astcod is not null then
         call ctc58m00_vis(g_documento.c24astcod)
      end if

   on key (F5)
{
      if g_documento.ramcod = 31   or
         g_documento.ramcod = 531  then
         call cta01m00()
      else
         call cta01m20()
      end if
}
       let g_monitor.horaini = current ## Flexvision
       call cta01m12_espelho(g_documento.ramcod,
                            g_documento.succod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            g_documento.prporg,
                            g_documento.prpnumdig,
                            g_documento.fcapacorg,
                            g_documento.fcapacnum,
                            g_documento.pcacarnum,
                            g_documento.pcaprpitm,
                            g_ppt.cmnnumdig,
                            g_documento.crtsaunum,
                            g_documento.bnfnum,
                            g_documento.ciaempcod)

 end input
 if  int_flag  then
     error " Operacao cancelada! "
 else
     #------------------------------------------------------------------------
     # Solicita 2a via do cartao
     #------------------------------------------------------------------------
     if  d_cts07m00.confirma = "S"  then

         begin work

         whenever error continue
           execute p_cts07m00_003 using ws.segnumdig
                                     ,d_cts07m00.endlgdtip
                                     ,d_cts07m00.endtxt
                                     ,d_cts07m00.endnum
                                     ,d_cts07m00.endcmp
                                     ,d_cts07m00.endcep
                                     ,d_cts07m00.endcepcmp
                                     ,d_cts07m00.endcid
                                     ,d_cts07m00.endufd
                                     ,d_cts07m00.endbrr
         whenever error stop

         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = -268 then
               whenever error continue
                 execute p_cts07m00_004 using d_cts07m00.endlgdtip
                                           ,d_cts07m00.endtxt
                                           ,d_cts07m00.endnum
                                           ,d_cts07m00.endcmp
                                           ,d_cts07m00.endcep
                                           ,d_cts07m00.endcepcmp
                                           ,d_cts07m00.endcid
                                           ,d_cts07m00.endufd
                                           ,d_cts07m00.endbrr
                                           ,ws.segnumdig

               whenever error stop

               if sqlca.sqlcode <> 0 then
                  error"Problemas na Alteracao DATMSEGVIAEND <cts07m00> "
                      ," Erro.: ",sqlca.sqlcode
                  rollback work
                  close window cts07m00
                  return
               end if
            else
               if sqlca.sqlcode <> 0 then
                  error"Problemas na Inclusao DATMSEGVIAEND <cts07m00> "
                      ," Erro.: ",sqlca.sqlcode
                  rollback work
                  close window cts07m00
                  return
               end if
            end if
         end if

         #----------------------------------------------------------------------
         let ws.msglog = "apgt2vfnc_ct24h(", g_documento.succod    ,",",
                                             g_documento.aplnumdig ,",",
                                             g_documento.edsnumref ,",",
                                             g_documento.itmnumdig ,",",
                                             "S"                   ,",",
                                             "N"                   ,")"

         call errorlog(ws.msglog)

         call figrc072_setTratarIsolamento()
         call apgt2vfnc_ct24h( g_documento.succod   ,
                               g_documento.aplnumdig,
                               g_documento.edsnumref,
                               g_documento.itmnumdig,
                               "S"                  , # Cartao
                               "N"                  ) # Apolice
              returning ws.retflg,
                        ws.msgtxt

         let ws.msglog = "apgt2vfnc_ct24h_ret ", ws.retflg, ws.msgtxt
         call errorlog(ws.msglog)
         if g_isoAuto.sqlCodErr <> 0 then
            let ws.msgtxt = "2 via Indisponivel"
            let ws.retflg = g_isoAuto.sqlCodErr
         end if
         #----------------------------------------------------------------------------------------

         if  ws.retflg <> 0  then
             rollback work
             let ws.msgtxt  = upshift(ws.msgtxt)
             call cts08g01("I","N","",ws.msgtxt,"","")
                  returning ws.confirma
         else
           #--------------------------------------------------------------------
           # Busca numeracao ligacao
           #--------------------------------------------------------------------
             call cts10g03_numeracao( 1, "" )
                  returning ws.lignum   ,
                            ws.atdsrvnum,
                            ws.atdsrvano,
                            ws.codigosql,
                            ws.msg

             if  ws.codigosql <> 0  then
                 let ws.msg = "CTS07M00 - ",ws.msg
                 call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
                 rollback work
                 prompt "" for char ws.prompt_key
                 return
             end if

           #--------------------------------------------------------------------
           # Grava ligacao
           #--------------------------------------------------------------------
             call cts40g03_data_hora_banco(2)
                  returning l_data, l_hora2
             call cts10g00_ligacao ( ws.lignum               ,
                                     l_data                  ,
                                     l_hora2                 ,
                                     g_documento.c24soltipcod,
                                     g_documento.solnom      ,
                                     g_documento.c24astcod   ,
                                     g_issk.funmat           ,
                                     g_documento.ligcvntip   ,
                                     g_c24paxnum             ,
                                     "","", "","", "",""     ,
                                     g_documento.succod      ,
                                     g_documento.ramcod      ,
                                     g_documento.aplnumdig   ,
                                     g_documento.itmnumdig   ,
                                     g_documento.edsnumref   ,
                                     g_documento.prporg      ,
                                     g_documento.prpnumdig   ,
                                     g_documento.fcapacorg   ,
                                     g_documento.fcapacnum   ,
                                     "","","",""             ,
                                     "", "", "", "" )
                  returning ws.tabname,
                            ws.codigosql

             if  ws.codigosql  <>  0  then
                 error " Erro (", ws.codigosql, ") na gravacao da",
                       " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
                 rollback work
                 prompt "" for char ws.prompt_key
                 return
             end if

           #--------------------------------------------------------------------
           # Atualiza veiculo da apolice com a placa
           #--------------------------------------------------------------------
             update ABBMVEIC
                set vcllicnum = d_cts07m00.vcllicnum
                    where succod    = g_documento.succod
                      and aplnumdig = g_documento.aplnumdig
                      and itmnumdig = g_documento.itmnumdig
                      and dctnumseq = g_funapol.vclsitatu

             if  sqlca.sqlcode  <>  0  then
                 error " Erro (", sqlca.sqlcode, ") na gravacao da",
                       " placa do veiculo. AVISE A INFORMATICA!"
                 rollback work
                 prompt "" for char ws.prompt_key
                 return
             end if

             let l_endaux = d_cts07m00.endcep clipped ,"-"
                           ,d_cts07m00.endcepcmp clipped
             #21/12/2006
             #call cts10g00_historico(1,ws.lignum,"","","",l_endaux)
             #     returning l_tabname, l_status
             call ctd06g01_ins_datmlighist(ws.lignum,
                                           g_issk.funmat,
                                           l_endaux,
                                           l_data,
                                           l_hora2,
                                           g_issk.usrtip,
                                           g_issk.empcod  )
                  returning l_status,   #retorno
                            l_tabname   #mensagem

             #if l_status <> 0 then
             if l_status <> 1 then
                #error "(", l_status, ")"
                #     ," na gravacao da tabela "
                #     ," l_tabname clipped,"
                error l_tabname
                rollback work
                return
             end if

             let l_endaux = d_cts07m00.endlgdtip clipped
                           ," ", d_cts07m00.endtxt clipped
                           ," ", d_cts07m00.endnum
             #call cts10g00_historico(1,ws.lignum,"","","",l_endaux)
             #     returning l_tabname, l_status
             call ctd06g01_ins_datmlighist(ws.lignum,
                                           g_issk.funmat,
                                           l_endaux,
                                           l_data,
                                           l_hora2,
                                           g_issk.usrtip,
                                           g_issk.empcod  )
                  returning l_status,   #retorno
                            l_tabname   #mensagem
             #if l_status <> 0 then
             if l_status <> 1 then
                #error "(", l_status, ")"
                #     ," na gravacao da tabela "
                #     ," l_tabname clipped,"
                error l_tabname
                rollback work
                return
             end if

             let l_endaux = d_cts07m00.endcmp clipped
             #call cts10g00_historico(1,ws.lignum,"","","",l_endaux)
             #     returning l_tabname, l_status
             call ctd06g01_ins_datmlighist(ws.lignum,
                                           g_issk.funmat,
                                           l_endaux,
                                           l_data,
                                           l_hora2,
                                           g_issk.usrtip,
                                           g_issk.empcod  )
                  returning l_status,   #retorno
                            l_tabname   #mensagem
             #if l_status <> 0 then
             if l_status <> 1 then
                #error "(", l_status, ")"
                #     ," na gravacao da tabela "
                #     ," l_tabname clipped,"
                error l_tabname
                rollback work
                return
             end if

             let l_endaux = d_cts07m00.endbrr clipped
             #call cts10g00_historico(1,ws.lignum,"","","",l_endaux)
             #     returning l_tabname, l_status
             call ctd06g01_ins_datmlighist(ws.lignum,
                                           g_issk.funmat,
                                           l_endaux,
                                           l_data,
                                           l_hora2,
                                           g_issk.usrtip,
                                           g_issk.empcod  )
                  returning l_status,   #retorno
                            l_tabname   #mensagem
             #if l_status <> 0 then
             if l_status <> 1 then
                #error "(", l_status, ")"
                #     ," na gravacao da tabela "
                #     ," l_tabname clipped,"
                error l_tabname
                rollback work
                return
             end if

             let l_endaux = d_cts07m00.endcid clipped
                           ,"-",d_cts07m00.endufd clipped
             #call cts10g00_historico(1,ws.lignum,"","","",l_endaux)
             #     returning l_tabname, l_status
             call ctd06g01_ins_datmlighist(ws.lignum,
                                           g_issk.funmat,
                                           l_endaux,
                                           l_data,
                                           l_hora2,
                                           g_issk.usrtip,
                                           g_issk.empcod  )
                  returning l_status,   #retorno
                            l_tabname   #mensagem
             #if l_status <> 0 then
             if l_status <> 1 then
                #error "(", l_status, ")"
                #     ," na gravacao da tabela "
                #     ," l_tabname clipped,"
                error l_tabname
                rollback work
                return
             end if

             commit work
             error " Inclusao de placa efetuada!"
             call cts08g01("I","N","","SEGUNDA VIA DO CARTAO DE PROTECAO",
                                    "FOI SOLICITADA AUTOMATICAMENTE!","")
                  returning ws.confirma
         end if
     end if
 end if

 close window cts07m00
 let int_flag = false

end function  ###  cts07m00
