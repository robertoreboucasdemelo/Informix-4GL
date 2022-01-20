###############################################################################
#                       * * * Alteracoes * * *                                #
#                                                                             #
#                                                                             #
# Data       Autor  Fabrica   Origem     Alteracao                            #
# ---------- ---------------- ---------- ------------------------------------ #
# 29/12/2003 Paulo, Meta      PSI 181765 Obrigar a digitacao do RG (para pes- #
#                             OSF 30368  soa fisica) e o codigo de atividade  #
#                                        economica (para pessoa juridica).    #
# 27/06/2005 James, Meta      PSI 193160 Permitir que o usuario inclua codigo #
#                                        de atividade sem entrar na popup     #
# 12/01/2006 Pedro  Lima                 Controle de complemento de logradou- #
#                                        ro para o Distrito Federal.          #
# 16/05/2006 T.Solda, Meta    PSI 197009 Controle p/ reconfirmacao dos campos #
# 27/06/2006 Pedro  Lima      PSI 197009 Reconfirmacao de documento para ra-  #
#                                        mo Auto                              #
# 30/06/2006 Sonia Sasaki     CT 6067454 Tela caindo - Definicao array        #
# 26/07/2006 Ligia Mattge     PSI 201987 acerto no insert/select/record like *#
# 28/07/2006 Kennedy Oliveira CT 6065552 Acerto na inicializacao de variaveis #
#                                        para versao compilada. Usei o anali- #
#                                        zador chqV4gc.                       #
# 31/08/2006 Pedro Lima       CT 6089635 Prob. insercao gsaktel campo nulo.   #
# 20/09/2006 Pedro Lima       PSI 201987 Controlar atualizacao de telefone  e #
#                                        email (pela central) somente  quando #
#                                        for uma ligacao realizada pelo segu- #
#                                        rado.                                #
#-----------------------------------------------------------------------------#
# 14/08/2008 Fabio,Meta      PSI223689   Alteracao SQL p/funcao osgtk1001     #
###############################################################################
globals '/homedsa/projetos/geral/globals/sg_glob1.4gl'
globals '/homedsa/projetos/geral/globals/figrc012.4gl'
globals '/homedsa/projetos/geral/globals/figrc072.4gl'
globals "/homedsa/projetos/geral/globals/sg_glob2.4gl"
globals "/homedsa/projetos/geral/globals/glseg.4gl"

define w_guarda_segnumdig   like gsakseg.segnumdig
      ,w_segurado_novo      char(1)      #Identifica se e inclusao ou alteracao
      ,w_lgdnomcmp_c        like glaklgd.lgdnomcmp
      ,w_lgdcompleto        like glaklgd.lgdnom
      ,m_prep_sql           smallint
      ,w_hoje               date
      ,m_confirma_docto     smallint
      ,m_ramo               smallint
      ,m_modalidade         smallint
      ,m_unocod             smallint
define m_host        like ibpkdbspace.srvnom #Humberto
#-------------------------
function cty17g00_ssgtseg_prepara()
#-------------------------
 define l_sql               char(1000)

 let l_sql = "select atlemp       "
            ,"      ,atlmat       "
            ,"      ,atlusrtip    "
            ,"      ,atldat       "
            ,"      ,atlhor       "
            ,"  from gsaktel      "
            ," where segnumdig = ?"
            ,"   and segtelseq = ?"
            ,"   and teltipcod = ?"
 whenever error continue
 prepare p_cty17g00_001 from l_sql
 declare c_cty17g00_001 cursor with hold for p_cty17g00_001
 whenever error stop
 if figrc072_checkGlbIsolamento(sqlca.sqlcode
                               ,"ssgtseg02"
                               ,"ssgtseg_prepare"
                               ,"cssgtseg039"
                               ,"","","","","","")  then
    let m_prep_sql = false
    return
 end if

 let l_sql = "select count(*)     "
            ,"  from gsaktel      "
            ," where segnumdig = ?"
 whenever error continue
 prepare p_cty17g00_002 from l_sql
 declare c_cty17g00_002 cursor with hold for p_cty17g00_002
 whenever error stop
 if figrc072_checkGlbIsolamento(sqlca.sqlcode
                               ,"ssgtseg02"
                               ,"ssgtseg_prepare"
                               ,"cssgtseg040"
                               ,"","","","","","")  then
    let m_prep_sql = false
    return
 end if

 let l_sql = "select grlinf    "
            ,"  from datkgeral "
            ," where grlchv[1,03] = 'PSO' "
            ,"   and grlchv[4,15] = 'EMAIL_SEGUR'"
 whenever error continue
 prepare p_cty17g00_003 from l_sql
 declare c_cty17g00_003 cursor for p_cty17g00_003
 whenever error stop
 if figrc072_checkGlbIsolamento(sqlca.sqlcode
                               ,"ssgtseg02"
                               ,"ssgtseg_prepare"
                               ,"cssgtseg041"
                               ,"","","","","","")  then
    let m_prep_sql = false
    return
 end if

 let l_sql = "select segnumdig, endfld   "
            ,"      ,maides   , atlemp   "
            ,"      ,atlmat   , atldat   "
            ,"      ,atlhor   , atlusrtip"
            ,"  from gsakendmai          "
            ," where segnumdig = ?       "
            ,"   and endfld    = '1'     "
 whenever error continue
 prepare p_cty17g00_004 from l_sql
 declare c_cty17g00_004 cursor for p_cty17g00_004
 whenever error stop
 if figrc072_checkGlbIsolamento(sqlca.sqlcode
                               ,"ssgtseg02"
                               ,"ssgtseg_prepare"
                               ,"cssgtseg042"
                               ,"","","","","","")  then
    let m_prep_sql = false
    return
 end if

 let l_sql = "select atldat, atlemp"
            ,"      ,atlmat, atlhor"
            ,"      ,atlusrtip     "
            ,"  from gsaktel       "
            ," where segnumdig = ? "
            ," order by atldat desc"
 whenever error continue
 prepare pssgtseg043 from l_sql
 declare cssgtseg043 cursor for pssgtseg043
 whenever error stop
 if figrc072_checkGlbIsolamento(sqlca.sqlcode
                               ,"ssgtseg02"
                               ,"ssgtseg_prepare"
                               ,"cssgtseg043"
                               ,"","","","","","")  then
    let m_prep_sql = false
    return
 end if

 let l_sql =  'select  endlgdtip'
             ,'       ,endlgd'
             ,'       ,endnum'
             ,'       ,endcmp'
             ,'       ,endcepcmp'
             ,'       ,endbrr'
             ,'       ,endcid'
             ,'       ,endufd'
             ,'       ,endcep'
             ,'       ,atlult'
             ,'       ,tlxtxt'
             ,'       ,factxt'
             ,'  from gsakend'
             ,' where segnumdig = ?'
             ,'   and endfld = "1"'
 whenever error continue
 prepare pssgtseg056 from l_sql
 declare cssgtseg056 cursor for pssgtseg056
 whenever error stop
 if figrc072_checkGlbIsolamento(sqlca.sqlcode
                               ,"ssgtseg02"
                               ,"ssgtseg_prepare"
                               ,"cssgtseg056"
                               ,"","","","","","")  then
    let m_prep_sql = false
    return
 end if
 let l_sql = 'select maides'
            ,'  from gsakendmai'
            ,' where segnumdig = ?'
            ,'   and endfld = "1"'
 whenever error continue
 prepare pssgtseg057 from l_sql
 declare cssgtseg057 cursor for pssgtseg057
 whenever error stop
 if figrc072_checkGlbIsolamento(sqlca.sqlcode
                               ,"ssgtseg02"
                               ,"ssgtseg_prepare"
                               ,"cssgtseg057"
                               ,"","","","","","")  then
    let m_prep_sql = false
    return
 end if

 let l_sql = 'select segtelseq'
            ,'      ,teltipcod'
            ,'      ,telnum'
            ,'      ,dddnum'
            ,'      ,telrmlnum'
            ,'      ,segtelobs'
            ,'  from gsaktel'
            ,' where segnumdig = ?'
 whenever error continue
 prepare pssgtseg058 from l_sql
 declare cssgtseg058 cursor for pssgtseg058
 whenever error stop
 if figrc072_checkGlbIsolamento(sqlca.sqlcode
                               ,"ssgtseg02"
                               ,"ssgtseg_prepare"
                               ,"cssgtseg058"
                               ,"","","","","","")  then
    let m_prep_sql = false
    return
 end if

 let m_prep_sql = true

end function


#------------------------
function cty17g00_ssgttel(r_param)
#------------------------
 define r_param               record
        opcao                 dec(1,0)     # 1-atualiza  2-consulta
       ,segnumdig             like gsakseg.segnumdig
       ,segurado              smallint     # 0-nada a fazer 1-segurado
        end                   record

       ,a_ssgttel array [5000] of record
        teltipcod             dec(3,0)
       ,teltipdes             char(32)
       ,dddnum                dec(4,0)
       ,telnum                dec(10,0)
       ,telrmlnum             dec(4,0)
       ,segtelobsflg          char(1)
       ,flag                  char(1)
        end                   record

       ,t_ssgttel             record
        funnom                like isskfunc.funnom
       ,dptsgl                like isskfunc.dptsgl
       ,atldat                like gsaktel.atldat
       ,atlhor                like gsaktel.atlhor
       ,atlemp                like gsaktel.atlemp
       ,atlmat                like gsaktel.atlmat
       ,atlusrtip             like gsaktel.atlusrtip
        end                   record

       ,a_ssgttel_ant array [5000] of record # DANIEL
        teltipcod             dec(3,0)
       ,dddnum                dec(4,0)
       ,telnum                dec(10,0)
       ,telrmlnum             dec(4,0)
        end                   record

       ,a_ssgttel_conf array [20] of record # DANIEL
        teltipcod             char(1)
       ,dddnum                char(1)
       ,telnum                char(1)
       ,telrmlnum             char(1)
        end                   record

       ,b_ssgttel array [100] of record
        segtelobs             varchar(100)
       ,segtelseq             smallint
        end                   record

       ,w_ssgttel             record
        atlemp                like gsaktel.atlemp
       ,atlmat                like gsaktel.atlmat
       ,atlusrtip             like gsaktel.atlusrtip
       ,atldat                like gsaktel.atldat
       ,atlhor                like gsaktel.atlhor
        end                   record

       ,w_func                record
        funnom                like isskfunc.funnom
       ,dptsgl                like isskfunc.dptsgl
        end                   record

       ,w_upd_end_dddnum      char(4)
       ,w_upd_end_telnum      char(10)
       ,w_posso_atualizar     char(1)
       ,w_teltxt_gsakend      char(40)
       ,ant_segtelobsflg      char(1)
       ,w_strsql              varchar(200)
       ,w_segtelobsret        varchar(100)
       ,w_sair                char(1)
       ,ant_teltipcod         dec(3,0)
       ,ant_teltipdes         char(32)
       ,ant_telnum            dec(10,0)
       ,ant_dddnum            dec(4,0)
       ,ant_telrmlnum         dec(4,0)
       ,ant_segtelobs         varchar(100)
       ,resposta              char(1)
       ,w_maxsegtelseq        smallint
       ,w_tamtelnum           dec(10,0)
       ,w_tamdddnum           char(4)
       ,w_telnum              char(8)
       ,w_acao                char(1)
       ,w_arr                 smallint
       ,w_resp                char(1)
       ,w_scr                 smallint
       ,w_fim                 smallint
       ,w_count               smallint
       ,ix                    smallint
       ,w_obs1                char(50)
       ,w_obs2                char(50)
       ,w_pf1                 integer
       ,w_contador            smallint
       ,l_ret                 smallint
       ,l_cod                 smallint
       ,l_alerta              smallint
       ,l_grlinf              dec(5,0)
       ,l_mensagem            like datkgeral.grlinf
       ,l_telemail            char(100)
       ,l_resposta            char(01)
       ,l_msg_alteracao       char(01)
   define lr_gsaktel  record
          segnumdig   like  gsaktel.segnumdig
         ,segtelseq   like  gsaktel.segtelseq
         ,teltipcod   like  gsaktel.teltipcod
         ,telnum      like  gsaktel.telnum
         ,dddnum      like  gsaktel.dddnum
         ,telrmlnum   like  gsaktel.telrmlnum
         ,segtelobs   like  gsaktel.segtelobs
         ,atlemp      like  gsaktel.atlemp
         ,atlmat      like  gsaktel.atlmat
         ,atlusrtip   like  gsaktel.atlusrtip
         ,atldat      like  gsaktel.atldat
         ,atlhor      like  gsaktel.atlhor
                      end record
   define lr_gsakend record
          segnumdig  like gsakseg.segnumdig
         ,endfld     smallint
         ,endlgdtip  like gsakend.endlgdtip
         ,endlgd     like gsakend.endlgd
         ,endnum     like gsakend.endnum
         ,endcmp     like gsakend.endcmp
         ,endcepcmp  like gsakend.endcepcmp
         ,endbrr     like gsakend.endbrr
         ,endcid     like gsakend.endcid
         ,endufd     like gsakend.endufd
         ,endcep     like gsakend.endcep
         ,dddcod     char(4)
         ,teltxt     char(10)
         ,tlxtxt     like gsakend.tlxtxt
         ,factxt     like gsakend.factxt
         ,atlult     like gsakend.atlult
                     end record
   define l_sqlcode integer
         ,l_sqlerrd integer
         ,l_opcao   char(01)
         ,l_stt     smallint

         ,l_cabecalho  char(1000)
   let l_sqlcode = null
   let l_sqlerrd = null
   let l_stt     = true
   let l_opcao   = null
   let l_cabecalho   = null

   initialize lr_gsaktel,lr_gsakend to null
 #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize w_posso_atualizar
           ,w_upd_end_dddnum
           ,w_upd_end_telnum
           ,w_teltxt_gsakend
           ,ant_segtelobsflg
           ,w_strsql
           ,w_segtelobsret
           ,w_sair
           ,ant_teltipcod
           ,ant_teltipdes
           ,ant_telnum
           ,ant_dddnum
           ,ant_telrmlnum
           ,ant_segtelobs
           ,resposta
           ,w_maxsegtelseq
           ,w_tamtelnum
           ,w_tamdddnum
           ,w_telnum
           ,w_acao
           ,w_arr
           ,w_resp
           ,w_scr
           ,w_fim
           ,w_count
           ,ix
           ,w_obs1
           ,w_obs2
           ,w_pf1        to null

 let l_msg_alteracao   = false
 let l_alerta          = true

 #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 for w_pf1 = 1 to 5000
    initialize a_ssgttel[w_pf1].*
              ,a_ssgttel_ant[w_pf1].* to null
 end for

 for w_pf1 = 1 to 20
    let a_ssgttel_conf[w_pf1].teltipcod =  'N' # DANIEL
    let a_ssgttel_conf[w_pf1].dddnum =     'N' # DANIEL
    let a_ssgttel_conf[w_pf1].telnum =     'N' # DANIEL
    let a_ssgttel_conf[w_pf1].telrmlnum =  'N' # DANIEL
 end for

 initialize b_ssgttel to null
 call cty17g00_ssgtseg02_cabecalho_xml(r_param.segnumdig)
      returning l_sqlcode
               ,l_cabecalho
 --- Identifica ambiente de execucao ---
 --- ------------------------------- ---
 call figrc072_initGlbIsolamento()
 call cty17g00_ssgtseg_prepara()
 if m_prep_sql = false then
    if r_param.opcao = 1  then # atualizacao
       return w_upd_end_dddnum
             ,w_upd_end_telnum
    else
 	     return
    end if
 end if

 if not figrc012_sitename('ssgtseg', '', '') then
    display 'Erro Selecionando Sitename da DUAL'
    exit program(1)
 end if

 let w_strsql = "select teltipcod,telnum,dddnum,telrmlnum,",
                "       segtelobs,segtelseq ",
                "  from gsaktel",
                " where segnumdig = ?"
 whenever error continue
 prepare pssgtseg010 from w_strsql
 declare cssgtseg026 cursor with hold for pssgtseg010
 whenever error stop
 if figrc072_checkGlbIsolamento(sqlca.sqlcode
                               ,"ssgtseg02"
                               ,"ssgttel"
                               ,"cssgtseg026"
                               ,"","","","","","")  then

    if r_param.opcao = 1  then # atualizacao
       let w_upd_end_dddnum  = null
       let w_upd_end_telnum = null
       return w_upd_end_dddnum
             ,w_upd_end_telnum
    else
 	     return
    end if
 end if

 let w_strsql = "select count(*)",
                "  from gsaktel",
                " where segnumdig = ?",
                "   and teltipcod = ? and telnum = ?"
 whenever error continue
 prepare pssgtseg011 from w_strsql
 declare cssgtseg027 cursor with hold for pssgtseg011
 whenever error stop
 if figrc072_checkGlbIsolamento(sqlca.sqlcode
                               ,"ssgtseg02"
                               ,"ssgttel"
                               ,"cssgtseg027"
                               ,"","","","","","")  then

    if r_param.opcao = 1  then # atualizacao
       let w_upd_end_dddnum  = null
       let w_upd_end_telnum = null
       return w_upd_end_dddnum
             ,w_upd_end_telnum
    else
 	     return
    end if
 end if

 let w_strsql = "select count(*)",
                "  from gsaktel",
                " where segnumdig = ?",
                "   and segtelseq = ? and teltipcod = ?"
 whenever error continue
 prepare pssgtseg012 from w_strsql
 declare cssgtseg028 cursor with hold for pssgtseg012
 whenever error stop
 if figrc072_checkGlbIsolamento(sqlca.sqlcode
                               ,"ssgtseg02"
                               ,"ssgttel"
                               ,"cssgtseg028"
                               ,"","","","","","")  then

    if r_param.opcao = 1  then # atualizacao
       let w_upd_end_dddnum  = null
       let w_upd_end_telnum = null
       return w_upd_end_dddnum
             ,w_upd_end_telnum
    else
 	     return
    end if
 end if

 let w_strsql = "select max(segtelseq)",
                "  from gsaktel",
                " where segnumdig = ?",
                "   and teltipcod = ? "
 whenever error continue
 prepare pssgtseg013   from w_strsql
 declare cssgtseg029   cursor with hold for pssgtseg013
 whenever error stop
 if figrc072_checkGlbIsolamento(sqlca.sqlcode
                               ,"ssgtseg02"
                               ,"ssgttel"
                               ,"cssgtseg029"
                               ,"","","","","","")  then

    if r_param.opcao = 1  then # atualizacao
       let w_upd_end_dddnum  = null
       let w_upd_end_telnum = null
       return w_upd_end_dddnum
             ,w_upd_end_telnum
    else
 	     return
    end if
 end if


 	 let m_host = fun_dba_servidor("EMISAUTO")
    let w_strsql = "select cpodes[1,31] from porto@",m_host clipped,":iddkdominio ",
                   " where cponom = 'segteltipcod'  and cpocod = ?"


 whenever error continue
 prepare pssgtseg014 from w_strsql
 declare cssgtseg030 cursor with hold for pssgtseg014
 whenever error stop
 if figrc072_checkGlbIsolamento(sqlca.sqlcode
                               ,"ssgtseg02"
                               ,"ssgttel"
                               ,"cssgtseg030"
                               ,"","","","","","")  then

    if r_param.opcao = 1  then # atualizacao
       let w_upd_end_dddnum  = null
       let w_upd_end_telnum = null
       return w_upd_end_dddnum
             ,w_upd_end_telnum
    else
 	     return
    end if
 end if

 let w_posso_atualizar = "s"

 --- Caso esteja rodando em teste ---
 --- ---------------------------- ---
 if g_issk.funmat is null then
    let g_issk.funmat = 1
 end if

 if g_issk.empcod is null then
    let g_issk.empcod = 1
 end if

 if g_issk.usrtip is null then
    let g_issk.usrtip = "F"
 end if

 --- Caso esteja rodando em teste ---

 open window ssgttel  at 10,7 with form "ssgttel"
      attribute (border,form line 1)

 let int_flag = false

 while int_flag = false
   let w_sair = "n"
   let w_arr  = 1

   clear form
   whenever error continue
   open    cssgtseg026 using r_param.segnumdig
   whenever error stop
   if figrc072_checkGlbIsolamento(sqlca.sqlcode
                                 ,"ssgtseg02"
                                 ,"ssgttel"
                                 ,"cssgtseg026"
                                 ,"","","","","","")  then

      if r_param.opcao = 1  then # atualizacao
         let w_upd_end_dddnum  = null
         let w_upd_end_telnum = null
         return w_upd_end_dddnum
               ,w_upd_end_telnum
      else
 	       return
      end if
   end if

   foreach cssgtseg026 into a_ssgttel[w_arr].teltipcod
                           ,a_ssgttel[w_arr].telnum
                           ,a_ssgttel[w_arr].dddnum
                           ,a_ssgttel[w_arr].telrmlnum
                           ,b_ssgttel[w_arr].segtelobs
                           ,b_ssgttel[w_arr].segtelseq
                           ,a_ssgttel[w_arr].segtelobsflg
     if ((b_ssgttel[w_arr].segtelobs is null)  or
         (b_ssgttel[w_arr].segtelobs = ' ' ))  then
        let a_ssgttel[w_arr].segtelobsflg = "N"
     else
        let a_ssgttel[w_arr].segtelobsflg = "S"
     end if

     whenever error continue
     open   cssgtseg030 using a_ssgttel[w_arr].teltipcod
     fetch  cssgtseg030 into  a_ssgttel[w_arr].teltipdes
     whenever error stop
     if sqlca.sqlcode < 0 then
        error "Erro no cursor cssgtseg026 : " , sqlca.sqlcode
        if figrc072_checkGlbIsolamento(sqlca.sqlcode
                                      ,"ssgtseg02"
                                      ,"ssgttel"
                                      ,"cssgtseg026"
                                      ,"","","","","","")  then
           if r_param.opcao = 1  then # atualizacao
              let w_upd_end_dddnum  = null
              let w_upd_end_telnum = null
              return w_upd_end_dddnum
                    ,w_upd_end_telnum
           else
              return
           end if
        end if
     end if

     if status = notfound then
        let a_ssgttel[w_arr].teltipdes = "NAO CADASTRADO"
     end if

     let a_ssgttel[w_arr].teltipdes = upshift(a_ssgttel[w_arr].teltipdes)

     let w_arr = w_arr + 1

     if w_arr > 5000 then
        exit foreach
     end if

   end foreach

   if l_alerta      = true      and
     (g_issk.dptsgl = "ct24hs"  or
      g_issk.dptsgl = "dsvatd"  or
      g_issk.dptsgl = "tlprod"  or
      g_issk.dptsgl = "desenv") and
      r_param.segurado  = 1     then
      -- Busca parametros de dias de atualizacao do e-mail do segurado
      let l_grlinf = cty17g00_ssgtseg_busca_dias()

      whenever error continue
      open cssgtseg043 using r_param.segnumdig
      fetch cssgtseg043 into t_ssgttel.atldat
      whenever error stop

      if sqlca.sqlcode < 0 then
         error "Erro no cursor cssgtseg043 : " , sqlca.sqlcode
         if figrc072_checkGlbIsolamento(sqlca.sqlcode
                                      ,"ssgtseg02"
                                      ,"ssgttel"
                                      ,"cssgtseg026"
                                      ,"","","","","","")  then
           if r_param.opcao = 1  then # atualizacao
              let w_upd_end_dddnum  = null
              let w_upd_end_telnum = null
              return w_upd_end_dddnum
                    ,w_upd_end_telnum
           else
              return
           end if
         end if
      else
         if sqlca.sqlcode = 100 then
            let t_ssgttel.atldat = (today - l_grlinf) - 5
         end if
      end if

      close cssgtseg043

      if (( today - t_ssgttel.atldat ) > l_grlinf) then
         let l_alerta        = false
         let l_msg_alteracao = true
         let l_telemail = "Telefone(s) atualizado a mais de "
         let l_mensagem = l_grlinf clipped, " dia(s)." clipped
         # Retirada por Solicitacao da Miriam Anselmo 10/09
         #call ssgtseg_alerta( "Q", l_telemail , l_mensagem," Solicite Confirmacao.")
      else
         let l_msg_alteracao = false
      end if
   end if

   let t_ssgttel.atldat = null

   call set_count(w_arr - 1)

   if r_param.opcao =  2  then  # consulta
      input array a_ssgttel  without defaults from s_ssgttel.*

        before row

          let w_arr = arr_curr()
          let w_scr = scr_line()

          whenever error continue
          open   c_cty17g00_002 using r_param.segnumdig
          fetch  c_cty17g00_002 into  w_contador
          whenever error stop
          if sqlca.sqlcode < 0 then
             error "Erro no cursor c_cty17g00_002 : " , sqlca.sqlcode
				         if figrc072_checkGlbIsolamento(sqlca.sqlcode
				                                      ,"ssgtseg02"
				                                      ,"ssgttel"
				                                      ,"cssgtseg040"
				                                      ,"","","","","","")  then
				           if r_param.opcao = 1  then # atualizacao
				              let w_upd_end_dddnum  = null
				              let w_upd_end_telnum = null
				              return w_upd_end_dddnum
				                    ,w_upd_end_telnum
				           else
				              return
				           end if
				         end if
          end if
          close  c_cty17g00_002

          if w_arr > w_contador then
             exit input
          end if

          whenever error continue
          open   c_cty17g00_001 using r_param.segnumdig,
                                     b_ssgttel[w_arr].segtelseq,
                                     a_ssgttel[w_arr].teltipcod
          fetch  c_cty17g00_001 into  t_ssgttel.atlemp,
                                   t_ssgttel.atlmat,
                                   t_ssgttel.atlusrtip,
                                   t_ssgttel.atldat,
                                   t_ssgttel.atlhor
          whenever error stop
          if sqlca.sqlcode < 0 then
             error "Erro no cursor c_cty17g00_001 : " , sqlca.sqlcode
				         if figrc072_checkGlbIsolamento(sqlca.sqlcode
				                                      ,"ssgtseg02"
				                                      ,"ssgttel"
				                                      ,"cssgtseg039"
				                                      ,"","","","","","")  then
				           if r_param.opcao = 1  then # atualizacao
				              let w_upd_end_dddnum  = null
				              let w_upd_end_telnum = null
				              return w_upd_end_dddnum
				                    ,w_upd_end_telnum
				           else
				              return
				           end if
				         end if
          end if
          close  c_cty17g00_001

          call cty17g00_ssgtseg_func(t_ssgttel.atlemp,
                            t_ssgttel.atlmat,
                            t_ssgttel.atlusrtip)

          returning w_func.funnom, w_func.dptsgl

          display w_func.funnom       to funnom
          display w_func.dptsgl       to dptsgl
          display w_func.funnom       to funnom
          display w_func.dptsgl       to dptsgl
          display t_ssgttel.atldat    to atldat
          display t_ssgttel.atlhor    to atlhor

         next field flag

      after row
           let w_arr = arr_curr()
           let w_scr = scr_line()
           display a_ssgttel[w_arr].* to
                   s_ssgttel[w_scr].*

      before field telrmlnum
         next field flag

        on key (control-c,f17,interrupt)
               if l_msg_alteracao = true and
                  r_param.opcao = 1      and   ## Alberto
                  r_param.segurado = 1   then  ## Alberto
                  let l_resposta = cty17g00_ssgtseg_confirma("T")
                  let l_resposta = upshift(l_resposta)

                  if l_resposta = "N" then
                     continue input
                  end if
               end if

               let w_sair = "s"
               let int_flag = true
               exit input

         on key (f5)
                let w_arr = arr_curr()

                if a_ssgttel[w_arr].segtelobsflg = "N"  then
                   message "Telefone sem Observacao"
                   sleep 2
                   message " "
                else
                   open window win_obstel at 18,13 with 4 rows,55 columns
                        attribute (border)

                   let w_obs1 = b_ssgttel[w_arr].segtelobs[1,50]
                   let w_obs2 = b_ssgttel[w_arr].segtelobs[51,100]

                   display w_obs1   at 1,1
                   display w_obs2   at 2,1
                   display " "      at 3,1

                   prompt "Digite qualquer tecla p/continuar " for char w_resp

                   close window win_obstel
                   let int_flag = false

                end if
       end input
   else
      input array a_ssgttel  without defaults from s_ssgttel.*

        before row

               let w_arr = arr_curr()
               let w_scr = scr_line()
               let w_fim = arr_count()
               let w_acao = "a"

               initialize ant_teltipcod
                         ,ant_teltipdes
                         ,ant_telnum
                         ,ant_dddnum
                         ,ant_telrmlnum
                         ,ant_segtelobs
                         ,ant_segtelobsflg to null

               let ant_teltipcod    = a_ssgttel[w_arr].teltipcod
               let ant_teltipdes    = a_ssgttel[w_arr].teltipdes
               let ant_telnum       = a_ssgttel[w_arr].telnum
               let ant_dddnum       = a_ssgttel[w_arr].dddnum
               let ant_telrmlnum    = a_ssgttel[w_arr].telrmlnum
               let ant_segtelobs    = b_ssgttel[w_arr].segtelobs
               let ant_segtelobsflg = a_ssgttel[w_arr].segtelobsflg

               whenever error continue
               open   c_cty17g00_001 using r_param.segnumdig,
                                        b_ssgttel[w_arr].segtelseq,
                                        a_ssgttel[w_arr].teltipcod
               fetch  c_cty17g00_001 into  t_ssgttel.atlemp,
                                        t_ssgttel.atlmat,
                                        t_ssgttel.atlusrtip,
                                        t_ssgttel.atldat,
                                        t_ssgttel.atlhor
               whenever error stop
               if sqlca.sqlcode < 0 then
                  error "Erro no cursor cssgtseg039: " , sqlca.sqlcode
									         if figrc072_checkGlbIsolamento(sqlca.sqlcode
									                                      ,"ssgtseg02"
									                                      ,"ssgttel"
									                                      ,"cssgtseg039"
									                                      ,"","","","","","")  then
									           if r_param.opcao = 1  then # atualizacao
									              let w_upd_end_dddnum  = null
									              let w_upd_end_telnum = null
									              return w_upd_end_dddnum
									                    ,w_upd_end_telnum
									           else
									              return
									           end if
									         end if
               end if

               close  c_cty17g00_001

               call cty17g00_ssgtseg_func( t_ssgttel.atlemp
                                 ,t_ssgttel.atlmat
                                 ,t_ssgttel.atlusrtip
                                 )
               returning w_func.funnom, w_func.dptsgl

               display w_func.funnom       to funnom
               display w_func.dptsgl       to dptsgl
               display t_ssgttel.atldat    to atldat
               display t_ssgttel.atlhor    to atlhor

        before insert

               let w_acao = "i"

               let w_func.funnom       = null
               let w_func.dptsgl       = null
               let t_ssgttel.atldat    = null
               let t_ssgttel.atlhor    = null

               display w_func.funnom       to funnom
               display w_func.dptsgl       to dptsgl
               display t_ssgttel.atldat    to atldat
               display t_ssgttel.atlhor    to atlhor

        before delete

               let w_acao = "d"

               prompt "Confirma exclusao ? <S/N>  " for char resposta

               if upshift(resposta) <> "S"  then
                  error "EXCLUSAO CANCELADA"
                  let int_flag = false
                  exit input
               end if

               begin work

               let l_sqlcode = osgtk1001_excluirTelefoneSegurado( r_param.segnumdig
                                                                 ,b_ssgttel[w_arr].segtelseq
                                                                 ,a_ssgttel[w_arr].teltipcod
                                                                 ,l_opcao)
               if l_sqlcode = 0 then
                  commit work
               else
                  rollback work
									         if figrc072_checkGlbIsolamento(l_sqlcode
									                                      ,"ssgtseg02"
									                                      ,"ssgttel"
									                                      ,"excluirtel"
									                                      ,"","","","","","")  then
									           if r_param.opcao = 1  then # atualizacao
									              let w_upd_end_dddnum  = null
									              let w_upd_end_telnum = null
									              return w_upd_end_dddnum
									                    ,w_upd_end_telnum
									           else
									              return
									           end if
									         end if
               end if

               initialize a_ssgttel[w_arr].* to null

               let int_flag = false
               exit input

        before field teltipcod
               if  a_ssgttel[w_arr].teltipcod is not null and
                   a_ssgttel[w_arr].teltipcod <> ' '      then
                   #next field dddnum
               end if

        after  field teltipcod
               if fgl_lastkey() = fgl_keyval("up")        or
                  fgl_lastkey() = fgl_keyval("down")      or
                  fgl_lastkey() = fgl_keyval("page up")   or
                  fgl_lastkey() = fgl_keyval("page down") then
                  let int_flag = false
                  exit input
               end if

               if ((a_ssgttel[w_arr].teltipcod is null)  or
                   (a_ssgttel[w_arr].teltipcod = ' '))   then

                  call cty17g00_ssgtpop()
                       returning a_ssgttel[w_arr].teltipcod
                                ,a_ssgttel[w_arr].teltipdes

                  if ((a_ssgttel[w_arr].teltipcod is null) or
                      (a_ssgttel[w_arr].teltipcod = ' '))  then
                     next field teltipcod
                  end if

                  let a_ssgttel[w_arr].teltipdes =
                      upshift(a_ssgttel[w_arr].teltipdes)

                  display a_ssgttel[w_arr].teltipcod to
                          s_ssgttel[w_scr].teltipcod

                  display a_ssgttel[w_arr].teltipdes to
                          s_ssgttel[w_scr].teltipdes
               end if

               whenever error continue
               open  cssgtseg030 using a_ssgttel[w_arr].teltipcod
               fetch cssgtseg030 into  a_ssgttel[w_arr].teltipdes
               whenever error stop
               if sqlca.sqlcode < 0 then
                  error "Erro no cursor cssgtseg030 : " , sqlca.sqlcode
									         if figrc072_checkGlbIsolamento(sqlca.sqlcode
									                                      ,"ssgtseg02"
									                                      ,"ssgttel"
									                                      ,"cssgtseg030"
									                                      ,"","","","","","")  then
									           if r_param.opcao = 1  then # atualizacao
									              let w_upd_end_dddnum  = null
									              let w_upd_end_telnum = null
									              return w_upd_end_dddnum
									                    ,w_upd_end_telnum
									           else
									              return
									           end if
									         end if
               end if

               if status = notfound then
                  let a_ssgttel[w_arr].teltipcod = ant_teltipcod
                  let a_ssgttel[w_arr].teltipdes = ant_teltipdes

                  display a_ssgttel[w_arr].teltipcod to
                          s_ssgttel[w_scr].teltipcod

                  display a_ssgttel[w_arr].teltipdes to
                          s_ssgttel[w_scr].teltipdes

                  error "Tipo de Telefone nao cadastrado."

                  call cty17g00_ssgtpop()
                       returning a_ssgttel[w_arr].teltipcod
                                ,a_ssgttel[w_arr].teltipdes

                  if ((a_ssgttel[w_arr].teltipcod is null) or
                      (a_ssgttel[w_arr].teltipcod = ' '))   then
                     next field teltipcod
                  end if
               end if

               let a_ssgttel[w_arr].teltipdes =
                   upshift(a_ssgttel[w_arr].teltipdes)

               display a_ssgttel[w_arr].teltipcod to s_ssgttel[w_scr].teltipcod
               display a_ssgttel[w_arr].teltipdes to s_ssgttel[w_scr].teltipdes

          if m_confirma_docto then
             if a_ssgttel_conf[w_arr].teltipcod  = 'N' or
                a_ssgttel_ant[w_arr].teltipcod  <> a_ssgttel[w_arr].teltipcod then
                call conqua59(m_ramo
                             ,m_modalidade
                             ,g_issk.funmat
                             ,g_issk.acsnivcod
                             ,m_unocod
                             ,'ssgtsegi'
                             ,'teltipcod'
                             ,''
                             ,''
                             ,''
                             ,''
                             ,a_ssgttel[w_arr].teltipcod)
                   returning l_ret
                            ,l_cod

                if l_ret then
                   if l_cod = 1 then
                      next field teltipcod
                   else
                      let a_ssgttel_conf[w_arr].teltipcod = 'S'
                      let a_ssgttel_ant[w_arr].teltipcod = a_ssgttel[w_arr].teltipcod
                   end if
                end if
            end if
          end if

        after field dddnum
               initialize w_tamdddnum to null

               let w_tamdddnum = a_ssgttel[w_arr].dddnum

               if w_tamdddnum is null then
                  let w_tamdddnum = 0
               end if

               if w_tamdddnum = 0 then
                  error "Informe o numero do DDD"
                  next field dddnum
               end if

               if w_tamdddnum < 2 then
                  error "Numero do DDD incompleto."
                  next field dddnum
               end if

               if a_ssgttel[w_arr].dddnum is null then
                  error "Informe o codido (DDD)"
                  next field dddnum
               end if

          if m_confirma_docto then
             if a_ssgttel_conf[w_arr].dddnum  = 'N' or
                a_ssgttel_ant[w_arr].dddnum <> a_ssgttel[w_arr].dddnum then
                call conqua59(m_ramo
                             ,m_modalidade
                             ,g_issk.funmat
                             ,g_issk.acsnivcod
                             ,m_unocod
                             ,'ssgtsegi'
                             ,'dddnum'
                             ,''
                             ,''
                             ,''
                             ,''
                             ,a_ssgttel[w_arr].dddnum)
                   returning l_ret
                            ,l_cod

                if l_ret then
                   if l_cod = 1 then
                      next field dddnum
                   else
                      let a_ssgttel_conf[w_arr].dddnum = 'S'
                      let a_ssgttel_ant[w_arr].dddnum  = a_ssgttel[w_arr].dddnum
                   end if
                end if
             end if
          end if

        after  field telnum
               if fgl_lastkey() = fgl_keyval("left") then
               else
                  if a_ssgttel[w_arr].telnum  is null then
                     error "Informe o numero do telefone."
                     next field telnum
                  end if
               end if

               initialize w_telnum to null

               let w_telnum    = a_ssgttel[w_arr].telnum
               let w_tamtelnum = length(w_telnum)

               if w_tamtelnum is null then
                  let w_tamtelnum = 0
               end if

               if fgl_lastkey() = fgl_keyval("left") then
               else
                  if w_tamtelnum > 0 and w_tamtelnum < 7 then
                     error "Numero de telefone incompleto."
                     next field telnum
                  end if
               end if

               if w_acao = "i" then
                  initialize w_count to null

                  whenever error continue
                  open  cssgtseg027 using r_param.segnumdig
                                         ,a_ssgttel[w_arr].teltipcod
                                         ,a_ssgttel[w_arr].telnum
                  fetch cssgtseg027 into  w_count
                  whenever error stop
                  if sqlca.sqlcode < 0 then
                     error "Erro no cursor cssgtseg027 : " , sqlca.sqlcode
												         if figrc072_checkGlbIsolamento(sqlca.sqlcode
												                                      ,"ssgtseg02"
												                                      ,"ssgttel"
												                                      ,"cssgtseg027"
												                                      ,"","","","","","")  then
												           if r_param.opcao = 1  then # atualizacao
												              let w_upd_end_dddnum  = null
												              let w_upd_end_telnum = null
												              return w_upd_end_dddnum
												                    ,w_upd_end_telnum
												           else
												              return
												           end if
												         end if
                  end if

                  if w_count is null then
                     let w_count = 0
                  end if

                  if w_count > 0 then
                     let a_ssgttel[w_arr].telnum = ant_telnum

                     display a_ssgttel[w_arr].telnum  to s_ssgttel[w_scr].telnum

                     error "Numero ja cadastrado para este tipo de telefone."
                     next field telnum
                  end if

                  display a_ssgttel[w_arr].telnum to s_ssgttel[w_scr].telnum
               end if

               if w_acao = "a" then
                  if a_ssgttel[w_arr].telnum <> ant_telnum then
                     initialize w_count to null

                     whenever error continue
                     open  cssgtseg027 using r_param.segnumdig
                                            ,a_ssgttel[w_arr].teltipcod
                                            ,a_ssgttel[w_arr].telnum
                     fetch cssgtseg027 into w_count
                     whenever error stop
                     if sqlca.sqlcode < 0 then
                        error " Erro no cursor cssgtseg027 : " , sqlca.sqlcode
															         if figrc072_checkGlbIsolamento(sqlca.sqlcode
															                                      ,"ssgtseg02"
															                                      ,"ssgttel"
															                                      ,"cssgtseg027"
															                                      ,"","","","","","")  then
															           if r_param.opcao = 1  then # atualizacao
															              let w_upd_end_dddnum  = null
															              let w_upd_end_telnum = null
															              return w_upd_end_dddnum
															                    ,w_upd_end_telnum
															           else
															              return
															           end if
															         end if
                     end if

                     if w_count is null then
                        let w_count = 0
                     end if

                     if w_count > 0 then
                        let a_ssgttel[w_arr].telnum = ant_telnum

                        display a_ssgttel[w_arr].telnum  to
                                s_ssgttel[w_scr].telnum

                        error "Numero ja cadastrado para este tipo de telefone."

                        next field telnum
                     end if

                     display a_ssgttel[w_arr].telnum to s_ssgttel[w_scr].telnum
                  end if
               end if

          if m_confirma_docto then
             if a_ssgttel_conf[w_arr].telnum  = 'N' or
                a_ssgttel_ant[w_arr].telnum <> a_ssgttel[w_arr].telnum then
                call conqua59(m_ramo
                             ,m_modalidade
                             ,g_issk.funmat
                             ,g_issk.acsnivcod
                             ,m_unocod
                             ,'ssgtsegi'
                             ,'telnum'
                             ,''
                             ,''
                             ,''
                             ,''
                             ,a_ssgttel[w_arr].telnum)
                   returning l_ret
                            ,l_cod

                if l_ret then
                   if l_cod = 1 then
                      next field telnum
                   else
                      let a_ssgttel_conf[w_arr].telnum = 'S'
                      let a_ssgttel_ant[w_arr].telnum = a_ssgttel[w_arr].telnum
                   end if
                end if
             end if
          end if

        after  field telrmlnum
               if a_ssgttel[w_arr].telrmlnum = 0 then
                  error "Ramal incorreto."

                  initialize a_ssgttel[w_arr].telrmlnum to null

                  display a_ssgttel[w_arr].telrmlnum to
                          s_ssgttel[w_scr].telrmlnum

                  next field telrmlnum
               end if

          if m_confirma_docto then
             if a_ssgttel[w_arr].telrmlnum is not null and
                a_ssgttel[w_arr].telrmlnum <> " "      then
                if a_ssgttel_conf[w_arr].telrmlnum = 'N' or
                   a_ssgttel_ant[w_arr].telrmlnum <> a_ssgttel[w_arr].telrmlnum then
                   call conqua59(m_ramo
                                ,m_modalidade
                                ,g_issk.funmat
                                ,g_issk.acsnivcod
                                ,m_unocod
                                ,'ssgtsegi'
                                ,'telrmlnum'
                                ,''
                                ,''
                                ,''
                                ,''
                                ,a_ssgttel[w_arr].telrmlnum)
                      returning l_ret
                               ,l_cod

                   if l_ret then
                      if l_cod = 1 then
                         next field telrmlnum
                      else
                         let a_ssgttel_conf[w_arr].telrmlnum = 'S'
                         let a_ssgttel_ant[w_arr].telrmlnum = a_ssgttel[w_arr].telrmlnum
                      end if
                   end if
                end if
             end if
          end if

        after  field segtelobsflg
               initialize w_segtelobsret to null

               if (a_ssgttel[w_arr].segtelobsflg is null)  then
                  let a_ssgttel[w_arr].segtelobsflg = "N"
               end if

               if ((a_ssgttel[w_arr].segtelobsflg <> "S")  and
                   (a_ssgttel[w_arr].segtelobsflg <> "N")) then
                  error "Informe <S>im   ou   <N>ao   para observacao."
                  next field segtelobsflg
               end if

               if w_acao = "i" then
                  if a_ssgttel[w_arr].segtelobsflg = "S" then
                     call cty17g00_ssgttel_obs (b_ssgttel[w_arr].segtelobs
                                      ,a_ssgttel[w_arr].teltipdes
                                      ,r_param.opcao)
                          returning b_ssgttel[w_arr].segtelobs
                     let int_flag = false
                  end if
               else
                   let a_ssgttel[w_arr].segtelobsflg = ant_segtelobsflg
               end if

               if (b_ssgttel[w_arr].segtelobs is not null) and
                  (b_ssgttel[w_arr].segtelobs <> ' ') then
                   let a_ssgttel[w_arr].segtelobsflg = "S"
               else
                   let a_ssgttel[w_arr].segtelobsflg = "N"
               end if

               display a_ssgttel[w_arr].segtelobsflg to s_ssgttel[w_scr].segtelobsflg

        after  row
           let lr_gsaktel.segnumdig = r_param.segnumdig
           let lr_gsaktel.segtelseq = b_ssgttel[w_arr].segtelseq
           let lr_gsaktel.teltipcod = a_ssgttel[w_arr].teltipcod
           let lr_gsaktel.telnum    = a_ssgttel[w_arr].telnum
           let lr_gsaktel.dddnum    = a_ssgttel[w_arr].dddnum
           let lr_gsaktel.telrmlnum = a_ssgttel[w_arr].telrmlnum
           let lr_gsaktel.segtelobs = b_ssgttel[w_arr].segtelobs
           let lr_gsaktel.atlemp    = g_issk.empcod
           let lr_gsaktel.atlmat    = g_issk.funmat
           let lr_gsaktel.atlusrtip = g_issk.usrtip
           let lr_gsaktel.atldat    = today
           let lr_gsaktel.atlhor    = current
               case w_acao

                  when "i"

                    if a_ssgttel[w_arr].segtelobsflg is null or
                       a_ssgttel[w_arr].segtelobsflg = ' ' then
                       let a_ssgttel[w_arr].segtelobsflg = 'N'

                       display a_ssgttel[w_arr].segtelobsflg to
                               s_ssgttel[w_scr].segtelobsflg
                    end if

                    initialize w_maxsegtelseq to null

                    whenever error continue
                    open  cssgtseg029 using r_param.segnumdig
                                           ,a_ssgttel[w_arr].teltipcod
                    fetch cssgtseg029 into  w_maxsegtelseq
                    whenever error stop
                    if sqlca.sqlcode < 0 then
                       error " Erro no cursor cssgtseg029 : " , sqlca.sqlcode
														         if figrc072_checkGlbIsolamento(sqlca.sqlcode
														                                      ,"ssgtseg02"
														                                      ,"ssgttel"
														                                      ,"cssgtseg029"
														                                      ,"","","","","","")  then
														           if r_param.opcao = 1  then # atualizacao
														              let w_upd_end_dddnum  = null
														              let w_upd_end_telnum = null
														              return w_upd_end_dddnum
														                    ,w_upd_end_telnum
														           else
														              return
														           end if
														         end if
                    end if

                    if w_maxsegtelseq is null then
                       let w_maxsegtelseq = 1
                    else
                       let w_maxsegtelseq = w_maxsegtelseq + 1
                    end if

                    let b_ssgttel[w_arr].segtelseq = w_maxsegtelseq

                    begin work

                    let lr_gsaktel.segtelseq = w_maxsegtelseq
                    let l_sqlcode = osgtk1001_incluirTelefoneSegurado( lr_gsaktel.segnumdig
                                                                      ,lr_gsaktel.segtelseq
                                                                      ,lr_gsaktel.teltipcod
                                                                      ,lr_gsaktel.telnum
                                                                      ,lr_gsaktel.dddnum
                                                                      ,lr_gsaktel.telrmlnum
                                                                      ,lr_gsaktel.segtelobs
                                                                      ,lr_gsaktel.atlemp
                                                                      ,lr_gsaktel.atlmat
                                                                      ,lr_gsaktel.atlusrtip
                                                                      ,lr_gsaktel.atldat
                                                                      ,lr_gsaktel.atlhor)
                    if l_sqlcode = 0 then
                       commit work

                       call cty17g00_ssgtseg02_envia_atlz_tel(l_cabecalho
                                                    ,lr_gsaktel.teltipcod
                                                    ,lr_gsaktel.telnum
                                                    ,lr_gsaktel.dddnum)

                    else
                       rollback work
														         if figrc072_checkGlbIsolamento(l_sqlcode
														                                      ,"ssgtseg02"
														                                      ,"ssgttel"
														                                      ,"excluirtel"
														                                      ,"","","","","","")  then
														           if r_param.opcao = 1  then # atualizacao
														              let w_upd_end_dddnum  = null
														              let w_upd_end_telnum = null
														              return w_upd_end_dddnum
														                    ,w_upd_end_telnum
														           else
														              return
														           end if
														         end if
                    end if

                  when "a"

                    begin work

                    call osgtk1001_alterarTelefoneSegurado( lr_gsaktel.segnumdig
                                                           ,lr_gsaktel.segtelseq
                                                           ,lr_gsaktel.teltipcod
                                                           ,lr_gsaktel.telnum
                                                           ,lr_gsaktel.dddnum
                                                           ,lr_gsaktel.telrmlnum
                                                           ,lr_gsaktel.segtelobs
                                                           ,lr_gsaktel.atlemp
                                                           ,lr_gsaktel.atlmat
                                                           ,lr_gsaktel.atlusrtip
                                                           ,lr_gsaktel.atldat
                                                           ,lr_gsaktel.atlhor)
                       returning l_sqlcode
                                ,l_sqlerrd
                    if l_sqlcode = 0 then
                       let l_msg_alteracao = true
                       commit work

                       call cty17g00_ssgtseg02_envia_atlz_tel(l_cabecalho
                                                    ,lr_gsaktel.teltipcod
                                                    ,lr_gsaktel.telnum
                                                    ,lr_gsaktel.dddnum)

                    else
                       rollback work
														         if figrc072_checkGlbIsolamento(l_sqlcode
														                                      ,"ssgtseg02"
														                                      ,"ssgttel"
														                                      ,"alterartel"
														                                      ,"","","","","","")  then
														           if r_param.opcao = 1  then # atualizacao
														              let w_upd_end_dddnum  = null
														              let w_upd_end_telnum = null
														              return w_upd_end_dddnum
														                    ,w_upd_end_telnum
														           else
														              return
														           end if
														         end if
                    end if

                  otherwise
                    let int_flag = false
                    exit input

               end case

        on key (F5)
               initialize w_segtelobsret
                         ,w_count        to null

               whenever error continue
               open  cssgtseg028 using r_param.segnumdig
                                      ,b_ssgttel[w_arr].segtelseq
                                      ,a_ssgttel[w_arr].teltipcod
               fetch cssgtseg028 into  w_count
               whenever error stop
               if sqlca.sqlcode < 0 then
                  error " Erro no cursor cssgtseg028 : " , sqlca.sqlcode
									         if figrc072_checkGlbIsolamento(sqlca.sqlcode
									                                      ,"ssgtseg02"
									                                      ,"ssgttel"
									                                      ,"cssgtseg028"
									                                      ,"","","","","","")  then
									           if r_param.opcao = 1  then # atualizacao
									              let w_upd_end_dddnum  = null
									              let w_upd_end_telnum = null
									              return w_upd_end_dddnum
									                    ,w_upd_end_telnum
									           else
									              return
									           end if
									         end if
               end if

               if w_count is null then
                  let w_count = 0
               end if

               if w_count > 0  then
                  call cty17g00_ssgttel_obs(b_ssgttel[w_arr].segtelobs
                                  ,a_ssgttel[w_arr].teltipdes
                                  ,r_param.opcao)
                       returning w_segtelobsret

                  let int_flag = false

                  if w_segtelobsret is null then
                     let w_segtelobsret = ' '
                  end if

                  if b_ssgttel[w_arr].segtelobs is null then
                     let b_ssgttel[w_arr].segtelobs = ' '
                  end if

                  let lr_gsaktel.telnum     = a_ssgttel[w_arr].telnum
                  let lr_gsaktel.dddnum     = a_ssgttel[w_arr].dddnum
                  let lr_gsaktel.telrmlnum  = a_ssgttel[w_arr].telrmlnum
                  let lr_gsaktel.segtelobs  = b_ssgttel[w_arr].segtelobs
                  let lr_gsaktel.atlemp     = g_issk.empcod
                  let lr_gsaktel.atlmat     = g_issk.funmat
                  let lr_gsaktel.atlusrtip  = g_issk.usrtip
                  let lr_gsaktel.atldat     = today
                  let lr_gsaktel.atlhor     = current
                  let lr_gsaktel.segnumdig  = r_param.segnumdig
                  let lr_gsaktel.segtelseq  = b_ssgttel[w_arr].segtelseq
                  let lr_gsaktel.teltipcod  = a_ssgttel[w_arr].teltipcod
                  if b_ssgttel[w_arr].segtelobs <> w_segtelobsret then
                     begin work

                     call osgtk1001_alterarTelefoneSegurado( lr_gsaktel.segnumdig
                                                            ,lr_gsaktel.segtelseq
                                                            ,lr_gsaktel.teltipcod
                                                            ,lr_gsaktel.telnum
                                                            ,lr_gsaktel.dddnum
                                                            ,lr_gsaktel.telrmlnum
                                                            ,lr_gsaktel.segtelobs
                                                            ,lr_gsaktel.atlemp
                                                            ,lr_gsaktel.atlmat
                                                            ,lr_gsaktel.atlusrtip
                                                            ,lr_gsaktel.atldat
                                                            ,lr_gsaktel.atlhor)
                        returning l_sqlcode
                                 ,l_sqlerrd
                     if l_sqlcode = 0 then
                        commit work

                       call cty17g00_ssgtseg02_envia_atlz_tel(l_cabecalho
                                                    ,lr_gsaktel.teltipcod
                                                    ,lr_gsaktel.telnum
                                                    ,lr_gsaktel.dddnum)

                     else
                        rollback work

															         if figrc072_checkGlbIsolamento(l_sqlcode
															                                      ,"ssgtseg02"
															                                      ,"ssgttel"
															                                      ,"alterartel"
															                                      ,"","","","","","")  then
															           if r_param.opcao = 1  then # atualizacao
															              let w_upd_end_dddnum  = null
															              let w_upd_end_telnum = null
															              return w_upd_end_dddnum
															                    ,w_upd_end_telnum
															           else
															              return
															           end if
															         end if
                     end if

                     begin work
                     call osgtk1001_alterarTelefoneSegurado( lr_gsaktel.segnumdig
                                                            ,lr_gsaktel.segtelseq
                                                            ,lr_gsaktel.teltipcod
                                                            ,lr_gsaktel.telnum
                                                            ,lr_gsaktel.dddnum
                                                            ,lr_gsaktel.telrmlnum
                                                            ,lr_gsaktel.segtelobs
                                                            ,lr_gsaktel.atlemp
                                                            ,lr_gsaktel.atlmat
                                                            ,lr_gsaktel.atlusrtip
                                                            ,lr_gsaktel.atldat
                                                            ,lr_gsaktel.atlhor)
                        returning l_sqlcode
                                 ,l_sqlerrd
                     if l_sqlcode = 0 then
                        commit work

                       call cty17g00_ssgtseg02_envia_atlz_tel(l_cabecalho
                                                    ,lr_gsaktel.teltipcod
                                                    ,lr_gsaktel.telnum
                                                    ,lr_gsaktel.dddnum)

                     else
                        rollback work
														         if figrc072_checkGlbIsolamento(l_sqlcode
														                                      ,"ssgtseg02"
														                                      ,"ssgttel"
														                                      ,"alterartel"
														                                      ,"","","","","","")  then
														           if r_param.opcao = 1  then # atualizacao
														              let w_upd_end_dddnum  = null
														              let w_upd_end_telnum = null
														              return w_upd_end_dddnum
														                    ,w_upd_end_telnum
														           else
														              return
														           end if
														         end if
                     end if
                  end if

                  if (w_segtelobsret is not null) and
                     (w_segtelobsret <> ' ')      then
                     let w_segtelobsret  = "S"
                  else
                     let w_segtelobsret  = "N"
                  end if

                  display w_segtelobsret to s_ssgttel[w_scr].segtelobsflg

                  let int_flag = false
                  let w_sair   = "n"

                  exit input
               end if

        on key (f17,control-c,interrupt)
               --- Tenta inserir telefone seguindo a ordem de importancia:
               --- (03) Telefone Residencial
               --- (10) Telefone Recado
               --- (11) Telefone Celular
                if l_msg_alteracao = true and
                   r_param.segurado = 1 then
                   let l_resposta = cty17g00_ssgtseg_confirma("T")
                   let l_resposta = upshift(l_resposta)

                   if l_resposta <> "S" then
                      continue input
                   end if
                end if

                call cty17g00_ssgtseg_atlz_usuario(r_param.segnumdig,
                                          g_issk.empcod,
                                          g_issk.funmat,
                                          g_issk.usrtip)

               initialize w_teltxt_gsakend to null

               whenever error continue
               select teltxt
                 into w_teltxt_gsakend
                 from gsakend
                where segnumdig = r_param.segnumdig
                  and endfld    = '1'
               whenever error stop
               if sqlca.sqlcode < 0 then
                  error "Erro ao selecionar telefone : " , sqlca.sqlcode
									         if figrc072_checkGlbIsolamento(sqlca.sqlcode
									                                      ,"ssgtseg02"
									                                      ,"ssgttel"
									                                      ,"selectend"
									                                      ,"","","","","","")  then
			 						           if r_param.opcao = 1  then # atualizacao
				 					              let w_upd_end_dddnum  = null
					 				              let w_upd_end_telnum = null
						 			              return w_upd_end_dddnum
							 		                    ,w_upd_end_telnum
								 	           else
									               return
									            end if
									         end if
               else
                  if sqlca.sqlcode = 100 then
                     let w_posso_atualizar = "n"
                     let w_sair            = "s"

                     exit input
                  end if
               end if

               if w_posso_atualizar = "s" then
                   let ix = 1

                   for ix = 1 to arr_count()
                       if (a_ssgttel[ix].teltipcod = 3 ) or   # --- Telefone Resi
                          (a_ssgttel[ix].teltipcod = 10) or   # --- Telefone Recado
                          (a_ssgttel[ix].teltipcod = 11) then # --- Telefone Cel

                           initialize w_upd_end_dddnum
                                     ,w_upd_end_telnum  to null

                           let w_upd_end_dddnum = a_ssgttel[ix].dddnum
                           let w_upd_end_telnum = a_ssgttel[ix].telnum

                           whenever error continue
                           open cssgtseg056 using r_param.segnumdig
                           fetch cssgtseg056 into lr_gsakend.endlgdtip
                                                 ,lr_gsakend.endlgd
                                                 ,lr_gsakend.endnum
                                                 ,lr_gsakend.endcmp
                                                 ,lr_gsakend.endcepcmp
                                                 ,lr_gsakend.endbrr
                                                 ,lr_gsakend.endcid
                                                 ,lr_gsakend.endufd
                                                 ,lr_gsakend.endcep
                                                 ,lr_gsakend.atlult
                                                 ,lr_gsakend.tlxtxt
                                                 ,lr_gsakend.factxt
                           whenever error stop
                           if sqlca.sqlcode <> 0 then
                              if sqlca.sqlcode = 100 then
                                 initialize lr_gsakend to null
                                 let l_stt = false
                              else
                                 error 'Erro SELECT cssgtseg056 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
                                 error 'SSGTSEG / ssgttel() / ',r_param.segnumdig  sleep 2
                                 let w_sair = "s"
                                 let l_stt = false
                                 exit input

																								         if figrc072_checkGlbIsolamento(sqlca.sqlcode
																								                                      ,"ssgtseg02"
																								                                      ,"ssgttel"
																								                                      ,"cssgtseg056"
																								                                      ,"","","","","","")  then
																		 						           if r_param.opcao = 1  then # atualizacao
																			 					              let w_upd_end_dddnum  = null
																				 				              let w_upd_end_telnum = null
																					 			              return w_upd_end_dddnum
																						 		                    ,w_upd_end_telnum
																							 	           else
																								               return
																								            end if
																								         end if
                              end if
                           end if

                           let lr_gsakend.segnumdig = r_param.segnumdig
                           let lr_gsakend.endfld    = 1
                           let lr_gsakend.teltxt    = w_upd_end_telnum
                           let lr_gsakend.dddcod    = w_upd_end_dddnum
                           if l_stt then
                              begin work
                              call osgtk1001_alterarEnderecoSegurado( lr_gsakend.segnumdig
                                                                     ,lr_gsakend.endfld
                                                                     ,lr_gsakend.endlgdtip
                                                                     ,lr_gsakend.endlgd
                                                                     ,lr_gsakend.endnum
                                                                     ,lr_gsakend.endcmp
                                                                     ,lr_gsakend.endcepcmp
                                                                     ,lr_gsakend.endbrr
                                                                     ,lr_gsakend.endcid
                                                                     ,lr_gsakend.endufd
                                                                     ,lr_gsakend.endcep
                                                                     ,lr_gsakend.dddcod
                                                                     ,lr_gsakend.teltxt
                                                                     ,lr_gsakend.tlxtxt
                                                                     ,lr_gsakend.factxt
                                                                     ,lr_gsakend.atlult)
                                    returning l_sqlcode
                                          ,l_sqlerrd
                              if l_sqlcode = 0 then
                                 commit work
                              else
                                 rollback work
																								         if figrc072_checkGlbIsolamento(l_sqlcode
																								                                      ,"ssgtseg02"
																								                                      ,"ssgttel"
																								                                      ,"alterarend"
																								                                      ,"","","","","","")  then
																		 						           if r_param.opcao = 1  then # atualizacao
																			 					              let w_upd_end_dddnum  = null
																				 				              let w_upd_end_telnum = null
																					 			              return w_upd_end_dddnum
																						 		                    ,w_upd_end_telnum
																							 	           else
																								               return
																								            end if
																								         end if
                              end if
                           end if
                           let l_stt = true
                           let w_posso_atualizar = "n"

                           exit for
                       end if
                   end for
                end if

                --(XX) Caso nao encontre um dos 3 acima insere o primeiro que achar.

                if w_posso_atualizar = "s" then
                   let w_posso_atualizar = "n"

                   initialize w_upd_end_dddnum
                             ,w_upd_end_telnum to null

                   declare cssgtseg031 cursor with hold for
                     select dddnum
                           ,telnum
                       from gsaktel
                      where segnumdig = r_param.segnumdig

                   whenever error continue
                   open  cssgtseg031
                   fetch cssgtseg031 into w_upd_end_dddnum
                                         ,w_upd_end_telnum
                   whenever error stop
                   if sqlca.sqlcode < 0 then
                      error "Erro no cursor cssgtseg031 : " , sqlca.sqlcode
													         if figrc072_checkGlbIsolamento(sqlca.sqlcode
													                                      ,"ssgtseg02"
													                                      ,"ssgttel"
													                                      ,"cssgtseg031"
													                                      ,"","","","","","")  then
							 						           if r_param.opcao = 1  then # atualizacao
								 					              let w_upd_end_dddnum  = null
									 				              let w_upd_end_telnum = null
										 			              return w_upd_end_dddnum
											 		                    ,w_upd_end_telnum
												 	           else
													               return
													            end if
													         end if
                   end if

                   if w_upd_end_dddnum is null then
                      let w_upd_end_dddnum = ' '
                   end if

                   if w_upd_end_telnum is null then
                      let w_upd_end_telnum = ' '
                   end if

                   initialize w_count to null

                   whenever error continue
                   select count(*)
                     into w_count
                     from gsakend
                    where segnumdig = r_param.segnumdig
                      and endfld    = '1'
                   whenever error stop

                   if sqlca.sqlcode < 0 then
                      error "Erro ao acessar o cadastro de endereco : " , sqlca.sqlcode

													         if figrc072_checkGlbIsolamento(sqlca.sqlcode
													                                      ,"ssgtseg02"
													                                      ,"ssgttel"
													                                      ,"selectend"
													                                      ,"","","","","","")  then
							 						           if r_param.opcao = 1  then # atualizacao
								 					              let w_upd_end_dddnum  = null
									 				              let w_upd_end_telnum = null
										 			              return w_upd_end_dddnum
											 		                    ,w_upd_end_telnum
												 	           else
													               return
													            end if
													         end if
                   end if
                   if w_count is null then
                      let w_count = 0
                   end if

                   if w_count > 0 then
                      whenever error continue
                      open cssgtseg056 using r_param.segnumdig
                      fetch cssgtseg056 into lr_gsakend.endlgdtip
                                            ,lr_gsakend.endlgd
                                            ,lr_gsakend.endnum
                                            ,lr_gsakend.endcmp
                                            ,lr_gsakend.endcepcmp
                                            ,lr_gsakend.endbrr
                                            ,lr_gsakend.endcid
                                            ,lr_gsakend.endufd
                                            ,lr_gsakend.endcep
                                            ,lr_gsakend.atlult
                                            ,lr_gsakend.tlxtxt
                                            ,lr_gsakend.factxt
                      whenever error stop
                      if sqlca.sqlcode <> 0 then
                         if sqlca.sqlcode = notfound then
                            initialize lr_gsakend to null
                            let l_stt = false
                         else
                            error 'Erro SELECT cssgtseg056 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
                            error 'SSGTSEG / ssgttel() / ',r_param.segnumdig  sleep 2
                            let w_sair = "s"
                            let l_stt = false
                            exit input

																			         if figrc072_checkGlbIsolamento(sqlca.sqlcode
																			                                      ,"ssgtseg02"
																			                                      ,"ssgttel"
																			                                      ,"cssgtseg056"
																			                                      ,"","","","","","")  then
													 						           if r_param.opcao = 1  then # atualizacao
														 					              let w_upd_end_dddnum  = null
															 				              let w_upd_end_telnum = null
																 			              return w_upd_end_dddnum
																	 		                    ,w_upd_end_telnum
																		 	           else
																			               return
																			            end if
																			         end if
                         end if
                      end if

                      let lr_gsakend.segnumdig = r_param.segnumdig
                      let lr_gsakend.endfld    = 1
                      let lr_gsakend.teltxt    = w_upd_end_telnum
                      let lr_gsakend.dddcod    = w_upd_end_dddnum


                      if l_stt then
                         begin work
                         call osgtk1001_alterarEnderecoSegurado(  lr_gsakend.segnumdig
                                                                 ,lr_gsakend.endfld
                                                                 ,lr_gsakend.endlgdtip
                                                                 ,lr_gsakend.endlgd
                                                                 ,lr_gsakend.endnum
                                                                 ,lr_gsakend.endcmp
                                                                 ,lr_gsakend.endcepcmp
                                                                 ,lr_gsakend.endbrr
                                                                 ,lr_gsakend.endcid
                                                                 ,lr_gsakend.endufd
                                                                 ,lr_gsakend.endcep
                                                                 ,lr_gsakend.dddcod
                                                                 ,lr_gsakend.teltxt
                                                                 ,lr_gsakend.tlxtxt
                                                                 ,lr_gsakend.factxt
                                                                 ,lr_gsakend.atlult)
                            returning  l_sqlcode
                                      ,l_sqlerrd
                            if l_sqlcode = 0 then
                               commit work
                            else
                               rollback work

																						         if figrc072_checkGlbIsolamento(l_sqlcode
																						                                      ,"ssgtseg02"
																						                                      ,"ssgttel"
																						                                      ,"alterarend"
																						                                      ,"","","","","","")  then
																 						           if r_param.opcao = 1  then # atualizacao
																	 					              let w_upd_end_dddnum  = null
																		 				              let w_upd_end_telnum = null
																			 			              return w_upd_end_dddnum
																				 		                    ,w_upd_end_telnum
																					 	           else
																						               return
																						            end if
																						         end if
                            end if
                      end if
                      let l_stt = true
                   end if
                end if

                let w_sair = "s"

                exit input

      end input

   end if

   if w_sair = "s" then
      let int_flag = true
      exit while
   end if

 end while
   if not l_stt then
      let int_flag = false
      close window ssgttel
      if r_param.opcao = 1  then
         return w_upd_end_dddnum
               ,w_upd_end_telnum
      end if
      return
   end if
 --- Seleciona registro para atualizar a ssgtseg (Tela Principal) ---
 --- ------------------------------------------------------------ ---

 declare cssgtseg032 cursor with hold for
   select dddnum
         ,telnum
     from gsaktel
    where segnumdig = r_param.segnumdig
      and teltipcod = 3  # --- Telefone Residencial

 whenever error continue
 open  cssgtseg032
 fetch cssgtseg032 into w_upd_end_dddnum
                       ,w_upd_end_telnum
 whenever error stop

 if sqlca.sqlcode < 0 then
    error "Erro no cursor cssgtseg032 : " , sqlca.sqlcode

    if figrc072_checkGlbIsolamento(sqlca.sqlcode
                                 ,"ssgtseg02"
                                 ,"ssgttel"
                                 ,"cssgtseg032"
                                 ,"","","","","","")  then
       if r_param.opcao = 1  then # atualizacao
          let w_upd_end_dddnum  = null
          let w_upd_end_telnum = null
          return w_upd_end_dddnum
                ,w_upd_end_telnum
       else
          return
       end if
    end if
 else
    if sqlca.sqlcode = 100 then
       initialize w_upd_end_dddnum
                 ,w_upd_end_telnum to null
    end if
 end if

 if ((w_upd_end_telnum is null) or (w_upd_end_dddnum is null) or
     (w_upd_end_telnum = ' ')   or (w_upd_end_dddnum = ' '))  then
    declare cssgtseg033 cursor with hold for
      select dddnum
            ,telnum
        from gsaktel
       where segnumdig = r_param.segnumdig
         and teltipcod = 11 # --- Telefone Celular

    whenever error continue
    open  cssgtseg033
    fetch cssgtseg033 into w_upd_end_dddnum
                          ,w_upd_end_telnum
    whenever error stop

    if sqlca.sqlcode < 0 then
       error " Erro no cursor cssgtseg033 : " , sqlca.sqlcode
			    if figrc072_checkGlbIsolamento(sqlca.sqlcode
			                                 ,"ssgtseg02"
			                                 ,"ssgttel"
			                                 ,"cssgtseg033"
			                                 ,"","","","","","")  then
			       if r_param.opcao = 1  then # atualizacao
			          let w_upd_end_dddnum  = null
			          let w_upd_end_telnum = null
			          return w_upd_end_dddnum
			                ,w_upd_end_telnum
			       else
			          return
			       end if
			    end if
    else
       if status = notfound then
          initialize w_upd_end_dddnum
                    ,w_upd_end_telnum to null
       end if
    end if
 end if

 if ((w_upd_end_telnum is null) or (w_upd_end_dddnum is null) or
     (w_upd_end_telnum = ' ')   or (w_upd_end_dddnum = ' '))  then
    declare cssgtseg034 cursor with hold for
      select dddnum
            ,telnum
        from gsaktel
       where segnumdig = r_param.segnumdig

    whenever error continue
    open  cssgtseg034
    fetch cssgtseg034 into w_upd_end_dddnum
                          ,w_upd_end_telnum
    whenever error stop
    if sqlca.sqlcode < 0 then
       error "Erro no cursor cssgtseg034 : " , sqlca.sqlcode

			    if figrc072_checkGlbIsolamento(sqlca.sqlcode
			                                 ,"ssgtseg02"
			                                 ,"ssgttel"
			                                 ,"cssgtseg034"
			                                 ,"","","","","","")  then
			       if r_param.opcao = 1  then # atualizacao
			          let w_upd_end_dddnum  = null
			          let w_upd_end_telnum = null
			          return w_upd_end_dddnum
			                ,w_upd_end_telnum
			       else
			          return
			       end if
			    end if
    else
       if sqlca.sqlcode = 100 then
          initialize w_upd_end_dddnum
                    ,w_upd_end_telnum to null
       end if
    end if
 end if

 let int_flag = false

 close window ssgttel

 if r_param.opcao = 1  then # atualizacao
    return w_upd_end_dddnum
          ,w_upd_end_telnum
 end if

end function

#-------------------------------------------------
function cty17g00_ssgttel_obs(w_segtelobs, tipotel,w_opcao)
#-------------------------------------------------

 define w_segtelobs varchar(100)
       ,tipotel     char(20)
       ,segtelobs1  char(50)
       ,segtelobs2  char(50)
       ,w_opcao     smallint
       ,w_lixo      char(1)

 #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 let segtelobs1 = null
 let segtelobs2 = null
 let w_lixo     = null

 let segtelobs1 = w_segtelobs[01,050]
 let segtelobs2 = w_segtelobs[51,100]

 open window ssgtobs  at 14,12 with form "ssgtobs"
      attribute (form line 1)

 let tipotel = upshift(tipotel)

 display tipotel at 2,33 attribute (reverse)

 if w_opcao = 1 then
    input by name segtelobs1
                 ,segtelobs2
          without defaults

      after  field segtelobs2
             if fgl_lastkey() <> fgl_keyval("up")   and
                fgl_lastkey() <> fgl_keyval("left") then
                let w_segtelobs = segtelobs1, segtelobs2
                let int_flag    = false
                exit input
             end if

      on key (interrupt)
             let w_segtelobs = segtelobs1, segtelobs2
             let int_flag    = false
             exit input

    end input
 else
    display segtelobs1 at 5,3
    display segtelobs2 at 6,3

    prompt '' for w_lixo
 end if

 let int_flag = false

 close window ssgtobs

 return w_segtelobs

end function

#-----------------
function cty17g00_ssgtpop()
#-----------------

 define param           char(30)
       ,w_arr           smallint
       ,w_comando       char(400)
       ,w_pf1           integer

 define a_popup array [200] of record
        va_teltipcod    dec(3,0)
       ,va_teltipdes    char(32)
 end record

 #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 let param      = null
 let w_arr      = null
 let w_comando  = null
 let w_pf1      = null

 #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 for w_pf1 = 1 to 200
     initialize a_popup[w_pf1].* to null
 end for

 initialize a_popup
           ,w_comando to null

 --- Identifica ambiente de execucao ---
 --- ------------------------------- ---
 call figrc072_initGlbIsolamento()
 call cty17g00_ssgtseg_prepara()
 if m_prep_sql = false then
    return a_popup[1].va_teltipcod
          ,a_popup[1].va_teltipdes
 end if

 if not figrc012_sitename('ssgtseg', '', '') then
    display 'Erro Selecionando Sitename da DUAL'
    exit program(1)
 end if


 	  let m_host = fun_dba_servidor("EMISAUTO")
    let w_comando = "select cpocod, cpodes ",
                    "  from porto@",m_host clipped,":iddkdominio",
                    " where cponom = 'segteltipcod'"

 whenever error continue
 prepare pssgtseg015 from w_comando
 declare cssgtseg035 cursor with hold for pssgtseg015
 whenever error stop
 if sqlca.sqlcode < 0 then
    error " Erro no prepare do cursor cssgtseg035 : " , sqlca.sqlcode
    if figrc072_checkGlbIsolamento(sqlca.sqlcode
                                 ,"ssgtseg02"
                                 ,"ssgtpop"
                                 ,"cssgtseg035"
                                 ,"","","","","","")  then
       let a_popup[1].va_teltipcod  = null
       let a_popup[1].va_teltipdes = null
       return a_popup[1].va_teltipcod
             ,a_popup[1].va_teltipdes
    end if
 end if

 let w_arr = 1

 foreach cssgtseg035 into a_popup[w_arr].*

   let a_popup[w_arr].va_teltipdes = upshift(a_popup[w_arr].va_teltipdes)

   if w_arr >= 200 then
      error "Tabela estourou"
      exit foreach
   end if

   let  w_arr  =  w_arr  +  1

 end foreach

 close cssgtseg035

 open window ssgtpop at 14,8   with form "ssgtpop"
      attribute (border, form line 1)

 display "(F8)-Selecionar (Ctrl C)-Sair" at 7,1

 let int_flag = false

 call set_count(w_arr - 1)

 display array a_popup to s_popup.*

   on key (interrupt)
          initialize a_popup[w_arr].va_teltipcod
                    ,a_popup[w_arr].va_teltipdes  to null
          exit display

   on key (f8)
          let w_arr = arr_curr()
          exit display

   on key (control-c)
          initialize a_popup[w_arr].va_teltipcod
                    ,a_popup[w_arr].va_teltipdes  to null

 end display

 let  int_flag = false

 close window ssgtpop

 return a_popup[w_arr].va_teltipcod
       ,a_popup[w_arr].va_teltipdes

end function

#-------------------------
function cty17g00_ssgtmail(w_email)
#-------------------------

 define ix           smallint
       ,w_ok         char(1)
       ,w_email      char(60)
       ,w_emailret   char(50)
       ,w_erro       char(1)
       ,w_ponto      char(1)
       ,w_arroba     char(1)
       ,w_tammail    smallint
       ,w_tammailret smallint

 #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize ix
           ,w_ok
           ,w_emailret
           ,w_erro
           ,w_ponto
           ,w_arroba
           ,w_tammail
           ,w_tammailret to null

 let w_erro       = "n"
 let w_ponto      = "n"
 let w_arroba     = "n"
 let w_ok         = "n"

 let w_tammail = length(w_email)

 if w_tammail is null or
    w_tammail  = ' '  or
    w_tammail  = 0    then
    let w_tammail = 1
 end if

 for ix = 1 to w_tammail
     if ix = 1 then
        if w_email[ix] = "." or
           w_email[ix] = "@" then
           let w_erro = "s"
           exit for
        end if
     end if

     if ((w_email[ix] = "@") and (w_email[ix +1] = ".")) or
        ((w_email[ix] = ".") and (w_email[ix +1] = "@")) then
        let w_erro = "s"
        exit for
     end if

     if w_email[ix] = " " then
        continue for
     end if

     if w_email[ix] = "." then
        let w_ponto  = "s"
     end if

     if w_email[ix] = "@" then
        let w_arroba = "s"
     end if

     let w_emailret = w_emailret clipped, w_email[ix]
 end for

 let w_tammailret = length(w_emailret)

 if (w_arroba = "s") and (w_ponto  = "s")   and
    (w_erro = "n")   and (w_tammailret > 4) then
    let w_ok = "s"
    return w_ok
 else
    let w_ok = "n"
    return w_ok
 end if

end function

#-----------------------------------------
function cty17g00_ssgtemail(w_segnumdig,w_segurado)
#-----------------------------------------

 define r_gsakendmai   record
        segnumdig      like gsakendmai.segnumdig,
        endfld         like gsakendmai.endfld,
        maides         like gsakendmai.maides    ## psi201987
       ,atlemp         like gsakendmai.atlemp
       ,atlmat         like gsakendmai.atlmat
       ,atldat         like gsakendmai.atldat
       ,atlhor         like gsakendmai.atlhor
       ,atlusrtip      like gsakendmai.atlusrtip ## psi201987
        end            record

       ,w_segnumdig    like gsakseg.segnumdig
       ,w_segurado     smallint
       ,w_oper         char(1)
       ,w_resposta     char(1)
       ,w_maides_old   like gsakendmai.maides
       ,w_ok           char(1)
       ,w_littxt       varchar(10)

       ,w_mailfunc     record
        funnom         like isskfunc.funnom
       ,dptsgl         like isskfunc.dptsgl
        end            record

       ,l_grlinf         dec(5,0)
       ,l_mensagem       like datkgeral.grlinf
       ,w_alerta_resp    char(01)
       ,l_alerta         smallint
       ,l_msg_alteracao  smallint
       ,l_telemail       char(33)
   define lr_gsakendmai record
          segnumdig     like gsakseg.segnumdig
         ,endfld        char(01)
         ,maides        like gsakendmai.maides
         ,atldat        like gsaktel.atldat
         ,atlhor        like gsaktel.atlhor
         ,atlmat        like gsaktel.atlmat
         ,atlusrtip     like gsaktel.atlusrtip
         ,atlemp        like gsaktel.atlemp
                        end record
   define l_sqlcode integer
         ,l_sqlerrd integer
         ,l_stt     smallint
         ,l_opcao   char(01)
         ,l_cabecalho char(1000)
   initialize lr_gsakendmai to null
   let l_sqlcode = null
   let l_sqlerrd = null
   let l_stt     = true
   let l_opcao   = null

 #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize w_oper
           ,w_resposta
           ,w_maides_old
           ,w_ok
           ,w_littxt
           ,l_grlinf
           ,l_mensagem
           ,l_telemail
           ,r_gsakendmai.*
           ,w_mailfunc.*  to  null

 let l_alerta        = true
 let l_msg_alteracao = true

 if m_prep_sql is null or
    m_prep_sql <> true then
    call figrc072_initGlbIsolamento()
    call cty17g00_ssgtseg_prepara()

    if m_prep_sql = false then
       return
    end if
 end if


 if w_segnumdig is null or
    w_segnumdig  = 0    then
    display "Erro na numeracao do segurado."
    return
 end if

 call cty17g00_ssgtseg02_cabecalho_xml(w_segnumdig)
      returning l_sqlcode
               ,l_cabecalho

 let int_flag = false

 while not int_flag

   whenever error continue
   open  c_cty17g00_004 using w_segnumdig
   fetch c_cty17g00_004 into  r_gsakendmai.segnumdig
                          ,r_gsakendmai.endfld
                          ,r_gsakendmai.maides     ## psi201987
                          ,r_gsakendmai.atlemp
                          ,r_gsakendmai.atlmat
                          ,r_gsakendmai.atldat
                          ,r_gsakendmai.atlhor
                          ,r_gsakendmai.atlusrtip  ## psi201987
   whenever error stop
   let l_sqlcode = sqlca.sqlcode
   if l_sqlcode < 0 then
      display " Erro no cursor cssgtseg042: " , l_sqlcode
      error   " Erro no cursor cssgtseg042: " , l_sqlcode

      if figrc072_checkGlbIsolamento(l_sqlcode
                                    ,"ssgtseg02"
                                    ,"ssgtemail"
                                    ,"cssgtseg042"
                                    ,"","","","","","")  then
         return
      end if
   end if

   if l_sqlcode = 100 then
      initialize r_gsakendmai.*
                ,w_mailfunc.*   to null

      -- Nao tendo email, busca ultima atualizacao do telefone
      whenever error continue
      open  cssgtseg043 using w_segnumdig
      fetch cssgtseg043 into  r_gsakendmai.atldat
                             ,r_gsakendmai.atlemp
                             ,r_gsakendmai.atlmat
                             ,r_gsakendmai.atlhor
                             ,r_gsakendmai.atlusrtip
      whenever error stop

      let l_sqlcode = sqlca.sqlcode
      if l_sqlcode < 0 then
         display " Erro no cursor cssgtseg043: " , l_sqlcode
         error   " Erro no cursor cssgtseg043: " , l_sqlcode

         if figrc072_checkGlbIsolamento(l_sqlcode
                                       ,"ssgtseg02"
                                       ,"ssgtemail"
                                       ,"cssgtseg043"
                                       ,"","","","","","")  then
            return
         end if
      end if
      close cssgtseg043

      let w_oper   = "I"
      let w_littxt = "inclusao"
   else
      -- Caso email esteja nulo, busca ultima atualizacao do telefone
      if r_gsakendmai.maides is null or
         r_gsakendmai.maides = " " then

         whenever error continue
         open  cssgtseg043 using w_segnumdig
         fetch cssgtseg043 into  r_gsakendmai.atldat
                                ,r_gsakendmai.atlemp
                                ,r_gsakendmai.atlmat
                                ,r_gsakendmai.atlhor
                                ,r_gsakendmai.atlusrtip
         whenever error stop

         let l_sqlcode = sqlca.sqlcode
         if l_sqlcode < 0 then
            display " Erro no cursor cssgtseg043: " , l_sqlcode
            error   " Erro no cursor cssgtseg043: " , l_sqlcode
						      if figrc072_checkGlbIsolamento(l_sqlcode
						                                    ,"ssgtseg02"
						                                    ,"ssgtemail"
						                                    ,"cssgtseg043"
						                                    ,"","","","","","")  then
						         return
						      end if
         end if
         close cssgtseg043
      end if

      let w_littxt = "alteracao"
      let w_oper   = "A"
   end if

   close c_cty17g00_004

   if r_gsakendmai.atlemp is null or
      r_gsakendmai.atlmat is null then
      let r_gsakendmai.atlemp    = g_issk.empcod
      let r_gsakendmai.atlmat    = g_issk.funmat
      let r_gsakendmai.atlusrtip = g_issk.usrtip
   end if

   call cty17g00_ssgtseg_func(r_gsakendmai.atlemp
                    ,r_gsakendmai.atlmat
                    ,r_gsakendmai.atlusrtip)
        returning w_mailfunc.funnom
                 ,w_mailfunc.dptsgl

   if r_gsakendmai.maides is null or
      r_gsakendmai.maides = " " then

      -- ATUALIZA GSAKTEL(atldat,atlhor,atlemp,atlmat,atlusrtip)

      call cty17g00_ssgtseg_atlz_usuario(w_segnumdig
                               ,r_gsakendmai.atlemp
                               ,r_gsakendmai.atlmat
                               ,r_gsakendmai.atlusrtip)
   end if

   if l_alerta      = true       and
      (g_issk.dptsgl = "ct24hs"  or
       g_issk.dptsgl = "dsvatd"  or
       g_issk.dptsgl = "tlprod"  or
       g_issk.dptsgl = "desenv") and
      w_segurado    = 1          then
      -- Busca dias de atualizacao do e-mail do segurado

      let l_grlinf = cty17g00_ssgtseg_busca_dias()
      if r_gsakendmai.atldat is null then
         let r_gsakendmai.atldat = (today - l_grlinf) - 5
      end if

      if (( today - r_gsakendmai.atldat ) > l_grlinf) then
         let l_alerta        = true
         let l_msg_alteracao = true
         let l_telemail = "E-mail atualizado a mais de "
         let l_mensagem = l_grlinf clipped, " dia(s)." clipped
         # Retirada por Solicitacao da Miriam Anselmo 10/09
         #call ssgtseg_alerta( "Q", l_telemail , l_mensagem," Solicite Confirmacao.")
      else
         let l_msg_alteracao = false
      end if
   end if

   open window ssgtEMAIL  at 10,7 with form "ssgtmai"
        attribute (border,form line 1)

   input by name r_gsakendmai.maides without defaults

     before field maides
            let w_maides_old = r_gsakendmai.maides

            call cty17g00_ssgtseg_func(r_gsakendmai.atlemp
                             ,r_gsakendmai.atlmat
                             ,r_gsakendmai.atlusrtip)
                 returning w_mailfunc.funnom
                          ,w_mailfunc.dptsgl

            display w_mailfunc.funnom       to funnom
            display w_mailfunc.dptsgl       to dptsgl
            display r_gsakendmai.atldat     to atldat
            display r_gsakendmai.atlhor     to atlhor

     after  field maides
            if w_maides_old is null then
               let w_maides_old =  " "
            end if

            if w_maides_old = r_gsakendmai.maides then
               let l_alerta     = false
            end if

            if r_gsakendmai.maides is null then
               let r_gsakendmai.maides =  " "
               exit input
            end if

            let w_ok = "n"

            call cty17g00_ssgtmail(r_gsakendmai.maides)
                 returning w_ok

            if downshift(w_ok) = "n" then
               error "E-mail invalido."
               exit input
            end if

            if w_maides_old <> r_gsakendmai.maides then
               let w_resposta = "N"

               display "+---------------------------+" at 10,22
               display "|" at 11,22
               display "Confirma ",w_littxt,"? <S/N>" at 11,23 attribute (reverse)
               display "+---------------------------+" at 12,22
               display "|" at 11,50

               prompt "" for char w_resposta

               if upshift(w_resposta) <> "S"  then
                  continue input
               else
                  let l_msg_alteracao = false
               end if
            end if
            let lr_gsakendmai.segnumdig = w_segnumdig
            let lr_gsakendmai.endfld    = '1'
            let lr_gsakendmai.maides    = r_gsakendmai.maides
            let lr_gsakendmai.atldat    = today
            let lr_gsakendmai.atlhor    = current
            let lr_gsakendmai.atlmat    = g_issk.funmat
            let lr_gsakendmai.atlusrtip = g_issk.usrtip
            let lr_gsakendmai.atlemp    = g_issk.empcod

            if w_oper = "I" then
               let l_sqlcode = osgtk1001_incluirEmailSegurado( lr_gsakendmai.segnumdig
                                                              ,lr_gsakendmai.endfld
                                                              ,lr_gsakendmai.maides
                                                              ,lr_gsakendmai.atldat
                                                              ,lr_gsakendmai.atlhor
                                                              ,lr_gsakendmai.atlmat
                                                              ,lr_gsakendmai.atlusrtip
                                                              ,lr_gsakendmai.atlemp)
               if l_sqlcode = 0 then
                  error "E-mail incluido" sleep 1

                  call cty17g00_ssgtseg02_envia_atlz_mai(l_cabecalho
                                               ,lr_gsakendmai.maides)

               else
                  error "Erro, E-mail não incluído :" , l_sqlcode
                  sleep 1
		      if figrc072_checkGlbIsolamento(l_sqlcode
		                                    ,"ssgtseg02"
		                                    ,"ssgtemail"
		                                    ,"incluirmail"
		                                    ,"","","","","","")  then
		         exit input
		      end if
               end if
            else
               let l_alerta     = false

               if w_maides_old <> r_gsakendmai.maides then
                  call osgtk1001_alterarEmailSegurado( lr_gsakendmai.segnumdig
                                                      ,lr_gsakendmai.endfld
                                                      ,lr_gsakendmai.maides
                                                      ,lr_gsakendmai.atldat
                                                      ,lr_gsakendmai.atlhor
                                                      ,lr_gsakendmai.atlmat
                                                      ,lr_gsakendmai.atlusrtip
                                                      ,lr_gsakendmai.atlemp)
                      returning  l_sqlcode
                                ,l_sqlerrd
                     if l_sqlerrd <> 0 and
                        l_sqlcode  = 0 then
                        error "E-mail alterado" sleep 1

                        call cty17g00_ssgtseg02_envia_atlz_mai(l_cabecalho
                                                     ,lr_gsakendmai.maides)
                     else
                        error "Erro, E-mail não alterado :" , l_sqlcode
                        sleep 1
			      if figrc072_checkGlbIsolamento(l_sqlcode
			                                    ,"ssgtseg02"
			                                    ,"ssgtemail"
			                                    ,"alterarmail"
			                                    ,"","","","","","")  then
			         exit input
			      end if
                     end if
               end if
            end if

            exit input

     on key (F2)
            let w_resposta = "N"

            display "+-------------------------+" at 10,22
            display "|" at 11,22
            display "Confirma exclusao? <S/N>" at 11,23 attribute (reverse)
            display "+-------------------------+" at 12,22
            display "|" at 11,48

            prompt "" for char w_resposta

            if upshift(w_resposta) = "S"  then
               let l_sqlcode = osgtk1001_excluirEmailSegurado( w_segnumdig
                                                              ,'1'
                                                              ,l_opcao)

               let r_gsakendmai.maides = null

               display r_gsakendmai.maides to maides

               if l_sqlcode = 0 then
                 error "E-mail exluido"
               else
                 error "E-mail nao excluido, erro: " , l_sqlcode
		     if figrc072_checkGlbIsolamento(l_sqlcode
		                                   ,"ssgtseg02"
		                                   ,"ssgtemail"
		                                   ,"excluirmail"
		                                   ,"","","","","","")  then
		        exit input
		     end if
               end if
            else
               error "Exclusao cancelada"
            end  if

            exit input

     on key (f17,control-c,interrupt)
            let w_alerta_resp = "N"

            if l_msg_alteracao = true   and
               (g_issk.dptsgl = "ct24hs"  or
                g_issk.dptsgl = "desenv"  or
                g_issk.dptsgl = "tlprod"  or
                g_issk.dptsgl = "dsvatd") and
               w_segurado = 1 then
               call cty17g00_ssgtseg_confirma("E")
                    returning w_alerta_resp

               if upshift(w_alerta_resp) = "S"  then
                  whenever error continue
                  open cssgtseg057 using w_segnumdig
                  fetch cssgtseg057 into lr_gsakendmai.maides
                  whenever error stop
                  if sqlca.sqlcode <> 0 then
                     if sqlca.sqlcode = 100 then
                        let lr_gsakendmai.maides = null
                        let l_stt = false
                     else
                        rollback work
                        error 'Erro SELECT cssgtseg057 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
                        error 'SSGTSEG / ssgtemail() / ',w_segnumdig  sleep 2
                        let int_flag = true
                        exit input

			    if figrc072_checkGlbIsolamento(sqlca.sqlcode
			                                  ,"ssgtseg02"
			                                  ,"ssgtemail"
			                                  ,"cssgtseg057"
			                                  ,"","","","","","")  then
			       exit input
                            end if
                     end if
                  end if
                  if l_stt then
                     begin work
                     let lr_gsakendmai.segnumdig = w_segnumdig
                     let lr_gsakendmai.endfld    = '1'
                     let lr_gsakendmai.atldat    = today
                     let lr_gsakendmai.atlhor    = current
                     let lr_gsakendmai.atlmat    = g_issk.funmat
                     let lr_gsakendmai.atlusrtip = g_issk.usrtip
                     let lr_gsakendmai.atlemp    = g_issk.empcod
                     call osgtk1001_alterarEmailSegurado(  lr_gsakendmai.segnumdig
                                                          ,lr_gsakendmai.endfld
                                                          ,lr_gsakendmai.maides
                                                          ,lr_gsakendmai.atldat
                                                          ,lr_gsakendmai.atlhor
                                                          ,lr_gsakendmai.atlmat
                                                          ,lr_gsakendmai.atlusrtip
                                                          ,lr_gsakendmai.atlemp)
                         returning  l_sqlcode
                                   ,l_sqlerrd
                     let l_msg_alteracao = false

                     if l_sqlcode = 0 and
                        l_sqlerrd > 0 then
                        commit work


                        call cty17g00_ssgtseg02_envia_atlz_mai(l_cabecalho
                                                     ,lr_gsakendmai.maides)

                     else
                        if l_sqlcode < 0 or
                           (l_sqlcode = 0 and l_sqlerrd = 0) then
                           error "Erro ao alterar o email : " , l_sqlcode

      if figrc072_checkGlbIsolamento(l_sqlcode
                                    ,"ssgtseg02"
                                    ,"ssgtemail"
                                    ,"alterarmail"
                                    ,"","","","","","")  then
         exit input
      end if
                           rollback work
                        end if
                     end if
                  end if
                else
                  next field maides
               end if
            end if
            let int_flag = true
            exit input
   end input

   close window ssgtEMAIL

 end while

end function


#-------------------------------------
function cty17g00_ssgtseg_func(param)
#-------------------------------------

 define param  record
         atlemp    like gsaktel.atlemp
        ,atlmat    like gsaktel.atlmat
        ,atlusrtip like gsaktel.atlusrtip
 end record

 define ret_func record
        funnom     like isskfunc.funnom
       ,dptsgl     like isskfunc.dptsgl
 end record


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ret_func.*  to  null

 whenever error continue
 select funnom          , dptsgl
 into   ret_func.funnom , ret_func.dptsgl
 from   isskfunc
 where  funmat = param.atlmat
 and    empcod = param.atlemp
 and    usrtip = param.atlusrtip
 whenever error stop
 if sqlca.sqlcode < 0 then
    error " Erro na funcao ssgtseg_func : " , sqlca.sqlcode
    if figrc072_checkGlbIsolamento(sqlca.sqlcode
                                  ,"ssgtseg02"
                                  ,"ssgtseg_func"
                                  ,"selectfunc"
                                  ,"","","","","","")  then
         return ret_func.funnom, ret_func.dptsgl
      end if
 end if

return ret_func.funnom, ret_func.dptsgl

end function

#-----------------------------
function cty17g00_ssgtseg_alerta(param)
#-----------------------------

 define param        record
    cabtip           char (01),  ###  Tipo do Cabecalho
    linha1           char (40),
    linha2           char (40),
    linha3           char (40)
 end record

 define d_ssgtseg   record
    cabtxt           char (40),
    confirma         char (01)
 end record


 initialize  d_ssgtseg.*  to  null

 open window w_ssgtsegj at 09,19 with form "ssgtsegj"
           attribute(border, form line first, message line last - 1)

 case param.cabtip
    when "C"  let  d_ssgtseg.cabtxt = "CONFIRME"
    when "Q"  let  d_ssgtseg.cabtxt = "QUESTIONE O SEGURADO"
    when "A"  let  d_ssgtseg.cabtxt = "A T E N C A O"
 end case
 let d_ssgtseg.cabtxt = cty17g00_ssgtseg_center(d_ssgtseg.cabtxt)
 let param.linha1 = cty17g00_ssgtseg_center(param.linha1)
 let param.linha2 = cty17g00_ssgtseg_center(param.linha2)
 let param.linha3 = cty17g00_ssgtseg_center(param.linha3)
 display by name d_ssgtseg.cabtxt  attribute (reverse)
 display by name param.linha1 thru param.linha3
 message " (F17)Abandona"

 input by name d_ssgtseg.confirma without defaults
         after field confirma
            next field confirma

         on key (interrupt, control-c)
            exit input
 end input

 let int_flag = false

 close window w_ssgtsegj

end function

#-----------------------------
function cty17g00_ssgtseg_center(param)
#-----------------------------

 define param        record
    lintxt           char (40)
 end record

 define i            smallint
 define tamanho      dec (2,0)

 let     i  =  null
 let     tamanho  =  null

 let tamanho = (40 - length(param.lintxt))/2

 for i = 1 to tamanho
    let param.lintxt = " ", param.lintxt clipped
 end for

 return param.lintxt

end function

#--------------------------------#
function cty17g00_ssgtseg_confirma(p_param)
#--------------------------------#

  define l_resposta char(01)
        ,p_param    char(1)

  let l_resposta = null

  open window w_alt_mail at 20,30 with 1 rows,30 columns
     attribute (border, form line first )

   let l_resposta = "E"

   while l_resposta <> "S" and l_resposta <> "N"

      if p_param = "E" then
         prompt "Confirma E-mail ? <S/N> "  for l_resposta
      else
         prompt "Confirma Telefone ? <S/N> "  for l_resposta
      end if
      let l_resposta = upshift(l_resposta)

      if l_resposta is null or
         l_resposta = " " then
         let l_resposta = "E"
      end if

   end while

  close window w_alt_mail
  let int_flag = false

  return l_resposta

end function

#-------------------------------------------------------------------------#
function cty17g00_ssgtseg_atlz_usuario(l_segnumdig, l_atlemp, l_atlmat, l_atlusrtip)
#-------------------------------------------------------------------------#

  define l_segnumdig like gsaktel.segnumdig
        ,l_atlemp    like gsaktel.atlemp
        ,l_atlmat    like gsaktel.atlmat
        ,l_atlusrtip like gsaktel.atlusrtip

   define lr_gsaktel  record
           segnumdig  like  gsaktel.segnumdig
          ,segtelseq  like  gsaktel.segtelseq
          ,teltipcod  like  gsaktel.teltipcod
          ,telnum     like  gsaktel.telnum
          ,dddnum     like  gsaktel.dddnum
          ,telrmlnum  like  gsaktel.telrmlnum
          ,segtelobs  like  gsaktel.segtelobs
          ,atlemp     like  gsaktel.atlemp
          ,atlmat     like  gsaktel.atlmat
          ,atlusrtip  like  gsaktel.atlusrtip
          ,atldat     like  gsaktel.atldat
          ,atlhor     like  gsaktel.atlhor
                      end record
   define l_sqlcode integer
         ,l_sqlerrd integer
         ,l_stt     smallint

   initialize lr_gsaktel to null
   let l_sqlcode = null
   let l_sqlerrd = null
   let l_stt     = true

   whenever error continue
   open cssgtseg058 using l_segnumdig
   fetch cssgtseg058 into lr_gsaktel.segtelseq
                         ,lr_gsaktel.teltipcod
                         ,lr_gsaktel.telnum
                         ,lr_gsaktel.dddnum
                         ,lr_gsaktel.telrmlnum
                         ,lr_gsaktel.segtelobs
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let lr_gsaktel.segtelseq  = null
         let lr_gsaktel.teltipcod  = null
         let lr_gsaktel.telnum     = null
         let lr_gsaktel.dddnum     = null
         let lr_gsaktel.telrmlnum  = null
         let lr_gsaktel.segtelobs  = null
         let l_stt                 = false
      else
         error 'Erro SELECT cssgtseg058 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
         error 'SSGTSEG / ssgtseg_atlz_usuario() / ',l_segnumdig  sleep 2
			      if figrc072_checkGlbIsolamento(sqlca.sqlcode
			                                    ,"ssgtseg02"
			                                    ,"ssgtseg_atlz_usuario"
			                                    ,"cssgtseg058"
			                                    ,"","","","","","")  then
			         return
			      end if
         return
      end if
   end if
   if l_stt then
      let lr_gsaktel.segnumdig = l_segnumdig
      let lr_gsaktel.atlemp    = l_atlemp
      let lr_gsaktel.atlmat    = l_atlmat
      let lr_gsaktel.atlusrtip = l_atlusrtip
      let lr_gsaktel.atldat    = today
      let lr_gsaktel.atlhor    = current
      call osgtk1001_alterarTelefoneSegurado(  lr_gsaktel.segnumdig
                                              ,lr_gsaktel.segtelseq
                                              ,lr_gsaktel.teltipcod
                                              ,lr_gsaktel.telnum
                                              ,lr_gsaktel.dddnum
                                              ,lr_gsaktel.telrmlnum
                                              ,lr_gsaktel.segtelobs
                                              ,lr_gsaktel.atlemp
                                              ,lr_gsaktel.atlmat
                                              ,lr_gsaktel.atlusrtip
                                              ,lr_gsaktel.atldat
                                              ,lr_gsaktel.atlhor)
         returning l_sqlcode
                  ,l_sqlerrd

			      if figrc072_checkGlbIsolamento(l_sqlcode
			                                    ,"ssgtseg02"
			                                    ,"ssgtseg_atlz_usuario"
			                                    ,"alterartel"
			                                    ,"","","","","","")  then
			         return
			      end if
   end if
end function

#---------------------------#
function cty17g00_ssgtseg_busca_dias()
#---------------------------#

  # BUSCA QTD. DE DIAS DESDE A ULTIMA ATUALIZACAO DO E-MAIL DO SEGURADO

  define l_grlinf like datkgeral.grlinf

  let l_grlinf = null

  if m_prep_sql is null or
     m_prep_sql <> true then
     call figrc072_initGlbIsolamento()
     call cty17g00_ssgtseg_prepara()
  end if

  if m_prep_sql = false then
     return l_grlinf
  end if


  whenever error continue
  open c_cty17g00_003
  fetch c_cty17g00_003 into l_grlinf
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_grlinf = null
     if sqlca.sqlcode = notfound then
        error "Nao encontrou qtde dias parametro(ssgtseg). AVISE A INFORMATICA!" sleep 5
     else
        error "Erro SELECT c_cty17g00_003 /", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
        error "ssgtseg_busca_dias() " sleep 3

		      if figrc072_checkGlbIsolamento(sqlca.sqlcode
		                                    ,"ssgtseg02"
		                                    ,"ssgtseg_busca_dias"
		                                    ,"cssgtseg041"
		                                    ,"","","","","","")  then

		         return l_grlinf
		      end if
     end if
  end if

  close c_cty17g00_003

  return l_grlinf

end function


#------------------------------------------------------------------------------
function cty17g00_ssgtseg02_cabecalho_xml(l_segnumdig)
#------------------------------------------------------------------------------

define l_segnumdig  like gsakseg.segnumdig
      ,l_cabecalho  char(1000)
      ,l_sqlcode    integer



let l_sqlcode = osgtk1001_pesquisarSeguradoPorCodigo(l_segnumdig)

if l_sqlcode = 0 then
	  let l_cabecalho =
	    "<?xml version='1.0' encoding='UTF-8' ?><mq>"
    ,"<servico>atulizardadoscadatraisclienteunificado</servico>"
    ,"<chave>"
       ,"<sisorgcod>1</sisorgcod>"
       ,"<cgccpfnum>"     ,g_r_gsakseg.cgccpfnum     ,"</cgccpfnum>"
       ,"<cgcord>"        ,g_r_gsakseg.cgcord        ,"</cgcord>"
       ,"<cgccpfdig>"     ,g_r_gsakseg.cgccpfdig     ,"</cgccpfdig>"
    ,"</chave>"
end if

return l_sqlcode
      ,l_cabecalho

end function

#------------------------------------------------------------------------------
function cty17g00_ssgtseg02_envia_atlz_tel(l_cabecalho
                                 ,l_teltipcod
                                 ,l_telnum
                                 ,l_dddnum)
#------------------------------------------------------------------------------

define l_cabecalho   char(1000)
      ,l_teltipcod   like gsaktel.teltipcod
      ,l_telnum      like gsaktel.telnum
      ,l_dddnum      like gsaktel.dddnum

      ,l_xml         char(32000)
      ,l_retorno     integer
let l_xml = null
let l_retorno = 0

let l_teltipcod = cty17g00_ssgtseg02_depara_tipotel(l_teltipcod)

let l_xml = l_cabecalho clipped
           ,"<telefones>"
             ,"<telefone>"
                 ,"<pesteltip>"  ,l_teltipcod  ,"</pesteltip>"
                 ,"<dddnum>"     ,l_dddnum     ,"</dddnum>"
                 ,"<telnum>"     ,l_telnum     ,"</telnum>"
                 ,"<optintel>N</optintel>"
             ,"</telefone>"
           ,"</telefones>"
           ,"</mq>"

let l_retorno = osgtf662_enviaxml_datagrama("GCLCLIENTUNIJAVA01D",l_xml)

end function


#------------------------------------------------------------------------------
function cty17g00_ssgtseg02_envia_atlz_mai(l_cabecalho
                                 ,l_maides)
#------------------------------------------------------------------------------

define l_cabecalho   char(1000)
      ,l_maides      like gsakendmai.maides

      ,l_xml         char(32000)
      ,l_retorno     integer
let l_xml = null
let l_retorno = 0

let l_xml = l_cabecalho clipped
             ,"<email>"
                 ,"<pesmaitip>1</pesmaitip>"
                 ,"<maides>"     ,l_maides clipped  ,"</maides>"
                 ,"<optinmail>N</optinmail>"
             ,"</email>"
           ,"</mq>"

let l_retorno = osgtf662_enviaxml_datagrama("GCLCLIENTUNIJAVA01D",l_xml)

end function

#------------------------------------------------------------------------------
function cty17g00_ssgtseg02_depara_tipotel(l_teltip)
#------------------------------------------------------------------------------

define l_teltip     integer
      ,l_retorno    integer

let l_retorno = 4

case l_teltip
   when 1
      let l_retorno = 4
   when 2
      let l_retorno = 3

   when 3
      let l_retorno = 1

   when 4
      let l_retorno = 4

   when 5
      let l_retorno = 4

   when 6
      let l_retorno = 4

   when 7
      let l_retorno = 4

   when 8
      let l_retorno = 4
   when 9
      let l_retorno = 4

   when 10
      let l_retorno = 4

   when 11
      let l_retorno = 2

end case

return l_retorno

end function
#------------------------------------------------------------------------------
function cty17g00_ssgtseg02_ct24h_email(lr_param)
#------------------------------------------------------------------------------

define lr_param record
  segnumdig like gsakseg.segnumdig
end record
define lr_retorno record
  segnumdig like gsakendmai.segnumdig  ,
  endfld    like gsakendmai.endfld     ,
  maides    like gsakendmai.maides     ,
  atlemp    like gsakendmai.atlemp     ,
  atlmat    like gsakendmai.atlmat     ,
  atldat    like gsakendmai.atldat     ,
  atlhor    like gsakendmai.atlhor     ,
  atlusrtip like gsakendmai.atlusrtip  ,
  grlinf    dec(5,0)                   ,
  erro      smallint
end record

call figrc072_initGlbIsolamento()
call cty17g00_ssgtseg_prepara()


    initialize lr_retorno.* to null
    let lr_retorno.erro = 1
    if (g_issk.dptsgl = "ct24hs"  or
        g_issk.dptsgl = "dsvatd"  or
        g_issk.dptsgl = "tlprod"  or
        g_issk.dptsgl = "desenv") then
         whenever error continue
         open  c_cty17g00_004 using lr_param.segnumdig
         fetch c_cty17g00_004 into  lr_retorno.segnumdig
                                ,lr_retorno.endfld
                                ,lr_retorno.maides
                                ,lr_retorno.atlemp
                                ,lr_retorno.atlmat
                                ,lr_retorno.atldat
                                ,lr_retorno.atlhor
                                ,lr_retorno.atlusrtip
         whenever error stop
         if sqlca.sqlcode < 0 then
            display " Erro no cursor cssgtseg042: " , sqlca.sqlcode
            error   " Erro no cursor cssgtseg042: " , sqlca.sqlcode
            if figrc072_checkGlbIsolamento(sqlca.sqlcode
                                          ,"ssgtseg02"
                                          ,"ssgtemail"
                                          ,"cssgtseg042"
                                          ,"","","","","","")  then
               let lr_retorno.erro = 1
            end if
         else
               -- Busca dias de atualizacao do e-mail do segurado
               let lr_retorno.grlinf = cty17g00_ssgtseg_busca_dias()
               if lr_retorno.atldat is null then
                  let lr_retorno.atldat = (today - lr_retorno.grlinf) - 5
               end if
               if (( today - lr_retorno.atldat ) > lr_retorno.grlinf) then
                  let lr_retorno.erro = 0
               else
                  let lr_retorno.erro = 1
               end if
         end if
         close c_cty17g00_004
    end if
    if lr_retorno.erro = 0 then
       return true
    else
       return false
    end if
end function

#------------------------------------------------------------------------------
function cty17g00_ssgtseg02_ct24h_rec_email(lr_param)
#------------------------------------------------------------------------------
define lr_param record
  segnumdig like gsakseg.segnumdig
end record
define lr_retorno record
  segnumdig like gsakendmai.segnumdig  ,
  endfld    like gsakendmai.endfld     ,
  maides    like gsakendmai.maides     ,
  atlemp    like gsakendmai.atlemp     ,
  atlmat    like gsakendmai.atlmat     ,
  atldat    like gsakendmai.atldat     ,
  atlhor    like gsakendmai.atlhor     ,
  atlusrtip like gsakendmai.atlusrtip
end record
call figrc072_initGlbIsolamento()
call cty17g00_ssgtseg_prepara()
    initialize lr_retorno.* to null
    if (g_issk.dptsgl = "ct24hs"  or
        g_issk.dptsgl = "dsvatd"  or
        g_issk.dptsgl = "tlprod"  or
        g_issk.dptsgl = "desenv") then
         whenever error continue
         open  c_cty17g00_004 using lr_param.segnumdig
         fetch c_cty17g00_004 into  lr_retorno.segnumdig
                                ,lr_retorno.endfld
                                ,lr_retorno.maides
                                ,lr_retorno.atlemp
                                ,lr_retorno.atlmat
                                ,lr_retorno.atldat
                                ,lr_retorno.atlhor
                                ,lr_retorno.atlusrtip
         whenever error stop
         if sqlca.sqlcode < 0 then
            display " Erro no cursor cssgtseg042: " , sqlca.sqlcode
            error   " Erro no cursor cssgtseg042: " , sqlca.sqlcode
            if figrc072_checkGlbIsolamento(sqlca.sqlcode
                                          ,"ssgtseg02"
                                          ,"ssgtemail"
                                          ,"cssgtseg042"
                                          ,"","","","","","")  then
            end if
         end if
         close c_cty17g00_004
    end if
    return lr_retorno.maides
end function

#-----------------------------------------
function cty17g00_email()
#-----------------------------------------

define lr_retorno  record
  maides      like gsakendmai.maides ,
  ok          char(1)                ,
  confirma    char(1)
end record


 initialize lr_retorno.* to null


   open window cty17g00b  at 10,7 with form "cty17g00b"
        attribute (border,form line 1)

   input by name lr_retorno.maides without defaults

     before field maides
        display by name lr_retorno.maides attribute (reverse)



     after  field maides
        display by name lr_retorno.maides

            let lr_retorno.ok = "n"

            call cty17g00_ssgtmail(lr_retorno.maides)
                 returning lr_retorno.ok

            if downshift(lr_retorno.ok) = "n" then
               error "E-mail Invalido."
               next field maides
            end if

            if lr_retorno.maides is not null then

                 let lr_retorno.confirma = cts08g01('C','S','','CONFIRMA INCLUSAO DO E-MAIL' ,'','')

               if upshift(lr_retorno.confirma) <> "S"  then
                  continue input
               end if

            end if


     on key (f17,control-c,interrupt)

            if lr_retorno.maides is null then

               let lr_retorno.confirma = cts08g01('C','S','', 'E-MAIL NAO INCLUSO' ,'DESEJA SAIR SEM INCLUIR?','')

               if lr_retorno.confirma = "N" then
                  next field maides
               end if

            end if

            let int_flag = true
            exit input

   end input

   close window cty17g00b

   return lr_retorno.maides

end function
