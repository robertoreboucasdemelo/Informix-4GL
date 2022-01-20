#----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                            #
#............................................................................#
# SISTEMA........: PORTO SOCORRO                                             #
# MODULO.........: CTC88M00.4GL                                              #
# ANALISTA RESP..: KEVELLIN                                                  #
# PSI/OSF........:                                                           #
# OBJETIVO.......: ATIVAR/DESATIVAR FROTA EXTRA.                             #
#............................................................................#
# DESENVOLVIMENTO: KEVELLIN                                                  #
# LIBERACAO......:                                                           #
#............................................................................#
#                        * * *  ALTERACOES  * * *                            #
#                                                                            #
# DATA        AUTOR FABRICA   PSI/OSF       ALTERACAO                        #
# ----------  -------------   ------------  -------------------------------- #
# 26/01/2010  Kevellin        253006        Inclusão pop-up Plantão SMS      #
# -------------------------------------------------------------------------- #
# 23/02/2010  Beatriz        253006         Inclusão da função para verificar#
#                                           se está em plantão sms ou não    #
# -------------------------------------------------------------------------- #
# 09/12/2010 Robert Lima      01689         Inclusão da funcao Lista_qrv2    #
# -------------------------------------------------------------------------- #
# 30/12/2010 Robert Lima      03339         Inclusão da funcao               #
#                                           gerEspecialidades                #
# -------------------------------------------------------------------------- #
# 01/04/2011 Robert Lima       PSI04710   Chave d bloqueio pela cidade sede  #
#----------------------------------------------------------------------------#
# 19/08/2011 Celso Yamahaki   CT-14655      Correcao no plantao sms          #
#----------------------------------------------------------------------------#  


 globals "/homedsa/projetos/geral/globals/glct.4gl"

 database porto

 define mr_entrada record
     chave   like datkgeral.grlchv,
     info    like datkgeral.grlinf,
     atvplt  like dbsksmspltprt.atvplt,
     dataatl like datkgeral.atldat,
     horaatl like datkgeral.atlhor,
     func    like datkgeral.atlemp,
     mat     like datkgeral.atlmat,
     geresp  char(01),
     obs     char(100)
 end record

 define mr_plantao record
        smninchor like dbsksmspltprt.smninchor,
        smnfnlhor like dbsksmspltprt.smnfnlhor,
        fdsinchor like dbsksmspltprt.fdsinchor,
        fdsfnlhor like dbsksmspltprt.fdsfnlhor,
        ferinchor like dbsksmspltprt.ferinchor,
        ferfnlhor like dbsksmspltprt.ferfnlhor
 end record

 define m_info like datkgeral.grlchv,
        m_consulta  smallint,
        m_consulta_plantao smallint,
        m_opcao     char(01),
        m_prepare   smallint,
        m_grlchv    char(10),
        m_sit       char(1),
        m_sitplt    char(1)

#---------------------------#
 function ctc88m00_prepare()
#---------------------------#

     define l_sql char(1000)

     let l_sql = " select grlinf ",
                   " from datkgeral ",
                  " where grlchv = ? "

     prepare pcctc88m00_01 from l_sql
     declare cqctc88m00_01 cursor for pcctc88m00_01

     let l_sql = " update datkgeral set (grlinf,atldat,atlhor,atlemp,atlmat) = (?,today,current,?,?) "
               ," where grlchv = ? "
     prepare pcctc88m00_02 from l_sql

     let l_sql = " select atvplt ",
                 "   from dbsksmspltprt "
     prepare pcctc88m00_03 from l_sql
     declare cqctc88m00_03 cursor for pcctc88m00_03

     let l_sql = " select smninchor, ",
                 "        smnfnlhor, ",
                 "        fdsinchor, ",
                 "        fdsfnlhor, ",
                 "        ferinchor, ",
                 "        ferfnlhor  ",
                 "   from dbsksmspltprt "
     prepare pcctc88m00_04 from l_sql
     declare cqctc88m00_04 cursor for pcctc88m00_04

     let l_sql = " update dbsksmspltprt set (atvplt,smninchor,smnfnlhor, ",
                 "                           fdsinchor,fdsfnlhor,ferinchor, ",
                 "                           ferfnlhor,atldat,empcod, ",
                 "                           atlfunmat) = ",
                 " (?,?,?,?,?,?,?,current,?,?) "
     prepare pcctc88m00_05 from l_sql

     let l_sql = " update dbsksmspltprt set (atvplt,atldat,empcod, atlfunmat) = ",
                 "                          (?,current,?,?) "
     prepare pcctc88m00_06 from l_sql


       # SMS no plantão dos socorristas
 let l_sql =  "select atvplt,       ",
              "       smninchor,    ",
              "       smnfnlhor,    ",
              "       fdsinchor,    ",
              "       fdsfnlhor,    ",
              "       ferinchor,    ",
              "       ferfnlhor     ",
              "  from dbsksmspltprt ",
              " where atvplt = 'S'  "
  prepare p_ctc88m00034 from l_sql
  declare c_ctc88m00034 cursor for p_ctc88m00034
  
  
  # para verificar se é feriado
  let l_sql = "select ferdia                        ",
              "  from igfkferiado                   ",
              " where ferdia = ?                    ",
              "   and (fertip = 'N' or fertip = 'P')"

  prepare p_ctc88m00035 from l_sql
  declare c_ctc88m00035 cursor for p_ctc88m00035
  
  let l_sql = "select count(*)          ",
              "  from dpmmqrvsgnprt   ",
              " where dtvdat is null   ",
              "   and dtvfunmat is null"
  prepare p_ctc88m00036 from l_sql              
  declare c_ctc88m00036 cursor for p_ctc88m00036
  
  let l_sql = "select count(*)                                 ",
              "  from datmespctrhst                       ",
              " where atmacnflg = 'S'                         ",
              "   and hstseq = (select max(hstseq) ",
              "                         from datmespctrhst", 
              "                        where espcnfcod = ?) "
  prepare p_ctc88m00037 from l_sql              
  declare c_ctc88m00037 cursor for p_ctc88m00037
  
  
  let l_sql = "select distinct(espcnfcod)",     
              "  from datkesp    "              
  prepare p_ctc88m00038 from l_sql                                                       
  declare c_ctc88m00038 cursor for p_ctc88m00038     
  
  let l_sql = "select count(*)",     
              "  from datkdominio",
              " where cponom = ?"              
  prepare p_ctc88m00040 from l_sql              
  declare c_ctc88m00040 cursor for p_ctc88m00040
                                                                             
  let m_prepare = true                     
  
 end function

#-------------------#
 function ctc88m00()
#-------------------#

     define l_confirma char(01)
     define l_count smallint
     define l_param char(20)

     if  not m_prepare then
         call ctc88m00_prepare()
     end if

     open window w_ctc88m00 at 4,2 with form 'ctc88m00'
       attribute(form line 1)

     #Entra na tela consultando
     if  ctc88m00_entrada_dados("C") then
         let m_consulta = true
     else
         let m_consulta = false
         clear form
     end if

     menu "ORIENTACAO"
         before menu
             hide option all
             
             
             show option "Alterar"
             
             #Verifica se pode mostrar o menu listar segundo qrv
             open c_ctc88m00036    
             fetch c_ctc88m00036 into l_count

             if l_count > 0 then
                if ctc59m01_verifica_usu_qrv2(g_issk.funmat) then 
                   show option "Lista_QRV2"
                end if
             end if
             
             #Verifica se pode mostrar o menu listar blq qra
             let l_count = 0
             let l_param = 'blqcidsedqra'
             open c_ctc88m00040 using l_param   
             fetch c_ctc88m00040 into l_count
             close c_ctc88m00040
    
             if l_count > 0 then
               if ctc59m01_verifica_usu_blq(g_issk.funmat) then 
                   show option "lista_BlqQra"
                end if
             end if
             
             #Verifica se pode mostrar o menu listar blq vtr
             let l_count = 0
             let l_param = 'blqcidsedvtr'
             open c_ctc88m00040 using l_param  
             fetch c_ctc88m00040 into l_count
             close c_ctc88m00040
             
             if l_count > 0 then
               if ctc59m01_verifica_usu_blq(g_issk.funmat) then 
                   show option "lista_BlqVtr"
                end if
             end if                          
             
             show option "Encerra"

         command key ("A") "Alterar" ""
             if m_consulta then
                 call ctc88m00_entrada_dados("A")
                    returning m_consulta
             else
                 error "Nenhuma consulta ativa."
                 next option "Encerra"
             end if
             
         command key ("L") "Lista_QRV2" ""
             call ctc88m00_Lista_QRV2()
             
         command key ("B") "lista_BlqQra" ""
            call ctc88m00_bloqCidSede('blqcidsedqra')   
            
         command key ("V") "lista_BlqVtr" ""
            call ctc88m00_bloqCidSede('blqcidsedvtr') 

         command key ("E",interrupt) "Encerra" "Retorna ao menu anterior"
             exit menu

     end menu

     close window w_ctc88m00

 end function

#----------------------------------------#
function ctc88m00_entrada_dados(l_opcao)
#----------------------------------------#

     define lr_retorno record
         erro smallint,
         msg  char(75)
     end record

     define l_confirma char(01),
            l_opcao    char(01),
            l_status   smallint,
            l_count    smallint
            
     define l_espcnfcod like datkesp.espcnfcod

     initialize m_grlchv to null

     let m_grlchv = 'GER_FROTEX'
     let m_opcao = l_opcao

     let int_flag = false
     initialize lr_retorno.* to null

     if m_opcao = 'C' then

        #CHAMA MÉTODO DE CONSULTA
        call ctc88m00_select()
            returning m_consulta
        if(m_consulta) then
            return true
        else
            return false
        end if

     end if

     if m_opcao = 'A' then

        input by name mr_entrada.info,
                      mr_entrada.atvplt,
                      mr_entrada.geresp

        before field info
           #CHAMA MÉTODO DE CONSULTA
           call ctc88m00_select()
              returning m_consulta
           if(m_consulta = false) then
              exit input
           end if

        after field info
           if mr_entrada.info <> 'S' and mr_entrada.info <> 'N' then
               error "Digite S para Ativar ou N para Desativar"
               next field info
           else

               if (m_sit and mr_entrada.info = 'N') or
                  (m_sit = false and mr_entrada.info = 'S') then

                   call cts08g01("A","S","","CONFIRMA A ALTERACAO ",
                                 "DA SITUACAO DA ",
                                 "FROTA EXTRA?")
                          returning l_confirma

                      if  l_confirma = "S" then
                          if  ctc88m00_update() then
                              error "Alteracao efetuada com sucesso."

                              if ctc88m00_entrada_dados("C") then
                                  return true
                              else
                                  return false
                              end if

                          else
                              error "Alteracao cancelada."
                          end if
                      else

                         if(m_sit) then
                            let mr_entrada.info = "S"
                         else
                            let mr_entrada.info = "N"
                         end if
                         display by name mr_entrada.info

                      end if

               else

                   #SE FOR ENTER
                   if(m_sit) then
                      let mr_entrada.info = "S"
                   else
                      let mr_entrada.info = "N"
                   end if
                   display by name mr_entrada.info

                   next field atvplt

               end if

           end if

           next field atvplt

           before field atvplt
               display by name mr_entrada.atvplt attribute (reverse)
               display by name mr_entrada.atvplt attribute (reverse)

           after field atvplt
               display by name mr_entrada.atvplt

               if fgl_lastkey() = fgl_keyval("down")   or
                  fgl_lastkey() = fgl_keyval("right") then

                  if (m_sitplt) then
                     let mr_entrada.atvplt = "S"
                  else
                     let mr_entrada.atvplt = "N"
                  end if
                  display by name mr_entrada.atvplt

                  exit input

               else

                  if mr_entrada.atvplt <> 'S' and mr_entrada.atvplt <> 'N' then
                      error "Digite S para Ativar ou N para Desativar o Plantao"
                      next field atvplt
                  #end if
                  else

                     if mr_entrada.atvplt is not null and
                        mr_entrada.atvplt = "S" then

                        #CHAMA POPUP PLANTAO
                        call ctc88m00_popup_plantao()
                     end if

                     if mr_entrada.atvplt is not null and
                        mr_entrada.atvplt = "N" then

                        let l_confirma = null
                        call cts08g01("A","S","","CONFIRMA  ",
                                      "A DESATIVACAO DO ",
                                      "PLANTAO POR SMS?")
                            returning l_confirma

                        if  l_confirma = "S" then
                            if  ctc88m00_update_plantao("N") then
                                error "Alteracao efetuada com sucesso."

                                if ctc88m00_entrada_dados("C") then
                                    return true
                                else
                                    return false
                                end if

                            else
                                error "Alteracao cancelada."
                            end if
                        else

                           if(m_sit) then
                              let mr_entrada.info = "S"
                           else
                              let mr_entrada.info = "N"
                           end if
                           display by name mr_entrada.info

                        end if

                     end if

                  end if

                  if (m_sitplt) then
                     let mr_entrada.atvplt = "S"
                  else
                     let mr_entrada.atvplt = "N"
                  end if
                  display by name mr_entrada.atvplt

               end if
               
           before field geresp
              call ctc88m00_gerEspecialidades()
              
           after field geresp
              let l_count = 0
              let mr_entrada.geresp = 'N'
              open c_ctc88m00038               
              foreach c_ctc88m00038 into l_espcnfcod
                 open c_ctc88m00037 using l_espcnfcod
                 fetch c_ctc88m00037 into l_count
                 close c_ctc88m00037
                 
                 if l_count > 0 then
                    let mr_entrada.geresp = 'S'
                    exit foreach
                 else
                    let mr_entrada.geresp = 'N'
                 end if
              end foreach

              display by name mr_entrada.geresp

           on key (interrupt)
              exit input

        end input

     end if

     if  int_flag then
         let int_flag = false
         return false
     else
         return true
     end if

 end function

#---------------------------#
 function ctc88m00_update()
#---------------------------#

    define lr_atl record
           data like datkgeral.atldat,
           hora like datkgeral.atlhor
    end record

    initialize lr_atl to null

    let lr_atl.data = today
    let lr_atl.hora = current

    whenever error continue
    execute pcctc88m00_02 using mr_entrada.info,
                                g_issk.empcod,
                                g_issk.funmat,
                                m_grlchv
    whenever error stop

    if sqlca.sqlcode <> 0 then
        display "Erro UPDATE pcctc88m00_02 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
        return false
    else
        return true
    end if

 end function

 function ctc88m00_popup_plantao()

    initialize mr_plantao.* to null

    open window w_ctc88m01 at 10,23 with form "ctc88m01"
        attribute(border, form line first, message line last - 1)

        #MOSTRAR OS VALORES NA TELA
        initialize mr_plantao.* to null

        clear form

        call ctc88m00_select_plantao()
            returning m_consulta_plantao

        menu "ORIENTACAO"

            command key ("A") "Alterar" ""
                if m_consulta_plantao then
                    if ctc88m00_update_plantao("S") then
                        error "Alteracao efetuada com sucesso."
                        next option "Encerra"
                    else
                        error "Alteracao cancelada. "
                        next option "Encerra"
                    end if
                else
                    error "Nenhuma consulta ativa."
                    next option "Encerra"
                end if

            command key ("E",interrupt) "Encerra" "Sair do pop-up"
                exit menu
                close window w_ctc88m01

        end menu

    let int_flag = false
    close window w_ctc88m01

 end function

 function ctc88m00_update_plantao(l_param)

    define l_param char(01)

    if l_param is not null and l_param = 'S' then

        #initialize mr_plantao.* to null

            input by name mr_plantao.smninchor,
                          mr_plantao.smnfnlhor,
                          mr_plantao.fdsinchor,
                          mr_plantao.fdsfnlhor,
                          mr_plantao.ferinchor,
                          mr_plantao.ferfnlhor

                before field smninchor
                    call ctc88m00_select_plantao()
                        returning m_consulta_plantao
                    if(m_consulta_plantao = false) then
                        exit input
                    end if

                after field smninchor
                    display by name mr_plantao.smninchor

                before field smnfnlhor
                    display by name mr_plantao.smnfnlhor
                    display by name mr_plantao.smnfnlhor

                after field smnfnlhor
                    if mr_plantao.smninchor is null      and
                       mr_plantao.smnfnlhor is not null  then
                       error " Horario de funcionamento invalido!"
                       next field smninchor
                    end if

                    if mr_plantao.smninchor is not null  and
                       mr_plantao.smnfnlhor is null      then
                       error " Horario de funcionamento invalido!"
                       next field smnfnlhor
                    end if

                    if mr_plantao.smninchor is not null  and
                       mr_plantao.smnfnlhor is not null  and
                       mr_plantao.smnfnlhor < mr_plantao.smninchor then
                       error " Horario de funcionamento incorreto!"
                       next field smninchor
                    end if

                    if mr_plantao.smninchor <> "00:00"   and
                       mr_plantao.smninchor is not null  and
                       mr_plantao.smnfnlhor =  "00:00"   then
                       error " Horario de funcionamento incorreto!"
                       next field smninchor
                    end if

                before field fdsinchor
                   display by name mr_plantao.fdsinchor

                after  field fdsinchor
                   display by name mr_plantao.fdsinchor

                before field fdsfnlhor
                   display by name mr_plantao.fdsfnlhor

                after  field fdsfnlhor
                   display by name mr_plantao.fdsfnlhor

                   if (mr_plantao.fdsinchor = "00:00" or mr_plantao.fdsinchor is null) and
                      (mr_plantao.fdsfnlhor = "00:00" or mr_plantao.fdsfnlhor is null) then
                      display by name mr_plantao.fdsinchor
                      display by name mr_plantao.fdsfnlhor
                else
                   if mr_plantao.fdsinchor is null      and
                      mr_plantao.fdsfnlhor is not null  then
                      error " Horario de funcionamento invalido!"
                      next field fdsinchor
                   end if

                   if mr_plantao.fdsinchor is not null  and
                      mr_plantao.fdsfnlhor is null      then
                      error " Horario de funcionamento invalido!"
                      next field fdsfnlhor
                   end if

                   if mr_plantao.fdsinchor is not null  and
                      mr_plantao.fdsfnlhor is not null  and
                      mr_plantao.fdsfnlhor < mr_plantao.fdsinchor then
                      error " Horario de funcionamento incorreto!"
                      next field fdsinchor
                   end if
                end if

                if mr_plantao.fdsinchor <> "00:00"   and
                   mr_plantao.fdsinchor is not null  and
                   mr_plantao.fdsfnlhor =  "00:00"   then
                   error " Horario de funcionamento incorreto!"
                   next field fdsinchor
                end if

                before field ferinchor
                   display by name mr_plantao.ferinchor

                after  field ferinchor
                   display by name mr_plantao.ferinchor

                before field ferfnlhor
                   display by name mr_plantao.ferfnlhor

                after  field ferfnlhor
                   display by name mr_plantao.ferfnlhor

                   if fgl_lastkey() = fgl_keyval("up")   or
                      fgl_lastkey() = fgl_keyval("left") then
                      next field ferinchor
                   end if

                   if (mr_plantao.ferinchor = "00:00" or mr_plantao.ferinchor is null) and
                      (mr_plantao.ferfnlhor = "00:00" or mr_plantao.ferfnlhor is null) then
                      display by name mr_plantao.ferinchor
                      display by name mr_plantao.ferfnlhor
                   else
                      if mr_plantao.ferinchor is null      and
                         mr_plantao.ferfnlhor is not null  then
                         error " Horario de funcionamento invalido!"
                         next field ferinchor
                      end if

                      if mr_plantao.ferinchor is not null  and
                         mr_plantao.ferfnlhor is null      then
                         error " Horario de funcionamento invalido!"
                         next field ferfnlhor
                      end if

                      if mr_plantao.ferinchor is not null  and
                         mr_plantao.ferfnlhor is not null  and
                         mr_plantao.ferfnlhor < mr_plantao.ferinchor then
                         error " Horario de funcionamento incorreto!"
                         next field ferinchor
                      end if

                      if mr_plantao.ferinchor <> "00:00"   and
                         mr_plantao.ferinchor is not null  and
                         mr_plantao.ferfnlhor =  "00:00"   then
                         error " Horario de funcionamento incorreto!"
                         next field ferinchor
                      end if
                   end if

                   whenever error continue
                   execute pcctc88m00_05 using mr_entrada.atvplt,
                                               mr_plantao.smninchor,
                                               mr_plantao.smnfnlhor,
                                               mr_plantao.fdsinchor,
                                               mr_plantao.fdsfnlhor,
                                               mr_plantao.ferinchor,
                                               mr_plantao.ferfnlhor,
                                               g_issk.empcod,
                                               g_issk.funmat
                   whenever error stop

                   if sqlca.sqlcode <> 0 then
                       display "Erro UPDATE pcctc88m00_05 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]

                       let int_flag = false
                       return false
                   else
                       let int_flag = false
                       let m_sitplt = true
                       return true
                   end if


                on key (interrupt)
                    exit input

            end input

    end if

    if l_param is not null and l_param = 'N' then

        whenever error continue
        execute pcctc88m00_06 using mr_entrada.atvplt,
                                    g_issk.empcod,
                                    g_issk.funmat
        whenever error stop

        if sqlca.sqlcode <> 0 then
            display "Erro UPDATE pcctc88m00_06 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
            return false
        else
            error "Alteração efetuada com sucesso."
            let int_flag = false
            let m_sitplt = false
            return true
        end if

    end if
    #let int_flag = false
    #close window w_ctc88m01

    return false

 end function

 function ctc88m00_select()

    define l_count smallint
    define l_espcnfcod like datkesp.espcnfcod
    define l_param char(20)
    
    initialize mr_entrada.* to null
    initialize m_sit, m_sitplt to null
    let l_count = 0
    
    clear form

    open cqctc88m00_01 using m_grlchv

    whenever error continue
    fetch cqctc88m00_01 into mr_entrada.info

    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          error "Nao foi encontrado registro para o parametro = ", mr_entrada.info
       else
          error "Erro SELECT cqctc88m00_01 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
          return false
       end if
       exit program(1)
    end if

    close cqctc88m00_01

    display by name mr_entrada.info

    if mr_entrada.info = 'S' then
        let mr_entrada.obs = 'A FROTA EXTRA ESTA ATIVADA'
        let m_sit = true
    else
        let mr_entrada.obs = 'A FROTA EXTRA ESTA DESATIVADA'
        let m_sit = false
    end if

    display by name mr_entrada.obs

    #PSI PLANTAO SMS
    open cqctc88m00_03

    whenever error continue
    fetch cqctc88m00_03 into mr_entrada.atvplt

    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          error "Nao foi encontrado registro para o plantao sms "
       else
          error "Erro SELECT cqctc88m00_03 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
          return false
       end if
       exit program(1)
    end if

    close cqctc88m00_03
    
    open c_ctc88m00036    
    fetch c_ctc88m00036 into l_count
    close c_ctc88m00036
    
    if l_count > 0 then
      display "S" to qrv2
    else
      display "N" to qrv2
    end if
    
    let l_count = 0
    let mr_entrada.geresp = 'N'
    open c_ctc88m00038
    foreach c_ctc88m00038 into l_espcnfcod
       open c_ctc88m00037 using l_espcnfcod
       fetch c_ctc88m00037 into l_count
       close c_ctc88m00037
       
       if l_count > 0 then
          let mr_entrada.geresp = 'S'
          exit foreach
       else
          let mr_entrada.geresp = 'N'
       end if
    end foreach
    
    display by name mr_entrada.geresp
    display by name mr_entrada.atvplt

    if mr_entrada.atvplt = 'S' then
        let m_sitplt = true
    else
        let m_sitplt = false
    end if
    
    let l_count = 0
    let l_param = 'blqcidsedqra'
    open c_ctc88m00040 using l_param   
    fetch c_ctc88m00040 into l_count
    close c_ctc88m00040
    
    if l_count > 0 then
      display "N" to blqqra
    else
      display "S" to blqqra
    end if
    
    let l_count = 0
    let l_param = 'blqcidsedvtr'  
    open c_ctc88m00040 using l_param   
    fetch c_ctc88m00040 into l_count
    close c_ctc88m00040
    
    if l_count > 0 then
      display "N" to blqvtr
    else
      display "S" to blqvtr
    end if

    return true

 end function

 function ctc88m00_select_plantao()

    initialize mr_plantao.* to null

    open cqctc88m00_04

    whenever error continue
    fetch cqctc88m00_04 into mr_plantao.smninchor,
                             mr_plantao.smnfnlhor,
                             mr_plantao.fdsinchor,
                             mr_plantao.fdsfnlhor,
                             mr_plantao.ferinchor,
                             mr_plantao.ferfnlhor

    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          error "Nao foi encontrado registro para o plantao sms "
       else
          error "Erro SELECT cqctc88m00_04 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
          return false
       end if
       exit program(1)
    end if

    close cqctc88m00_04

    display by name mr_plantao.smninchor,
                    mr_plantao.smnfnlhor,
                    mr_plantao.fdsinchor,
                    mr_plantao.fdsfnlhor,
                    mr_plantao.ferinchor,
                    mr_plantao.ferfnlhor

    return true

 end function

#Funcão para envio de SMS(Plantão) para o celular cadastrado na viatura
#--------------------------------
function ctc88m00_plantao_sms()
#--------------------------------

 define ctc88m00_plthora  record
        atvplt            like dbsksmspltprt.atvplt    ,
        smninchor         like dbsksmspltprt.smninchor ,
        smnfnlhor         like dbsksmspltprt.smnfnlhor ,
        fdsinchor         like dbsksmspltprt.fdsinchor ,
        fdsfnlhor         like dbsksmspltprt.fdsfnlhor ,
        ferinchor         like dbsksmspltprt.ferinchor ,
        ferfnlhor         like dbsksmspltprt.ferfnlhor
 end record

 define l_data_atual     date,
        l_hora_atual     datetime hour to minute,
        l_cod_dia        char (10),
        l_celular        char(13),
        l_ferdia         date,
        envia_sms        smallint

 call cts40g03_data_hora_banco(2)
         returning l_data_atual,
                   l_hora_atual

  let l_cod_dia = weekday(l_data_atual)

 if  not m_prepare then
     call ctc88m00_prepare()
 end if
 #para buscar o horario que não é para enviar SMS para o Plantão
 open c_ctc88m00034
 whenever error continue
 
 fetch c_ctc88m00034 into ctc88m00_plthora.atvplt    ,
                          ctc88m00_plthora.smninchor ,
                          ctc88m00_plthora.smnfnlhor ,
                          ctc88m00_plthora.fdsinchor ,
                          ctc88m00_plthora.fdsfnlhor ,
                          ctc88m00_plthora.ferinchor ,
                          ctc88m00_plthora.ferfnlhor  
 whenever error stop
 close c_ctc88m00034 
 
 if ctc88m00_plthora.atvplt = 'S' then
    case l_cod_dia

         when 0
              # verifica se a hora não está no periodo que não é pra mandar SMS
              if l_hora_atual < ctc88m00_plthora.fdsinchor  or
                 l_hora_atual > ctc88m00_plthora.fdsfnlhor  then
                    let envia_sms = true
                    return envia_sms
              end if

         when 6
              # verifica se a hora não está no periodo que não é pra mandar SMS
              if l_hora_atual < ctc88m00_plthora.fdsinchor  or
                 l_hora_atual > ctc88m00_plthora.fdsfnlhor  then
                    let envia_sms = true
                    return envia_sms
              end if

         otherwise
              
               open c_ctc88m00035 using l_data_atual
               whenever error continue
               fetch c_ctc88m00035 into l_ferdia
               whenever error stop
               close c_ctc88m00035
               
              if l_ferdia is not null and l_ferdia <> '31/12/1899' then
                 if ctc88m00_plthora.ferinchor = ctc88m00_plthora.ferfnlhor then
                    let envia_sms = true 
                    return envia_sms     
                 else
                    # verifica se a hora não está no periodo que não é pra mandar SMS
                    if l_hora_atual <= ctc88m00_plthora.ferinchor  or
                       l_hora_atual >= ctc88m00_plthora.ferfnlhor  then
                         let envia_sms = true 
                         return envia_sms     
                    end if
                 end if
              else
                 # verifica se a hora não está no periodo que não é pra mandar SMS
                 if l_hora_atual <= ctc88m00_plthora.smninchor  or
                    l_hora_atual >= ctc88m00_plthora.smnfnlhor  then
                       let envia_sms = true
                       return envia_sms
                       
                 end if
              end if
    end case
 end if

  return false

end function

#Função que lista as cidades sedes com qrv2 ativado
#--------------------------------
function ctc88m00_Lista_QRV2()  
#--------------------------------

define lista_qrv array[500] of record
   aux           char(1),
   cidnom        like glakcid.cidnom,
   ufdcod        like glakcid.ufdcod,
   cidsedqrvseq  like dpmmqrvsgnprt.cidsedqrvseq,
   atvdat        like dpmmqrvsgnprt.atvdat      ,
   atvhor        like dpmmqrvsgnprt.atvhor      ,
   funmatass     char(40)
end record

define l_indice        smallint
define l_cidsedcod     like dpmmqrvsgnprt.cidsedcod,
       l_cidsedqrvseq  like dpmmqrvsgnprt.cidsedqrvseq,
       l_arr_curr      smallint,
       l_scr_curr      smallint,
       l_funmat        like dpmmqrvsgnprt.atvfunmat
       
 declare cqctc88m00_37 cursor for 
   select cidsedcod, cidsedqrvseq
     from dpmmqrvsgnprt
    where dtvdat is null
      and dtvfunmat is null
 
 let l_indice = 1
 
 foreach cqctc88m00_37 into l_cidsedcod,
                            l_cidsedqrvseq
     
     select cidnom,ufdcod,cidsedqrvseq,atvdat,atvhor,atvfunmat
       into lista_qrv[l_indice].cidnom       ,
            lista_qrv[l_indice].ufdcod       ,
            lista_qrv[l_indice].cidsedqrvseq ,
            lista_qrv[l_indice].atvdat       ,
            lista_qrv[l_indice].atvhor       ,
            l_funmat
       from glakcid a, dpmmqrvsgnprt b                      
      where a.cidcod = b.cidsedcod
        and a.cidcod = l_cidsedcod
        and b.cidsedqrvseq = l_cidsedqrvseq 
      
      call ctc88m00_func(1,g_issk.funmat)
         returning lista_qrv[l_indice].funmatass 
                                  
     let l_indice = l_indice + 1
 end foreach
 
 open window w_ctc88m00a at 4,2 with form 'ctc88m00a'
       attribute(form line 1)
 
 call set_count(l_indice-1)
 
 while true
     options
             INSERT KEY control-q,
             DELETE KEY control-c
     input array lista_qrv without defaults from s_ctc88m00a.*
                      
         before row
             let l_arr_curr = arr_curr()
             let l_scr_curr = scr_line()
             
             if l_arr_curr <= l_indice-1 then
                let lista_qrv[l_arr_curr].aux = ">"                     
                display lista_qrv[l_arr_curr].* to                      
                        s_ctc88m00a[l_scr_curr].* attribute (reverse)
             else
                exit input
             end if
                     
         after row                            
             let l_arr_curr = arr_curr()      
             let l_scr_curr = scr_line()      
             let lista_qrv[l_arr_curr].aux = ""  
             display lista_qrv[l_arr_curr].* to  
                     s_ctc88m00a[l_scr_curr].*
     
         on key(control-c,interrupt)
             initialize l_indice to null 
             exit input
             
     end input
     
     if int_flag then
        let int_flag = false
        exit while
     end if
     
 end while
 close window w_ctc88m00a
 
end function


#---------------------------------------------------------
 function ctc88m00_func(param)
#---------------------------------------------------------
                                                          
 define param         record                              
    empcod            like isskfunc.empcod,               
    funmat            like isskfunc.funmat                
 end record                                               
                                                          
 define ws            record                              
    funnom            like isskfunc.funnom                
 end record                                               
                                                          
                                                          
 initialize ws.*    to null                               
                                                          
 select funnom                                            
   into ws.funnom                                         
   from isskfunc                                          
  where isskfunc.empcod = param.empcod                    
    and isskfunc.funmat = param.funmat                    
                                                          
 return ws.funnom                                         
                                                          
end function         

#---------------------------------------------------------
 function ctc88m00_gerEspecialidades()
#---------------------------------------------------------

 define gerEspecial array[500] of record
     navega         char(1),
     espcnfcod      like datmespctrhst.espcnfcod,
     hstseq         like datmespctrhst.hstseq,
     vcldtbgrpdes   char(20),
     cpodes         char(50),
     asitipdes      char(20),
     atmacnflg      char(3),
     funnom         char(100),
     atldat         date,
     atlhor         datetime hour to second
 end record
 
 define l_indice        smallint,
        l_espcnfcod     like datmespctrhst.espcnfcod,
        l_vcldtbgrpcod  like datkvcldtbgrp.vcldtbgrpcod,
        l_socvcltip     like datkesp.socvcltip,
        l_asitipcod     like datkasitip.asitipcod,
        l_fucmat        decimal(6,0),
        l_cademp        decimal(2,0),
        l_cadusrtip     char(1),
        l_resultado     smallint,
        l_arr_curr      smallint,
        l_scr_curr      smallint,
        l_mensagem      char(100)
    
  #---------[INICIALIZANDO AS VARIAVEIS]------------------
  let l_indice = 1
  for l_indice=1 to 500
      initialize gerEspecial[l_indice].* to null
  end for
    
  let l_indice = 1
  
  #Busca as configurações cadatradas  e popula o array  
  declare cqctc88m00_38 cursor for
    select distinct(a.espcnfcod)
      from datmespctrhst a, datkesp b
     where a.espcnfcod = b.espcnfcod

  foreach cqctc88m00_38 into l_espcnfcod
      whenever error continue
           select b.espcnfcod,
                  a.hstseq,
                  b.vcldtbgrpcod,
                  b.socvcltip   ,
                  b.asitipcod   ,
                  a.atlmat    ,
                  a.atlemp    ,
                  a.atlusrtip ,
                  a.atldat    ,
                  a.atlhor    ,
                  a.atmacnflg
             into gerEspecial[l_indice].espcnfcod,
                  gerEspecial[l_indice].hstseq,
                  l_vcldtbgrpcod    ,
                  l_socvcltip       ,
                  l_asitipcod       ,
                  l_fucmat          ,
                  l_cademp          ,
                  l_cadusrtip       ,
                  gerEspecial[l_indice].atldat,
                  gerEspecial[l_indice].atlhor,
                  gerEspecial[l_indice].atmacnflg
             from datmespctrhst a, datkesp b
            where a.espcnfcod = b.espcnfcod
              and a.espcnfcod = l_espcnfcod
              and a.hstseq =(select max(hstseq)
                             from datmespctrhst
                            where espcnfcod = l_espcnfcod)
           
           if sqlca.sqlcode = notfound then
              error "NENHUM CADASTRO ENCONTRADO"
              return
           end if
      whenever error stop 
      
      #Busca a descrição do grupo de distribuição, assistencia e tipo de viatura    
      call ctc00m23_obter_des_ges_espe(l_vcldtbgrpcod,
                                       l_asitipcod,
                                       l_socvcltip)
           returning l_resultado,
                     gerEspecial[l_indice].vcldtbgrpdes,                     
                     gerEspecial[l_indice].cpodes,
                     gerEspecial[l_indice].asitipdes
      
      
      if l_resultado <> 0 then
         let l_indice = 1
         for l_indice=1 to 500
             initialize gerEspecial[l_indice].* to null
         end for
         error "ERRO AO BUSCAR DADOS"
         clear form
         return
      end if
      
      #Busca o nome do funcionario
      call ctc00m22_func(l_cademp, l_fucmat)
         returning gerEspecial[l_indice].funnom
                                          
      let gerEspecial[l_indice].funnom = "POR: ",gerEspecial[l_indice].funnom clipped
      
      #Altera o valor da flag de 'N/S' para 'OFF/ON'
      if gerEspecial[l_indice].atmacnflg = 'N' then
         let gerEspecial[l_indice].atmacnflg = 'OFF'
      else
         let gerEspecial[l_indice].atmacnflg = 'ON'
      end if
      
      let l_indice = l_indice + 1
           
  end foreach 
  
  open window w_ctc88m02 at 7,2 with form 'ctc88m02'
       attribute(form line 1,border)
 
  call set_count(l_indice-1)
 
 if l_indice = 1 then
    close window w_ctc88m02
    error "NAO EXISTEM CONFIGURACOES CADASTRADAS"
    return   
 end if
 
 while true

     options
             INSERT KEY control-q,
             DELETE KEY control-c
     input array gerEspecial without defaults from s_ctc88m02.*
                      
         before row 
             let l_arr_curr = arr_curr()
             let l_scr_curr = scr_line()
             
             if l_arr_curr <= l_indice-1 then
                let gerEspecial[l_arr_curr].navega = ">"                     
                display gerEspecial[l_arr_curr].* to                      
                        s_ctc88m02[l_scr_curr].* attribute (reverse)
             else
                exit input
             end if
                     
         after row                            
             let l_arr_curr = arr_curr()      
             let l_scr_curr = scr_line()      
             let gerEspecial[l_arr_curr].navega = ""  
             display gerEspecial[l_arr_curr].* to  
                     s_ctc88m02[l_scr_curr].*
                     
         on key(f5) #Altera a flag 'OFF/ON'
            call ctc00m23_altera_chave(gerEspecial[l_arr_curr].espcnfcod,
                                       gerEspecial[l_arr_curr].hstseq,
                                       gerEspecial[l_arr_curr].atmacnflg)
                 returning l_resultado,
                           gerEspecial[l_arr_curr].atmacnflg,
                           gerEspecial[l_arr_curr].hstseq
            
            if l_resultado = 0 then
               display gerEspecial[l_arr_curr].atmacnflg to
                       s_ctc88m02[l_scr_curr].atmacnflg  attribute (reverse)
                       
               display gerEspecial[l_arr_curr].hstseq to 
                       s_ctc88m02[l_scr_curr].hstseq  attribute (reverse)
            end if
     
         on key(control-c,interrupt)
             initialize l_indice to null 
             exit input
             
     end input
     
     if int_flag then
        let int_flag = false
        exit while
     end if
 end while
 
 close window w_ctc88m02
 

end function

#---------------------------------------------------------
function ctc88m00_bloqCidSede(param)                    
#---------------------------------------------------------

 define param record
     cponom    like datkdominio.cponom
 end record
 
 define bloqCidSede array[500] of record
    navega    char(1),
    cidnom    like glakcid.cidnom,
    ufdcod    like glakcid.ufdcod,
    atldat    char(10),
    funmatass char(40)
 end record
 
 define ctc88m00_blq record
    cpodes like datkdominio.cpodes,
    cpocod like datkdominio.cpocod,
    atlult like datkdominio.atlult  
 end record
 
 define l_indice smallint
 define l_funmat like isskfunc.funmat,
        l_arr_curr smallint,
        l_scr_curr smallint,
        l_aux char(3)
 
 #---------[INICIALIZANDO AS VARIAVEIS]------------------
  let l_indice = 1
  for l_indice=1 to 500
      initialize bloqCidSede[l_indice].* to null
  end for
    
  let l_indice = 1

  whenever error continue
  declare cqctc88m00_39 cursor for
     select cpodes,    
            cpocod,
            atlult                
     from datkdominio
    where cponom = param.cponom       
   order by cpocod
  
  foreach cqctc88m00_39 into ctc88m00_blq.cpodes,
                             ctc88m00_blq.cpocod,
                             ctc88m00_blq.atlult         
       
      select cidnom, ufdcod
       into bloqCidSede[l_indice].cidnom,
            bloqCidSede[l_indice].ufdcod
       from glakcid
      where cidcod = ctc88m00_blq.cpodes
     
      let bloqCidSede[l_indice].atldat = ctc88m00_blq.atlult[5,6],'/',
                                         ctc88m00_blq.atlult[3,4],'/20',
                                         ctc88m00_blq.atlult[1,2]

      let l_funmat = ctc88m00_blq.atlult[15,19]
                   
      call ctc88m00_func(1,l_funmat)
         returning bloqCidSede[l_indice].funmatass 
      
      let l_indice = l_indice + 1
      
  end foreach
   
  whenever error stop
  
  open window w_ctc88m00b at 4,2 with form 'ctc88m00b'
       attribute(form line 1,border)
  
  call set_count(l_indice-1)
 
  if l_indice = 1 then
     close window w_ctc88m00b
     error "NAO EXISTEM CONFIGURACOES CADASTRADAS"
     return   
  end if
  
  
  let l_aux = upshift(param.cponom[10,12])
  display l_aux to texto
  
  while true
  
      options
              INSERT KEY control-q,
              DELETE KEY control-c
              
      input array bloqCidSede without defaults from s_ctc88m00b.*
                       
          before row 
              let l_arr_curr = arr_curr()
              let l_scr_curr = scr_line()
              
              if l_arr_curr <= l_indice-1 then
                 let bloqCidSede[l_arr_curr].navega = ">"                     
                 display bloqCidSede[l_arr_curr].* to                      
                         s_ctc88m00b[l_scr_curr].* attribute (reverse)
              else
                 exit input
              end if
                      
          after row                            
              let l_arr_curr = arr_curr()      
              let l_scr_curr = scr_line()      
              let bloqCidSede[l_arr_curr].navega = ""  
              display bloqCidSede[l_arr_curr].* to  
                      s_ctc88m00b[l_scr_curr].*                               

          on key(control-c,interrupt)
              initialize l_indice to null 
              exit input
              
      end input
      
      if int_flag then
         let int_flag = false
         exit while
      end if
  end while  
  
  close window w_ctc88m00b
  
end function
  
  
  