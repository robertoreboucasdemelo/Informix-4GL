#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cty05g00.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 183.431                                                    #
# OSF           : 036.439                                                    #
#                 Obter dados da apolice                                     #
#                 Consistir o item da apolice                                #
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
#                              OSF 38105  cty05g00_segnumdig e               #
#                                         cty05g00_convenio.                 #
#                                                                            #
# 28/10/2004 META, Marcos MP   PSI.188425 Incluir as funcoes:                #
#  Analista: Ligia Mattge                 cty05g00_cls018 e                  #
#                                         cty05g00_dados_veic                #
#                                                                            #
# 26/01/2005 Robson, Meta      PSI190080  Adicionar vclchsinc e vclanofbc ao #
#                                         cursor ccty05g000909. Incluir a    #
#                                         funcao cty05g00_prp_aplice()       #
#                                                                            #
# 26/06/2007 Roberto           PSI207446  Adicionado as funcoes cty05g00     #
#                                         recupera_tel, segnumdig_vida,      #
#                                         cgccpf_vida                        #
# 06/04/2009 Ligia Mattge      PSI198404  Incluir as funcoes: cty05g00_cls e #
#                                         cty05g00_abamcor                   #
#----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"

define m_prep_sql   smallint
      ,m_prep_sql2  smallint
      ,m_prep_sql3  smallint
      ,m_prep_sql4  smallint
      ,m_msg        char(60)

define m_prep_018   smallint,
       m_prep_veic  smallint
      ,m_prep_apolice smallint
define mr_ret       record
       stt          smallint,
       msg          char(80)
end record

define m_prep smallint

define m_hostname   like ibpkdbspace.srvnom


#--------------------------#
function cty05g00_prepare()
#--------------------------#
  define l_sql        char(250)

  let l_sql = " select aplstt, vigfnl, etpnumdig "
             ,"   from abamapol       "
             ,"  where succod    = ?  "
             ,"    and aplnumdig = ?  "
  prepare p_cty05g00_001  from l_sql
  declare c_cty05g00_001  cursor for p_cty05g00_001

  let l_sql = " select emsdat        "
             ,"   from abamdoc       "
             ,"  where succod    = ? "
             ,"    and aplnumdig = ? "
             ,"    and edsnumdig = 0 "
  prepare p_cty05g00_002  from l_sql
  declare c_cty05g00_002  cursor for p_cty05g00_002

  let l_sql = " select 1             "
             ,"   from abbmitem      "
             ,"  where succod    = ? "
             ,"    and aplnumdig = ? "
             ,"    and itmnumdig = ? "
  prepare p_cty05g00_003  from l_sql
  declare c_cty05g00_003  cursor for p_cty05g00_003

  let l_sql = " select clscod from abbmclaus "
                 ,"where succod    = ?    and "
                       ," aplnumdig = ? and "
                       ," itmnumdig = ? and "
                       ," dctnumseq = ?   and "
                       ," clscod   in ('033','33R','035','055','35A','35R','034','34A',"
                       ,"'34B','34C','046','46R','047','47R','044','44R','048','48R') " #Adicionado clausula 34 --- BURINI

 prepare p_cty05g00_004  from l_sql
 declare c_cty05g00_004  cursor for p_cty05g00_004
 let l_sql = " select edsnumdig from abamdoc a ",
              " where a.succod    =  ? ",
                " and a.aplnumdig =  ? ",
                " and a.dctnumseq = ? "
 prepare pcty05g00009 from l_sql
 declare ccty05g00009 cursor for pcty05g00009
 let l_sql = " select corsus from abamcor ",
              " where succod    =  ? ",
                " and aplnumdig =  ? ",
                " and corlidflg = 'S' "

 prepare pcty05g00029 from l_sql
 declare ccty05g00029 cursor for pcty05g00029

 let l_sql = ' select count(*) from abbmclaus ',
             '  where succod    = ? ',
             '    and aplnumdig = ? ',
             '    and itmnumdig = ? ',
             '    and clscod    in ("095","034","035","34A","35A","35R","033","33R") '

 prepare pcty05g00030 from l_sql
 declare ccty05g00030 cursor for pcty05g00030
 let l_sql = ' select clscod from datrastcls ',
             '  where c24astcod = ? ',
             '  and ramcod = ? ',
             '  and clscod = ? '
 prepare pcty05g00031 from l_sql
 declare ccty05g00031 cursor for pcty05g00031
 let l_sql = 'select clscod ',
             ' from abbmclaus ',
             ' where succod  = ? ',
             ' and aplnumdig = ? ',
             ' and itmnumdig = ? ',
             ' and dctnumseq = ? '
 prepare pcty05g00032 from l_sql
 declare ccty05g00032 cursor for pcty05g00032
 let m_prep_sql = true
 let m_prep  = true

end function

#psi1863763
#----------------------------#
function cty05g00_prepare_2()
#----------------------------#

  define l_sql   char(500)

  let l_sql = " select segnumdig "
             ,"   from abbmdoc "
             ,"  where succod = ? "
             ,"    and aplnumdig = ? "
             ,"    and itmnumdig = ? "
             ,"    and dctnumseq = ? "

  prepare p_cty05g00_005 from l_sql
  declare c_cty05g00_005 cursor for p_cty05g00_005
  let l_sql = " select cvnnum "
             ,"   from abamapol "
             ,"  where succod = ? "
             ,"    and aplnumdig = ? "
  prepare pcty05g00006 from l_sql
  declare ccty05g00006 cursor for pcty05g00006



  let m_prep_sql2 = true

end function

#----------------------------#
function cty05g00_prepare_3()
#----------------------------#

  define l_sql   char(500)

  let m_hostname = fun_dba_servidor("EMISAUTO")

  whenever error continue
  let l_sql = " select etpnumdig "
             ," from porto@",m_hostname clipped, ":apamcapa "
             ," where prporgpcp = ? "
             ," and prpnumpcp = ?   "
  prepare pcty05g00005 from l_sql
  declare ccty05g00005 cursor for pcty05g00005
  whenever error stop
  if figrc072_checkGlbIsolamento(sqlca.sqlcode        ,
                                 "cty05g00"           ,
                                 "cty05g00_prepare_3" ,
                                 "ccty05g00005"       ,
                                 "","","","","","")  then
     return
  end if

  whenever error continue
  let l_sql = " select cvnnum "
             ," from porto@",m_hostname clipped,":apamcapa "
             ," where prporgpcp = ? "
             ," and prpnumpcp = ? "

  prepare pcty05g00007 from l_sql
  declare ccty05g00007 cursor for pcty05g00007
  whenever error stop

  if figrc072_checkGlbIsolamento(sqlca.sqlcode        ,
                                 "cty05g00"           ,
                                 "cty05g00_prepare_3" ,
                                 "ccty05g00007"       ,
                                 "","","","","","")  then
     return
  end if
  let m_prep_sql3 = true

end function

#---------------------------------------------------------------------
function cty05g00_prepare_4()
#---------------------------------------------------------------------


define l_sql     char(2000)

      let l_sql = "select dddcod,"        ,
                  "       teltxt "        ,
                  "from gsakend "         ,
                  "where segnumdig = ? "  ,
                  "and endfld = '1'"
      prepare p_cty05g00_006 from l_sql
      declare c_cty05g00_006 cursor for p_cty05g00_006


     let l_sql = "select count(*) "
                ," from vtamseguro "
                ," where segnumdig = ?"
     prepare p_cty05g00_007 from l_sql
     declare c_cty05g00_007 cursor for p_cty05g00_007

     let l_sql =   "select segnumdig   "
                  ,"      ,segnom      "
                  ,"      ,pestip      "
                  ,"      ,cgccpfnum   "
                  ,"      ,cgcord      "
                  ,"      ,cgccpfdig   "
                  ,"      ,nscdat      "
                  ,"  from gsakseg      "
                  ," where cgccpfnum = ? "
                  ," and   cgccpfdig = ? "
                  ," and   pestip = ? "
     prepare p_cty05g00_008 from l_sql
     declare c_cty05g00_008 cursor for p_cty05g00_008


     let l_sql = " select count(*) ",
                   " from gsakseg ",
                  " where prifoncod = ? "
     prepare p_cty05g00_009 from l_sql
     declare c_cty05g00_009 cursor for p_cty05g00_009

     let l_sql = " select count(*) ",
                   " from gsakseg ",
                  " where segfoncod = ? "

     prepare p_cty05g00_010 from l_sql
     declare c_cty05g00_010 cursor for p_cty05g00_010

     let l_sql = " select count(*) ",
                   " from gsakseg ",
                  " where terfoncod = ? "

     prepare p_cty05g00_011 from l_sql
     declare c_cty05g00_011 cursor for p_cty05g00_011
     let m_prep_sql4 = true

end function

#------------------------------------------------------------------------------
function cty05g00_cria_temp()
#------------------------------------------------------------------------------


 call cty05g00_drop_temp()

 whenever error continue
      create temp table cty05g00_temp(segnumdig    decimal(8,0) ,
                                      segnom       char(50)     ,
		                                  pestip       char(1)      ,
         	                            cgccpfnum    decimal(12,0),
	                                    cgcord       decimal(4,0) ,
                                      cgccpfdig    decimal(2,0) ,
				                              nscdat       date         ,
				                              prporg       decimal(2,0) ,  ---> Nilo
				                              prpnumdig    decimal(8,0) )  ---> Nilo
                                                   with no log

     create unique index idx_tmpcty05g00 on cty05g00_temp (segnumdig)
  whenever error stop


 if sqlca.sqlcode <> 0  then

	 if sqlca.sqlcode = -310 or
	    sqlca.sqlcode = -958 then
	        call cty05g00_drop_temp()
	  end if

	 return false

 end if

     return true

end function

#------------------------------------------------------------------------------
function cty05g00_drop_temp()
#------------------------------------------------------------------------------

    whenever error continue
        drop table cty05g00_temp
    whenever error stop

    return

end function

#------------------------------------------------------------------------------
function cty05g00_prep_temp()
#------------------------------------------------------------------------------

    define w_ins char(1000)

    let w_ins = 'insert into cty05g00_temp'
	     , ' values(?,?,?,?,?,?,?,?,?)' ---> Nilo
    prepare p_cty05g00_012 from w_ins

end function


#fim psi1863763

# PSI.188425 - PREPARA COMANDOS SQL DA FUNCAO 'cty05g00_cls018
#-------------------------------------------------------------------------------
function cty05g00_prep_018()
#-------------------------------------------------------------------------------
   define l_prep         char(1500)

   if m_prep_018 then
      return true
   end if

   whenever error go to ERROPREP018

   let l_prep = "select 1",
                "  from abbmclaus",
                " where succod = ?",
                "   and aplnumdig = ?",
                "   and itmnumdig = ?",
                "   and dctnumseq = ?",
                "   and clscod = '018'"
   prepare p_cty05g00_013 from l_prep
   declare c_cty05g00_012 cursor for p_cty05g00_013

   whenever error stop

   let m_prep_018 = true

   return true

label ERROPREP018:
#----------------
   call cty05g00_monta_ret(" PREPARE abbmclaus")

   return false

end function

# PSI.188425 - PREPARA COMANDOS SQL DA FUNCAO 'cty05g00_dados_veic'
#-------------------------------------------------------------------------------
function cty05g00_prep_veic()
#-------------------------------------------------------------------------------
   define l_prep         char(1500)

   if m_prep_veic then
      return true
   end if

   whenever error go to ERROPREPVEIC

   let l_prep = "select vcllicnum, vclchsinc, vclchsfnl, vclanofbc, vclcoddig ",
                "  from abbmveic",
                " where succod = ?",
                "   and aplnumdig = ?",
                "   and itmnumdig = ?",
                "   and dctnumseq = ?"
   prepare p_cty05g00_014 from l_prep
   declare c_cty05g00_013 cursor for p_cty05g00_014

   whenever error stop

   let m_prep_veic = true

   return true

label ERROPREPVEIC:
#-----------------
   call cty05g00_monta_ret(" PREPARE abbmveic")

   return false

end function

#-------------------------------------------------------------------------------
function cty05g00_prep_prp_apolice()
#-------------------------------------------------------------------------------
   define l_prep char(400)

   if m_prep_apolice then
      return true
   end if

   whenever error go to ERROPREPPRP

   let l_prep = "select prporgpcp, prpnumpcp ",
                "  from abamdoc",
                " where succod = ?",
                "   and aplnumdig = ?",
                "   and edsnumdig = ?"
   prepare p_cty05g00_015 from l_prep
   declare c_cty05g00_014 cursor for p_cty05g00_015

   whenever error stop

   let m_prep_apolice = true

   return true

label ERROPREPPRP:
#-----------------
   call cty05g00_monta_ret(" PREPARE abamdoc")

   return false

end function

#---------------------------------------#
function cty05g00_dados_apolice(lr_param)
#---------------------------------------#

   define lr_param        record
          succod          like abamapol.succod
         ,aplnumdig       like abamapol.aplnumdig
   end record

   define lr_cty05g00     record
          resultado       smallint
         ,mensagem        char(42)
         ,emsdat          like abamdoc.emsdat
         ,aplstt          like abamapol.aplstt
         ,vigfnl          like abamapol.vigfnl
         ,etpnumdig       like abamapol.etpnumdig
   end record

   if m_prep_sql is null or m_prep_sql <> true then
      call cty05g00_prepare()
   end if

   initialize lr_cty05g00 to null

   if lr_param.succod    is not null and
      lr_param.aplnumdig is not null then

      let lr_cty05g00.resultado = 1
      open c_cty05g00_001  using lr_param.*
      whenever error continue
      fetch c_cty05g00_001 into  lr_cty05g00.aplstt, lr_cty05g00.vigfnl, lr_cty05g00.etpnumdig
      whenever error stop
      if sqlca.sqlcode = 0 then
         open c_cty05g00_002  using lr_param.*
         whenever error continue
         fetch c_cty05g00_002 into  lr_cty05g00.emsdat
         whenever error stop
         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = notfound then
               let lr_cty05g00.resultado = 2
               let lr_cty05g00.mensagem  = "Data de emissao da apolice nao encontrada!"
            else
               let lr_cty05g00.resultado = 3
               let lr_cty05g00.mensagem  = "ERRO ", sqlca.sqlcode, " em abamdoc"
               let m_msg = " Erro de SELECT - c_cty05g00_001 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
               call errorlog(m_msg)
               let m_msg = " cty05g00_dados_apolice() / ",lr_param.succod, " / ",
                                                          lr_param.aplnumdig
               call errorlog(m_msg)
            end if
         end if
         close c_cty05g00_002
      else
         if sqlca.sqlcode = notfound then
            let lr_cty05g00.resultado = 2
            let lr_cty05g00.mensagem  = "Apolice do ramo AUTOMOVEL nao cadastrada!"
         else
            let lr_cty05g00.resultado = 3
            let lr_cty05g00.mensagem  = "ERRO ", sqlca.sqlcode, " em abamapol"
            let m_msg = " Erro de SELECT - c_cty05g00_001 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
            call errorlog(m_msg)
            let m_msg = " cty05g00_dados_apolice() / ",lr_param.succod, " / ",
                                                       lr_param.aplnumdig
            call errorlog(m_msg)
         end if
      end if
      close c_cty05g00_001
   else
      let lr_cty05g00.resultado = 3
      let lr_cty05g00.mensagem = "Parametros nulos"
   end if

   return lr_cty05g00.*

end function

#---------------------------------------#
function cty05g00_consiste_item(lr_param)
#---------------------------------------#
   define lr_param        record
          succod          like abbmitem.succod
         ,aplnumdig       like abbmitem.aplnumdig
         ,itmnumdig       like abbmitem.itmnumdig
   end record
   define m_msg           char(100)
         ,l_flag          smallint

   if m_prep_sql is null or m_prep_sql <> true then
      call cty05g00_prepare()
   end if

   if lr_param.succod    is not null and
      lr_param.aplnumdig is not null and
      lr_param.itmnumdig is not null then
      open c_cty05g00_003 using lr_param.*
      whenever error continue
      fetch c_cty05g00_003
      whenever error stop
      if sqlca.sqlcode = 0 then
         let l_flag = 1
      else
         if sqlca.sqlcode = notfound then
            let l_flag = 2
         else
            let l_flag = 3
            let m_msg = " Erro de SELECT - c_cty05g00_003 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
            call errorlog(m_msg)
            let m_msg = " cty05g00_consiste_item() / ",lr_param.succod, " / ",
                                                       lr_param.aplnumdig, " / ",
                                                       lr_param.itmnumdig
            call errorlog(m_msg)
         end if
      end if
      close c_cty05g00_003
   else
      let l_flag = 3
      let m_msg = 'Parametros nulos - cty05g00_consiste_item()'
      call errorlog(m_msg)
   end if
   return l_flag
end function

#psi1863763
#-------------------------------------#
function cty05g00_segnumdig(lr_param)
#-------------------------------------#

   define lr_param   record
          succod     like abbmdoc.succod
         ,aplnumdig  like abbmdoc.aplnumdig
         ,itmnumdig  like abbmdoc.itmnumdig
         ,dctnumseq  like abbmdoc.dctnumseq
         ,prporgpcp  like apamcapa.prporgpcp
         ,prpnumpcp  like apamcapa.prpnumpcp
   end record

   define lr_retorno record
          resultado  smallint
         ,mensagem   char(60)
         ,segnumdig  like abbmdoc.segnumdig
   end record

   initialize lr_retorno.* to null
   let lr_retorno.resultado = 1

   if m_prep_sql2 is null or
      m_prep_sql2 <> true then
      call cty05g00_prepare_2()
   end if

   if lr_param.aplnumdig is not null then
      open c_cty05g00_005 using lr_param.succod
                             ,lr_param.aplnumdig
                             ,lr_param.itmnumdig
                             ,lr_param.dctnumseq
      whenever error continue
      fetch c_cty05g00_005 into lr_retorno.segnumdig
      whenever error stop

      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
            let lr_retorno.resultado = 2
            let lr_retorno.mensagem  = "Codigo do segurado nao encontrado"
         else
            let lr_retorno.resultado = 3
            let lr_retorno.mensagem  = "ERRO ", sqlca.sqlcode, " em abbmdoc"
            let m_msg = " ERRO SQL SELECT - c_cty05g00_005 "
                        ,sqlca.sqlcode," / ",sqlca.sqlerrd[2]
            call errorlog(m_msg)
            let m_msg = " cty05g00_segnumdig() / ",lr_param.succod, " / "
                                                  ,lr_param.aplnumdig, " / "
                                                  ,lr_param.itmnumdig, " / "
                                                  ,lr_param.dctnumseq
            call errorlog(m_msg)
         end if
      end if
   else
      call figrc072_initGlbIsolamento()
      if m_prep_sql3 is null or
         m_prep_sql3 <> true then
         call cty05g00_prepare_3()
         if figrc072_getErro() then
               return lr_retorno.*
         end if
      end if
      open ccty05g00005 using lr_param.prporgpcp
                             ,lr_param.prpnumpcp
      whenever error continue
      fetch ccty05g00005 into lr_retorno.segnumdig
      whenever error stop

      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
            let lr_retorno.resultado = 2
            let lr_retorno.mensagem  = "Codigo do segurado nao encontrado"
         else
            let lr_retorno.resultado = 3
            let lr_retorno.mensagem  = "ERRO ", sqlca.sqlcode, " em apamcapa"
            let m_msg = " ERRO SQL SELECT - ccty05g00005 "
                        ,sqlca.sqlcode," / ",sqlca.sqlerrd[2]
            call errorlog(m_msg)
            let m_msg = " cty05g00_segnumdig() / ",lr_param.prporgpcp, " / "
                                                  ,lr_param.prpnumpcp
            call errorlog(m_msg)
         end if
      end if
   end if

   return lr_retorno.*

end function

#------------------------------------#
function cty05g00_convenio(lr_param)
#------------------------------------#

   define lr_param   record
          succod     like abamapol.succod
         ,aplnumdig  like abamapol.aplnumdig
         ,prporgpcp  like apamcapa.prporgpcp
         ,prpnumpcp  like apamcapa.prpnumpcp
   end record

   define lr_retorno record
          resultado  smallint
         ,mensagem   char(60)
         ,cvnnum     like abamapol.cvnnum
   end record

   initialize lr_retorno.* to null
   let lr_retorno.resultado = 1

   if m_prep_sql2 is null or
      m_prep_sql2 <> true then
      call cty05g00_prepare_2()
   end if

   if lr_param.succod    is not null and
      lr_param.aplnumdig is not null then
      open ccty05g00006 using lr_param.succod
                             ,lr_param.aplnumdig
      whenever error continue
      fetch ccty05g00006 into lr_retorno.cvnnum
      whenever error stop

      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
           #let lr_retorno.resultado = 2
           #let lr_retorno.mensagem  = "Convenio nao encontrado"
            let lr_retorno.cvnnum  =  0
         else
            let lr_retorno.resultado = 3
            let lr_retorno.mensagem  = "ERRO ", sqlca.sqlcode, " em abamapol"
            let m_msg = " ERRO SQL SELECT - ccty05g00006 "
                        ,sqlca.sqlcode," / ",sqlca.sqlerrd[2]
            call errorlog(m_msg)
            let m_msg = " cty05g00_convenio() / ",lr_param.succod, " / "
                                                 ,lr_param.aplnumdig
            call errorlog(m_msg)
         end if
      end if
   else
      call figrc072_initGlbIsolamento()
      if m_prep_sql3 is null or
         m_prep_sql3 <> true then
         call cty05g00_prepare_3()
         if figrc072_getErro() then
               return lr_retorno.*
         end if
      end if
      if lr_param.prporgpcp is not null and
         lr_param.prpnumpcp is not null then
         open ccty05g00007 using lr_param.prporgpcp
                                ,lr_param.prpnumpcp
         whenever error continue
         fetch ccty05g00007 into lr_retorno.cvnnum
         whenever error stop

         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = notfound then
              #let lr_retorno.resultado = 2
              #let lr_retorno.mensagem  = "Convenio nao encontrado"
               let lr_retorno.cvnnum  =  0
            else
               let lr_retorno.resultado = 3
               let lr_retorno.mensagem  = "ERRO ", sqlca.sqlcode, " em apamcapa"
               let m_msg = " ERRO SQL SELECT - ccty05g00007 "
                           ,sqlca.sqlcode," / ",sqlca.sqlerrd[2]
               call errorlog(m_msg)
               let m_msg = " cty05g00_convenio() / ",lr_param.prporgpcp, " / "
                                                    ,lr_param.prpnumpcp
               call errorlog(m_msg)
            end if
         end if
      end if
   end if

   return lr_retorno.*

end function
#fim psi1863763

# PSI.1888425 - VERIFICA SE APOLICE POSSUI CLAUSULA 18
#-------------------------------------------------------------------------------
function cty05g00_cls018(lr_param)
#-------------------------------------------------------------------------------
   define lr_param       record
          succod         like abbmclaus.succod,
          aplnumdig      like abbmclaus.aplnumdig,
          itmnumdig      like abbmclaus.itmnumdig,
          dctnumseq      like abbmclaus.dctnumseq
   end record

#=> PREPARA COMANDOS
   if not cty05g00_prep_018() then
      return mr_ret.*
   end if

   whenever error go to ERROCLS018

   open  c_cty05g00_012 using lr_param.*
   fetch c_cty05g00_012
   if sqlca.sqlcode = notfound then
      let mr_ret.stt = 2
      let mr_ret.msg = "Apolice sem clausula 018"
      return mr_ret.*
   end if

   whenever error stop

   call cty05g00_monta_ret("")

   return mr_ret.*

label ERROCLS018:
#---------------
   call cty05g00_monta_ret(" em abbmclaus")

   return mr_ret.*

end function

# PSI.188425 - OBTEM PLACA E CHASSI FINAL DO VEICULO
#-------------------------------------------------------------------------------
function cty05g00_dados_veic(lr_param)
#-------------------------------------------------------------------------------
   define lr_param       record
          succod         like abbmveic.succod,
          aplnumdig      like abbmveic.aplnumdig,
          itmnumdig      like abbmveic.itmnumdig,
          dctnumseq      like abbmveic.dctnumseq
   end record
   define lr_veic        record
          vcllicnum      like abbmveic.vcllicnum,
          vclchsinc      like abbmveic.vclchsinc,
          vclchsfnl      like abbmveic.vclchsfnl,
          vclanofbc      like abbmveic.vclanofbc,
          vclcoddig      like abbmveic.vclcoddig
   end record

   initialize lr_veic to null

 if lr_param.succod    is null or
    lr_param.aplnumdig is null or
    lr_param.itmnumdig is null or
    lr_param.dctnumseq is null then
    let mr_ret.stt = 2
    let mr_ret.msg = "Parametros nao devem ser nulos "
    return mr_ret.*, lr_veic.*
 end if

#=> PREPARA COMANDOS
   if not cty05g00_prep_veic() then
      return mr_ret.*, lr_veic.*
   end if

   whenever error go to ERROVEIC

   open  c_cty05g00_013 using lr_param.*
   fetch c_cty05g00_013  into lr_veic.*
   if sqlca.sqlcode = notfound then
      let mr_ret.stt = 2
      let mr_ret.msg = "Veiculo nao encontrado"
      return mr_ret.*, lr_veic.*
   end if

   whenever error stop

   call cty05g00_monta_ret("")

   return mr_ret.*, lr_veic.*

label ERROVEIC:
#-------------
   call cty05g00_monta_ret(" em abbmveic")

   return mr_ret.*, lr_veic.*

end function

#-------------------------------------------------------------------------------
function cty05g00_prp_apolice(lr_param)
#-------------------------------------------------------------------------------
   define lr_param       record
          succod         like abamdoc.succod,
          aplnumdig      like abamdoc.aplnumdig,
          edsnumdig      like abamdoc.edsnumdig
   end record
   define lr_ret         record
          prporgpcp      like abamdoc.prporgpcp,
          prpnumpcp      like abamdoc.prpnumpcp
   end record

   initialize lr_ret to null

#=> PREPARA COMANDOS
   if not cty05g00_prep_prp_apolice() then
      return mr_ret.*, lr_ret.*
   end if

   whenever error go to ERROPRP

   open  c_cty05g00_014 using lr_param.*
   fetch c_cty05g00_014  into lr_ret.*
   if sqlca.sqlcode = notfound then
      let mr_ret.stt = 2
      let mr_ret.msg = "Proposta nao encontrada"
      return mr_ret.*, lr_ret.*
   end if

   whenever error stop

   call cty05g00_monta_ret("")

   return mr_ret.*, lr_ret.*

label ERROPRP:
#-------------
   call cty05g00_monta_ret(" em abamdoc")

   return mr_ret.*, lr_ret.*

end function

# PSI.188425 - MONTA RETORNO
#-------------------------------------------------------------------------------
function cty05g00_monta_ret(l_texto)
#-------------------------------------------------------------------------------
   define l_texto        char(80)

   if l_texto is null or
      l_texto = ""    or
      l_texto = " "   then
      let mr_ret.stt = 1
      let mr_ret.msg = null
   else
      let mr_ret.stt = 3
      let mr_ret.msg = "Erro ", sqlca.sqlcode, sqlca.sqlerrd[2], l_texto
   end if

end function

function cty05g00_assist_passag(param)

  define l_clscod char(03)
  define l_clscodant char(03)
  define param record
        retorno smallint,
        succod like datrligapol.succod,
        aplnumdig like datrligapol.aplnumdig,
        itmnumdig like datrligapol.itmnumdig,
        dctnumseq decimal(04,00)
  end record

  define l_exist smallint


  let l_clscod = null
  let l_clscod = null
  let l_exist = false

  if m_prep_sql is null or m_prep_sql <> true then
      call cty05g00_prepare()
  end if

  --call cty05g00_prepare()

  open c_cty05g00_004 using param.succod,
                          param.aplnumdig,
                          param.itmnumdig,
                          param.dctnumseq
 whenever error continue
 let l_exist = false
 foreach c_cty05g00_004 into l_clscod

  let l_exist = true
  if l_clscod <> "034" and
     l_clscod <> "071" then
     let l_clscodant = l_clscod
  end if
  if l_clscod = "034" or
     l_clscod = "071" or
     l_clscod = "077" then
    if cta13m00_verifica_clausula(param.succod        ,
                                  param.aplnumdig     ,
                                  param.itmnumdig     ,
                                  g_funapol.dctnumseq ,
                                  l_clscod           ) then
     let l_clscod = l_clscodant
     continue foreach
    end if
  end if
 end foreach
 whenever error stop


  if l_exist = false  then
    error "Clausula não contratada para este tipo de assistencia"
    close c_cty05g00_004
    return l_clscod
  end if

  if param.retorno = 1 then
    close c_cty05g00_004
    return l_clscod
  end if

end function

#-------------------------------------------------------------------------------
function cty05g00_recupera_tel(lr_param)
#-------------------------------------------------------------------------------

define lr_param record
       segnumdig like abbmdoc.segnumdig
end record

define ret record
       dddcod    like gcakfilial.dddcod ,
       segteltxt like gsakend.teltxt
end record

initialize ret.* to null

 if m_prep_sql4 is null or
    m_prep_sql4 <> true then
    call cty05g00_prepare_4()
 end if

 open c_cty05g00_006  using lr_param.segnumdig

 whenever error continue
 fetch c_cty05g00_006   into ret.*


 whenever error stop


 close c_cty05g00_006

 return ret.*

 end function


#-------------------------------------------------------------------------------
function cty05g00_segnumdig_vida(lr_param)
#-------------------------------------------------------------------------------

define lr_param record
        segnom     like gsakseg.segnom      ,
        pestip     like gsakseg.pestip
end record

define l_ret  record
       segnumdig     like gsakseg.segnumdig   ,
       segnom        like gsakseg.segnom      ,
       pestip        like gsakseg.pestip      ,
       cgccpfnum     like gsakseg.cgccpfnum   ,
       cgcord        like gsakseg.cgcord      ,
       cgccpfdig     like gsakseg.cgccpfdig   ,
       nscdat        like gsakseg.nscdat      ,
       prporg        decimal(2,0)             ,  ---> Nilo
       prpnumdig     decimal(8,0)                ---> Nilo
end record

define l_fon record
       prifoncod  like gsakseg.prifoncod   ,
       segfoncod  like gsakseg.segfoncod   ,
       terfoncod  like gsakseg.terfoncod
end record

define l_cont    integer
define l_qtd_reg integer
define l_comando char(500)

---> Funeral III - Nilo
define al_retorno array[40] of record
       segnom     char(50)
      ,cgccpfnum  decimal(12,0)
      ,cgccpfdig  decimal(2,0)
      ,nscdat     date
      ,sgrorg     decimal(8,0)
      ,sgrnumdig  decimal(11,0)
      ,sgrstt     char(1)
      ,segnumdig  decimal(8,0)
      ,aplnumdig  like vtamdoc.aplnumdig
      ,temaft     char(1)
      ,tipo_seg   char(02)
      ,prpstt     decimal(2,0)
      ,etpnom     like vgsmseg.segnom
      ,ramcod     smallint
end record

define l_erro     smallint
define x          smallint

initialize l_ret.* to null
initialize l_fon.* to null
---> Funeral III - Nilo
initialize al_retorno to null

let l_cont    = 0
let l_comando = null
let l_erro    = null


   error "Aguarde Pesquisando Segurados ..."


     # Crio uma temporaria para posteriormente a mesma seja
     # lida na localizacao de apolice do vida (cta01m30)

    if not cty05g00_cria_temp() then
        return 1
    end if

    call cty05g00_prep_temp()

     if m_prep_sql4 is null or
        m_prep_sql4 <> true then
        call cty05g00_prepare_4()
     end if



    let l_comando = " select  segnumdig    "
                    ,"       ,segnom       "
                    ,"       ,pestip       "
                    ,"       ,cgccpfnum    "
                    ,"       ,cgcord       "
                    ,"       ,cgccpfdig    "
                    ,"       ,nscdat       "
                    ,"   from gsakseg      "
                    ,"   where segnom matches '",lr_param.segnom clipped, "*'"
                    ,"  order by 2 "


      prepare p_cty05g00_016 from l_comando
      declare c_cty05g00_015 cursor for p_cty05g00_016

      open c_cty05g00_015

      foreach  c_cty05g00_015 into l_ret.*

         if l_ret.segnumdig is not null then

               ---> Funeral III - Nilo

               call fvita008_pesquisa_segurado(l_ret.segnumdig)
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

               if l_erro = 0 then

                  let l_ret.prporg    = null
                  let l_ret.prpnumdig = null
                  let l_ret.prporg    = al_retorno[1].sgrorg
                  let l_ret.prpnumdig = al_retorno[1].sgrnumdig
                  whenever error continue

                  execute p_cty05g00_012 using l_ret.*

                  whenever error stop

               end if

               initialize al_retorno to null
               let l_erro = null

         end if
      end foreach
      close  c_cty05g00_015

     error ""

    return 0
end function

#-------------------------------------------------------------------------------
function cty05g00_cgccpf_vida(lr_param)
#-------------------------------------------------------------------------------

define lr_param record
       cgccpfnum  like gsakseg.cgccpfnum   ,
       cgccpfdig  like gsakseg.cgccpfdig   ,
       pestip     like gsakseg.pestip
end record

define l_ret  record
       segnumdig     like gsakseg.segnumdig   ,
       segnom        like gsakseg.segnom      ,
       pestip        like gsakseg.pestip      ,
       cgccpfnum     like gsakseg.cgccpfnum   ,
       cgcord        like gsakseg.cgcord      ,
       cgccpfdig     like gsakseg.cgccpfdig   ,
       nscdat        like gsakseg.nscdat      ,
       prporg        decimal(2,0)             ,  ---> Nilo
       prpnumdig     decimal(8,0)                ---> Nilo
end record

define l_cont integer

---> Funeral III - Nilo
define al_retorno array[40] of record
       segnom     char(50)
      ,cgccpfnum  decimal(12,0)
      ,cgccpfdig  decimal(2,0)
      ,nscdat     date
      ,sgrorg     decimal(8,0)
      ,sgrnumdig  decimal(11,0)
      ,sgrstt     char(1)
      ,segnumdig  decimal(8,0)
      ,aplnumdig  like vtamdoc.aplnumdig
      ,temaft     char(1)
      ,tipo_seg   char(02)
      ,prpstt     decimal(2,0)
      ,etpnom     like vgsmseg.segnom
      ,ramcod     smallint
end record

define l_erro     smallint

initialize l_ret.* to null

---> Funeral III - Nilo
initialize al_retorno to null

let l_cont = 0
let l_erro = null


        if m_prep_sql4 is null or
           m_prep_sql4 <> true then
           call cty05g00_prepare_4()
        end if

        # Crio uma temporaria para posteriormente a mesma seja
        # lida na localizacao de apolice do vida (cta01m30)

       if not cty05g00_cria_temp() then
           return 1
       end if

       call cty05g00_prep_temp()

       # Recupero o Segurado pelo CGC e CPF

       open c_cty05g00_008 using lr_param.cgccpfnum ,
                               lr_param.cgccpfdig ,
                               lr_param.pestip

       whenever error continue
       foreach c_cty05g00_008 into l_ret.*

          if l_ret.segnumdig is not null then

             ---> Funeral III - Nilo
             call fvita008_pesquisa_segurado(l_ret.segnumdig)
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

             if l_erro = 0 then

                let l_ret.prporg    = null
                let l_ret.prpnumdig = null
                let l_ret.prporg    = al_retorno[1].sgrorg
                let l_ret.prpnumdig = al_retorno[1].sgrnumdig

                whenever error continue

                execute p_cty05g00_012 using l_ret.*

                whenever error stop

             end if

             initialize al_retorno to null

             let l_erro = null

          end if
       end foreach
       close c_cty05g00_008

       error ""

       return 0

end function
#-------------------------------------------------------------------------------
function cty05g00_qtd_segurado(lr_param)
#-------------------------------------------------------------------------------

define lr_param record
        segnom        like gsakseg.segnom
end record

define l_comando char(200)
define l_qtd_seg integer

let l_qtd_seg = 0

 let l_comando = " select count(*) "
                 ,"   from gsakseg      "
                 ,"   where segnom matches '",lr_param.segnom clipped, "*'"


 let l_comando = l_comando clipped

 prepare p_cty05g00_017 from l_comando
 declare c_cty05g00_016 cursor for p_cty05g00_017

 open c_cty05g00_016
 whenever error continue
 fetch  c_cty05g00_016 into l_qtd_seg
 close c_cty05g00_016
 whenever error stop

 return  l_qtd_seg

end function

#------------------------------------------------------------------------------
function cty05g00_edsnumref(param)
#------------------------------------------------------------------------------

  define param    record
        retorno   smallint,
        succod    like datrligapol.succod,
        aplnumdig like datrligapol.aplnumdig,
        dctnumseq decimal(04,00)
  end record
  define l_edsnumref like abamdoc.edsnumdig
  let l_edsnumref = null
  if m_prep_sql is null or m_prep_sql <> true then
      call cty05g00_prepare()
  end if
  open ccty05g00009 using param.succod,
                          param.aplnumdig,
                          param.dctnumseq
  whenever error continue
  fetch ccty05g00009 into l_edsnumref
  whenever error stop
  if sqlca.sqlcode = notfound  then
    error "Endosso nao encontrado para esta apolice"
    close ccty05g00009
    return l_edsnumref
  end if
  if param.retorno = 1 then
    close ccty05g00009
    return l_edsnumref
  end if
end function

#-------------------------------------------------------#
function cty05g00_abamcor(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          nivel_retorno    smallint
         ,succod           like abamcor.succod
         ,aplnumdig        like abamcor.aplnumdig
   end record

   define lr_retorno       record
          corsus           like abamcor.corsus
   end record

   define l_resultado   smallint,
          l_mensagem    char(60)

   if m_prep_sql is null or
      m_prep_sql <> true then
      call cty05g00_prepare()
   end if

   let l_resultado = 0
   let l_mensagem  = null
   initialize lr_retorno.* to null

   whenever error continue
   open  ccty05g00029 using lr_param.succod, lr_param.aplnumdig
   fetch ccty05g00029 into  lr_retorno.*

   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Nao achou dados em abamcor "
      else
         let l_resultado = 3
         let l_mensagem = "Erro na selecao de abamcor ", sqlca.sqlcode
      end if
   end if

   close ccty05g00029

   if lr_param.nivel_retorno = 1 then
      return l_resultado, l_mensagem,
             lr_retorno.corsus
   end if

end function

#-------------------------------------------------------#
function cty05g00_cls(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          succod           like abbmclaus.succod
         ,aplnumdig        like abbmclaus.aplnumdig
         ,itmnumdig        like abbmclaus.itmnumdig
   end record

   define lr_retorno       record
          contados         integer
   end record

   define l_resultado   smallint,
          l_mensagem    char(60)

   if m_prep_sql is null or
      m_prep_sql <> true then
      call cty05g00_prepare()
   end if

   let l_resultado = 0
   let l_mensagem  = null
   initialize lr_retorno.* to null

   whenever error continue
   open  ccty05g00030 using lr_param.succod, lr_param.aplnumdig,
                            lr_param.itmnumdig
   fetch ccty05g00030 into  lr_retorno.*

   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Nao achou dados em abbmclaus "
      else
         let l_resultado = 3
         let l_mensagem = "Erro na selecao de abbmclaus ", sqlca.sqlcode
      end if
   end if

   close ccty05g00030

   return l_resultado, l_mensagem, lr_retorno.contados

end function

function cty05g00_clausula_assunto(lr_param)

  define lr_param record
       c24astcod like datkassunto.c24astcod
  end record
  define lr_retorno record
         erro     smallint,
         msg      char(300),
         clscod   like datrsrvcls.clscod
  end record
  define lr_funapol       record
    resultado       char(01),
    dctnumseq       decimal(04,00),
    vclsitatu       decimal(04,00),
    autsitatu       decimal(04,00),
    dmtsitatu       decimal(04,00),
    dpssitatu       decimal(04,00),
    appsitatu       decimal(04,00),
    vidsitatu       decimal(04,00)
  end record
  define l_clscod like datrsrvcls.clscod,
         l_existe smallint
  initialize lr_retorno.* to null
  initialize lr_funapol.* to null
  let l_clscod = null
  let l_existe = false
  if m_prep = "" or
     m_prep = false then
    call cty05g00_prepare()
  end if
  call f_funapol_ultima_situacao
      (g_documento.succod, g_documento.aplnumdig, g_documento.itmnumdig)
       returning lr_funapol.*
  whenever error continue
  open ccty05g00032 using g_documento.succod
                         ,g_documento.aplnumdig
                         ,g_documento.itmnumdig
                         ,lr_funapol.dctnumseq
  foreach ccty05g00032 into l_clscod
     let l_existe = true
     if l_clscod = "034" or
        l_clscod = "071" or
        l_clscod = "077" then # PSI 239.399 Clausula 77
       if cta13m00_verifica_clausula(g_documento.succod        ,
                                     g_documento.aplnumdig     ,
                                     g_documento.itmnumdig     ,
                                     lr_funapol.dctnumseq      ,
                                     l_clscod           ) then
        continue foreach
       end if
     end if
     open ccty05g00031 using lr_param.c24astcod,
                             g_documento.ramcod,
                             l_clscod
     fetch ccty05g00031 into lr_retorno.clscod
     if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = 100 then
          let lr_retorno.clscod = null
          let lr_retorno.erro = sqlca.sqlcode
          let lr_retorno.msg = "Clausula <",l_clscod ,"> não cadastrada para o assunto < ",lr_param.c24astcod ," > !"
          call errorlog(lr_retorno.msg)
       else
          let lr_retorno.clscod = null
          let lr_retorno.erro = sqlca.sqlcode
          let lr_retorno.msg = "Erro <",lr_retorno.erro ,"> na busca de assunto e clausula !"
          call errorlog(lr_retorno.msg)
       end if
     else
        exit foreach
     end if
  end foreach
  whenever error stop
  if l_existe = false then
     let lr_retorno.erro = 100
     let lr_retorno.msg  = " Não existe clausula para essa apolice "
     call errorlog(lr_retorno.msg)
  end if
  return lr_retorno.*

end function

