################################################################################
#                     PORTO SEGURO CIA DE SEGUROS GERAIS                      #
#.............................................................................#
# Sistema        : ATENDIMENTO SEGURADO                                       #
# Modulo         : cta02m13                                                   #
#                  Verifica a regra para chamar laudo ou apenas registrar a   #
#                  ligacao                                                    #
# Analista Resp. : Ligia Mattge                                               #
# PSI            : 188425                                                     #
#.............................................................................#
# Desenvolvimento: Helio (Meta)                                               #
# Liberacao      :                                                            #
#.............................................................................#
#                     * * * A L T E R A C A O * * *                           #
#                                                                             #
# Data       Autor Fabrica        PSI    Alteracao                            #
# ---------- -------------------  ------ -------------------------------------#
# 03/11/2004 Helio (Meta)         188425 Adendo - Tratamento e retorno dos    #
#                                        metodos. A pedido da Ligia Mattge    #
#                                        todas as funcoes retornarao 1.       #
#                                                                             #
# 26/01/2005 Robson, Meta         190080 Retornar numero ligacao nas funcoes: #
#                                        cta02m13(),                          #
#                                        cta02m13_atendimento_sem_laudo() e   #
#                                        cta02m13_chama_laudos()              #
#-----------------------------------------------------------------------------#
#                                                                             #
#                         * * * Alteracoes * * *                              #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 20/12/2004  Marcio - Meta    PSI187887  Incluir novo parametro de retorno na#
#                                         chamada funcao cty05g00_dados_veic()#
#-----------------------------------------------------------------------------#
# 06/03/2006  Priscila         Zeladoria  Buscar data e hora do banco de dados#
#-----------------------------------------------------------------------------#
#   /09/2006  Priscila         PSI199850  Transfere ligacao RE para assunto   #
#                                         V46 e V48 e V00                     #
#-----------------------------------------------------------------------------#
# 14/11/2006  Ruiz             psi 205206 Ajustes p/ Atendimento Azul Seguros #
#-----------------------------------------------------------------------------#
# 08/03/2007  Ruiz             AS 132187  Controlar os avisos de furto/roubo  #
#                                         que ficaram pendente da geração do  #
#                                         sinistro.                           #
-------------------------------------------------------------------------------
# 18/05/2007  Ruiz             207.446    Laudo de Servico Assistencia Funeral#
#                                                                             #
#-----------------------------------------------------------------------------#
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a    #
#                                         global                              #
#-----------------------------------------------------------------------------#
# 20/11/2008 Amilton, Meta     Psi 230669 incluir relacionamento de ligacao   #
#                                         com atedimento                      #
#-----------------------------------------------------------------------------#
# 30/12/2008 Priscila                      Exibir mensagem de erro retornada  #
#                                          por ctd25g00                       #
#-----------------------------------------------------------------------------#
# 13/03/2009 Carla Rampazzo PSI 235580 -Incluir tratamento p/ novos assuntos  #
#                                       do Curso de Direcao Defensiva         #
#                                      -Acrescentar Parametro na chamada de   #
#                                       cts40g20_ret_codassu()                #
#                                       1-Direcao Defensiva (so c/apolice)    #
#                                       2-Demais Agendamentos                 #
#-----------------------------------------------------------------------------#
# 22/12/2009  ??????????   Patricia W.  Envio de Informacoes SINISTRO,        #
#                                       Integracao EJB / 4GL                  #
#-----------------------------------------------------------------------------#
# 13/05/2010 Carla Rampazzo PSI 219444 -Gravar Historico com Descricao do     #
#                                       Local de Risco ou Bloco               #
#-----------------------------------------------------------------------------#
# 11/10/2010 Carla Rampazzo PSI 260606  Tratar Fluxo de Reclamacao p/PSS (107)#
#-----------------------------------------------------------------------------#
# 03/11/2010 Carla Rampazzo PSI 000762  Tratamento para direcionar o fluxo    #
#                                       de assuntos do Help Desk Casa         #
#-----------------------------------------------------------------------------#
# 25/11/2010 Helder, Meta   SA__260142_1 Separar em blocos as opções de       #
#                                        FURTO/ROUBO e AVISO DE SINISTRO.     #
#                                        lr_cta02m1303.prgcod = 3 e 5         #
#                                        Funções criadas :                    #
#                                         > cta02m13_furto_roubo(...)         #
#                                         > cta02m13_aviso_sinistro(...)      #
#-----------------------------------------------------------------------------#
# 10/02/2011 Carla Rampazzo PSI         Fluxo de Reclamacao p/ PortoSeg(518)  #
#-----------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail   #
###############################################################################


globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc012.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl" --> 223689


  define m_cta02m13_prep smallint
        ,m_texto1        char(60)
        ,m_texto2        char(60)

  define m_flag          char(100)

define m_cidade      char(100)
define m_estado      char(100)
define m_flagbo      char(100)
define m_BO          char(100)
#-------------------------#
function cta02m13_prepare()
#-------------------------#

  define l_sql char(5000)

  let l_sql = "  select segnumdig     "
             ,"        ,dctnumseq     "
             ,"        ,clalclcod     "
             ,"   from abbmdoc        "
             ,"  where succod    = ?  "
             ,"    and aplnumdig = ?  "
             ,"    and itmnumdig = ?  "

  prepare p_cta02m13_001 from l_sql
  declare c_cta02m13_001 cursor for p_cta02m13_001

  let l_sql = "  select cgccpfnum      "
             ,"        ,cgcord         "
             ,"        ,cgccpfdig      "
             ,"        ,pestip         "
             ,"    from gsakseg        "
             ,"   where segnumdig  = ? "

  prepare p_cta02m13_002 from l_sql
  declare c_cta02m13_002 cursor for p_cta02m13_002

  let l_sql = "  select corsus       "
             ,"   from abamcor       "
             ,"  where succod    = ? "
             ,"    and aplnumdig = ? "
             ,"    and corlidflg = ? "

  prepare p_cta02m13_003 from l_sql
  declare c_cta02m13_003 cursor for p_cta02m13_003

  let l_sql = "  select c24astagp    "
             ,"   from datkassunto   "
             ,"  where c24astcod = ? "

  prepare p_cta02m13_004 from l_sql
  declare c_cta02m13_004 cursor for p_cta02m13_004

  let l_sql = "  select cpodes    "
             ,"   from datkdominio   "
             ,"  where cponom = ? "

  prepare pcta02m13007 from l_sql
  declare ccta02m13007 cursor for pcta02m13007

  let l_sql = ' insert into datrligrcuccsmtv    '
            , ' (lignum,rcuccsmtvcod,c24astcod) '
            , ' values (?,?,?) '
   prepare pcta02m13008 from l_sql


 let l_sql = "select lignum,     "
          , "       atdsrvano,  "
          , "       atdsrvnum,  "
          , "       ligdat   ,  "
          , "       lighorinc   "
          , "  from datmligacao "
          , "  where lignum = ?  "
 prepare p_cta02m13_010 from l_sql
 declare c_cta02m13_010 cursor for p_cta02m13_010


 let l_sql = "select count(*) "
          , "  from datkdominio "
          , "  where cponom = 'assunto_gcho_sin'"
          , "  and cpodes = ? "
 prepare p_cta02m13_011 from l_sql
 declare c_cta02m13_011 cursor for p_cta02m13_011



 let m_cta02m13_prep = true

end function

#------------------------------------------------------------------------------
function cta02m13(lr_cta01m1301)
#------------------------------------------------------------------------------

define lr_cta01m1301    record
   prgcod               like datkassunto.prgcod
  ,aplflg               char(01)
  ,docflg               char(01)
  ,c24astcod            like datrastfun.c24astcod
  ,c24atrflg            like datkassunto.c24atrflg
  ,c24jstflg            like datkassunto.c24jstflg
  ,funnom               like isskfunc.funnom
  ,funmat               like isskfunc.funmat
  ,data                 date
  ,hora                 datetime hour to  second
  ,succod               like datrligapol.succod
  ,aplnumdig            like abamapol.aplnumdig
  ,itmnumdig            like abbmdoc.itmnumdig
  ,vclsitatu            decimal(4,0)
  ,flgIS096             char(01)
  ,w_sinnull            smallint
  ,webrlzflg            like datkassunto.webrlzflg
end record

   define l_result        smallint
   define l_msg           char(80)
   define l_vcllicnum     like abbmveic.vcllicnum
   define l_vclchsfnl     like abbmveic.vclchsfnl
   define l_vclchsinc     like abbmveic.vclchsinc
   define l_vclanofbc     like abbmveic.vclanofbc
   define l_ret           smallint
   define l_vstagnnum     like svomvstagn.vstagnnum
   define l_lignum        like datmligacao.lignum
   define l_prgcod        like datkassunto.prgcod


   let l_result = 0
   let l_msg = ""
   let l_vcllicnum = ""
   let l_vclchsfnl = ""
   let l_vclchsinc = null
   let l_vclanofbc = null
   let l_lignum    = null
   let l_vstagnnum = null
   let l_prgcod    = null

   ---> Tratamento para Cortesia e Help Desk para direcionar o atendimento
   if lr_cta01m1301.c24astcod = "HDK" or
   	  lr_cta01m1301.c24astcod = "RDK" or
      lr_cta01m1301.c24astcod = "S68" or
      lr_cta01m1301.c24astcod = "R68" then
      let l_prgcod             = lr_cta01m1301.prgcod
      let lr_cta01m1301.prgcod = 0
   end if

   if lr_cta01m1301.prgcod = 0 then

      call cta02m13_atendimento_semlaudo(lr_cta01m1301.aplflg
                                        ,lr_cta01m1301.c24astcod
                                        ,lr_cta01m1301.c24atrflg
                                        ,lr_cta01m1301.c24jstflg
                                        ,lr_cta01m1301.funnom
                                        ,lr_cta01m1301.funmat
                                        ,lr_cta01m1301.data
                                        ,lr_cta01m1301.hora
                                        ,lr_cta01m1301.succod
                                        ,lr_cta01m1301.aplnumdig
                                        ,lr_cta01m1301.itmnumdig
                                        ,lr_cta01m1301.vclsitatu
                                        ,lr_cta01m1301.flgIS096)
      returning l_ret, l_lignum

      ---> HDK volta como S67 ou S68
      ---> S68 volta como S78 ou permanece S68
      if g_documento.c24astcod = "S66" or    ---> HDK Telefonico Porto
         g_documento.c24astcod = "S67" or    ---> HDK Presencial Porto
         g_documento.c24astcod = "S68" or    ---> HDK Cortesia Presencial Porto
         g_documento.c24astcod = "S78" or    ---> HDK Cortesia Telefonico Porto
         g_documento.c24astcod = "R66" or  	 ---> HDK Telefonico Itau         
         g_documento.c24astcod = "R67" or  	 ---> HDK Presencial Itau        
         g_documento.c24astcod = "R68" or  	 ---> HDK Cortesia Presencial Itau
         g_documento.c24astcod = "R78" then	 ---> HDK Cortesia Telefonico Itau
         	

         let lr_cta01m1301.c24astcod = g_documento.c24astcod
         let lr_cta01m1301.prgcod    = l_prgcod

         if lr_cta01m1301.c24astcod = "S67" or
            lr_cta01m1301.c24astcod = "S68" or 
            lr_cta01m1301.c24astcod = "R67" or    	
            lr_cta01m1301.c24astcod = "R68" then 	

            call cta02m13_chama_laudos(lr_cta01m1301.prgcod
                                      ,""
                                      ,lr_cta01m1301.aplflg
                                      ,lr_cta01m1301.docflg
                                      ,lr_cta01m1301.webrlzflg)
                             returning l_ret, l_lignum
         end if
      end if
   else
      call cta02m13_chama_laudos(lr_cta01m1301.prgcod
                                ,""
                                ,lr_cta01m1301.aplflg
                                ,lr_cta01m1301.docflg
                                ,lr_cta01m1301.webrlzflg)
      returning l_ret, l_lignum
   end if

   ## CT 4116164
   if  lr_cta01m1301.w_sinnull  then
       initialize g_documento.sinramcod,
                  g_documento.sinano   ,
                  g_documento.sinnum   ,
                  g_documento.sinitmseq to null
   end if

   return l_ret, l_lignum

end function #cta02m13

#------------------------------------------------------------------------------
function cta02m13_atendimento_semlaudo(lr_cta02m1302)
#------------------------------------------------------------------------------
#Para ssuntos que nao tem um laudo  relacionado, somente registra o historico
#da ligacao

define lr_cta02m1302    record
   aplflg               char(01)
  ,c24astcod            like datrastfun.c24astcod
  ,c24atrflg            like datkassunto.c24atrflg
  ,c24jstflg            like datkassunto.c24jstflg
  ,funnom               like isskfunc.funnom
  ,funmat               like isskfunc.funmat
  ,data                 date
  ,hora                 datetime hour to second
  ,succod               like datrligapol.succod
  ,aplnumdig            like abamapol.aplnumdig
  ,itmnumdig            like abbmdoc.itmnumdig
  ,vclsitatu            decimal(4,0)
  ,flgIS096             char(01)
end record

define l_lignum               like datmligacao.lignum

define l_confirma    char(01)
define l_ret         smallint
define l_tabname     like systables.tabname
define l_sqlcode     smallint

define  l_transfere like sremligsnc.sncinftxt    #PSI 199850
define  l_c24astagp like datkassunto.c24astagp

define l_historico     char(45)
define l_data          date
define l_hora          datetime hour to  second
define l_localdes      char(60)
define l_result        smallint
define l_msg           char(80)


   let l_msg       = null
   let l_result    = null
   let l_localdes  = null
   let l_historico = null
   let l_confirma  = ""
   let l_ret       = 0
   let l_tabname   = ""
   let l_sqlcode   = 0
   let l_lignum    = null
   let l_transfere = null     #PSI 199850

   if m_cta02m13_prep is null or
      m_cta02m13_prep <> true then
      call cta02m13_prepare()
   end if
   # Psi 230669 Inicio
   open c_cta02m13_004 using lr_cta02m1302.c24astcod
   fetch c_cta02m13_004 into l_c24astagp
   close c_cta02m13_004
   # Psi 230669 Fim

   #Para reclamacoes sem documento informado
   if lr_cta02m1302.aplflg    =  "N"   and
      l_c24astagp             =  "W"   and # Psi 230669
      lr_cta02m1302.c24astcod <> "W00" and
      lr_cta02m1302.c24astcod <> "107" and       #PSS
      lr_cta02m1302.c24astcod <> "518" and       #PortoSeg
      lr_cta02m1302.c24astcod <> "I99" and       #Itau
      lr_cta02m1302.c24astcod <> "P24" and
      lr_cta02m1302.c24astcod <> "K00" then      #PSI 205206

      error "Reclamacao deve estar vinculada a uma apolice"
      sleep 1
      let l_ret = 1
      return l_ret, l_lignum
   end if

   #Gravar ligacao

   call cta02m00_grava(lr_cta02m1302.c24atrflg
                      ,lr_cta02m1302.c24jstflg
                      ,lr_cta02m1302.funnom)
    returning l_confirma,l_lignum


   if l_confirma = false then
      let l_ret = 1
      return l_ret, l_lignum
   end if

   #PSI 199850 -  - sincronizar ligação com sistema RE apenas para assunto V46
   # e V48 sincronismo de ligacoes com RE
   if lr_cta02m1302.c24astcod = "V46" or
      lr_cta02m1302.c24astcod = "V48" or
      lr_cta02m1302.c24astcod = "V00" then
      #montar chave para transferir ligacao
      let l_transfere = "SINRE",                    #chave para RE
                    ";",lr_cta02m1302.c24astcod,    #assunto para V46 ou V48
                    ";",                            #ano vistoria (V46 nao tem)
                    ";",                            #num vistoria (V46 nao tem)
                    ";",g_documento.succod,         #sucursal
                    ";",g_documento.ramcod,         #ramo
                    ";",g_documento.aplnumdig,      #apolice
                    ";",g_documento.c24soltipcod,   #tipo solicitante
                    ";",g_documento.solnom,         #nome solicitante
                    ";"

      begin work
      if cts39g00_transfere_ligacao(g_c24paxnum,               #PA do atendente
                                    l_transfere) then          #chave para transferencia
         #atualizou tabela do sincronismo para transferencia da ligação
         commit work
      else
         rollback work
      end if
   end if

   #Assuntos do grupo Localizacao
   if lr_cta02m1302.c24astcod = "L10" or
      lr_cta02m1302.c24astcod = "L11" or
      lr_cta02m1302.c24astcod = "L12" or
      lr_cta02m1302.c24astcod = "L45" then
      let l_ret = cta02m13_trata_localizacao(lr_cta02m1302.c24astcod
                                            ,l_lignum
                                            ,lr_cta02m1302.funmat
                                            ,lr_cta02m1302.data
                                            ,lr_cta02m1302.hora
                                            ,lr_cta02m1302.succod
                                            ,lr_cta02m1302.aplnumdig
                                            ,lr_cta02m1302.itmnumdig
                                            ,lr_cta02m1302.vclsitatu
                                            ,lr_cta02m1302.aplflg )
      if l_ret = 3 then
         let l_ret = 1
         return l_ret, l_lignum
      end if
   end if

   #Trata agendamento de vistoria sinistro
   if l_c24astagp = "C" or   # Psi 230669 Inicio
      l_c24astagp = "D" then # Psi 230669 Inicio

      ---> Curso de Direcao Defensiva so agenda com Apolice (com Laudo)
      if lr_cta02m1302.c24astcod <> "D00" and  --> Agendar
         lr_cta02m1302.c24astcod <> "D10" and  --> Consultar
         lr_cta02m1302.c24astcod <> "D11" and  --> Alterar
         lr_cta02m1302.c24astcod <> "D12" and  --> Cancelar
         lr_cta02m1302.c24astcod <> "DPV" and   # Pedido por Cristiane Marcondes 08/07/2010
         lr_cta02m1302.c24astcod <> "C01" and   # Pedido por Cristiane Marcondes 08/02/2011
         lr_cta02m1302.c24astcod <> "CDN" then  # Pedido por Cristiane Marcondes 08/02/2011

         ## PSI 208892
         call cts46g00(l_lignum, lr_cta02m1302.funmat, lr_cta02m1302.data,
                       lr_cta02m1302.hora,lr_cta02m1302.c24astcod,
                       g_documento.rcuccsmtvcod, g_issk.usrtip, g_issk.empcod,
                       g_documento.succod, g_documento.aplnumdig,
                       g_documento.itmnumdig, g_documento.ramcod,
                       g_documento.edsnumref)


         call cta02m00_agenda(lr_cta02m1302.c24astcod)
                 returning lr_cta02m1302.data, lr_cta02m1302.hora
      end if
   end if

   #Grava historico da clscod 096 na ligacao
   if lr_cta02m1302.flgIS096 is not null then
      #Trata clausula 096
      call cta02m13_trata_cls096(lr_cta02m1302.flgIS096
                                ,l_lignum
                                ,lr_cta02m1302.funmat)
           returning l_tabname, l_sqlcode
      if l_sqlcode <> 0 then
         error l_tabname
         sleep 1
         let l_ret = 1
         return l_ret, l_lignum
      end if
   end if

   error "Registre as informacoes no historico"
   sleep 1

   call cts40g03_data_hora_banco(1)
        returning l_data, l_hora

   #Chame Menu de Historico da Ligacao
   let g_documento.acao = "INC"

   call cta03n00(l_lignum
                ,lr_cta02m1302.funmat
                ,lr_cta02m1302.data
                ,lr_cta02m1302.hora)


   #Verifica se o Assunto e a Matricula tem acesso a replicacao de atendimentos de Advertencia

   if cta02m13_acesso_replicacao(lr_cta02m1302.succod     ,
                                 lr_cta02m1302.aplnumdig  ,
                                 lr_cta02m1302.c24astcod  ,
                                 lr_cta02m1302.funmat     ) then

        # Replica a Ligacao para os Itens do Itau

        if g_documento.ciaempcod = 84 then

           call cta00m30(g_documento.itaciacod   ,
                         g_doc_itau[1].itaramcod ,
                         lr_cta02m1302.aplnumdig ,
                         g_doc_itau[1].aplseqnum ,
                         lr_cta02m1302.succod    ,
                         lr_cta02m1302.funmat    ,
                         lr_cta02m1302.data      ,
                         lr_cta02m1302.hora      ,
                         lr_cta02m1302.c24atrflg ,
                         lr_cta02m1302.c24jstflg ,
                         lr_cta02m1302.funnom    ,
                         l_lignum                )


        else

        # Replica a Ligacao para os Outros Itens

        call cta00m21(lr_cta02m1302.succod    ,
                      lr_cta02m1302.aplnumdig ,
                      lr_cta02m1302.funmat    ,
                      lr_cta02m1302.data      ,
                      lr_cta02m1302.hora      ,
                      lr_cta02m1302.c24atrflg ,
                      lr_cta02m1302.c24jstflg ,
                      lr_cta02m1302.funnom    ,
                      l_lignum                )
        end if

   end if


   let l_ret =  1
   return l_ret, l_lignum

end function #cta02m13_atendimento_semlaudo

#------------------------------------------------------------------------------
function cta02m13_chama_laudos(lr_cta02m1303)
#------------------------------------------------------------------------------
#Funcao unica que chama os laudos dos servicos oferecidos pela Central 24h.
#Para o Atendimento ao Segurado, chama o laudo atraves do codigo de programa
#(prgcod), parametrizado no cadastro de assuntos.
#Para o acionamento do servico, chama o laudo atraves da origem(atdsrvorg)
#do servico

define lr_cta02m1303   record
   prgcod              like datkassunto.prgcod
  ,atdsrvorg           like datmservico.atdsrvorg
  ,aplflg              char(01)
  ,docflg              char(01)
  ,webrlzflg           like datkassunto.webrlzflg
end record

define l_null          char(01)
define l_ret           smallint

 ## CT 303208
 ## alberto
 define l_cmd char(500)

 define l_mens record
          msg char(200)
         ,de char(50)
         ,subject char(100)
         ,para char(100)
         ,cc char(100)
       end record

 define l_today date
 define l_hora datetime hour to second

 define l_ant_aplnumdig like abamapol.aplnumdig

  define lr_numeracao record
         lignum       like datmligacao.lignum,
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano,
         sqlcode      integer,
         msg          char(80)
  end record

  define l_sttweb       like datmagnwebsrv.sttweb,
         l_status       smallint,
         l_ligorgcod    like datmagnwebsrv.ligorgcod,
         l_abnwebflg    like datmagnwebsrv.abnwebflg,
         l_ligasscod    like datmagnwebsrv.ligasscod,
         l_vstagnnum    like datmagnwebsrv.vstagnnum,
         l_vstagnstt    like datmagnwebsrv.vstagnstt,
         l_orgvstagnnum like datmagnwebsrv.orgvstagnnum,
         l_data_lig     date,
         l_c24astcod    like datmligacao.c24astcod,
         l_atencao      char(01),
         l_hora_lig     datetime hour to minute,
         l_horas_lig    datetime hour to second,
         l_tabname      char(30),
         l_sqlcode      integer,
         l_cornom       like gcakcorr.cornom,
         l_corsus       like gcaksusep.corsus,
         l_vcllicnum    like datmsinatditf.vcllicnum,
         l_vclchsinc    like datmsinatditf.vclchsinc,
         l_vclchsfnl    like datmsinatditf.vclchsfnl,
         l_corlidflg    like abamcor.corlidflg,
         l_ambiente     char(08)

  ## Alberto

  define ret_param_msg char(50)

  define l_ctq00m01_ret   record
         err         smallint,
         msg         char(80),
         lignum      like datmligacao.lignum,
         atdsrvnum   like datmservico.atdsrvnum,
         atdsrvano   like datmservico.atdsrvano
  end record

  define lr_retorno  record
         sttatendi   char(01)
        ,matranali   like datmligacao.c24funmat
        ,nomeanali   like isskfunc.funnom
        ,foneanali   like datmligacao.c24paxnum
        ,msg         char(32766)
        ,param       char(2000)
        ,coderro     dec(1,0)
        ,msgerro     char(1000)
  end record
  define l_hist      record
         tipgrv      smallint,
         lignum      like datmlighist.lignum,
         c24funmat   like datmlighist.c24funmat,
         ligdat      like datmlighist.ligdat,
         lighorinc   like datmlighist.lighorinc,
         c24ligdsc   like datmlighist.c24ligdsc
  end record
  define l_retorno   record
         tabname     like systables.tabname,
         sqlcode     integer
  end record
  define l_ok        smallint
  define l_matratend like datmligacao.c24funmat
  define l_funnomatd like isskfunc.funnom
  define l_motrecusa smallint
  define l_funmat    like datmligacao.c24funmat
  define l_sinatdsit char(01)
  define l_trfhor    interval hour to second
  define l_cpodes    like iddkdominio.cpodes
  define l_remetente char(50)
  define l_assunto   char(50)
  define l_para      char(1000)
  define l_comando   char(32766)
  define l_maquina   char(10)
  define l_maqsgl    char(10)
  define l_u11       char(1)
  define l_alt_assunto smallint
  define r_c24astcod   like datkassunto.c24astcod
  define l_ciaempcod_slv like datmligacao.ciaempcod

  define l_liberadoN10 char(01) # verificar se liberado todo atendente na WEB - N10/N11 = "S"
                                # 20/01/2009
  initialize l_ctq00m01_ret
            ,lr_retorno
            ,l_retorno
            ,l_hist  to null

  let l_liberadoN10 = "N"

  let ret_param_msg = "000"
  let l_matratend   = null
  let l_funnomatd   = null
  let l_motrecusa   = null
  let l_funmat      = null
  let l_sinatdsit   = null
  let l_trfhor      = null
  let l_remetente   = null
  let l_para        = null
  let l_assunto     = null
  let l_status      = null
  let l_comando     = null
  let l_ambiente    = null
  let l_u11         = null
  let l_alt_assunto = false
  let r_c24astcod   = null



 ## Alberto

  let l_cmd          = null
  let l_today        = null
  let l_hora         = null
  let l_sttweb       = null
  let l_atencao      = null
  let l_status       = null
  let l_ligorgcod    = null
  let l_abnwebflg    = null
  let l_ligasscod    = null
  let l_vstagnnum    = null
  let l_vstagnstt    = null
  let l_orgvstagnnum = null
  let l_c24astcod    = null
  let l_null         = null
  let l_data_lig     = null
  let l_hora_lig     = null
  let l_horas_lig    = null
  let l_tabname      = null
  let l_sqlcode      = null
  let l_ret          = 1
  let l_cornom       = null
  let l_corsus       = null
  let l_vcllicnum    = null
  let l_vclchsinc    = null
  let l_vclchsfnl    = null
  let l_corlidflg    = "S"
  let l_cpodes       = null
  let l_maquina      = null
  let l_maquina      = null
  let l_maqsgl       = null

  initialize lr_numeracao to null

   #--------------------------------------------------------------------
   #Laudo - Remocoes
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 1    or
      lr_cta02m1303.atdsrvorg = 4 then
      call cts02m00()
   end if


   #--------------------------------------------------------------------
   #Laudo - D.A.F./ Porto Socorro
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 2    or
      lr_cta02m1303.atdsrvorg = 1 then
      let l_ciaempcod_slv = g_documento.ciaempcod
      call cts03m00()
      let g_documento.ciaempcod = l_ciaempcod_slv
   end if


  #--------------------------------------------------------------------
   #Aviso de Sinstro ROUBO/FURTO Total
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 3     or
      lr_cta02m1303.atdsrvorg = 11 then

      call cta02m13_furto_roubo(lr_cta02m1303.*)  #SA__260142_1

   end if

   #--------------------------------------------------------------------
   #Laudo - Aviso de Sinistro / Laudo Aviso de Sinstro N10/N11 PSI 206.938
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 5 then

      call cta02m13_aviso_sinistro(lr_cta02m1303.*) #SA__260142_1

   end if


   #--------------------------------------------------------------------
   #Inclusao da placa do veiculo na apolice
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 6 then
      if lr_cta02m1303.aplflg = "N" then
         error "Inclusao de placa deve estar vinculada a uma apolice"
         sleep 1
      else
         call cts07m00()
      end if
   end if


   #--------------------------------------------------------------------
   #Pedido de 2a via decartao de protecao total
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 7 then
      if lr_cta02m1303.aplflg = "N" then
         error "Solicitacao de cartao deve estar vinculada a uma apolice"
         sleep 1
      else
         call cts08m00()
      end if
   end if


   #--------------------------------------------------------------------
   #Laudo - Remocao de Perda Total
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 8    or
      lr_cta02m1303.atdsrvorg = 5 then
      call cts12m00()
   end if


   #--------------------------------------------------------------------
   #Laudo - Replace
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 9    or
      lr_cta02m1303.atdsrvorg = 7 then
      call cts09m00()
   end if


   #--------------------------------------------------------------------
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 10 then
      if lr_cta02m1303.docflg = "N" then
         error "Marcacao de vistoria de sinistro deve estar vinculada"
              ,"a um documento"
      else
         call cts14m00()
      end if
   end if


   #--------------------------------------------------------------------
   #Laudo - Reserva de locacao de veiculos
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 11    or
      lr_cta02m1303.atdsrvorg = 8 then
      call cts15m00()
   end if


   #--------------------------------------------------------------------
   #Marcacao de Vistoria - Ramos Elementares
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 12 then
      call cts21m00()
   end if

   #--------------------------------------------------------------------
   #Laudo para assistencia a passageiros - transporte
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 13   or
      lr_cta02m1303.atdsrvorg = 2 then
      call cts11m00()
   end if


   #--------------------------------------------------------------------
   #Solicitacao de reparos para danos nos vidros do veiculo B14
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 14    or
      lr_cta02m1303.atdsrvorg = 14 then
      call cts19m06()
   end if


   #--------------------------------------------------------------------
   #Laudo - Servico Emergencial a Residencia
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 15   or
      lr_cta02m1303.atdsrvorg = 9 then
      let l_ciaempcod_slv = g_documento.ciaempcod
      call cts17m00()
      let g_documento.ciaempcod = l_ciaempcod_slv
   end if


   #--------------------------------------------------------------------
   #Laudo - Sinistro Ramos Elementares
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 16    or
      lr_cta02m1303.atdsrvorg = 13 then
      call cts04m00()
   end if


   #--------------------------------------------------------------------
   #Laudo para assistencia a passageiros - hospedagem
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 17   or
      lr_cta02m1303.atdsrvorg = 3 then
      call cts22m00()
   end if


   #--------------------------------------------------------------------
   #Pesquisa Receptiva (Clausula 18)
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 18 then
      if lr_cta02m1303.aplflg = "N" then
         error "Pesquisa receptiva deve estar vinculada a uma apolice!"
      else
         call ctx06g00("4GC","oaeia035")
      end if
   end if


   #--------------------------------------------------------------------
   #Exibe dados de sinistros do atendimento a perda parcial
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 19 then
      # psi 211753-U10
      if lr_cta02m1303.webrlzflg = "S"      then
         call cts40g03_data_hora_banco(2)
              returning l_data_lig, l_hora_lig
         let l_ok     = 1
         let l_sttweb = "A"

         call cta02m13_grava_transicao
             (g_issk.empcod           , # atlemp       Empresa Atendente
              g_issk.funmat           , # atlmat       Matricula Atendente
              "F"                     , # atlusrtip    Tipo Usuario
              g_documento.c24astcod   , # c24astcod    codigo do Assunto
              ""                      , # sinntzdes    Descrigco da natureza
              ""                      , # sinntzcod    Csdigo natureza
              g_documento.solnom      , # sinifrnom    Nome do informante
              g_documento.c24soltipcod, # c24soltipcod Tipo de informante
              l_data_lig              , # ligdat       Data da ligagco
              l_hora_lig              , # lighor       Hora da ligagco
              g_issk.empcod           , # empcod       empresa
              g_documento.succod      , # succod       Sucursal
              g_documento.ramcod      , # ramcod       Ramo
              g_documento.aplnumdig   , # aplnumdig    Apolice
              g_documento.itmnumdig   , # itmnumdig    Item
              g_documento.ligcvntip   , # ligcvntip    Codigo convenio
              g_c24paxnum             , # c24paxnum    Numero da PA
              ""                      , # lignum       Numero atendimento
              "A"                     , # sinatdsit    Status do atendimento
              ""                      , # placa para atd. sem docto
              ""                      , # chassi inicial p/ atd. sem docto
              ""                      , # chassi final   p/ atd. sem docto
              ""                      , # origem da proposta
              ""                      , # numero da proposta
              ""                      , # dddcod p/ ligacao s/docto
              ""                      , # telefone p/ ligacao s/docto
              ""                      , # empcod
              ""                      , # matricula p/ ligacao s/docto
              ""                      , # usrtip
              ""                      , # cgc e cpf p/ ligacao s/docto
              ""                      , # ordem cgc p/ligacao s/docto
              ""                      , # digito cgc cpf p/ligacao s/docto
              ""                      , # susep p/ ligacao s/ docto
              ""                      , # motivo recusa
              ""                      ) # intervalo de horas

         returning l_ok
         if not l_ok then
            return l_ok, 0
         end if

         # ---> ATENDIMENTO SENDO REALIZADO VIA WEB

         while l_sttweb = "A"
            # ---> EXIBE A MENSAGEM PARA O USUARIO

            initialize m_texto1, m_texto2 to null
            let m_texto1 = "PRESSIONE ALT+TAB PARA CONSULTAR"
            let m_texto2 = "PROCESSO DE SINISTRO NA WEB... "

            ---> Abre tela de Aviso com Atalho F1-Funcoes
            call cta02m13_men()


            # ---> BUSCA O STATUS DE RETORNO DA WEB
            call cta02m13_pesq_transicao( g_issk.empcod ,
                                          g_issk.funmat ,
                                          g_documento.c24astcod)
                 returning l_sttweb, l_ctq00m01_ret.lignum

            # PSI 243655 U10-Motivo   Inicio
            # Implementacao que devera ser removida apos aceite do cliente( Evitar voltar versão)
            if g_documento.c24astcod = "U10" then
               whenever error continue
               let l_cpodes = "N"
               select cpodes into l_cpodes
                 from iddkdominio
                where cponom = "liberaU10"
               whenever error stop
               if sqlca.sqlcode = 100 then
                  let l_cpodes  = "N"
               end if
               # Implementacao que devera ser removida apos aceite do cliente( Evitar voltar versão)
               if l_cpodes = "S" or
                  l_cpodes = "s" then
                  if l_sttweb = "F" then
                     # Criado este laço para não deixar sair sem selecionar o Motivo, após ter
                     # finalizado o processo na WEB

                      call cts08g01_reclamacao ("A","S", "",
                        "SINISTRO E PERDA PARCIAL ?",
                        "",
                        "")
                       returning l_u11

                     while true
                           let g_documento.rcuccsmtvcod = null
                           if l_u11 = 'N' then
                              let l_alt_assunto = true
                              let g_documento.c24astcod = "U00"
                           end if
                           call ctc26m01() returning g_documento.rcuccsmtvcod
                           if g_documento.rcuccsmtvcod = 0    then
                              error 'Assunto nao tem motivos cadastrados !' sleep 2
                              let l_sttweb = "A"
                              let g_documento.rcuccsmtvcod = null
                              continue while
                           end if
                           if g_documento.rcuccsmtvcod is null then
                              error ' O motivo deve ser informado !' sleep 2
                              let l_sttweb = "A"
                              continue while
                           else
                              let l_sttweb = "F"
                              if l_alt_assunto = true then
                                 let g_documento.c24astcod = "U10"
                              end if
                              exit while
                           end if
                     end while
                  end if
               end if
            end if
            # PSI 243655 U10-Motivo   Fim
         end while
         if l_sttweb = "F" then
            # ---> ASSUNTO FINALIZADO NA WEB
            # --> BUSCA A DATA E HORA DO BANCO

            call cts40g03_data_hora_banco(2)
                 returning l_data_lig, l_hora_lig

            if g_documento.acao is null then
               let g_documento.acao = "INC"
            end if
            ## ATUALIZA HORA FINAL DA LIGACAO

            whenever error continue
            begin work
               update  datmligacao
               set     lighorfnl = l_hora_lig
               where   lignum    = l_ctq00m01_ret.lignum
            whenever error stop
            if sqlca.sqlcode = 0 then
               if cta02m13_remove_transicao(g_issk.empcod,
                                            g_issk.funmat,
                                            l_assunto) then
                  commit work
               else
                  rollback work
               end if
            else
               rollback work
            end if

            # PSI 243655 U10-Motivo
            if l_ctq00m01_ret.lignum is not null    and
               g_documento.rcuccsmtvcod is not null and
               g_documento.c24astcod = "U10"        then

               if l_alt_assunto = true then
                   let r_c24astcod = "U00"
               else
                   let r_c24astcod = g_documento.c24astcod
               end if

               whenever error continue
               begin work
               insert into datrligrcuccsmtv (lignum,
                                             rcuccsmtvcod,
                                             c24astcod)
                                     values (l_ctq00m01_ret.lignum,
                                             g_documento.rcuccsmtvcod,
                                             r_c24astcod)
               whenever error stop

               if sqlca.sqlcode = 0 then
                  commit work
               else
                  rollback work
               end if
            end if
            # PSI 243655 U10-Motivo
         end if
      else
         # psi 211753-U10
         call cta06m00()
      end if
   end if


   #--------------------------------------------------------------------
   #Laudo - JIT
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 20    or
      lr_cta02m1303.atdsrvorg = 15 then
      call cts26m00()
   end if


   #--------------------------------------------------------------------
   #Pedido de 2a. via de cartao de protecao total
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 21 then
      if lr_cta02m1303.aplflg = "N" then
         error "Solicitacao de 2a VIA deve estar vinculada a uma apolice"
      else
         call cts08m00()
      end if
   end if


   #--------------------------------------------------------------------
   #Consulta criterios de servicos gratuitos
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 22 then
      if lr_cta02m1303.aplflg = "N" then
         error "Servicos Gratuitos, deve estar vinculada a uma apolice"
      else
         call cta08m00()
      end if
   end if


   #--------------------------------------------------------------------
   #Laudo de Averbacao de transportes no Ct24hs
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 23 then
      if lr_cta02m1303.aplflg = "N" then
         error "Averbacao de Transportes, deve estar vinculada a uma apolice"
      else
         call cts27m00(l_null,'cta02m00')
      end if
   end if


   #--------------------------------------------------------------------
   #Laudo - Sinsitro de Transportes
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 24    or
      lr_cta02m1303.atdsrvorg = 16 then
      call cts28m00()
   end if


   #--------------------------------------------------------------------
   #Marcacao de Vistoria Previa Domiciliar
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 25    or
      lr_cta02m1303.atdsrvorg = 10 then
      call cts06m00("N",l_null,l_null,l_null)
   end if


   #--------------------------------------------------------------------
   # 196541 - Agendamento de Servicos em Postos Porto seguro.
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod    = 26 and
      lr_cta02m1303.webrlzflg = "S" then
      call cts10g03_numeracao(1, "")
           returning lr_numeracao.lignum,
                     lr_numeracao.atdsrvnum,
                     lr_numeracao.atdsrvano,
                     lr_numeracao.sqlcode,
                     lr_numeracao.msg

      # --> BUSCA A DATA E HORA DO BANCO
      call cts40g03_data_hora_banco(2)
           returning l_data_lig, l_hora_lig
      call cts10g00_ligacao(lr_numeracao.lignum,
                            l_data_lig,
                            l_hora_lig,
                            g_documento.c24soltipcod,
                            g_documento.solnom,
                            g_documento.c24astcod,
                            g_issk.funmat,
                            g_documento.ligcvntip,
                            g_c24paxnum,
                            lr_numeracao.atdsrvnum,
                            lr_numeracao.atdsrvano,
                            "",       # --> SINVSTNUM
                            "",       # --> SINVSTANO
                            "",       # --> SINAVSNUM
                            "",       # --> SINAVSANO
                            g_documento.succod,
                            g_documento.ramcod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            g_documento.edsnumref,
                            g_documento.prporg,
                            g_documento.prpnumdig,
                            g_documento.fcapacorg,
                            g_documento.fcapacnum,
                            "",       # --> SINRAMCOD
                            "",       # --> SINANO
                            "",       # --> SINNUM
                            "",       # --> SINITMSEQ
                            "",       # --> CADDAT
                            "",       # --> CADHOR
                            "",       # --> EMPCOD
                            "")       # --> FUNMAT

           returning l_tabname, l_sqlcode

      call cts40g20_pesq_web(g_issk.empcod, g_issk.funmat)
           returning l_status,
                     l_sttweb,
                     l_abnwebflg,
                     l_ligasscod,
                     l_vstagnnum,
                     l_vstagnstt,
                     l_orgvstagnnum
      if l_status = 0 then # ---> ENCONTROU REGISTRO
         # ---> APAGA O REGISTRO DA WEB
         call cts40g20_apaga_web(g_issk.empcod, g_issk.funmat)
      end if
      ### BUSCA CORSUS
      if m_cta02m13_prep is null or
         m_cta02m13_prep <> true then
         call cta02m13_prepare()
      end if

      if g_documento.corsus is not null then
         let l_corsus = g_documento.corsus
      else
         open c_cta02m13_003 using g_documento.succod
                                ,g_documento.aplnumdig
                                ,l_corlidflg
         whenever error continue
         fetch c_cta02m13_003 into l_corsus
         whenever error stop
         if sqlca.sqlcode <> 0 and
            sqlca.sqlcode <> notfound then
            let l_corsus = null
         end if
      end if
      if l_corsus is not null then
         select a.cornom
              into l_cornom
              from gcakcorr a, gcaksusep b
             where b.corsus    = l_corsus
               and a.corsuspcp = b.corsuspcp
      end if
      let l_ligorgcod = 1 # origem do atd = 1 Porto
      if g_documento.corsus is not null then
         select a.cornom
              into l_cornom
              from gcakcorr a, gcaksusep b
             where b.corsus    = g_documento.corsus
               and a.corsuspcp = b.corsuspcp
      end if
      call cts40g20_insere_web(g_issk.empcod,
                               g_issk.funmat,
                               g_documento.succod,
                               g_documento.ramcod,
                               g_documento.aplnumdig,
                               g_documento.itmnumdig,
                               g_documento.prporg,
                               g_documento.prpnumdig,
                               g_documento.solnom,
                               g_documento.c24soltipcod,
                               l_corsus, ## g_documento.corsus, #---> lig.s/doc por corsus
                               "",  # --> NUMERO AGENDAMENTO
                               lr_numeracao.lignum,
                               "",  # --> CORLIGNUM
                               "",  # --> CORLIGANO
                               "A", # --> SITUACAO ATENDIMENTO
                               "",  # --> TIPO OPERACAO
                               l_ligorgcod,   # --> ATENDIMENTO PORTO
                               "",  # --> (S)ABANDONO (N)CONCLUIU
                               "",  # --> EMPCOD
                               "",  # --> FUNMAT
                               "",  # --> FUNNOM
                               l_cornom,   # --> lig.s/doc por corsus
                               "",  # --> STATUS AGENDAMENTO
                               "S", # --> CORASSHSTFLG
                               "",  # --> NUMERO AGEND.(ORIGINAL)
                               g_documento.atdnum )  # --> NUMERO de Atendimento Psi 230669

                 # Psi 230669 inicio
                 call ctd25g00_insere_atendimento(g_documento.atdnum,lr_numeracao.lignum)
                 returning l_retorno.sqlcode,l_retorno.tabname
                 # Psi 230669 Fim
                 #Priscila 30/12/08
                 if l_retorno.sqlcode <> 0 then
                   error l_retorno.tabname sleep 3
                end if

      let l_sttweb = "A"

      # ---> ATENDIMENTO SENDO REALIZADO VIA WEB
      while l_sttweb = "A"

         # ---> EXIBE A MENSAGEM PARA O USUARIO

         initialize m_texto1, m_texto2 to null
         let m_texto1 = "PRESSIONE ALT+TAB PARA CONTINUAR"
         let m_texto2 = "O AGENDAMENTO NA WEB... "

         ---> Abre tela de Aviso com Atalho F1-Funcoes
         call cta02m13_men()


         # ---> BUSCA O STATUS DE RETORNO DA WEB
         call cts40g20_pesq_web(g_issk.empcod, g_issk.funmat)
              returning l_status,
                        l_sttweb,
                        l_abnwebflg,
                        l_ligasscod,
                        l_vstagnnum,
                        l_vstagnstt,
                        l_orgvstagnnum
      end while

      if l_sttweb = "F" then  # ---> ASSUNTO FINALIZADO NA WEB
         if l_abnwebflg = "S" then
            # a ligacao foi abandonada
         else
            # ---> BUSCA O CODIGO DO ASSUNTO
            let l_c24astcod = cts40g20_ret_codassu("S", # --> ATD. SEGURADO
                                                 # g_issk.dptsgl,
                                                   l_ligorgcod,
                                                   l_ligasscod,
                                                   2)-->Demais Agendamentos

            # ---> ATUALIZA O ASSUNTO NA TABELA DATMLIGACAO
            call cts40g20_atlz_asslig(l_c24astcod, lr_numeracao.lignum)
            # ---> GRAVA O AGENDAMENTO
            let l_status = cts40g20_grava_agend("S",  # --> "S" = ATD. SEGURADO
                                                l_orgvstagnnum,
                                                "",   # --> CORLIGNUM
                                                "",   # --> CORLIGITMSEQ
                                                l_vstagnnum,
                                                l_vstagnstt,
                                                "",   # --> CORLIGANO
                                                lr_numeracao.lignum)
         end if
         # ---> APAGA O REGISTRO DA WEB
         call cts40g20_apaga_web(g_issk.empcod, g_issk.funmat)
      end if
   end if

   #--------------------------------------------------------------------
   #Laudo - ENVIO DE SOCORRO (AZUL)
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 27   or
      lr_cta02m1303.atdsrvorg = 1 or
      lr_cta02m1303.atdsrvorg = 4 then

      call cts02m07(g_documento.atdsrvnum,
                    g_documento.atdsrvano,
                    g_documento.ligcvntip,
                    g_documento.succod,
                    g_documento.ramcod,
                    g_documento.aplnumdig,
                    g_documento.itmnumdig,
                    g_documento.acao,
                    g_documento.prporg,
                    g_documento.prpnumdig,
                    g_documento.c24astcod,
                    g_documento.solnom,
                    g_documento.atdsrvorg,
                    g_documento.edsnumref,
                    g_documento.fcapacorg,
                    g_documento.fcapacnum,
                    g_documento.lignum,
                    g_documento.soltip,
                    g_documento.c24soltipcod,
                    g_documento.lclocodesres)
   end if


   #--------------------------------------------------------------------
   #Laudo - Reserva de locacao de veiculos(AZUL)
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 28    or
      lr_cta02m1303.atdsrvorg = 8 then
      if lr_cta02m1303.aplflg = "N" then
         error "Laudo de Carro-Extra deve estar vinculado a uma apolice"
         sleep 1
      else
         # -> LAUDO - RESERVA DE LOCACAO DE VEICULOS (ASSUNTO KA1)
         call cts15m15(g_documento.atdsrvnum,
                       g_documento.atdsrvano,
                       g_documento.ligcvntip,
                       g_documento.succod,
                       g_documento.ramcod,
                       g_documento.aplnumdig,
                       g_documento.itmnumdig,
                       g_documento.acao,
                       g_documento.prporg,
                       g_documento.prpnumdig,
                       g_documento.c24astcod,
                       g_documento.solnom,
                       g_documento.atdsrvorg,
                       g_documento.edsnumref,
                       g_documento.fcapacorg,
                       g_documento.fcapacnum,
                       g_documento.lignum,
                       g_documento.soltip,
                       g_documento.c24soltipcod,
                       g_documento.lclocodesres)
      end if
   end if


   #--------------------------------------------------------------------
   #Laudo para assistencia a passageiros - transporte(AZUL)
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 29   or
      lr_cta02m1303.atdsrvorg = 2 then
      call cts11m10(g_documento.succod,
                    g_documento.ramcod,
                    g_documento.aplnumdig,
                    g_documento.itmnumdig,
                    g_documento.edsnumref,
                    g_documento.prporg,
                    g_documento.prpnumdig,
                    g_documento.ligcvntip)
   end if


   #--------------------------------------------------------------------
   #Laudo para assistencia a passageiros - hospedagem(AZUL)
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 30   or
      lr_cta02m1303.atdsrvorg = 3 then
      call cts22m02(g_documento.atdsrvnum,
                    g_documento.atdsrvano,
                    g_documento.ligcvntip,
                    g_documento.succod,
                    g_documento.ramcod,
                    g_documento.aplnumdig,
                    g_documento.itmnumdig,
                    g_documento.acao,
                    g_documento.prporg,
                    g_documento.prpnumdig,
                    g_documento.c24astcod,
                    g_documento.solnom,
                    g_documento.atdsrvorg,
                    g_documento.edsnumref,
                    g_documento.fcapacorg,
                    g_documento.fcapacnum,
                    g_documento.lignum,
                    g_documento.soltip,
                    g_documento.c24soltipcod,
                    g_documento.lclocodesres)
   end if


   #--------------------------------------------------------------------
   #Laudo - SAF - Assistencia Funeral
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod    = 31 or
      lr_cta02m1303.atdsrvorg = 18 then
      let g_documento.atdsrvorg = 18

      ## Implementar qtde de utilizacao
      let g_documento.acao = "INC"
      call cts31m00()

   end if


   #--------------------------------------------------------------------
   #Laudo - Agendamento de Curso Direcao Defensiva
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod    = 32  and
      lr_cta02m1303.webrlzflg = "S" then

      call cts10g03_numeracao(1, "")
           returning lr_numeracao.lignum,
                     lr_numeracao.atdsrvnum,
                     lr_numeracao.atdsrvano,
                     lr_numeracao.sqlcode,
                     lr_numeracao.msg

      --> BUSCA A DATA E HORA DO BANCO
      call cts40g03_data_hora_banco(2)
           returning l_data_lig, l_hora_lig

      call cts10g00_ligacao(lr_numeracao.lignum,
                            l_data_lig,
                            l_hora_lig,
                            g_documento.c24soltipcod,
                            g_documento.solnom,
                            g_documento.c24astcod,
                            g_issk.funmat,
                            g_documento.ligcvntip,
                            g_c24paxnum,
                            lr_numeracao.atdsrvnum,
                            lr_numeracao.atdsrvano,
                            "",       # --> SINVSTNUM
                            "",       # --> SINVSTANO
                            "",       # --> SINAVSNUM
                            "",       # --> SINAVSANO
                            g_documento.succod,
                            g_documento.ramcod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            g_documento.edsnumref,
                            g_documento.prporg,
                            g_documento.prpnumdig,
                            g_documento.fcapacorg,
                            g_documento.fcapacnum,
                            "",       # --> SINRAMCOD
                            "",       # --> SINANO
                            "",       # --> SINNUM
                            "",       # --> SINITMSEQ
                            "",       # --> CADDAT
                            "",       # --> CADHOR
                            "",       # --> EMPCOD
                            "")       # --> FUNMAT
           returning l_tabname, l_sqlcode

      call cts40g20_pesq_web(g_issk.empcod, g_issk.funmat)
           returning l_status,
                     l_sttweb,
                     l_abnwebflg,
                     l_ligasscod,
                     l_vstagnnum,
                     l_vstagnstt,
                     l_orgvstagnnum

      if l_status = 0 then # ---> ENCONTROU REGISTRO
         ---> APAGA O REGISTRO DA WEB
         call cts40g20_apaga_web(g_issk.empcod, g_issk.funmat)
      end if

      if m_cta02m13_prep is null or
         m_cta02m13_prep <> true then
         call cta02m13_prepare()
      end if

      ### BUSCA CORSUS
      if g_documento.corsus is not null then
         let l_corsus = g_documento.corsus
      else
         open c_cta02m13_003 using g_documento.succod
                                ,g_documento.aplnumdig
                                ,l_corlidflg
         whenever error continue
         fetch c_cta02m13_003 into l_corsus
         whenever error stop

         if sqlca.sqlcode <> 0 and
            sqlca.sqlcode <> notfound then
            let l_corsus = null
         end if
      end if

      if l_corsus is not null then

         select a.cornom
           into l_cornom
           from gcakcorr a, gcaksusep b
          where b.corsus    = l_corsus
            and a.corsuspcp = b.corsuspcp
      end if

      let l_ligorgcod = 1 # origem do atd = 1 Porto

      call cts40g20_insere_web(g_issk.empcod,
                               g_issk.funmat,
                               g_documento.succod,
                               g_documento.ramcod,
                               g_documento.aplnumdig,
                               g_documento.itmnumdig,
                               g_documento.prporg,
                               g_documento.prpnumdig,
                               g_documento.solnom,
                               g_documento.c24soltipcod,
                               l_corsus,    --> lig.s/doc por corsus
                               "",          --> NUMERO AGENDAMENTO
                               lr_numeracao.lignum,
                               "",          --> CORLIGNUM
                               "",          --> CORLIGANO
                               "A",         --> SITUACAO ATENDIMENTO
                               "",          --> TIPO OPERACAO
                               l_ligorgcod, --> ATENDIMENTO PORTO
                               "",          --> (S)ABANDONO (N)CONCLUIU
                               "",          --> EMPCOD
                               "",          --> FUNMAT
                               "",          --> FUNNOM
                               l_cornom,    --> lig.s/doc por corsus
                               "",          --> STATUS AGENDAMENTO
                               "S",         --> CORASSHSTFLG
                               "",          --> NUMERO AGEND.(ORIGINAL)
                               g_documento.atdnum )  --> NUMERO de Atendimento


      # Psi 230669 inicio
      call ctd25g00_insere_atendimento(g_documento.atdnum
                                      ,lr_numeracao.lignum)
           returning l_retorno.sqlcode,l_retorno.tabname
      # Psi 230669 Fim

      if l_retorno.sqlcode <> 0 then
         error l_retorno.tabname sleep 3
      end if

      let l_sttweb = "A"

      ---> ATENDIMENTO SENDO REALIZADO VIA WEB
      while l_sttweb = "A"

         ---> EXIBE A MENSAGEM PARA O USUARIO

         initialize m_texto1, m_texto2 to null
         let m_texto1 = "PRESSIONE ALT+TAB PARA CONTINUAR"
         let m_texto2 = "O AGENDAMENTO NA WEB... "

         ---> Abre tela de Aviso com Atalho F1-Funcoes
         call cta02m13_men()


         ---> BUSCA O STATUS DE RETORNO DA WEB
         call cts40g20_pesq_web(g_issk.empcod, g_issk.funmat)
              returning l_status,
                        l_sttweb,
                        l_abnwebflg,
                        l_ligasscod,
                        l_vstagnnum,
                        l_vstagnstt,
                        l_orgvstagnnum
      end while


      if l_sttweb = "F" then  # ---> ASSUNTO FINALIZADO NA WEB

         if l_abnwebflg = "S" then
            # a ligacao foi abandonada
         else
            ---> BUSCA O CODIGO DO ASSUNTO
            let l_c24astcod = cts40g20_ret_codassu("S", # --> ATD. SEGURADO
                                                   l_ligorgcod,
                                                   l_ligasscod,
                                                   1)-->Curso Direcao Defensiva

            ---> ATUALIZA O ASSUNTO NA TABELA DATMLIGACAO
            call cts40g20_atlz_asslig(l_c24astcod, lr_numeracao.lignum)

            ---> GRAVA O AGENDAMENTO DO CURSO DE DIRECAO DEFENSIVA
            let l_status = cts40g20_grava_dir_def("S",     --> "S"=ATD.SEGURADO
                                                  l_orgvstagnnum,
                                                  "",         --> CORLIGNUM
                                                  "",         --> CORLIGITMSEQ
                                                  l_vstagnnum,
                                                  l_vstagnstt,
                                                  "",         --> CORLIGANO
                                                  lr_numeracao.lignum)
         end if

         ---> APAGA O REGISTRO DA WEB
         call cts40g20_apaga_web(g_issk.empcod, g_issk.funmat)
      end if
   end if

   # DVP 77909 Melhorias
   # PSI 245.640 Novo Aviso - Suporte, Apoio, Ajustes
   #--------------------------------------------------------------------
   #Aviso de Sinstro ROUBO/FURTO Total F15/F16 - AVS
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 33 and
      g_documento.c24astcod = "AVS" then
      if lr_cta02m1303.webrlzflg = "S"      then
         # --> BUSCA A DATA E HORA DO BANCO
         call cts40g03_data_hora_banco(2)
              returning l_data_lig, l_hora_lig
         let l_horas_lig = current


         let l_funmat    = g_issk.funmat
         let l_sinatdsit = "A"
         let l_sttweb    = "A"

         if m_cta02m13_prep is null or
            m_cta02m13_prep <> true then
            call cta02m13_prepare()
         end if
         call cts10g03_numeracao(2, "5")
              returning lr_numeracao.lignum,
                        lr_numeracao.atdsrvnum,
                        lr_numeracao.atdsrvano,
                        lr_numeracao.sqlcode,
                        lr_numeracao.msg

         call cta02m13_grava_transicao
             (g_issk.empcod           , # atlemp       Empresa Atendente
              l_funmat                , # atlmat       Matricula Atendente
              "F"                     , # atlusrtip    Tipo Usuario
              g_documento.c24astcod   , # c24astcod    codigo do Assunto
              "CONS/ALT AVS SINISTRO" , # sinntzdes    Descrição da natureza
              30                      , # sinntzcod    Código natureza
              g_documento.solnom      , # sinifrnom    Nome do informante
              g_documento.c24soltipcod, # c24soltipcod Tipo de informante
              l_data_lig              , # ligdat       Data da ligação
              l_hora_lig              , # lighor       Hora da ligação
              g_issk.empcod           , # empcod       empresa
              g_documento.succod      , # succod       Sucursal
              g_documento.ramcod      , # ramcod       Ramo
              g_documento.aplnumdig   , # aplnumdig    Apolice
              g_documento.itmnumdig   , # itmnumdig    Item
              g_documento.ligcvntip   , # ligcvntip    Codigo convenio
              g_c24paxnum             , # c24paxnum    Número da PA
              lr_numeracao.lignum     , # lignum       Número atendimento
              l_sinatdsit             , # sinatdsit    Status do atendimento
              l_vcllicnum             , # placa para atd. sem docto
              l_vclchsinc             , # chassi inicial p/ atd. sem docto
              l_vclchsfnl             , # chassi final   p/ atd. sem docto
              g_documento.prporg      , #
              g_documento.prpnumdig   , #
              g_documento.dddcod      , # dddcod p/ ligacao s/docto
              g_documento.ctttel      , # telefone p/ ligacao s/docto
              1                       , # empcod
              g_documento.funmat      , # matricula p/ ligacao s/docto
              "F"                     , # usrtip
              g_documento.cgccpfnum   , # cgc e cpf p/ ligacao s/docto
              g_documento.cgcord      , # ordem cgc p/ligacao s/docto
              g_documento.cgccpfdig   , # digito cgc cpf p/ligacao s/docto
              g_documento.corsus      , # susep p/ ligacao s/ docto
              l_motrecusa             , # motivo da recusa
              l_trfhor                ) # intervalo de horas
         returning l_ok

         if not l_ok then
            return l_ok, 0
         end if

         # ---> ATENDIMENTO SENDO REALIZADO VIA WEB
            while l_sttweb = "A"
               # ---> EXIBE A MENSAGEM PARA O USUARIO
               initialize m_texto1, m_texto2 to null
               let m_texto1 = "PRESSIONE ALT+TAB PARA CONSULTAR"
               let m_texto2 = "OU ALTERAR OS CODIGOS N10/N11/F10 NA WEB..."

               ---> Abre tela de Aviso com Atalho F1-Funcoes
               call cta02m13_men()


               # ---> BUSCA O STATUS DE RETORNO DA WEB
               call cta02m13_pesq_transicao( g_issk.empcod ,
                                             g_issk.funmat ,
                                             g_documento.c24astcod)
                    returning l_sttweb, l_ctq00m01_ret.lignum
               # impedir a liberacao do terminal Informix, ate que o motivo da
               # nao transferencia seja preenchido no Aviso Web, ou, que o
               # atendente informe no Aviso Web que a ligagco foi de fato
               # transferida.  11/07/07 - Marcelo Garcia/Ruiz
               if l_sttweb = "T" then  # nao liberar o terminal
                  let l_sttweb = "A"
               end if
            end while

            if l_sttweb = "F" or
               l_sttweb = "B" then
               # ---> ASSUNTO FINALIZADO NA WEB
               # --> BUSCA A DATA E HORA DO BANCO

               call cts40g03_data_hora_banco(2)
                    returning l_data_lig, l_hora_lig

               if g_documento.acao is null then
                  let g_documento.acao = "CON"
               end if


               ## ATUALIZA HORA FINAL DA LIGACAO

               whenever error continue
               begin work
                  update  datmligacao
                  set     lighorfnl = l_hora_lig
                  where   lignum = l_ctq00m01_ret.lignum
               whenever error stop

               if sqlca.sqlcode = 0 then
                  if cta02m13_remove_transicao(g_issk.empcod,
                                               g_issk.funmat,
                                               g_documento.c24astcod) then
                     commit work
                  else
                     rollback work
                  end if
               else
                  rollback work
               end if
            end if
      end if

   end if
   # DVP 77909 Melhorias
   # PSI 245.640 Novo Aviso - Suporte, Apoio, Ajustes

   if lr_cta02m1303.prgcod = 34 then
      call cta02m13_aviso_sinistro(lr_cta02m1303.*)
   end if

   #--------------------------------------------------------------------
   #Laudo para envio de guincho - Remocao e Sinistro(Itau)
   #--------------------------------------------------------------------

   if lr_cta02m1303.prgcod = 35   then
      call cts60m00()
   end if

   #--------------------------------------------------------------------
   #Laudo para servicos a residencia - (Itau)
   #--------------------------------------------------------------------

   if lr_cta02m1303.prgcod = 36    or
      lr_cta02m1303.atdsrvorg = 9 then
      let l_ciaempcod_slv = g_documento.ciaempcod
      if g_documento.ramcod <> 14 then
         call cts61m00()
      else
         call cts65m00()
      end if
      let g_documento.ciaempcod = l_ciaempcod_slv
   end if

   #--------------------------------------------------------------------
   #Laudo para assistencia a passageiros - Transporte(Itau)
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 37   or
      lr_cta02m1303.atdsrvorg = 2 then
      if g_documento.ramcod <> 14 then
         call cts62m00()
      else
	 call cts66m00()
      end if
   end if

   #--------------------------------------------------------------------
   #Laudo para assistencia a passageiros - Hospedagem(Itau)
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 38   or
      lr_cta02m1303.atdsrvorg = 3 then
      call cts63m00()
   end if

   #--------------------------------------------------------------------
   #Laudo Carro Reseva - Locacao(Itau)
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 39   or
      lr_cta02m1303.atdsrvorg = 8 then
      call cts64m00()
   end if

   #--------------------------------------------------------------------
   #Laudo para envio de guincho - Remocao e Sinistro(Pss)
   #--------------------------------------------------------------------

   if lr_cta02m1303.prgcod = 40   then
      call cts70m00()
   end if

   #--------------------------------------------------------------------
   #Laudo para servicos a residencia - (Pss)
   #--------------------------------------------------------------------

   if lr_cta02m1303.prgcod = 41    or
      lr_cta02m1303.atdsrvorg = 9 then
      let l_ciaempcod_slv = g_documento.ciaempcod
      call cts71m00()
      let g_documento.ciaempcod = l_ciaempcod_slv
   end if

   #--------------------------------------------------------------------
   #Laudo para assistencia a passageiros - Transporte(Pss)
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 42   or
      lr_cta02m1303.atdsrvorg = 2 then
      call cts72m00()
   end if

   #--------------------------------------------------------------------
   #Laudo para assistencia a passageiros - Hospedagem(Pss)
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 43   or
      lr_cta02m1303.atdsrvorg = 3 then
      call cts73m00()
   end if

   #--------------------------------------------------------------------
   #Laudo Carro Reseva - Locacao(Pss)
   #--------------------------------------------------------------------
   if lr_cta02m1303.prgcod = 44   or
      lr_cta02m1303.atdsrvorg = 8 then
      call cts74m00()
   end if

   return l_ret, g_documento.lignum

end function #cta02m13_chama_laudos

#-------------------------------------------#
function cta02m13_trata_cls096(lr_cta02m1304)
#-------------------------------------------#
#Tratamento para clausula 096 para gravar o historico na ligacao

define lr_cta02m1304   record
   flgIS096            char(01)
  ,lignum              like datmligacao.lignum
  ,funmat              like isskfunc.funmat
end record

define l_historico     char(45)
define l_data          date
define l_hora          datetime hour to  second
define l_tabname       like systables.tabname
define l_sqlcode       smallint

   call cts40g03_data_hora_banco(1)
        returning l_data, l_hora

   let l_historico = ""
   let l_tabname = ""
   let l_sqlcode = 0

   if lr_cta02m1304.flgIS096 = "S" then
      let l_historico = '096 = Valor da Cobertura FOI ultrapassado'
   end if

   if lr_cta02m1304.flgIS096 = "N" then
      let l_historico = '096 = Valor da Cobertura NAO FOI ultrapassado'
   end if

   if lr_cta02m1304.flgIS096 = "P" then
      let l_historico = '096 = Problemas no acesso a apolice ou outros'
   end if

   if l_historico is not null then
      call ctd06g01_ins_datmlighist(lr_cta02m1304.lignum,
                                    lr_cta02m1304.funmat,
                                    l_historico,
                                    l_data,
                                    l_hora,
                                    g_issk.usrtip,
                                    g_issk.empcod  )
           returning l_sqlcode,  #retorno
                     l_tabname   #mensagem

      #if l_sqlcode <> 0 then
      if l_sqlcode <> 1 then
         error l_tabname
      end if
   end if

   return l_tabname, l_sqlcode

end function #cta02m13_trata_cls096

#------------------------------------------------------------------------------
function cta02m13_trata_localizacao(lr_cta02m1305)
#------------------------------------------------------------------------------
#Tratar assuntos do grupo Localizacao: L10, L11, L12, L45

define lr_cta02m1305   record
   c24astcod           like datrastfun.c24astcod
  ,lignum              like datmligacao.lignum
  ,funmat              like isskfunc.funmat
  ,data                date
  ,hora                datetime hour to second
  ,succod              like datrligapol.succod
  ,aplnumdig           like abamapol.aplnumdig
  ,itmnumdig           like abbmdoc.itmnumdig
  ,vclsitatu           smallint
  ,aplflg              char(01)
end record

define l_result        smallint
define l_msg           char(80)
define l_vcllicnum     like abbmveic.vcllicnum
define l_vclchsfnl     like abbmveic.vclchsfnl
define l_vclchsinc     like abbmveic.vclchsinc
define l_chassi        char(20)
define l_vclanofbc     like abbmveic.vclanofbc
define l_vclcoddig     like abbmveic.vclcoddig
define l_nome          char(100)
define l_telefone      char(11)
#define l_mensagem      like datmlighist.c24ligdsc
define aux_times       char(11)
define l_data          date
define l_hora          like datmservico.atdhor
define l_verifica      smallint

define l_ret         smallint,
       l_mensg       char(50)

   let l_result = 0
   let l_msg = ""
   let l_vcllicnum = ""
   let l_vclchsfnl = ""
   let l_chassi    = ""
   let l_vclchsinc = null
   let l_vclanofbc = null
   let l_vclcoddig = null


   #Obter placa e chassi do veiculo
   call cty05g00_dados_veic(lr_cta02m1305.succod
                           ,lr_cta02m1305.aplnumdig
                           ,lr_cta02m1305.itmnumdig
                           ,lr_cta02m1305.vclsitatu)
            returning l_result,l_msg,l_vcllicnum, l_vclchsinc,
                      l_vclchsfnl, l_vclanofbc , l_vclcoddig


   #Com ou sem Avarias
   if lr_cta02m1305.c24astcod = "L11" or
      lr_cta02m1305.c24astcod = "L12" then
      error "Formatando dados para localizacao..."
      #Patricia
      let l_chassi  = l_vclchsinc clipped, l_vclchsfnl clipped
      call cta02m05(lr_cta02m1305.lignum
                   ,lr_cta02m1305.funmat
                   ,lr_cta02m1305.data
                   ,lr_cta02m1305.hora
                   ,l_vcllicnum
                   ,l_chassi)
      # helder 15/03/2011
           returning m_cidade,
                     m_estado,
                     m_flagbo,
                     m_BO

      let m_cidade = m_cidade clipped
      let m_estado = m_estado clipped
      let m_flagbo = m_flagbo clipped
      let m_BO     = m_BO     clipped

      let l_verifica = cta00m06_jit_cidades(m_cidade,m_estado)

      if l_verifica =  1   and
         m_flagbo   = 'N' then
         #flag
          if cts08g01("A","S","OFERECA O SERVICO DE JIT PARA "
                             ,"REALIZACAO DO BOLETIM DE OCORRENCIA."
                             ,"O SERVICO FOI ACEITO ?"
                             ,"") = "S"  then
            let m_flag = 'SIM ACEITOU O BENEFÍCIO JIT'
          else
            let m_flag = 'NAO ACEITOU O BENEFÍCIO JIT'
          end if

         #nome e tel
          call cta02m13_captura_nome_tel()
               returning l_nome, l_telefone

         # motivo
          call ctc26m01()
               returning g_documento.rcuccsmtvcod

         #grava cidade, estado, flagbo, bo, flag, nome e tel no historico
         call cts40g03_data_hora_banco(1)
             returning l_data, l_hora

          let m_flag              =  m_flag clipped

          let m_cidade = 'Cidade...............: ' , m_cidade
          let m_estado = 'Estado...............: ' , m_estado
          let m_flagbo = 'Boletim de Ocorrencia: ' , m_flagbo

         call ctd06g01_ins_datmlighist( lr_cta02m1305.lignum           #grava cidade
                                         ,lr_cta02m1305.funmat
                                         ,m_cidade
                                         ,l_data
                                         ,l_hora
                                         ,g_issk.usrtip
                                         ,g_issk.empcod )
                       returning l_ret,
                                 l_mensg

         call ctd06g01_ins_datmlighist( lr_cta02m1305.lignum           #grava estado
                                         ,lr_cta02m1305.funmat
                                         ,m_estado
                                         ,l_data
                                         ,l_hora
                                         ,g_issk.usrtip
                                         ,g_issk.empcod )
                       returning l_ret,
                                 l_mensg

         call ctd06g01_ins_datmlighist( lr_cta02m1305.lignum           #grava flagbo
                                         ,lr_cta02m1305.funmat
                                         ,m_flagbo
                                         ,l_data
                                         ,l_hora
                                         ,g_issk.usrtip
                                         ,g_issk.empcod )
                       returning l_ret,
                                 l_mensg

          call ctd06g01_ins_datmlighist( lr_cta02m1305.lignum           #grava m_flag
                                         ,lr_cta02m1305.funmat
                                         ,m_flag
                                         ,l_data
                                         ,l_hora
                                         ,g_issk.usrtip
                                         ,g_issk.empcod )
                       returning l_ret,
                                 l_mensg


          call ctd06g01_ins_datmlighist( lr_cta02m1305.lignum          #grava nome
                                         ,lr_cta02m1305.funmat
                                         ,l_nome
                                         ,l_data
                                         ,l_hora
                                         ,g_issk.usrtip
                                         ,g_issk.empcod )
                       returning l_ret,
                                 l_mensg

          call ctd06g01_ins_datmlighist( lr_cta02m1305.lignum          #grava telefone
                                         ,lr_cta02m1305.funmat
                                         ,l_telefone
                                         ,l_data
                                         ,l_hora
                                         ,g_issk.usrtip
                                         ,g_issk.empcod )
                       returning l_ret,
                                 l_mensg


         #grava motivo
          whenever error continue
          execute pcta02m13008 using  lr_cta02m1305.lignum
                                    , g_documento.rcuccsmtvcod
                                    , lr_cta02m1305.c24astcod
          whenever error stop
          if sqlca.sqlcode <> 0 then
             error 'Erro INSERT datrligrcuccsmtv:',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
          end if

         #envia email
         if g_documento.succod    is null and
            g_documento.aplnumdig is null then         #se apolice nula
            if g_documento.prporg     is not null and
               g_documento.prpnumdig  is not null then #e se for proposta
              if lr_cta02m1305.aplflg = "N" then    # atd. sem documento
                 call cta02m13_informa_placa_chassi()
                      returning l_vcllicnum,
                                l_vclchsinc,
                                l_vclchsfnl
              end if
            end if
         end if

          call cta02m13_enviaEmail_localizacao(lr_cta02m1305.lignum
                                            , l_vcllicnum
                                            , l_telefone
                                            , l_nome
                                            , lr_cta02m1305.c24astcod
                                            , ''
                                            , ''
                                            , m_flag)
      else
         call cts40g03_data_hora_banco(1)
             returning l_data, l_hora

             let m_flag              =  m_flag clipped

             let m_cidade = 'Cidade...............: ' , m_cidade
             let m_estado = 'Estado...............: ' , m_estado
             let m_flagbo = 'Boletim De Ocorrencia: ' , m_flagbo

             if m_BO is null or m_BO = ' '   then
                let m_BO     = 'Numero Do B.O........: ' , 'NAO INFORMADO!'
             else
                let m_BO     = 'Numero Do B.O........: ' , m_BO
             end if

             call ctd06g01_ins_datmlighist( lr_cta02m1305.lignum           #grava cidade
                                            ,lr_cta02m1305.funmat
                                            ,m_cidade
                                            ,l_data
                                            ,l_hora
                                            ,g_issk.usrtip
                                            ,g_issk.empcod )
                          returning l_ret,
                                    l_mensg

            call ctd06g01_ins_datmlighist( lr_cta02m1305.lignum           #grava estado
                                            ,lr_cta02m1305.funmat
                                            ,m_estado
                                            ,l_data
                                            ,l_hora
                                            ,g_issk.usrtip
                                            ,g_issk.empcod )
                          returning l_ret,
                                    l_mensg

            call ctd06g01_ins_datmlighist( lr_cta02m1305.lignum           #grava flagbo
                                            ,lr_cta02m1305.funmat
                                            ,m_flagbo
                                            ,l_data
                                            ,l_hora
                                            ,g_issk.usrtip
                                            ,g_issk.empcod )
                          returning l_ret,
                                    l_mensg
         if m_flagbo = 'S' then
                call ctd06g01_ins_datmlighist( lr_cta02m1305.lignum           #grava bo
                                        ,lr_cta02m1305.funmat
                                        ,m_BO
                                        ,l_data
                                        ,l_hora
                                        ,g_issk.usrtip
                                        ,g_issk.empcod )
                      returning l_ret,
                                l_mensg

         end if
      end if

   end if

   if lr_cta02m1305.c24astcod = "L10" or
      lr_cta02m1305.c24astcod = "L11" or
      lr_cta02m1305.c24astcod = "L12" or
      lr_cta02m1305.c24astcod = "L45" then
      if lr_cta02m1305.aplnumdig is not null then
         #Obter placa e chassi do veiculo
         call cty05g00_dados_veic(lr_cta02m1305.succod
                                 ,lr_cta02m1305.aplnumdig
                                 ,lr_cta02m1305.itmnumdig
                                 ,lr_cta02m1305.vclsitatu)
              returning l_result,l_msg,l_vcllicnum, l_vclchsinc,
                        l_vclchsfnl, l_vclanofbc , l_vclcoddig
         if l_result = 3 then
            error l_msg
            sleep 1
         else
            #Baixa acionamento do dispositivo GRILO
            call cty07g01_fadia010(l_vcllicnum, l_vclchsfnl,'B')
         end if
      else
         if lr_cta02m1305.aplflg = "N"then    # atd. sem documento
            if  lr_cta02m1305.c24astcod  = "L10" or
                lr_cta02m1305.c24astcod  = "L45" then
                call cta02m13_informa_placa_chassi()
                     returning l_vcllicnum,
                               l_vclchsinc,
                               l_vclchsfnl
            end if

            call cta02m00_enviaEmail(g_documento.lignum,
                            l_vcllicnum,
                            "",
                            "",
                            g_documento.c24astcod )

            ## chama cty13g00 para gravar dados para DAF5
            let l_chassi  = l_vclchsinc clipped, l_vclchsfnl clipped
            -------------[ funcao de interface com sistema daf ]------------------
            call cty13g00("",                    # Fim Integração                       |excfnl
                          "",                    # Codigo Erro                          |errcod
                          "",                    # Descrição Erro                       |errdsc
                          "",                    # Codigo Dispositivo                   |discoddig
                          "",                    # ws.lclltt # Latitude                 |sinlclltt
                          "",                    # ws.lcllgt # Longitude                |sinlcllgt
                          "",                    # param.atdsrvnum # Número Atendimento |atdsrvnum
                          "",                    # param.atdsrvano # Ano Atendimento    |atdsrvano
                          "",                    # ws.vclcoddig    # Codigo Veículo     |vclcoddig
                          "",                    # lr_cts05g00.vcldes# Descricao Veículo|vcldes
                          l_vcllicnum,           # Placa Veículo                        |vcllicnum
                          g_documento.c24astcod, # Assunto
                          l_chassi,              # Número Chassi                        |vclchscod
                          "",                    # lr_cts05g00.segnom,# Nome Segurado   |segnom
                          lr_cta02m1305.data ,   # Data Sisnistro                       |sindat
                          lr_cta02m1305.hora ,   # Data Comunicado                      |cincmudat
                          lr_cta02m1305.data ,   # Data Cadastro                        |caddat
                          "",                    # Importancia Segurada                 |imsvlr
                          "",                    # Resumo do Sinistro                   |sinres
                          "",                    # Ticket de Entrega                    |enttck
                          g_documento.succod,    # Codigo Sucursal                      |succod
                          g_documento.aplnumdig, # Número Apólice                       |aplnumdig
                          g_documento.itmnumdig, # Item Apólice                         |itmnumdig
                          "",                    # Seq Número Docto                     |dctnumseq
                          "",                    # ws.edsnumref, # Número Endosso       |edsnumdig
                          "",                    # ws.prporg,    # Origem Proposta      |prporgpcp
                          "",                    # ws.prpnumdig, # Número Proposta      |prpnumpcp
                          "",                    # cgccpfnum,# Número CGC/CPF           |cgccpfnum
                          "",                    # cgcord,   # Ordem CGC                |cgcord
                          "",                    # cgccpfdig,# Dígito CGC/CPF           |cgccpfdig
                          "",                    # vclcordes, # Descrição cor Veículo   |vclcordsc
                          "",                    # Nome Condutor                        |cdtnom
                          "",                    # Número Tentativas                    |itgttvnum
                          "cta02m13")            # Programa chamador   ---> Ruiz/Camila

         end if
      end if
   end if

   return l_result

end function #cta02m13_trata_localizacao

#------------------------------------------------------------------------------
 function cta02m13_grava_transicao(param)
#------------------------------------------------------------------------------

 define param record
    atlemp        like datmsinatditf.atlemp       ,
    atlmat        like datmsinatditf.atlmat       ,
    atlusrtip     like datmsinatditf.atlusrtip    ,
    atdassdes     like datmsinatditf.atdassdes    ,
    sinntzdes     like datmsinatditf.sinntzdes    ,
    sinntzcod     like datmsinatditf.sinntzcod    ,
    sinifrnom     like datmsinatditf.sinifrnom    ,
    c24soltipcod  like datmsinatditf.c24soltipcod ,
    ligdat        like datmsinatditf.ligdat       ,
    lighor        like datmsinatditf.lighor       ,
    empcod        like datmsinatditf.empcod       ,
    succod        like datmsinatditf.succod       ,
    ramcod        like datmsinatditf.ramcod       ,
    aplnumdig     like datmsinatditf.aplnumdig    ,
    itmnumdig     like datmsinatditf.itmnumdig    ,
    ligcvntip     like datmsinatditf.ligcvntip    ,
    c24paxnum     like datmsinatditf.c24paxnum    ,
    lignum        like datmsinatditf.lignum       ,
    sinatdsit     like datmsinatditf.sinatdsit    ,
    vcllicnum     like datmsinatditf.vcllicnum    ,
    vclchsinc     like datmsinatditf.vclchsinc    ,
    vclchsfnl     like datmsinatditf.vclchsfnl    ,
    prporg        like datmsinatditf.prporg       ,
    prpnumdig     like datmsinatditf.prpnumdig    ,
    dddcod        like datmsinatditf.dddcod       ,
    teltxt        like datmsinatditf.teltxt       ,
    solempcod     like datmsinatditf.solempcod    ,
    solfunmat     like datmsinatditf.solfunmat    ,
    solusrtip     like datmsinatditf.solusrtip    ,
    cgccpfnum     like datmsinatditf.cgccpfnum    ,
    cgcord        like datmsinatditf.cgcord       ,
    cgccpfdig     like datmsinatditf.cgccpfdig    ,
    corsus        like datmsinatditf.corsus       ,
    motrecusa     smallint                        ,
    trfhor        interval hour to second

 end record

 define cta02m13_srv record
        lignum    like  datmligacao.lignum   ,
        atdsrvnum like  datmservico.atdsrvnum,
        atdsrvano like  datmservico.atdsrvano,
        erro      smallint                   ,
        msgerro   char(80)
 end record

 define l_atdsrvano    char(04)
 define l_atdsrvnum    like datmservico.atdsrvnum
 define l_retorno      smallint
 define l_hoje         char(04)
 define l_anoatual     char(02)
 define l_ligdat       like datmpndsin.ligdat

 define l_conta integer

 initialize l_atdsrvano to null
 initialize l_atdsrvnum to null
 initialize l_hoje      to null
 initialize l_anoatual  to null
 initialize l_ligdat    to null
 initialize cta02m13_srv.* to null

 ## verifica pendencia
 let l_retorno      = 1
 let l_conta = 0
 select count(*) into l_conta
 from   datmsinatditf
 where  atlemp     = param.atlemp
 and    atlmat     = param.atlmat
 and    atlusrtip  = param.atlusrtip
#and    atdassdes  = param.atdassdes  # (F10 ou U10)

 if l_conta > 0 then
    delete
    from   datmsinatditf
    where  atlemp     = param.atlemp
    and    atlmat     = param.atlmat
    and    atlusrtip  = param.atlusrtip
   #and    atdassdes  = param.atdassdes Conforme solicitacao daniel DN N10/N11.
 end if
 ----[verifica se existe atendimento pendente para apolice - ass F10]-------
 if param.atdassdes = "F10" then
    declare c_cta02m13_005 cursor for
       select atdsrvnum,
              atdsrvano,
              ligdat
      #into   cta02m13_srv.atdsrvnum,
      #       cta02m13_srv.atdsrvano
       from datmpndsin
       where succod    = param.succod
         and ramcod    = param.ramcod
         and aplnumdig = param.aplnumdig
         and itmnumdig = param.itmnumdig
    open c_cta02m13_005
    fetch c_cta02m13_005 into cta02m13_srv.atdsrvnum,
                            cta02m13_srv.atdsrvano,
                            l_ligdat
    if sqlca.sqlcode = 0 then
       #Esta regra foi definida pelo Moacyr e Marcio de Lima - 08/04/08
       # A CT24hrs ira verificar o ANO da vistoria.
       # Se o ano atual for diferente do ano da vistoria,
       # uma nova vistoria deve ser gerada.
       #
       # Se o ano da vistoria for o mesmo que o atual,
       # sera verificado se a vistoria foi gerada num período de 5 dias.
       # Caso afirmativo, usamos a mesma vistoria, caso contrario,
       # geramos uma nova.
       #
       # Exemplo:
       # 664442/2007=> ANO diferente do Ano Atual (2008) => gerar nova vistoria.
       # 664442/2008=> ANO igual ao atual = > Verificar período de 5 dias.

       let l_hoje     = year(today)
       let l_anoatual = l_hoje[3,4]

       if l_anoatual <> cta02m13_srv.atdsrvano then
          let sqlca.sqlcode   =   100 # gera nova vistoria
       else
          if l_ligdat < (today - 5 units day) then
             let sqlca.sqlcode =  100 # gera nova vistoria
          end if
       end if
    end if
    if sqlca.sqlcode <> 0 then # gera nova vistoria
       ## Gerar Nº aviso
       call cts10g03_numeracao(0,"5")         # 0=so gera numero do aviso,
               returning cta02m13_srv.lignum, # nao gera ligacao. 11/02/08
                         cta02m13_srv.atdsrvnum,
                         cta02m13_srv.atdsrvano,
                         cta02m13_srv.erro,
                         cta02m13_srv.msgerro
       if cta02m13_srv.atdsrvnum is null or
          cta02m13_srv.atdsrvnum = 0 then
          error "Registro locado, Tente Novamente... " sleep 3
          let l_retorno = 0  ## Zero eh falso
          return l_retorno
       else
          error " "
          let l_retorno = 1
       end if

       let l_atdsrvnum = cta02m13_srv.atdsrvnum
       let l_atdsrvano =  '20', cta02m13_srv.atdsrvano using "&&"

       ---[remover a tabela no ctx19g00 apos a gravacao da ligacao]-----
       insert into datmpndsin(succod    ,
                              ramcod    ,
                              aplnumdig ,
                              itmnumdig ,
                              vcllicnum ,
                              vclchsinc ,
                              vclchsfnl ,
                              atdsrvnum ,
                              atdsrvano ,
                              ligdat    ,
                              lighorinc ,
                              c24funmat ,
                              c24empcod ,
                              c24usrtip )
             values         (param.succod    ,
                             param.ramcod    ,
                             param.aplnumdig ,
                             param.itmnumdig ,
                             ""              , #param.vcllicnum ,
                             ""              , #param.vclchsinc ,
                             ""              , #param.vclchsfnl ,
                             cta02m13_srv.atdsrvnum ,
                             cta02m13_srv.atdsrvano ,
                             param.ligdat    ,
                             param.lighor    ,
                             param.atlmat    ,
                             param.atlemp    ,
                             param.atlusrtip )
    else
        error "Existe Sinistro Pendente - ", cta02m13_srv.atdsrvnum
    end if
 end if

 if l_atdsrvnum is not null then
    let l_atdsrvnum = cta02m13_srv.atdsrvnum
    let l_atdsrvano =  '20', cta02m13_srv.atdsrvano using "&&"
 end if

 if param.aplnumdig is null then
    let param.vcllicnum  = null
    let param.vclchsinc  = null
    let param.vclchsfnl  = null
 end if


 insert into datmsinatditf ( atlemp             ,
                             atlmat             ,
                             atlusrtip          ,
                             atdassdes          ,
                             sinntzdes          ,
                             sinntzcod          ,
                             sinifrnom          ,
                             c24soltipcod       ,
                             ligdat             ,
                             lighor             ,
                             empcod             ,
                             succod             ,
                             ramcod             ,
                             aplnumdig          ,
                             itmnumdig          ,
                             ligcvntip          ,
                             c24paxnum          ,
                             lignum             ,
                             sinatdsit          ,
                             sinvstnum          ,
                             sinvstano          ,
                             vcllicnum          ,
                             vclchsinc          ,
                             vclchsfnl          ,
                             prporg             ,
                             prpnumdig          ,
                             dddcod             ,
                             teltxt             ,
                             solempcod          ,
                             solfunmat          ,
                             solusrtip          ,
                             cgccpfnum          ,
                             cgcord             ,
                             cgccpfdig          ,
                             corsus             ,
                             recmtv             ,
                             trfhor             ,
                             atdnum             ) #psi 223689
        values            (  param.atlemp       ,
                             param.atlmat       ,
                             param.atlusrtip    ,
                             param.atdassdes    ,
                             param.sinntzdes    ,
                             param.sinntzcod    ,
                             param.sinifrnom    ,
                             param.c24soltipcod ,
                             param.ligdat       ,
                             param.lighor       ,
                             param.empcod       ,
                             param.succod       ,
                             param.ramcod       ,
                             param.aplnumdig    ,
                             param.itmnumdig    ,
                             param.ligcvntip    ,
                             param.c24paxnum    ,
                             param.lignum       ,
                             param.sinatdsit    ,
                             l_atdsrvnum        ,
                             l_atdsrvano        ,
                             param.vcllicnum    ,
                             param.vclchsinc    ,
                             param.vclchsfnl    ,
                             param.prporg       ,
                             param.prpnumdig    ,
                             param.dddcod       ,
                             param.teltxt       ,
                             param.solempcod    ,
                             param.solfunmat    ,
                             param.solusrtip    ,
                             param.cgccpfnum    ,
                             param.cgcord       ,
                             param.cgccpfdig    ,
                             param.corsus       ,
                             param.motrecusa    ,
                             param.trfhor       ,
                             g_documento.atdnum ) # psi 230669
 return l_retorno

end function # cta02m13_grava_transicao()

#------------------------------------------------------------------------------
 function cta02m13_pesq_transicao(param)
#------------------------------------------------------------------------------

 define param record
    atlemp        smallint    ,
    atlmat        decimal(6,0),
    c24astcod     like datmligacao.c24astcod
 end record

 define l_stt     char(01)
 define l_ligacao like datmligacao.lignum

 let l_stt = "A"
 let l_ligacao = null

 select sinatdsit, lignum
 into   l_stt,     l_ligacao
 from   datmsinatditf
 where  atlemp  = param.atlemp
 and    atlmat  = param.atlmat
 and    atdassdes = param.c24astcod

 if l_stt is null then
    let l_stt = "A"
 end if

 return l_stt, l_ligacao

end function # cta02m13_pesq_transicao()

#------------------------------------------------------------------------------
 function cta02m13_remove_transicao(param)
#------------------------------------------------------------------------------

 define param record
    atlemp   like datmsinatditf.atlemp,
    atlmat   like datmsinatditf.atlmat,
    c24astcod like datmligacao.c24astcod
 end record

 delete from   datmsinatditf
 where  atlemp  = param.atlemp
 and    atlmat  = param.atlmat
 and    atdassdes = param.c24astcod
 and    sinatdsit in( "F", "B" )

 if sqlca.sqlcode <> 0 then
    return false
 end if

 return true

end function # cta02m13_remove_transicao()

-----------------------------------------------------------------------------
function cta02m13_acesso_web(param)
-----------------------------------------------------------------------------

  define param record

         cpodes like iddkdominio.cpodes
  end record

  define ws_web  record
         count         dec (10,0),
         status        smallint
  end record

  select count(*) into ws_web.count
    from iddkdominio
   where cponom matches "web_n10*" -- "web_furto*"
     and cpodes = param.cpodes

  if ws_web.count is null then
     let ws_web.count = 0
  end if

  if ws_web.count > 0 then  # matricula sem acesso a web
     let ws_web.status = 1
  else
     let ws_web.status = 0
  end if

 return ws_web.status

end function

#-------------------------------------------------------------#
  function cta02m13_monta_xml(lr_param)
#-------------------------------------------------------------#

    define lr_param  record
           ligdat           like datmligacao.ligdat     ,# (  1)ligdat
           lighorinc        like datmligacao.lighorinc  ,# (  2)lighorinc
           c24soltipcod     like datksoltip.c24soltipcod,# (  3)1-SEGURADO, 2-CORRETOR, 3-OUTROS, 4-Oficina
           c24solnom        like datmligacao.c24solnom  ,# (  4)Solicitante
           c24astcod        like datmligacao.c24astcod  ,# (  5)V10 ou V11
           c24funmat        like datmligacao.c24funmat  ,# (  6)g_issk.funmat
           ligcvntip        like datmligacao.ligcvntip  ,# (  7)0-
           c24paxnum        like datmligacao.c24paxnum  ,# (  8)Nº PA para Portal 9999 ??
           atdsrvnum        like datrligsrv.atdsrvnum   ,# (  9) ""
           atdsrvano        like datrligsrv.atdsrvano   ,# ( 10) ""
           sinavsnum        like datrligsinavs.sinavsnum,# ( 11) ""
           sinavsano        like datrligsinavs.sinavsano,# ( 12) ""
           succod           like datrligapol.succod     ,# ( 13)succod
           ramcod           like datrligapol.ramcod     ,# ( 14)ramcod
           aplnumdig        like datrligapol.aplnumdig  ,# ( 15)aplnumdig
           itmnumdig        like datrligapol.itmnumdig  ,# ( 16)itmnumdig
           edsnumref        like datrligapol.edsnumref  ,# ( 17)edsnumref
           prporg           like datrligprp.prporg      ,# ( 18)prporg
           prpnumdig        like datrligprp.prpnumdig   ,# ( 19)prpnumdig
           fcapacorg        like datrligpac.fcapacorg   ,# ( 20)fcapacorg
           fcapacnum        like datrligpac.fcapacnum   ,# ( 21)fcapacnum
           sinramcod        like ssamsin.ramcod         ,# ( 22) ""
           sinano           like ssamsin.sinano         ,# ( 23) ""
           sinnum           like ssamsin.sinnum         ,# ( 24) ""
           sinitmseq        like ssamitem.sinitmseq     ,# ( 25) ""
           caddat           like datmligfrm.caddat      ,# ( 26) ""
           cadhor           like datmligfrm.cadhor      ,# ( 27) ""
           cademp           like datmligfrm.cademp      ,# ( 28) ""
           cadmat           like datmligfrm.cadmat      ,# ( 29) ""
           vstsolnom        like datmvstsin.vstsolnom   ,# ( 30)
           vstsoltip        like datmvstsin.vstsoltip   ,# ( 31)
           vstsoltipcod     like datmvstsin.vstsoltipcod,# ( 32)
           segnom           like datmvstsin.segnom      ,# ( 33)
           subcod           like datmvstsin.subcod      ,# ( 34)
           dddcod           like datmvstsin.dddcod      ,# ( 35)
           teltxt           like datmvstsin.teltxt      ,# ( 36)
           cornom           like datmvstsin.cornom      ,# ( 37)
           corsus           like datmvstsin.corsus      ,# ( 38)
           vcldes           like datmvstsin.vcldes      ,# ( 49)
           vclanomdl        like datmvstsin.vclanomdl   ,# ( 40)
           vcllicnum        like datmvstsin.vcllicnum   ,# ( 41)
           vclchsfnl        like datmvstsin.vclchsfnl   ,# ( 42)
           sindat           like datmvstsin.sindat      ,# ( 43)
           sinavs           like datmvstsin.sinavs      ,# ( 44)
           orcvlr           like datmvstsin.orcvlr      ,# ( 45)
           ofnnumdig        like datmvstsin.ofnnumdig   ,# ( 46)
           vstdat           like datmvstsin.vstdat      ,# ( 47)
           vstretdat        like datmvstsin.vstretdat   ,# ( 48)
           vstretflg        like datmvstsin.vstretflg   ,# ( 49)
           funmat           like datmvstsin.funmat      ,# ( 50)
           atddat           like datmvstsin.atddat      ,# ( 51)
           atdhor           like datmvstsin.atdhor      ,# ( 52)
           sinvstorgnum     like datmvstsin.sinvstorgnum,# ( 53)
           sinvstorgano     like datmvstsin.sinvstorgano,# ( 54)
           sinvstsolsit     like datmvstsin.sinvstsolsit,# ( 55)
           vclchsinc        like datmvstsin.vclchsinc   ,# ( 56)
           ## Grava Serviço
           vclcorcod        like datmservico.vclcorcod  ,# ( 57)vclcorcod  ,
           atdlibflg        like datmservico.atdlibflg  ,# ( 59)           ,
           atdlibhor        like datmservico.atdlibhor  ,# ( 60)           ,
           atdlibdat        like datmservico.atdlibdat  ,# ( 61)           ,
           atdlclflg        like datmservico.atdlclflg  ,# ( 62)atdlclflg  ,
           atdhorpvt        like datmservico.atdhorpvt  ,# ( 63}           ,
           atddatprg        like datmservico.atddatprg  ,# ( 64)           ,
           atdhorprg        like datmservico.atdhorprg  ,# ( 65)           ,
           atdtip           like datmservico.atdtip     ,# ( 66)"5"        ,
           atdmotnom        like datmservico.atdmotnom  ,# ( 67)           ,
           atdvclsgl        like datmservico.atdvclsgl  ,# ( 68)           ,
           atdprscod        like datmservico.atdprscod  ,# ( 69)           ,
           atdcstvlr        like datmservico.atdcstvlr  ,# ( 70)           ,
           atdfnlflg        like datmservico.atdfnlflg  ,# ( 71)"S"        ,
           atdfnlhor        like datmservico.atdfnlhor  ,# ( 72) ""       ,
           atdrsdflg        like datmservico.atdrsdflg  ,# ( 73)atdrsdflg  ,
           atddfttxt        like datmservico.atddfttxt  ,# ( 74)atddfttxt  ,
           atddoctxt        like datmservico.atddoctxt  ,# ( 75)atddoctxt  ,
           c24opemat        like datmservico.c24opemat  ,# ( 76)c24opemat  ,
           nom              like datmservico.nom        ,# ( 77)nom        ,
           cnldat           like datmservico.cnldat     ,# ( 78)data       ,
           pgtdat           like datmservico.pgtdat     ,# ( 79)""         ,
           c24nomctt        like datmservico.c24nomctt  ,# ( 80)""         ,
           atdpvtretflg     like datmservico.atdpvtretflg,# ( 81)          ,
           atdvcltip        like datmservico.atdvcltip  ,# ( 82)           ,
           asitipcod        like datmservico.asitipcod  ,# ( 83)           ,
           socvclcod        like datmservico.socvclcod  ,# ( 84)           ,
           vclcoddig        like datmservico.vclcoddig  ,# ( 85)vclcoddig  ,
           srvprlflg        like datmservico.srvprlflg  ,# ( 86)"N"        ,
           srrcoddig        like datmservico.srrcoddig  ,# ( 87)           ,
           atdprinvlcod     like datmservico.atdprinvlcod,# ( 88)          ,
           atdsrvorg        like datmservico.atdsrvorg  ,# ( 89)atdsrvorg
           ## Grava datmservicocmp
           c24sintip        like datmservicocmp.c24sintip,# ( 90)
           c24sinhor        like datmservicocmp.c24sinhor,# ( 91)
           bocflg           like datmservicocmp.bocflg   ,# ( 92)
           bocnum           like datmservicocmp.bocnum   ,# ( 93)
           bocemi           like datmservicocmp.bocemi   ,# ( 94)
           vicsnh           like datmservicocmp.vicsnh   ,# ( 95)
           sinhor           like datmservicocmp.sinhor   ,# ( 96)
           ## Grava datmsrvacp                            #
           atdsrvseq        like datmsrvacp.atdsrvseq    ,# ( 97)
           atdetpcod        like datmsrvacp.atdetpcod    ,# ( 98)
           atdetpdat        like datmsrvacp.atdetpdat    ,# ( 99)
           atdetphor        like datmsrvacp.atdetphor    ,# (100)
           empcod           like datmsrvacp.empcod       ,# (101)
           ## Local e Ocorrencia
           operacao         char (01)                    ,# (102)
           c24endtip        like datmlcl.c24endtip       ,# (103)
           lclidttxt        like datmlcl.lclidttxt       ,# (104)
           lgdtip           like datmlcl.lgdtip          ,# (105)
           lgdnom           like datmlcl.lgdnom          ,# (106)
           lgdnum           like datmlcl.lgdnum          ,# (107)
           lclbrrnom        like datmlcl.lclbrrnom       ,# (108)
           brrnom           like datmlcl.brrnom          ,# (109)
           cidnom           like datmlcl.cidnom          ,# (110)
           ufdcod           like datmlcl.ufdcod          ,# (111)
           lclrefptotxt     like datmlcl.lclrefptotxt    ,# (112)
           endzon           like datmlcl.endzon          ,# (113)
           lgdcep           like datmlcl.lgdcep          ,# (114)
           lgdcepcmp        like datmlcl.lgdcepcmp       ,# (115)
           lclltt           like datmlcl.lclltt          ,# (116)
           lcllgt           like datmlcl.lcllgt          ,# (117)
           lcldddcod        like datmlcl.dddcod          ,# (118)
           lcltelnum        like datmlcl.lcltelnum       ,# (119)
           lclcttnom        like datmlcl.lclcttnom       ,# (120)
           c24lclpdrcod     like datmlcl.c24lclpdrcod    ,# (121)
           lclofnnumdig     like datmlcl.ofnnumdig       ,# (122)
           emeviacod        like datmlcl.emeviacod       ,# (123)
           ## Grava tabela de Aviso de sinistro
           sinntzcod        like datmavssin.sinntzcod    ,# (124)
           eqprgicod        like datmavssin.eqprgicod    ,# (125)
           ctcdtnom         char(50)                     ,# (126)
           ctcgccpfnum      dec(12,0)                    ,# (127)
           ctcgccpfdig      dec(02,0)                    ,# (128)
           cdtseq           like aeikcdt.cdtseq           # (129

    end record

    define l_xml       char(32766)

    let l_xml = "<mq>",
                "<servico>","REGISTRASERVICOFURTOROUBO","</servico>",
                "<param>lr_param.ligdat</param>"      ,
                "<param>lr_param.lighorinc</param>"   ,
                "<param>lr_param.c24soltipcod</param>",
                "<param>lr_param.c24solnom</param>"   ,
                "<param>lr_param.c24astcod</param>"   ,
                "<param>lr_param.c24funmat</param>"   ,
                "<param>lr_param.ligcvntip</param>"   ,
                "<param>lr_param.c24paxnum</param>"   ,
                "<param>lr_param.atdsrvnum</param>"   ,
                "<param>lr_param.atdsrvano</param>"   ,
                "<param>lr_param.sinavsnum</param>"   ,
                "<param>lr_param.sinavsano</param>"   ,
                "<param>lr_param.succod</param>"      ,
                "<param>lr_param.ramcod</param>"      ,
                "<param>lr_param.aplnumdig</param>"   ,
                "<param>lr_param.itmnumdig</param>"   ,
                "<param>lr_param.edsnumref</param>"   ,
                "<param>lr_param.prporg</param>"      ,
                "<param>lr_param.prpnumdig</param>"   ,
                "<param>lr_param.fcapacorg</param>"   ,
                "<param>lr_param.fcapacnum</param>"   ,
                "<param>lr_param.sinramcod</param>"   ,
                "<param>lr_param.sinano</param>"      ,
                "<param>lr_param.sinnum</param>"      ,
                "<param>lr_param.sinitmseq</param>"   ,
                "<param>lr_param.caddat</param>"      ,
                "<param>lr_param.cadhor</param>"      ,
                "<param>lr_param.cademp</param>"      ,
                "<param>lr_param.cadmat</param>"      ,
                "<param>lr_param.vstsolnom</param>"   ,
                "<param>lr_param.vstsoltip</param>"   ,
                "<param>lr_param.vstsoltipcod</param>",
                "<param>lr_param.segnom</param>"      ,
                "<param>lr_param.subcod</param>"      ,
                "<param>lr_param.dddcod</param>"      ,
                "<param>lr_param.teltxt</param>"      ,
                "<param>lr_param.cornom</param>"      ,
                "<param>lr_param.corsus</param>"      ,
                "<param>lr_param.vcldes</param>"      ,
                "<param>lr_param.vclanomdl</param>"   ,
                "<param>lr_param.vcllicnum</param>"   ,
                "<param>lr_param.vclchsfnl</param>"   ,
                "<param>lr_param.sindat</param>"      ,
                "<param>lr_param.sinavs</param>"      ,
                "<param>lr_param.orcvlr</param>"      ,
                "<param>lr_param.ofnnumdig</param>"   ,
                "<param>lr_param.vstdat</param>"      ,
                "<param>lr_param.vstretdat</param>"   ,
                "<param>lr_param.vstretflg</param>"   ,
                "<param>lr_param.funmat</param>"      ,
                "<param>lr_param.atddat</param>"      ,
                "<param>lr_param.atdhor</param>"      ,
                "<param>lr_param.sinvstorgnum</param>",
                "<param>lr_param.sinvstorgano</param>",
                "<param>lr_param.sinvstsolsit</param>",
                "<param>lr_param.vclchsinc</param>"   ,
                "<param>lr_param.vclcorcod</param>"   ,
                "<param>lr_param.atdlibflg</param>"   ,
                "<param>lr_param.atdlibhor</param>"   ,
                "<param>lr_param.atdlibdat</param>"   ,
                "<param>lr_param.atdlclflg</param>"   ,
                "<param>lr_param.atdhorpvt</param>"   ,
                "<param>lr_param.atddatprg</param>"   ,
                "<param>lr_param.atdhorprg</param>"   ,
                "<param>lr_param.atdtip</param>"      ,
                "<param>lr_param.atdmotnom</param>"   ,
                "<param>lr_param.atdvclsgl</param>"   ,
                "<param>lr_param.atdprscod</param>"   ,
                "<param>lr_param.atdcstvlr</param>"   ,
                "<param>lr_param.atdfnlflg</param>"   ,
                "<param>lr_param.atdfnlhor</param>"   ,
                "<param>lr_param.atdrsdflg</param>"   ,
                "<param>lr_param.atddfttxt</param>"   ,
                "<param>lr_param.atddoctxt</param>"   ,
                "<param>lr_param.c24opemat</param>"   ,
                "<param>lr_param.nom</param>"         ,
                "<param>lr_param.cnldat</param>"      ,
                "<param>lr_param.pgtdat</param>"      ,
                "<param>lr_param.c24nomctt</param>"   ,
                "<param>lr_param.atdpvtretflg</param>",
                "<param>lr_param.atdvcltip</param>"   ,
                "<param>lr_param.asitipcod</param>"   ,
                "<param>lr_param.socvclcod</param>"   ,
                "<param>lr_param.vclcoddig</param>"   ,
                "<param>lr_param.srvprlflg</param>"   ,
                "<param>lr_param.srrcoddig</param>"   ,
                "<param>lr_param.atdprinvlcod</param>",
                "<param>lr_param.atdsrvorg</param>"   ,
                "<param>lr_param.c24sintip</param>"   ,
                "<param>lr_param.c24sinhor</param>"   ,
                "<param>lr_param.bocflg</param>"      ,
                "<param>lr_param.bocnum</param>"      ,
                "<param>lr_param.bocemi</param>"      ,
                "<param>lr_param.vicsnh</param>"      ,
                "<param>lr_param.sinhor</param>"      ,
                "<param>lr_param.atdsrvseq</param>"   ,
                "<param>lr_param.atdetpcod</param>"   ,
                "<param>lr_param.atdetpdat</param>"   ,
                "<param>lr_param.atdetphor</param>"   ,
                "<param>lr_param.empcod</param>"      ,
                "<param>lr_param.operacao</param>"    ,
                "<param>lr_param.c24endtip</param>"   ,
                "<param>lr_param.lclidttxt</param>"   ,
                "<param>lr_param.lgdtip</param>"      ,
                "<param>lr_param.lgdnom</param>"      ,
                "<param>lr_param.lgdnum</param>"      ,
                "<param>lr_param.lclbrrnom</param>"   ,
                "<param>lr_param.brrnom</param>"      ,
                "<param>lr_param.cidnom</param>"      ,
                "<param>lr_param.ufdcod</param>"      ,
                "<param>lr_param.lclrefptotxt</param>",
                "<param>lr_param.endzon</param>"      ,
                "<param>lr_param.lgdcep</param>"      ,
                "<param>lr_param.lgdcepcmp</param>"   ,
                "<param>lr_param.lclltt</param>"      ,
                "<param>lr_param.lcllgt</param>"      ,
                "<param>lr_param.lcldddcod</param>"   ,
                "<param>lr_param.lcltelnum</param>"   ,
                "<param>lr_param.lclcttnom</param>"   ,
                "<param>lr_param.c24lclpdrcod</param>",
                "<param>lr_param.lclofnnumdig</param>",
                "<param>lr_param.emeviacod</param>"   ,
                "<param>lr_param.sinntzcod</param>"   ,
                "<param>lr_param.eqprgicod</param>"   ,
                "<param>lr_param.ctcdtnom</param>"    ,
                "<param>lr_param.ctcgccpfnum</param>" ,
                "<param>lr_param.ctcgccpfdig</param>" ,
                "<param>lr_param.cdtseq</param>"      ,
         "</mq>"

    return l_xml

  end function

#------------------------------------------------------------------------------
function cta02m13_grava_dafmintsrv(param)
#------------------------------------------------------------------------------
 define param record
        atdsrvnum like datmservico.atdsrvnum,
        atdsrvano like datmservico.atdsrvano
 end record
 define ws    record
        vcldes    like datmservico.vcldes,
        vclcorcod like datmservico.vclcorcod,
        vclcordes like iddkdominio.cpodes,
        vclcoddig like datmservico.vclcoddig,
        vcllicnum like datmservico.vcllicnum,
        sindat    like datmservicocmp.sindat,
        sinhor    like datmservicocmp.sinhor,
        atddat    like datmservico.atddat ,
        atdhor    like datmservico.atdhor,
        lclltt    like datmlcl.lclltt,
        lcllgt    like datmlcl.lcllgt,
        succod    like datrservapol.succod,
        ramcod    like datrservapol.ramcod,
        aplnumdig like datrservapol.aplnumdig,
        itmnumdig like datrservapol.itmnumdig,
        edsnumref like datrservapol.edsnumref,
        vclchsinc like abbmveic.vclchsinc,
        vclchsfnl like abbmveic.vclchsfnl,
        vclchsnum char (20),
        segnumdig like gsakseg.segnumdig,
        segnom    like gsakseg.segnom,
        cgccpfnum like gsakseg.cgccpfnum,
        cgcord    like gsakseg.cgcord,
        cgccpfdig like gsakseg.cgccpfdig,
        lignum    like datmligacao.lignum,
        prporg    like datrligprp.prporg,
        prpnumdig like datrligprp.prpnumdig,
        c24astcod like datmligacao.c24astcod
 end record

 initialize ws.*  to null

 ------------------[ busca dados do servico e cor veiculo ]-------------------
 select vclcoddig, vcldes   ,
        vcllicnum, vclcorcod,
        atddat   , atdhor
   into ws.vclcoddig,
        ws.vcldes   ,
        ws.vcllicnum,
        ws.vclcorcod        ,
        ws.atddat           ,
        ws.atdhor
   from datmservico
  where atdsrvnum = param.atdsrvnum  and
        atdsrvano = param.atdsrvano

 select cpodes
   into ws.vclcordes
   from iddkdominio
  where cponom = "vclcorcod"  and
        cpocod = ws.vclcorcod
 --------------------[ busca latitude e longitude ]-----------------
 select lclltt,
        lcllgt
   into ws.lclltt,
        ws.lcllgt
   from datmlcl
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano
    and c24endtip = 1
 --------------------[ busca numero da apolice ou proposta ]-----------------
 select succod   ,
        ramcod   ,
        aplnumdig,
        itmnumdig,
        edsnumref
   into ws.succod   ,
        ws.ramcod   ,
        ws.aplnumdig,
        ws.itmnumdig,
        ws.edsnumref
   from datrservapol
  where atdsrvnum = param.atdsrvnum and
        atdsrvano = param.atdsrvano

  if ws.aplnumdig is null then
     call cts20g00_servico(param.atdsrvnum,
                           param.atdsrvano)
          returning ws.lignum
     select prporg,
            prpnumdig
       into ws.prporg,
            ws.prpnumdig
       from datrligprp
      where lignum = ws.lignum
  end if
 -----------------------[ busca data e hora do aviso de sinistro ]------------
 select sindat   ,
        sinhor
   into ws.sindat   ,
        ws.sinhor
   from datmservicocmp
  where atdsrvnum = param.atdsrvnum and
        atdsrvano = param.atdsrvano
 -----------------------[ busca chassi do veiculo ]--------------------------
 select vclchsinc,
        vclchsfnl
   into ws.vclchsinc,
        ws.vclchsfnl
   from abbmveic
  where succod    = ws.succod      and
        aplnumdig = ws.aplnumdig   and
        itmnumdig = ws.itmnumdig   and
        dctnumseq = (select max(dctnumseq)
                             from abbmveic
                            where succod    = ws.succod      and
                                  aplnumdig = ws.aplnumdig   and
                                  itmnumdig = ws.itmnumdig)
  let ws.vclchsnum = ws.vclchsinc clipped, ws.vclchsfnl clipped
  ------------------------[ busca dados do segurado ]-------------------------
  select segnumdig
    into ws.segnumdig
    from abbmdoc
   where succod    = ws.succod    and
         aplnumdig = ws.aplnumdig and
         itmnumdig = ws.itmnumdig and
         dctnumseq = g_funapol.dctnumseq

  select segnom,cgccpfnum,
         cgcord,cgccpfdig
    into ws.segnom   ,
         ws.cgccpfnum,
         ws.cgcord   ,
         ws.cgccpfdig
    from gsakseg
   where segnumdig  =  ws.segnumdig

   -------------[ funcao de interface com sistema daf ]------------------
   call cty13g00("",                    # Fim Integração       |excfnl
                 "",                    # Codigo Erro          |errcod
                 "",                    # Descrição Erro       |errdsc
                 "",                    # Codigo Dispositivo   |discoddig
                 ws.lclltt,             # Latitude             |sinlclltt
                 ws.lcllgt,             # Longitude            |sinlcllgt
                 param.atdsrvnum,       # Número Atendimento   |atdsrvnum
                 param.atdsrvano,       # Ano Atendimento      |atdsrvano
                 ws.vclcoddig,          # Codigo Veículo       |vclcoddig
                 ws.vcldes,             # Descricao Veículo    |vcldes
                 ws.vcllicnum,          # Placa Veículo        |vcllicnum
                 "F10",
                 ws.vclchsnum,          # Número Chassi        |vclchscod
                 ws.segnom,             # Nome Segurado        |segnom
                 ws.sindat,             # Data Sisnistro       |sindat
                 ws.sinhor,             # Data Comunicado      |cincmudat
                 ws.atddat,             # Data Cadastro        |caddat
                 "",                    # Importancia Segurada |imsvlr
                 "",                    # Resumo do Sinistro   |sinres
                 "",                    # Ticket de Entrega    |enttck
                 ws.succod,             # Codigo Sucursal      |succod
                 ws.aplnumdig,          # Número Apólice       |aplnumdig
                 ws.itmnumdig,          # Item Apólice         |itmnumdig
                 "",                    # Seq Número Docto     |dctnumseq
                 ws.edsnumref,          # Número Endosso       |edsnumdig
                 ws.prporg,             # Origem Proposta      |prporgpcp
                 ws.prpnumdig,          # Número Proposta      |prpnumpcp
                 ws.cgccpfnum,          # Número CGC/CPF       |cgccpfnum
                 ws.cgcord,             # Ordem CGC            |cgcord
                 ws.cgccpfdig,          # Dígito CGC/CPF       |cgccpfdig
                 ws.vclcordes,          # Descrição cor Veículo|vclcordsc
                 "",                    # Nome Condutor        |cdtnom
                 "",                    # Número Tentativas    |itgttvnum
                 "cta02m13")            # Programa chamador   ---> Ruiz/Camila
end function

#-----------------------------------------------------------------------------
function cta02m13_informa_placa_chassi()
#-----------------------------------------------------------------------------
   define ws   record
          vclchsinc       like datmsinatditf.vclchsinc,
          vclchsfnl       like datmsinatditf.vclchsfnl
   end record
   define lr_input record
          vcllicnum       like datmsinatditf.vcllicnum,
          chassi          char (20)
   end record

   initialize lr_input.*,
              ws.*        to null

   open window w_cta02m13b at 9,35 with form "cta02m13b"
              attribute(border, form line 1)

   input by name lr_input.vcllicnum,
                 lr_input.chassi without defaults

      before field vcllicnum
        display by name lr_input.vcllicnum attribute(reverse)

      after field vcllicnum
        display by name lr_input.vcllicnum

        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           next field vcllicnum
        end if
        if lr_input.vcllicnum is not null then
           exit input
        end if

      before field chassi
        display by name lr_input.chassi attribute(reverse)

      after field chassi
        display by name lr_input.chassi

        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           next field vcllicnum
        end if
        if lr_input.vcllicnum is null and
           lr_input.chassi    is null then
           error "Placa ou Chassi deve ser informado"
           next field vcllicnum
        end if

       on key (interrupt)
         if lr_input.vcllicnum is null and
            lr_input.chassi    is null then
            error "Placa ou Chassi deve ser informado!"
            next field vcllicnum
         end if
         exit input
   end input
   if lr_input.chassi is not null then
      let ws.vclchsinc = lr_input.chassi[1,12]
      let ws.vclchsfnl = lr_input.chassi[13,20]
   end if
   close window w_cta02m13b
   let int_flag = false

   return lr_input.vcllicnum,
          ws.vclchsinc,
          ws.vclchsfnl
end function


#--------------------------------------------#
function cta02m13_gera_integracao(lr_param)
#--------------------------------------------#
#ruiz
   define lr_param record
          ligdat        like datmsinatditf.ligdat
         ,lighor        datetime hour to second
         ,vcllicnum     like abbmveic.vcllicnum
         ,vclchsinc     like abbmveic.vclchsinc
         ,vclchsfnl     like abbmveic.vclchsfnl
         ,corsus        like gcaksusep.corsus
         ,lignum        like datmligacao.lignum
         ,atdsrvnum     like datmservico.atdsrvnum
   end record

   define lr_retorno    record
          sttatendi     char(01)
         ,matranali     like datmligacao.c24funmat
         ,nomeanali     like isskfunc.funnom
         ,foneanali     like datmligacao.c24paxnum
         ,msg           char(32766)
         ,param         char(2000)
         ,coderro       dec(1,0)
         ,msgerro       char(1000)
   end record

   define l_retxml      char(32000)
         ,l_cgccpfnum   like gsakseg.cgccpfnum
         ,l_cgcord      like gsakseg.cgcord
         ,l_cgccpfdig   like gsakseg.cgccpfdig
         ,l_pestip      like gsakseg.pestip
         ,l_segnumdig   like abbmdoc.segnumdig
         ,l_dctnumseq   like abbmdoc.dctnumseq
         ,l_clalclcod   like abbmdoc.clalclcod
         ,l_aviso       smallint
         ,l_cgccpf      char(18)
         ,l_online      smallint
         ,retorno       char(500)
         ,l_succod      like datrligapol.succod
         ,l_ramcod      like datrligapol.ramcod
         ,l_aplnumdig   like datrligapol.aplnumdig
         ,l_itmnumdig   like datrligapol.itmnumdig
         ,l_edsnumref   like datrligapol.edsnumref
         ,l_corlidflg   like abamcor.corlidflg
         ,l_remetente   char(50)
         ,l_assunto     char(50)
         ,l_para        char(1000)
         ,l_comando     char(32766)
         ,l_status      smallint
         ,l_ambiente    char(08)

   define l_retorno record
          coderro       smallint
         ,menserro      char(30)
         ,mensagemRet   char(32766)
   end record
   define l_aux record
          nom               like datmservico.nom,
          corsus            like gcaksusep.corsus,
          cornom            like gcakcorr.cornom,
          cvnnom            char (19)           ,
          vclcoddig         like datmservico.vclcoddig   ,
          vcldes            like datmservico.vcldes      ,
          vclanomdl         like datmservico.vclanomdl   ,
          vcllicnum         like datmservico.vcllicnum   ,
          vclcordes         char (11)
   end record
   define l_docHandle   integer
   define l_temErro     char(100)

   let l_online     = 0
   let l_retxml     = null
   let l_cgccpfnum  = null
   let l_cgcord     = null
   let l_cgccpfdig  = null
   let l_pestip     = null
   let l_segnumdig  = null
   let l_dctnumseq  = null
   let l_clalclcod  = null
   let l_aviso      = 0
   let l_cgccpf     = null
   let l_corlidflg  = "S"
   let l_succod     = null
   let l_ramcod     = null
   let l_aplnumdig  = null
   let l_itmnumdig  = null
   let l_edsnumref  = null
   let l_remetente  = null
   let l_assunto    = null
   let l_para       = null
   let l_comando    = null
   let l_status     = null
   let l_ambiente   = null

   initialize lr_retorno.*
             ,l_retorno.*
             ,l_docHandle
             ,l_temErro
             ,l_aux  to null

   let l_online = online()

   if m_cta02m13_prep is null or
      m_cta02m13_prep <> true then
      call cta02m13_prepare()
   end if
   let l_succod     =  g_documento.succod
   let l_ramcod     =  g_documento.ramcod
   let l_aplnumdig  =  g_documento.aplnumdig
   let l_itmnumdig  =  g_documento.itmnumdig
   let l_edsnumref  =  g_documento.edsnumref

   if lr_param.vcllicnum is null and
      lr_param.vclchsinc is null then
      let l_aviso = 0
      open c_cta02m13_003 using g_documento.succod
                             ,g_documento.aplnumdig
                             ,l_corlidflg
      whenever error continue
      fetch c_cta02m13_003 into lr_param.corsus
      whenever error stop
      if sqlca.sqlcode <> 0 and
         sqlca.sqlcode <> notfound then
         let lr_param.corsus = null
      end if

   else  #  sem apolice
      let l_aviso = 1
      let l_segnumdig = 0
      let l_dctnumseq = 0
      let l_clalclcod = 0
      let l_cgccpf    = 0
      let l_ramcod    = 531
      let l_succod    = 0
      let l_aplnumdig = 0
      let l_itmnumdig = 0
      let l_edsnumref = 0
      let l_pestip    = "F"
   end if
   if l_aviso = 0 then
      open c_cta02m13_001 using l_succod
                             ,l_aplnumdig
                             ,l_itmnumdig
      whenever error continue
      fetch c_cta02m13_001 into l_segnumdig
                             ,l_dctnumseq
                             ,l_clalclcod
      whenever error stop
      if sqlca.sqlcode <> 0 and
         sqlca.sqlcode <> notfound then
         let l_segnumdig = null
         let l_dctnumseq = null
         let l_clalclcod = null
      end if

      open c_cta02m13_002 using l_segnumdig
      whenever error continue
      fetch c_cta02m13_002 into l_cgccpfnum
                             ,l_cgcord
                             ,l_cgccpfdig
                             ,l_pestip
      whenever error stop
      if sqlca.sqlcode <> 0 and
         sqlca.sqlcode <> notfound then
         let l_cgccpfnum = null
         let l_cgcord    = null
         let l_cgccpfdig = null
         let l_pestip    = null
      end if
      let l_cgccpf = l_cgccpfnum using '<<<<<<<<<<<<'
                    ,l_cgcord using '<<<<'
                    ,l_cgccpfdig using '<<'

      select vclchsinc,
             vclchsfnl
        into lr_param.vclchsinc,
             lr_param.vclchsfnl
        from abbmveic
       where succod    = l_succod      and
             aplnumdig = l_aplnumdig   and
             itmnumdig = l_itmnumdig   and
             dctnumseq = (select max(dctnumseq)
                                  from abbmveic
                                 where succod    = l_succod    and
                                       aplnumdig = l_aplnumdig and
                                       itmnumdig = l_itmnumdig)
       call cts05g00 (l_succod       ,
                      l_ramcod       ,
                      l_aplnumdig    ,
                      l_itmnumdig    )
            returning l_aux.nom      ,
                      l_aux.corsus   ,
                      l_aux.cornom   ,
                      l_aux.cvnnom   ,
                      l_aux.vclcoddig,
                      l_aux.vcldes   ,
                      l_aux.vclanomdl,
                      lr_param.vcllicnum,
                      lr_param.vclchsinc,
                      lr_param.vclchsfnl,
                      l_aux.vclcordes
   end if

   let lr_retorno.param = "Parametros enviados para Servico MQ ", "\n",
     "empresaAtualizacao........... = ",g_issk.empcod            clipped, "\n",
     "tipoUsuarioAtualizacao....... = ",g_issk.usrtip            clipped, "\n",
     "matriculaAtualizacao......... = ",g_issk.funmat            clipped, "\n",
     "nomeAtendente................ = ",g_issk.funnom            clipped, "\n",
     "codigoSucursal............... = ",l_succod                 clipped, "\n",
     "digitoENumeroApolice......... = ",l_aplnumdig              clipped, "\n",
     "codigoInformanteCentral...... = ",g_documento.c24soltipcod clipped, "\n",
     "numeroLigacao................ = ",lr_param.lignum          clipped, "\n",
     "numeroPedidoVistoriaSinistro. = ",lr_param.atdsrvnum       clipped, "\n",
     "dataLigacao.................. = ",lr_param.ligdat          clipped, "\n",
     "horarioLigacao............... = ",lr_param.lighor          clipped, "\n",
     "descricaoAssuntoAtendimento.. = ",g_documento.c24astcod    clipped, "\n",
     "codigoRamo................... = ",l_ramcod                 clipped, "\n",
     "digitoENumeroItem............ = ",l_itmnumdig              clipped, "\n",
     "numeroEndosso................ = ",l_edsnumref              clipped, "\n",
     "numeroSequenciaDocumento..... = ",l_dctnumseq              clipped, "\n",
     "numeroLicencaVeiculoPlacas... = ",lr_param.vcllicnum       clipped, "\n",
     "parteInicialNumeroChassi..... = ",lr_param.vclchsinc       clipped, "\n",
     "parteFinalNumeroChassi....... = ",lr_param.vclchsfnl       clipped, "\n",
     "numeroEDigitoCgcCpfSegurado.. = ",l_cgccpf                 clipped, "\n",
     "seguradoTipoPessoa........... = ",l_pestip                 clipped, "\n",
     "susepCorretor................ = ",lr_param.corsus          clipped, "\n",
     "avisoSemApolice.............. = ",l_aviso                  clipped, "\n",
     "codigoClasseLocalizacao...... = ",l_clalclcod              clipped, "\n",
     "sucursalMatricula............ = ",g_issk.succod            clipped, "\n",
     "siglaDepartamento............ = ",g_issk.dptsgl            clipped, "\n",
     "tipoPerda.................... = ", ""                      clipped, "\n"

   error "* ATENCAO, pesquisando transferencia da ligacao............"

   call figrc010_inicio_doc() # Inicializa

      call figrc010_inicio_integracao(
        "F10",                                       # Nome integracao
        "CLASS",                                     # Tipo objeto Java
        "com.porto.sinistro.integracaoavisosinistrows.util.BPELConnector",
                                                     # Classe
        " ")                                         # nome jndi
         call figrc010_inicio_metodo("enviarProcessoBPEL")  # nome do metodo

         call figrc010_inicio_parametro_vo("AtendimentoVO","com.porto.sinistro.integracaoavisosinistrows.common.AtendimentoVO")
         call figrc010_add_parametro_vo_attr("empresaAtualizacao"           ,g_issk.empcod            )
         call figrc010_add_parametro_vo_attr("tipoUsuarioAtualizacao"       ,g_issk.usrtip            )
         call figrc010_add_parametro_vo_attr("matriculaAtualizacao"         ,g_issk.funmat            )
         call figrc010_add_parametro_vo_attr("nomeAtendente"                ,g_issk.funnom            )
         call figrc010_add_parametro_vo_attr("codigoSucursal"               ,l_succod       )
         call figrc010_add_parametro_vo_attr("digitoENumeroApolice"         ,l_aplnumdig    )
         call figrc010_add_parametro_vo_attr("codigoInformanteCentral"      ,g_documento.c24soltipcod )
         call figrc010_add_parametro_vo_attr("numeroLigacao"                ,lr_param.lignum          )
         call figrc010_add_parametro_vo_attr("numeroPedidoVistoriaSinistro" ,lr_param.atdsrvnum       )
         call figrc010_add_parametro_vo_attr("dataLigacao"                  ,lr_param.ligdat          )
         call figrc010_add_parametro_vo_attr("horarioLigacao"               ,lr_param.lighor          )
         call figrc010_add_parametro_vo_attr("descricaoAssuntoAtendimento"  ,g_documento.c24astcod    )
         call figrc010_add_parametro_vo_attr("codigoRamo"                   ,l_ramcod       )
         call figrc010_add_parametro_vo_attr("digitoENumeroItem"            ,l_itmnumdig    )
         call figrc010_add_parametro_vo_attr("numeroEndosso"                ,l_edsnumref    )
         call figrc010_add_parametro_vo_attr("numeroSequenciaDocumento"     ,l_dctnumseq              )
         call figrc010_add_parametro_vo_attr("numeroLicencaVeiculoPlacas"   ,lr_param.vcllicnum       )
         call figrc010_add_parametro_vo_attr("parteInicialNumeroChassi"     ,lr_param.vclchsinc       )
         call figrc010_add_parametro_vo_attr("parteFinalNumeroChassi"       ,lr_param.vclchsfnl       )
         call figrc010_add_parametro_vo_attr("numeroEDigitoCgcCpfSegurado"  ,l_cgccpf                 )
         call figrc010_add_parametro_vo_attr("seguradoTipoPessoa"           ,l_pestip                 )
         call figrc010_add_parametro_vo_attr("susepCorretor"                ,lr_param.corsus          )
         call figrc010_add_parametro_vo_attr("avisoSemApolice"              ,l_aviso                  )
         call figrc010_add_parametro_vo_attr("codigoClasseLocalizacao"      ,l_clalclcod              )
         call figrc010_add_parametro_vo_attr("sucursalMatricula"            ,g_issk.succod            )
         call figrc010_add_parametro_vo_attr("siglaDepartamento"            ,g_issk.dptsgl            )
         call figrc010_add_parametro_vo_attr("tipoPerda"                    , "")
         call figrc010_fim_parametro_vo()

         call figrc010_fim_metodo()                       # finaliza metodo

      call figrc010_fim_integracao()

   call figrc010_fim_doc()                                # finaliza

   -----[alterado para esta chamada em 23/11/07 - Estela/Marcio ]------
   call  figrc010_executa3(15, online(), "INTEGRA4.4GL.JAVA")
        returning l_retorno.coderro,
                  l_retorno.menserro,
                  l_retorno.mensagemRet
   let l_retorno.menserro = cta02m13_limparetmsg(l_retorno.menserro)
   let lr_retorno.msg = lr_retorno.msg clipped," ",
       "** RETORNO DA FUNCAO figrc010_executa3 ** \n" clipped,
       "   Cod.Erro = ",l_retorno.coderro     clipped, "\n",
       "   Msg.Erro = ",l_retorno.menserro    clipped, "\n",
       "   Data     = ",current                      , "\n",
       "   Msg.Ret  = ",l_retorno.mensagemRet clipped, "\n","\n"
   if l_retorno.coderro <> 0 then
      let lr_retorno.coderro = 1
      if l_retorno.coderro = 2033  then
         error "ERRO - Aplicacao Java fora do ar, erro 2033 "  sleep 3
      else
         error "ERRO FATAL ..." sleep 3
      end if
      return lr_retorno.*
   end if
   #-- inicializa operacao de parse
   call figrc011_fim_parse()
   call figrc011_inicio_parse()

   #-- efetua o parse do retorno.
   let l_docHandle = figrc011_parse(l_retorno.mensagemRet clipped)

   # trata erro fatal na operacao
   let l_temErro      = figrc010_tem_erro_fatal(l_docHandle)
   let lr_retorno.msg = lr_retorno.msg clipped," ",
       "** RETORNO DA FUNCAO figrc010_tem_erro_fatal ** \n" clipped,
       "   Cod.Erro = ",l_temErro     clipped, "\n",
       "   Data     = ",current, "\n","\n"
   if l_temErro is not null and l_temErro <> " " then
      error "ERRO FATAL, metodo(figrc010_tem_erro_fatal)" sleep 3
      call figrc011_fim_parse()
      let lr_retorno.coderro = 1
      return lr_retorno.*
   end if

   # Trata erro do metodo solicitado.
   let l_temErro = figrc010_tem_erro_servico(l_docHandle, # id xml recuperado
                                                   "F10", # nome da integragco
                                    "enviarProcessoBPEL") # nome do metodo
   let lr_retorno.msg = lr_retorno.msg clipped," ",
       "** RETORNO DA FUNCAO figrc010_tem_erro_servico ** \n" clipped,
       "   Cod.Erro = ",l_temErro     clipped, "\n",
       "   Data     = ",current, "\n"
   if l_temErro is not null and l_temErro <> " " then
      error "ERRO de execucao, metodo(figrc010_tem_erro_servico)" sleep 3
      call figrc011_fim_parse()
      let lr_retorno.coderro = 1
      return lr_retorno.*
   end if

   -----[ realiza parse das informacoes ]-----
   let lr_retorno.coderro   = figrc011_xpath(l_docHandle, "/Retorno/F10/enviarProcessoBPEL/TransferenciaVO/codigoErro")
   let lr_retorno.msgerro   = figrc011_xpath(l_docHandle, "/Retorno/F10/enviarProcessoBPEL/TransferenciaVO/mensagemErro")
   let lr_retorno.matranali = figrc011_xpath(l_docHandle, "/Retorno/F10/enviarProcessoBPEL/TransferenciaVO/analista")
   let lr_retorno.nomeanali = figrc011_xpath(l_docHandle, "/Retorno/F10/enviarProcessoBPEL/TransferenciaVO/nomeAnalista")
   let lr_retorno.foneanali = figrc011_xpath(l_docHandle, "/Retorno/F10/enviarProcessoBPEL/TransferenciaVO/ramal")
   let lr_retorno.sttatendi = figrc011_xpath(l_docHandle, "/Retorno/F10/enviarProcessoBPEL/TransferenciaVO/transfereAtendimento")


   call figrc011_fim_parse()

   return lr_retorno.*

end function

#---------------------------------------------------------------------------
function cta02m13_limparetmsg(mensagem)
#---------------------------------------------------------------------------
   define mensagem char(30)
   define i smallint
   for i = 1 to 30
     if ascii(mensagem [i]) < 48 or ascii(mensagem [i]) > 122 then
        let mensagem [i] = " "
     end if
   end for
   return mensagem

end function

#---------------------------------------------------------------------------
function cta02m13_acesso_replicacao(lr_param)
#---------------------------------------------------------------------------

define lr_param record
   succod       like abbmveic.succod        ,
   aplnumdig    like abbmveic.aplnumdig     ,
   c24astcod    like datkassunto.c24astcod  ,
   funmat       like isskfunc.funmat
end record

define lr_retorno record
       cponom1  like datkdominio.cponom ,
       cponom2  like datkdominio.cponom ,
       cpodes   like datkdominio.cpodes ,
       replica1 smallint                ,
       replica2 smallint                ,
       qtd      smallint
end record

initialize lr_retorno.* to null

      if m_cta02m13_prep is null or
         m_cta02m13_prep <> true then
         call cta02m13_prepare()
      end if

      let lr_retorno.cponom1  = "assunto_replica"
      let lr_retorno.cponom2  = "matricula_replica"
      let lr_retorno.replica1 = false
      let lr_retorno.replica2 = false


      # Verifica se o Assunto tem Permissao para Replicar

      open ccta02m13007 using lr_retorno.cponom1

      foreach ccta02m13007 into lr_retorno.cpodes

        if lr_param.c24astcod = lr_retorno.cpodes then

             let lr_retorno.replica1 = true
             exit foreach
        end if
      end foreach

      close ccta02m13007

      # Verifica se o Atendente tem Permissao para Replicar

      open ccta02m13007 using lr_retorno.cponom2

      foreach ccta02m13007 into lr_retorno.cpodes

        if lr_param.funmat = lr_retorno.cpodes then

             let lr_retorno.replica2 = true
             exit foreach
        end if
      end foreach

      close ccta02m13007

      if  lr_retorno.replica1 and
          lr_retorno.replica2 then

          # Recupera a Quantidade de Itens da Apolice

          if g_documento.ciaempcod = 84 then

            call cta00m30_recupera_qtd(g_documento.itaciacod   ,
                                       g_doc_itau[1].itaramcod ,
                                       lr_param.aplnumdig      ,
                                       g_doc_itau[1].aplseqnum )
            returning lr_retorno.qtd

          else

            call cta00m21_recupera_qtd(lr_param.succod    ,
                                       lr_param.aplnumdig )
            returning lr_retorno.qtd

          end if

          if lr_retorno.qtd > 1 then

                 if cts08g01("C","S","DESEJA REPLICAR ",
                             "AS ADVERTENCIAS ?",
                             "",
                             "") = "S"  then

                     return true
                 end if
          end if

      end if


      return false

end function

#----------------------------------------------------------------------
function cta02m13_men()
#----------------------------------------------------------------------

  define ws record
      ret     integer,
      espera  char(1)
  end record

  define l_msg char(100)

  open window w_cta02m13c at 11,19 with form "cta02m13c"
        attribute(border, form line 1)

  display m_texto1 to texto1
  display m_texto2 to texto2

  input by name ws.espera

     after field espera
        next field espera

     on key(f17, control-c, interrupt)
        exit input

     on key(F1)
        call cta01m10_funcoes(g_documento.ramcod
                             ,g_documento.succod
                             ,g_documento.aplnumdig
                             ,g_documento.itmnumdig
                             ,g_documento.prporg
                             ,g_documento.prpnumdig
                             ,g_ppt.cmnnumdig
                             ,g_ppt.segnumdig
                             ,g_documento.cgccpfnum
                             ,g_documento.cgcord
                             ,g_documento.cgccpfdig
                             ,g_documento.ligcvntip
                             ,"" ---> l_param.dctnumseg
                             ,g_documento.crtsaunum)

  end input

  close window w_cta02m13c

  let int_flag = false

  return

end function

#-----------------------------------------#
 function cta02m13_furto_roubo(lr_cta02m1303)  #SA__260142_1
#-----------------------------------------#

define lr_cta02m1303   record
   prgcod              like datkassunto.prgcod
  ,atdsrvorg           like datmservico.atdsrvorg
  ,aplflg              char(01)
  ,docflg              char(01)
  ,webrlzflg           like datkassunto.webrlzflg
end record


define l_null          char(01)
define l_ret           smallint

 ## CT 303208
 ## alberto
 define l_cmd char(500)

 define l_mens record
          msg char(200)
         ,de char(50)
         ,subject char(100)
         ,para char(100)
         ,cc char(100)
       end record

 define l_today date
 define l_hora datetime hour to second

 define l_ant_aplnumdig like abamapol.aplnumdig

  define lr_numeracao record
         lignum       like datmligacao.lignum,
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano,
         sqlcode      integer,
         msg          char(80)
  end record

  define l_sttweb       like datmagnwebsrv.sttweb,
         l_status       smallint,
         l_ligorgcod    like datmagnwebsrv.ligorgcod,
         l_abnwebflg    like datmagnwebsrv.abnwebflg,
         l_ligasscod    like datmagnwebsrv.ligasscod,
         l_vstagnnum    like datmagnwebsrv.vstagnnum,
         l_vstagnstt    like datmagnwebsrv.vstagnstt,
         l_orgvstagnnum like datmagnwebsrv.orgvstagnnum,
         l_data_lig     date,
         l_c24astcod    like datmligacao.c24astcod,
         l_atencao      char(01),
         l_hora_lig     datetime hour to minute,
         l_horas_lig    datetime hour to second,
         l_tabname      char(30),
         l_sqlcode      integer,
         l_cornom       like gcakcorr.cornom,
         l_corsus       like gcaksusep.corsus,
         l_vcllicnum    like datmsinatditf.vcllicnum,
         l_vclchsinc    like datmsinatditf.vclchsinc,
         l_vclchsfnl    like datmsinatditf.vclchsfnl,
         l_corlidflg    like abamcor.corlidflg,
         l_ambiente     char(08)

  ## Alberto

  define ret_param_msg char(50)

  define l_ctq00m01_ret   record
         err         smallint,
         msg         char(80),
         lignum      like datmligacao.lignum,
         atdsrvnum   like datmservico.atdsrvnum,
         atdsrvano   like datmservico.atdsrvano
  end record

  define lr_retorno  record
         sttatendi   char(01)
        ,matranali   like datmligacao.c24funmat
        ,nomeanali   like isskfunc.funnom
        ,foneanali   like datmligacao.c24paxnum
        ,msg         char(32766)
        ,param       char(2000)
        ,coderro     dec(1,0)
        ,msgerro     char(1000)
  end record
  define l_hist      record
         tipgrv      smallint,
         lignum      like datmlighist.lignum,
         c24funmat   like datmlighist.c24funmat,
         ligdat      like datmlighist.ligdat,
         lighorinc   like datmlighist.lighorinc,
         c24ligdsc   like datmlighist.c24ligdsc
  end record
  define l_retorno   record
         tabname     like systables.tabname,
         sqlcode     integer
  end record
  define l_ok        smallint
  define l_matratend like datmligacao.c24funmat
  define l_funnomatd like isskfunc.funnom
  define l_motrecusa smallint
  define l_funmat    like datmligacao.c24funmat
  define l_sinatdsit char(01)
  define l_trfhor    interval hour to second
  define l_cpodes    like iddkdominio.cpodes
  define l_remetente char(50)
  define l_assunto   char(50)
  define l_para      char(1000)
  define l_comando   char(32766)
  define l_maquina   char(10)
  define l_maqsgl    char(10)
  define l_u11       char(1)
  define l_alt_assunto smallint
  define r_c24astcod   like datkassunto.c24astcod
  define l_ciaempcod_slv like datmligacao.ciaempcod

  define l_liberadoN10 char(01) # verificar se liberado todo atendente na WEB - N10/N11 = "S"
                                # 20/01/2009



   # inibir o 'IF', todos atendentes acessam a web - 22/10/08 Neia --
        #if cta02m13_acesso_web(g_issk.funmat) and
         if lr_cta02m1303.webrlzflg = "S"      then
            # --> BUSCA A DATA E HORA DO BANCO
            call cts40g03_data_hora_banco(2)
                 returning l_data_lig, l_hora_lig
            let l_horas_lig = current
            if lr_cta02m1303.aplflg = "N" then    # atd. sem documento
               call cta02m13_informa_placa_chassi()
                    returning l_vcllicnum,
                              l_vclchsinc,
                              l_vclchsfnl
            end if
            let l_funmat    = g_issk.funmat
            let l_sinatdsit = "A"
            let l_sttweb    = "A"
            #--- psi 205745 - Gera integracao
            #-- Busca Corsus
            if m_cta02m13_prep is null or
               m_cta02m13_prep <> true then
               call cta02m13_prepare()
            end if
            call cts10g03_numeracao(2, "5")
                 returning lr_numeracao.lignum,
                           lr_numeracao.atdsrvnum,
                           lr_numeracao.atdsrvano,
                           lr_numeracao.sqlcode,
                           lr_numeracao.msg

            call cta02m13_grava_transicao
                (g_issk.empcod           , # atlemp       Empresa Atendente
                 l_funmat                , # atlmat       Matricula Atendente
                 "F"                     , # atlusrtip    Tipo Usuario
                 g_documento.c24astcod   , # c24astcod    codigo do Assunto
                 "ROUBO"                 , # sinntzdes    Descrição da natureza
                 30                      , # sinntzcod    Código natureza
                 g_documento.solnom      , # sinifrnom    Nome do informante
                 g_documento.c24soltipcod, # c24soltipcod Tipo de informante
                 l_data_lig              , # ligdat       Data da ligação
                 l_hora_lig              , # lighor       Hora da ligação
                 g_issk.empcod           , # empcod       empresa
                 g_documento.succod      , # succod       Sucursal
                 g_documento.ramcod      , # ramcod       Ramo
                 g_documento.aplnumdig   , # aplnumdig    Apolice
                 g_documento.itmnumdig   , # itmnumdig    Item
                 g_documento.ligcvntip   , # ligcvntip    Codigo convenio
                 g_c24paxnum             , # c24paxnum    Número da PA
                 lr_numeracao.lignum     , # lignum       Número atendimento
                 l_sinatdsit             , # sinatdsit    Status do atendimento
                 l_vcllicnum             , # placa para atd. sem docto
                 l_vclchsinc             , # chassi inicial p/ atd. sem docto
                 l_vclchsfnl             , # chassi final   p/ atd. sem docto
                 g_documento.prporg      , #
                 g_documento.prpnumdig   , #
                 g_documento.dddcod      , # dddcod p/ ligacao s/docto
                 g_documento.ctttel      , # telefone p/ ligacao s/docto
                 1                       , # empcod
                 g_documento.funmat      , # matricula p/ ligacao s/docto
                 "F"                     , # usrtip
                 g_documento.cgccpfnum   , # cgc e cpf p/ ligacao s/docto
                 g_documento.cgcord      , # ordem cgc p/ligacao s/docto
                 g_documento.cgccpfdig   , # digito cgc cpf p/ligacao s/docto
                 g_documento.corsus      , # susep p/ ligacao s/ docto
                 l_motrecusa             , # motivo da recusa
                 l_trfhor                ) # intervalo de horas
            returning l_ok

            if not l_ok then
               return l_ok, 0
            end if

            # ---> ATENDIMENTO SENDO REALIZADO VIA WEB

            #if lr_retorno.sttatendi = 'S' and
            #   l_motrecusa is null then
            #else
               while l_sttweb = "A"

                  # ---> EXIBE A MENSAGEM PARA O USUARIO

                  initialize m_texto1, m_texto2 to null

                  let m_texto1 = "PRESSIONE ALT+TAB PARA PREENCHER"
                  let m_texto2 = "O AVISO FURTO/ROUBO NA WEB... "

                  ---> Abre tela de Aviso com Atalho F1-Funcoes
                  call cta02m13_men()

                  # ---> BUSCA O STATUS DE RETORNO DA WEB
                  call cta02m13_pesq_transicao( g_issk.empcod ,
                                                g_issk.funmat ,
                                                g_documento.c24astcod)
                       returning l_sttweb, l_ctq00m01_ret.lignum
                # impedir a liberacao do terminal Informix, ate que o motivo da
                # nao transferencia seja preenchido no Aviso Web, ou, que o
                # atendente informe no Aviso Web que a ligagco foi de fato
                # transferida.  11/07/07 - Marcelo Garcia/Ruiz
                  if l_sttweb = "T" then  # nao liberar o terminal
                     let l_sttweb = "A"
                  end if
               end while
            #end if

            if l_sttweb = "F" or
               l_sttweb = "B" then
               # ---> ASSUNTO FINALIZADO NA WEB
               # --> BUSCA A DATA E HORA DO BANCO

               call cts40g03_data_hora_banco(2)
                    returning l_data_lig, l_hora_lig

               if g_documento.acao is null then
                  let g_documento.acao = "INC"
               end if


               ## ATUALIZA HORA FINAL DA LIGACAO

               whenever error continue
               begin work
                  update  datmligacao
                  set     lighorfnl = l_hora_lig
                  where   lignum = l_ctq00m01_ret.lignum
               whenever error stop

               if sqlca.sqlcode = 0 then
                  if cta02m13_remove_transicao(g_issk.empcod,
                                               g_issk.funmat,
                                               g_documento.c24astcod) then
                     commit work
                    #call cta02m13_grava_dafmintsrv(l_ctq00m01_ret.atdsrvnum,
                    #                               l_ctq00m01_ret.atdsrvano)
                  else
                     rollback work
                  end if
               else
                  rollback work
               end if
            end if
         else
            if lr_cta02m1303.aplflg = "N" then
               error "Laudo de Furto/Roubo deve estar vinculado a uma apolice "
               sleep 1
            else
               # se a flag do assunto for "S" e o atendente nao esta no
               # dominio o mesmo tem que transferir para outra fila.
               # So vai entrar no laudo se a flag for "N"  28/03/07
               if lr_cta02m1303.webrlzflg = "S"      then
                  call cts08g01 ("A","N", "",
                                 "Transferir esta ligacao para  fila 2010.",
                                 "Havendo fila de espera, transferir para ",
                                 "2345")
                       returning l_atencao
                  return l_ret, g_documento.lignum
               end if

               # LH - 04/03/2010 - inicio
               if (g_documento.aplnumdig is null) then
                  call cts05m00 ()
               else
                  call ssata801 ()
               end if
               # LH - 04/03/2010 - fim
            end if
         end if
     #end if


end function


#----------------------------------------------#
 function cta02m13_aviso_sinistro(lr_cta02m1303)  #SA__260142_1
#----------------------------------------------#

define lr_cta02m1303   record
   prgcod              like datkassunto.prgcod
  ,atdsrvorg           like datmservico.atdsrvorg
  ,aplflg              char(01)
  ,docflg              char(01)
  ,webrlzflg           like datkassunto.webrlzflg
end record


define l_null          char(01)
define l_ret           smallint

 ## CT 303208
 ## alberto
 define l_cmd char(500)

 define l_mens record
          msg char(200)
         ,de char(50)
         ,subject char(100)
         ,para char(100)
         ,cc char(100)
       end record

 define l_today date
 define l_hora datetime hour to second

 define l_ant_aplnumdig like abamapol.aplnumdig

  define lr_numeracao record
         lignum       like datmligacao.lignum,
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano,
         sqlcode      integer,
         msg          char(80)
  end record

  define l_sttweb       like datmagnwebsrv.sttweb,
         l_status       smallint,
         l_ligorgcod    like datmagnwebsrv.ligorgcod,
         l_abnwebflg    like datmagnwebsrv.abnwebflg,
         l_ligasscod    like datmagnwebsrv.ligasscod,
         l_vstagnnum    like datmagnwebsrv.vstagnnum,
         l_vstagnstt    like datmagnwebsrv.vstagnstt,
         l_orgvstagnnum like datmagnwebsrv.orgvstagnnum,
         l_data_lig     date,
         l_c24astcod    like datmligacao.c24astcod,
         l_atencao      char(01),
         l_hora_lig     datetime hour to minute,
         l_horas_lig    datetime hour to second,
         l_tabname      char(30),
         l_sqlcode      integer,
         l_cornom       like gcakcorr.cornom,
         l_corsus       like gcaksusep.corsus,
         l_vcllicnum    like datmsinatditf.vcllicnum,
         l_vclchsinc    like datmsinatditf.vclchsinc,
         l_vclchsfnl    like datmsinatditf.vclchsfnl,
         l_corlidflg    like abamcor.corlidflg,
         l_ambiente     char(08)

  ## Alberto

  define ret_param_msg char(50)

  define l_ctq00m01_ret   record
         err         smallint,
         msg         char(80),
         lignum      like datmligacao.lignum,
         atdsrvnum   like datmservico.atdsrvnum,
         atdsrvano   like datmservico.atdsrvano
  end record

  define lr_retorno  record
         sttatendi   char(01)
        ,matranali   like datmligacao.c24funmat
        ,nomeanali   like isskfunc.funnom
        ,foneanali   like datmligacao.c24paxnum
        ,msg         char(32766)
        ,param       char(2000)
        ,coderro     dec(1,0)
        ,msgerro     char(1000)
  end record
  define l_hist      record
         tipgrv      smallint,
         lignum      like datmlighist.lignum,
         c24funmat   like datmlighist.c24funmat,
         ligdat      like datmlighist.ligdat,
         lighorinc   like datmlighist.lighorinc,
         c24ligdsc   like datmlighist.c24ligdsc
  end record
  define l_retorno   record
         tabname     like systables.tabname,
         sqlcode     integer
  end record
  define l_ok        smallint
  define l_matratend like datmligacao.c24funmat
  define l_funnomatd like isskfunc.funnom
  define l_motrecusa smallint
  define l_funmat    like datmligacao.c24funmat
  define l_sinatdsit char(01)
  define l_trfhor    interval hour to second
  define l_cpodes    like iddkdominio.cpodes
  define l_remetente char(50)
  define l_assunto   char(50)
  define l_para      char(1000)
  define l_comando   char(32766)
  define l_maquina   char(10)
  define l_maqsgl    char(10)
  define l_u11       char(1)
  define l_alt_assunto smallint
  define r_c24astcod   like datkassunto.c24astcod
  define l_count    smallint
  define l_ciaempcod_slv like datmligacao.ciaempcod
  #define l_c24astcod like datkassunto.c24astcod

  define l_liberadoN10 char(01) # verificar se liberado todo atendente na WEB - N10/N11 = "S"
                                # 20/01/2009

 initialize l_mens.* to null
 initialize lr_numeracao.* to null
 initialize l_ctq00m01_ret.* to null
 initialize lr_retorno.* to null
 initialize l_hist.* to null
 initialize l_retorno.* to null

 let l_null            = null
 let l_ret             = null
 let l_cmd             = null
 let l_today           = null
 let l_hora            = null
 let l_ant_aplnumdig   = null
 let l_sttweb          = null
 let l_status          = null
 let l_ligorgcod       = null
 let l_abnwebflg       = null
 let l_ligasscod       = null
 let l_vstagnnum       = null
 let l_vstagnstt       = null
 let l_orgvstagnnum    = null
 let l_data_lig        = null
 let l_c24astcod       = null
 let l_atencao         = null
 let l_hora_lig        = null
 let l_horas_lig       = null
 let l_tabname         = null
 let l_sqlcode         = null
 let l_cornom          = null
 let l_corsus          = null
 let l_vcllicnum       = null
 let l_vclchsinc       = null
 let l_vclchsfnl       = null
 let l_corlidflg       = null
 let l_ambiente        = null
 let ret_param_msg     = null
 let l_ok              = null
 let l_matratend       = null
 let l_funnomatd       = null
 let l_motrecusa       = null
 let l_funmat          = null
 let l_sinatdsit       = null
 let l_trfhor          = null
 let l_cpodes          = null
 let l_remetente       = null
 let l_assunto         = null
 let l_para            = null
 let l_comando         = null
 let l_maquina         = null
 let l_maqsgl          = null
 let l_u11             = null
 let l_alt_assunto     = null
 let r_c24astcod       = null
 let l_count           = null
 let l_ciaempcod_slv   = null
 let l_c24astcod = null
 let l_count = 0

  if lr_cta02m1303.prgcod = 5 then


      let l_liberadoN10 = "N"
      #if lr_cta02m1303.webrlzflg = "S" then
      select cpodes into l_cpodes
        from iddkdominio
       where cponom = "liberan10"
       if lr_cta02m1303.webrlzflg = "S" then
          if (l_cpodes      = "S" or
              l_cpodes      = "s" ) then
             let l_liberadoN10 = "S"
          else
             if cta02m13_acesso_web(g_issk.funmat) then
                #lr_cta02m1303.webrlzflg = "S"      then
                let l_liberadoN10 = "S"
             else
                let l_liberadoN10 = "N"
             end if
          end if
       end if

      if l_liberadoN10 = "S" then
         # --> BUSCA A DATA E HORA DO BANCO
         call cts40g03_data_hora_banco(2)
              returning l_data_lig, l_hora_lig
         let l_horas_lig = current
         let l_funmat    = g_issk.funmat

         let l_sinatdsit = "A"
         let l_sttweb    = "A"

         #--- psi 205745 - Gera integracao
         #--- Busca Corsus

         if m_cta02m13_prep is null or
            m_cta02m13_prep <> true then
            call cta02m13_prepare()
         end if

         let l_ok = 1
         ######################################################################
         # Solicitado para não gerar Nº de ligação, pois,
         # Na chamada do sinistro (N10/N11) estão desprezando este Nº e passando
         # na chamada do MQ-bdatm005, com Nº ligação nula(0), o que faz com que
         # seja solicitado a geração de um novo Nº de ligacao.

         ## Gera Nº Ligação PSI 206.938
         #call cts10g03_numeracao( 1, "" )
         #returning lr_numeracao.lignum,
         #          lr_numeracao.atdsrvnum,
         #          lr_numeracao.atdsrvano,
         #          lr_numeracao.sqlcode,
         #          lr_numeracao.msg
         ######################################################################

         call cta02m13_grava_transicao
             (g_issk.empcod           , # atlemp       Empresa Atendente
              l_funmat                , # atlmat       Matricula Atendente
              "F"                     , # atlusrtip    Tipo Usuario
              g_documento.c24astcod   , # c24astcod    codigo do Assunto
              "COLISAO"               , # sinntzdes    Descrição da natureza ?
              10                      , # sinntzcod    Código natureza       ?
              g_documento.solnom      , # sinifrnom    Nome do informante
              g_documento.c24soltipcod, # c24soltipcod Tipo de informante
              l_data_lig              , # ligdat       Data da ligação
              l_hora_lig              , # lighor       Hora da ligação
              g_issk.empcod           , # empcod       empresa
              g_documento.succod      , # succod       Sucursal
              g_documento.ramcod      , # ramcod       Ramo
              g_documento.aplnumdig   , # aplnumdig    Apolice
              g_documento.itmnumdig   , # itmnumdig    Item
              g_documento.ligcvntip   , # ligcvntip    Codigo convenio
              g_c24paxnum             , # c24paxnum    Número da PA
              lr_numeracao.lignum     , # lignum      e Número atendimento
              l_sinatdsit             , # sinatdsit    Status do atendimento
              l_vcllicnum             , # placa para atd. sem docto
              l_vclchsinc             , # chassi inicial p/ atd. sem docto
              l_vclchsfnl             , # chassi final   p/ atd. sem docto
              g_documento.prporg      , #
              g_documento.prpnumdig   , #
              g_documento.dddcod      , # dddcod p/ ligacao s/docto
              g_documento.ctttel      , # telefone p/ ligacao s/docto
              1                       , # empcod
              g_documento.funmat      , # matricula p/ ligacao s/docto
              "F"                     , # usrtip
              g_documento.cgccpfnum   , # cgc e cpf p/ ligacao s/docto
              g_documento.cgcord      , # ordem cgc p/ligacao s/docto
              g_documento.cgccpfdig   , # digito cgc cpf p/ligacao s/docto
              g_documento.corsus      , # susep p/ ligacao s/ docto
              l_motrecusa             , # motivo da recusa
              l_trfhor                ) # intervalo de horas
         returning l_ok

         if not l_ok then
            return l_ok, 0
         end if
         # ---> ATENDIMENTO SENDO REALIZADO VIA WEB
         while l_sttweb = "A"
            # ---> EXIBE A MENSAGEM PARA O USUARIO

            initialize m_texto1, m_texto2 to null
            let m_texto1 = "PRESSIONE ALT+TAB PARA MIGRAR"
            let m_texto2 = "PARA AMBIENTE WEB... "

            ---> Abre tela de Aviso com Atalho F1-Funcoes
            call cta02m13_men()


            # ---> BUSCA O STATUS DE RETORNO DA WEB
            call cta02m13_pesq_transicao( g_issk.empcod ,
                                          g_issk.funmat ,
                                          g_documento.c24astcod)
                 returning l_sttweb, l_ctq00m01_ret.lignum
                # impedir a liberacao do terminal Informix, ate que o motivo da
                # nao transferencia seja preenchido no Aviso Web, ou, que o
                # atendente informe no Aviso Web que a ligagco foi de fato
                # transferida.  11/07/07 - Marcelo Garcia/Ruiz
            if l_sttweb = "T" then  # nao liberar o terminal
               let l_sttweb = "A"
            end if
         end while

         if l_sttweb = "F" or
            l_sttweb = "B" then
            # ---> ASSUNTO FINALIZADO NA WEB
            # --> BUSCA A DATA E HORA DO BANCO

            call cts40g03_data_hora_banco(2)
                 returning l_data_lig, l_hora_lig

            # recuperar Nº ligação da datmsinatditf
            select lignum
            into   g_documento.lignum
            from   datmsinatditf
            where  atlemp     = g_issk.empcod
            and    atlmat     = g_issk.funmat
            and    atlusrtip  = "F"
            and    atdassdes  = g_documento.c24astcod

            if g_documento.acao is null then
               let g_documento.acao = "INC"
            end if


               begin work
               if cta02m13_remove_transicao(g_issk.empcod,
                                            g_issk.funmat,
                                            g_documento.c24astcod) then
                  commit work
               else
                  rollback work
               end if

         end if


      else

         call figrc072_setTratarIsolamento()        --> 223689

               # LH - 04/03/2010 - inicio
               if (g_documento.aplnumdig is null) then
                   error "Laudo de Aviso de Sinistro deve estar vinculado a uma apolice ! "
                   sleep 1
                  # call cts18m00 ("", "") Função retirada a pedido da Karla Santos e
                  # Daniel Silvestri ( Sinistro ) na Homologacao do novo aviso de
                  # sinistro. 17/01/2011
               else
                  call ssata801 ()
               end if
               # LH - 04/03/2010 - fim

         if g_isoAuto.sqlCodErr <> 0 then --> 223689
                error "Função cts18m00 indisponivel no momento ! Avise a Informatica !" sleep 2
                return l_ret, g_documento.lignum
         end if    --> 223689

      end if
  end if

  if lr_cta02m1303.prgcod = 34 then

     if lr_cta02m1303.webrlzflg = "S"      then

         # --> BUSCA A DATA E HORA DO BANCO
         call cts40g03_data_hora_banco(2)
              returning l_data_lig, l_hora_lig
         let l_horas_lig = current

         let l_funmat    = g_issk.funmat
         let l_sinatdsit = "A"
         let l_sttweb    = "A"

         if m_cta02m13_prep is null or
            m_cta02m13_prep <> true then
            call cta02m13_prepare()
         end if

         select c24astcod into l_c24astcod from datmligacao
                where lignum = g_documento.lignum

         whenever error continue
           open c_cta02m13_011 using l_c24astcod
           fetch c_cta02m13_011 into l_count
         whenever error stop

         if l_count > 0 then
            let lr_numeracao.lignum = g_documento.lignum
         end if


         call cta02m13_grava_transicao
             (g_issk.empcod           , # atlemp       Empresa Atendente
              l_funmat                , # atlmat       Matricula Atendente
              "F"                     , # atlusrtip    Tipo Usuario
              g_documento.c24astcod   , # c24astcod    codigo do Assunto
              "CONS/ALT AVS SINISTRO" , # sinntzdes    Descrição da natureza
              30                      , # sinntzcod    Código natureza
              g_documento.solnom      , # sinifrnom    Nome do informante
              g_documento.c24soltipcod, # c24soltipcod Tipo de informante
              l_data_lig              , # ligdat       Data da ligação
              l_hora_lig              , # lighor       Hora da ligação
              g_issk.empcod           , # empcod       empresa
              g_documento.succod      , # succod       Sucursal
              g_documento.ramcod      , # ramcod       Ramo
              g_documento.aplnumdig   , # aplnumdig    Apolice
              g_documento.itmnumdig   , # itmnumdig    Item
              g_documento.ligcvntip   , # ligcvntip    Codigo convenio
              g_c24paxnum             , # c24paxnum    Número da PA
              lr_numeracao.lignum     , # lignum       Número atendimento
              l_sinatdsit             , # sinatdsit    Status do atendimento
              l_vcllicnum             , # placa para atd. sem docto
              l_vclchsinc             , # chassi inicial p/ atd. sem docto
              l_vclchsfnl             , # chassi final   p/ atd. sem docto
              g_documento.prporg      , #
              g_documento.prpnumdig   , #
              g_documento.dddcod      , # dddcod p/ ligacao s/docto
              g_documento.ctttel      , # telefone p/ ligacao s/docto
              1                       , # empcod
              g_documento.funmat      , # matricula p/ ligacao s/docto
              "F"                     , # usrtip
              g_documento.cgccpfnum   , # cgc e cpf p/ ligacao s/docto
              g_documento.cgcord      , # ordem cgc p/ligacao s/docto
              g_documento.cgccpfdig   , # digito cgc cpf p/ligacao s/docto
              g_documento.corsus      , # susep p/ ligacao s/ docto
              l_motrecusa             , # motivo da recusa
              l_trfhor                ) # intervalo de horas
         returning l_ok

         if not l_ok then
            return l_ok, 0
         end if

         # ---> ATENDIMENTO SENDO REALIZADO VIA WEB
            while l_sttweb = "A"
               # ---> EXIBE A MENSAGEM PARA O USUARIO
               initialize m_texto1, m_texto2 to null
               let m_texto1 = "PRESSIONE ALT+TAB PARA MIGRAR"
               let m_texto2 = "PARA O AMBIENTE WEB..."

               ---> Abre tela de Aviso com Atalho F1-Funcoes
               call cta02m13_men()

               # ---> BUSCA O STATUS DE RETORNO DA WEB
               call cta02m13_pesq_transicao( g_issk.empcod ,
                                             g_issk.funmat ,
                                             g_documento.c24astcod)
                    returning l_sttweb, l_ctq00m01_ret.lignum
               if l_sttweb = "T" then  # nao liberar o terminal
                  let l_sttweb = "A"
               end if
            end while

            if l_sttweb = "F" or
               l_sttweb = "B" then
               # ---> ASSUNTO FINALIZADO NA WEB
               # --> BUSCA A DATA E HORA DO BANCO

               call cts40g03_data_hora_banco(2)
                    returning l_data_lig, l_hora_lig

               if g_documento.acao is null then
                  let g_documento.acao = "CON"
               end if


               ## ATUALIZA HORA FINAL DA LIGACAO

               whenever error continue
               begin work
                  update  datmligacao
                  set     lighorfnl = l_hora_lig
                  where   lignum = l_ctq00m01_ret.lignum
               whenever error stop

               if sqlca.sqlcode = 0 then
                  if cta02m13_remove_transicao(g_issk.empcod,
                                               g_issk.funmat,
                                               g_documento.c24astcod) then
                     commit work
                  else
                     rollback work
                  end if
               else
                  rollback work
               end if
            end if
     else
                 call cts08g01 ("A","N", "",
                                "UTILIZAR OS ASSUNTOS ORIGINAIS ",
                                "DO SINISTRO ! ",
                                "")
                      returning l_atencao
     end if
   end if

end function


#-------------------------------------------------------------------------------
 function cta02m13_captura_nome_tel()
#-------------------------------------------------------------------------------

define la_dados record
    nome      char(100)
   ,ddd       char(2)
   ,telefone  char(11)
end record

define l_nome     char(100)
define l_telefone char(11)
define i          smallint
define l_flg          smallint


    open window w_cta02m13d at 18,7 with form 'cta02m13d'
         attribute(border, form line 1)

    input by name la_dados.nome
                , la_dados.ddd
                , la_dados.telefone

      #------------------
       before field nome
      #-------------------
         display la_dados.nome to nome attribute(reverse)

      #----------------
       after field nome
      #----------------
         display la_dados.nome to nome attribute(reverse)

         if la_dados.nome is null or
            la_dados.nome = ''    or
            la_dados.nome = ' '   then
            error 'DIGITE O NOME DO CLIENTE'
            next field nome
         end if

         display la_dados.nome to nome

      #------------------
       before field ddd
      #-------------------
         display la_dados.ddd to ddd attribute(reverse)

      #----------------
       after field ddd
      #----------------
         display la_dados.ddd to ddd attribute(reverse)

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
           next field nome
         end if

         if la_dados.ddd is null or
            la_dados.ddd = ''    or
            la_dados.ddd = ' '   then
            error 'DIGITE O DDD'
            next field ddd
         end if

         let l_telefone = ''
         let l_telefone = la_dados.ddd
         let l_flg = 0

         for i = 1 to 8
             if l_telefone[i] matches '[A-Z]' then
                let l_flg = 1
             end if
         end for

         if l_flg = 1 then
            error 'DDD não pode conter letras'
            next field ddd
         end if

         display la_dados.ddd to ddd

      #------------------
       before field telefone
      #-------------------
         display la_dados.telefone to telefone attribute(reverse)

      #---------------------
       after field telefone
      #---------------------
         display la_dados.telefone to telefone attribute(reverse)

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
           next field ddd
         end if

         if fgl_lastkey() = fgl_keyval("return")  then
           error 'Necessario confirmação dos dados. Tecle F8-Confirma'
           next field telefone
         end if

         if la_dados.telefone is null or
            la_dados.telefone = ''    or
            la_dados.telefone = ' '   then
            error 'DIGITE O TELEFONE DO CLIENTE'
            next field telefone
         end if

         let l_telefone = ''
         let l_telefone = la_dados.telefone
         let l_flg = 0

         for i = 1 to 8
             if l_telefone[i] matches '[A-Z]' then
                let l_flg = 1
             end if
         end for

         if l_flg = 1 then
            error 'TELEFONE não pode conter letras'
            next field telefone
         end if

         display la_dados.telefone to telefone

     #----------------
      on key (interrupt)
     #----------------
         error 'Necessario confirmação dos dados. Tecle F8-Confirma'

     #----------------
      on key(F8)
     #----------------
         let la_dados.telefone = get_fldbuf(telefone)

         if la_dados.nome is not null and
            la_dados.ddd is not null and
            la_dados.telefone is not null then
            exit input
         else
            error 'Preencha todos os campos!'
         end if



    end input

    let l_nome = ''
    let l_telefone = ''

    let l_nome     = la_dados.nome
    let l_telefone = la_dados.ddd,'-',la_dados.telefone

    close window w_cta02m13d

    return l_nome, l_telefone


end function

#-----------------------------------------------------#
function cta02m13_enviaEmail_localizacao(lr_parametro)
#-----------------------------------------------------#

  define lr_parametro record
         lignum       like datmligacao.lignum
       , vcllicnum    like datkveiculo.vcllicnum
       , fone         char(11)
       , segnom       like gsakseg.segnom
       , c24astcod    like datmligacao.c24astcod
       , atdsrvnum    like datmservico.atdsrvnum
       , atdsrvano    like datmservico.atdsrvano
       , l_flag       char(15)
  end record

  define l_comando       char(15000),
         l_historico     char(10000),
         l_msg           char(30000),
         l_assunto       char(100),
         l_espera        char(01),
         l_remetente     char(50),
         l_atdsrvnum     like datmservico.atdsrvnum,
         l_atdsrvano     like datmservico.atdsrvano,
         l_para          char(1000),
         l_status        smallint,
         l_ligdat        date,
         l_lighorinc     like datmligacao.lighorinc,
         l_c24astdes     char (45),
         l_aux_assunto   char(100),
         l_apl_prp       char(200),
         l_org,
         l_prp,
         l_scod,
         l_apln          char(100),
         l_num_serv      char(100)

  define  l_mail             record
        de                 char(500)   # De
       ,para               char(5000)  # Para
       ,cc                 char(500)   # cc
       ,cco                char(500)   # cco
       ,assunto            char(500)   # Assunto do e-mail
       ,mensagem           char(32766) # Nome do Anexo
       ,id_remetente       char(20)
       ,tipo               char(4)     #
  end  record
  define l_erro  smallint
  define msg_erro char(500)
  let l_comando   = null
  let l_msg       = ''
  let l_assunto   = null
  let l_remetente = null
  let l_ligdat    = null
  let l_atdsrvnum = null
  let l_atdsrvano = null
  let l_espera    = null
  let l_status    = null
  let l_lighorinc = null

  let lr_parametro.l_flag = lr_parametro.l_flag clipped

   if lr_parametro.c24astcod = 'L11' or
      lr_parametro.c24astcod = 'L12' then
      let l_historico = cta02m00_buscaHistoricoServico(lr_parametro.lignum)
   else
      let l_historico = cta02m00_buscaHistServicoL10(lr_parametro.atdsrvnum, lr_parametro.atdsrvano)
   end if

  if m_cta02m13_prep is null or
      m_cta02m13_prep <> true then
      call cta02m13_prepare()
   end if

  call cta00m06_jit_email()
       returning l_para   #pega email no dominio

  let l_remetente = "Central-24-Horas"

  if lr_parametro.l_flag[1,3] = 'SIM' then
     let l_assunto = 'ACEITACAO JIT Localizacao'
  else
     let l_assunto = 'NAO-ACEITACAO JIT Localizacao'
  end if

  open c_cta02m13_010 using lr_parametro.lignum
  fetch c_cta02m13_010 into lr_parametro.lignum,
                            l_atdsrvano,
                            l_atdsrvnum,
                            l_ligdat,
                            l_lighorinc
  close c_cta02m13_010

  call c24geral8(lr_parametro.c24astcod)
       returning l_c24astdes

  let l_aux_assunto = lr_parametro.c24astcod clipped,'-', l_c24astdes  clipped

  if g_documento.succod    is null and
     g_documento.aplnumdig is null then         #se apolice nula
     if g_documento.prporg     is not null and
        g_documento.prpnumdig  is not null then #e se for proposta
        let l_org = g_documento.prporg
        let l_prp = g_documento.prpnumdig
        let l_apl_prp = "Proposta.............: ", l_org clipped,'-', l_prp clipped
     end if
  else
     let l_scod = g_documento.succod
     let l_apln = g_documento.aplnumdig
     let l_apl_prp = "Apolice..............: ", l_scod clipped,'-', l_apln clipped
  end if

  if lr_parametro.c24astcod = 'L11' or
     lr_parametro.c24astcod = 'L12' then
     let l_msg       = "<html><body><font face = Calibri> "
                     ,"ASSUNTO..............: ", l_aux_assunto          clipped, " <br><br>"
                     , "Nome do Segurado.....: ", lr_parametro.segnom    clipped, " <br>"
                     , "Telefone do Segurado.: ", lr_parametro.fone      clipped, " <br>"
                     , l_apl_prp                                         clipped, " <br>"
                     , "Placa do Veiculo.....: ", lr_parametro.vcllicnum clipped, " <br>"
                     , "Data da Ligacao......: ", l_ligdat using "dd/mm/yyyy"   , " <br>"
                     , "Hora da Ligacao......: ", l_lighorinc                   , " <br><br>"
                     , "|---------------[ Historico da Ligacao ]----------------|"   , "<br>"
                     , l_historico
  else
     let l_num_serv = g_documento.atdsrvorg using "<<<<" ,'-',l_atdsrvnum using "<<<<<<<<<<" ,"/",l_atdsrvano using "<<<<<<"


     let l_msg       = "<html><body><font face = Calibri> "
                     , "ASSUNTO..............: ", l_aux_assunto          clipped, " <br><br>"
                     , "Nome do Segurado.....: ", lr_parametro.segnom    clipped, " <br>"
                     , "Telefone do Segurado.: ", lr_parametro.fone      clipped, " <br>"
                     , "Numero de Servico....: ", l_num_serv             clipped, " <br>"
                     , l_apl_prp                                         clipped, " <br>"
                     , "Placa do Veiculo.....: ", lr_parametro.vcllicnum clipped, " <br>"
                     , "Data da Ligacao......: ", l_ligdat using "dd/mm/yyyy"   , " <br>"
                     , "Hora da Ligacao......: ", l_lighorinc                   , " <br><br>"
                     , "---------------Historico da Ligacao---------------- "   , " <br>"
                     , l_historico
  end if

  #PSI-2013-23297 - Inicio

  let l_mail.de = l_remetente
  #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
  let l_mail.para = l_para
  let l_mail.cc = ""
  let l_mail.cco = ""
  let l_mail.assunto = l_assunto
  let l_mail.mensagem = l_msg
  let l_mail.id_remetente = "CT24HS"
  let l_mail.tipo = "html"

  call figrc009_mail_send1 (l_mail.*)
      returning l_erro,msg_erro

  #PSI-2013-23297 - Fim
  if l_erro <> 0 then
     error "ERRO NO ENVIO DE E-MAIL DE LOCALIZACAO. AVISE A INFORMATICA !"
     prompt " " for l_espera
  end if

end function
