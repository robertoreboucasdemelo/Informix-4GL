#############################################################################
# Nome do Modulo: CTB02M00                                          Wagner  #
#                                                                           #
# Protocolo da ordem de pagamento - Carro-extra                    Out/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 03/07/2001  PSI 13448-1  Wagner       Alterar qtde dias data pagamento p/3#
#############################################################################
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data      Autor Fabrica PSI/OSF Alteracao                                 #
# -------- -------------  ------- ------------------------------------------#
#07/07/2003 Rodrigo, Meta  175544 Adicionar o codigo da loja na busca de OPS#
#                                 para o mesmo favorecido                   #
#19/08/2003 Ale Souza       24740 Critica automatica por nro de Nota Fiscal #
#---------------------------------------------------------------------------#
# 20/07/2006  PSI 197858  Cristiane Silva  Subtrair do valor total os des-  #
#                                          contos, se houver.               #
#---------------------------------------------------------------------------#
# 29/12/2006 Priscila Staingel PSI205206 Exibir se a OP é da Azul ou Porto  #
#                                        sendo q todos os itens da OP devem #
#                                        ser da mesma empresa               #
#---------------------------------------------------------------------------#
# 20/03/2008  PSI 221074   Burini       Fases da OP - Registro Responsavel  #
# 27/05/2009  PSI 198404   Fabio Costa  Impedir edicao de OP com status 10  #
#                                       e 11, digitacao da NF apos os itens #
# 06/08/2009  PSI 198404   Fabio Costa  Reembolso ao segurado para OP Carro #
# 26/04/2010  PSI 198404   Fabio Costa  Tratar reembolso segurado Azul, tipo#
#                                       favorecido, NFS na OP, verific. NFS #
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepara_sql smallint  #psi175544

define m_dominio record
       erro      smallint  ,
       mensagem  char(100) ,
       cpodes    like iddkdominio.cpodes
end record
 
#----------------------------#
 function ctb02m00_prepara()   #psi175544
#----------------------------#

    define l_sqlstmt  char(200)

    let l_sqlstmt = 'select aviestcod ',
                    '  from datkavislocal ',
                    ' where lcvcod = ? ',
                    '   and lcvextcod = ? '
   prepare pctb02m0001 from l_sqlstmt
   declare cctb02m0001 cursor for pctb02m0001

   let l_sqlstmt = 'select socopgnum ',
                   '  from dbsmopg   ',
                   ' where socfatpgtdat between ? and ? ',
                   '   and lcvcod       = ? ',
                   '   and aviestcod    = ? ',
                   '   and socopgsitcod < 6 '
   prepare pctb02m0002 from l_sqlstmt
   declare cctb02m0002 cursor for pctb02m0002

   let l_sqlstmt = 'select socopgnum ',
                   '  from dbsmopg   ',
                   ' where socfatpgtdat between ? and ? ',
                   '   and socopgsitcod < 6 ',
                   '   and soctip    = 2 ',
                   '   and segnumdig = ? '
   prepare p_opg_seg_sel from l_sqlstmt
   declare c_opg_seg_sel cursor for p_opg_seg_sel
   
   let m_prepara_sql = true

end function #fim psi175544

#------------------------------------------------------------
function ctb02m00()
#------------------------------------------------------------

   define k_ctb02m00   record
          socopgnum    like dbsmopg.socopgnum
   end record

   define ctb02m00     record
          socopgnum    like dbsmopg.socopgnum,
          socopgsitcod like dbsmopg.socopgsitcod,
          socopgsitdes char (30),
          empresa      char (5),         #PSI 205206
          lcvcod       like datklocadora.lcvcod,
          lcvnom       like datklocadora.lcvnom,
          lcvextcod    like datkavislocal.lcvextcod,
          aviestnom    like datkavislocal.aviestnom,
          pestip       like dbsmopg.pestip,
          cgccpfnum    like dbsmopg.cgccpfnum,
          cgcord       like dbsmopg.cgcord,
          cgccpfdig    like dbsmopg.cgccpfdig,
          socpgtdoctip like dbsmopg.socpgtdoctip,
          socpgtdocdes char(15),
          nfsnum       like dbsmopgitm.nfsnum,
          socfatentdat like dbsmopg.socfatentdat,
          socfatpgtdat like dbsmopg.socfatpgtdat,
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          socfatrelqtd like dbsmopg.socfatrelqtd,
          linhamsg     char (70),
          segnumdig    like dbsmopg.segnumdig,
          segnom       like gsakseg.segnom,
          favtip       smallint,
          favtipdes    char(12),
          favtipnom1   char(40),
          favtipnom2   char(40),
          empcod       like dbsmopg.empcod,
          empnom       like gabkemp.empnom
   end record

#  if not get_niv_mod(g_issk.prgsgl, "ctb02m00") then
#     error " Modulo sem nivel de consulta e atualizacao!"
#     return
#  end if

   let int_flag = false

   initialize ctb02m00.*   to  null
   initialize k_ctb02m00.* to  null

   if m_prepara_sql is null or m_prepara_sql = false then   #psi175544
      call ctb02m00_prepara()
   end if # fim psi175544

   open window ctb02m00 at 04,02 with form "ctb02m00"

   menu "PROTOCOLO"

       before menu
          hide option all
#         if  g_issk.acsnivcod >= g_issk.acsnivcns  then        # NIVEL 1
#               show option "Seleciona", "Proximo", "Anterior"
#         end if
#         if  g_issk.acsnivcod >= g_issk.acsnivatl  then        # NIVEL 5
                show option "Seleciona", "Proximo", "Anterior",
                            "Modifica", "Inclui"
#         end if
#         if  g_issk.acsnivcod  = 8   then                      # NIVEL 8
                show option "Remove"
#         end if
          show option "Encerra"

   command "Seleciona" "Pesquisa protocolo conforme criterios"
            call seleciona_ctb02m00() returning k_ctb02m00.*, ctb02m00.*
            if k_ctb02m00.socopgnum is not null  then
               message ""
               next option "Proximo"
            else
               error " Nenhum protocolo selecionado!"
               message ""
               next option "Seleciona"
            end if

   command "Proximo" "Mostra proxima protocolo selecionado"
            message ""
            if k_ctb02m00.socopgnum is not null then
               call proximo_ctb02m00(k_ctb02m00.*)
                    returning k_ctb02m00.*, ctb02m00.*
            else
               error " Nenhum protocolo nesta direcao!"
               next option "Seleciona"
            end if

   command "Anterior" "Mostra protocolo anterior selecionado"
            message ""
            if k_ctb02m00.socopgnum is not null then
               call anterior_ctb02m00(k_ctb02m00.*)
                    returning k_ctb02m00.*, ctb02m00.*
            else
               error " Nenhum protocolo nesta direcao!"
               next option "Seleciona"
            end if

   command "Modifica" "Modifica protocolo corrente selecionado"
            message ""
            if k_ctb02m00.socopgnum  is not null
               then
               if ctb02m00.socopgsitcod  <>  7   and  #-> EMITIDA
                  ctb02m00.socopgsitcod  <>  8   and  #-> CANCELADA
                  ctb02m00.socopgsitcod  <>  10  and  #-> aguard emissao People
                  ctb02m00.socopgsitcod  <>  11       #-> aguard cancel People
                  then
                  if ctb02m00.socopgsitcod  >  1   and   #-> PASSOU FASE PROT.
                     g_issk.acsnivcod       <  6
                     then
                     error " Nivel de acesso nao permite alteracao!"
                  else
                     call modifica_ctb02m00(k_ctb02m00.*, ctb02m00.*)
                          returning k_ctb02m00.*
                     next option "Seleciona"
                  end if
               else
                  error " Ordem de pagamento nao deve ser alterada!"
               end if
            else
               error " Nenhum protocolo selecionado!"
               next option "Seleciona"
            end if

   command "Remove" "Remove protocolo corrente selecionado"
            message ""
            if k_ctb02m00.socopgnum is not null then
               call remove_ctb02m00(k_ctb02m00.*)
                    returning k_ctb02m00.*
               next option "Seleciona"
            else
               error " Nenhum protocolo selecionado!"
               next option "Seleciona"
            end if

   command "Inclui" "Inclui protocolo"
            message ""
            call inclui_ctb02m00()
            next option "Seleciona"

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
   end menu

   close window ctb02m00

end function  ###  ctb02m00

#------------------------------------------------------------
function seleciona_ctb02m00()
#------------------------------------------------------------

   define k_ctb02m00   record
          socopgnum    like dbsmopg.socopgnum
   end record

   define ctb02m00     record
          socopgnum    like dbsmopg.socopgnum,
          socopgsitcod like dbsmopg.socopgsitcod,
          socopgsitdes char (30),
          empresa      char (5),         #PSI 205206
          lcvcod       like datklocadora.lcvcod,
          lcvnom       like datklocadora.lcvnom,
          lcvextcod    like datkavislocal.lcvextcod,
          aviestnom    like datkavislocal.aviestnom,
          pestip       like dbsmopg.pestip,
          cgccpfnum    like dbsmopg.cgccpfnum,
          cgcord       like dbsmopg.cgcord,
          cgccpfdig    like dbsmopg.cgccpfdig,
          socpgtdoctip like dbsmopg.socpgtdoctip,
          socpgtdocdes char(15),
          nfsnum       like dbsmopgitm.nfsnum,
          socfatentdat like dbsmopg.socfatentdat,
          socfatpgtdat like dbsmopg.socfatpgtdat,
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          socfatrelqtd like dbsmopg.socfatrelqtd,
          linhamsg     char (70),
          segnumdig    like dbsmopg.segnumdig,
          segnom       like gsakseg.segnom,
          favtip       smallint,
          favtipdes    char(12),
          favtipnom1   char(40),
          favtipnom2   char(40),
          empcod       like dbsmopg.empcod,
          empnom       like gabkemp.empnom
   end record

   clear form
   let int_flag = false
   initialize  ctb02m00.*  to null

   input by name k_ctb02m00.socopgnum

      before field socopgnum
          display by name k_ctb02m00.socopgnum attribute (reverse)

          if k_ctb02m00.socopgnum is null then
             let k_ctb02m00.socopgnum = 0
          end if

      after  field socopgnum
          display by name k_ctb02m00.socopgnum

      on key (interrupt)
          exit input
   end input

   if int_flag  then
      let int_flag = false
      initialize ctb02m00.*   to null
      initialize k_ctb02m00.* to null
      error " Operacao cancelada!"
      clear form
      return k_ctb02m00.*, ctb02m00.*
   end if

   if k_ctb02m00.socopgnum  =  0   then
      select min (dbsmopg.socopgnum)
        into k_ctb02m00.socopgnum
        from dbsmopg
       where socopgnum > k_ctb02m00.socopgnum
         and soctip    = 2

      display by name k_ctb02m00.socopgnum
   end if

   call ler_ctb02m00(k_ctb02m00.*)  returning  ctb02m00.*

   if ctb02m00.socopgnum  is not null
      then
      display by name ctb02m00.socopgnum   ,
                      ctb02m00.socopgsitcod,
                      ctb02m00.socopgsitdes,
                      ctb02m00.favtip      ,
                      ctb02m00.favtipdes   ,
                      ctb02m00.lcvcod      ,
                      ctb02m00.lcvnom      ,
                      ctb02m00.lcvextcod   ,
                      ctb02m00.aviestnom   ,
                      ctb02m00.segnumdig   ,
                      ctb02m00.segnom      ,
                      ctb02m00.pestip      ,
                      ctb02m00.cgccpfnum   ,
                      ctb02m00.cgcord      ,
                      ctb02m00.cgccpfdig   ,
                      ctb02m00.socpgtdoctip,
                      ctb02m00.socpgtdocdes,
                      ctb02m00.nfsnum      ,
                      ctb02m00.socfatentdat,
                      ctb02m00.socfatpgtdat,
                      ctb02m00.socfatitmqtd,
                      ctb02m00.socfattotvlr,
                      ctb02m00.socfatrelqtd,
                      ctb02m00.linhamsg,
                      ctb02m00.empcod,
                      ctb02m00.empnom
                      
          
      display by name  ctb02m00.empresa attribute (reverse) #PSI 205206
   else
      error " Protocolo nao cadastrado!"
      initialize ctb02m00.*    to null
      initialize k_ctb02m00.*  to null
   end if

   return k_ctb02m00.*, ctb02m00.*

end function  ###  seleciona_ctb02m00

#------------------------------------------------------------
function proximo_ctb02m00(k_ctb02m00)
#------------------------------------------------------------

   define k_ctb02m00   record
          socopgnum    like dbsmopg.socopgnum
   end record

   define ctb02m00     record
          socopgnum    like dbsmopg.socopgnum,
          socopgsitcod like dbsmopg.socopgsitcod,
          socopgsitdes char (30),
          empresa      char (5),         #PSI 205206
          lcvcod       like datklocadora.lcvcod,
          lcvnom       like datklocadora.lcvnom,
          lcvextcod    like datkavislocal.lcvextcod,
          aviestnom    like datkavislocal.aviestnom,
          pestip       like dbsmopg.pestip,
          cgccpfnum    like dbsmopg.cgccpfnum,
          cgcord       like dbsmopg.cgcord,
          cgccpfdig    like dbsmopg.cgccpfdig,
          socpgtdoctip like dbsmopg.socpgtdoctip,
          socpgtdocdes char(15),
          nfsnum       like dbsmopgitm.nfsnum,
          socfatentdat like dbsmopg.socfatentdat,
          socfatpgtdat like dbsmopg.socfatpgtdat,
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          socfatrelqtd like dbsmopg.socfatrelqtd,
          linhamsg     char (70),
          segnumdig    like dbsmopg.segnumdig,
          segnom       like gsakseg.segnom,
          favtip       smallint,
          favtipdes    char(12),
          favtipnom1   char(40),
          favtipnom2   char(40),
          empcod       like dbsmopg.empcod,
          empnom       like gabkemp.empnom
   end record

   initialize ctb02m00.*   to null

   select min (dbsmopg.socopgnum)
     into ctb02m00.socopgnum
     from dbsmopg
    where socopgnum > k_ctb02m00.socopgnum
      and soctip    = 2

   if ctb02m00.socopgnum  is not null   then
      let k_ctb02m00.socopgnum = ctb02m00.socopgnum
      call ler_ctb02m00(k_ctb02m00.*)  returning  ctb02m00.*

      if ctb02m00.socopgnum  is not null
         then
         display by name ctb02m00.socopgnum   ,
                         ctb02m00.socopgsitcod,
                         ctb02m00.socopgsitdes,
                         ctb02m00.favtip      ,
                         ctb02m00.favtipdes   ,
                         ctb02m00.lcvcod      ,
                         ctb02m00.lcvnom      ,
                         ctb02m00.lcvextcod   ,
                         ctb02m00.aviestnom   ,
                         ctb02m00.segnumdig   ,
                         ctb02m00.segnom      ,
                         ctb02m00.pestip      ,
                         ctb02m00.cgccpfnum   ,
                         ctb02m00.cgcord      ,
                         ctb02m00.cgccpfdig   ,
                         ctb02m00.socpgtdoctip,
                         ctb02m00.socpgtdocdes,
                         ctb02m00.nfsnum      ,
                         ctb02m00.socfatentdat,
                         ctb02m00.socfatpgtdat,
                         ctb02m00.socfatitmqtd,
                         ctb02m00.socfattotvlr,
                         ctb02m00.socfatrelqtd,
                         ctb02m00.linhamsg,
                         ctb02m00.empcod,
                         ctb02m00.empnom
                         
         display by name  ctb02m00.empresa attribute (reverse) #PSI 205206
      else
         error " Nao ha' protocolo nesta direcao!"
         initialize ctb02m00.*    to null
         initialize k_ctb02m00.*  to null
      end if
   else
      error " Nao ha' protocolo nesta direcao!"
      initialize ctb02m00.*    to null
      initialize k_ctb02m00.*  to null
   end if

   return k_ctb02m00.*, ctb02m00.*

end function  ###  proximo_ctb02m00

#------------------------------------------------------------
function anterior_ctb02m00(k_ctb02m00)
#------------------------------------------------------------

   define k_ctb02m00   record
          socopgnum    like dbsmopg.socopgnum
   end record

   define ctb02m00     record
          socopgnum    like dbsmopg.socopgnum,
          socopgsitcod like dbsmopg.socopgsitcod,
          socopgsitdes char (30),
          empresa      char (5),         #PSI 205206
          lcvcod       like datklocadora.lcvcod,
          lcvnom       like datklocadora.lcvnom,
          lcvextcod    like datkavislocal.lcvextcod,
          aviestnom    like datkavislocal.aviestnom,
          pestip       like dbsmopg.pestip,
          cgccpfnum    like dbsmopg.cgccpfnum,
          cgcord       like dbsmopg.cgcord,
          cgccpfdig    like dbsmopg.cgccpfdig,
          socpgtdoctip like dbsmopg.socpgtdoctip,
          socpgtdocdes char(15),
          nfsnum       like dbsmopgitm.nfsnum,
          socfatentdat like dbsmopg.socfatentdat,
          socfatpgtdat like dbsmopg.socfatpgtdat,
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          socfatrelqtd like dbsmopg.socfatrelqtd,
          linhamsg     char (70),
          segnumdig    like dbsmopg.segnumdig,
          segnom       like gsakseg.segnom,
          favtip       smallint,
          favtipdes    char(12),
          favtipnom1   char(40),
          favtipnom2   char(40),
          empcod       like dbsmopg.empcod,
          empnom       like gabkemp.empnom
   end record

   let int_flag = false
   initialize ctb02m00.*  to null

   select max (dbsmopg.socopgnum)
     into ctb02m00.socopgnum
     from dbsmopg
    where socopgnum < k_ctb02m00.socopgnum
      and soctip    = 2

   if ctb02m00.socopgnum  is  not  null  then
      let k_ctb02m00.socopgnum = ctb02m00.socopgnum
      call ler_ctb02m00(k_ctb02m00.*)  returning  ctb02m00.*

      if ctb02m00.socopgnum  is not null
         then
         display by name ctb02m00.socopgnum   ,
                         ctb02m00.socopgsitcod,
                         ctb02m00.socopgsitdes,
                         ctb02m00.favtip      ,
                         ctb02m00.favtipdes   ,
                         ctb02m00.lcvcod      ,
                         ctb02m00.lcvnom      ,
                         ctb02m00.lcvextcod   ,
                         ctb02m00.aviestnom   ,
                         ctb02m00.segnumdig   ,
                         ctb02m00.segnom      ,
                         ctb02m00.pestip      ,
                         ctb02m00.cgccpfnum   ,
                         ctb02m00.cgcord      ,
                         ctb02m00.cgccpfdig   ,
                         ctb02m00.socpgtdoctip,
                         ctb02m00.socpgtdocdes,
                         ctb02m00.nfsnum      ,
                         ctb02m00.socfatentdat,
                         ctb02m00.socfatpgtdat,
                         ctb02m00.socfatitmqtd,
                         ctb02m00.socfattotvlr,
                         ctb02m00.socfatrelqtd,
                         ctb02m00.linhamsg,
                         ctb02m00.empcod,
                         ctb02m00.empnom
                         
         display by name  ctb02m00.empresa attribute (reverse) #PSI 205206
      else
         error " Nao ha' protocolo nesta direcao!"
         initialize ctb02m00.*    to null
         initialize k_ctb02m00.*  to null
      end if
   else
      error " Nao ha' protocolo nesta direcao!"
      initialize ctb02m00.*    to null
      initialize k_ctb02m00.*  to null
   end if

   return k_ctb02m00.*, ctb02m00.*

end function  ###  anterior_ctb02m00

#------------------------------------------------------------
function modifica_ctb02m00(k_ctb02m00, ctb02m00)
#------------------------------------------------------------

   define k_ctb02m00   record
          socopgnum    like dbsmopg.socopgnum
   end record

   define ctb02m00     record
          socopgnum    like dbsmopg.socopgnum,
          socopgsitcod like dbsmopg.socopgsitcod,
          socopgsitdes char (30),
          empresa      char (5),         #PSI 205206
          lcvcod       like datklocadora.lcvcod,
          lcvnom       like datklocadora.lcvnom,
          lcvextcod    like datkavislocal.lcvextcod,
          aviestnom    like datkavislocal.aviestnom,
          pestip       like dbsmopg.pestip,
          cgccpfnum    like dbsmopg.cgccpfnum,
          cgcord       like dbsmopg.cgcord,
          cgccpfdig    like dbsmopg.cgccpfdig,
          socpgtdoctip like dbsmopg.socpgtdoctip,
          socpgtdocdes char(15),
          nfsnum       like dbsmopgitm.nfsnum,
          socfatentdat like dbsmopg.socfatentdat,
          socfatpgtdat like dbsmopg.socfatpgtdat,
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          socfatrelqtd like dbsmopg.socfatrelqtd,
          linhamsg     char (70),
          segnumdig    like dbsmopg.segnumdig,
          segnom       like gsakseg.segnom,
          favtip       smallint,
          favtipdes    char(12),
          favtipnom1   char(40),
          favtipnom2   char(40),
          empcod       like dbsmopg.empcod,
          empnom       like gabkemp.empnom
   end record
   
   define ws           record
          aviestcod    like datkavislocal.aviestcod,
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          segnumdig    like dbsmopg.segnumdig
   end record
   
   define lr_retorno record
          retorno   smallint,      
          mensagem  char(60)         
   end record
   
   define l_sqlca   integer , 
          l_sqlerr  integer ,
          l_succod  like datkavislocal.succod
   
   call input_ctb02m00("a", k_ctb02m00.* , ctb02m00.*) returning ctb02m00.*

   if int_flag  then
      let int_flag = false
      initialize k_ctb02m00.*  to null
      initialize ctb02m00.*    to null
      error " Operacao cancelada!"
      clear form
      return k_ctb02m00.*
   end if

   initialize ws.*   to null
   initialize lr_retorno.* to null
   initialize l_succod to null
   
   select socfatitmqtd   , socfattotvlr   , segnumdig
     into ws.socfatitmqtd, ws.socfattotvlr, ws.segnumdig
     from dbsmopg
    where socopgnum = k_ctb02m00.socopgnum

   if ctb02m00.favtip = 4  # Locadora
      then
      declare c_avis2 cursor for
      select aviestcod, succod
        from datkavislocal
       where lcvcod    = ctb02m00.lcvcod
         and lcvextcod = ctb02m00.lcvextcod
  
      foreach c_avis2 into ws.aviestcod, l_succod
          exit foreach
      end foreach
   else 
      initialize l_succod to null  # info so inserida quando favtip = 4 ou na capa da OP
   end if

   whenever error continue

   begin work
      update dbsmopg  set (lcvcod,
                           aviestcod,
                           segnumdig,
                           pestip,
                           cgccpfnum,
                           cgcord,
                           cgccpfdig,
                           socfatentdat,
                           socfatpgtdat,
                           socfatitmqtd,
                           socfattotvlr,
                           socfatrelqtd,
                           atldat,
                           funmat,
                           succod,
                           socpgtdoctip,
                           favtip,
                           nfsnum,
                           empcod)
                       =  (ctb02m00.lcvcod,
                           ws.aviestcod,
                           ctb02m00.segnumdig,
                           ctb02m00.pestip,
                           ctb02m00.cgccpfnum,
                           ctb02m00.cgcord,
                           ctb02m00.cgccpfdig,
                           ctb02m00.socfatentdat,
                           ctb02m00.socfatpgtdat,
                           ctb02m00.socfatitmqtd,
                           ctb02m00.socfattotvlr,
                           ctb02m00.socfatrelqtd,
                           today,
                           g_issk.funmat,
                           l_succod,
                           ctb02m00.socpgtdoctip,
                           ctb02m00.favtip,
                           ctb02m00.nfsnum,
                           ctb02m00.empcod)
      where socopgnum  =  k_ctb02m00.socopgnum
      
      whenever error stop
      
      if sqlca.sqlcode <>  0  then
         error " Erro (",sqlca.sqlcode,") na alteração da protocolo!"
         rollback work
         initialize ctb02m00.*   to null
         initialize k_ctb02m00.* to null
         return k_ctb02m00.*
      -- else
         -- error " Alteracao efetuada com sucesso!"
      end if
      
      # update NFSNUM nos itens das OP
      if ctb02m00.nfsnum is not null and
         ctb02m00.nfsnum > 0
         then
         
         call ctd20g01_upd_nfs_opgitm(k_ctb02m00.socopgnum, 
                                      ctb02m00.socopgsitcod,
                                      ctb02m00.nfsnum)
                            returning l_sqlca, l_sqlerr
         
         if l_sqlca != 0
            then
            if l_sqlca != 100
               then
               if l_sqlca = 99
                  then
                  error " Não permitido alterar Documento Fiscal nesta OP "
                  sleep 2
               else
                  error " Erro na atualização do Documento Fiscal ", l_sqlca
                  rollback work
                  initialize ctb02m00.*   to null
                  initialize k_ctb02m00.* to null
                  return k_ctb02m00.*
               end if
            end if
         else
            if sqlca.sqlerrd[3] = 0
               then
               error " OP ainda não possui itens, Documento Fiscal gravado na OP "
               sleep 1
            else
               error " Atualização do Documento Fiscal ok em ", l_sqlerr, " itens"
               sleep 1
               
               # num de NF gravado nos itens, atualiza etapa para "Digitada"
               call cts50g00_atualiza_etapa(k_ctb02m00.socopgnum, 3, 
                                            g_issk.funmat)
                                  returning lr_retorno.retorno,
                                            lr_retorno.mensagem
                                            
               if lr_retorno.retorno != 1
                  then
                  error lr_retorno.mensagem
                  sleep 2
                  rollback work
                  initialize ctb02m00.*   to null
                  initialize k_ctb02m00.* to null
                  return k_ctb02m00.*
               end if
            end if
         end if
      end if
      
   commit work
   error " Alteracao efetuada com sucesso!"
   sleep 1
   
   #---------------------------------------------------
   # Se houver alteracao na qtde/valor fazer batimento
   #---------------------------------------------------
   if ctb02m00.socfatitmqtd <> ws.socfatitmqtd   or
      ctb02m00.socfattotvlr <> ws.socfattotvlr   then
      call ctb02m09(k_ctb02m00.socopgnum, ctb02m00.lcvcod, ws.aviestcod,
                    ws.segnumdig)
   end if
   
   clear form
   message ""
   return k_ctb02m00.*

end function  ###  modifica_ctb02m00

#------------------------------------------------------------
function inclui_ctb02m00()
#------------------------------------------------------------

   define k_ctb02m00   record
          socopgnum    like dbsmopg.socopgnum
   end record

   define ctb02m00     record
          socopgnum    like dbsmopg.socopgnum,
          socopgsitcod like dbsmopg.socopgsitcod,
          socopgsitdes char (30),
          empresa      char (5),         #PSI 205206
          lcvcod       like datklocadora.lcvcod,
          lcvnom       like datklocadora.lcvnom,
          lcvextcod    like datkavislocal.lcvextcod,
          aviestnom    like datkavislocal.aviestnom,
          pestip       like dbsmopg.pestip,
          cgccpfnum    like dbsmopg.cgccpfnum,
          cgcord       like dbsmopg.cgcord,
          cgccpfdig    like dbsmopg.cgccpfdig,
          socpgtdoctip like dbsmopg.socpgtdoctip,
          socpgtdocdes char(15),
          nfsnum       like dbsmopgitm.nfsnum,
          socfatentdat like dbsmopg.socfatentdat,
          socfatpgtdat like dbsmopg.socfatpgtdat,
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          socfatrelqtd like dbsmopg.socfatrelqtd,
          linhamsg     char (70),
          segnumdig    like dbsmopg.segnumdig,
          segnom       like gsakseg.segnom,
          favtip       smallint,
          favtipdes    char(12),
          favtipnom1   char(40),
          favtipnom2   char(40),
          empcod       like dbsmopg.empcod,
          empnom       like gabkemp.empnom
   end record
   
   define ws record
          aviestcod  like datkavislocal.aviestcod,
          succod     like datkavislocal.succod,
          time       char(08),
          hora       char(05),
          retorno    smallint,      
          mensagem   char(60)           
   end record
   
   define prompt_key   char (01)

   clear form

   initialize ctb02m00.*   to null
   initialize k_ctb02m00.* to null
   initialize ws.*         to null

   call input_ctb02m00("i",k_ctb02m00.*, ctb02m00.*) returning ctb02m00.*

   if int_flag  then
      let int_flag = false
      initialize ctb02m00.*  to null
      error " Operacao cancelada!"
      clear form
      return
   end if
   
   if ctb02m00.favtip = 4  # Locadora
      then
      declare c_avis cursor for
       select aviestcod, succod
         from datkavislocal
        where lcvcod    = ctb02m00.lcvcod
          and lcvextcod = ctb02m00.lcvextcod
   
      foreach c_avis into ws.aviestcod, ws.succod
          exit foreach
      end foreach
   end if

   declare c_ctb02m00m  cursor with hold  for
      select max(socopgnum)
      from dbsmopg
      where socopgnum > 0
      
   foreach c_ctb02m00m into ctb02m00.socopgnum
       exit foreach
   end foreach
   
   if ctb02m00.socopgnum is null
      then
      let ctb02m00.socopgnum = 0
   end if
   
   let ctb02m00.socopgnum = ctb02m00.socopgnum + 1
   let ws.time = time
   let ws.hora = ws.time[1,5]
   
   whenever error continue
   
   begin work
      insert into dbsmopg (socopgnum,
                           socopgsitcod,
                           lcvcod,
                           aviestcod,
                           segnumdig,
                           pestip,
                           cgccpfnum,
                           cgcord,
                           cgccpfdig,
                           socfatentdat,
                           socfatpgtdat,
                           socfatitmqtd,
                           socfattotvlr,
                           socfatrelqtd,
                           socopgorgcod,
                           atldat,
                           funmat,
                           soctip,
                           succod,
                           favtip,
                           nfsnum,
                           empcod,
                           socpgtdoctip)
                  values  (ctb02m00.socopgnum,
                           ctb02m00.socopgsitcod,
                           ctb02m00.lcvcod,
                           ws.aviestcod,
                           ctb02m00.segnumdig,
                           ctb02m00.pestip,
                           ctb02m00.cgccpfnum,
                           ctb02m00.cgcord,
                           ctb02m00.cgccpfdig,
                           ctb02m00.socfatentdat,
                           ctb02m00.socfatpgtdat,
                           ctb02m00.socfatitmqtd,
                           ctb02m00.socfattotvlr,
                           ctb02m00.socfatrelqtd,
                           1 ,
                           today,
                           g_issk.funmat,
                           2,
                           ws.succod,
                           ctb02m00.favtip,
                           ctb02m00.nfsnum,
                           ctb02m00.empcod,
                           ctb02m00.socpgtdoctip)

      if sqlca.sqlcode <>  0   then
         error " Erro (",sqlca.sqlcode,") na inclusao do protocolo!"
         rollback work
         return
      end if
      
      # PSI 211074 - BURINI
      call cts50g00_insere_etapa(ctb02m00.socopgnum, 1, g_issk.funmat)
           returning ws.retorno, 
                     ws.mensagem

      if ws.retorno <>  1   then
         error ws.mensagem
         rollback work
         return
      end if

   commit work

   whenever error stop

   display by name ctb02m00.socopgnum attribute (reverse)
   error " Verifique o codigo do protocolo e tecle ENTER!"
   prompt "" for char prompt_key
   
   error " Inclusao efetuada com sucesso! "
   sleep 1
   
   error "Digite o numero do Documento Fiscal na OP apos a digitacao dos itens"
   sleep 1
   
   clear form

end function  ###  inclui_ctb02m00

#--------------------------------------------------------------------
function input_ctb02m00(operacao_aux, k_ctb02m00, ctb02m00)
#--------------------------------------------------------------------

   define operacao_aux char (01)

   define k_ctb02m00   record
          socopgnum    like dbsmopg.socopgnum
   end record

   define ctb02m00     record
          socopgnum    like dbsmopg.socopgnum,
          socopgsitcod like dbsmopg.socopgsitcod,
          socopgsitdes char (30),
          empresa      char (5),         #PSI 205206
          lcvcod       like datklocadora.lcvcod,
          lcvnom       like datklocadora.lcvnom,
          lcvextcod    like datkavislocal.lcvextcod,
          aviestnom    like datkavislocal.aviestnom,
          pestip       like dbsmopg.pestip,
          cgccpfnum    like dbsmopg.cgccpfnum,
          cgcord       like dbsmopg.cgcord,
          cgccpfdig    like dbsmopg.cgccpfdig,
          socpgtdoctip like dbsmopg.socpgtdoctip,
          socpgtdocdes char(15),
          nfsnum       like dbsmopgitm.nfsnum,
          socfatentdat like dbsmopg.socfatentdat,
          socfatpgtdat like dbsmopg.socfatpgtdat,
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          socfatrelqtd like dbsmopg.socfatrelqtd,
          linhamsg     char (70),
          segnumdig    like dbsmopg.segnumdig,
          segnom       like gsakseg.segnom,
          favtip       smallint,
          favtipdes    char(12),
          favtipnom1   char(40),
          favtipnom2   char(40),
          empcod       like dbsmopg.empcod,
          empnom       like gabkemp.empnom
   end record

   define ws           record
          favtipsva    smallint,
          socopgnum    like dbsmopg.socopgnum,
          diasem       smallint,
          dataini      date,
          datafim      date,
          mensagem     char (40),
          cgccpfdig    like dbsmopg.cgccpfdig,
          pestipcad    like dbsmopg.pestip,
          cgccpfnumcad like dbsmopg.cgccpfnum,
          cgccpfdigcad like dbsmopg.cgccpfdig,
          socopgdscvlr like dbsmopg.socopgdscvlr,
          confirma2    char (01),
          aviestcod    like datkavislocal.aviestcod
   end record
   
   define lr_seg_ita record               
        segnom   like datmitaapl.segnom,  
        errocod  smallint,                
        erromsg  char(80)                 
   end record                             
    
   define l_ret       char (01),
          l_res       smallint ,
          l_msg       char(80) ,
          l_cliemp    char(01)
          
   let int_flag    = false
   let l_ret       = null
   
   initialize l_cliemp to null
   initialize ws.*   to null
   initialize lr_seg_ita.* to null
   
   input by name ctb02m00.socopgnum,
                 ctb02m00.favtip,
                 ctb02m00.empcod,
                 ctb02m00.lcvcod,
                 ctb02m00.lcvextcod,
                 ctb02m00.segnumdig,
                 ctb02m00.pestip,
                 ctb02m00.cgccpfnum,
                 ctb02m00.cgcord,
                 ctb02m00.cgccpfdig,
                 ctb02m00.socpgtdoctip,
                 ctb02m00.nfsnum,
                 ctb02m00.socfatentdat,
                 ctb02m00.socfatpgtdat,
                 ctb02m00.socfatitmqtd,
                 ctb02m00.socfattotvlr,
                 ctb02m00.socfatrelqtd   without defaults

      before field socopgnum
             if operacao_aux = "i"   then
                let ctb02m00.socopgsitcod = 1
                let ctb02m00.socopgsitdes = "NAO ANALISADA"
                display by name ctb02m00.socopgsitcod
                display by name ctb02m00.socopgsitdes
             end if
             next field favtip
             display by name ctb02m00.socopgnum attribute (reverse)

      after  field socopgnum
             display by name ctb02m00.socopgnum
             
             #  initialize ctb02m00.lcvcod     to null
             #  initialize ctb02m00.lcvnom     to null
             #  initialize ctb02m00.lcvextcod  to null
             #  initialize ctb02m00.aviestnom  to null
             #  initialize ctb02m00.pestip     to null
             #  initialize ctb02m00.cgccpfnum  to null
             #  initialize ctb02m00.cgcord     to null
             #  initialize ctb02m00.cgccpfdig  to null
             #  display by name ctb02m00.lcvcod
             #  display by name ctb02m00.lcvnom
             #  display by name ctb02m00.lcvextcod
             #  display by name ctb02m00.aviestnom
             #  display by name ctb02m00.pestip
             #  display by name ctb02m00.cgccpfnum
             #  display by name ctb02m00.cgcord
             #  display by name ctb02m00.cgccpfdig

      before field favtip
             if operacao_aux  =  "a"   then
                if ctb02m00.socopgsitcod  >  1 then  #--> passou do protocolo
                   next field socfatpgtdat
                end if
             end if
             display by name ctb02m00.favtip   attribute (reverse)
             let ws.favtipsva = ctb02m00.favtip

      after  field favtip
             display by name ctb02m00.favtip

             if ctb02m00.favtip   is null   then
                error " Tipo do favorecido deve ser informado!"
                next field favtip
             end if

             if ws.favtipsva  is not null and
                ws.favtipsva  <>  ctb02m00.favtip
                then
                initialize ctb02m00.segnumdig,
                           ctb02m00.segnom   ,
                           ctb02m00.pestip   ,
                           ctb02m00.cgccpfnum,
                           ctb02m00.cgcord   ,
                           ctb02m00.cgccpfdig,
                           ctb02m00.lcvcod   ,
                           ctb02m00.lcvnom   ,
                           ctb02m00.lcvextcod,
                           ctb02m00.aviestnom  to null
                           
                display by name ctb02m00.segnumdig,
                                ctb02m00.segnom   ,
                                ctb02m00.pestip   ,
                                ctb02m00.cgccpfnum,
                                ctb02m00.cgcord   ,
                                ctb02m00.cgccpfdig,
                                ctb02m00.lcvcod   ,
                                ctb02m00.lcvnom   ,
                                ctb02m00.lcvextcod,
                                ctb02m00.aviestnom
             end if
             
             case ctb02m00.favtip
                  when  3  let ctb02m00.favtipdes = "SEGURADO"
                           display by name ctb02m00.favtipdes
                           next field empcod
                           
                  when  4  let ctb02m00.favtipdes = "LOCADORA"
                           display by name ctb02m00.favtipdes
                           next field empcod

                  otherwise
                           error " Tipo de favorecido invalido!"
                           next field favtip
             end case
             
      before field empcod
             display by name ctb02m00.empcod    attribute (reverse)
      
             # padrao empresa Porto
             if ctb02m00.empcod is null
                then
                let ctb02m00.empcod = 1
             end if
             
      after field empcod
             display by name ctb02m00.empcod

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field favtip
             end if
             
             if ctb02m00.empcod is not null 
                then
                call cty14g00_empresa(1, ctb02m00.empcod)
                     returning l_ret, l_msg, ctb02m00.empnom
                     
                if l_ret != 1
                   then
                   error l_msg clipped
                   let ctb02m00.empcod = null
                   next field empcod
                end if
             else
                call cty14g00_popup_empresa()
                     returning l_ret, ctb02m00.empcod, ctb02m00.empnom
                if ctb02m00.empcod is null 
                   then
                   next field empcod
                end if
             end if
             
              
             call cty14g00_empresa_abv(ctb02m00.empcod)
                  returning l_ret, l_msg, ctb02m00.empresa
                  
             display by name ctb02m00.empcod, ctb02m00.empnom, ctb02m00.empresa
             
             case ctb02m00.favtip
                when  3
                   if ctb02m00.empcod = 35 or ctb02m00.empcod = 84
                      then
                      initialize ctb02m00.segnumdig to null
                      display by name ctb02m00.segnumdig
                      next field pestip
                   else
                      next field segnumdig
                   end if
                when  4  
                   next field lcvcod
                otherwise
                   error ' Favorecido não definido '
                   next field favtip
             end case
             
      before field lcvcod
             display by name ctb02m00.lcvcod    attribute (reverse)
             
      after  field lcvcod
             display by name ctb02m00.lcvcod

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field empcod
             end if

             if ctb02m00.lcvcod is null then
                error " Codigo da Locadora e' item obrigatorio!"
                call ctc30m01() returning ctb02m00.lcvcod
                next field lcvcod
             end if

             initialize ctb02m00.lcvnom to null

             select lcvnom , cgccpfnum, cgcord, cgccpfdig
               into ctb02m00.lcvnom, ctb02m00.cgccpfnum,
                    ctb02m00.cgcord, ctb02m00.cgccpfdig
               from datklocadora
              where lcvcod = ctb02m00.lcvcod

             if sqlca.sqlcode <> 0  then
                error " Locadora nao cadastrada!"
                next field lcvcod
             else
                display by name ctb02m00.lcvnom
             end if

      before field lcvextcod
             display by name ctb02m00.lcvextcod attribute (reverse)

      after  field lcvextcod
             display by name ctb02m00.lcvextcod

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field  lcvcod
             end if

             if ctb02m00.lcvextcod  is null then
                error " Codigo da loja e' item obrigatorio!"
                call ctc30m02(ctb02m00.lcvcod)
                    returning ctb02m00.lcvextcod
                next field lcvextcod
             end if

             initialize ctb02m00.aviestnom to null

             select aviestnom
               into ctb02m00.aviestnom
               from datkavislocal
              where lcvcod    = ctb02m00.lcvcod
                and lcvextcod = ctb02m00.lcvextcod

             if sqlca.sqlcode <> 0  then
                error " Loja/Locadora nao cadastrada!"
                next field lcvextcod
             else
                display by name ctb02m00.aviestnom
             end if

             let ctb02m00.pestip = "J"
             display by name ctb02m00.pestip
             display by name ctb02m00.cgccpfnum
             display by name ctb02m00.cgcord
             display by name ctb02m00.cgccpfdig

             let ws.pestipcad    = ctb02m00.pestip
             let ws.cgccpfnumcad = ctb02m00.cgccpfnum
             let ws.cgccpfdigcad = ctb02m00.cgccpfdig
             
             next field pestip

      before field segnumdig
             display by name ctb02m00.segnumdig attribute (reverse)
             
             initialize ctb02m00.segnom     to null
             initialize ctb02m00.pestip     to null
             initialize ctb02m00.cgccpfnum  to null
             initialize ctb02m00.cgcord     to null
             initialize ctb02m00.cgccpfdig  to null
             display by name ctb02m00.segnom
             display by name ctb02m00.pestip
             display by name ctb02m00.cgccpfnum
             display by name ctb02m00.cgcord
             display by name ctb02m00.cgccpfdig

      after  field segnumdig
             display by name ctb02m00.segnumdig
             
             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field empcod
             end if
             
             if ctb02m00.empcod is null
                then
                error ' Empresa não definida '
                next field empcod
             end if
             
             # PSI 198404 People: tratamento reembolso Azul e ISAR, cliente nao tem cadastro corporativo
             if ctb02m00.empcod = 35 or ctb02m00.empcod = 84
                then
                next field pestip
             else
                if ctb02m00.segnumdig is null
                   then
                   error " Codigo do segurado deve ser informado! "
                   sleep 1
                   next field segnumdig
                else
                   call ctd20g07_dados_cli(ctb02m00.segnumdig)
                        returning l_res, l_msg,
                                  ctb02m00.segnom,
                                  ctb02m00.cgccpfnum,
                                  ctb02m00.cgcord,
                                  ctb02m00.cgccpfdig,
                                  ctb02m00.pestip
                   
                   if l_res = 0
                      then
                      display by name ctb02m00.segnom
                      display by name ctb02m00.pestip
                      display by name ctb02m00.cgccpfnum
                      display by name ctb02m00.cgcord
                      display by name ctb02m00.cgccpfdig
                   else
                      error l_msg clipped
                      initialize ctb02m00.segnom     to null
                      initialize ctb02m00.pestip     to null
                      initialize ctb02m00.cgccpfnum  to null
                      initialize ctb02m00.cgcord     to null
                      initialize ctb02m00.cgccpfdig  to null
                      display by name ctb02m00.segnom
                      display by name ctb02m00.pestip
                      display by name ctb02m00.cgccpfnum
                      display by name ctb02m00.cgcord
                      display by name ctb02m00.cgccpfdig
                      next field segnumdig
                   end if
                end if
             end if
             
      before field pestip
             display by name ctb02m00.pestip   attribute(reverse)

      after  field pestip
             display by name ctb02m00.pestip

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                if ctb02m00.favtip = 4
                   then
                   next field lcvcod
                else
                   if ctb02m00.empcod = 35 or ctb02m00.empcod = 84
                      then
                      next field empcod
                   else
                      next field segnumdig
                   end if
                end if
             end if

             if ctb02m00.pestip   is null   then
                error " Tipo de pessoa deve ser informado!"
                next field pestip
             end if

             if ctb02m00.pestip  <>  "F"   and
                ctb02m00.pestip  <>  "J"   then
                error " Tipo de pessoa invalido!"
                next field pestip
             end if

             if ctb02m00.pestip  =  "F"   then
                initialize ctb02m00.cgcord  to null
                display by name ctb02m00.cgcord
             end if

      before field cgccpfnum
             display by name ctb02m00.cgccpfnum   attribute(reverse)

      after  field cgccpfnum
             display by name ctb02m00.cgccpfnum

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field pestip
             end if

             if ctb02m00.cgccpfnum   is null   or
                ctb02m00.cgccpfnum   =  0      then
                error " Numero do Cgc/Cpf deve ser informado!"
                next field cgccpfnum
             end if

             if ctb02m00.pestip  =  "F"   then
                next field cgccpfdig
             end if

      before field cgcord
             display by name ctb02m00.cgcord   attribute(reverse)

      after  field cgcord
             display by name ctb02m00.cgcord

             if fgl_lastkey() = fgl_keyval ("up")   or
                fgl_lastkey() = fgl_keyval ("left") then
                next field cgccpfnum
             end if

             if ctb02m00.cgcord   is null or 
                ctb02m00.cgcord =  0
                then
                error " Filial do Cgc/Cpf deve ser informada!"
                next field cgcord
             end if

      before field cgccpfdig
             display by name ctb02m00.cgccpfdig  attribute(reverse)

      after  field cgccpfdig
             display by name ctb02m00.cgccpfdig

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                if ctb02m00.pestip  =  "J"  then
                   next field cgcord
                else
                   next field cgccpfnum
                end if
             end if

             if ctb02m00.cgccpfdig is null
                then
                error " Digito do Cgc/Cpf deve ser informado!"
                next field cgccpfdig
             end if

             if ctb02m00.pestip  =  "J"
                then
                call F_FUNDIGIT_DIGITOCGC(ctb02m00.cgccpfnum, ctb02m00.cgcord)
                     returning ws.cgccpfdig
             else
                call F_FUNDIGIT_DIGITOCPF(ctb02m00.cgccpfnum)
                     returning ws.cgccpfdig
             end if

             if ws.cgccpfdig is null or
                ctb02m00.cgccpfdig <> ws.cgccpfdig 
                then
                error " Digito Cgc/Cpf incorreto!"
                next field cgccpfnum
             else
               case ctb02m00.empcod
                   when 35
                   	if ctb02m00.favtip = 3 then # Reembolso Azul
                   	   let l_res = 0   
                           let l_msg = null
                           call ctd02g01_azlapl_sel(2, ctb02m00.cgccpfnum,
                                                       ctb02m00.cgcord,
                                                       ctb02m00.cgccpfdig)
                                 returning l_res, l_msg, ctb02m00.segnom
                            if l_res = 0
                               then
                               let ctb02m00.segnumdig = 35353535  # codigo generico reembolso Azul
                               display by name ctb02m00.segnom
                            else
                               error ' ', l_msg clipped
                               sleep 1
                               initialize ctb02m00.segnom, ctb02m00.segnumdig to null
                               display by name ctb02m00.segnom, ctb02m00.segnumdig
                               next field cgccpfdig
                            end if
                   	end if 
                   when	84   
                      if ctb02m00.favtip = 3 then      # Reembolso Isar          
                         call ctb00g01_seg_itau(ctb02m00.cgccpfnum,
                                                ctb02m00.cgcord,
                                                ctb02m00.cgccpfdig)
                              returning lr_seg_ita.segnom, 
                                        lr_seg_ita.errocod,
                                        lr_seg_ita.erromsg 
                         
                         if lr_seg_ita.errocod <> 0 then
                            error lr_seg_ita.erromsg 
                            next field cgccpfnum 
                         else
                            let ctb02m00.segnumdig = 84848484  # codigo generico reembolso ISAR
                            display by name ctb02m00.segnom                                    
                         end if
                      end if  
                end case
             end if 
             
      before field socpgtdoctip
             display by name ctb02m00.socpgtdoctip attribute (reverse)
             
      after  field socpgtdoctip
             display by name ctb02m00.socpgtdoctip
             
             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field cgccpfdig
             end if
             
             if ctb02m00.socpgtdoctip <> 1 and
                ctb02m00.socpgtdoctip <> 2 and
                ctb02m00.socpgtdoctip <> 3 and
                ctb02m00.socpgtdoctip <> 4 
                then
                error " Informe o Tipo de Docto: 1-Nota Fiscal, 2-Recibo, 3-R.P.A., 4-NF Eletronica"
                next field socpgtdoctip
             end if
             
             if ctb02m00.socpgtdoctip is null and
                ctb02m00.nfsnum is not null
                then
                error " Digite o tipo de documento "
                next field socpgtdoctip
             end if
             
             if ctb02m00.socpgtdoctip =  0  or
                ctb02m00.socpgtdoctip is null
                then
                initialize ctb02m00.socpgtdocdes to null
                display by name ctb02m00.socpgtdoctip, ctb02m00.socpgtdocdes
                next field socfatentdat
             else
                initialize m_dominio.* to null
                
                call cty11g00_iddkdominio('socpgtdoctip', ctb02m00.socpgtdoctip)
                     returning m_dominio.*
                     
                if m_dominio.erro = 1
                   then
                   let ctb02m00.socpgtdocdes = m_dominio.cpodes clipped
                else
                   initialize ctb02m00.socpgtdocdes to null
                   error "Tipo documento fiscal: ", m_dominio.mensagem
                end if
                display by name ctb02m00.socpgtdoctip, ctb02m00.socpgtdocdes
             end if
             
      # PSI 198404 - Por enquanto a informacao so serve para a verificacao se 
      # a NF esta duplicada pois no momento do protocolo a OP nao tem itens e 
      # nao e possivel gravar o NFSNUM
      before field nfsnum
             display by name ctb02m00.nfsnum    attribute (reverse)
      
      after  field nfsnum 
             display by name ctb02m00.nfsnum
             
             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field socpgtdoctip
             end if
             
             # Retirado a pedido do PS em 22/06/2009
             # if ctb02m00.socpgtdoctip = 1 or 
             #    ctb02m00.socpgtdoctip = 4 
             #    then
             #    if ctb02m00.nfsnum =  0 or
             #       ctb02m00.nfsnum is null then
             #       error " Informe o Numero do Documento Fiscal "
             #       next field nfsnum
             #    end if
             # end if
             
             if ctb02m00.nfsnum    <>  0    and
                ctb02m00.nfsnum is not null then
                
                if ctb02m00.socopgnum is null then
                   let ctb02m00.socopgnum = 0
                end if
                
                call ctb00g01_vernfs(2         #---> soctip =  2 - Carro Extra
                                    ,ctb02m00.pestip
                                    ,ctb02m00.cgccpfnum
                                    ,ctb02m00.cgcord
                                    ,ctb02m00.cgccpfdig
                                    ,ctb02m00.socopgnum
                                    ,ctb02m00.socpgtdoctip
                                    ,ctb02m00.nfsnum)
                   returning l_ret
                   
                if l_ret = "S" then
                   error " Documento duplicado! "
                   next field nfsnum
                end if
             end if
             
      before field socfatentdat
             if operacao_aux  =  "a"  then
                display by name ctb02m00.socfatentdat
                next field socfatpgtdat
             end if

             display by name ctb02m00.socfatentdat    attribute (reverse)

      after  field socfatentdat
             display by name ctb02m00.socfatentdat

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                if ctb02m00.socpgtdoctip =  0    or
                   ctb02m00.socpgtdoctip is null then
                   next field cgccpfdig
                else
                   next field cgccpfdig
                end if
             end if

             if ctb02m00.socfatentdat   is null    then
                error " Data de entrega deve ser informada!"
                next field socfatentdat
             end if

             if ctb02m00.socfatentdat  >  today   then
                error " Data de entrega nao deve ser maior que data atual!"
                next field socfatentdat
             end if

             if ctb02m00.socfatentdat  <  today - 2 units day   then
                error " Data entrega nao deve ser anterior a 3 dias!"
                next field socfatentdat
             end if

             let ws.diasem = weekday(ctb02m00.socfatentdat)
             if ws.diasem  =  0    or
                ws.diasem  =  6    then
                error " Data de entrega nao deve ser sabado ou domingo!"
                next field socfatentdat
             end if

             initialize  ws.socopgnum   to null

      before field socfatpgtdat
             display by name ctb02m00.socfatpgtdat    attribute (reverse)

      after  field socfatpgtdat
             display by name ctb02m00.socfatpgtdat

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                if operacao_aux  =  "a"   then
                   if ctb02m00.socopgsitcod  >  1   then
                      error " Data entrega/favorecido nao deve ser alterado!"
                      next field socfatpgtdat
                   else
                      next field cgccpfdig
                   end if
                end if
                next field socfatentdat
             end if
             
             if ctb02m00.socfatpgtdat  is null  then
                error " Data de pagamento deve ser informada!"
                next field socfatpgtdat
             end if
             
             if ctb02m00.socfatpgtdat  <  today  then
                error " Data de pagamento nao deve ser menor que data atual!"
                next field socfatpgtdat
             end if
             
             let ws.diasem = weekday(ctb02m00.socfatpgtdat)
             if ws.diasem  =  0    or
                ws.diasem  =  6    then
                error " Data de pagamento nao deve ser sabado ou domingo!"
                next field socfatpgtdat
             end if
             
             if dias_uteis(ctb02m00.socfatpgtdat, 0, "", "S", "S") = ctb02m00.socfatpgtdat
                then
             else
                if ctb02m00.socfatpgtdat <> "18/10/1999" then  # dia securitario
                   error " Data de pagamento nao deve ser feriado!"
                   next field socfatpgtdat
                end if
             end if
             
             if ctb02m00.socfatpgtdat  >=  today + 30 units day  then
                error " Data pagamento nao deve superior a 30 dias!"
                next field socfatpgtdat
             end if
             
             if dias_entre_datas(today, ctb02m00.socfatpgtdat, "", "S", "S") <= 4 
                then
                error " Pagamento deve ser programado c/ 4 DIAS DE ANTECEDENCIA!"
                if g_issk.acsnivcod < 8  then
                   next field socfatpgtdat
                else
                   call cts08g01("A", "N", "",
                                 "DEPTO. FINANCEIRO DEVE SER AVISADO",
                                 "ANTES DA GERACAO DA ORDEM DE PAGTO!","")
                        returning ws.confirma2

                   next field socfatpgtdat
                end if
             end if
             
             #------------------------------------------------------
             # Avisar se existe O.P. para o mesmo prestador/dt pagto
             #------------------------------------------------------
             initialize  ws.socopgnum  to null
             initialize  ws.dataini    to null
             initialize  ws.datafim    to null
             initialize  ws.mensagem   to null

             if operacao_aux       = "i"  then
                let ws.dataini = ctb02m00.socfatpgtdat - 5 units day
                let ws.datafim = ctb02m00.socfatpgtdat + 5 units day

                if ctb02m00.favtip = 4  # Locadora
                   then
                   #psi175544
                   open cctb02m0001 using ctb02m00.lcvcod,ctb02m00.lcvextcod
                   whenever error continue
                   fetch cctb02m0001 into ws.aviestcod
                   whenever error stop
   
                   if sqlca.sqlcode <> 0 then
                      if sqlca.sqlcode = 100 then
                         error ' Registro nao encontrado em datkavislocal	'
                         sleep 2
                      else
                        error ' Erro SELECT datkavislocal:	',sqlca.sqlcode,'|',
                              sqlca.sqlerrd[2] 
                        sleep 2
                        let int_flag = true
                        exit input
                      end if
                   end if
   
                   open cctb02m0002 using ws.dataini, ws.datafim, 
                                          ctb02m00.lcvcod, ws.aviestcod
   
                   #fim psi175544
   
                   foreach  cctb02m0002 into ws.socopgnum
                      exit foreach
                   end foreach

                else
                
                   whenever error continue
                   open c_opg_seg_sel using ws.dataini, ws.datafim, 
                                            ctb02m00.segnumdig
                   whenever error stop
                   
                   foreach c_opg_seg_sel into ws.socopgnum
                      exit foreach
                   end foreach
                end if
                
                if ws.socopgnum  is not null
                   then
                   let ws.mensagem = "     VERIFIQUE O.P. NUMERO : ",
                                     ws.socopgnum using "&&&&&&&&"
                   call cts08g01("A", "N",
                                 "JA' EXISTE O.P. PARA PAGAMENTO EM UMA",
                                "DATA PROXIMA A DATA INFORMADA",
                                 "",
                                 ws.mensagem)
                        returning ws.confirma2
                end if
             end if

      before field socfatitmqtd
             display by name ctb02m00.socfatitmqtd    attribute (reverse)

      after  field socfatitmqtd
             display by name ctb02m00.socfatitmqtd

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field socfatpgtdat
             end if

             if ctb02m00.socfatitmqtd   is null    or
                ctb02m00.socfatitmqtd   =  0       then
                error " Quantidade total de servicos deve ser informada!"
                next field socfatitmqtd
             end if

      before field socfattotvlr
             display by name ctb02m00.socfattotvlr    attribute (reverse)

      after  field socfattotvlr
             display by name ctb02m00.socfattotvlr

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field socfatitmqtd
             end if

             if ctb02m00.socfattotvlr   is null    or
                ctb02m00.socfattotvlr   =  0       then
                error " Valor total dos servicos deve ser informado!"
                next field socfattotvlr
             end if

             if operacao_aux = "a"  then
                initialize ws.socopgdscvlr to null

                select socopgdscvlr
                  into ws.socopgdscvlr
                  from dbsmopg
                 where socopgnum = k_ctb02m00.socopgnum

                if ws.socopgdscvlr is not null  then
                   if ws.socopgdscvlr  >  ctb02m00.socfattotvlr   then
                      error " Valor desconto nao deve ser maior que o valor total da O.P.!"
                      next field socfattotvlr
                   end if

                   if ctb02m00.pestip   =  "F"                           and
                      ws.socopgdscvlr  >=  ctb02m00.socfattotvlr * 0.90  then
                      error " Valor desconto nao deve ser maior ou igual a 90% do valor total da O.P.!"
                      next field socfattotvlr
                   end if
                end if
             end if

      before field socfatrelqtd
             if operacao_aux  =  "a"   then
                if ctb02m00.socopgsitcod  >  1    then  #--> passou do protocolo
                   exit input
                end if
             end if
             display by name ctb02m00.socfatrelqtd    attribute (reverse)

      after  field socfatrelqtd
             display by name ctb02m00.socfatrelqtd

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field socfattotvlr
             end if

             if ctb02m00.socfatrelqtd   =  0       then
                error " Quantidade de relacoes nao deve ser igual a zero!"
                next field socfatrelqtd
             end if

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      initialize ctb02m00.*  to null
      return ctb02m00.*
   end if

   return ctb02m00.*

end function  ###  input_ctb02m00

#--------------------------------------------------------------------
function remove_ctb02m00(k_ctb02m00)
#--------------------------------------------------------------------

   define k_ctb02m00   record
          socopgnum    like dbsmopg.socopgnum
   end record

   define ctb02m00     record
          socopgnum    like dbsmopg.socopgnum,
          socopgsitcod like dbsmopg.socopgsitcod,
          socopgsitdes char (30),
          empresa      char (5),         #PSI 205206
          lcvcod       like datklocadora.lcvcod,
          lcvnom       like datklocadora.lcvnom,
          lcvextcod    like datkavislocal.lcvextcod,
          aviestnom    like datkavislocal.aviestnom,
          pestip       like dbsmopg.pestip,
          cgccpfnum    like dbsmopg.cgccpfnum,
          cgcord       like dbsmopg.cgcord,
          cgccpfdig    like dbsmopg.cgccpfdig,
          socpgtdoctip like dbsmopg.socpgtdoctip,
          socpgtdocdes char(15),
          nfsnum       like dbsmopgitm.nfsnum,
          socfatentdat like dbsmopg.socfatentdat,
          socfatpgtdat like dbsmopg.socfatpgtdat,
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          socfatrelqtd like dbsmopg.socfatrelqtd,
          linhamsg     char (70),
          segnumdig    like dbsmopg.segnumdig,
          segnom       like gsakseg.segnom,
          favtip       smallint,
          favtipdes    char(12),
          favtipnom1   char(40),
          favtipnom2   char(40),
          empcod       like dbsmopg.empcod,
          empnom       like gabkemp.empnom
   end record

   define ws           record
          socopgfascod like dbsmopgfas.socopgfascod,
          socopgnum    like dbsmopg.socopgnum,
          retorno      smallint,      
          mensagem     char(60)
   end record

   menu "Confirma Exclusao ?"

      command "Nao" "Nao exclui o protocolo"
              clear form
              initialize ctb02m00.*   to null
              initialize k_ctb02m00.* to null
              error " Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui protocolo"
              call ler_ctb02m00(k_ctb02m00.*) returning ctb02m00.*

              if sqlca.sqlcode = notfound  then
                 initialize ctb02m00.*   to null
                 initialize k_ctb02m00.* to null
                 error " Protocolo nao localizado!"
              else

                 #----------------------------------------------------
                 # Verifica fase da O.P.
                 #----------------------------------------------------
                
                # PSI 211074 - BURINI
                call cts50g00_sel_max_etapa(k_ctb02m00.socopgnum)
                     returning ws.retorno, 
                               ws.mensagem,
                               ws.socopgfascod

                 if ws.socopgfascod  <>  01   then
                    error " O.P. nao esta na fase de protocolo, portanto nao deve ser removida!"
                    exit menu
                 end if

                 #----------------------------------------------------
                 # Verifica itens da O.P.
                 #----------------------------------------------------
                 declare c_ctb02m00itm  cursor for
                    select socopgnum
                      into ws.socopgnum
                      from dbsmopgitm
                     where socopgnum = k_ctb02m00.socopgnum

                 initialize ws.socopgnum   to null
                 foreach  c_ctb02m00itm  into  ws.socopgnum
                    exit foreach
                 end foreach

                 if ws.socopgnum  is not null   then
                    error " O.P. possui itens digitados, portanto nao deve ser removida!"
                    exit menu
                 end if

                 #------------------------------------------------------
                 # Verifica custos da O.P.
                 #------------------------------------------------------
                 declare c_ctb02m00cst  cursor for
                    select socopgnum
                      into ws.socopgnum
                      from dbsmopgcst
                     where socopgnum = k_ctb02m00.socopgnum

                 initialize ws.socopgnum   to null
                 foreach  c_ctb02m00cst  into  ws.socopgnum
                    exit foreach
                 end foreach

                 if ws.socopgnum  is not null   then
                    error " O.P. possui custos digitados, portanto nao deve ser removida!"
                    exit menu
                 end if

                 #-------------------------------------------------------
                 # Verifica favorecido da O.P.
                 #-------------------------------------------------------
                 declare c_ctb02m00fav  cursor for
                    select socopgnum
                      into ws.socopgnum
                      from dbsmopgfav
                     where socopgnum = k_ctb02m00.socopgnum

                 initialize ws.socopgnum   to null
                 foreach  c_ctb02m00fav  into  ws.socopgnum
                    exit foreach
                 end foreach

                 if ws.socopgnum  is not null   then
                    error " O.P. possui favorecido, portanto nao deve ser removida!"
                    exit menu
                 end if

                 begin work
                    delete from dbsmopg
                     where dbsmopg.socopgnum = k_ctb02m00.socopgnum

                    # PSI 211074 - BURINI
                    call cts50g00_delete_etapa(k_ctb02m00.socopgnum)
                         returning ws.retorno,
                                   ws.mensagem

                    delete from dbsmopgobs
                     where dbsmopgobs.socopgnum = k_ctb02m00.socopgnum
                 commit work

                 if sqlca.sqlcode <> 0   then
                    initialize ctb02m00.*   to null
                    initialize k_ctb02m00.* to null
                    error " Erro (",sqlca.sqlcode,") na exlusao do protocolo!"
                 else
                    initialize ctb02m00.*   to null
                    initialize k_ctb02m00.* to null
                    error   " Protocolo excluido!"
                    message ""
                    clear form
                 end if
              end if

              exit menu
   end menu

   return k_ctb02m00.*

end function  ###  remove_ctb02m00

#---------------------------------------------------------
function ler_ctb02m00(k_ctb02m00)
#---------------------------------------------------------

   define k_ctb02m00   record
          socopgnum    like dbsmopg.socopgnum
   end record

   define ctb02m00     record
          socopgnum    like dbsmopg.socopgnum,
          socopgsitcod like dbsmopg.socopgsitcod,
          socopgsitdes char (30),
          empresa      char (5),         #PSI 205206
          lcvcod       like datklocadora.lcvcod,
          lcvnom       like datklocadora.lcvnom,
          lcvextcod    like datkavislocal.lcvextcod,
          aviestnom    like datkavislocal.aviestnom,
          pestip       like dbsmopg.pestip,
          cgccpfnum    like dbsmopg.cgccpfnum,
          cgcord       like dbsmopg.cgcord,
          cgccpfdig    like dbsmopg.cgccpfdig,
          socpgtdoctip like dbsmopg.socpgtdoctip,
          socpgtdocdes char (15),
          nfsnum       like dbsmopgitm.nfsnum,
          socfatentdat like dbsmopg.socfatentdat,
          socfatpgtdat like dbsmopg.socfatpgtdat,
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          socfatrelqtd like dbsmopg.socfatrelqtd,
          linhamsg     char (70),
          segnumdig    like dbsmopg.segnumdig,
          segnom       like gsakseg.segnom,
          favtip       smallint,
          favtipdes    char(12),
          favtipnom1   char(40),
          favtipnom2   char(40),
          empcod       like dbsmopg.empcod,
          empnom       like gabkemp.empnom
   end record

   define ws           record
          funmat       like isskfunc.funmat,
          funnom       like isskfunc.funnom,
          socopgfasdat like dbsmopgfas.socopgfasdat,
          socopgfashor like dbsmopgfas.socopgfashor,
          soctip       like dbsmopg.soctip,
          aviestcod    like dbsmopg.aviestcod,
          desconto     decimal(15,5)
   end record

   define l_fav record
          errcod     smallint ,
          msg        char(80)
   end record
   
   define l_ciaempcod   like datmservico.ciaempcod,      #PSI 205206
          l_ciaempcodOP like datmservico.ciaempcod,
          l_ret         smallint,
          l_mensagem    char(50),
          l_nfsnum      like dbsmopgitm.nfsnum

   initialize ctb02m00.* to null
   initialize ws.*       to null
   initialize l_fav.*    to null
   initialize l_ciaempcod, l_ciaempcodOP, l_ret, l_mensagem, l_nfsnum to null
   
   select socopgnum,
          socopgsitcod,
          segnumdig,
          pestip,
          cgccpfnum,
          cgcord,
          cgccpfdig,
          socfatentdat,
          socfatpgtdat,
          socfatitmqtd,
          socfattotvlr,
          socfatrelqtd,
          lcvcod,
          aviestcod,
          soctip,
          socpgtdoctip,
          empcod,
          favtip,
          nfsnum
     into ctb02m00.socopgnum,
          ctb02m00.socopgsitcod,
          ctb02m00.segnumdig,
          ctb02m00.pestip,
          ctb02m00.cgccpfnum,
          ctb02m00.cgcord,
          ctb02m00.cgccpfdig,
          ctb02m00.socfatentdat,
          ctb02m00.socfatpgtdat,
          ctb02m00.socfatitmqtd,
          ctb02m00.socfattotvlr,
          ctb02m00.socfatrelqtd,
          ctb02m00.lcvcod,
          ws.aviestcod,
          ws.soctip,
          ctb02m00.socpgtdoctip,
          ctb02m00.empcod,
          ctb02m00.favtip,
          ctb02m00.nfsnum
     from dbsmopg
    where socopgnum = k_ctb02m00.socopgnum

   if sqlca.sqlcode = notfound   then
      error " Protocolo nao cadastrado!"
      initialize ctb02m00.*    to null
      initialize k_ctb02m00.*  to null
      return ctb02m00.*
   end if

#   select sum(dscvlr)
#   into ws.desconto
#   from dbsropgdsc
#   where socopgnum = k_ctb02m00.socopgnum

#   if sqlca.sqlcode = 0 then
#   	if ws.desconto is not null or ws.desconto > 0.00 then
#   		let ctb02m00.socfattotvlr = ctb02m00.socfattotvlr - ws.desconto
#   	end if
#   end if

   if ws.soctip <> 2   then
      error " Este numero de protocolo nao pertence ao Carro-Extra!"
      sleep 4
      initialize ctb02m00.*    to null
      initialize k_ctb02m00.*  to null
      return ctb02m00.*
   end if

   #PSI 205206
   #verificar qual a empresa dos itens da OP - caso exista
   declare cctb02m00001 cursor for
      select b.ciaempcod, a.nfsnum
         from dbsmopgitm a, outer datmservico b
         where a.socopgnum = k_ctb02m00.socopgnum
           and a.atdsrvnum = b.atdsrvnum
           and a.atdsrvano = b.atdsrvano
           
   foreach cctb02m00001 into l_ciaempcod, l_nfsnum
       #se empresa da OP é nula
       if l_ciaempcodOP is null
          then
          #empresa da OP recebe empresa do item
          let l_ciaempcodOP = l_ciaempcod
          
          #busca descricao da empresa
          # call cty14g00_empresa(1, l_ciaempcodOP)
          #      returning l_ret,
          #                l_mensagem,
          #                ctb02m00.empresa
          #
          
       else
          #verificar se empresa da OP e empresa do item são iguais
          if l_ciaempcodOP <> l_ciaempcod then
             error "Itens da OP com empresas diferentes!"
          end if
       end if
   end foreach
   
   # atribuir numero da NFS do item
   if ctb02m00.nfsnum is null and l_nfsnum is not null
      then
      let ctb02m00.nfsnum = l_nfsnum
   end if
   
   # busca descricao da empresa, se nao houver itens mostra N/D
   call cty14g00_empresa_abv(ctb02m00.empcod)
        returning l_ret, l_mensagem, ctb02m00.empresa
        
   call cty14g00_empresa(1, ctb02m00.empcod)
        returning l_ret, l_mensagem, ctb02m00.empnom
        
   # buscar dados do favorecido conforme tipo
   call ctb00g01_dados_favtip(6, '', 
                              ctb02m00.segnumdig,
                              ctb02m00.lcvcod, 
                              ws.aviestcod,
                              '',
                              ctb02m00.empcod,
                              ctb02m00.cgccpfnum,
                              ctb02m00.cgcord,
                              ctb02m00.cgccpfdig,
                              ctb02m00.favtip)
                    returning l_fav.errcod,
                              l_fav.msg,
                              ctb02m00.favtip,
                              ctb02m00.favtipnom1,
                              ctb02m00.favtipnom2,
                              ctb02m00.lcvextcod,
                              ctb02m00.favtipdes
   
   if l_fav.errcod != 0 
      then
      error l_fav.msg
      sleep 1
      initialize ctb02m00.*    to null
      initialize k_ctb02m00.*  to null
      return ctb02m00.*
   else
      case ctb02m00.favtip
         when 3
            let ctb02m00.segnom = ctb02m00.favtipnom1
         when 4
            let ctb02m00.lcvnom = ctb02m00.favtipnom1
            let ctb02m00.aviestnom = ctb02m00.favtipnom2
      end case
   end if
   
   initialize m_dominio.* to null
   
   call cty11g00_iddkdominio('socopgsitcod', ctb02m00.socopgsitcod)
        returning m_dominio.*
        
   if m_dominio.erro = 1
      then
      let ctb02m00.socopgsitdes = m_dominio.cpodes clipped
   else
      error " Erro (",sqlca.sqlcode,") na leitura da situacao!"
      initialize ctb02m00.*    to null
      initialize k_ctb02m00.*  to null
      return ctb02m00.*
   end if
   
   #-----------------------------------------------------------------
   # Monta data de protocolo
   #-----------------------------------------------------------------
   select socopgfasdat, socopgfashor, funmat
     into ws.socopgfasdat, ws.socopgfashor, ws.funmat
     from dbsmopgfas
    where socopgnum    = k_ctb02m00.socopgnum    and
          socopgfascod = 01

   if sqlca.sqlcode <> 0    then
      error " Erro (",sqlca.sqlcode,") na leitura do codigo da fase!"
      initialize ctb02m00.*    to null
      initialize k_ctb02m00.*  to null
      return ctb02m00.*
   end if

   select funnom
     into ws.funnom
     from isskfunc
    where empcod = 01
      and funmat = ws.funmat

   let ctb02m00.linhamsg = "Protocolado em..: ", ws.socopgfasdat, " as ",
                           ws.socopgfashor, " por ", ws.funnom
                           
   #----------------------------------------------------------------
   if ctb02m00.socpgtdoctip is not null and 
      ctb02m00.socpgtdoctip > 0
      then
      initialize m_dominio.* to null
   
      call cty11g00_iddkdominio('socpgtdoctip', ctb02m00.socpgtdoctip)
           returning m_dominio.*
           
      if m_dominio.erro = 1
         then
         let ctb02m00.socpgtdocdes = m_dominio.cpodes clipped
      else
         initialize ctb02m00.socpgtdocdes to null
         error "Tipo documento fiscal: ", m_dominio.mensagem
      end if
   end if
   
   return ctb02m00.*

end function  ###  ler_ctb02m00

