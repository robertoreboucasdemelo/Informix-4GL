#-----------------------------------------------------------------------------#
# Sistema    : Porto Socorro                                                  #
# Modulo     : ctc00m21                                                       #
# Programa   : Complemento do cadastro do prestador  - Circular 380 -         #
#-----------------------------------------------------------------------------#
# Analista Resp. : Robert Lima                                                #
# PSI            : 259136                                                     #
#                                                                             #
# Desenvolvedor  : Robert Lima                                                #
# DATA           : 16/08/2010                                                 #
#.............................................................................#
# Data        Autor      Alteracao                                            #
#                                                                             #
# ----------  ---------------  -----------------------------------------------#
# 04/04/2011  Ueslei Oliveira  Remocao dos cases, obtendo receita operacional # 
#			       atraves do dominio.			      # 
#-----------------------------------------------------------------------------#

database porto

#-------------------------------------------------------
function ctc00m21_prepare()                    
#-------------------------------------------------------

define l_sql char(500)


  let l_sql = "select renfxaincvlr, ",          
              "       renfxafnlvlr  ",          
              "  from gsakmenrenfxa ",          
              " where empcod    = 1 ",
              "   and renfxacod = ? "
             
   prepare pctc00m21001 from l_sql                                       
   declare cctc00m21001 cursor for pctc00m21001
   
   let l_sql = "select liqptrfxaincvlr,",
               "      liqptrfxafnlvlr  ",
               " from gsakliqptrfxa    ",                           
               "where empcod       = 1 ",
               "  and liqptrfxacod = ? " 
   prepare pctc00m21002 from l_sql             
   declare cctc00m21002 cursor for pctc00m21002               
   
end function


#-------------------------------------------------------
function ctc00m21(param, l_operacao,l_tipo)
#-------------------------------------------------------

define param record
   codpstlja  decimal(6,0),
   lcvcod     smallint    , 
   pestip    like dpaksocor.pestip    
end record

define l_operacao char(1),
       l_tipo char(1)

call ctc00m21_prepare()

if param.pestip = 'F' then
   call ctc00m21_PF(param.*, l_operacao)    
else
   if l_tipo = 'L' then
      call ctc00m21_PJLoja(param.*, l_operacao) 
   else   
      call ctc00m21_PJ(param.*, l_operacao) 
   end if
end if                 
                   
end function    


#-------------------------------------------------------                                                                                   
function ctc00m21_PF(param, l_operacao)                    
#-------------------------------------------------------

define param record
   pstcoddig like dpaksocor.pstcoddig,
   lcvcod     smallint    , 
   pestip    like dpaksocor.pestip
end record

define ctc00m21_campos record
   renfxaempcod     like dpaksocor.renfxaempcod   ,
   renfxacod        like dpaksocor.renfxacod      ,
   renfxades        char(30)                      ,
   pepindcod        like dpakctd.pepindcod
end record

define l_operacao char(1),
       l_aux      smallint,
       l_renfxaincvlr like gsakmenrenfxa.renfxaincvlr,
       l_renfxafnlvlr like gsakmenrenfxa.renfxafnlvlr,
       l_nomePst      like dpakctd.ctdnom,
       l_cpf          char(14),
       l_cgccpfnumdig like dpakctd.cgccpfnumdig,
       l_cpfNum       char(12),#like dpaksocor.cgccpfnum,
       l_cpfDig       char(2),#like dpaksocor.cgccpfdig,
       l_ctdcod       like dpakctd.ctdcod
       
       
   open window w_comp_presPF AT 9,4 WITH FORM "ctc00m21"
          ATTRIBUTE (border, form line first)  

initialize ctc00m21_campos.* to null

display "Faixa de renda mensal" to texto
                        
#Busca dados do prestador(Nome,Cpf,cod da faixa de renda)   
   select renfxacod,nomrazsoc,cgccpfnum,cgccpfdig              
     into ctc00m21_campos.renfxacod,
          l_nomePst,
          l_cpfNum,
          l_cpfDig
     from dpaksocor                       
    where pstcoddig = param.pstcoddig     

if l_operacao = 'A' then
  
   open cctc00m21001 using ctc00m21_campos.renfxacod   
   fetch cctc00m21001 into l_renfxaincvlr,
                           l_renfxafnlvlr
   close cctc00m21001
                           
   if l_renfxaincvlr is not null or l_renfxaincvlr <> 0 then
      if l_renfxafnlvlr is not null or l_renfxafnlvlr <> 0 then
         let ctc00m21_campos.renfxades = "DE ",l_renfxaincvlr clipped,
                                         " ATE ",l_renfxafnlvlr clipped
      end if
   end if
   
   display by name ctc00m21_campos.renfxades 
   
   select a.ctdcod,a.pepindcod
     into l_ctdcod,ctc00m21_campos.pepindcod
     from dpakctd a,dparpstctd b
    where a.ctdcod = b.ctdcod
      and b.pstcoddig = param.pstcoddig
   
   display by name ctc00m21_campos.pepindcod
           
end if 

while true

     input by name ctc00m21_campos.renfxacod,
                   ctc00m21_campos.pepindcod
                   without defaults
                   
     #--------------------------------------------------------------------------------------      
           before field  renfxacod
              display by name ctc00m21_campos.renfxades  attribute(reverse)
              
           after field renfxacod
              display by name ctc00m21_campos.renfxades
              
              if ctc00m21_campos.renfxacod is null or ctc00m21_campos.renfxacod = '' then
                 call ctc00m18(1)                       
                   returning ctc00m21_campos.renfxades,
                             ctc00m21_campos.renfxaempcod,
                             ctc00m21_campos.renfxacod 
                 next field renfxacod                      
              end if                     
                 
                 let l_renfxaincvlr = null
                 let l_renfxafnlvlr = null
                         
                 open cctc00m21001 using ctc00m21_campos.renfxacod
        
                 fetch cctc00m21001 into l_renfxaincvlr,
                                         l_renfxafnlvlr
                 close cctc00m21001
                                     
                 if l_renfxaincvlr is not null or l_renfxaincvlr <> 0 then
                    if l_renfxafnlvlr is not null or l_renfxafnlvlr <> 0 then
                       let ctc00m21_campos.renfxades = "DE ",l_renfxaincvlr clipped,
                                                       " ATE ",l_renfxafnlvlr clipped
                       display by name ctc00m21_campos.renfxades                                                 
                    end if
                 else
                    call ctc00m18(1)                       
                         returning ctc00m21_campos.renfxades,
                                   ctc00m21_campos.renfxaempcod,
                                   ctc00m21_campos.renfxacod 
                    next field renfxacod   
                 end if
     #--------------------------------------------------------------------------------------      
           before field  pepindcod
              display by name ctc00m21_campos.pepindcod  attribute(reverse)
              
           after field pepindcod
              display by name ctc00m21_campos.pepindcod                                                                                  
                                                                                                
              if ctc00m21_campos.pepindcod is null then                                      
                 call ctc00m18_pep()                                                                
                      returning ctc00m21_campos.pepindcod                                    
                 next field pepindcod              
              else
                 if ctc00m21_campos.pepindcod <> 'S' and ctc00m21_campos.pepindcod <> 'N' 
                    and ctc00m21_campos.pepindcod <> 'R' then
                      call ctc00m18_pep()                                                                
                          returning ctc00m21_campos.pepindcod                                    
                      next field pepindcod
                 end if                                                
              end if
              
              if fgl_lastkey() = fgl_keyval("up")    or                                         
                 fgl_lastkey() = fgl_keyval("left")  or
                 fgl_lastkey() = fgl_keyval("down")  then                                        
                 next field renfxacod                                                          
              end if               
                 
           update dpaksocor set (renfxaempcod,
                                 renfxacod   )
                               =
                                (ctc00m21_campos.renfxaempcod,
                                 ctc00m21_campos.renfxacod)
                  where pstcoddig = param.pstcoddig
                 
                 if sqlca.sqlcode <> 0 then
                    error "Erro [",sqlca.sqlcode,"] - modulo ctc00m21_PF()"
                    return
                 end if
           
           
           let l_cpf = l_cpfNum clipped,l_cpfDig clipped
           let l_cgccpfnumdig = l_cpf clipped
           
           if l_operacao = 'A' then
               call ctc00m20_alterar(l_ctdcod,l_nomePst clipped,l_cgccpfnumdig,ctc00m21_campos.pepindcod)                
           else
              call ctc00m20_insere(0,l_nomePst clipped,l_cgccpfnumdig,ctc00m21_campos.pepindcod,param.pstcoddig,0,'C')
           end if

           exit input
           
           on key(f17,interrupt,control-c)
              exit input
               
     end input
     
     #impossibilita a saida da tela ate os campos estiverem preenchidos                                                                       
     
     if l_operacao = 'I' then
       if int_flag = false then
          exit while
       else
          let int_flag = false  
       end if 
     else
       if ctc00m21_campos.renfxacod is null or ctc00m21_campos.renfxacod = ''  then 
          error "E' OBRIGATORIO O PREENCHIMENTO DA FAIXA DE RENDA"                                                                          
       else                                              
          if ctc00m21_campos.pepindcod is not null then                              
             if ctc00m21_campos.pepindcod <> 'S' and ctc00m21_campos.pepindcod <> 'N'
              and ctc00m21_campos.pepindcod <> 'R' then                              
                error "PEP PREENCHIDO INCORRETAMENTE"                                                                     
             else                                                               
                exit while                                                           
             end if                                                                  
          else         
             error "E' OBRIGATORIO PREENCHIMENTO DO PEP"                             
          end if                                                                     
       end if
     end if
     
end while

close window w_comp_presPF

error "Cadastro efetuado com sucesso"
                                              
end function

#-------------------------------------------------------
function ctc00m21_PJ(param, l_operacao)                    
#-------------------------------------------------------

define param record
   codpstlja like dpaksocor.pstcoddig,
   lcvcod     smallint    , 
   pestip    like dpaksocor.pestip
end record

define ctc00m21_campos record
   liqptrfxaempcod  like dpaksocor.liqptrfxaempcod,
   liqptrfxacod     like dpaksocor.liqptrfxacod   ,
   liqptrfxades     char(30)                      ,                                                  
   anobrtoprrctvlr  like dpaksocor.anobrtoprrctvlr,
   anobrtoprrctdes  char(30)                      
end record

define l_operacao char(1),
       l_aux      smallint,
       l_liqptrfxaincvlr like gsakliqptrfxa.liqptrfxaincvlr,
       l_liqptrfxafnlvlr like gsakliqptrfxa.liqptrfxafnlvlr

initialize ctc00m21_campos.* to null

   open window w_comp_presPJ AT 10,4 WITH FORM "ctc00m21a"
       ATTRIBUTE (border, form line first) 

let ctc00m21_campos.liqptrfxaempcod = 1 #As faixas sempre buscam referencia empresa 1(porto)

if l_operacao = 'A' then
   
   select liqptrfxacod,
          anobrtoprrctvlr                  
     into ctc00m21_campos.liqptrfxacod,   
          ctc00m21_campos.anobrtoprrctvlr 
     from dpaksocor                       
    where pstcoddig = param.codpstlja     
   
   open cctc00m21002 using ctc00m21_campos.liqptrfxacod   
   fetch cctc00m21002 into l_liqptrfxaincvlr,
                           l_liqptrfxafnlvlr
   close cctc00m21001
                           
   if l_liqptrfxaincvlr is not null or l_liqptrfxaincvlr <> 0 then
      if l_liqptrfxafnlvlr is not null or l_liqptrfxafnlvlr <> 0 then
         let ctc00m21_campos.liqptrfxades = "DE ",l_liqptrfxaincvlr clipped,
                                            " ATE ",l_liqptrfxafnlvlr clipped
      end if
   end if
   
   display by name ctc00m21_campos.liqptrfxades  
   
   select cpodes 
    into ctc00m21_campos.anobrtoprrctdes 
   from iddkdominio 
    where cponom = 'anobrtoprrctvlr' 
   and cpocod = ctc00m21_campos.anobrtoprrctvlr
   
   if sqlca.sqlcode <> 0 then
       let ctc00m21_campos.anobrtoprrctdes = ""
       error "Erro ao preencher Receita bruta anual" 
   end if

     
   display by name ctc00m21_campos.anobrtoprrctdes     
end if    

while true

     input by name ctc00m21_campos.liqptrfxacod,
                   ctc00m21_campos.anobrtoprrctvlr
                   without defaults   
               
                   
     #--------------------------------------------------------------------------------------             
          before field liqptrfxacod
                display "      Patrimonio liquido" to texto
                display by name ctc00m21_campos.liqptrfxades  attribute(reverse)   
                     
          after field liqptrfxacod
                display by name ctc00m21_campos.liqptrfxades
                
                if ctc00m21_campos.liqptrfxacod is null then
                   call ctc00m18(2)
                     returning ctc00m21_campos.liqptrfxades,
                               ctc00m21_campos.liqptrfxaempcod,
                               ctc00m21_campos.liqptrfxacod   
                   next field liqptrfxacod
                end if
                
                let l_liqptrfxaincvlr = null
                let l_liqptrfxafnlvlr = null
                
                open cctc00m21002 using ctc00m21_campos.liqptrfxacod   
                fetch cctc00m21002 into l_liqptrfxaincvlr,
                                        l_liqptrfxafnlvlr
                close cctc00m21001
                                        
                if l_liqptrfxaincvlr is not null or l_liqptrfxaincvlr <> 0 then
                   if l_liqptrfxafnlvlr is not null or l_liqptrfxafnlvlr <> 0 then
                      let ctc00m21_campos.liqptrfxades = "DE ",l_liqptrfxaincvlr clipped,
                                                         " ATE ",l_liqptrfxafnlvlr clipped
                      display by name ctc00m21_campos.liqptrfxades                                                      
                   end if
                else
                   call ctc00m18(2)
                     returning ctc00m21_campos.liqptrfxades,
                               ctc00m21_campos.liqptrfxaempcod,
                               ctc00m21_campos.liqptrfxacod   
                   next field liqptrfxacod
                end if
     #--------------------------------------------------------------------------------------                        
          before field anobrtoprrctvlr
             display "Receita operacional bruta anual" to texto
             display by name ctc00m21_campos.anobrtoprrctdes attribute(reverse)
                         
          after field anobrtoprrctvlr
             display by name ctc00m21_campos.anobrtoprrctdes 
             
             if ctc00m21_campos.anobrtoprrctvlr is null then
                call ctc00m18(3)
                  returning ctc00m21_campos.anobrtoprrctdes,
                            ctc00m21_campos.anobrtoprrctvlr,
                            l_aux
                  next field anobrtoprrctvlr
             end if
             
             
             
             select cpodes 
	      into ctc00m21_campos.anobrtoprrctdes 
	     from iddkdominio 
	      where cponom = 'anobrtoprrctvlr' 
	     and cpocod = ctc00m21_campos.anobrtoprrctvlr
             
             if sqlca.sqlcode <> 0 then
                 let ctc00m21_campos.anobrtoprrctdes = ""
                 error "Erro ao preencher Receita bruta anual" 
                 call ctc00m18(3)
                          returning ctc00m21_campos.anobrtoprrctdes,
                                    ctc00m21_campos.anobrtoprrctvlr,
                                    l_aux    
                 next field anobrtoprrctvlr 
             end if
             
             display by name ctc00m21_campos.anobrtoprrctdes 
             
             if fgl_lastkey() = fgl_keyval("up")    or                                         
                fgl_lastkey() = fgl_keyval("left")  or 
                fgl_lastkey() = fgl_keyval("down") then                              
                next field liqptrfxacod                                                          
             end if  
             
           update dpaksocor set (liqptrfxaempcod,
                                 liqptrfxacod   ,
                                 anobrtoprrctvlr)
                               =
                                (ctc00m21_campos.liqptrfxaempcod,
                                 ctc00m21_campos.liqptrfxacod   ,
                                 ctc00m21_campos.anobrtoprrctvlr)
           where pstcoddig = param.codpstlja                            
     
           if sqlca.sqlcode <> 0 then
             error "Erro [",sqlca.sqlcode,"] - modulo ctc00m21_PJ()" 
             return
           end if
         exit input
         
         on key(f17,interrupt,control-c)
              exit input
                    
     end input
     
     #impossibilita a saida da tela ate os campos estiverem preenchidos                                                                       
     
     if l_operacao = 'I' then
       if int_flag = false then
          exit while
       else
          let int_flag = false  
       end if 
     else
       if ctc00m21_campos.liqptrfxacod is null or ctc00m21_campos.liqptrfxacod = ''  then 
          error "E' OBRIGATORIO O PREENCHIMENTO DA PATRIMONIO LIQUIDO"                                                                          
       else                                              
          if ctc00m21_campos.anobrtoprrctvlr is null or ctc00m21_campos.anobrtoprrctvlr = ''  then 
             error "E' OBRIGATORIO O PREENCHIMENTO DA RECEITA OPERACIONAL BRUTA ANUAL"
          else         
             exit while
          end if                                                                     
       end if
     end if
     
end while    


close window w_comp_presPJ

error "Cadastro efetuado com sucesso"
           
end function

#-------------------------------------------------------
function ctc00m21_PJLoja(param, l_operacao)                    
#-------------------------------------------------------

define param record
   codpstlja decimal(6,0),
   lcvcod    smallint    , 
   pestip    like dpaksocor.pestip
end record

define ctc00m21_campos record
   liqptrfxaempcod  like datkavislocal.liqptrfxaempcod,
   liqptrfxacod     like datkavislocal.liqptrfxacod   ,
   liqptrfxades     char(30)                      ,                                                  
   anobrtoprrctvlr  like datkavislocal.anobrtoprrctvlr,
   anobrtoprrctdes  char(30)                      
end record

define l_operacao char(1),
       l_aux      smallint,
       l_liqptrfxaincvlr like gsakliqptrfxa.liqptrfxaincvlr,
       l_liqptrfxafnlvlr like gsakliqptrfxa.liqptrfxafnlvlr

initialize ctc00m21_campos.* to null

   open window w_comp_presPJLoja AT 10,4 WITH FORM "ctc00m21a"
       ATTRIBUTE (border, form line first) 

if l_operacao = 'A' then
   
   select liqptrfxacod,
          anobrtoprrctvlr                  
     into ctc00m21_campos.liqptrfxacod,   
          ctc00m21_campos.anobrtoprrctvlr 
     from datkavislocal                       
    where aviestcod = param.codpstlja     
      and lcvcod    = param.lcvcod
      
   open cctc00m21002 using ctc00m21_campos.liqptrfxacod   
   fetch cctc00m21002 into l_liqptrfxaincvlr,
                           l_liqptrfxafnlvlr
   close cctc00m21001
                           
   if l_liqptrfxaincvlr is not null or l_liqptrfxaincvlr <> 0 then
      if l_liqptrfxafnlvlr is not null or l_liqptrfxafnlvlr <> 0 then
         let ctc00m21_campos.liqptrfxades = "DE ",l_liqptrfxaincvlr clipped,
                                            " ATE ",l_liqptrfxafnlvlr clipped                                            
      end if
   end if
   
   display by name ctc00m21_campos.liqptrfxades  
   
   
   select cpodes 
    into ctc00m21_campos.anobrtoprrctdes 
   from iddkdominio 
    where cponom = 'anobrtoprrctvlr' 
    and cpocod = ctc00m21_campos.anobrtoprrctvlr
   
   if sqlca.sqlcode <> 0 then
       let ctc00m21_campos.anobrtoprrctdes = ""
       error "Erro ao preencher Receita bruta anual" 
   end if
  
   display by name ctc00m21_campos.anobrtoprrctdes     
end if    

while true

     input by name ctc00m21_campos.liqptrfxacod,
                   ctc00m21_campos.anobrtoprrctvlr
                   without defaults   
               
                   
     #--------------------------------------------------------------------------------------             
          before field liqptrfxacod
                display "      Patrimonio liquido" to texto
                display by name ctc00m21_campos.liqptrfxades  attribute(reverse)   
                     
          after field liqptrfxacod
                display by name ctc00m21_campos.liqptrfxades
                
                if ctc00m21_campos.liqptrfxacod is null then
                   call ctc00m18(2)
                     returning ctc00m21_campos.liqptrfxades,
                               ctc00m21_campos.liqptrfxaempcod,
                               ctc00m21_campos.liqptrfxacod   
                   next field liqptrfxacod
                end if
                
                let l_liqptrfxaincvlr = null
                let l_liqptrfxafnlvlr = null
                
                open cctc00m21002 using ctc00m21_campos.liqptrfxacod   
                fetch cctc00m21002 into l_liqptrfxaincvlr,
                                        l_liqptrfxafnlvlr
                close cctc00m21001
                                        
                if l_liqptrfxaincvlr is not null or l_liqptrfxaincvlr <> 0 then
                   if l_liqptrfxafnlvlr is not null or l_liqptrfxafnlvlr <> 0 then
                      let ctc00m21_campos.liqptrfxades = "DE ",l_liqptrfxaincvlr clipped,
                                                         " ATE ",l_liqptrfxafnlvlr clipped
                      display by name ctc00m21_campos.liqptrfxades                                                     
                   end if
                else
                   call ctc00m18(2)
                     returning ctc00m21_campos.liqptrfxades,
                               ctc00m21_campos.liqptrfxaempcod,
                               ctc00m21_campos.liqptrfxacod   
                   next field liqptrfxacod
                end if
     #--------------------------------------------------------------------------------------                        
          before field anobrtoprrctvlr
             display "Receita operaciona bruta anual" to texto
             display by name ctc00m21_campos.anobrtoprrctdes attribute(reverse)
                         
          after field anobrtoprrctvlr
             display by name ctc00m21_campos.anobrtoprrctdes                
             
             if ctc00m21_campos.anobrtoprrctvlr is null then
                call ctc00m18(3)
                  returning ctc00m21_campos.anobrtoprrctdes,
                            ctc00m21_campos.anobrtoprrctvlr,
                            l_aux
                next field anobrtoprrctvlr
             end if
                                                       
             select cpodes 
	      into ctc00m21_campos.anobrtoprrctdes 
	     from iddkdominio 
	      where cponom = 'anobrtoprrctvlr' 
	     and cpocod = ctc00m21_campos.anobrtoprrctvlr
             
             if sqlca.sqlcode <> 0 then
                 let ctc00m21_campos.anobrtoprrctdes = ""
                 error "Erro ao preencher Receita bruta anual" 
                 call ctc00m18(3)
                          returning ctc00m21_campos.anobrtoprrctdes,
                                    ctc00m21_campos.anobrtoprrctvlr,
                                    l_aux    
                 next field anobrtoprrctvlr 
             end if
             
             display by name ctc00m21_campos.anobrtoprrctdes  
             
             if fgl_lastkey() = fgl_keyval("up")    or                                         
                fgl_lastkey() = fgl_keyval("left")  or
                fgl_lastkey() = fgl_keyval("down")  then                                        
                next field liqptrfxacod                                                          
             end if  
     
           update datkavislocal set (liqptrfxaempcod,
                                     liqptrfxacod   ,
                                     anobrtoprrctvlr)
                                   =
                                    (ctc00m21_campos.liqptrfxaempcod,
                                     ctc00m21_campos.liqptrfxacod   ,
                                     ctc00m21_campos.anobrtoprrctvlr)
           where aviestcod = param.codpstlja 
             and lcvcod    = param.lcvcod                            
     
           if sqlca.sqlcode <> 0 then
              error "Erro [",sqlca.sqlcode,"] - modulo ctc00m21_PJLoja()" 
              return
           end if
         exit input
         
         on key(f17,interrupt,control-c)
                   exit input
                         
     end input
     
     #impossibilita a saida da tela ate os campos estiverem preenchidos                                                                       
     
     if l_operacao = 'I' then
       if int_flag = false then
          exit while
       else
          let int_flag = false  
       end if 
     else
       if ctc00m21_campos.liqptrfxacod is null or ctc00m21_campos.liqptrfxacod = ''  then 
          error "E' OBRIGATORIO O PREENCHIMENTO DA PATRIMONIO LIQUIDO"                                                                          
       else                                              
          if ctc00m21_campos.anobrtoprrctvlr is null or ctc00m21_campos.anobrtoprrctvlr = ''  then 
             error "E' OBRIGATORIO O PREENCHIMENTO DA RECEITA OPERACIONAL BRUTA ANUAL"
          else         
             exit while
          end if                                                                     
       end if
     end if
     
end while

close window w_comp_presPJLoja

error "Cadastro efetuado com sucesso"
           
end function


