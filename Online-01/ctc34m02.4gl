 #############################################################################
 # Nome do Modulo: ctc34m02                                         Marcelo  #
 #                                                                  Gilberto #
 # Observacoes sobre a situacao do veiculo (bloqueado/cancelado)    Ago/1998 #
 #############################################################################
 # Alteracoes:                                                               #
 #                                                                           #
 # DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
 #---------------------------------------------------------------------------#
 # 06/06/2001  PSI 13253-5  Wagner       Inclusao nova situacao prestador    #
 #                                       B-Bloqueado.                        #
 #---------------------------------------------------------------------------#
 # 06/08/2008 PSI226300     Diomar, Meta Incluido gravacao do historico      #
 #############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

  define m_ctc34m02_prep smallint

#-------------------------#
function ctc34m02_prepare()
#-------------------------#

  define l_sql char(300)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " select vstpbmcod, ",
                     " vstsitdat ",
                " from dpakvst ",
               " where socvclcod = ? ",
               " order by vstsitdat desc "

  prepare pctc34m02001 from l_sql
  declare cctc34m02001 cursor for pctc34m02001

  let m_ctc34m02_prep = true

end function

#-----------------------------------------------------------
 function ctc34m02(param)
#-----------------------------------------------------------

 define param         record
    socvclcod         like datkvclsit.socvclcod,
    atdvclsgl         like datkveiculo.atdvclsgl,
    vcldes            char (58)
 end record

 define d_ctc34m02    record
    socoprsitcod      like datkveiculo.socoprsitcod,
    socoprsitcoddes   char (09),
    obs1              char (50),
    obs2              char (50),
    obs3              char (50),
    caddat            like datkvclsit.caddat,
    cadhor            like datkvclsit.cadhor,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvclsit.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    socoprsitcod      like datkveiculo.socoprsitcod,
    pstcoddig         like datkveiculo.pstcoddig,
    socctrposflg      like datkveiculo.socctrposflg,
    socvclsitdes      like datkvclsit.socvclsitdes,
    prssitcod         like dpaksocor.prssitcod,
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat,
    achousit          char (01),
    confirma          char (01)
 end record
 
 define lr_ctc34m02_ant            record
    socoprsitcod         like datkveiculo.socoprsitcod,
    socoprsitcoddes      char (09),
    socvclsitdes         like datkvclsit.socvclsitdes
 end record

 define l_vstpbmcod   like dpakvst.vstpbmcod
 define l_vstsitdat   like dpakvst.vstsitdat
 define l_nulo        char(01)
       ,l_mensagem    char(100)
       ,l_mensagem2   char(3000)
       ,l_stt         smallint

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_vstpbmcod  = null
        let     l_vstsitdat  = null
        let     l_nulo       = null
        let     l_mensagem   = null
        let     l_mensagem2  = null
        let     l_stt        = null
        
#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  d_ctc34m02.*  to  null

        initialize  ws.*  to  null

 if m_ctc34m02_prep is null or
    m_ctc34m02_prep <> true then
    call ctc34m02_prepare()
 end if

 initialize ws.*         to null
 initialize d_ctc34m02   to null
 let int_flag = false
 let l_vstpbmcod = null
 let l_vstsitdat = null

 if param.socvclcod  is null   then
    error " Codigo do veiculo nao informado, AVISE INFORMATICA!"
    return
 end if

 if not get_niv_mod(g_issk.prgsgl, "ctc34m02") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

#---------------------------------------------------------
# Ler dados sobre veiculo/situacao
#---------------------------------------------------------
 select datkveiculo.socoprsitcod,
        datkveiculo.pstcoddig,
        datkveiculo.socctrposflg,
        datkvclsit.caddat,
        datkvclsit.cadhor,
        datkvclsit.cademp,
        datkvclsit.cadmat,
        datkvclsit.atldat,
        datkvclsit.atlemp,
        datkvclsit.atlmat,
        datkvclsit.socvclsitdes
   into d_ctc34m02.socoprsitcod,
        ws.pstcoddig,
        ws.socctrposflg,
        d_ctc34m02.caddat,
        d_ctc34m02.cadhor,
        ws.cademp,
        ws.cadmat,
        d_ctc34m02.atldat,
        ws.atlemp,
        ws.atlmat,
        ws.socvclsitdes
   from datkveiculo, outer datkvclsit
  where datkveiculo.socvclcod =  param.socvclcod
    and datkvclsit.socvclcod  =  datkveiculo.socvclcod

 let ws.achousit = "N"

 if sqlca.sqlcode  <>  0   then
    error " Veiculo nao encontrado, AVISE INFORMATICA!"
    return
 end if
 
 initialize lr_ctc34m02_ant.* to null

  
 select cpodes
   into d_ctc34m02.socoprsitcoddes
   from iddkdominio
  where iddkdominio.cponom  =  "socoprsitcod"
    and iddkdominio.cpocod  =  d_ctc34m02.socoprsitcod

 if d_ctc34m02.socoprsitcod  <>  1   then
    let ws.achousit = "S"

    let d_ctc34m02.obs1 = ws.socvclsitdes[001,050]
    let d_ctc34m02.obs2 = ws.socvclsitdes[051,100]
    let d_ctc34m02.obs3 = ws.socvclsitdes[101,150]

    call ctc34m02_func(ws.cademp, ws.cadmat)
     returning d_ctc34m02.cadfunnom

    call ctc34m02_func(ws.atlemp, ws.atlmat)
         returning d_ctc34m02.funnom
 else
    error " Nao existem observacoes sobre situacao do veiculo!"
 end if
  
 let lr_ctc34m02_ant.socoprsitcod    = d_ctc34m02.socoprsitcod
 let lr_ctc34m02_ant.socvclsitdes    = ws.socvclsitdes 
 let lr_ctc34m02_ant.socoprsitcoddes = d_ctc34m02.socoprsitcoddes

#---------------------------------------------------------
# Exibe tela para consulta/modificacao
#---------------------------------------------------------
 open window ctc34m02 at 6,2 with form "ctc34m02"
      attribute(form line first)

 display by name param.socvclcod  attribute(reverse)
 display by name param.atdvclsgl  attribute(reverse)
 display by name param.vcldes     attribute(reverse)

 display by name d_ctc34m02.*

 input by name d_ctc34m02.socoprsitcod,
               d_ctc34m02.obs1,
               d_ctc34m02.obs2,
               d_ctc34m02.obs3  without defaults

    before field socoprsitcod
           display by name d_ctc34m02.socoprsitcod  attribute(reverse)

    after  field socoprsitcod
           display by name d_ctc34m02.socoprsitcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socoprsitcod
           end if

           if g_issk.acsnivcod  <  g_issk.acsnivatl   then
              error " Nivel de acesso nao permite atualizacao!"
              next field socoprsitcod
           end if

           if d_ctc34m02.socoprsitcod  is null   then
              error " Codigo da situacao deve ser informado!"
              call ctn36c00("Situacao do veiculo", "socoprsitcod")
                   returning  d_ctc34m02.socoprsitcod
              next field socoprsitcod
           end if

           select cpodes
             into d_ctc34m02.socoprsitcoddes
             from iddkdominio
            where iddkdominio.cponom  =  "socoprsitcod"
              and iddkdominio.cpocod  =  d_ctc34m02.socoprsitcod

           if sqlca.sqlcode  <>  0   then
              error " Situacao nao cadastrada!"
              call ctn36c00("Situacao do veiculo", "socoprsitcod")
                   returning  d_ctc34m02.socoprsitcod
              next field socoprsitcod
           end if
           display by name d_ctc34m02.socoprsitcoddes

           initialize ws.socoprsitcod  to null
           select socoprsitcod
             into ws.socoprsitcod
             from datkveiculo
            where datkveiculo.socvclcod  =  param.socvclcod

           if sqlca.sqlcode  <>  0   then
              error " Veiculo nao encontrado, AVISE INFORMATICA!"
              next field socoprsitcod
           end if

           if d_ctc34m02.socoprsitcod  =  1   and
              ws.socoprsitcod          =  1   then
             error " Observacoes somente para situacao: bloqueado ou cancelado!"
              next field socoprsitcod
           end if

           if d_ctc34m02.socoprsitcod  =  3    and
              ws.socctrposflg          = "S"   then
             error " Antes de cancelar, retire o veiculo do controle do radio!"
              next field socoprsitcod
           end if

           initialize ws.prssitcod  to null
           select prssitcod
             into ws.prssitcod
             from dpaksocor
            where dpaksocor.pstcoddig  =  ws.pstcoddig

           if ws.prssitcod  <>  "A" then
              case ws.prssitcod
                 when "C" error " Prestador cancelado, nao e' possivel alterar situacao do veiculo!"
                 when "P" error " Prestador em proposta, nao e' possivel alterar situacao do veiculo!"
                 when "B" error " Prestador bloqueado, nao e' possivel alterar situacao do veiculo!"
              end case
              next field socoprsitcod
           end if

           if d_ctc34m02.socoprsitcod  =  1   then   #--> Ativo

              if ws.socctrposflg  =  "S"   then
                 call cts08g01("C","S",
                                   "                                        ",
                                   "VEICULO VOLTARA' A SER EXIBIDO NA TELA  ",
                                   "DE POSICAO DA FROTA (RADIO)             ",
                                   "                                        ")
                 returning ws.confirma

                 if ws.confirma  =  "N"   then
                    next field socoprsitcod
                 end if
              end if

              initialize d_ctc34m02.obs1   to null
              display by name d_ctc34m02.obs1
              initialize d_ctc34m02.obs2   to null
              display by name d_ctc34m02.obs2
              initialize d_ctc34m02.obs3   to null
              display by name d_ctc34m02.obs3

              exit input
           end if

           if ws.socctrposflg  =  "S"   and
              ws.socoprsitcod  =   1    then
              call cts08g01("C","S","                                        ",
                                    "VEICULO SERA' COLOCADO AUTOMATICAMENTE  ",
                                    "EM (QTP) E (NAO) SERA' EXIBIDO NA TELA  ",
                                    "DE POSICAO DA FROTA (RADIO)             ")
              returning ws.confirma

              if ws.confirma  =  "N"   then
                 next field socoprsitcod
              end if
           end if

    before field obs1
        display by name d_ctc34m02.obs1 attribute (reverse)

    after  field obs1
        display by name d_ctc34m02.obs1

        if d_ctc34m02.obs1  is null   then
           error " Observacoes sobre a situacao devem ser informadas!"
           next field obs1
        end if

    before field obs2
        display by name d_ctc34m02.obs2 attribute (reverse)

    after  field obs2
        display by name d_ctc34m02.obs2

    before field obs3
        display by name d_ctc34m02.obs3 attribute (reverse)

    after  field obs3
        display by name d_ctc34m02.obs3

        if d_ctc34m02.obs3  is not null   and
           d_ctc34m02.obs2  is null       then
           error " Nao devem existir linha(s) anterior(es) sem conteudo!"
           next field obs3
        end if

    on key (interrupt)
        exit input

 end input

 if not int_flag   then
    #---------------------------------------------------------
    # Atualiza dados nas tabelas de veiculo/situacao
    #---------------------------------------------------------
    let ws.socvclsitdes = d_ctc34m02.obs1,
                          d_ctc34m02.obs2,
                          d_ctc34m02.obs3
    let l_mensagem  = "Alteracao no  cadastro do veiculo.Codigo = " clipped,
                      param.socvclcod clipped
    let l_mensagem2 = null
        
    begin work

      update datkveiculo  set socoprsitcod = d_ctc34m02.socoprsitcod
       where datkveiculo.socvclcod  =  param.socvclcod
  
      if lr_ctc34m02_ant.socoprsitcod <> d_ctc34m02.socoprsitcod then
    
          let l_mensagem2 = "Situacao do Veiculo alterado de [",lr_ctc34m02_ant.socoprsitcod clipped,
              "-",lr_ctc34m02_ant.socoprsitcoddes clipped,"] para [",d_ctc34m02.socoprsitcod clipped,
              "-",d_ctc34m02.socoprsitcoddes clipped,"] "
      end if
    
      if d_ctc34m02.socoprsitcod  =  1   then
         delete
           from datkvclsit
          where datkvclsit.socvclcod  = param.socvclcod
         
         let l_mensagem2 = l_mensagem2 clipped, " Observacoes do Veiculo [",param.socvclcod,"] Excluido !" clipped
         
         call ctc34m02_desbloqueia_vcl(param.socvclcod)
         
       else

         #---------------------------------------------------------
         # Grava registro para bloqueio/cancelamento
         #---------------------------------------------------------
         if ws.achousit  =  "N"   then
            insert  into datkvclsit  ( socvclcod,
                                       socvclsitdes,
                                       caddat,
                                       cadhor,
                                       cademp,
                                       cadmat,
                                       atldat,
                                       atlemp,
                                       atlmat )
                         values
                                     ( param.socvclcod,
                                       ws.socvclsitdes,
                                       today,
                                       current hour to minute,
                                       g_issk.empcod,
                                       g_issk.funmat,
                                       today,
                                       g_issk.empcod,
                                       g_issk.funmat )

            let l_mensagem2 = l_mensagem2 clipped," Observacoes do Veiculo [",param.socvclcod clipped,"] incluido !" clipped

            #---------------------------------------------------------
            # Coloca o veiculo em QTP
            #---------------------------------------------------------
            let l_nulo = null

            update dattfrotalocal set
                   (mdtmvtdircod,
                    mdtmvtvlc,
                    atdsrvnum,
                    atdsrvano,
                    cttdat,
                    ctthor,
                    srrcoddig,
                    c24atvcod,
                    atdvclpriflg) = (l_nulo,
                                     l_nulo,
                                     l_nulo,
                                     l_nulo,
                                     l_nulo,
                                     l_nulo,
                                     l_nulo,
                                     "QTP",
                                     "N")
             where socvclcod = param.socvclcod

            update datmfrtpos set
                   (ufdcod,
                    cidnom,
                    brrnom,
                    endzon,
                    lclltt,
                    lcllgt,
                    atldat,
                    atlhor) = (l_nulo,
                               l_nulo,
                               l_nulo,
                               l_nulo,
                               l_nulo,
                               l_nulo,
                               today,
                               current hour to minute)
             where socvclcod =  param.socvclcod
               and socvcllcltip  in (1,2,3)
         else
            #---------------------------------------------------------
            # Troca situacao do veiculo
            #---------------------------------------------------------
            update datkvclsit  set   ( socvclsitdes,
                                       atldat,
                                       atlemp,
                                       atlmat )
                                =
                                     ( ws.socvclsitdes,
                                       today,
                                       g_issk.empcod,
                                       g_issk.funmat )
             where datkvclsit.socvclcod  =  param.socvclcod
                                                                                              
             if lr_ctc34m02_ant.socvclsitdes <> ws.socvclsitdes then      
           
                let l_mensagem2 = l_mensagem2 clipped, " Observacao da Situacao do Veiculo alterado de [",
                   lr_ctc34m02_ant.socvclsitdes clipped,"] para [",ws.socvclsitdes clipped,"]"
                
             end if                               
         end if

      end if
      
      let l_stt = ctc34m02_grava_hist(param.socvclcod
                                      ,l_mensagem
                                      ,today
                                      ,l_mensagem2 clipped)
    commit work
 end if

 close window ctc34m02
 let int_flag = false

end function  ###  ctc34m02

#---------------------------------------------------------
 function ctc34m02_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

 if m_ctc34m02_prep is null or
    m_ctc34m02_prep <> true then
    call ctc34m02_prepare()
 end if

 initialize ws.*    to null

 select funnom
   into ws.funnom
   from isskfunc
  where isskfunc.empcod = param.empcod
    and isskfunc.funmat = param.funmat

 return ws.funnom

 end function   # ctc34m02_func


#------------------------------------------------
function ctc34m02_grava_hist(lr_param,l_mensagem)
#------------------------------------------------

   define lr_param record
          socvclcod  like datrvclasi.socvclcod
         ,mensagem   char(100)
         ,data       date
          end record

   define lr_retorno record
                     stt smallint
                    ,msg char(50)
          end record

   define l_mensagem  char(3000)
         ,l_stt       smallint
         ,l_erro      smallint
         ,l_prshstdes2  char(3000)
	 ,l_count
         ,l_iter
         ,l_length
         ,l_length2    smallint
         ,l_opcao     char(1)

   let l_stt  = true

   initialize lr_retorno to null

   let l_length = length(l_mensagem clipped)
   if  l_length mod 70 = 0 then
       let l_iter = l_length / 70
   else
       let l_iter = l_length / 70 + 1
   end if

   let l_length2     = 0
   let l_erro        = 0
   
   for l_count = 1 to l_iter
       if  l_count = l_iter then
           let l_prshstdes2 = l_mensagem[l_length2 + 1, l_length]
       else
           let l_length2 = l_length2 + 70
           let l_prshstdes2 = l_mensagem[l_length2 - 69, l_length2]
       end if
       
      call ctb85g01_grava_hist(1
                           ,lr_param.socvclcod
                           ,l_prshstdes2
                           ,lr_param.data
                           ,g_issk.empcod
                           ,g_issk.funmat
                           ,g_issk.usrtip)
      returning lr_retorno.stt
               ,lr_retorno.msg

   end for
   
   if lr_retorno.stt = 0 then
   
      call ctb85g01_mtcorpo_email_html('CTC34M01',
		                       lr_param.data,
		                       current hour to minute,
		                       g_issk.empcod,
		                       g_issk.usrtip,
		                       g_issk.funmat,
		                       lr_param.mensagem,
		                       l_mensagem)
		returning l_erro

      if l_erro  <> 0 then
         error 'Erro no envio do e-mail' sleep 2
         let l_stt = false
      else
         let l_stt = true
      end if
   else
      error 'Erro na gravacao do historico',lr_retorno.stt,'-',lr_retorno.msg sleep 2
      let l_stt = false
   end if

   return l_stt

end function

#----------------------------------------#
 function ctc34m02_desbloqueia_vcl(param)
#----------------------------------------#
 
     define param record
            socvclcod like datkveiculo.socvclcod
     end record
     
     define lr_aux record
         maxevtseq smallint,
         titulo    char(100),        
         mensagem  char(300),
         erro      smallint
     end record
     
     select max(evtseq)  
       into lr_aux.maxevtseq
       from datmvstsemvcl
      where evttip    = 1
        and socvclcod = param.socvclcod
     
     if  sqlca.sqlcode = 0 and lr_aux.maxevtseq is not null then

         update datmvstsemvcl  
            set evttip = 2
          where socvclcod = param.socvclcod  
            and evtseq    = lr_aux.maxevtseq     
         
         if  sqlca.sqlcode = 0 then
         
             let lr_aux.titulo = 'DESBLOQUEIO DE VEICULO ', param.socvclcod using '<<<<&',
                                 ' NAO CONFORMIDADE COM A VISTORIA'         
         
             let lr_aux.mensagem = 'VEICULO COM PENDENCIAS NA VISTORIA LIBERADO'       
         
             call ctc34m02_grava_hist(param.socvclcod
                        ,lr_aux.titulo
                        ,today
                        ,lr_aux.mensagem)
               returning lr_aux.erro
         
         end if
     end if
     
 end function
