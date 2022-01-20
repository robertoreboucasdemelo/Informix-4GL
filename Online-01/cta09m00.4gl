#############################################################################
# Nome do Modulo: cta09m00                                             Ruiz #
# Atendimento ao Atendente - Dados do solicitante                  Out/2002 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 09/10/2008  Psi 230.650  Alberto      Inclusao campo atd a ser localizado.#
#############################################################################
 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-------------------------------------------------------------------------------
 function cta09m00()
#-------------------------------------------------------------------------------

   define d_cta09m00      record
          empcod          like isskfunc.empcod,
          funmat          like isskfunc.funmat,
          funnom          like isskfunc.funnom,
          atdnum          like datmatd6523.atdnum,
          confirma        char(01)
   end record

   define ws              record
          data            date                    ,
          hora            datetime hour to minute ,
          empcod          like isskfunc.empcod    ,
          funmat          like isskfunc.funmat    ,
          funnom          like isskfunc.funnom    ,
          param           char(100)               ,
          ret             integer                 ,
          sissgl          like ibpmsistprog.sissgl,
          comando         char(900)
   end record

   define  d_cta09m00_ret record
           resultado      smallint
          ,mensagem       char(60)
          ,funmat         like isskfunc.funmat
          ,ciaempcod      like datmatd6523.ciaempcod
   end record

   define w_comando       char(600)


	let	w_comando  =  null

	initialize  d_cta09m00.*  to  null

	initialize  ws.*  to  null

	initialize d_cta09m00_ret.* to null


   call cts14g02("N", "cta09m00")

 #------------------------------------------------------------------------------
 # Inicializacao de variaveis
 #------------------------------------------------------------------------------
   initialize d_cta09m00,
              ws        ,
              w_comando  to null

       let w_comando = "select funnom  "         ,
                         "from ISSKFUNC "        ,
                              "where empcod = ? ",
                                "and funmat = ? "

       prepare p_cta09m00_001  from   w_comando
       declare c_cta09m00_001  cursor for p_cta09m00_001


 #------------------------------------------------------------------------------
 # Inicio da tela
 #------------------------------------------------------------------------------

   open window win_cta09m00 at 03,02 with form "cta09m00"
        attribute (form line first)


   while true

   #----------------------------------------------------------------------------
   # Inicializacao de variaveis
   #----------------------------------------------------------------------------
     let int_flag     = false

     initialize d_cta09m00 to null

   #----------------------------------------------------------------------------
   # Input
   #----------------------------------------------------------------------------
     clear form

     input by name d_cta09m00.* without defaults

        before field empcod
           display by name d_cta09m00.empcod   attribute(reverse)

        after  field empcod
           display by name d_cta09m00.empcod

           if  fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field funmat
           end if

           if  d_cta09m00.empcod = 0      or
               d_cta09m00.empcod is null  then
               call cto00m01("S")
                    returning d_cta09m00.empcod,
                              d_cta09m00.funmat,
                              d_cta09m00.funnom

               next field empcod
           end if

        before field funmat
           display by name d_cta09m00.funmat   attribute(reverse)

        after  field funmat
           display by name d_cta09m00.funmat

           if  fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field empcod
           end if

           if  d_cta09m00.funmat <> 0         and
               d_cta09m00.funmat is not null  then
               open  c_cta09m00_001 using d_cta09m00.empcod,
                                      d_cta09m00.funmat
               fetch c_cta09m00_001 into  d_cta09m00.funnom
                 if  sqlca.sqlcode <> 0  then
                     if  sqlca.sqlcode = 100  then
                         error " Matricula nao cadastrada!"
                         call cto00m01("S")
                              returning d_cta09m00.empcod,
                                        d_cta09m00.funmat,
                                        d_cta09m00.funnom
                     else
                         error " Erro (", sqlca.sqlcode, ") durante ",
                              "a confirmacao da matricula. AVISE A INFORMATICA!"
                     end if
                     next field empcod
                 end if

               display by name d_cta09m00.funnom
           else
               error " Informe a matricula do funcionario! "
               next field funmat
           end if

        # Psi 230.650
        before field atdnum
           display by name d_cta09m00.atdnum   attribute(reverse)

        after  field atdnum
           display by name d_cta09m00.atdnum

           if  fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field funmat
           end if

           if  d_cta09m00.atdnum <> 0         and
               d_cta09m00.atdnum is not null  then

               # Validar Matricula do atendente com Numero do Atendimento
               call  cta09m00_atd_mat( d_cta09m00.empcod,
                                       d_cta09m00.funmat,
                                       d_cta09m00.atdnum )
                     returning d_cta09m00_ret.resultado,
                               d_cta09m00_ret.mensagem ,
                               d_cta09m00_ret.funmat   ,
                               d_cta09m00_ret.ciaempcod


               if d_cta09m00_ret.resultado <> 1 then
                  error d_cta09m00_ret.mensagem , " Empresa <", d_cta09m00_ret.ciaempcod,">"
                  next field atdnum
               end if

               if d_cta09m00.funmat <> d_cta09m00_ret.funmat then
                  error "Este atendimento nao pertence a esta Matricula !", d_cta09m00_ret.funmat
                  next field atdnum
               else
                  ## Carrega a Global Atdnum e g_documento.ciaempcod
                  let g_documento.atdnum    = d_cta09m00.atdnum
                  let g_documento.ciaempcod = d_cta09m00_ret.ciaempcod
               end if

               display by name d_cta09m00.atdnum
            else
               error " Informe o Numero do Atendimento! "
               next field atdnum
           end if
        # Psi 230.650

        before field confirma
           let d_cta09m00.confirma = "S"

           display by name d_cta09m00.confirma attribute(reverse)

        after  field confirma
           display by name d_cta09m00.confirma

           if  fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field atdnum
           end if

           if  d_cta09m00.confirma = "S"  then
               if ( d_cta09m00.empcod = 0      or
                    d_cta09m00.empcod is null    )  and
                  ( d_cta09m00.funmat = 0      or
                    d_cta09m00.funmat is null    )  then
                   error "Informe a empresa ou ",
                         "a matricula do atendente! "
                   next field empcod
               end if
           end if

           exit input

        on key (interrupt)
           exit input

     end input

     if  int_flag  then
         let int_flag = false
         exit while
     end if

     if  d_cta09m00.confirma       = "S" then
         let g_documento.apoio     = "S"
         let g_documento.empcodatd = d_cta09m00.empcod
         let g_documento.funmatatd = d_cta09m00.funmat
         select usrtip
               into g_documento.usrtipatd
               from isskfunc
              where empcod = d_cta09m00.empcod
                and funmat = d_cta09m00.funmat
         exit while
     else
         initialize g_documento.apoio to null
     end if

   end while
   if g_issk.funmat = 601566 then
      display "* g_documento.apoio    = ", g_documento.apoio
      display "* g_documento.empcodatd= ", g_documento.empcodatd
      display "* g_documento.funmatatd= ", g_documento.funmatatd
      display "* g_documento.usrtipatd= ", g_documento.usrtipatd
   end if
   close window win_cta09m00

end function

#---------------------------------------------------------------------------
function cta09m00_atd_mat(l_val_param) ## Validar Matricula com atendimento
#---------------------------------------------------------------------------
 define l_val_param     record
        empcod          like isskfunc.empcod,
        funmat          like isskfunc.funmat,
        atdnum          like datmatd6523.atdnum
 end record

 define l_usrtip like isskfunc.usrtip

 define lr_retorno            record
         ciaempcod        like datmatd6523.ciaempcod
        ,funmat           like datmatd6523.funmat
        ,empcod           like datmatd6523.empcod
        ,usrtip           like datmatd6523.usrtip
        ,resultado        smallint
        ,mensagem         char(60)
 end record

 initialize l_usrtip to null
 initialize lr_retorno.* to null

 let l_usrtip = "F"

 # Verifica o usrtip

 select usrtip
   into l_usrtip
   from isskfunc
  where empcod = l_val_param.empcod
    and funmat = l_val_param.funmat

  if sqlca.sqlcode = 100  then
     return  lr_retorno.resultado
            ,lr_retorno.mensagem
            ,lr_retorno.funmat
            ,lr_retorno.empcod
            ,lr_retorno.usrtip
            ,lr_retorno.ciaempcod
  end if

  call ctd24g00_valida_atd( l_val_param.atdnum,"" , 2  )
  returning lr_retorno.resultado
           ,lr_retorno.mensagem
           ,lr_retorno.funmat
           ,lr_retorno.empcod
           ,lr_retorno.usrtip
           ,lr_retorno.ciaempcod

return  lr_retorno.resultado,
        lr_retorno.mensagem ,
        lr_retorno.funmat   ,
        lr_retorno.ciaempcod

end function
