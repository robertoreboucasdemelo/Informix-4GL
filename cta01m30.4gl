#############################################################################
# Nome do Modulo: CTA01M30                                         Roberto  #
#                                                                  Jun/2007 #
#  Localizacao do Segurado                                                  #
#############################################################################
# ........................................................................... #
#                                                                             #
#                          * * * ALTERACOES * * *                             #
#                                                                             #
# Data       Autor           Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
# 18/09/2007 Saulo, Meta     AS149675   Novas variaveis globais populadas:    #
#                                       g_segnumdig, g_cgccpfnum, g_cgccpfdig #
#-----------------------------------------------------------------------------#
# 21/09/2007 Saulo, Meta     AS149675   Incluida a funcao cta01m30_popup      #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals '/homedsa/projetos/geral/globals/gpvia021.4gl'

define mr_documento   record
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
       sinitmseq     like ssamitem.sinitmseq,      # Prd Parcial - Item p/ramo 53
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
       corsus        like gcaksusep.corsus      ,
       dddcod        like datmreclam.dddcod     ,  # codigo da area de discagem
       ctttel        like datmreclam.ctttel     ,  # numero do telefone
       funmat        like isskfunc.funmat       ,  # matricula do funcionario
       cgccpfnum     like gsakseg.cgccpfnum     ,  # numero do CGC(CNPJ)
       cgcord        like gsakseg.cgcord        ,  # filial do CGC(CNPJ)
       cgccpfdig     like gsakseg.cgccpfdig     ,  # digito do CGC(CNPJ) ou CPF
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
       averbacao     like datrligtrpavb.trpavbnum,
       crtsaunum     like datksegsau.crtsaunum,
       bnfnum        like datksegsau.bnfnum,
       ramgrpcod     like gtakram.ramgrpcod
end record


define mr_ppt        record
       segnumdig     like gsakseg.segnumdig,
       cmnnumdig     like pptmcmn.cmnnumdig,
       endlgdtip     like rlaklocal.endlgdtip,
       endlgdnom     like rlaklocal.endlgdnom,
       endnum        like rlaklocal.endnum,
       ufdcod        like rlaklocal.ufdcod,
       endcmp        like rlaklocal.endcmp,
       endbrr        like rlaklocal.endbrr,
       endcid        like rlaklocal.endcid,
       endcep        like rlaklocal.endcep,
       endcepcmp     like rlaklocal.endcepcmp,
       edsstt        like rsdmdocto.edsstt,
       viginc        like rsdmdocto.viginc,
       vigfnl        like rsdmdocto.vigfnl,
       emsdat        like rsdmdocto.emsdat,
       corsus        like rsampcorre.corsus,
       pgtfrm        like rsdmdadcob.pgtfrm,
       mdacod        like gfakmda.mdacod,
       lclrsccod     like rlaklocal.lclrsccod
end record


define m_array      array[5000] of record
       segnumdig     like gsakseg.segnumdig    ,
       segnom        like gsakseg.segnom       ,
       pestip        like gsakseg.pestip       ,
       cgccpfnum     like gsakseg.cgccpfnum    ,
       cgcord        like gsakseg.cgcord       ,
       cgccpfdig     like gsakseg.cgccpfdig    ,
       nscdat        like gsakseg.nscdat
end record

define m_cta01m32 record
       ramcod      like datrservapol.ramcod   ,
       succod      like datrligapol.succod    ,
       aplnumdig   like datrligapol.aplnumdig ,
       prporg      like datrligprp.prporg     ,
       prpnumdig   like datrligprp.prpnumdig  ,
       segnumdig   like gsakseg.segnumdig  ,
       cgccpfnum   like gsakseg.cgccpfnum     ,
       cgcord      like gsakseg.cgcord        ,
       cgccpfdig   like gsakseg.cgccpfdig     ,
       cornom      like gcakcorr.cornom       ,
       corsus      like gcaksusep.corsus
end record

define m_ret smallint

#----------------------------------------------------------------------
function cta01m30(l_param)
#----------------------------------------------------------------------

define l_param record
       solnom            like datmligacao.c24solnom   ,
       c24soltipcod      like datmligacao.c24soltipcod,
       c24soltipdes      char (40)                    ,
       ramcod            like gtakram.ramcod          ,
       ramnom            like gtakram.ramnom          ,
       funmatatd         like isskfunc.funmat         ,
       c24astcod         char(03)                     ,
       c24paxnum         integer                      ,
       succod            like datmatd6523.succod      ,
       aplnumdig         like datmatd6523.aplnumdig   ,
       segnom            like datmatd6523.segnom      ,
       pestip            like datmatd6523.pestip      ,
       cgccpfnum         like datmatd6523.cgccpfnum   ,
       cgcord            like datmatd6523.cgcord      ,
       cgccpfdig         like datmatd6523.cgccpfdig   ,
       prporg            like datmatd6523.prporg      ,
       prpnumdig         like datmatd6523.prpnumdig   ,
       semdcto           like datmatd6523.semdcto
end record

define l_cta01m30    record
   solnom            like datmligacao.c24solnom,
   ramcod            like gtakram.ramcod       ,
   succod            like gabksuc.succod,
   sucnom            like gabksuc.sucnom,
   aplnumdig         like abamdoc.aplnumdig,
   segnom            char (40),
   pestip            char (01),
   cgccpfnum         like gsakseg.cgccpfnum,
   cgcord            like gsakseg.cgcord,
   cgccpfdig         like gsakseg.cgccpfdig,
   prporg            like datrligprp.prporg,
   prpnumdig         like datrligprp.prpnumdig,
   semdocto          char (01),
   atdnum            char (24)
end record

define ws            record
       segnom        char (40)              ,
       cgccpfdig     like gsakseg.cgccpfdig
end record


define l_fon record
       erro       smallint
end record

define l_cta01m31  record
       segnumdig     like gsakseg.segnumdig   ,
       segnom        like gsakseg.segnom      ,
       pestip        like gsakseg.pestip      ,
       cgccpfnum     like gsakseg.cgccpfnum   ,
       cgcord        like gsakseg.cgcord      ,
       cgccpfdig     like gsakseg.cgccpfdig   ,
       nscdat        like gsakseg.nscdat      ,
       prporg        dec(2,0)                 ,   ---> Funeral
       prpnumdig     dec(8,0)                     ---> Funeral
end record


define l_cont      integer
define l_asterisco char(1)
define l_flag      char(01)
define m_arraycont integer
define aux_segnom  char(50)
define l_sel       smallint
define l_erro      smallint
define l_flag1     smallint
define l_qtd_seg   integer

    ---> Funeral - Previdencia
    define l_ret record
        coderro         integer,
        menserro        char(30),
        qtdlinhas       smallint
    end record


let g_documento.c24soltipcod  = l_param.c24soltipcod
let g_documento.solnom        = l_param.solnom
let g_documento.c24astcod     = l_param.c24astcod
let g_documento.funmatatd     = l_param.funmatatd
let g_c24paxnum               = l_param.c24paxnum
let g_documento.soltip        = l_param.c24soltipdes[1,1]
let g_documento.ramcod        = l_param.ramcod

let l_flag1   = 0
let l_qtd_seg = 0

    ---> Funeral - Previdencia
    initialize l_ret.* to null
    initialize g_prporg, g_prpnumdig to null

open window cta01m30 at 05,02 with form "cta01m30"
                     attribute(border,form line 1)



while true

initialize mr_documento.* to null
initialize l_cta01m30.*   to null
initialize ws.*           to null
initialize mr_ppt.*       to null
initialize l_fon.*        to null
initialize l_cta01m31.*   to null
initialize m_cta01m32.*   to null


for m_arraycont  =  1  to  5000
    initialize m_array[m_arraycont].* to null
end for


let l_flag     = null
let aux_segnom = null
let l_sel      = null
let l_erro     = null

if g_documento.atdnum < 0 then
   let g_documento.atdnum = 0
end if

if g_documento.atdnum is not null and
   g_documento.atdnum <> 0        then

   ---> Nome da Sucursal
   call f_fungeral_sucursal(l_param.succod)
        returning l_cta01m30.sucnom

   let l_cta01m30.succod    = l_param.succod
   let l_cta01m30.aplnumdig = l_param.aplnumdig
   let l_cta01m30.segnom    = l_param.segnom
   let l_cta01m30.pestip    = l_param.pestip
   let l_cta01m30.cgccpfnum = l_param.cgccpfnum
   let l_cta01m30.cgcord    = l_param.cgcord
   let l_cta01m30.cgccpfdig = l_param.cgccpfdig
   let l_cta01m30.prporg    = l_param.prporg
   let l_cta01m30.prpnumdig = l_param.prpnumdig
   let l_cta01m30.semdocto  = l_param.semdcto

   display by name l_cta01m30.succod
   display by name l_cta01m30.aplnumdig
   display by name l_cta01m30.segnom
   display by name l_cta01m30.pestip
   display by name l_cta01m30.cgccpfnum
   display by name l_cta01m30.cgcord
   display by name l_cta01m30.cgccpfdig
   display by name l_cta01m30.prporg
   display by name l_cta01m30.prpnumdig
   display by name l_cta01m30.semdocto

end if


input by name l_cta01m30.*  without defaults

#----------------------------Before-Solnom-----------------------------------------

before field solnom


     display by name l_param.solnom
     display by name l_param.c24soltipcod
     display by name l_param.c24soltipdes
     display by name l_param.ramcod
     display by name l_param.ramnom

#----------------------------Before-Succod-----------------------------------------

       before field succod

          display by name l_cta01m30.succod  attribute (reverse)

#----------------------------After-Succod-----------------------------------------

       after  field succod


          ---> Previdencia - Funeral
          initialize g_a_psqseg to null
          initialize g_a_psqaplseg to null
          initialize g_a_psqdadseg to null
          initialize g_a_psqbnfapl to null
          initialize g_a_psqvlrbnf to null

          display by name l_cta01m30.succod


          if l_cta01m30.succod is null  then
             let l_cta01m30.succod = 01
             display by name l_cta01m30.succod
          end if


          #-- Obter o nome da sucursal --#

          call f_fungeral_sucursal(l_cta01m30.succod)
          returning l_cta01m30.sucnom


          if l_cta01m30.sucnom is null then

             error " Sucursal nao cadastrada!"

             #-- Exibe tela popup para escolha da sucursal

             call c24geral11()
                  returning l_cta01m30.succod, l_cta01m30.sucnom

             next field succod
          end if

          display by name l_cta01m30.succod
          display by name l_cta01m30.sucnom

#----------------------------Before-Aplnumdig-----------------------------------------

       before field aplnumdig
          display by name l_cta01m30.aplnumdig attribute (reverse)

#----------------------------After-Aplnumdig-----------------------------------------

       after  field aplnumdig

          display by name l_cta01m30.aplnumdig

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             let l_cta01m30.aplnumdig = null
             display by name l_cta01m30.aplnumdig
             next field succod
          end if

          if l_cta01m30.aplnumdig = 0 then
             let l_cta01m30.aplnumdig = null
             display by name l_cta01m30.aplnumdig
          end if

          if l_cta01m30.aplnumdig is not null then
             let m_cta01m32.aplnumdig = l_cta01m30.aplnumdig
                exit input
          end if

#----------------------------Before-Segnom-----------------------------------------

       before field segnom
          display by name l_cta01m30.segnom attribute (reverse)

#----------------------------After-Segnom-----------------------------------------

       after  field segnom
         display by name l_cta01m30.segnom


         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            initialize l_cta01m30.segnom  to null
            initialize l_cta01m30.pestip to null
            display by name l_cta01m30.segnom
            display by name l_cta01m30.pestip

            next field aplnumdig
         end if

         if l_cta01m30.segnom is not null then

            if length(l_cta01m30.segnom) < 10 then
               error "Especifique a consulta, digite um nome que tenha mais que 10 letras!"
               next field segnom
            end if

            let ws.segnom   = l_cta01m30.segnom  clipped ,"*"

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

#----------------------------Before-Pestip-----------------------------------------

       before field pestip
          display by name l_cta01m30.pestip attribute (reverse)

#----------------------------After-Pestip-----------------------------------------

       after  field pestip
          display by name l_cta01m30.pestip

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             initialize l_cta01m30.cgccpfnum  to null
             initialize l_cta01m30.cgcord     to null
             initialize l_cta01m30.cgccpfdig  to null
             display by name l_cta01m30.cgccpfnum
             display by name l_cta01m30.cgcord
             display by name l_cta01m30.cgccpfdig
             next field segnom
          end if

          if l_cta01m30.pestip <> "F" and
             l_cta01m30.pestip <> "J" then
               error "Informe Apenas <F> ou <J> !"
               next field pestip
          end if


          if l_cta01m30.cgccpfnum is null     and
             l_cta01m30.pestip    is not null and
             l_cta01m30.segnom    is not null then

             initialize g_a_psqseg to null

             let m_arraycont = 0


                    let l_qtd_seg = cty05g00_qtd_segurado(l_cta01m30.segnom)


                    if l_qtd_seg = 0 or
                       l_qtd_seg is null then

                       initialize g_a_psqseg to null
                       call fpvia21_pesquisa_segurado(l_cta01m30.prporg
                                                     ,l_cta01m30.prpnumdig
                                                     ,l_cta01m30.cgccpfnum
                                                     ,0
                                                     ,l_cta01m30.cgccpfdig
                                                     ,l_cta01m30.segnom
                                                     ,l_cta01m30.succod
                                                     ,l_param.ramcod
                                                     ,l_cta01m30.aplnumdig)
                                            returning l_ret.*
                                            #---> Variaveis g_a_psqseg carregadas

                           if l_ret.qtdlinhas = 0 then
                              error " Nenhum segurado foi localizado. "
                                   ,l_ret.coderro
                              initialize g_a_psqseg to null
                              next field segnom
                           end if
                    else
                       if l_qtd_seg > 150  then
                          error " Mais de 150 registros selecionados,",
                                " complemente o nome do segurado!"
                          next field segnom
                       end if
                    end if

                    # - Recupera os Segurados

                   let l_fon.erro = cty05g00_segnumdig_vida(l_cta01m30.segnom    ,
                                                            l_cta01m30.pestip    )


                   if l_fon.erro = 1 then
                      error "Erro na Funcao cty05g00!"
                      next field segnom
                   end if


                   declare c_cta01m30_001 cursor for
                   select * from cty05g00_temp
                   order by 2
                   open c_cta01m30_001
                   foreach  c_cta01m30_001 into l_cta01m31.segnumdig   ,
                                              l_cta01m31.segnom      ,
                                              l_cta01m31.pestip      ,
                                              l_cta01m31.cgccpfnum   ,
                                              l_cta01m31.cgcord      ,
                                              l_cta01m31.cgccpfdig   ,
                                              l_cta01m31.nscdat      ,
                                              l_cta01m31.prporg      , ---> Funeral
                                              l_cta01m31.prpnumdig     ---> Funeral

                      let m_arraycont = m_arraycont + 1

                      if  m_arraycont > 500 then
                          exit foreach
                      end if

                      let m_array[m_arraycont].segnumdig    = l_cta01m31.segnumdig
                      let m_array[m_arraycont].segnom       = l_cta01m31.segnom
                      let m_array[m_arraycont].cgccpfnum    = l_cta01m31.cgccpfnum
                      let m_array[m_arraycont].cgcord       = l_cta01m31.cgcord
                      let m_array[m_arraycont].cgccpfdig    = l_cta01m31.cgccpfdig
                      let m_array[m_arraycont].pestip       = l_cta01m31.pestip
                      let m_array[m_arraycont].nscdat       = l_cta01m31.nscdat


                   end foreach

                   if m_arraycont = 0 then

                       initialize g_a_psqseg to null
                       call fpvia21_pesquisa_segurado(l_cta01m30.prporg
                                                     ,l_cta01m30.prpnumdig
                                                     ,l_cta01m30.cgccpfnum
                                                     ,0
                                                     ,l_cta01m30.cgccpfdig
                                                     ,l_cta01m30.segnom
                                                     ,l_cta01m30.succod
                                                     ,l_param.ramcod
                                                     ,l_cta01m30.aplnumdig)
                                          returning l_ret.*
                                          #---> Variaveis g_a_psqseg carregadas

                     if l_ret.qtdlinhas = 0 then
                        error "Segurado nao encontrado para este Ramo!(01)"
                              ,l_ret.coderro
                        initialize g_a_psqseg to null
                        next field segnom
                     end if
                   end if

                   if m_arraycont     > 500 or
                      l_ret.qtdlinhas > 500 then ---> Funeral - Previdencia
                       error "Consulta ultrapassou 500 registros!"
                       initialize g_a_psqseg to null
                       next field segnom
                   end if

                   # Se o filtro achou somente um Segurado nao abro a tela de Consulta (cta01m31)

                   if m_arraycont = 1 then

                       display by name l_cta01m31.segnom
                       display by name l_cta01m31.cgccpfnum
                       display by name l_cta01m31.cgcord
                       display by name l_cta01m31.cgccpfdig

                       let m_cta01m32.segnumdig = m_array[m_arraycont].segnumdig
                       let m_cta01m32.cgccpfnum = m_array[m_arraycont].cgccpfnum
                       let m_cta01m32.cgcord    = m_array[m_arraycont].cgcord
                       let m_cta01m32.cgccpfdig = m_array[m_arraycont].cgccpfdig

                       let g_segnumdig = m_cta01m32.segnumdig
                       let g_cgccpfnum = m_cta01m32.cgccpfnum
                       let g_cgccpfdig = m_cta01m32.cgccpfdig

                       let l_sel = null
                       exit input

                   end if

                   ---> Funeral - Previdencia
                   if l_ret.qtdlinhas = 1 then

                       display by name l_cta01m31.segnom
                       display by name l_cta01m31.cgccpfnum
                       display by name l_cta01m31.cgcord
                       display by name l_cta01m31.cgccpfdig

                       let m_cta01m32.segnumdig = 0
                       let m_cta01m32.cgccpfnum = g_a_psqseg[1].cgccpfnum
                       let m_cta01m32.cgcord    = 0
                       let m_cta01m32.cgccpfdig = g_a_psqseg[1].cgccpfdig

                       let g_segnumdig = m_cta01m32.segnumdig
                       let g_cgccpfnum = m_cta01m32.cgccpfnum
                       let g_cgccpfdig = m_cta01m32.cgccpfdig

                       let l_sel = null
                       exit input

                   end if

                   let l_sel = 1

                   exit input
          end if



#----------------------------Before-Cgccpfnum-----------------------------------------

       before field cgccpfnum
          display by name l_cta01m30.cgccpfnum   attribute(reverse)

#----------------------------After-Cgccpfnum-----------------------------------------

       after  field cgccpfnum
          display by name l_cta01m30.cgccpfnum

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field pestip
          end if

          if l_cta01m30.cgccpfnum is null then
                  next field prporg
          end if


          if l_cta01m30.pestip is null then
             error "Informe o Tipo de Pessoa!"
             next field pestip
          end if


          if l_cta01m30.pestip = "F" then
             next field cgccpfdig
          end if

#----------------------------Before-Cgcord-----------------------------------------

       before field cgcord
          display by name l_cta01m30.cgcord   attribute(reverse)

#----------------------------After-Cgcord-----------------------------------------

       after  field cgcord
          display by name l_cta01m30.cgcord

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field cgccpfnum
          end if



          if l_cta01m30.cgcord   is null   or
             l_cta01m30.cgcord   =  0      then
             error " Filial do CGC deve ser informada!"
             next field cgcord
          end if

#----------------------------Before-Cgccpfdig-----------------------------------------

       before field cgccpfdig
          display by name l_cta01m30.cgccpfdig  attribute(reverse)

#----------------------------After-Cgccpfdig-----------------------------------------

       after  field cgccpfdig
          display by name l_cta01m30.cgccpfdig

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             if l_cta01m30.pestip =  "J"  then
                next field cgcord
             else
                next field cgccpfnum
             end if
          end if

          if l_cta01m30.cgccpfdig   is null   then
             error " Digito do CGC/CPF deve ser informado!"
             next field cgccpfdig
          end if

          if l_cta01m30.pestip =  "J"    then
             call F_FUNDIGIT_DIGITOCGC(l_cta01m30.cgccpfnum,
                                       l_cta01m30.cgcord)
                  returning ws.cgccpfdig
          else
             call F_FUNDIGIT_DIGITOCPF(l_cta01m30.cgccpfnum)
                  returning ws.cgccpfdig
          end if

          if ws.cgccpfdig          is null            or
             l_cta01m30.cgccpfdig  <>  ws.cgccpfdig   then
             error " Digito do CGC/CPF incorreto!"
             next field cgccpfdig
          else

             # - Recupero o Segurado

             let l_fon.erro = cty05g00_cgccpf_vida(l_cta01m30.cgccpfnum  ,
                                                   l_cta01m30.cgccpfdig  ,
                                                   l_cta01m30.pestip     )



             if l_fon.erro = 1 then
                error "Erro na Funcao cty05g00!"
                next field cgccpfnum
             end if

             ---> Funeral - Consulta por cpf
             initialize m_array to null
             initialize l_cta01m31.* to null
             let m_arraycont = 0

             declare ccta00m01030 cursor for
             select * from cty05g00_temp
             order by 2
             open ccta00m01030
             foreach  ccta00m01030 into l_cta01m31.segnumdig   ,
                                        l_cta01m31.segnom      ,
                                        l_cta01m31.pestip      ,
                                        l_cta01m31.cgccpfnum   ,
                                        l_cta01m31.cgcord      ,
                                        l_cta01m31.cgccpfdig   ,
                                        l_cta01m31.nscdat      ,
                                        l_cta01m31.prporg      ,   ---> Funeral
                                        l_cta01m31.prpnumdig       ---> Funeral

                let m_arraycont = m_arraycont + 1

                if  m_arraycont > 500 then
                    exit foreach
                end if

                let m_array[m_arraycont].segnumdig    = l_cta01m31.segnumdig
                let m_array[m_arraycont].segnom       = l_cta01m31.segnom
                let m_array[m_arraycont].cgccpfnum    = l_cta01m31.cgccpfnum
                let m_array[m_arraycont].cgcord       = l_cta01m31.cgcord
                let m_array[m_arraycont].cgccpfdig    = l_cta01m31.cgccpfdig
                let m_array[m_arraycont].pestip       = l_cta01m31.pestip
                let m_array[m_arraycont].nscdat       = l_cta01m31.nscdat
             end foreach
             if m_arraycont = 0 then

                       initialize g_a_psqseg to null
                       call fpvia21_pesquisa_segurado(l_cta01m30.prporg
                                                     ,l_cta01m30.prpnumdig
                                                     ,l_cta01m30.cgccpfnum
                                                     ,0
                                                     ,l_cta01m30.cgccpfdig
                                                     ,l_cta01m30.segnom
                                                     ,l_cta01m30.succod
                                                     ,l_param.ramcod
                                                     ,l_cta01m30.aplnumdig)
                                          returning l_ret.*
                                          #---> Variaveis g_a_psqseg carregadas

                     if l_ret.qtdlinhas = 0 then
                        error "Segurado nao encontrado para esta Consulta!"
                              ,l_ret.coderro
                        initialize g_a_psqseg to null
                        next field segnom
                     end if
             end if
             if m_arraycont > 500 or
                l_ret.qtdlinhas > 500 then ---> Funeral - Previdencia
                 error "Consulta ultrapassou 500 registros!"
                 initialize g_a_psqseg to null
                 next field segnom
             end if
             # Se o filtro achou somente um Segurado nao abro a tela de Consulta (cta01m31)
             if m_arraycont = 1 then
                 display by name l_cta01m31.segnom

                 display by name l_cta01m31.cgccpfnum
                 display by name l_cta01m31.cgcord
                 display by name l_cta01m31.cgccpfdig
                 let m_cta01m32.segnumdig = m_array[m_arraycont].segnumdig
                 let m_cta01m32.cgccpfnum = m_array[m_arraycont].cgccpfnum
                 let m_cta01m32.cgcord    = m_array[m_arraycont].cgcord
                 let m_cta01m32.cgccpfdig = m_array[m_arraycont].cgccpfdig
                 let g_segnumdig = m_cta01m32.segnumdig
                 let g_cgccpfnum = m_cta01m32.cgccpfnum
                 let g_cgccpfdig = m_cta01m32.cgccpfdig
                 let l_sel = null
                 exit input
             end if

             ---> Funeral - Previdencia
             if l_ret.qtdlinhas = 1 then

                display by name l_cta01m31.segnom
                display by name l_cta01m31.cgccpfnum
                display by name l_cta01m31.cgcord
                display by name l_cta01m31.cgccpfdig

                let m_cta01m32.segnumdig = 0
                let m_cta01m32.cgccpfnum = g_a_psqseg[1].cgccpfnum
                let m_cta01m32.cgcord    = 0
                let m_cta01m32.cgccpfdig = g_a_psqseg[1].cgccpfdig

                let g_segnumdig = m_cta01m32.segnumdig
                let g_cgccpfnum = m_cta01m32.cgccpfnum
                let g_cgccpfdig = m_cta01m32.cgccpfdig

                let l_sel = null
                exit input

             end if
             let l_sel = 1
             exit input
          end if

#----------------------------Before-Prporg-----------------------------------------

      before field prporg
         display by name l_cta01m30.prporg    attribute (reverse)

#----------------------------After-Prporg-----------------------------------------

      after  field prporg
         display by name l_cta01m30.prporg

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            initialize l_cta01m30.prporg    to null
            initialize l_cta01m30.prpnumdig to null
            display by name l_cta01m30.prporg
            display by name l_cta01m30.prpnumdig
            next field cgccpfnum
         end if

        if l_cta01m30.prporg is null  then
            next field semdocto
        end if

#----------------------------Before-Prpnumdig-----------------------------------------

      before field prpnumdig
         display by name l_cta01m30.prpnumdig attribute (reverse)

#----------------------------After-Prpnumdig-----------------------------------------

      after  field prpnumdig
         display by name l_cta01m30.prpnumdig

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field prporg
         end if

         if l_cta01m30.prpnumdig is not null then

            exit input
         else
            next field prporg
         end if


#----------------------------Before-Semdocto-----------------------------------------

      before field semdocto
         display by name l_cta01m30.semdocto  attribute (reverse)

#----------------------------After-Semdocto-----------------------------------------

      after field semdocto
         display by name l_cta01m30.semdocto

         if fgl_lastkey() = fgl_keyval("up") or
            fgl_lastkey() = fgl_keyval("left")then

               next field prporg

         else
            if l_cta01m30.semdocto is null then
                  next field succod
            else
               if l_cta01m30.semdocto <> "S" then
                  error 'Opcao invalida, digite "S" para ligacao Sem Docto.' sleep 2
                  next field semdocto
               else
                  call cta10m00_entrada_dados()

                  let mr_documento.corsus       = g_documento.corsus
                  let mr_documento.dddcod       = g_documento.dddcod
                  let mr_documento.ctttel       = g_documento.ctttel
                  let mr_documento.funmat       = g_documento.funmat
                  let mr_documento.cgccpfnum    = g_documento.cgccpfnum
                  let mr_documento.cgcord       = g_documento.cgcord
                  let mr_documento.cgccpfdig    = g_documento.cgccpfdig
                  let mr_documento.ramcod       = l_param.ramcod
                  let mr_documento.c24soltipcod = l_param.c24soltipcod
                  let mr_documento.solnom       = l_param.solnom


                  if mr_documento.corsus    is null and
                     mr_documento.dddcod    is null and
                     mr_documento.ctttel    is null and
                     mr_documento.funmat    is null and
                     mr_documento.cgccpfnum is null and
                     mr_documento.cgcord    is null and
                     mr_documento.cgccpfdig is null then
                     error 'Falta informacoes para registrar Ligacao sem Docto.' sleep 2
                     next field semdocto
                  else
                      exit while
                  end if
               end if
            end if
         end if


         on key (interrupt)

           let l_sel = null
           let l_flag1 = 1

           exit while


     end input

    if l_sel is not null then

       # Se obter varios Segurados abro a tela p/ consulta

       call cta01m31()

       if m_ret = 1 then
          continue while
       end if

       ---> Funeral
       let m_cta01m32.prporg    = l_cta01m30.prporg
       let m_cta01m32.prpnumdig = l_cta01m30.prpnumdig
    else
       ---> Funeral
       if l_cta01m31.prporg is not null and
          l_cta01m31.prpnumdig is not null then
          let m_cta01m32.prporg    = l_cta01m31.prporg
          let m_cta01m32.prpnumdig = l_cta01m31.prpnumdig
       else
          let m_cta01m32.prporg    = l_cta01m30.prporg
          let m_cta01m32.prpnumdig = l_cta01m30.prpnumdig
       end if
    end if

    let m_cta01m32.ramcod    = l_param.ramcod
    let m_cta01m32.succod    = l_cta01m30.succod

    #let m_cta01m32.aplnumdig = l_cta01m30.aplnumdig
    ---> Funeral let m_cta01m32.prporg    = l_cta01m30.prporg
    ---> Funeral let m_cta01m32.prpnumdig = l_cta01m30.prpnumdig

    #let g_segnumdig = m_cta01m32.segnumdig
    #let g_cgccpfnum = m_cta01m32.cgccpfnum
    #let g_cgccpfdig = m_cta01m32.cgccpfdig

    # Chamo o espelho da Apolice do Vida

    call cta01m32(m_cta01m32.ramcod    ,
                  m_cta01m32.succod    ,
                  m_cta01m32.aplnumdig ,
                  m_cta01m32.prporg    ,
                  m_cta01m32.prpnumdig ,
                  m_cta01m32.segnumdig ,
                  m_cta01m32.cgccpfnum ,
                  m_cta01m32.cgccpfdig )
    returning  m_cta01m32.aplnumdig ,
               m_cta01m32.prporg    ,
               m_cta01m32.prpnumdig ,
               m_cta01m32.segnumdig ,
               m_cta01m32.succod    ,
               l_erro,
               m_cta01m32.ramcod ---> Funeral

      let g_documento.ramcod = m_cta01m32.ramcod ---> Funeral

      if l_erro <> 0 then
         error "Dados da Apolice nao encontrada"
         continue while
      else
         # Se a proposta e a apolice estiver carregada descarto
         # a proposta e fico somente com a apolice

         if m_cta01m32.aplnumdig is not null then
            # Carrego as Globais
            call cta01m30_carrega_globais()
            let m_cta01m32.prporg    = null
            let m_cta01m32.prpnumdig = null
         else
           let g_documento.prporg        = m_cta01m32.prporg
           let g_documento.prpnumdig     = m_cta01m32.prpnumdig
         end if
         exit while
      end if


 end while


 let int_flag = false

 close window cta01m30

  # Carrego as Globais

  ##call cta01m30_carrega_globais()


return l_flag1, l_cta01m30.semdocto

end function

#---------------------------------------------------------------------------------
function cta01m31()
#---------------------------------------------------------------------------------

define a_cta01m31       array[500] of record
       segnom            like gsakseg.segnom
      ,cgccpf            char(20)
      ,nscdat            like gsakseg.nscdat
end    record


define l_cont      integer
define l_arraycont integer
define l_cgccpfnum char(12)
define l_cgccpfdig char(2)
define l_cgcord    char(4)
define l_cinco     char(5)
define l_tres      char(3)


let l_cont      = null
let l_arraycont = null
let l_cgccpfnum = null
let l_cgccpfdig = null
let l_cgcord    = null
let l_cinco     = null
let l_tres      = null
let m_ret       = 0

for l_arraycont  =  1  to  500
    initialize  a_cta01m31[l_arraycont].* to null
end for



open window cta01m31 at 3,2 with form "cta01m31"
     attribute (form line 1)

message "(F8)Seleciona, (CTRL-C)Retorna"

for l_cont = 1 to 500

    if m_array[l_cont].segnom is not null then
       let a_cta01m31[l_cont].segnom = m_array[l_cont].segnom
       let a_cta01m31[l_cont].nscdat = m_array[l_cont].nscdat

       let l_cgccpfnum = cta01m30_parametriza(m_array[l_cont].cgccpfnum,12)
       let l_cinco     = m_array[l_cont].cgcord + 10000
       let l_cgcord    = l_cinco[2,5]
       let l_tres      = m_array[l_cont].cgccpfdig + 100
       let l_cgccpfdig = l_tres[2,3]

       if m_array[l_cont].pestip = "F" then
          let a_cta01m31[l_cont].cgccpf = l_cgccpfnum[4,6]  ,"."
                                          ,l_cgccpfnum[7,9]  ,"."
                                          ,l_cgccpfnum[10,12],"-"
                                          ,l_cgccpfdig
       else
          let a_cta01m31[l_cont].cgccpf = l_cgccpfnum[3,6]  ,"."
                                          ,l_cgccpfnum[7,9]  ,"."
                                          ,l_cgccpfnum[10,12],"/"
                                          ,l_cgcord         ,"-"
                                          ,l_cgccpfdig
       end if
    else
       if g_a_psqseg[l_cont].segnom is not null then

          let a_cta01m31[l_cont].segnom = g_a_psqseg[l_cont].segnom
          let a_cta01m31[l_cont].nscdat = g_a_psqseg[l_cont].nscdat

         let l_cgccpfnum = cta01m30_parametriza(g_a_psqseg[l_cont].cgccpfnum,12)
          let l_cinco     = 0 + 10000
          let l_cgcord    = l_cinco[2,5]
          let l_tres      = g_a_psqseg[l_cont].cgccpfdig + 100
          let l_cgccpfdig = l_tres[2,3]

          let a_cta01m31[l_cont].cgccpf = l_cgccpfnum[4,6]  ,"."
                                         ,l_cgccpfnum[7,9]  ,"."
                                         ,l_cgccpfnum[10,12],"-"
                                         ,l_cgccpfdig

       else
          exit for
       end if
    end if


end for

   call set_count(l_cont)
   display array a_cta01m31 to s_cta01m31.*


   on key (f8)

         let l_cont    = arr_curr()

         let m_ret = 0

         ---> Previdencia - Funeral
         if m_array[l_cont].cgccpfnum is not null then
            let m_cta01m32.segnumdig = m_array[l_cont].segnumdig
            let m_cta01m32.cgccpfnum = m_array[l_cont].cgccpfnum
            let m_cta01m32.cgcord    = m_array[l_cont].cgcord
            let m_cta01m32.cgccpfdig = m_array[l_cont].cgccpfdig

            let g_segnumdig = m_array[l_cont].segnumdig
            let g_cgccpfnum = m_array[l_cont].cgccpfnum
            let g_cgccpfdig = m_array[l_cont].cgccpfdig
         else
            let m_cta01m32.segnumdig = 0
            let m_cta01m32.cgccpfnum = g_a_psqseg[l_cont].cgccpfnum
            let m_cta01m32.cgcord    = g_a_psqseg[l_cont].cgccpford
            let m_cta01m32.cgccpfdig = g_a_psqseg[l_cont].cgccpfdig

            let g_segnumdig = 0
            let g_cgccpfnum = g_a_psqseg[l_cont].cgccpfnum
            let g_cgccpfdig = g_a_psqseg[l_cont].cgccpfdig
         end if

         call cta01m30_popup()

         if int_flag = true then
            exit display
         end if

    on key (interrupt,control-c)
         let m_ret  = 1

        for l_cont  =  1  to  500
            initialize m_array[l_cont].* to null
        end for


        exit display
   end display

   close window cta01m31


end function

#-----------------------------------------------------------------------------
function cta01m30_parametriza(l_key)
#-----------------------------------------------------------------------------

define l_key        record
       valor        dec(20,0)
      ,tamanho      integer
end    record

 define l_destino    char(20)
       ,l_char       char(20)
       ,l_posini     integer
       ,l_posfin     integer

 let l_destino = null
 let l_char    = null
 let l_posini  = null
 let l_posfin  = null

 if l_key.valor   is null or
    l_key.tamanho is null or
    l_key.tamanho  = 0    then
    let l_destino = null
 else
    let l_char   = l_key.valor
    let l_posini = l_key.tamanho - length(l_char) + 1
    let l_posfin = l_key.tamanho

    let l_destino = "00000000000000000000"
    let l_destino [l_posini, l_posfin] = l_key.valor
 end if

 return l_destino [1,l_posfin]

end function

#-----------------------------------------------------------------------------
function cta01m30_carrega_globais()
#-----------------------------------------------------------------------------

let g_documento.ramcod    = m_cta01m32.ramcod
let g_documento.succod    = m_cta01m32.succod
let g_documento.aplnumdig = m_cta01m32.aplnumdig
let g_documento.prporg    = m_cta01m32.prporg
let g_documento.prpnumdig = m_cta01m32.prpnumdig
let g_prporg              = m_cta01m32.prporg
let g_prpnumdig           = m_cta01m32.prpnumdig
let g_segnumdig           = m_cta01m32.segnumdig

end function

#-----------------------------------------------------------------------------
 function cta01m30_popup()
#-----------------------------------------------------------------------------

   define al_retorno array[40] of record
             segnom    char(50)
            ,cgccpfnum decimal(12,0)
            ,cgccpfdig decimal(2,0)
            ,nscdat    date
            ,sgrorg    decimal(8,0)
            ,sgrnumdig decimal(11,0)
            ,sgrstt    char(1)
            ,segnumdig decimal(8,0)
            ,aplnumdig like vtamdoc.aplnumdig
            ,temaft    char(1)
            ,tipo_seg  char(02)
            ,prpstt    decimal(2,0)
            ,etpnom    like vgsmseg.segnom
            ,ramcod    smallint
   end record

   #define al_popup array[40] of record
   #          aplnumdig like vtamdoc.aplnumdig
   #         ,sgrstt    char(10)
   #end record

   #
   define al_popup array[40] of record
             aplnumdig like vtamdoc.aplnumdig
            ,sgrstt    char(10)
            ,temaft    char(1)
   end record

   define lr_cta01m32 record
             aplnumdig like datrligapol.aplnumdig
            ,prporg    like datrligprp.prporg
            ,prpnumdig like datrligprp.prpnumdig
            ,segnumdig like gsakseg.segnumdig
            ,succod    like datrligapol.succod
   end record

   ---> Funeral - Previdencia
   define l_ret record
       coderro         integer,
       menserro        char(30),
       qtdlinhas       smallint
   end record

   define l_erro smallint
         ,l_i    smallint
         ,l_cont smallint

   initialize al_retorno, al_popup, lr_cta01m32 to null

   ---> Funeral - Previdencia
   initialize l_ret.* to null


   let l_erro = null
   let l_i    = 1
   let l_cont = null
   call fvita008_pesquisa_segurado(g_segnumdig)
      returning l_erro
               ,al_retorno[1].*
               ,al_retorno[2].*
               ,al_retorno[3].*
               ,al_retorno[4].*
               ,al_retorno[5].*
               ,al_retorno[6].*
               ,al_retorno[7].*
               ,al_retorno[8].*
               ,al_retorno[9].*
               ,al_retorno[10].*
               ,al_retorno[11].*
               ,al_retorno[12].*
               ,al_retorno[13].*
               ,al_retorno[14].*
               ,al_retorno[15].*
               ,al_retorno[16].*
               ,al_retorno[17].*
               ,al_retorno[18].*
               ,al_retorno[19].*
               ,al_retorno[20].*
               ,al_retorno[21].*
               ,al_retorno[22].*
               ,al_retorno[23].*
               ,al_retorno[24].*
               ,al_retorno[25].*
               ,al_retorno[26].*
               ,al_retorno[27].*
               ,al_retorno[28].*
               ,al_retorno[29].*
               ,al_retorno[30].*
               ,al_retorno[31].*
               ,al_retorno[32].*
               ,al_retorno[33].*
               ,al_retorno[34].*
               ,al_retorno[35].*
               ,al_retorno[36].*
               ,al_retorno[37].*
               ,al_retorno[38].*
               ,al_retorno[39].*
               ,al_retorno[40].*

   ---> Previdencia - Funeral
   call fpvia21_pesquisa_apolice_segurado(m_cta01m32.cgccpfnum
                                         ,m_cta01m32.cgcord
                                         ,m_cta01m32.cgccpfdig)
                        returning l_ret.*

   for l_i = 1 to 40
      if al_retorno[l_i].aplnumdig is not null then
         let al_popup[l_i].aplnumdig = al_retorno[l_i].aplnumdig

         case al_retorno[l_i].sgrstt
            when 'A'
               let al_popup[l_i].sgrstt = 'ATIVO'
            when 'P'
               let al_popup[l_i].sgrstt = 'PENDENTE'
            when 'C'
               let al_popup[l_i].sgrstt = 'CANCELADO'
         end case

         #
         let al_popup[l_i].temaft = al_retorno[l_i].temaft

         if al_retorno[l_i].aplnumdig is null then
          #  exit for
         end if
      else
         let al_popup[l_i].aplnumdig = g_a_psqaplseg[l_i].aplnumdig

         case g_a_psqaplseg[l_i].asststt
            when 'A'
               let al_popup[l_i].sgrstt = 'ATIVO'
            when 'P'
               let al_popup[l_i].sgrstt = 'PENDENTE'
            when 'C'
               let al_popup[l_i].sgrstt = 'CANCELADO'
         end case

         #
         if g_a_psqaplseg[l_i].aplnumdig is not null then
            let al_popup[l_i].temaft = 'S'
         end if
      end if
   end for

   if l_i >= 1 then
      open window w_cta01m30a at 11,25 with form "cta01m30a"
         attribute (border, form line 1)

      call set_count(l_i)
      let int_flag = true

      display array al_popup to s_cta01m31a.*

         on key(f8)
            ##let l_cont = arr_curr()
            let l_i = arr_curr()
            ##let m_cta01m32.segnumdig = al_retorno[l_cont].segnumdig
            ##let m_cta01m32.cgccpfnum = al_retorno[l_cont].cgccpfnum
            ##let m_cta01m32.cgccpfdig = al_retorno[l_cont].cgccpfdig

            if al_popup[l_i].aplnumdig is null or
               al_popup[l_i].aplnumdig =  0    then
               error "Apolice invalida. Escolha outro registro."
               let int_flag = false
               exit display
            else
               ---> Previdencia - Funeral
               if al_retorno[l_i].segnumdig is not null then
                  let m_cta01m32.segnumdig = al_retorno[l_i].segnumdig
                  let m_cta01m32.cgccpfnum = al_retorno[l_i].cgccpfnum
                  let m_cta01m32.cgccpfdig = al_retorno[l_i].cgccpfdig
                  let m_cta01m32.aplnumdig = al_retorno[l_i].aplnumdig

                  let g_segnumdig = al_retorno[l_i].segnumdig
                  let g_cgccpfnum = al_retorno[l_i].cgccpfnum
                  let g_cgccpfdig = al_retorno[l_i].cgccpfdig
               else
                  let m_cta01m32.segnumdig = 0
                  let m_cta01m32.aplnumdig = al_retorno[l_i].aplnumdig

                  let g_segnumdig = 0
                  let g_cgccpfnum = m_cta01m32.cgccpfnum
                  let g_cgccpfdig = m_cta01m32.cgccpfdig
               end if

               let int_flag = true

               exit display
            end if


         on key(interrupt, control-c, f17)
            let int_flag = false
            exit display

      end display

      close window w_cta01m30a
   else
      let m_cta01m32.segnumdig = al_retorno[l_i].segnumdig
      let m_cta01m32.cgccpfnum = al_retorno[l_i].cgccpfnum
      let m_cta01m32.cgccpfdig = al_retorno[l_i].cgccpfdig
      let m_cta01m32.aplnumdig = al_retorno[l_i].aplnumdig

      let g_segnumdig = al_retorno[l_i].segnumdig
      let g_cgccpfnum = al_retorno[l_i].cgccpfnum
      let g_cgccpfdig = al_retorno[l_i].cgccpfdig
   end if

end function

