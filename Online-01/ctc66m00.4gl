#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Porto Socorro                                             #
# Modulo.........: ctc66m00                                                  #
# Objetivo.......: Relacionar o grupo com a empresa e o assunto utilizado    #
#                  pelo tele-atendimento                                     #
# Analista Resp. : Ligia Mattge                                              #
# PSI            : 211982                                                    #
#............................................................................#
# Desenvolvimento: Luiz Adolphs, META                                        #
# Liberacao      : 24/09/2007                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica  PSI         Alteracao                            #
# --------   -------------  ------      -------------------------------------#
# 11/11/2008 Carla Rampazzo PSI 230650  Tratar 1a. posigco do Assunto para   #
#                                       carregar pop-up com esta inicial     #
# 16/10/2012 Celso Issamu   2012-28671  Posicao do Array de tela e array do  #
#                                       Programa                             #
#----------------------------------------------------------------------------#
 
globals "/homedsa/projetos/geral/globals/glct.4gl" 

   define m_prep_ctc66m00 smallint

   define mr_param record
      socntzgrpcod like datksocntzgrp.socntzgrpcod
     ,socntzgrpdes like datksocntzgrp.socntzgrpdes
   end record
   
   define am_tela array[300] of record
      empcod    like gabkemp.empcod
     ,empnom    like gabkemp.empnom
     ,c24astcod like datkassunto.c24astcod
     ,c24astdes like datkassunto.c24astdes
   end record

   define m_res smallint,
          m_msg char(40)
      
#-------------------------#
function ctc66m00_prepare()
#-------------------------#
   define l_sql char(500)
   
   let l_sql = ' select empcod '
                    ,' ,c24astcod '
                ,' from datrempgrp '
               ,' where socntzgrpcod = ? '
   
   prepare pctc66m00001 from l_sql
   declare cctc66m00001 cursor for pctc66m00001
   
   let l_sql = ' select 1 '
                ,' from datrempgrp '
               ,' where empcod = ? '
                 ,' and c24astcod    = ? '
                 ,' and socntzgrpcod = ? '
                 
   prepare pctc66m00004 from l_sql
   declare cctc66m00004 cursor for pctc66m00004
   
   let l_sql = ' insert into datrempgrp(empcod '
                                    ,' ,c24astcod '
                                    ,' ,socntzgrpcod) '
                              ,' values(?,?,?) '

   prepare pctc66m00005 from l_sql
   
   let l_sql = ' delete from datrempgrp '
               ,' where empcod       = ? '
                 ,' and c24astcod    = ? '
                 ,' and socntzgrpcod = ? '
   
   prepare pctc66m00006 from l_sql
   
   let m_prep_ctc66m00 = true
   
end function

#-------------------------#
function ctc66m00(lr_param)
#-------------------------#

   define lr_param record
      socntzgrpcod like datksocntzgrp.socntzgrpcod
     ,socntzgrpdes like datksocntzgrp.socntzgrpdes
   end record
   
   define l_repet smallint
   
   let l_repet = 0
   let m_res = null
   let m_msg = null
      
   let mr_param.socntzgrpcod = lr_param.socntzgrpcod
   let mr_param.socntzgrpdes = lr_param.socntzgrpdes
   
   if m_prep_ctc66m00 is null or
      m_prep_ctc66m00 <> true then
      call ctc66m00_prepare()
   end if
   
   options
      insert key f1
     ,delete key control-y
   
   open window w_ctc66m00 at 05,02 with form 'ctc66m00'
      attribute (form line 01)

   display mr_param.socntzgrpcod to socntzgrpcod
   display mr_param.socntzgrpdes to socntzgrpdes

   call ctc66m00_input_array()

   close window w_ctc66m00
   let int_flag = false

   options
      insert key f1
     ,delete key f2

end function

#-----------------------------#
function ctc66m00_input_array()
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
   
   call ctc66m00_carrega_array() returning l_ret ,l_qtdreg
   
   call set_count(l_qtdreg)

   input array am_tela without defaults from s_ctc66m00.*

         before row
            let l_pos  = arr_curr()
            let l_tela = scr_line()
         
         before field empcod
            display am_tela[l_pos].empcod to 
                    s_ctc66m00[l_tela].empcod attribute(reverse)
                           
         after field empcod
            display am_tela[l_pos].empcod to s_ctc66m00[l_tela].empcod
            
            if am_tela[l_pos].empcod is null then
               call cty14g00_popup_empresa()
                    returning m_res, am_tela[l_pos].empcod,
                              am_tela[l_pos].empnom
                          
               if m_res <> 1 then
                  let am_tela[l_pos].empcod = null
                  let am_tela[l_pos].empnom = null
                  display am_tela[l_pos].empcod to s_ctc66m00[l_tela].empcod
                  display am_tela[l_pos].empnom to s_ctc66m00[l_tela].empnom
                  next field empcod
               end if

               display am_tela[l_pos].empcod to s_ctc66m00[l_tela].empcod
               display am_tela[l_pos].empnom to s_ctc66m00[l_tela].empnom
            else
               call cty14g00_empresa(1, am_tela[l_pos].empcod) 
                    returning m_res,m_msg, am_tela[l_pos].empnom  
               if m_res <> 1 then
                  error m_msg
                  let am_tela[l_pos].empnom = null
                  display am_tela[l_pos].empnom to s_ctc66m00[l_tela].empnom
                  next field empcod
               end if

               display am_tela[l_pos].empnom to s_ctc66m00[l_tela].empnom

            end if

         before field c24astcod 
            display am_tela[l_pos].c24astcod to 
                    s_ctc66m00[l_tela].c24astcod attribute(reverse)
         
         after field c24astcod
            display am_tela[l_pos].c24astcod to s_ctc66m00[l_tela].c24astcod

            if am_tela[l_pos].c24astcod is null then     

               call cta02m03(g_issk.dptsgl
                            ,am_tela[l_pos].c24astcod)
                    returning am_tela[l_pos].c24astcod,
                              am_tela[l_pos].c24astdes
                          
               if am_tela[l_pos].c24astcod is null then

                  let am_tela[l_pos].c24astdes = null

                  display am_tela[l_pos].c24astcod to 
                          s_ctc66m00[l_tela].c24astcod
                  display am_tela[l_pos].c24astdes to 
                          s_ctc66m00[l_tela].c24astdes
               end if

               display am_tela[l_pos].c24astcod to s_ctc66m00[l_tela].c24astcod
               display am_tela[l_pos].c24astdes to s_ctc66m00[l_tela].c24astdes
            end if

            call cts25g00_dados_assunto(5, am_tela[l_pos].c24astcod)
                 returning m_res, m_msg, am_tela[l_pos].c24astdes

            if m_res <> 1 then
               error m_msg
               next field c24astcod
            end if

            display am_tela[l_pos].c24astdes to s_ctc66m00[l_tela].c24astdes

            if am_tela[l_pos].c24astcod is not null then
               let l_ret = ctc66m00_atualiza(l_pos)

               if l_ret <> 0 then
                  next field c24astcod
               end if
            else 
               next field c24astcod
            end if

         on key(f2)
            call ctc66m00_excluir(l_pos, l_tela)

         on key (control-c, f17, interrupt)
            let int_flag = false
            exit input
            
   end input
      
end function

#-------------------------------#
function ctc66m00_carrega_array()
#-------------------------------#
   define l_cont smallint
         ,l_erro smallint
         
   initialize am_tela to null
   
   let l_erro  = 0   
   let l_cont = 1
   
   open cctc66m00001 using mr_param.socntzgrpcod

   foreach cctc66m00001 into am_tela[l_cont].empcod   
                            ,am_tela[l_cont].c24astcod
      
      call cty14g00_empresa(1, am_tela[l_cont].empcod) 
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
function ctc66m00_atualiza(l_pos)
#---------------------------------------#
   define l_pos  smallint
   
   define l_ret  smallint
   
   let l_ret = 0
   
   open cctc66m00004 using am_tela[l_pos].empcod
                          ,am_tela[l_pos].c24astcod
                          ,mr_param.socntzgrpcod

   fetch cctc66m00004

   if sqlca.sqlcode = notfound then 
      whenever error continue
      execute pctc66m00005 using am_tela[l_pos].empcod
                                ,am_tela[l_pos].c24astcod
                                ,mr_param.socntzgrpcod
      whenever error stop
      if sqlca.sqlcode <> 0 then
         error 'Erro INSERT / ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] sleep 2
         let l_ret = 2
      end if
   
   end if

   return l_ret
   
end function


#--------------------------------------#
function ctc66m00_excluir(l_pos, l_tela)
#--------------------------------------#
 define l_pos  smallint
       ,l_tela smallint
       ,l_cont smallint
       ,l_ret  smallint
       
 let l_cont = null
 
 whenever error continue
 execute pctc66m00006 using am_tela[l_pos].empcod
                           ,am_tela[l_pos].c24astcod
                           ,mr_param.socntzgrpcod
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error 'Erro DELETE / ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] sleep 2
 end if
 
 for l_cont = l_pos to 299
    let am_tela[l_cont].* = am_tela[l_cont+1].*
 
    if am_tela[l_cont+1].empcod is null then
       exit for
    end if
 end for
 
 if l_cont = 300 then
    initialize am_tela[l_cont] to null
 end if

 let l_cont = l_cont - 1

 call set_count(l_cont)

 call ctc66m00_atualiza_tela(l_pos, l_tela)

end function

#----------------------------------------------#
function ctc66m00_atualiza_tela(l_i, l_x)
#----------------------------------------------#
   define l_i    smallint
         ,l_x    smallint
         ,l_z    smallint
   
   let l_i = l_i - (l_x - 1)
   let l_x = 0
   
   for l_z = l_i to 300
      let l_x = l_x + 1
      display am_tela[l_z].*   to s_ctc66m00[l_x].*
   
      if l_x = 12 then
         exit for
      end if
   end for
   
end function
