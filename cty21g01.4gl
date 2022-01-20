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

#globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep     smallint

define m_org        like  gppmppwtrxhst.prporg    
define m_propnum    like  gppmppwtrxhst.prpnumdig     
define m_ppwpro     like  gppmppwtrx.ppwprpnum
define m_corsus     like  gppmppwtrx.corsus

define am_cty21g01  array[500] of record 
       marca        char(001)
      ,ppwtrxhordat like gppmnetprpcpaaut.ppwtrxhordat
      ,ppwtrxqtd    like gppmnetprpcpaaut.ppwtrxqtd
      ,sitdesc      varchar(030)
      ,ppwprpsit    like gppmnetprpcpaaut.ppwprpsit
end record

#============================
function cty21g01_prepare()
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
 prepare pcty21g01001 from l_sql              
 declare ccty21g01001 cursor for pcty21g01001

 
 let l_sql = ' select ppwtrxhordat,                      '
            ,'        ppwtrxqtd,                         '
            ,'        ppwprpsit                          '
            ,'  from gppmnetprpcpaaut                    '
            ,' where corsus = ?                          '
            ,'   and ppwprpnum = ?                       '
  prepare pcty21g01002 from l_sql                 
  declare ccty21g01002 cursor for pcty21g01002
  
   let l_sql = ' select count(ppwtrxqtd)                   '
              ,'  from gppmnetprpcpaaut                    '
              ,' where corsus = ?                          '
              ,'   and ppwprpnum = ?                       '
  prepare pcty21g01003 from l_sql                 
  declare ccty21g01003 cursor for pcty21g01003
  
 let m_prep = 1

end function

#==================================================
function cty21g01_seleciona_dados(l_org,l_propnum)
#==================================================
define l_org     like  gppmppwtrxhst.prporg    
define l_propnum like  gppmppwtrxhst.prpnumdig 
define l_index   smallint
                     
  if m_prep <> 1 then
     call cty21g01_prepare()
  end if

  let m_org = l_org
  let m_propnum = l_propnum

  initialize am_cty21g01 to null
    
  open ccty21g01001 using m_org
                         , m_propnum
   fetch ccty21g01001 into m_ppwpro
                         , m_corsus  
   
   let l_index = 1
   
   open ccty21g01002 using  m_corsus
                         ,  m_ppwpro
   
   foreach ccty21g01002 into am_cty21g01[l_index].ppwtrxhordat
                           , am_cty21g01[l_index].ppwtrxqtd   
                           , am_cty21g01[l_index].ppwprpsit   
                                                  
           case am_cty21g01[l_index].ppwprpsit 
               when 0    
                    let am_cty21g01[l_index].sitdesc = "- Em Transmissao" 
          
               when 1
                    let am_cty21g01[l_index].sitdesc = "- A  Formatar"
          
               when 2
                    let am_cty21g01[l_index].sitdesc = "- Proposta Formatada"
          
               when 3
                    let am_cty21g01[l_index].sitdesc = "- A  Formatar"
          
               when 4
                    let am_cty21g01[l_index].sitdesc = "- Orcamento Formatado"
                    
               when 6                                                   
                    let am_cty21g01[l_index].sitdesc = "- Orcamento Formatado"     
                    
               when 99
                    let am_cty21g01[l_index].sitdesc = "- A  Formatar"
                    
               when 100 
                    let am_cty21g01[l_index].sitdesc = "- Proposta Formatada"
            end case

           let l_index = l_index + 1   
          
   end foreach 

   # incluir emissao
#      
#      ,ppwtrxhordat like gppmnetprpcpaaut.ppwtrxhordat
#      ,ppwtrxqtd    like gppmnetprpcpaaut.ppwtrxqtd
#      ,sitdesc      varchar(030)
#      ,ppwprpsit    like gppmnetprpcpaaut.ppwprpsit

   call cty21g01_input(l_index)
   
end function

#==============================
function cty21g01_input(l_index)
#============================== 
define l_arrc      smallint
define l_tela      smallint
define l_i         smallint
define l_conta     smallint
define l_proposta  char(20)
define i           smallint
define l_index     smallint
define l_seq1      like    gppmnetprpcpaaut.ppwtrxqtd
define l_seq2      like    gppmnetprpcpaaut.ppwtrxqtd
define j           smallint
define l_flg       smallint
define l_marcado   smallint

  if m_prep <> 1 then
     call cty21g01_prepare()
  end if

  open window w_cty21g01 at 6,2 with form 'cty21g01'
             attribute(form line first, comment line last -1)
 
  display 'COMPARACAO DE PROPOSTA' at 1,29    
 
  let l_proposta = m_org using '<<' ,'-',m_propnum using '<<<<<<<<'
  let l_proposta = l_proposta clipped
  display l_proposta to proposta attribute(reverse) 
  
   let l_marcado = 0
   let l_conta = 0
   call set_count(l_index - 1)

   input array am_cty21g01 without defaults from sa_cty21g01.*

    #-----------
     before row
    #-----------
      let l_arrc = arr_curr()
      let l_tela = scr_line()
      
      if am_cty21g01[l_arrc].ppwtrxhordat is null then
         next field marca
      end if
     
     
     
     if l_index < 3 then
        call cty21g01_popup_trasmissao (  '         E necessario, NO MINIMO,'
                                        , '        2 (duas) transmissoes para '
                                        , '         esse tipo de comparacao')

        exit input
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
      
    #------------------
     after field marca
    #------------------

         #verifica se tem mais de 2 'X' marcados
         call cty21g01_conta_X()
              returning l_conta
         
         if l_conta > 2 then
            error 'Só é possivel comparar 2 transmissoes'
            let am_cty21g01[l_arrc].marca = ""
            next field marca
         else
            if l_conta = 2 then
               message '             (F5) -> CONFRONTAR DADOS          (F6) -> RESUMO'
            else
               message ' '
            end if
            
         end if
        #-------
         
         if am_cty21g01[l_arrc].marca <> "X" and
            am_cty21g01[l_arrc].marca <> " " then
            error " Digite X para marcar ou ESPACO para desmarcar."
            let am_cty21g01[l_arrc].marca = ""
            next field marca
         end if   
    
                      
         display am_cty21g01[l_arrc].marca   to sa_cty21g01[l_tela].marca
   
  #----------- 
   on key (F5)
  #-----------
     let am_cty21g01[l_arrc].marca = get_fldbuf(marca)
       
     if cty21g01_conta_x() <> 2 then
        message ' '
        error 'Selecione 2 transmissoes'
     else
     
        let l_flg = 1
        
        for j = 1 to arr_count()
            if am_cty21g01[j].marca = 'X' then
               if l_flg = 1 then
                  let l_seq1 = am_cty21g01[j].ppwtrxqtd
                  let l_flg = 2
               else
                  let l_seq2 = am_cty21g01[j].ppwtrxqtd
               end if
            end if               
        end for
        
        error "Por Favor, Aguarde! ..." 
        call cty21g03( m_ppwpro   #    Por padrao, funcao pede 2 numeros de
                     , m_ppwpro   #  proposta, 2 de susep e 2 de sequencia.
                     , m_corsus   #    Neste caso (de uma so proposta)
                     , m_corsus   # sera enviado duplicado o numero ppw
                     , l_seq1     # e susep Corretor
                     , l_seq2
                     , l_proposta
                     , l_proposta
                     , 'F5'
                     )
     end if
      
      
  #----------- 
   on key (F6)
  #-----------
     let am_cty21g01[l_arrc].marca = get_fldbuf(marca)
       
     if cty21g01_conta_x() <> 2 then
        message ' '
        error 'Selecione 2 transmissoes'
     else
     
        let l_flg = 1
        
        for j = 1 to arr_count()
            if am_cty21g01[j].marca = 'X' then
               if l_flg = 1 then
                  let l_seq1 = am_cty21g01[j].ppwtrxqtd
                  let l_flg = 2
               else
                  let l_seq2 = am_cty21g01[j].ppwtrxqtd
               end if
            end if               
        end for
        
        error "Por Favor, Aguarde! ..." 
        call cty21g03( m_ppwpro   #    Por padrao, funcao pede 2 numeros de
                     , m_ppwpro   #  proposta, 2 de susep e 2 de sequencia.
                     , m_corsus   #    Neste caso (de uma so proposta)
                     , m_corsus   # sera enviado duplicado o numero ppw
                     , l_seq1     # e susep Corretor
                     , l_seq2
                     , l_proposta
                     , l_proposta
                     , 'F6'
                     )
     end if 
      
      
  end input

  close window w_cty21g01
  return
  
end function

#==========================
function cty21g01_conta_x()
#==========================
define l_i     smallint
define l_conta smallint
  
  if m_prep <> 1 then
     call cty21g01_prepare()
  end if
  
  let l_conta = 0

  for l_i = 1 to arr_count()
      if am_cty21g01[l_i].marca = 'X' then
         let l_conta = l_conta + 1
      end if
  end for

 return l_conta
 
end function

#==============================================================
function cty21g01_popup_trasmissao(l_linha1,l_linha2,l_linha3)
#==============================================================
# esta funcao mostra tela de aviso que proposta
# so possui 1  ou nenhuma transmissao

  define l_linha1  char(50)
  define l_linha2  char(50)
  define l_linha3  char(50)
  define confirma  char(1)
 
  open window w_cty21g01a at 11,19 with form "cty21g01a"
              attribute (border, form line 1)
 
  input by name confirma without defaults
        before field confirma
          display l_linha1 to linha1
          display l_linha2 to linha2
          display l_linha3 to linha3
     
        after field confirma
           next field confirma

         on key (interrupt, control-c)
           exit input
           
  end input
  
  close window w_cty21g01a
  
end function