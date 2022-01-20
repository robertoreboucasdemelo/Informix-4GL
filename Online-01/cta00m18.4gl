#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cta00m18.4gl                                               #
# Analista Resp : Roberto Reboucas                                           #
#                 Atendimento por CNPJ/CPF                                   #
#............................................................................#
# Desenvolvimento: Roberto Reboucas                                          #
# Liberacao      : 18/12/2007                                                #
#----------------------------------------------------------------------------#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica  Origem     Alteracao                             #
# ---------- -------------- ---------- --------------------------------------#
# 01/10/2008 Amilton, Meta  Psi 223689 Incluir tratamento de erro com global #
#----------------------------------------------------------------------------#
# 21/10/2008 Carla Rampazzo PSI 230650 .Carregar dados do documento pelo     #
#                                      Nro.Atendimento                       #
#                                      .Gerar Nro.Atendimento a cada ligacao #
#                                      para casos sem documento              #
#                                      (so apoio tem opcao de nao gerar)     #
#----------------------------------------------------------------------------#
# 29/12/2009 Patricia W.               Projeto SUCCOD - Smallint             #
#----------------------------------------------------------------------------#
# 01/04/2010 Carla Rampazzo PSI 219444 .chamar framc215 do RE p/ selecionar  #
#                                      Local de Risco / Bloco                #
#                                      .alimentar global com dados retornados#
#----------------------------------------------------------------------------#
# 22/04/2010 Roberto Melo   PSI 242853 Implementacao do PSS                  #
#----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"

define mr_documento  record
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
       ramcod        like datrservapol.ramcod,     # Codigo aamo
       lignum        like datmligacao.lignum,      # Numero da Ligacao
       c24astcod     like datkassunto.c24astcod,   # Assunto da Ligacao
       ligcvntip     like datmligacao.ligcvntip,   # Convenio Operacional
       atdsrvnum     like datmservico.atdsrvnum,   # Numero do Servico
       atdsrvano     like datmservico.atdsrvano,   # Ano do Servico
       sinramcod     like ssamsin.ramcod,          # Prd Parcial - Ramo sinistro
       sinano        like ssamsin.sinano,          # Prd Parcial - Ano sinistro
       sinnum        like ssamsin.sinnum,          # Prd Parcial - Num sinistro
       sinitmseq     like ssamitem.sinitmseq,      # Prd Parcial - Item p/rm 53
       acao          char (03),                    # ALT, REC ou CAN
       atdsrvorg     like datksrvtip.atdsrvorg,    # Origem do tipo de Servico
       cndslcflg     like datkassunto.cndslcflg,   # Flag solicita condutor
       lclnumseq     like rsdmlocal.lclnumseq,     # Local de Risco
       vstnumdig     like datmvistoria.vstnumdig,  # numero da vistoria
       flgIS096      char (01)                  ,  # flag cobertura claus.096
       flgtransp     char (01)                  ,  # flag averbacao transporte
       apoio         char (01)                  ,  # flag atend. pelo apoio(S/N)
       empcodatd     like datmligatd.apoemp     ,  # empresa do atendente
       funmatatd     like datmligatd.apomat     ,  # matricula do atendente
       usrtipatd     like datmligatd.apotip     ,  # tipo do atendente
       corsus        char(06)      ,               #
       dddcod        char(04)      ,               # codigo da area de discagem
       ctttel        char(20)      ,               # numero do telefone
       funmat        decimal(6,0)  ,               # matricula do funcionario
       cgccpfnum     decimal(12,0) ,               # numero do CGC(CNPJ)
       cgcord        decimal(4,0)  ,               # filial do CGC(CNPJ)
       cgccpfdig     decimal(2,0)  ,               # digito do CGC(CNPJ) ou CPF
       atdprscod     like datmservico.atdprscod ,
       atdvclsgl     like datkveiculo.atdvclsgl ,
       srrcoddig     like datmservico.srrcoddig ,
       socvclcod     like datkveiculo.socvclcod ,
       dstqtd        dec(8,4)                   ,
       prvcalc       interval hour(2) to minute ,
       lclltt        like datmlcl.lclltt        ,
       lcllgt        like datmlcl.lcllgt        ,
       rcuccsmtvcod  like datrligrcuccsmtv.rcuccsmtvcod,    ## Codigo do Motivo
       c24paxnum     like datmligacao.c24paxnum ,           # Numero da P.A.
       averbacao     like datrligtrpavb.trpavbnum,          # PSI183431 Daniel
       crtsaunum     like datksegsau.crtsaunum,
       bnfnum        like datksegsau.bnfnum,
       ramgrpcod     like gtakram.ramgrpcod
end record

define mr_documento2 record
       viginc        date,
       vigfnl        date,
       segcod        integer,
       segnom        char(50),
       vcldes        char(25),
       resultado     smallint,
       emsdat        date,
       doc_handle    integer,
       mensagem      char(50),
       situacao      char(10),
       cod_produto   smallint,
       semdocto      smallint,
       ligdctnum     like datrligsemapl.ligdctnum,
       ligdcttip     like datrligsemapl.ligdcttip,
       psscntcod     like kspmcntrsm.psscntcod,
       itaciacod     like datkitacia.itaciacod
end record

define m_ramsgl    char(15)
define m_dtresol86   date


---> Variaveis Auxiliares para Inclusao/Tratamento do Nro.Atendimento
define mr_atd             record
       semdocto           char(01)
      ,semdoctoempcodatd  like datmatd6523.semdoctoempcodatd
      ,semdoctopestip     like datmatd6523.semdoctopestip
      ,semdoctocgccpfnum  like datmatd6523.semdoctocgccpfnum
      ,semdoctocgcord     like datmatd6523.semdoctocgcord
      ,semdoctocgccpfdig  like datmatd6523.semdoctocgccpfdig
      ,semdoctocorsus     like datmatd6523.semdoctocorsus
      ,semdoctofunmat     like datmatd6523.semdoctofunmat
      ,semdoctoempcod     like datmatd6523.semdoctoempcod
      ,semdoctodddcod     like datmatd6523.semdoctodddcod
      ,semdoctoctttel     like datmatd6523.semdoctoctttel
      ,segnom             like datmatd6523.segnom
      ,ramcod             like datmatd6523.ramcod
      ,vcllicnum          like datmatd6523.vcllicnum
      ,flgvp              like datmatd6523.flgvp
      ,vstnumdig          like datmatd6523.vstnumdig
      ,flgcp              like datmatd6523.flgcp
      ,cpbnum             like datmatd6523.cpbnum
      ,pestip             like datmatd6523.pestip
      ,gera               char(01)
      ,novo_nroatd        like datmatd6523.atdnum
end record

----------------------------------------------------------------------------
function cta00m18(lr_param)
#------------------------------------------------------------------------------
define lr_param  record
       apoio     char(01),
       empcodatd like isskfunc.empcod,
       funmatatd like isskfunc.funmat,
       usrtipatd like issmnivnovo.usrtip,
       c24paxnum integer
end record

  call cta00m18_field(lr_param.*)
  return  mr_documento.*,
          mr_documento2.doc_handle ,
          mr_documento2.cod_produto,
          mr_documento2.semdocto

end function
#------------------------------------------------------------------------------
function cta00m18_field(lr_param)
#------------------------------------------------------------------------------

define lr_param  record
       apoio     char(01),
       empcodatd like isskfunc.empcod,
       funmatatd like isskfunc.funmat,
       usrtipatd like issmnivnovo.usrtip,
       c24paxnum integer
end record

define d_cta00m18 record
   cpocod       like datkdominio.cpocod      ,
   cpodes       like datkdominio.cpodes      ,
   solnom       like datmligacao.c24solnom   ,
   c24soltipcod like datmligacao.c24soltipcod,
   c24soltipdes char (40)                    ,
   outcam       char (1)                     ,
   c24paxtxt    char (12)                    ,
   pestip       char (01)                    ,
   cgccpfnum    like gsakseg.cgccpfnum       ,
   cgcord       like gsakseg.cgcord          ,
   cgccpfdig    like gsakseg.cgccpfdig       ,
   segnom       char (40)                    ,
   atdseg       char (1)
end record

define ws record
       tamanho           smallint                     ,
       c24soltipdes      like datksoltip.c24soltipdes ,
       contador          integer                      ,
       segnom            char (60)                    ,
       cgccpfdig         like gsakseg.cgccpfdig       ,
       qtd_segnom        integer                      ,
       tipo_ligacao      like datksoltip.c24ligtipcod ,
       acsnivcod         like issmnivnovo.acsnivcod   ,
       sqlcode           integer
end record

define lr_retorno record
       resultado  smallint   ,
       mensagem   char(42)
end record

define lr_cty06g00 record
   resultado      smallint
  ,mensagem       char(60)
  ,sgrorg         like rsamseguro.sgrorg
  ,sgrnumdig      like rsamseguro.sgrnumdig
  ,vigfnl         like rsdmdocto.vigfnl
  ,aplstt         like rsdmdocto.edsstt
  ,prporg         like rsdmdocto.prporg
  ,prpnumdig      like rsdmdocto.prpnumdig
  ,segnumdig      like rsdmdocto.segnumdig
end record

define lr_cta01m60 record
      cgccpf     like gsakpes.cgccpfnum ,
      cgcord     like gsakpes.cgcord    ,
      cgccpfdig  like gsakpes.cgccpfdig ,
      pesnom     like gsakpes.pesnom    ,
      pestip     like gsakpes.pestip
end record

define lr_cta01m62 record
       cod_produto smallint                   ,
       succod      like datrligapol.succod    ,
       ramcod      like datrligapol.ramcod    ,
       aplnumdig   like datrligapol.aplnumdig ,
       itmnumdig   like datrligapol.itmnumdig ,
       crtsaunum   like datksegsau.crtsaunum  ,
       segnom      char(50)                   ,
       cgccpfnum   like gsakpes.cgccpfnum     ,
       cgcord      like gsakpes.cgcord        ,
       cgccpfdig   like gsakpes.cgccpfdig     ,
       prporg      like datrligprp.prporg     ,
       prpnumdig   like datrligprp.prpnumdig  ,
       documento   integer                    ,
       pesnum      like gsakpes.pesnum        ,
       itaciacod   like datkitacia.itaciacod
end record

define lr_aux       record
       resultado    smallint
      ,mensagem     char(60)
end record

define msg               record
       linha1            char(40),
       linha2            char(40),
       linha3            char(40),
       linha4            char(40)
end record

 define l_cont       integer    ,
        l_asterisco  char(1)    ,
        l_resultado  smallint   ,
        l_flag       smallint   ,
        l_confirma   char(01)   ,
        l_controle   smallint   ,
        l_cta00m18a  smallint   ,
        l_rmeblcdes  like rsdmbloco.rmeblcdes

initialize   d_cta00m18.*
           , mr_documento.*
           , mr_documento2.*
           , mr_atd.*
           , lr_aux.*
           , msg.*
           , lr_retorno.*
           , lr_cty06g00.*
           , lr_cta01m60.*
           , lr_cta01m62.*
           , l_resultado
           , l_confirma
           , l_cont
           , l_asterisco
           , l_rmeblcdes
           , g_documento.atdnum
           , ws.* to null

for  l_cont  =  1  to  500
   initialize  g_doc_itau[l_cont].* to  null
end  for

let l_flag      = null
let l_cta00m18a = null
let l_controle  = false
let mr_atd.gera = "N" ---> Gera atendimento por esta tela so p/alguns casos
let g_gera_atd  = "S" ---> Controla se gera ou nao Atendimento na tela de Assunto
let l_cont      = null


display d_cta00m18.*

open window cta00m18 at 04,02 with form "cta00m18"
                     attribute(form line 1)

while true

input by name d_cta00m18.* without defaults

 #----------Before-Cpocod--------------------------------------
 before field cpocod
    display by name d_cta00m18.cpocod attribute (reverse)

    let d_cta00m18.cpocod = 0

    call cta00m00_recupera_convenio(d_cta00m18.cpocod)
    returning d_cta00m18.cpodes

    display by name d_cta00m18.cpodes

 #----------After-Cpocod---------------------------------------
 after field cpocod

    display by name d_cta00m18.cpocod

    if d_cta00m18.cpocod is null then
       let d_cta00m18.cpocod = cta00m00_convenios()
       if d_cta00m18.cpocod is null then
          next field cpocod
       end if
    end if

    call cta00m00_recupera_convenio(d_cta00m18.cpocod)
    returning d_cta00m18.cpodes

    if d_cta00m18.cpodes is null then

       error "Convenio Inexistente!" sleep 1
       let d_cta00m18.cpocod = cta00m00_convenios()

       if d_cta00m18.cpocod is null then
          next field cpocod
       end if

       call cta00m00_recupera_convenio(d_cta00m18.cpocod)
       returning d_cta00m18.cpodes
    end if

    let g_documento.ligcvntip = d_cta00m18.cpocod
    display by name d_cta00m18.cpocod
    display by name d_cta00m18.cpodes

 #----------------------------Before-Solnom-------------------------------------
    before field solnom

     if  fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field cpocod
     end if

     if l_resultado = 2 then
         display by name d_cta00m18.segnom
         next field segnom
     end if

    let mr_documento.empcodatd = lr_param.empcodatd
    let mr_documento.funmatatd = lr_param.funmatatd
    let mr_documento.usrtipatd = lr_param.usrtipatd
    let d_cta00m18.outcam = "N"
    let d_cta00m18.atdseg = "N"
    let d_cta00m18.segnom    = null
    let d_cta00m18.cgccpfnum = null
    let d_cta00m18.cgcord    = null
    let d_cta00m18.cgccpfdig = null

    display by name d_cta00m18.outcam
    display by name d_cta00m18.segnom
    display by name d_cta00m18.atdseg
    display by name d_cta00m18.cgccpfnum
    display by name d_cta00m18.cgcord
    display by name d_cta00m18.cgccpfdig

    if lr_param.apoio = "S" then
          call cty08g00_nome_func(lr_param.empcodatd
          		         ,lr_param.funmatatd
                                 ,lr_param.usrtipatd)
                   returning lr_retorno.resultado
                            ,lr_retorno.mensagem
                            ,d_cta00m18.solnom

           if lr_retorno.resultado = 3 then
              call errorlog(lr_retorno.mensagem)
              exit input
           else
              if lr_retorno.resultado = 2 then
                call errorlog(lr_retorno.mensagem)
              end if
           end if

           let d_cta00m18.c24soltipcod = 6
           let d_cta00m18.c24soltipdes = "APOIO"

           display by name d_cta00m18.c24soltipcod
           display by name d_cta00m18.c24soltipdes
           display by name d_cta00m18.solnom

           let mr_documento.c24soltipcod = d_cta00m18.c24soltipcod
           let mr_documento.solnom       = d_cta00m18.solnom

           next field pestip
     end if

     display by name d_cta00m18.solnom  attribute (reverse)

#----------------------------After-Solnom---------------------------------------
     after field solnom
         display by name d_cta00m18.solnom

         if  d_cta00m18.solnom is null then
             error 'Nome do solicitante deve ser informado!'
             next field solnom
         end if

         let mr_documento.solnom = d_cta00m18.solnom

#----------------------------Before-C24soltipcod--------------------------------
     before field c24soltipcod
         display by name d_cta00m18.c24soltipcod attribute (reverse)
         let ws.tipo_ligacao = 1

#----------------------------After-C24soltipcod---------------------------------
     after field c24soltipcod
         display by name d_cta00m18.c24soltipcod

         if  fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field solnom
         end if

         #-- Exibe popup dos tipos de solicitante --#
         if  d_cta00m18.c24soltipcod is null then
             error "Tipo do solicitante deve ser informado!"
             let d_cta00m18.c24soltipcod = cto00m00(ws.tipo_ligacao)
             display by name d_cta00m18.c24soltipcod
         end if

         #-- Busca a Descrição do Tipo do Solicitante --#
         call cto00m00_nome_solicitante(d_cta00m18.c24soltipcod, ws.tipo_ligacao)
              returning lr_retorno.resultado
                       ,lr_retorno.mensagem
                       ,ws.c24soltipdes

          if ws.c24soltipdes is null then
              error " Tipo de solicitante nao cadastrado!"
              #Exibe popup dos tipos de solicitantes
              let d_cta00m18.c24soltipcod = cto00m00(ws.tipo_ligacao)
              call cto00m00_nome_solicitante(d_cta00m18.c24soltipcod,ws.tipo_ligacao)
                   returning lr_retorno.resultado
                            ,lr_retorno.mensagem
                            ,ws.c24soltipdes
          end if

          # Se for Corretor chama a Tela de Atendimento
          if d_cta00m18.c24soltipcod = 2 then
             let g_documento.ciaempcod    = '1'
             let g_documento.solnom       = d_cta00m18.solnom
             let g_documento.c24soltipcod = d_cta00m18.c24soltipcod
             let g_cgccpf.acesso = 1
             let l_flag =  cta00m05_controle(lr_param.*)
             exit while
         end if

         if  lr_retorno.resultado <> 1 then
             error lr_retorno.mensagem
             next field c24soltipcod
         else
             display by name d_cta00m18.c24soltipdes
             if d_cta00m18.c24soltipcod < 3 then
                let mr_documento.soltip = d_cta00m18.c24soltipdes[1,1]
             else
                let mr_documento.soltip = "O"
             end if
         end if

         display by name ws.c24soltipdes
         let mr_documento.c24soltipcod = d_cta00m18.c24soltipcod

         if lr_param.c24paxnum is null and g_issk.acsnivcod = 6 then
            #Obter Nivel do Funcionario
            call cty08g00_nivel_func(g_issk.usrtip
                                    ,g_issk.empcod
                                    ,g_issk.usrcod
                                    ,'pso_ct24h')
            returning lr_retorno.resultado
                     ,lr_retorno.mensagem
                     ,ws.acsnivcod
            if ws.acsnivcod is null then
               while lr_param.c24paxnum is null
                  #-- Obter nr. do Pax --#
                  let lr_param.c24paxnum = cta02m09()
               end while
            end if
         end if

         if lr_param.c24paxnum is not null  and
            lr_param.c24paxnum <> 0 then
            let d_cta00m18.c24paxtxt = "P.A.: ", lr_param.c24paxnum using "######"
            display by name d_cta00m18.c24paxtxt  attribute (reverse)
         else
            let lr_param.c24paxnum = 0
         end if

         let mr_documento.c24paxnum = lr_param.c24paxnum

         if d_cta00m18.c24soltipdes is null then
             let d_cta00m18.c24soltipdes = ws.c24soltipdes
             display by name d_cta00m18.c24soltipdes
         end if

#----------------------------Before-outcam--------------------------------------
         before field outcam
            display by name d_cta00m18.outcam attribute (reverse)

#----------------------------After-outcam---------------------------------------
         after  field outcam
            display by name d_cta00m18.outcam

            if fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field c24soltipcod
            end if

            if d_cta00m18.outcam is null then
               error " Campo nao pode ser nulo!"
               next field outcam
            end if

            if d_cta00m18.outcam <> 'S' and
               d_cta00m18.outcam <> 'N' then
                  error " Digite <S>im ou <N>ao"
                  next field outcam
            end if

            if d_cta00m18.outcam = "S" then
                let l_cta00m18a = cta00m18a_field(lr_param.*)
                if l_cta00m18a is null  then
                   exit while
                end if
                let d_cta00m18.outcam = "N"
                display by name d_cta00m18.outcam
            end if

#----------------------------Before-Pestip--------------------------------------
        before field pestip
           display by name d_cta00m18.pestip attribute (reverse)

#----------------------------After-Pestip---------------------------------------
        after  field pestip
           display by name d_cta00m18.pestip

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              initialize d_cta00m18.cgccpfnum  to null
              initialize d_cta00m18.cgcord     to null
              initialize d_cta00m18.cgccpfdig  to null
              display by name d_cta00m18.cgccpfnum
              display by name d_cta00m18.cgcord
              display by name d_cta00m18.cgccpfdig
              next field outcam
           end if

           if d_cta00m18.pestip <>  "F"      and
              d_cta00m18.pestip <>  "J"      then
              error " Tipo de pessoa invalido!"
              next field pestip
           end if

           let mr_atd.pestip = d_cta00m18.pestip

#----------------------------Before-Cgccpfnum-----------------------------------
       before field cgccpfnum
          display by name d_cta00m18.cgccpfnum   attribute(reverse)

#----------------------------After-Cgccpfnum------------------------------------
       after  field cgccpfnum
          display by name d_cta00m18.cgccpfnum

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field pestip
          end if

          if d_cta00m18.cgccpfnum is null then
                initialize d_cta00m18.cgcord     to null
                initialize d_cta00m18.cgccpfdig  to null
                display by name d_cta00m18.cgcord
                display by name d_cta00m18.cgccpfdig
                next field segnom
          else
               if d_cta00m18.pestip is null then
                  error " Informe o Tipo de Pessoa"
                  next field pestip
               end if
          end if

          if d_cta00m18.pestip =  "F"   then
             next field cgccpfdig
          end if

#----------------------------Before-Cgcord--------------------------------------
       before field cgcord
          display by name d_cta00m18.cgcord   attribute(reverse)

#----------------------------After-Cgcord---------------------------------------
       after  field cgcord
          display by name d_cta00m18.cgcord

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field cgccpfnum
          end if

          if d_cta00m18.cgcord   is null   or
             d_cta00m18.cgcord   =  0      then
             error " Filial do CGC deve ser informada!"
             next field cgcord
          end if

#----------------------------Before-Cgccpfdig-----------------------------------
       before field cgccpfdig
          display by name d_cta00m18.cgccpfdig  attribute(reverse)

#----------------------------After-Cgccpfdig------------------------------------
       after  field cgccpfdig
          display by name d_cta00m18.cgccpfdig

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             if d_cta00m18.pestip =  "J"  then
                next field cgcord
             else
                next field cgccpfnum
             end if
          end if

          if d_cta00m18.cgccpfdig   is null   then
             error " Digito do CGC/CPF deve ser informado!"
             next field cgccpfdig
          end if

          if d_cta00m18.pestip =  "J"    then
             call F_FUNDIGIT_DIGITOCGC(d_cta00m18.cgccpfnum,
                                       d_cta00m18.cgcord)
                  returning ws.cgccpfdig
          else
             call F_FUNDIGIT_DIGITOCPF(d_cta00m18.cgccpfnum)
                  returning ws.cgccpfdig
          end if

          if ws.cgccpfdig          is null            or
             d_cta00m18.cgccpfdig  <>  ws.cgccpfdig   then
             error " Digito do CGC/CPF incorreto!"
             next field cgccpfdig
          end if

          #//Obter quantidade de segurados com o mesmo cpf/cgc
           call cty15g00_conta_cliente_cgccpf(d_cta00m18.cgccpfnum  ,
                                              d_cta00m18.cgcord     ,
                                              d_cta00m18.cgccpfdig  ,
                                              d_cta00m18.pestip     )
          returning ws.contador

          if ws.contador = 0  then
             error " Nenhum segurado foi localizado!"
             next field cgccpfnum
          else
             if ws.contador > 150 then
                error " Limite de consulta excedido, mais de 150 segurados!"
                next field cgccpfnum
              else
                exit input
             end if
          end if

 #----------------------------Before-Segnom-------------------------------------
        before field segnom
           display by name d_cta00m18.segnom attribute (reverse)

 #----------------------------After-Segnom--------------------------------------
        after  field segnom
          display by name d_cta00m18.segnom

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             initialize d_cta00m18.segnom  to null
             let ws.segnom = null
             display by name d_cta00m18.segnom
             next field cgccpfdig
          end if

          if d_cta00m18.segnom is not null then
             let ws.segnom   = d_cta00m18.segnom  clipped ,"*"
             for l_cont  = 1 to length(ws.segnom)
                 let l_asterisco = ws.segnom[l_cont ,l_cont ]
                 if l_asterisco = " " then
                    continue for
                 end if
                 if l_asterisco matches "[*]" then
                    Error "Nome do segurado nao pode começar com(*)!" sleep 2
                    next field segnom
                 end if
                 exit for
             end for
          end if

          if d_cta00m18.segnom is null  then
             next field atdseg
          end if

          let ws.tamanho = (length (d_cta00m18.segnom))

          if  ws.tamanho < 10  then
              error " Complemente o nome do segurado (minimo 10 caracteres)!"
              next field segnom
          end if

          let ws.segnom   = d_cta00m18.segnom

          call cty15g00_conta_cliente_nome(ws.segnom,d_cta00m18.pestip)
          returning ws.sqlcode ,ws.qtd_segnom

          if ws.qtd_segnom = 0 or
             ws.qtd_segnom is null then
             error " Nenhum segurado foi localizado!"
             next field segnom
          else
             if ws.qtd_segnom > 150  then
                error " Mais de 150 registros selecionados,",
                      " complemente o nome do segurado!"
                next field segnom
             else
                 exit input
             end if
          end if

#----------------------------Before-Atdseg--------------------------------------
       before field atdseg
          display by name d_cta00m18.atdseg attribute (reverse)
          let ws.segnom = null

#----------------------------After-Atdseg---------------------------------------
       after  field atdseg
         display by name d_cta00m18.atdseg

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            let d_cta00m18.atdseg = "N"
            display by name d_cta00m18.atdseg
            next field segnom
         end if

         if d_cta00m18.atdseg is null then
            error " Campo nao pode ser nulo!"
            next field atdseg
         end if

         if d_cta00m18.atdseg <> 'S' and
            d_cta00m18.atdseg <> 'N' then
               error " Digite <S>im ou <N>ao"
               next field atdseg
         end if

         if d_cta00m18.atdseg = 'S' then
             let g_documento.ciaempcod    = '1'
             let g_documento.solnom       = d_cta00m18.solnom
             let g_documento.c24soltipcod = d_cta00m18.c24soltipcod
             let g_cgccpf.acesso = 1
             let l_flag =  cta00m05_controle(lr_param.*)
             exit while
         else
             next field outcam
         end if

         on key (interrupt,control-c,f17)
             let l_controle = true
             error " Operacao Cancelada. "
             exit while

         on key (interrupt)
             exit while
       end input

      # Recupera os cliente com o Nome ou Cnpj/Cpf
      call cta01m60_rec_cliente(ws.segnom            ,
                                d_cta00m18.pestip    ,
                                d_cta00m18.cgccpfnum ,
                                d_cta00m18.cgcord    ,
                                d_cta00m18.cgccpfdig )
      returning lr_cta01m60.cgccpf    ,
                lr_cta01m60.cgcord    ,
                lr_cta01m60.cgccpfdig ,
                lr_cta01m60.pesnom    ,
                lr_cta01m60.pestip    ,
                l_resultado
       let ws.segnom = null

       if l_resultado = 0 then

          call cta01m62(lr_cta01m60.cgccpf    ,
                        lr_cta01m60.cgcord    ,
                        lr_cta01m60.cgccpfdig ,
                        lr_cta01m60.pesnom    ,
                        lr_cta01m60.pestip    )
              returning lr_cta01m62.cod_produto
                       ,lr_cta01m62.succod
                       ,lr_cta01m62.ramcod
                       ,lr_cta01m62.aplnumdig
                       ,lr_cta01m62.itmnumdig
                       ,lr_cta01m62.crtsaunum
                       ,lr_cta01m62.segnom
                       ,lr_cta01m62.cgccpfnum
                       ,lr_cta01m62.cgcord
                       ,lr_cta01m62.cgccpfdig
                       ,lr_cta01m62.prporg
                       ,lr_cta01m62.prpnumdig
                       ,lr_cta01m62.documento
                       ,lr_cta01m62.pesnum
                       ,lr_cta01m62.itaciacod

          if lr_cta01m62.cod_produto is null then
             continue while
          end if

          --> Busca Dados do local de Risco ou Bloco p/ Clausulas do docto. RE
          if lr_cta01m62.aplnumdig is not null and
             (lr_cta01m62.cod_produto = 2   or
              lr_cta01m62.cod_produto = 12  or
              lr_cta01m62.cod_produto = 13) then


             initialize g_rsc_re.*
                       ,g_documento.lclnumseq
                       ,g_documento.rmerscseq to null

             while g_rsc_re.lclrsccod is null or
                   g_rsc_re.lclrsccod =  0

                call framc215(lr_cta01m62.succod
                             ,lr_cta01m62.ramcod
                             ,lr_cta01m62.aplnumdig)
                    returning lr_retorno.resultado
                             ,lr_retorno.mensagem
                             ,g_rsc_re.lclrsccod
                             ,g_rsc_re.lgdtip
                             ,g_rsc_re.lgdnom
                             ,g_rsc_re.lgdnum
                             ,g_rsc_re.lclbrrnom
                             ,g_rsc_re.cidnom
                             ,g_rsc_re.ufdcod
                             ,g_rsc_re.lgdcep
                             ,g_rsc_re.lgdcepcmp
                             ,g_documento.lclnumseq
                             ,g_documento.rmerscseq
                             ,l_rmeblcdes
                            ,g_rsc_re.lclltt
                            ,g_rsc_re.lcllgt

             if g_rsc_re.lclrsccod is null or
                g_rsc_re.lclrsccod =  0    then

                if lr_retorno.mensagem is null or
                   lr_retorno.mensagem =  " "  then

                   call cts08g01 ("A","N",""
                                 ,"PARA PROSSEGUIR NO ATENDIMENTO, "
                                 ,"SELECIONE UMA DAS OPCOES DA LISTA. ", " " )
                        returning l_confirma
		else
                   error " Local de Risco nao Localizado para o Documento. "
		   exit while
                end if
             end if
             end while
          end if
       else
          continue while
       end if
        # Direciona para qual produto e o Atendimento

        call cta00m18_direciona( lr_cta01m62.cod_produto
                                ,lr_cta01m62.succod
                                ,lr_cta01m62.ramcod
                                ,lr_cta01m62.aplnumdig
                                ,lr_cta01m62.itmnumdig
                                ,lr_cta01m62.crtsaunum
                                ,lr_cta01m62.segnom
                                ,lr_cta01m62.cgccpfnum
                                ,lr_cta01m62.cgcord
                                ,lr_cta01m62.cgccpfdig
                                ,lr_cta01m62.prporg
                                ,lr_cta01m62.prpnumdig
                                ,lr_cta01m62.documento
                                ,lr_cta01m62.pesnum
                                ,lr_cta01m62.itaciacod )
        returning lr_retorno.resultado
        if lr_retorno.resultado = 1 then
             exit while
        else
             continue while
        end if
    end while

    let mr_atd.segnom = lr_cta01m62.segnom
    call cta00m18_guarda_globais()

   ---> Se nao localizou Apolice entao abre Atendimento por aqui
   if g_documento.aplnumdig   is null or
      g_documento.aplnumdig   =  0    then
      let mr_atd.gera = "S" ---> Gera novo Atendimento
   end if


   if not l_controle then
   #Gera atendimento para todos os níveis
      {if g_issk.acsnivcod >= 7  and
         mr_atd.gera       = "S" then

         initialize l_confirma to null

         call cts08g01 ("A","S","",
                        "DESEJA GERAR UM NOVO ATENDIMENTO ? ","","")
              returning l_confirma

         if l_confirma = "N" then
            let mr_atd.gera = "N" ---> Nao Gera novo Atendimento
            let g_gera_atd  = "N"

            initialize g_documento.atdnum to null
         end if
      end if}
      ---> Gera Numero de Atendimento
      if mr_atd.gera = "S" then

         ---> Se nao ha docto trata variaveis p/ nao gravar em campos indevidos
         if mr_atd.semdocto = "S" then
            let g_documento.cgccpfnum = null
            let g_documento.cgcord    = null
            let g_documento.cgccpfdig = null
            let g_documento.corsus    = null
         end if


         if g_documento.ciaempcod is null or
            g_documento.ciaempcod =  0    then
            let g_documento.ciaempcod =  1
         end if

         begin work
         call ctd24g00_ins_atd(""                       ---> atdnum
                              ,g_documento.ciaempcod
                              ,d_cta00m18.solnom
                              ,""                       --->flgavstransp
                              ,d_cta00m18.c24soltipcod
                              ,mr_atd.ramcod
                              ,"N"                      --->flgcar
                              ,mr_atd.vcllicnum
                              ,g_documento.corsus
                              ,g_documento.succod
                              ,g_documento.aplnumdig
                              ,g_documento.itmnumdig
                              ,g_documento.itaciacod
                              ,mr_atd.segnom
                              ,mr_atd.pestip
                              ,g_documento.cgccpfnum
                              ,g_documento.cgcord
                              ,g_documento.cgccpfdig
                              ,g_documento.prporg
                              ,g_documento.prpnumdig
                              ,mr_atd.flgvp
                              ,mr_atd.vstnumdig
                              ,""                       --->vstdnumdig
                              ,""                       --->flgvd
                              ,mr_atd.flgcp             --->flgcp
                              ,mr_atd.cpbnum            --->cpbnum
                              ,mr_atd.semdocto
                              ,"N"                      --->ies_ppt
                              ,"N"                      --->ies_pss
                              ,"N"                      --->transp
                              ,""                       --->trpavbnum
                              ,""                       --->vclchsfnl
                              ,g_documento.sinramcod
                              ,g_documento.sinnum
                              ,g_documento.sinano
                              ,""                       --->sinvstnum
                              ,""                       --->sinvstano
                              ,""                       --->flgauto
                              ,""                       --->sinautnum
                              ,""                       --->sinautano
                              ,""                       --->flgre
                              ,""                       --->sinrenum
                              ,""                       --->sinreano
                              ,""                       --->flgavs
                              ,""                       --->sinavsnum
                              ,""                       --->sinavsano
                              ,mr_atd.semdoctoempcodatd
                              ,mr_atd.semdoctopestip
                              ,mr_atd.semdoctocgccpfnum
                              ,mr_atd.semdoctocgcord
                              ,mr_atd.semdoctocgccpfdig
                              ,mr_atd.semdoctocorsus
                              ,mr_atd.semdoctofunmat
                              ,mr_atd.semdoctoempcod
                              ,mr_atd.semdoctodddcod
                              ,mr_atd.semdoctoctttel
                              ,g_issk.funmat
                              ,g_issk.empcod
                              ,g_issk.usrtip
                              ,g_documento.ligcvntip)
              returning mr_atd.novo_nroatd
                       ,lr_aux.resultado
                       ,lr_aux.mensagem

         if lr_aux.resultado <> 0 then

            error lr_aux.mensagem sleep 3
            let int_flag              = true
            let g_documento.ligcvntip = null
            let g_documento.atdnum    = null
            let g_documento.succod    = null
            let g_documento.aplnumdig = null
            let g_documento.itmnumdig = null
            let g_documento.aplnumdig = null
            let g_documento.edsnumref = null
            let g_documento.fcapacorg = null
            let g_documento.fcapacnum = null
            let g_documento.sinramcod = null
            let g_documento.sinano    = null
            let g_documento.sinnum    = null
            let g_documento.vstnumdig = null
            let g_documento.corsus    = null
            let g_documento.dddcod    = null
            let g_documento.ctttel    = null
            let g_documento.funmat    = null
            let g_documento.cgccpfnum = null
            let g_documento.cgcord    = null
            let g_documento.cgccpfdig = null
            let g_cgccpf.ligdctnum    = null
            let g_cgccpf.ligdcttip    = null
            let g_crtdvgflg           = "N"
            initialize mr_documento.* to null
            rollback work
         else
            initialize l_confirma
                      ,msg.linha1
                      ,msg.linha2
                      ,msg.linha3 to null

            commit work
            while l_confirma is null or l_confirma = "N"

               let msg.linha1 = "INFORME AO CLIENTE O"
               let msg.linha2 = "NUMERO DE ATENDIMENTO : "
               let msg.linha3 = "< " , mr_atd.novo_nroatd using "<<<<<<<&&&"
                              , " >"
               call cts08g01 ("A","N","",msg.linha1, msg.linha2 , msg.linha3)
                    returning l_confirma

               initialize msg.linha1
                         ,msg.linha2
                         ,msg.linha3 to null

               let msg.linha1 = "NUMERO DE ATENDIMENTO < "
                                ,mr_atd.novo_nroatd using "<<<<<<<&&&" ," >"

               let msg.linha2 = "FOI INFORMADO AO CLIENTE?"

               call cts08g01 ("A","S","",msg.linha1, msg.linha2, "")
                    returning l_confirma
            end while

            ---> Atribui O Novo Numero de Atendimento a Global
            let g_documento.atdnum = mr_atd.novo_nroatd

            ---> Se gerou Atendimento aqui nao gera na tela do Assunto
            let g_gera_atd = "N"

            ---> Se nao ha docto volta valor para variaveis
            if mr_atd.semdocto = "S" then
               let g_documento.cgccpfnum = mr_atd.semdoctocgccpfnum
               let g_documento.cgcord    = mr_atd.semdoctocgcord
               let g_documento.cgccpfdig = mr_atd.semdoctocgccpfdig
               let g_documento.corsus    = mr_atd.semdoctocorsus
            end if
         end if
      end if
   end if


close window cta00m18
return

end function

#------------------------------------------------------------------------------
function cta00m18_direciona(lr_param)
#------------------------------------------------------------------------------

define lr_param record
       cod_produto smallint                   ,
       succod      like datrligapol.succod    ,
       ramcod      like datrligapol.ramcod    ,
       aplnumdig   like datrligapol.aplnumdig ,
       itmnumdig   like datrligapol.itmnumdig ,
       crtsaunum   like datksegsau.crtsaunum  ,
       segnom      char(50)                   ,
       cgccpfnum   like gsakpes.cgccpfnum     ,
       cgcord      like gsakpes.cgcord        ,
       cgccpfdig   like gsakpes.cgccpfdig     ,
       prporg      like datrligprp.prporg     ,
       prpnumdig   like datrligprp.prpnumdig  ,
       documento   integer                    ,
       pesnum      like gsakpes.pesnum        ,
       itaciacod   like datkitacia.itaciacod
end record

define lr_retorno record
       resultado smallint,
       mensagem  char(60),
       ramnom    char(30),
       ramsgl    char(15),
       flag      char(01),
       chave     char(20),
       msg       char(100)
end record

define lr_cty06g00 record
   resultado      smallint
  ,mensagem       char(60)
  ,sgrorg         like rsamseguro.sgrorg
  ,sgrnumdig      like rsamseguro.sgrnumdig
  ,vigfnl         like rsdmdocto.vigfnl
  ,aplstt         like rsdmdocto.edsstt
  ,prporg         like rsdmdocto.prporg
  ,prpnumdig      like rsdmdocto.prpnumdig
  ,segnumdig      like rsdmdocto.segnumdig
  ,edsnumref      like rsdmdocto.edsnumdig
end record

define l_resultado  smallint
initialize lr_retorno.* , lr_cty06g00.* to null
let l_resultado = null

   # Auto
   if lr_param.cod_produto = 1 then
       let mr_documento.succod    = lr_param.succod
       let mr_documento.ramcod    = lr_param.ramcod
       let mr_documento.aplnumdig = lr_param.aplnumdig
       let mr_documento.itmnumdig = lr_param.itmnumdig

       call f_funapol_ultima_situacao
           (mr_documento.succod, mr_documento.aplnumdig, mr_documento.itmnumdig)
            returning  g_funapol.*

       call cty05g00_edsnumref(1,mr_documento.succod, mr_documento.aplnumdig,
                               g_funapol.dctnumseq)
            returning mr_documento.edsnumref

       let l_resultado = 1
   end if

   # RE, Transporte ou Fianca
   if lr_param.cod_produto = 2 or
      lr_param.cod_produto = 12 or
      lr_param.cod_produto = 13 then

       # Recupera a descricao do ramo
       call cty10g00_descricao_ramo(lr_param.ramcod,1)
       returning lr_retorno.resultado
                ,lr_retorno.mensagem
                ,lr_retorno.ramnom
                ,lr_retorno.ramsgl

       # Recupera os dados do RE
       call cty06g00_dados_apolice(lr_param.succod
                                  ,lr_param.ramcod
                                  ,lr_param.aplnumdig
                                  ,lr_retorno.ramsgl )
       returning lr_cty06g00.*

       let mr_documento.succod    = lr_param.succod
       let mr_documento.ramcod    = lr_param.ramcod
       let mr_documento.aplnumdig = lr_param.aplnumdig
       let mr_documento.itmnumdig = lr_param.itmnumdig
       let mr_documento.edsnumref = lr_cty06g00.edsnumref
       let g_index   = 1
       let g_dctoarray[1].succod    = lr_param.succod
       let g_dctoarray[1].ramcod    = lr_param.ramcod
       let g_dctoarray[1].aplnumdig = lr_param.aplnumdig
       let g_dctoarray[1].segnumdig = lr_cty06g00.segnumdig
       let g_dctoarray[1].prporg    = lr_cty06g00.prporg
       let g_dctoarray[1].prpnumdig = lr_cty06g00.prpnumdig
       let l_resultado = 1

   end if

  # Saude
  if lr_param.cod_produto = 98 then
     let g_documento.ciaempcod = 50 ---> Saude

       call cta01m13("",
                     lr_param.cgccpfnum,
                     lr_param.cgccpfdig,
                     lr_param.segnom)
               returning mr_documento.succod,
                         mr_documento.ramcod,
                         mr_documento.aplnumdig,
                         mr_documento.crtsaunum,
                         mr_documento.bnfnum
      let l_resultado = 1
  end if

 # Azul
 if lr_param.cod_produto = 99 then
     call cts38m00_dados_apolice(lr_param.succod,
                                 lr_param.aplnumdig,
                                 lr_param.itmnumdig,
                                 lr_param.ramcod)
                       returning mr_documento.aplnumdig,
                                 mr_documento.itmnumdig,
                                 mr_documento.edsnumref,
                                 mr_documento.succod,
                                 mr_documento.ramcod,
                                 mr_documento2.emsdat,
                                 mr_documento2.viginc,
                                 mr_documento2.vigfnl,
                                 mr_documento2.segcod,
                                 mr_documento2.segnom,
                                 mr_documento2.vcldes,
                                 mr_documento.corsus,
                                 mr_documento2.doc_handle,
                                 mr_documento2.resultado,
                                 mr_documento2.mensagem,
                                 mr_documento2.situacao
      let l_resultado = 1
      if  mr_documento2.resultado <> 1 then
          error 'Item nao encontrado para a Apólice'
          let l_resultado = null
      end if

      let g_documento.ciaempcod = 35
      call cta00m07_sit_apol(mr_documento2.vigfnl,
                             mr_documento2.situacao)
           returning lr_retorno.resultado
 end if

 # Itau
 if lr_param.cod_produto = 93 then


   if lr_param.ramcod = 14 then

   call cty25g00_rec_ult_sequencia(lr_param.itaciacod,
                                      lr_param.ramcod   ,
                                      lr_param.aplnumdig)
      returning mr_documento.edsnumref,
                mr_documento2.resultado,
                mr_documento2.mensagem

      let l_resultado = 1
      if  mr_documento2.resultado  <> 0 then
          error mr_documento2.mensagem
          let l_resultado = null
      else
          let g_documento.ciaempcod   = 84
          let mr_documento2.itaciacod = lr_param.itaciacod
          let mr_documento.succod     = lr_param.succod
          let mr_documento.ramcod     = lr_param.ramcod
          let mr_documento.aplnumdig  = lr_param.aplnumdig
          let mr_documento.itmnumdig  = lr_param.itmnumdig
      end if

   else
      call cty22g00_rec_ult_sequencia(lr_param.itaciacod,
                                      lr_param.ramcod   ,
                                      lr_param.aplnumdig)
      returning mr_documento.edsnumref,
                mr_documento2.resultado,
                mr_documento2.mensagem

      let l_resultado = 1
      if  mr_documento2.resultado  <> 0 then
          error mr_documento2.mensagem
          let l_resultado = null
      else
          let g_documento.ciaempcod   = 84
          let mr_documento2.itaciacod = lr_param.itaciacod
          let mr_documento.succod     = lr_param.succod
          let mr_documento.ramcod     = lr_param.ramcod
          let mr_documento.aplnumdig  = lr_param.aplnumdig
          let mr_documento.itmnumdig  = lr_param.itmnumdig
      end if
   end if


 end if


 # Cartao
 if lr_param.cod_produto = 97 then
       let mr_documento.cgccpfnum     = lr_param.cgccpfnum
       let mr_documento.cgcord        = lr_param.cgcord
       let mr_documento.cgccpfdig     = lr_param.cgccpfdig
       let l_resultado = 1
 end if

 # Proposta
 if lr_param.cod_produto = 96 then

     call cty02g00_opacc149(lr_param.prporg, lr_param.prpnumdig)
          returning lr_retorno.flag,lr_retorno.msg

    if  lr_retorno.msg is not null or
        lr_retorno.msg <> " "     then
        error lr_retorno.msg
    else
      if lr_retorno.flag = "N"  then
           error "Proposta nao digitada para acompanhamento!"
      else
           let mr_documento.prporg    =   lr_param.prporg
           let mr_documento.prpnumdig =   lr_param.prpnumdig
           let mr_documento.ramcod    =   lr_param.ramcod
           let l_resultado = 1
      end if
    end if

 end if

 # Vistoria
 if lr_param.cod_produto = 95 then

     let lr_retorno.chave = "ct24hs" , lr_param.documento using '<<<&&&&&&'

     call chama_prog("Con_Aceit","av_previa",lr_retorno.chave)
     returning lr_retorno.resultado

     if lr_retorno.resultado = -1 then
        error " Espelho da Vistoria nao Disponivel no Momento!"
        let l_resultado = null
     else
        let l_resultado = 1
        let mr_documento2.ligdctnum = lr_param.documento
        let mr_documento2.ligdcttip = 1
     end if

 end if

# Cobertura
 if lr_param.cod_produto = 94 then

     let lr_retorno.chave = "ct24hs" , lr_param.documento  using '<<<&&&&&&'

     call chama_prog("Con_Aceit","av_pccob",lr_retorno.chave)
     returning lr_retorno.resultado

     if lr_retorno.resultado = -1 then
        error " Espelho da Cobertura nao Disponivel no Momento!"
        let l_resultado = null
     else
        let l_resultado = 1
        let mr_documento2.ligdctnum = lr_param.documento
        let mr_documento2.ligdcttip = 2
        let mr_atd.flgcp            = "S"
        let mr_atd.cpbnum           = lr_param.documento
     end if

 end if

 # PSS
 if lr_param.cod_produto = 25 then

    let g_documento.ciaempcod      = 43
    let mr_documento.cgccpfnum     = lr_param.cgccpfnum
    let mr_documento.cgcord        = lr_param.cgcord
    let mr_documento.cgccpfdig     = lr_param.cgccpfdig
    let mr_documento2.psscntcod    = lr_param.documento
    call cta00m26_espelho(mr_documento2.psscntcod)

    let l_resultado = 1
 end if

 if l_resultado is null then
    let lr_param.cod_produto = null
 else
    let mr_documento2.cod_produto = lr_param.cod_produto
 end if

 # Recupera o grupo de ramos
 call cty10g00_grupo_ramo(g_issk.empcod
                         ,mr_documento.ramcod)
 returning lr_retorno.resultado,
           lr_retorno.mensagem ,
           mr_documento.ramgrpcod
 return l_resultado

end function

#---------------------------------#
function cta00m18_guarda_globais()
#---------------------------------#

  initialize g_documento.solnom,
             g_documento.atdnum,
             g_documento.c24soltipcod,
             g_documento.soltip,
             g_documento.ramcod,
             g_documento.succod,
             g_documento.aplnumdig,
             g_documento.empcodatd,
             g_documento.funmatatd,
             g_documento.usrtipatd,
             g_documento.itmnumdig,
             g_documento.corsus,
             g_documento.dddcod,
             g_documento.ctttel,
             g_documento.funmat,
             g_documento.cgccpfnum,
             g_documento.cgcord,
             g_documento.cgccpfdig,
             g_documento.prpnumdig,
             g_documento.edsnumref,
             g_documento.ramgrpcod,
             g_documento.bnfnum,
             g_documento.prporg,
             g_documento.prpnumdig,
             g_cgccpf.ligdctnum,
             g_cgccpf.ligdcttip,
             g_pss.psscntcod   to null

 let g_c24paxnum              = mr_documento.c24paxnum
 let g_documento.solnom       = mr_documento.solnom
 let g_documento.c24soltipcod = mr_documento.c24soltipcod
 let g_documento.soltip       = mr_documento.soltip
 let g_documento.ramcod       = mr_documento.ramcod
 let g_documento.succod       = mr_documento.succod
 let g_documento.aplnumdig    = mr_documento.aplnumdig
 let g_documento.empcodatd    = mr_documento.empcodatd
 let g_documento.funmatatd    = mr_documento.funmatatd
 let g_documento.usrtipatd    = mr_documento.usrtipatd
 let g_documento.itmnumdig    = mr_documento.itmnumdig
 let g_documento.corsus       = mr_documento.corsus
 let g_documento.dddcod       = mr_documento.dddcod
 let g_documento.ctttel       = mr_documento.ctttel
 let g_documento.funmat       = mr_documento.funmat
 let g_documento.cgccpfnum    = mr_documento.cgccpfnum
 let g_documento.cgcord       = mr_documento.cgcord
 let g_documento.cgccpfdig    = mr_documento.cgccpfdig
 let g_documento.edsnumref    = mr_documento.edsnumref
 let g_documento.ramgrpcod    = mr_documento.ramgrpcod
 let g_documento.crtsaunum    = mr_documento.crtsaunum
 let g_documento.bnfnum       = mr_documento.bnfnum
 let g_documento.prporg       = mr_documento.prporg
 let g_documento.prpnumdig    = mr_documento.prpnumdig
 let g_cgccpf.ligdctnum       = mr_documento2.ligdctnum
 let g_cgccpf.ligdcttip       = mr_documento2.ligdcttip
 let g_documento.itaciacod    = mr_documento2.itaciacod
 let g_pss.psscntcod          = mr_documento2.psscntcod

 if  mr_documento.itmnumdig is null then
     let mr_documento.itmnumdig = 0
     let g_documento.itmnumdig  = 0
 else
     let g_documento.itmnumdig = mr_documento.itmnumdig
 end if

end function

#------------------------------------------------------------------------------
function cta00m18a_field(lr_param)
#------------------------------------------------------------------------------

define lr_param  record
       apoio     char(01),
       empcodatd like isskfunc.empcod,
       funmatatd like isskfunc.funmat,
       usrtipatd like issmnivnovo.usrtip,
       c24paxnum integer
end record

define d_cta00m18a record
   ciaempcod    like gabkemp.empcod          ,
   ciaempnom    like gabkemp.empnom          ,
   itaciacod    like datkitacia.itaciacod    ,
   itaciades    like datkitacia.itaciades    ,
   ramcod       like gtakram.ramcod          ,
   ramnom       like gtakram.ramnom          ,
   vcllicnum    like abbmveic.vcllicnum      ,
   succod       like gabksuc.succod          ,
   sucnom       like gabksuc.sucnom          ,
   aplnumdig    like abamdoc.aplnumdig       ,
   itmnumdig    like abbmveic.itmnumdig      ,
   doctip       char(1)                      ,
   doctxt       char(14)                     ,
   prporg       like datrligprp.prporg       ,
   doc          integer                      ,
   semdocto     char(1)
end record

define lr_cta01m61 record
      cgccpfnum  like gsakpes.cgccpfnum ,
      cgcord     like gsakpes.cgcord    ,
      cgccpfdig  like gsakpes.cgccpfdig ,
      pestip     like gsakpes.pestip    ,
      pesnom     like gsakpes.pesnom
end record

define lr_cta01m62 record
       cod_produto smallint                   ,
       succod      like datrligapol.succod    ,
       ramcod      like datrligapol.ramcod    ,
       aplnumdig   like datrligapol.aplnumdig ,
       itmnumdig   like datrligapol.itmnumdig ,
       crtsaunum   like datksegsau.crtsaunum  ,
       segnom      char(50)                   ,
       cgccpfnum   like gsakpes.cgccpfnum     ,
       cgcord      like gsakpes.cgcord        ,
       cgccpfdig   like gsakpes.cgccpfdig     ,
       prporg      like datrligprp.prporg     ,
       prpnumdig   like datrligprp.prpnumdig  ,
       documento   integer                    ,
       pesnum      like gsakpes.pesnum        ,
       itaciacod   like datkitacia.itaciacod
end record

define ws record
       ramo              char (04)                    ,
       ramcod            like gtakram.ramcod          ,
       aplnumdig         like abamapol.aplnumdig      ,
       itmnumdig         like abbmitem.itmnumdig      ,
       salva_succod      like datrligapol.succod,  #decimal(2,0),  #projeto succod
       flag              char(01)                     ,
       flag_acesso       smallint                     ,
       pesqdoc           smallint                     ,
       erro              smallint                     ,
       cont              integer
end record

define lr_retorno record
       resultado  smallint   ,
       mensagem   char(70)
end record

define lr_ret_sel_datk record
       erro       smallint,
       mensagem   char(60),
       grlinf     like datkgeral.grlinf
end record

define l_resultado      smallint
define l_result_azul    smallint
define l_itmnumdig_aux  like datrligapol.itmnumdig
define l_msg            char(100)
define l_confirma       char(01)
define l_rmeblcdes      like rsdmbloco.rmeblcdes

initialize  d_cta00m18a.*
           ,m_dtresol86
           ,l_confirma
           ,lr_ret_sel_datk.*
           ,m_ramsgl
           ,lr_retorno.*
           ,lr_cta01m61.*
           ,lr_cta01m62.*
           ,l_resultado
           ,l_result_azul
           ,l_itmnumdig_aux
           ,l_msg
           ,l_rmeblcdes
           ,g_pss.*
           ,ws.* to null

# Obter data resolucao 86
call cta12m00_seleciona_datkgeral('ct24resolucao86')
returning lr_ret_sel_datk.*

let m_dtresol86 = lr_ret_sel_datk.grlinf

display d_cta00m18a.*

open window cta00m18a at 15,02 with form "cta00m18a"
                     attribute(form line 1)

while true

initialize  d_cta00m18a.*
           ,lr_retorno.*
           ,lr_cta01m61.*
           ,lr_cta01m62.*
           ,l_resultado
           ,l_result_azul
           ,l_itmnumdig_aux
           ,ws.* to null

let ws.flag_acesso = cta00m06(g_issk.dptsgl)
let ws.pesqdoc     = false

input by name d_cta00m18a.* without defaults

#----------------------------Before-Ciaempcod-----------------------------------
   before field ciaempcod

   let d_cta00m18a.vcllicnum = null
   let d_cta00m18a.succod    = null
   let d_cta00m18a.sucnom    = null
   let d_cta00m18a.aplnumdig = null
   let d_cta00m18a.itmnumdig = null
   let d_cta00m18a.ramnom    = null
   let d_cta00m18a.doctip    = null
   let d_cta00m18a.doctxt    = null
   let d_cta00m18a.prporg    = null
   let d_cta00m18a.doc       = null
   let d_cta00m18a.itaciacod = null
   let d_cta00m18a.itaciades = null
   let d_cta00m18a.ciaempcod = 1
   let d_cta00m18a.ciaempnom = null
   let d_cta00m18a.ramcod    = 531

   display by name d_cta00m18a.vcllicnum
   display by name d_cta00m18a.succod
   display by name d_cta00m18a.sucnom
   display by name d_cta00m18a.aplnumdig
   display by name d_cta00m18a.itmnumdig
   display by name d_cta00m18a.ramnom
   display by name d_cta00m18a.doctip
   display by name d_cta00m18a.doctxt
   display by name d_cta00m18a.prporg
   display by name d_cta00m18a.doc
   display by name d_cta00m18a.itaciacod
   display by name d_cta00m18a.itaciades
   display by name d_cta00m18a.ciaempcod attribute (reverse)
   display by name d_cta00m18a.ciaempnom
   display by name d_cta00m18a.ramcod

   if ws.flag_acesso = 0 then
      let d_cta00m18a.ciaempcod = 1
      let d_cta00m18a.ramcod    = 531
      let d_cta00m18a.succod    = 1
      display by name d_cta00m18a.ciaempcod
      display by name d_cta00m18a.ramcod
      display by name d_cta00m18a.succod
      next field vcllicnum
   end if

#----------------------------After-Ciaempcod---------------------------------------
   after field ciaempcod
      display by name d_cta00m18a.ciaempcod

      if d_cta00m18a.ciaempcod is null then

          call cty14g00_popup_empresa()
             returning lr_retorno.resultado
                      ,d_cta00m18a.ciaempcod
                      ,d_cta00m18a.ciaempnom

          if lr_retorno.resultado = 3 then
             error 'Codigo de Empresa nao Selecionado!'
             next field ciaempcod
          end if

      else

          call cty14g00_empresa_nome(d_cta00m18a.ciaempcod)
             returning d_cta00m18a.ciaempnom
                      ,lr_retorno.resultado
                      ,lr_retorno.mensagem

          if lr_retorno.resultado <> 0 then
             error lr_retorno.mensagem
             next field ciaempcod
          end if

      end if

      display by name d_cta00m18a.ciaempnom

      if d_cta00m18a.ciaempcod <> 84 then
        next field ramcod
      end if

#----------------------------Before-Itaciacod--------------------------------------
   before field itaciacod
     display by name d_cta00m18a.itaciacod attribute (reverse)

     if d_cta00m18a.itaciacod is null then

         let d_cta00m18a.itaciacod = 33

         call cto00m10_recupera_descricao(1,d_cta00m18a.itaciacod)
         returning d_cta00m18a.itaciades

         display by name d_cta00m18a.itaciades

     end if

#----------------------------After-Itaciacod---------------------------------------
   after field itaciacod
      display by name d_cta00m18a.itaciacod

      if fgl_lastkey() = fgl_keyval("up")   or
         fgl_lastkey() = fgl_keyval("left") then
           display by name d_cta00m18a.ramcod
           next field ciaempcod
      end if

      if d_cta00m18a.itaciacod is null then
         call cto00m10_popup(1)
         returning d_cta00m18a.itaciacod, d_cta00m18a.itaciades
      else
         call cto00m10_recupera_descricao(1,d_cta00m18a.itaciacod)
         returning d_cta00m18a.itaciades
      end if

      if d_cta00m18a.itaciades is null then
         next field itaciacod
      end if

      display by name d_cta00m18a.itaciacod
      display by name d_cta00m18a.itaciades


#----------------------------Before-Ramcod--------------------------------------
   before field ramcod
     display by name d_cta00m18a.ramcod attribute (reverse)

#----------------------------After-Ramcod---------------------------------------
   after field ramcod

      if fgl_lastkey() = fgl_keyval("up")   or
         fgl_lastkey() = fgl_keyval("left") then
         display by name d_cta00m18a.succod

         if d_cta00m18a.ciaempcod <> 84 then
           next field ciaempcod
         else
           next field itaciacod
         end if

      end if

      if d_cta00m18a.ramcod is null then
         if m_dtresol86 <= today then
            let d_cta00m18a.ramcod = 531
         else
            let d_cta00m18a.ramcod = 31
         end if
      end if

      if d_cta00m18a.ramcod = 80  or
         d_cta00m18a.ramcod = 81  or
         d_cta00m18a.ramcod = 981 or
         d_cta00m18a.ramcod = 982 then
         error " Consulta nao disponivel para este ramo!"
         next field ramcod
      end if

      if d_cta00m18a.ramcod = 31  or
         d_cta00m18a.ramcod = 531  then
         let ws.ramo = "AUTO"
      else
         if d_cta00m18a.ramcod = 91   or
            d_cta00m18a.ramcod = 991  or
            d_cta00m18a.ramcod = 1391 then
            let ws.ramo = "VIDA"
         else
            let ws.ramo = "RE  "
         end if
      end if

       # Obter a descricao do ramo
       call cty10g00_descricao_ramo(d_cta00m18a.ramcod,1)
       returning lr_retorno.resultado
                ,lr_retorno.mensagem
                ,d_cta00m18a.ramnom
                ,m_ramsgl
       if lr_retorno.resultado = 3 then
          call errorlog(lr_retorno.mensagem)
          exit input
       else
          if lr_retorno.resultado = 2 then
             call errorlog(lr_retorno.mensagem)
          end if
       end if

       # Exibir tela popup para escolha do ramo
       if d_cta00m18a.ramnom is null then
          error " Ramo nao cadastrado!" sleep 2
          call c24geral10()
               returning d_cta00m18a.ramcod, d_cta00m18a.ramnom
          next field ramcod
       end if

       call cty10g00_grupo_ramo(g_issk.empcod
                               ,d_cta00m18a.ramcod)
            returning lr_retorno.resultado,
                      lr_retorno.mensagem,
                      mr_documento.ramgrpcod

       # Verifico se e Saude ou Vida
       if mr_documento.ramgrpcod = 5    or
          d_cta00m18a.ramcod     = 991  or
          d_cta00m18a.ramcod     = 1391 then
            let l_resultado = 1
            exit while
       end if

       display by name d_cta00m18a.ramcod
       display by name d_cta00m18a.ramnom

       let mr_atd.ramcod = d_cta00m18a.ramcod
       if d_cta00m18a.ramcod  <>  31 and
          d_cta00m18a.ramcod  <> 531 then
          next field succod
       end if

#----------------------------Before-Vcllicnum-----------------------------------
        before field vcllicnum
           display by name d_cta00m18a.vcllicnum attribute (reverse)
#----------------------------After-Vcllicnum------------------------------------
        after  field vcllicnum
           display by name d_cta00m18a.vcllicnum

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              let d_cta00m18a.vcllicnum = null
              if ws.flag_acesso = 0 then
                 exit input
              end if

              display by name d_cta00m18a.vcllicnum

              if d_cta00m18a.ramcod     <>  31   or
                 d_cta00m18a.ramcod     <> 531   or
                 d_cta00m18a.itmnumdig  is null  then
                 let d_cta00m18a.aplnumdig  = null
                 let ws.aplnumdig          = null
                 let g_documento.aplnumdig = null
              end if

              next field ramcod
           end if

           if d_cta00m18a.vcllicnum  is not null  and
              d_cta00m18a.ramcod     <> 31        and
              d_cta00m18a.ramcod     <> 531       then
              error " Localizacao por licenca somente ramo",
                    " Automovel!"
              next field vcllicnum
           end if

           if d_cta00m18a.vcllicnum  is not null  then
              let ws.aplnumdig          = null
              let ws.itmnumdig          = null
              let ws.ramcod             = null

              if d_cta00m18a.ramcod = 31   or
                 d_cta00m18a.ramcod = 531   then

                 call cta01m61_rec_cliente_placa(d_cta00m18a.vcllicnum)
                 returning lr_retorno.resultado  ,
                           lr_retorno.mensagem   ,
                           lr_cta01m61.cgccpfnum ,
                           lr_cta01m61.cgcord    ,
                           lr_cta01m61.cgccpfdig ,
                           lr_cta01m61.pestip    ,
                           lr_cta01m61.pesnom

                 if lr_retorno.resultado <> 0 then
                      error lr_retorno.mensagem
                      next field vcllicnum
                 end if

              end if

              if lr_cta01m61.cgccpfnum is null  then
                 error " Nenhuma Apolice foi Selecionada!"
                 let d_cta00m18a.succod = ws.salva_succod
                 next field vcllicnum
              end if

              let d_cta00m18a.ramcod = ws.ramcod
              let mr_atd.vcllicnum   = d_cta00m18a.vcllicnum

              exit input
           end if

           if ws.flag_acesso = 0 and
              d_cta00m18a.vcllicnum is null then
              next field vcllicnum
           else
               next field succod
           end if

#----------------------------Before-Succod--------------------------------------
       before field succod
          display by name d_cta00m18a.succod  attribute (reverse)

#----------------------------After-Succod---------------------------------------
       after  field succod
          display by name d_cta00m18a.succod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             if d_cta00m18a.ramcod  =  31   or
                d_cta00m18a.ramcod  =  531  then
                next field vcllicnum
             end if
                next field ramcod
          end if

          if d_cta00m18a.succod is null  then
             let d_cta00m18a.succod = 01
             display by name d_cta00m18a.succod
          end if

          let ws.salva_succod = d_cta00m18a.succod

          # Obter o Nome da Sucursal
          call f_fungeral_sucursal(d_cta00m18a.succod)
          returning d_cta00m18a.sucnom

          if d_cta00m18a.sucnom is null then
             error " Sucursal nao cadastrada!"
             # Exibe Tela Popup para Escolha da Sucursal
             call c24geral11()
                  returning d_cta00m18a.succod, d_cta00m18a.sucnom
             next field succod
          end if

          display by name d_cta00m18a.succod
          display by name d_cta00m18a.sucnom

#----------------------------Before-Aplnumdig-----------------------------------
         before field aplnumdig
            display by name d_cta00m18a.aplnumdig attribute (reverse)

#----------------------------After-Aplnumdig------------------------------------
         after  field aplnumdig
         display by name d_cta00m18a.aplnumdig

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            let d_cta00m18a.aplnumdig = null
            display by name d_cta00m18a.aplnumdig
            next field succod
         end if

         if d_cta00m18a.aplnumdig     = 0 then
            let d_cta00m18a.aplnumdig = null
            display by name d_cta00m18a.aplnumdig
         end if

         let ws.aplnumdig = null

         if d_cta00m18a.aplnumdig is not null  then
            call F_FUNDIGIT_DIGAPOL (d_cta00m18a.succod,
                                     d_cta00m18a.ramcod,
                                     d_cta00m18a.aplnumdig)
                 returning ws.aplnumdig
            if ws.aplnumdig is null  then
               error " Problemas no digito da apolice ! AVISE A INFORMATICA!"
               let ws.aplnumdig = null
               next field aplnumdig
            else
               let g_documento.aplnumdig = ws.aplnumdig
            end if
         end if

         # Recupera Apolice de RE
         if d_cta00m18a.aplnumdig is not null  then
              if d_cta00m18a.ramcod <> 531 and
                 d_cta00m18a.ramcod <> 31  then
                  call cta01m61_rec_cliente_apolice(d_cta00m18a.succod   ,
                                                    d_cta00m18a.ramcod   ,
                                                    ws.aplnumdig         ,
                                                    d_cta00m18a.itmnumdig,
                                                    m_ramsgl             ,
                                                    d_cta00m18a.itaciacod)
                  returning lr_retorno.resultado  ,
                            lr_retorno.mensagem   ,
                            lr_cta01m61.cgccpfnum ,
                            lr_cta01m61.cgcord    ,
                            lr_cta01m61.cgccpfdig ,
                            lr_cta01m61.pesnom    ,
                            lr_cta01m61.pestip
                  if lr_retorno.resultado <> 0 then
                       error lr_retorno.mensagem
                       next field aplnumdig
                  else
                       let g_index   = 1
                       let g_dctoarray[1].succod    = d_cta00m18a.succod
                       let g_dctoarray[1].ramcod    = d_cta00m18a.ramcod
                       let g_dctoarray[1].aplnumdig = ws.aplnumdig
                       exit input
                  end if
              end if
           end if

         if d_cta00m18a.aplnumdig  is null  then
            next field doctip
         end if

#----------------------------Before-Itmnumdig-----------------------------------
       before field itmnumdig
          let l_result_azul = 0
          display by name d_cta00m18a.itmnumdig attribute (reverse)

#----------------------------After-Itmnumdig------------------------------------
       after  field itmnumdig
          display by name d_cta00m18a.itmnumdig

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             initialize d_cta00m18a.itmnumdig  to null
             display by name d_cta00m18a.itmnumdig
             next field aplnumdig
          end if

          if d_cta00m18a.itmnumdig  =  0    then
             initialize  d_cta00m18a.itmnumdig  to null
             display by name d_cta00m18a.itmnumdig
          end if

          if d_cta00m18a.aplnumdig  is not null   then
             let g_index                        =  1
             let g_dctoarray[g_index].succod    =  d_cta00m18a.succod
             let g_dctoarray[g_index].aplnumdig =  d_cta00m18a.aplnumdig


             case d_cta00m18a.ciaempcod
                   when 1 # Porto

                        if d_cta00m18a.itmnumdig is null   then

                           call cta00m13(d_cta00m18a.succod, ws.aplnumdig)
                                returning d_cta00m18a.itmnumdig

                           if d_cta00m18a.itmnumdig   is null   then
                              error " Nenhum item  da apolice foi selecionado!"
                              next field  itmnumdig
                           else
                              display by name d_cta00m18a.itmnumdig
                           end if

                        end if

                        call F_FUNDIGIT_DIGITO11 (d_cta00m18a.itmnumdig)
                             returning ws.itmnumdig

                        if d_cta00m18a.itmnumdig  is null   then
                           error " Problemas no digito do item. AVISE A INFORMATICA!"
                           next field itmnumdig
                        end if

                        #-- Consistir o item na apolice --#
                        let ws.flag = cty05g00_consiste_item(d_cta00m18a.succod
                                                            ,ws.aplnumdig
                                                            ,ws.itmnumdig)

                        if ws.flag = 2 then
                           error " Item informado nao existe nesta apolice!"
                           let d_cta00m18a.itmnumdig = null
                           next field itmnumdig
                        end if

                        #-- Obter ultima situacao da apolice de Auto --#
                        call f_funapol_ultima_situacao
                             (d_cta00m18a.succod, ws.aplnumdig, ws.itmnumdig)
                              returning  g_funapol.*

                        if g_funapol.resultado <> "O"   then
                           error " Ultima situacao da apolice nao encontrada.",
                                 " AVISE A INFORMATICA!"
                           next field succod
                        end if

                   when 35 # Azul

                        call cta00m18_consiste_apol_azul(d_cta00m18a.succod    ,
                                                         d_cta00m18a.aplnumdig ,
                                                         d_cta00m18a.itmnumdig,
                                                         d_cta00m18a.ramcod)
                        returning l_result_azul  ,
                                  l_itmnumdig_aux

                        if l_result_azul = 1 then
                           let ws.aplnumdig          = d_cta00m18a.aplnumdig
                           let d_cta00m18a.itmnumdig = l_itmnumdig_aux
                        end if

                   when 84 # Itau

                        call cta00m18_consiste_apol_itau(d_cta00m18a.itaciacod,
                                                         d_cta00m18a.ramcod   ,
                                                         d_cta00m18a.aplnumdig,
                                                         d_cta00m18a.itmnumdig)
                        returning lr_retorno.resultado,
                                  lr_retorno.mensagem ,
                                  d_cta00m18a.succod  ,
                                  d_cta00m18a.itmnumdig

                        if lr_retorno.resultado <> 0 then
                           error lr_retorno.mensagem
                           next field itmnumdig
                        else
                           let ws.aplnumdig  = d_cta00m18a.aplnumdig
                        end if

             end case
          else

             if d_cta00m18a.itmnumdig  is not null   then
                error " Numero da apolice deve ser informado!"
                next field aplnumdig
             end if
          end if

          # Recupera a Apolice do Auto
          call cta01m61_rec_cliente_apolice(d_cta00m18a.succod   ,
                                            d_cta00m18a.ramcod   ,
                                            ws.aplnumdig         ,
                                            d_cta00m18a.itmnumdig,
                                            m_ramsgl             ,
                                            d_cta00m18a.itaciacod)
          returning lr_retorno.resultado  ,
                    lr_retorno.mensagem   ,
                    lr_cta01m61.cgccpfnum ,
                    lr_cta01m61.cgcord    ,
                    lr_cta01m61.cgccpfdig ,
                    lr_cta01m61.pesnom    ,
                    lr_cta01m61.pestip

          if lr_retorno.resultado <> 0 then
               error lr_retorno.mensagem
               next field aplnumdig
          end if

         exit input

#----------------------------Before-Doctip--------------------------------------
     before field doctip
           display by name d_cta00m18a.doctip  attribute (reverse)

#----------------------------After-Doctip---------------------------------------
      after field doctip
         display by name d_cta00m18a.doctip

         if fgl_lastkey() = fgl_keyval("up") or
            fgl_lastkey() = fgl_keyval("left")then
              let d_cta00m18a.doctip = null
              display by name d_cta00m18a.doctip
              next field aplnumdig
         end if

        case d_cta00m18a.doctip
              when "C"
                 let d_cta00m18a.doctxt = "Cobertura....:"
              when "V"
                 let d_cta00m18a.doctxt = "Vistoria.....:"
              when "P"
                 let d_cta00m18a.doctxt = "Proposta.....:"
         end case

         display by name d_cta00m18a.doctxt

         if d_cta00m18a.doctip is null then
            let d_cta00m18a.doctxt = null
            let d_cta00m18a.doc    = null
            let mr_atd.flgvp       = null
            let mr_atd.vstnumdig   = null
            let mr_atd.flgcp       = null
            let mr_atd.cpbnum      = null

	         display by name d_cta00m18a.doc
	         display by name d_cta00m18a.doctxt

            next field semdocto
         else
            if d_cta00m18a.doctip <> "P" then
               next field doc
            end if
         end if

#----------------------------Before-Prporg--------------------------------------
    before field prporg
         display by name d_cta00m18a.prporg  attribute (reverse)

#----------------------------After-Prporg---------------------------------------
    after field prporg
        display by name d_cta00m18a.prporg

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left")then
             let d_cta00m18a.doctxt = null
             display by name d_cta00m18a.doctxt
             next field doctip
        end if

        if d_cta00m18a.prporg = 0  then

          # Chama o Programa da Proposta
          # ini Psi 223689
          call cty02g01_opacc156()
               returning d_cta00m18a.prporg
                        ,d_cta00m18a.doc
                        ,l_msg

          if d_cta00m18a.prporg is null  or
             d_cta00m18a.doc    is null  then

             if l_msg is null and
                l_msg = " " then
                error " Nenhuma proposta foi selecionada!"
                next field prporg
             else
                error l_msg
             end if  ## Fim Psi 223689
          end if
        end if

#----------------------------Before-Doc-----------------------------------------
    before field doc
         display by name d_cta00m18a.doc  attribute (reverse)

#----------------------------After-Doc-----------------------------------------
    after field doc
        display by name d_cta00m18a.doc

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left")then
             if d_cta00m18a.doctip = "P" then
                 next field prporg
             else
                 let d_cta00m18a.doctxt = null
                 display by name d_cta00m18a.doctxt
                 next field doctip
             end if
        end if

        if d_cta00m18a.doc is null then
           error "Numero do Documento nao pode ser Nulo!"
           next field doc
        end if

        if d_cta00m18a.doc = 0       and
           d_cta00m18a.doctip <> "P" then
           case d_cta00m18a.doctip
               when "V"

                     call cta01m64(d_cta00m18a.doctip)
                     returning d_cta00m18a.doc

                     if d_cta00m18a.doc is null then
                        error "Nenhuma Vistoria Encontrada!"
                        next field doc
                     end if
               when "C"

                      call cta01m64(d_cta00m18a.doctip)
                      returning d_cta00m18a.doc

                     if d_cta00m18a.doc is null then
                         error "Nenhuma Cobertura Encontrada!"
                         next field doc
                      end if
           end case
         end if

        case d_cta00m18a.doctip
           when "P"
                 call cta00m18_trata_proposta(ws.ramo              ,
                                              d_cta00m18a.prporg   ,
                                              d_cta00m18a.doc      )
                 returning ws.erro
                          ,lr_cta01m62.succod
                          ,lr_cta01m62.ramcod
                          ,lr_cta01m62.aplnumdig
                          ,lr_cta01m62.itmnumdig

                 if ws.erro = 1 then
                    next field d_cta00m18a.doc
                 else

                     if lr_cta01m62.aplnumdig is not null then
                         if ws.ramo = "AUTO" then
                             let lr_cta01m62.cod_produto = 1
                         end if
                         if ws.ramo = "RE" then
                             let lr_cta01m62.cod_produto = 2
                         end if
                      else
                         let lr_cta01m62.cod_produto = 96
                         let lr_cta01m62.prporg      = d_cta00m18a.prporg
                         let lr_cta01m62.prpnumdig   = d_cta00m18a.doc
                         call figrc072_setTratarIsolamento()
                         call fpacc280_rec_ramo(ws.ramo              ,
                                                lr_cta01m62.prporg   ,
                                                lr_cta01m62.prpnumdig)
                         returning  lr_cta01m62.ramcod
                         if g_isoAuto.sqlCodErr <> 0 then
                            error "Função fpacc280_rec_ramo indisponivel no momento ! Avise a Informatica !" sleep 2
                            exit input
                         end if
                      end if

                      let ws.pesqdoc = true
                      exit input
                 end if
           when "V"

                 let ws.cont = fvpic012_rec_qtd_vistoria(d_cta00m18a.doc)

                 if ws.cont = 0 then
                    error "Vistoria nao Encontrada!"
                    next field doc
                 end if

                 let lr_cta01m62.cod_produto = 95
                 let lr_cta01m62.documento   = d_cta00m18a.doc
                 let mr_atd.flgvp            = "S"
                 let mr_atd.vstnumdig        = d_cta00m18a.doc
                 let ws.pesqdoc = true
                 exit input
           when "C"

                 let ws.cont = fvpic012_rec_qtd_cobertura(d_cta00m18a.doc)

                 if ws.cont = 0 then
                    error "Cobertura nao Encontrada!"
                    next field doc
                 end if

                 let lr_cta01m62.cod_produto = 94
                 let lr_cta01m62.documento   = d_cta00m18a.doc
                 let mr_atd.flgcp            = "S"
                 let mr_atd.cpbnum           = d_cta00m18a.doc
                 let ws.pesqdoc = true
                 exit input
          end case

#----------------------------Before-Semdocto------------------------------------
      before field semdocto
         display by name d_cta00m18a.semdocto  attribute (reverse)

#----------------------------After-Semdocto-------------------------------------
      after field semdocto
         display by name d_cta00m18a.semdocto

         if fgl_lastkey() = fgl_keyval("up") or
            fgl_lastkey() = fgl_keyval("left")then
             if d_cta00m18a.doctip is null then
                  next field doctip
             else
                  next field doc
             end if
         end if

         if d_cta00m18a.semdocto is null then
               next field ramcod
         end if

         if d_cta00m18a.semdocto <> "S" then
            error 'Opcao invalida, digite "S" para ligacao Sem Docto.' sleep 2
            next field semdocto
         else

            let mr_atd.gera = "S" ---> Como nao abre o Espelho gera
                                  ---> Nro.Atendimento nesta tela

            let g_documento.ciaempcod = d_cta00m18a.ciaempcod

            call cta10m00_entrada_dados()

            let mr_documento.corsus    = g_documento.corsus
            let mr_documento.dddcod    = g_documento.dddcod
            let mr_documento.ctttel    = g_documento.ctttel
            let mr_documento.funmat    = g_documento.funmat
            let mr_documento.cgccpfnum = g_documento.cgccpfnum
            let mr_documento.cgcord    = g_documento.cgcord
            let mr_documento.cgccpfdig = g_documento.cgccpfdig

            if mr_documento.corsus    is null and
               mr_documento.dddcod    is null and
               mr_documento.ctttel    is null and
               mr_documento.funmat    is null and
               mr_documento.cgccpfnum is null and
               mr_documento.cgcord    is null and
               mr_documento.cgccpfdig is null then
               error 'Falta informacoes para registrar Ligacao sem Docto.' sleep 2
               let g_documento.ciaempcod = null
               next field semdocto
            else
                 let l_resultado            = null
                 let mr_documento2.semdocto = 1
                 exit while
            end if

         end if

        on key (interrupt)
             let l_resultado = 1
             exit while

     end input

     if ws.pesqdoc = false then

        if lr_retorno.resultado = 0 then

           call cta01m62(lr_cta01m61.cgccpfnum ,
                         lr_cta01m61.cgcord    ,
                         lr_cta01m61.cgccpfdig ,
                         lr_cta01m61.pesnom    ,
                         lr_cta01m61.pestip    )
              returning  lr_cta01m62.cod_produto
                        ,lr_cta01m62.succod
                        ,lr_cta01m62.ramcod
                        ,lr_cta01m62.aplnumdig
                        ,lr_cta01m62.itmnumdig
                        ,lr_cta01m62.crtsaunum
                        ,lr_cta01m62.segnom
                        ,lr_cta01m62.cgccpfnum
                        ,lr_cta01m62.cgcord
                        ,lr_cta01m62.cgccpfdig
                        ,lr_cta01m62.prporg
                        ,lr_cta01m62.prpnumdig
                        ,lr_cta01m62.documento
                        ,lr_cta01m62.pesnum
                        ,lr_cta01m62.itaciacod

           if lr_cta01m62.cod_produto is null then
              continue while
           end if

           --> Busca Dados do local de Risco ou Bloco p/ Clausulas do docto. RE
           if lr_cta01m62.aplnumdig is not null and
             (lr_cta01m62.cod_produto = 2   or
              lr_cta01m62.cod_produto = 12  or
              lr_cta01m62.cod_produto = 13) then

              initialize g_rsc_re.*
                        ,g_documento.lclnumseq
                        ,g_documento.rmerscseq to null

              while g_rsc_re.lclrsccod is null or
                    g_rsc_re.lclrsccod =  0

                 call framc215(lr_cta01m62.succod
                              ,lr_cta01m62.ramcod
                              ,lr_cta01m62.aplnumdig)
                     returning lr_retorno.resultado
                              ,lr_retorno.mensagem
                              ,g_rsc_re.lclrsccod
                              ,g_rsc_re.lgdtip
                              ,g_rsc_re.lgdnom
                              ,g_rsc_re.lgdnum
                              ,g_rsc_re.lclbrrnom
                              ,g_rsc_re.cidnom
                              ,g_rsc_re.ufdcod
                              ,g_rsc_re.lgdcep
                              ,g_rsc_re.lgdcepcmp
                              ,g_documento.lclnumseq
                              ,g_documento.rmerscseq
                              ,l_rmeblcdes
                              ,g_rsc_re.lclltt
                              ,g_rsc_re.lcllgt

                 if g_rsc_re.lclrsccod is null or
                    g_rsc_re.lclrsccod =  0    then

                    call cts08g01 ("A","N",""
                                  ,"PARA PROSSEGUIR NO ATENDIMENTO, "
                                  ,"SELECIONE UMA DAS OPCOES DA LISTA. ", " " )
                         returning l_confirma
                 end if
              end while
           end if
        else
           continue while
        end if
      else
         let ws.pesqdoc = false
      end if

      # Direciona para qual produto e o Atendimento

      call cta00m18_direciona( lr_cta01m62.cod_produto
                              ,lr_cta01m62.succod
                              ,lr_cta01m62.ramcod
                              ,lr_cta01m62.aplnumdig
                              ,lr_cta01m62.itmnumdig
                              ,lr_cta01m62.crtsaunum
                              ,lr_cta01m62.segnom
                              ,lr_cta01m62.cgccpfnum
                              ,lr_cta01m62.cgcord
                              ,lr_cta01m62.cgccpfdig
                              ,lr_cta01m62.prporg
                              ,lr_cta01m62.prpnumdig
                              ,lr_cta01m62.documento
                              ,lr_cta01m62.pesnum
                              ,lr_cta01m62.itaciacod  )
      returning lr_retorno.resultado

      if lr_retorno.resultado = 1 then
           let l_resultado = null
           exit while
      else
           continue while
      end if

  end while

  ---> Captura de Dados p/ Gerar Atendimento
  if d_cta00m18a.semdocto = "S" then

     if g_documento.cgcord is not null and
        g_documento.cgcord <> 0        then
        let mr_atd.semdoctopestip = "J"
     else
        let mr_atd.semdoctopestip = "F"
     end if

     let mr_atd.semdocto          = d_cta00m18a.semdocto
     let mr_atd.semdoctoempcodatd = g_documento.empcodatd
     let mr_atd.semdoctocgccpfnum = g_documento.cgccpfnum
     let mr_atd.semdoctocgcord    = g_documento.cgcord
     let mr_atd.semdoctocgccpfdig = g_documento.cgccpfdig
     let mr_atd.semdoctocorsus    = g_documento.corsus
     let mr_atd.semdoctofunmat    = g_documento.funmat
     let mr_atd.semdoctoempcod    = g_documento.empcodmat
     let mr_atd.semdoctodddcod    = g_documento.dddcod
     let mr_atd.semdoctoctttel    = g_documento.ctttel
  end if

  close window cta00m18a

  return l_resultado

end function

#------------------------------------------------------------------------------
function cta00m18_consiste_apol_azul(lr_param)
#------------------------------------------------------------------------------

define lr_param record
    succod       like gabksuc.succod      ,
    aplnumdig    like abamdoc.aplnumdig   ,
    itmnumdig    like abbmveic.itmnumdig,
    ramcod       smallint
end record

define lr_retorno record
   aplnumdig     like datrligapol.aplnumdig,
   itmnumdig     like datrligapol.itmnumdig,
   edsnumref     like datrligapol.edsnumref,
   succod        like datrligapol.succod   ,
   ramcod        like datrservapol.ramcod  ,
   emsdat        date                      ,
   viginc        date                      ,
   vigfnl        date                      ,
   segcod        integer                   ,
   segnom        char(50)                  ,
   vcldes        char(25)                  ,
   corsus        char(06)                  ,
   doc_handle    integer                   ,
   resultado     smallint                  ,
   mensagem      char(50)                  ,
   situacao      char(10)
end record

define l_resultado smallint

initialize lr_retorno.* to null
let l_resultado = 0

   if  lr_param.aplnumdig  is not null and
       lr_param.itmnumdig  is not null then

         call cts38m00_dados_apolice(lr_param.succod,
                                     lr_param.aplnumdig,
                                     lr_param.itmnumdig,
                                     lr_param.ramcod)
                           returning lr_retorno.aplnumdig ,
                                     lr_retorno.itmnumdig ,
                                     lr_retorno.edsnumref ,
                                     lr_retorno.succod    ,
                                     lr_retorno.ramcod    ,
                                     lr_retorno.emsdat    ,
                                     lr_retorno.viginc    ,
                                     lr_retorno.vigfnl    ,
                                     lr_retorno.segcod    ,
                                     lr_retorno.segnom    ,
                                     lr_retorno.vcldes    ,
                                     lr_retorno.corsus    ,
                                     lr_retorno.doc_handle,
                                     lr_retorno.resultado ,
                                     lr_retorno.mensagem  ,
         		             lr_retorno.situacao

          if  lr_retorno.resultado <> 1 then
              let l_resultado = 0
          else
             call cta00m07_sit_apol(lr_retorno.vigfnl,
                                    lr_retorno.situacao)
                  returning lr_retorno.resultado

             if lr_retorno.resultado = 1 then
                 let l_resultado = 1
             else
                 let l_resultado = 0
             end if

          end if

    else
          call cts38m00_busca_itens_apolice(lr_param.succod  ,
                                            lr_param.aplnumdig)
                                  returning lr_retorno.aplnumdig ,
                                            lr_retorno.itmnumdig ,
                                            lr_retorno.edsnumref ,
                                            lr_retorno.succod    ,
                                            lr_retorno.ramcod    ,
                                            lr_retorno.emsdat    ,
                                            lr_retorno.viginc    ,
                                            lr_retorno.vigfnl    ,
                                            lr_retorno.segcod    ,
                                            lr_retorno.segnom    ,
                                            lr_retorno.vcldes    ,
                                            lr_retorno.corsus    ,
                                            lr_retorno.doc_handle,
                                            lr_retorno.resultado ,
                                            lr_retorno.mensagem  ,
          			            lr_retorno.situacao
          if  lr_retorno.resultado <> 1 then
              let l_resultado = 0
          else

             call cta00m07_sit_apol(lr_retorno.vigfnl,
                                    lr_retorno.situacao)
                  returning lr_retorno.resultado
             if lr_retorno.resultado = 1 then
                 let l_resultado = 1
             else
                 let l_resultado = 0
             end if
          end if
     end if

     return l_resultado ,
            lr_retorno.itmnumdig

end function

#------------------------------------------------------------------------------
function cta00m18_consiste_apol_itau(lr_param)
#------------------------------------------------------------------------------

define lr_param record
    itaciacod     like datmitaapl.itaciacod       ,
    itaramcod     like datmitaapl.itaramcod       ,
    itaaplnum     like datmitaapl.itaaplnum       ,
    itaaplitmnum  like datmitaaplitm.itaaplitmnum
end record

define lr_retorno record
       qtd          integer                       ,
       aplseqnum    like datmitaapl.aplseqnum     ,
       erro         integer                       ,
       mensagem     char(50)                      ,
       succod       like datmitaapl.succod
end record

initialize lr_retorno.* to null
let lr_retorno.erro = 0


     if lr_param.itaciacod is not null and
        lr_param.itaramcod is not null and
        lr_param.itaaplnum is not null then


           # Verifica se Apolice Existe

           call cty22g00_qtd_apolice(lr_param.itaciacod,
                                     lr_param.itaramcod,
                                     lr_param.itaaplnum)
           returning lr_retorno.qtd

           if lr_retorno.qtd = 0 then
              let lr_retorno.mensagem =  "Apolice Nao Encontrada!"
              let lr_retorno.erro     = 1
           else

              # Verifica a Ultima Sequencia da Apolice

              call cty22g00_rec_ult_sequencia(lr_param.itaciacod,
                                              lr_param.itaramcod,
                                              lr_param.itaaplnum)
              returning lr_retorno.aplseqnum,
                        lr_retorno.erro     ,
                        lr_retorno.mensagem

              if lr_retorno.erro <> 0 then
                 let lr_retorno.erro = 1
              end if

           end if

           if lr_retorno.erro = 0 then

              # Recupera o Item da Apolice

              call cta00m29(lr_param.itaciacod    ,
                            lr_param.itaramcod    ,
                            lr_param.itaaplnum    ,
                            lr_retorno.aplseqnum  ,
                            lr_param.itaaplitmnum )
              returning lr_param.itaaplitmnum,
                        lr_retorno.succod   ,
                        lr_retorno.erro     ,
                        lr_retorno.mensagem

              if lr_retorno.erro <> 0 then
                 let lr_retorno.erro = 1
              end if

           end if

     else
          let lr_retorno.mensagem =  "Apolice Nao Encontrada!"
          let lr_retorno.erro     = 1
     end if

   return  lr_retorno.erro       ,
           lr_retorno.mensagem   ,
           lr_retorno.succod     ,
           lr_param.itaaplitmnum


end function

#-----------------------------------------#
function cta00m18_trata_proposta(lr_param)
#-----------------------------------------#

define lr_param  record
       ramo      char(10)
      ,prporg    like datrligprp.prporg
      ,prpnumdig like datrligprp.prpnumdig
end record

define lr_retorno  record
       resultado   smallint
      ,succod      like abamapol.succod
      ,ramcod      like gtakram.ramcod
      ,aplnumdig   like abamapol.aplnumdig
      ,itmnumdig   like abbmitem.itmnumdig
end record

initialize lr_retorno.* to null

   if lr_param.ramo      is not null and
      lr_param.prporg    is not null and
      lr_param.prpnumdig is not null then
      let lr_retorno.resultado = 0

      if lr_param.ramo = "AUTO" then
         call cta00m03(lr_param.prporg, lr_param.prpnumdig)
            returning lr_retorno.succod
                     ,lr_retorno.ramcod
                     ,lr_retorno.aplnumdig
                     ,lr_retorno.itmnumdig
      else
         if lr_param.ramo = "RE" then
            call cta00m15(lr_param.prporg, lr_param.prpnumdig)
               returning lr_retorno.succod
                        ,lr_retorno.ramcod
                        ,lr_retorno.aplnumdig
         end if
      end if

   else
      let lr_retorno.resultado = 1
      error "Parametros Nulos"
   end if

   return lr_retorno.*

end function
