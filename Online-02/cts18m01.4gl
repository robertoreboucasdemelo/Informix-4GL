###############################################################################
# Nome do Modulo: CTS18M01                                           Marcelo  #
#                                                                    Gilberto #
# Informacoes sobre motorista                                        Ago/1997 #
###############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 26/02/2002  PSI 14654-4  Ruiz         Aproveitar os dados qdo da apolice  #
#                                       do "terceiro segurado".             #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#---------------------------------------------------------------------------#
# 03/03/2004 Amaury        PSI 172090 OSF 32859. Inclusao de novos parame-  #
#                                         tros na chamada da funcao cts18m01#
#---------------------------------------------------------------------------#
# 07/06/2004  Leandro(FSW) CT209325  Incluir a funcao (F5)Espelho           #
#---------------------------------------------------------------------------#
# 05/01/2010  Amilton                    projeto sucursal smallint          #
#---------------------------------------------------------------------------#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define m_segur       record
    aplnumdig         dec(9,0)                     ,
    prpnumdig         dec(8,0)                     ,
    sinmotnom         like ssammot.sinmotnom       ,
    cgccpfnum         like ssammot.cgccpfnum       ,
    cgcord            like ssammot.cgcord          ,
    cgccpfdig         like ssammot.cgccpfdig       ,
    endlgd            like ssammot.endlgd          ,
    endbrr            like ssammot.endbrr          ,
    endcid            like ssammot.endcid          ,
    endufd            like ssammot.endufd          ,
    dddcod            like gsakend.dddcod          ,
    telnum            like ssammot.telnum          ,
    cnhnum            like ssammot.cnhnum          ,
    cnhvctdat         like ssammot.cnhvctdat       ,
    sinmotidd         like ssammot.sinmotidd       ,
    sinmotsex         like ssammot.sinmotsex       ,
    cdtestcod         like ssammot.cdtestcod       ,
    sinmotprfcod      like ssammot.sinmotprfcod    ,
    sinmotprfdes      like ssammot.sinmotprfdes    ,
    sinsgrvin         like ssammot.sinsgrvin       ,
    sgrvindes         char (12),
    filler            char (01)
end record

#-----------------------------------------------------------
 function cts18m01(d_cts18m01)
#-----------------------------------------------------------

 define d_cts18m01    record
    tipchv            char (01)                    ,
    ramcod            like gtakram.ramcod         ,
    segnom            like gsakseg.segnom          ,
    sinmotnom         like ssammot.sinmotnom       ,
    cgccpfnum         like ssammot.cgccpfnum       ,
    cgcord            like ssammot.cgcord          ,
    cgccpfdig         like ssammot.cgccpfdig       ,
    endlgd            like ssammot.endlgd          ,
    endbrr            like ssammot.endbrr          ,
    endcid            like ssammot.endcid          ,
    endufd            like ssammot.endufd          ,
    dddcod            like gsakend.dddcod          ,
    telnum            like ssammot.telnum          ,
    cnhnum            like ssammot.cnhnum          ,
    cnhvctdat         like ssammot.cnhvctdat       ,
    sinmotidd         like ssammot.sinmotidd       ,
    sinmotsex         like ssammot.sinmotsex       ,
    cdtestcod         like ssammot.cdtestcod       ,
    sinmotprfcod      like ssammot.sinmotprfcod    ,
    sinmotprfdes      like ssammot.sinmotprfdes    ,
    sinsgrvin         like ssammot.sinsgrvin       ,
    vstnumdig         like avlmlaudo.vstnumdig     ,
    succod            smallint , # dec(2,0)                     , projeto succod
    aplnumdig         dec(9,0)                     ,  #---> PSI 172090
    itmnumdig         dec(7,0)                     ,  #---> PSI 172090
    prporg            dec(2,0)                     ,  #---> PSI 172090
    prpnumdig         dec(8,0)                        #---> PSI 172090
 end record

 define ws            record
    sinmotprfcod      like ssammot.sinmotprfcod,
    sinmotprfdes      like ssammot.sinmotprfdes,
    cgccpfdig         like ssammot.cgccpfdig,
    sgrvindes         char (12),
    cdtestdes         char (15),
    lintxt            char (40),
    filler            char (01),
    confirma          char (01),
    nscdat            like avlmlaudo.nscdat,
    prpflg            char(01)
 end record

 define l_ret_cts18m11            record
        tipo_motorista            char(01)
       ,nome_principal_condutor   char(50)
       ,cgccpfnum_condutor        dec(12,0)
       ,cgcord_condutor           dec(04,0)
       ,cgccpfdig_condutor        dec(02,0)
       ,cnh_condutor              dec(12,0)
       ,data_exame_condutor       date
       ,idade_condutor            dec(02,0)
       ,sexo_condutor             char(01)
      #,est_civil_condutor        smallint
      #,vinculo_condutor          char(20)
      #,cod_profissao_condutor    dec(04,0)
      #,desc_profissao_condutor   char(60)
 end record

 initialize ws.* ,l_ret_cts18m11.* to null

 open window w_cts18m01 at 13,02 with form "cts18m01"
                        attribute(form line 1, comment line last - 1)

 if d_cts18m01.ramcod = 31  or
    d_cts18m01.ramcod = 531  then
    display "SEGURADO" to cabtxt
    let ws.lintxt = "         MOTORISTA DO SEGURADO          "
 else
    if d_cts18m01.ramcod = 53  or
       d_cts18m01.ramcod = 553  then
       display "TERCEIRO" to cabtxt
       let ws.lintxt = "         MOTORISTA DO TERCEIRO          "
    else
       display "CAUSADOR" to cabtxt
       let ws.lintxt = "         MOTORISTA DO CAUSADOR          "
    end if
 end if

 if d_cts18m01.tipchv = "I"  then
    message " (F17)Abandona, (F5)Espelho, (F8)Acidente"
    if g_documento.c24astcod = "N10" then
       call cts08g01("Q", "N", "", "INFORMACOES REFERENTES AO", ws.lintxt, "")
         returning ws.confirma
    else
       if g_documento.c24astcod = "N11" then
          call cts08g01("U", "N", "", "INFORMACOES REFERENTES AO",ws.lintxt, "")
            returning ws.confirma
       end if
   end if
 else
    message " (F17)Abandona, (F5)Espelho "
 end if

 if d_cts18m01.sinsgrvin is not null  and
    d_cts18m01.sinsgrvin <> 0         then
    select cpodes into ws.sgrvindes
      from iddkdomsin
     where cponom = "sinsgrvin"    and
           cpocod = d_cts18m01.sinsgrvin

    if sqlca.sqlcode = notfound  then
       initialize ws.sgrvindes to null
    else
       display by name ws.sgrvindes
    end if
 end if
 if d_cts18m01.vstnumdig is not null and
    d_cts18m01.ramcod    =  53   or
    d_cts18m01.ramcod    =  553  then
    select cnhnum,exmvctdat,nscdat,segsexcod,estcvlcod
       into d_cts18m01.cnhnum,
            d_cts18m01.cnhvctdat,
            ws.nscdat           ,
            d_cts18m01.sinmotsex,
            d_cts18m01.cdtestcod
       from avlmlaudo
      where vstnumdig = d_cts18m01.vstnumdig
    call idade_cts18m00(ws.nscdat, today)
          returning d_cts18m01.sinmotidd
 end if

 #---> PSI 172090 - INICIO

 ## Se for uma Inclusao e atendimento for por documento
 ## informado (apolice ou proposta)
 if d_cts18m01.tipchv = "I"  and
   (d_cts18m01.aplnumdig is not null or
    d_cts18m01.prpnumdig is not null) then

    #----> Salvando os dados do Segurado
    if (d_cts18m01.aplnumdig is not null   and
        d_cts18m01.aplnumdig <> 0          and
        d_cts18m01.aplnumdig <> m_segur.aplnumdig ) or
       (d_cts18m01.prpnumdig is not null   and
        d_cts18m01.prpnumdig <> 0          and
        d_cts18m01.prpnumdig <> m_segur.prpnumdig ) then

       initialize m_segur.* to null
       let m_segur.aplnumdig     =  d_cts18m01.aplnumdig
       let m_segur.prpnumdig     =  d_cts18m01.prpnumdig
       let m_segur.sinmotnom     =  d_cts18m01.sinmotnom
       let m_segur.cgccpfnum     =  d_cts18m01.cgccpfnum
       let m_segur.cgcord        =  d_cts18m01.cgcord
       let m_segur.cgccpfdig     =  d_cts18m01.cgccpfdig
       let m_segur.endlgd        =  d_cts18m01.endlgd
       let m_segur.endbrr        =  d_cts18m01.endbrr
       let m_segur.endcid        =  d_cts18m01.endcid
       let m_segur.endufd        =  d_cts18m01.endufd
       let m_segur.dddcod        =  d_cts18m01.dddcod
       let m_segur.telnum        =  d_cts18m01.telnum
       let m_segur.cnhnum        =  d_cts18m01.cnhnum
       let m_segur.cnhvctdat     =  d_cts18m01.cnhvctdat
       let m_segur.sinmotidd     =  d_cts18m01.sinmotidd
       let m_segur.sinmotsex     =  d_cts18m01.sinmotsex
       let m_segur.cdtestcod     =  d_cts18m01.cdtestcod
       let m_segur.sinsgrvin     =  d_cts18m01.sinsgrvin
       let m_segur.sgrvindes     =  ws.sgrvindes
       let m_segur.sinmotprfcod  =  d_cts18m01.sinmotprfcod
       let m_segur.sinmotprfdes  =  d_cts18m01.sinmotprfdes
       let m_segur.filler        =  ws.filler
    end if

    ## Metodo para selecionar o condutor no momento do sinistro
    initialize l_ret_cts18m11.* to null
    call cts18m11_condutor_veiculo(d_cts18m01.succod    ,d_cts18m01.aplnumdig
                                  ,d_cts18m01.itmnumdig ,d_cts18m01.sinmotnom
                                  ,d_cts18m01.prporg    ,d_cts18m01.prpnumdig)
         returning l_ret_cts18m11.*

    #--------------------------------------------------------
    # Se foi escolhido o principal condutor, assumir os
    # dados do principal condutor
    #--------------------------------------------------------
    if l_ret_cts18m11.tipo_motorista  = "C" then
       let d_cts18m01.sinmotnom    = l_ret_cts18m11.nome_principal_condutor
       let d_cts18m01.cgccpfnum    = l_ret_cts18m11.cgccpfnum_condutor
       let d_cts18m01.cgcord       = l_ret_cts18m11.cgcord_condutor
       let d_cts18m01.cgccpfdig    = l_ret_cts18m11.cgccpfdig_condutor
       let d_cts18m01.cnhnum       = l_ret_cts18m11.cnh_condutor
       let d_cts18m01.cnhvctdat    = l_ret_cts18m11.data_exame_condutor
       let d_cts18m01.sinmotidd    = l_ret_cts18m11.idade_condutor
       let d_cts18m01.sinmotsex    = l_ret_cts18m11.sexo_condutor
       let d_cts18m01.cdtestcod    = null
       let d_cts18m01.sinsgrvin    = null
       let ws.sgrvindes            = null
       let d_cts18m01.sinmotprfcod = null
       let d_cts18m01.sinmotprfdes = null
    end if
    if l_ret_cts18m11.tipo_motorista  = "O" then  #Outros
       let d_cts18m01.sinmotnom     = null
       let d_cts18m01.cgccpfnum     = null
       let d_cts18m01.cgcord        = null
       let d_cts18m01.cgccpfdig     = null
       let d_cts18m01.endlgd        = null
       let d_cts18m01.endbrr        = null
       let d_cts18m01.endcid        = null
       let d_cts18m01.endufd        = null
       let d_cts18m01.dddcod        = null
       let d_cts18m01.telnum        = null
       let d_cts18m01.cnhnum        = null
       let d_cts18m01.cnhvctdat     = null
       let d_cts18m01.sinmotidd     = null
       let d_cts18m01.sinmotsex     = null
       let d_cts18m01.cdtestcod     = null
       let d_cts18m01.sinsgrvin     = null
       let ws.sgrvindes             = null
       let d_cts18m01.sinmotprfcod  = null
       let d_cts18m01.sinmotprfdes  = null
       let ws.filler                = null
    end if
    if l_ret_cts18m11.tipo_motorista  = "S" then  #Segurado
       #----> Manter os dados da tela
       let d_cts18m01.sinmotnom     =  m_segur.sinmotnom
       let d_cts18m01.cgccpfnum     =  m_segur.cgccpfnum
       let d_cts18m01.cgcord        =  m_segur.cgcord
       let d_cts18m01.cgccpfdig     =  m_segur.cgccpfdig
       let d_cts18m01.endlgd        =  m_segur.endlgd
       let d_cts18m01.endbrr        =  m_segur.endbrr
       let d_cts18m01.endcid        =  m_segur.endcid
       let d_cts18m01.endufd        =  m_segur.endufd
       let d_cts18m01.dddcod        =  m_segur.dddcod
       let d_cts18m01.telnum        =  m_segur.telnum
       let d_cts18m01.cnhnum        =  m_segur.cnhnum
       let d_cts18m01.cnhvctdat     =  m_segur.cnhvctdat
       let d_cts18m01.sinmotidd     =  m_segur.sinmotidd
       let d_cts18m01.sinmotsex     =  m_segur.sinmotsex
       let d_cts18m01.cdtestcod     =  m_segur.cdtestcod
       let d_cts18m01.sinsgrvin     =  m_segur.sinsgrvin
       let ws.sgrvindes             =  m_segur.sgrvindes
       let d_cts18m01.sinmotprfcod  =  m_segur.sinmotprfcod
       let d_cts18m01.sinmotprfdes  =  m_segur.sinmotprfdes
       let ws.filler                =  m_segur.filler
    end if
 end if
 #---> PSI 172090 - FIM

 input by name d_cts18m01.sinmotnom   ,
               d_cts18m01.cgccpfnum   ,
               d_cts18m01.cgcord      ,
               d_cts18m01.cgccpfdig   ,
               d_cts18m01.endlgd      ,
               d_cts18m01.endbrr      ,
               d_cts18m01.endcid      ,
               d_cts18m01.endufd      ,
               d_cts18m01.dddcod      ,
               d_cts18m01.telnum      ,
               d_cts18m01.cnhnum      ,
               d_cts18m01.cnhvctdat   ,
               d_cts18m01.sinmotidd   ,
               d_cts18m01.sinmotsex   ,
               d_cts18m01.cdtestcod   ,
               ws.sgrvindes           ,
               d_cts18m01.sinmotprfcod,
               d_cts18m01.sinmotprfdes,
               ws.filler                 without defaults


   before field sinmotnom
      if d_cts18m01.tipchv = "S"  then
         next field filler
      end if

      if d_cts18m01.tipchv = "M"           and
         d_cts18m01.sinmotnom is not null  then
         display by name d_cts18m01.sinmotnom

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field filler
         else
            next field cgccpfnum
         end if
      else
         display by name d_cts18m01.sinmotnom  attribute (reverse)
      end if

   after  field sinmotnom
      display by name d_cts18m01.sinmotnom

      if d_cts18m01.ramcod <> 99       and
         d_cts18m01.sinmotnom is null  then
         error " Nome do motorista deve ser informado!"
         next field sinmotnom
      end if

   before field cgccpfnum
      if d_cts18m01.tipchv = "M"           and
         d_cts18m01.cgccpfnum is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field sinmotnom
         else
            next field endlgd
         end if
      end if

      display by name d_cts18m01.cgccpfnum  attribute (reverse)

   after  field cgccpfnum
      display by name d_cts18m01.cgccpfnum

      if fgl_lastkey() <> fgl_keyval("up")    and
         fgl_lastkey() <> fgl_keyval("left")  then
         if d_cts18m01.cgccpfnum is null  then
            initialize d_cts18m01.cgcord, d_cts18m01.cgccpfdig to null
            display by name d_cts18m01.cgcord
            display by name d_cts18m01.cgccpfdig
            next field endlgd
         end if
      end if

   before field cgcord
      display by name d_cts18m01.cgcord  attribute (reverse)

   after  field cgcord
      display by name d_cts18m01.cgcord

   before field cgccpfdig
      if fgl_lastkey() = fgl_keyval("up")    or
         fgl_lastkey() = fgl_keyval("left")  then
         if d_cts18m01.cgccpfnum is null  then
            next field cgccpfnum
         end if
      end if

      display by name d_cts18m01.cgccpfdig  attribute (reverse)

   after  field cgccpfdig
      display by name d_cts18m01.cgccpfdig

      if fgl_lastkey() <> fgl_keyval("up")    and
         fgl_lastkey() <> fgl_keyval("left")  then
         if d_cts18m01.cgccpfnum is null  then
            initialize d_cts18m01.cgcord, d_cts18m01.cgccpfdig to null
            display by name d_cts18m01.cgcord
            display by name d_cts18m01.cgccpfdig
            next field endlgd
         end if
      end if

      if d_cts18m01.cgccpfnum is not null  then
         if d_cts18m01.cgccpfdig is null  then
            error " Digito do CGC/CPF deve ser informado!"
            next field cgccpfdig
         end if

         let ws.cgccpfdig = 0

         if d_cts18m01.cgcord is not null  then
            call f_fundigit_digitocgc(d_cts18m01.cgccpfnum, d_cts18m01.cgcord)
                            returning ws.cgccpfdig
         else
            call f_fundigit_digitocpf(d_cts18m01.cgccpfnum)
                            returning ws.cgccpfdig
         end if

         if ws.cgccpfdig         is null          or
            d_cts18m01.cgccpfdig <> ws.cgccpfdig  then
            if d_cts18m01.tipchv = "M"  then
               initialize d_cts18m01.cgccpfnum,
                          d_cts18m01.cgcord   ,
                           d_cts18m01.cgccpfdig  to null
               display by name d_cts18m01.cgccpfdig
            end if
            error " Digito do CGC/CPF incorreto! Informe novamente."
            next field cgccpfnum
         end if
      end if

   before field endlgd
      if d_cts18m01.tipchv = "M"        and
         d_cts18m01.endlgd is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field cgccpfdig
         else
            next field endbrr
         end if
      end if

      display by name d_cts18m01.endlgd  attribute (reverse)

   after  field endlgd
      display by name d_cts18m01.endlgd

      if fgl_lastkey() <> fgl_keyval("up")    and
         fgl_lastkey() <> fgl_keyval("left")  then
         if d_cts18m01.ramcod <> 99    and
            d_cts18m01.endlgd is null  then
            error " Endereco do motorista deve ser informado!"
            next field endlgd
         end if
      end if

   before field endbrr
      if d_cts18m01.tipchv = "M"        and
         d_cts18m01.endbrr is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field endlgd
         else
            next field endcid
         end if
      end if

      display by name d_cts18m01.endbrr  attribute (reverse)

   after  field endbrr
      display by name d_cts18m01.endbrr

   before field endcid
      if d_cts18m01.tipchv = "M"        and
         d_cts18m01.endcid is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field endbrr
         else
            next field endufd
         end if
      end if

      display by name d_cts18m01.endcid  attribute (reverse)

   after  field endcid
      display by name d_cts18m01.endcid

   before field endufd
      if d_cts18m01.tipchv = "M"        and
         d_cts18m01.endufd is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field endcid
         else
            next field dddcod
         end if
      end if

      display by name d_cts18m01.endufd  attribute (reverse)

   after  field endufd
      display by name d_cts18m01.endufd

      if d_cts18m01.endufd is not null  then
         select ufdcod from glakest
          where ufdcod = d_cts18m01.endufd

         if sqlca.sqlcode = notfound  then
            error " Unidade federativa nao cadastrada!"
            next field endufd
         end if
      end if

   before field dddcod
      if d_cts18m01.tipchv = "M"        and
         d_cts18m01.dddcod is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field endufd
         else
            next field telnum
         end if
      end if

      display by name d_cts18m01.dddcod  attribute (reverse)

   after  field dddcod
      display by name d_cts18m01.dddcod

   before field telnum
      if d_cts18m01.tipchv = "M"        and
         d_cts18m01.telnum is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field dddcod
         else
            next field cnhnum
         end if
      end if

      display by name d_cts18m01.telnum  attribute (reverse)

   after  field telnum
      display by name d_cts18m01.telnum

   before field cnhnum
      if d_cts18m01.tipchv = "M"        and
         d_cts18m01.cnhnum is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field telnum
         else
            next field cnhvctdat
         end if
      end if

      display by name d_cts18m01.cnhnum  attribute (reverse)

   after  field cnhnum
      display by name d_cts18m01.cnhnum

   before field cnhvctdat
      if d_cts18m01.tipchv = "M"           and
         d_cts18m01.cnhvctdat is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field cnhnum
         else
            if d_cts18m01.ramcod <> 31   and
               d_cts18m01.ramcod <> 531  then
               next field cdtestcod
            else
               next field sinmotidd
            end if
         end if
      end if

      display by name d_cts18m01.cnhvctdat  attribute (reverse)

   after  field cnhvctdat
      display by name d_cts18m01.cnhvctdat

      if d_cts18m01.cnhvctdat < today  then
         error " Carteira de habilitacao vencida!"
      end if

      if d_cts18m01.ramcod = 31   or
         d_cts18m01.ramcod = 531  then
         if d_cts18m01.sinsgrvin is null  then
            let d_cts18m01.sinsgrvin = 0
         end if
      else
         next field cdtestcod
      end if

   before field sinmotidd
      if d_cts18m01.tipchv = "M"           and
         d_cts18m01.sinmotidd is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field cnhvctdat
         else
            next field sinmotsex
         end if
      end if

      display by name d_cts18m01.sinmotidd  attribute (reverse)

   after  field sinmotidd
      display by name d_cts18m01.sinmotidd

      if d_cts18m01.sinmotidd is not null  then
         if d_cts18m01.sinmotidd < 10  then
            error " Idade invalida!"
            next field sinmotidd
         end if

         if d_cts18m01.sinmotidd < 18  then
            error " Motorista menor de idade!"
         end if
      end if

   before field sinmotsex
      if d_cts18m01.tipchv = "M"           and
         d_cts18m01.sinmotsex is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field sinmotidd
         else
            next field cdtestcod
         end if
      end if

      display by name d_cts18m01.sinmotsex  attribute (reverse)

   after  field sinmotsex
      display by name d_cts18m01.sinmotsex

      if fgl_lastkey() <> fgl_keyval("up")    and
         fgl_lastkey() <> fgl_keyval("left")  then
         if d_cts18m01.sinmotsex is null  then
            error " Sexo do motorista deve ser informado!"
            next field sinmotsex
         else
            if d_cts18m01.sinmotsex <> "M"  and
               d_cts18m01.sinmotsex <> "F"  then
               error " Sexo do motorista deve ser (M)asculino ou (F)eminino!"
               next field sinmotsex
            end if
         end if
      end if

   before field cdtestcod
      if d_cts18m01.tipchv = "M"           and
         d_cts18m01.cdtestcod is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            if d_cts18m01.ramcod = 31  or
               d_cts18m01.ramcod = 531  then
               next field sinmotsex
            else
               next field cnhvctdat
            end if
         else
            if d_cts18m01.ramcod = 31   or
               d_cts18m01.ramcod = 531  then
               next field sgrvindes
            else
               next field filler
            end if
         end if
      end if

      display by name d_cts18m01.cdtestcod  attribute (reverse)

   after  field cdtestcod
      display by name d_cts18m01.cdtestcod

      if fgl_lastkey() <> fgl_keyval("up")    and
         fgl_lastkey() <> fgl_keyval("left")  then
         if d_cts18m01.cdtestcod is null  then
            error " Estado civil do motorista deve ser informado!"
            call festcivil()
                 returning d_cts18m01.cdtestcod, ws.cdtestdes
            next field cdtestcod
         else
            select *  from  iddkdominio
             where cponom = "estcvlcod"
               and cpocod = d_cts18m01.cdtestcod

            if sqlca.sqlcode = notfound   then
               error " Codigo de estado civil nao cadastrado!"
               next field cdtestcod
            end if
         end if
      end if

      if d_cts18m01.ramcod <> 31  and
         d_cts18m01.ramcod <> 531  then
         next field filler
      end if

   before field sgrvindes
      if d_cts18m01.segnom = d_cts18m01.sinmotnom  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field cdtestcod
         else
            next field sinmotprfdes
         end if
      else
         if d_cts18m01.tipchv = "M"   and
            ws.sgrvindes is not null  then
            if fgl_lastkey() = fgl_keyval("up")    or
               fgl_lastkey() = fgl_keyval("left")  then
               next field cdtestcod
            else
               next field sinmotprfdes
            end if
         else
            display by name ws.sgrvindes  attribute (reverse)
         end if
      end if

   after  field sgrvindes
      display by name ws.sgrvindes

      if fgl_lastkey() <> fgl_keyval("up")    and
         fgl_lastkey() <> fgl_keyval("left")  then
         if ws.sgrvindes is null  then
            error " Vinculo com o segurado deve ser informado!"
            call cts18m06() returning d_cts18m01.sinsgrvin, ws.sgrvindes
            next field sgrvindes
         else
            select cpocod into d_cts18m01.sinsgrvin
              from iddkdomsin
             where cponom = "sinsgrvin"
               and cpodes = ws.sgrvindes

            if sqlca.sqlcode = notfound  then
               error " Tipo de vinculo nao cadastrado!"
               call cts18m06() returning d_cts18m01.sinsgrvin, ws.sgrvindes
               next field sgrvindes
            end if
         end if
      end if

      display by name ws.sgrvindes



   before field sinmotprfdes
      if  d_cts18m01.sinmotprfcod is not null  then
          if  d_cts18m01.sinmotprfcod <> 999       then
              select irfprfdes
                into d_cts18m01.sinmotprfdes
                from ssakprf
                     where irfprfcod = d_cts18m01.sinmotprfcod

              if  sqlca.sqlcode <> 0  then
                  error " Erro (", sqlca.sqlcode, ") na localizacao da",
                        " profissao. AVISE A INFORMATICA!"
              end if
          else
              initialize d_cts18m01.sinmotprfcod to null
          end if
      end if

      display by name d_cts18m01.sinmotprfdes  attribute (reverse)

   after  field sinmotprfdes
      display by name d_cts18m01.sinmotprfdes

      if  fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          if  d_cts18m01.segnom = d_cts18m01.sinmotnom  then
              next field sinmotsex
          else
              next field sgrvindes
          end if
      end if

      if  d_cts18m01.sinmotprfdes is null  then
          error " Descricao da profissao deve ser informada!"
          next field sinmotprfdes
      end if

      call cts18m05( d_cts18m01.sinmotprfdes )
           returning ws.sinmotprfcod,
                     ws.sinmotprfdes

      if  ws.sinmotprfcod is null  then
          next field sinmotprfdes
      else
          let d_cts18m01.sinmotprfcod = ws.sinmotprfcod
          if  ws.sinmotprfcod <> 999  then  # Outros
              let d_cts18m01.sinmotprfdes = ws.sinmotprfdes
          end if
      end if

      display by name d_cts18m01.sinmotprfdes


   before field filler
      if d_cts18m01.tipchv = "I"  then
         exit input
      else
         error " Pressione ENTER para continuar... "
      end if

   after  field filler
      if fgl_lastkey() = fgl_keyval("return")  then
         exit input
      else
         next field filler
      end if

   on key (F5)
{
      if d_cts18m01.succod    is not null  and
	 d_cts18m01.ramcod    is not null  and
	 d_cts18m01.aplnumdig is not null  then
	 if d_cts18m01.ramcod = 31    or
	    d_cts18m01.ramcod = 531  then
	    call cta01m00()
	 else
	    call cta01m20()
         end if
      else
        if d_cts18m01.prporg is not null and
	   d_cts18m01.prpnumdig is not null  then
	   call opacc149(d_cts18m01.prporg, d_cts18m01.prpnumdig)
		returning ws.prpflg
        else
	   if g_documento.pcacarnum is not null  and
	      g_documento.pcaprpitm is not null  then
	      call cta01m50(g_documento.pcacarnum, g_documento.pcaprpitm)
	   else
	      error " Espelho so' com documento localizado!"
           end if
        end if
     end if
}
     let g_monitor.horaini = current ## Flexvision
     call cta01m12_espelho(g_documento.ramcod,
                            g_documento.succod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            g_documento.prporg,
                            g_documento.prpnumdig,
                            g_documento.fcapacorg,
                            g_documento.fcapacnum,
                            g_documento.pcacarnum,
                            g_documento.pcaprpitm,
                            g_ppt.cmnnumdig,
                            g_documento.crtsaunum,
                            g_documento.bnfnum,
                            g_documento.ciaempcod)

   on key (interrupt)
      exit input

   on key (F8)
      if d_cts18m01.tipchv = "I"  then
         exit input
      end if
 end input

 close window w_cts18m01

 return d_cts18m01.sinmotnom thru d_cts18m01.vstnumdig

end function  ###  cts18m01
