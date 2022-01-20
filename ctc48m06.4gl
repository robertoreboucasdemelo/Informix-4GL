#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Porto Socorro                                             #
# Modulo.........: ctc48m06                                                  #
# Objetivo.......: Relacionar o problema com a empresa e o assunto utilizado #
#                  pelo tele-atendimento                                     #
# Analista Resp. : Beatriz Araujo                                            #
# PSI            : PSI_2012_26560                                            #
#............................................................................#
# Desenvolvimento: Betariz Araujo                                            #
# Liberacao      : 21/01/2013                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica  PSI         Alteracao                            #
# --------   -------------  ------      -------------------------------------#
#----------------------------------------------------------------------------#
 
globals "/homedsa/projetos/geral/globals/glct.4gl" 

   define m_prep_ctc48m06 smallint

   define mr_param record
      c24pbmcod like datkpbm.c24pbmcod,
      c24pbmdes like datkpbm.c24pbmdes
   end record
   
   define am_tela array[300] of record
      ciaempcod    like datrempligatdprb.ciaempcod   ,
      empnom    like gabkemp.empnom            ,
      c24astcod like datrempligatdprb.c24astcod,
      c24astdes like datkassunto.c24astdes
   end record

   define m_res smallint,
          m_msg char(40)
      
#-------------------------#
function ctc48m06_prepare()
#-------------------------#
   define l_sql char(500)
   
   let l_sql = ' select ciaempcod '
                    ,' ,c24astcod '
                ,' from datrempligatdprb '
               ,' where c24pbmcod = ? '
   
   prepare pctc48m06001 from l_sql
   declare cctc48m06001 cursor for pctc48m06001
   
   let l_sql = ' select 1 '
                ,' from datrempligatdprb '
               ,' where ciaempcod = ? '
                 ,' and c24astcod    = ? '
                 ,' and c24pbmcod = ? '
                 
   prepare pctc48m06004 from l_sql
   declare cctc48m06004 cursor for pctc48m06004
   
   let l_sql = ' insert into datrempligatdprb(c24pbmcod,ciaempcod,c24astcod) '
                              ,' values(?,?,?) '

   prepare pctc48m06005 from l_sql
   
   let l_sql = ' delete from datrempligatdprb '
               ,' where ciaempcod       = ? '
                 ,' and c24astcod    = ? '
                 ,' and c24pbmcod = ? '
   
   prepare pctc48m06006 from l_sql
   
   let m_prep_ctc48m06 = true
   
end function

#-------------------------#
function ctc48m06(lr_param)
#-------------------------#

   define lr_param record
      c24pbmcod like datkpbm.c24pbmcod
   end record
   
   define l_repet smallint
   
   let l_repet = 0
   let m_res = null
   let m_msg = null
      
   if m_prep_ctc48m06 is null or
      m_prep_ctc48m06 <> true then
      call ctc48m06_prepare()
   end if
   
   select c24pbmdes into  mr_param.c24pbmdes
   from datkpbm
  where c24pbmcod = lr_param.c24pbmcod
   
   let mr_param.c24pbmcod = lr_param.c24pbmcod
   
   options
      insert key f1
     ,delete key control-y
   
   open window w_ctc48m06 at 05,02 with form 'ctc48m06'
      attribute (form line 01)

   display mr_param.c24pbmcod to c24pbmcod
   display mr_param.c24pbmdes to c24pbmdes

   call ctc48m06_input_array()

   close window w_ctc48m06
   let int_flag = false

   options
      insert key f1
     ,delete key f2

end function

#-----------------------------#
function ctc48m06_input_array()
#-----------------------------#
   
   define l_qtdreg   smallint
         ,l_pos      smallint
         ,l_tela     smallint
         ,l_sql      char(300)
         ,l_ret      smallint
         ,l_excult   smallint
         
   define lr_retpop record
      erro smallint
     ,cod  char(011)
     ,dsc  char(040)
   end record
   
   initialize lr_retpop to null
   
   let l_qtdreg   = null
   let l_pos      = null
   let l_tela     = null
   let l_sql      = null
   let l_ret      = null
   let l_excult   = false   
   
   call ctc48m06_carrega_array() returning l_ret ,l_qtdreg
   
   call set_count(l_qtdreg)

   input array am_tela without defaults from s_ctc48m06.*

         before row
            let l_pos  = arr_curr()
            let l_tela = scr_line()
         before field ciaempcod
            display am_tela[l_pos].ciaempcod to 
                    s_ctc48m06[l_tela].ciaempcod attribute(reverse)
                           
         after field ciaempcod
            display am_tela[l_pos].ciaempcod to s_ctc48m06[l_tela].ciaempcod
            
            if am_tela[l_pos].ciaempcod is null then
               call cty14g00_popup_empresa()
                    returning m_res, am_tela[l_pos].ciaempcod,
                              am_tela[l_pos].empnom
                          
               if m_res <> 1 then
                  let am_tela[l_pos].ciaempcod = null
                  let am_tela[l_pos].empnom = null
                  display am_tela[l_pos].ciaempcod to s_ctc48m06[l_tela].ciaempcod
                  display am_tela[l_pos].empnom to s_ctc48m06[l_tela].empnom
                  next field ciaempcod
               end if

               display am_tela[l_pos].ciaempcod to s_ctc48m06[l_tela].ciaempcod
               display am_tela[l_pos].empnom to s_ctc48m06[l_tela].empnom
            else
               call cty14g00_empresa(1, am_tela[l_pos].ciaempcod) 
                    returning m_res,m_msg, am_tela[l_pos].empnom  
               if m_res <> 1 then
                  error m_msg
                  let am_tela[l_pos].empnom = null
                  display am_tela[l_pos].empnom to s_ctc48m06[l_tela].empnom
                  next field ciaempcod
               end if

               display am_tela[l_pos].empnom to s_ctc48m06[l_tela].empnom

            end if

         before field c24astcod 
            display am_tela[l_pos].c24astcod to 
                    s_ctc48m06[l_tela].c24astcod attribute(reverse)
         
         after field c24astcod
            display am_tela[l_pos].c24astcod to s_ctc48m06[l_tela].c24astcod

            if am_tela[l_pos].c24astcod is null then     

               call cta02m03(g_issk.dptsgl
                            ,am_tela[l_pos].c24astcod)
                    returning am_tela[l_pos].c24astcod,
                              am_tela[l_pos].c24astdes
                          
               if am_tela[l_pos].c24astcod is null then

                  let am_tela[l_pos].c24astdes = null

                  display am_tela[l_pos].c24astcod to 
                          s_ctc48m06[l_tela].c24astcod
                  display am_tela[l_pos].c24astdes to 
                          s_ctc48m06[l_tela].c24astdes
               end if

               display am_tela[l_pos].c24astcod to s_ctc48m06[l_tela].c24astcod
               display am_tela[l_pos].c24astdes to s_ctc48m06[l_tela].c24astdes
            end if

            call cts25g00_dados_assunto(5, am_tela[l_pos].c24astcod)
                 returning m_res, m_msg, am_tela[l_pos].c24astdes

            if m_res <> 1 then
               error m_msg
               next field c24astcod
            end if

            display am_tela[l_pos].c24astdes to s_ctc48m06[l_tela].c24astdes

            if am_tela[l_pos].c24astcod is not null then
               let l_ret = ctc48m06_atualiza(l_pos)

               if l_ret <> 0 then
                  next field c24astcod
               end if
            else 
               next field c24astcod
            end if

         on key(f2)
            call ctc48m06_excluir(l_pos, l_tela)

         on key (control-c, f17, interrupt)
            let int_flag = false
            exit input
            
   end input
      
end function

#-------------------------------#
function ctc48m06_carrega_array()
#-------------------------------#
   define l_cont smallint
         ,l_erro smallint
         
   initialize am_tela to null
   
   let l_erro  = 0   
   let l_cont = 1
   
   open cctc48m06001 using mr_param.c24pbmcod

   foreach cctc48m06001 into am_tela[l_cont].ciaempcod   
                            ,am_tela[l_cont].c24astcod
      
      call cty14g00_empresa(1, am_tela[l_cont].ciaempcod) 
           returning m_res,m_msg, am_tela[l_cont].empnom  

      call cts25g00_dados_assunto(5, am_tela[l_cont].c24astcod)
           returning m_res, m_msg, am_tela[l_cont].c24astdes

      let l_cont = l_cont + 1                      

      if l_cont > 300 then
         error 'Numero de registros excedeu o limite'
         exit foreach
      end if
   end foreach
   
   let l_cont = l_cont - 1
   
   return l_erro ,l_cont
         
end function

#---------------------------------------#
function ctc48m06_atualiza(l_pos)
#---------------------------------------#
   define l_pos  smallint
   
   define l_ret  smallint
   
   let l_ret = 0
   
   open cctc48m06004 using am_tela[l_pos].ciaempcod
                          ,am_tela[l_pos].c24astcod
                          ,mr_param.c24pbmcod

   fetch cctc48m06004

   if sqlca.sqlcode = notfound then 
      whenever error continue
      execute pctc48m06005 using mr_param.c24pbmcod,
                                 am_tela[l_pos].ciaempcod,
                                 am_tela[l_pos].c24astcod
      whenever error stop
      if sqlca.sqlcode <> 0 then
         error 'Erro INSERT / ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] sleep 2
         let l_ret = 2
      end if
   
   end if

   return l_ret
   
end function


#--------------------------------------#
function ctc48m06_excluir(l_pos, l_tela)
#--------------------------------------#
 define l_pos  smallint
       ,l_tela smallint
       ,l_cont smallint
       ,l_ret  smallint
       
 let l_cont = null
 
 whenever error continue
 execute pctc48m06006 using am_tela[l_pos].ciaempcod
                           ,am_tela[l_pos].c24astcod
                           ,mr_param.c24pbmcod
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error 'Erro DELETE / ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] sleep 2
 end if
 
 for l_cont = l_pos to 299
    let am_tela[l_cont].* = am_tela[l_cont+1].*
 
    if am_tela[l_cont+1].ciaempcod is null then
       exit for
    end if
 end for
 
 if l_cont = 300 then
    initialize am_tela[l_cont] to null
 end if

 let l_cont = l_cont - 1

 call set_count(l_cont)

 call ctc48m06_atualiza_tela(l_pos, l_tela)

end function

#----------------------------------------------#
function ctc48m06_atualiza_tela(l_i, l_x)
#----------------------------------------------#
   define l_i    smallint
         ,l_x    smallint
         ,l_z    smallint
   
   let l_i = l_i - (l_x - 1)
   let l_x = 0
   
   for l_z = l_i to 300
      let l_x = l_x + 1
      display am_tela[l_z].*   to s_ctc48m06[l_x].*
   
      if l_x = 12 then
         exit for
      end if
   end for
   
end function
