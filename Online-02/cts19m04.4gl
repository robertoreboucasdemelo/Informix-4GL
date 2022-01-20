#############################################################################
# Nome do Modulo: cts19m04                                         Ruiz     #
# Tela de categoria e franquia de vidros  -  com documento         Mai/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#                     * * * A L T E R A C A O * * *                         #
#  Analista Resp. : Henrique Pezella                 OSF : 9377             #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 20/11/2002       #
#  Objetivo       : Aprimoramento da clausula 71-Danos aos vidros atraves   #
#                   da clausula 75(contem clausula 71 + espelho retrovisor) #
#---------------------------------------------------------------------------#
# 09/05/2007  CT 7051656  Roberto Reboucas - Inclusao das funcoes           #
#                                            faemc603_apolice e             #
#                                            faemc603_item                  #
#---------------------------------------------------------------------------#
#                                                                           #
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a  #
#                                         global                            #
#---------------------------------------------------------------------------#
# 10/09/2009 Amilton, Meta     Psi 247006 Incluir tela de saldo e limites   #
#                                         de vidros de acordo com a clausula#
#---------------------------------------------------------------------------#
# 22/10/2010 Patricia W.       Psi 260479 Alteracoes para autorizacao do    #
#                                         B14 (clausulas da proposta)       #
#---------------------------------------------------------------------------#
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl" --> 223689

   define m_prep smallint
   define m_pbsvig   smallint                                                
   define m_lateral  smallint                                                
   define m_retrov   smallint                                                
   define m_farol    smallint                                                
   define m_laternas smallint 
   define m_utiliz   smallint  
   define m_mens     char(100)
   

   define d_cts19m04  record
      vdrpbsfrqvlr    like aacmclscnd.frqvlr
     ,vdrvgafrqvlr    like aacmclscnd.frqvlr
     ,vdrlatfrqvlr    like aacmclscnd.frqvlr
     ,vdrocufrqvlr    like aacmclscnd.frqvlr
     ,vdrqbvfrqvlr    like aacmclscnd.frqvlr
     ,vdrrtrfrqvlr    like aacmclscnd.frqvlr
     ,farolnfrqvlr    like aacmclscnd.frqvlr
     ,farmilfrqvlr    like aacmclscnd.frqvlr
     ,farnebfrqvlr    like aacmclscnd.frqvlr
     ,farpiscaqvlr    like aacmclscnd.frqvlr
     ,farlanteqvlr    like aacmclscnd.frqvlr
     ,vdrrtrtxt       char(14)
     ,txtfarol        char(14)
     ,txtfarolmilha   char(14)
     ,txtfarolneblina char(14)
     ,txtpisca        char(14)
     ,txtlanterna     char(14)
     ,prbrisa         char(01)
     ,traseiro        char(01)
     ,lateral         char(01)
     ,oculo           char(01)
     ,qvent           char(01)
     ,retrovisor      char(01)
     ,farol           char(01)
     ,farolmilha      char(01)
     ,farolneblina    char(01)
     ,pisca           char(01)
     ,lanterna        char(01)
     ,obs             char(20)      
      
   end record
      
   # -- OSF 9377 - Fabrica de Software, Katiucia -- #
   define d_aux19m04   record
      vdrdirfrqvlr     like aacmclscnd.frqvlr
     ,vdresqfrqvlr     like aacmclscnd.frqvlr
     ,ocudirfrqvlr     like aacmclscnd.frqvlr
     ,ocuesqfrqvlr     like aacmclscnd.frqvlr
     ,dirrtrfrqvlr     like aacmclscnd.frqvlr
     ,esqrtrfrqvlr     like aacmclscnd.frqvlr
     ,frqvlrfarois     like aacmclscnd.frqvlr
   end record

 define ws          record
       viginc          like abamapol.viginc,
       vigfnl          like abamapol.vigfnl,
       aplstt          like abamapol.aplstt,
       cvnnum          like abamapol.cvnnum,
       segnumdig       like gsakseg.segnumdig,
       cgccpfnum       like gsakseg.cgccpfnum,
       cgcord          like gsakseg.cgcord,
       cgccpfdig       like gsakseg.cgccpfdig,
       segdddcod       like gsakend.dddcod,
       segteltxt       like gsakend.teltxt,
       cordddcod       like gcakfilial.dddcod,
       corteltxt       like gcakfilial.teltxt,
       itmstt          like abbmdoc.itmstt,
       vclmrccod       like agbkveic.vclmrccod,
       vcltipcod       like agbkveic.vcltipcod,
       vclchsinc       like abbmveic.vclchsinc,
       vclchsfnl       like abbmveic.vclchsfnl,
       vclchsnum       char (20),
       vclanofbc       like abbmveic.vclanofbc,
       vclcoddig       like abbmveic.vclcoddig,
       vclanomdl       like abbmveic.vclanomdl,
       dctnumseq       like abbmclaus.dctnumseq,
       cbtcod          like abbmcasco.cbtcod,
       ctgtrfcod       like abbmcasco.ctgtrfcod,
       clcdat          like abbmcasco.clcdat,
       clalclcod       like abbmdoc.clalclcod,
       clsviginc       like abbmclaus.viginc,
       edsviginc       like abbmdoc.viginc,
       confirma        char (01),
       solantcab       char (21),
       solantdes       char (19),
       clscndvlr       like aacmclscnd.clscndvlr,
       clscndreivlr    like aacmclscnd.clscndreivlr,
       tabnum          like itatvig.tabnum,
       pbrfrqvlr       like aacmclscnd.frqvlr,
       vigfrqvlr       like aacmclscnd.frqvlr,
       latfrqvlr       like aacmclscnd.frqvlr,
       vllatdir        like aacmclscnd.frqvlr,
       vlocuesq        like aacmclscnd.frqvlr,
       vlocudir        like aacmclscnd.frqvlr,
       vlqvento        like aacmclscnd.frqvlr,
       vlrtrdir        like aacmclscnd.frqvlr,
       vlrtresq        like aacmclscnd.frqvlr,
       vlrfardir       like aacmclscnd.frqvlr,
       vlrfaresq       like aacmclscnd.frqvlr,
       vlrfarmidir     like aacmclscnd.frqvlr,
       vlrfarmiesq     like aacmclscnd.frqvlr,
       vlrfarneesq     like aacmclscnd.frqvlr,
       vlrfarnedir     like aacmclscnd.frqvlr,
       vlrpiscadir     like aacmclscnd.frqvlr,
       vlrpiscaesq     like aacmclscnd.frqvlr,
       vlrlanteesq     like aacmclscnd.frqvlr,
       vlrlantedir     like aacmclscnd.frqvlr,
       msgtxt          char (40),
       c24astcod       like datmligacao.c24astcod,
       frqvlrlat       like aacmclscnd.frqvlr,
       frqvlrret       like aacmclscnd.frqvlr,
       clscod          like abbmclaus.clscod,
       frqvlr          like aacmclscnd.frqvlr,
       frqvlrfarois    decimal(15,5)
 end record

function cts19m04_prepare()

   define l_sql char(300)
   
   let l_sql = null 
   
   let l_sql = "select b.atdsrvnum,b.atdsrvano ",
               " from datrligapol a,           ",
               "      datmligacao b            ",
               " where a.succod = ?           ",
               "  and a.ramcod = ?           ",
               "  and a.aplnumdig = ?      ",
               "  and a.itmnumdig = ?         ",
               "  and b.lignum = a.lignum      ",
               "  and b.c24astcod = 'B14'      ",
               "group by 1,2                  "
   prepare p_cts19m04001 from l_sql                                
   declare c_cts19m04001 cursor with hold for p_cts19m04001          
   
   let l_sql = "select max(lignum)  ",
               "from datmligacao    ",
               "where atdsrvnum = ? ",
               "and atdsrvano = ?   "
   prepare p_cts19m04002 from l_sql                                
   declare c_cts19m04002 cursor with hold for p_cts19m04002
   
   let l_sql = "select "                                      
               ," vdrpbsavrfrqvlr,vdrvgaavrfrqvlr "
               ,",vdresqavrfrqvlr,vdrdiravrfrqvlr "
               ,",ocudiravrfrqvlr,ocuesqavrfrqvlr "
               ,",dirrtravrvlr,esqrtravrvlr "
               ,",drtfrlvlr,esqfrlvlr,drtmlhfrlvlr "
               ,",esqmlhfrlvlr,drtnblfrlvlr "
               ,",esqnblfrlvlr,drtpscvlr "
               ,",esqpscvlr,drtlntvlr,esqlntvlr "
               ,"from datmsrvext1 "                                 
               ,"where lignum = ? "
               ,"and   atdsrvnum = ? "
               ,"and   atdsrvano = ? "            
   prepare p_cts19m04003 from l_sql                                
   declare c_cts19m04003 cursor with hold for p_cts19m04003    
   
   let l_sql = "select cpodes from datkdominio ",
               " where cponom = ? "                
   prepare pcts19m04004 from l_sql 
   declare ccts19m04004 cursor with hold for pcts19m04004
       

let m_prep = true                    
                
end function    
                
#----------------------#
function cts19m04(param)
#----------------------#

    define param   record
        vclcoddig  like abbmveic.vclcoddig,
        vclanomdl  like abbmveic.vclanomdl
    end record
    
    define lr_saldo record
        pbsvig    char(2),
        lateral   char(2),
        retrov    char(2),
        farol     char(2),
        laterna   char(2) 
    end record           
    
    define prompt_key char (01)
    define w_erro  dec (1,0)
    define l_nulo char(40)   # PSI 239.399 Clausula 077

    define l_abrir char(01)  # PSI 239.399 Clausula 077

    define l_qtd_itens_proposta smallint #PSI 260479 espelho proposta

    let prompt_key  = null
    let w_erro      = null
    let l_nulo = null
    let l_abrir= "N"

    initialize ws.*         to null
    initialize d_cts19m04.* to null

    open window w_cts19m04 at 06,40 with form "cts19m04"
               attribute(form line 1, border)

    while true
     let w_erro = 0

     if g_documento.succod    is not null and
        g_documento.aplnumdig is not null then

        #------------------------------------------------------
        # Busca ultima situacao da apolice
        #------------------------------------------------------
        call f_funapol_ultima_situacao
              (g_documento.succod,g_documento.aplnumdig,g_documento.itmnumdig)
               returning g_funapol.*

        if g_funapol.resultado <> "O"   then
           error " Ultima situacao da apolice nao encontrada."
                ," AVISE A INFORMATICA!"
           prompt "" for char prompt_key
           let w_erro = 1
           exit while
        end if

        #----------------------------------#
        # SELECIONAR CLAUSULA EM ABBMCLAUS #
        #----------------------------------#

        if g_vdr_blindado is null then
           let g_vdr_blindado = "N" # Inicializada em cta02m00 com "N"
        end if
        declare c_abbmclaus cursor for
        select clscod
          from abbmclaus
         where succod    = g_documento.succod
           and aplnumdig = g_documento.aplnumdig
           and itmnumdig = g_documento.itmnumdig
           and dctnumseq = g_funapol.dctnumseq
           and clscod  in ("071","075","75R","076","76R","077")

        foreach c_abbmclaus into ws.clscod

            if ws.clscod = "077" then    # PSI 239.399 Clausula 077
               let l_abrir = "S"
               let g_vdr_blindado = "S"  # Aqui é atribuido o valor para "S"
                                         # e no modulo cts19m06 PSI 239.399 Clausula 77
               select clsdes into l_nulo
                 from aackcls
                where tabnum =( select max(a.tabnum) from aackcls a
                                 where a.ramcod = g_documento.ramcod
                                   and a.clscod = ws.clscod  )
                  and ramcod = g_documento.ramcod
                  and clscod = ws.clscod
            end if ## PSI 239.399 Clausula 077

            if cta13m00_verifica_clausula(g_documento.succod       ,
                                          g_documento.aplnumdig    ,
                                          g_documento.itmnumdig    ,
                                          g_funapol.dctnumseq ,
                                          ws.clscod           ) then

               continue foreach
            end if

        end foreach

        #------------------------------------------------------
        # Busca informacoes sobre a apolice
        #------------------------------------------------------
        select viginc   , vigfnl   ,
               aplstt   , cvnnum
          into ws.viginc, ws.vigfnl,
               ws.aplstt, ws.cvnnum
          from abamapol
         where succod    = g_documento.succod     and
               aplnumdig = g_documento.aplnumdig

        if sqlca.sqlcode <> 0   then
           error " Erro (",sqlca.sqlcode,") na leitura da apolice.",
                 " AVISE A INFORMATICA!"
           prompt "" for char prompt_key
           let w_erro = 1
           exit while
        end if

        select segnumdig,
               viginc,
               itmstt,
               clalclcod
          into ws.segnumdig,
               ws.edsviginc,
               ws.itmstt,
               ws.clalclcod
          from abbmdoc
         where succod    = g_documento.succod     and
               aplnumdig = g_documento.aplnumdig  and
               itmnumdig = g_documento.itmnumdig  and
               dctnumseq = g_funapol.dctnumseq

        #---------------------------------------------------------------
        # Dados do casco/veiculo
        #---------------------------------------------------------------
        select ctgtrfcod, cbtcod
          into ws.ctgtrfcod, ws.cbtcod
          from abbmcasco
         where succod    = g_documento.succod     and
               aplnumdig = g_documento.aplnumdig  and
               itmnumdig = g_documento.itmnumdig  and
               dctnumseq = g_funapol.autsitatu

        if sqlca.sqlcode = notfound  then
           error " Dados do casco nao encontrado! AVISE A INFORMATICA!"
           prompt "" for char prompt_key
           let w_erro = 1
           exit while
        end if

        # - Roberto CT 7051656 - Recupera a data de calculo da apolice

        call figrc072_setTratarIsolamento()        --> 223689

        call faemc603_apolice(g_documento.succod   ,
                              g_documento.aplnumdig,
                              g_funapol.dctnumseq  ,
                              g_documento.itmnumdig)
        returning ws.clcdat

         if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
           error "Função faemc603 indisponivel no momento! Avise a Informatica !" sleep 2
           let w_erro = 1
           exit while
        end if        -- > 223689

     else 
      if g_documento.prporg    is not null and
         g_documento.prpnumdig is not null then

        # PSI 260479
        declare ccts19m04_apbmclaus cursor for
         select clscod 
          from apbmclaus 
         where prporgpcp = g_documento.prporg and  
               prpnumpcp = g_documento.prpnumdig and
               clscod    in ('071','075','75R','076','76R','077')

        foreach ccts19m04_apbmclaus into ws.clscod
            if ws.clscod = "077" then    
               let l_abrir = "S"
               let g_vdr_blindado = "S"  
                                         
               select clsdes into l_nulo
                 from aackcls
                where tabnum =( select max(a.tabnum) from aackcls a
                                 where a.ramcod = g_documento.ramcod
                                   and a.clscod = ws.clscod  )
                  and ramcod = g_documento.ramcod
                  and clscod = ws.clscod
            end if 
        end foreach
      end if       # Fim PSI 260479
     end if
      
     let l_qtd_itens_proposta = 0
     
     call cts19m04_item_proposta(g_documento.prporg,
                                 g_documento.prpnumdig)
         returning l_qtd_itens_proposta

     if (g_documento.succod    is null or
         g_documento.aplnumdig is null) and  #Psi 260479
        ((g_documento.prporg    is null or
          g_documento.prpnumdig is null) or 
          l_qtd_itens_proposta > 1) or
        ws.clscod             is null then

        open window t_conf at 15,14 with 2 rows, 50 columns
                           attribute(border)
        menu "ESCOLHA A CLAUSULA"
           command "071" "Clausula 071"
              let ws.clscod = "071"
              exit menu

           command "075" "Clausula 075"
              let ws.clscod = "075"
              exit menu

           command "75R" "Clausula 75R"
              let ws.clscod = "75R"
              exit menu

           command "076" "Clausula 076"
              let ws.clscod = "076"
              exit menu

           command "76R" "Clausula 76R"
              let ws.clscod = "76R"
              exit menu

           command "077" "Clausula 077" # PSI 239.399 Clausula 077
              let ws.clscod = "077"
              let l_abrir  = "S"
              let g_vdr_blindado = "S"  # Aqui é atribuido o valor para "S"
                                        # e no modulo cts19m06 PSI 239.399 Clausula 77
               exit menu

        end menu
        close window t_conf


         # - Roberto CT 7051656 -  Recupera a data de calculo da Proposta

         call figrc072_setTratarIsolamento()        --> 223689

         call faemc603_proposta(g_documento.prporg
                               ,g_documento.prpnumdig)
         returning  ws.clcdat

        if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
           error "Função faemc603 indisponivel no momento! Avise a Informatica !" sleep 2
           let w_erro = 1
           exit while
        end if        -- > 223689



        let ws.cvnnum    = 1
        let ws.cbtcod    = 1
        let ws.clalclcod = 11

        if ws.ctgtrfcod is null then
           select autctgatu
             into ws.ctgtrfcod
             from agetdecateg
            where vclcoddig = param.vclcoddig
              and viginc    <= ws.clcdat
              and vigfnl    >= ws.clcdat

        end if
     end if

     select vclmrccod, vcltipcod
       into ws.vclmrccod, ws.vcltipcod
       from agbkveic
      where vclcoddig = param.vclcoddig

     if sqlca.sqlcode = notfound  then
        error " Veiculo nao encontrado! AVISE A INFORMATICA!"
        prompt "" for char prompt_key
        let w_erro = 1
        exit while
     end if

     display ws.clscod to mensagem attribute(reverse)


     if (ws.clcdat < "01/05/2007" )  then --varani
       call apgffger_valor_cfc_cls_novo ( ws.clscod
                      ,ws.clcdat
                      ,ws.cvnnum
                      ,ws.cbtcod
                      ,ws.ctgtrfcod
                      ,ws.clalclcod
                      ,ws.vclmrccod
                      ,ws.vcltipcod
                      ,param.vclcoddig
                      ,param.vclanomdl
                      ,0
                      ,0)
            returning ws.clscndvlr
                     ,ws.clscndreivlr
                     ,d_cts19m04.vdrpbsfrqvlr
                     ,ws.clscndvlr
                     ,ws.clscndreivlr
                     ,ws.frqvlr
                     ,ws.clscndvlr
                     ,ws.clscndreivlr
                     ,ws.frqvlrfarois

     else

          call figrc072_setTratarIsolamento()        --> 223689
          
          if g_vdr_blindado = "S" then ## PSI 239.399 Clausula 77
             select clsdes into l_nulo
               from aackcls
              where tabnum =( select max(a.tabnum) from aackcls a
                               where a.ramcod = 531
                                 and a.clscod = ws.clscod )
                and ramcod = 531
                and clscod = ws.clscod
          end if ## PSI 239.399 Clausula 77          
          call faemc464(g_documento.prporg
                        ,g_documento.prpnumdig
                        ,g_documento.prporg
                        ,g_documento.prpnumdig
                        ,g_documento.succod
                        ,g_documento.aplnumdig
                        ,g_documento.itmnumdig
                        ,g_funapol.dctnumseq
                        ,ws.clscod
                        ,l_nulo
                        ,l_abrir )  ## 'N') # PSI 239.399 Clausula 77
          returning  d_cts19m04.vdrpbsfrqvlr
                    ,ws.frqvlr
                    ,ws.frqvlrfarois

          if g_isoAuto.sqlCodErr <> 0 then --> 223689
               error "Função faemc464 indisponivel no momento ! Avise a Informatica !" sleep 2
               let w_erro = 1
               exit while
          end if    --> 223689

     end if
     
     let d_cts19m04.vdrvgafrqvlr = d_cts19m04.vdrpbsfrqvlr
     if ws.clscod = "077" then # PSI 239.399 Clausula 077
        let d_cts19m04.vdrvgafrqvlr = 0
        let d_cts19m04.vdrlatfrqvlr = 0
        let d_cts19m04.vdrpbsfrqvlr = 0
     end if
     if d_cts19m04.vdrpbsfrqvlr is null then
        error " Valor de franquia do para-brisa/vigia nao encontrado",
              " para vigencia " , ws.clcdat, "! AVISE A INFORMATICA!"
        prompt "" for char prompt_key
        let w_erro = 1
        exit while
     else

        if ws.clscod = "071" then
           let d_cts19m04.vdrlatfrqvlr = ws.frqvlr
           let d_cts19m04.vdrrtrfrqvlr = null
           initialize d_cts19m04.vdrrtrtxt to null
        else
           if ws.clscod = "075" or
              ws.clscod = "75R" then
              let d_cts19m04.vdrlatfrqvlr = 0
              let d_cts19m04.vdrrtrfrqvlr = ws.frqvlr
              let d_cts19m04.vdrrtrtxt    = "Retrovisor...:"
           else
              if ws.clscod = "076" or
                 ws.clscod = "76R" then
                 let d_cts19m04.vdrlatfrqvlr = 0
                 let d_cts19m04.vdrrtrfrqvlr = ws.frqvlr
                 let d_cts19m04.farolnfrqvlr = ws.frqvlrfarois # VLR. FRANQUIA FAROL
                 let d_cts19m04.farmilfrqvlr = ws.frqvlrfarois # VLR. FRANQUIA FAROL MILHA
                 let d_cts19m04.farnebfrqvlr = ws.frqvlrfarois # VLR. FRANQUIA FAROL NEBLINA
                 let d_cts19m04.farpiscaqvlr = ws.frqvlrfarois # VLR. FRANQUIA PISCA
                 let d_cts19m04.farlanteqvlr = ws.frqvlrfarois # VLR. FRANQUIA LANTERNA

                 let d_cts19m04.vdrrtrtxt       = "Retrovisor...:"
                 let d_cts19m04.txtfarol        = "Farol........:"
                 let d_cts19m04.txtfarolmilha   = "Farol milha..:"
                 let d_cts19m04.txtfarolneblina = "Farol neblina:"
                 let d_cts19m04.txtpisca        = "Pisca........:"
                 let d_cts19m04.txtlanterna     = "Lanterna.....:"
              end if
           end if
              if ws.clscod = "071" then
                 let d_cts19m04.vdrlatfrqvlr = ws.frqvlr
                 let d_cts19m04.vdrrtrfrqvlr = null
                 initialize d_cts19m04.vdrrtrtxt to null
              end if
        end if

        let d_cts19m04.vdrocufrqvlr = d_cts19m04.vdrlatfrqvlr
        let d_cts19m04.vdrqbvfrqvlr = 0


        # -- OSF 9377 - Fabrica de Software, Katiucia -- #
        let d_aux19m04.vdresqfrqvlr  =  d_cts19m04.vdrlatfrqvlr
        let d_aux19m04.vdrdirfrqvlr  =  d_cts19m04.vdrlatfrqvlr

        let d_aux19m04.ocuesqfrqvlr  =  d_cts19m04.vdrocufrqvlr
        let d_aux19m04.ocudirfrqvlr  =  d_cts19m04.vdrocufrqvlr

        let d_aux19m04.esqrtrfrqvlr  =  d_cts19m04.vdrrtrfrqvlr
        let d_aux19m04.dirrtrfrqvlr  =  d_cts19m04.vdrrtrfrqvlr

     end if

     initialize ws.msgtxt to null

     if d_cts19m04.vdrpbsfrqvlr is null then
       #let ws.msgtxt = "VALOR FRANQUIA DO PARA-BRISA/VIGIA NAO ENCONTRADO!"
        let ws.msgtxt = "FRANQUIA PARA-BRISA/VIGIA NAO ENCONTRADO"
     end if
     if d_cts19m04.vdrlatfrqvlr is null  then
       #let ws.msgtxt = "VALOR FRANQUIA DOS VIDROS LATERAIS NAO ENCONTRADO!"
        let ws.msgtxt = "FRANQUIA VIDROS LATERAIS NAO ENCONTRADO!"
     end if

     if ws.msgtxt is not null  then
        call cts08g01("A","N","NAO E' POSSIVEL SOLICITAR REPARO!",
                      "",ws.msgtxt,"") returning ws.confirma
        let w_erro = 1
        exit while
     end if
     exit while
    end while

    if w_erro = 1 then
       let int_flag = false
       close window w_cts19m04
       return "","","","","","","","","","","","","","","","","","","",
              "","","","","","","","","","",""
    end if

    #-------------------------------------
    # Exibe dados na tela
    #-------------------------------------
    
    
    let d_cts19m04.obs = "(F8)Ver Saldo"
    
     display by name d_cts19m04.*

     input by name d_cts19m04.prbrisa,
                   d_cts19m04.traseiro,
                   d_cts19m04.lateral,
                   d_cts19m04.oculo,
                   d_cts19m04.qvent,
                   d_cts19m04.retrovisor,
                   d_cts19m04.farol,
                   d_cts19m04.farolmilha,
                   d_cts19m04.farolneblina,
                   d_cts19m04.pisca,
                   d_cts19m04.lanterna without defaults

        # PARA-BRISA
        before field prbrisa
           display by name d_cts19m04.prbrisa attribute (reverse)

        after field prbrisa
           display by name d_cts19m04.prbrisa

           if d_cts19m04.prbrisa is not null and
              d_cts19m04.prbrisa <> "X"      then
              error "Marque um  X em uma das Franquias"
              next field prbrisa
           end if

        # TRASEIRO
        before field traseiro
           display by name d_cts19m04.traseiro attribute (reverse)

        after field traseiro
           display by name d_cts19m04.traseiro

           if d_cts19m04.traseiro is not null and
              d_cts19m04.traseiro <> "X"      then
              error "Marque um  X em uma das Franquias"
              next field traseiro
           end if

        # LATERAL
        before field lateral
           display by name d_cts19m04.lateral attribute (reverse)

        after field lateral
           display by name d_cts19m04.lateral

           if not cts19m04_infor_certo(d_cts19m04.lateral) then
              error "Informe D para Direito, E para Esquerdo ou A para Ambos"
              next field lateral
           end if

        # OCULO
        before field oculo
             display by name d_cts19m04.oculo attribute (reverse)

        after field oculo
           display by name d_cts19m04.oculo

           if not cts19m04_infor_certo(d_cts19m04.oculo) then
              error "Informe D para Direito, E para Esquerdo ou A para Ambos"
              next field oculo
           end if

        # QUEBRA VENTO
        before field qvent
           display by name d_cts19m04.qvent attribute (reverse)

        after field qvent
           display by name d_cts19m04.qvent

           if d_cts19m04.qvent   is not null and
              d_cts19m04.qvent   <> "X"      then
              error "Marque um X em uma das Franquias"
              next field qvent
           end if

        # RETROVISOR
        before field retrovisor
           if ws.clscod = "071" then
              exit input
           end if

           display by name d_cts19m04.retrovisor attribute (reverse)

        after field retrovisor
           display by name d_cts19m04.retrovisor

           if not cts19m04_infor_certo(d_cts19m04.retrovisor) then
              error "Informe D para Direito, E para Esquerdo ou A para Ambos"
              next field retrovisor
           end if

        # FAROL
        before field farol
           display by name d_cts19m04.farol attribute (reverse)

        after field farol
           display by name d_cts19m04.farol

           if not cts19m04_infor_certo(d_cts19m04.farol) then
              error "Informe D para Direito, E para Esquerdo ou A para Ambos"
              next field farol
           end if

        # FAROL MILHA
        before field farolmilha
           display by name d_cts19m04.farolmilha attribute (reverse)

        after field farolmilha
           display by name d_cts19m04.farolmilha

           if not cts19m04_infor_certo(d_cts19m04.farolmilha) then
              error "Informe D para Direito, E para Esquerdo ou A para Ambos"
              next field farolmilha
           end if

        # FAROL NEBLINA
        before field farolneblina
           display by name d_cts19m04.farolneblina attribute (reverse)

        after field farolneblina
           display by name d_cts19m04.farolneblina

           if not cts19m04_infor_certo(d_cts19m04.farolneblina) then
              error "Informe D para Direito, E para Esquerdo ou A para Ambos"
              next field farolneblina
           end if

        # PISCA
        before field pisca
           display by name d_cts19m04.pisca attribute (reverse)

        after field pisca
           display by name d_cts19m04.pisca

           if not cts19m04_infor_certo(d_cts19m04.pisca) then
              error "Informe D para Direito, E para Esquerdo ou A para Ambos"
              next field pisca
           end if

        # LANTERNA
        before field lanterna
           display by name d_cts19m04.lanterna attribute (reverse)

        after field lanterna
           display by name d_cts19m04.lanterna

           if not cts19m04_infor_certo(d_cts19m04.lanterna) then
              error "Informe D para Direita, E para Esquerda ou A para Ambas"
              next field lanterna
           end if

         on key (F8)            
                      
           if g_documento.c24astcod = 'B14' or 
              g_documento.acao = "ALT"  or      
              g_documento.acao = "CON"  then                          
              call cts19m04_saldo (ws.clscod)           
           else
              error "FUNCAO (F8) NAO DISPONIVEL PARA ESSE ASSUNTO !"
              sleep 2 
           end if    
         
         on key (interrupt)
             let int_flag = true
             exit input

     end input

     # PARA-BRISA
     if d_cts19m04.prbrisa =  "X"  then
        let ws.pbrfrqvlr   =  d_cts19m04.vdrpbsfrqvlr
     else
        let ws.pbrfrqvlr   =  null
     end if

     # TRASEIRO
     if d_cts19m04.traseiro = "X"  then
        let ws.vigfrqvlr    =  d_cts19m04.vdrvgafrqvlr
     else
        let ws.vigfrqvlr    = null
     end if

     # LATERAL
     if d_cts19m04.lateral = "D" or
        d_cts19m04.lateral = "A" then
        let ws.vllatdir    =  d_aux19m04.vdrdirfrqvlr
     end if

     if d_cts19m04.lateral = "E" or
        d_cts19m04.lateral = "A" then
        let ws.latfrqvlr   =  d_aux19m04.vdresqfrqvlr
     end if

     if d_cts19m04.lateral <> "D" and
        d_cts19m04.lateral <> "E" and
        d_cts19m04.lateral <> "A" then
        let ws.vllatdir  = null
        let ws.latfrqvlr = null
     end if

     # OCULO
     if d_cts19m04.oculo = "D" or
        d_cts19m04.oculo = "A" then
        let ws.vlocudir  =  d_aux19m04.ocudirfrqvlr
     end if

     if d_cts19m04.oculo = "E" or
        d_cts19m04.oculo = "A" then
        let ws.vlocuesq  =  d_aux19m04.ocuesqfrqvlr
     end if

     if d_cts19m04.oculo <> "D" and
        d_cts19m04.oculo <> "E" and
        d_cts19m04.oculo <> "A" then
        let ws.vlocudir  = null
        let ws.vlocuesq  = null
     end if

     # QUEBRA VENTO
     if d_cts19m04.qvent = "X" then
        let ws.vlqvento = d_cts19m04.vdrqbvfrqvlr
     else
        let ws.vlqvento  = null
     end if

     # RETROVISOR
     if d_cts19m04.retrovisor = "D" or
        d_cts19m04.retrovisor = "A" then
        let ws.vlrtrdir = d_aux19m04.dirrtrfrqvlr
     end if

     if d_cts19m04.retrovisor = "E" or
        d_cts19m04.retrovisor = "A" then
        let ws.vlrtresq = d_aux19m04.esqrtrfrqvlr
     end if

     if d_cts19m04.retrovisor <> "D" and
        d_cts19m04.retrovisor <> "E" and
        d_cts19m04.retrovisor <> "A" then
        let ws.vlrtrdir = null
        let ws.vlrtresq = null
     end if

     # FAROL
     if d_cts19m04.farol = "D" or
        d_cts19m04.farol = "A" then
        let ws.vlrfardir = d_cts19m04.farolnfrqvlr
     end if

     if d_cts19m04.farol = "E" or
        d_cts19m04.farol = "A" then
        let ws.vlrfaresq = d_cts19m04.farolnfrqvlr
     end if

     if d_cts19m04.farol <> "D" and
        d_cts19m04.farol <> "E" and
        d_cts19m04.farol <> "A" then
        let ws.vlrfardir = null
        let ws.vlrfaresq = null
     end if

     # FAROL MILHA
     if d_cts19m04.farolmilha = "D" or
        d_cts19m04.farolmilha = "A" then
        let ws.vlrfarmidir = d_cts19m04.farmilfrqvlr
     end if

     if d_cts19m04.farolmilha = "E" or
        d_cts19m04.farolmilha = "A" then
        let ws.vlrfarmiesq = d_cts19m04.farmilfrqvlr
     end if

     if d_cts19m04.farolmilha <> "D" and
        d_cts19m04.farolmilha <> "E" and
        d_cts19m04.farolmilha <> "A" then
        let ws.vlrfarmidir = null
        let ws.vlrfarmiesq = null
     end if

     # FAROL NEBLINA
     if d_cts19m04.farolneblina = "D" or
        d_cts19m04.farolneblina = "A" then
        let ws.vlrfarnedir = d_cts19m04.farnebfrqvlr
     end if

     if d_cts19m04.farolneblina = "E" or
        d_cts19m04.farolneblina = "A" then
        let ws.vlrfarneesq = d_cts19m04.farnebfrqvlr
     end if

     if d_cts19m04.farolneblina <> "D" and
        d_cts19m04.farolneblina <> "E" and
        d_cts19m04.farolneblina <> "A" then
        let ws.vlrfarneesq = null
        let ws.vlrfarnedir = null
     end if

     # PISCA
     if d_cts19m04.pisca = "D" or
        d_cts19m04.pisca = "A" then
        let ws.vlrpiscadir = d_cts19m04.farpiscaqvlr
     end if

     if d_cts19m04.pisca = "E" or
        d_cts19m04.pisca = "A" then
        let ws.vlrpiscaesq = d_cts19m04.farpiscaqvlr
     end if

     if d_cts19m04.pisca <> "D" and
        d_cts19m04.pisca <> "E" and
        d_cts19m04.pisca <> "A" then
        let ws.vlrpiscadir = null
        let ws.vlrpiscaesq = null
     end if

     # LANTERNA
     if d_cts19m04.lanterna = "D" or
        d_cts19m04.lanterna = "A" then
        let ws.vlrlantedir = d_cts19m04.farlanteqvlr
     end if

     if d_cts19m04.lanterna = "E" or
        d_cts19m04.lanterna = "A" then
        let ws.vlrlanteesq = d_cts19m04.farlanteqvlr
     end if

     if d_cts19m04.lanterna <> "D" and
        d_cts19m04.lanterna <> "E" and
        d_cts19m04.lanterna <> "A" then
        let ws.vlrlanteesq = null
        let ws.vlrlantedir = null
     end if

     close window w_cts19m04
     let int_flag = false
      

     return d_cts19m04.vdrpbsfrqvlr,
            d_cts19m04.vdrvgafrqvlr,
            d_aux19m04.vdrdirfrqvlr,
            d_aux19m04.vdresqfrqvlr,
            d_aux19m04.ocudirfrqvlr,
            d_aux19m04.ocuesqfrqvlr,
            d_cts19m04.vdrqbvfrqvlr,
            d_aux19m04.dirrtrfrqvlr,
            d_aux19m04.esqrtrfrqvlr,
            ws.pbrfrqvlr,
            ws.vigfrqvlr,
            ws.vllatdir,
            ws.latfrqvlr,
            ws.vlocudir,
            ws.vlocuesq,
            ws.vlqvento,
            ws.vlrtrdir,
            ws.vlrtresq,
            ws.vlrfardir,
            ws.vlrfaresq,
            ws.vlrfarmidir,
            ws.vlrfarmiesq,
            ws.vlrfarnedir,
            ws.vlrfarneesq,
            ws.vlrpiscadir,
            ws.vlrpiscaesq,
            ws.vlrlantedir,
            ws.vlrlanteesq,
            ws.frqvlrfarois,
            ws.clscod

 end function

#------------------------------------#
function cts19m04_infor_certo(l_opcao)
#------------------------------------#

  # FUNCAO PARA VERIFICAR SE O USUARIO INFORMOU O VALOR
  # CORRETO "E", "D" ou "A"

  define l_opcao           char(01),
         l_informou_certo  smallint

  let l_informou_certo = true

  if l_opcao is not null and
     l_opcao <> "D" and   # DIREITO
     l_opcao <> "E" and   # ESQUERDO
     l_opcao <> "A" then  # AMBOS
     let l_informou_certo = false
  end if

  return l_informou_certo

end function

function cts19m04_saldo(lr_param)

   define lr_param record 
        clscod like aackcls.clscod
   end record     
   

   define lr_limite record
       pbsvig    char(3),
       lateral   char(3),
       retrov    char(3),
       farol     char(3),
       laterna   char(3)
    end record
    
    define lr_saldo record
        pbsvig    char(3), 
        lateral   char(3), 
        retrov    char(3), 
        farol     char(3), 
        laterna   char(3),
        saldo_71  char(3)  
    end record            
    
    define lr_execedido record
        pbsvig    char(3), 
        lateral   char(3), 
        retrov    char(3), 
        farol     char(3), 
        laterna   char(3),
        saldo_71  char(3)  
    end record            
    
    define lr_retorno record 
       pbrfrqvlr       like aacmclscnd.frqvlr,
       vigfrqvlr       like aacmclscnd.frqvlr,
       latfrqvlr       like aacmclscnd.frqvlr,
       vllatdir        like aacmclscnd.frqvlr,
       vlocuesq        like aacmclscnd.frqvlr,
       vlocudir        like aacmclscnd.frqvlr,
       vlqvento        like aacmclscnd.frqvlr,
       vlrtrdir        like aacmclscnd.frqvlr,
       vlrtresq        like aacmclscnd.frqvlr,
       vlrfardir       like aacmclscnd.frqvlr,
       vlrfaresq       like aacmclscnd.frqvlr,
       vlrfarmidir     like aacmclscnd.frqvlr,
       vlrfarmiesq     like aacmclscnd.frqvlr,
       vlrfarneesq     like aacmclscnd.frqvlr,
       vlrfarnedir     like aacmclscnd.frqvlr,
       vlrpiscadir     like aacmclscnd.frqvlr,
       vlrpiscaesq     like aacmclscnd.frqvlr,
       vlrlanteesq     like aacmclscnd.frqvlr,
       vlrlantedir     like aacmclscnd.frqvlr    
    end record     
            
    
    define aux_cts19m04a array[10] of record         
           vidro      char(25),
           saldo      smallint,
           execedido  smallint             
    end record
    define arr_aux       smallint,
           arr_cou       smallint               
    for  arr_aux  =  1  to  10
      initialize  aux_cts19m04a[arr_aux].* to  null       
    end  for 
        
    let arr_aux = null  
    let arr_cou = null      
    initialize lr_retorno.* to null 
    initialize lr_execedido.* to null 
    initialize lr_limite.* to null 
    initialize lr_saldo.* to null 
        
        
    let m_pbsvig   = 0                                                                      
    let m_lateral  = 0                                                                      
    let m_retrov   = 0                                                                      
    let m_farol    = 0                                                                      
    let m_laternas = 0  
    
    call cts19m08_buscalimite(lr_param.clscod)
          returning lr_limite.*     
                    
    call cts19m04_verifica_vidros()
    returning lr_retorno.*
    
    call cts19m08_verifica_saldo(lr_param.clscod,
                                lr_retorno.pbrfrqvlr,  
                                lr_retorno.vigfrqvlr,  
                                lr_retorno.vllatdir,   
                                lr_retorno.latfrqvlr,  
                                lr_retorno.vlocudir,   
                                lr_retorno.vlocuesq,                              
                                lr_retorno.vlrtrdir,   
                                lr_retorno.vlrtresq,   
                                lr_retorno.vlrfardir,  
                                lr_retorno.vlrfaresq,  
                                lr_retorno.vlrfarmidir,
                                lr_retorno.vlrfarmiesq,
                                lr_retorno.vlrfarnedir,
                                lr_retorno.vlrfarneesq,
                                lr_retorno.vlrpiscadir,
                                lr_retorno.vlrpiscaesq,
                                lr_retorno.vlrlantedir,
                                lr_retorno.vlrlanteesq )   
    returning m_pbsvig  ,
              m_lateral ,
              m_retrov  ,
              m_farol   ,
              m_laternas 
              
   
   let m_utiliz = m_pbsvig + m_lateral + m_retrov + m_farol + m_laternas                                                                                                
   
   let lr_saldo.saldo_71 = lr_limite.pbsvig - m_utiliz 
   
   let lr_saldo.pbsvig   = lr_limite.pbsvig  - m_pbsvig                                     
   let lr_saldo.lateral  = lr_limite.lateral - m_lateral                                    
   let lr_saldo.retrov   = lr_limite.retrov  - m_retrov                                     
   let lr_saldo.farol    = lr_limite.farol   - m_farol                                      
   let lr_saldo.laterna  = lr_limite.laterna - m_laternas                                   

   let lr_execedido.pbsvig   = m_pbsvig   - lr_limite.pbsvig  
   let lr_execedido.lateral  = m_lateral  - lr_limite.lateral 
   let lr_execedido.retrov   = m_retrov   - lr_limite.retrov  
   let lr_execedido.farol    = m_farol    - lr_limite.farol   
   let lr_execedido.laterna  = m_laternas - lr_limite.laterna 
   let lr_execedido.saldo_71 = m_utiliz    - lr_limite.pbsvig 
   if lr_saldo.pbsvig < 0 then 
      let lr_saldo.pbsvig = 0 
   end if    
   
   if lr_saldo.lateral < 0 then 
      let lr_saldo.lateral = 0 
   end if    
   
   if lr_saldo.retrov < 0 then 
      let lr_saldo.retrov = 0 
   end if    
   
   if lr_saldo.farol < 0 then 
      let lr_saldo.farol = 0 
   end if    
   
   if lr_saldo.laterna < 0 then 
      let lr_saldo.laterna = 0 
   end if  
   
   if lr_saldo.saldo_71 < 0 then 
      let lr_saldo.saldo_71 = 0  
   end if                          
   
   # Execedido 
   if lr_execedido.pbsvig < 0 then 
      let lr_execedido.pbsvig = 0 
   end if    
   
   if lr_execedido.lateral < 0 then 
      let lr_execedido.lateral = 0 
   end if    
   
   if lr_execedido.retrov < 0 then 
      let lr_execedido.retrov = 0 
   end if    
   
   if lr_execedido.farol < 0 then 
      let lr_execedido.farol = 0 
   end if    
   
   if lr_execedido.laterna < 0 then 
      let lr_execedido.laterna = 0 
   end if  
   
   if lr_execedido.saldo_71 < 0 then 
      let lr_execedido.saldo_71 = 0  
   end if                      
   
   if lr_param.clscod = 71 or                    
      lr_param.clscod = 77 then                  
      let arr_cou = 1                     
      let aux_cts19m04a[1].vidro      = "Vidros..............:"
      let aux_cts19m04a[1].saldo      = lr_saldo.saldo_71 
      let aux_cts19m04a[1].execedido  = lr_execedido.saldo_71 
      
   else           
      let aux_cts19m04a[1].vidro       = "Para-brisa/vigia....:"
      let aux_cts19m04a[1].saldo       = lr_saldo.pbsvig
      let aux_cts19m04a[1].execedido   = lr_execedido.pbsvig      
      let aux_cts19m04a[2].vidro       = "Lateral/oculo.......:"
      let aux_cts19m04a[2].saldo       = lr_saldo.lateral
      let aux_cts19m04a[2].execedido   = lr_execedido.lateral
      let aux_cts19m04a[3].vidro       = "Retrovisores........:"
      let aux_cts19m04a[3].saldo       = lr_saldo.retrov
      let aux_cts19m04a[3].execedido   = lr_execedido.retrov
      let aux_cts19m04a[4].vidro       = "Farol/neblina/milha.:"
      let aux_cts19m04a[4].saldo       =  lr_saldo.farol   
      let aux_cts19m04a[4].execedido   = lr_execedido.farol                     
      let aux_cts19m04a[5].vidro       = "Lanterna/Pisca......:"
      let aux_cts19m04a[5].saldo       = lr_saldo.laterna         
      let aux_cts19m04a[5].execedido   = lr_execedido.laterna   
   end if    
     open window w_cts19m04a at 06,35 with form "cts19m04a"
               attribute(form line 1, border)
   
     let int_flag = false        
       
     message "(F17)Abandona"        
                                              
   if (lr_param.clscod  = 75  or lr_param.clscod  = "75R" ) then      
       
       let arr_cou = 3       
       for  arr_aux  =  4  to  5
          initialize  aux_cts19m04a[arr_aux].* to  null       
       end  for        
   end if 
   if (lr_param.clscod  = 76  or lr_param.clscod  = "76R" ) then         
      let arr_cou = 5                  
   end if    
       
          
   
   display by name lr_param.clscod   
   call set_count(arr_cou)
   display array aux_cts19m04a to s_cts19m04a.* 
      
      on key (interrupt,control-c,f17)       
         exit display                             
   
   end display    
   
   close window  w_cts19m04a
      
   let int_flag = false       
   
   return 
                         
end function            

function cts19m04_verifica_vidros()

    define lr_retorno record 
       pbrfrqvlr       like aacmclscnd.frqvlr,
       vigfrqvlr       like aacmclscnd.frqvlr,
       latfrqvlr       like aacmclscnd.frqvlr,
       vllatdir        like aacmclscnd.frqvlr,
       vlocuesq        like aacmclscnd.frqvlr,
       vlocudir        like aacmclscnd.frqvlr,
       vlqvento        like aacmclscnd.frqvlr,
       vlrtrdir        like aacmclscnd.frqvlr,
       vlrtresq        like aacmclscnd.frqvlr,
       vlrfardir       like aacmclscnd.frqvlr,
       vlrfaresq       like aacmclscnd.frqvlr,
       vlrfarmidir     like aacmclscnd.frqvlr,
       vlrfarmiesq     like aacmclscnd.frqvlr,
       vlrfarneesq     like aacmclscnd.frqvlr,
       vlrfarnedir     like aacmclscnd.frqvlr,
       vlrpiscadir     like aacmclscnd.frqvlr,
       vlrpiscaesq     like aacmclscnd.frqvlr,
       vlrlanteesq     like aacmclscnd.frqvlr,
       vlrlantedir     like aacmclscnd.frqvlr    
    end record 
   

    initialize lr_retorno.* to null 



     # PARA-BRISA
     if d_cts19m04.prbrisa =  "X"  then
        let lr_retorno.pbrfrqvlr   =  d_cts19m04.vdrpbsfrqvlr
     else
        let lr_retorno.pbrfrqvlr   =  null
     end if

     # TRASEIRO
     if d_cts19m04.traseiro = "X"  then
        let lr_retorno.vigfrqvlr    =  d_cts19m04.vdrvgafrqvlr
     else
        let lr_retorno.vigfrqvlr    = null
     end if

     # LATERAL
     if d_cts19m04.lateral = "D" or
        d_cts19m04.lateral = "A" then
        let lr_retorno.vllatdir    =  d_aux19m04.vdrdirfrqvlr
     end if

     if d_cts19m04.lateral = "E" or
        d_cts19m04.lateral = "A" then
        let lr_retorno.latfrqvlr   =  d_aux19m04.vdresqfrqvlr
     end if


     # OCULO
     if d_cts19m04.oculo = "D" or
        d_cts19m04.oculo = "A" then
        let lr_retorno.vlocudir  =  d_aux19m04.ocudirfrqvlr
     end if

     if d_cts19m04.oculo = "E" or
        d_cts19m04.oculo = "A" then
        let lr_retorno.vlocuesq  =  d_aux19m04.ocuesqfrqvlr
     end if



     # RETROVISOR
     if d_cts19m04.retrovisor = "D" or
        d_cts19m04.retrovisor = "A" then
        let lr_retorno.vlrtrdir = d_aux19m04.dirrtrfrqvlr
     end if

     if d_cts19m04.retrovisor = "E" or
        d_cts19m04.retrovisor = "A" then
        let lr_retorno.vlrtresq = d_aux19m04.esqrtrfrqvlr
     end if



     # FAROL
     if d_cts19m04.farol = "D" or
        d_cts19m04.farol = "A" then
        let lr_retorno.vlrfardir = d_cts19m04.farolnfrqvlr
     end if

     if d_cts19m04.farol = "E" or
        d_cts19m04.farol = "A" then
        let lr_retorno.vlrfaresq = d_cts19m04.farolnfrqvlr
     end if



     # FAROL MILHA
     if d_cts19m04.farolmilha = "D" or
        d_cts19m04.farolmilha = "A" then
        let lr_retorno.vlrfarmidir = d_cts19m04.farmilfrqvlr
     end if

     if d_cts19m04.farolmilha = "E" or
        d_cts19m04.farolmilha = "A" then
        let lr_retorno.vlrfarmiesq = d_cts19m04.farmilfrqvlr
     end if
     

     # FAROL NEBLINA
     if d_cts19m04.farolneblina = "D" or
        d_cts19m04.farolneblina = "A" then
        let lr_retorno.vlrfarnedir = d_cts19m04.farnebfrqvlr
     end if

     if d_cts19m04.farolneblina = "E" or
        d_cts19m04.farolneblina = "A" then
        let lr_retorno.vlrfarneesq = d_cts19m04.farnebfrqvlr
     end if

     # PISCA
     if d_cts19m04.pisca = "D" or
        d_cts19m04.pisca = "A" then
        let lr_retorno.vlrpiscadir = d_cts19m04.farpiscaqvlr
     end if

     if d_cts19m04.pisca = "E" or
        d_cts19m04.pisca = "A" then
        let lr_retorno.vlrpiscaesq = d_cts19m04.farpiscaqvlr
     end if
     

     # LANTERNA
     if d_cts19m04.lanterna = "D" or
        d_cts19m04.lanterna = "A" then
        let lr_retorno.vlrlantedir = d_cts19m04.farlanteqvlr
     end if

     if d_cts19m04.lanterna = "E" or
        d_cts19m04.lanterna = "A" then
        let lr_retorno.vlrlanteesq = d_cts19m04.farlanteqvlr
     end if     

     return lr_retorno.*




end function

#--------------------------------------------------------------------------#
function cts19m04_item_proposta(p_prporg,p_prpnumdig)
#--------------------------------------------------------------------------#
# retorna a quantidade de itens da proposta
   
   define p_prporg like apamcapa.prporgpcp,
          p_prpnumdig like apamcapa.prpnumpcp,
          l_qtditens smallint 
   
   let l_qtditens = 0       
          
   declare ccts19m04_item cursor for
   select prpqtditm 
     from apamcapa
    where prporgpcp = p_prporg
      and prpnumpcp = p_prpnumdig
   
   open ccts19m04_item 
      whenever error continue 
      fetch ccts19m04_item into l_qtditens
      whenever error stop 
   close ccts19m04_item 
 
   return l_qtditens
   
end function