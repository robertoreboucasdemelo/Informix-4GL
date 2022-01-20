#############################################################################
# Nome do Modulo: CTE01M00                                             Akio #
#                                                                      Ruiz #
# Atendimento ao corretor - Dados do solicitante                   Abr/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 14/08/2000  psi          Arnaldo      carregar o codigo da agencia par a  #
#                                       tela do orcamento.                  #
# 29/12/2000  psi 120286   Raji         Carregar alerta para as SUSEPs      #
#############################################################################
#                                                                           #
#                       * * * Alteracoes * * *                              #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- ------------------------------------ #
# 27/10/2003  Meta,Bruno     PSI175269 Realizar tratamento para a chamada   #
#                            OSF25780  da funcao cts14g02.                  #
#---------------------------------------------------------------------------#
# 05/08/2008  Douglas,Meta   PSI224499 Adicionado o campo status do corretor#
#                                                                           #
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a  #
#                                         global                            #
# ------------------------------------------------------------------------- #
#############################################################################

#globals  "/homedsa/fontes/ct24h/producao/glcte.4gl"
globals "/homedsa/projetos/geral/globals/glcte.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"

 define g_cte01m00        char(01)
 define m_prep            smallint


function cte01m00_prepare()

   define l_sql char(300)


   let l_sql = " select count(*) from datkdominio ",
               " where cponom = 'empresa_corretor'",
               " and cpocod = ? "
   prepare pcte01m00002 from l_sql
   declare ccte01m00002 cursor with hold for pcte01m00002

  let m_prep = true

end function

#-------------------------------------------------------------------------------
 function cte01m00()
#-------------------------------------------------------------------------------
   define   w_log     char(60)

   define d_cte01m00      record
          ini             char(06),
          empcodatend     LIKE isskfunc.empcod,
          funmatend       LIKE isskfunc.funmat,
          solnom          like dacmlig.c24solnom,
          c24soltipcod    like datksoltip.c24soltipcod, ---> PSI - 224030
          c24soltipdes    like datksoltip.c24soltipdes, ---> PSI - 224030
          corsus          like dacrligsus.corsus,
          cornom          like gcakcorr.cornom,
          empcod          like dacrligfun.empcod,
          funmat          like dacrligfun.funmat,
          funnom          like isskfunc.funnom,
          ciaempcod       like gabkemp.empcod,          ---> PSI - 224030
          empnom          like gabkemp.empnom,          ---> PSI - 224030
          confirma        char(01),
          stt             char(30)
   end record
   define l_erro          smallint
   define l_flag          char(1)
   define ws              record
          data            date                    ,
          hora            datetime hour to minute ,
          ura             smallint                ,
          uralida         smallint                ,
          relsgl          like igbmparam.relsgl   ,
          relpamseq       like igbmparam.relpamseq,
          relpamtxt       like igbmparam.relpamtxt,
          corsuspcp       like gcaksusep.corsuspcp,
          suslnhqtd       like gcaksusep.suslnhqtd,
          corligorg       like dacmlig.corligorg  ,
          corass          char(40)              ,
          corasscod       like dackass.corasscod,
          corassdes       like dackass.corassdes,
          corassagpcod    like dackassagp.corassagpcod,
          corassagpsgl    like dackassagp.corassagpsgl,
          grlinf          like igbkgeral.grlinf   ,
          atlult          like igbkgeral.atlult   ,
          empcod          like isskfunc.empcod    ,
          funmat          like isskfunc.funmat    ,
          funnom          like isskfunc.funnom    ,
          corblqtip       like gcambloqsus.corblqtip,
          cvnnum          like apamcapa.cvnnum,
          cvncptagnnum    like akckagn.cvncptagnnum,
          msg             char(20)
   end record

   ---> PSI - 224030
   define lr_aux       record
          resultado    smallint
         ,mensagem     char(60)
         ,c24soltipdes like datksoltip.c24soltipdes ---> PSI - 224030
   end record

   define lr_retorno record
          coderro smallint
         ,mens    char(400)
         ,flag    char(1)
   end record

   define w_comando       char(600)
   define w_erro          integer                   ---> PSI - 224030
   define l_host          like ibpkdbspace.srvnom #Saymon ambnovo

	let	w_comando  =  null
        let     w_erro     =  null                  ---> PSI - 224030

	initialize  d_cte01m00.*  to  null

	initialize  ws.*  to  null
	initialize  lr_aux.*  to  null  ---> PSI - 224030

 #------------Saymon---------------------#
 # Carrega host do banco de dados        #
 #---------------------------------------#
 #ambnovo
 let l_host = fun_dba_servidor("ORCAMAUTO")
 #ambnovo

 ## PSI 175269 - Inicio

 if g_atdcor.apoio = "S" then
    call cts14g02("N", "ctapoiocor")
 else
    call cts14g02("N", "cte01m00")
 end if

 ## PSI 175269 - Final

 #------------------------------------------------------------------------------
 # Inicializacao de variaveis
 #------------------------------------------------------------------------------
   initialize d_cte01m00,
              ws        ,
              w_comando ,
              lr_retorno to null

 #------------------------------------------------------------------------------
 # Preparacao dos comandos SQL
 #------------------------------------------------------------------------------
   if  g_cte01m00 is null  then
       let g_cte01m00 = "N"

       let w_comando = "select grlinf, "                      ,
                              "atlult "                       ,
                         "from IGBKGERAL "                    ,
                              "where mducod = 'C24' "         ,
                                "and grlchv = 'ATDCOR-SIMUL' "

       prepare s_igbkgeral from   w_comando
       declare c_igbkgeral cursor for s_igbkgeral

       let w_comando = "select relpamtxt "          ,
                         "from porto@",l_host clipped,":IGBMPARAM "          ,
                              "where relsgl = ? "   ,
                                "and relpamseq = ? "


       prepare s_igbmparam from   w_comando
       declare c_igbmparam cursor for s_igbmparam

       let w_comando = "select corsus, "            ,
                              "corsuspcp "          ,
                         "from GCAKSUSEP "          ,
                              "where suslnhqtd = ? "

       prepare s1_gcaksusep  from   w_comando
       declare c1_gcaksusep  cursor for s1_gcaksusep

       let w_comando = "select corsuspcp "          ,
                         "from GCAKSUSEP "          ,
                              "where corsus = ? "

       prepare s2_gcaksusep  from   w_comando
       declare c2_gcaksusep  cursor for s2_gcaksusep

       let w_comando = "select cornom "             ,
                         "from GCAKCORR "           ,
                              "where corsuspcp = ? "

       prepare s_gcakcorr  from   w_comando
       declare c_gcakcorr  cursor for s_gcakcorr

       let w_comando = "select funnom "          ,
                         "from ISSKFUNC "        ,
                              "where empcod = ? ",
                                "and funmat = ? "

       prepare s_isskfunc  from   w_comando
       declare c_isskfunc  cursor for s_isskfunc

       ---> PSI 224030
       let w_comando = "select empnom "          ,
                         "from gabkemp "        ,
                        "where empcod = ? "

       prepare s_gabkemp  from   w_comando
       declare c_gabkemp  cursor for s_gabkemp

       let w_comando = "insert into IGBKGERAL( mducod, " ,
                                              "grlchv, " ,
                                              "grlinf, " ,
                                              "atlult ) ",
                                   "values('C24','ATDCOR-SIMUL',?,?)"

       prepare i_igbkgeral from   w_comando

       let w_comando = "delete from IGBKGERAL "  ,
                              "where mducod = 'C24' ",
                                "and grlchv = 'ATDCOR-SIMUL' "
       prepare d_igbkgeral from w_comando

       let w_comando = "select corassdes   , "                ,
                              "corassagpcod "                 ,
                         "from DACKASS "                      ,
                              "where corasscod = ?  "

       prepare s_dackass   from   w_comando
       declare c_dackass   cursor with hold for s_dackass

       let w_comando = "select corassagpsgl "                 ,
                         "from DACKASSAGP "                   ,
                              "where corassagpcod = ?  "

       prepare s_dackassagp   from   w_comando
       declare c_dackassagp   cursor with hold for s_dackassagp

       let w_comando = "delete from porto@",l_host clipped,":IGBMPARAM "     ,
                              "where relsgl = ? "   ,
                                "and relpamseq = ? "


       prepare d_igbmparam    from   w_comando
   end if


 #------------------------------------------------------------------------------
 # Chama tela de P.A.
 #------------------------------------------------------------------------------

  #call cta02m09() returning g_c24paxnum
  #if  g_c24paxnum is null  then
  #    return
  #end if

   call aogtura(g_issk.succod,g_issk.funmat,g_issk.dptsgl)
          returning g_c24paxnum
   if  g_c24paxnum is null  then
       return
   end if

   let ws.relsgl    = "URAATENDPREVIO"
   let ws.relpamseq = g_c24paxnum

 #------------------------------------------------------------------------------
 # Inicio da tela
 #------------------------------------------------------------------------------

   open window win_cte01m00 at 03,02 with form "cte01m00"
        attribute (form line first)

   while true

   #----------------------------------------------------------------------------
   # Inicializacao de variaveis
   #----------------------------------------------------------------------------
     let int_flag     = false

     let ws.data      = today
     let ws.hora      = current hour to minute
     let ws.uralida   = false
     let ws.corligorg = 0

     initialize d_cte01m00 to null

   #----------------------------------------------------------------------------
   # Input
   #----------------------------------------------------------------------------
     clear form

     input by name d_cte01m00.* without defaults

        before field ini

           IF g_atdcor.apoio = "S" THEN
              DISPLAY "A T E N D I M E N T O  A P O I O" TO atdcabec
              NEXT FIELD empcodatend
           ELSE
              display "***   AGUARDANDO ATENDIMENTO ...   ***" to atdcabec
              error " ", g_issk.funnom clipped,
                      ", pressione <ENTER> para iniciar o atendimento! "
           end if

        after  field ini
           display " " to ini

           if  d_cte01m00.ini = "aabbcc"  then
               open  c_igbkgeral
               fetch c_igbkgeral into ws.grlinf,
                                      ws.atlult
               if  sqlca.sqlcode = 0  then
                   let ws.empcod =  ws.atlult[01,02]
                   let ws.funmat =  ws.atlult[03,08]
                   open  c_isskfunc using ws.empcod,
                                          ws.funmat
                   fetch c_isskfunc into  ws.funnom

                   error " Sistema em simulacao por ",
                         ws.empcod using "&&", "/", ws.funmat using "&&&&&&",
                         "-", ws.funnom
                   sleep 2
                   initialize d_cte01m00.ini to null
                   display by name d_cte01m00.ini
                   next field ini
               else
                   begin work
                   let ws.atlult[01,02] = g_issk.empcod using "&&"
                   let ws.atlult[03,08] = g_issk.funmat using "&&&&&&"
                   execute i_igbkgeral using ws.grlinf,
                                             ws.atlult
                   if  sqlca.sqlcode <> 0  then
                       error " Erro (", sqlca.sqlcode, ") durante ",
                             "a gravacao do registro de simulacao."
                       next field ini
                   end if
                   commit work

                   let g_simulacao = true
                   display "SIMULACAO" to simulacao attribute(reverse)

                   let ws.ura = false
                   display "A T E N D I M E N T O     D I R E T O."
                           to atdcabec attribute(reverse)

                   display "Matricula...:" to funmatcab
                   display "Funcionario.:" to funnomcab
                   next field solnom
               end if
           else
               let g_simulacao = false
               display "         " to simulacao
           end if


       ###PSI 196134 - comentado em 16/01/2006
       ###             URA nao eh mais utilizado pela central
         #----------------------------------------------------------------------
         # Carrega dados para atendimento pelo URA
         #----------------------------------------------------------------------
         # if  ws.uralida = false  then
         #     let ws.uralida = true

         #     error "Carregando informacoes, aguarde ..."

         #     open  c_igbmparam using ws.relsgl,
         #                             ws.relpamseq
         #     fetch c_igbmparam into  ws.relpamtxt

         #     if  sqlca.sqlcode = 0  and
         #         ws.relpamtxt  > 0  then
         #         close c_igbmparam

         #         let ws.suslnhqtd = ws.relpamtxt[05,10]
         #         open  c1_gcaksusep using ws.suslnhqtd
         #         fetch c1_gcaksusep into  d_cte01m00.corsus,
         #                                  ws.corsuspcp
         #         if  sqlca.sqlcode = 0  then
         #             open  c_gcakcorr  using ws.corsuspcp
         #             fetch c_gcakcorr  into  d_cte01m00.cornom
         #             close c_gcakcorr
         #             let ws.ura       = true
         #             let ws.corligorg = 1
         #             display "   A T E N D I M E N T O      U R A   "
         #                     to atdcabec attribute(reverse)
         #             display by name d_cte01m00.corsus attribute (reverse)
         #             display by name d_cte01m00.cornom attribute (reverse)
         #             display "Assunto.....:" to corasscab

         #            #-----------------------------------------------------
         #            # Os codigos de assunto precisam ser informados pelo
         #            # usuario que os cadastraram.
         #            #
         #             case ws.relpamtxt[1,4]
         #                 when "0101" let ws.corasscod = 1
         #                 when "0102" let ws.corasscod = 1
         #                 when "0103" let ws.corasscod = 1
         #                 when "0200" let ws.corasscod = 2
         #                 when "0300" let ws.corasscod = 4
         #                 when "0400" let ws.corasscod = 23
         #             end case
         #            #-----------------------------------------------------
         #             open  c_dackass using ws.corasscod
         #             fetch c_dackass into  ws.corassdes   ,
         #                                   ws.corassagpcod

         #             open  c_dackassagp using ws.corassagpcod
         #             fetch c_dackassagp into  ws.corassagpsgl

         #             let ws.corass = ws.corassagpsgl clipped,
         #                             "-", ws.corassdes clipped
         #             display by name ws.corass attribute(reverse)
         #         else
         #             error " Erro (", sqlca.sqlcode, ") durante ",
         #                   "a validacao do URA. Mudando para atd direto!"
         #             let ws.ura = false
         #             let ws.corligorg = 2
         #             display "A T E N D I M E N T O    D I R E T O.."
         #                     to atdcabec attribute(reverse)
         #             display "Matricula...:" to funmatcab
         #             display "Funcionario.:" to funnomcab
         #         end if
         #         close c1_gcaksusep

         #         begin work
         #         execute d_igbmparam using ws.relsgl,
         #                                   ws.relpamseq
         #         commit work
         #         next field solnom  # ruiz
         #     else
         #         close c_igbmparam
         #         let ws.ura = false
         #         let ws.corligorg = 2
         #         display "A T E N D I M E N T O   D I R E T O..."
         #                 to atdcabec attribute(reverse)
         #         display "Matricula...:" to funmatcab
         #         display "Funcionario.:" to funnomcab
         #         next field solnom
         #     end if
         #     error ""
         # end if
         ###PSI 196134 - acerto da navegacao na tela
               if g_atdcor.apoio <> "S" or
                  g_atdcor.apoio is null then
                   let ws.ura = false
                   let ws.corligorg = 2
                   display "A T E N D I M E N T O   D I R E T O..."
                           to atdcabec attribute(reverse)
                   display "Matricula...:" to funmatcab
                   display "Funcionario.:" to funnomcab
                   next field solnom
              end if

        AFTER FIELD empcodatend
           IF d_cte01m00.empcodatend IS NULL THEN
              error "Empresa do atendente deve ser informada" ATTRIBUTE(reverse)
              call cto00m01(g_atdcor.apoio)
                   returning d_cte01m00.empcodatend,
                             d_cte01m00.funmatend,
                             d_cte01m00.funnom
              initialize d_cte01m00.funnom to null
              NEXT FIELD empcodatend
           END IF

        AFTER FIELD funmatend
           IF d_cte01m00.funmatend IS NULL THEN
             error"Matricula do atendente deve ser informada" ATTRIBUTE(reverse)
              call cto00m01(g_atdcor.apoio)
                   returning d_cte01m00.empcodatend,
                             d_cte01m00.funmatend,
                             d_cte01m00.funnom
              initialize d_cte01m00.funnom to null
              NEXT FIELD funmatend
           END IF

           LET w_comando = 'select funmat,funnom,empcod,usrtip ',
                          '  from isskfunc',
                          ' where funmat = ',d_cte01m00.funmatend,
                          '   and empcod = ',d_cte01m00.empcodatend

           PREPARE pcte01m00001 FROM w_comando
           DECLARE ccte01m00001 CURSOR FOR pcte01m00001
           OPEN ccte01m00001
           FETCH ccte01m00001 INTO g_atdcor.funmat,g_atdcor.funnom,
                                   g_atdcor.empcod,g_atdcor.usrtip

           if g_issk.funmat = 601566 then
              display "g_atdcor.empcod = ", g_atdcor.empcod
              display "g_atdcor.funmat = ", g_atdcor.funmat
              display "g_atdcor.funnom = ", g_atdcor.funnom
              display "g_atdcor.usrtip = ", g_atdcor.usrtip
           end if
           IF SQLCA.sqlcode = 0 THEN
              LET d_cte01m00.solnom = g_atdcor.funnom
              DISPLAY d_cte01m00.solnom TO solnom
           ELSE
              IF SQLCA.sqlcode = NOTFOUND THEN
                 MESSAGE "Empresa/Matricula inexistentes!!!" ATTRIBUTE(reverse)
                 SLEEP 3
                 CLOSE ccte01m00001
                 NEXT FIELD empcodatend
              END IF
           END IF
           CLOSE ccte01m00001
           NEXT FIELD corsus

        before field solnom
           display by name d_cte01m00.solnom  attribute(reverse)

        after  field solnom
           display by name d_cte01m00.solnom

           if  fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field solnom
           end if
           if  d_cte01m00.solnom = " "    or
               d_cte01m00.solnom is null  then
               error " Informe o nome do solicitante!"
               next field solnom
           end if
           let g_c24solnom = d_cte01m00.solnom
           if  ws.ura  then
               ---> PSI 224030 next field confirma
               next field ciaempcod
           end if

        ---> PSI 224030
before field c24soltipcod
           display by name d_cte01m00.c24soltipcod  attribute(reverse)

        after  field c24soltipcod
           display by name d_cte01m00.c24soltipcod

           if  fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field solnom
           end if

           if  d_cte01m00.c24soltipcod is null  then
               error " Informe o tipo do solicitante!"
           end if

           if d_cte01m00.c24soltipcod is null then
               error "Tipo do solicitante deve ser informado!"

               #-- Exibe popup dos tipos de solicitante --#
               let d_cte01m00.c24soltipcod = cto00m00(3)
               display by name d_cte01m00.c24soltipcod
           end if

           #Obter descricao do tipo de solicitante
           call cto00m00_nome_solicitante(d_cte01m00.c24soltipcod, 3)
                returning lr_aux.resultado
                         ,lr_aux.mensagem
                         ,lr_aux.c24soltipdes

           if lr_aux.resultado <> 1 then
              error lr_aux.mensagem
              next field c24soltipcod
           end if

           let d_cte01m00.c24soltipdes = lr_aux.c24soltipdes
           display by name d_cte01m00.c24soltipdes

        before field corsus
           display by name d_cte01m00.corsus   attribute(reverse)

        after  field corsus
           IF d_cte01m00.corsus IS NULL and
              g_atdcor.apoio = "S"      THEN
              NEXT FIELD confirma
           END IF
           display by name d_cte01m00.corsus

           if  fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field solnom
           end if

           if  d_cte01m00.corsus <> " "       and
               d_cte01m00.corsus is not null  then
               if d_cte01m00.corsus <>  "99999J"  then
                  open  c2_gcaksusep using d_cte01m00.corsus
                  fetch c2_gcaksusep into  ws.corsuspcp

                    if  sqlca.sqlcode <> 0  then
                        if  sqlca.sqlcode = 100  then
                            error " Susep nao cadastrada!"
                           #call cto00m05()
                           #  returning d_cte01m00.corsus,
                           #            d_cte01m00.cornom
                            call aggucora()
                              returning d_cte01m00.corsus,
                                        ws.cvnnum        ,
                                        ws.cvncptagnnum
                        else
                            error " Erro (", sqlca.sqlcode, ") durante ",
                               "a confirmacao da susep. AVISE A INFORMATICA!"
                        end if
                        next field corsus
                    end if
                  close c2_gcaksusep

                  open  c_gcakcorr  using ws.corsuspcp
                  fetch c_gcakcorr  into  d_cte01m00.cornom


                  call ctf00m05_status_corretor(d_cte01m00.corsus)
                     returning l_flag
                              ,l_erro
                  if l_erro <> 0 then
                     let d_cte01m00.stt = ' '
                  else
                      if l_flag = 'A' then
                         let d_cte01m00.stt = 'Corretor antigo'
                      else
                         let d_cte01m00.stt = 'Corretor novo'
                      end if
                  end if
                  display by name d_cte01m00.stt

                  call gcfc020(d_cte01m00.corsus,1)
                           returning ws.corblqtip
                  if ws.corblqtip is not null then
                    # alterado conforme Rosana Mincon, considerar bloqueio com
                    # tipo = N ou R. 14/05/2002 - ruiz
                    #if ws.corblqtip =  "I" then
                    #   if cts08g01("A","S",
                    #              "" ,"Susep Inativa   ",
                    #              "" ,"Confirma ?" ) = "N" then
                    #      exit input
                    #   end if
                    #else
                       if ws.corblqtip = "N" or  #bloqueado p/ calculo
                          ws.corblqtip = "R" then#bloqueado p/ calculo
                          let ws.msg = "Susep Bloqueada-",ws.corblqtip
                          if cts08g01("A","S",
                                      "" ,ws.msg            ,
                                      "" ,"Confirma ?" ) = "N" then
                             exit input
                          end if
                       end if
                    #end if
                  end if
               else
                  let d_cte01m00.cornom = "Susep Provisoria"
               end if
               display by name d_cte01m00.cornom

               initialize      d_cte01m00.empcod,
                               d_cte01m00.funmat,
                               d_cte01m00.funnom to null
               display by name d_cte01m00.empcod,
                               d_cte01m00.funmat,
                               d_cte01m00.funnom

               next field ciaempcod
           else
               initialize      d_cte01m00.cornom to null
               display by name d_cte01m00.cornom

               next field empcod
           end if

        before field empcod
           display by name d_cte01m00.empcod   attribute(reverse)

        after  field empcod
           display by name d_cte01m00.empcod

           if  fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field corsus
           end if

           if  d_cte01m00.empcod = 0      or
               d_cte01m00.empcod is null  then
               call cto00m01(g_atdcor.apoio)
                    returning d_cte01m00.empcod,
                              d_cte01m00.funmat,
                              d_cte01m00.funnom

               next field empcod
           end if

        before field funmat
           display by name d_cte01m00.funmat   attribute(reverse)

        after  field funmat
           display by name d_cte01m00.funmat

           if  fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field empcod
           end if

           if  d_cte01m00.funmat <> 0         and
               d_cte01m00.funmat is not null  then
               open  c_isskfunc using d_cte01m00.empcod,
                                      d_cte01m00.funmat
               fetch c_isskfunc into  d_cte01m00.funnom
                 if  sqlca.sqlcode <> 0  then
                     if  sqlca.sqlcode = 100  then
                         error " Matricula nao cadastrada!"
                         call cto00m01(g_atdcor.apoio)
                              returning d_cte01m00.empcod,
                                        d_cte01m00.funmat,
                                        d_cte01m00.funnom
                     else
                         error " Erro (", sqlca.sqlcode, ") durante ",
                              "a confirmacao da matricula. AVISE A INFORMATICA!"
                     end if
                     next field empcod
                 end if

               display by name d_cte01m00.funnom
           else
               error " Informe a matricula do funcionario! "
               next field funmat
           end if

        ---> PSI 224030
        before field ciaempcod
           display by name d_cte01m00.ciaempcod   attribute(reverse)

        after  field ciaempcod
           display by name d_cte01m00.ciaempcod

           if  fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field funmat
           end if

           if  d_cte01m00.ciaempcod <> 0         and
               d_cte01m00.ciaempcod is not null  then

               call cte01m00_valida_empresa(d_cte01m00.ciaempcod)
                    returning lr_retorno.*

               if lr_retorno.flag = false then
                  error " Empresa Invalida, escolha uma empresa valida !" sleep 2
                  call cte01m00_popup_empresa()
                    returning w_erro
                             ,d_cte01m00.ciaempcod
                             ,d_cte01m00.empnom
               else
                 open  c_gabkemp using d_cte01m00.ciaempcod
                 fetch c_gabkemp into  d_cte01m00.empnom
                   if  sqlca.sqlcode <> 0  then
                       if  sqlca.sqlcode = 100  then
                           error " Empresa nao cadastrada!"
                           next field ciaempcod
                       else
                           error " Erro (", sqlca.sqlcode, ") durante ",
                                "a confirmacao da Empresa!"
                       end if
                       next field ciaempcod
                   end if

                 display by name d_cte01m00.empnom
               end if
           else
               error " Informe a Empresa do Documento! "
               call cte01m00_popup_empresa()
                    returning w_erro
                             ,d_cte01m00.ciaempcod
                             ,d_cte01m00.empnom

               display by name d_cte01m00.ciaempcod
               display by name d_cte01m00.empnom

               next field ciaempcod
           end if

        before field confirma
           let d_cte01m00.confirma = "S"

           display by name d_cte01m00.confirma attribute(reverse)

        after  field confirma
           display by name d_cte01m00.confirma

           if  fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               if  ws.ura  then
                   ---> PSI 224030 next field solnom
                   next field ciaempcod
               else
                   if  d_cte01m00.corsus <> " "       and
                       d_cte01m00.corsus is not null  then
                       next field corsus
                   else
                       next field ciaempcod
                   end if
               end if
           end if

           if ( d_cte01m00.confirma <> "S"  and
                d_cte01m00.confirma <> "N"     )  or
              ( d_cte01m00.confirma is null    )  then
               error " Confirma dados do solicitante ? (S/N)"
               next field confirma
           else
               if  d_cte01m00.confirma = "S"  THEN
                  IF g_atdcor.apoio = "S" THEN
                  ELSE
                     if ( d_cte01m00.corsus = " "    or
                          d_cte01m00.corsus is null    )  and
                        ( d_cte01m00.empcod = 0      or
                          d_cte01m00.empcod is null    )  and
                        ( d_cte01m00.funmat = 0      or
                          d_cte01m00.funmat is null    )  then
                         error "Informe a susep do corretor ou ",
                               "a matricula do funcionario! "
                         NEXT field corsus
                     end IF
                  END IF
               end if
           end if

           call figrc072_setTratarIsolamento() -- > psi 223689
           # Alerta ao corretor
           call gpgtaler("S",d_cte01m00.corsus,"O")

           if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
              error "Função gpgtaler indisponivel no momento ! Avise a Informatica !" sleep 2
              exit input
           end if        -- > 223689
           exit input

        on key (interrupt)
           exit input

     end input

     if  int_flag  then
         let int_flag = false

         if  d_cte01m00.ini = "aabbcc"  then
             begin work
             execute d_igbkgeral
             commit work
         end if
         update apamuraorc          # saindo do Atendimento ao corretor
              set succod = null,    # limpar a ura utilizada.
                  funmat = null
           where urapaxcod = g_c24paxnum

         exit while
     end if

   #----------------------------------------------------------------------------
   # Call no modulo de escolha dos assuntos
   #----------------------------------------------------------------------------
     if  d_cte01m00.confirma = "S"  then
         call cte01m01( ws.data          ,
                        ws.hora          ,
                        d_cte01m00.solnom,
                        d_cte01m00.corsus,
                        d_cte01m00.cornom,
                        d_cte01m00.empcod,
                        d_cte01m00.funmat,
                        d_cte01m00.funnom,
                        ws.corligorg     ,
                        ws.corasscod     ,
                        ws.cvncptagnnum  ,
                        d_cte01m00.c24soltipcod,  ---> PSI - 224030
                        d_cte01m00.ciaempcod)     ---> PSI - 224030
     end if

   end while

   close window win_cte01m00

end function
#---------------------------------------------#
function cte01m00_popup_empresa()
#---------------------------------------------#

 define lr_popup       record
        lin            smallint   # Nro da linha
       ,col            smallint   # Nro da coluna
       ,titulo         char (054) # Titulo do Formulario
       ,tit2           char (012) # Titulo da 1a.coluna
       ,tit3           char (040) # Titulo da 2a.coluna
       ,tipcod         char (001) # Tipo do Codigo a retornar
                                  # 'N' - Numerico
                                  # 'A' - Alfanumerico
       ,cmd_sql        char (1999)# Comando SQL p/ pesquisa
       ,aux_sql        char (200) # Complemento SQL apos where
       ,tipo           char (001) # Tipo de Popup
                                  # 'D' Direto
                                  # 'E' Com entrada
 end  record

 define lr_retorno     record
        erro           smallint,
        ciaempcod      like gabkemp.empcod,
        empnom         like gabkemp.empnom
 end record

 define l_lista  char(1000)

 initialize lr_retorno.*  to  null
 initialize lr_popup.*    to  null

 call cta00m06_empresas_atend_corretor()
      returning l_lista

 let lr_popup.lin    = 6
 let lr_popup.col    = 12
 let lr_popup.titulo = "Empresas"
 let lr_popup.tit2   = "Codigo"
 let lr_popup.tit3   = "Nome"
 let lr_popup.tipcod = "N"
 let lr_popup.cmd_sql = "select empcod, empnom ",
                        "  from gabkemp ",
                        " where empcod in ",l_lista clipped,
                        " order by empcod "
 let lr_popup.tipo   = "D"

 call ofgrc001_popup(lr_popup.*)
      returning lr_retorno.*


 if lr_retorno.erro = 0 then
    let lr_retorno.erro = 1
 else
    if lr_retorno.erro = 1 then
       let lr_retorno.erro = 2
    else
       let lr_retorno.erro = 3
    end if
 end if

 let int_flag = false

 return lr_retorno.*

end function

#===============================================
function cte01m00_valida_empresa(lr_param)
#===============================================

   define lr_param record
          ciaempcod    like gabkemp.empcod
   end record

   define lr_retorno record
          coderro smallint
         ,mens    char(400)
         ,flag    char(1)
   end record

   define l_count smallint

   let lr_retorno.coderro = 0
   let lr_retorno.mens = null
   let lr_retorno.flag = false
   let l_count = 0

   if m_prep is null or
      m_prep = 0 then
      call cte01m00_prepare()
   end if

   whenever error continue
   open ccte01m00002 using lr_param.ciaempcod
   fetch ccte01m00002 into l_count
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_retorno.coderro = sqlca.sqlcode
      let lr_retorno.mens = "Erro < ",sqlca.sqlcode clipped , " > ao buscar empresa no dominio "
      call errorlog(lr_retorno.mens)
   end if

   if l_count >= 1  then
      let lr_retorno.flag = true
      return lr_retorno.*
   else
      let lr_retorno.flag = false
      return lr_retorno.*
   end if

end function
