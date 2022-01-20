 #############################################################################
 # Nome do Modulo: CTX04G00                                         Marcelo  #
 #                                                                  Gilberto #
 # Funcoes genericas - locais dos servicos                          Mar/1999 #
 #############################################################################
 # ......................................................................... #
 #                                                                           #
 #                           * * * Alteracoes * * *                          #
 #                                                                           #
 # Data       Autor Fabrica   Origem     Alteracao                           #
 # ---------- --------------  ---------- ----------------------------------- #
 # 18/05/2005 Adriano, Meta   PSI191108  Criada funcao ctx04g00_local()      #
 #                                       inserido campo emeviacod em select  #
 #                                       da tabela datmlcl e retornos.       #
# ----------  --------------  --------- -------------------------------------#
# 30/01/2006  T.Solda, Meta   PSI194387  Passar o "vcompila" no modulo       #
#----------------------------------------------------------------------------#
# 11/09/2007  Saulo, Meta     PSI211982  Criar funcao ctx04g00_cidade_uf     #
#                                        Substituicao de palavras reservadas #
# 13/08/2009  Sergio Burini   PSI 244236 Inclusão do Sub-Dairro              #
#----------------------------------------------------------------------------#

 database porto

 define m_prep_sql    smallint
       ,m_prepare_sql smallint

#------------------------------------------------------------------
 function ctx04g00_local_completo(param)
#------------------------------------------------------------------

 define param        record
    atdsrvnum        like datmlcl.atdsrvnum,
    atdsrvano        like datmlcl.atdsrvano,
    c24endtip        like datmlcl.c24endtip
 end record

 define d_ctx04g00   record
    lclidttxt        like datmlcl.lclidttxt,
    lgdtip           like datmlcl.lgdtip,
    lgdnom           like datmlcl.lgdnom,
    lgdnum           like datmlcl.lgdnum,
    lclbrrnom        like datmlcl.lclbrrnom,
    brrnom           like datmlcl.brrnom,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclrefptotxt     like datmlcl.lclrefptotxt,
    endzon           like datmlcl.endzon,
    lgdcep           like datmlcl.lgdcep,
    lgdcepcmp        like datmlcl.lgdcepcmp,
    dddcod           like datmlcl.dddcod,
    lcltelnum        like datmlcl.lcltelnum,
    lclcttnom        like datmlcl.lclcttnom,
    c24lclpdrcod     like datmlcl.c24lclpdrcod,
    coderro          integer,
    endcmp           like datmlcl.endcmp
 end record





#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#


	initialize  d_ctx04g00.*  to  null

 initialize d_ctx04g00.*  to null

 if param.atdsrvnum is null  or
    param.atdsrvano is null  or
    param.c24endtip is null  then
    return d_ctx04g00.*
 end if

#--------------------------------------------------------------------
# Informacoes do local da ocorrencia
#--------------------------------------------------------------------
 select lclidttxt,
        lgdtip,
        lgdnom,
        lgdnum,
        lclbrrnom,
        brrnom,
        cidnom,
        ufdcod,
        lclrefptotxt,
        endzon,
        lgdcep,
        lgdcepcmp,
        dddcod,
        lcltelnum,
        lclcttnom,
        c24lclpdrcod,
        endcmp
   into d_ctx04g00.lclidttxt,
        d_ctx04g00.lgdtip,
        d_ctx04g00.lgdnom,
        d_ctx04g00.lgdnum,
        d_ctx04g00.lclbrrnom,
        d_ctx04g00.brrnom,
        d_ctx04g00.cidnom,
        d_ctx04g00.ufdcod,
        d_ctx04g00.lclrefptotxt,
        d_ctx04g00.endzon,
        d_ctx04g00.lgdcep,
        d_ctx04g00.lgdcepcmp,
        d_ctx04g00.dddcod,
        d_ctx04g00.lcltelnum,
        d_ctx04g00.lclcttnom,
        d_ctx04g00.c24lclpdrcod,
        d_ctx04g00.endcmp
   from datmlcl
  where atdsrvnum = param.atdsrvnum  and
        atdsrvano = param.atdsrvano  and
        c24endtip = param.c24endtip

 let d_ctx04g00.coderro = sqlca.sqlcode

 if  (d_ctx04g00.brrnom is null or d_ctx04g00.brrnom = " ") and
     (d_ctx04g00.lclbrrnom is not null and d_ctx04g00.lclbrrnom <> " ") then
     let d_ctx04g00.brrnom = d_ctx04g00.lclbrrnom
 end if
 if  (d_ctx04g00.brrnom is not null and d_ctx04g00.brrnom <> " ") and
     (d_ctx04g00.lclbrrnom is null or d_ctx04g00.lclbrrnom = " ") then
     let d_ctx04g00.lclbrrnom = d_ctx04g00.brrnom
 end if
 return d_ctx04g00.*

end function  ###  ctx04g00_local_completo

#----------------------#
function ctx04g00_prep()
#----------------------#

 define l_sql char(800)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_sql  =  null

 let l_sql = "select lclidttxt "
                  ," ,lgdtip "
                  ," ,lgdnom "
                  ," ,lgdnum "
                  ," ,lclbrrnom "
                  ," ,brrnom "
                  ," ,cidnom "
                  ," ,ufdcod "
                  ," ,lclrefptotxt "
                  ," ,endzon "
                  ," ,lgdcep "
                  ," ,lgdcepcmp "
                  ," ,lclltt "
                  ," ,lcllgt "
                  ," ,dddcod "
                  ," ,lcltelnum "
                  ," ,lclcttnom "
                  ," ,c24lclpdrcod "
                  ," ,emeviacod "
                  ," ,celteldddcod "
                  ," ,celtelnum   "
                  ," ,endcmp "
            , " from datmlcl "
           , " where atdsrvnum = ? "
             , " and atdsrvano = ? "
             , " and c24endtip = ? "
  prepare p_ctx04g00_001 from l_sql
  declare c_ctx04g00_001 cursor for p_ctx04g00_001

  let m_prep_sql = true

end function

#------------------------------------------------------------------
 function ctx04g00_local_gps(param)
#------------------------------------------------------------------

 define param        record
    atdsrvnum        like datmlcl.atdsrvnum,
    atdsrvano        like datmlcl.atdsrvano,
    c24endtip        like datmlcl.c24endtip
 end record

 define d_ctx04g00   record
    lclidttxt        like datmlcl.lclidttxt,
    lgdtip           like datmlcl.lgdtip,
    lgdnom           like datmlcl.lgdnom,
    lgdnum           like datmlcl.lgdnum,
    lclbrrnom        like datmlcl.lclbrrnom,
    brrnom           like datmlcl.brrnom,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclrefptotxt     like datmlcl.lclrefptotxt,
    endzon           like datmlcl.endzon,
    lgdcep           like datmlcl.lgdcep,
    lgdcepcmp        like datmlcl.lgdcepcmp,
    lclltt           like datmlcl.lclltt,
    lcllgt           like datmlcl.lcllgt,
    dddcod           like datmlcl.dddcod,
    lcltelnum        like datmlcl.lcltelnum,
    lclcttnom        like datmlcl.lclcttnom,
    c24lclpdrcod     like datmlcl.c24lclpdrcod,
    celteldddcod     like datmlcl.celteldddcod,
    celtelnum        like datmlcl.celtelnum,
    endcmp           like datmlcl.endcmp,
    coderro          integer
 end record

 define l_emeviacod  like datmlcl.emeviacod


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_emeviacod  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#


 initialize  d_ctx04g00.*  to  null

 initialize d_ctx04g00.*  to null

 let l_emeviacod = null

 if param.atdsrvnum is null  or
    param.atdsrvano is null  or
    param.c24endtip is null  then
    return d_ctx04g00.*, l_emeviacod
 end if

 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctx04g00_prep()
 end if

 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia (inclusive latitude/longitude)
 #--------------------------------------------------------------------

 open c_ctx04g00_001 using param.atdsrvnum
                        ,param.atdsrvano
                        ,param.c24endtip

 fetch c_ctx04g00_001 into d_ctx04g00.lclidttxt
                        ,d_ctx04g00.lgdtip
                        ,d_ctx04g00.lgdnom
                        ,d_ctx04g00.lgdnum
                        ,d_ctx04g00.lclbrrnom
                        ,d_ctx04g00.brrnom
                        ,d_ctx04g00.cidnom
                        ,d_ctx04g00.ufdcod
                        ,d_ctx04g00.lclrefptotxt
                        ,d_ctx04g00.endzon
                        ,d_ctx04g00.lgdcep
                        ,d_ctx04g00.lgdcepcmp
                        ,d_ctx04g00.lclltt
                        ,d_ctx04g00.lcllgt
                        ,d_ctx04g00.dddcod
                        ,d_ctx04g00.lcltelnum
                        ,d_ctx04g00.lclcttnom
                        ,d_ctx04g00.c24lclpdrcod
                        ,l_emeviacod
                        ,d_ctx04g00.celteldddcod
                        ,d_ctx04g00.celtelnum
                        ,d_ctx04g00.endcmp

 let d_ctx04g00.coderro = sqlca.sqlcode

 close c_ctx04g00_001

 return d_ctx04g00.*, l_emeviacod

end function  ###  ctx04g00_local_gps

#------------------------------------------------------------------
 function ctx04g00_local_reduzido(param)
#------------------------------------------------------------------

 define param        record
    atdsrvnum        like datmlcl.atdsrvnum,
    atdsrvano        like datmlcl.atdsrvano,
    c24endtip        like datmlcl.c24endtip
 end record

 define d_ctx04g00   record
    lclidttxt        like datmlcl.lclidttxt,
    lgdtxt           char (80),
    brrnom           like datmlcl.brrnom,
    endzon           like datmlcl.endzon,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclrefptotxt     like datmlcl.lclrefptotxt,
    dddcod           like datmlcl.dddcod,
    lcltelnum        like datmlcl.lcltelnum,
    lclcttnom        like datmlcl.lclcttnom,
    coderro          integer
 end record

 define ws           record
    lclidttxt        like datmlcl.lclidttxt,
    lgdtip           like datmlcl.lgdtip,
    lgdnom           like datmlcl.lgdnom,
    lgdnum           like datmlcl.lgdnum,
    lclbrrnom        like datmlcl.lclbrrnom,
    brrnom           like datmlcl.brrnom,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclrefptotxt     like datmlcl.lclrefptotxt,
    endzon           like datmlcl.endzon,
    lgdcep           like datmlcl.lgdcep,
    lgdcepcmp        like datmlcl.lgdcepcmp,
    dddcod           like datmlcl.dddcod,
    lcltelnum        like datmlcl.lcltelnum,
    lclcttnom        like datmlcl.lclcttnom,
    c24lclpdrcod     like datmlcl.c24lclpdrcod,
    endcmp           like datmlcl.endcmp
 end record






#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#


	initialize  d_ctx04g00.*  to  null

	initialize  ws.*  to  null

 initialize d_ctx04g00.*  to null
 initialize ws.*          to null

 if param.atdsrvnum is null  or
    param.atdsrvano is null  or
    param.c24endtip is null  then
    return d_ctx04g00.*
 end if

#--------------------------------------------------------------------
# Informacoes do local da ocorrencia
#--------------------------------------------------------------------
 call ctx04g00_local_completo(param.atdsrvnum,
                              param.atdsrvano,
                              param.c24endtip)
                    returning ws.lclidttxt,
                              ws.lgdtip,
                              ws.lgdnom,
                              ws.lgdnum,
                              ws.lclbrrnom,
                              ws.brrnom,
                              ws.cidnom,
                              ws.ufdcod,
                              ws.lclrefptotxt,
                              ws.endzon,
                              ws.lgdcep,
                              ws.lgdcepcmp,
                              ws.dddcod,
                              ws.lcltelnum,
                              ws.lclcttnom,
                              ws.c24lclpdrcod,
                              d_ctx04g00.coderro,
                              ws.endcmp

 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 call cts06g10_monta_brr_subbrr(ws.brrnom,
                                ws.lclbrrnom)
      returning ws.lclbrrnom

 let d_ctx04g00.lclidttxt    = ws.lclidttxt
 let d_ctx04g00.lgdtxt       = ws.lgdtip clipped, " ",
                               ws.lgdnom clipped, " ",
                               ws.lgdnum using "<<<<#", " ",
                               ws.endcmp clipped
 let d_ctx04g00.brrnom       = ws.lclbrrnom
 let d_ctx04g00.cidnom       = ws.cidnom
 let d_ctx04g00.ufdcod       = ws.ufdcod
 let d_ctx04g00.endzon       = ws.endzon
 let d_ctx04g00.dddcod       = ws.dddcod
 let d_ctx04g00.lcltelnum    = ws.lcltelnum
 let d_ctx04g00.lclrefptotxt = ws.lclrefptotxt
 let d_ctx04g00.lclcttnom    = ws.lclcttnom

 return d_ctx04g00.*

end function  ###  ctx04g00_local_reduzido

#PSI 237337 - MELHORIAS NA COMUNICAÇÃO
#------------------------------------------------------------------
 function ctx04g00_local_reduzido_ctg(param)
#------------------------------------------------------------------

 define param        record
    atdsrvnum        like datmlcl.atdsrvnum,
    atdsrvano        like datmlcl.atdsrvano,
    c24endtip        like datmlcl.c24endtip
 end record

 define d_ctx04g00   record
    lclidttxt        like datmlcl.lclidttxt,
    lgdtxt           char (28),
    lgdnum           char(5),
    brrnom           like datmlcl.brrnom,
    endzon           like datmlcl.endzon,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclrefptotxt     like datmlcl.lclrefptotxt,
    dddcod           like datmlcl.dddcod,
    lcltelnum        like datmlcl.lcltelnum,
    lclcttnom        like datmlcl.lclcttnom,
    coderro          integer
 end record

 define ws           record
    lclidttxt        like datmlcl.lclidttxt,
    lgdtip           like datmlcl.lgdtip,
    lgdnom           like datmlcl.lgdnom,
    lgdnum           like datmlcl.lgdnum,
    lclbrrnom        like datmlcl.lclbrrnom,
    brrnom           like datmlcl.brrnom,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclrefptotxt     like datmlcl.lclrefptotxt,
    endzon           like datmlcl.endzon,
    lgdcep           like datmlcl.lgdcep,
    lgdcepcmp        like datmlcl.lgdcepcmp,
    dddcod           like datmlcl.dddcod,
    lcltelnum        like datmlcl.lcltelnum,
    lclcttnom        like datmlcl.lclcttnom,
    c24lclpdrcod     like datmlcl.c24lclpdrcod,
    endcmp           like datmlcl.endcmp
 end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#
 initialize  d_ctx04g00.*  to  null
 initialize  ws.*  to  null
 initialize d_ctx04g00.*  to null
 initialize ws.*          to null

 if param.atdsrvnum is null  or
    param.atdsrvano is null  or
    param.c24endtip is null  then
    return d_ctx04g00.*
 end if

#--------------------------------------------------------------------
# Informacoes do local da ocorrencia
#--------------------------------------------------------------------
 call ctx04g00_local_completo(param.atdsrvnum,
                              param.atdsrvano,
                              param.c24endtip)
                    returning ws.lclidttxt,
                              ws.lgdtip,
                              ws.lgdnom,
                              ws.lgdnum,
                              ws.lclbrrnom,
                              ws.brrnom,
                              ws.cidnom,
                              ws.ufdcod,
                              ws.lclrefptotxt,
                              ws.endzon,
                              ws.lgdcep,
                              ws.lgdcepcmp,
                              ws.dddcod,
                              ws.lcltelnum,
                              ws.lclcttnom,
                              ws.c24lclpdrcod,
                              d_ctx04g00.coderro,
                              ws.endcmp

 let d_ctx04g00.lclidttxt    = ws.lclidttxt
 let d_ctx04g00.lgdtxt       = ws.lgdnom clipped
 let d_ctx04g00.lgdnum       = ws.lgdnum using "<<<<#"
 let d_ctx04g00.brrnom       = ws.lclbrrnom
 let d_ctx04g00.cidnom       = ws.cidnom
 let d_ctx04g00.ufdcod       = ws.ufdcod
 let d_ctx04g00.endzon       = ws.endzon
 let d_ctx04g00.dddcod       = ws.dddcod
 let d_ctx04g00.lcltelnum    = ws.lcltelnum
 let d_ctx04g00.lclrefptotxt = ws.lclrefptotxt
 let d_ctx04g00.lclcttnom    = ws.lclcttnom

 return d_ctx04g00.*

end function  ###  ctx04g00_local_reduzido

#------------------------------------------------------------------
 function ctx04g00_local_prepare(param)
#------------------------------------------------------------------

 define param        record
    atdsrvnum        like datmlcl.atdsrvnum,
    atdsrvano        like datmlcl.atdsrvano,
    c24endtip        like datmlcl.c24endtip,
    privez           smallint
 end record

 define d_ctx04g00   record
    lclidttxt        like datmlcl.lclidttxt,
    lgdtip           like datmlcl.lgdtip,
    lgdnom           like datmlcl.lgdnom,
    lgdnum           like datmlcl.lgdnum,
    lclbrrnom        like datmlcl.lclbrrnom,
    brrnom           like datmlcl.brrnom,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclrefptotxt     like datmlcl.lclrefptotxt,
    endzon           like datmlcl.endzon,
    lgdcep           like datmlcl.lgdcep,
    lgdcepcmp        like datmlcl.lgdcepcmp,
    dddcod           like datmlcl.dddcod,
    lcltelnum        like datmlcl.lcltelnum,
    lclcttnom        like datmlcl.lclcttnom,
    c24lclpdrcod     like datmlcl.c24lclpdrcod,
    coderro          integer
 end record

 define l_emeviacod  like datmlcl.emeviacod


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_emeviacod  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#


 initialize  d_ctx04g00.*  to  null

 initialize d_ctx04g00.*  to null

 if param.atdsrvnum is null  or
    param.atdsrvano is null  or
    param.c24endtip is null  then
    return d_ctx04g00.*
 end if

 if param.privez = true  then
    call ctx04g00_prepare() returning d_ctx04g00.coderro
    if d_ctx04g00.coderro <> 0  then
       return d_ctx04g00.*
    end if
 end if

 call ctx04g00_select(param.atdsrvnum,
                      param.atdsrvano,
                      param.c24endtip)
            returning d_ctx04g00.*, l_emeviacod

 return d_ctx04g00.*

end function   ###   ctx04g00_local_prepare

#------------------------------------------------------------------
 function ctx04g00_prepare()
#------------------------------------------------------------------

 define ws           record
    sql              char (750)
 end record





#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#


	initialize  ws.*  to  null

 let ws.sql = "select lclidttxt,   ",
              "       lgdtip,      ",
              "       lgdnom,      ",
              "       lgdnum,      ",
              "       lclbrrnom,   ",
              "       brrnom,      ",
              "       cidnom,      ",
              "       ufdcod,      ",
              "       lclrefptotxt,",
              "       endzon,      ",
              "       lgdcep,      ",
              "       lgdcepcmp,   ",
              "       dddcod,      ",
              "       lcltelnum,   ",
              "       lclcttnom,   ",
              "       c24lclpdrcod,",
              "       emeviacod    ",
              "  from datmlcl      ",
              " where atdsrvnum = ?",
              "   and atdsrvano = ?",
              "   and c24endtip = ?"

 prepare p_ctx04g00_002 from ws.sql
 declare c_ctx04g00_002 cursor for p_ctx04g00_002

 let m_prepare_sql = true

 return sqlca.sqlcode

end function  ###  ctx04g00_prepare

#------------------------------------------------------------------
 function ctx04g00_select(param)
#------------------------------------------------------------------

 define param        record
    atdsrvnum        like datmlcl.atdsrvnum,
    atdsrvano        like datmlcl.atdsrvano,
    c24endtip        like datmlcl.c24endtip
 end record

 define d_ctx04g00   record
    lclidttxt        like datmlcl.lclidttxt,
    lgdtip           like datmlcl.lgdtip,
    lgdnom           like datmlcl.lgdnom,
    lgdnum           like datmlcl.lgdnum,
    lclbrrnom        like datmlcl.lclbrrnom,
    brrnom           like datmlcl.brrnom,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lclrefptotxt     like datmlcl.lclrefptotxt,
    endzon           like datmlcl.endzon,
    lgdcep           like datmlcl.lgdcep,
    lgdcepcmp        like datmlcl.lgdcepcmp,
    dddcod           like datmlcl.dddcod,
    lcltelnum        like datmlcl.lcltelnum,
    lclcttnom        like datmlcl.lclcttnom,
    c24lclpdrcod     like datmlcl.c24lclpdrcod,
    coderro          integer
 end record

 define l_emeviacod  like datmlcl.emeviacod



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_emeviacod  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  d_ctx04g00.*  to  null


 initialize d_ctx04g00.*  to null

 let l_emeviacod = null

 open  c_ctx04g00_002 using param.atdsrvnum,
                       param.atdsrvano,
                       param.c24endtip
 fetch c_ctx04g00_002 into d_ctx04g00.lclidttxt,
                      d_ctx04g00.lgdtip,
                      d_ctx04g00.lgdnom,
                      d_ctx04g00.lgdnum,
                      d_ctx04g00.lclbrrnom,
                      d_ctx04g00.brrnom,
                      d_ctx04g00.cidnom,
                      d_ctx04g00.ufdcod,
                      d_ctx04g00.lclrefptotxt,
                      d_ctx04g00.endzon,
                      d_ctx04g00.lgdcep,
                      d_ctx04g00.lgdcepcmp,
                      d_ctx04g00.dddcod,
                      d_ctx04g00.lcltelnum,
                      d_ctx04g00.lclcttnom,
                      d_ctx04g00.c24lclpdrcod,
                      l_emeviacod

 let d_ctx04g00.coderro = sqlca.sqlcode

 close c_ctx04g00_002

 return d_ctx04g00.*, l_emeviacod

end function  ###  ctx04g00_select

#-------------------------------#
function ctx04g00_local(lr_param)
#-------------------------------#

 define lr_param     record
    atdsrvnum        like datmlcl.atdsrvnum
   ,atdsrvano        like datmlcl.atdsrvano
   ,c24endtip        like datmlcl.c24endtip
   ,privez           smallint
 end record

 define lr_ctx04g00   record
    lclidttxt        like datmlcl.lclidttxt
   ,lgdtip           like datmlcl.lgdtip
   ,lgdnom           like datmlcl.lgdnom
   ,lgdnum           like datmlcl.lgdnum
   ,lclbrrnom        like datmlcl.lclbrrnom
   ,brrnom           like datmlcl.brrnom
   ,cidnom           like datmlcl.cidnom
   ,ufdcod           like datmlcl.ufdcod
   ,lclrefptotxt     like datmlcl.lclrefptotxt
   ,endzon           like datmlcl.endzon
   ,lgdcep           like datmlcl.lgdcep
   ,lgdcepcmp        like datmlcl.lgdcepcmp
   ,dddcod           like datmlcl.dddcod
   ,lcltelnum        like datmlcl.lcltelnum
   ,lclcttnom        like datmlcl.lclcttnom
   ,c24lclpdrcod     like datmlcl.c24lclpdrcod
   ,coderro          integer
 end record

 define l_emeviacod  like datmlcl.emeviacod


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_emeviacod  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#


 initialize lr_ctx04g00.*  to  null
 let l_emeviacod = null

 if lr_param.atdsrvnum is null  or
    lr_param.atdsrvano is null  or
    lr_param.c24endtip is null  then
    return lr_ctx04g00.*, l_emeviacod
 end if

 if lr_param.privez = true  then
    let lr_ctx04g00.coderro = ctx04g00_prepare()
    if lr_ctx04g00.coderro <> 0  then
       return lr_ctx04g00.*, l_emeviacod
    end if
 end if

 call ctx04g00_select(lr_param.atdsrvnum,
                      lr_param.atdsrvano,
                      lr_param.c24endtip)
            returning lr_ctx04g00.*, l_emeviacod

 return lr_ctx04g00.*, l_emeviacod

end function

#------------------------------------------------------------------
 function ctx04g00_cidade_uf(lr_param)
#------------------------------------------------------------------

   define lr_param record
             atdsrvnum like datmlcl.atdsrvnum
            ,atdsrvano like datmlcl.atdsrvano
            ,c24endtip like datmlcl.c24endtip
   end record

   define lr_retorno record
             coderro  smallint
            ,msgerro  char(040)
            ,cidnom   like datmlcl.cidnom
            ,ufdcod   like datmlcl.ufdcod
   end record

   define l_lixo char(060)
         ,l_prep smallint

   initialize lr_retorno to null

   let l_lixo = null
   let l_prep = null

   if m_prepare_sql is null or
      m_prepare_sql <> true then
      let l_prep = ctx04g00_prepare()
   end if

   open c_ctx04g00_002 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano
                          ,lr_param.c24endtip
   whenever error continue
   fetch c_ctx04g00_002 into l_lixo
                          ,l_lixo
                          ,l_lixo
                          ,l_lixo
                          ,l_lixo
                          ,l_lixo
                          ,lr_retorno.cidnom
                          ,lr_retorno.ufdcod
   whenever error stop
   if sqlca.sqlcode = 0 then
      let lr_retorno.coderro = 1
   else
      if sqlca.sqlcode = notfound then
         let lr_retorno.coderro = 2
         let lr_retorno.msgerro = 'Nao achou cidade/uf do servico'
      else
         let lr_retorno.coderro = 3
         let lr_retorno.msgerro = 'Erro de acesso a tabela datmlcl'
         error 'Erro SELECT c_ctx04g00_002 / ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] sleep 2
         error 'CTX04G00 / ctx04g00_cidade_uf() / ',lr_param.atdsrvnum
                                             ,' / ',lr_param.atdsrvano
                                             ,' / ',lr_param.c24endtip sleep 2
      end if
   end if

   return lr_retorno.coderro
         ,lr_retorno.msgerro
         ,lr_retorno.cidnom
         ,lr_retorno.ufdcod

end function

#------------------------------------------------------------------
 function ctx04g00_brr_cid_uf(lr_param)
#------------------------------------------------------------------

   define lr_param record
             atdsrvnum like datmlcl.atdsrvnum
            ,atdsrvano like datmlcl.atdsrvano
            ,c24endtip like datmlcl.c24endtip
   end record

   define lr_retorno record
             coderro  smallint
            ,msgerro  char(040)
            ,cidnom   like datmlcl.cidnom
            ,ufdcod   like datmlcl.ufdcod
            ,brrnom   like datmlcl.brrnom
   end record

   define l_lixo char(060)
         ,l_prep smallint

   initialize lr_retorno to null

   let l_lixo = null
   let l_prep = null

   if m_prepare_sql is null or
      m_prepare_sql <> true then
      let l_prep = ctx04g00_prepare()
   end if

   open c_ctx04g00_002 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano
                          ,lr_param.c24endtip
   whenever error continue
   fetch c_ctx04g00_002 into l_lixo
                          ,l_lixo
                          ,l_lixo
                          ,l_lixo
                          ,l_lixo
                          ,lr_retorno.brrnom
                          ,lr_retorno.cidnom
                          ,lr_retorno.ufdcod
   whenever error stop
   if sqlca.sqlcode = 0 then
      let lr_retorno.coderro = 1
   else
      if sqlca.sqlcode = notfound then
         let lr_retorno.coderro = 2
         let lr_retorno.msgerro = 'Nao achou cidade/uf do servico'
      else
         let lr_retorno.coderro = 3
         let lr_retorno.msgerro = 'Erro de acesso a tabela datmlcl'
         error 'Erro SELECT c_ctx04g00_002 / ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] sleep 2
         error 'CTX04G00 / ctx04g00_cidade_uf() / ',lr_param.atdsrvnum
                                             ,' / ',lr_param.atdsrvano
                                             ,' / ',lr_param.c24endtip sleep 2
      end if
   end if

   return lr_retorno.coderro
         ,lr_retorno.msgerro
         ,lr_retorno.cidnom
         ,lr_retorno.ufdcod
         ,lr_retorno.brrnom

end function
