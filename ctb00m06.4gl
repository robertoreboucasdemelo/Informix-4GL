#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema..: Porto Socorro                                                   #
# Modulo...: ctb00m06                                                        #
# Objetivo.: Conferencia de dados obrigatorios para a emissao da OP no People#
# Analista.: Fabio Costa                                                     #
# PSI      : 198404                                                          #
# Liberacao: 30/06/2009                                                      #
#............................................................................#
# Alteracoes                                                                 #
#----------------------------------------------------------------------------#
database porto

#----------------------------------------------------------------
function ctb00m06_confere_cadastro(l_param)
#----------------------------------------------------------------

  define l_param record
         tipo       char(02)                  ,
         lcvcod     like datklcvfav.lcvcod    ,
         aviestcod  like datklcvfav.aviestcod ,
         pstcoddig  like dpaksocor.pstcoddig
  end record
  
  define l_confere record
         pisnum     decimal(12,0),
         muninsnum  char(20)     ,
         nitnum     decimal(12,0)
  end record
  
  define l_cadastro record
         txtpismun  char(20) ,
         txtlabel   char(41) ,
         txtaux01   char(31)
  end record
  
  define l_cad       smallint ,
         l_err       smallint ,
         l_msg       char(80) ,
         l_tipo      char(01) , 
         l_sqlca     smallint , 
         l_sqlerr    smallint ,
         l_confirma  char (01)
         
  let l_cad = 0
  initialize l_cadastro.*, l_confere.*, l_confirma, l_err, l_msg to null
  
  let l_param.tipo = upshift(l_param.tipo)
  
  if l_param.tipo = 'PP' or l_param.tipo = 'IP'  # PIS prestador / Inscr prestador
     then
     
     call ctd12g00_dados_pst2(4, l_param.pstcoddig)
          returning l_sqlca, l_msg, l_confere.pisnum, l_confere.nitnum,
                    l_confere.muninsnum
                    
     if l_sqlca != 0
        then
        return l_sqlca, 'Erro na seleção do prestador'
     end if
     
     if l_param.tipo = 'PP'
        then
        let l_cadastro.txtaux01 = 'PIS do prestador'
        if (l_confere.pisnum is null or l_confere.pisnum <= 0) and
           (l_confere.nitnum is null or l_confere.nitnum <= 0)
           then
           let l_cad = 1
        end if
     else
        let l_cadastro.txtaux01 = 'INSCR. MUNCIPAL do prestador'
        if l_confere.muninsnum is null or
           l_confere.muninsnum = ' '
           then
           let l_cad = 1
        end if
     end if
     
  else
  
     if l_param.tipo = 'IF'  # Inscr favorecido
        then
        
        call ctd19g02_lcvfav_sel(1, l_param.lcvcod, l_param.aviestcod)
             returning l_sqlca, l_confere.muninsnum
             
        if l_sqlca != 0
           then
           return l_sqlca, 'Erro na selecao do favorecido'
        end if
        
        let l_cadastro.txtaux01 = 'INSCR. MUNCIPAL do favorecido'
        if l_confere.muninsnum is null or
           l_confere.muninsnum = ' '
           then
           let l_cad = 1
        end if
     else
        error " Tipo de alteracao nao definida em CTB00M06 "
        return 999, l_msg
     end if
     
  end if
  
  if l_cad = 1
     then
     
     error ' ', l_cadastro.txtaux01 clipped, ' está nulo, necessário cadastrar '
     sleep 1
     
     let l_cadastro.txtlabel = 'Cadastrar ', l_cadastro.txtaux01 clipped
     
     open window w_ctb00m06 at 12,18 with form "ctb00m06"
     attribute(form line 1, border, message line last - 1)
     
     message " (Ctrl+C) Abandona "
     
     display by name l_cadastro.txtlabel
     
     let int_flag = false
     
     input by name l_cadastro.txtpismun without defaults
     
        before field txtpismun
           initialize l_cadastro.txtpismun to null
           display by name l_cadastro.txtpismun attribute(reverse)
           
        after field txtpismun
           display by name l_cadastro.txtpismun
           
           if l_cadastro.txtpismun is null or
              l_cadastro.txtpismun = ' '   or
              l_cadastro.txtpismun = '0'
              then
              error ' Número não pode ser nulo ou zero '
              #sleep 1
              next field txtpismun
           end if
           
           if l_param.tipo[1] = 'P' and
              length(l_cadastro.txtpismun) > 12
              then
              error ' Número de PIS até 12 caracteres '
              #sleep 1
              next field txtpismun
           end if
           
           if l_param.tipo[1] = 'P'
              then
              initialize l_tipo to null
              call ctb00m06_tipo_valor(l_cadastro.txtpismun) returning l_tipo
              if l_tipo != 'N'
                 then
                 error ' Digite apenas valores numéricos para o cadastro de PIS '
                 #sleep 1
                 next field txtpismun
              end if
           end if
           
           call cts08g01("C","S","","CONFIRMA ATUALIZAÇÃO ?", "","")
               returning l_confirma
               
           if l_confirma = 'S'
              then
              begin work
              
              case l_param.tipo
                 when 'PP'
                    call ctd12g00_pst_upd('pisnum', l_cadastro.txtpismun, 'N',
                                          l_param.pstcoddig)
                                returning l_sqlca, l_sqlerr
                
                 when 'IP'
                    call ctd12g00_pst_upd('muninsnum', l_cadastro.txtpismun, 
                                          'A', l_param.pstcoddig)
                                returning l_sqlca, l_sqlerr
                 
                 when 'IF'
                    call ctd19g02_lcvfav_upd('mncinscod', 
                                             l_cadastro.txtpismun,
                                             'A',
                                             l_param.lcvcod,
                                             l_param.aviestcod)
                                   returning l_sqlca, l_sqlerr
              end case
              
              if l_sqlca != 0 or l_sqlerr != 1
                 then
                 rollback work
                 let l_err = l_sqlca
                 let l_msg = ' Erro na atualização: ', l_sqlca using "<<<<<<"
                           , ' | qtd:', l_sqlerr using "<<<<<<"
                 sleep 1
                 next field txtpismun
              else
                 commit work
                 let l_err = 0
                 let l_msg = ' Atualização realizada com sucesso '
                 sleep 1
              end if
           else
              let l_msg = ' Alteração cancelada'
              let l_err = 999
           end if
           
        on key (interrupt)
           exit input
           
     end input
     
     if int_flag
        then
        let int_flag = false
        let l_msg = ' Alteração cancelada'
        let l_err = 999
     end if
     
     close window w_ctb00m06
     
  end if
  
  return l_err, l_msg
  
end function

# testar se valor na string e texto, numerico ou alfanumerico
#----------------------------------------------------------------
function ctb00m06_tipo_valor(l_valor)
#----------------------------------------------------------------

  define l_valor  char(12)
  
  define l_tipo record
         temnum  smallint , 
         temtxt  smallint ,
         tipo    char(01)  # A - Alfanumerico, N - Numerico, T - Texto
  end record
  
  define l_ctt smallint
  
  initialize l_tipo.* to null
  
  let l_ctt = 1
  let l_tipo.temnum = 0
  let l_tipo.temtxt = 0
  
  for l_ctt = 1 to length(l_valor)
     if l_valor[l_ctt] matches "[0-9]"
        then
        let l_tipo.temnum = 1
     else
        let l_tipo.temtxt = 1
     end if
  end for
  
  if l_tipo.temnum = 1 and l_tipo.temtxt = 1
     then
     let l_tipo.tipo = 'A'
  else
     if l_tipo.temnum = 1
        then
        let l_tipo.tipo = 'N'
     end if
     
     if l_tipo.temtxt = 1
        then
        let l_tipo.tipo = 'T'
     end if
  end if
  
  return l_tipo.tipo
  
end function

