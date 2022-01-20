#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Radar/ Porto Socorro                                      #
# Modulo.........: ctc39m00                                                  #
# Objetivo.......: manutenir cadastros de candidatos do porto socorro        #
#                                                                            #
# Analista Resp. : Debora Vaz Paez                                           #
# PSI            : 220710                                                    #
#............................................................................#
# Desenvolvimento: Vinicius, META                                            #
# Liberacao      : 24/04/2008                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica  PSI       Alteracao                              #
# --------   -------------  ------    ---------------------------------------#
# 30/03/09   Adriano Santos 239178    Inclusao do campo Consultoria e display#
#                                     informando se candidato virou          #
#                                     socorrista com data. Possibilitar que  #
#                                     alteração do campo Situacao            #
# 25/05/10   Robert Lima    257206    Foi impossibilitado a continuidade do  #
#                                     fluxo se o CPF estiver invalido        #
#----------------------------------------------------------------------------#
# 06/10/12   Celso Yamahaki P12010028 Alteracao do tamanho do campo nomepres #
#                                     no array modular de char(60) para      #
#                                     like dpaksocor.nomrazsoc               #
#----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'

   define mr_tela record
                  pestip       like dpakcnd.pestip
                 ,cgccpfnum    like dpakcnd.cgccpfnum
                 ,cgcord       like dpakcnd.cgcord
                 ,cgccpfdig    like dpakcnd.cgccpfdig
                 ,pstcndnom    like dpakcnd.pstcndnom
                 ,rgenum       like dpakcnd.rgenum
                 ,rgeufdcod    like dpakcnd.rgeufdcod
                 ,nscdat       like dpakcnd.nscdat
                 ,idade        smallint
                 ,cnhnum       like dpakcnd.cnhnum
                 ,cnhctgcod    like dpakcnd.cnhctgcod
                 ,cnhpridat    like dpakcnd.cnhpridat
                 ,pstcndsitcod like dpakcnd.pstcndsitcod
                 ,descrsit     char(30)
                 ,pstcndconcod like dpakcnd.pstcndconcod
                 ,descrcon     char(30)
                 ,rdranlultdat like dpakcnd.rdranlultdat
                 ,caddat       date
                 ,cadhor       datetime hour to minute
                 ,cademp       like dpakcnd.cademp
                 ,cadmat       like dpakcnd.cadmat
                 ,cadnome      char(20)
                 ,atldat       date
                 ,atlhor       datetime hour to minute
                 ,atlemp       like dpakcnd.atlemp
                 ,atlmat       like dpakcnd.atlmat
                 ,atlnome      char(20)
                 ,datqra       date
                  end record

   define mr_tela_ant record # PSI239178
                  pestip       like dpakcnd.pestip
                 ,cgccpfnum    like dpakcnd.cgccpfnum
                 ,cgcord       like dpakcnd.cgcord
                 ,cgccpfdig    like dpakcnd.cgccpfdig
                 ,pstcndnom    like dpakcnd.pstcndnom
                 ,rgenum       like dpakcnd.rgenum
                 ,rgeufdcod    like dpakcnd.rgeufdcod
                 ,nscdat       like dpakcnd.nscdat
                 ,idade        smallint
                 ,cnhnum       like dpakcnd.cnhnum
                 ,cnhctgcod    like dpakcnd.cnhctgcod
                 ,cnhpridat    like dpakcnd.cnhpridat
                 ,pstcndsitcod like dpakcnd.pstcndsitcod
                 ,descrsit     char(30)
                 ,pstcndconcod like dpakcnd.pstcndconcod
                 ,descrcon     char(30)
                 ,rdranlultdat like dpakcnd.rdranlultdat
                 ,caddat       date
                 ,cadhor       datetime hour to minute
                 ,cademp       like dpakcnd.cademp
                 ,cadmat       like dpakcnd.cadmat
                 ,cadnome      char(20)
                 ,atldat       date
                 ,atlhor       datetime hour to minute
                 ,atlemp       like dpakcnd.atlemp
                 ,atlmat       like dpakcnd.atlmat
                 ,atlnome      char(20)
                 ,datqra       date
                  end record

   define m_pstcndcod          like dpakcnd.pstcndcod
         ,m_srrcoddig          like dpakcnd.srrcoddig
         ,m_rspnom             char(40)
         ,m_datpres            date
         ,m_caddat             datetime year to minute
         ,m_atldat             datetime year to minute
         ,m_count              smallint
   define am_prestadores       array[100] of record
                               ghost    char(1)
                              ,codpres  decimal(6,0)
                              ,masctela char(1)
                              ,nompres  like dpaksocor.nomrazsoc #char(60) P12010028
                              ,datpres  date
                               end record

   define m_prep_ctc39m00  smallint

   define lr_retornonome     record
          erro           smallint
         ,mensagem       char(60)
         ,funnom         like isskfunc.funnom
   end record

     define lr_ret record
          erro     smallint
         ,mensagem char(100)
         ,cpodes   like iddkdominio.cpodes
          end record

   define m_data       date,
          m_datqra     date,
          m_hora       datetime hour to minute,
          m_e_soc      smallint,
          m_situacao     smallint,
          m_consultoria  smallint

#-----------------------------------------------#
function ctc39m00_prepare()
#-----------------------------------------------#

   define l_sql char(600)

   let l_sql = ' update dpakcnd '
              ,'    set pstcndnom = ? '
                    ,' ,rgenum = ? '
                    ,' ,rgeufdcod = ? '
                    ,' ,nscdat = ? '
                    ,' ,cnhnum = ? '
                    ,' ,cnhctgcod = ? '
                    ,' ,cnhpridat = ? '
                    ,' ,pstcndsitcod = ? '
                    ,' ,pstcndconcod = ? '  # PSI239178
                    ,' ,atldat = ? '
                    ,' ,atlemp = ? '
                    ,' ,atlmat = ? '
                    ,' ,atlusrtip = ? '
              ,'  where pstcndcod = ? '
   prepare pctc39m00002 from l_sql

   let l_sql = ' update dpakcnd '
                 ,' set pstcndsitcod = ? '
                    ,' ,atldat = ? '
                    ,' ,atlemp = ? '
                    ,' ,atlmat = ? '
               ,' where pstcndcod = ? '
   prepare pctc39m00003 from l_sql

   let l_sql = ' insert into dpakcnd '
                         ,' (pstcndcod, cgccpfnum, cgccpfdig, '
                         ,'  cgcord, pestip, pstcndnom, '
                         ,'  rgenum, rgeufdcod, nscdat, '
                         ,'  cnhnum, cnhctgcod, cnhpridat, '
                         ,'  pstcndsitcod, pstcndconcod, rdranlultdat, '  # PSI239178
                         ,'  caddat, cademp, cadmat, '
                         ,'  cadusrtip, atldat, atlemp, '
                         ,'  atlmat, atlusrtip, srrcoddig) '
                  ,' values (0,?,?,?,?,?,?,?,?,?,?,?,?,?, '
                          ,' ?,?,?,?,?,?,?,?,?,?) '
   prepare pctc39m00004 from l_sql

   let l_sql = ' select 1 '
              ,'   from dpakcnd '
              ,'  where cgccpfnum = ? '
              ,'    and cgcord    = ? '
              ,'    and cgccpfdig = ? '
   prepare pctc39m00005 from l_sql
   declare cctc39m00005 scroll cursor for pctc39m00005

   let l_sql = ' insert into dparpstcnd '
              ,'        (pstcoddig,pstcndcod,caddat)'
              ,'  values (?,?,?) '
   prepare pctc39m00006 from l_sql

   let l_sql = ' select pstcoddig, caddat'
              ,'   from dparpstcnd '
              ,'  where pstcndcod = ? '
   prepare pctc39m00007 from l_sql
   declare cctc39m00007 cursor for pctc39m00007

   let l_sql = ' select max(pstcndcod)'
              ,'   from dpakcnd '
   prepare pctc39m00008 from l_sql
   declare cctc39m00008 cursor for pctc39m00008

   let m_prep_ctc39m00 = true

   let l_sql = ' update dpakcnd '
                 ,' set pstcndconcod = ? '
                    ,' ,atldat = ? '
                    ,' ,atlemp = ? '
                    ,' ,atlmat = ? '
               ,' where pstcndcod = ? '
   prepare pctc39m00009 from l_sql

   let l_sql = ' select caddat        '
              ,'   from datksrr       '
              ,'  where srrcoddig = ? '
   prepare pctc39m00010 from l_sql
   declare cctc39m00010 cursor for pctc39m00010

   let l_sql = ' update dpakcnd '
                 ,' set srrcoddig = ? '
               ,' where pstcndcod = ? '
   prepare pctc39m00011 from l_sql

   let l_sql = 'select pstcndcod '
              ,' from dpakcnd '
              ,' where cgccpfnum  = ? '
              ,' and  (cgcord is null or cgcord  = ?) '
              ,' and  cgccpfdig  = ? '

   prepare pctc39m00012 from l_sql
   declare cctc39m00012 cursor for pctc39m00012

   let l_sql = 'select pstcndcod '
              ,' from dpakcnd '
              ,' where cnhnum  = ? '

   prepare pctc39m00013 from l_sql
   declare cctc39m00013 cursor for pctc39m00013

   let l_sql = 'select pstcndcod '
              ,' from dpakcnd '
              ,' where rgenum  = ? '
              ,' and  rgeufdcod  = ? '

   prepare pctc39m00014 from l_sql
   declare cctc39m00014 cursor for pctc39m00014

end function

#-----------------------------------------------#
function ctc39m00()
#-----------------------------------------------#
   define l_retorno  smallint,
          l_aux      smallint

   let m_data = null
   let m_datqra = null
   let m_hora = null
   let m_e_soc = false
   let m_situacao = 0
   let m_consultoria = 0
   let l_retorno = null

   call cts40g03_data_hora_banco(2)
        returning m_data, m_hora

   open window w_ctc39m00 at 4,2 with form "ctc39m00"

   if m_prep_ctc39m00 is null or
      m_prep_ctc39m00 <> true then
      call ctc39m00_prepare()
   end if

   menu 'CANDIDATOS'
      before menu
         hide option 'Proximo'
         hide option 'Anterior'
         hide option 'Modificar'
         hide option 'Cancelar'
         hide option 'Aprovar'
         hide option 'Historico'

      command key ('S') 'Selecionar' 'Selecionar Socorristas'
         let l_retorno = ctc39m00_input('S')
         if l_retorno  then
            show option 'Proximo'
            show option 'Anterior'
            show option 'Modificar'
            show option 'Cancelar'
            show option 'Aprovar'
            show option 'Historico'
         else
            call ctc39m00_limpa_tela()
         end if

      command key ('P') 'Proximo' 'Selecionar Proximo Socorrista'
         if mr_tela.pestip    is null then
            error 'Nenhum registro selecionado!'
            next option 'Selecionar'
         else
            let l_retorno = ctc39m00_navega('P')
         end if

      command key ('A') 'Anterior' 'Selecionar Socorrista Anterior'
         if mr_tela.pestip    is null then
            error 'Nenhum registro selecionado!'
            next option 'Selecionar'
         else
            let l_retorno = ctc39m00_navega('A')
         end if

      command key ('M') 'Modificar' 'Modificar Socorrista'
         if mr_tela.pestip    is null then
            error 'Nenhum registro selecionado!'
            next option 'Selecionar'
         else
            let l_retorno = ctc39m00_input('M')
         end if

      command key ('I') 'Incluir' 'Incluir Socorrista'
         let l_retorno = ctc39m00_input('I')
         if l_retorno then
            show option 'Modificar'
            show option 'Cancelar'
            show option 'Aprovar'
            show option 'Historico'
         else
            call ctc39m00_limpa_tela()
            hide option 'Modificar'
            hide option 'Cancelar'
            hide option 'Aprovar'
            hide option 'Historico'
         end if
         hide option 'Proximo'
         hide option 'Anterior'

         next option 'Selecionar'

      command key ('C') 'Cancelar' 'Cancelar Socorrista'
         if mr_tela.pestip    is null then
            error 'Nenhum registro selecionado!'
            next option 'Selecionar'
         else
            let l_retorno = ctc39m00_altera_situacao(3)
         end if

      command key ('R') 'Aprovar' 'Aprovar Socorrista'
         if mr_tela.pestip    is null then
            error 'Nenhum registro selecionado!'
            next option 'Selecionar'
         else
            let l_retorno = ctc39m00_altera_situacao(2)
         end if

      command key ("D")"raDar" "Acesso ao Sistema Radar"
        call chama_prog("Radar","ofptm076",'')
                   returning m_situacao
        if m_situacao <> 0 then # problemas na execucao
           if  m_situacao < 0 then
               error "Erro de consistencia. Contate o Radar - ",m_situacao
             else
               error "Erro de execucao. Contate o Radar - ",m_situacao
           end if
        end if

      command key ("H") 'Historico' 'Consulta o historico'
       if mr_tela.pestip    is null then
         error 'Nenhum registro selecionado!'
         next option 'Selecionar'
      else
         let l_aux = 'Candidato'
         call ctb85g00(4
                      ,l_aux
                      ,m_pstcndcod
                      ,mr_tela.pstcndnom)
      end if

      command key ('E') 'Encerrar' 'Retorna ao menu anterior'
         exit menu

   end menu

   close window w_ctc39m00

end function


#-----------------------------------------------#
function ctc39m00_input(l_operacao)
#-----------------------------------------------#
   define l_operacao   char(1)
   define l_result     smallint
   define l_retorno    smallint
         ,l_conf       char(1)
         ,l_tempo_hab  integer
         ,l_ano1       integer
         ,l_ano2       integer
         ,l_mes1       integer
         ,l_mes2       integer
         ,l_dia1       integer
         ,l_dia2       integer
         ,l_rgenum       like dpakcnd.rgenum
         ,l_ufdnom       like glakest.ufdnom
         ,l_srrstt       like datksrr.srrstt

   define lr_retorno   record
          resultado    smallint
         ,mensagem     char(60)
         ,nomrazsoc    like dpaksocor.nomrazsoc
         ,rspnom       like dpaksocor.rspnom
         ,teltxt       like dpaksocor.teltxt
          end record

   let l_result = true
   let l_retorno = null
   let l_conf = null
   let l_ano1 = 0
   let l_ano2 = 0
   let l_mes1 = 0
   let l_mes2 = 0
   let l_dia1 = 0
   let l_dia2 = 0
   let l_tempo_hab = 0
   let l_rgenum = null
   let l_ufdnom = null
   let l_srrstt = null

   initialize lr_retorno.* to null
   initialize am_prestadores to null
   initialize mr_tela_ant to null

   if l_operacao <> 'M' then
      call ctc39m00_limpa_tela()
   else
      let mr_tela_ant.* = mr_tela.*
   end if

   input by name mr_tela.pestip
                ,mr_tela.cgccpfnum
                ,mr_tela.cgcord
                ,mr_tela.cgccpfdig
                ,mr_tela.pstcndnom
                ,mr_tela.rgenum
                ,mr_tela.rgeufdcod
                ,mr_tela.nscdat
                ,mr_tela.cnhnum
                ,mr_tela.cnhctgcod
                ,mr_tela.cnhpridat
                ,mr_tela.pstcndsitcod
                ,mr_tela.pstcndconcod
                ,mr_tela.rdranlultdat without defaults

      on key (control-c, f17, interrupt)
         let int_flag = true
         call ctc39m00_limpa_tela()
         exit input

      before input
         if l_operacao = 'S' then
            next field pestip
         else
            next field pstcndconcod
         end if

      before field pstcndconcod # PSI239178
         display by name mr_tela.pstcndconcod attribute (reverse)

      after field  pstcndconcod # PSI239178
         display by name mr_tela.pstcndconcod


         if (fgl_lastkey() = fgl_keyval('up') or
             fgl_lastkey() = fgl_keyval('left')) and
             l_operacao = 'M' then
             next field pstcndconcod
         end if

         if mr_tela.pstcndconcod is null then

            call cty09g00_popup_iddkdominio('pstcndconcod')
                 returning l_result, mr_tela.pstcndconcod,
                                     mr_tela.descrcon
            if l_result <> 1 then
                 next field pstcndconcod
            end if

         end if

         call cty11g00_iddkdominio('pstcndconcod',mr_tela.pstcndconcod)
              returning lr_ret.*

         let mr_tela.descrcon = lr_ret.cpodes

         display by name mr_tela.descrcon
         if l_operacao = 'M' then
            next field pstcndnom
         else
            next field pestip
         end if

      before field pestip
         display by name mr_tela.pestip    attribute (reverse)

      after field pestip
         display by name mr_tela.pestip

         if fgl_lastkey() = fgl_keyval('up') or
            fgl_lastkey() = fgl_keyval('left') then
            if l_operacao = 'S' then
               next field pestip
            else
               next field pstcndconcod
            end if
         end if

         if (mr_tela.pestip    <> 'F'  and
             mr_tela.pestip    <> 'J') or
             (l_operacao= "I" and mr_tela.pestip is null)  then
            error 'Informe F ou J'
            next field pestip
         end if

         if mr_tela.pestip  = 'F' then
            let mr_tela.cgcord = null
            clear cgcord
         end if

         if mr_tela.pestip    = 'J' then
            let mr_tela.rgenum = null
            clear rgenum
         end if

      before field cgccpfnum
         display by name mr_tela.cgccpfnum attribute (reverse)

      after field  cgccpfnum
         display by name mr_tela.cgccpfnum

         if fgl_lastkey() = fgl_keyval('up') or
            fgl_lastkey() = fgl_keyval('left') then
            next field pestip
         end if

         if mr_tela.cgccpfnum is null then
            if l_operacao <> 'S' then
               error 'Informe o CNPJ/CPF'
               next  field cgccpfnum
            end if
         end if

      before field cgcord
         if mr_tela.pestip  = 'F' then
            let mr_tela.cgcord    = 0
            next field cgccpfdig
         end if

         display by name mr_tela.cgcord attribute (reverse)

      after field  cgcord
         display by name mr_tela.cgcord

         if fgl_lastkey() = fgl_keyval('up') or
            fgl_lastkey() = fgl_keyval('left') then
            next field cgccpfnum
         end if

         if mr_tela.cgcord is null then
            if l_operacao <> 'S' then
               error 'Informe a Ordem'
               next  field cgcord
            end if
         end if

      before field cgccpfdig
         display by name mr_tela.cgccpfdig attribute (reverse)

      after field  cgccpfdig
         display by name mr_tela.cgccpfdig

         if fgl_lastkey() = fgl_keyval('up') or
            fgl_lastkey() = fgl_keyval('left') then
            if mr_tela.pestip = 'F' then
               next field cgccpfnum
            else
               next field cgcord
            end if
         end if

         if mr_tela.cgccpfdig is null then
            if l_operacao <> 'S' then
               error 'Informe o Digito'
               next  field cgccpfdig
            end if
         end if

         case mr_tela.pestip
            when 'F'
               if mr_tela.cgccpfdig <> f_fundigit_digitocpf(mr_tela.cgccpfnum) then
                  error 'Digito invalido!'
                  #Alteração de cgccpfdig para cgccpfnum efetuada por Robert Lima
                  next field cgccpfnum
               end if
            when 'J'
               if mr_tela.cgccpfdig <> f_fundigit_digitocgc(mr_tela.cgccpfnum,mr_tela.cgcord) then
                  error 'Digito invalido!'
                  next field cgccpfnum
               end if
         end case

         if  l_operacao = "I" then
             let m_count = 0

             open cctc39m00005 using mr_tela.cgccpfnum
                                    ,mr_tela.cgcord
                                    ,mr_tela.cgccpfdig
             whenever error continue
             fetch cctc39m00005
             whenever error stop
             if sqlca.sqlcode <> notfound then
                if sqlca.sqlcode = 0 then
                   let l_retorno = ctc39m00_seleciona(1)
                    let m_e_soc = true
                 else
                    error 'Erro SELECT cctc39m00005: ', sqlca.sqlcode
                end if
                exit input
             end if

             ## Verifica se ja esta como socorrista
             call ctc39m00_val_socorrista(mr_tela.cgccpfnum
                                         ,mr_tela.cgcord
                                         ,mr_tela.cgccpfdig, "","")
                  returning l_result, l_srrstt

             if l_srrstt = 1 then
                call cts08g01("A", "N", "", "NAO E POSSIVEL INCLUIR CANDIDATO",
                         "POIS E SOCORRISTA ATIVO", "")
                     returning l_conf
                let mr_tela.pestip = null
                let int_flag = true
                exit input
             end if

         else
            if mr_tela.cgccpfdig is not null then
               let l_result = ctc39m00_seleciona(1)
               exit input
            end if
         end if

      before field pstcndnom
         display by name mr_tela.pstcndnom attribute (reverse)

      after field pstcndnom
         display by name mr_tela.pstcndnom

         if l_operacao = 'S' then
            if fgl_lastkey() = fgl_keyval('up') or
               fgl_lastkey() = fgl_keyval('left') then
               next field cgccpfnum
            end if
         end if

         if l_operacao = 'M' then
            if fgl_lastkey() = fgl_keyval('up') or
               fgl_lastkey() = fgl_keyval('left') then
               next field pstcndconcod
            end if

            if mr_tela.pestip    = 'J' then
               next field rgeufdcod
            end if
         end if

         if l_operacao = "S" then
            if mr_tela.pstcndnom is null then
               next field pstcndsitcod
            else
               exit input
            end if
         else
            if mr_tela.pstcndnom is null then
               next field pstcndnom
            end if
         end if

      before field rgenum
         let l_rgenum = mr_tela.rgenum
         display by name mr_tela.rgenum attribute (reverse)

      after field  rgenum
         display by name mr_tela.rgenum

      before field rgeufdcod
         display by name mr_tela.rgeufdcod attribute (reverse)

      after field  rgeufdcod
         display by name mr_tela.rgeufdcod

         if l_operacao = 'M' then
            if fgl_lastkey() = fgl_keyval('up') or
               fgl_lastkey() = fgl_keyval('left') and
               (mr_tela.pestip    = 'J') then
               next field pstcndnom
            end if
         end if

         if mr_tela.rgeufdcod is not null then
            call F_FUNGERAL_FEDERACAO(mr_tela.rgeufdcod)
                 returning l_ufdnom

            if l_ufdnom is null then
               error "Unidade de Federacao invalida"
               next field rgeufdcod
            end if

            if l_operacao = "I" or l_rgenum <> mr_tela.rgenum then
               ## Verifica se ja esta como socorrista
               call ctc39m00_val_socorrista("", "", ""
                                            ,mr_tela.rgenum
                                            ,mr_tela.rgeufdcod)
                    returning l_result, l_srrstt

               if l_result = false then
                  next field pestip
               end if

               if l_srrstt = 1 then
                  call cts08g01("A", "N","", "NAO E POSSIVEL INCLUIR CANDIDATO",
                           "POIS E SOCORRISTA ATIVO", "")
                       returning l_conf
                   let mr_tela.pestip = null
                   let int_flag = true
                   exit input
                end if
            end if

        end if

      before field nscdat
         display by name mr_tela.nscdat attribute (reverse)

      after field  nscdat
         display by name mr_tela.nscdat
         call ctc39m00_mostra_idade()

      before field cnhnum
         display by name mr_tela.cnhnum attribute (reverse)

      after field  cnhnum
         display by name mr_tela.cnhnum

      before field cnhctgcod
         display by name mr_tela.cnhctgcod attribute (reverse)


      after field  cnhctgcod
         display by name mr_tela.cnhctgcod


      before field cnhpridat
         display by name mr_tela.cnhpridat attribute (reverse)

      after field  cnhpridat
         display by name mr_tela.cnhpridat

         if l_operacao = 'I' then
            if fgl_lastkey() = fgl_keyval('up') or
               fgl_lastkey() = fgl_keyval('left') then
               next field cnhctgcod
            end if

         end if

         if mr_tela.cnhpridat is not null then

            let l_ano1 = year(m_data)
            let l_ano2 = year(mr_tela.cnhpridat)
            let l_tempo_hab = l_ano1 - l_ano2

            if l_tempo_hab <= 2 then
               let l_mes1 = month(m_data)
               let l_mes2 = month(mr_tela.cnhpridat)

               if l_mes1 < l_mes2 then
                  let l_tempo_hab = 1
               else
                  let l_dia1 = day(m_data)
                  let l_dia2 = day(mr_tela.cnhpridat)
                  if l_dia1 < l_dia2 then
                     let l_tempo_hab = 1
                  else
                     let l_tempo_hab = 2
                  end if
               end if
            end if
            if l_tempo_hab < 2 then
               call cts08g01("A", "N", "", "CANDIDATO COM MENOS DE 2 ANOS",
                        "DE HABILITACAO", "")
                    returning l_conf
            end if

         end if

         if l_operacao = "S" then
            next field pstcndsitcod
         else

            let mr_tela.cademp = g_issk.empcod
            let mr_tela.cadmat = g_issk.funmat
            let mr_tela.atlemp = g_issk.empcod
            let mr_tela.atlmat = g_issk.funmat

            if l_operacao = 'I' then
               call cty08g00_nome_func(mr_tela.cademp,mr_tela.cadmat,
                                       "F")
                   returning lr_retornonome.*
               let mr_tela.cadnome = lr_retornonome.funnom
               display by name mr_tela.cadnome
               let l_result = ctc39m00_inclui()
               if l_result = true then
                   let l_result = ctc39m00_inclui_prestadores(l_operacao)
               else
                   error 'Inclusao nao foi efetuada com sucesso!' sleep 2
               end if
               exit input
            else
               if l_operacao = 'M' then
                   next field pstcndsitcod
               end if
            end if
         end if

      before field pstcndsitcod
         display by name mr_tela.pstcndsitcod attribute (reverse)

      after field  pstcndsitcod
         display by name mr_tela.pstcndsitcod


         if (fgl_lastkey() = fgl_keyval('up') or
             fgl_lastkey() = fgl_keyval('left')) and
             l_operacao = 'M' then
             next field cnhpridat
         else
             if fgl_lastkey() = fgl_keyval('up') or
                fgl_lastkey() = fgl_keyval('left') then
                next field cnhctgcod
             end if
         end if

         if mr_tela.pstcndsitcod is null then
            call cty09g00_popup_iddkdominio('pstcndsitcod')
                 returning l_result, mr_tela.pstcndsitcod,
                                     mr_tela.descrsit
            if l_result <> 1 then
                 next field pstcndsitcod
            end if

         end if

         call cty11g00_iddkdominio('pstcndsitcod',mr_tela.pstcndsitcod)
              returning lr_ret.*

         let mr_tela.descrsit = lr_ret.cpodes
         display by name mr_tela.pstcndsitcod
         display by name mr_tela.descrsit

         if l_operacao = 'M' then # PSI239178
             if mr_tela.pstcndsitcod = 2 or mr_tela.pstcndsitcod = 3 then
                 sleep 2
                 let l_retorno = ctc39m00_altera_situacao(mr_tela.pstcndsitcod)
             end if
             let l_result = ctc39m00_altera()
             let l_result = ctc39m00_inclui_prestadores(l_operacao)
         end if
         exit input

   end input

   if int_flag then
      let int_flag = false
      return l_result
   end if

   let l_result = ctc39m00_seleciona(l_result)

   if l_operacao <> "S" and mr_tela.pstcndsitcod = 1 and
      m_e_soc = false then
      call cts08g01("A", "S", "", "",
                        "APROVAR AGORA COMO SOCORRISTA S/N ?", "")
               returning l_conf

      if l_conf = "S" then
         call ctc39m00_sit_ps(mr_tela.pstcndsitcod)
              returning m_situacao

         call ctc44m00( mr_tela.pestip
                       ,mr_tela.cgccpfnum
                       ,mr_tela.cgcord
                       ,mr_tela.cgccpfdig
                       ,mr_tela.pstcndnom
                       ,mr_tela.rgenum
                       ,mr_tela.rgeufdcod
                       ,mr_tela.nscdat
                       ,mr_tela.cnhnum
                       ,mr_tela.cnhctgcod
                       ,mr_tela.cnhpridat
                       ,m_situacao
                       ,mr_tela.rdranlultdat)
      end if
   end if

   return l_result

end function

#-----------------------------------------------#
function ctc39m00_altera_situacao(l_operacao)
#-----------------------------------------------#
   define l_operacao      smallint
   define l_result        smallint
         ,l_opc           char(1)
         ,l_conf          char(1)
         ,l_srrcoddig     like datksrr.srrcoddig
         ,l_res           smallint
         ,l_msg           char(80)
         ,l_cpodes        char(80)
         ,l_texto         char(200)

   define lr_retorno record
          erro     smallint
         ,mensagem char(100)
         ,cpodes   like iddkdominio.cpodes
          end record

   let l_result = true
   let l_srrcoddig = null
   let l_res = null
   let l_msg = null
   let l_cpodes = null
   let l_texto = null

   let int_flag = false
   let l_opc = null
   let l_conf = null

   while l_opc is null or
      (l_opc <> 'S' and l_opc <> 'N')

      if l_operacao = 3 then
         prompt 'Deseja cancelar o candidato a socorrista? (S/N)' for l_opc
      else
         prompt 'Deseja aprovar o candidato a socorrista? (S/N)'  for l_opc
      end if

      if int_flag then
         let int_flag = false
         let l_opc    = 'N'
      else
         let l_opc = upshift(l_opc)
      end if
   end while

   if l_opc = 'S' then
      let m_atldat = ctc39m00_dataatual()
      let mr_tela.atldat = date(m_atldat)
      let mr_tela.atlhor = extend(m_atldat, hour to minute)

      let mr_tela.atlemp = g_issk.empcod
      let mr_tela.atlmat = g_issk.funmat

      let mr_tela.pstcndsitcod = l_operacao
      call cty11g00_iddkdominio('pstcndsitcod',mr_tela.pstcndsitcod)
           returning lr_retorno.*

      if lr_retorno.erro <> 1 then
         error lr_retorno.mensagem
         let l_result = false
         return l_result
      end if

      let mr_tela.descrsit = lr_retorno.cpodes

      display by name mr_tela.pstcndsitcod
      display by name mr_tela.descrsit

      whenever error continue
      execute pctc39m00003 using l_operacao,
                                 m_atldat,
                                 mr_tela.atlemp,
                                 mr_tela.atlmat,
                                 m_pstcndcod
      whenever error stop
      if sqlca.sqlcode <> 0 then
         error 'Erro UPDATE pctc39m00003: ', sqlca.sqlcode
         error 'CTC39M00 / ctc39moo_altera_situacao() / ',l_operacao
                                                     ,'/',m_atldat
                                                     ,'/',mr_tela.atlemp
                                                     ,'/',mr_tela.atlmat
                                                     ,'/',m_pstcndcod
         let l_result = false
      else
         display by name mr_tela.caddat
                        ,mr_tela.cadhor
                        ,mr_tela.atldat
                        ,mr_tela.atlhor
                        ,mr_tela.atlemp
                        ,mr_tela.atlmat
                        ,mr_tela.pstcndsitcod
                        ,mr_tela.descrsit

         if l_operacao = 2 then
            call ctc39m00_sit_ps(mr_tela.pstcndsitcod)
                 returning m_situacao

            call ctc44m00_sel_srr(mr_tela.cgccpfnum, mr_tela.cgcord,
                                  mr_tela.cgccpfdig)
                 returning l_srrcoddig

            if l_srrcoddig is not null then

               let m_srrcoddig = l_srrcoddig

               call cty11g00_iddkdominio("pstcndsitcod" ,mr_tela.pstcndsitcod)
                    returning l_res ,l_msg ,l_cpodes

               if l_res <> 1 then
                  let l_msg = mr_tela.pstcndsitcod
               end if

                 let l_texto = 'SITUACAO DO RADAR EM ' ,m_data ,' '
                            ,l_cpodes clipped ,' ' ,l_msg

               begin work
               call ctd18g01_grava_hist(l_srrcoddig
                                       ,l_texto
                                       ,m_data
                                       ,g_issk.empcod
                                       ,g_issk.funmat
                                       ,'F')
                    returning l_res ,l_msg

               if l_res <> 1 then
                  display l_msg clipped
                  rollback work
               else

                  if l_res <> 1 then
                     let l_res = 0
                     display l_msg
                  else
                     call ctd18g00_update_socorrista(m_data,
                                                     mr_tela.pstcndsitcod,
                                                     m_situacao,
                                                     m_data,l_srrcoddig)
                          returning l_res, l_msg
                  end if
                  if l_res = 1 then
                     commit work
                  else
                     display l_msg
                  end if

               end if
            end if

            call ctc44m00( mr_tela.pestip
                          ,mr_tela.cgccpfnum
                          ,mr_tela.cgcord
                          ,mr_tela.cgccpfdig
                          ,mr_tela.pstcndnom
                          ,mr_tela.rgenum
                          ,mr_tela.rgeufdcod
                          ,mr_tela.nscdat
                          ,mr_tela.cnhnum
                          ,mr_tela.cnhctgcod
                          ,mr_tela.cnhpridat
                          ,m_situacao
                          ,mr_tela.rdranlultdat)
         end if
      end if
   end if

   return l_result

end function

#-----------------------------------------------#
function ctc39m00_seleciona(l_result)
#-----------------------------------------------#
   define l_result     smallint
         ,l_sql        char(600)
         ,l_qtdreg     integer


   ##let l_result = true
   let l_qtdreg = 0

   let l_sql = ' select pstcndcod '
                    ,' ,pestip '
                    ,' ,cgccpfnum '
                    ,' ,cgcord '
                    ,' ,cgccpfdig '
                    ,' ,pstcndnom '
                    ,' ,rgenum '
                    ,' ,rgeufdcod '
                    ,' ,nscdat '
                    ,' ,cnhnum '
                    ,' ,cnhctgcod '
                    ,' ,cnhpridat '
                    ,' ,pstcndsitcod '
                    ,' ,rdranlultdat '
                    ,' ,caddat '
                    ,' ,cademp '
                    ,' ,cadmat '
                    ,' ,atldat '
                    ,' ,atlemp '
                    ,' ,atlmat '
                    ,' ,pstcndconcod '
                    ,' ,srrcoddig '
             ,'   from dpakcnd '
             ,'  where 1 = 1 '

   if mr_tela.pestip is not null then
      let l_sql = l_sql clipped, ' and pestip    = "', mr_tela.pestip, '" '
   end if
   if mr_tela.cgccpfnum is not null then
      let l_sql = l_sql clipped, ' and cgccpfnum = ', mr_tela.cgccpfnum
   end if
   if mr_tela.cgcord is not null then
      let l_sql = l_sql clipped, ' and cgcord = ', mr_tela.cgcord
   end if
   if mr_tela.cgccpfdig is not null then
      let l_sql = l_sql clipped, ' and cgccpfdig = ', mr_tela.cgccpfdig
   end if

   if mr_tela.pstcndnom is not null then
      let l_sql = l_sql clipped, ' and pstcndnom like "%', mr_tela.pstcndnom clipped, '%"'
   end if
   if mr_tela.pstcndsitcod is not null then
      let l_sql = l_sql clipped, ' and pstcndsitcod = ', mr_tela.pstcndsitcod
   end if
   #if mr_tela.pstcndconcod is not null then
   #   let l_sql = l_sql clipped, ' and pstcndconcod = ', mr_tela.pstcndconcod
   #end if

   prepare pctc39m00001 from l_sql
   declare cctc39m00001 scroll cursor for pctc39m00001

   open cctc39m00001
   whenever error continue
   fetch cctc39m00001 into m_pstcndcod
                          ,mr_tela.pestip
                          ,mr_tela.cgccpfnum
                          ,mr_tela.cgcord
                          ,mr_tela.cgccpfdig
                          ,mr_tela.pstcndnom
                          ,mr_tela.rgenum
                          ,mr_tela.rgeufdcod
                          ,mr_tela.nscdat
                          ,mr_tela.cnhnum
                          ,mr_tela.cnhctgcod
                          ,mr_tela.cnhpridat
                          ,mr_tela.pstcndsitcod
                          ,mr_tela.rdranlultdat
                          ,m_caddat
                          ,mr_tela.cademp
                          ,mr_tela.cadmat
                          ,m_atldat
                          ,mr_tela.atlemp
                          ,mr_tela.atlmat
                          ,mr_tela.pstcndconcod
                          ,m_srrcoddig
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         error 'Nao existe candidato nesta condicao'
         let l_result = false
      else
         error 'Erro SELECT cctc39m00001: ', sqlca.sqlcode, 'CTC39M00 / ctc39moo_seleciona()'
      end if
      let l_result = false
   else
      if m_srrcoddig is null or m_srrcoddig = "" then
           display '                ' at 4,18
           display 'NAO' at 4,18
      else
           open cctc39m00010 using m_srrcoddig
           whenever error continue
           fetch cctc39m00010 into m_datqra
           whenever error stop
           let mr_tela.datqra = m_datqra
           display '                ' at 4,18
           display 'desde ', mr_tela.datqra at 4,18
      end if
   end if

   let mr_tela.caddat = date(m_caddat)
   let mr_tela.cadhor = extend(m_caddat, hour to minute)
   let mr_tela.atldat = date(m_atldat)
   let mr_tela.atlhor = extend(m_atldat, hour to minute)

   call cty08g00_nome_func(mr_tela.cademp,mr_tela.cadmat, "F")
        returning lr_retornonome.*

   let mr_tela.cadnome = lr_retornonome.funnom

   call cty08g00_nome_func(mr_tela.atlemp,mr_tela.atlmat, "F")
        returning lr_retornonome.*

   let mr_tela.atlnome = lr_retornonome.funnom

   if m_pstcndcod <> 0 then
      let l_result = ctc39m00_mostra_dados_pst(l_result)
   else
      call ctc39m00_limpa_tela()
   end if



   return l_result

end function

#-----------------------------------------------#
function ctc39m00_navega(l_operacao)
#-----------------------------------------------#
   define l_operacao   char(1)
   define l_result     smallint

   let l_result = true

   if l_operacao = 'P' then
      whenever error continue
      fetch next cctc39m00001 into m_pstcndcod
                                  ,mr_tela.pestip
                                  ,mr_tela.cgccpfnum
                                  ,mr_tela.cgcord
                                  ,mr_tela.cgccpfdig
                                  ,mr_tela.pstcndnom
                                  ,mr_tela.rgenum
                                  ,mr_tela.rgeufdcod
                                  ,mr_tela.nscdat
                                  ,mr_tela.cnhnum
                                  ,mr_tela.cnhctgcod
                                  ,mr_tela.cnhpridat
                                  ,mr_tela.pstcndsitcod
                                  ,mr_tela.rdranlultdat
                                  ,m_caddat
                                  ,mr_tela.cademp
                                  ,mr_tela.cadmat
                                  ,m_atldat
                                  ,mr_tela.atlemp
                                  ,mr_tela.atlmat
                                  ,mr_tela.pstcndconcod
                                  ,m_srrcoddig
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
            error 'Nao existe um proximo registro'
         else
            error 'Erro SELECT cctc39m00001 / ', sqlca.sqlcode, ' / ',  sqlca.sqlerrd[2]
            error 'CTC39M00 / ctc39m00_navega() '
            let l_result = false
         end if
      end if
   else
      whenever error continue
      fetch previous cctc39m00001 into m_pstcndcod
                                      ,mr_tela.pestip
                                      ,mr_tela.cgccpfnum
                                      ,mr_tela.cgcord
                                      ,mr_tela.cgccpfdig
                                      ,mr_tela.pstcndnom
                                      ,mr_tela.rgenum
                                      ,mr_tela.rgeufdcod
                                      ,mr_tela.nscdat
                                      ,mr_tela.cnhnum
                                      ,mr_tela.cnhctgcod
                                      ,mr_tela.cnhpridat
                                      ,mr_tela.pstcndsitcod
                                      ,mr_tela.rdranlultdat
                                      ,m_caddat
                                      ,mr_tela.cademp
                                      ,mr_tela.cadmat
                                      ,m_atldat
                                      ,mr_tela.atlemp
                                      ,mr_tela.atlmat
                                      ,mr_tela.pstcndconcod
                                      ,m_srrcoddig
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
            error ' Nao existe um registro anterior'
         else
            error 'Erro SELECT cctc39m00001: ', sqlca.sqlcode
            error 'CTC39M00 / ctc39m00_navega() '
            let l_result = false
         end if
      end if
   end if

   if m_srrcoddig is null or m_srrcoddig = "" then
        display '                ' at 4,18
        display 'NAO' at 4,18
   else
        open cctc39m00010 using m_srrcoddig
        whenever error continue
        fetch cctc39m00010 into m_datqra
        whenever error stop
        let mr_tela.datqra = m_datqra
        display '                ' at 4,18
        display 'desde ', mr_tela.datqra at 4,18
   end if

   let mr_tela.cadhor = extend(m_caddat, hour to minute)
   let mr_tela.cadhor = mr_tela.cadhor

   let mr_tela.atlhor = extend(m_atldat, hour to minute)
   let mr_tela.atlhor = mr_tela.atlhor

   call cty08g00_nome_func(mr_tela.cademp,mr_tela.cadmat,"F")
        returning lr_retornonome.*

   let mr_tela.cadnome = lr_retornonome.funnom
   display by name mr_tela.cadnome

   call cty08g00_nome_func(mr_tela.atlemp,mr_tela.atlmat,"F")
        returning lr_retornonome.*

   let mr_tela.atlnome = lr_retornonome.funnom
   display by name mr_tela.atlnome

   initialize am_prestadores to null
   let l_result = ctc39m00_mostra_dados_pst(1)

   if not l_result then
      call ctc39m00_limpa_tela()
   end if

   return l_result

end function

#-----------------------------------------------#
function ctc39m00_altera()
#-----------------------------------------------#
   define l_retorno    smallint

   let l_retorno = true

   let m_atldat  = ctc39m00_dataatual()
   let mr_tela.atldat = date(m_caddat)
   let mr_tela.atlhor = extend(m_caddat, hour to minute)

   display by name mr_tela.atldat, mr_tela.atlhor
   call cty08g00_nome_func(mr_tela.atlemp,mr_tela.atlmat,"F")
        returning lr_retornonome.*

   let mr_tela.atlnome = lr_retornonome.funnom
   display by name mr_tela.atlnome

   whenever error continue

   call ctc30m00_remove_caracteres(mr_tela.pstcndnom)
            returning mr_tela.pstcndnom


   execute pctc39m00002 using mr_tela.pstcndnom
                             ,mr_tela.rgenum
                             ,mr_tela.rgeufdcod
                             ,mr_tela.nscdat
                             ,mr_tela.cnhnum
                             ,mr_tela.cnhctgcod
                             ,mr_tela.cnhpridat
                             ,mr_tela.pstcndsitcod
                             ,mr_tela.pstcndconcod
                             ,m_atldat
                             ,g_issk.empcod
                             ,g_issk.funmat
                             ,g_issk.usrtip
                             ,m_pstcndcod
   whenever error stop
   if sqlca.sqlcode <> 0 then
      error 'Erro UPDATE cctc39m00002: ', sqlca.sqlcode
      error 'CTC39M00 / ctc39m00_altera()  / ', mr_tela.pstcndnom
                                        ,' / ', mr_tela.rgenum
                                        ,' / ', mr_tela.rgeufdcod
                                        ,' / ', mr_tela.nscdat
                                        ,' / ', mr_tela.cnhnum
                                        ,' / ', mr_tela.cnhctgcod
                                        ,' / ', mr_tela.cnhpridat
                                        ,' / ', mr_tela.pstcndsitcod
                                        ,' / ', mr_tela.pstcndconcod
                                        ,' / ', m_atldat
                                        ,' / ', g_issk.empcod
                                        ,' / ', g_issk.funmat
                                        ,' / ', g_issk.usrtip
                                        ,' / ', m_pstcndcod
                                        ,' / ', g_issk.empcod
                                        ,' / ', g_issk.funmat
                                        ,' / ', g_issk.usrtip
                                        ,' / ', m_pstcndcod

      let l_retorno = false
   end if
   call ctc39m00_verifica_mod()
   return l_retorno

end function

#-----------------------------------------------#
function ctc39m00_inclui()
#-----------------------------------------------#
   define l_retorno     smallint,
          l_mensagem    char(60),
          l_mensagem2   char(60),
          l_stt         smallint
   define lr_retorno   record
                       result        smallint
                      ,stats         char(1)
                      ,msg           char(80)  ### 'L' -> Liberado / 'S -> Suspenso
                       end record

   let l_mensagem  = null
   let l_mensagem2 = null
   let l_stt       = null

   let l_retorno = true

   let mr_tela.rdranlultdat  = m_data
   let m_caddat  = ctc39m00_dataatual()
   let mr_tela.caddat = m_caddat
   let mr_tela.atldat = m_caddat
   let mr_tela.cadhor = extend(m_caddat, hour to minute)
   let mr_tela.atlhor = mr_tela.cadhor

   display by name mr_tela.caddat, mr_tela.atldat,
                   mr_tela.cadhor, mr_tela.atlhor

   display by name mr_tela.atldat, mr_tela.atlhor
   call cty08g00_nome_func(mr_tela.atlemp,mr_tela.atlmat,"F")
        returning lr_retornonome.*

   let mr_tela.atlnome = lr_retornonome.funnom
   display by name mr_tela.atlnome
   if mr_tela.cgcord is null then
      let mr_tela.cgcord = 0
   end if

   display '------ Chamada ffpta070 ------'
   display 'mr_tela.pestip   : ',mr_tela.pestip
   display 'mr_tela.cgccpfnum: ',mr_tela.cgccpfnum
   display 'mr_tela.cgcord   : ',mr_tela.cgcord
   display 'mr_tela.cgccpfdig: ',mr_tela.cgccpfdig
   display "3,' ',3"
   call ffpta070(mr_tela.pestip, mr_tela.cgccpfnum,mr_tela.cgcord,mr_tela.cgccpfdig,3,' ',3)
      returning lr_retorno.*
   display '------ Retorno da ffpta070 ------'
   display 'lr_retorno.result: ', lr_retorno.result
   display 'lr_retorno.stats : ', lr_retorno.stats
   display 'lr_retorno.msg   : ', lr_retorno.msg   clipped
   if lr_retorno.result = 0 then
      case lr_retorno.stats
           when "L"  ## LIBERADO
                 let mr_tela.pstcndsitcod = 1 ##ANALISE OK, AGUARDANDO FC
           otherwise ## QQ outra situacao <> de Liberado
                 let mr_tela.pstcndsitcod = 4 ##LIBERACAO PENDENTE
      end case

   else
      error lr_retorno.msg sleep 3
      let l_retorno = false
   end if

   if l_retorno then

      whenever error continue

      call ctc30m00_remove_caracteres(mr_tela.pstcndnom)
            returning mr_tela.pstcndnom

      execute pctc39m00004 using mr_tela.cgccpfnum,
                                 mr_tela.cgccpfdig,
                                 mr_tela.cgcord,
                                 mr_tela.pestip,
                                 mr_tela.pstcndnom,
                                 mr_tela.rgenum,
                                 mr_tela.rgeufdcod,
                                 mr_tela.nscdat,
                                 mr_tela.cnhnum,
                                 mr_tela.cnhctgcod,
                                 mr_tela.cnhpridat,
                                 mr_tela.pstcndsitcod,
                                 mr_tela.pstcndconcod,
                                 mr_tela.rdranlultdat,
                                 m_caddat,
                                 g_issk.empcod,
                                 g_issk.funmat,
                                 g_issk.usrtip,
                                 m_caddat,
                                 g_issk.empcod,
                                 g_issk.funmat,
                                 g_issk.usrtip,
                                 m_srrcoddig
      whenever error stop

      if sqlca.sqlcode <> 0 then
         error 'Erro INSERT pctc39m00004: ', sqlca.sqlcode
         sleep 2
         error 'CTC39M00 / ctc39m00_inclui() / ', mr_tela.cgccpfnum,
                                           ' / ', mr_tela.cgccpfdig,
                                           ' / ', mr_tela.cgcord,
                                           ' / ', mr_tela.pestip,
                                           ' / ', mr_tela.pstcndnom,
                                           ' / ', mr_tela.rgenum,
                                           ' / ', mr_tela.rgeufdcod,
                                           ' / ', mr_tela.nscdat,
                                           ' / ', mr_tela.cnhnum,
                                           ' / ', mr_tela.cnhctgcod,
                                           ' / ', mr_tela.cnhpridat,
                                           ' / ', mr_tela.pstcndsitcod,
                                           ' / ', mr_tela.rdranlultdat,
                                           ' / ', m_caddat,
                                           ' / ', g_issk.empcod,
                                           ' / ', g_issk.funmat,
                                           ' / ', g_issk.usrtip,
                                           ' / ', m_caddat,
                                           ' / ', g_issk.empcod,
                                           ' / ', g_issk.funmat,
                                           ' / ', g_issk.usrtip
         let l_retorno = false
      end if

      open cctc39m00008
      whenever error continue
      fetch cctc39m00008 into m_pstcndcod
      whenever error stop
      if sqlca.sqlcode <> 0 then
         error 'CTC39M00 / ctc39m00_inclui()'
         let l_retorno = false
      end if

      if l_retorno = true then
           let l_mensagem  = "Candidato [",mr_tela.pstcndnom clipped,"] incluido "
           let l_mensagem2 = 'Inclusao no cadastro do Candidato. Codigo : ', m_pstcndcod using '<<<<<'

           let l_stt = ctc39m00_grava_hist(m_pstcndcod
                                          ,l_mensagem
                                          ,today
                                          ,l_mensagem2,"I")

      end if
   end if
   display 'FIM DA INCLUSAO'
   display 'l_mensagem : ',l_mensagem  clipped
   display 'l_mensagem2: ',l_mensagem2 clipped
   return l_retorno

end function

#-----------------------------------------------#
function ctc39m00_dataatual()
#-----------------------------------------------#
   define l_data      date
         ,l_hora      datetime hour to minute
         ,l_completo  datetime year to minute
         ,l_char      char(20)


   call cts40g03_data_hora_banco(2)
        returning l_data,
                  l_hora

   let l_char = l_data using 'yyyy-mm-dd' ,' ', l_hora

   let l_completo = l_char

   return l_completo

end function


#-----------------------------------------------#
function ctc39m00_mostra_dados_pst(l_result)
#-----------------------------------------------#
   define l_result     smallint
   define l_count      smallint
   define lr_retorno   record
          resultado    smallint
         ,mensagem     char(60)
         ,nomrazsoc    like dpaksocor.nomrazsoc
         ,rspnom       like dpaksocor.rspnom
         ,teltxt       like dpaksocor.teltxt
          end record

   initialize lr_retorno.* to null

   if l_result = false then
      let m_count = 1
   else
      if am_prestadores[1].codpres is not null then
         let m_count = 2
      end if
   end if

   let l_result = ctc39m00_mostra_consultoria()

   let l_result = ctc39m00_mostra_situacao()

   let l_result = true
   let l_count = 1
   let m_count = 1

   open cctc39m00007 using m_pstcndcod

   foreach cctc39m00007 into am_prestadores[m_count].codpres
                            ,am_prestadores[m_count].datpres

      call ctd12g00_dados_pst(1,am_prestadores[m_count].codpres)
         returning lr_retorno.*

      if lr_retorno.resultado <> 1 then
         exit foreach
      end if

      let am_prestadores[m_count].nompres   = lr_retorno.nomrazsoc
      let am_prestadores[m_count].masctela = '-'

      let m_count = m_count + 1
      if m_count > 100 then
         exit foreach
      end if
   end foreach

   let m_count = m_count - 1

   for l_count = 1 to 3
      display am_prestadores[l_count].codpres to s_ctc39m00[l_count].codpres
      display am_prestadores[l_count].masctela to s_ctc39m00[l_count].masctela
      display am_prestadores[l_count].nompres to s_ctc39m00[l_count].nompres
      display am_prestadores[l_count].datpres to s_ctc39m00[l_count].datpres
   end for


   call ctc39m00_mostra_idade()

   display by name mr_tela.pestip
                  ,mr_tela.cgccpfnum
                  ,mr_tela.cgcord
                  ,mr_tela.cgccpfdig
                  ,mr_tela.pstcndnom
                  ,mr_tela.rgenum
                  ,mr_tela.rgeufdcod
                  ,mr_tela.nscdat
                  ,mr_tela.idade
                  ,mr_tela.cnhnum
                  ,mr_tela.cnhctgcod
                  ,mr_tela.cnhpridat
                  ,mr_tela.pstcndsitcod
                  ,mr_tela.descrsit
                  ,mr_tela.pstcndconcod
                  ,mr_tela.descrcon
                  ,mr_tela.rdranlultdat
                  ,mr_tela.caddat
                  ,mr_tela.cadhor
                  ,mr_tela.cademp
                  ,mr_tela.cadmat
                  ,mr_tela.cadnome
                  ,mr_tela.atldat
                  ,mr_tela.atlhor
                  ,mr_tela.atlemp
                  ,mr_tela.atlmat
                  ,mr_tela.atlnome

   return l_result

end function

#-----------------------------------------------#
function ctc39m00_mostra_situacao()
#-----------------------------------------------#
   define l_result   smallint
   define lr_retorno record
          erro       smallint
         ,mensagem   char(100)
         ,cpodes     like iddkdominio.cpodes
         end record

   define lr_ret     record
          erro       smallint
         ,cpocod     smallint
         ,cpodes     like iddkdominio.cpodes
         end record

   initialize lr_retorno.* to null
   initialize lr_ret.* to null

   let l_result = true

   call cty11g00_iddkdominio('pstcndsitcod',mr_tela.pstcndsitcod)
      returning lr_retorno.*

   let mr_tela.descrsit = lr_retorno.cpodes
   display by name mr_tela.descrsit

   return l_result

end function

#-----------------------------------------------#
function ctc39m00_mostra_consultoria()
#-----------------------------------------------#
   define l_result   smallint
   define lr_retorno record
          erro       smallint
         ,mensagem   char(100)
         ,cpodes     like iddkdominio.cpodes
         end record

   define lr_ret     record
          erro       smallint
         ,cpocod     smallint
         ,cpodes     like iddkdominio.cpodes
         end record

   initialize lr_retorno.* to null
   initialize lr_ret.* to null

   let l_result = true

   call cty11g00_iddkdominio('pstcndconcod',mr_tela.pstcndconcod)
      returning lr_retorno.*

   let mr_tela.descrcon = lr_retorno.cpodes
   display by name mr_tela.descrcon

   return l_result

end function


#-----------------------------------------------#
function ctc39m00_mostra_idade()
#-----------------------------------------------#
   define l_char       char(30)

   let l_char = extend(today, year to month) - extend(mr_tela.nscdat, year to month)
   let mr_tela.idade = l_char[1,5]

   display by name mr_tela.idade

end function

#-----------------------------------------------#
function ctc39m00_limpa_tela()
#-----------------------------------------------#

   initialize mr_tela.* to null
   initialize am_prestadores to null
   let m_pstcndcod = null
   let m_srrcoddig = null
   let m_rspnom    = null
   let m_datpres   = null
   display '                ' at 4,18
   clear form

end function

#-----------------------------------------------#
function ctc39m00_inclui_prestadores(l_operacao)
#-----------------------------------------------#
   define l_retorno  smallint
   define l_result     smallint
   define l_arr      integer
         ,l_tela     integer
         ,l_acao     char(1)
         ,l_incluir  smallint
         ,l_prestant smallint
         ,l_i        smallint
         ,l_conf     char(1)
         ,l_operacao char(1)

   define lr_retorno   record
          resultado    smallint
         ,mensagem     char(60)
         ,nomrazsoc    like dpaksocor.nomrazsoc
         ,rspnom       like dpaksocor.rspnom
         ,teltxt       like dpaksocor.teltxt
          end record
   define lr_ffpta070  record
                       result        smallint
                      ,stats         char(1)
                      ,msg           char(80)  ### 'L' -> Liberado / 'S -> Suspenso
                       end record

   options
      insert key control-i
     ,delete key control-y

   initialize lr_retorno to null
   let l_retorno = true
   let l_conf  = null

   if m_count = 0 then
      let l_incluir = true
   else
      let l_incluir = false
   end if

   let l_result = ctc39m00_mostra_dados_pst(1)

   call set_count(m_count)

   input array am_prestadores without defaults from s_ctc39m00.*
      before row
         let l_arr  = arr_curr()
         let l_tela = scr_line()
         next field ghost

      before field ghost
         if am_prestadores[l_arr].codpres is null then
            let l_incluir = true
         end if

         if l_incluir then
            next field codpres
         end if

      after field ghost
         if fgl_lastkey() = 2014 then
            let l_incluir = true
         else
            if fgl_lastkey() = fgl_keyval('down')     or
               fgl_lastkey() = fgl_keyval('nextpage') then
               if l_arr < 100 then
                  if am_prestadores[l_arr+1].codpres is null then
                     next field ghost
                  else
                     continue input
                  end if
               else
                  next field ghost
               end if
            end if

            if fgl_lastkey() = fgl_keyval('up')       or
               fgl_lastkey() = fgl_keyval('prevpage') then
               continue input
            else
               if fgl_lastkey() = fgl_keyval('return') then
                  next field datpres
               else
                  next field ghost
               end if
            end if
         end if

      before field codpres
         let l_arr  = arr_curr()
         let l_tela = scr_line()
        if not l_incluir then
           next field ghost
        end if
        display am_prestadores[l_arr].codpres  to  s_ctc39m00[l_tela].codpres attribute (reverse)

      after field codpres
         let l_arr  = arr_curr()
         let l_tela = scr_line()
         display am_prestadores[l_arr].codpres  to  s_ctc39m00[l_tela].codpres

         if fgl_lastkey() = fgl_keyval('up') then
            if am_prestadores[l_arr].codpres is null then
               let l_incluir = false
               continue input
            end if
         end if

         if am_prestadores[l_arr].codpres is null then
            error 'Informe o codigo do Prestador!'
            next field codpres
         end if

         #for l_i = 1 to 100
         #   if am_prestadores[l_arr].codpres = am_prestadores[l_i].codpres and
         #      l_arr <> l_i then
         #      error 'Prestador ja informado na linha ', l_i  using '<&&'
         #      exit for
         #   end if
         #end for

         #if l_i <= 100 then
         #   next field codpres
         #end if
         call ctd12g00_dados_pst(1,am_prestadores[l_arr].codpres)
            returning lr_retorno.*

         if lr_retorno.resultado <> 1 then
            error 'Erro na selecao do nome do Prestador!'
            error lr_retorno.mensagem
            next field codpres
         end if

         if am_prestadores[l_arr].nompres is null then
            let am_prestadores[l_arr].nompres  = lr_retorno.nomrazsoc
            let am_prestadores[l_arr].datpres  = m_data
            let am_prestadores[l_arr].masctela = '-'
         end if

         display am_prestadores[l_arr].nompres   to s_ctc39m00[l_tela].nompres
         display am_prestadores[l_arr].datpres  to s_ctc39m00[l_tela].datpres
         display am_prestadores[l_arr].masctela to s_ctc39m00[l_tela].masctela

         whenever error continue
         execute pctc39m00006 using am_prestadores[l_arr].codpres
                                   ,m_pstcndcod
                                   ,am_prestadores[l_arr].datpres
         whenever error stop
         if sqlca.sqlcode <> 0 then
            error 'Erro INSERT pctc39m00006: ', sqlca.sqlcode
            let l_retorno = false
            exit input
         end if

         let l_incluir = false

      on key (control-c, f17, interrupt)
         let int_flag = false
         exit input

   end input

   options
      insert key f1
     ,delete key f2

   if l_operacao = "M" then
      call cts08g01("A", "S", "", "",
                    "SUBMETER A ANALISE DO RADAR S/N ?", "")
           returning l_conf

      if l_conf = "S" then
           display '----- CHAMADA DA FUNÇÃO ffpta070 TELA CTC39M00 -----'
           display 'mr_tela.pestip: ',mr_tela.pestip
           display 'mr_tela.cgccpfnum: ',mr_tela.cgccpfnum
           display 'mr_tela.cgcord: ', mr_tela.cgcord
           display 'mr_tela.cgccpfdig: ', mr_tela.cgccpfdig
           display '3, " ", 3'
           display '--------------- ctc39m00 ----------------------------'

         call ffpta070(mr_tela.pestip, mr_tela.cgccpfnum,
                       mr_tela.cgcord,mr_tela.cgccpfdig,3,' ',3)
              returning lr_ffpta070.*

              display '----- RETORNO DA FUNÇÃO ffpta070 TELA CTC39M00 -----'
              display 'lr_ffpta070.result:', lr_ffpta070.result
              display 'lr_ffpta070.stats :', lr_ffpta070.stats
              display 'lr_ffpta070.msg   :', lr_ffpta070.msg    clipped
              display '--------------- ctc39m00 ----------------------------'

         if lr_ffpta070.result = 0 then
            if lr_ffpta070.stats = 'L' then
               let mr_tela.pstcndsitcod = 1
            else
               let mr_tela.pstcndsitcod = 4
            end if

            let m_atldat = ctc39m00_dataatual()
            let mr_tela.atldat = date(m_atldat)
            let mr_tela.atlhor = extend(m_atldat, hour to minute)

            let mr_tela.atlemp = g_issk.empcod
            let mr_tela.atlmat = g_issk.funmat

            display '-------- ATUALIZANDO DADOS DO CANDIDATO --------'
            DISPLAY 'PREPARE pctc39m00003'
            DISPLAY 'mr_tela.pstcndsitcod:',mr_tela.pstcndsitcod
            DISPLAY 'm_atldat            :',m_atldat
            DISPLAY 'mr_tela.atlemp      :',mr_tela.atlemp
            DISPLAY 'mr_tela.atlmat      :',mr_tela.atlmat
            DISPLAY 'm_pstcndcod         :',m_pstcndcod

            whenever error continue
            execute pctc39m00003 using mr_tela.pstcndsitcod,
                                       m_atldat,
                                       mr_tela.atlemp,
                                       mr_tela.atlmat,
                                       m_pstcndcod
            DISPLAY 'sqlca.sqlcode do prepare pctc39m00003: ', sqlca.sqlcode
      whenever error stop
         else
            error lr_ffpta070.msg
            let l_retorno = false
         end if
      end if
   end if

   return l_retorno

end function

#------------------------------------------------
function ctc39m00_val_socorrista(lr_param)
#------------------------------------------------

   define lr_param   record
          cgccpfnum    like dpakcnd.cgccpfnum
         ,cgcord       like dpakcnd.cgcord
         ,cgccpfdig    like dpakcnd.cgccpfdig
         ,rgenum       like dpakcnd.rgenum
         ,rgeufdcod    like dpakcnd.rgeufdcod
         end record

   define lr_retorno   record
          resultado    smallint
         ,mensagem     char(60)
         ,nomrazsoc    like dpaksocor.nomrazsoc
         ,rspnom       like dpaksocor.rspnom
         ,teltxt       like dpaksocor.teltxt
          end record

   define  l_res        smallint
          ,l_result     smallint
          ,l_msg        char(80)

   define l_cgccpfnum    like dpakcnd.cgccpfnum
   define l_cgcord       like dpakcnd.cgcord
   define l_cgccpfdig    like dpakcnd.cgccpfdig
   define l_rgenum       like dpakcnd.rgenum
   define l_rgeufdcod    like dpakcnd.rgeufdcod
   define l_pstcndnom    like dpakcnd.pstcndnom
   define l_nscdat       like dpakcnd.nscdat
   define l_cnhnum       like dpakcnd.cnhnum
   define l_cnhctgcod    like dpakcnd.cnhctgcod
   define l_cnhpridat    like dpakcnd.cnhpridat
   define l_srrcoddig    like datksrr.srrcoddig
   define l_srrstt       like datksrr.srrstt

   initialize lr_retorno.* to null
   let l_result = true
   let l_res = null
   let l_msg = null
   let l_srrcoddig = null
   let l_cgccpfnum = null
   let l_cgcord = null
   let l_cgccpfdig = null
   let l_rgenum = null
   let l_rgeufdcod = null
   let l_pstcndnom = null
   let l_nscdat = null
   let l_cnhnum = null
   let l_cnhctgcod = null
   let l_cnhpridat = null
   let l_srrstt = null

   call ctd18g00_val_socorrista(lr_param.cgccpfnum
                               ,lr_param.cgcord
                               ,lr_param.cgccpfdig
                               ,lr_param.rgenum
                               ,lr_param.rgeufdcod)
        returning l_res, l_msg, l_srrcoddig
                              , l_pstcndnom
                              , l_nscdat
                              , l_cnhnum
                              , l_cnhctgcod
                              , l_cnhpridat
                              , l_rgenum
                              , l_rgeufdcod
                              , l_cgccpfnum
                              , l_cgcord
                              , l_cgccpfdig
                              , l_srrstt
   if l_res = 1 then
      let m_e_soc = true
      call ctd11g00_inf_socor(2, l_srrcoddig)
           returning l_res, l_msg, am_prestadores[1].codpres,
                                   am_prestadores[1].datpres

      call ctd12g00_dados_pst(1,am_prestadores[1].codpres)
         returning lr_retorno.*

      let am_prestadores[1].nompres = lr_retorno.nomrazsoc
      display am_prestadores[1].* to s_ctc39m00[1].*

      let mr_tela.pstcndnom = l_pstcndnom
      let mr_tela.nscdat = l_nscdat
      let mr_tela.cnhnum = l_cnhnum
      let mr_tela.cnhctgcod = l_cnhctgcod
      let mr_tela.cnhpridat = l_cnhpridat
      let mr_tela.rgenum = l_rgenum
      let mr_tela.rgeufdcod = l_rgeufdcod

      display by name mr_tela.pstcndnom
      display by name mr_tela.rgenum
      display by name mr_tela.rgeufdcod
      display by name mr_tela.nscdat
      display by name mr_tela.cnhnum
      display by name mr_tela.cnhctgcod
      display by name mr_tela.cnhpridat
      display by name mr_tela.rgenum
      display by name mr_tela.rgeufdcod

      if mr_tela.cgccpfnum <> l_cgccpfnum or
         mr_tela.cgcord <> l_cgcord or
         mr_tela.cgccpfdig <> l_cgccpfdig then
         error 'CGC/CPF informado diferente: ' , mr_tela.cgccpfnum,' ', mr_tela.cgcord, ' ', mr_tela.cgccpfdig
         let l_result = false
      end if

   end if

   return l_result, l_srrstt

end function

#----------------------------------------------------
function ctc39m00_sit_ps(l_sit_radar)
#----------------------------------------------------

   define l_sit_radar   smallint,
          l_sit_ps      smallint

   let l_sit_ps = 0

   case l_sit_radar
        when 1 let l_sit_ps = 4
        when 2 let l_sit_ps = 1
        when 3 let l_sit_ps = 2
        when 4 let l_sit_ps = 4
   end case

   return l_sit_ps

end function


#--------------------------------------------------------
function ctc39m00_grava_hist(lr_param,l_mensagem,l_opcao)   # PSI - 239178
#--------------------------------------------------------

   define lr_param record
          pstcndcod   like dpakcnd.pstcndcod
         ,mensagem    char(3000)
         ,data        date
          end record

   define lr_retorno record
           stt       smallint
          ,msg       char(50)
          end record

   define l_mensagem    char(100)
         ,l_erro        smallint
         ,l_stt         smallint
         ,l_path        char(100)
         ,l_opcao       char(1)
	 ,l_hora        datetime hour to minute
	 ,l_prshstdes2  char(3000)
	 ,l_count
         ,l_iter
         ,l_length
         ,l_length2    smallint

   let l_stt  = true
   let l_path = null
   let l_hora = current hour to minute

   initialize lr_retorno to null

   let l_length = length(lr_param.mensagem clipped)
   if  l_length mod 70 = 0 then
       let l_iter = l_length / 70
   else
       let l_iter = l_length / 70 + 1
   end if

   let l_length2     = 0
   let l_erro        = 0

   for l_count = 1 to l_iter
       if  l_count = l_iter then
           let l_prshstdes2 = lr_param.mensagem[l_length2 + 1, l_length]
       else
           let l_length2 = l_length2 + 70
           let l_prshstdes2 = lr_param.mensagem[l_length2 - 69, l_length2]
       end if

       call ctb85g01_grava_hist(4
                              ,lr_param.pstcndcod
                              ,l_prshstdes2
                              ,lr_param.data
                              ,g_issk.empcod
                              ,g_issk.funmat
                              ,g_issk.usrtip)
          returning lr_retorno.stt
                   ,lr_retorno.msg

   end for

   if l_opcao <>  "A" then
      if lr_retorno.stt =  0 then

        call ctb85g01_mtcorpo_email_html('CTC39M00',
                                         lr_param.data,
                                         l_hora,
                                         g_issk.empcod,
                                         g_issk.usrtip,
                                         g_issk.funmat,
                                         l_mensagem,
                                         lr_param.mensagem)
               returning l_erro

         if l_erro <> 0 then
            error 'Erro no envio do e-mail' sleep 2
            let l_stt = false
         else
            let l_stt = true
         end if
      else
         error 'Erro na gravacao do historico' sleep 2
         let l_stt = false
      end if
     else
      if lr_retorno.stt <> 0 then
         error 'Erro na gravacao do historico' sleep 2
         let l_stt = false
      end if
   end if

   return l_stt

end function

#---------------------------------------------------------
function ctc39m00_verifica_mod()                          # PSI - 239178
#---------------------------------------------------------


   define l_mensagem  char(3000)
         ,l_mensagem2 char(100)
         ,l_flg      integer
         ,l_stt      integer
         ,l_cmd      char(100)
         ,l_mensmail char(3000)
         ,l_hora     datetime hour to minute

   let l_mensagem2 = 'Alteracao no cadastro do Candidato. Codigo : ' ,
                      m_pstcndcod
   let l_hora      = current hour to minute

   let l_mensmail = null

   if (mr_tela_ant.pstcndnom is null     and mr_tela.pstcndnom is not null) or
      (mr_tela_ant.pstcndnom is not null and mr_tela.pstcndnom is null)     or
      (mr_tela_ant.pstcndnom              <> mr_tela.pstcndnom)             then
      let l_mensagem = "Nome do Proprietario alterado de [",mr_tela_ant.pstcndnom clipped,"] para [",mr_tela.pstcndnom clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc39m00_grava_hist(m_pstcndcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then
	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (mr_tela_ant.rgenum is null     and mr_tela.rgenum is not null) or
      (mr_tela_ant.rgenum is not null and mr_tela.rgenum is null)     or
      (mr_tela_ant.rgenum              <> mr_tela.rgenum)             then
      let l_mensagem = "RG do Candidato alterado de [",mr_tela_ant.rgenum clipped,
          "-",mr_tela_ant.rgenum using '<<<<<<<<<<&',"] para [",mr_tela.rgenum using '<<<<<<<<<<&'

      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc39m00_grava_hist(m_pstcndcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (mr_tela_ant.rgeufdcod is null     and mr_tela.rgeufdcod is not null) or
      (mr_tela_ant.rgeufdcod is not null and mr_tela.rgeufdcod is null)     or
      (mr_tela_ant.rgeufdcod              <> mr_tela.rgeufdcod)             then
      let l_mensagem = "UF do Candidato alterado de [",mr_tela_ant.rgeufdcod clipped,"] para [",mr_tela.rgeufdcod clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc39m00_grava_hist(m_pstcndcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (mr_tela_ant.nscdat is null     and mr_tela.nscdat is not null) or
      (mr_tela_ant.nscdat is not null and mr_tela.nscdat is null)     or
      (mr_tela_ant.nscdat              <> mr_tela.nscdat)             then
      let l_mensagem = "Data de Nascimento do Candidato alterado de [",mr_tela_ant.nscdat clipped,"] para [",mr_tela.nscdat clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc39m00_grava_hist(m_pstcndcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (mr_tela_ant.cnhnum is null     and mr_tela.cnhnum is not null) or
      (mr_tela_ant.cnhnum is not null and mr_tela.cnhnum is null)     or
      (mr_tela_ant.cnhnum              <> mr_tela.cnhnum)             then
      let l_mensagem = "CNH do Candidato alterado de [",mr_tela_ant.cnhnum clipped,"] para [",mr_tela.cnhnum clipped,"]"

      let l_mensmail = l_mensmail using '<<<<<<<<<<<&'," ",l_mensagem using '<<<<<<<<<<<&'
      let l_flg = 1

      if not ctc39m00_grava_hist(m_pstcndcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (mr_tela_ant.cnhctgcod is null     and mr_tela.cnhctgcod is not null) or
      (mr_tela_ant.cnhctgcod is not null and mr_tela.cnhctgcod is null)     or
      (mr_tela_ant.cnhctgcod              <> mr_tela.cnhctgcod)             then
      let l_mensagem = "Categoria alterado de [",mr_tela_ant.cnhctgcod clipped,"] para [",mr_tela.cnhctgcod clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc39m00_grava_hist(m_pstcndcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (mr_tela_ant.cnhpridat is null     and mr_tela.cnhpridat is not null) or
      (mr_tela_ant.cnhpridat is not null and mr_tela.cnhpridat is null)     or
      (mr_tela_ant.cnhpridat              <> mr_tela.cnhpridat)             then
      let l_mensagem = "Data da 1a Habilitacao alterado de [",mr_tela_ant.cnhpridat clipped,"] para [",mr_tela.cnhpridat clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc39m00_grava_hist(m_pstcndcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (mr_tela_ant.pstcndsitcod is null     and mr_tela.pstcndsitcod is not null) or
      (mr_tela_ant.pstcndsitcod is not null and mr_tela.pstcndsitcod is null)     or
      (mr_tela_ant.pstcndsitcod              <> mr_tela.pstcndsitcod)             then
      let l_mensagem = "Situacao do Candidato alterado de [",mr_tela_ant.pstcndsitcod using '<&',"] para [",mr_tela.pstcndsitcod using '<&',"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc39m00_grava_hist(m_pstcndcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if



   # Consultoria
   if (mr_tela_ant.pstcndconcod is null     and mr_tela.pstcndconcod is not null) or
      (mr_tela_ant.pstcndconcod is not null and mr_tela.pstcndconcod is null)     or
      (mr_tela_ant.pstcndconcod              <> mr_tela.pstcndconcod)             then
      let l_mensagem = "Consultoria alterado de [",mr_tela_ant.pstcndconcod using '<&',"] para [",mr_tela.pstcndconcod using '<&',"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc39m00_grava_hist(m_pstcndcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if



   if l_mensmail is not null then
      call ctc39m00_envia_email(l_mensagem2,today ,
                             current hour to minute, l_mensmail)
	    returning l_stt
   end if

end function

#------------------------------------------------
function ctc39m00_envia_email(lr_param) # PSI239178
#------------------------------------------------

  define lr_param record
          titulo     char(100)
         ,data       date
         ,hora       datetime hour to minute
         ,mensmail   char(2000)
  end record

  define l_stt       smallint
	,l_path      char(100)
	,l_cmd       char(100)
	,l_mensmail2 like dbsmhstprs.prshstdes
	,l_erro
	,l_count
	,l_iter
	,l_length
	,l_length2    smallint

   let l_stt  = true
   let l_path = null

   call ctb85g01_mtcorpo_email_html('CTC39M00',
                                    lr_param.data,
                                    lr_param.hora,
                                    g_issk.empcod,
                                    g_issk.usrtip,
                                    g_issk.funmat,
                                    lr_param.titulo,
                                    lr_param.mensmail)
               returning l_erro

    if l_erro  <> 0 then
	error 'Erro no envio do e-mail' sleep 2
	let l_stt = false
     else
	let l_stt = true
    end if

    return l_stt

end function


