#----------------------------------------------------------------#
# PORTO SEGURO CIA DE SEGUROS GERAIS                             #
#................................................................#
#  Sistema        : Central 24h                                  #
#  Modulo         : cta02m16.4gl                                 #
#                   Liberacao de atendimento                     #
#  Analista Resp. : Carlos Ruiz                                  #
#  PSI            : 166871                                       #
#................................................................#
#  Desenvolvimento: FABRICA DE SOFTWARE, Mariana Gimenez         #
#  Liberacao      : 05/03/2003                                   #
#................................................................#
#                     * * *  ALTERACOES  * * *                   #
#                                                                #
#  Data         Autor Fabrica  Data   Alteracao                  #
#  ----------   -------------  ------ -------------------------- #
#                                                                #
#----------------------------------------------------------------#

database porto

#----------------------------#
function cta02m16_prepare()
#----------------------------#

 define w_comando         char(200)


 let w_comando = "  select rowid ",
                 "    from gabkemp ",
                 "   where empcod = ? " 

     prepare p_gabkemp from w_comando
     declare c_gabkemp cursor for p_gabkemp

 let w_comando = " select funnom ", 
                 "   from isskfunc ",
                 "  where empcod = ? ",
                 "    and funmat = ? "  

     prepare p_isskfunc from w_comando
     declare c_isskfunc cursor for p_isskfunc


 let w_comando = " select rowid ", 
                 "   from ismkmaq ",
                 "  where maqsgl = ? "

     prepare p_ismkmaq from w_comando 
     declare c_ismkmaq cursor for p_ismkmaq

 let w_comando = " select grlinf[1,3]",
                 "   from datkgeral ",
                 "  where grlchv = ? " 

     prepare p_datkgeral from w_comando
     declare c_datkgeral cursor for p_datkgeral

 let w_comando = " select grlinf",
                 "   from datkgeral ",
                 "  where grlchv = ? " 

     prepare p_datkgeral1 from w_comando
     declare c_datkgeral1 cursor for p_datkgeral1
      
 let w_comando = " select c24astdes ",
                 "   from datkassunto ",
                 "  where c24astcod = ? "

     prepare p_datkassunto from w_comando
     declare c_datkassunto cursor for p_datkassunto


 let w_comando = " select funmat, funsnh ",
                 "   from datkfun " ,
                 "  where empcod = ? ",
                 "    and funmat = ? " 

     prepare p_datkfun from w_comando
     declare c_datkfun cursor for p_datkfun 

 
 let w_comando = "update datkgeral",
                 "  set grlinf[4,5] = ?, ",
                 "      grlinf[6,11] = ?, ",
                 "      grlinf[12,25] = ? ",
                 " where grlchv = ? "

     prepare p_update from w_comando     

 end function 
#---------------------#
function cta02m16() 
#---------------------#

define w_cta02m16     record
       empcod         like isskfunc.empcod,
       funmat         like isskfunc.funmat,
       funnom         like isskfunc.funnom,
       maqsgl         like ismkmaq.maqsgl,
       c24astcod      like datkassunto.c24astcod,
       c24astdes      like datkassunto.c24astdes,
       doctxt         char(60),
       empcod2        like datkfun.empcod,
       funmat2        like datkfun.funmat,
       funnom2        like isskfunc.funnom,
       funsnh         like datkfun.funsnh
                      end record

define w_funmatchar   char(06),
       w_empcodchar   char(02),
       w_senha        like datkfun.funsnh,
       w_grlchv       like datkgeral.grlchv,
       w_ct24         char(04),
       w_rowid        integer,
       w_grlinf       like datkgeral.grlinf
   
   initialize w_cta02m16.* to null

   call cta02m16_prepare()

   open window w_cta02m16 at 4,3 with form "cta02m16"
     attributes(border, message line last)

   let int_flag = false
  
   input by name w_cta02m16.* 

     after field empcod  
       if w_cta02m16.empcod is not null then 
          open c_gabkemp using w_cta02m16.empcod 
          fetch c_gabkemp into  w_rowid            
           
           if sqlca.sqlcode <> 0 then 
              error "Empresa nao cadastrada"
              next field empcod
           end if 
       else
           error "Informe o codigo da empresa"
       end if 

      after field funmat 
        display by name w_cta02m16.funmat
        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           next field empcod 
        end if
        if w_cta02m16.funmat is not null then 
           open c_isskfunc using w_cta02m16.empcod,
                                 w_cta02m16.funmat
           fetch c_isskfunc into w_cta02m16.funnom
           if sqlca.sqlcode <> 0 then 
              error "Matricula nao existente "    
              next field funmat
              display by name w_cta02m16.*
            end if 
        else
           error "Informe o numero da matricula"
           next field funmat
        end if 
        display by name w_cta02m16.*

      after field maqsgl          
        display by name w_cta02m16.maqsgl
        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           next field funmat
        end if
        if w_cta02m16.maqsgl is not null then 
        else
           error "Informe o numero da maquina"
           next field maqsgl
        end if 
        let w_funmatchar = w_cta02m16.funmat
        let w_empcodchar = w_cta02m16.empcod
        let w_ct24       = "ct24" 
        let w_grlchv     = w_ct24 clipped, w_empcodchar clipped,
                          w_funmatchar clipped, 
                          w_cta02m16.maqsgl
        open c_datkgeral using w_grlchv
        fetch c_datkgeral into w_cta02m16.c24astcod

        if sqlca.sqlcode <> 0 then 
           error "Matricula nao encontrada"
           next field empcod
        else
           open c_datkassunto using w_cta02m16.c24astcod
           fetch c_datkassunto into w_cta02m16.c24astdes 
           
           let w_grlchv = w_grlchv clipped,"X"
           display "* cta02m16-w_grlchv = ", w_grlchv
           open c_datkgeral1 using w_grlchv
           fetch c_datkgeral1 into w_grlinf

           if sqlca.sqlcode <> 0 then
              let w_cta02m16.doctxt =  "Sem Documento Informado"             
           else
              if w_grlinf[1,1]="A" then # apolice
                 let w_cta02m16.doctxt = 
                    "Suc: ",   w_grlinf[2,3] clipped  using "&&", 
                    " Ramo: ", w_grlinf[4,7]  clipped using "&&&&",
                    " Apl: ",  w_grlinf[8,16] clipped using "<<<<<<<# #"
                 if w_grlinf[17,23] is not null then
                    let w_cta02m16.doctxt = w_cta02m16.doctxt clipped,  
                        " Item: ", w_grlinf[17,23] using "<<<<<# #"
                 end if 
              else
                 if w_grlinf[1,1] = "P" then  # proposta
                    let w_cta02m16.doctxt = 
                    "Proposta: ", w_grlinf[2,3] clipped  using "&&", " ",
                                  w_grlinf[4,12] clipped                      
                 else
                    if w_grlinf[1,1] = "F" then # pac
                       let w_cta02m16.doctxt = 
                       "No.PAC:", w_grlinf[2,3] clipped  using "&&", " ",
                                  w_grlinf[4,12] clipped using "<<<<<<<<&"
                    else
                       if w_grlinf[1,1] = "C" then # patrimonial
                          let w_cta02m16.doctxt =
                              "Contrato:", w_grlinf[2,10] clipped 
                       else
                          let w_cta02m16.doctxt =
                          "SEM DOCUMENTO INFORMADO"
                       end if
                    end if
                 end if   
               end if
           end if           
         end if 
         display by name w_cta02m16.*
 
       after field empcod2 
         if w_cta02m16.empcod2 is not null then
            open c_gabkemp using w_cta02m16.empcod2
            fetch c_gabkemp into w_rowid
                   
            if sqlca.sqlcode <> 0 then 
               error "Empresa nao cadastrada"
               next field empcod2
            end if 
         else
            error "Informe o codigo da empresa"
            next field empcod2
         end if 
          
      after field funmat2
        display by name w_cta02m16.funmat2
        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           next field empcod2
        end if
        if w_cta02m16.funmat2 is not null then 
           open c_isskfunc using w_cta02m16.empcod2,
                                 w_cta02m16.funmat2
           fetch c_isskfunc into w_cta02m16.funnom2
           if sqlca.sqlcode <> 0 then  
              error "Matricula nao cadastrada"
              next field funmat2
           end if
           display by name w_cta02m16.*
        else
           error "Informe o numero da matricula"
           next field empcod2
        end if              

       after field funsnh
         display by name w_cta02m16.funsnh 
         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field funmat2 
         end if
         if w_cta02m16.funsnh is not null then 
            open c_datkfun using w_cta02m16.empcod2,
                                 w_cta02m16.funmat2
            fetch c_datkfun  into w_cta02m16.funmat, w_senha
            if w_senha <> w_cta02m16.funsnh then 
               error "Senha invalida, tente novamente"
               next field funsnh
            else
               whenever error continue  
                  let w_grlchv     = w_ct24 clipped, w_empcodchar clipped,
                                     w_funmatchar clipped, 
                                     w_cta02m16.maqsgl
                  execute p_update using w_cta02m16.empcod2,
                                         w_cta02m16.funmat2,
                                         w_cta02m16.funsnh,
                                         w_grlchv
               whenever error stop
               if sqlca.sqlcode <> 0 then 
                  error "Problemas ao atualizar a tabela, erro: ", sqlca.sqlcode               end if 
            end if                
         else
            error "Informe a senha"
            next field funsnh
         end if             

         on key(control-c, interrupt)
            exit input
        
    end input

 close window w_cta02m16
 end function 
