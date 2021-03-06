#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                  #
# Modulo.........: cts12g09                                                  #
# Objetivo.......: Lista de Servicos do Auto Plano Itau                      #
# Analista Resp. : Roberto Melo                                              #
# PSI            :                                                           #
#............................................................................#
# Desenvolvimento: R.Fornax                                                  #
# Liberacao      : 05/08/2014                                                #
#............................................................................#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


define m_prepare  smallint


define mr_servicos   array[500] of record
    codigo    smallint
   ,servdes   char(50)
   ,km        smallint
end record


#------------------------------------------------------------------------------
function cts12g09_prepare()
#------------------------------------------------------------------------------

define l_sql char(10000)

 let l_sql =  ' select cpocod,                     '
             ,'        cpodes                      '
             ,' from   datkdominio                 '
             ,' where cponom = ?                   '
 prepare p_cts12g09_001 from l_sql
 declare c_cts12g09_001 cursor for p_cts12g09_001


end function

#------------------------------------------------------------------------------
function cts12g09_rec_servico()
#------------------------------------------------------------------------------

define l_chave char(50)

define l_index integer

for  l_index  =  1  to  500
   initialize  mr_servicos[l_index].* to  null
end  for

if m_prepare is null or
   m_prepare <> true then
   call cts12g09_prepare()
end if

   let l_index = 1
   let l_chave = "guincho_itau_ter"

   open c_cts12g09_001 using l_chave
   foreach c_cts12g09_001 into mr_servicos[l_index].codigo  ,
                               mr_servicos[l_index].km

   let mr_servicos[l_index].servdes = "GUINCHO TERCEIRO"

   let l_index = l_index + 1

   end foreach


end function

#--------------------------------------------------------------------------
function cts12g09()
#--------------------------------------------------------------------------


define l_index     integer
      ,l_null      char(1)
      ,l_flag      smallint
      ,l_qtde      smallint
      ,arr_aux     integer


let l_index           = 0
let l_null            = null
let l_qtde            = 0
let arr_aux           = 0



for l_index  =  1  to  500
    initialize  mr_servicos[l_index].* to  null
end for



   #---------------------------
   # Busca Servicos
   #---------------------------
   call cts12g09_rec_servico()


   open window w_cts12g09 at 3,2 with form "cts12g09"
   attribute(form line 1)

   let int_flag = false

   message " (F17)Abandona "

   call set_count(l_index - 1)

   display array mr_servicos to s_cts12g09.*


      on key (interrupt,control-c,f17)
            exit display


   end display

   close window  w_cts12g09

   let int_flag = false


end function


