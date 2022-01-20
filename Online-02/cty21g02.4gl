###############################################################################
# Nome do Modulo: cty21m01                                    Helder Oliveira #
#                                                                             #
# Comparacao de proposta                                             Jan/2011 #
###############################################################################
#                             ALTERACOES                                      #
#                             ----------                                      #
# Data         Autor         PSI             Descrição                        #
# -----------  ------------- -------------   -------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#
#                                                                             #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define l_proposta1  char(15)
define l_proposta2  char(15)

define m_prep     smallint

define m_org1        like  gppmppwtrxhst.prporg     
define m_propnum1    like  gppmppwtrxhst.prpnumdig  
define m_ppwpro1     like  gppmppwtrx.ppwprpnum
define m_corsus1     like  gppmppwtrx.corsus

define m_org2        like  gppmppwtrxhst.prporg     
define m_propnum2    like  gppmppwtrxhst.prpnumdig  
define m_ppwpro2     like  gppmppwtrx.ppwprpnum
define m_corsus2     like  gppmppwtrx.corsus
define l_seq1      like    gppmnetprpcpaaut.ppwtrxqtd
define l_seq2      like    gppmnetprpcpaaut.ppwtrxqtd


define m_flag     smallint
 
define am_cty21g02  array[500] of record       #array que faz o input by name
       marca        char(001)
      ,ppwtrxhordat char(022)
      ,ppwtrxqtd    smallint
      ,sitdesc      varchar(030)
      ,ppwprpsit    smallint
end record 
 
define am_cty21g02_1  array[500] of record     #array que pega dados da Primeira proposta
       marca        char(001)
      ,ppwtrxhordat char(022)
      ,ppwtrxqtd    smallint
      ,sitdesc      varchar(030)
      ,ppwprpsit    smallint
end record

define am_cty21g02_2  array[500] of record     #array que pega dados da Segunda proposta
       marca        char(001)
      ,ppwtrxhordat char(022)
      ,ppwtrxqtd    smallint
      ,sitdesc      varchar(030)
      ,ppwprpsit    smallint
end record

#============================
function cty21g02_prepare()
#============================
define l_sql char(500)
  
 let l_sql = '   select distinct t.ppwprpnum,            '
            ,'                   t.corsus                '
            ,'     from gppmppwtrx t,                    '
            ,'          gppmppwtrxhst h                  '
            ,'    where h.prporg    = ?                  '
            ,'      and h.prpnumdig = ?                  '
            ,'      and t.prpnumdig = h.prpnumdig        '
            ,'      and t.ramcod    = h.ramcod           '
            ,'      and t.rmemdlcod = h.rmemdlcod        '
            ,'      and t.corsus    = h.corsus           '
            ,'      and t.ppwprpnum = h.ppwprpnum        '
 prepare pcty21g02001 from l_sql              
 declare ccty21g02001 cursor for pcty21g02001
 
 let l_sql = ' select ppwtrxhordat,                      '
            ,'        ppwtrxqtd,                         '
            ,'        ppwprpsit                          '
            ,'  from gppmnetprpcpaaut                    '
            ,' where corsus = ?                          '
            ,'   and ppwprpnum = ?                       '
  prepare pcty21g02002 from l_sql                 
  declare ccty21g02002 cursor for pcty21g02002
 
  let l_sql = ' select count(cpodes)        '
             ,'  from datkdominio           '
             ,' where cponom = "comp_perm"  '
             ,'   and cpodes = ?            '
  prepare pcty21g02003 from l_sql                 
  declare ccty21g02003 cursor for pcty21g02003

 let m_prep = 1

end function

#============================================================================
function cty21g02_entrada_dados( l_org1 , l_propnum1 , l_org2 , l_propnum2)
#============================================================================
define l_org1     like  gppmppwtrxhst.prporg    
define l_propnum1 like  gppmppwtrxhst.prpnumdig  
define l_org2     like  gppmppwtrxhst.prporg    
define l_propnum2 like  gppmppwtrxhst.prpnumdig  
 
 let m_org1     = l_org1
 let m_propnum1 = l_propnum1
 let m_org2     = l_org2
 let m_propnum2 = l_propnum2
 
   
 open window w_cty21g02 at 6,2 with form 'cty21g02'
             attribute(form line first, comment line last -1)
 
 display 'COMPARACAO DE PROPOSTA' at 1,29
 
# display 'funmat:',g_issk.funmat sleep 3
 
 call cty21g02_seleciona_proposta1()

 return true
 
end function

#============================================================================
function cty21g02_seleciona_proposta1()
#============================================================================
define l_index     smallint

  if m_prep <> 1 then
     call cty21g02_prepare()
  end if
  
  initialize am_cty21g02_1 to null
  let m_flag = 1

 
 #selects aqui de acordo coma  1° proposta
 
   open ccty21g02001 using m_org1
                         , m_propnum1
   
   fetch ccty21g02001 into m_ppwpro1
                         , m_corsus1  
   
   
   let l_index = 1
   
   open ccty21g02002 using  m_corsus1
                         ,  m_ppwpro1
   
   foreach ccty21g02002 into am_cty21g02_1[l_index].ppwtrxhordat
                           , am_cty21g02_1[l_index].ppwtrxqtd   
                           , am_cty21g02_1[l_index].ppwprpsit   
 
          case am_cty21g02_1[l_index].ppwprpsit 
              when 0    
                   let am_cty21g02_1[l_index].sitdesc = "- Em Transmissao" 

              when 1
                   let am_cty21g02_1[l_index].sitdesc = "- A  Formatar"

              when 2
                   let am_cty21g02_1[l_index].sitdesc = "- Proposta Formatada"

              when 3
                   let am_cty21g02_1[l_index].sitdesc = "- A  Formatar"

              when 4
                   let am_cty21g02_1[l_index].sitdesc = "- Orcamento Formatado"
                   
              when 6                                                   
                   let am_cty21g02_1[l_index].sitdesc = "- Orcamento Formatado"     
                   
              when 99
                   let am_cty21g02_1[l_index].sitdesc = "- A  Formatar"
                   
              when 100 
                   let am_cty21g02_1[l_index].sitdesc = "- Proposta Formatada"
           end case

           let l_index = l_index + 1

   end foreach
   
   let l_proposta1 = m_org1 using '<<' ,'-',m_propnum1 using '<<<<<<<<'
   let l_proposta1 = l_proposta1 clipped
   display l_proposta1 to proposta attribute(reverse)

    call cty21g02_input(l_index)

end function

#========================================
function cty21g02_seleciona_proposta2()
#========================================
define l_index     smallint
      
   if m_prep <> 1 then
     call cty21g02_prepare()
   end if
  
   initialize am_cty21g02_2 to null
   let m_flag = 2
   
   #selects aqui de acordo coma  1° proposta
 
   open ccty21g02001 using m_org2
                         , m_propnum2
   
   fetch ccty21g02001 into m_ppwpro2
                         , m_corsus2  
   
   
   let l_index = 1
   
   open ccty21g02002 using  m_corsus2
                         ,  m_ppwpro2
   
   foreach ccty21g02002 into am_cty21g02_2[l_index].ppwtrxhordat
                           , am_cty21g02_2[l_index].ppwtrxqtd   
                           , am_cty21g02_2[l_index].ppwprpsit   
 
          case am_cty21g02_2[l_index].ppwprpsit 
              when 0    
                   let am_cty21g02_2[l_index].sitdesc = "- Em Transmissao" 

              when 1
                   let am_cty21g02_2[l_index].sitdesc = "- A  Formatar"

              when 2
                   let am_cty21g02_2[l_index].sitdesc = "- Proposta Formatada"

              when 3
                   let am_cty21g02_2[l_index].sitdesc = "- A  Formatar"

              when 4
                   let am_cty21g02_2[l_index].sitdesc = "- Orcamento Formatado"
                   
              when 6                                                   
                   let am_cty21g02_2[l_index].sitdesc = "- Orcamento Formatado"     
                   
              when 99
                   let am_cty21g02_2[l_index].sitdesc = "- A  Formatar"
                   
              when 100 
                   let am_cty21g02_2[l_index].sitdesc = "- Proposta Formatada"
           end case

           let l_index = l_index + 1

   end foreach
        
   open window w_cty21g02a at 15,2 with form 'cty21g02a'
       attribute(form line first, message line last, comment line last -1 )
   
   let l_proposta2 = m_org2 using '<<' ,'-',m_propnum2 using '<<<<<<<<'
   let l_proposta2 = l_proposta2 clipped
   display l_proposta2 to proposta attribute(reverse)          
   
   call cty21g02_input(l_index)      

end function

#============================
function cty21g02_input(l_index)
#============================ 
define l_arrc      smallint
define l_tela      smallint
define l_i         smallint
define l_conta     smallint
define i           smallint
define l_index     smallint
define j           smallint
define l_flg       smallint
define l_resp      smallint

  if m_prep <> 1 then
     call cty21g02_prepare()
  end if
   
   let l_conta = 0
   
   if m_flag = 1 then
      let am_cty21g02.* = am_cty21g02_1.*
   else
      let am_cty21g02.* = am_cty21g02_2.*
   end if   
   
   call set_count(l_index - 1)

   input array am_cty21g02 without defaults from sa_cty21g02.*

       #-----------
        before row
       #-----------
         let l_arrc = arr_curr()
         let l_tela = scr_line()
         
         if am_cty21g02[l_arrc].ppwtrxhordat is null then
            next field marca
         end if
         
         
         call cty21g02_conta_x()
              returning l_conta
         
         if l_conta < 1 then
            message '                  ESOLHA 1 TRANSMISSAO PARA ESSA PROPOSTA '
         else
            if l_conta = 1 then
                  if m_flag = 1 then
                     message '                 (F6) -> SELECIONAR TRANSMISSAO DA 2a PROPOSTA '
                  else
                     #open ccty21g02003 using g_issk.funmat
                     #fetch ccty21g02003 into l_resp
                     
                    # if l_resp > 0 then
                    #   message '   (F5) -> CONFRONTAR DADOS     (F6) -> RESUMO    (F9) -> CONFIGURA RESUMO '                     
                    # else
                        message '             (F5) -> CONFRONTAR DADOS          (F6) -> RESUMO'                     
                    # end if                   
                  end if 
            end if
         end if         
       
       #-----------
        after row
       #-----------
         if (fgl_lastkey() = fgl_keyval("down")    or
             fgl_lastkey() = fgl_keyval("right")   or
             fgl_lastkey() = fgl_keyval("tab")     or
             fgl_lastkey() = fgl_keyval("return")) and
             l_arrc = arr_count()                 then 
             next field marca
         end if 
       
       #--------------------
        before field  marca
       #--------------------
         if l_arrc = arr_count() then
                  if m_flag = 1 then
                     message '                 (F6) -> SELECIONAR TRANSMISSAO DA 2a PROPOSTA '
                  else
                     #open ccty21g02003 using g_issk.funmat
                     #fetch ccty21g02003 into l_resp
                     
                     #if l_resp > 0 then
                     #   message '   (F5) -> CONFRONTAR DADOS     (F6) -> RESUMO    (F9) -> CONFIGURA RESUMO '                     
                     #else
                        message '             (F5) -> CONFRONTAR DADOS          (F6) -> RESUMO'                     
                     #end if
                  end if 
         end if
         
         
       #------------------
        after field marca
       #------------------
           let am_cty21g02[l_arrc].marca = get_fldbuf(marca)
           
           #verifica se tem mais de 2 'X' marcados
           call cty21g02_conta_x()
                 returning l_conta
            
           if l_conta > 1 then
              error 'Só é possivel marcar 1 transmissao para cada proposta'
              let am_cty21g02[l_arrc].marca = ""
              next field marca
           end if
           #-------
            
            if am_cty21g02[l_arrc].marca <> "X" and
               am_cty21g02[l_arrc].marca <> " " then
               error " Digite X para marcar ou ESPACO para desmarcar."
               let am_cty21g02[l_arrc].marca = ""
               next field marca
            end if   
                
            
            display am_cty21g02[l_arrc].marca   to sa_cty21g02[l_tela].marca
       
       #------------------
        on key (interrupt)
       #------------------
          if m_flag = 2 then
             initialize am_cty21g02_2 to null
             let am_cty21g02.* = am_cty21g02_1.*
             #display 'ctrl-c ', l_arrc
          end if
          exit input
       
       #----------- 
        on key (F5)
       #-----------
          let am_cty21g02[l_arrc].marca = get_fldbuf(marca)
  
          if l_arrc = arr_count() then
             call cty21g02_conta_x()
                  returning l_conta
             
             if l_conta <> 1 then
                error 'Selecione uma transmissao'
             end if
          end if  

          if m_flag = 2 then
             call cty21g02_conta_x()
                  returning l_conta
                  
             if l_conta = 1 then
                #comparar os dados 
                 for j = 1 to arr_count()
                  if am_cty21g02[j].marca = 'X' then
                     let l_seq2 = am_cty21g02[j].ppwtrxqtd
                  end if                                           
                 end for

                error "Por Favor, Aguarde! ..." 
                call cty21g03 ( m_ppwpro1   #    Por padrao, funcao pede 2 numeros de
                              , m_ppwpro2   #  proposta, 2 de susep e 2 de sequencia.
                              , m_corsus1   #    Neste caso (de uma so proposta)
                              , m_corsus2   # sera enviado duplicado o numero ppw
                              , l_seq1      # e susep Corretor
                              , l_seq2
                              , l_proposta1
                              , l_proposta2
                              , 'F5'
                              )
             end if
          end if
          
       #----------- 
        on key (F6)
       #-----------
          let am_cty21g02[l_arrc].marca = get_fldbuf(marca)
          if get_fldbuf(marca) is not null then
             let l_arrc = 1
          end if
          
          if m_flag = 1 then
             call cty21g02_conta_x()
                  returning l_conta
                  
             if l_conta = 1 then
             #guarda dados da 1°
                for j = 1 to arr_count()
                  if am_cty21g02[j].marca = 'X' then
                     let l_seq1 = am_cty21g02[j].ppwtrxqtd
                   end if                
                end for
                
                message ' '
                call cty21g02_seleciona_proposta2()
             end if
          
         end if 
        
        
         if m_flag = 2 then
            call cty21g02_conta_x()
                 returning l_conta
                  
             if l_conta = 1 then
                #comparar os dados 
                for j = 1 to arr_count()
                  if am_cty21g02[j].marca = 'X' then
                     let l_seq2 = am_cty21g02[j].ppwtrxqtd
                  end if                                           
                end for

                error "Por Favor, Aguarde! ..." 

                call cty21g03 ( m_ppwpro1   #    Por padrao, funcao pede 2 numeros de
                              , m_ppwpro2   #  proposta, 2 de susep e 2 de sequencia.
                              , m_corsus1   #    Neste caso (de uma so proposta)
                              , m_corsus2   # sera enviado duplicado o numero ppw
                              , l_seq1      # e susep Corretor
                              , l_seq2
                              , l_proposta1
                              , l_proposta2
                              , 'F6'
                              )
          end if
   
         end if
  
  
       #----------- 
       # on key (F9)
       #-----------
       #open ccty21g02003 using g_issk.funmat
       #fetch ccty21g02003 into l_resp
       #              
       # if l_resp > 0 then
       #    call cty21g04() #configuracao da tela resumida         
       # end if
      
           
  
   end input
  
  if m_flag = 1 then
      close window w_cty21g02
  else
      let m_flag = 1
      close window w_cty21g02a
      message '                  ESOLHA 1 TRANSMISSAO PARA ESSA PROPOSTA '
  end if
         
         
end function

#==========================
function cty21g02_conta_x()
#==========================
define l_i     smallint
define l_conta smallint
  
  if m_prep <> 1 then
     call cty21g02_prepare()
  end if
  
  let l_conta = 0

  for l_i = 1 to arr_count()
      if am_cty21g02[l_i].marca = 'X' then
         let l_conta = l_conta + 1
      end if
  end for

 return l_conta
 
end function

