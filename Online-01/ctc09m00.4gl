#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : CENTRAL 24 HORAS                                           #
# Modulo        : ctc09m00.4gl                                               #
# Analista Resp : Glauce Lima                                                #
# PSI           : 172.057                                                    #
# OSF           : 028991                                                     #
#                 Carta de Transferencia de Corretagem.                      #
#............................................................................#
# Desenvolvimento: Meta, Robson Inocencio                                    #
# Liberacao      : 25/11/2003                                                #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 22/07/2004 Meta, Robson      PSI183.431 Obter informacao da carta de       #
#                              OSF036.439 transferencia.                     #
# 11/08/2004 Kiandra                      Carta de corretagem, nao pode ser  #
#                                         por item somente por apl.          #
#----------------------------------------------------------------------------#


globals '/homedsa/projetos/geral/globals/glct.4gl'

define m_ctc09m00_prep    smallint

#------------------------#
 function ctc09m00_prep()
#------------------------#

 define l_sql_stmt  char(800)

 let l_sql_stmt = ' select corsus, ',
                         ' solnom, ',
                         ' atlult, ',
                         ' cortrftip ',
                    ' from apbmcortrans ',
                   ' where succod = ? ',
                     ' and aplnumdig = ? '

 prepare p_ctc09m00_001 from l_sql_stmt
 declare c_ctc09m00_001 cursor for p_ctc09m00_001

 let l_sql_stmt = ' select corsus, ',
                         ' slcnom, ',
                         ' cortrftip, ',
                         ' atldat ',
                    ' from rsamcortrans ',
                   ' where sgrorg = ? ',
                     ' and sgrnumdig = ? '

 prepare p_ctc09m00_002 from l_sql_stmt
 declare c_ctc09m00_002 cursor for p_ctc09m00_002

 let l_sql_stmt = ' select cornom ',
                    ' from gcaksusep, gcakcorr ',
                   ' where gcaksusep.corsus = ? ',
                     ' and gcakcorr.corsuspcp = gcaksusep.corsuspcp '

 prepare p_ctc09m00_003 from l_sql_stmt
 declare c_ctc09m00_003 cursor for p_ctc09m00_003

 #PSI183431 - robson - inicio
 let l_sql_stmt = " select corsus, solnom,  "
                 ,"        atlult, cortrftip "
                 ,"   from apbmcortrans  "
                 ,"  where succod    = ? "
                 ,"    and aplnumdig = ? "
                 ,"    and itmnumdig = ? "
 prepare pctc09m00004 from l_sql_stmt
 declare cctc09m00004 cursor for pctc09m00004
 #PSI183431 - robson - fim

 let m_ctc09m00_prep = true

 end function

#----------------------------------------#
 function ctc09m00(l_sgrorg, l_sgrnumdig)
#----------------------------------------#
 define l_sgrorg    like rsamseguro.sgrorg,
        l_sgrnumdig like rsamseguro.sgrnumdig
 define lr_carta record
        susep_atual     char(06),                    {susep atual}
        nom_susep_atual char(40),                    {descricao susep atual}
        corsus          like apbmcortrans.corsus,    {susep autorizado}
        solnom          like apbmcortrans.solnom,    {descricao susep autorizado}
        cornom          like gcakcorr.cornom,        {nome solicitante}
        cortrftip       like apbmcortrans.cortrftip, {autorizacao}
        mensagem        char(50)                     {mensagem}
 end record
 define  l_atlult       like apbmcortrans.atlult
 define  l_resp char(001)

 let int_flag = false
 let l_resp   = null
 if m_ctc09m00_prep is null or
    m_ctc09m00_prep <> true then
    call ctc09m00_prep()
 end if

 initialize lr_carta.* to null

 if g_documento.ramcod = 531 or
    g_documento.ramcod = 31 then
    whenever error continue
    open c_ctc09m00_001 using g_documento.succod,
                            g_documento.aplnumdig
                          # g_documento.itmnumdig
    fetch c_ctc09m00_001 into lr_carta.corsus,
                            lr_carta.cornom,
                            l_atlult,
                            lr_carta.cortrftip
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode < 0 then                             ## Erro de acesso a base
          error " Erro ACESSO apbmcortrans ", sqlca.sqlcode, "/",sqlca.sqlerrd[2] sleep 2
          error "ctc09m00()/", g_documento.succod, " ", g_documento.aplnumdig, " ", g_documento.itmnumdig sleep 2
          return
       else
          error " Nao existe carta de corretagem para essa apolice " sleep 2
          return
       end if
    end if
 else
    whenever error continue
    open c_ctc09m00_002 using l_sgrorg,
                            l_sgrnumdig
    fetch c_ctc09m00_002 into lr_carta.corsus,
                            lr_carta.cornom,
                            lr_carta.cortrftip,
                            l_atlult
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode < 0 then                             ## Erro de acesso a base
          error " Erro ACESSO rsamcortrans ", sqlca.sqlcode, "/",sqlca.sqlerrd[2] sleep 2
          error "ctc09m00()/", l_sgrorg, " ", l_sgrnumdig sleep 2
          return
       else
          error " Nao existe carta de corretagem para essa apolice " sleep 2
          return
       end if
    end if
 end if

 whenever error continue
 open c_ctc09m00_003 using lr_carta.corsus
 fetch c_ctc09m00_003 into lr_carta.solnom
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_carta.solnom = null
    else
       error " Erro ACESSO gcakcorr ", sqlca.sqlcode, "/",sqlca.sqlerrd[2] sleep 2
       error "ctc09m00()/", lr_carta.corsus sleep 2
       return
    end if
 end if

 let lr_carta.susep_atual     = g_corretor.corsusapl
 let lr_carta.nom_susep_atual = g_corretor.cornomapl
 if g_documento.ramcod = 531 or
    g_documento.ramcod = 31 then
    let lr_carta.mensagem = F_FUNGERAL_ATLULT_MSG(l_atlult)
 else
    let lr_carta.mensagem = l_atlult
 end if

 open window w_ctc09m00 at 7, 5 with form "ctc09m00" attribute (border)

 display by name lr_carta.*
 while int_flag = false
   prompt " " attribute(invisible) for char l_resp
      on key (f17,control-c,interrupt)
         let int_flag = true
   end prompt
 end while
 close window w_ctc09m00
 let int_flag = false

 end function

 #PSI183431 - robson - inicio

#---------------------------------------------#
function ctc09m00_carta_tranferencia(lr_param)
#---------------------------------------------#
   define lr_param      record
          succod        like apbmcortrans.succod
         ,aplnumdig     like apbmcortrans.aplnumdig
         ,itmnumdig     like apbmcortrans.itmnumdig
         ,sgrorg        like rsamcortrans.sgrorg
         ,sgrnumdig     like rsamcortrans.sgrnumdig
         ,tipo          char(01)
         ,ramcod        like rsamseguro.ramcod
         ,corsussol     like apbmcortrans.corsus
         ,corsusapl     like apbmcortrans.corsus
   end record
   define lr_retorno    record
          resultado     smallint
         ,mensagem      char(60)
         ,corsus        like apbmcortrans.corsus
         ,solnom        like apbmcortrans.solnom
         ,cortrftip     like apbmcortrans.cortrftip
         ,atldat        like apbmcortrans.atlult
   end record
   define lr_aux          record
          mensagem       char(50)
         ,resultado       smallint
         ,mensagem1       char(60)
         ,cornom          like gcakcorr.cornom
         ,susep_atual     like apbmcortrans.corsus
         ,nom_susep_atual like gcakcorr.cornom
         ,resp            char(1)
    end record
   define l_msg         char(60)
   initialize lr_retorno to null
   initialize lr_aux to null
   if m_ctc09m00_prep is null or m_ctc09m00_prep <> true then
      call ctc09m00_prep()
   end if
   if lr_param.ramcod is not null and
      lr_param.tipo   is not null and
      (lr_param.tipo = "T" or
       lr_param.tipo = "C") then
      if lr_param.ramcod = 31  or
         lr_param.ramcod = 531 then

         open cctc09m00004 using lr_param.succod
                                ,lr_param.aplnumdig
                                ,lr_param.itmnumdig
         whenever error continue
         fetch cctc09m00004 into lr_retorno.corsus
                                ,lr_retorno.solnom
                                ,lr_retorno.atldat
                                ,lr_retorno.cortrftip
         whenever error stop

         if sqlca.sqlcode = 0 then
            let lr_retorno.resultado = 1
            let lr_aux.mensagem     = f_fungeral_atlult_msg(lr_retorno.atldat)
         else
            if sqlca.sqlcode = notfound then
               let lr_retorno.resultado = 2
               let lr_retorno.mensagem  = "Nao existe carta de transf. de corretagem para essa apolice"
               let l_msg = "Nao existe carta de transf. de corretagem para essa apolice"
               call errorlog(l_msg)
            else
               let lr_retorno.resultado = 3
               let lr_retorno.mensagem  = "Erro", sqlca.sqlcode, " em apbmcortrans"
               let l_msg = " Erro de SELECT - cctc09m00004 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
               call errorlog(l_msg)
               let l_msg = " ctc09m00_carta_tranferencia() / ",lr_param.succod, " / "
                                                              ,lr_param.aplnumdig, " / "
                                                              ,lr_param.itmnumdig
               call errorlog(l_msg)
            end if
         end if
         close cctc09m00004
      else
         open c_ctc09m00_002 using lr_param.sgrorg
                                ,lr_param.sgrnumdig
         whenever error continue
         fetch c_ctc09m00_002 into lr_retorno.corsus
                                ,lr_retorno.solnom
                                ,lr_retorno.cortrftip
                                ,lr_retorno.atldat
         whenever error stop

         if sqlca.sqlcode = 0 then
            let lr_retorno.resultado = 1
            let lr_aux.mensagem = lr_retorno.atldat
         else
            if sqlca.sqlcode = notfound then
               let lr_retorno.resultado = 2
               let lr_retorno.mensagem  = "Nao existe carta de transf de corretagem para este documento"
               let l_msg = "Nao existe carta de transf de corretagem para este documento"
               call errorlog(l_msg)
            else
               let lr_retorno.resultado = 3
               let lr_retorno.mensagem  = "Erro", sqlca.sqlcode, " em rsamcortrans"
               let l_msg = " Erro de SELECT - c_ctc09m00_002 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
               call errorlog(l_msg)
               let l_msg = " ctc09m00_carta_tranferencia() / ",lr_param.sgrorg, " / "
                                                              ,lr_param.sgrnumdig
               call errorlog(l_msg)
            end if
         end if
         close c_ctc09m00_002
      end if

      if lr_retorno.resultado = 1 and
         lr_param.tipo = "T"    then
         call cty00g00_nome_corretor(lr_param.corsusapl)
            returning lr_aux.resultado, lr_aux.mensagem1, lr_aux.cornom
         let lr_aux.susep_atual     = lr_param.corsusapl
         let lr_aux.nom_susep_atual = lr_aux.cornom
         call cty00g00_nome_corretor(lr_retorno.corsus)
            returning lr_aux.resultado, lr_aux.mensagem1, lr_aux.cornom
         open window w_ctc09m00 at 7,5 with form "ctc09m00"
            attribute (border)
         display by name
            lr_aux.susep_atual
           ,lr_aux.nom_susep_atual
           ,lr_retorno.corsus
           ,lr_retorno.solnom
           ,lr_aux.cornom
           ,lr_retorno.cortrftip
           ,lr_aux.mensagem
         while int_flag = false
            prompt " " for char lr_aux.resp
               attribute (invisible)
               on key (F17, control-c, interrupt)
                  let int_flag = true
            end prompt
         end while
         close window w_ctc09m00
         let int_flag = false
      end if
   else
      let lr_retorno.resultado = 3
      let lr_retorno.mensagem  = "Parametros nulos"
      let l_msg = "Parametros nulos"
      call errorlog(l_msg)
   end if
   return lr_retorno.*
end function

 #PSI183431 - robson - fim
