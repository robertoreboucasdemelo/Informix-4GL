############################################################################### 
# Nome do Modulo: CTC59M01                                           Wagner   # 
#                                                                    Raji     # 
# Cidades x Cidade Sede                                              Jul/2002 # 
############################################################################### 
#                                                                             # 
#                   * * * Alteracoes * * *                                    # 
#                                                                             # 
# Data       Autor Fabrica     Origem     Alteracao                           # 
# ---------- ----------------- ---------- ------------------------------------# 
# 28/01/2005 Carlos, Meta      PSI190241  Incluido campo indicativo de        # 
#                                         alerta na Cidade sede.              # 
#-----------------------------------------------------------------------------# 
# 10/11/2006 Priscila          AS         Chamar funcao para verificar se eh  # 
#                                         cidade sede                         # 
#-----------------------------------------------------------------------------# 
# 29/01/2008 Norton, Meta      psi214566  Inclusao de Funcao para exibir      # 
#                                         estado de emergencia                # 
#-----------------------------------------------------------------------------# 
# 08/05/2009 Kevellin          PSI241733  Implementações e função             # 
#                                         separar_servicos                    # 
#-----------------------------------------------------------------------------# 
# 09/02/2010 Adriano           PSI252891  Flag de indexacao por Bairro e      #  
#                                         Sub-bairro                          #  
#-----------------------------------------------------------------------------#  
# 01/04/2011 Robert Lima       PSI04710   Chave d bloqueio pela cidade sede   #
#-----------------------------------------------------------------------------# 
# 13/01/2012 Jose Kurihara     PSI-2011-21476-PR  bloqueio veiculo sem seguro #
#                                                 de uma cidade sede          #
#-----------------------------------------------------------------------------# 
 
database porto 
 
globals '/homedsa/projetos/geral/globals/glct.4gl' 
 
define m_cid_esp char(1), 
       m_toda_sed char(1), 
       m_arr_aux integer 
 
define m_ctc59m01_2 array[40] of record 
   atnflg        char(1), 
   cidnom        like glakcid.cidnom, 
   ufdcod        like glakcid.ufdcod, 
   cidcod        like datrcidsed.cidcod 
end record 
 
#-------------------------------------------------------------- 
 function ctc59m01() 
#-------------------------------------------------------------- 
 
 define d_ctc59m01   record 
    cidsedcod        like datrcidsed.cidsedcod, 
    ufdsedcod        like glakcid.ufdcod, 
    cidsednom        like glakcid.cidnom, 
    brrtipflg        char(1) 
 end record 
 
 initialize d_ctc59m01.* to null 
 
 let int_flag  = false 
 
 open window ctc59m01 at 06,02 with form "ctc59m01" 
      attribute (form line 1,comment line last - 1) 
 
 message " (F17)Abandona" 
 
 while true 
 
    input by name d_ctc59m01.cidsednom, 
                  d_ctc59m01.ufdsedcod  without defaults 
 
       before field cidsednom 
              #VERIFICA SE ESTADO DE ATENÇÃO ESTÁ SEPARADA - TELAS DO RADIO AUTO E RE 
              call ctc59m01_alertasep(); 
 
              display by name d_ctc59m01.cidsednom attribute (reverse) 
 
       after  field cidsednom 
          display by name d_ctc59m01.cidsednom 
 
          if d_ctc59m01.cidsednom is null  then 
             error " Cidade deve ser informada!" 
             next field ufdsedcod 
          end if 
 
       before field ufdsedcod 
          display by name d_ctc59m01.ufdsedcod attribute (reverse) 
 
       after  field ufdsedcod 
          display by name d_ctc59m01.ufdsedcod 
 
          if fgl_lastkey() <> fgl_keyval("up")   and 
             fgl_lastkey() <> fgl_keyval("left") then 
 
             if d_ctc59m01.ufdsedcod is null  then 
                error " Sigla da unidade da federacao deve ser informada!" 
                next field ufdsedcod 
             end if 
 
             #-------------------------------------------------------------- 
             # Verifica se UF esta cadastrada 
             #-------------------------------------------------------------- 
             select ufdcod 
               from glakest 
              where ufdcod = d_ctc59m01.ufdsedcod 
 
             if sqlca.sqlcode = notfound then 
                error " Unidade federativa nao cadastrada!" 
                next field ufdsedcod 
             end if 
 
             if d_ctc59m01.ufdsedcod = d_ctc59m01.cidsednom  then 
                select ufdnom 
                          into d_ctc59m01.cidsednom 
                  from glakest 
                         where ufdcod = d_ctc59m01.cidsednom 
 
                if sqlca.sqlcode = 0  then 
                   display by name d_ctc59m01.cidsednom 
                else 
                   let d_ctc59m01.cidsednom = d_ctc59m01.ufdsedcod 
                end if 
             end if 
 
             #-------------------------------------------------------------- 
             # Verifica se a cidade esta cadastrada 
             #-------------------------------------------------------------- 
             declare c_glakcid cursor for 
                select cidcod 
                  from glakcid 
                 where cidnom = d_ctc59m01.cidsednom 
                   and ufdcod = d_ctc59m01.ufdsedcod 
 
             open  c_glakcid 
             fetch c_glakcid  into  d_ctc59m01.cidsedcod 
 
             if sqlca.sqlcode  =  100   then 
                call cts06g04(d_ctc59m01.cidsednom, d_ctc59m01.ufdsedcod) 
                     returning d_ctc59m01.cidsedcod, 
                               d_ctc59m01.cidsednom, 
                               d_ctc59m01.ufdsedcod 
 
                if d_ctc59m01.cidsednom  is null   then 
                   error " Cidade deve ser informada!" 
                end if 
                next field cidsednom 
             end if 
             close c_glakcid 
          end if 
 
          #-------------------------------------------------------------- 
          # Verifica se a cidade esta em alerta 
          #-------------------------------------------------------------- 
 
          call ctc59m01_alerta(d_ctc59m01.cidsedcod) 
 
          call ctc59m01_alertasep() 
          
          call ctc59m01_qrv2(d_ctc59m01.cidsedcod,0)
                   
          if ctc59m01_verifica_usu_blq(g_issk.funmat) then                    
             if ctc59m01_blqcidsed(d_ctc59m01.cidsedcod,'blqcidsedqra',0) then  # bloqueio seg vida                
                display "F3:SEM BLOQ QRA" to blqqraflg             
             else
                display "F3:BLOQ QRA OK" to blqqraflg
             end if
             
             if ctc59m01_blqcidsed(d_ctc59m01.cidsedcod,'blqcidsedvtr',0) then  # bloqueio vistoria
                display "F4:SEM BLOQ VTR" to blqvtrflg
             else
                display "F4:BLOQ VTR OK" to blqvtrflg 
             end if
             if ctc59m01_blqcidsed(d_ctc59m01.cidsedcod,'blqcidsedsegvtr',0) then  # bloqueio veiculo sem seguro
                display "^+B:BLQ VTR SEG  OK" to blqvclsegflg
             else
                display "^+B:SEM BLQ VTR SEG" to blqvclsegflg 
             end if
          end if 

          call ctc59m01_cidades(d_ctc59m01.cidsedcod)                     
          
       on key (interrupt) 
          exit input 
 
    end input 
 
    if int_flag   then 
       exit while 
    end if 
 
 end while 
 
 close window ctc59m01 
 let int_flag = false 
 
end function  #  ctc59m01 
 
#-------------------------------------------------------------- 
 function ctc59m01_cidades(param) 
#-------------------------------------------------------------- 
 
 define param        record 
    cidsedcod        like datrcidsed.cidsedcod 
 end record 
 
 define a_ctc59m01   array[40] of record 
    cidnom        like glakcid.cidnom, 
    ufdcod        like glakcid.ufdcod, 
    cidcod        like datrcidsed.cidcod 
 end record 
 
 define ws           record 
    cidcod           like glakcid.cidcod, 
    atlmat           like dammaleastcvn.atlmat, 
    atlemp           like dammaleastcvn.atlemp, 
    atlusrtip        like dammaleastcvn.atlusrtip, 
    confirma         char (01), 
    operacao         char (01), 
    atencaodes       char(20), 
    atnflg           char(1), 
    brrtipflg        like datrcidsed.brrtipflg, 
    brrtipflgdes     char(3),
    txtbrrtip        char(60)
 end record 
 
 define arr_aux      integer 
 define scr_aux      integer 
 define x            smallint 
 
 define l_cidade_sede like glakcid.cidnom 
 define l_cidsedcod   like glakcid.cidcod    #AS 10/11 
 define l_ufdcod      like glakcid.ufdcod    #AS 10/11 
 define l_cidflg smallint 
 
 define l_ret smallint            #AS 10/11 
 define l_mensagem char(50)       #AS 10/11 
 
 define l_opcao decimal(8,0) 
  
 define l_brrtipflg like datrcidsed.brrtipflg 
 
 define l_opcoe char(1000),
        prompt_key char(1)
 
 initialize a_ctc59m01  to null 
 initialize m_ctc59m01_2 to null 
 initialize ws.*        to null 
 let m_cid_esp = null 
 let m_toda_sed = null 
 let arr_aux = 1 
 let l_cidflg = 1 
 let l_opcao = 0 
 let l_brrtipflg = 'N' 
 
 declare c_ctc59m01 cursor for 
  select cidcod, atnflg, brrtipflg 
    from datrcidsed 
   where cidsedcod  = param.cidsedcod 
 
 foreach c_ctc59m01 into a_ctc59m01[arr_aux].cidcod, ws.atnflg, l_brrtipflg 
 
    {if arr_aux = 1 then 
       case ws.atnflg 
          when 'S' 
             let ws.atencaodes = 'Estado de ATENCAO' 
          otherwise 
             let ws.atencaodes = 'Operacao NORMAL' 
       end case 
       display by name ws.atencaodes 
    end if} 
 
    let a_ctc59m01[arr_aux].ufdcod = "NF" 
    let a_ctc59m01[arr_aux].cidnom = "NAO CADASTRADO!" 
    select ufdcod, 
           cidnom 
      into a_ctc59m01[arr_aux].ufdcod, 
           a_ctc59m01[arr_aux].cidnom 
      from glakcid 
     where cidcod = a_ctc59m01[arr_aux].cidcod 
 
    if param.cidsedcod = a_ctc59m01[arr_aux].cidcod then 
        if l_brrtipflg is null then 
            let ws.brrtipflg = 'N' 
        else 
            let ws.brrtipflg = l_brrtipflg 
        end if 
    end if 
     
    let arr_aux = arr_aux + 1 
    if arr_aux > 40 then 
       error " Limite excedido, cidade sede com mais de 40 cidades" 
       exit foreach 
    end if 
 
 end foreach 
 
 call set_count(arr_aux-1) 
 options comment line last - 1 
 
 let l_opcoe = "F1-Inc,F2-Exc,F6-Separa,F7-TipVtr,F8-TipAst,F9-GrpNtz"
 if ctc59m01_verifica_usu(g_issk.funmat) then    
    # message "F1-Inc,F2-Exc,F6-Separa,F7-TipVtr,F8-TipAst,F9-GrpNtz,F10-IdxBrr" 
    let l_opcoe = l_opcoe clipped, ",F10-IdxBrr"
 else
    # message "F1-Inc,F2-Exc,F6-Separa,F7-TipVtr,F8-TipAst,F9-GrpNtz" 
 end if
 
 if ctc59m01_verifica_usu_qrv2(g_issk.funmat) then    
    # message "F1-Inc,F2-Exc,F6-Separa,F7-TipVtr,F8-TipAst,F9-GrpNtz,F10-IdxBrr"
    let l_opcoe = l_opcoe clipped, ",F5-QRV2" 
 else
    # message "F1-Inclui,F2-Exclui,F6-Separa,F7-Tip Vtr,F8-Tip Ast,F9-Grp Ntz" 
 end if 
 
 message l_opcoe clipped
 
 while 2 
 
    let int_flag = false 
 
    options
       next key control-n,
       previous key control-p,
       insert key f1,
       delete key f2
          
    input array a_ctc59m01 without defaults from s_ctc59m01.*             
       
       before row 
          let arr_aux = arr_curr() 
          let scr_aux = scr_line() 
          if ctc59m01_verifica_usu(g_issk.funmat) then
              let ws.txtbrrtip = '(F10)Indexa por Bairro e Sub-Bairro para as cidades da sede?'
              if ws.brrtipflg = 'N' then 
                  let ws.brrtipflgdes = 'NAO'
              else 
                  let ws.brrtipflgdes = 'SIM' 
              end if
              display ws.txtbrrtip    to txtbrrtip
              display ws.brrtipflgdes to brrtipflgdes attribute (reverse)
          end if
          if arr_aux <= arr_count()  then 
             let ws.operacao = "a" 
             let ws.cidcod   = a_ctc59m01[arr_aux].cidcod 
          end if 
 
       before insert 
          let ws.operacao = "i" 
          initialize a_ctc59m01[arr_aux].*  to null 
          display a_ctc59m01[arr_aux].* to s_ctc59m01[scr_aux].* 
 
       before field cidnom 
              display a_ctc59m01[arr_aux].cidnom to 
                      s_ctc59m01[scr_aux].cidnom attribute (reverse) 
 
       after  field cidnom 
          display a_ctc59m01[arr_aux].cidnom to 
                  s_ctc59m01[scr_aux].cidnom 
 
          if a_ctc59m01[arr_aux].cidnom is null  then 
             error " Cidade deve ser informada!" 
             next field cidnom 
          else 
             if l_cidflg = 1 and 
                a_ctc59m01[arr_aux].ufdcod is null then 
                next field ufdcod 
             end if 
          end if 
 
       before field ufdcod 
          display a_ctc59m01[arr_aux].ufdcod to 
                  s_ctc59m01[scr_aux].ufdcod attribute (reverse) 
 
       after  field ufdcod 
          display a_ctc59m01[arr_aux].ufdcod to 
                  s_ctc59m01[scr_aux].ufdcod 
          if fgl_lastkey() <> fgl_keyval("up")   or 
             fgl_lastkey() <> fgl_keyval("down")  or 
             fgl_lastkey() <> fgl_keyval("left") then 
             if a_ctc59m01[arr_aux].ufdcod is null  then 
                error " Sigla da unidade da federacao deve ser informada!" 
                next field ufdcod 
             end if 
 
             #-------------------------------------------------------------- 
             # Verifica se UF esta cadastrada 
             #-------------------------------------------------------------- 
             select ufdcod 
                       from glakest 
              where ufdcod = a_ctc59m01[arr_aux].ufdcod 
 
             if sqlca.sqlcode = notfound then 
                error " Unidade federativa nao cadastrada!" 
                next field ufdcod 
             end if 
 
             if a_ctc59m01[arr_aux].ufdcod = a_ctc59m01[arr_aux].cidnom  then 
                select ufdnom 
                          into a_ctc59m01[arr_aux].cidnom 
                  from glakest 
                         where ufdcod = a_ctc59m01[arr_aux].cidnom 
 
                if sqlca.sqlcode = 0  then 
                   display a_ctc59m01[arr_aux].cidnom to 
                           s_ctc59m01[scr_aux].cidnom 
                else 
                   let a_ctc59m01[arr_aux].cidnom = a_ctc59m01[arr_aux].ufdcod 
                end if 
             end if 
 
             #-------------------------------------------------------------- 
             # Verifica se a cidade esta cadastrada 
             #-------------------------------------------------------------- 
             declare c_glakcidade cursor for 
                select cidcod 
                  from glakcid 
                         where cidnom = a_ctc59m01[arr_aux].cidnom 
                   and ufdcod = a_ctc59m01[arr_aux].ufdcod 
 
             open  c_glakcidade 
             fetch c_glakcidade  into  a_ctc59m01[arr_aux].cidcod 
 
 
             if sqlca.sqlcode  =  100   then 
                call cts06g04(a_ctc59m01[arr_aux].cidnom, 
                              a_ctc59m01[arr_aux].ufdcod) 
                     returning a_ctc59m01[arr_aux].cidcod, 
                               a_ctc59m01[arr_aux].cidnom, 
                               a_ctc59m01[arr_aux].ufdcod 
 
                if a_ctc59m01[arr_aux].cidnom  is null   then 
                   error " Cidade deve ser informada!" 
                end if 
                next field cidnom 
             end if 
             close c_glakcidade 
          end if 
          for x = 1 to 40 
              if arr_aux <> x                                       and 
                 a_ctc59m01[arr_aux].cidcod = a_ctc59m01[x].cidcod  then 
                 error " Cidade ja' cadastrada para esta sede!" 
                 next field cidnom 
              end if 
          end for 
 
########################################################################### 
             # verifica se a cidade ja´ existe em outra cidade sede 
             let l_cidade_sede = null 
             let l_cidsedcod = null 
               #Priscila - AS - 10/11/06 
               #call ctc59m01_existe_sede( a_ctc59m01[arr_aux].cidcod ) 
               #returning l_cidade_sede 
               #Buscar cidade sede da cidade 
               call ctd01g00_obter_cidsedcod(1,a_ctc59m01[arr_aux].cidcod) 
                    returning l_ret, l_mensagem, l_cidsedcod 
               #if l_cidade_sede is not null then 
               if l_ret = 1 then 
                  #Buscar nome da cidade sede 
                  call cty10g00_cidade_uf(l_cidsedcod) 
                       returning l_ret, l_mensagem, 
                                 l_cidade_sede, l_ufdcod 
                  error "Cidade já cadastrada na cidade sede : ", 
                         l_cidade_sede , " ! " sleep 3 
                  let l_cidflg = 1 
                  let a_ctc59m01[arr_aux].ufdcod = null 
                  next field cidnom 
               else 
                  let l_cidflg = 0 
               end if 
########################################################################### 
       before delete 
          let ws.operacao = "d" 
          if a_ctc59m01[arr_aux].cidcod  is null  then 
             continue input 
          end if 
 
          delete from datrcidsed 
           where cidcod = a_ctc59m01[arr_aux].cidcod 
 
          if sqlca.sqlcode <> 0 then 
             error " Erro (", sqlca.sqlcode, ") na exclusao desta cidade, favor verificar!" 
          end if 
 
          initialize a_ctc59m01[arr_aux].* to null 
          display a_ctc59m01[arr_aux].* to s_ctc59m01[scr_aux].* 
 
       after row 
          case ws.operacao 
             when "i" 
               insert into datrcidsed    (cidsedcod, 
                                          cidcod) 
                                  values (param.cidsedcod, 
                                          a_ctc59m01[arr_aux].cidcod ) 
 
               if sqlca.sqlcode <> 0 then 
                  error " Erro (", sqlca.sqlcode, ") na inclusao deste assunto favor verificar!" 
               end if 
 
            end case 
 
          let ws.operacao = " " 
 
       on key (interrupt) 
          exit input 
 
          #separar serviços tela do rádio 
          on key (F6) 
            call separar_servicos(); 
 
          #abrir para viaturas 
          on key (F7) 
            call abrir_opcao(); 
            if m_cid_esp = 'X' then 
                let l_opcao = 1 
                let int_flag = true 
                exit while 
            end if 
 
            call abrir_assistencias(param.cidsedcod, 1) 
            # Verifica se a cidade esta em alerta 
            call ctc59m01_alerta(param.cidsedcod) 
 
          #abrir assistências 
          on key (F8) 
            call abrir_opcao(); 
            if m_cid_esp = 'X' then 
                let l_opcao = 2 
                let int_flag = true 
                exit while 
            end if 
 
            call abrir_assistencias(param.cidsedcod, 2) 
            # Verifica se a cidade esta em alerta 
            call ctc59m01_alerta(param.cidsedcod) 
 
          #abrir grupos de natureza 
          on key (F9) 
            call abrir_opcao(); 
            if m_cid_esp = 'X' then 
                let l_opcao = 3 
                let int_flag = true 
                exit while 
            end if 
 
            call abrir_assistencias(param.cidsedcod, 3) 
            # Verifica se a cidade esta em alerta 
            call ctc59m01_alerta(param.cidsedcod) 
 
          {update datrcidsed 
            set atnflg = ws.atnflg 
          where cidsedcod = param.cidsedcod} 
           
          on key (F10) 
              if ctc59m01_verifica_usu(g_issk.funmat) then
                  if ws.brrtipflg is null or ws.brrtipflg = 'N' then 
                     let ws.brrtipflg = 'S' 
                     let ws.brrtipflgdes = 'SIM' 
                  else 
                     let ws.brrtipflg = 'N' 
                     let ws.brrtipflgdes = 'NAO' 
                  end if 
                  call ctc59m01_brrtipflg(param.cidsedcod,ws.brrtipflg) 
                      returning l_ret 
                  if l_ret then 
                      error "Erro na atualizacao da flag de indexacao por bairro" 
                  end if 
                  display ws.brrtipflgdes to brrtipflgdes attribute (reverse) 
              end if
          
          on key (F5)
              if ctc59m01_verifica_usu_qrv2(g_issk.funmat) then
                 call cts08g01('C','S',"","   Confirma a ativacao/desativacao","do QRV2?","")
                      returning prompt_key
                 if prompt_key <> 'N' then
                    call ctc59m01_qrv2(param.cidsedcod,1)
                 end if
                 
              end if
              
          on key (F3)
             if ctc59m01_verifica_usu_blq(g_issk.funmat) then
                call cts08g01('C','S',"","   Confirma a ativacao/desativacao","do bloqueio por",
                              "falta de seguro de vida?")
                     returning prompt_key
                if prompt_key <> 'N' then
                   if ctc59m01_blqcidsed(param.cidsedcod using "&&&&",'blqcidsedqra',1) then  # bloqueio seg vida
                      display "SEM BLOQ QRA" to blqqraflg
                   else
                      display "BLOQ QRA OK" to blqqraflg
                   end if
                end if
                 
             end if
          
          on key (F4)
             if ctc59m01_verifica_usu_blq(g_issk.funmat) then
                call cts08g01('C','S',"","   Confirma a ativacao/desativacao","do bloqueio por",
                              "inconformidades na Vistoria?")
                     returning prompt_key
                if prompt_key <> 'N' then
                   if ctc59m01_blqcidsed(param.cidsedcod using "&&&&",'blqcidsedvtr',1) then  # bloqueio vistoria
                      display "SEM BLOQ VTR" to blqvtrflg
                   else
                      display "BLOQ VTR OK" to blqvtrflg
                   end if
                end if
                 
             end if           
          
          on key (control-b)             # 13.01.12 ZeLuis PSI-2011-21476-PR
             if ctc59m01_verifica_usu_blq(g_issk.funmat) then
                call cts08g01('C','S', "","Confirma a ativacao / desativacao  do",
"bloqueio por irregularidade de seguro", "de veiculo desta cidade sede?")

                     returning prompt_key
                if prompt_key <> 'N' then
                   if ctc59m01_blqcidsed(param.cidsedcod using "&&&&",'blqcidsedsegvtr',1) then  # bloqueio seg veiculo
                      display "^+B:BLQ VTR SEG  OK" to blqvclsegflg
                   else
                      display "^+B:SEM BLQ VTR SEG" to blqvclsegflg
                   end if
                end if
             end if
          

    end input 
 
    if int_flag    then 
       exit while 
    end if 
 
end while 
 
if m_cid_esp = 'X' then 
 
    let m_arr_aux = 1 
    let ws.atnflg = null 
 
    foreach c_ctc59m01 into m_ctc59m01_2[m_arr_aux].cidcod, ws.atnflg 
 
         if l_opcao = '1' then 
 
            declare c_ctc59m02 cursor for 
             select atnflg from datrcidsedatn 
              where cidsedcod = param.cidsedcod 
                and cidcod    = m_ctc59m01_2[m_arr_aux].cidcod 
                and vcltipcod <> '0' 
 
             open c_ctc59m02 
             fetch c_ctc59m02 into m_ctc59m01_2[m_arr_aux].atnflg 
 
                if (m_ctc59m01_2[m_arr_aux].atnflg = 'S') then 
                    let m_ctc59m01_2[m_arr_aux].atnflg = 'X' 
                else 
                    let m_ctc59m01_2[m_arr_aux].atnflg = '' 
                end if 
 
             close c_ctc59m02 
 
         end if 
 
         if l_opcao = '2' then 
 
            declare c_ctc59m03 cursor for 
             select atnflg from datrcidsedatn 
              where cidsedcod = param.cidsedcod 
                and cidcod    = m_ctc59m01_2[m_arr_aux].cidcod 
                and asitipcod <> '0' 
 
             open c_ctc59m03 
             fetch c_ctc59m03 into m_ctc59m01_2[m_arr_aux].atnflg 
 
                if (m_ctc59m01_2[m_arr_aux].atnflg = 'S') then 
                    let m_ctc59m01_2[m_arr_aux].atnflg = 'X' 
                else 
                    let m_ctc59m01_2[m_arr_aux].atnflg = '' 
                end if 
 
             close c_ctc59m03 
 
         end if 
 
         if l_opcao = '3' then 
 
            declare c_ctc59m04 cursor for 
             select atnflg from datrcidsedatn 
              where cidsedcod = param.cidsedcod 
                and cidcod    = m_ctc59m01_2[m_arr_aux].cidcod 
                and socntzgrpcod <> '0' 
 
             open c_ctc59m04 
             fetch c_ctc59m04 into m_ctc59m01_2[m_arr_aux].atnflg 
 
                if (m_ctc59m01_2[m_arr_aux].atnflg = 'S') then 
                    let m_ctc59m01_2[m_arr_aux].atnflg = 'X' 
                else 
                    let m_ctc59m01_2[m_arr_aux].atnflg = '' 
                end if 
 
             close c_ctc59m04 
 
         end if 
 
         let m_ctc59m01_2[m_arr_aux].ufdcod = "NF" 
         let m_ctc59m01_2[m_arr_aux].cidnom = "NAO CADASTRADO!" 
         select ufdcod, 
                cidnom 
           into m_ctc59m01_2[m_arr_aux].ufdcod, 
                m_ctc59m01_2[m_arr_aux].cidnom 
           from glakcid 
          where cidcod = m_ctc59m01_2[m_arr_aux].cidcod 
 
         let m_arr_aux = m_arr_aux + 1 
         if m_arr_aux > 40 then 
            error " Limite excedido, convenio com mais de 40 assuntos" 
            exit foreach 
         end if 
 
    end foreach 
 
    message "(F8) para salvar - Marque X na cidade(s) a ser(em) bloqueada(s) " 
 
    call set_count(arr_count()) 
    input array m_ctc59m01_2 without defaults from s_ctc59m01_2.* 
 
        {before row 
            if scr_line() = m_arr_aux then 
                error "Limite excedido! " 
 
                if fgl_lastkey() = fgl_keyval("return") or 
                   fgl_lastkey() = fgl_keyval("right")  or 
                   fgl_lastkey() = fgl_keyval("down")   then 
                   next field atnflg 
                end if 
 
            end if} 
 
        on key (F8) 
            call abrir_assistencias(param.cidsedcod, l_opcao) 
            # Verifica se a cidade esta em alerta 
            call ctc59m01_alerta(param.cidsedcod) 
 
    end input 
 
end if 
 
clear form 
 
let int_flag = false 
 
end function  #  ctc59m01_cidades 
 
# PSI: 214566 
#-------------------------------------------------------------- 
function abrir_assistencias(param, assOuNtz) 
#-------------------------------------------------------------- 
 
    define param  decimal(8,0) 
    define assOuNtz smallint 
    define l_prep char(250) 
    define nom    char(40) 
 
    #array que serve de parâmetro tanto para viaturas, assistências e naturezas 
    define assMult array [100] of record 
        aux              char(01), 
        asitipcod        like datkasitip.asitipcod, 
        asitipdes        like datkasitip.asitipdes 
    end record 
 
    #record para registros de assistência e natureza 
    define assAux record 
        cidsedcod    like datrcidsedatn.cidsedcod, 
        asitipcod    like datrcidsedatn.asitipcod, 
        socntzgrpcod like datrcidsedatn.socntzgrpcod, 
        atnflg       like datrcidsedatn.atnflg 
    end record 
 
    define i integer 
    define x integer 
    define x2 integer 
    define atnflag_aux char(01) 
    --define lCurrent integer 
 
    initialize assAux.* to null 
 
    declare cursor_aux_vcl cursor for 
     select unique atn.atnflg, vcl.cpocod, vcl.cpodes 
       from iddkdominio vcl, outer datrcidsedatn atn 
      where atn.cidsedcod = param 
        and vcl.cpocod = atn.vcltipcod 
        and vcl.cponom = 'socvcltip' 
      order by vcl.cpocod 
 
    declare cursor_aux_ast cursor for 
     select unique atn.atnflg, dat.asitipcod, dat.asitipdes 
       from datkasitip dat, outer datrcidsedatn atn 
      where atn.cidsedcod = param 
        and dat.asitipcod = atn.asitipcod 
      order by dat.asitipcod 
 
    declare cursor_aux_ntz cursor for 
     select unique atn.atnflg, ntz.socntzgrpcod, ntz.socntzgrpdes 
       from datksocntzgrp ntz, outer datrcidsedatn atn 
      where atn.cidsedcod = param 
        and ntz.socntzgrpcod = atn.socntzgrpcod 
      order by ntz.socntzgrpcod 
 
    #Verifica se existe estado de alerta para algum item para alguma cidade sede 
    let l_prep = "select * from datrcidsedatn atn", 
                 " where atn.cidsedcod = ? " 
    prepare pctc59m0110 from l_prep 
    declare cctc59m0110 cursor for pctc59m0110 
 
    #Pôr cidade específica em estado de atenção 
    let l_prep = "update datrcidsed ", 
                 "   set atnflg = ? ", 
                 " where cidcod = ? " 
    prepare pctc59m0120 from l_prep 
 
    #cursor para viaturas 
    if (assOuNtz = 1) then 
        let nom = 'Viatura(s)' 
 
        open cursor_aux_vcl 
        let i = 1 
        foreach cursor_aux_vcl into assMult[i].aux, assMult[i].asitipcod, assMult[i].asitipdes 
            #Substitui S da tabela por X para o usuário 
            if (assMult[i].aux = 'S') then 
                let assMult[i].aux = 'X' 
            else 
                let assMult[i].aux = '' 
            end if 
 
            let i = i + 1 
        end foreach 
        close cursor_aux_vcl 
    end if 
 
    #cursor para assistências 
    if (assOuNtz = 2) then 
        let nom = 'Assistência(s)' 
 
        open cursor_aux_ast 
        let i = 1 
        foreach cursor_aux_ast into assMult[i].aux, assMult[i].asitipcod, assMult[i].asitipdes 
            #Substitui S da tabela por X para o usuário 
            if (assMult[i].aux = 'S') then 
                let assMult[i].aux = 'X' 
            else 
                let assMult[i].aux = '' 
            end if 
            let i = i + 1 
        end foreach 
        close cursor_aux_ast 
    end if 
 
    #cursor para grupos de natureza 
    if (assOuNtz = 3) then 
        let nom = 'Natureza(s)' 
 
        open cursor_aux_ntz 
        let i = 1 
        foreach cursor_aux_ntz into assMult[i].aux, assMult[i].asitipcod, assMult[i].asitipdes 
            #Substitui S da tabela por X para o usuário 
            if (assMult[i].aux = 'S') then 
                let assMult[i].aux = 'X' 
            else 
                let assMult[i].aux = '' 
            end if 
            let i = i + 1 
        end foreach 
        close cursor_aux_ntz 
    end if 
 
    open window wf1 at 9,31 with form 'ctc59m02'    #Tela para seleção de assistências 
        attribute (border) 
 
        display nom to nom 
        display nom to nom2 
 
    call set_count(i-1) 
    #carrega tela ctc59m0101 com dados de assistência ou grupos de natureza ou viaturas 
    input array assMult without defaults from assistencias.* 
 
    #Quando for salvar asitipcod selecionados 
    on key (f8) 
 
        for x = 1 to i-1 
 
            if assMult[x].aux = 'X' then 
 
                let assMult[x].aux = 'S' 
 
                #viaturas - F7 
                if (assOuNtz = 1) then 
 
                    let l_prep = "select * from datrcidsedatn atn", 
                                 " where atn.cidsedcod = ? ", 
                                 "   and atn.vcltipcod = ? " 
                    prepare pctc59m0101 from l_prep 
                    declare cctc59m0101 cursor for pctc59m0101 
 
                    let l_prep = "insert into datrcidsedatn values(?,?,?,?,?,?,?)" 
                    prepare pctc59m0102 from l_prep 
 
                    if m_cid_esp = 'X' then 
 
                        let x2 = 1 
                        for x2 = 1 to m_arr_aux - 1 
 
                            if m_ctc59m01_2[x2].atnflg = 'X' then 
 
                                let l_prep = "select * from datrcidsedatn atn", 
                                 " where atn.cidsedcod = ? ", 
                                 "   and atn.cidcod = ? ", 
                                 "   and atn.vcltipcod = ? " 
                                prepare pctc59m0114 from l_prep 
                                declare cctc59m0114 cursor for pctc59m0114 
 
                                #MOSTRA OPÇÕES MARCADAS PARA A CIDADE SEDE 
                                open  cctc59m0114 using param, m_ctc59m01_2[x2].cidcod, assMult[x].asitipcod 
                                fetch cctc59m0114 into assAux.* 
                                if sqlca.sqlcode = notfound then 
                                    #insert para viaturas - GRAVA CIDADE SEDE E CIDADE ESPECIFICA - ALTER TABLE 
                                    execute pctc59m0102 using param, '0', '0' , assMult[x].asitipcod, assMult[x].aux, '0', 
                                                              m_ctc59m01_2[x2].cidcod 
 
                                    #SÓ COLOCA EM ESTADO DE ATENÇÃO A CIDADE ESPECÍFICA 
                                    execute pctc59m0120 using 'S', m_ctc59m01_2[x2].cidcod 
 
                                end if 
                                close cctc59m0114 
 
                            end if 
 
                        end for 
 
                    else 
 
                        open  cctc59m0101 using param, assMult[x].asitipcod 
                        fetch cctc59m0101 into assAux.* 
                        if sqlca.sqlcode = notfound then 
 
                            #insert para viaturas 
                            execute pctc59m0102 using param, '0', '0' , assMult[x].asitipcod, assMult[x].aux, '0', param 
 
                        end if 
 
                    end if 
 
                end if 
 
                #assistências - F8 
                if (assOuNtz = 2) then 
                    let l_prep = "select * from datrcidsedatn atn", 
                                " where atn.cidsedcod = ? ", 
                                "   and atn.asitipcod = ? " 
                    prepare pctc59m0104 from l_prep 
                    declare cctc59m0104 cursor for pctc59m0104 
 
                    let l_prep = "insert into datrcidsedatn values(?,?,?,?,?,?,?)" 
                    prepare pctc59m0105 from l_prep 
 
                    if m_cid_esp = 'X' then 
 
                        let x2 = 1 
                        for x2 = 1 to m_arr_aux - 1 
 
                            if m_ctc59m01_2[x2].atnflg = 'X' then 
 
                                let l_prep = "select * from datrcidsedatn atn", 
                                " where atn.cidsedcod = ? ", 
                                "   and atn.cidcod = ? ", 
                                "   and atn.asitipcod = ? " 
                                prepare pctc59m0115 from l_prep 
                                declare cctc59m0115 cursor for pctc59m0115 
 
                                #MOSTRA OPÇÕES MARCADAS PARA A CIDADE SEDE 
                                open  cctc59m0115 using param, m_ctc59m01_2[x2].cidcod, assMult[x].asitipcod 
                                fetch cctc59m0115 into assAux.* 
                                if sqlca.sqlcode = notfound then 
                                    #display "NÃO ENCONTROU NADA PARA ", assMult[x].asitipdes 
                                    #insert para assistências - GRAVA CIDADE SEDE E CIDADE ESPECIFICA - ALTER TABLE 
                                    execute pctc59m0105 using param, assMult[x].asitipcod, '0' , '0', assMult[x].aux, '0', 
                                                              m_ctc59m01_2[x2].cidcod 
 
                                    #SÓ COLOCA EM ESTADO DE ATENÇÃO A CIDADE ESPECÍFICA 
                                    execute pctc59m0120 using 'S', m_ctc59m01_2[x2].cidcod 
 
                                end if 
                                close cctc59m0115 
 
                            end if 
 
                        end for 
 
                    else 
 
                        open  cctc59m0104 using param, assMult[x].asitipcod 
                        fetch cctc59m0104 into assAux.* 
                        if sqlca.sqlcode = notfound then 
                            #display "NÃO ENCONTROU NADA PARA ", assMult[x].asitipdes 
                            #insert para assistências 
                            execute pctc59m0105 using param, assMult[x].asitipcod, '0' , '0', assMult[x].aux, '0', '0' 
                        end if 
 
                    end if 
 
                end if 
 
                #naturezas - F9 
                if (assOuNtz = 3) then 
                    let l_prep = "select * from datrcidsedatn atn", 
                                 " where atn.cidsedcod    = ? ", 
                                 "   and atn.socntzgrpcod = ? " 
                    prepare pctc59m0107 from l_prep 
                    declare cctc59m0107 cursor for pctc59m0107 
 
                    let l_prep = "insert into datrcidsedatn values(?,?,?,?,?,?,?)" 
                    prepare pctc59m0108 from l_prep 
 
                    if m_cid_esp = 'X' then 
 
                        let x2 = 1 
                        for x2 = 1 to m_arr_aux - 1 
 
                            if m_ctc59m01_2[x2].atnflg = 'X' then 
 
                                let l_prep = "select * from datrcidsedatn atn", 
                                 " where atn.cidsedcod    = ? ", 
                                 "   and atn.cidcod = ? ", 
                                 "   and atn.socntzgrpcod = ? " 
                                prepare pctc59m0116 from l_prep 
                                declare cctc59m0116 cursor for pctc59m0116 
 
                                #MOSTRA OPÇÕES MARCADAS PARA A CIDADE SEDE 
                                open  cctc59m0116 using param, m_ctc59m01_2[x2].cidcod, assMult[x].asitipcod 
                                fetch cctc59m0116 into assAux.* 
                                if sqlca.sqlcode = notfound then 
                                    #display "NÃO ENCONTROU NADA PARA ", assMult[x].asitipdes 
                                    #insert para assistências - GRAVA CIDADE SEDE E CIDADE ESPECIFICA - ALTER TABLE 
                                    execute pctc59m0108 using param, '0', assMult[x].asitipcod , '0', assMult[x].aux, '0', 
                                                              m_ctc59m01_2[x2].cidcod 
 
                                    #SÓ COLOCA EM ESTADO DE ATENÇÃO A CIDADE ESPECÍFICA 
                                    execute pctc59m0120 using 'S', m_ctc59m01_2[x2].cidcod 
 
                                end if 
                                close cctc59m0116 
 
                            end if 
 
                        end for 
 
                    else 
 
                        open  cctc59m0107 using param, assMult[x].asitipcod 
                        fetch cctc59m0107 into assAux.* 
                        if sqlca.sqlcode = notfound then 
                            #display "NÃO ENCONTROU NADA PARA ", assMult[x].asitipdes 
                            #insert para assistências 
                            execute pctc59m0108 using param, '0', assMult[x].asitipcod , '0', assMult[x].aux, '0', '0' 
                        end if 
 
                    end if 
 
                end if 
 
            else 
 
                #viaturas - F7 
                if (assOuNtz = 1) then 
                    let l_prep = "select * from datrcidsedatn atn", 
                                 " where atn.cidsedcod = ? ", 
                                 "   and atn.vcltipcod = ? " 
                    prepare pctc59m0111 from l_prep 
                    declare cctc59m0111 cursor for pctc59m0111 
 
                    open  cctc59m0111 using param, assMult[x].asitipcod 
                    fetch cctc59m0111 into assAux.* 
                    if sqlca.sqlcode = notfound then 
                    #display "NÃO ENCONTROU NADA " 
 
                    else 
                        let l_prep = "delete from datrcidsedatn ", 
                                     " where cidsedcod = ? ", 
                                     "   and vcltipcod = ? " 
                        prepare pctc59m0103 from l_prep 
                        #deletando registro que não está mais em ESTADO DE ATENÇÃO 
                        execute pctc59m0103 using param, assMult[x].asitipcod 
 
                    end if 
 
                end if 
 
                #assistências - F8 
                if (assOuNtz = 2) then 
                    let l_prep = "select * from datrcidsedatn atn", 
                                 " where atn.cidsedcod = ? ", 
                                 "   and atn.asitipcod = ? " 
                    prepare pctc59m0112 from l_prep 
                    declare cctc59m0112 cursor for pctc59m0112 
 
                    open  cctc59m0112 using param, assMult[x].asitipcod 
                    fetch cctc59m0112 into assAux.* 
                    if sqlca.sqlcode = notfound then 
                        #display "NÃO ENCONTROU NADA " 
 
                    else 
                        let l_prep = "delete from datrcidsedatn ", 
                                     " where cidsedcod = ? ", 
                                     "   and asitipcod = ? " 
                        prepare pctc59m0106 from l_prep 
                        #deletando registro que não está mais em ESTADO DE ATENÇÃO 
                        execute pctc59m0106 using param, assMult[x].asitipcod 
 
                    end if 
 
                end if 
 
                #naturezas - F9 
                if (assOuNtz = 3) then 
                    let l_prep = "select * from datrcidsedatn atn", 
                                 " where atn.cidsedcod = ? ", 
                                 "   and atn.socntzgrpcod = ? " 
                    prepare pctc59m0113 from l_prep 
                    declare cctc59m0113 cursor for pctc59m0113 
 
                    open  cctc59m0113 using param, assMult[x].asitipcod 
                    fetch cctc59m0113 into assAux.* 
                    if sqlca.sqlcode = notfound then 
                        #display "NÃO ENCONTROU NADA " 
 
                    else 
                        let l_prep = "delete from datrcidsedatn ", 
                                     " where cidsedcod    = ? ", 
                                     "   and socntzgrpcod = ? " 
                        prepare pctc59m0109 from l_prep 
                        #deletando registro que não está mais em ESTADO DE ATENÇÃO 
                        execute pctc59m0109 using param, assMult[x].asitipcod 
 
                    end if 
 
                end if 
 
            end if 
 
        end for 
 
        #Seta flag de estado de alerta para contingência 
        open cctc59m0110  using param 
        fetch cctc59m0110 into assAux.* 
        if sqlca.sqlcode = notfound then 
            let atnflag_aux = 'N' 
        else 
            let atnflag_aux = 'S' 
        end if 
 
        if m_cid_esp = 'X' then 
 
            let x2 = 1 
            for x2 = 1 to m_arr_aux - 1 
 
                if m_ctc59m01_2[x2].atnflg is null or m_ctc59m01_2[x2].atnflg =  " " then 
 
                    execute pctc59m0120 using 'N', m_ctc59m01_2[x2].cidcod 
 
                end if 
            end for 
 
        else 
 
            update datrcidsed 
               set atnflg    = atnflag_aux 
             where cidsedcod = param 
 
        end if 
 
        exit input 
 
    end input 
 
    close window wf1 
 
end function    # abrir_assistencias 
 
#---------------------------------------- 
function ctc59m01_alerta(param_cidsedcod) 
#---------------------------------------- 
 
 define param_cidsedcod   like datrcidsed.cidsedcod 
 
 define r_alerta     record 
    asitipcod        like datrcidsedatn.asitipcod, 
    socntzgrpcod     like datrcidsedatn.socntzgrpcod, 
    vcltipcod        like datrcidsedatn.vcltipcod, 
    cidcod           like datrcidsedatn.cidcod 
 end record 
 
 define l_ctr         char(03) 
 define l_atencaodes  char(30) 
 define l_atencao_aux char(30) 
 define teste         char(1) 
 define l_prep        char(200) 
 
 let l_prep = " select asitipcod,socntzgrpcod,vcltipcod,cidcod ", 
              " from datrcidsedatn ", 
              " where  cidsedcod = ?" 
  prepare palerta  from l_prep 
  declare c_alerta cursor for palerta 
 
  initialize l_atencao_aux to  null 
  initialize l_atencaodes  to  null 
  initialize l_ctr         to  null 
  initialize r_alerta.*    to  null 
 
  display l_atencaodes to atencaodes 
 
  open  c_alerta  using param_cidsedcod 
  foreach c_alerta   into  r_alerta.* 
 
     if r_alerta.asitipcod <> 0 then 
        let l_ctr[1,1] = 1 
     end if 
 
     if r_alerta.socntzgrpcod <> 0 then 
        let l_ctr[2,2] = 1 
     end if 
 
     if r_alerta.vcltipcod    <> 0 then 
        let l_ctr[3,3] = 1 
     end if 
 
  end foreach 
 
  if l_ctr[1,1] = "1" then 
     let l_atencao_aux = " AST" clipped 
  end if 
 
  if l_ctr[2,2] = "1" then 
    let l_atencao_aux = l_atencao_aux clipped ," NTZ" clipped 
  end if 
 
  if l_ctr[3,3] = "1" then 
    let l_atencao_aux  = l_atencao_aux clipped," VTR" clipped 
  end if 
 
  if l_atencao_aux is not null then 
     let l_atencaodes = 'ATENCAO' clipped ,l_atencao_aux clipped 
 
     if r_alerta.cidcod <> 0 then 
        let l_atencaodes = l_atencaodes clipped, "/CID ESP" clipped 
     end if 
 
     display l_atencaodes to atencaodes 
  else 
 
     #VERIFICA SE O ALERTA É DE CIDADE ESPECÍFICA 
     {initialize r_alerta.* to null 
     initialize l_ctr to null 
     initialize l_atencao_aux to  null 
     initialize l_atencaodes  to  null 
 
     select asitipcod,socntzgrpcod,vcltipcod 
       into r_alerta.asitipcod, r_alerta.socntzgrpcod, r_alerta.vcltipcod 
       from datrcidsedatn 
      where cidcod = param_cidsedcod 
 
     if r_alerta.asitipcod <> 0 then 
        let l_ctr[1,1] = 1 
     end if 
 
     if r_alerta.socntzgrpcod <> 0 then 
        let l_ctr[2,2] = 1 
     end if 
 
     if r_alerta.vcltipcod    <> 0 then 
        let l_ctr[3,3] = 1 
     end if 
 
     if l_ctr[1,1] = "1" then 
        let l_atencao_aux = " AST" clipped 
     end if 
 
     if l_ctr[2,2] = "1" then 
         let l_atencao_aux = l_atencao_aux clipped ," NTZ" clipped 
     end if 
 
     if l_ctr[3,3] = "1" then 
        let l_atencao_aux  = l_atencao_aux clipped," VTR" clipped 
     end if 
 
     let l_atencaodes = 'ATENCAO' clipped ,l_atencao_aux clipped 
     let l_atencaodes = l_atencaodes clipped, "/CID ESP" clipped 
     display l_atencaodes to atencaodes 
 
     if l_atencao_aux is null then 
        let l_atencaodes = 'OPERACAO NORMAL' clipped 
        display l_atencaodes to atencaodes 
     end if} 
 
     let l_atencaodes = 'OPERACAO NORMAL' clipped 
     display l_atencaodes to atencaodes 
 
  end if 
 
  close c_alerta 
 
  return 
 
end function 
 
 
#-------------------------------------------------------------- 
{ function ctc59m01_cidades_especificas(param) 
#-------------------------------------------------------------- 
 
 define param        record 
    cidsedcod        like datrcidsed.cidsedcod 
 end record 
 
 define a_ctc59m01   array[40] of record 
    atnflg        char(1) 
    cidnom        like glakcid.cidnom, 
    ufdcod        like glakcid.ufdcod, 
    cidcod        like datrcidsed.cidcod 
 end record 
 
 define ws           record 
    cidcod           like glakcid.cidcod, 
    atlmat           like dammaleastcvn.atlmat, 
    atlemp           like dammaleastcvn.atlemp, 
    atlusrtip        like dammaleastcvn.atlusrtip, 
    confirma         char (01), 
    operacao         char (01), 
    atencaodes       char(20), 
    atnflg           char(1) 
 end record 
 
 define arr_aux      integer 
 define scr_aux      integer 
 define x            smallint 
 
 define l_cidade_sede like glakcid.cidnom 
 define l_cidsedcod   like glakcid.cidcod    #AS 10/11 
 define l_ufdcod      like glakcid.ufdcod    #AS 10/11 
 define l_cidflg smallint 
 
 define l_ret smallint            #AS 10/11 
 define l_mensagem char(50)       #AS 10/11 
 
 initialize a_ctc59m01  to null 
 initialize ws.*        to null 
 let arr_aux = 1 
 let l_cidflg = 1 
 
 declare c_ctc59m01 cursor for 
  select cidcod, atnflg 
    from datrcidsed 
   where cidsedcod  = param.cidsedcod 
 
 foreach c_ctc59m01 into a_ctc59m01[arr_aux].cidcod, a_ctc59m01[arr_aux].atnflg 
 
    if (a_ctc59m01[arr_aux].atnflg = 'S') then 
        let a_ctc59m01[arr_aux].atnflg = 'X' 
    else 
        let a_ctc59m01[arr_aux].atnflg = '' 
    end if 
 
    {if arr_aux = 1 then 
       case ws.atnflg 
          when 'S' 
             let ws.atencaodes = 'Estado de ATENCAO' 
          otherwise 
             let ws.atencaodes = 'Operacao NORMAL' 
       end case 
       display by name ws.atencaodes 
    end if} 
 
    {let a_ctc59m01[arr_aux].ufdcod = "NF" 
    let a_ctc59m01[arr_aux].cidnom = "NAO CADASTRADO!" 
    select ufdcod, 
           cidnom 
      into a_ctc59m01[arr_aux].ufdcod, 
           a_ctc59m01[arr_aux].cidnom 
      from glakcid 
     where cidcod = a_ctc59m01[arr_aux].cidcod 
 
    let arr_aux = arr_aux + 1 
    if arr_aux > 40 then 
       error " Limite excedido, convenio com mais de 40 assuntos" 
       exit foreach 
    end if 
 
 end foreach 
 
 call set_count(arr_aux-1) 
 options comment line last - 1 
 
 while 2 
 
    let int_flag = false 
 
    open window wf3 at 9,31 with form 'ctc59m05'    #Tela para seleção de assistências 
         attribute (border) 
 
    call set_count(arr_aux-1) 
 
    input array a_ctc59m01 without defaults from cidades.* 
 
    on key (f8) 
        #display "qtd i", i 
 
        for x = 1 to arr_aux - 1 
 
            if assMult[x].atnflg = 'X' then 
                #display "ASSMULT IF >>>>> ", assMult[x].* 
 
                let assMult[x].atnflg = 'S' 
 
                let l_prep = "select * from datrcidsedatn atn", 
                            " where atn.cidsedcod = ? ", 
                            "   and atn.vcltipcod = ? " 
                prepare pctc59m0101 from l_prep 
                declare cctc59m0101 cursor for pctc59m0101 
 
                let l_prep = "insert into datrcidsedatn values(?,?,?,?,?,?)" 
                prepare pctc59m0102 from l_prep 
 
                open  cctc59m0101 using param, assMult[x].asitipcod 
                fetch cctc59m0101 into assAux.* 
                if sqlca.sqlcode = notfound then 
                    #display "NÃO ENCONTROU NADA PARA ", assMult[x].asitipdes 
                    #insert para assistências 
                    execute pctc59m0102 using param, '0', '0' , assMult[x].asitipcod, assMult[x].aux, '0' 
                end if 
            else 
                let l_prep = "select * from datrcidsedatn atn", 
                             " where atn.cidsedcod = ? ", 
                             "   and atn.vcltipcod = ? " 
                prepare pctc59m0111 from l_prep 
                declare cctc59m0111 cursor for pctc59m0111 
 
                open  cctc59m0111 using param, assMult[x].asitipcod 
                fetch cctc59m0111 into assAux.* 
                if sqlca.sqlcode = notfound then 
                    #display "NÃO ENCONTROU NADA " 
 
                else 
                    let l_prep = "delete from datrcidsedatn ", 
                                 " where cidsedcod = ? ", 
                                 "   and vcltipcod = ? " 
                    prepare pctc59m0103 from l_prep 
                    #deletando registro que não está mais em ESTADO DE ATENÇÃO 
                    execute pctc59m0103 using param, assMult[x].asitipcod 
            end if 
 
       on key (interrupt) 
          exit input 
 
    end input 
 
    close window wf3 
 
    if int_flag    then 
       exit while 
    end if 
 
end while 
 
clear form 
 
let int_flag = false 
 
end function}  #  ctc59m01_cidades_especificas 
 
function abrir_opcao() 
 
    open window wf2 at 9,31 with form 'ctc59m04'    #Seleção de opção 
        attribute (border) 
 
    let m_cid_esp = null 
    let m_toda_sed = null 
 
    input by name m_toda_sed, 
                  m_cid_esp without defaults 
 
    before field m_toda_sed 
        display by name m_toda_sed attribute (reverse) 
 
        if m_cid_esp = 'X' then 
            let m_cid_esp = null 
            display by name m_cid_esp 
        end if 
 
        let m_toda_sed = 'X' 
        display by name m_toda_sed 
 
    after field m_toda_sed 
        if m_toda_sed <> 'X' then 
            next field m_toda_sed 
        end if 
        display by name m_toda_sed 
 
    before field m_cid_esp 
        display by name m_cid_esp attribute (reverse) 
 
        if m_toda_sed = 'X' then 
            let m_toda_sed = null 
            display by name m_toda_sed 
        end if 
 
        let m_cid_esp = 'X' 
        display by name m_cid_esp 
 
    after field m_cid_esp 
        if m_cid_esp <> 'X' then 
            next field m_cid_esp 
        end if 
        display by name m_cid_esp 
 
        if fgl_lastkey() = fgl_keyval("up")      or 
           fgl_lastkey() = fgl_keyval("down")    or 
           fgl_lastkey() = fgl_keyval("left")    or 
           fgl_lastkey() = fgl_keyval("right")   or 
           fgl_lastkey() = fgl_keyval("return")  then 
           next field m_toda_sed 
        end if 
 
    on key (f8) 
        exit input 
 
        end input 
 
        close window wf2 
 
end function 
 
#PSI 241733 - FUNCAO RESPONSAVEL POR 
#SEPARAR SERVICOS EM ALERTA NA TELA DO RADIO 
function separar_servicos() 
 
    define l_prep char(250), 
           l_flg smallint, 
           l_atencaosep char(75) 
 
    let l_flg = null 
    let l_atencaosep = null 
 
    let l_prep = "select grlinf from igbkgeral", 
                    " where mducod = 'C24' ", 
                    "   and grlchv = 'SEP-SRV'  " 
    prepare pctc59m0117 from l_prep 
    declare cctc59m0117 cursor for pctc59m0117 
 
    open cctc59m0117 
    fetch cctc59m0117 into l_flg 
 
    #SE A SEPARAÇÃO DE SERVIÇOS ESTIVER DESATIVADA, ATIVA 
    if l_flg = false then 
 
        let l_prep = "update igbkgeral set grlinf = '1' ", 
                     " where mducod = 'C24' ", 
                     "   and grlchv = 'SEP-SRV' " 
        prepare pctc59m0118 from l_prep 
 
        whenever error continue 
        execute pctc59m0118 
        whenever error stop 
 
        if sqlca.sqlcode <> 0 then 
            error "Erro ao setar separacao de servicos! ", sqlca.sqlcode 
        else 
            let l_atencaosep = 'ATENÇÃO: VISUALIZAÇÃO DE ESTADO DE ATENÇÃO SEPARADA, (F6)UNIFICA ' 
            display l_atencaosep to atencaosep attribute (reverse) 
            error "Separacao de servicos ativada! " 
        end if 
 
    end if 
 
    if l_flg = true then 
 
        let l_prep = "update igbkgeral set grlinf = '0' ", 
                     " where mducod = 'C24' ", 
                     "   and grlchv = 'SEP-SRV' " 
        prepare pctc59m0119 from l_prep 
 
        whenever error continue 
        execute pctc59m0119 
        whenever error stop 
 
        if sqlca.sqlcode <> 0 then 
            error "Erro ao setar separacao de servicos! ", sqlca.sqlcode 
        else 
            let l_atencaosep = null 
            display l_atencaosep to atencaosep 
            error "Separacao de servicos desativada! " 
        end if 
 
    end if 
 
    close cctc59m0117 
 
end function 
 
function ctc59m01_alertasep() 
 
    define l_atencaosep like igbkgeral.grlinf, 
           l_atencaosepmsg char(75) 
 
    let l_atencaosep = null 
    let l_atencaosepmsg = null 
 
    select grlinf 
      into l_atencaosep 
      from igbkgeral 
     where mducod = 'C24' 
       and grlchv = 'SEP-SRV' 
 
    if l_atencaosep = true then 
       let l_atencaosepmsg = 'ATENCAO: VISUALIZACAO DE ESTADO DE ATENCAO SEPARADA, (F6)UNIFICA' 
       display l_atencaosepmsg to atencaosep attribute (reverse) 
    end if 
 
end function 
 
# #Priscila - AS - 10/11/06 
#------------------------------------ 
#function ctc59m01_existe_sede(param) 
#------------------------------------ 
# 
# define param      record 
#    cidcod         like glakcid.cidcod 
# end record 
# 
# define l_cidade_sede like glakcid.cidnom 
# define l_cidade      like glakcid.cidcod 
# 
# let l_cidade_sede = null 
# let l_cidade      = null 
# #Select a.cidsedcod into l_cidade 
# #from   datrcidsed a 
# #where  a.cidcod    = param.cidcod 
# #if l_cidade is not null then 
# #   select  a.cidnom  into l_cidade_sede 
# #   from    glakcid a 
# #   where   a.cidcod = l_cidade 
# #end if 
# 
# return l_cidade_sede 
# 
#end function  #  ctc59m01_existe 
 
------------------------------------ 
function ctc59m01_brrtipflg(param) 
------------------------------------ 
 
 define param      record 
    cidsedcod         like datrcidsed.cidsedcod, 
    brrtipflg         like datrcidsed.brrtipflg 
 end record 
  
 define l_erro smallint 
 let l_erro = false 
 
 whenever error continue 
 update datrcidsed set brrtipflg = param.brrtipflg 
 where cidsedcod = param.cidsedcod 
 whenever error stop 
  
 if sqlca.sqlcode > 0 then 
     let l_erro = true 
 end if 
 
 return l_erro 
 
end function  #  ctc59m01_brrtipflg 
 
#---------------------------------------#
 function  ctc59m01_verifica_usu(l_param)
#---------------------------------------#
     define l_funmat    like datmservico.funmat,
            l_param     like datmservico.funmat,
            l_sql       char(300)
 
     #if  m_prepare is null or 
     #    m_prepare <> true then 
     #    call  ctc59m01_prepare()
     #end if
     let l_sql = "select cpodes ",
                  " from iddkdominio ",
                 " where cponom = 'PSOBRRIDXSEDECID' "

     prepare pctc59m0121  from l_sql
     declare cctc59m0121  cursor for pctc59m0121
     
     open cctc59m0121
     foreach cctc59m0121 into l_funmat
         if  l_funmat = l_param then
             return true
         end if
     end foreach
     return false
 end function 
 
#---------------------------------------#
 function  ctc59m01_verifica_usu_qrv2(l_param)
#---------------------------------------#
     define l_funmat    like datmservico.funmat,
            l_param     like datmservico.funmat,
            l_sql       char(300)

     let l_sql = "select cpodes ",
                 " from iddkdominio ",
                 " where cponom = 'GSTSEDQRV2' "

     prepare pctc59m0122  from l_sql
     declare cctc59m0122  cursor for pctc59m0122
     
     open cctc59m0122
     foreach cctc59m0122 into l_funmat
         if  l_funmat = l_param then
             return true
         end if
     end foreach
     return false
 end function 

#---------------------------------------#
 function  ctc59m01_qrv2(param)
#---------------------------------------#

 define param record
     cidsedcod like dpmmqrvsgnprt.cidsedcod,
     atualiza  smallint
 end record
 
 define ctc59m01_qrv2 record
      cidsedqrvseq like dpmmqrvsgnprt.cidsedqrvseq,
      dtvdat       like dpmmqrvsgnprt.dtvdat   ,
      dtvfunmat    like dpmmqrvsgnprt.dtvfunmat,
      dtvfunempcod like dpmmqrvsgnprt.dtvfunempcod
 end record
 
 define l_sql       char(300), 
        l_hora      datetime hour to second
 
 let l_hora = current

 let l_sql = "update dpmmqrvsgnprt set dtvdat    = today  ,",
             "                         dtvhor    = current,",
             "                         dtvfunmat = ?      ,",
             "                         dtvfunempcod = ?   ,",
             "                         dtvfunusrtip = ?    ",
             " where cidsedcod     = ?",
             "   and cidsedqrvseq  = ?"
 prepare pctc59m0123  from l_sql
 
 let l_sql = "insert into dpmmqrvsgnprt(     ",
             "                  cidsedcod   ,",
             "                  cidsedqrvseq,",
             "                  atvdat      ,",
             "                  atvhor      ,",
             "                  atvfunempcod,",
             "                  atvfunmat   ,",
             "                  atvfunusrtip)",
             "        values  (?,?,today,current,?,?,?)"
 prepare pctc59m0124  from l_sql
 
 whenever error continue
 select max(cidsedqrvseq)
   into ctc59m01_qrv2.cidsedqrvseq
   from dpmmqrvsgnprt
  where cidsedcod = param.cidsedcod
 
 select dtvdat, dtvfunmat,dtvfunempcod
   into ctc59m01_qrv2.dtvdat,ctc59m01_qrv2.dtvfunmat,ctc59m01_qrv2.dtvfunempcod
   from dpmmqrvsgnprt
  where cidsedcod = param.cidsedcod
    and cidsedqrvseq = ctc59m01_qrv2.cidsedqrvseq
 whenever error stop
                        
 if sqlca.sqlcode = notfound then
    if param.atualiza = 1 then
       whenever error continue
       execute pctc59m0124 using param.cidsedcod,
                                 '1',
                                 g_issk.empcod,
                                 g_issk.funmat,
                                 g_issk.usrtip
                             
       if sqlca.sqlcode <> 0 then
         error "Erro Insert [",sqlca.sqlcode,"] - ctc59m01_qrv2()"
         whenever error stop
         return
       end if
       whenever error stop
       
       display "QRV2 ATIVO" to atdqrvflg
       return
    else
       display "QRV2 INATIVO" to atdqrvflg
       return                             
    end if
 end if
 whenever error stop
 
 if (ctc59m01_qrv2.dtvdat is null or ctc59m01_qrv2.dtvdat = ' ')      and
    (ctc59m01_qrv2.dtvfunmat is null or ctc59m01_qrv2.dtvfunmat = '') then

    if param.atualiza = 1 then
       whenever error continue
              
       execute pctc59m0123 using g_issk.funmat,
                                 g_issk.empcod,
                                 g_issk.usrtip,
                                 param.cidsedcod,
                                 ctc59m01_qrv2.cidsedqrvseq
       
       if sqlca.sqlcode <> 0 then
         error "Erro Update [",sqlca.sqlcode,"] - ctc59m01_qrv2()"
         whenever error stop
         return
       end if
       whenever error stop
       
       display "QRV2 INATIVO" to atdqrvflg
    else
       display "QRV2 ATIVO" to atdqrvflg
    end if
 else  
    if param.atualiza = 1 then
       let ctc59m01_qrv2.cidsedqrvseq =  ctc59m01_qrv2.cidsedqrvseq + 1
       whenever error continue
       execute pctc59m0124 using param.cidsedcod,
                                 ctc59m01_qrv2.cidsedqrvseq ,
                                 g_issk.empcod,
                                 g_issk.funmat,
                                 g_issk.usrtip
                             
       if sqlca.sqlcode <> 0 then
         error "Erro Insert [",sqlca.sqlcode,"] - ctc59m01_qrv2()"
         whenever error stop
         return
       end if
       whenever error stop
       
       display "QRV2 ATIVO" to atdqrvflg
    else
       display "QRV2 INATIVO" to atdqrvflg
    end if
 end if
end function

#---------------------------------------#
 function  ctc59m01_verifica_usu_blq(l_param)
#---------------------------------------#
     define l_funmat    like datmservico.funmat,
            l_param     like datmservico.funmat,
            l_sql       char(300)

     let l_sql = "select cpodes ",
                 " from iddkdominio ",
                 " where cponom = 'GSTBLQCIDSED' "

     prepare pctc59m0125  from l_sql
     declare cctc59m0125  cursor for pctc59m0125
     
     open cctc59m0125
     foreach cctc59m0125 into l_funmat
         if  l_funmat = l_param then
             return true
         end if
     end foreach
     return false
 end function
 
#---------------------------------------#
 function  ctc59m01_blqcidsed(param)
#---------------------------------------#

 define param record
     cidsedcod like datrcidsed.cidsedcod, 
     cponom    like datkdominio.cponom,
     atualiza  smallint
 end record
 
 define l_sql    char(300),
        l_cpodes like datkdominio.cpodes,       
        l_cpocod like datkdominio.cpocod,
        l_atlult like datkdominio.atlult,
        retorno smallint
 
 let l_sql = "select cpodes,     ", 
             "       cpocod      ",
             "  from datkdominio ",
             " where cponom = ?  ",
             "   and cpodes = ?  "
 prepare pctc59m0126  from l_sql
 declare cctc59m0126  cursor for pctc59m0126
 
 #VERIFICA SE BLOQUEIO ESTA LIBERADO NA CIDADE SEDE
 open cctc59m0126 using param.cponom,  
                        param.cidsedcod
 fetch cctc59m0126 into l_cpodes, l_cpocod
 
 if sqlca.sqlcode = notfound then
    let retorno = false
 else
    let retorno = true
 end if
 
 close cctc59m0126
 
 if param.atualiza then
    if retorno then
       whenever error continue
       
       delete from datkdominio
       where cponom = param.cponom
         and cpocod = l_cpocod
         
       if sqlca.sqlcode <> 0 then
          error "Erro ao retirar bloqueio da cidade sede. Contactar a Informatica"
          let retorno = true
       else
          error "Operacao realizada com sucesso"  
          let retorno = false        
       end if
              
       whenever error stop
    else
       whenever error continue
       
       let l_atlult = f_fungeral_atlult()
       
       select max(cpocod)                       
         into l_cpocod                          
         from datkdominio                       
        where cponom = param.cponom             
       
       if l_cpocod is null then
          let l_cpocod = 0
       end if
       
       let l_cpocod = l_cpocod + 1
       
       insert into datkdominio(cponom,
                               cpocod,
                               cpodes,
                               atlult)
                       values (param.cponom,
                               l_cpocod,
                               param.cidsedcod,
                               l_atlult)
                               
       if sqlca.sqlcode <> 0 then
          error "Erro ao cadastrar bloqueio na cidade sede. Contactar a Informatica"
          let retorno = false          
       else
          error "Operacao realizada com sucesso" 
          let retorno = true         
       end if
       
       whenever error stop
    end if 
 end if
 
 return retorno
 
end function