#############################################################################
# Nome do Modulo: CTA01M30                                         Roberto  #
#                                                                  Jun/2007 #
# Espelho da Apolice do Vida                                                #
#############################################################################

globals '/homedsa/projetos/geral/globals/glct.4gl'
---> Funeral - Previdencia
globals '/homedsa/projetos/geral/globals/gpvia021.4gl'

function cta01m32(l_param)

define l_param record
       ramcod      like datrservapol.ramcod   ,
       succod      like datrligapol.succod    ,
       aplnumdig   like datrligapol.aplnumdig ,
       prporg      like datrligprp.prporg     ,
       prpnumdig   like datrligprp.prpnumdig  ,
       segnumdig   like gsakseg.segnumdig  ,
       cgccpfnum   like gsakseg.cgccpfnum     ,
       cgccpfdig   like gsakseg.cgccpfdig
end record

define l_cta01m32 record
       succod     like  vtamdoc.succod     ,
       aplnumdig  like  vtamdoc.aplnumdig  ,
       solnom     char(30)                 ,
       vdapdtdes  like  vgpkprod.vdapdtdes ,
       prporg     like  vtamdoc.prporg     ,
       prpnumdig  like  vtamdoc.prpnumdig  ,
       emsdat     like  vtamdoc.emsdat     ,
       viginc     like  vtamdoc.viginc     ,
       vigfnl     like  vtamdoc.vigfnl     ,
       cpodes     like  iddkdominio.cpodes ,
       benefx     char(3)                  ,
       segnom     like  gsakseg.segnom     ,
       segnumdig  like  gsakseg.segnumdig  ,
       segteltxt  like  gsakend.teltxt     ,
       cornom     like  gcakcorr.cornom    ,
       corsus     like  gcaksusep.corsus   ,
       corteltxt  like  gcakfilial.teltxt
end record

define l_cta01m32vida    record
       msg           char(80),
       tipo          char(02),  #VN Vida Nova/VI Vida Individual/VG Vida Grupo
       existe_massa  smallint,  # 0 NAO Tem Massa / 1 TEM MASSA
       empcod        dec(2,0)                    ,
       ramcod        smallint                    ,
       succod        like  vtamdoc.succod        ,
       aplnumdig     like  vtamdoc.aplnumdig     ,
       vdapdtcod     like  vtamseguro.vdapdtcod  ,
       vdapdtdes     like  vgpkprod.vdapdtdes    ,
       prporg        like  vtamdoc.prporg        ,
       prpnumdig     like  vtamdoc.prpnumdig     ,
       emsdat        like  vtamdoc.emsdat        ,
       viginc        like  vtamdoc.viginc        ,
       vigfnl        like  vtamdoc.vigfnl        ,
       prpstt        like  vtamdoc.prpstt        ,
       cpodes        like iddkdominio.cpodes     ,
       segnumdig     like  gsakseg.segnumdig     ,
       segnom        like  gsakseg.segnom        ,
       nscdat        like  gsakseg.nscdat        ,
       segsex        like  gsakseg.segsex        ,
       endlgdtip     like  gsakend.endlgdtip     ,
       endlgd        like  gsakend.endlgd        ,
       endnum        like  gsakend.endnum        ,
       endbrr        like  gsakend.endbrr        ,
       endcid        like  gsakend.endcid        ,
       endufd        like  gsakend.endufd        ,
       endcep        like  gsakend.endcep        ,
       corsuspcp     like  gcakcorr.corsuspcp    ,
       cornom        like  gcakcorr.cornom
end record


define a_cta01m32 array[10] of record
       vdacbttip  like vtamcap.vdacbttip    ,
       vdacbtdes  like vgpktipcob.vdacbtdes ,
       moeda      char(2)                   ,
       imsvlr     decimal(10,2)             ,
       msg        char(30)
end record

define l_cta01m32cla array[10] of record
       vdacbttip     like vtamcap.vdacbttip    ,
       vdacbtdes     like vgpktipcob.vdacbtdes ,
       imsvlr        like vtamcap.imsvlr       ,
       cob_principal char(01)
end record


define l_cta01m32bnf array[10] of record
      bnfnom       like vtamsegdpd.dpdnom       # Nome
     ,bnfnscdat    like vtamsegdpd.dpdnscdat    # data nascimento
     ,bnfprngracod like vtamsegdpd.dpdprngracod # codigo do grau de parentesco
     ,bnfprngrades like iddkdominio.cpodes      # Descricao do grau de parentesco
     ,cpfnum       like vtamsegdpd.cpfnum       # Numero do CPF do dependente
     ,cpfdig       like vtamsegdpd.cpfdig       # Numero do Digito do CPF
     ,doecrndiaqtd like vtamsegdpd.doecrndiaqtd # Quantidade dias carencia doenca
end record


define r_gcakfilial    record
        endlgd          like gcakfilial.endlgd
       ,endnum          like gcakfilial.endnum
       ,endcmp          like gcakfilial.endcmp
       ,endbrr          like gcakfilial.endbrr
       ,endcid          like gcakfilial.endcid
       ,endcep          like gcakfilial.endcep
       ,endcepcmp       like gcakfilial.endcepcmp
       ,endufd          like gcakfilial.endufd
       ,dddcod          like gcakfilial.dddcod
       ,teltxt          like gcakfilial.teltxt
       ,dddfax          like gcakfilial.dddfax
       ,factxt          like gcakfilial.factxt
       ,maides          like gcakfilial.maides
       ,crrdstcod       like gcaksusep.crrdstcod
       ,crrdstnum       like gcaksusep.crrdstnum
       ,crrdstsuc       like gcaksusep.crrdstsuc
       ,status          smallint
end record

---> Funeral
define l_retornofnc record
       coderro      integer,
       menserro     char(30),
       qtdlinhas    integer
end record

define x           integer
define aux_x       integer
define l_erro      smallint
define l_erro2     smallint
define l_prporg    like  vtamdoc.prporg
define l_prpnumdig like  vtamdoc.prpnumdig
define l_qtdfil    integer
define l_doecrndiaqtd integer
define l_tipo      char(02)
define l_tipo_claus  char(02)
define l_ramcod      smallint
define l_empcod      dec(2,0)

initialize l_cta01m32.*      to null
initialize l_cta01m32vida.*  to null
initialize r_gcakfilial.*    to null

---> Funeral
initialize l_retornofnc.* to null


let l_erro       = 0
let l_erro2      = 0
let l_prporg     = null
let l_prpnumdig  = null
let l_qtdfil     = null
let aux_x        = 1
let l_tipo       = null
let l_tipo_claus = null
let l_ramcod     = null
let l_empcod     = null

for     x  =  1  to  10
        initialize  a_cta01m32[x].*    to  null
        initialize  l_cta01m32cla[x].* to null
        initialize  l_cta01m32bnf[x].*   to null
end  for

    # Chamo a funcao do vida para recuperar os dados do segurado

    ---> Funeral
    #let l_param.ramcod = null

    call fvita008_vida(l_param.*)
    returning l_erro,l_cta01m32vida.*

     let l_param.ramcod    = l_cta01m32vida.ramcod
     let l_param.prporg    = l_cta01m32vida.prporg
     let l_param.prpnumdig = l_cta01m32vida.prpnumdig

     if l_erro <> 0 then
---> Funeral
#              return  l_cta01m32.aplnumdig,
#                      l_cta01m32.prporg   ,
#                      l_cta01m32.prpnumdig,
#                      l_cta01m32.segnumdig,
#                      l_cta01m32.succod   ,
#                      l_erro,
#                      l_param.ramcod
     end if

    # Chamo a funcao do vida para recuperar as clausulas do segurado

    call fvita008_clausulas(l_param.*)
         returning l_erro             ,
                   l_tipo_claus       ,
                   l_prporg           ,
                   l_prpnumdig        ,
                   l_empcod           ,
                   l_ramcod           ,
                   l_cta01m32cla[1].* ,
                   l_cta01m32cla[2].* ,
                   l_cta01m32cla[3].* ,
                   l_cta01m32cla[4].* ,
                   l_cta01m32cla[5].* ,
                   l_cta01m32cla[6].* ,
                   l_cta01m32cla[7].* ,
                   l_cta01m32cla[8].* ,
                   l_cta01m32cla[9].* ,
                   l_cta01m32cla[10].*

           # Comentado conforme conversado com reinaldo. Assumindo ramo apenas
           # do retorno da funcao fvita008_vida - ramo pai.
           #let l_param.ramcod = l_ramcod

    if l_erro <> 0 then
---> Funeral
#             return  l_cta01m32.aplnumdig,
#                     l_cta01m32.prporg   ,
#                     l_cta01m32.prpnumdig,
#                     l_cta01m32.segnumdig,
#                     l_cta01m32.succod   ,
#                     l_erro,
#                     l_param.ramcod
    end if

   # Chamo a funcao do vida para recuperar os beneficiarios do segurado

   call fvita008_beneficiario(l_param.*)
        returning l_erro2            ,
                  l_tipo             ,
                  l_qtdfil           ,
                  l_doecrndiaqtd     ,
                  l_empcod           ,
                  l_ramcod           ,
                  l_cta01m32bnf[1].* ,
                  l_cta01m32bnf[2].* ,
                  l_cta01m32bnf[3].* ,
                  l_cta01m32bnf[4].* ,
                  l_cta01m32bnf[5].* ,
                  l_cta01m32bnf[6].* ,
                  l_cta01m32bnf[7].* ,
                  l_cta01m32bnf[8].* ,
                  l_cta01m32bnf[9].* ,
                  l_cta01m32bnf[10].*

        # Comentado conforme conversado com reinaldo. Assumindo ramo apenas
        # do retorno da funcao fvita008_vida - ramo pai.
        #let l_param.ramcod = l_ramcod

     if l_erro2 <> 0 then
        let l_cta01m32.benefx = "NAO"
     else
        let l_cta01m32.benefx = "SIM"
     end if


    # Recupero o Telefone do Segurado
    # Alterar funcionalidade para recuperar dados do endereço - Vida DVP 68.225
    call cty05g00_recupera_tel(l_cta01m32.segnumdig)
     returning r_gcakfilial.dddcod,
               l_cta01m32.segteltxt


    let l_cta01m32.segteltxt = "(", r_gcakfilial.dddcod  , ") ", l_cta01m32.segteltxt


    let r_gcakfilial.dddcod = null

    # Recupero o Telefone do Corretor

    call fgckc811(l_cta01m32vida.corsuspcp)
         returning r_gcakfilial.*

    let l_cta01m32.corteltxt = "(", r_gcakfilial.dddcod  , ") ", r_gcakfilial.teltxt


    ---> Funeral - Previdencia
    if l_param.cgccpfnum is not null and
       l_param.cgccpfdig is not null then

       call fpvia21_pesquisa_apolice_segurado(l_param.cgccpfnum
                                             ,0                ---> cgcord
                                             ,l_param.cgccpfdig)
                            returning l_retornofnc.coderro
                                     ,l_retornofnc.menserro
                                     ,l_retornofnc.qtdlinhas
                                     # ---> Carrega array g_a_psqaplseg:
                                     #     -empcod
                                     #     -succod
                                     #     -ramcod
                                     #     -aplnumdig
                                     #     -asststt
                                     #     -vdacbttip
                                     #     -imsvlr

        if l_retornofnc.qtdlinhas > 0 then

           initialize l_retornofnc.* to null

           call fpvia21_pesquisa_dados_segurado(g_a_psqaplseg[1].succod
                                               ,g_a_psqaplseg[1].ramcod
                                               ,g_a_psqaplseg[1].aplnumdig)
                                returning l_retornofnc.coderro
                                         ,l_retornofnc.menserro
                                         ,l_retornofnc.qtdlinhas
                                         # ---> Carrega array g_a_psqdadseg
        end if
    end if

    if l_param.succod is not null    and
       l_param.aplnumdig is not null and
      (l_retornofnc.qtdlinhas = 0 or
       l_retornofnc.qtdlinhas is null) then

       initialize l_retornofnc.* to null

       call fpvia21_pesquisa_dados_segurado(l_param.succod
                                           ,l_param.ramcod
                                           ,l_param.aplnumdig)
                              returning l_retornofnc.coderro
                                       ,l_retornofnc.menserro
                                       ,l_retornofnc.qtdlinhas
                                       # ---> Carrega array g_a_psqdadseg

    end if

    if (l_param.prporg is not null    and
        l_param.prpnumdig is not null and
       (l_retornofnc.qtdlinhas = 0 or
        l_retornofnc.qtdlinhas is null))  or
        l_cta01m32vida.segnom is not null then

          initialize l_retornofnc.* to null

          call fpvia21_pesquisa_segurado(l_param.prporg
                                        ,l_param.prpnumdig
                                        ,0 ---> cgccpfnum
                                        ,0 ---> cgccpford
                                        ,0 ---> cgccpfdig
                                        ,'' --> segnom
                                        ,0 ---> succod
                                        ,0 ---> ramcod
                                        ,0) ---> aplnumdig
                            returning l_retornofnc.coderro
                                     ,l_retornofnc.menserro
                                     ,l_retornofnc.qtdlinhas
                                     # ---> Carrega array g_a_psqseg

          if l_retornofnc.qtdlinhas = 0 then
             call fpvia21_pesquisa_segurado(0
                                           ,0
                                           ,0 ---> cgccpfnum
                                           ,0 ---> cgccpford
                                           ,0 ---> cgccpfdig
                                           ,l_cta01m32vida.segnom --> segnom
                                           ,0 ---> succod
                                           ,0 ---> ramcod
                                           ,0) ---> aplnumdig
                               returning l_retornofnc.coderro
                                        ,l_retornofnc.menserro
                                        ,l_retornofnc.qtdlinhas
                                        # ---> Carrega array g_a_psqseg
          end if

          if l_retornofnc.qtdlinhas > 0 then
             initialize l_retornofnc.* to null

             call fpvia21_pesquisa_apolice_segurado(g_a_psqseg[1].cgccpfnum
                                                   ,0                ---> cgcord
                                                   ,g_a_psqseg[1].cgccpfdig)
                            returning l_retornofnc.coderro
                                     ,l_retornofnc.menserro
                                     ,l_retornofnc.qtdlinhas
                                     # ---> Carrega array g_a_psqaplseg:
                                     #     -empcod
                                     #     -succod
                                     #     -ramcod
                                     #     -aplnumdig
                                     #     -asststt
                                     #     -vdacbttip
                                     #     -imsvlr

           if l_retornofnc.qtdlinhas > 0 then

              initialize l_retornofnc.* to null

              call fpvia21_pesquisa_dados_segurado(g_a_psqaplseg[1].succod
                                                  ,g_a_psqaplseg[1].ramcod
                                                  ,g_a_psqaplseg[1].aplnumdig)
                                         returning l_retornofnc.coderro
                                                  ,l_retornofnc.menserro
                                                  ,l_retornofnc.qtdlinhas
                                             # ---> Carrega array g_a_psqdadseg
          end if
       end if
    end if

    ---> Trata documento nao encontrado. - Funeral - Vida - Previdencia
    if l_cta01m32vida.segnom is null   and
       g_a_psqdadseg[1].segnom is null then
       return  l_cta01m32.aplnumdig,
               l_cta01m32.prporg   ,
               l_cta01m32.prpnumdig,
               l_cta01m32.segnumdig,
               l_cta01m32.succod   ,
               1,     ---> l_erro
               l_param.ramcod
    end if

let l_retornofnc.menserro = null

let g_cob_fun_saf = null
let g_cob_fun_eme = null # Vida, Servico a residencia

for x = 1 to 10

        ## if  l_cta01m32cla[x].vdacbttip = 104   or
        ##     l_cta01m32cla[x].vdacbttip = 105   or
        ##
        ##     l_cta01m32cla[x].vdacbttip = 114   or
        ##     l_cta01m32cla[x].vdacbttip = 115   or
        ##
        ##     l_cta01m32cla[x].vdacbttip = 120   or
        ##     l_cta01m32cla[x].vdacbttip = 121   or
        ##     l_cta01m32cla[x].vdacbttip = 122   or
        ##     l_cta01m32cla[x].vdacbttip = 123   or
        ##     l_cta01m32cla[x].vdacbttip = 124   or
        ##     l_cta01m32cla[x].vdacbttip = 126   or
        ##     l_cta01m32cla[x].vdacbttip = 127   or
        ##     l_cta01m32cla[x].vdacbttip = 129   or
        ##     l_cta01m32cla[x].vdacbttip = 131   or
        ##     l_cta01m32cla[x].vdacbttip = 132   or
        ##     l_cta01m32cla[x].vdacbttip = 133   or
        ##     l_cta01m32cla[x].vdacbttip = 134   or
        ##     l_cta01m32cla[x].vdacbttip = 137   or
        ##     l_cta01m32cla[x].vdacbttip = 138   or
        ##     l_cta01m32cla[x].vdacbttip = 147   or
        ##     l_cta01m32cla[x].vdacbttip = 150   or
        ##     l_cta01m32cla[x].vdacbttip = 151   or
        ##     l_cta01m32cla[x].vdacbttip = 152   or
        ##     l_cta01m32cla[x].vdacbttip = 154   or
        ##     l_cta01m32cla[x].vdacbttip = 155   or
        ##     l_cta01m32cla[x].vdacbttip = 165   or
        ##     l_cta01m32cla[x].vdacbttip = 166   or
        ##     l_cta01m32cla[x].vdacbttip = 167   or
        ##     l_cta01m32cla[x].vdacbttip = 168   or
        ##     l_cta01m32cla[x].vdacbttip = 170   or
        ##
        ##     l_cta01m32cla[x].vdacbttip = 180   or
        ##     l_cta01m32cla[x].vdacbttip = 181   or
        ##     l_cta01m32cla[x].vdacbttip = 183   or
        ##     l_cta01m32cla[x].vdacbttip = 190   or
        ##
        ##     l_cta01m32cla[x].vdacbttip = 333   or
        ##     l_cta01m32cla[x].vdacbttip = 334   or
        ##
        ##     l_cta01m32cla[x].vdacbttip = 'APF' or
        ##     l_cta01m32cla[x].vdacbttip = 'APT' or
        ##     l_cta01m32cla[x].vdacbttip = 'AP1' or
        ##     l_cta01m32cla[x].vdacbttip = 'AP2' or
        ##     l_cta01m32cla[x].vdacbttip = 'AP3' or
        ##     l_cta01m32cla[x].vdacbttip = 'AFT' or
        ##     l_cta01m32cla[x].vdacbttip = 'AFF' or
        ##     l_cta01m32cla[x].vdacbttip = '206' or
        ##     l_cta01m32cla[x].vdacbttip = 'EME' or
        ##     l_cta01m32cla[x].vdacbttip = 'ASR' or
        ##     l_cta01m32cla[x].vdacbttip = 'REJ' or
        ##     l_cta01m32cla[x].vdacbttip = 'RPC' then
        ##
        ##     let a_cta01m32[aux_x].vdacbttip = l_cta01m32cla[x].vdacbttip
        ##     let a_cta01m32[aux_x].vdacbtdes = l_cta01m32cla[x].vdacbtdes
        ##     let a_cta01m32[aux_x].imsvlr    = l_cta01m32cla[x].imsvlr
        ##
        ##     let a_cta01m32[aux_x].moeda     = "R$"
        ##     let a_cta01m32[aux_x].msg       = "(LIMITE) POR OBITO ASSISTIDO"
        ##
        ##     if l_cta01m32cla[x].vdacbttip = 'EME' or
        ##        l_cta01m32cla[x].vdacbttip = 'ASR' then
        ##        let a_cta01m32[aux_x].moeda     = ""
        ##        let a_cta01m32[aux_x].msg       = ""
        ##        let a_cta01m32[aux_x].imsvlr    = ""
        ##        let a_cta01m32[aux_x].imsvlr    = ""
        ##     else
        ##
        ##        let a_cta01m32[aux_x].moeda     = "R$"
        ##        let a_cta01m32[aux_x].msg       = "(LIMITE) POR OBITO ASSISTIDO"
        ##     end if
        ##
        ##     let aux_x = aux_x + 1
        ##     let g_cob_fun_saf = 1 ---> VEP - Vida
        ## end if

        # Alberto DVP 56.235 Vida
        let a_cta01m32[aux_x].vdacbttip = l_cta01m32cla[x].vdacbttip
        let a_cta01m32[aux_x].vdacbtdes = l_cta01m32cla[x].vdacbtdes
        let a_cta01m32[aux_x].imsvlr    = l_cta01m32cla[x].imsvlr
        let a_cta01m32[aux_x].moeda     = "R$"

        if l_cta01m32cla[x].cob_principal = "S" then
           let a_cta01m32[aux_x].moeda     = "R$"
           let a_cta01m32[aux_x].msg       = "(LIMITE) POR OBITO ASSISTIDO"
        else
           if a_cta01m32[aux_x].imsvlr = 0.00 or
              a_cta01m32[aux_x].imsvlr is null then
              let a_cta01m32[aux_x].moeda     = ""
              let a_cta01m32[aux_x].imsvlr = ""
           end if
           let a_cta01m32[aux_x].msg       = ""
        end if

        let aux_x = aux_x + 1
        let g_cob_fun_saf = 1 ---> VEP - Vida
        if l_cta01m32cla[x].vdacbttip = 'EME' or
           l_cta01m32cla[x].vdacbttip = 'ASR' then
           let g_cob_fun_eme = 1 ---> EME - Vida
        end if
end for


let aux_x = 1

for x = 1 to 10

     if g_a_psqdadseg[x].vdacbttip = '1'   or   ---> Funeral - Previdencia
        g_a_psqdadseg[x].vdacbttip = '2'   then ---> Funeral - Previdencia

        if a_cta01m32[x].imsvlr is null then
           let a_cta01m32[aux_x].imsvlr = 0
        end if

        if g_a_psqdadseg[x].imsvlr is null then
           let g_a_psqdadseg[x].imsvlr = 0
        end if

        if a_cta01m32[x].imsvlr >= g_a_psqdadseg[x].imsvlr then
        else
           let l_retornofnc.menserro = null
           let a_cta01m32[aux_x].vdacbttip = g_a_psqdadseg[x].vdacbttip
           let a_cta01m32[aux_x].vdacbtdes = g_a_psqdadseg[x].vdacbtdes
           let a_cta01m32[aux_x].imsvlr    = g_a_psqdadseg[x].imsvlr
           let l_retornofnc.menserro = 'PREVIDENCIA'
        end if

        if l_cta01m32cla[x].vdacbttip = 'EME' or
           l_cta01m32cla[x].vdacbttip = 'ASR' then
           let a_cta01m32[aux_x].moeda     = ""
           let a_cta01m32[aux_x].msg       = ""
           let a_cta01m32[aux_x].imsvlr    = ""
        else

           let a_cta01m32[aux_x].moeda     = "R$"
           let a_cta01m32[aux_x].msg       = "(LIMITE) POR OBITO ASSISTIDO"
        end if
        let aux_x = aux_x + 1
        let g_cob_fun_saf = 1 ---> VEP - Vida
     end if
end for

 open window cta01m32 at 03,02 with form "cta01m32"
                      attribute(form line 1)
message "(F1)Funcoes (F4)Corr"


 display by name l_cta01m32.*

 call set_count(x - 1)

 ---> Funeral - Trata Previdencia
 if l_retornofnc.menserro = 'PREVIDENCIA' then

    let l_cta01m32.succod     = g_a_psqdadseg[1].succod
    let l_cta01m32.aplnumdig  = g_a_psqdadseg[1].aplnumdig
    let l_cta01m32.vdapdtdes  = g_a_psqdadseg[1].cpodes
    let l_cta01m32.prporg     = g_a_psqdadseg[1].prporg
    let l_cta01m32.prpnumdig  = g_a_psqdadseg[1].prpnumdig
    let l_cta01m32.emsdat     = g_a_psqdadseg[1].dtemsprp
    let l_cta01m32.viginc     = g_a_psqdadseg[1].viginc
    let l_cta01m32.vigfnl     = g_a_psqdadseg[1].vigfnl
    let l_cta01m32.cpodes     = g_a_psqdadseg[1].prpstt
#   let l_cta01m32.segnumdig  = l_cta01m32vida.segnumdig
    let l_cta01m32.segnom     = g_a_psqdadseg[1].segnom
    let l_cta01m32.corsus     = g_a_psqdadseg[1].corsus
    let l_cta01m32.cornom     = g_a_psqdadseg[1].cornom
    let g_documento.ciaempcod = g_a_psqdadseg[1].empcod
    let l_cta01m32.cpodes     = upshift(g_a_psqdadseg[1].prpstt)
    let l_param.ramcod        = g_a_psqdadseg[1].ramcod
    let l_erro                = 0
 else
    let l_cta01m32.succod     = l_cta01m32vida.succod
    let l_cta01m32.aplnumdig  = l_cta01m32vida.aplnumdig
    let l_cta01m32.vdapdtdes  = l_cta01m32vida.vdapdtdes
    let l_cta01m32.prporg     = l_cta01m32vida.prporg
    let l_cta01m32.prpnumdig  = l_cta01m32vida.prpnumdig
    let l_cta01m32.emsdat     = l_cta01m32vida.emsdat
    let l_cta01m32.viginc     = l_cta01m32vida.viginc
    let l_cta01m32.vigfnl     = l_cta01m32vida.vigfnl
    let l_cta01m32.cpodes     = l_cta01m32vida.cpodes
    let l_cta01m32.segnumdig  = l_cta01m32vida.segnumdig
    let l_cta01m32.segnom     = l_cta01m32vida.segnom
    let l_cta01m32.corsus     = l_cta01m32vida.corsuspcp
    let l_cta01m32.cornom     = l_cta01m32vida.cornom
    let g_documento.ciaempcod = l_cta01m32vida.empcod
    let l_cta01m32.cpodes     = upshift(l_cta01m32.cpodes)
 end if

 display by name l_cta01m32.succod
 display by name l_cta01m32.aplnumdig
 display by name g_documento.solnom   attribute (reverse)
 display by name l_cta01m32.vdapdtdes attribute (reverse)
 display by name l_cta01m32.prporg
 display by name l_cta01m32.prpnumdig
 display by name l_cta01m32.emsdat
 display by name l_cta01m32.viginc
 display by name l_cta01m32.vigfnl
 display by name l_cta01m32.cpodes    attribute (reverse)
 display by name l_cta01m32.segnumdig
 display by name l_cta01m32.segnom
 display by name l_cta01m32.corsus
 display by name l_cta01m32.cornom
 display by name l_cta01m32.segteltxt
 display by name l_cta01m32.corteltxt
 display by name l_cta01m32.benefx

 let g_funeral_segnumdig = l_cta01m32.segnumdig

 display array a_cta01m32 to s_cta01m32.*

 on key (interrupt)

     exit display

 on key (F1)

 call cta01m10_vida(l_param.ramcod      ,
                    l_param.succod      ,
                    l_cta01m32.aplnumdig,
                    l_cta01m32.prporg   ,
                    l_cta01m32.prpnumdig,
                    ""                  )

 on key (F4)

 if l_cta01m32.corsus is not null then
      call ctn09c00(l_cta01m32.corsus )
 else
     error "Dados do Corretor Inexistente!"
 end if



 end display

   close window cta01m32

   let g_funeral_segnumdig = l_cta01m32.segnumdig


  return  l_cta01m32.aplnumdig,
          l_cta01m32.prporg   ,
          l_cta01m32.prpnumdig,
          l_cta01m32.segnumdig,
          l_cta01m32.succod   ,
          l_erro,
          l_param.ramcod

end function
