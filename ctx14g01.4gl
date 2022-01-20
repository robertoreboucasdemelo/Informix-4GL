#############################################################################
# Nome do Modulo: CTX14G00                                         Raji     #
#                                                                           #
# Mostra funcoes/Limpa String                                      Set/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################
#                                                                           #
#                        * * * Alteracoes * * *                             #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- -----------------------------------  #
# 18/09/2003  Meta,Bruno     PSI175552 Selecionar e fazer um insert na      #
#                            OSF26077  tabela datrligmens.                  #
# 01/04/2004  Amaury         CT 169223 Logica para contemplar dois acessos
#                            simultaneos tentando inserir registros na tabela
#                            dammtrx. Correcao do Chamado: 4025999
#---------------------------------------------------------------------------#
# 15/02/2007 Fabiano, Meta    AS 130087  Migracao para a versao 7.32        #
#                                                                           #
#############################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function ctx14g01(p_ctx14g01)
#-----------------------------------------------------------
   define p_ctx14g01  record
      titulo          char(25),
      popup           char(6000)
   end record

   define a_ctx14g01  array[200] of record
      fundes          char (40)
   end record

   define strpos      smallint
   define strini      smallint
   define scr_aux     smallint
   define arr_aux     smallint
   define fun_des     char (40)


        define  w_pf1   integer

        let     strpos  =  null
        let     strini  =  null
        let     scr_aux  =  null
        let     arr_aux  =  null
        let     fun_des  =  null

        for     w_pf1  =  1  to  200
                initialize  a_ctx14g01[w_pf1].*  to  null
        end     for

   if p_ctx14g01.titulo <> 'Agenda Disponivel' then
      open window ctx14g01 at 09,54 with form "ctx14g01"
                  attribute(form line 1, border)

   else
      open window ctx14g01b at 09,38 with form "ctx14g01b"
                  attribute(form line 1, border)

   end if

   let int_flag = false
   initialize a_ctx14g01   to null

   let arr_aux = 1
   let strini = 1
   let p_ctx14g01.popup = p_ctx14g01.popup clipped

   for strpos = 1 to length(p_ctx14g01.popup)
       if p_ctx14g01.popup[strpos, strpos] = "|" then
          let a_ctx14g01[arr_aux].fundes = p_ctx14g01.popup[strini,strpos-1]
          let strini = strpos + 1
          let arr_aux = arr_aux + 1
       end if
   end for
   let a_ctx14g01[arr_aux].fundes = p_ctx14g01.popup[strini,strpos-1]


   message "(F8)Seleciona"
   call set_count(arr_aux)

   display by name p_ctx14g01.titulo
   display array a_ctx14g01 to s_ctx14g01.*
      on key (interrupt,control-c)
         initialize a_ctx14g01   to null
         let arr_aux = 0
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let scr_aux = scr_line()
         exit display
   end display

   if p_ctx14g01.titulo <> 'Agenda Disponivel' then
   	close window  ctx14g01
   else
   	close window  ctx14g01b
   end if
   let int_flag = false

   if arr_aux = 0 then
      let fun_des = ""
   else
      let fun_des = a_ctx14g01[arr_aux].fundes
   end if

   return arr_aux,
          fun_des

 end function  ###  ctx14g01



#-----------------------------------------------------------
 function ctx14g01_carro_extra(p_ctx14g01)
#-----------------------------------------------------------
   define p_ctx14g01  record
      titulo          char(25),
      popup           char(6000)
   end record

   define a_ctx14g01  array[200] of record
      fundes          char (80)
   end record

   define strpos      smallint
   define strini      smallint
   define scr_aux     smallint
   define arr_aux     smallint
   define fun_des     char (20)
   define l_opcao     smallint


        define  w_pf1   integer

        let     strpos  =  null
        let     strini  =  null
        let     scr_aux  =  null
        let     arr_aux  =  null
        let     fun_des  =  null

        for     w_pf1  =  1  to  200
                initialize  a_ctx14g01[w_pf1].*  to  null
        end     for


   open window ctx14g01 at 10,18 with form "ctx14g01"
               attribute(form line 1, border)

   let int_flag = false
   initialize a_ctx14g01   to null

   let arr_aux = 1
   let strini = 1
   let p_ctx14g01.popup = p_ctx14g01.popup clipped
   for strpos = 1 to length(p_ctx14g01.popup)
       if p_ctx14g01.popup[strpos, strpos] = "|" then
          let a_ctx14g01[arr_aux].fundes = p_ctx14g01.popup[strini,strpos-1]
          let strini = strpos + 1
          let arr_aux = arr_aux + 1
       end if
   end for
   let a_ctx14g01[arr_aux].fundes = p_ctx14g01.popup[strini,strpos-1]

   message "(F8)Seleciona"
   call set_count(arr_aux)

   display by name p_ctx14g01.titulo
   display array a_ctx14g01 to s_ctx14g01.*
      on key (interrupt,control-c)
         initialize a_ctx14g01   to null
         let arr_aux = 0
         let l_opcao = null
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let scr_aux = scr_line()
         exit display
   end display
   close window  ctx14g01
   let int_flag = false

   if arr_aux = 0 then
      let fun_des = ""
   else
      let fun_des = a_ctx14g01[arr_aux].fundes
      let l_opcao = a_ctx14g01[arr_aux].fundes[1,2]
   end if

   return l_opcao


 end function  ###  ctx14g01_carro_extra

#-----------------------------------------------------------------------------
 function ctx14g01_tipo_logradouro(p_ctx14g01)
#-----------------------------------------------------------------------------
   define p_ctx14g01  record
      titulo          char(25),
      popup           char(6000)
   end record

   define a_ctx14g01  array[200] of record
      fundes          char (30)
   end record

   define strpos      smallint
   define strini      smallint
   define scr_aux     smallint
   define arr_aux     smallint
   define fun_des     char (20)


        define  w_pf1   integer

        let     strpos  =  null
        let     strini  =  null
        let     scr_aux  =  null
        let     arr_aux  =  null
        let     fun_des  =  null

        for     w_pf1  =  1  to  200
                initialize  a_ctx14g01[w_pf1].*  to  null
        end     for

   open window ctx14g01 at 09,25 with form "ctx14g01"
               attribute(form line 1, border)

   let int_flag = false
   initialize a_ctx14g01   to null

   let arr_aux = 1
   let strini = 1
   let p_ctx14g01.popup = p_ctx14g01.popup clipped
   for strpos = 1 to length(p_ctx14g01.popup)
       if p_ctx14g01.popup[strpos, strpos] = "|" then
          let a_ctx14g01[arr_aux].fundes = p_ctx14g01.popup[strini,strpos-1]
          let strini = strpos + 1
          let arr_aux = arr_aux + 1
       end if
   end for
   let a_ctx14g01[arr_aux].fundes = p_ctx14g01.popup[strini,strpos-1]

   message "(F8)Seleciona"
   call set_count(arr_aux)

   display by name p_ctx14g01.titulo
   display array a_ctx14g01 to s_ctx14g01.*
      on key (interrupt,control-c)
         initialize a_ctx14g01   to null
         let arr_aux = 0
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let scr_aux = scr_line()
         exit display
   end display
   close window  ctx14g01
   let int_flag = false

   if arr_aux = 0 then
      let fun_des = ""
   else
      let fun_des = a_ctx14g01[arr_aux].fundes
   end if
   return fun_des

 end function  ###  ctx14g01



# -----------------------------------------------------------------------------
 function ctx14g01_tipo_marginal(p_ctx14g01)
# -----------------------------------------------------------------------------
   define p_ctx14g01  record
      titulo          char(25),
      popup           char(6000)
   end record

   define a_ctx14g01  array[200] of record
      fundes          char (100)
   end record

   define strpos      smallint
   define strini      smallint
   define scr_aux     smallint
   define arr_aux     smallint
   define fun_des     char (100)


        define  w_pf1   integer

        let     strpos  =  null
        let     strini  =  null
        let     scr_aux  =  null
        let     arr_aux  =  null
        let     fun_des  =  null

        for     w_pf1  =  1  to  200
                initialize  a_ctx14g01[w_pf1].*  to  null
        end     for

   open window ctx14g01 at 09,54 with form "ctx14g01"
               attribute(form line 1, border)

   let int_flag = false
   initialize a_ctx14g01   to null

   let arr_aux = 1
   let strini = 1
   let p_ctx14g01.popup = p_ctx14g01.popup clipped
   for strpos = 1 to length(p_ctx14g01.popup)
       if p_ctx14g01.popup[strpos, strpos] = "|" then
          let a_ctx14g01[arr_aux].fundes = p_ctx14g01.popup[strini,strpos-1]
          let strini = strpos + 1
          let arr_aux = arr_aux + 1
       end if
   end for
   let a_ctx14g01[arr_aux].fundes = p_ctx14g01.popup[strini,strpos-1]

   message "(F8)Seleciona"
   call set_count(arr_aux)

   display by name p_ctx14g01.titulo
   display array a_ctx14g01 to s_ctx14g01.*
      on key (interrupt,control-c)
         initialize a_ctx14g01   to null
         let arr_aux = 0
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let scr_aux = scr_line()
         exit display
   end display
   close window  ctx14g01
   let int_flag = false

   if arr_aux = 0 then
      let fun_des = ""
   else
      let fun_des = a_ctx14g01[arr_aux].fundes
   end if
   return fun_des

 end function  ###  ctx14g01



# -----------------------------------------------------------------------------
 function ctx14g01a(p_ctx14g01)
# -----------------------------------------------------------------------------
   define p_ctx14g01  record
      titulo          char(25),
      popup           char(6000)
   end record

   define a_ctx14g01  array[200] of record
      fundes          char (100)
   end record

   define strpos      smallint
   define strini      smallint
   define scr_aux     smallint
   define arr_aux     smallint
   define fun_des     char (100)


        define  w_pf1   integer

        let     strpos  =  null
        let     strini  =  null
        let     scr_aux  =  null
        let     arr_aux  =  null
        let     fun_des  =  null

        for     w_pf1  =  1  to  200
                initialize  a_ctx14g01[w_pf1].*  to  null
        end     for

   open window ctx14g01 at 13,12 with form "ctx14g01a"
               attribute(form line 1, border)

   let int_flag = false
   initialize a_ctx14g01   to null

   let arr_aux = 1
   let strini = 1
   let p_ctx14g01.popup = p_ctx14g01.popup clipped
   for strpos = 1 to length(p_ctx14g01.popup)
       if p_ctx14g01.popup[strpos, strpos] = "|" then
          let a_ctx14g01[arr_aux].fundes = p_ctx14g01.popup[strini,strpos-1]
          let strini = strpos + 1
          let arr_aux = arr_aux + 1
       end if
   end for
   let a_ctx14g01[arr_aux].fundes = p_ctx14g01.popup[strini,strpos-1]

   message "(F8)Seleciona"
   call set_count(arr_aux)

   display by name p_ctx14g01.titulo
   display array a_ctx14g01 to s_ctx14g01a.*
      on key (interrupt,control-c)
         initialize a_ctx14g01   to null
         let arr_aux = 0
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let scr_aux = scr_line()
         exit display
   end display
   close window  ctx14g01
   let int_flag = false

   if arr_aux = 0 then
      let fun_des = ""
   else
      let fun_des = a_ctx14g01[arr_aux].fundes
   end if
   return fun_des

 end function  ###  ctx14g01



 # -----------------------------------------------------------------------------
 function ctx14g01_tipo_sentido2(p_ctx14g01)
# -----------------------------------------------------------------------------
   define p_ctx14g01  record
      titulo          char(25),
      popup           char(6000)
   end record

   define a_ctx14g01  array[200] of record
      fundes          char (100)
   end record

   define strpos      smallint
   define strini      smallint
   define scr_aux     smallint
   define arr_aux     smallint
   define fun_des     char (100)


        define  w_pf1   integer

        let     strpos  =  null
        let     strini  =  null
        let     scr_aux  =  null
        let     arr_aux  =  null
        let     fun_des  =  null

        for     w_pf1  =  1  to  200
                initialize  a_ctx14g01[w_pf1].*  to  null
        end     for

   open window ctx14g01 at 09,54 with form "ctx14g01"
               attribute(form line 1, border)

   let int_flag = false
   initialize a_ctx14g01   to null

   let arr_aux = 1
   let strini = 1
   let p_ctx14g01.popup = p_ctx14g01.popup clipped
   for strpos = 1 to length(p_ctx14g01.popup)
       if p_ctx14g01.popup[strpos, strpos] = "|" then
          let a_ctx14g01[arr_aux].fundes = p_ctx14g01.popup[strini,strpos-1]
          let strini = strpos + 1
          let arr_aux = arr_aux + 1
       end if
   end for
   let a_ctx14g01[arr_aux].fundes = p_ctx14g01.popup[strini,strpos-1]

   message "(F8)Seleciona"
   call set_count(arr_aux)

   display by name p_ctx14g01.titulo
   display array a_ctx14g01 to s_ctx14g01.*
      on key (interrupt,control-c)
         initialize a_ctx14g01   to null
         let arr_aux = 0
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let scr_aux = scr_line()
         exit display
   end display
   close window  ctx14g01
   let int_flag = false

   if arr_aux = 0 then
      let fun_des = ""
   else
      let fun_des = a_ctx14g01[arr_aux].fundes
   end if
   return fun_des

 end function  ###  ctx14g01



# -----------------------------------------------------------------------------
 function ctx14g01_tipo_pista(p_ctx14g01)
# -----------------------------------------------------------------------------
   define p_ctx14g01  record
      titulo          char(25),
      popup           char(6000)
   end record

   define a_ctx14g01  array[200] of record
      fundes          char (100)
   end record

   define strpos      smallint
   define strini      smallint
   define scr_aux     smallint
   define arr_aux     smallint
   define fun_des     char (100)


        define  w_pf1   integer

        let     strpos  =  null
        let     strini  =  null
        let     scr_aux  =  null
        let     arr_aux  =  null
        let     fun_des  =  null

        for     w_pf1  =  1  to  200
                initialize  a_ctx14g01[w_pf1].*  to  null
        end     for

   open window ctx14g01 at 09,54 with form "ctx14g01"
               attribute(form line 1, border)

   let int_flag = false
   initialize a_ctx14g01   to null

   let arr_aux = 1
   let strini = 1
   let p_ctx14g01.popup = p_ctx14g01.popup clipped
   for strpos = 1 to length(p_ctx14g01.popup)
       if p_ctx14g01.popup[strpos, strpos] = "|" then
          let a_ctx14g01[arr_aux].fundes = p_ctx14g01.popup[strini,strpos-1]
          let strini = strpos + 1
          let arr_aux = arr_aux + 1
       end if
   end for
   let a_ctx14g01[arr_aux].fundes = p_ctx14g01.popup[strini,strpos-1]

   message "(F8)Seleciona"
   call set_count(arr_aux)

   display by name p_ctx14g01.titulo
   display array a_ctx14g01 to s_ctx14g01.*
      on key (interrupt,control-c)
         initialize a_ctx14g01   to null
         let arr_aux = 0
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let scr_aux = scr_line()
         exit display
   end display
   close window  ctx14g01
   let int_flag = false

   if arr_aux = 0 then
      let fun_des = ""
   else
      let fun_des = a_ctx14g01[arr_aux].fundes
   end if
   return fun_des

 end function  ###  ctx14g01
#-----------------------------------------------------------
 function ctx14g01_motivos_azul(p_ctx14g01)
#-----------------------------------------------------------
   define p_ctx14g01  record
      titulo          char(30),
      popup           char(6000)
   end record
   define a_ctx14g01  array[200] of record
      fundes          char (100)
   end record
   define strpos      smallint
   define strini      smallint
   define scr_aux     smallint
   define arr_aux     smallint
   define fun_des     char (30)
   define l_opcao     smallint
        define  w_pf1   integer
        let     strpos  =  null
        let     strini  =  null
        let     scr_aux =  null
        let     arr_aux =  null
        let     fun_des =  null
        for     w_pf1  =  1  to  200
                initialize  a_ctx14g01[w_pf1].*  to  null
        end     for
   open window ctx14g01c at 11,50 with form "ctx14g01c"
                        attribute(form line 1, border)
   let int_flag = false
   initialize a_ctx14g01   to null
   let arr_aux = 1
   let strini = 1
   let p_ctx14g01.popup = p_ctx14g01.popup clipped
   for strpos = 1 to length(p_ctx14g01.popup)
       if p_ctx14g01.popup[strpos, strpos] = "|" then
          let a_ctx14g01[arr_aux].fundes = p_ctx14g01.popup[strini,strpos-1]
          let strini = strpos + 1
          let arr_aux = arr_aux + 1
       end if
   end for
   let a_ctx14g01[arr_aux].fundes = p_ctx14g01.popup[strini,strpos-1]
   message "(F8)Seleciona"
   call set_count(arr_aux)
   display by name p_ctx14g01.titulo
   display array a_ctx14g01 to s_ctx14g01.*
      on key (interrupt,control-c)
         initialize a_ctx14g01   to null
         let arr_aux = 0
         let l_opcao = null
         exit display
      on key (F8)
         let arr_aux = arr_curr()
         let scr_aux = scr_line()
         exit display
   end display
   close window  ctx14g01c
   let int_flag = false
   if arr_aux = 0 then
      let fun_des = ""
   else
      let fun_des = a_ctx14g01[arr_aux].fundes
      let l_opcao = a_ctx14g01[arr_aux].fundes[1,2]
   end if
   return l_opcao
 end function  ###  ctx14g01_motivos_azul