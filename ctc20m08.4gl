#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#------------------------------------------------------------------------------#
# Sistema    : PORTO SOCORRO                                                   #
# Modulo     : ctc20m08.4gl                                                    #
# Objetivo   : Cadastro generico de pârametros para critérios de bonificação   #
#              nos grupos de serviço. Tratamento específico por critério       #
# Projeto    : PSI 258610                                                      #
# Analista   : Fabio Costa                                                     #
# Liberacao  : 31/08/2010                                                      #
#------------------------------------------------------------------------------#
# ALTERACOES                                                                   #
# Data        Responsavel         PSI     Alteracao                            #
# ----------  ------------------  ------  -------------------------------------#
#------------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_array  array[08] of record
       param   char(25) ,
       vlrdec  dec(5,2) ,
       unidad  char(07) ,
       atldat  date     ,
       funnom  char(20)
end record

define m_ctc20m08  array[08] of record
       vlrant  dec(5,2) ,
       insere  smallint ,
       relsgl  char(18) ,
       prtbnfgrpcod  integer
end record

define m_tela record
       titulo  char(78) ,
       cabec   char(74) ,
       msg     char(74)
end record

define m_aux record
       txtupd    char(57) ,
       txtwhe    char(70) ,
       qtdpar    smallint ,
       confirma  char(01) ,
       funnom    char(20)
end record
  
define m_cur integer ,
       m_src integer

#----------------------------------------------------------------
function ctc20m08(l_param)
#----------------------------------------------------------------

  define l_param record
         prtbnfgrpcod  integer  ,
         prtbnfgrpdes  char(50) ,
         bnfcrtcod     integer  ,
         bnfcrtdes     char(50)
  end record
  
  define l_ctd30g00 record
         sqlcode      integer  ,
         sqlerrd      integer  ,
         relpamtxt01  char(100),
         relpamtxt02  char(100)
  end record
  
  define l_ret record
         sqlcode  integer  ,
         sqlerrd  integer  ,
         msg      char(100)
  end record
  
  define arr_aux, ctt_aux integer
  
  initialize l_ctd30g00.*, l_ret.* to null
  initialize m_ctc20m08 to null
  initialize m_array to null
  initialize m_aux.* to null
  initialize m_tela.* to null
  
  let m_cur = 0
  let m_src = 0

  let m_aux.txtupd[01,01] = '|'
  let m_aux.txtupd[02,03] = l_param.bnfcrtcod using "&&"
  let m_aux.txtupd[04,04] = '|'
  let m_aux.txtupd[05,06] = l_param.prtbnfgrpcod using "&&"
  let m_aux.txtupd[07,07] = '|'
  let m_aux.txtwhe = ' and relpamtxt matches "*', m_aux.txtupd clipped, '*"'
  
  # formato dos parametros dos criterios de bonificacao
  # Ex: |06|01|020.00|%      |07/07/2010|009179|Luis Melo       |

  # obter nome do operador atual
  call cty08g00_nome_func(1, g_issk.usrcod, 'F')
       returning l_ret.sqlcode, l_ret.msg, m_aux.funnom
       
  if l_ret.sqlcode is null or l_ret.sqlcode != 1
     then
     error ' Erro na consulta ao operador: ', l_ret.msg clipped
     sleep 2
     return
  end if
  
  let m_ctc20m08[01].insere = 1  # considera registro existente
  let m_ctc20m08[02].insere = 1  # considera registro existente
  
  # configuracao para criterio Pontualidade
  if l_param.bnfcrtcod = 6
     then
     initialize l_ctd30g00.* to null
     
     # valores fixos
     let m_ctc20m08[01].prtbnfgrpcod = l_param.prtbnfgrpcod
     let m_ctc20m08[01].relsgl = 'CRTBNFTOLPNT'
     
     # valores fixos
     let m_aux.qtdpar = 1
     let m_array[01].param  = 'Margem de tolerância    :'
     let m_array[01].unidad = '%      '
     
     call ctd30g00_sel_igbm_whe(1, m_ctc20m08[01].relsgl, m_ctc20m08[01].prtbnfgrpcod, 1, m_aux.txtwhe clipped)
          returning l_ctd30g00.sqlcode, l_ctd30g00.relpamtxt01
     
     if l_ctd30g00.sqlcode != 0
        then
        if l_ctd30g00.sqlcode = 100
           then
           error ' Tolerância não cadastrada para ', l_param.bnfcrtdes clipped, 
                 ' grupo ', l_param.prtbnfgrpdes clipped, ' '
                 
           let m_ctc20m08[01].insere = 99
           
           let m_array[01].atldat = today using "dd/mm/yyyy"
           let m_array[01].funnom = m_aux.funnom
        else
           error ' Erro na consulta a tolerância: ', l_ctd30g00.sqlcode
           return
        end if
     else
        let m_array[01].vlrdec = l_ctd30g00.relpamtxt01[8,13]
        let m_ctc20m08[01].vlrant = m_array[01].vlrdec
        let m_array[01].atldat = l_ctd30g00.relpamtxt01[23,32]
        let m_array[01].funnom = l_ctd30g00.relpamtxt01[41,56]
     end if
  end if

  # configuracao para criterio Telemetria
  if l_param.bnfcrtcod = 8
     then
     initialize l_ctd30g00.* to null
     
     # valores fixos
     let m_aux.qtdpar = 2
     let m_ctc20m08[01].relsgl = 'CRTBNFTOLRECINI'
     let m_ctc20m08[02].relsgl = 'CRTBNFTOLINIFIM'
     let m_array[01].param  = 'Intervalo REC / INI     :'
     let m_array[02].param  = 'Intervalo INI / FIM     :'
     let m_array[01].unidad = 'min    '
     let m_array[02].unidad = 'min    '
     let m_ctc20m08[01].prtbnfgrpcod = l_param.prtbnfgrpcod
     let m_ctc20m08[02].prtbnfgrpcod = l_param.prtbnfgrpcod
     
     call ctd30g00_sel_igbm_whe(1, m_ctc20m08[01].relsgl, m_ctc20m08[01].prtbnfgrpcod, 1, m_aux.txtwhe clipped)
          returning l_ctd30g00.sqlcode, l_ctd30g00.relpamtxt01
     
     if l_ctd30g00.sqlcode != 0
        then
        if l_ctd30g00.sqlcode = 100
           then
           error ' Tolerância REC/INI não cadastrada para ', l_param.bnfcrtdes clipped, 
                 ' grupo ', l_param.prtbnfgrpdes clipped
           sleep 1
           let m_ctc20m08[01].insere = 99
           
           let m_array[01].atldat = today using "dd/mm/yyyy"
           let m_array[01].funnom = m_aux.funnom
        else
           error ' Erro na consulta a tolerância REC/INI: ', l_ctd30g00.sqlcode
           return
        end if
     else
        let m_array[01].vlrdec = l_ctd30g00.relpamtxt01[8,13]
        let m_ctc20m08[01].vlrant = m_array[01].vlrdec
        let m_array[01].atldat = l_ctd30g00.relpamtxt01[23,32]
        let m_array[01].funnom = l_ctd30g00.relpamtxt01[41,56]
     end if
     
     initialize l_ctd30g00.* to null
     
     call ctd30g00_sel_igbm_whe(1, m_ctc20m08[02].relsgl, m_ctc20m08[02].prtbnfgrpcod, 1, m_aux.txtwhe clipped)
          returning l_ctd30g00.sqlcode, l_ctd30g00.relpamtxt02
     
     if l_ctd30g00.sqlcode != 0
        then
        if l_ctd30g00.sqlcode = 100
           then
           error ' Tolerância REC/FIM não cadastrada para ', l_param.bnfcrtdes clipped, 
                 ' grupo ', l_param.prtbnfgrpdes clipped
           let m_ctc20m08[02].insere = 99
           
           let m_array[02].atldat = today using "dd/mm/yyyy"
           let m_array[02].funnom = m_aux.funnom
        else
           error ' Erro na consulta a tolerância REC/FIM: ', l_ctd30g00.sqlcode
           return
        end if
     else
        let m_array[02].vlrdec = l_ctd30g00.relpamtxt02[8,13]
        let m_ctc20m08[02].vlrant = m_array[02].vlrdec
        let m_array[02].atldat = l_ctd30g00.relpamtxt02[23,32]
        let m_array[02].funnom = l_ctd30g00.relpamtxt02[41,56]
     end if
  end if
  
  # montar cabecalho da tela
  let m_tela.titulo        = 'CRITERIO: ', l_param.bnfcrtdes clipped
  let m_tela.titulo[33,36] = ' |  '
  let m_tela.titulo[37,78] = 'GRUPO DE SERVICOS: ', l_param.prtbnfgrpdes clipped 
  let m_tela.cabec    = 'Parâmetro                  Valor  Unidade   Data alt.     Usuário alt.'
  let m_tela.msg      = '                    (Ctrl + C)Sair     (F8)Gravar'
  
  open window w_ctc20m08 at 4,2 with form "ctc20m08"
       attribute(form line first)
 
     let int_flag = false
     
     display by name m_tela.titulo
     display by name m_tela.cabec 
     display by name m_tela.msg
     
     while true
     
        input array m_array without defaults from s_ctc20m08.*
                                                  
           before input
              let m_cur = arr_curr()
              let m_src = scr_line()
              call ctc20m08_display()
              
           before row
              let m_cur = arr_curr()
              let m_src = scr_line()
              
           before insert
              if m_ctc20m08[m_cur].insere = 1
                 then
                 error ' Parâmetro existente só é possível a edição do valor '
                 next field vlrdec
              end if
              
           before delete
              if m_ctc20m08[m_cur].insere = 1
                 then
                 call cts08g01("C", "F" , "",
                               "CONFIRMA A EXCLUSAO DO VALOR","SELECIONADO ?","")
                      returning m_aux.confirma
                      
                 if m_aux.confirma = "S"
                    then
                    call ctd30g00_del_igbm(m_ctc20m08[m_cur].relsgl, m_ctc20m08[m_cur].prtbnfgrpcod, 1)
                         returning l_ret.sqlcode, l_ret.sqlerrd
                         
                    if l_ret.sqlcode != 0
                       then
                       error ' Erro na exclusão do registro: ', l_ret.sqlcode
                       let m_array[m_cur].vlrdec = m_ctc20m08[m_cur].vlrant
                    else
                       error ' Parâmetro deletado '
                       sleep 1
                       let m_array[m_cur].vlrdec = 0
                       let int_flag = true
                    end if
                 else
                    error ' Exclusão cancelada '
                    sleep 1
                    let int_flag = true
                 end if
              else
                 error ' Parâmetro não cadastrado na base de dados, só é possível a inclusão do valor '
                 next field vlrdec
              end if
              
           if int_flag 
              then
              exit input
           end if
           
           before field vlrdec
              let arr_aux = arr_curr()
              let ctt_aux = arr_count()
              
           after field vlrdec
              if m_array[m_cur].vlrdec is null
                 then
                 error ' O valor deve ser informado '
                 next field vlrdec
              end if
              
              if
                 ( fgl_lastkey() = fgl_keyval("DOWN")   or
                   fgl_lastkey() = fgl_keyval("RIGHT")  or
                   fgl_lastkey() = fgl_keyval("RETURN") or
                   fgl_lastkey() = fgl_keyval("TAB") ) and
                 arr_aux = m_aux.qtdpar
                 then
                 error ' Para salvar a alteração tecle F8 '
                 next field vlrdec
              end if
              
           on key(F8)
              call ctc20m08_editar()
           
           if int_flag 
              then
              exit input
           end if
           
        end input
        
        if int_flag 
           then
           let int_flag = false
           exit while
        end if
        
     end while

  initialize m_ctc20m08 to null
  initialize m_array to null
  initialize m_aux.* to null
  initialize m_tela.* to null
  
  close window w_ctc20m08

end function
 
#----------------------------------------------------------------
function ctc20m08_display()
#----------------------------------------------------------------

  define l_ct integer
  
  initialize l_ct to null
  
  for l_ct = 1 to m_aux.qtdpar
     display m_array[l_ct].param  to s_ctc20m08[l_ct].param 
     display m_array[l_ct].vlrdec to s_ctc20m08[l_ct].vlrdec
     display m_array[l_ct].unidad to s_ctc20m08[l_ct].unidad
     display m_array[l_ct].atldat to s_ctc20m08[l_ct].atldat
     display m_array[l_ct].funnom to s_ctc20m08[l_ct].funnom
  end for
  
end function

#----------------------------------------------------------------
function ctc20m08_editar()
#----------------------------------------------------------------

  define l_ct      integer  ,
         l_txtupd  char(57) ,
         l_erros   smallint
  
  define l_ret record
         sqlcode  integer  ,
         sqlerrd  integer  ,
         msg      char(100)
  end record
  
  define l_ctd30g00 record
         sqlcode      integer  ,
         sqlerrd      integer  ,
         relpamtxt01  char(100),
         relpamtxt02  char(100)
  end record
  
  initialize l_txtupd to null
  initialize l_ret.*, l_ctd30g00.* to null
  
  let l_ct = 0
  let l_erros = 0
  
  #----------------------------------------------------------------
  # display 'm_aux.txtupd        : ', m_aux.txtupd  
  # display 'm_aux.txtwhe        : ', m_aux.txtwhe  
  # display 'm_aux.qtdpar        : ', m_aux.qtdpar  
  # display 'm_aux.confirma      : ', m_aux.confirma
  # display 'm_aux.funnom        : ', m_aux.funnom  
  #----------------------------------------------------------------
  
  begin work
  
  for l_ct = 1 to m_aux.qtdpar
  
     initialize l_txtupd to null
     initialize l_ret.*, l_ctd30g00.* to null
     
     # retirar
     #----------------------------------------------------------------
     display ' ENTROU FUNCAO '
     
     display 'm_array[l_ct].param    : ',  m_array[l_ct].param 
     display 'm_array[l_ct].vlrdec   : ',  m_array[l_ct].vlrdec
     display 'm_array[l_ct].unidad   : ',  m_array[l_ct].unidad
     display 'm_array[l_ct].atldat   : ',  m_array[l_ct].atldat
     display 'm_array[l_ct].funnom   : ',  m_array[l_ct].funnom
     
     display 'm_ctc20m08[l_ct].vlrant: ',  m_ctc20m08[l_ct].vlrant
     display 'm_ctc20m08[l_ct].insere: ',  m_ctc20m08[l_ct].insere
     display 'm_ctc20m08[l_ct].relsgl: ',  m_ctc20m08[l_ct].relsgl
     display 'm_ctc20m08[l_ct].prtbnfgrpcod: ', m_ctc20m08[l_ct].prtbnfgrpcod
     #----------------------------------------------------------------
     
     if m_ctc20m08[l_ct].vlrant is null  or
        m_array[l_ct].vlrdec != m_ctc20m08[l_ct].vlrant
        then
        
        let l_txtupd[01,07] = m_aux.txtupd[01,07]
        let l_txtupd[08,13] = m_array[l_ct].vlrdec using "&&&.&&"
        let l_txtupd[14,14] = '|' 
        let l_txtupd[15,21] = m_array[l_ct].unidad
        let l_txtupd[22,22] = '|'
        let l_txtupd[23,32] = today using "dd/mm/yyyy"
        let l_txtupd[33,33] = '|'
        let l_txtupd[34,39] = g_issk.usrcod
        let l_txtupd[40,40] = '|'
        let l_txtupd[41,56] = m_aux.funnom clipped
        let l_txtupd[57,57] = '|'
        
        if m_ctc20m08[l_ct].insere = 99
           then
           call ctd30g00_ins_igbm(m_ctc20m08[l_ct].relsgl, m_ctc20m08[l_ct].prtbnfgrpcod, 1, l_txtupd)
                returning l_ctd30g00.sqlcode
                
           if l_ctd30g00.sqlcode != 0
              then
              let l_erros = l_erros + 1
              error ' Erro na inserção da tolerância: ', l_ctd30g00.sqlcode
              exit for
           else
              let m_array[l_ct].vlrdec = m_ctc20m08[l_ct].vlrant
           end if
        else
           call ctd30g00_upd_igbm(m_ctc20m08[l_ct].relsgl, m_ctc20m08[l_ct].prtbnfgrpcod, 1, l_txtupd)
                returning l_ctd30g00.sqlcode, l_ctd30g00.sqlerrd
                
           if l_ctd30g00.sqlcode != 0 or l_ctd30g00.sqlerrd != 1
              then
              let l_erros = l_erros + 1
              error ' Erro na atualização da tolerância: ', l_ctd30g00.sqlcode
              exit for
           else
              let m_array[l_ct].vlrdec = m_ctc20m08[l_ct].vlrant
           end if
        end if
     end if
     
  end for
  
  if l_erros > 0
     then
     rollback work
     error ' Erro na atualização da tolerância: ', l_ctd30g00.sqlcode
  else
     commit work
     error ' Tolerância atualizada com sucesso '
  end if
  
end function
