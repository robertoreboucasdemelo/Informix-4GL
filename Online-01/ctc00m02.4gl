###############################################################################
# Nome do Modulo: CTC00M02                                              Pedro #
#                                                                             #
# Manutencao no Cadastro de Prestadores (Porto Socorro)              Mar/1995 #
############################################################################### 
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 10/12/1999  PSI 9637-7   Wagner       Incluir opcao para o preenchimento dos#
#                                       campos e-mail e codigo cronograma.    #
#-----------------------------------------------------------------------------#
# 09/03/2000  PSI 10181-8  Wagner       Incluir manutencao do novo campo tipo #
#                                       cooperativa.                          #
#-----------------------------------------------------------------------------#
# 14/09/2000  PSI 11575-4  Raji         Incluido para o campo qualidade o aces#
#                                       so na iddkdominio.                    #
#-----------------------------------------------------------------------------#
# 29/09/2000  PSI 10475-2  Wagner       Inclusao da gravacao do codigo da ci_ #
#                                       dade que esta no MAPA(datkmpacid).    #
#-----------------------------------------------------------------------------#
# 28/-3/2001  PSI 12758-2  Wagner       Inclusao novo status (PROPOSTA) para  #
#                                       o prestador.                          #
#-----------------------------------------------------------------------------#
# 04/06/2001  PSI 13253-5  Wagner       Inclusao nova situacao prestador      #
#                                       B-Bloqueado.                          #
#-----------------------------------------------------------------------------#
# 22/08/2001  PSI 136220   Ruiz         Adaptacao para servicos acionado via  #
#                                       internet.                             #
#-----------------------------------------------------------------------------#
# 07/05/2002  PSI 15053-3  Wagner       Inclusao do novo campo tabela precos  #
#                                       para RE.                              #
#-----------------------------------------------------------------------------#
# 05/02/2003  CT 276121    Wagner       Correcao returno funcao tarifa RE     #
#-----------------------------------------------------------------------------#
# 02/04/2003  CT 197475    Paula        Alterar campo "Outras Cias" p/        #
#                                                     "Forma Pagto"           #
#-----------------------------------------------------------------------------#
#     Data      Autor Fabrica   Origem  Alteracao                             #
#   ----------  -------------  -------- --------------------------------------#
#  06/12/2004   Adriana-Meta    188220  Somente permitir alteração de alguns  #
#                                       campos, para os departamentos         #
#                                       Porto Socorro e Desenv.Sistemas.      #
#                                                                             #
#  15/03/2005   Vinicius, Meta  188751  Preencher o laudo RIS no Portal de    #
#                                       Negocios.                             #
#-----------------------------------------------------------------------------#
#  27/04/2006   Priscila      PSI198714 Tipos de assistencia para o prestador #
#-----------------------------------------------------------------------------#
#  21/06/2006   Priscila      PSI197858 DDD e celular do Prestador p/ SMS     #
#                                       menu Situacao e Historico             #
#  17/11/2006   Priscila      PSI205206 menu "Empresa"                        #
#-----------------------------------------------------------------------------#
#  14/06/2007   Fabiano       PSI209953 Gravar historico de alteracoes Prest. #
#-----------------------------------------------------------------------------#
#  24/07/2008  Douglas,Meta  PSI226300 Controle por e-mail sobre alteracao,   #
#                                       inclusao e exclusao dos cadastros     #
#-----------------------------------------------------------------------------#
# 31/03/2009 CT 684821  Fabio Costa  Acertar merge nao realizado na ultima    #
#                                    versao, cadastro de PIS, NIT, sucursal   #
#                                    Merge com todas as versoes anteriores    #
# 25/05/2009 PSI 198404 Fabio Costa  Obrigar inscricao municipal no cadastro  #
#                                    de prestador PJ, sugerir sucursal        #
# 29/06/2009 PSI 198404 Fabio Costa  Incluir cadastro de atividade principal  #
# 24/07/2009 PSI 242853 Adriano San  Incluir cadastro de natureza X prestador #
# 26/02/2010 PSI 198404 Fabio Costa  Incluir cadastro de optante pelo simples #
# 25/05/2010 PSI 257206 Robert Lima  Gravar historico a alteracao do respon.  #
# 20/08/2010 PSI 259136 Robert Lima  Atendendo a circualr 380 foi colocado o  #
#                                    cadastro de responsaveis.                #
# 14/09/2010 PSI 00009EV Robert Lima Alteração da chamada na tela de cpf já   #
#                                    cadastrado e adição da cadeia de gestao  #
# 18/11/2010 PSI 00009EV Robert Lima Alterado o returning da chamada do       #
#                                    ctc00m20                                 #
# 26/10/2011            Celso Yamahaki Chamada de funcao que limpa os campos  #
#                                      String antes de cadastras/atualizar    #
# 25/05/2012  Jose Kurihara  PSI-11-19199PR bloquear alteracao do campo de    #
#                                           flag Optante Simples (via Portal) #
#-----------------------------------------------------------------------------#
# 28/11/2012 Gregorio, Biz PSI-2012-23608 (incluir e alterar) o cadastro do   #
#                                          tipo de endereco dos prestadores.  #
#-----------------------------------------------------------------------------#
# 28/11/2012 PSI-2012-23608 Robert Lima Alterada chamada da tela de endereço  #
#                                       e colocado o insert e update do       #
#                                       endereço após inclusão e alteração do #
#                                       prestador.                            #
#-----------------------------------------------------------------------------#
# 24/01/2013 PSI-2012-23608 Robert Lima Implementada chamada da função do     #
#                                       para atualização da sucursal no       #
#                                       cadastro.                             #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/ffpgc368.4gl"  #Fornax-Quantum
globals "/homedsa/projetos/geral/globals/ffpgc361.4gl" #Fornax-Quantum

define m_res smallint,
       m_msg char(70)
       
define mr_retSAP record                                       
        stt    integer                                     
       ,msg    char(100)                                   
end record       
       
       

#---------------------------------------------
# Rotina principal
#----------------------------------------------

define d_ctc00m02       record
       pstcoddig        like dpaksocor.pstcoddig   ,
       nomrazsoc        like dpaksocor.nomrazsoc   ,
       nomgrr           like dpaksocor.nomgrr      ,
       cgccpfnum        like dpaksocor.cgccpfnum   ,
       cgcord           like dpaksocor.cgcord      ,
       cgccpfdig        like dpaksocor.cgccpfdig   ,
       muninsnum        like dpaksocor.muninsnum   ,
       pestip           like dpaksocor.pestip      ,
       endlgd           like dpaksocor.endlgd      ,
       endcmp           like dpaksocor.endcmp      ,
       endbrr           like dpaksocor.endbrr      ,
       endcid           like dpaksocor.endcid      ,
       endufd           like dpaksocor.endufd      ,
       endcep           like dpaksocor.endcep      ,
       endcepcmp        like dpaksocor.endcepcmp   ,
       pptnom           like dpaksocor.pptnom      ,
       patpprflg        like dpaksocor.patpprflg   ,
       outciatxt        like dpaksocor.outciatxt   ,
       rspnom           like dpaksocor.rspnom      ,
       srvnteflg        like dpaksocor.srvnteflg   ,
       dddcod           like dpaksocor.dddcod      ,
       teltxt           like dpaksocor.teltxt      ,
       faxnum           like dpaksocor.faxnum      ,
       socpgtopccod     like dpaksocorfav.socpgtopccod,
       socpgtopcdes     char(10),
       socfavnom        like dpaksocorfav.socfavnom,
       pestipfav        like dpaksocorfav.pestip,
       cgccpfnumfav     like dpaksocorfav.cgccpfnum,
       cgcordfav        like dpaksocorfav.cgcord,
       cgccpfdigfav     like dpaksocorfav.cgccpfdig,
       bcoctatip        like dpaksocorfav.bcoctatip,
       bcocod           like dpaksocorfav.bcocod,
       bcoagnnum        like dpaksocorfav.bcoagnnum,
       bcoagndig        like dpaksocorfav.bcoagndig,
       bcoctanum        like dpaksocorfav.bcoctanum,
       bcoctadig        like dpaksocorfav.bcoctadig,
       horsegsexinc     like dpaksocor.horsegsexinc,
       horsegsexfnl     like dpaksocor.horsegsexfnl,
       horsabinc        like dpaksocor.horsabinc   ,
       horsabfnl        like dpaksocor.horsabfnl   ,
       hordominc        like dpaksocor.hordominc   ,
       hordomfnl        like dpaksocor.hordomfnl   ,
       qldgracod        like dpaksocor.qldgracod   ,
       qldgrades        char(12)                   ,
       prssitcod        like dpaksocor.prssitcod   ,
       prssitdes        char(09)                   ,
       pstobs           like dpaksocor.pstobs      ,
       prscootipcod     like dpaksocor.prscootipcod,
       prscootipdes     char (09)                  ,
       vlrtabflg        like dpaksocor.vlrtabflg   ,
       rmesoctrfcod     like dpaksocor.rmesoctrfcod,
       soctrfdes_re     like dbsktarifasocorro.soctrfdes,
       atldat           like dpaksocor.atldat      ,
       funmat           like dpaksocor.funmat      ,
       funnom           like isskfunc.funnom       ,
       cmtdat           like dpaksocor.cmtdat      ,
       cmtmatnum        like dpaksocor.cmtmatnum   ,
       cmtnom           like isskfunc.funnom       ,
       mpacidcod        like dpaksocor.mpacidcod   ,
       intsrvrcbflg     like dpaksocor.intsrvrcbflg,
       intdescr         char (08),
       risprcflg        like dpaksocor.risprcflg,
       celdddnum        like dpaksocor.celdddnum,
       celtelnum        like dpaksocor.celtelnum,
       lgdtip           like dpaksocor.lgdtip,
       lgdnum           like dpaksocor.lgdnum,
       lclltt           like datmlcl.lclltt,
       lcllgt           like datmlcl.lcllgt,
       c24lclpdrcod     like datmlcl.c24lclpdrcod,
       frtrpnflg        like dpaksocor.frtrpnflg,
       frtrpndes        char(20),
       pisnum           like dpaksocor.pisnum,
       nitnum           like dpaksocor.nitnum,
       succod           like dpaksocor.succod,
       sucnom           like gabksuc.sucnom,
       pcpatvcod        like dpaksocor.pcpatvcod,
       pcpatvdes        char(30),
       simoptpstflg     like dpaksocor.simoptpstflg,
       pcpprscod        like dpaksocor.pcpprscod,
       gstcdicod        like dpaksocor.gstcdicod,
       nscdat           like dpaksocorfav.nscdat,
       sexcod           like dpaksocorfav.sexcod 
end record

define d_ctc00m02_end   array[10] of record   
       lgdtip           like dpakpstend.lgdtip      #char(10)    
      ,endlgd           like dpakpstend.endlgd      #char(40)     	
      ,lgdnum           like dpakpstend.lgdnum      #decimal(6,0)
      ,lgdcmp           like dpakpstend.lgdcmp      #char(15)    
      ,endbrr           like dpakpstend.endbrr      #char(20)    
      ,endcid           like dpakpstend.endcid      #char(20)    
      ,ufdsgl           like dpakpstend.ufdsgl      #char(2)     
      ,domtipdes        char(40)    
      ,endtipcod        like dpakpstend.endtipcod   #decimal(2)   
      ,endcep           like dpakpstend.endcep      #char(5)     
      ,endcepcmp        like dpakpstend.endcepcmp   #char(3)     
      ,lclltt           like dpakpstend.lclltt      #decimal(8,6)
      ,lcllgt           like dpakpstend.lcllgt      #decimal(9,6)
end record


define ws_resp          like dpatguincho.gchtip

define k_ctc00m02       record
       pstcoddig        like dpaksocor.pstcoddig
end record

define m_dominio record
       erro      smallint  ,
       mensagem  char(100) ,
       cpodes    like iddkdominio.cpodes
end record

define m_prep_sql       smallint,
       m_aux            char(100)

#----------------------------------------------
function ctc00m02_prepare()
#----------------------------------------------
 define l_sql    char(5000)

 let l_sql = " insert into dpaksocor ( pstcoddig   , pptnom      , outciatxt , "
                                    ," rspnom      , patpprflg   , srvnteflg , "
                                    ," horsegsexinc, horsegsexfnl, horsabinc , "
                                    ," horsabfnl   , hordominc   , hordomfnl , "
                                    ," qldgracod   , pstobs      , prssitcod , "
                                    ," nomrazsoc   , nomgrr      , cgccpfnum , "
                                    ," cgcord      , cgccpfdig   , muninsnum , "
                                    ," pestip      , endlgd      , endcmp    , "
                                    ," endbrr      , endcid      , endufd    , "
                                    ," endcep      , endcepcmp   , dddcod    , "
                                    ," teltxt      , faxnum      , atldat    , "
                                    ," funmat      , cmtdat      , cmtmatnum , "
                                    ," vlrtabflg   , prscootipcod, mpacidcod , "
                                    ," intsrvrcbflg, rmesoctrfcod, frtrpnflg , "
                                    ," risprcflg   , celdddnum   , celtelnum , "
                                    ," lgdtip      , lgdnum      , lclltt    , "
                                    ," lcllgt      , c24lclpdrcod, pisnum    , "
                                    ," nitnum      , succod      , pcpatvcod , "
                                    ," simoptpstflg, pcpprscod   , gstcdicod )"
                           ," values ( ?,?,?, ?,?,?, ?,?,?, ?,?,?, ?,?,?, "
                                    ," ?,?,?, ?,?,?, ?,?,?, ?,?,?, ?,?,?, "
                                    ," ?, ?    , today, "
                                    ," ?, today, ?    , "
                                    ," ?,?,?, ?,?,?, ?,?,?, ?,?,?, ?,?,?, "
                                    ," ?,?,?, ?, ?, ? )"
 prepare pctc00m02001 from l_sql 
                                             
 let l_sql = " select pstcoddig   , nomrazsoc   , nomgrr      , "
                   ," cgccpfnum   , cgcord      , cgccpfdig   , "
                   ," muninsnum   , pestip      , endlgd      ,  endcmp   ,"
                   ," endbrr      , endcid      , endufd      , "
                   ," endcep      , endcepcmp   , pptnom      , "
                   ," patpprflg   , outciatxt   , rspnom      , "
                   ," srvnteflg   , dddcod      , teltxt      , "
                   ," faxnum      , horsegsexinc, horsegsexfnl, "
                   ," horsabinc   , horsabfnl   , hordominc   , "
                   ," hordomfnl   , qldgracod   , prssitcod   , "
                   ," pstobs      , vlrtabflg   , atldat      , "
                   ," funmat      , cmtdat      , cmtmatnum   , "
                   ," prscootipcod, intsrvrcbflg, rmesoctrfcod, frtrpnflg,"
                   ," risprcflg   , celdddnum   , celtelnum   , "
                   ," lgdtip      , lgdnum      , lclltt      , "
                   ," lcllgt      , c24lclpdrcod, pisnum      , "
                   ," nitnum      , succod      , pcpatvcod   , "
                   ," simoptpstflg, pcpprscod   , gstcdicod "
            ," from dpaksocor "              
            ," where dpaksocor.pstcoddig = ? "
 prepare pctc00m02002 from l_sql
 declare cctc00m02002 cursor for pctc00m02002

 let l_sql = "update dpaksocor set ( nomrazsoc   , nomgrr      , cgccpfnum, "
                                  ," cgcord      , cgccpfdig   , muninsnum, "
                                  ," pestip      , endlgd      , endcmp   , "
                                  ," endbrr      , endcid      , endufd   , "
                                  ," endcep      , endcepcmp   , dddcod   , "
                                  ," teltxt      , faxnum      , atldat   , "
                                  ," funmat      , pptnom      , outciatxt, "
                                  ," rspnom      , patpprflg   , srvnteflg, "
                                  ," horsegsexinc, horsegsexfnl, horsabinc, "
                                  ," horsabfnl   , hordominc   , hordomfnl, "
                                  ," qldgracod   , pstobs      , prssitcod, "
                                  ," vlrtabflg   , prscootipcod, mpacidcod, "
                                  ," intsrvrcbflg, rmesoctrfcod, frtrpnflg, "
                                  ," risprcflg   , celdddnum   , celtelnum, "
                                  ," lgdtip      , lgdnum      , lclltt   , "
                                  ," lcllgt      , c24lclpdrcod, pisnum   , "
                                  ," nitnum      , succod      , pcpatvcod, "
                                  ," simoptpstflg, pcpprscod   , gstcdicod )"
                              ," = ( ?,?,?, ?,?,?, ?,?,?, ?,?,?, ?,?,?,  "
                                  ," ?,?,today, "
                                  ," ?,?,?, ?,?,?, ?,?,?, ?,?,?, ?,?,?, "
                                  ," ?,?,?, ?,?,?, ?,?,?, ?,?,?, ?,?,?, "
                                  ," ?,?,?, ?, ?, ? ) "
                         ," where dpaksocor.pstcoddig = ? "                   
 prepare pctc00m02003 from l_sql

 let l_sql = " insert into dbsmhstprs (pstcoddig, dbsseqcod, prshstdes,"
            ,"                         caddat   , cademp   , cadusrtip, cadmat)"
            ," values(?,?,?, ?,?,?, ?) "
 prepare pctc00m02004 from l_sql

 let l_sql = " select cpodes ",
             " from iddkdominio ",
             " where iddkdominio.cponom = ? ",
             "   and iddkdominio.cpocod = ? "
 prepare pctc00m02005 from l_sql
 declare cctc00m02005 cursor for pctc00m02005

 let l_sql = "select socvclcod ",
              " from datkveiculo ",
             " where pstcoddig = ? "
 prepare pctc00m02006 from l_sql
 declare cctc00m02006 cursor for pctc00m02006
 
 let l_sql = "select gstcdicod ",
              " from dpaksocor ",
             " where pstcoddig = ? "
 prepare pctc00m02007 from l_sql
 declare cctc00m02007 cursor for pctc00m02007
 
 let l_sql = "select pcpprscod ",
              " from dpaksocor ",
             " where pstcoddig = ? "
 prepare pctc00m02008 from l_sql
 declare cctc00m02008 cursor for pctc00m02008

 #let l_sql = "update datkveiculo ",
 #              " set frtrpnflg = ? ",
 #            " where socvclcod = ? "
 #
 #prepare pctc00m02007 from l_sql
 
 let l_sql = " select 1             "   #PSI-2012-23608
            ,"   from dpakpstend    "
            ,"  where pstcoddig = ? "            
 prepare pctc00m02009 from l_sql
 declare cctc00m02009 cursor for pctc00m02009 
 
 let l_sql = " insert into dpakpstend "
            ," (pstcoddig, endtipcod, lgdtip, endlgd, lgdnum, lgdcmp "
            ,"  , endcep, endcepcmp, endbrr, endcid, ufdsgl, lclltt, lcllgt)"
            ,"  values(?,?,?,?,?,?,?,?,?,?,?,?,?) "
 prepare pctc00m02010 from l_sql
 
 let l_sql = " update dpakpstend       "
            ,"    set  lgdtip    = ?   "
            ,"       , endlgd    = ?   "
            ,"       , lgdnum    = ?   "
            ,"       , lgdcmp    = ?   "
            ,"       , endcep    = ?   "
            ,"       , endcepcmp = ?   "
            ,"       , endbrr    = ?   "
            ,"       , endcid    = ?   "
            ,"       , ufdsgl    = ?   "
            ,"       , lclltt    = ?   "
            ,"       , lcllgt    = ?   "
            ,"   where pstcoddig = ?   "
            ,"     and endtipcod = ?   "           
 prepare pctc00m02011 from l_sql
 
 let l_sql = " select empcod        "
            ,"   from dpaksocor     "
            ,"  where pstcoddig = ? "
 prepare pctc00m02012 from l_sql
 declare cctc00m02012 cursor for pctc00m02012
 
  let l_sql = " select 1             "   #PSI-2012-23608
            ,"   from dpakpstend    "
            ,"  where pstcoddig = ? "
            ,"    and endtipcod = ? "
 prepare pctc00m02013 from l_sql
 declare cctc00m02013 cursor for pctc00m02013 

 let l_sql = "update dpaksocor set (lgdtip, endlgd, lgdnum, endcmp, endbrr, endcid, endufd, "
                                 ," endcep, endcepcmp, lclltt,lcllgt)"      
                              ," = (?,?,?,?,?,?,?,?,?,?,?) "
                         ," where dpaksocor.pstcoddig = ? "                   
 prepare pctc00m02014 from l_sql
 
 let l_sql = "update dpaksocor ",
               " set mpacidcod = ?  ",
             " where pstcoddig = ? " 
 
 prepare pctc00m02015 from l_sql 

 let m_prep_sql = true

end function

#----------------------------------------------
 function ctc00m02()
#----------------------------------------------
# Menu do modulo
#---------------

  define ws               record
         pestip           like dpaksocor.pestip,
         cgccpfnum        like dpaksocor.cgccpfnum,
         cgcord           like dpaksocor.cgcord,
         cgccpfdig        like dpaksocor.cgccpfdig,
         temvclflg        char (01),
         temsrrflg        char (01)
  end record
  
  define lr_saida_801 record      #PSI-2012-23608, Biz
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

  define l_pstcoddig    like dpaksocor.pstcoddig,
         l_comando      char(100),
         l_ret          smallint,
         l_operacional  smallint,
         l_indice       smallint,
         l_endfat       smallint,
         l_mpacidcod    like dpaksocor.mpacidcod,
         l_mpacidcodope like dpaksocor.mpacidcod,
         l_msg          char(70)

  if m_prep_sql is null or
     m_prep_sql <> true then
     call ctc00m02_prepare()
  end if

  if not get_niv_mod(g_issk.prgsgl, "ctc00m02") then
     error " Modulo sem nivel de consulta e atualizacao!"
     return
  end if

  let m_res = null
  let m_msg = null

  open window w_ctc00m02 at 04,02 with form "ctc00m02"
       attribute(comment line last)
       
  let int_flag = false

  initialize  d_ctc00m02.*    to   null
  initialize  k_ctc00m02.*    to   null
  initialize  lr_saida_801.*  to   null
  initialize  l_mpacidcod     to   null
  initialize  l_mpacidcodope  to   null
  
  menu "PRESTADORES"
     before menu
        hide option all
        if g_issk.acsnivcod >= g_issk.acsnivcns  then
           show option "Situacao", "Seleciona", "Proximo", "Anterior",
                       "Vigencia", "serVicos", "Historico" #, "rE" PSI 242853 PST X GRP NTZ -> PST X NTZ
                       , "natureZa", 
                       "parameTros", "assisteNcia", "Frota", "pesQuisa", 
                       "tabeLa_PS", "Cadeia de gestao", "prestaDor_principal", "EnderecOs"
        end if

        if g_issk.acsnivcod >= g_issk.acsnivatl  then

           show option "Situacao", "Seleciona", "Proximo", "Anterior",
                       "Modifica", "Inclui", "Vigencia", "serVicos", "Historico",
                       # "rE", PSI 242853 PST X GRP NTZ -> PST X NTZ
                       "natureZa", "parameTros", "assisteNcia", "Empresa","Responsaveis",
                       "Frota", "pesQuisa", "cRonograma", "tabeLa_PS", "indeXar",
                       "Cadeia de gestao", "prestaDor_principal", "EnderecOs"

        end if

        if g_issk.acsnivcod >= 6      or
           g_issk.funmat    = 14209   then
           show option "Cancela"
           show option "paGtos"
           show option "Bonificacao"
        end if

        show option "Encerra"

  command key ("U") "sitUacao"
               "Lista prestadores conforme situacao"
               call ctc00m12()
                    returning l_pstcoddig
               if l_pstcoddig is not null then
                  let k_ctc00m02.pstcoddig = l_pstcoddig
                  call ctc00m02_ler()
               end if

  command key ("S") "Seleciona"
               "Pesquisa tabela conforme criterios"
               call ctc00m02_seleciona()
               message ""
               if k_ctc00m02.pstcoddig is not null then
                  next option "Proximo"
               else
                  error " Nenhum registro selecionado!"
                  message ""
                  next option "Seleciona"
               end if

  command key ("P") "Proximo"
               "Mostra proximo registro selecionado"
               message ""
               if k_ctc00m02.pstcoddig is not null then
                  call ctc00m02_proximo()
               else
                  error " Nao ha' mais registros nesta direcao!"
                  next option "Seleciona"
               end if

  command key ("A") "Anterior"
               "Mostra registro anterior selecionado"
               message ""
               if k_ctc00m02.pstcoddig is not null then
                  call ctc00m02_anterior()
               else
                  error " Nao ha' mais registros nesta direcao!"
                  next option "Seleciona"
               end if

  command key ("M") "Modifica"
               "Modifica registro corrente selecionado"
               message ""
               if k_ctc00m02.pstcoddig is not null then
                  call ctc00m02_modifica("m")
                  next option "Seleciona"
               else
                  error " Nenhum registro selecionado!"
                  next option "Seleciona"
               end if
               
  command key ("O") "EnderecOs"
               "Cadastro do endereço dos pretadores"
               message ""
               if k_ctc00m02.pstcoddig is not null then

                  initialize d_ctc00m02_end, l_endfat, l_operacional, l_mpacidcod to null
                  
                  call ctc00m25(d_ctc00m02.pstcoddig, true)
                       returning d_ctc00m02_end[1].*,
                                 d_ctc00m02_end[2].*,
                                 d_ctc00m02_end[3].*,
                                 d_ctc00m02_end[4].*,
                                 d_ctc00m02_end[5].*,
                                 d_ctc00m02_end[6].*,
                                 d_ctc00m02_end[7].*,
                                 d_ctc00m02_end[8].*,
                                 d_ctc00m02_end[9].*,
                                 d_ctc00m02_end[10].*,
                                 l_operacional,
                                 m_aux

                  let d_ctc00m02.lgdtip    = d_ctc00m02_end[l_operacional].lgdtip
                  let d_ctc00m02.endlgd    = d_ctc00m02_end[l_operacional].endlgd
                  let d_ctc00m02.lgdnum    = d_ctc00m02_end[l_operacional].lgdnum
                  let d_ctc00m02.endcmp    = d_ctc00m02_end[l_operacional].lgdcmp
                  let d_ctc00m02.endbrr    = d_ctc00m02_end[l_operacional].endbrr
                  let d_ctc00m02.endcid    = d_ctc00m02_end[l_operacional].endcid
                  let d_ctc00m02.endufd    = d_ctc00m02_end[l_operacional].ufdsgl
                  let d_ctc00m02.endcep    = d_ctc00m02_end[l_operacional].endcep   
                  let d_ctc00m02.endcepcmp = d_ctc00m02_end[l_operacional].endcepcmp
                  let d_ctc00m02.lclltt    = d_ctc00m02_end[l_operacional].lclltt   
                  let d_ctc00m02.lcllgt    = d_ctc00m02_end[l_operacional].lcllgt                   

                  execute pctc00m02014 using d_ctc00m02.lgdtip,                       
                                             d_ctc00m02.endlgd,   
                                             d_ctc00m02.lgdnum,   
                                             d_ctc00m02.endcmp,   
                                             d_ctc00m02.endbrr,   
                                             d_ctc00m02.endcid,   
                                             d_ctc00m02.endufd,   
                                             d_ctc00m02.endcep,   
                                             d_ctc00m02.endcepcmp,
                                             d_ctc00m02.lclltt,   
                                             d_ctc00m02.lcllgt,   
                                             d_ctc00m02.pstcoddig   

                   call cty10g00_obter_cidcod(d_ctc00m02.endcid, d_ctc00m02.endufd)
                         returning l_ret,
                                   l_msg,
                                   d_ctc00m02.mpacidcod                  
                  
                   if  l_ret = 0 then
                       execute pctc00m02015 using d_ctc00m02.mpacidcod, d_ctc00m02.pstcoddig
                   end if

                  #PSI-2012-23608 - Inicio
                  for l_indice = 1 to 10
                      
                      if d_ctc00m02_end[l_indice].endlgd is null then
                         exit for
                      end if
                      
                      open cctc00m02013 using d_ctc00m02.pstcoddig,d_ctc00m02_end[l_indice].endtipcod
                      fetch cctc00m02013 into l_ret
                      
                      if sqlca.sqlcode = 100 then                         
                         
                         execute pctc00m02010 using d_ctc00m02.pstcoddig
                                                  , d_ctc00m02_end[l_indice].endtipcod
                                                  , d_ctc00m02_end[l_indice].lgdtip   
                                                  , d_ctc00m02_end[l_indice].endlgd   
                                                  , d_ctc00m02_end[l_indice].lgdnum   
                                                  , d_ctc00m02_end[l_indice].lgdcmp   
                                                  , d_ctc00m02_end[l_indice].endcep   
                                                  , d_ctc00m02_end[l_indice].endcepcmp
                                                  , d_ctc00m02_end[l_indice].endbrr   
                                                  , d_ctc00m02_end[l_indice].endcid   
                                                  , d_ctc00m02_end[l_indice].ufdsgl   
                                                  , d_ctc00m02_end[l_indice].lclltt   
                                                  , d_ctc00m02_end[l_indice].lcllgt   
                         
                         
                         if sqlca.sqlcode <> 0 then
                            error " Erro (", sqlca.sqlcode, ") alteracao de enderecos.",
                                  " AVISE A INFORMATICA!"     
                            rollback work     
                            return
                         end if
                      else
                      
                         execute pctc00m02011 using d_ctc00m02_end[l_indice].lgdtip    
                                                ,d_ctc00m02_end[l_indice].endlgd   
                                                ,d_ctc00m02_end[l_indice].lgdnum   
                                                ,d_ctc00m02_end[l_indice].lgdcmp   
                                                ,d_ctc00m02_end[l_indice].endcep   
                                                ,d_ctc00m02_end[l_indice].endcepcmp
                                                ,d_ctc00m02_end[l_indice].endbrr   
                                                ,d_ctc00m02_end[l_indice].endcid   
                                                ,d_ctc00m02_end[l_indice].ufdsgl   
                                                ,d_ctc00m02_end[l_indice].lclltt   
                                                ,d_ctc00m02_end[l_indice].lcllgt   
                                                ,d_ctc00m02.pstcoddig       
                                                ,d_ctc00m02_end[l_indice].endtipcod
                         if sqlca.sqlcode <> 0 then
                            error " Erro (", sqlca.sqlcode, ") alteracao de enderecos.",
                                  " AVISE A INFORMATICA!"     
                            rollback work     
                            return
                         end if
                      end if
                      
                      #Verifica a posição do end fiscal no array
                      if d_ctc00m02_end[l_indice].domtipdes like "%FISCAL%" then
                          let l_endfat = l_indice         
                      end if      
                      
                      close cctc00m02013

                      #atualiza o cadastro com a susursal retornada pela função do tributus
                      if l_endfat is null or l_endfat = 0 then
                         #error "NAO FOI ENCONTRADO ENDERECO FISCAL. AVISE A INFORMATICA" sleep 2
                      else   
                         call cty10g00_obter_cidcod(d_ctc00m02_end[l_endfat].endcid, d_ctc00m02_end[l_endfat].ufdsgl)
                               returning l_ret,
                                         l_msg,
                                         l_mpacidcod

                         if l_ret = 0 then  
                            call fcgtc801(1, l_mpacidcod)
                                  returning lr_saida_801.coderr      
                                           ,lr_saida_801.msgerr      
                                           ,lr_saida_801.ppssucnum   
                                           ,lr_saida_801.etbnom      
                                           ,lr_saida_801.etbcpjnum   
                                           ,lr_saida_801.etblgddes   
                                           ,lr_saida_801.etblgdnum   
                                           ,lr_saida_801.etbcpldes   
                                           ,lr_saida_801.etbbrrnom   
                                           ,lr_saida_801.etbcepnum   
                                           ,lr_saida_801.etbcidnom   
                                           ,lr_saida_801.etbufdsgl   
                                           ,lr_saida_801.etbiesnum   
                                           ,lr_saida_801.etbmuninsnum  
                            
                            update dpaksocor set succod = lr_saida_801.ppssucnum
                             where pstcoddig = d_ctc00m02.pstcoddig

                         else
                            error l_msg
                         end if
                      end if                      
                  end for 
                  
                  call ctc00m02_ler()                  

                  next option "Seleciona"
               else
                  error " Nenhum registro selecionado!"
                  next option "Seleciona"
               end if               

  command key ("I") "Inclui"
               "Inclui Registro na Tabela"
               message ""
               call inclui_ctc00m02("i")
               next option "Seleciona"

  command key ("C") "Cancela"
               "Cancela prestador"
               message ""
               if k_ctc00m02.pstcoddig is not null then
                  call ctc00m02_veiculos(k_ctc00m02.pstcoddig)
                       returning ws.temvclflg

                  call ctc00m02_socorristas(k_ctc00m02.pstcoddig)
                       returning ws.temsrrflg

                  if ws.temsrrflg  =  "n"   and
                     ws.temvclflg  =  "n"   then
                     call ctc00m02_cancela(k_ctc00m02.pstcoddig)
                     next option "Encerra"
                  end if
               else
                  error " Nenhum registro selecionado!"
                  next option "Seleciona"
               end if

  command key ("W") "Vigencia"
               "Vigencia de contrato do prestador"
               message ""
               if k_ctc00m02.pstcoddig is not null then
                  if d_ctc00m02.qldgracod = 1 then
                      call ctc00m17(d_ctc00m02.pstcoddig, d_ctc00m02.nomgrr)
                  else
                      error "Somente prestadores com Qualidade PADRÃO PORTO possuem cadastro de vigências!"
                  end if
               else
                  error " Nenhum registro selecionado!"
                  next option "Seleciona"
               end if
  
  command key ("V") "serVicos"
               "Servicos realizados pelo prestador"
               message ""
               if k_ctc00m02.pstcoddig is not null then
                  call ctc08m00(d_ctc00m02.pstcoddig, d_ctc00m02.nomgrr )
               else
                  error " Nenhum registro selecionado!"
                  next option "Seleciona"
               end if

  command key ("H") "Historico"
               "Historico cadastrado para o Prestador"
               message ""
               if k_ctc00m02.pstcoddig is not null then
                  call ctc00m13(k_ctc00m02.pstcoddig)
               else
                  error " Nenhum registro selecionado!"
                  next option "Seleciona"
               end if

  #command key ("B") "rE" PSI 242853 PST X GRP NTZ -> PST X NTZ
  #             "Servicos de RE realizados pelo prestador"
  #             message ""
  #             if k_ctc00m02.pstcoddig is not null then
  #                call ctc76m00(d_ctc00m02.pstcoddig, d_ctc00m02.nomgrr)
  #             else
  #                error " Nenhum registro selecionado!"
  #                next option "Seleciona"
  #             end if

  command key ("Z") "natureZa"
               "Tipo de Natureza realizados pelo prestador"
               message ""
               if k_ctc00m02.pstcoddig is not null then
                  call ctc00m16(d_ctc00m02.pstcoddig, d_ctc00m02.nomgrr)
               else
                  error " Nenhum registro selecionado!"
                  next option "Seleciona"
               end if  
  
  command key ("T") "parameTros"
               "Parametrizar o numero final do servico p/ prestador Internet"
               message ""
               if k_ctc00m02.pstcoddig is not null then
                  call ctc77m00(d_ctc00m02.pstcoddig, d_ctc00m02.nomgrr)
               else
                  error " Nenhum registro selecionado!"
                  next option "Seleciona"
               end if

  command key ("N") "assisteNcia"
                "Tipos de assistencia do prestador"
                if k_ctc00m02.pstcoddig is not null then
                  call ctc00m11(d_ctc00m02.pstcoddig, d_ctc00m02.nomgrr)
               else
                  error " Nenhum registro selecionado!"
                  next option "Seleciona"
               end if

  command key ("E") "Empresa"
               "Mantem o cadastro das empresas atendidas pelo prestador"
               message ""

               if k_ctc00m02.pstcoddig is not null then
                  call ctc00m02_empresas(k_ctc00m02.pstcoddig)
                  next option "Seleciona"
               else
                  error " Nenhum registro selecionado!"
                  next option "Seleciona"
               end if
               
  command key ("K") "Responsaveis"
               "Mantem as informações do prestador exigidas pela circular 380"
               message ""

               if k_ctc00m02.pstcoddig is not null then
                  if d_ctc00m02.pestip <> 'F' then
                     call ctc00m20('A',k_ctc00m02.pstcoddig, 0) #PSI circular 380
                     initialize d_ctc00m02.*  to null
                     initialize k_ctc00m02.*  to null
                     next option "Seleciona"                                                        
                  else
                     error "Pessoa Fisica nao utiliza a funcionalidade Responsavel"
                  end if            
               else
                  error " Nenhum registro selecionado!"
                  next option "Seleciona"
               end if

  command key ("F") "Frota"
               "Frota do prestador"
               message ""
               if k_ctc00m02.pstcoddig is not null then
                  select pstcoddig
                    from dpaksocor
                   where dpaksocor.pstcoddig = d_ctc00m02.pstcoddig

                  if sqlca.sqlcode = notfound then
                     error " Prestador nao cadastrado!"
                     next option "Inclui"
                  else
                     call ctc07m00(d_ctc00m02.pstcoddig, d_ctc00m02.nomgrr)
                  end if
               else
                  error " Nenhum registro selecionado!"
                  next option "Seleciona"
               end if

  command key ("Q") "pesQuisa"
               "Pesquisa por Nome Guerra, Razao, Cgc/Cpf, O.S."
               message ""
               call ctb12m02("")  returning  k_ctc00m02.pstcoddig,
                                             ws.pestip,
                                             ws.cgccpfnum,
                                             ws.cgcord,
                                             ws.cgccpfdig
               call ctc00m02_ler()
               message ""
               if k_ctc00m02.pstcoddig  is not null   then
                  error " Selecione e TECLE ENTER "
                  next option "Seleciona"
               else
                  error " Nenhum prestador selecionado!"
               end if

  command key ("R") "cRonograma"
               "Releciona cronograma de entrega ao prestador"
               message ""
               if k_ctc00m02.pstcoddig is not null then
                  call ctc00m09(k_ctc00m02.pstcoddig)
                  next option "Seleciona"
               else
                  error " Nenhum registro selecionado!"
                  next option "Seleciona"
               end if

  command key ("G") "paGtos"
               "Ordens de pagamento realizadas para prestador"
               message ""
               if k_ctc00m02.pstcoddig is not null then
                  call ctc00m08(d_ctc00m02.pstcoddig)
               else
                  error " Nenhum prestador selecionado!"
                  next option "Seleciona"
               end if

  command key ("L") "tabeLa_PS"
               "Tabela de Tarifas Porto Socorro"
               message ""
               if k_ctc00m02.pstcoddig is not null then
                  call ctc00m14(d_ctc00m02.pstcoddig)
               else
                  error " Nenhum prestador selecionado!"
                  next option "Seleciona"
               end if

  command key ("Y") "Bonificacao"
               "Processos Bonificaveis dos Prestadores."
               message ""
               if k_ctc00m02.pstcoddig is not null then
                  call ctc20m07(d_ctc00m02.pstcoddig, d_ctc00m02.nomgrr)
               else
                  error " Nenhum prestador selecionado!"
                  next option "Seleciona"
               end if

  command key ("X") "indeXar"
               "Indexa os enderecos dos prestadores"
               let l_comando = "cts48g00.4gc"
               run l_comando

command key ("B") "Cadeia de gestao" "Cadastro da cadeia de gestao do prestador"
  	       message ""
  	       if k_ctc00m02.pstcoddig is not null then
  	          call ctc00m02_complemento('C')
  	             returning d_ctc00m02.gstcdicod
  	       else
  	          error " Nenhum registro selecionado!"
                  next option "Seleciona"
  	       end if               
               
  command key ("D") "prestaDor_principal"
               "Vincula um prestador como prestador princial"
               message ""
               if k_ctc00m02.pstcoddig is not null then
                  call ctc00m02_pstprinc()
               else
                  error " Nenhum registro selecionado!"
                  next option "Seleciona"
               end if               

  command key (interrupt) "Encerra" "Retorna ao menu anterior"
              exit menu
  end menu

  close window w_ctc00m02

end function    #-- ctc00m02


#---------------------------------------
function ctc00m02_seleciona()
#---------------------------------------

    clear form
    initialize d_ctc00m02_end to null
    let int_flag = false

    input by name k_ctc00m02.pstcoddig  without defaults
       before field pstcoddig
          display by name k_ctc00m02.pstcoddig attribute(reverse)

          if k_ctc00m02.pstcoddig is null then
             let k_ctc00m02.pstcoddig = 0
          end if

       after  field pstcoddig
          display by name k_ctc00m02.pstcoddig

       on key (interrupt)
          exit input
    end input

    if int_flag then
       let int_flag = false
       initialize d_ctc00m02.* to null
       initialize k_ctc00m02.* to null
       error " Operacao cancelada!"
       clear form
       return
    end if

    if k_ctc00m02.pstcoddig  =  0   then
       select min (dpaksocor.pstcoddig)
         into k_ctc00m02.pstcoddig
         from dpaksocor
        where dpaksocor.pstcoddig > 0

       display by name k_ctc00m02.pstcoddig
    end if

    let d_ctc00m02.pstcoddig = k_ctc00m02.pstcoddig

    call ctc00m02_ler()


end function   #-- ctc00m02_seleciona


#---------------------------------------------------------
function inclui_ctc00m02(param)
#---------------------------------------------------------

  define param record
         operacao     char(01)
  end record

  define l_prshstdes  char(2000)
  define l_ret        smallint
  define prompt_key   char(001)
  define l_indice     smallint,
         l_endfat     smallint,
         l_res        integer,
         l_msg        char(70),
         l_mpacidcod  like dpaksocor.mpacidcod   
  
  define lr_saida_801 record      #PSI-2012-23608, Biz
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

  clear form
  initialize d_ctc00m02.* to null
  initialize k_ctc00m02.* to null
  initialize lr_saida_801.* to null
  
  for l_indice = 1 to 10
      initialize d_ctc00m02_end[l_indice].* to null
  end for

  call ctc00m02_input(param.operacao)

  if int_flag  then
     let int_flag = false
     initialize d_ctc00m02.* to null
     error " Operacao cancelada!"
     clear form
     return
  end if

  whenever error continue

  select max (dpaksocor.pstcoddig)
    into d_ctc00m02.pstcoddig
    from dpaksocor
   where pstcoddig <> 999999

  let d_ctc00m02.pstcoddig = d_ctc00m02.pstcoddig + 1
  
  call ctc30m00_remove_caracteres(d_ctc00m02.pptnom)
            returning d_ctc00m02.pptnom
  
  call ctc30m00_remove_caracteres(d_ctc00m02.rspnom)
            returning d_ctc00m02.rspnom
  
  call ctc30m00_remove_caracteres(d_ctc00m02.outciatxt)
            returning d_ctc00m02.outciatxt             
  
  call ctc30m00_remove_caracteres(d_ctc00m02.pstobs)
            returning d_ctc00m02.pstobs
            
  call ctc30m00_remove_caracteres(d_ctc00m02.nomrazsoc)
            returning d_ctc00m02.nomrazsoc             
  
  call ctc30m00_remove_caracteres(d_ctc00m02.nomgrr)
            returning d_ctc00m02.nomgrr 
            
  call ctc30m00_remove_caracteres(d_ctc00m02.endbrr)
            returning d_ctc00m02.endbrr            
  
  call ctc30m00_remove_caracteres(d_ctc00m02.endcmp)
            returning d_ctc00m02.endcmp                        
    
  call ctc30m00_remove_caracteres(d_ctc00m02.endcid)
            returning d_ctc00m02.endcid
            
  
  begin work
  execute pctc00m02001 using d_ctc00m02.pstcoddig,
                             d_ctc00m02.pptnom   ,
                             d_ctc00m02.outciatxt,
                             d_ctc00m02.rspnom   ,
                             d_ctc00m02.patpprflg,
                             d_ctc00m02.srvnteflg,
                             d_ctc00m02.horsegsexinc,
                             d_ctc00m02.horsegsexfnl,
                             d_ctc00m02.horsabinc,
                             d_ctc00m02.horsabfnl,
                             d_ctc00m02.hordominc,
                             d_ctc00m02.hordomfnl,
                             d_ctc00m02.qldgracod,
                             d_ctc00m02.pstobs   ,
                             d_ctc00m02.prssitcod,
                             d_ctc00m02.nomrazsoc,
                             d_ctc00m02.nomgrr   ,
                             d_ctc00m02.cgccpfnum,
                             d_ctc00m02.cgcord   ,
                             d_ctc00m02.cgccpfdig,
                             d_ctc00m02.muninsnum,
                             d_ctc00m02.pestip   ,
                             d_ctc00m02.endlgd   ,
                             d_ctc00m02.endcmp   ,
                             d_ctc00m02.endbrr   ,
                             d_ctc00m02.endcid   ,
                             d_ctc00m02.endufd   ,
                             d_ctc00m02.endcep   ,
                             d_ctc00m02.endcepcmp,
                             d_ctc00m02.dddcod   ,
                             d_ctc00m02.teltxt   ,
                             d_ctc00m02.faxnum   ,
                             g_issk.funmat       ,
                             g_issk.funmat       ,
                             d_ctc00m02.vlrtabflg,
                             d_ctc00m02.prscootipcod,
                             d_ctc00m02.mpacidcod   ,
                             d_ctc00m02.intsrvrcbflg,
                             d_ctc00m02.rmesoctrfcod,
                             d_ctc00m02.frtrpnflg,
                             d_ctc00m02.risprcflg,
                             d_ctc00m02.celdddnum,
                             d_ctc00m02.celtelnum,
                             d_ctc00m02.lgdtip,
                             d_ctc00m02.lgdnum,
                             d_ctc00m02.lclltt,
                             d_ctc00m02.lcllgt,
                             d_ctc00m02.c24lclpdrcod,
                             d_ctc00m02.pisnum,
                             d_ctc00m02.nitnum,
                             d_ctc00m02.succod,
                             d_ctc00m02.pcpatvcod,
                             d_ctc00m02.simoptpstflg,
                             d_ctc00m02.pcpprscod,
                             d_ctc00m02.gstcdicod
                             

  if sqlca.sqlcode <> 0 then
     error 'Erro INSERT pctc00m02001 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
     sleep 2
     error 'CTC00M02 / inclui_ctc00m02() '  sleep 2
     rollback work
     return
  end if
  
  call ctc30m00_remove_caracteres(d_ctc00m02.socfavnom)
            returning d_ctc00m02.socfavnom 
  

  insert into dpaksocorfav( pstcoddig,
                            socpgtopccod,
                            socfavnom,
                            pestip,
                            cgccpfnum,
                            cgcord,
                            cgccpfdig,
                            bcoctatip,
                            bcocod,
                            bcoagnnum,
                            bcoagndig,
                            bcoctanum,
                            bcoctadig,
                            nscdat,
                            sexcod)
                   values ( d_ctc00m02.pstcoddig,
                            d_ctc00m02.socpgtopccod,
                            d_ctc00m02.socfavnom,
                            d_ctc00m02.pestipfav,
                            d_ctc00m02.cgccpfnumfav,
                            d_ctc00m02.cgcordfav,
                            d_ctc00m02.cgccpfdigfav,
                            d_ctc00m02.bcoctatip,
                            d_ctc00m02.bcocod,
                            d_ctc00m02.bcoagnnum,
                            d_ctc00m02.bcoagndig,
                            d_ctc00m02.bcoctanum,
                            d_ctc00m02.bcoctadig,
                            d_ctc00m02.nscdat,
                            d_ctc00m02.sexcod)
                            
  if sqlca.sqlcode <> 0 then
     error " Erro (", sqlca.sqlcode, ") inclusao do favorecido.",
           " AVISE A INFORMATICA!"
     rollback work
     return
  end if
    
  whenever error stop
  
  let l_prshstdes = "Prestador incluido [", d_ctc00m02.pstcoddig clipped, "] !"

  call ctc00m02_grava_hist(d_ctc00m02.pstcoddig, l_prshstdes, 'I')
  
  #PSI-2012-23608 - Inicio
  for l_indice = 1 to 10
      if d_ctc00m02_end[l_indice].endlgd is null and l_indice > 1 then
         exit for
      end if
      
      whenever error continue

      execute pctc00m02010 using d_ctc00m02.pstcoddig
                               , d_ctc00m02_end[l_indice].endtipcod
                               , d_ctc00m02_end[l_indice].lgdtip   
                               , d_ctc00m02_end[l_indice].endlgd   
                               , d_ctc00m02_end[l_indice].lgdnum   
                               , d_ctc00m02_end[l_indice].lgdcmp   
                               , d_ctc00m02_end[l_indice].endcep   
                               , d_ctc00m02_end[l_indice].endcepcmp
                               , d_ctc00m02_end[l_indice].endbrr   
                               , d_ctc00m02_end[l_indice].endcid           
                               , d_ctc00m02_end[l_indice].ufdsgl   
                               , d_ctc00m02_end[l_indice].lclltt   
                               , d_ctc00m02_end[l_indice].lcllgt   
      whenever error stop
      
      
      #if sqlca.sqlcode <> 0 then
      #   error " Erro (", sqlca.sqlcode, ") inclusao de enderecos.",
      #         " AVISE A INFORMATICA!"     
      #   rollback work     
      #   return
      #end if                  
      
      #Verifica a posição do end fiscal no array
      if d_ctc00m02_end[l_indice].domtipdes like "%FISCAL%" then
          let l_endfat = l_indice         
      end if
      
  end for  
  
  #atualiza o cadastro com a susursal retornada pela função do tributus
  if l_endfat is null or l_endfat = 0 then
     error "NAO FOI ENCONTRADO ENDERECO FISCAL. AVISE A INFORMATICA" sleep 2
  else   
     call cty10g00_obter_cidcod(d_ctc00m02_end[l_endfat].endcid, d_ctc00m02_end[l_endfat].ufdsgl)
           returning l_res,
                     l_msg,
                     l_mpacidcod
     
     if l_res = 0 then  
        call fcgtc801(1, l_mpacidcod)
              returning lr_saida_801.coderr      
                       ,lr_saida_801.msgerr      
                       ,lr_saida_801.ppssucnum   
                       ,lr_saida_801.etbnom      
                       ,lr_saida_801.etbcpjnum   
                       ,lr_saida_801.etblgddes   
                       ,lr_saida_801.etblgdnum   
                       ,lr_saida_801.etbcpldes   
                       ,lr_saida_801.etbbrrnom   
                       ,lr_saida_801.etbcepnum   
                       ,lr_saida_801.etbcidnom   
                       ,lr_saida_801.etbufdsgl   
                       ,lr_saida_801.etbiesnum   
                       ,lr_saida_801.etbmuninsnum  
        
        update dpaksocor set succod = lr_saida_801.ppssucnum
         where pstcoddig = d_ctc00m02.pstcoddig
        
     else
        error l_msg
     end if
  end if
  #PSI-2012-23608 - Fim      
  commit work              
                           
  call ctc00m21(d_ctc00m02.pstcoddig,0,d_ctc00m02.pestip,'I','P')
                           
  call ctc00m02_empresas(d_ctc00m02.pstcoddig)
                           
  if d_ctc00m02.pestip <> 'F' then
     call ctc00m20('I',d_ctc00m02.pstcoddig, 0) #PSI circular 380    
  end if                   
                           
  call ctc20m07_obrigatorio(d_ctc00m02.pstcoddig,d_ctc00m02.rspnom)
                           
  display by name d_ctc00m02.pstcoddig attribute(reverse)
  error " Verifique o codigo do prestador e tecle ENTER!"
  prompt "" for char prompt_key
  error " Incluir os servicos realizados pelo prestador !!"
  if d_ctc00m02.pstcoddig is not null then
     call ctc08m00(d_ctc00m02.pstcoddig, d_ctc00m02.nomgrr)
  else
     error " Erro na inclusao dos servicos realizados pelo prestador! ",
           "AVISE A INFORMATICA!"
  end if

  clear form

end function   #-- inclui_ctc00m02


#-----------------------------------------------------------
function ctc00m02_proximo()
#-----------------------------------------------------------

  let int_flag = false

  select min (dpaksocor.pstcoddig)
    into d_ctc00m02.pstcoddig
    from dpaksocor
   where dpaksocor.pstcoddig > k_ctc00m02.pstcoddig

  if d_ctc00m02.pstcoddig is not null then
     let k_ctc00m02.pstcoddig = d_ctc00m02.pstcoddig
     call ctc00m02_ler()
  end if

  if d_ctc00m02.pstcoddig  is null   or
     sqlca.sqlcode  =  notfound      then
     error " Nao ha' mais registros nesta direcao!"
     initialize d_ctc00m02.* to null
  end if

end function    #-- ctc00m02_proximo


#-----------------------------------------------------------
function ctc00m02_anterior()
#-----------------------------------------------------------

  let int_flag = false

  select max (dpaksocor.pstcoddig)
    into d_ctc00m02.pstcoddig
    from dpaksocor
   where dpaksocor.pstcoddig < k_ctc00m02.pstcoddig

  if d_ctc00m02.pstcoddig is not null then
     let k_ctc00m02.pstcoddig = d_ctc00m02.pstcoddig
     call ctc00m02_ler()
  end if

  if d_ctc00m02.pstcoddig  is null   or
     sqlca.sqlcode  =  notfound      then
     error " Nao ha' mais registros nesta direcao!"
     initialize d_ctc00m02.* to null
  end if

end function    #-- ctc00m02_anterior


#-----------------------------------------------------------
function ctc00m02_modifica(param)
#-----------------------------------------------------------

  define param          record
    operacao            char(01)
  end record

  define lr_ctc00m02_ant record
         pstcoddig       like dpaksocor.pstcoddig   ,
         nomrazsoc       like dpaksocor.nomrazsoc   ,
         nomgrr          like dpaksocor.nomgrr      ,
         cgccpfnum       like dpaksocor.cgccpfnum   ,
         cgcord          like dpaksocor.cgcord      ,
         cgccpfdig       like dpaksocor.cgccpfdig   ,
         muninsnum       like dpaksocor.muninsnum   ,
         pestip          like dpaksocor.pestip      ,
         endlgd          like dpaksocor.endlgd      ,
         endcmp          like dpaksocor.endcmp      ,
         endbrr          like dpaksocor.endbrr      ,
         endcid          like dpaksocor.endcid      ,
         endufd          like dpaksocor.endufd      ,
         endcep          like dpaksocor.endcep      ,
         endcepcmp       like dpaksocor.endcepcmp   ,
         pptnom          like dpaksocor.pptnom      ,
         patpprflg       like dpaksocor.patpprflg   ,
         outciatxt       like dpaksocor.outciatxt   ,
         rspnom          like dpaksocor.rspnom      ,
         srvnteflg       like dpaksocor.srvnteflg   ,
         dddcod          like dpaksocor.dddcod      ,
         teltxt          like dpaksocor.teltxt      ,
         faxnum          like dpaksocor.faxnum      ,
         socpgtopccod    like dpaksocorfav.socpgtopccod,
         socpgtopcdes    char(10),
         socfavnom       like dpaksocorfav.socfavnom,
         pestipfav       like dpaksocorfav.pestip,
         cgccpfnumfav    like dpaksocorfav.cgccpfnum,
         cgcordfav       like dpaksocorfav.cgcord,
         cgccpfdigfav    like dpaksocorfav.cgccpfdig,
         bcoctatip       like dpaksocorfav.bcoctatip,
         bcocod          like dpaksocorfav.bcocod,
         bcoagnnum       like dpaksocorfav.bcoagnnum,
         bcoagndig       like dpaksocorfav.bcoagndig,
         bcoctanum       like dpaksocorfav.bcoctanum,
         bcoctadig       like dpaksocorfav.bcoctadig,
         horsegsexinc    like dpaksocor.horsegsexinc,
         horsegsexfnl    like dpaksocor.horsegsexfnl,
         horsabinc       like dpaksocor.horsabinc   ,
         horsabfnl       like dpaksocor.horsabfnl   ,
         hordominc       like dpaksocor.hordominc   ,
         hordomfnl       like dpaksocor.hordomfnl   ,
         qldgracod       like dpaksocor.qldgracod   ,
         qldgrades       char(12)                   ,
         prssitcod       like dpaksocor.prssitcod   ,
         prssitdes       char(09)                   ,
         pstobs          like dpaksocor.pstobs      ,
         prscootipcod    like dpaksocor.prscootipcod,
         prscootipdes    char (09)                  ,
         vlrtabflg       like dpaksocor.vlrtabflg   ,
         rmesoctrfcod    like dpaksocor.rmesoctrfcod,
         soctrfdes_re    like dbsktarifasocorro.soctrfdes,
         atldat          like dpaksocor.atldat      ,
         funmat          like dpaksocor.funmat      ,
         funnom          like isskfunc.funnom       ,
         cmtdat          like dpaksocor.cmtdat      ,
         cmtmatnum       like dpaksocor.cmtmatnum   ,
         cmtnom          like isskfunc.funnom       ,
         mpacidcod       like dpaksocor.mpacidcod   ,
         intsrvrcbflg    like dpaksocor.intsrvrcbflg,
         intdescr        char (08),
         risprcflg       like dpaksocor.risprcflg,
         celdddnum       like dpaksocor.celdddnum,
         celtelnum       like dpaksocor.celtelnum,
         lgdtip          like dpaksocor.lgdtip,
         lgdnum          like dpaksocor.lgdnum,
         lclltt          like datmlcl.lclltt,
         lcllgt          like datmlcl.lcllgt,
         c24lclpdrcod    like datmlcl.c24lclpdrcod,
         frtrpnflg       like dpaksocor.frtrpnflg,
         frtrpndes       char(20),
         pisnum          like dpaksocor.pisnum,
         nitnum          like dpaksocor.nitnum,
         succod          like dpaksocor.succod,
         sucnom          like gabksuc.sucnom,
         pcpatvcod       like dpaksocor.pcpatvcod,
         pcpatvdes       char(30),
         simoptpstflg    like dpaksocor.simoptpstflg,
         pcpprscod       like dpaksocor.pcpprscod,
         gstcdicod       like dpaksocor.gstcdicod,
         nscdat          like dpaksocorfav.nscdat,
         sexcod          like dpaksocorfav.sexcod 
  end record
  define lr_ret record
         errcod    smallint,
         errmsg    char(100) 
  end record
  
  define lr_saida_801 record      #PSI-2012-23608, Biz
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
  
  define l_prshstdes  char(2000),
         l_length     smallint,
         teste        char(1) ,
         l_ret        smallint,
         l_indice     smallint,
         l_count      smallint,
         l_endfat     smallint,
         l_res        integer,
         l_msg        char(70),
         l_mpacidcod  like dpaksocor.mpacidcod 
	 
  define l_aux_cnpjcpf   char(20)     #Fornax-Quantum   
  define l_corpoemail    char(1000)   #Fornax-Quantum   
  define l_assunto       char(100)    #Fornax-Quantum   
  define l_erro          smallint     #Fornax-Quantum   
  define l_texto_html    char(32000)  #Fornax-Quantum   
  define lr_ciaempcod    integer      #Fornax-Quantum   
  define l_enviaSap      integer 
  define l_enviaEmailSap integer 
  define l_texto_SAP     char(32000)
  
  
  let l_enviaSap = false 
  let l_enviaEmailSap = false 
  
  initialize l_texto_SAP to null
  
  let lr_ctc00m02_ant.* = d_ctc00m02.*
  
  for l_indice = 1 to 10
      initialize d_ctc00m02_end[l_indice].* to null
  end for

  # PSI 198404, atualizar o PIS com o NIT ao modificar o cadastro
  # Sao a mesma informacao segundo o tributos
  if d_ctc00m02.pisnum is null or
     d_ctc00m02.pisnum <= 0
     then
     let d_ctc00m02.pisnum = d_ctc00m02.nitnum
  end if
  
  let int_flag = false
  
  call ctc00m02_input(param.operacao)

  if int_flag then
     let int_flag = false
     initialize d_ctc00m02.* to null
     error " Operacao cancelada!"
     clear form
     return
  end if

  begin work
  
  whenever error continue
  call ctc30m00_remove_caracteres(d_ctc00m02.nomrazsoc)
            returning d_ctc00m02.nomrazsoc 
  
  call ctc30m00_remove_caracteres(d_ctc00m02.nomgrr)
            returning d_ctc00m02.nomgrr 
            
  call ctc30m00_remove_caracteres(d_ctc00m02.endlgd)
            returning d_ctc00m02.endlgd             
  
  call ctc30m00_remove_caracteres(d_ctc00m02.endcmp)
            returning d_ctc00m02.endcmp

  call ctc30m00_remove_caracteres(d_ctc00m02.endcid)
            returning d_ctc00m02.endcid
            
  call ctc30m00_remove_caracteres(d_ctc00m02.endbrr)
            returning d_ctc00m02.endbrr                                                
  
  call ctc30m00_remove_caracteres(d_ctc00m02.nomgrr)
            returning d_ctc00m02.nomgrr
            
  call ctc30m00_remove_caracteres(d_ctc00m02.nomrazsoc)
            returning d_ctc00m02.nomrazsoc             
  
  call ctc30m00_remove_caracteres(d_ctc00m02.endcid)
            returning d_ctc00m02.endcid
            
  call ctc30m00_remove_caracteres(d_ctc00m02.pptnom)
            returning d_ctc00m02.pptnom 
  
  call ctc30m00_remove_caracteres(d_ctc00m02.outciatxt)
            returning d_ctc00m02.outciatxt
            
  call ctc30m00_remove_caracteres(d_ctc00m02.rspnom)
            returning d_ctc00m02.rspnom                       
           
  
  
  
  execute pctc00m02003 using d_ctc00m02.nomrazsoc,
                             d_ctc00m02.nomgrr   ,
                             d_ctc00m02.cgccpfnum,
                             d_ctc00m02.cgcord   ,
                             d_ctc00m02.cgccpfdig,
                             d_ctc00m02.muninsnum,
                             d_ctc00m02.pestip   ,
                             d_ctc00m02.endlgd   ,
                             d_ctc00m02.endcmp   ,
                             d_ctc00m02.endbrr   ,
                             d_ctc00m02.endcid   ,
                             d_ctc00m02.endufd   ,
                             d_ctc00m02.endcep   ,
                             d_ctc00m02.endcepcmp,
                             d_ctc00m02.dddcod   ,
                             d_ctc00m02.teltxt   ,
                             d_ctc00m02.faxnum   ,
                             g_issk.funmat       ,
                             d_ctc00m02.pptnom   ,
                             d_ctc00m02.outciatxt,
                             d_ctc00m02.rspnom   ,
                             d_ctc00m02.patpprflg,
                             d_ctc00m02.srvnteflg,
                             d_ctc00m02.horsegsexinc,
                             d_ctc00m02.horsegsexfnl,
                             d_ctc00m02.horsabinc,
                             d_ctc00m02.horsabfnl,
                             d_ctc00m02.hordominc,
                             d_ctc00m02.hordomfnl,
                             d_ctc00m02.qldgracod,
                             d_ctc00m02.pstobs   ,
                             d_ctc00m02.prssitcod,
                             d_ctc00m02.vlrtabflg,
                             d_ctc00m02.prscootipcod,
                             d_ctc00m02.mpacidcod   ,
                             d_ctc00m02.intsrvrcbflg,
                             d_ctc00m02.rmesoctrfcod,
                             d_ctc00m02.frtrpnflg,
                             d_ctc00m02.risprcflg,
                             d_ctc00m02.celdddnum,
                             d_ctc00m02.celtelnum,
                             d_ctc00m02.lgdtip,
                             d_ctc00m02.lgdnum,
                             d_ctc00m02.lclltt,
                             d_ctc00m02.lcllgt,
                             d_ctc00m02.c24lclpdrcod,
                             d_ctc00m02.pisnum,
                             d_ctc00m02.nitnum,
                             d_ctc00m02.succod,
                             d_ctc00m02.pcpatvcod,
                             d_ctc00m02.simoptpstflg,
                             d_ctc00m02.pcpprscod,
                             d_ctc00m02.gstcdicod,
                             k_ctc00m02.pstcoddig
  
  
  
  # whenever error stop
  
  if sqlca.sqlcode <> 0  then
     display 'Erro na atualizacao do prestador: ', sqlca.sqlcode
     error 'Erro na atualizacao do prestador: ', sqlca.sqlcode,' / ',
           sqlca.sqlerrd[2]
     sleep 2
     rollback work
     initialize d_ctc00m02.*  to null
     initialize k_ctc00m02.*  to null
     return
  end if
  
  call ctc30m00_remove_caracteres(d_ctc00m02.socfavnom)
            returning d_ctc00m02.socfavnom
  

  update dpaksocorfav set ( socpgtopccod,
                            socfavnom,
                            pestip,
                            cgccpfnum,
                            cgcord,
                            cgccpfdig,
                            bcoctatip,
                            bcocod,
                            bcoagnnum,
                            bcoagndig,
                            bcoctanum,
                            bcoctadig,
                            nscdat,
                            sexcod)
                      =   ( d_ctc00m02.socpgtopccod,
                            d_ctc00m02.socfavnom,
                            d_ctc00m02.pestipfav,
                            d_ctc00m02.cgccpfnumfav,
                            d_ctc00m02.cgcordfav,
                            d_ctc00m02.cgccpfdigfav,
                            d_ctc00m02.bcoctatip,
                            d_ctc00m02.bcocod,
                            d_ctc00m02.bcoagnnum,
                            d_ctc00m02.bcoagndig,
                            d_ctc00m02.bcoctanum,
                            d_ctc00m02.bcoctadig,
                            d_ctc00m02.nscdat,
                            d_ctc00m02.sexcod)
          where pstcoddig = k_ctc00m02.pstcoddig

  if sqlca.sqlcode <> 0  then
     error " Erro (", sqlca.sqlcode, ") na alteracao favorecido.",
           " AVISE A INFORMATICA!"
     rollback work
     initialize d_ctc00m02.*  to null
     initialize k_ctc00m02.*  to null
     return
  end if
  

  ## Verifica se alguma das informacoes foi alterada     ##
  ## e concatena na descricao para gravacao do historico ##
  let l_prshstdes = null

  if (d_ctc00m02.nomrazsoc is     null and lr_ctc00m02_ant.nomrazsoc is not null) or
     (d_ctc00m02.nomrazsoc is not null and lr_ctc00m02_ant.nomrazsoc is null)     or
     (d_ctc00m02.nomrazsoc <> lr_ctc00m02_ant.nomrazsoc)                         then
       let l_prshstdes = l_prshstdes clipped,
          " Razao Social alterada de [",
          lr_ctc00m02_ant.nomrazsoc clipped,"] para [",
          d_ctc00m02.nomrazsoc clipped,"],"
          
       let l_enviaEmailSap = true  
       
       if l_texto_SAP is not null then 
          let l_texto_SAP = l_texto_SAP clipped, 
          "<br/> Razao Social alterada de <b><font color=blue>",lr_ctc00m02_ant.nomrazsoc clipped,
          "</font></b> para <b><font color=red>",d_ctc00m02.nomrazsoc clipped,"</font></b>"
       else
          let l_texto_SAP = "Razao Social alterada de <b><font color=blue>",lr_ctc00m02_ant.nomrazsoc clipped,
          "</font></b> para <b><font color=red>",d_ctc00m02.nomrazsoc clipped,"</font></b>"
       end if
          
  end if

  if (d_ctc00m02.nomgrr is     null  and  lr_ctc00m02_ant.nomgrr is not null)  or
     (d_ctc00m02.nomgrr is not null  and  lr_ctc00m02_ant.nomgrr is    null)   or
     (d_ctc00m02.nomgrr <> lr_ctc00m02_ant.nomgrr)                            then
      let l_prshstdes = l_prshstdes clipped,
          " Nome Guerra alterado de [",
          lr_ctc00m02_ant.nomgrr clipped,"] para [",
          d_ctc00m02.nomgrr clipped,"],"
  end if

  if  (d_ctc00m02.pestip is     null and  lr_ctc00m02_ant.pestip is not null) or
      (d_ctc00m02.pestip is not null and  lr_ctc00m02_ant.pestip is     null) or
      (d_ctc00m02.pestip             <>   lr_ctc00m02_ant.pestip)            then
      let l_prshstdes = l_prshstdes clipped, " Tipo Pessoa alterado de [",
          lr_ctc00m02_ant.pestip clipped,"] para [",
          d_ctc00m02.pestip clipped,"],"
  end if

  if  (d_ctc00m02.cgccpfnum is null      and  lr_ctc00m02_ant.cgccpfnum is not null) or
      (d_ctc00m02.cgccpfnum is not null  and  lr_ctc00m02_ant.cgccpfnum is     null) or
      (d_ctc00m02.cgccpfnum               <>  lr_ctc00m02_ant.cgccpfnum)            then
      let l_prshstdes = l_prshstdes clipped,
          " CGC/CPF alterado de [",
          lr_ctc00m02_ant.cgccpfnum clipped,"] para [",
          d_ctc00m02.cgccpfnum clipped,"],"
  end if

  if  (d_ctc00m02.cgcord is     null  and lr_ctc00m02_ant.cgcord is not null) or
      (d_ctc00m02.cgcord is not null  and lr_ctc00m02_ant.cgcord is     null) or
      (d_ctc00m02.cgcord           <>     lr_ctc00m02_ant.cgcord)             then
      let l_prshstdes = l_prshstdes clipped,
          " Filial do CGC alterado de [",
          lr_ctc00m02_ant.cgcord clipped,"] para [",
          d_ctc00m02.cgcord clipped,"],"
  end if

  if  (d_ctc00m02.cgccpfdig is     null and  lr_ctc00m02_ant.cgccpfdig is not null)  or
      (d_ctc00m02.cgccpfdig is not null and  lr_ctc00m02_ant.cgccpfdig is     null)  or
      (d_ctc00m02.cgccpfdig             <>   lr_ctc00m02_ant.cgccpfdig)             then
      let l_prshstdes = l_prshstdes clipped,
          " Digito CGC/CPF alterado de [",
          lr_ctc00m02_ant.cgccpfdig clipped,"] para [",
          d_ctc00m02.cgccpfdig clipped,"],"
  end if

  if  (d_ctc00m02.muninsnum is     null    and lr_ctc00m02_ant.muninsnum is not null) or
      (d_ctc00m02.muninsnum is not null    and lr_ctc00m02_ant.muninsnum is     null) or
      (d_ctc00m02.muninsnum              <> lr_ctc00m02_ant.muninsnum)               then
      let l_prshstdes = l_prshstdes clipped, " Inscr.Mun. alterada de [",
          lr_ctc00m02_ant.muninsnum clipped,"] para [", d_ctc00m02.muninsnum clipped,"],"
          
      let l_enviaEmailSap = true
      
      if l_texto_SAP is not null then 
         let l_texto_SAP = l_texto_SAP clipped, 
         "<br/> Inscr.Mun. alterada de <b><font color=blue>",lr_ctc00m02_ant.muninsnum clipped,
         "</font></b> para <b><font color=red>",d_ctc00m02.muninsnum clipped,"</font></b>"
      else
         let l_texto_SAP = "Inscr.Mun. alterada de <b><font color=blue>",lr_ctc00m02_ant.muninsnum clipped,
         "</font></b> para <b><font color=red>",d_ctc00m02.muninsnum clipped,"</font></b>"
      end if 
          
  end if

  if  (d_ctc00m02.lgdtip is     null    and lr_ctc00m02_ant.lgdtip is not null) or
      (d_ctc00m02.lgdtip is not null    and lr_ctc00m02_ant.lgdtip is     null) or
      (d_ctc00m02.lgdtip                <>  lr_ctc00m02_ant.lgdtip)            then
      let l_prshstdes = l_prshstdes clipped, " Tipo Logradouro alterada de [",
                        lr_ctc00m02_ant.lgdtip clipped,"] para [",
                        d_ctc00m02.lgdtip clipped,"],"
  end if

  if  (d_ctc00m02.endlgd is     null  and  lr_ctc00m02_ant.endlgd is not null)   or
      (d_ctc00m02.endlgd is not null  and  lr_ctc00m02_ant.endlgd is     null)   or
      (d_ctc00m02.endlgd              <> lr_ctc00m02_ant.endlgd)                then
      let l_prshstdes = l_prshstdes clipped," Endereco alterado de [",
          lr_ctc00m02_ant.endlgd clipped,"] para [",
          d_ctc00m02.endlgd clipped,"],"
  end if

  if  (d_ctc00m02.endcmp is null      and lr_ctc00m02_ant.endcmp is not null)  or
      (d_ctc00m02.endcmp is not null  and lr_ctc00m02_ant.endcmp is     null)  or
      (d_ctc00m02.endcmp               <> lr_ctc00m02_ant.endcmp)             then
      let l_prshstdes = l_prshstdes clipped, " Complemento do Endereco alterado de [",
          lr_ctc00m02_ant.endcmp clipped,"] para [", d_ctc00m02.endcmp clipped,"]."
  end if

  if  (d_ctc00m02.lgdnum is null      and lr_ctc00m02_ant.lgdnum is not null)  or
      (d_ctc00m02.lgdnum is not null  and lr_ctc00m02_ant.lgdnum is     null)  or
      (d_ctc00m02.lgdnum               <> lr_ctc00m02_ant.lgdnum)             then
      let l_prshstdes = l_prshstdes clipped, " Numero do Endereco alterado de [",
          lr_ctc00m02_ant.lgdnum clipped,"] para [", d_ctc00m02.lgdnum clipped,"]."
  end if

  if  (d_ctc00m02.endbrr is     null  and lr_ctc00m02_ant.endbrr is not null)   or
      (d_ctc00m02.endbrr is not null  and lr_ctc00m02_ant.endbrr is     null)   or
      (d_ctc00m02.endbrr              <> lr_ctc00m02_ant.endbrr)               then
      let l_prshstdes = l_prshstdes clipped, " Bairro alterado de [",
          lr_ctc00m02_ant.endbrr clipped,"] para [",
          d_ctc00m02.endbrr clipped,"],"
  end if

  if  (d_ctc00m02.endcid is     null  and lr_ctc00m02_ant.endcid is not null)   or
      (d_ctc00m02.endcid is not null  and lr_ctc00m02_ant.endcid is     null)   or
      (d_ctc00m02.endcid              <> lr_ctc00m02_ant.endcid )              then
      let l_prshstdes = l_prshstdes clipped," Cidade alterada de [",
          lr_ctc00m02_ant.endcid clipped,"] para [",
          d_ctc00m02.endcid clipped,"],"
  end if

  if  (d_ctc00m02.endufd is     null  and  lr_ctc00m02_ant.endufd is not null)   or
      (d_ctc00m02.endufd is not null  and  lr_ctc00m02_ant.endufd is     null)   or
      (d_ctc00m02.endufd              <> lr_ctc00m02_ant.endufd)               then
      let l_prshstdes = l_prshstdes clipped, " UF alterada de [",
          lr_ctc00m02_ant.endufd clipped,"] para [",
          d_ctc00m02.endufd clipped,"],"
  end if

  if  (d_ctc00m02.endcep is     null  and lr_ctc00m02_ant.endcep is not null)   or
      (d_ctc00m02.endcep is not null  and lr_ctc00m02_ant.endcep is     null)   or
      (d_ctc00m02.endcep              <> lr_ctc00m02_ant.endcep)               then
      let l_prshstdes = l_prshstdes clipped, " CEP alterado de [",
          lr_ctc00m02_ant.endcep using "&&&&&","] para [",d_ctc00m02.endcep using "&&&&&","],"
  end if

  if  (d_ctc00m02.endcepcmp is     null  and lr_ctc00m02_ant.endcepcmp is not null)   or
      (d_ctc00m02.endcepcmp is not null  and lr_ctc00m02_ant.endcepcmp is     null)   or
      (d_ctc00m02.endcepcmp <> lr_ctc00m02_ant.endcepcmp)                            then
      let l_prshstdes = l_prshstdes clipped,"Complemento do CEP alterado de [",
          lr_ctc00m02_ant.endcepcmp using "&&&","] para [",d_ctc00m02.endcepcmp using "&&&","],"
  end if

  if  (d_ctc00m02.dddcod is     null  and lr_ctc00m02_ant.dddcod is not null)   or
      (d_ctc00m02.dddcod is not null  and lr_ctc00m02_ant.dddcod is     null)   or
      (d_ctc00m02.dddcod              <> lr_ctc00m02_ant.dddcod)               then
      let l_prshstdes = l_prshstdes clipped, " DDD alterado de [",
          lr_ctc00m02_ant.dddcod clipped,"] para [",
          d_ctc00m02.dddcod clipped,"],"
  end if

  if  (d_ctc00m02.teltxt is     null  and lr_ctc00m02_ant.teltxt is not null)   or
      (d_ctc00m02.teltxt is not null  and lr_ctc00m02_ant.teltxt  is     null)   or
      (d_ctc00m02.teltxt              <> lr_ctc00m02_ant.teltxt)                then
      let l_prshstdes = l_prshstdes clipped, " Telefone alterado de [",
          lr_ctc00m02_ant.teltxt clipped,"] para [",
          d_ctc00m02.teltxt clipped,"],"
  end if

  if  (d_ctc00m02.faxnum is     null  and lr_ctc00m02_ant.faxnum is not null)   or
      (d_ctc00m02.faxnum is not null  and lr_ctc00m02_ant.faxnum is     null)   or
      (d_ctc00m02.faxnum              <> lr_ctc00m02_ant.faxnum)               then
      let l_prshstdes = l_prshstdes clipped," Fax alterado de [",
          lr_ctc00m02_ant.faxnum clipped,"] para [",
          d_ctc00m02.faxnum clipped,"],"
  end if

  if  (d_ctc00m02.celdddnum is     null  and  lr_ctc00m02_ant.celdddnum is not null)   or
      (d_ctc00m02.celdddnum is not null  and  lr_ctc00m02_ant.celdddnum is     null)   or
      (d_ctc00m02.celdddnum              <>   lr_ctc00m02_ant.celdddnum)              then
      let l_prshstdes = l_prshstdes clipped, " DDD Celular alterado de [",
          lr_ctc00m02_ant.celdddnum clipped,"] para [", d_ctc00m02.celdddnum clipped,"],"
  end if

  if  (d_ctc00m02.celtelnum is null      and lr_ctc00m02_ant.celtelnum is not null)  or
      (d_ctc00m02.celtelnum is not null  and lr_ctc00m02_ant.celtelnum is     null)  or
      (d_ctc00m02.celtelnum               <> lr_ctc00m02_ant.celtelnum)             then
      let l_prshstdes = l_prshstdes clipped, " Celular alterado de [",
          lr_ctc00m02_ant.celtelnum clipped,"] para [", d_ctc00m02.celtelnum clipped,"]."
  end if

  if  (d_ctc00m02.pptnom is     null  and  lr_ctc00m02_ant.pptnom is not null)   or
      (d_ctc00m02.pptnom is not null  and  lr_ctc00m02_ant.pptnom is     null)   or
      (d_ctc00m02.pptnom              <> lr_ctc00m02_ant.pptnom)               then
      let l_prshstdes = l_prshstdes clipped, " Proprietario alterado de [",
          lr_ctc00m02_ant.pptnom clipped,"] para [",
          d_ctc00m02.pptnom clipped,"],"
  end if

  if (d_ctc00m02.socpgtopccod is null     and lr_ctc00m02_ant.socpgtopccod is not null)  or
     (d_ctc00m02.socpgtopccod is not null and lr_ctc00m02_ant.socpgtopccod is null)      or
     (d_ctc00m02.socpgtopccod             <>  lr_ctc00m02_ant.socpgtopccod)              then
     let l_prshstdes = l_prshstdes clipped,	" Opcao de Pagamento alterado de [",
     lr_ctc00m02_ant.socpgtopccod clipped,"-",lr_ctc00m02_ant.socpgtopcdes clipped,
     "] para [",	d_ctc00m02.socpgtopccod clipped,"-",d_ctc00m02.socpgtopcdes clipped,"]."
  end if

  if  (d_ctc00m02.outciatxt is     null  and lr_ctc00m02_ant.outciatxt is not null)   or
      (d_ctc00m02.outciatxt is not null  and lr_ctc00m02_ant.outciatxt is     null)   or
      (d_ctc00m02.outciatxt              <> lr_ctc00m02_ant.outciatxt)               then
      let l_prshstdes = l_prshstdes clipped, " Forma Pagto alterado de [",
          lr_ctc00m02_ant.outciatxt clipped,"] para [",
          d_ctc00m02.outciatxt clipped,"],"
  end if

  if  (d_ctc00m02.rspnom is     null  and lr_ctc00m02_ant.rspnom is not null)   or
      (d_ctc00m02.rspnom is not null  and lr_ctc00m02_ant.rspnom is     null)   or
      (d_ctc00m02.rspnom              <> lr_ctc00m02_ant.rspnom)               then
      let l_prshstdes = l_prshstdes clipped, " Contato alterado de [",
          lr_ctc00m02_ant.rspnom clipped,"] para [",
          d_ctc00m02.rspnom clipped,"],"
  end if

  if  (d_ctc00m02.patpprflg is     null  and lr_ctc00m02_ant.patpprflg is not null)   or
      (d_ctc00m02.patpprflg is not null  and lr_ctc00m02_ant.patpprflg is     null)   or
      (d_ctc00m02.patpprflg              <> lr_ctc00m02_ant.patpprflg)              then
      let l_prshstdes = l_prshstdes clipped,  " Flag Patio Proprio alterado de [",
          lr_ctc00m02_ant.patpprflg clipped,"] para [",
          d_ctc00m02.patpprflg clipped,"],"
  end if

  if  (d_ctc00m02.srvnteflg is     null  and lr_ctc00m02_ant.srvnteflg is not null)   or
      (d_ctc00m02.srvnteflg is not null  and lr_ctc00m02_ant.srvnteflg is     null)   or
      (d_ctc00m02.srvnteflg              <> lr_ctc00m02_ant.srvnteflg)               then
      let l_prshstdes = l_prshstdes clipped,
          " Flag Atd.24h alterado de [",
          lr_ctc00m02_ant.srvnteflg clipped,"] para [",
          d_ctc00m02.srvnteflg clipped,"],"
  end if

  if  (d_ctc00m02.horsegsexinc is     null  and lr_ctc00m02_ant.horsegsexinc is not null)   or
      (d_ctc00m02.horsegsexinc is not null  and lr_ctc00m02_ant.horsegsexinc is     null)   or
      (d_ctc00m02.horsegsexinc              <> lr_ctc00m02_ant.horsegsexinc)               then
      let l_prshstdes = l_prshstdes clipped,
          " Hor.Inic. Seg a Sex alterado de [",
          lr_ctc00m02_ant.horsegsexinc clipped,"] para [",
          d_ctc00m02.horsegsexinc clipped,"],"
  end if

  if  (d_ctc00m02.horsegsexfnl is     null  and lr_ctc00m02_ant.horsegsexfnl is not null)   or
      (d_ctc00m02.horsegsexfnl is not null  and lr_ctc00m02_ant.horsegsexfnl is     null)   or
      (d_ctc00m02.horsegsexfnl              <> lr_ctc00m02_ant.horsegsexfnl)               then
      let l_prshstdes = l_prshstdes clipped, " Hor.Final Seg a Sex alterado de [",
          lr_ctc00m02_ant.horsegsexfnl clipped,"] para [",
          d_ctc00m02.horsegsexfnl clipped,"],"
  end if

  if  (d_ctc00m02.horsabinc is     null  and lr_ctc00m02_ant.horsabinc is not null)   or
      (d_ctc00m02.horsabinc is not null  and lr_ctc00m02_ant.horsabinc is     null)   or
      (d_ctc00m02.horsabinc              <> lr_ctc00m02_ant.horsabinc)               then
      let l_prshstdes = l_prshstdes clipped, " Hor.Inic. Sabado alterado de [",
          lr_ctc00m02_ant.horsabinc clipped,"] para [", d_ctc00m02.horsabinc clipped,"],"
  end if

  if  (d_ctc00m02.horsabfnl is     null  and lr_ctc00m02_ant.horsabfnl is not null)   or
      (d_ctc00m02.horsabfnl is not null  and lr_ctc00m02_ant.horsabfnl is     null)   or
      (d_ctc00m02.horsabfnl              <> lr_ctc00m02_ant.horsabfnl)               then
      let l_prshstdes = l_prshstdes clipped, " Hor.Final Sabado alterado de [",
          lr_ctc00m02_ant.horsabfnl clipped,"] para [",d_ctc00m02.horsabfnl clipped,"],"
  end if

  if  (d_ctc00m02.hordominc is     null  and lr_ctc00m02_ant.hordominc is not null)   or
      (d_ctc00m02.hordominc is not null  and lr_ctc00m02_ant.hordominc is     null)   or
      (d_ctc00m02.hordominc              <> lr_ctc00m02_ant.hordominc)               then
      let l_prshstdes = l_prshstdes clipped,  " Hor.Inic. Domingo alterado de [",
          lr_ctc00m02_ant.hordominc clipped,"] para [", d_ctc00m02.hordominc clipped,"],"
  end if

  if  (d_ctc00m02.hordomfnl is     null  and  lr_ctc00m02_ant.hordomfnl is not null)   or
      (d_ctc00m02.hordomfnl is not null  and  lr_ctc00m02_ant.hordomfnl is     null)   or
      (d_ctc00m02.hordomfnl              <> lr_ctc00m02_ant.hordomfnl)                then
      let l_prshstdes = l_prshstdes clipped, " Hor.Final Domingo alterado de [",
          lr_ctc00m02_ant.hordomfnl clipped,"] para [", d_ctc00m02.hordomfnl clipped,"],"
  end if

  if  (d_ctc00m02.qldgracod is     null  and  lr_ctc00m02_ant.qldgracod is not null)   or
      (d_ctc00m02.qldgracod is not null  and  lr_ctc00m02_ant.qldgracod is     null)   or
      (d_ctc00m02.qldgracod              <> lr_ctc00m02_ant.qldgracod)               then
      let l_prshstdes = l_prshstdes clipped, " Qualidade alterada de [",
          lr_ctc00m02_ant.qldgracod clipped,"] para [",
          d_ctc00m02.qldgracod clipped,"],"
  end if

  if  (d_ctc00m02.pstobs is     null  and  lr_ctc00m02_ant.pstobs is not null)   or
      (d_ctc00m02.pstobs is not null  and  lr_ctc00m02_ant.pstobs is     null)   or
      (d_ctc00m02.pstobs              <> lr_ctc00m02_ant.pstobs)               then
      let l_prshstdes = l_prshstdes clipped, " Observacoes alterada de [",
          lr_ctc00m02_ant.pstobs clipped,"] para [", d_ctc00m02.pstobs clipped,"],"
  end if

  if  (d_ctc00m02.prssitcod is     null  and  lr_ctc00m02_ant.prssitcod is not null)   or
      (d_ctc00m02.prssitcod is not null  and  lr_ctc00m02_ant.prssitcod is     null)   or
      (d_ctc00m02.prssitcod              <> lr_ctc00m02_ant.prssitcod)               then
      let l_prshstdes = l_prshstdes clipped, " Situacao alterada de [",
          lr_ctc00m02_ant.prssitcod clipped,"] para [",  d_ctc00m02.prssitcod clipped,"],"
  end if

  if  (d_ctc00m02.vlrtabflg is     null  and  lr_ctc00m02_ant.vlrtabflg is not null)   or
      (d_ctc00m02.vlrtabflg is not null  and  lr_ctc00m02_ant.vlrtabflg is     null)   or
      (d_ctc00m02.vlrtabflg              <> lr_ctc00m02_ant.vlrtabflg)               then
      let l_prshstdes = l_prshstdes clipped,      " Flag Usa Tabela alterada de [",
          lr_ctc00m02_ant.vlrtabflg clipped,"] para [", d_ctc00m02.vlrtabflg clipped,"],"
  end if

  if  (d_ctc00m02.prscootipcod is     null  and  lr_ctc00m02_ant.prscootipcod is not null)   or
      (d_ctc00m02.prscootipcod is not null  and  lr_ctc00m02_ant.prscootipcod is     null)   or
      (d_ctc00m02.prscootipcod <> lr_ctc00m02_ant.prscootipcod )              then
      let l_prshstdes = l_prshstdes clipped, " Tp.Coop alterada de [",
          lr_ctc00m02_ant.prscootipcod clipped,"] para [", d_ctc00m02.prscootipcod clipped,"],"
  end if

  if  (d_ctc00m02.intsrvrcbflg is     null  and lr_ctc00m02_ant.intsrvrcbflg is not null)   or
      (d_ctc00m02.intsrvrcbflg is not null  and lr_ctc00m02_ant.intsrvrcbflg is     null)   or
      (d_ctc00m02.intsrvrcbflg <> lr_ctc00m02_ant.intsrvrcbflg )              then
      let l_prshstdes = l_prshstdes clipped,    " Acionamento alterado de [",
          lr_ctc00m02_ant.intsrvrcbflg clipped,"] para [", d_ctc00m02.intsrvrcbflg clipped,"],"
  end if

  if  (d_ctc00m02.rmesoctrfcod is     null  and lr_ctc00m02_ant.rmesoctrfcod is not null)   or
      (d_ctc00m02.rmesoctrfcod is not null  and lr_ctc00m02_ant.rmesoctrfcod is     null)   or
      (d_ctc00m02.rmesoctrfcod <> lr_ctc00m02_ant.rmesoctrfcod )              then
      let l_prshstdes = l_prshstdes clipped,  " Tar.RE alterada de [",
          lr_ctc00m02_ant.rmesoctrfcod clipped,"] para [", d_ctc00m02.rmesoctrfcod clipped,"],"
  end if

  if  (d_ctc00m02.risprcflg is     null  and  lr_ctc00m02_ant.risprcflg is not null)   or
      (d_ctc00m02.risprcflg is not null  and  lr_ctc00m02_ant.risprcflg is     null)   or
      (d_ctc00m02.risprcflg <> lr_ctc00m02_ant.risprcflg)                            then
      let l_prshstdes = l_prshstdes clipped, " Flag Preenche RIS alterada de [",
          lr_ctc00m02_ant.risprcflg clipped,"] para [",  d_ctc00m02.risprcflg clipped,"],"
  end if


  if (d_ctc00m02.socfavnom is null     and lr_ctc00m02_ant.socfavnom is not null)  or
     (d_ctc00m02.socfavnom is not null and lr_ctc00m02_ant.socfavnom is null)      or
     (d_ctc00m02.socfavnom             <>  lr_ctc00m02_ant.socfavnom)              then
     let l_prshstdes = l_prshstdes clipped,	" Nome Favorecido alterado de [",
     lr_ctc00m02_ant.socfavnom clipped,"] para [",	d_ctc00m02.socfavnom clipped,"]."
  end if

  if (d_ctc00m02.pestipfav is null     and lr_ctc00m02_ant.pestipfav is not null)  or
     (d_ctc00m02.pestipfav is not null and lr_ctc00m02_ant.pestipfav is null)      or
     (d_ctc00m02.pestipfav             <>  lr_ctc00m02_ant.pestipfav)              then
     let l_prshstdes = l_prshstdes clipped,	" Tipo Pessoa alterado de [",
     lr_ctc00m02_ant.pestipfav clipped,"] para [",	d_ctc00m02.pestipfav clipped,"]."
  end if

  if (d_ctc00m02.cgccpfnumfav is null      and lr_ctc00m02_ant.cgccpfnumfav is not null)  or
      (d_ctc00m02.cgccpfnumfav is not null and lr_ctc00m02_ant.cgccpfnumfav is null)      or
      (d_ctc00m02.cgccpfnumfav             <>  lr_ctc00m02_ant.cgccpfnumfav)              then
      let l_prshstdes = l_prshstdes clipped,	" Cgc/Cpf Favorecido alterado de [",
      lr_ctc00m02_ant.cgccpfnumfav clipped,"] para [",	d_ctc00m02.cgccpfnumfav clipped,"]."
  end if

  if (d_ctc00m02.cgcordfav is null      and lr_ctc00m02_ant.cgcordfav is not null)  or
      (d_ctc00m02.cgcordfav is not null and lr_ctc00m02_ant.cgcordfav is null)      or
      (d_ctc00m02.cgcordfav             <>  lr_ctc00m02_ant.cgcordfav)              then
      let l_prshstdes = l_prshstdes clipped,	" Filial Cgc/Cpf Favorecido alterado de [",
      lr_ctc00m02_ant.cgcordfav clipped,"] para [",	d_ctc00m02.cgcordfav clipped,"]."
  end if

  if (d_ctc00m02.cgccpfdigfav is null      and lr_ctc00m02_ant.cgccpfdigfav is not null)  or
      (d_ctc00m02.cgccpfdigfav is not null and lr_ctc00m02_ant.cgccpfdigfav is null)      or
      (d_ctc00m02.cgccpfdigfav             <>  lr_ctc00m02_ant.cgccpfdigfav)              then
      let l_prshstdes = l_prshstdes clipped,	" Digito Cgc/Cpf Favorecido alterado de [",
      lr_ctc00m02_ant.cgccpfdigfav clipped,"] para [",	d_ctc00m02.cgccpfdigfav clipped,"]."
  end if

  if (d_ctc00m02.bcoctatip is null     and lr_ctc00m02_ant.bcoctatip is not null)  or
     (d_ctc00m02.bcoctatip is not null and lr_ctc00m02_ant.bcoctatip is null)      or
     (d_ctc00m02.bcoctatip             <>  lr_ctc00m02_ant.bcoctatip)              then
     let l_prshstdes = l_prshstdes clipped,	" Tipo de Conta alterado de [",
     lr_ctc00m02_ant.bcoctatip clipped,"] para [",	d_ctc00m02.bcoctatip clipped,"]."
  end if

  if (d_ctc00m02.bcocod is null     and lr_ctc00m02_ant.bcocod is not null) or
     (d_ctc00m02.bcocod is not null and lr_ctc00m02_ant.bcocod is null)     or
     (d_ctc00m02.bcocod             <>  lr_ctc00m02_ant.bcocod)            then
     let l_prshstdes = l_prshstdes clipped,	" Numero do Banco alterado de [",
     lr_ctc00m02_ant.bcocod clipped,"] para [",d_ctc00m02.bcocod  clipped,"]."
     
     let l_enviaSap = true
     
  end if

  if  (d_ctc00m02.bcoagnnum is null     and  lr_ctc00m02_ant.bcoagnnum is not null) or
      (d_ctc00m02.bcoagnnum is not null and  lr_ctc00m02_ant.bcoagnnum is null)     or
      (d_ctc00m02.bcoagnnum             <>   lr_ctc00m02_ant.bcoagnnum)            then
      let l_prshstdes = l_prshstdes clipped,	" Codigo da Agencia alterado de [",
      lr_ctc00m02_ant.bcoagnnum clipped,"] para [",d_ctc00m02.bcoagnnum clipped,"]."
      
      let l_enviaSap = true
      
  end if

  if  (d_ctc00m02.bcoagndig is null     and lr_ctc00m02_ant.bcoagndig is not null) or
      (d_ctc00m02.bcoagndig is not null and lr_ctc00m02_ant.bcoagndig is null)     or
      (d_ctc00m02.bcoagndig             <>  lr_ctc00m02_ant.bcoagndig)            then
      let l_prshstdes = l_prshstdes clipped,	" Digito da Agencia alterado de [",
      lr_ctc00m02_ant.bcoagndig clipped,"] para [",	d_ctc00m02.bcoagndig clipped,"]."
      
      let l_enviaSap = true
      
  end if

  if  (d_ctc00m02.bcoctanum is null       and  lr_ctc00m02_ant.bcoctanum is not null) or
      (d_ctc00m02.bcoctanum is not null   and  lr_ctc00m02_ant.bcoctanum is null)     or
      (d_ctc00m02.bcoctanum               <>   lr_ctc00m02_ant.bcoctanum)            then
      let l_prshstdes = l_prshstdes clipped,	" Numero da Conta alterado de [",
      lr_ctc00m02_ant.bcoctanum clipped,"] para [",d_ctc00m02.bcoctanum clipped,"]."
      
      let l_enviaSap = true
      
  end if

  if (d_ctc00m02.bcoctadig is null      and  lr_ctc00m02_ant.bcoctadig is not null)  or
     (d_ctc00m02.bcoctadig is not null  and  lr_ctc00m02_ant.bcoctadig is     null)  or
     (d_ctc00m02.bcoctadig              <>   lr_ctc00m02_ant.bcoctadig)             then
     let l_prshstdes = l_prshstdes clipped,	" Digito da Conta alterado de [",
     lr_ctc00m02_ant.bcoctadig clipped,"] para [",d_ctc00m02.bcoctadig clipped,"]."
     
     let l_enviaSap = true
     
  end if
  
  if (d_ctc00m02.pcpprscod is null      and  lr_ctc00m02_ant.pcpprscod is not null)  or
     (d_ctc00m02.pcpprscod is not null  and  lr_ctc00m02_ant.pcpprscod is     null)  or
     (d_ctc00m02.pcpprscod              <>   lr_ctc00m02_ant.pcpprscod)             then
     let l_prshstdes = l_prshstdes clipped,	" Pst principal alterado de [",
     lr_ctc00m02_ant.pcpprscod clipped,"] para [",d_ctc00m02.pcpprscod clipped,"]."
  end if
  
  if (d_ctc00m02.gstcdicod is null      and  lr_ctc00m02_ant.gstcdicod is not null)  or
     (d_ctc00m02.gstcdicod is not null  and  lr_ctc00m02_ant.gstcdicod is     null)  or
     (d_ctc00m02.gstcdicod              <>   lr_ctc00m02_ant.gstcdicod)             then
     let l_prshstdes = l_prshstdes clipped,	" Cadeia resp alterado de [",
     lr_ctc00m02_ant.gstcdicod clipped,"] para [",d_ctc00m02.gstcdicod clipped,"]."
  end if

  if  d_ctc00m02.pisnum <> lr_ctc00m02_ant.pisnum then
      let l_prshstdes = l_prshstdes clipped,
          " PIS alterado de [",
          lr_ctc00m02_ant.pisnum clipped,"] para [",
          d_ctc00m02.pisnum clipped,"]."
       
      let l_enviaEmailSap = true    
      
      if l_texto_SAP is not null then 
         let l_texto_SAP = l_texto_SAP clipped, 
         "<br/> PIS/NIT alterado de <b><font color=blue>",lr_ctc00m02_ant.pisnum clipped,
         "</font></b> para <b><font color=red>",d_ctc00m02.pisnum clipped,"</font></b>"
      else
         let l_texto_SAP = "PIS/NIT alterado de <b><font color=blue>",lr_ctc00m02_ant.pisnum clipped,
         "</font></b> para <b><font color=red>",d_ctc00m02.pisnum clipped,"</font></b>"
      end if 
        
  end if

  # if  d_ctc00m02.nitnum <> lr_ctc00m02_ant.nitnum then
  #     let l_prshstdes = l_prshstdes clipped,
  #         " NIT alterado de [",
  #         lr_ctc00m02_ant.nitnum clipped,"] para [",
  #         d_ctc00m02.nitnum clipped,"]."
  # end if
  
  if  d_ctc00m02.succod <> lr_ctc00m02_ant.succod then
      let l_prshstdes = l_prshstdes clipped,
          " Sucursal alterada de [",
          lr_ctc00m02_ant.succod clipped,"] para [",
          d_ctc00m02.succod clipped,"]."
  end if
  
  if  d_ctc00m02.pcpatvcod <> lr_ctc00m02_ant.pcpatvcod
      then
      let l_prshstdes = l_prshstdes clipped,
          " Ativ. principal alterada de [",
          lr_ctc00m02_ant.pcpatvcod clipped,"] para [",
          d_ctc00m02.pcpatvcod clipped,"]."
          
      call ctd40g00_atualiza_usr_emp(k_ctc00m02.pstcoddig)
           returning lr_ret.errcod,
                     lr_ret.errmsg        

  end if
  
  if  d_ctc00m02.simoptpstflg <> lr_ctc00m02_ant.simoptpstflg
      then
      let l_prshstdes = l_prshstdes clipped,
          " Flag optante simples alterado de [",
          lr_ctc00m02_ant.simoptpstflg clipped,"] para [",
          d_ctc00m02.simoptpstflg clipped,"]."
  end if
  
  #Alteração realizada por Robert Lima
  if d_ctc00m02.frtrpnflg  <> lr_ctc00m02_ant.frtrpnflg then
      let l_prshstdes = l_prshstdes clipped,
          "Responsavel alterado de[",
          lr_ctc00m02_ant.frtrpnflg clipped,"] para [",
          d_ctc00m02.frtrpnflg clipped,"]."
  end if
         
  if d_ctc00m02.nscdat  <> lr_ctc00m02_ant.nscdat then
      let l_prshstdes = l_prshstdes clipped,
          "Data de nascimento Favorecido alterada de[",
          lr_ctc00m02_ant.nscdat clipped,"] para [",
          d_ctc00m02.nscdat clipped,"]."
  end if
  
  if d_ctc00m02.sexcod  <> lr_ctc00m02_ant.sexcod then
      let l_prshstdes = l_prshstdes clipped,
          "Sexo do Favorecido alterado de[",
          lr_ctc00m02_ant.sexcod clipped,"] para [",
          d_ctc00m02.sexcod clipped,"]."
  end if       
         
         
  #Retira a virgula do final da string (se houver),
  #coloca o ponto e grava na tabela de historico
  let l_length = length(l_prshstdes clipped)
  if  l_prshstdes is not null and l_length > 0 then
      if  l_prshstdes[1] = " " then
          let l_prshstdes = l_prshstdes[2,l_length]
          let l_length = length(l_prshstdes clipped)
      end if

      if  l_prshstdes[l_length] = "," then
          let l_prshstdes = l_prshstdes[1,l_length - 1], "."
      end if

      call ctc00m02_grava_hist(k_ctc00m02.pstcoddig,l_prshstdes,'A')
  end if 
  
  #PSI-2012-23608 - Inicio
  for l_indice = 1 to 10
      
      if d_ctc00m02_end[l_indice].endlgd is null and l_indice > 1 then
         exit for
      end if
      
      open cctc00m02013 using d_ctc00m02.pstcoddig,d_ctc00m02_end[l_indice].endtipcod
      fetch cctc00m02013 into l_ret
      
      if sqlca.sqlcode = 100 then
      
         execute pctc00m02010 using d_ctc00m02.pstcoddig
                                  , d_ctc00m02_end[l_indice].endtipcod
                                  , d_ctc00m02_end[l_indice].lgdtip   
                                  , d_ctc00m02_end[l_indice].endlgd   
                                  , d_ctc00m02_end[l_indice].lgdnum   
                                  , d_ctc00m02_end[l_indice].lgdcmp   
                                  , d_ctc00m02_end[l_indice].endcep   
                                  , d_ctc00m02_end[l_indice].endcepcmp
                                  , d_ctc00m02_end[l_indice].endbrr   
                                  , d_ctc00m02_end[l_indice].endcid   
                                  , d_ctc00m02_end[l_indice].ufdsgl   
                                  , d_ctc00m02_end[l_indice].lclltt   
                                  , d_ctc00m02_end[l_indice].lcllgt   
         
         
         if sqlca.sqlcode <> 0 then
            error " Erro (", sqlca.sqlcode, ") alteracao de enderecos.",
                  " AVISE A INFORMATICA!"     
            rollback work     
            return
         end if
      else
      
         execute pctc00m02011 using d_ctc00m02_end[l_indice].lgdtip    
                                ,d_ctc00m02_end[l_indice].endlgd   
                                ,d_ctc00m02_end[l_indice].lgdnum   
                                ,d_ctc00m02_end[l_indice].lgdcmp   
                                ,d_ctc00m02_end[l_indice].endcep   
                                ,d_ctc00m02_end[l_indice].endcepcmp
                                ,d_ctc00m02_end[l_indice].endbrr   
                                ,d_ctc00m02_end[l_indice].endcid   
                                ,d_ctc00m02_end[l_indice].ufdsgl   
                                ,d_ctc00m02_end[l_indice].lclltt   
                                ,d_ctc00m02_end[l_indice].lcllgt   
                                ,d_ctc00m02.pstcoddig       
                                ,d_ctc00m02_end[l_indice].endtipcod
         if sqlca.sqlcode <> 0 then
            error " Erro (", sqlca.sqlcode, ") alteracao de enderecos.",
                  " AVISE A INFORMATICA!"     
            rollback work     
            return
         end if
      end if
      
      #Verifica a posição do end fiscal no array
      if d_ctc00m02_end[l_indice].domtipdes like "%FISCAL%" then
          let l_endfat = l_indice         
      end if      
      
      close cctc00m02013
  end for
  
  #atualiza o cadastro com a susursal retornada pela função do tributus
  if l_endfat is null or l_endfat = 0 then
     error "NAO FOI ENCONTRADO ENDERECO FISCAL. AVISE A INFORMATICA" sleep 2
  else   
     call cty10g00_obter_cidcod(d_ctc00m02_end[l_endfat].endcid, d_ctc00m02_end[l_endfat].ufdsgl)
           returning l_res,
                     l_msg,
                     l_mpacidcod
     
     if l_res = 0 then  
        call fcgtc801(1, l_mpacidcod)
              returning lr_saida_801.coderr      
                       ,lr_saida_801.msgerr      
                       ,lr_saida_801.ppssucnum   
                       ,lr_saida_801.etbnom      
                       ,lr_saida_801.etbcpjnum   
                       ,lr_saida_801.etblgddes   
                       ,lr_saida_801.etblgdnum   
                       ,lr_saida_801.etbcpldes   
                       ,lr_saida_801.etbbrrnom   
                       ,lr_saida_801.etbcepnum   
                       ,lr_saida_801.etbcidnom   
                       ,lr_saida_801.etbufdsgl   
                       ,lr_saida_801.etbiesnum   
                       ,lr_saida_801.etbmuninsnum  
        
        update dpaksocor set succod = lr_saida_801.ppssucnum
         where pstcoddig = d_ctc00m02.pstcoddig
        
     else
        error l_msg
     end if
  end if
  
  
  #PSI-2012-23608 - Fim
  whenever error stop

  commit work
  
  declare c_dparpstctd  cursor for
   select pstcoddig from dparpstctd
   where pstcoddig = d_ctc00m02.pstcoddig
  open c_dparpstctd
  fetch c_dparpstctd into d_ctc00m02.pstcoddig 
   
  if sqlca.sqlcode = notfound then
     call ctc00m21(d_ctc00m02.pstcoddig,0,d_ctc00m02.pestip,'I','P')
  else
     call ctc00m21(d_ctc00m02.pstcoddig,0,d_ctc00m02.pestip,'A','P')
  end if 
  
  close c_dparpstctd
  

  if d_ctc00m02.pestip <> 'F' then
     call ctc00m20('A',d_ctc00m02.pstcoddig, 0) #PSI circular 380
  end if

  call ctc20m07_obrigatorio(d_ctc00m02.pstcoddig,d_ctc00m02.rspnom)
     
  error " Alteracao efetuada com sucesso!"
  
  #Fornax-Quantum - Fim 
  if lr_ctc00m02_ant.simoptpstflg <> d_ctc00m02.simoptpstflg then 
  
     let l_aux_cnpjcpf = d_ctc00m02.cgccpfnum using '&&&&&&&&&'
  
     if d_ctc00m02.pestip = "J" then
        let l_aux_cnpjcpf =       l_aux_cnpjcpf[1,3]          
                             ,'.',l_aux_cnpjcpf[4,6]      
                             ,'.',l_aux_cnpjcpf[7,9]      
                             ,'/',d_ctc00m02.cgcord using '&&&&'  
                             ,'-',d_ctc00m02.cgccpfdig using '&&' 
     else 
        let l_aux_cnpjcpf =      l_aux_cnpjcpf[1,3]          
                            ,'.',l_aux_cnpjcpf[4,6]      
                            ,'.',l_aux_cnpjcpf[7,9]      
                            ,'-',d_ctc00m02.cgccpfdig using '&&'
     end if 
   
   let l_assunto = 'Divergencia no cadastro do optante simples'
      
    if lr_ctc00m02_ant.simoptpstflg = "N" then
       let l_corpoemail = "Prezado, <br/><br/> O prestador <b>", d_ctc00m02.pstcoddig clipped, "-",d_ctc00m02.nomrazsoc clipped, "</b>, registrado com o <b>CPF/CNPJ:",l_aux_cnpjcpf clipped,
                          "</b> alterou sua opcao de optante simples na OP da empresa ",g_issk.empcod clipped, "-Porto Seguro.<br/><br/> ",
                          "O Prestador alterou de Optante Simples: <b><font color=blue>SIM</font></b> para Optante Simples: <b><font color=red>NAO</font></b>. <br/><br/>",
                          "<b><i>Favor conferir o cadastro deste prestador no SAP, para que nao tenhamos problema com o pagamento do imposto para este prestador.</i></b>"
    else
        let l_corpoemail = "Prezado, <br/><br/> O prestador <b>", d_ctc00m02.pstcoddig clipped, "-",d_ctc00m02.nomrazsoc clipped, "</b>, registrado com o <b>CPF/CNPJ:",l_aux_cnpjcpf clipped,
                          "</b> alterou sua opcao de optante simples na OP da empresa ",g_issk.empcod clipped, "-Porto Seguro.<br/><br/> ",
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
      display "ERRO Email ", l_erro                                                               
  end if 
  
  
  if l_enviaEmailSap then
     
     let l_aux_cnpjcpf = d_ctc00m02.cgccpfnum using '&&&&&&&&&'
  
     if d_ctc00m02.pestip = "J" then
        let l_aux_cnpjcpf =       l_aux_cnpjcpf[1,3]          
                             ,'.',l_aux_cnpjcpf[4,6]      
                             ,'.',l_aux_cnpjcpf[7,9]      
                             ,'/',d_ctc00m02.cgcord using '&&&&'  
                             ,'-',d_ctc00m02.cgccpfdig using '&&' 
     else 
        let l_aux_cnpjcpf =      l_aux_cnpjcpf[1,3]          
                            ,'.',l_aux_cnpjcpf[4,6]      
                            ,'.',l_aux_cnpjcpf[7,9]      
                            ,'-',d_ctc00m02.cgccpfdig using '&&'
     end if 
     
    let l_assunto = 'Alteracao no cadastro do prestador'
      
    let l_corpoemail = "Prezado, <br/><br/> O prestador <b>", d_ctc00m02.pstcoddig clipped, "-",d_ctc00m02.nomrazsoc clipped, "</b>, registrado com o <b>CPF/CNPJ:",l_aux_cnpjcpf clipped,
                          "</b> teve as seguintes alteracoes em seu cadastro:<br/><br/>",l_texto_SAP clipped,
                          "<br/><br/><b><i>Favor conferir se os dados alterados irao impactar no pagamento deste prestador.</i></b>"
    let l_texto_html = "<html>",                                                                                                        
                         "<body>",                                                                                                    
                           "<br><font face=arial size=2>",l_corpoemail clipped,                                                                     
                            "<br><br>Porto Seguro Seguros<br>Porto Socorro"                                                          
                                                                                                                                         
              let l_erro = ctx22g00_envia_email_html("WDATC040" ,                                                                        
                                                     l_assunto,                                                                          
                                                     l_texto_html clipped)
      display "ERRO Email ", l_erro   
      
  end if 
  
  if l_enviaSap then
     whenever error continue                            
      declare c_opgitm_sel02 cursor with hold for       
      select ciaempcod                                  
        from dparpstemp                           
       where pstcoddig = d_ctc00m02.pstcoddig             
     whenever error stop                                
     
        foreach c_opgitm_sel02 into lr_ciaempcod           
          
          #Verifica se a OP e People ou SAP  Inicio  #Fornax-Quantum  
          call ffpgc377_verificarIntegracaoAtivaEmpresaRamo("034PTSOC",today,lr_ciaempcod, 0)  
               returning  mr_retSAP.stt                                                                 
                         ,mr_retSAP.msg     
                 
          display "mr_retSAP.stt ", mr_retSAP.stt
          display "mr_retSAP.msg ", mr_retSAP.msg                                                             
          
          if mr_retSAP.stt <> 0 then 
             call ctc00m02_carrega_var_global_sap(lr_ciaempcod)
          end if
        end foreach 
        #Fornax-Quantum - Incluir pop-up de aviso ref. Alterar Prestador
        #call ctc00m02c()
        #Fornax-Quantum - Fim 
  end if
  
end function    #-- ctc00m02_modifica


#-----------------------------------------------------------
function ctc00m02_ler()
#-----------------------------------------------------------

  define l_aux like iddkdominio.cpodes

  initialize d_ctc00m02.*   to null

  open cctc00m02002 using k_ctc00m02.pstcoddig
  whenever error continue
  fetch cctc00m02002 into d_ctc00m02.pstcoddig   ,
                          d_ctc00m02.nomrazsoc   ,
                          d_ctc00m02.nomgrr      ,
                          d_ctc00m02.cgccpfnum   ,
                          d_ctc00m02.cgcord      ,
                          d_ctc00m02.cgccpfdig   ,
                          d_ctc00m02.muninsnum   ,
                          d_ctc00m02.pestip      ,
                          d_ctc00m02.endlgd      ,
                          d_ctc00m02.endcmp      ,
                          d_ctc00m02.endbrr      ,
                          d_ctc00m02.endcid      ,
                          d_ctc00m02.endufd      ,
                          d_ctc00m02.endcep      ,
                          d_ctc00m02.endcepcmp   ,
                          d_ctc00m02.pptnom      ,
                          d_ctc00m02.patpprflg   ,
                          d_ctc00m02.outciatxt   ,
                          d_ctc00m02.rspnom      ,
                          d_ctc00m02.srvnteflg   ,
                          d_ctc00m02.dddcod      ,
                          d_ctc00m02.teltxt      ,
                          d_ctc00m02.faxnum      ,
                          d_ctc00m02.horsegsexinc,
                          d_ctc00m02.horsegsexfnl,
                          d_ctc00m02.horsabinc   ,
                          d_ctc00m02.horsabfnl   ,
                          d_ctc00m02.hordominc   ,
                          d_ctc00m02.hordomfnl   ,
                          d_ctc00m02.qldgracod   ,
                          d_ctc00m02.prssitcod   ,
                          d_ctc00m02.pstobs      ,
                          d_ctc00m02.vlrtabflg   ,
                          d_ctc00m02.atldat      ,
                          d_ctc00m02.funmat      ,
                          d_ctc00m02.cmtdat      ,
                          d_ctc00m02.cmtmatnum   ,
                          d_ctc00m02.prscootipcod,
                          d_ctc00m02.intsrvrcbflg,
                          d_ctc00m02.rmesoctrfcod,
                          d_ctc00m02.frtrpnflg   ,
                          d_ctc00m02.risprcflg   ,
                          d_ctc00m02.celdddnum   ,
                          d_ctc00m02.celtelnum   ,
                          d_ctc00m02.lgdtip      ,
                          d_ctc00m02.lgdnum      ,
                          d_ctc00m02.lclltt      ,
                          d_ctc00m02.lcllgt      ,
                          d_ctc00m02.c24lclpdrcod,
                          d_ctc00m02.pisnum      ,
                          d_ctc00m02.nitnum      ,
                          d_ctc00m02.succod      ,
                          d_ctc00m02.pcpatvcod   ,
                          d_ctc00m02.simoptpstflg,
                          d_ctc00m02.pcpprscod   ,
                          d_ctc00m02.gstcdicod

  whenever error stop

  if sqlca.sqlcode  =  0   then
     select socpgtopccod, socfavnom,
            pestip      , cgccpfnum,
            cgcord      , cgccpfdig,
            bcoctatip   , bcocod,
            bcoagnnum   , bcoagndig,
            bcoctanum   , bcoctadig,
            nscdat      ,sexcod
      into  d_ctc00m02.socpgtopccod, d_ctc00m02.socfavnom,
            d_ctc00m02.pestipfav   , d_ctc00m02.cgccpfnumfav,
            d_ctc00m02.cgcordfav   , d_ctc00m02.cgccpfdigfav,
            d_ctc00m02.bcoctatip   , d_ctc00m02.bcocod,
            d_ctc00m02.bcoagnnum   , d_ctc00m02.bcoagndig,
            d_ctc00m02.bcoctanum   , d_ctc00m02.bcoctadig,
            d_ctc00m02.nscdat      , d_ctc00m02.sexcod       
     from dpaksocorfav
     where pstcoddig = k_ctc00m02.pstcoddig

     if sqlca.sqlcode <> 0 then
        error " Dados do favorecido nao cadastrados!"
        sleep 2
     end if

     #PSI 222020 - Burini
     let l_aux = "socpgtopccod"
     open cctc00m02005 using l_aux,
                             d_ctc00m02.socpgtopccod
     fetch cctc00m02005 into d_ctc00m02.socpgtopcdes

     if sqlca.sqlcode <> 0    then
        error " Opcao de pagamento nao cadastrada!"
        sleep 2
     end if

     initialize d_ctc00m02.funnom   to null
     select funnom  into  d_ctc00m02.funnom
       from isskfunc
      where funmat = d_ctc00m02.funmat
        and empcod = g_issk.empcod

     initialize d_ctc00m02.cmtnom   to null
     select funnom  into  d_ctc00m02.cmtnom
       from isskfunc
      where funmat = d_ctc00m02.cmtmatnum
        and empcod = g_issk.empcod

     #BURINI if d_ctc00m02.soctrfcod  is not null   then
     #BURINI    select soctrfdes  into  d_ctc00m02.soctrfdes
     #BURINI      from dbsktarifasocorro
     #BURINI     where soctrfcod = d_ctc00m02.soctrfcod
     #BURINI end if

     if d_ctc00m02.rmesoctrfcod  is not null   then
        select soctrfdes  into  d_ctc00m02.soctrfdes_re
          from dbsktarifasocorro
         where soctrfcod = d_ctc00m02.rmesoctrfcod
     end if

     case d_ctc00m02.prssitcod
        when "A"  let d_ctc00m02.prssitdes = "ATIVO"
        when "C"  let d_ctc00m02.prssitdes = "CANCELADO"
        when "P"  let d_ctc00m02.prssitdes = "PROPOSTA"
        when "B"  let d_ctc00m02.prssitdes = "BLOQUEADO"
     end case

     #PSI 222020 - Burini
     let l_aux = "qldgracod"
     open cctc00m02005 using l_aux,
                             d_ctc00m02.qldgracod
     fetch cctc00m02005 into d_ctc00m02.qldgrades

     #PSI 222020 - Burini
     let l_aux = "prscootipcod"
     open cctc00m02005 using l_aux,
                             d_ctc00m02.prscootipcod
     fetch cctc00m02005 into d_ctc00m02.prscootipdes

     if d_ctc00m02.prscootipcod =  1 then        ### SAI
        let  d_ctc00m02.prscootipdes = "TAXI"    ### SAI
     end if                                      ### SAI

     if d_ctc00m02.intsrvrcbflg  =  "1"  then
        let d_ctc00m02.intdescr  =  "INTERNET"
     end if
     
     #PSI 222020 - Burini
     let l_aux = "frtrpnflg"
     open cctc00m02005 using l_aux,
                             d_ctc00m02.frtrpnflg
     fetch cctc00m02005 into d_ctc00m02.frtrpndes

     call cty10g00_nome_sucursal(d_ctc00m02.succod)
          returning m_res, m_msg, d_ctc00m02.sucnom

     # buscar descricao da atividade principal
     if d_ctc00m02.pcpatvcod is not null and
        d_ctc00m02.pcpatvcod > 0
        then
        initialize m_dominio.* to null
        
        call cty11g00_iddkdominio('pcpatvcod', d_ctc00m02.pcpatvcod)
             returning m_dominio.*
             
        if m_dominio.erro = 1
           then
           let d_ctc00m02.pcpatvdes = m_dominio.cpodes clipped
        else
           initialize d_ctc00m02.pcpatvdes to null
           error "Atividade principal: ", m_dominio.mensagem
        end if
     end if
     
     display by name d_ctc00m02.pstcoddig   ,
                     d_ctc00m02.nomrazsoc   ,
                     d_ctc00m02.nomgrr      ,
                     d_ctc00m02.cgccpfnum   ,
                     d_ctc00m02.cgcord      ,
                     d_ctc00m02.cgccpfdig   ,
                     d_ctc00m02.muninsnum   ,
                     d_ctc00m02.pestip      ,
                     d_ctc00m02.lgdtip      ,
                     d_ctc00m02.endlgd      ,
                     d_ctc00m02.endcmp      ,
                     d_ctc00m02.lgdnum      ,
                     d_ctc00m02.endbrr      ,
                     d_ctc00m02.endcid      ,
                     d_ctc00m02.endufd      ,
                     d_ctc00m02.endcep      ,
                     d_ctc00m02.endcepcmp   ,
                     d_ctc00m02.pptnom      ,
                     d_ctc00m02.patpprflg   ,
                     d_ctc00m02.outciatxt   ,
                     d_ctc00m02.rspnom      ,
                     d_ctc00m02.srvnteflg   ,
                     d_ctc00m02.dddcod      ,
                     d_ctc00m02.teltxt      ,
                     d_ctc00m02.faxnum      ,
                     d_ctc00m02.celdddnum   ,
                     d_ctc00m02.celtelnum   ,
                     d_ctc00m02.pstobs      ,
                     d_ctc00m02.rmesoctrfcod,
                     d_ctc00m02.frtrpnflg   ,
                     d_ctc00m02.soctrfdes_re,
                     d_ctc00m02.prscootipcod,
                     d_ctc00m02.prscootipdes,
                     d_ctc00m02.intsrvrcbflg,
                     d_ctc00m02.intdescr    ,
                     d_ctc00m02.risprcflg   ,
                     d_ctc00m02.frtrpndes   ,
                     d_ctc00m02.pisnum      ,
                  #  d_ctc00m02.nitnum      ,
                     d_ctc00m02.succod      ,  
                     d_ctc00m02.sucnom      ,
                     d_ctc00m02.pcpatvcod   ,
                     d_ctc00m02.pcpatvdes   ,
                     d_ctc00m02.simoptpstflg

     display by name d_ctc00m02.prssitcod    attribute(reverse)
     display by name d_ctc00m02.prssitdes    attribute(reverse)
     display by name d_ctc00m02.socpgtopccod attribute(reverse)
     display by name d_ctc00m02.socpgtopcdes attribute(reverse)
     display by name d_ctc00m02.qldgracod    attribute(reverse)
     display by name d_ctc00m02.qldgrades    attribute(reverse)
     display by name d_ctc00m02.vlrtabflg    attribute(reverse)
     display by name d_ctc00m02.intsrvrcbflg attribute(reverse)
     display by name d_ctc00m02.intdescr     attribute(reverse)
     display by name d_ctc00m02.frtrpnflg    attribute(reverse)
     display by name d_ctc00m02.frtrpndes    attribute(reverse)

     #BURINI if d_ctc00m02.soctrfcod  is not null   then
     #BURINI    display by name d_ctc00m02.soctrfcod attribute(reverse)
     #BURINI end if

     if d_ctc00m02.rmesoctrfcod  is not null   then
        display by name d_ctc00m02.rmesoctrfcod attribute(reverse)
     end if

  else

     if sqlca.sqlcode = notfound then
        error " Prestador nao cadastrado!"
     else
         error 'Erro SELECT cctc00m02002 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
         sleep 2
         error 'CTC00M02 / ctc00m02_ler() '  sleep 2
     end if
  end if

end function    #-- ctc00m02_ler

#--------------------------------------------------------------
function ctc00m02_complemento(param)
#--------------------------------------------------------------

define param record
   operacao char(1)
end record

define ctc00m02 record
   gstcdicod like dpaksocor.gstcdicod,
   sprnom    like dpakprsgstcdi.sprnom,
   gernom    like dpakprsgstcdi.gernom,
   cdnnom    like dpakprsgstcdi.cdnnom,
   anlnom    like dpakprsgstcdi.anlnom
end record

define prompt_key  char(1)
       
initialize ctc00m02.* to null

  open window w_ctc00m02a at 11,06 with form "ctc00m02a"
       attribute(form line 1,comment line last,border)

  error "E' OBRIGATORIO CADASTRAR UMA CADEIA DE GESTAO"
  
  whenever error continue
  open cctc00m02007 using k_ctc00m02.pstcoddig
  fetch cctc00m02007 into ctc00m02.gstcdicod
  
  if sqlca.sqlcode <> 0 and sqlca.sqlcode <> 100 then
     initialize ctc00m02.* to null
     return  0 
  end if
  whenever error stop
  
  
  #busca os dados do grupo de responsaveis
  whenever error continue
  if ctc00m02.gstcdicod is not null then
     select sprnom,   
            gernom,    
            cdnnom,  
            anlnom
       into ctc00m02.sprnom,
            ctc00m02.gernom,
            ctc00m02.cdnnom,
            ctc00m02.anlnom
       from dpakprsgstcdi
      where gstcdicod = ctc00m02.gstcdicod
  end if
  whenever error stop
  
  display by name ctc00m02.*
         
  
     input by name  ctc00m02.gstcdicod without defaults
                   
                      
         before field gstcdicod
              display by name ctc00m02.gstcdicod attribute(reverse)
         
         after field gstcdicod
              display by name ctc00m02.gstcdicod
                                         
              if ctc00m02.gstcdicod is null then
                 error "CADEIA DE RESPONSAVEL E' OBRIGATORIO"
                 call ctc00m22_popup()
                   returning ctc00m02.gstcdicod
              end if
              
              whenever error continue
              select sprnom,                       
                     gernom,                       
                     cdnnom,                       
                     anlnom                        
                into ctc00m02.sprnom,              
                     ctc00m02.gernom,              
                     ctc00m02.cdnnom,              
                     ctc00m02.anlnom               
                from dpakprsgstcdi                 
               where gstcdicod = ctc00m02.gstcdicod
                            
              if sqlca.sqlcode = notfound then  
                 error "CADEIA DE RESPONSAVEL NAO ENCONTRADA"
                 next field gstcdicod
              end if 
              whenever error stop
               
              display by name ctc00m02.sprnom,
                              ctc00m02.gernom,
                              ctc00m02.cdnnom,
                              ctc00m02.anlnom  
                              
              if param.operacao = 'C' then                                             
                 begin work
                    update dpaksocor
                       set gstcdicod = ctc00m02.gstcdicod
                     where pstcoddig = k_ctc00m02.pstcoddig
                    
                    if sqlca.sqlcode <> 0 then
                       error 'ERRO UPDATE ctc00m02_cadges()/ ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]	           
                       sleep 2
                       error 'CTC00M02 / ctc00m02_cadges() '  sleep 2
                       rollback work
                       return 0
                    end if
                 commit work
              end if
              
              on key(interrupt)
                 if ctc00m02.gstcdicod is not null then
                   exit input
                 else
                   error "Campo Cadeia de Gestao Obrigatorio"
                 end if
              
     end input
        

  error " Verifique o dados do prestador e tecle ENTER!"
  prompt "" for char prompt_key     

  close window w_ctc00m02a   
  
  return  ctc00m02.gstcdicod

end function #ctc00m02_cadges()

#--------------------------------------------------------------
function ctc00m02_pstprinc()
#--------------------------------------------------------------

define ctc00m02 record
   pcpprscod like dpaksocor.pcpprscod,
   nomrazsoc like dpaksocor.nomrazsoc
end record

define prompt_key     char(1)
define l_pcpprscodaux like dpaksocor.pcpprscod,
       l_pcpprscod    like dpaksocor.pcpprscod
       
initialize ctc00m02.* to null

  open window w_ctc00m02b at 11,06 with form "ctc00m02b"
       attribute(form line 1,comment line last,border)

    
  whenever error continue
  open cctc00m02008 using k_ctc00m02.pstcoddig
  fetch cctc00m02008 into ctc00m02.pcpprscod
  
  if sqlca.sqlcode <> 0 and sqlca.sqlcode <> 100 then
     initialize ctc00m02.* to null
     return  0 
  end if
  whenever error stop
  
  
  #busca o nome do prestador principal
  whenever error continue
  if ctc00m02.pcpprscod is not null then
     select nomrazsoc   
       into ctc00m02.nomrazsoc
       from dpaksocor
      where pstcoddig = ctc00m02.pcpprscod
  end if
  whenever error stop
  
  display by name ctc00m02.*

  input by name  ctc00m02.pcpprscod without defaults
                
                   
      before field pcpprscod
           display by name ctc00m02.pcpprscod attribute(reverse)
      
      after field pcpprscod
           display by name ctc00m02.pcpprscod
                                                 
           whenever error continue
           select nomrazsoc
             into ctc00m02.nomrazsoc
             from dpaksocor
            where pstcoddig = ctc00m02.pcpprscod
                         
           if sqlca.sqlcode = notfound then  
              error "PRESTADOR NAO ENCONTRADO"
              next field pcpprscod
           end if 
           whenever error stop
            
           display by name ctc00m02.nomrazsoc
	   
	   let l_pcpprscodaux = ctc00m02.pcpprscod
	   let l_pcpprscod    = l_pcpprscodaux
	   
	   while true
	     whenever error continue
             select pcpprscod 
               into l_pcpprscodaux
               from dpaksocor
              where pstcoddig = l_pcpprscodaux
             
             if l_pcpprscodaux is not null and l_pcpprscodaux <> l_pcpprscod then
                let l_pcpprscod = l_pcpprscodaux
             else
                exit while
             end if
             whenever error stop
           end while
	   
	   whenever error continue
	      begin work
	        update dpaksocor
	           set pcpprscod = l_pcpprscod
	         where pstcoddig = k_ctc00m02.pstcoddig
	        
	        if sqlca.sqlcode <> 0 then
	           error 'ERRO UPDATE ctc00m02_pstprinc()/ ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]	           
                   sleep 2
                   error 'CTC00M02 / ctc00m02_pstprinc() '  sleep 2
                   rollback work
                   return
	        end if
	   
	      commit work
	   whenever error stop

           on key(interrupt)
                exit input
           
  end input      

  error " Verifique o dados do prestador e tecle ENTER!"
  prompt "" for char prompt_key     

  close window w_ctc00m02b   

end function #ctc00m02_pstprinc()

#--------------------------------------------------------------
function ctc00m02_input(param)
#--------------------------------------------------------------

  define param record
         operacao  char(01)
  end record

  define ws record
     endcid         like dpaksocor.endcid   ,
     cgccpfdig      like dpaksocor.cgccpfdig,
     temvclflg      char(01),
     temsrrflg      char(01),
     contador       decimal(6,0),
     retlgd         char(40),
     count          dec(5,0),
     callok         char(01),
     soctip         like dbsktarifasocorro.soctip,
     aux            char(15),
     erro           smallint
  end record

  define l_aux2      like iddkdominio.cpodes,
         l_frtrpnflg like dpaksocor.frtrpnflg,
         l_sql       char(200),
         l_index     smallint,
         l_qtdLinha  smallint         

  define l_aux record
         socpgtopccod     like dpaksocorfav.socpgtopccod,
         qldgracod        like dpaksocor.qldgracod   ,
         outciatxt        like dpaksocor.outciatxt   ,
         prscootipcod     like dpaksocor.prscootipcod,
         vlrtabflg        like dpaksocor.vlrtabflg   ,
         soctrfcod        like dpaksocor.soctrfcod   ,
         rmesoctrfcod     like dpaksocor.rmesoctrfcod,
         pstobs           like dpaksocor.pstobs      ,
         risprcflg        like dpaksocor.risprcflg   ,
         simoptpstflg     like dpaksocor.simoptpstflg    # PSI-11-19199PR
  end record
  
  define lr_retorno     record
         erro    smallint,
         cpocod  integer ,
         cpodes  char(50)
  end record

  define l_popup char(6000), l_opcao smallint
  
  define lr_numnit   char(30) #Fornax-Quantum 
  define lr_dignit   integer  #Fornax-Quantum 
  define l_count       integer     #PSI-2012-23608
        ,l_domtipdes   char(20)      
        ,l_endtipcod   decimal(2,0)
        ,l_operacional smallint
        ,l_digEnd      smallint
        ,l_endNulo     smallint
        ,l_ret         smallint
        ,l_msg         char(50)

  let l_count     = null      #PSI-2012-23608
  let l_domtipdes = null
  let l_endtipcod = null
  let l_digEnd    = false
  let l_endNulo   = false
  
  
  let l_sql = null
  let int_flag = false
  initialize ws.*, l_aux2  to null
  
  input by name  d_ctc00m02.nomrazsoc   ,
                 d_ctc00m02.nomgrr      ,
                 d_ctc00m02.prssitcod   ,
                 d_ctc00m02.pestip      ,
                 d_ctc00m02.cgccpfnum   ,
                 d_ctc00m02.cgcord      ,
                 d_ctc00m02.cgccpfdig   ,
                 d_ctc00m02.muninsnum   ,
                 d_ctc00m02.pcpatvcod   ,
                 d_ctc00m02.pisnum      ,
                 d_ctc00m02.lgdtip      ,
                 {d_ctc00m02.endlgd      ,
                 d_ctc00m02.lgdnum      ,
                 d_ctc00m02.endbrr      ,
                 d_ctc00m02.endcid      ,
                 d_ctc00m02.endufd      ,
                 d_ctc00m02.endcmp      ,
                 d_ctc00m02.endcep      ,
                 d_ctc00m02.endcepcmp   ,}
                 d_ctc00m02.dddcod      ,
                 d_ctc00m02.teltxt      ,
                 d_ctc00m02.faxnum      ,
                 d_ctc00m02.celdddnum   ,
                 d_ctc00m02.celtelnum   ,
               #  d_ctc00m02.succod      ,
                 d_ctc00m02.pptnom      ,
                 d_ctc00m02.patpprflg   ,
                 d_ctc00m02.rspnom      ,
                 d_ctc00m02.srvnteflg   ,
                 d_ctc00m02.socpgtopccod,
                 d_ctc00m02.qldgracod   ,
                 d_ctc00m02.outciatxt   ,
                 d_ctc00m02.prscootipcod,
                 d_ctc00m02.vlrtabflg   ,
                 d_ctc00m02.rmesoctrfcod,
                 d_ctc00m02.frtrpnflg   ,
                 d_ctc00m02.pstobs      ,
                 d_ctc00m02.intsrvrcbflg,
                 d_ctc00m02.risprcflg   ,
               # d_ctc00m02.nitnum      ,
                 d_ctc00m02.simoptpstflg
         without defaults

  before input
         let l_frtrpnflg = d_ctc00m02.frtrpnflg

  before field nomrazsoc
         #if param.operacao  =  "m"   then
         #   next field nomgrr
         #end if
         display by name d_ctc00m02.nomrazsoc     attribute(reverse)

  after  field nomrazsoc
         display by name d_ctc00m02.nomrazsoc

         if d_ctc00m02.nomrazsoc is null  or
            d_ctc00m02.nomrazsoc = " "    then
            error " Razao Social deve ser informada!"
            next field nomrazsoc
         end if
         
         # MOSTRA DATAS CREDENCIAMENTO/ATUALIZACAO
         #----------------------------------------
         if param.operacao  =  "m"   then
            call ctc00m07(d_ctc00m02.atldat   , d_ctc00m02.funmat,
                          d_ctc00m02.funnom   , d_ctc00m02.cmtdat,
                          d_ctc00m02.cmtmatnum, d_ctc00m02.cmtnom)
         end if

  before field nomgrr
         display by name d_ctc00m02.nomgrr    attribute(reverse)

  after  field nomgrr
         display by name d_ctc00m02.nomgrr

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            #if param.operacao  =  "m"   then
            #   next field nomgrr
            #end if
            next field nomrazsoc
         end if

         if d_ctc00m02.nomgrr    is null  or
            d_ctc00m02.nomgrr    = " "    then
            error " Nome de guerra deve ser informado!"
            next field nomgrr
         end if

         

  before field prssitcod
         display by name d_ctc00m02.prssitcod    attribute(reverse)

  after  field prssitcod
         display by name d_ctc00m02.prssitcod    attribute(reverse)

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field nomgrr
         end if
         
         if d_ctc00m02.prssitcod   is null   then
            error " Situacao do prestador deve ser informada!"
            next field prssitcod
         end if
         
         case d_ctc00m02.prssitcod
            when "A"  let d_ctc00m02.prssitdes = "ATIVO"
            when "C"  let d_ctc00m02.prssitdes = "CANCELADO"
            when "P"  let d_ctc00m02.prssitdes = "PROPOSTA"
            when "B"  let d_ctc00m02.prssitdes = "BLOQUEADO"
            otherwise
                 error " Situacao do prestador invalida!"
                 next field prssitcod
         end case
         display by name d_ctc00m02.prssitdes  attribute(reverse)
         
         if d_ctc00m02.prssitcod  =  "C"   then
            call ctc00m02_veiculos(d_ctc00m02.pstcoddig)
                 returning ws.temvclflg

            call ctc00m02_socorristas(d_ctc00m02.pstcoddig)
                 returning ws.temsrrflg

            if ws.temvclflg  =  "s"   or
               ws.temsrrflg  =  "s"   then
               next field prssitcod
            end if
         end if
         
         if param.operacao  =  "m"   then
            #------------------------------------------------------------
            # VERIFICA SE CGC/CPF JA' CADASTRADO
            #------------------------------------------------------------
            if d_ctc00m02.pcpprscod is null then

                call ctc00m06(1, d_ctc00m02.pestip, d_ctc00m02.pstcoddig,
                              d_ctc00m02.cgccpfnum)
                    returning d_ctc00m02.pcpprscod
                    
                    if d_ctc00m02.pcpprscod == 0 then
                       initialize d_ctc00m02.pcpprscod to null
                    end if
            end if
                   
            if d_ctc00m02.gstcdicod is null then
                call ctc00m02_complemento(param.operacao)
  	            returning d_ctc00m02.gstcdicod                          
  	    end if

            next field muninsnum
         end if

  before field pestip
         display by name d_ctc00m02.pestip   attribute(reverse)

  after  field pestip
         display by name d_ctc00m02.pestip

         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
            next field prssitcod
         end if

         if d_ctc00m02.pestip   is null   then
            error " Tipo de pessoa deve ser informado!"
            next field pestip
         end if

         if d_ctc00m02.pestip  <>  "F"   and
            d_ctc00m02.pestip  <>  "J"   then
            error " Tipo de pessoa invalido!"
            next field pestip
         end if
         
         if d_ctc00m02.pestip  =  "F"   then
            initialize d_ctc00m02.cgcord  to null
            display by name d_ctc00m02.cgcord
         end if
         
  before field cgccpfnum
         display by name d_ctc00m02.cgccpfnum   attribute(reverse)

  after  field cgccpfnum
         display by name d_ctc00m02.cgccpfnum

         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
            next field pestip
         end if

         if d_ctc00m02.cgccpfnum   is null   or
            d_ctc00m02.cgccpfnum   =  0      then
            error " Numero do Cgc/Cpf deve ser informado!"
            next field cgccpfnum
         end if

         if d_ctc00m02.pestip  =  "F"   then
            next field cgccpfdig
         end if

  before field cgcord
         display by name d_ctc00m02.cgcord   attribute(reverse)

  after  field cgcord
         display by name d_ctc00m02.cgcord

         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
            next field cgccpfnum
         end if

         if d_ctc00m02.cgcord   is null   or
            d_ctc00m02.cgcord   =  0      then
            error " Filial do Cgc deve ser informada!"
            next field cgcord
         end if

  before field cgccpfdig
         display by name d_ctc00m02.cgccpfdig  attribute(reverse)

  after  field cgccpfdig
         display by name d_ctc00m02.cgccpfdig

         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
            if d_ctc00m02.pestip  =  "J"  then
               next field cgcord
            else
               next field cgccpfnum
            end if
         end if

         if d_ctc00m02.cgccpfdig   is null   then
            error " Digito do Cgc/Cpf deve ser informado!"
            next field cgccpfdig
         end if

         if d_ctc00m02.pestip  =  "J"    then
            call F_FUNDIGIT_DIGITOCGC(d_ctc00m02.cgccpfnum,
                                      d_ctc00m02.cgcord)
                 returning ws.cgccpfdig
         else
            call F_FUNDIGIT_DIGITOCPF(d_ctc00m02.cgccpfnum)
                 returning ws.cgccpfdig
         end if

         if ws.cgccpfdig         is null           or
            d_ctc00m02.cgccpfdig <> ws.cgccpfdig   then
            error " Digito do Cgc/Cpf incorreto!"
            next field cgccpfnum
         end if

         #------------------------------------------------------------
         # VERIFICA SE CGC/CPF JA' CADASTRADO
         #------------------------------------------------------------
         if d_ctc00m02.pcpprscod  is null then
              call ctc00m06(1, d_ctc00m02.pestip, d_ctc00m02.pstcoddig,
                            d_ctc00m02.cgccpfnum)
                  returning d_ctc00m02.pcpprscod
                  
              if d_ctc00m02.pcpprscod == 0 then
                 initialize d_ctc00m02.pcpprscod to null
              end if   
         end if
         
         if d_ctc00m02.gstcdicod is null then
              call ctc00m02_complemento(param.operacao)
  	          returning  d_ctc00m02.gstcdicod                       
  	 end if

  before field muninsnum
         display by name d_ctc00m02.muninsnum attribute(reverse)

  after  field muninsnum
         display by name d_ctc00m02.muninsnum

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")
            then
            if param.operacao  =  "m"
               then
               next field prssitcod
            end if
            next field cgccpfdig
         end if
         
         if d_ctc00m02.muninsnum = 0  then
            error " Inscricao municipal nao pode ser igual a zeros!"
            next field muninsnum
         end if
         
         if d_ctc00m02.pestip = 'J'
            then
            if d_ctc00m02.muninsnum = ' ' or
               d_ctc00m02.muninsnum is null
               then
               error " Inscricao municipal obrigatoria para PJ "
               next field muninsnum
            end if
         end if
         
  before field pcpatvcod
         display by name d_ctc00m02.pcpatvcod attribute(reverse)
         
  after  field pcpatvcod
         display by name d_ctc00m02.pcpatvcod
         
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field muninsnum
         end if
         
         initialize lr_retorno.* to null
         initialize m_dominio.* to null
         
         if d_ctc00m02.pcpatvcod is null
            then
            error " Informe a atividade principal do prestador "
            call cty09g00_popup_iddkdominio("pcpatvcod")
                 returning lr_retorno.erro, d_ctc00m02.pcpatvcod,
                           d_ctc00m02.pcpatvdes
         else
            call cty11g00_iddkdominio('pcpatvcod', d_ctc00m02.pcpatvcod)
                 returning m_dominio.*
                 
            if m_dominio.erro != 1
               then
               if m_dominio.cpodes is null
                  then
                  error ' Atividade não encontrada '
               else
                  error m_dominio.mensagem
               end if
               initialize d_ctc00m02.pcpatvdes to null
               display by name d_ctc00m02.pcpatvdes
               
               call cty09g00_popup_iddkdominio("pcpatvcod")
                    returning lr_retorno.erro, d_ctc00m02.pcpatvcod,
                              d_ctc00m02.pcpatvdes
                           
            else
               let d_ctc00m02.pcpatvdes = m_dominio.cpodes
            end if
         end if
         
         if d_ctc00m02.pcpatvcod is null
            then
            next field pcpatvcod
         end if
         
         display by name d_ctc00m02.pcpatvcod, d_ctc00m02.pcpatvdes
         
  before field pisnum
         display by name d_ctc00m02.pisnum    attribute(reverse)

  after  field pisnum
         display by name d_ctc00m02.pisnum
         
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field pcpatvcod
         end if
         
         #Fornax-Quantum. Validar o campo NIT no cadastro do prestador - Inicio
         #if d_ctc00m02.pestip = "F" and
         #   d_ctc00m02.pisnum is null then
         #   error "Informe o nr. do PIS"
         #   next field pisnum
         #end if
         
         if d_ctc00m02.pestip = "F" then
            if d_ctc00m02.pisnum is null then  
               error  "Número do PIS/NIT Obrigatório"
               next field pisnum               
            end if 
            
            let lr_numnit = d_ctc00m02.pisnum
            
            if length(lr_numnit) <> 11 then 
             error "Numero do PIS/NIT incorreto"
             next field pisnum
            else 
                display "lr_numnit ", lr_numnit
                
                call ctc00m02_validanit(lr_numnit)
                returning lr_dignit 
                
                if lr_numnit[11] <> lr_dignit then 
                  error "Numero do PIS/NIT incorreto"
                  next field pisnum 
                end if 
                                  
            end if
         end if 
         #Fornax-Quantum. Validar o campo NIT no cadastro do prestador - Fim 

  before field lgdtip
        display by name d_ctc00m02.lgdtip attribute(reverse)

        #PSI-2012-23608 - Inicio        
        open cctc00m02009 using d_ctc00m02.pstcoddig
        whenever error continue
        fetch cctc00m02009 into l_count
        whenever error stop
        if sqlca.sqlcode < 0 then
           error 'Problemas ao buscar dados do endereco!'
           sleep 2
        end if 
        
        if sqlca.sqlcode = 0 then

           if l_digEnd = true then
              call ctc00m25(d_ctc00m02.pstcoddig, false)
              returning d_ctc00m02_end[1].*,
                        d_ctc00m02_end[2].*,
                        d_ctc00m02_end[3].*,
                        d_ctc00m02_end[4].*,
                        d_ctc00m02_end[5].*,
                        d_ctc00m02_end[6].*,
                        d_ctc00m02_end[7].*,
                        d_ctc00m02_end[8].*,
                        d_ctc00m02_end[9].*,
                        d_ctc00m02_end[10].*,
                        l_operacional,
                        l_qtdLinha
           else
              call ctc00m25(d_ctc00m02.pstcoddig, true)
              returning d_ctc00m02_end[1].*,
                        d_ctc00m02_end[2].*,
                        d_ctc00m02_end[3].*,
                        d_ctc00m02_end[4].*,
                        d_ctc00m02_end[5].*,
                        d_ctc00m02_end[6].*,
                        d_ctc00m02_end[7].*,
                        d_ctc00m02_end[8].*,
                        d_ctc00m02_end[9].*,
                        d_ctc00m02_end[10].*,
                        l_operacional,
                        l_qtdLinha
           end if
           let l_digEnd = true          
           let d_ctc00m02.lgdtip    = d_ctc00m02_end[l_operacional].lgdtip
           let d_ctc00m02.endlgd    = d_ctc00m02_end[l_operacional].endlgd
           let d_ctc00m02.lgdnum    = d_ctc00m02_end[l_operacional].lgdnum
           let d_ctc00m02.endcmp    = d_ctc00m02_end[l_operacional].lgdcmp
           let d_ctc00m02.endbrr    = d_ctc00m02_end[l_operacional].endbrr
           let d_ctc00m02.endcid    = d_ctc00m02_end[l_operacional].endcid
           let d_ctc00m02.endufd    = d_ctc00m02_end[l_operacional].ufdsgl
           let l_domtipdes          = d_ctc00m02_end[l_operacional].domtipdes
           let l_endtipcod          = d_ctc00m02_end[l_operacional].endtipcod
           let d_ctc00m02.endcep    = d_ctc00m02_end[l_operacional].endcep   
           let d_ctc00m02.endcepcmp = d_ctc00m02_end[l_operacional].endcepcmp
           let d_ctc00m02.lclltt    = d_ctc00m02_end[l_operacional].lclltt   
           let d_ctc00m02.lcllgt    = d_ctc00m02_end[l_operacional].lcllgt
        else           
           if sqlca.sqlcode = 100 then
           
              if l_digEnd = true then
                 call ctc00m25(d_ctc00m02.pstcoddig, false)
                 returning d_ctc00m02_end[1].*,
                           d_ctc00m02_end[2].*,
                           d_ctc00m02_end[3].*,
                           d_ctc00m02_end[4].*,
                           d_ctc00m02_end[5].*,
                           d_ctc00m02_end[6].*,
                           d_ctc00m02_end[7].*,
                           d_ctc00m02_end[8].*,
                           d_ctc00m02_end[9].*,
                           d_ctc00m02_end[10].*,
                           l_operacional,
                           l_qtdLinha
                          
                 let d_ctc00m02.lgdtip    = d_ctc00m02_end[l_operacional].lgdtip
                 let d_ctc00m02.endlgd    = d_ctc00m02_end[l_operacional].endlgd
                 let d_ctc00m02.lgdnum    = d_ctc00m02_end[l_operacional].lgdnum
                 let d_ctc00m02.endcmp    = d_ctc00m02_end[l_operacional].lgdcmp
                 let d_ctc00m02.endbrr    = d_ctc00m02_end[l_operacional].endbrr
                 let d_ctc00m02.endcid    = d_ctc00m02_end[l_operacional].endcid
                 let d_ctc00m02.endufd    = d_ctc00m02_end[l_operacional].ufdsgl
                 let l_domtipdes          = d_ctc00m02_end[l_operacional].domtipdes
                 let l_endtipcod          = d_ctc00m02_end[l_operacional].endtipcod
                 let d_ctc00m02.endcep    = d_ctc00m02_end[l_operacional].endcep   
                 let d_ctc00m02.endcepcmp = d_ctc00m02_end[l_operacional].endcepcmp
                 let d_ctc00m02.lclltt    = d_ctc00m02_end[l_operacional].lclltt   
                 let d_ctc00m02.lcllgt    = d_ctc00m02_end[l_operacional].lcllgt
              else
                 if l_endNulo = true then                                   
                    call ctc00m25_controle('I',d_ctc00m02.pstcoddig, false,1)
                    returning d_ctc00m02_end[1].*, 
                              d_ctc00m02_end[2].*, 
                              d_ctc00m02_end[3].*, 
                              d_ctc00m02_end[4].*, 
                              d_ctc00m02_end[5].*, 
                              d_ctc00m02_end[6].*, 
                              d_ctc00m02_end[7].*, 
                              d_ctc00m02_end[8].*, 
                              d_ctc00m02_end[9].*, 
                              d_ctc00m02_end[10].*,
                              l_operacional,
                              l_qtdLinha       
                 else                    
                    call ctc00m25_controle('I',d_ctc00m02.pstcoddig, true,1)
                    returning d_ctc00m02_end[1].*, 
                              d_ctc00m02_end[2].*, 
                              d_ctc00m02_end[3].*, 
                              d_ctc00m02_end[4].*, 
                              d_ctc00m02_end[5].*, 
                              d_ctc00m02_end[6].*, 
                              d_ctc00m02_end[7].*, 
                              d_ctc00m02_end[8].*, 
                              d_ctc00m02_end[9].*, 
                              d_ctc00m02_end[10].*,
                              l_operacional,
                              l_qtdLinha  
                 end if    
                 let l_digEnd = true 
                                                   
                 let d_ctc00m02.lgdtip    = d_ctc00m02_end[l_operacional].lgdtip
                 let d_ctc00m02.endlgd    = d_ctc00m02_end[l_operacional].endlgd
                 let d_ctc00m02.lgdnum    = d_ctc00m02_end[l_operacional].lgdnum
                 let d_ctc00m02.endcmp    = d_ctc00m02_end[l_operacional].lgdcmp
                 let d_ctc00m02.endbrr    = d_ctc00m02_end[l_operacional].endbrr
                 let d_ctc00m02.endcid    = d_ctc00m02_end[l_operacional].endcid
                 let d_ctc00m02.endufd    = d_ctc00m02_end[l_operacional].ufdsgl
                 let l_domtipdes          = d_ctc00m02_end[l_operacional].domtipdes
                 let l_endtipcod          = d_ctc00m02_end[l_operacional].endtipcod
                 let d_ctc00m02.endcep    = d_ctc00m02_end[l_operacional].endcep   
                 let d_ctc00m02.endcepcmp = d_ctc00m02_end[l_operacional].endcepcmp
                 let d_ctc00m02.lclltt    = d_ctc00m02_end[l_operacional].lclltt   
                 let d_ctc00m02.lcllgt    = d_ctc00m02_end[l_operacional].lcllgt   
              end if             
           end if
        end if
        
        if l_qtdLinha = 0 then
           let l_digEnd = false
           let l_endNulo = true
           next field pisnum
        end if
               
        let l_endNulo = false
                
        for l_operacional = 1 to l_qtdLinha
            if d_ctc00m02_end[l_operacional].lgdtip is null or   
               d_ctc00m02_end[l_operacional].endlgd is null or   
               d_ctc00m02_end[l_operacional].lgdnum is null or   
               d_ctc00m02_end[l_operacional].endbrr is null or   
               d_ctc00m02_end[l_operacional].endcid is null or   
               d_ctc00m02_end[l_operacional].ufdsgl is null or   
               d_ctc00m02_end[l_operacional].endcep is null or   
               d_ctc00m02_end[l_operacional].endcepcmp is null then
               let l_digEnd = false                
               let l_endNulo = true               
               next field pisnum               
            end if
        end for
        
        display by name d_ctc00m02.lgdtip
        display by name d_ctc00m02.endlgd
        display by name d_ctc00m02.lgdnum
        display by name d_ctc00m02.endbrr
        display by name d_ctc00m02.endcid
        display by name d_ctc00m02.endufd
        display by name d_ctc00m02.endcmp 
        display by name d_ctc00m02.endcep   
        display by name d_ctc00m02.endcepcmp        
        #next field dddcod
        
        #PSI-2012-23608 - Fim
        
        #call ctx25g05("C",
        #              "                       ROTEIRIZACAO DE ENDERECO",
        #              d_ctc00m02.endufd,
        #              d_ctc00m02.endcid,
        #              d_ctc00m02.lgdtip,
        #              d_ctc00m02.endlgd,
        #              d_ctc00m02.lgdnum,
        #              d_ctc00m02.endbrr,
        #              d_ctc00m02.endcep,
        #              d_ctc00m02.endcepcmp,
        #              d_ctc00m02.lclltt,
        #              d_ctc00m02.lcllgt,
        #              d_ctc00m02.c24lclpdrcod)
        #   returning d_ctc00m02.lgdtip,
        #             d_ctc00m02.endlgd,
        #             d_ctc00m02.lgdnum,
        #             d_ctc00m02.endbrr,
        #             ws.aux,
        #             ws.aux,
        #             d_ctc00m02.lclltt,
        #             d_ctc00m02.lcllgt,
        #             d_ctc00m02.c24lclpdrcod,
        #             d_ctc00m02.endufd,
        #             d_ctc00m02.endcid

        #display by name d_ctc00m02.lgdtip
        #display by name d_ctc00m02.endlgd
        #display by name d_ctc00m02.endbrr
        #display by name d_ctc00m02.endcid
        #display by name d_ctc00m02.endufd

        initialize d_ctc00m02.mpacidcod, l_ret, l_msg to null
        
        #declare c_ctc00m02cid  cursor for
        #   select mpacidcod
        #     from datkmpacid
        #    where cidnom = d_ctc00m02.endcid   and
        #          ufdcod = d_ctc00m02.endufd
        #
        #foreach  c_ctc00m02cid  into  d_ctc00m02.mpacidcod
        #   exit foreach
        #end foreach
        
        call cty10g00_obter_cidcod(d_ctc00m02.endcid, d_ctc00m02.endufd)        
             returning l_ret,                                                   
                       l_msg,                                                   
                       d_ctc00m02.mpacidcod                                     

        next field dddcod        
        
        #
        #if fgl_lastkey() = fgl_keyval("up")    or
        #   fgl_lastkey() = fgl_keyval("left")  then
        #   next field muninsnum
        #else
        #   next field endcep
        #end if

  #after field lgdtip
  #      display by name d_ctc00m02.lgdtip


#PSI-2012-23608 - Inicio
{
  before field endlgd
         display by name d_ctc00m02.endlgd attribute(reverse)

  after  field endlgd
         display by name d_ctc00m02.endlgd

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            if param.operacao  =  "m"   then
               next field prssitcod
            end if
            next field lgdtip
         end if
         
         if d_ctc00m02.endlgd  = " "   or
            d_ctc00m02.endlgd is null  then
            error " Logradouro deve ser informado!"
            next field endlgd
         end if
         
  before field lgdnum
         display by name d_ctc00m02.lgdnum    attribute(reverse)

  after  field lgdnum
         display by name d_ctc00m02.lgdnum

  before field endbrr
         display by name d_ctc00m02.endbrr    attribute(reverse)

  after  field endbrr
         display by name d_ctc00m02.endbrr

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field lgdnum
         end if

         if d_ctc00m02.endbrr  = " "   or
            d_ctc00m02.endbrr is null  then
            error " Bairro deve ser informado!"
            next field endbrr
         end if

  before field endcid
         display by name d_ctc00m02.endcid    attribute(reverse)

  after  field endcid
         display by name d_ctc00m02.endcid

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field endbrr
         end if

         if d_ctc00m02.endcid  = " "   or
            d_ctc00m02.endcid is null  then
            error " Cidade deve ser informada!"
            next field endcid
         end if

  before field endufd
         display by name d_ctc00m02.endufd    attribute(reverse)

  after  field endufd
         display by name d_ctc00m02.endufd

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field endcid
         end if

         if d_ctc00m02.endufd   is null    then
            error " Unidade federativa deve ser informada!"
            next field endufd
         end if

         select ufdcod from glakest
         where glakest.ufdcod = d_ctc00m02.endufd

         if sqlca.sqlcode = notfound   then
            error " Unidade federativa nao cadastrada!"
            next field endufd
         end if
         
         initialize d_ctc00m02.mpacidcod to null
         
         declare c_ctc00m02cid  cursor for
            select mpacidcod
              from datkmpacid
             where cidnom = d_ctc00m02.endcid   and
                   ufdcod = d_ctc00m02.endufd

         foreach  c_ctc00m02cid  into  d_ctc00m02.mpacidcod
            exit foreach
         end foreach

         if d_ctc00m02.mpacidcod is null   then
            error " Cidade/U.F. nao cadastrada no MAPA!"
            next field endcid
         end if

         call ctx25g05("C",
                       "                       ROTEIRIZACAO DE ENDERECO",    
                       d_ctc00m02.endufd,                                    
                       d_ctc00m02.endcid,                                    
                       d_ctc00m02.lgdtip,                                    
                       d_ctc00m02.endlgd,                                    
                       d_ctc00m02.lgdnum,                                    
                       d_ctc00m02.endbrr,                                    
                       "",                                                   
                       d_ctc00m02.endcep,                                    
                       d_ctc00m02.endcepcmp,                                 
                       d_ctc00m02.lclltt,                                    
                       d_ctc00m02.lcllgt,                                    
                       d_ctc00m02.c24lclpdrcod)                              
             returning d_ctc00m02.lgdtip,             
                       d_ctc00m02.endlgd,             
                       d_ctc00m02.lgdnum,             
                       d_ctc00m02.endbrr,             
                       ws.aux,                        
                       ws.aux,                        
                       ws.aux,                        
                       d_ctc00m02.lclltt,             
                       d_ctc00m02.lcllgt,             
                       d_ctc00m02.c24lclpdrcod,       
                       d_ctc00m02.endufd,             
                       d_ctc00m02.endcid

         display by name d_ctc00m02.lgdtip
         display by name d_ctc00m02.endlgd
         display by name d_ctc00m02.endbrr
         display by name d_ctc00m02.endcid
         display by name d_ctc00m02.endufd

  before field endcmp
         display by name d_ctc00m02.endcmp    attribute(reverse)

  after  field endcmp
         display by name d_ctc00m02.endcmp

  before field endcep
         #if  d_ctc00m02.endlgd is null or d_ctc00m02.endlgd = " " then
         #    error 'Endereco obrigatorio'
         #    next field muninsnum
         #end if

         display by name d_ctc00m02.endcep    attribute(reverse)

  after  field endcep
         display by name d_ctc00m02.endcep

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field endcmp
         end if

         let ws.contador = 0
         select count(*) into ws.contador
           from glakcid
          where glakcid.cidcep  =  d_ctc00m02.endcep

         if ws.contador = 0  then
            select count(*) into ws.contador
              from glaklgd
             where glaklgd.lgdcep = d_ctc00m02.endcep

            if ws.contador = 0  then
               call C24GERAL_TRATSTR(d_ctc00m02.endlgd, 40)
                                     returning  ws.retlgd

               error " CEP nao cadastrado - Consulte pelo logradouro!"
               initialize d_ctc00m02.endcep, d_ctc00m02.endcepcmp to null

               call ctn11c02(d_ctc00m02.endufd,d_ctc00m02.endcid,ws.retlgd)
                    returning d_ctc00m02.endcep, d_ctc00m02.endcepcmp

               if d_ctc00m02.endcep is null then
                  error " Ver cep por cidade - Consulte pela cidade!"

                  call ctn11c03(d_ctc00m02.endcid)
                       returning d_ctc00m02.endcep
               end if
               next field endcep
            end if
         end if

  before field endcepcmp
         display by name d_ctc00m02.endcepcmp  attribute(reverse)

  after  field endcepcmp
         display by name d_ctc00m02.endcepcmp
}
#PSI-2012-23608 - Fim
  
  before field dddcod
         display by name d_ctc00m02.dddcod    attribute(reverse)

  after  field dddcod
         display by name d_ctc00m02.dddcod

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field pisnum                             #PSI-2012-23608
         end if
         
         if d_ctc00m02.dddcod  is null
            then
            error " Codigo do DDD deve ser informado !!"
            next field dddcod
         end if
         
         if not ctc00m02_valida_ddd(d_ctc00m02.dddcod)
            then
            error " Codigo do DDD invalido !"
            next field dddcod
         end if
         
  before field teltxt
         display by name d_ctc00m02.teltxt    attribute(reverse)

  after  field teltxt
         display by name d_ctc00m02.teltxt

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field dddcod
         end if

         if d_ctc00m02.teltxt  is null   then
            error " Telefone do prestador deve ser informado!"
            next field teltxt
         end if

  before field faxnum
         display by name d_ctc00m02.faxnum    attribute(reverse)

  after  field faxnum
         display by name d_ctc00m02.faxnum

         if d_ctc00m02.faxnum is not null  and
            d_ctc00m02.faxnum <= 99999     then
            error " Numero de FAX invalido!"
            next field faxnum
         end if

  before field celdddnum
         if (d_ctc00m02.celdddnum is null or   # sugerir DDD igual
             d_ctc00m02.celdddnum = ' ' ) and
            (fgl_lastkey() != fgl_keyval("up") or
             fgl_lastkey() != fgl_keyval("left") )
            then
            let d_ctc00m02.celdddnum = d_ctc00m02.dddcod
         end if
         display by name d_ctc00m02.celdddnum  attribute(reverse)
         
  after field celdddnum
         display by name d_ctc00m02.celdddnum

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field faxnum
         end if
         
         #caso nao informe DDD celular nao podera informar telefone celular
         if d_ctc00m02.celdddnum is null or
            d_ctc00m02.celdddnum = "" 
            then
            let d_ctc00m02.celtelnum = null
            display by name d_ctc00m02.celtelnum
            #next field succod   #Gregorio  
            next field pptnom
         else
            if not ctc00m02_valida_ddd(d_ctc00m02.celdddnum)
               then
               error " Codigo do DDD invalido !"
               next field celdddnum
            end if
         end if
         
  before field celtelnum
         display by name d_ctc00m02.celtelnum  attribute(reverse)

  after field celtelnum
         display by name d_ctc00m02.celtelnum

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field celdddnum
         end if

         if (d_ctc00m02.celtelnum is null or
             d_ctc00m02.celtelnum = "") and
             d_ctc00m02.celdddnum is not null
            then
            error "Informe telefone celular do prestador"
            next field celtelnum
         end if
         
  {  ####Gregorio - Inicio
  before field succod
         if d_ctc00m02.succod is null or
            d_ctc00m02.succod <= 0
            then
            let d_ctc00m02.succod = ctb00g01_sugere_sucursal(d_ctc00m02.endufd, 
                                                             d_ctc00m02.endcid)
            call cty10g00_nome_sucursal(d_ctc00m02.succod)
                 returning m_res, m_msg, d_ctc00m02.sucnom
            error " Sucursal sugerida conforme a cidade "
         end if
         display by name d_ctc00m02.succod, d_ctc00m02.sucnom attribute(reverse)
         
  after  field succod
         display by name d_ctc00m02.succod

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  
            then
            if d_ctc00m02.succod is null or
               d_ctc00m02.succod <= 0
               then
               initialize d_ctc00m02.sucnom to null
               display by name d_ctc00m02.succod, d_ctc00m02.sucnom
            end if
            next field celtelnum
         end if
         
         if d_ctc00m02.succod is null or
            d_ctc00m02.succod <= 0
            then
            let l_sql = " select succod, sucnom from gabksuc ",
                        " order by 2 "
            call ofgrc001_popup(08, 13, 'ESCOLHA A SUCURSAL',
                                'Codigo', 'Descricao', 'N', l_sql, '', 'D')
                 returning m_res, d_ctc00m02.succod, d_ctc00m02.sucnom
            next field succod
         end if
         
         if d_ctc00m02.succod is not null then
            call cty10g00_nome_sucursal(d_ctc00m02.succod)
                 returning m_res, m_msg, d_ctc00m02.sucnom

            if m_res <> 1 then
               error m_msg
               next field succod
            end if
         end if
         
         display by name d_ctc00m02.succod, d_ctc00m02.sucnom
  } ####Gregorio - Fim
  before field pptnom
         display by name d_ctc00m02.pptnom attribute(reverse)

  after  field pptnom
         display by name d_ctc00m02.pptnom

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            #next field succod #Gregorio
            next field celtelnum
         end if
         
         if d_ctc00m02.pptnom  = " "   or
            d_ctc00m02.pptnom is null  then
            error " Nome do proprietario deve ser informado!"
            next field pptnom
         end if

  before field patpprflg
         display by name d_ctc00m02.patpprflg attribute(reverse)

  after  field patpprflg
         display by name d_ctc00m02.patpprflg

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field pptnom
         end if
         
         if d_ctc00m02.patpprflg is null  then
            error " Prestador possui patio deve ser informado!"
            next field patpprflg
         else
            if d_ctc00m02.patpprflg <> "S"  and
               d_ctc00m02.patpprflg <> "N"  then
               error " Prestador possui patio: (S)im ou (N)ao !"
               next field patpprflg
            end if
         end if         
         
  before field rspnom
         display by name d_ctc00m02.rspnom    attribute(reverse)

  after  field rspnom
         display by name d_ctc00m02.rspnom

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field patpprflg
         end if

         if d_ctc00m02.rspnom  = " "   or
            d_ctc00m02.rspnom is null  then
            error " Nome do responsavel deve ser informado!"
            next field rspnom
         end if
         
  before field srvnteflg
         display by name d_ctc00m02.srvnteflg attribute(reverse)
         
  after  field srvnteflg
         display by name d_ctc00m02.srvnteflg
         
         if d_ctc00m02.srvnteflg is null  then
            error " Prestador atende 24 Horas deve ser informado!"
            next field srvnteflg
         else
            if d_ctc00m02.srvnteflg <> "S"  and
               d_ctc00m02.srvnteflg <> "N"  then
               error " Prestador atende 24 horas: (S)im ou (N)ao !"
               next field srvnteflg
            end if
         end if
         
         if d_ctc00m02.srvnteflg = "N"  then
            call ctc00m04(d_ctc00m02.horsegsexinc,
                          d_ctc00m02.horsegsexfnl,
                          d_ctc00m02.horsabinc   ,
                          d_ctc00m02.horsabfnl   ,
                          d_ctc00m02.hordominc   ,
                          d_ctc00m02.hordomfnl   )
                returning d_ctc00m02.horsegsexinc,
                          d_ctc00m02.horsegsexfnl,
                          d_ctc00m02.horsabinc   ,
                          d_ctc00m02.horsabfnl   ,
                          d_ctc00m02.hordominc   ,
                          d_ctc00m02.hordomfnl

            if d_ctc00m02.horsegsexinc  is null     or
               d_ctc00m02.horsegsexinc  = "00:00"   or
               d_ctc00m02.horsegsexfnl  is null     then
               error " Horario de segunda/sexta deve ser informado!"
               next field srvnteflg
            end if
         end if

  before field socpgtopccod
         let l_aux.socpgtopccod = d_ctc00m02.socpgtopccod
         
         # operador nao PS ou desenv so passa pelo campo sem cadastrar
         if g_issk.dptsgl <> "psocor" and
            g_issk.dptsgl <> "desenv" 
            then
            if fgl_lastkey() = fgl_keyval("up")    or
               fgl_lastkey() = fgl_keyval("left")  then
               next field srvnteflg
            else
               next field qldgracod
            end if
         else
            display by name d_ctc00m02.socpgtopccod attribute(reverse)
         end if
         
  after  field socpgtopccod
         display by name d_ctc00m02.socpgtopccod attribute(reverse)
         
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field srvnteflg
         end if
         
         if d_ctc00m02.socpgtopccod is null then
            error " Opcao de pagamento deve ser informada!"
            let  d_ctc00m02.socpgtopccod = l_aux.socpgtopccod
            next field socpgtopccod
         end if
         
         #PSI 222020 - Burini
         let l_aux2 = "socpgtopccod"
         open cctc00m02005 using l_aux2,
                                 d_ctc00m02.socpgtopccod
         fetch cctc00m02005 into d_ctc00m02.socpgtopcdes
         
         if sqlca.sqlcode <> 0    then
            error " Opcao de pagamento nao cadastrada!"
            next field socpgtopccod
         else
            display by name d_ctc00m02.socpgtopcdes  attribute(reverse)
         end if
         
         ## PSI:188220
         if (l_aux.socpgtopccod <> d_ctc00m02.socpgtopccod ) or
            (l_aux.socpgtopccod      is null and
             d_ctc00m02.socpgtopccod is not null ) or
            (l_aux.socpgtopccod      is not null and
             d_ctc00m02.socpgtopccod is null )   then
             
            if g_issk.dptsgl <> "psocor" and
               g_issk.dptsgl <> "desenv" then
               error "Alteracao Nao Permitida !!"
               sleep 2
               error ""
               let d_ctc00m02.socpgtopccod = l_aux.socpgtopccod
               display by name d_ctc00m02.socpgtopccod
               display by name d_ctc00m02.socpgtopcdes
               next field socpgtopccod
            end if
         end if
         
         # sugerir favorecido com os dados do prestador
         if d_ctc00m02.socfavnom is null
            then
            let d_ctc00m02.socfavnom = d_ctc00m02.nomrazsoc
         end if
         
         if d_ctc00m02.pestipfav is null
            then
            let d_ctc00m02.pestipfav = d_ctc00m02.pestip
         end if
         if d_ctc00m02.cgccpfnumfav is null
            then
            let d_ctc00m02.cgccpfnumfav = d_ctc00m02.cgccpfnum
         end if
         if d_ctc00m02.cgcordfav is null
            then
            let d_ctc00m02.cgcordfav = d_ctc00m02.cgcord
         end if
         if d_ctc00m02.cgccpfdigfav is null
            then
            let d_ctc00m02.cgccpfdigfav = d_ctc00m02.cgccpfdig
         end if
         
         # mostra informacoes de pagamento
         #--------------------------------
         let ws.callok  =  "n"
         call ctc00m05(param.operacao,
                       d_ctc00m02.pstcoddig,
                       d_ctc00m02.pestip,
                       d_ctc00m02.cgccpfnum,
                       d_ctc00m02.nomrazsoc,
                       d_ctc00m02.socpgtopccod,
                       d_ctc00m02.socpgtopcdes,
                       d_ctc00m02.socfavnom,
                       d_ctc00m02.pestipfav,
                       d_ctc00m02.cgccpfnumfav,
                       d_ctc00m02.cgcordfav,
                       d_ctc00m02.cgccpfdigfav,
                       d_ctc00m02.nscdat,
                       d_ctc00m02.sexcod,
                       d_ctc00m02.bcoctatip,
                       d_ctc00m02.bcocod   ,
                       d_ctc00m02.bcoagnnum,
                       d_ctc00m02.bcoagndig,
                       d_ctc00m02.bcoctanum,
                       d_ctc00m02.bcoctadig)
             returning
                       d_ctc00m02.socpgtopccod,
                       d_ctc00m02.socfavnom,
                       d_ctc00m02.pestipfav,
                       d_ctc00m02.cgccpfnumfav,
                       d_ctc00m02.cgcordfav,
                       d_ctc00m02.cgccpfdigfav,
                       d_ctc00m02.bcoctatip,
                       d_ctc00m02.bcocod   ,
                       d_ctc00m02.bcoagnnum,
                       d_ctc00m02.bcoagndig,
                       d_ctc00m02.bcoctanum,
                       d_ctc00m02.bcoctadig, 
                       d_ctc00m02.nscdat,
                       d_ctc00m02.sexcod,
                       ws.callok

         if ws.callok  is null   or
            ws.callok  <>  "s"   then
            error " Informacoes sobre opcao de pagamento nao confirmadas!"
            next field socpgtopccod
         end if

  before field qldgracod
         let l_aux.qldgracod = d_ctc00m02.qldgracod
         display by name d_ctc00m02.qldgracod   attribute(reverse)

  after  field qldgracod
         display by name d_ctc00m02.qldgracod

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field socpgtopccod
         end if
         
         initialize lr_retorno.* to null
         
         if d_ctc00m02.qldgracod is null 
            then
            call cty09g00_popup_iddkdominio("qldgracod")
                 returning lr_retorno.erro, d_ctc00m02.qldgracod, 
                           lr_retorno.cpodes
         end if
         
         if d_ctc00m02.qldgracod is null
            then
            error " Qualidade dos servicos deve ser informado!"
            let  d_ctc00m02.qldgracod = l_aux.qldgracod
            next field qldgracod
         else
            #PSI 222020 - Burini
            let l_aux2 = "qldgracod"
            open cctc00m02005 using l_aux2,
                                    d_ctc00m02.qldgracod
            fetch cctc00m02005 into d_ctc00m02.qldgrades

            if sqlca.sqlcode <> 0    then
                error " Qualidade dos servicos invalida!"
                next field qldgracod
            end if
         end if
         
         display by name d_ctc00m02.qldgrades  attribute(reverse)

  before field outciatxt
         let l_aux.outciatxt = d_ctc00m02.outciatxt
         
         # operador nao PS ou desenv so passa pelo campo sem cadastrar
         if g_issk.dptsgl <> "psocor" and
            g_issk.dptsgl <> "desenv" 
            then
            if fgl_lastkey() = fgl_keyval("up")    or
               fgl_lastkey() = fgl_keyval("left")  then
               next field qldgracod
            else
               next field prscootipcod
            end if
         else
            display by name d_ctc00m02.outciatxt attribute(reverse)
         end if
         
  after  field outciatxt
         display by name d_ctc00m02.outciatxt
         
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field qldgracod
         end if
         
         if d_ctc00m02.outciatxt is null then
            let l_popup = 'INTERNET AUTO|INTERNET RE|INTERNET AUTO E RE|LOTE|MANUAL'
            while true
               # montar a popup para a escolha da opcao
               call ctx14g01('Formas de pagamento', l_popup)
                    returning l_opcao, d_ctc00m02.outciatxt
               
               if l_opcao >= 0 then
                  exit while
               end if
               
            end while
            
            display by name d_ctc00m02.outciatxt
         end if
         
         if d_ctc00m02.outciatxt is null then
            error "Informe uma forma de pagamento:"
            let d_ctc00m02.outciatxt = l_aux.outciatxt
            next field outciatxt
         end if
         
         ## PSI:188220
         if (l_aux.outciatxt <> d_ctc00m02.outciatxt ) or
            (l_aux.outciatxt      is null and
             d_ctc00m02.outciatxt is not null ) or
            (l_aux.outciatxt      is not null and
             d_ctc00m02.outciatxt is null )   then

            if g_issk.dptsgl <> "psocor" and
               g_issk.dptsgl <> "desenv" then
               error "Alteracao Nao Permitida !!"
               sleep 2
               error ""
               let d_ctc00m02.outciatxt = l_aux.outciatxt
               display by name d_ctc00m02.outciatxt
               next field outciatxt
            end if
         end if
         ## FIM
         
         if d_ctc00m02.outciatxt <> "INTERNET AUTO" and
            d_ctc00m02.outciatxt <> "INTERNET RE"   and
            d_ctc00m02.outciatxt <> "INTERNET AUTO E RE" and
            d_ctc00m02.outciatxt <> "LOTE"               and
            d_ctc00m02.outciatxt <> "MANUAL"
            then
            error "Opcao invalida: ", d_ctc00m02.outciatxt clipped
            next field outciatxt
        end if
        
  before field prscootipcod
         let l_aux.prscootipcod = d_ctc00m02.prscootipcod
         display by name d_ctc00m02.prscootipcod   attribute(reverse)

  after  field prscootipcod
         display by name d_ctc00m02.prscootipcod

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field outciatxt
         end if
         
         ## PSI:188220
         if (l_aux.prscootipcod <> d_ctc00m02.prscootipcod ) or
            (l_aux.prscootipcod      is null and
             d_ctc00m02.prscootipcod is not null ) or
            (l_aux.prscootipcod      is not null and
             d_ctc00m02.prscootipcod is null )   
            then
            if g_issk.dptsgl <> "psocor" and
               g_issk.dptsgl <> "desenv" then
               error "Alteracao Nao Permitida !!"
               sleep 2
               error ""
               let d_ctc00m02.prscootipcod = l_aux.prscootipcod
               display by name d_ctc00m02.prscootipcod
               next field prscootipcod
            end if
         end if
         
         #PSI 222020 - Burini
         if d_ctc00m02.prscootipcod is not null 
            then
            if d_ctc00m02.prscootipcod =  1 
               then
               let d_ctc00m02.prscootipdes = "TAXI"
            else
               let l_aux2 = "prscootipcod"
               open cctc00m02005 using l_aux2,
                                       d_ctc00m02.prscootipcod
               fetch cctc00m02005 into d_ctc00m02.prscootipdes
               if sqlca.sqlcode != 0
                  then
                  error "Tipo de cooperativa nao cadastrado "
                  next field prscootipcod
               end if
            end if
         else
            initialize d_ctc00m02.prscootipdes to null
         end if
         
         display by name d_ctc00m02.prscootipdes
         
  before field vlrtabflg
         let l_aux.vlrtabflg = d_ctc00m02.vlrtabflg
         display by name d_ctc00m02.vlrtabflg   attribute(reverse)

  after  field vlrtabflg
         display by name d_ctc00m02.vlrtabflg   attribute(reverse)

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field prscootipcod
         end if
         
         if d_ctc00m02.vlrtabflg is null  then
            error " Prestador trabalha com tabela deve ser informado!"
            let  d_ctc00m02.vlrtabflg = l_aux.vlrtabflg
            next field vlrtabflg
         else
            
            # solicitado retirar para que o operador da vistoria possa cadastrar
            # um prestador, este campo e nao nulo (31/03/2009)
            #if (l_aux.vlrtabflg <> d_ctc00m02.vlrtabflg ) or
            #   (l_aux.vlrtabflg      is null and
            #    d_ctc00m02.vlrtabflg is not null ) or
            #   (l_aux.vlrtabflg      is not null and
            #    d_ctc00m02.vlrtabflg is null )   then
            #
            #   if g_issk.dptsgl <> "psocor" and
            #      g_issk.dptsgl <> "desenv" then
            #      error "Alteracao Nao Permitida !!"
            #      sleep 2
            #      error ""
            #      let d_ctc00m02.vlrtabflg = l_aux.vlrtabflg
            #      display by name d_ctc00m02.vlrtabflg
            #      next field vlrtabflg
            #   end if
            #end if
            
            if d_ctc00m02.vlrtabflg <> "S"  and
               d_ctc00m02.vlrtabflg <> "N"  then
               error " Prestador trabalha com tabela: (S)im ou (N)ao !"
               next field vlrtabflg
            end if
         end if

         #BURINI if d_ctc00m02.vlrtabflg = "N"    then
         #BURINI    initialize d_ctc00m02.soctrfcod   to null
         #BURINI    initialize d_ctc00m02.soctrfdes   to null
         #BURINI    display by name d_ctc00m02.soctrfcod
         #BURINI    display by name d_ctc00m02.soctrfdes
         #BURINI    next field rmesoctrfcod
         #BURINI end if

         #BURINI before field soctrfcod
         #BURINI     let l_aux.soctrfcod = d_ctc00m02.soctrfcod
         #BURINI     display by name d_ctc00m02.soctrfcod attribute(reverse)
         #BURINI
         #BURINI after field soctrfcod
         #BURINI     display by name d_ctc00m02.soctrfcod
         #BURINI
         #BURINI        if fgl_lastkey() = fgl_keyval("up")    or
         #BURINI           fgl_lastkey() = fgl_keyval("left")  then
         #BURINI           next field vlrtabflg
         #BURINI        end if
         #BURINI
         #BURINI        if d_ctc00m02.soctrfcod  is null   or
         #BURINI           d_ctc00m02.soctrfcod  =  0      then
         #BURINI           error " Codigo da tarifa deve ser informada!"
         #BURINI           call ctb10m05()  returning d_ctc00m02.soctrfcod
         #BURINI          ## next field soctrfcod
         #BURINI        end if
         #BURINI
         #BURINI        ## PSI:188220
         #BURINI        if (l_aux.soctrfcod <> d_ctc00m02.soctrfcod ) or
         #BURINI           (l_aux.soctrfcod      is null and
         #BURINI            d_ctc00m02.soctrfcod is not null ) or
         #BURINI           (l_aux.soctrfcod      is not null and
         #BURINI            d_ctc00m02.soctrfcod is null )   then
         #BURINI
         #BURINI           if g_issk.dptsgl <> "psocor" and
         #BURINI              g_issk.dptsgl <> "desenv" then
         #BURINI              error "Alteracao Nao Permitida !!"
         #BURINI              sleep 2
         #BURINI              error ""
         #BURINI              let d_ctc00m02.soctrfcod = l_aux.soctrfcod
         #BURINI              display by name d_ctc00m02.soctrfcod
         #BURINI              next field soctrfcod
         #BURINI           end if
         #BURINI        end if
         #BURINI        ## FIM
         #BURINI
         #BURINI
         #BURINI        select soctrfdes, soctip
         #BURINI          into d_ctc00m02.soctrfdes, ws.soctip
         #BURINI          from dbsktarifasocorro
         #BURINI         where soctrfcod = d_ctc00m02.soctrfcod
         #BURINI
         #BURINI        if sqlca.sqlcode  <>  0   then
         #BURINI           error " Tarifa nao cadastrada!"
         #BURINI           call ctb10m05()  returning d_ctc00m02.soctrfcod
         #BURINI           next field soctrfcod
         #BURINI        else
         #BURINI           if ws.soctip <> 1 then
         #BURINI              error " Tarifa nao pertence ao Porto Socorro!"
         #BURINI              next field soctrfcod
         #BURINI           end if
         #BURINI           display by name d_ctc00m02.soctrfdes
         #BURINI        end if

  before field rmesoctrfcod
         let l_aux.rmesoctrfcod = d_ctc00m02.rmesoctrfcod
         
         initialize d_ctc00m02.soctrfdes_re   to null
         
         display by name d_ctc00m02.soctrfdes_re
         
         # operador nao PS ou desenv so passa pelo campo sem cadastrar
         if g_issk.dptsgl <> "psocor" and
            g_issk.dptsgl <> "desenv" 
            then
            if fgl_lastkey() = fgl_keyval("up")    or
               fgl_lastkey() = fgl_keyval("left")  then
               next field vlrtabflg
            else
               next field pstobs
            end if
         else
            display by name d_ctc00m02.rmesoctrfcod attribute(reverse)
         end if
         
  after  field rmesoctrfcod
         display by name d_ctc00m02.rmesoctrfcod

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            if d_ctc00m02.vlrtabflg  =  "N"   then
               next field vlrtabflg
            end if
            #next field soctrfcod
         end if
         
         ## PSI:188220
         if (l_aux.rmesoctrfcod <> d_ctc00m02.rmesoctrfcod ) or
            (l_aux.rmesoctrfcod      is null and
             d_ctc00m02.rmesoctrfcod is not null ) or
            (l_aux.rmesoctrfcod      is not null and
             d_ctc00m02.rmesoctrfcod is null )   then

            if g_issk.dptsgl <> "psocor" and
               g_issk.dptsgl <> "desenv" then
               error "Alteracao Nao Permitida !!"
               sleep 2
               error ""
               let d_ctc00m02.rmesoctrfcod = l_aux.rmesoctrfcod
               display by name d_ctc00m02.rmesoctrfcod
               next field rmesoctrfcod
            end if
         end if
         
         if d_ctc00m02.rmesoctrfcod  is not null then
            select soctrfdes, soctip
              into d_ctc00m02.soctrfdes_re, ws.soctip
              from dbsktarifasocorro
             where soctrfcod = d_ctc00m02.rmesoctrfcod

            if sqlca.sqlcode  <>  0   then
               error " Tarifa nao cadastrada!"
               call ctb10m05()  returning d_ctc00m02.rmesoctrfcod
               next field rmesoctrfcod
            else
               if ws.soctip <> 3 then
                  error " Tarifa nao pertence ao RE(Ramos Elementares)!"
                  next field rmesoctrfcod
               end if
               display by name d_ctc00m02.soctrfdes_re
            end if
         end if

  before field frtrpnflg
         # operador nao PS ou desenv so passa pelo campo sem cadastrar
         if g_issk.dptsgl <> "psocor" and
            g_issk.dptsgl <> "propat" and
            g_issk.dptsgl <> "desenv" 
            then
            if fgl_lastkey() = fgl_keyval("up")    or
               fgl_lastkey() = fgl_keyval("left")  then
               next field qldgracod
            else
               next field pstobs
            end if
         else
            display by name d_ctc00m02.frtrpnflg attribute(reverse)
         end if
         
  after  field frtrpnflg
         initialize lr_retorno.* to null
         if  d_ctc00m02.frtrpnflg is null or d_ctc00m02.frtrpnflg = " " then
             call cty09g00_popup_iddkdominio("frtrpnflg")
                  returning lr_retorno.erro,
                            d_ctc00m02.frtrpnflg,
                            d_ctc00m02.frtrpndes
         else
             #PSI 222020 - Burini
             let l_aux2 = "frtrpnflg"
             open cctc00m02005 using l_aux2,
                                     d_ctc00m02.frtrpnflg
             fetch cctc00m02005 into d_ctc00m02.frtrpndes
             
             if  sqlca.sqlcode <> 0 then
                 error 'Responsavel nao cadastrado'
                 let d_ctc00m02.frtrpnflg = ""
                 let d_ctc00m02.frtrpndes = ""
                 next field frtrpnflg
             end if
             
             if  l_frtrpnflg <> d_ctc00m02.frtrpnflg and
                 d_ctc00m02.frtrpnflg = 1            and
                 g_issk.dptsgl <> "psocor"           and
                 g_issk.dptsgl <> "propat"           and
                 g_issk.dptsgl <> "desenv"           then
                 error 'Somente usuarios PORTO SOCORRO podem fazer essa operação'
                 let d_ctc00m02.frtrpnflg = ""
                 let d_ctc00m02.frtrpndes = ""
                 next field frtrpnflg
             end if
         end if
         
         display by name d_ctc00m02.frtrpndes attribute(reverse)
         display by name d_ctc00m02.frtrpnflg attribute(reverse)

  before field pstobs
         let l_aux.pstobs =  d_ctc00m02.pstobs
         display by name d_ctc00m02.pstobs    attribute(reverse)

  after  field pstobs
         display by name d_ctc00m02.pstobs
         
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field frtrpnflg
         end if
         
         # solicitado retirar para que o operador da vistoria possa cadastrar
         # um prestador, este campo e nao nulo (31/03/2009)
         #if (l_aux.pstobs <> d_ctc00m02.pstobs ) or
         #   (l_aux.pstobs      is null and
         #    d_ctc00m02.pstobs is not null ) or
         #   (l_aux.pstobs      is not null and
         #    d_ctc00m02.pstobs is null )   then
         #
         #   if g_issk.dptsgl <> "psocor" and
         #      g_issk.dptsgl <> "desenv" then
         #      error "Alteracao Nao Permitida !!"
         #      sleep 2
         #      error ""
         #      let d_ctc00m02.pstobs = l_aux.pstobs
         #      display by name d_ctc00m02.pstobs
         #      next field pstobs
         #   end if
         #end if
         
  before field intsrvrcbflg
         display by name d_ctc00m02.intsrvrcbflg attribute(reverse)
         display by name d_ctc00m02.intdescr     attribute(reverse)

  after  field intsrvrcbflg
         display by name d_ctc00m02.intsrvrcbflg
         display by name d_ctc00m02.intdescr attribute(reverse)
         
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  
            then
            next field pstobs
         end if
         
         if d_ctc00m02.intsrvrcbflg = "1"    # acionamento internet
            then
            let d_ctc00m02.intdescr  =  "INTERNET"
         else
            let d_ctc00m02.intsrvrcbflg = null
            let d_ctc00m02.intdescr     = null
         end if
         
         display by name d_ctc00m02.intsrvrcbflg
         display by name d_ctc00m02.intdescr
         
  before field risprcflg
         let l_aux.risprcflg = d_ctc00m02.risprcflg
         display by name d_ctc00m02.risprcflg attribute (reverse)
         error " Prestador preenche RIS: (S)im ou (N)ao !"
         
  after  field risprcflg
         display by name d_ctc00m02.risprcflg attribute (reverse)
         
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  
            then
            next field intsrvrcbflg
         end if
         
         if d_ctc00m02.risprcflg is null 
            then
            error " Prestador preenche RIS deve ser informado !"
            let d_ctc00m02.risprcflg = l_aux.risprcflg
            next field risprcflg
         else
            # solicitado retirar para que o operador da vistoria possa cadastrar
            # um prestador, este campo e nao nulo (31/03/2009)
            #if (l_aux.risprcflg <> d_ctc00m02.risprcflg   ) or
            #   (l_aux.risprcflg is null and d_ctc00m02.risprcflg is not null) or
            #   (l_aux.risprcflg is not null and d_ctc00m02.risprcflg is null) 
            #   then
            #   if g_issk.dptsgl <> "psocor" and
            #      g_issk.dptsgl <> "desenv" then
            #      error "Alteracao nao permitida !!" sleep 2
            #      let d_ctc00m02.risprcflg = l_aux.risprcflg
            #      display by name d_ctc00m02.risprcflg
            #      next field risprcflg
            #   end if
            #end if
            
            if d_ctc00m02.risprcflg <> "S" and
               d_ctc00m02.risprcflg <> "N" then
               error " Prestador preenche RIS: (S)im ou (N)ao !"
               next field risprcflg
            end if
         end if
         
         next field simoptpstflg
         
  # Nao mais utilizado apos 18/02/2010 - PSI 198404
  # before field nitnum
  #        display by name d_ctc00m02.nitnum attribute(reverse)
  # 
  # after  field nitnum
  #        display by name d_ctc00m02.nitnum
  # 
  #        if fgl_lastkey() = fgl_keyval("up")    or
  #           fgl_lastkey() = fgl_keyval("left")  
  #           then
  #           if d_ctc00m02.pestip = "F" and
  #              d_ctc00m02.pisnum is null and
  #              d_ctc00m02.nitnum is null
  #              then
  #              next field pisnum
  #           else
  #              next field risprcflg
  #           end if
  #        end if
  #        
  #        if d_ctc00m02.pestip = "F" and
  #           d_ctc00m02.pisnum is null and
  #           d_ctc00m02.nitnum is null
  #           then
  #           error " Numero do NIT ou PIS obrigtório para prestador pessoa física "
  #           next field nitnum
  #        end if
         
  before field simoptpstflg
         if d_ctc00m02.simoptpstflg is null
            then
            let d_ctc00m02.simoptpstflg = "N"
         end if
         let l_aux.simoptpstflg = d_ctc00m02.simoptpstflg  # PSI-11-19199PR
         
         display by name d_ctc00m02.simoptpstflg attribute(reverse)
         
  after field simoptpstflg
         #RETIRADO BURINI if param.operacao  =  "m"   then           # ini PSI-11-19199PR
         #RETIRADO BURINI    if d_ctc00m02.simoptpstflg <> l_aux.simoptpstflg then
         #                       let d_ctc00m02.simoptpstflg = l_aux.simoptpstflg
         #RETIRADO BURINI       error " Nao e permitido alterar o campo, somente no Portal Prestador"; sleep 3
         #RETIRADO BURINI       next field simoptpstflg
         #RETIRADO BURINI    end if
         #RETIRADO BURINI end if                                     # fim PSI-11-19199PR
         if fgl_lastkey() = fgl_keyval("up") or
            fgl_lastkey() = fgl_keyval("left")
            then
            next field risprcflg
         end if
         
         if d_ctc00m02.simoptpstflg is null or
            (d_ctc00m02.simoptpstflg != "S"  and
             d_ctc00m02.simoptpstflg != "N")
            then
            error " Prestador optante pelo simples: (S)im ou (N)ao"
            next field simoptpstflg
         end if
         
  on key (interrupt)
     #Ao interromper elina todos os endereços com prestador zerado
     whenever error continue
     
     execute pctc00m02010     
     
     whenever error stop
     exit input

  end input
  
  if  int_flag  then
      error " Operacao Cancelada!"
  else
      #call ctc00m02_atualiza_veic()
  end if

  return

end function    #-- ctc00m02_input

#------------------------------------------------------------
function ctc00m02_cancela(param)
#------------------------------------------------------------

  define param      record
     pstcoddig      like dpaksocor.pstcoddig
  end record
 
  let int_flag = false
 
  if d_ctc00m02.prssitcod = "C"  then
     error "Prestador ja' cancelado!"
     return
  end if
 
  input by name d_ctc00m02.pstobs without defaults
 
      before field pstobs
         display by name d_ctc00m02.pstobs attribute (reverse)
 
      after field pstobs
         display by name d_ctc00m02.pstobs
 
         if d_ctc00m02.pstobs is null  then
            error "Informe o motivo do cancelamento!"
            next field pstobs
         end if
 
      on key (interrupt, control-c)
         exit input

  end input

  if int_flag = false  then
  
     call ctc30m00_remove_caracteres(d_ctc00m02.pstobs)
            returning d_ctc00m02.pstobs
            
     update dpaksocor
        set (atldat, funmat, pstobs, prssitcod)
          = (today, g_issk.funmat, d_ctc00m02.pstobs, "C")
       where pstcoddig = param.pstcoddig

     if sqlca.sqlcode <> 0  then
        error "Erro (", sqlca.sqlcode, ") no cancelamento do prestador. AVISE A INFORMATICA!"
     else
        error " Prestador cancelado!"
     end if
  else
     error " Operacao cancelada!"
  end if

  let int_flag = false

end function   ### ctc00m02_cancela


#------------------------------------------------------------
function ctc00m02_veiculos(param)
#------------------------------------------------------------

  define param      record
     pstcoddig      like dpaksocor.pstcoddig
  end record
 
  define ws         record
     socvclcod      like datkveiculo.socvclcod,
     temvclflg      char (01) ,
     confirma       char (01)
  end record
 
 
  initialize ws.*   to null
  
  # VERIFICA SE EXISTEM VEICULOS ATIVOS
  #---------------------------------------
  let ws.temvclflg = "n"
  declare c_datkveiculo  cursor for
     select socvclcod
       from datkveiculo
      where datkveiculo.pstcoddig     =   param.pstcoddig
        and datkveiculo.socoprsitcod  <>  3
 
  foreach c_datkveiculo  into  ws.socvclcod
     exit foreach
  end  foreach
 
  if ws.socvclcod  is not null   then
     error " Existe(m) veiculo(s) nao cancelado(s)! --> ", ws.socvclcod
     call cts08g01("A","N","","ANTES DE REALIZAR O CANCELAMENTO",
                              "DO PRESTADOR, TODOS OS SEUS",
                              "VEICULOS DEVEM SER CANCELADOS")
          returning ws.confirma
     let ws.temvclflg = "s"
  end if
 
  return ws.temvclflg

end function   ### ctc00m02_veiculos


#------------------------------------------------------------
function ctc00m02_socorristas(param)
#------------------------------------------------------------

  define param      record
     pstcoddig      like dpaksocor.pstcoddig
  end record
 
  define ws         record
     pstcoddig      like datrsrrpst.pstcoddig,
     srrcoddig      like datrsrrpst.srrcoddig,
     temsrrflg      char (01) ,
     confirma       char (01)
  end record
 
 
  initialize ws.*   to null
  let ws.temsrrflg = "n"
 
  # VERIFICA SE EXISTEM SOCORRISTAS ATIVOS
  #---------------------------------------
  declare c_datrsrrpst_1  cursor for
     select datrsrrpst.srrcoddig
       from datrsrrpst, datksrr
      where datrsrrpst.pstcoddig  =  param.pstcoddig
        and datksrr.srrcoddig     =  datrsrrpst.srrcoddig
        and datksrr.srrstt        <> 3
 
  foreach c_datrsrrpst_1  into  ws.srrcoddig
 
      declare c_datrsrrpst_2  cursor for
         select pstcoddig, vigfnl
           from datrsrrpst
          where datrsrrpst.srrcoddig  =  ws.srrcoddig
          order by vigfnl desc
 
      initialize ws.pstcoddig  to null
 
      open  c_datrsrrpst_2
      fetch c_datrsrrpst_2  into  ws.pstcoddig
      close c_datrsrrpst_2
      if ws.pstcoddig  =  param.pstcoddig   then
         let ws.temsrrflg = "s"
         exit foreach
      end if
 
  end foreach
 
  if ws.temsrrflg  =  "s"   then
     error " Existe(m) socorrista(s) nao cancelado(s)! --> ", ws.srrcoddig
     call cts08g01("A","N","","ANTES DE REALIZAR O CANCELAMENTO",
                              "DO PRESTADOR, TODOS OS SEUS",
                              "SOCORRISTAS DEVEM SER CANCELADOS")
          returning ws.confirma
  end if
 
  return ws.temsrrflg

end function   ### ctc00m02_socorristas


#---------------------------------#
function ctc00m02_empresas(l_pstcoddig)
#---------------------------------#
    define l_pstcoddig   like dpaksocor.pstcoddig

    define a_empresas array[15] of record
        ciaempcod   like gabkemp.empcod
    end record

    define l_ret   smallint,
           l_mensagem char(60),
           l_aux  smallint,
           l_total smallint

    #Grava historico de alteracao empresas
    define idx1, idx2 smallint
    define a_emp_ant  array[15] of record
           ciaempcod   like gabkemp.empcod
    end record

    define l_prshstdes  char(2000),
           l_empsgl     like gabkemp.empsgl
    
    
    initialize a_empresas, a_emp_ant to null

    let l_ret = 0
    let l_mensagem = null
    let l_aux = 1
    let l_total = 0

    call ctd03g00_empresas(1, l_pstcoddig)
         returning l_ret,
                   l_mensagem,
                   l_total,
                   a_empresas[1].ciaempcod,
                   a_empresas[2].ciaempcod,
                   a_empresas[3].ciaempcod,
                   a_empresas[4].ciaempcod,
                   a_empresas[5].ciaempcod,
                   a_empresas[6].ciaempcod,
                   a_empresas[7].ciaempcod,
                   a_empresas[8].ciaempcod,
                   a_empresas[9].ciaempcod,
                   a_empresas[10].ciaempcod,
                   a_empresas[11].ciaempcod,
                   a_empresas[12].ciaempcod,
                   a_empresas[13].ciaempcod,
                   a_empresas[14].ciaempcod,
                   a_empresas[15].ciaempcod

    let a_emp_ant.* = a_empresas.*

    #Abrir janela para atualizacao de empresas para o prestador
    call ctc00m03(1,
                  a_empresas[1].ciaempcod,
                  a_empresas[2].ciaempcod,
                  a_empresas[3].ciaempcod,
                  a_empresas[4].ciaempcod,
                  a_empresas[5].ciaempcod,
                  a_empresas[6].ciaempcod,
                  a_empresas[7].ciaempcod,
                  a_empresas[8].ciaempcod,
                  a_empresas[9].ciaempcod,
                  a_empresas[10].ciaempcod,
                  a_empresas[11].ciaempcod,
                  a_empresas[12].ciaempcod,
                  a_empresas[13].ciaempcod,
                  a_empresas[14].ciaempcod,
                  a_empresas[15].ciaempcod   )
        returning l_ret,
                  l_mensagem,
                  a_empresas[1].ciaempcod,
                  a_empresas[2].ciaempcod,
                  a_empresas[3].ciaempcod,
                  a_empresas[4].ciaempcod,
                  a_empresas[5].ciaempcod,
                  a_empresas[6].ciaempcod,
                  a_empresas[7].ciaempcod,
                  a_empresas[8].ciaempcod,
                  a_empresas[9].ciaempcod,
                  a_empresas[10].ciaempcod,
                  a_empresas[11].ciaempcod,
                  a_empresas[12].ciaempcod,
                  a_empresas[13].ciaempcod,
                  a_empresas[14].ciaempcod,
                  a_empresas[15].ciaempcod

    if l_ret = 1 then
       #apagar empresas cadastradas ao prestador
       call ctd03g00_delete_dparpstemp(l_pstcoddig)
            returning l_ret,
                      l_mensagem
       #inserir empresas cadastradas ao prestador
       if l_ret = 1 then
          let l_prshstdes = null
          #percorrer array de empresas e inserir para o prestador
          while l_aux <= 15    #tamanho do array
                if a_empresas[l_aux].ciaempcod is not null then
                    call ctd03g00_insert_dparpstemp(l_pstcoddig,
                                                    a_empresas[l_aux].ciaempcod)
                         returning l_ret,
                                   l_mensagem
                    if l_ret = 1 then
                       #Se retorno OK grava o historico de alteracoes na tabela,
                       #onde l_ret: 0=inalterado, 1=incluido, -1=excluido

                       let l_ret = 1
                       for idx2 = 1 to 15
                          if a_empresas[l_aux].ciaempcod =
                             a_emp_ant[idx2].ciaempcod then
                             let l_ret = 0
                             let a_emp_ant[idx2].ciaempcod = null
                             exit for
                          end if
                       end for
                       if l_ret = 1 then
                          #Buscar a descricao da empresa
                          call cty14g00_empresa(1, a_empresas[l_aux].ciaempcod)
                               returning l_ret,
                                         l_mensagem,
                                         l_empsgl

                          if l_prshstdes is null then
                              let l_prshstdes =
                                  a_empresas[l_aux].ciaempcod using "<<<<&",
                                  " - ", l_empsgl clipped
                          else
                              let l_prshstdes = l_prshstdes clipped, ", ",
                                  a_empresas[l_aux].ciaempcod using "<<<<&",
                                  " - ", l_empsgl clipped
                          end if
                       end if
                       
                       #Verifica se a OP e People ou SAP  Inicio  #Fornax-Quantum  
                       call ffpgc377_verificarIntegracaoAtivaEmpresaRamo("034PTSOC",today,a_empresas[l_aux].ciaempcod, 0)  
                            returning  mr_retSAP.stt                                                                 
                                      ,mr_retSAP.msg     
                              
                       display "mr_retSAP.stt ", mr_retSAP.stt
                       display "mr_retSAP.msg ", mr_retSAP.msg                                                             
                       
                       if mr_retSAP.stt <> 0 then 
                          call ctc00m02_carrega_var_global_sap(a_empresas[l_aux].ciaempcod)
                       end if
                    else
                       error l_mensagem
                       exit while
                    end if
                    let l_aux = l_aux + 1
                else
                    #se é nulo mas não chegou no fim do array - continua
                    # pois em ctc00m03 se tentar inserir com f1, mas
                    # não informar ciaempcod e nem excluir a linha
                    let l_aux = l_aux + 1
                end if
          end while

          #Grava mensagem de empresas incluidas
          if l_prshstdes is not null then
             let idx1 = length(l_prshstdes clipped)
             let l_prshstdes =
                 "Empresa(s) incluida(s) [", l_prshstdes clipped, "] !"
             call ctc00m02_grava_hist(l_pstcoddig,
                                      l_prshstdes,
                                      'I')

          end if

          #Gera mensagem de empresas excluidas
          let l_prshstdes = null
          for idx1 = 1 to 15
             if a_emp_ant[idx1].ciaempcod is not null then
                let l_ret = -1
                for idx2 = 1 to 15
                   if a_emp_ant[idx1].ciaempcod =
                      a_empresas[idx2].ciaempcod then
                      let l_ret = 0
                      exit for
                   end if
                end for
                if l_ret = -1 then
                   #Buscar a descricao da empresa
                   call cty14g00_empresa(1, a_emp_ant[idx1].ciaempcod)
                        returning l_ret,
                                  l_mensagem,
                                  l_empsgl

                   if l_prshstdes is null then
                       let l_prshstdes =
                           a_emp_ant[idx1].ciaempcod using "<<<<&",
                           " - ", l_empsgl clipped
                   else
                       let l_prshstdes = l_prshstdes clipped, ", ",
                           a_emp_ant[idx1].ciaempcod using "<<<<&",
                           " - ", l_empsgl clipped
                   end if
                end if
             end if
          end for

          if l_prshstdes is not null then
             let idx1 = length(l_prshstdes clipped)
             let l_prshstdes =
                 "Empresa(s) excluida(s) [", l_prshstdes clipped, "] !"
             call ctc00m02_grava_hist(l_pstcoddig,
                                      l_prshstdes,
                                      'E')
          end if
       else
          error l_mensagem
       end if
    else
       error l_mensagem
    end if

    return

end function #ctc00m02_empresas

#-------------------------------------#
function ctc00m02_grava_hist(lr_param)
#-------------------------------------#
  define lr_param record
         pstcoddig   like dpaksocor.pstcoddig,
         prshstdes   char(2000),
         operacao    char(1)
  end record
  
  define lr_ret record
         texto1  char(70)
        ,texto2  char(70)
        ,texto3  char(70)
        ,texto4  char(70)
        ,texto5  char(70)
        ,texto6  char(70)
        ,texto7  char(70)
        ,texto8  char(70)
        ,texto9  char(70)
        ,texto10 char(70)
  end record

  define l_stt       smallint
        ,l_path      char(100)
        ,l_cmd2      char(4000)
        ,l_texto2    char(3000)

  define l_dbsseqcod  like dbsmhstprs.dbsseqcod,
         l_prshstdes2 like dbsmhstprs.prshstdes,
         l_texto      like dbsmhstprs.prshstdes,
         l_cmtnom     like isskfunc.funnom,
         l_data       date,
         l_hora       datetime hour to minute,
         l_count,
         l_iter,
         l_length,
         l_length2    smallint,
         l_msg        char(50),
         l_erro       smallint,
         l_cmd        char(100),
         l_corpo_email char(1000),
         teste         char(1)

  let l_msg = null

  if m_prep_sql is null or
     m_prep_sql <> true then
     call ctc00m02_prepare()
  end if
  
  #Buscar ultimo item de historico cadastrado para o prestador
  let l_dbsseqcod = 0
  select max(dbsseqcod) into l_dbsseqcod
    from dbsmhstprs
   where pstcoddig = lr_param.pstcoddig
  
  if l_dbsseqcod is null or l_dbsseqcod = 0 then
     let l_dbsseqcod = 1
  else
     let l_dbsseqcod = l_dbsseqcod + 1
  end if

  #Busca data e hora do banco
  call cts40g03_data_hora_banco(2) returning l_data, l_hora
  
  let l_length = length(lr_param.prshstdes clipped)
  if  l_length mod 70 = 0 then
      let l_iter = l_length / 70
  else
      let l_iter = l_length / 70 + 1
  end if

  let l_corpo_email = null
  let l_length2     = 0
  let l_erro        = 0

  for l_count = 1 to l_iter
      if  l_count = l_iter then
          let l_prshstdes2 = lr_param.prshstdes[l_length2 + 1, l_length]
      else
          let l_length2 = l_length2 + 70
          let l_prshstdes2 = lr_param.prshstdes[l_length2 - 69, l_length2]
      end if

      # grava historico para o prestador
      execute pctc00m02004 using lr_param.pstcoddig,
                                 l_dbsseqcod,
                                 l_prshstdes2,
                                 l_data,
                                 g_issk.empcod,
                                 g_issk.usrtip,
                                 g_issk.funmat

      if sqlca.sqlcode <> 0  then
          error "Erro (", sqlca.sqlcode, ") na inclusao do historico (dbsmhstprs). "
          let l_erro = sqlca.sqlcode
      end if

      if l_erro <> 0 then
         exit for
      end if

      let l_dbsseqcod  = l_dbsseqcod + 1

  end for

  if l_erro = 0 then
     #Envia Email para o prestador

     case lr_param.operacao
        when 'I'
           let l_msg = 'Inclusao no Cadastro do Prestador: Codigo  ',
                       lr_param.pstcoddig
        when 'E'
           let l_msg = 'Exclusao no Cadastro do Prestador: Codigo  ',
                       lr_param.pstcoddig
        when 'A'
           let l_msg = 'Alteracao no Cadastro do Prestador: Codigo  ',
                       lr_param.pstcoddig
     end case

     initialize l_cmtnom   to null

     select funnom  into  l_cmtnom
     from isskfunc
     where funmat = g_issk.funmat
      and empcod  = g_issk.empcod

     call ctb85g01_mtcorpo_email_html("CTC00M02",
                                      l_data,
                                      l_hora,
                                      g_issk.empcod,
                                      g_issk.usrtip,
                                      g_issk.funmat,
                                      l_msg,
                                      lr_param.prshstdes clipped)
                            returning l_erro

     if l_erro <> 0 then
        error "Erro Envio do Email ", l_erro
     end if
  end if

end function

#---------------------------------#
function ctc00m02_atualiza_veic()
#---------------------------------#

  define l_socvclcod like datkveiculo.socvclcod,
         l_erro      smallint

  begin work

  let l_erro = false

  open cctc00m02006 using k_ctc00m02.pstcoddig

  display 'ATUALIZANDO VEICULOS'

  foreach cctc00m02006 into l_socvclcod
  
      #execute pctc00m02007 using d_ctc00m02.frtrpnflg,
      #                           l_socvclcod

      if  sqlca.sqlcode <> 0 then
          let l_erro = true
          rollback work
          exit foreach
      end if

  end foreach

  if  not l_erro then
      commit work
  end if

end function


#----------------------------------------------------------------
function ctc00m02_valida_ddd(l_ddd)
#----------------------------------------------------------------

  define l_ddd char(4) ,
         l_tam smallint
  
  let l_tam = 0
  
  if l_ddd   = "   "    or
     l_ddd   = "0   "   or
     l_ddd   = "00  "   or
     l_ddd   = "000 "   or
     l_ddd   = "0000"   or
     l_ddd   = "0"
     then
     return false
  end if
  
  let l_tam = length(l_ddd)
  
  if l_tam  <  2  then
     return false
  end if
  
  if l_tam =  4 and
     l_ddd  <  099   
     then
     if l_ddd[1,1] = "0"   then
        return false
     end if
  end if
  
  return true
  
end function

#Fornax-Quantum - inicio
#Incluir chamada da API 034 - inicio
#------------------------------------------
function ctc00m02_carrega_var_global_sap(lr_param)
#------------------------------------------

  define lr_param record 
         empcod  char(02)
  end record 

  define l_termoPesquisa1,
         l_termoPesquisa2 char (20)
  
  #inicializa GLOBAIS
  initialize gr_034_cab_fcd_v1.*     ,gr_034_pesdad_v1.*
            ,gr_034_pes_pf_v1.*      ,gr_034_pes_pj_v1.*
            ,gr_034_end_v1.*         ,gr_034_ctt_v1.*
            ,gr_034_doc_pj_v1.*      ,gr_034_doc_pf_v1.*
            ,gr_034_fin_v1.*         ,gr_034_req_v1.*   
            ,gr_aci_req_head.*       ,gr_034_cpom_v1 to null
   
           
  #Carrega globais de comunicacao entre as API's e Interfaces SAP (header)
  let gr_aci_req_head.id_integracao   = "034PTSOC"
  let gr_aci_req_head.usuario         = g_issk.funmat  #Nao requerido
  
  
  # Carrega Dados Fixos que sao enviados para o SAP
  let gr_034_cab_fcd_v1.tip_pcr_neg   = "0001"
  let gr_034_cab_fcd_v1.origem_dados  = "Z011"
  let gr_034_cpom_v1.valido           = "N"
  let gr_034_cta_ctr_v1.cat_ct_ctr    = "PR" 
  let gr_034_cta_ctr_v1.gr_prev_tes   = "PG"
  let gr_034_cta_ctr_v1.visao_cta_ext = "E"
  
  
  
  # Carrega Dados do prestador por Tipo de pessoa
   if d_ctc00m02.pestip = "J" then
      let gr_034_cab_fcd_v1.tipo_pessoa   = "PJ"
      let gr_034_doc_pj_v1.numero_cnpj    = d_ctc00m02.cgccpfnum  using '&&&&&&&&'
      let gr_034_doc_pj_v1.ordem_cnpj     = d_ctc00m02.cgcord     using '&&&&'    
      let gr_034_doc_pj_v1.digito_cnpj    = d_ctc00m02.cgccpfdig  using '&&'
      let gr_034_doc_pj_v1.ins_municipal  = d_ctc00m02.muninsnum      
      
      let l_termoPesquisa1 = gr_034_doc_pj_v1.numero_cnpj using '&&&&&&&&', '/',
                             gr_034_doc_pj_v1.ordem_cnpj using '&&&&', '-', 
                             gr_034_doc_pj_v1.digito_cnpj using '&&'
      
      if d_ctc00m02.simoptpstflg = "S" then
         let gr_034_doc_pj_v1.set_industrial = "ZSN01"
      else
         let gr_034_doc_pj_v1.set_industrial = " "
      end if
      
      let gr_034_pes_pj_v1.nome_fantasia = l_termoPesquisa1
      let gr_034_pes_pj_v1.compl_nom_fant = d_ctc00m02.nomgrr
      
   else
   
      let gr_034_cab_fcd_v1.tipo_pessoa     = "PF"
      let gr_034_pes_pf_v1.sexo             = d_ctc00m02.sexcod
      let gr_034_pes_pf_v1.data_nascimento  = d_ctc00m02.nscdat using "ddmmyyyy"
      let gr_034_doc_pf_v1.numero_cpf       = d_ctc00m02.cgccpfnum using '&&&&&&&&&'
      let gr_034_doc_pf_v1.digito_cpf       = d_ctc00m02.cgccpfdig using '&&'
      let gr_034_doc_pf_v1.nit             =  d_ctc00m02.pisnum
      let gr_034_pes_pf_v1.termo_pesquisa1 = gr_034_doc_pf_v1.numero_cpf using '&&&&&&&&&', '-', 
                                             gr_034_doc_pf_v1.digito_cpf using '&&'
      let gr_034_pes_pf_v1.termo_pesquisa2 = d_ctc00m02.nomgrr
   end if
  
  
  let gr_034_cab_fcd_v1.empresa       = lr_param.empcod using "&&&"
  let gr_034_pesdad_v1.nome_parceiro  = d_ctc00m02.nomrazsoc  
 
  
  #Dados Endereco                       
  let gr_034_end_v1.logradouro        = d_ctc00m02.endlgd
  let gr_034_end_v1.numero            = d_ctc00m02.lgdnum
  let gr_034_end_v1.comp_endereco     = d_ctc00m02.endcmp
  let gr_034_end_v1.codigo_postal     = d_ctc00m02.endcep using "&&&&&", '-', d_ctc00m02.endcepcmp using "&&&"
  let gr_034_end_v1.bairro            = d_ctc00m02.endbrr
  let gr_034_end_v1.cidade            = d_ctc00m02.endcid
  let gr_034_end_v1.estado            = d_ctc00m02.endufd

  #Dados Contato                        
  let gr_034_ctt_v1.telefone          = d_ctc00m02.teltxt
  let gr_034_ctt_v1.celular           = d_ctc00m02.celtelnum

  
  #Financeiro                           
  let gr_034_fin_v1.codigo_banco      = d_ctc00m02.bcocod    using '<&&&'
  let gr_034_fin_v1.agencia           = d_ctc00m02.bcoagnnum using '<<&&&'         
  let gr_034_fin_v1.digito_agencia    = d_ctc00m02.bcoagndig using '&'             
  let gr_034_fin_v1.conta             = d_ctc00m02.bcoctanum using '<<<<<<<<<&&&&&'
  let gr_034_fin_v1.digito_conta      = d_ctc00m02.bcoctadig using '<&'            

  #Requisitante                         
  let gr_034_req_v1.tipo_usuario      = g_issk.usrtip
  let gr_034_req_v1.emp_matricula     = g_issk.empcod
  let gr_034_req_v1.mat_responsavel   = g_issk.funmat
  
  
  #
  #Chama a API responsavel por cadastrar fornecedor no SAP
  if gr_034_cab_fcd_v1.tipo_pessoa = "PJ" then #Documento Pessoa Juridica            
     call ffpgc373_cadfrc_pj() 
     
     #Fornax-Quantum
     #Retorno da global header
     display "gr_aci_res_head.codigo_retorno ",gr_aci_res_head.codigo_retorno  # Codigo de retorno da integracao.            
     display "gr_aci_res_head.mensagem       ",gr_aci_res_head.mensagem        # Mensagem de retorno da integracao.          
     display "gr_aci_res_head.tipo_erro      ",gr_aci_res_head.tipo_erro       # Tipo de erro, caso ocorra.                  
     display "gr_aci_res_head.track_number   ",gr_aci_res_head.track_number    # Numero de rastreio para integr assincronas.
     
     if gr_aci_res_head.codigo_retorno <> 0 then 
        error "Erro na ffpgc373. ", "Msg: ", gr_aci_res_head.mensagem, " Tipo: ", gr_aci_res_head.tipo_erro
     end if 
     #Fornax-Quantum
  else
     if gr_034_cab_fcd_v1.tipo_pessoa = "PF" then #Documento Pessoa Fisica              
        call ffpgc373_cadfrc_pf()
        #Fornax-Quantum
        #Retorno da global header
        display "gr_aci_res_head.codigo_retorno ",gr_aci_res_head.codigo_retorno  # Codigo de retorno da integracao.            
        display "gr_aci_res_head.mensagem       ",gr_aci_res_head.mensagem        # Mensagem de retorno da integracao.          
        display "gr_aci_res_head.tipo_erro      ",gr_aci_res_head.tipo_erro       # Tipo de erro, caso ocorra.                  
        display "gr_aci_res_head.track_number   ",gr_aci_res_head.track_number    # Numero de rastreio para integr assincronas.
        
        if gr_aci_res_head.codigo_retorno <> 0 then 
           error "Erro na ffpgc373. ", "Msg: ", gr_aci_res_head.mensagem, " Tipo: ", gr_aci_res_head.tipo_erro
        end if 
        #Fornax-Quantum
     end if
  end if

end function

#Fornax-Quantum. Digito NIT - Inicio 
function ctc00m02_validanit(lr_param)
  
  define lr_param record
         numnit   char(30)
  end record
  
  define lr_num record
          nit1        integer
         ,nit2        integer 
         ,nit3        integer 
         ,nit4        integer 
         ,nit5        integer 
         ,nit6        integer 
         ,nit7        integer 
         ,nit8        integer 
         ,nit9        integer 
         ,nit10       integer 
  end record 
  
  define lr_somanit   integer
  define lr_dignit    integer
  define lr_divnit    integer 
  
  let lr_num.nit1    = 3 * lr_param.numnit[1]      
  let lr_num.nit2    = 2 * lr_param.numnit[2]      
  let lr_num.nit3    = 9 * lr_param.numnit[3]      
  let lr_num.nit4    = 8 * lr_param.numnit[4]      
  let lr_num.nit5    = 7 * lr_param.numnit[5]      
  let lr_num.nit6    = 6 * lr_param.numnit[6]      
  let lr_num.nit7    = 5 * lr_param.numnit[7]      
  let lr_num.nit8    = 4 * lr_param.numnit[8]      
  let lr_num.nit9    = 3 * lr_param.numnit[9]      
  let lr_num.nit10   = 2 * lr_param.numnit[10]     
                  
                  
  let lr_somanit  =  lr_num.nit1 +  lr_num.nit2 + 
                     lr_num.nit3 +  lr_num.nit4 + 
                     lr_num.nit5 +  lr_num.nit6 + 
                     lr_num.nit7 +  lr_num.nit8 +
                     lr_num.nit9 +  lr_num.nit10
  
  let lr_divnit  =  lr_somanit mod 11
  
  let lr_dignit  =  11 - lr_divnit

  if lr_dignit = 10 or lr_dignit = 11 then 
     let lr_dignit = 0 
  end if 
  
  return lr_dignit
      
end function 
#Fornax-Quantum. Digito NIT - Fim 
