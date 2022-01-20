#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Ct24h                                                      #
# Modulo         : ctg20.4gl                                                  #
# Analista Resp. : Roberto Melo                                               #
# Psi            : 221830                                                     #
#.............................................................................#
# Desenvolvimento: Meta - Amilton                                             #
# Liberacao      :  /  /2008                                                  #
# Objetivo : Localizar doctos Azul Seguros                                    #
#.............................................................................#
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 18/10/2008 Carla Rampazzo  PSI 230650 Passar p/ "ctg18" o campo atdnum      #
#-----------------------------------------------------------------------------#
# 18/03/2010 Carla Rampazzo  PSI 219444 Passar p/ "ctg18" os campos           #
#                                       lclnumseq / rmerscseq (RE)            #
#-----------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/glct.4gl"

 define w_log     char(60)



 define m_prep_sql      smallint


MAIN
   define w_data    date
   define w_ret     integer
   define w_param   char(100)
   define w_apoio   char(01)
   define w_empcodatd like isskfunc.empcod
   define w_funmatatd like isskfunc.funmat
   define w_usrtipatd like isskfunc.usrtip
   -----------------------------------------------------------------------



   define l_demanda  char(15),
          l_contingencia  smallint

   define lr_documento  record
         succod        like datrligapol.succod,      # Codigo Sucursal
         aplnumdig     like datrligapol.aplnumdig,   # Numero Apolice
         itmnumdig     like datrligapol.itmnumdig,   # Numero do Item
         edsnumref     like datrligapol.edsnumref,   # Numero do Endosso
         prporg        like datrligprp.prporg,       # Origem da Proposta
         prpnumdig     like datrligprp.prpnumdig,    # Numero da Proposta
         fcapacorg     like datrligpac.fcapacorg,    # Origem PAC
         fcapacnum     like datrligpac.fcapacnum,    # Numero PAC
         pcacarnum     like eccmpti.pcapticod,       # No. Cartao PortoCard
         pcaprpitm     like epcmitem.pcaprpitm,      # Item (Veiculo) PortoCard
         solnom        char (15),                    # Solicitante
         soltip        char (01),                    # Tipo Solicitante
         c24soltipcod  like datmligacao.c24soltipcod,# Tipo do Solicitante
         ramcod        like datrservapol.ramcod,     # Codigo Ramo
         lignum        like datmligacao.lignum,      # Numero da Ligacao
         c24astcod     like datkassunto.c24astcod,   # Assunto da Ligacao
         ligcvntip     like datmligacao.ligcvntip,   # Convenio Operacional
         atdsrvnum     like datmservico.atdsrvnum,   # Numero do Servico
         atdsrvano     like datmservico.atdsrvano,   # Ano do Servico
         sinramcod     like ssamsin.ramcod,          # Prd Parcial-Ramo sinistro
         sinano        like ssamsin.sinano,          # Prd Parcial-Ano sinistro
         sinnum        like ssamsin.sinnum,          # Prd Parcial-Num sinistro
         sinitmseq     like ssamitem.sinitmseq,      # Prd Parcial-Itemp/ramo 53
         acao          char (03),                    # ALT, REC ou CAN
         atdsrvorg     like datksrvtip.atdsrvorg,    # Origem do tipo de Servico
         cndslcflg     like datkassunto.cndslcflg,   # Flag solicita condutor
         lclnumseq     like rsdmlocal.lclnumseq,     # Local de Risco
         vstnumdig     like datmvistoria.vstnumdig,  # numero da vistoria
         flgIS096      char (01)                  ,  # flag cobertura claus.096
         flgtransp     char (01)                  ,  # flag averbacao transporte
         apoio         char (01)                  ,  # flag atend.peloapoio(S/N)
         empcodatd     like datmligatd.apoemp     ,  # empresa do atendente
         funmatatd     like datmligatd.apomat     ,  # matricula do atendente
         usrtipatd     like datmligatd.apotip     ,  # tipo do atendente
         corsus        like gcaksusep.corsus      ,  # psi172413 eduardo - meta
         dddcod        like datmreclam.dddcod     ,  # cod da area de discagem
         ctttel        like datmreclam.ctttel     ,  # numero do telefone
         funmat        like isskfunc.funmat       ,  # matricula do funcionario
         cgccpfnum     like gsakseg.cgccpfnum     ,  # numero do CGC(CNPJ)
         cgcord        like gsakseg.cgcord        ,  # filial do CGC(CNPJ)
         cgccpfdig     like gsakseg.cgccpfdig     ,  # digito do CGC(CNPJ) ou CPF /fim psi172413 eduardo - meta
         atdprscod     like datmservico.atdprscod ,
         atdvclsgl     like datkveiculo.atdvclsgl ,
         srrcoddig     like datmservico.srrcoddig ,
         socvclcod     like datkveiculo.socvclcod ,
         dstqtd        dec(8,4)                   ,
         prvcalc       interval hour(2) to minute ,
         lclltt        like datmlcl.lclltt        ,
         lcllgt        like datmlcl.lcllgt        ,
         rcuccsmtvcod  like datrligrcuccsmtv.rcuccsmtvcod, ## Codigo do Motivo
         c24paxnum     like datmligacao.c24paxnum ,        # Numero da P.A.
         averbacao     like datrligtrpavb.trpavbnum,       # PSI183431 Daniel
         crtsaunum     like datksegsau.crtsaunum,
         bnfnum        like datksegsau.bnfnum,
         ramgrpcod     like gtakram.ramgrpcod
  end record





   define l_parm          record
          atdprscod       like datmservico.atdprscod,
          atdvclsgl       like datkveiculo.atdvclsgl,
          srrcoddig       like dattfrotalocal.srrcoddig,
          socvclcod       like dattfrotalocal.socvclcod,
          prvcalc         char(06),
          dstqtd          dec(8,4),
          flag_cts00m02   dec(1,0)
   end record



 define l_grlinf    like igbkgeral.grlinf
       ,l_resultado smallint
       ,l_mensagem  char(60)

 define l_flag_acesso smallint,
        l_doc_handle   integer,
        l_flag        smallint,
        l_aux         char(05)

 define l_texto  char(100)

 let l_grlinf    = null
 let l_resultado = null
 let l_mensagem  = null
 let l_texto     = null
 let l_contingencia = null
 let g_senha_cnt = null
  let l_doc_handle   = null

   initialize g_c24paxnum   to null
   initialize g_documento.* to null
   initialize lr_documento.* to null

   ## Flexvision
   initialize g_monitor.dataini   to null ## dataini   date,
   initialize g_monitor.horaini   to null ## horaini   datetime hour to fraction,
   initialize g_monitor.horafnl   to null ## horafnl   datetime hour to fraction,
   initialize g_monitor.intervalo to null ## intervalo datetime hour to fraction

   call fun_dba_abre_banco("CT24HS")
   
   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dat_ctg20.log"

   call startlog(w_log)

   #------------------------------------------
   #  ABRE BANCO   (TESTE ou PRODUCAO)
   #------------------------------------------

   

   select sitename into g_hostname from dual

   let g_hostname = g_hostname[1,3]

   defer interrupt
   set lock mode to wait

   options
      prompt  line last,
      comment line last,
      message line last,
      accept  key  F40

   whenever error continue
   initialize g_ppt.* to null

   open window WIN_CAB at 2,2 with 22 rows,78 columns
        attribute (border)

   let w_data = today
   display "CENTRAL 24 HS" at 01,01
   display "P O R T O   S E G U R O  -  S E G U R O S" AT 1,20
   display w_data       at 01,69

   open window WIN_MENU at 04,02 with 20 rows, 78 columns
   call p_reg_logo()
   call get_param()



   display "---------------------------------------------------------------",
           "---------ctg20--" at 03,01

   menu "OPCOES"

   before menu
          hide option all
          if g_issk.prgsgl = "ctg20T" then
             let g_issk.prgsgl = "ctg20"
          end if
            show option "Atd_aZul"
            show option "Encerra"



      command key ("Z") "Atd_aZul"
                        "Atendimento telefonico Azul Seguros"
         initialize g_documento.* to null
         let g_documento.ciaempcod = '35'



              --[ inclusao de parametros psi209007-contingencia da Azul ]---
              call cta00m07_principal(w_apoio
                                    ,w_empcodatd
                                    ,w_funmatatd
                                    ,w_usrtipatd
                                    ,g_c24paxnum,"","","","","","","","","","","")
                   returning lr_documento.*,
                             l_doc_handle

              let lr_documento.apoio     = w_apoio
              let lr_documento.ligcvntip = 0

              if  l_doc_handle is not null then
                  call cta00m16_chama_prog("ctg18", lr_documento.ramcod,
                                                    lr_documento.succod,
                                                    lr_documento.aplnumdig,
                                                    lr_documento.itmnumdig,
                                                    lr_documento.edsnumref,
                                                    lr_documento.ligcvntip,
                                                    lr_documento.prporg,
                                                    lr_documento.prpnumdig,
                                                    lr_documento.solnom,
                                                    g_documento.ciaempcod,
                                                    g_documento.ramgrpcod,
                                                    g_documento.c24soltipcod,
                                                    g_documento.corsus,
                                                    g_documento.atdnum,
                                                    g_documento.lclnumseq,
                                                    g_documento.rmerscseq,
                                                    g_documento.itaciacod)
                       returning l_resultado
              end if




      command key (interrupt,E) "Encerra" "Fim de servico"
         exit menu
   end menu

   close window win_cab
   close window win_menu

   let int_flag = false

END MAIN

#----------------------------------------------------------
function p_reg_logo()
#----------------------------------------------------------
     define ba char(01)


	let	ba  =  null

     open form reg from "apelogo2"
     display form reg
     let ba = ascii(92)
     display ba at 15,23
     display ba at 14,22
     display "PORTO SEGURO" AT 16,52
     display "                                  Seguros" at 17,23
             attribute (reverse)
end function



















































