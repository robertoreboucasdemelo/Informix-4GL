#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cty03g00.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 183.431                                                    #
# OSF           : 036.439                                                    #
#                 Obter a quantidade de segurados com o mesmo nome           #
#............................................................................#
# Desenvolvimento: Meta, Robson Inocencio                                    #
# Liberacao      : 21/07/2004                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 26/07/2004 Jefferson, Meta   PSI186376  Incluir as funcoes                 #
#                              OSF 38105  cty03g00_obter_codgeral e          #
#                                         cty03g00_dades_segurado            #
#----------------------------------------------------------------------------#
database porto

define m_prep_sql   smallint
      ,m_msg        char(60)

#--------------------------#
function cty03g00_prepare()
#--------------------------#

 define l_sql char(500)

 let l_sql = " select count(*) ",
               " from gsaksegger ",
              " where prifoncod = ? "

 prepare p_cty03g00_001  from l_sql
 declare c_cty03g00_001  cursor for p_cty03g00_001

 let l_sql = ' select count(*) '
            ,'   from gsaksegger '
            ,'  where cgccpfnum  =  ? '
            ,'    and pestip     =  ? '

 prepare p_cty03g00_002  from l_sql
 declare c_cty03g00_002  cursor for p_cty03g00_002

 let l_sql = " select seggernumdig "
            ,"   from gsarsegger "
            ,"  where segnumdig = ? "
            ,"  and   orgcadcod = 1 "

 prepare p_cty03g00_003 from l_sql
 declare c_cty03g00_003 cursor for p_cty03g00_003

 let l_sql = " select segnumdig "
            ,"       ,segnom "
            ,"   from gsaksegger "
            ,"  where cgccpfnum = ? "
            ,"    and cgcord = ? "
            ,"    and cgccpfdig = ? "

 prepare p_cty03g00_004 from l_sql
 declare c_cty03g00_004 cursor for p_cty03g00_004

 let l_sql = " select segnom "
            ,"       ,pestip "
            ,"       ,cgccpfnum "
            ,"       ,cgcord "
            ,"       ,cgccpfdig "
            ,"   from gsakseg "
            ,"  where segnumdig = ? "

 prepare p_cty03g00_005 from l_sql
 declare c_cty03g00_005 cursor for p_cty03g00_005

 let l_sql = " select count(*) ",
               " from gsaksegger ",
              " where segfoncod = ? "

 prepare p_cty03g00_006  from l_sql
 declare c_cty03g00_006  cursor for p_cty03g00_006

 let l_sql = " select count(*) ",
               " from gsaksegger ",
              " where terfoncod = ? "

 prepare p_cty03g00_007  from l_sql
 declare c_cty03g00_007  cursor for p_cty03g00_007

 let l_sql = " select count(*) "
            ,"   from gsakseg "
            ,"  where segnom matches ? "

 prepare p_cty03g00_008  from l_sql
 declare c_cty03g00_008  cursor for p_cty03g00_008

 let l_sql = ' select count(*) '
            ,'   from gsakseg '
            ,'  where cgccpfnum  =  ? '
            ,'    and pestip     =  ? '

 prepare p_cty03g00_009  from l_sql
 declare c_cty03g00_009  cursor for p_cty03g00_009

 let m_prep_sql = true

end function

#-----------------------------------------------------------#
function cty03g00_qtd_segurado(l_segnom,l_cgccpfnum,l_pestip)
#-----------------------------------------------------------#

 define l_segnom    like gsakseg.segnom
       ,l_cgccpfnum like gsakseg.cgccpfnum
       ,l_pestip    char(01)

 define lr_retorno record
        resultado smallint
       ,mensagem  char(60)
       ,contador  smallint
 end record

 define l_qtd_reg smallint

 define l_p_fon    char(20),
        l_s_fon    char(20),
        l_t_fon    char(20),
        l_psq_fon  smallint

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cty03g00_prepare()
 end if

 initialize lr_retorno.* to null

 let l_qtd_reg = 0
 let l_p_fon   = null
 let l_s_fon   = null
 let l_t_fon   = null
 let l_psq_fon = true

 if l_segnom is not null then

    # -> BUSCA OS CODIGOS FONETICOS(PRIMEIRO, SEGUNDO E TERCEIRO)
    call cty03g00_gera_cod_fon(l_segnom,
                               l_pestip)
         returning l_p_fon,
                   l_s_fon,
                   l_t_fon

    # -> PESQUISA PELO PRIMEIRO CODIGO FONETICO
    open c_cty03g00_001 using l_p_fon
    fetch c_cty03g00_001 into l_qtd_reg
    close c_cty03g00_001

    if l_qtd_reg is null then
       let l_qtd_reg = 0
    end if

    if l_qtd_reg = 0 then
       # -> PESQUISA PELO SEGUNDO CODIGO FONETICO
       open c_cty03g00_006 using l_s_fon
       fetch c_cty03g00_006 into l_qtd_reg
       close c_cty03g00_006

       if l_qtd_reg is null then
          let l_qtd_reg = 0
       end if

       if l_qtd_reg = 0 then
          # -> PESQUISA PELO TERCEIRO CODIGO FONETICO
          open c_cty03g00_007 using l_t_fon
          fetch c_cty03g00_007 into l_qtd_reg
          close c_cty03g00_007

          if l_qtd_reg is null then
             let l_qtd_reg = 0
          end if

          if l_qtd_reg = 0 then
             let l_psq_fon = false
             let l_segnom  = l_segnom clipped, "*"
             open c_cty03g00_008 using l_segnom
             fetch c_cty03g00_008 into l_qtd_reg
             close c_cty03g00_008

             if l_qtd_reg is null then
                let l_qtd_reg = 0
             end if
          end if

       end if

    end if

    if l_psq_fon = true then
       if l_qtd_reg > 150 then
          # -> SE FOR PESQUISA FONETICA E ULTRAPASSOU O LIMITE DE 150
          # -> REGISTROS, BUSCA NA TABELA GSAKSEG
          let l_segnom = l_segnom clipped, "*"
          open c_cty03g00_008 using l_segnom
          fetch c_cty03g00_008 into l_qtd_reg
          close c_cty03g00_008

          if l_qtd_reg is null then
             let l_qtd_reg = 0
          end if
       end if
    end if

    let lr_retorno.resultado = 1
    let lr_retorno.mensagem  = null
    let lr_retorno.contador  = l_qtd_reg
 else
    open c_cty03g00_002 using l_cgccpfnum, l_pestip
    fetch c_cty03g00_002 into lr_retorno.contador
    close c_cty03g00_002

    if lr_retorno.contador is null then
       let lr_retorno.contador = 0
    end if

    if lr_retorno.contador = 0 then
       open c_cty03g00_009 using l_cgccpfnum, l_pestip
       fetch c_cty03g00_009 into lr_retorno.contador
       close c_cty03g00_009

       if lr_retorno.contador is null then
          let lr_retorno.contador = 0
       end if
    end if

    let lr_retorno.resultado = 1
    let lr_retorno.mensagem  = null

 end if

 return lr_retorno.*

end function

#psi1863763
#-----------------------------------------#
function cty03g00_obter_codgeral(lr_param)
#-----------------------------------------#

   define lr_param record
          segnumdig  like gsarsegger.segnumdig
         ,cgccpfnum  like gsaksegger.cgccpfnum
         ,cgcord     like gsaksegger.cgcord
         ,cgccpfdig  like gsaksegger.cgccpfdig
   end record

   define lr_retorno record
          resultado  smallint
         ,mensagem   char(60)
         ,codgeral   like gsarsegger.segnumdig
         ,segnom     like gsaksegger.segnom
   end record

   initialize lr_retorno.* to null
   let lr_retorno.resultado = 1

   if m_prep_sql is null or
      m_prep_sql <> true then
      call cty03g00_prepare()
   end if

   if lr_param.segnumdig is not null then
      open c_cty03g00_003 using lr_param.segnumdig
      whenever error continue
      fetch c_cty03g00_003 into lr_retorno.codgeral
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
            let lr_retorno.resultado = 2
            let lr_retorno.mensagem  = "Codigo geral do segurado nao encontrado"
         else
            let lr_retorno.resultado = 3
            let lr_retorno.mensagem  = "ERRO ", sqlca.sqlcode, " em gsarsegger"
            let m_msg = " ERRO SQL SELECT - c_cty03g00_003 "
                        ,sqlca.sqlcode," / ",sqlca.sqlerrd[2]
            call errorlog(m_msg)
            let m_msg = " cty03g00_obter_codgeral() / ", lr_param.segnumdig
            call errorlog(m_msg)
         end if
      end if
   else
      open c_cty03g00_004 using lr_param.cgccpfnum
                             ,lr_param.cgcord
                             ,lr_param.cgccpfdig
      whenever error continue
      fetch c_cty03g00_004 into lr_retorno.codgeral
                             ,lr_retorno.segnom
      whenever error stop

      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
            let lr_retorno.resultado = 2
            let lr_retorno.mensagem  = "Codigo geral do segurado nao encontrado"
         else
            let lr_retorno.resultado = 3
            let lr_retorno.mensagem  = "ERRO ", sqlca.sqlcode, " em gsaksegger"
            let m_msg = " ERRO SQL SELECT - c_cty03g00_003 "
                        ,sqlca.sqlcode," / ",sqlca.sqlerrd[2]
            call errorlog(m_msg)
            let m_msg = " cty03g00_obter_codgeral() / ",lr_param.cgccpfnum, " / "
                                                       ,lr_param.cgcord, " / "
                                                       ,lr_param.cgccpfdig
            call errorlog(m_msg)
         end if
      end if
   end if

   return lr_retorno.*

end function

#--------------------------------------------#
function cty03g00_dados_segurado(l_segnumdig)
#--------------------------------------------#

   define l_segnumdig  like gsakseg.segnumdig

   define lr_retorno record
          resultado  smallint
         ,mensagem   char(60)
         ,segnom     like gsakseg.segnom
         ,pestip     like gsakseg.pestip
         ,cgccpfnum  like gsakseg.cgccpfnum
         ,cgcord     like gsakseg.cgcord
         ,cgccpfdig  like gsakseg.cgccpfdig
   end record

   initialize lr_retorno.* to null

  if m_prep_sql is null or
     m_prep_sql <> true then
     call cty03g00_prepare()
  end if

   open c_cty03g00_005 using l_segnumdig
   whenever error continue
   fetch c_cty03g00_005 into lr_retorno.segnom
                          ,lr_retorno.pestip
                          ,lr_retorno.cgccpfnum
                          ,lr_retorno.cgcord
                          ,lr_retorno.cgccpfdig
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let lr_retorno.resultado = 2
         let lr_retorno.mensagem  = "Informacoes do segurado nao encontrado"
      else
         let lr_retorno.resultado = 3
         let lr_retorno.mensagem  = "ERRO ", sqlca.sqlcode, " em gsakseg"
         let m_msg = " ERRO SQL SELECT - c_cty03g00_005 "
                     ,sqlca.sqlcode," / ",sqlca.sqlerrd[2]
         call errorlog(m_msg)
         let m_msg = " cty03g00_dados_segurado() / ", l_segnumdig
         call errorlog(m_msg)
      end if
   else
      let lr_retorno.resultado = 1
   end if

   return lr_retorno.*

end function

#------------------------------------------#
function cty03g00_gera_cod_fon(lr_parametro)
#------------------------------------------#

  # -> FUNCAO PARA GERAR O CODIGO FONETICO

  define lr_parametro record
         segnom       like gsaksegger.segnom,
         pestip       like gsaksegger.pestip
  end record

  define l_p_fon    char(20),
         l_s_fon    char(20),
         l_t_fon    char(20),
         l_ent_fon  char(52),
         l_sai_fon  char(100)

  let l_p_fon   = null
  let l_s_fon   = null
  let l_t_fon   = null
  let l_ent_fon = null
  let l_sai_fon = null

  if lr_parametro.pestip = "M" then
     let lr_parametro.pestip = "J"
  end if

  if lr_parametro.pestip = "F" then
     let l_ent_fon = "1", lr_parametro.segnom
  else
     let l_ent_fon = "2", lr_parametro.segnom
  end if

  let l_sai_fon = fonetica2(l_ent_fon)

  if l_sai_fon[1,3] = "100" then
     error "Problema no servidor de fonetica, AVISAR O HELP DESK !" sleep 4
     let l_sai_fon = "################################################"
  end if

  let l_p_fon = l_sai_fon[1,15]
  let l_s_fon = l_sai_fon[17,31]

  if l_s_fon is null or
     l_s_fon = " " then
     let l_s_fon = l_p_fon
  end if

  let l_t_fon = l_sai_fon[33,47]

  if l_t_fon is null or
     l_t_fon = " " then
     let l_t_fon = l_p_fon
  end if

  return l_p_fon,
         l_s_fon,
         l_t_fon

end function
