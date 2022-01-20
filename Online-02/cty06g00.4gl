#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cty06g00.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 183.431                                                    #
# OSF           : 036.439                                                    #
#                 Seleciona dados da apolice                                 #
#............................................................................#
# Desenvolvimento: Meta, Robson Inocencio                                    #
# Liberacao      : 21/07/2004                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 23/07/2004 Bruno, Meta       PSI 186376 Criacao de novas funcoes:          #
#                              OSF  38105  - cty06g00_obter_seguro()         #
#                                          - cty06g00_segnumdig()            #
#                                          - cty06g00_convenio()             #
# 06/04/2009 Ligia Mattge      PSI198404  Incluir a funcao cty06g00_modal_re #
#----------------------------------------------------------------------------#

database porto
globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep_sql   smallint

#---------------------------#
 function cty06g00_prepare()
#---------------------------#

  define l_sql        char(400)
  let l_sql = " select sgrorg, sgrnumdig "
             ,"   from rsamseguro "
             ,"  where succod    = ? "
             ,"    and ramcod    = ? "
             ,"    and aplnumdig = ? "
  prepare pcty06g00001  from l_sql
  declare ccty06g00001  cursor for pcty06g00001

  let l_sql = " select vigfnl, edsstt "
             ,"   from rsdmdocto "
             ,"  where sgrorg    = ? "
             ,"    and sgrnumdig = ? "
             ,"    and dctnumseq = 1 "
  prepare pcty06g00002  from l_sql
  declare ccty06g00002  cursor for pcty06g00002
    let l_sql = " select max(dctnumseq) "
               ,"   from rsdmdocto      "
               ,"  where sgrorg    = ?  "
               ,"    and sgrnumdig = ?  "
  prepare pcty06g00003  from l_sql
  declare ccty06g00003  cursor for pcty06g00003
    let l_sql = " select prporg, prpnumdig, "
               ,"        segnumdig, edsnumdig "
               ,"   from rsdmdocto "
               ,"  where sgrorg    = ? "
               ,"    and sgrnumdig = ? "
               ,"    and dctnumseq = ? "
  prepare pcty06g00004  from l_sql
  declare ccty06g00004  cursor for pcty06g00004

    let l_sql = " select succod, aplnumdig "
               ,"   from rgrmgrevcl, rsamseguro "
               ,"  where rgrmgrevcl.grevclctfnum = ? "
               ,"    and rsamseguro.sgrorg    = rgrmgrevcl.prporg "
               ,"    and rsamseguro.sgrnumdig = rgrmgrevcl.prpnumdig "
               ,"    and rsamseguro.ramcod    = ? "
  prepare pcty06g00005  from l_sql
  declare ccty06g00005  cursor for pcty06g00005
  # PSI 186376 - Inicio --
  let l_sql = " select segnumdig "
             ,"   from rsdmdocto "
             ,"  where sgrorg = ? "
             ,"    and sgrnumdig = ? "
             ,"    and dctnumseq = (select max(dctnumseq) "
             ,"                       from rsdmdocto "
             ,"                      where sgrorg = ? "
             ,"                        and sgrnumdig = ? "
             ,"                        and prpstt in (19,65,66,88) ) "
  prepare pcty06g00006 from l_sql
  declare ccty06g00006 cursor for pcty06g00006
  let l_sql = " select segnumdig "
             ,"   from rsdmdocto "
             ,"  where prporg = ? "
             ,"    and prpnumdig = ? "
  prepare pcty06g00007 from l_sql
  declare ccty06g00007 cursor for pcty06g00007

  let l_sql = " select a.prporg, "
             ,"        a.prpnumdig "
             ,"   from rsdmdocto a, "
             ,"        rsamseguro b "
             ,"  where a.sgrorg = b.sgrorg "
             ,"    and a.sgrnumdig = b.sgrnumdig "
             ,"    and b.ramcod = ? "
             ,"    and b.succod = ? "
             ,"    and b.aplnumdig = ? "
  prepare pcty06g00008 from l_sql
  declare ccty06g00008 cursor for pcty06g00008
  let l_sql = " select cvnnum "
             ,"   from rsdmcvnnum "
             ,"  where prporg = ? "
             ,"    and prpnumdig = ? "
  prepare pcty06g00009 from l_sql
  declare ccty06g00009 cursor for pcty06g00009
  # PSI 186376 - Final --
  let l_sql = " select vigfnl, edsstt "
             ,"   from rsdmdocto "
             ,"  where sgrorg    = ? "
             ,"    and sgrnumdig = ? "
             ,"    and dctnumseq = (select max(dctnumseq) "
             ,"                       from rsdmdocto "
             ,"                      where sgrorg = ? "
             ,"                        and sgrnumdig = ? "
             ,"                        and prpstt in (19,65,66,88) ) "
  prepare pcty06g00010  from l_sql
  declare ccty06g00010  cursor for pcty06g00010

  let l_sql = " select rmemdlcod "
             ,"   from rsamseguro "
             ,"  where succod    = ? "
             ,"    and ramcod    = ? "
             ,"    and aplnumdig = ? "
  prepare pcty06g00011  from l_sql
  declare ccty06g00011  cursor for pcty06g00011
  let l_sql = ' select clscod         '
             ,' from rsdmclaus        '
             ,' where prporg    = ?   '
             ,'   and prpnumdig = ?   '
             ,'   and lclnumseq = ?   '
             ,'   and rmerscseq = ?   '
             ,'   and clsstt    = "A" '
  prepare pcty06g00012  from l_sql
  declare ccty06g00012  cursor for pcty06g00012
  let l_sql = ' select clscod from datrastcls ',
              '  where c24astcod = ? ',
              '  and ramcod = ? ',
              '  and clscod = ? '
  prepare pcty06g00013 from l_sql
  declare ccty06g00013 cursor for pcty06g00013
  let l_sql = ' select clscod  ',
              '  from rsdmclaus ',
              ' where prporg    = ? ',
              '  and  prpnumdig = ? ',
              '  and  lclnumseq = ? ',
              '  and  clsstt    = "A" '
  prepare pcty06g00014 from l_sql
  declare ccty06g00014 cursor for pcty06g00014
  let m_prep_sql = true
end function

#------------------------------------------#
function cty06g00_dados_apolice(lr_param)
#------------------------------------------#
  define lr_param       record
         succod         like rsamseguro.succod
        ,ramcod         like rsamseguro.ramcod
        ,aplnumdig      like rsamseguro.aplnumdig
	,ramsgl         char(15)
  end record

  define lr_rsamseguro  record
         sgrorg         like rsamseguro.sgrorg
        ,sgrnumdig      like rsamseguro.sgrnumdig
  end record

  define lr_rsdmdocto   record
         vigfnl         like rsdmdocto.vigfnl
        ,edsstt         like rsdmdocto.edsstt
        ,prporg         like rsdmdocto.prporg
        ,prpnumdig      like rsdmdocto.prpnumdig
        ,segnumdig      like rsdmdocto.segnumdig
        ,edsnumdig      like rsdmdocto.edsnumdig
  end record

  define lr_retorno     record
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

  define l_dctnumseq    like rsdmdocto.dctnumseq
        ,l_msg          char(60)
  if m_prep_sql is null or m_prep_sql <> true then
     call cty06g00_prepare()
  end if
  initialize lr_rsamseguro to null
  initialize lr_rsdmdocto  to null
  initialize lr_retorno    to null
  let l_dctnumseq = null
  open ccty06g00001  using lr_param.succod,
			   lr_param.ramcod,
			   lr_param.aplnumdig
  whenever error continue
  fetch ccty06g00001 into  lr_rsamseguro.*
  whenever error stop
  if sqlca.sqlcode = 0 then
     let lr_retorno.resultado = 1
     close ccty06g00001
  else
     if sqlca.sqlcode = notfound then
        let lr_retorno.resultado = 2
        let lr_retorno.mensagem  = "Apolice de RAMOS ELEMENTARES nao cadastrada!"
        let l_msg = "Apolice de RAMOS ELEMENTARES nao cadastrada!"
        call errorlog(l_msg)
     else
        let lr_retorno.resultado = 3
        let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode, " em rsamseguro"
        let l_msg = " Erro de SELECT - ccty06g00001 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
        call errorlog(l_msg)
        let l_msg = " cty06g00_dados_apolice() / ",lr_param.ramcod, " / ",
                                                   lr_param.aplnumdig, " / ",
                                                   lr_param.succod
        call errorlog(l_msg)
     end if
     close ccty06g00001
     return lr_retorno.*
   end if

   if lr_param.ramsgl = "TRANSP" then
      open ccty06g00002  using lr_rsamseguro.sgrorg, lr_rsamseguro.sgrnumdig
      whenever error continue
      fetch ccty06g00002 into  lr_rsdmdocto.vigfnl, lr_rsdmdocto.edsstt
      whenever error stop
      if sqlca.sqlcode = 0 then
         let lr_retorno.resultado = 1
         close ccty06g00002
      else
        if sqlca.sqlcode = notfound then
           let lr_retorno.resultado = 2
           let lr_retorno.mensagem  = "Vigencia nao cadastrada!"
           let l_msg = "Vigencia nao cadastrada!"
           call errorlog(l_msg)
        else
           let lr_retorno.resultado = 3
           let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode, " em rsdmdocto"
           let l_msg = " Erro de SELECT - ccty06g00002 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
           call errorlog(l_msg)
           let l_msg = " cty06g00_dados_apolice() / ",lr_rsamseguro.sgrorg, " / ",
                                                   lr_rsamseguro.sgrnumdig
           call errorlog(l_msg)
        end if
        close ccty06g00002
        return lr_retorno.*
      end if
 else
      open ccty06g00010  using lr_rsamseguro.sgrorg, lr_rsamseguro.sgrnumdig,
			       lr_rsamseguro.sgrorg, lr_rsamseguro.sgrnumdig
      whenever error continue
      fetch ccty06g00010 into  lr_rsdmdocto.vigfnl, lr_rsdmdocto.edsstt
      whenever error stop
      if sqlca.sqlcode = 0 then
         let lr_retorno.resultado = 1
         close ccty06g00010
      else
        if sqlca.sqlcode = notfound then
           let lr_retorno.resultado = 2
           let lr_retorno.mensagem  = "Vigencia nao cadastrada!"
           let l_msg = "Vigencia nao cadastrada!"
           call errorlog(l_msg)
        else
           let lr_retorno.resultado = 3
           let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode, " em rsdmdocto"
           let l_msg = " Erro de SELECT - ccty06g00010 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
           call errorlog(l_msg)
           let l_msg = " cty06g00_dados_apolice() / ",lr_rsamseguro.sgrorg, " / ",
                                                   lr_rsamseguro.sgrnumdig
           call errorlog(l_msg)
        end if
        close ccty06g00010
        return lr_retorno.*
      end if
  end if

   open ccty06g00003  using lr_rsamseguro.sgrorg, lr_rsamseguro.sgrnumdig
   whenever error continue
   fetch ccty06g00003 into l_dctnumseq
   whenever error stop
   if sqlca.sqlcode = 0 then
      open ccty06g00004  using lr_rsamseguro.sgrorg
                              ,lr_rsamseguro.sgrnumdig
                              ,l_dctnumseq
      whenever error continue
      fetch ccty06g00004 into lr_rsdmdocto.prporg
                             ,lr_rsdmdocto.prpnumdig
                             ,lr_rsdmdocto.segnumdig
                             ,lr_rsdmdocto.edsnumdig
      whenever error stop
      if sqlca.sqlcode = 0 then
         let lr_retorno.sgrorg     = lr_rsamseguro.sgrorg
         let lr_retorno.sgrnumdig  = lr_rsamseguro.sgrnumdig
         let lr_retorno.vigfnl     = lr_rsdmdocto.vigfnl
         let lr_retorno.aplstt     = lr_rsdmdocto.edsstt
         let lr_retorno.prporg     = lr_rsdmdocto.prporg
         let lr_retorno.prpnumdig  = lr_rsdmdocto.prpnumdig
         let lr_retorno.segnumdig  = lr_rsdmdocto.segnumdig
         let lr_retorno.edsnumref  = lr_rsdmdocto.edsnumdig
      else
         if sqlca.sqlcode = notfound then
            let lr_retorno.resultado = 2
            let lr_retorno.mensagem  = "Proposta nao encontrada!"
            let l_msg = "Proposta nao encontrada!"
            call errorlog(l_msg)
         else
            let lr_retorno.resultado = 3
            let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode, " em rsdmdocto"
            let l_msg = " Erro de SELECT - ccty06g00004 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
            call errorlog(l_msg)
            let l_msg = " cty06g00_dados_apolice() / ",lr_rsamseguro.sgrorg, " / ",
                                                       lr_rsamseguro.sgrnumdig, " / ",
                                                       l_dctnumseq
            call errorlog(l_msg)
         end if
      end if
      close ccty06g00004
   else
      let lr_retorno.resultado = 3
      let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode, " em rsdmdocto"
      let l_msg = " Erro de SELECT - ccty06g00003 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
      call errorlog(l_msg)
      let l_msg = " cty06g00_dados_apolice() / ",lr_rsamseguro.sgrorg, " / ",
                                                 lr_rsamseguro.sgrnumdig
      call errorlog(l_msg)
   end if
   close ccty06g00003
   return lr_retorno.*
end function

#-----------------------------------------------#
function cty06g00_apolice_certificado(lr_param)
#-----------------------------------------------#
   define lr_param       record
          grevclctfun    like rgrmgrevcl.grevclctfnum
         ,ramcod         like rsamseguro.ramcod
   end record

   define lr_retorno     record
          resultado      smallint
         ,mensagem       char(60)
         ,succod         like rsamseguro.succod
         ,aplnumdig      like rsamseguro.aplnumdig
   end record

   define l_msg          char(60)
   if m_prep_sql is null or m_prep_sql <> true then
      call cty06g00_prepare()
   end if
   initialize lr_retorno to null
   open ccty06g00005  using lr_param.grevclctfun, lr_param.ramcod
   whenever error continue
   fetch ccty06g00005 into lr_retorno.succod, lr_retorno.aplnumdig
   whenever error stop
   if sqlca.sqlcode = 0 then
      let lr_retorno.resultado = 1
   else
      if sqlca.sqlcode = notfound then
         let lr_retorno.resultado = 2
         let lr_retorno.mensagem  = "Nenhuma apolice foi localizada!"
         let l_msg = "Nenhuma apolice foi localizada!"
         call errorlog(l_msg)
      else
         let lr_retorno.resultado = 3
         let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode, " em rgrmgrevcl, rsamseguro"
         let l_msg = " Erro de SELECT - ccty06g00005 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
         call errorlog(l_msg)
         let l_msg = " cty06g00_apolice_certificado() / ",lr_param.grevclctfun, " / ",
                                                          lr_param.ramcod
         call errorlog(l_msg)
      end if
   end if
   close ccty06g00005
   return lr_retorno.*
end function

# --- PSI 186376 - Inicio --
#==============================================================================
 function cty06g00_obter_seguro(lr_param)
#==============================================================================

 define lr_param   record
     ramcod        like rsamseguro.ramcod
    ,succod        like rsamseguro.succod
    ,aplnumdig     like rsamseguro.aplnumdig
 end record
 define lr_retorno record
     status        smallint
    ,mensagem      char(50)
    ,sgrorg        like rsamseguro.sgrorg
    ,sgrnumdig     like rsamseguro.sgrnumdig
 end record

 initialize lr_retorno.* to null

 if m_prep_sql is null or m_prep_sql <> true then
    call cty06g00_prepare()
 end if

 open ccty06g00001 using lr_param.succod
                        ,lr_param.ramcod
                        ,lr_param.aplnumdig
 whenever error continue
 fetch ccty06g00001 into lr_retorno.sgrorg
                        ,lr_retorno.sgrnumdig
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> 100 then
       let lr_retorno.mensagem = 'Erro de SQL ccty06g00001 ',sqlca.sqlcode,'/',sqlca.sqlerrd[2]
       call errorlog(lr_retorno.mensagem)
       let lr_retorno.mensagem = 'cty06g00_obter_seguro()/',lr_param.succod
                                                       ,'/',lr_param.ramcod
                                                       ,'/',lr_param.aplnumdig
       call errorlog(lr_retorno.mensagem)
       let lr_retorno.mensagem = 'Erro ',sqlca.sqlcode,' em rsamseguro '
       let lr_retorno.status = 3
    else
       let lr_retorno.mensagem = 'Seguro nao encontrado'
       call errorlog(lr_retorno.mensagem)
       let lr_retorno.status = 2
    end if
 else
    let lr_retorno.status = 1
 end if

 return lr_retorno.*
 end function # -- cty06g00_obter_seguro()

#==============================================================================
 function cty06g00_segnumdig(lr_param)
#==============================================================================

 define lr_param   record
     sgrorg        like rsdmdocto.sgrorg
    ,sgrnumdig     like rsdmdocto.sgrnumdig
    ,prporg        like rsdmdocto.prporg
    ,prpnumdig     like rsdmdocto.prpnumdig
 end record
 define lr_retorno record
     status        smallint
    ,mensagem      char(50)
    ,segnumdig     like rsdmdocto.segnumdig
 end record

 initialize lr_retorno.* to null

 if m_prep_sql is null or m_prep_sql <> true then
    call cty06g00_prepare()
 end if

 if lr_param.sgrorg is not null and
    lr_param.sgrnumdig is not null then
    open ccty06g00006 using lr_param.sgrorg, lr_param.sgrnumdig,
                            lr_param.sgrorg, lr_param.sgrnumdig
    whenever error continue
    fetch ccty06g00006 into lr_retorno.segnumdig
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode <> 100 then
          let lr_retorno.mensagem = 'Erro de SQL ccty06g00006 ',sqlca.sqlcode,'/',sqlca.sqlerrd[2]
          call errorlog(lr_retorno.mensagem)
          let lr_retorno.mensagem = 'cty06g00_segnumdig()/',lr_param.sgrorg
                                                       ,'/',lr_param.sgrnumdig
          call errorlog(lr_retorno.mensagem)
          let lr_retorno.mensagem = 'Erro ',sqlca.sqlcode,' em rsdmdocto '
          let lr_retorno.status = 3
       else
          let lr_retorno.mensagem = 'Codigo do Segurado nao encontrado'
          call errorlog(lr_retorno.mensagem)
          let lr_retorno.status = 2
       end if
    else
       let lr_retorno.status = 1
    end if
 else
    open ccty06g00007 using lr_param.prporg, lr_param.prpnumdig
    whenever error continue
    fetch ccty06g00007 into lr_retorno.segnumdig
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode <> 100 then
          let lr_retorno.mensagem = 'Erro de SQL ccty06g00007 ',sqlca.sqlcode,'/',sqlca.sqlerrd[2]
          call errorlog(lr_retorno.mensagem)
          let lr_retorno.mensagem = 'cty06g00_segnumdig()/',lr_param.prporg
                                                       ,'/',lr_param.prpnumdig
          call errorlog(lr_retorno.mensagem)
          let lr_retorno.mensagem = 'Erro ',sqlca.sqlcode,' em rsdmdocto '
          let lr_retorno.status = 3
       else
          let lr_retorno.mensagem = 'Codigo do Segurado nao encontrado'
          call errorlog(lr_retorno.mensagem)
          let lr_retorno.status = 2
       end if
    else
       let lr_retorno.status = 1
    end if
 end if

 return lr_retorno.*
 end function # -- cty06g00_segnumdig()

#==============================================================================
 function cty06g00_convenio(lr_param)
#==============================================================================

 define lr_param   record
     ramcod        like rsamseguro.ramcod
    ,succod        like rsamseguro.succod
    ,aplnumdig     like rsamseguro.aplnumdig
    ,prporg        like rsdmdocto.prporg
    ,prpnumdig     like rsdmdocto.prpnumdig
 end record
 define lr_retorno record
     status        smallint
    ,mensagem      char(50)
    ,cvnnum        like rsdmcvnnum.cvnnum
 end record

 define l_prporg    like rsdmdocto.prporg
       ,l_prpnumdig like rsdmdocto.prpnumdig

 initialize lr_retorno.* to null
 let l_prporg = null
 let l_prpnumdig = null

 if m_prep_sql is null or m_prep_sql <> true then
    call cty06g00_prepare()
 end if

 if lr_param.succod is not null and
    lr_param.aplnumdig is not null then
    open ccty06g00008 using lr_param.ramcod
                           ,lr_param.succod
                           ,lr_param.aplnumdig
    whenever error continue
    fetch ccty06g00008 into l_prporg, l_prpnumdig
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode <> 100 then
          let lr_retorno.mensagem = 'Erro de SQL ccty06g00008 ',sqlca.sqlcode,'/',sqlca.sqlerrd[2]
          call errorlog(lr_retorno.mensagem)
          let lr_retorno.mensagem = 'cty06g00_convenio()/',lr_param.succod
                                                      ,'/',lr_param.ramcod
                                                      ,'/',lr_param.aplnumdig
          call errorlog(lr_retorno.mensagem)
          let lr_retorno.mensagem = 'Erro ',sqlca.sqlcode,' em rsdmdocto/rsamseguro '
          let lr_retorno.status = 3
          return lr_retorno.*
       end if
    end if
 end if
 if lr_param.prporg is null or lr_param.prpnumdig is null then
    let lr_param.prporg    = l_prporg
    let lr_param.prpnumdig = l_prpnumdig
 end if

 open ccty06g00009 using lr_param.prporg
                        ,lr_param.prpnumdig
 whenever error continue
 fetch ccty06g00009 into lr_retorno.cvnnum
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> 100 then
       let lr_retorno.mensagem = 'Erro de SQL ccty06g00009 ',sqlca.sqlcode,'/',sqlca.sqlerrd[2]
       call errorlog(lr_retorno.mensagem)
       let lr_retorno.mensagem = 'cty06g00_convenio()/',l_prporg
                                                   ,'/',l_prpnumdig
       call errorlog(lr_retorno.mensagem)
       let lr_retorno.mensagem = 'Erro ',sqlca.sqlcode,' em rsdmcvnnum '
       let lr_retorno.status = 3
    else
      #let lr_retorno.mensagem = 'Convenio nao encontrado'
      #call errorlog(lr_retorno.mensagem)
      #let lr_retorno.status = 2
       let lr_retorno.cvnnum = 0
    end if
 else
    let lr_retorno.status = 1
 end if

 return lr_retorno.*
 end function # -- cty06g00_convenio()
# --- PSI 186376 - Final --


#------------------------------------------#
function cty06g00_modal_re(lr_param)
#------------------------------------------#
  define lr_param       record
         nivel_retorno  smallint
        ,succod         like rsamseguro.succod
        ,ramcod         like rsamseguro.ramcod
        ,aplnumdig      like rsamseguro.aplnumdig
  end record

  define lr_retorno     record
         resultado      smallint
        ,mensagem       char(60)
        ,rmemdlcod      like rsamseguro.rmemdlcod
  end record

  if m_prep_sql is null or m_prep_sql <> true then
     call cty06g00_prepare()
  end if
  initialize lr_retorno    to null
  open ccty06g00011  using lr_param.succod,
			   lr_param.ramcod,
			   lr_param.aplnumdig
  whenever error continue
  fetch ccty06g00011 into lr_retorno.rmemdlcod
  whenever error stop

  if sqlca.sqlcode = 0 then
     let lr_retorno.resultado = 1
     let lr_retorno.mensagem = null
  else
     if sqlca.sqlcode = notfound then
        let lr_retorno.resultado = 2
        let lr_retorno.mensagem  = "Apolice RAMOS ELEMENTARES nao cadastrada!"
     else
        let lr_retorno.resultado = 3
        let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode, " em rsamseguro"
     end if
   end if

   close ccty06g00011

   if lr_param.nivel_retorno = 1 then
      return lr_retorno.resultado, lr_retorno.mensagem,
             lr_retorno.rmemdlcod
   end if
end function

function cty06g00_clausula_assunto(lr_param)

 define lr_param       record
        c24astcod      like datkassunto.c24astcod
 end record
 define lr_apolice     record
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
 define lr_ramo record
        resultado  integer,
        mensagem   char(500),
        ramgrpcod  like gtakram.ramgrpcod
 end record
 define lr_retorno record
         erro     smallint,
         msg      char(300),
         clscod   like datrsrvcls.clscod
  end record
 define l_clscod like datrsrvcls.clscod
       ,l_existe smallint
       ,l_ramsgl char(15)
 initialize lr_retorno.* to null
 initialize lr_ramo.* to null
 initialize lr_apolice.* to null
 let l_clscod = null
 let l_ramsgl = "RE"
 let l_existe = false
 if m_prep_sql is null or
    m_prep_sql = false then
    call cty06g00_prepare()
 end if
  call cty10g00_grupo_ramo(g_documento.ciaempcod
                          ,g_documento.ramcod)
          returning lr_ramo.*
  call cty06g00_dados_apolice(g_documento.succod,
                              g_documento.ramcod,
                              g_documento.aplnumdig,
                              l_ramsgl)
       returning lr_apolice.*
  if lr_ramo.ramgrpcod = 4 then
      let l_existe = false
      whenever error continue
      open ccty06g00012 using lr_apolice.prporg,
                              lr_apolice.prpnumdig,
                              g_documento.lclnumseq,
                              g_documento.rmerscseq
      foreach ccty06g00012 into l_clscod
              let l_existe = true
              open ccty06g00013 using g_documento.c24astcod,
                                      g_documento.ramcod,
                                      l_clscod
              fetch ccty06g00013 into lr_retorno.clscod
              if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                   let lr_retorno.clscod = null
                   let lr_retorno.erro = sqlca.sqlcode
                   let lr_retorno.msg = "Clausula <",l_clscod ,"> não cadastrada para o assunto < ",g_documento.c24astcod ," > !"
                   call errorlog(lr_retorno.msg)
                else
                   let lr_retorno.clscod = null
                   let lr_retorno.erro = sqlca.sqlcode
                   let lr_retorno.msg = "Erro <",lr_retorno.erro ,"> na busca de assunto e clausula !"
                   call errorlog(lr_retorno.msg)
                end if
              else
                 close ccty06g00013
                 exit foreach
              end if
      end foreach
      whenever error stop
      close ccty06g00012
   end if
   if lr_ramo.ramgrpcod = 3 then
      let l_existe = false
      whenever error continue
      open ccty06g00014 using lr_apolice.prporg
                             ,lr_apolice.prpnumdig
                             ,g_documento.lclnumseq
      foreach ccty06g00014 into l_clscod
        let l_existe = true
        open ccty06g00013 using g_documento.c24astcod,
                                g_documento.ramcod,
                                l_clscod
                fetch ccty06g00013 into lr_retorno.clscod
                if sqlca.sqlcode <> 0 then
                  if sqlca.sqlcode = 100 then
                     let lr_retorno.clscod = null
                     let lr_retorno.erro = sqlca.sqlcode
                     let lr_retorno.msg = "Clausula <",l_clscod ,"> não cadastrada para o assunto < ",g_documento.c24astcod ," > !"
                     call errorlog(lr_retorno.msg)
                  else
                     let lr_retorno.clscod = null
                     let lr_retorno.erro = sqlca.sqlcode
                     let lr_retorno.msg = "Erro <",lr_retorno.erro ,"> na busca de assunto e clausula !"
                     call errorlog(lr_retorno.msg)
                  end if
                else
                   close ccty06g00013
                   exit foreach
                end if
      end foreach
      close ccty06g00014
   end if
  if l_existe = false then
     let lr_retorno.erro = 100
     let lr_retorno.msg  = " Não existe clausula para essa apolice "
     call errorlog(lr_retorno.msg)
  end if
  return lr_retorno.*
end function


