#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Porto Seguro                                              #
# Modulo.........: ctb85g01                                                  #
# Objetivo.......: Fazer acesso a tabela  de historico generica.             #
#                                                                            #
#                                                                            #
# Analista Resp. : Norton Nery Santanna                                      #
# PSI            : 226300                                                    #
#............................................................................#
# Desenvolvimento: Eliane Ortiz, META                                        #
# Liberacao      : 05/08/2008                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
# 05/05/2010 Burini        255734    Integração PSO x VST                    #
#----------------------------------------------------------------------------#
# 21/10/2010 Alberto Rodrigues       Correcao de ^M                          #
#----------------------------------------------------------------------------#
# 18/11/2010 Robert Lima   02086     Retirado o startlog                     #
#----------------------------------------------------------------------------#
database porto

define m_prep_ctb85g01  smallint
define teste  char(1)
define m_path char(80)

#----------------------------------------------------------
   function ctb85g01_prepare()
#----------------------------------------------------------

   define l_sql  char(500)

   let l_sql = 'select conchv         '
              ,'     , hstseq         '
              ,'     , hsttex         '
              ,'     , caddat         '
              ,'     , cademp         '
              ,'     , cadmat         '
              ,'     , cadusrtip      '
              ,'  from datmcadalthst  '
              ,' where hstide = ?     '
              ,'   and conchv = ?     '
              ,' order by caddat desc '
              ,'        , hstseq      '

   prepare p_ctb85g01_001 from l_sql
   declare c_ctb85g01_001 scroll cursor  for p_ctb85g01_001

   let l_sql = 'select  nvl(max( hstseq ),0 )+ 1 '
              ,'  from datmcadalthst  '
              ,' where hstide = ?     '
              ,'   and conchv = ?     '

   prepare p_ctb85g01_002 from l_sql
   declare c_ctb85g01_002 cursor for p_ctb85g01_002

   let l_sql = 'insert into datmcadalthst( hstide      '
              ,'                         , conchv      '
              ,'                         , hstseq      '
              ,'                         , hsttex      '
              ,'                         , caddat      '
              ,'                         , cademp      '
              ,'                         , cadmat      '
              ,'                         , cadusrtip ) '
              ,' values ( ?,?,?,?,?,?,?,? )            '

   prepare p_ctb85g01_003 from l_sql

   let m_prep_ctb85g01 = true

end function

#----------------------------------------------------------
   function ctb85g01_consult_hist( l_tipo, l_codigo, l_pos )
#----------------------------------------------------------

   define l_tipo    like datmcadalthst.hstide
        , l_codigo  like datmcadalthst.conchv
        , l_pos     smallint

   define lr_retorno record
                     srrcoddig  like datmcadalthst.conchv
                   , srrhstseq  like datmcadalthst.hstseq
                   , srrhsttxt  like datmcadalthst.hsttex
                   , caddat     like datmcadalthst.caddat
                   , cademp     like datmcadalthst.cademp
                   , cadmat     like datmcadalthst.cadmat
                   , cadusrtip  like datmcadalthst.cadusrtip
                   , erro       smallint
                 end record

   define l_msg   varchar(100)
        , l_msg2  varchar(060)

   initialize lr_retorno to null

   let l_msg  = null
   let l_msg2 = null
   let lr_retorno.erro = 0

   if m_prep_ctb85g01 is null or
      m_prep_ctb85g01 <> true then
      call ctb85g01_prepare()
   end if

   open c_ctb85g01_001 using l_tipo
                         , l_codigo

   whenever error continue
   fetch relative l_pos c_ctb85g01_001 into lr_retorno.srrcoddig
                                        , lr_retorno.srrhstseq
                                        , lr_retorno.srrhsttxt
                                        , lr_retorno.caddat
                                        , lr_retorno.cademp
                                        , lr_retorno.cadmat
                                        , lr_retorno.cadusrtip
   whenever error stop

   if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        initialize lr_retorno to null
        let l_msg = 'Dados nao encontrados.'
       # call errorlog( l_msg )
       # error  'Dados nao encontrados.'
       # sleep 2
        let lr_retorno.erro = 1
     else

        let l_msg2 = 'Erro SELECT c_ctb85g01_001 / ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2], '.'
       # call errorlog( l_msg2 )
        let l_msg = ' CTB85G01 / ctb85g01_consult_hist() / ', l_tipo
                                                      ,' / ', l_codigo
       # call errorlog( l_msg )
        error 'Erro SELECT c_ctb85g01_001 / ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2], '.'
        let l_msg = l_msg2 clipped, l_msg
        initialize lr_retorno to null
        sleep 2
        let lr_retorno.erro = 2
     end if
   end if

   return lr_retorno.erro
        , lr_retorno.srrcoddig
        , lr_retorno.srrhstseq
        , lr_retorno.srrhsttxt
        , lr_retorno.caddat
        , lr_retorno.cademp
        , lr_retorno.cadmat
        , lr_retorno.cadusrtip

end function

#----------------------------------------------------------
   function ctb85g01_grava_hist( lr_param )
#----------------------------------------------------------

   define lr_param record
                   tipo      like datmcadalthst.hstide
                 , codigo    like datmcadalthst.conchv
                 , texto     like datmcadalthst.hsttex
                 , caddat    like datmcadalthst.caddat
                 , cademp    like datmcadalthst.cademp
                 , cadmat    like datmcadalthst.cadmat
                 , cadusrtip like datmcadalthst.cadusrtip
              end record

   define lr_retorno record
                     errcod smallint
                   , errmsg char(200)
                 end record

   define l_hstseq like datmcadalthst.hstseq
        , l_msg    varchar(060)

   let l_hstseq = 0
   let l_msg    = null

   let m_path = f_path("DAT", "LOG")

   if m_path is null then
      let m_path = 'ctb85g01.log'
    else
      let m_path = m_path clipped, '/ctb85g01.log'
   end if

   #call startlog(m_path)

   initialize lr_retorno to null

   if m_prep_ctb85g01 is null or
      m_prep_ctb85g01 <> true then
      call ctb85g01_prepare()
   end if

   open c_ctb85g01_002 using lr_param.tipo
                         , lr_param.codigo

   whenever error continue
   fetch c_ctb85g01_002 into l_hstseq
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let l_msg = 'Erro SELECT c_ctb85g01_002 / ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2], '.'
    #  call errorlog( l_msg )
      let lr_retorno.errmsg = ' CTB85G01 / ctb85g01_grava_hist() / ', lr_param.tipo
                                                              ,' / ', lr_param.codigo
     # call errorlog( lr_retorno.errmsg )
      error 'Erro SELECT c_ctb85g01_002 / ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2], '.'
      sleep 2
      let lr_retorno.errcod = 2
      let lr_retorno.errmsg = l_msg clipped, lr_retorno.errmsg
      return lr_retorno.errcod
           , lr_retorno.errmsg
   end if

   whenever error continue
   execute p_ctb85g01_003 using lr_param.tipo
                            , lr_param.codigo
                            , l_hstseq
                            , lr_param.texto
                            , lr_param.caddat
                            , lr_param.cademp
                            , lr_param.cadmat
                            , lr_param.cadusrtip
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let l_msg = 'Erro INSERT p_ctb85g01_003 / ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2], '. '
     # call errorlog( l_msg )
      let lr_retorno.errmsg = ' CTB85G01 / ctb85g01_grava_hist() / ', lr_param.tipo
                                                              ,' / ', lr_param.codigo clipped
                                                              ,' / ', l_hstseq
                                                              ,' / ', lr_param.texto clipped
                                                              ,' / ', lr_param.caddat
                                                              ,' / ', lr_param.cademp
                                                              ,' / ', lr_param.cadmat
                                                              ,' / ', lr_param.cadusrtip clipped
     # call errorlog( lr_retorno.errmsg )
      error 'Erro INSERT p_ctb85g01_003 / ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2], '. '
      sleep 2
      let lr_retorno.errcod = 2
      let lr_retorno.errmsg = l_msg clipped, lr_retorno.errmsg
      return lr_retorno.errcod
           , lr_retorno.errmsg
   end if

   let lr_retorno.errcod = 0
   let lr_retorno.errmsg = null

   return lr_retorno.errcod
        , lr_retorno.errmsg

end function

#----------------------------------------------------------
   function ctb85g01_gera_arq( lr_param )
#----------------------------------------------------------

   define lr_param record
                   msg   char(200)
                 , acao  char(01)
                 , cam   char(60)
               end record


   define l_cmd     char(200)

   let l_cmd     = null


   if lr_param.acao = 'G' then
      let lr_param.cam =  f_path('DBS','ARQUIVO')

      if lr_param.cam is null or
         lr_param.cam = ' '   then
         let lr_param.cam  = '.'
      end if

      let lr_param.cam = lr_param.cam clipped, '/ctb85g01.html'

      let l_cmd = 'echo "', lr_param.msg clipped, '" > 'clipped, lr_param.cam

      run l_cmd

      return lr_param.cam
   end if

   if lr_param.cam is not null then
      let l_cmd = 'rm -f ', lr_param.cam
                , ' 2> /dev/null'

      run l_cmd

      let lr_param.cam = null
   end if

   return lr_param.cam

end function

#----------------------------------------------------------
 function ctb85g01_mtcorpo_email( lr_param)
#----------------------------------------------------------

   define lr_param record
                   l_data  char(200)
                 , l_hora  char(01)
		 , empcod  like  isskfunc.empcod
		 , usrtip  like  isskfunc.usrtip
		 , funmat  like  isskfunc.funmat
		 , texto     char(70)
               end record

  define l_path    char(60)
  define l_cmd     char(200)
  define l_texto   char(70)
  define l_cmtnom  like isskfunc.funnom

  initialize l_cmtnom   to null
  initialize l_cmd      to null

  select funnom  into  l_cmtnom
   from isskfunc
  where funmat = lr_param.funmat
  and empcod  = lr_param.empcod

  let l_texto = "Data da Modificacao : ",lr_param.l_data

  call ctb85g01_gera_arq(l_texto
                         ,'G'
                         ,'')
       returning l_path

  let l_texto = "Hora da Modificacao : ", lr_param.l_hora
  let l_cmd = 'echo "',l_texto,'" >> ',l_path
  run l_cmd

  let l_texto = "                      "
  let l_cmd = 'echo "',l_texto,'" >> ',l_path
  run l_cmd

  let l_texto = "Dados do funcionario que Realizou a Modificacao:"
  let l_cmd = 'echo "',l_texto,'" >> ',l_path
  run l_cmd

  let l_texto = "------------------------------------------------"
  let l_cmd = 'echo "',l_texto,'" >> ',l_path
  run l_cmd

  let l_texto = "                      "
  let l_cmd = 'echo "',l_texto,'" >> ',l_path
  run l_cmd

  let l_texto = "Empresa..: ",  lr_param.empcod
  let l_cmd = 'echo "',l_texto,'" >> ',l_path
  run l_cmd

  let l_texto = "Tipo.....: ",  lr_param.usrtip
  let l_cmd = 'echo "',l_texto,'" >> ', l_path
  run l_cmd

  let l_texto = "Matricula: ",  lr_param.funmat
  let l_cmd = 'echo "',l_texto,'" >> ',l_path
  run l_cmd

  let l_texto = "Nome.....: ",  l_cmtnom
  let l_cmd = 'echo "',l_texto,'" >> ',l_path
  run l_cmd

  let l_texto = "                      "
  let l_cmd = 'echo "',l_texto,'" >> ',l_path
  run l_cmd

  let l_texto = "Modificacao Realizada :"
  let l_cmd = 'echo "',l_texto,'" >> ',l_path
  run l_cmd

  let l_texto = "-----------------------"
  let l_cmd = 'echo "',l_texto,'" >> ',l_path
  run l_cmd

  let l_texto = "                      "
  let l_cmd = 'echo "',l_texto,'" >> ',l_path
  run l_cmd

  return l_path

end function

#----------------------------------------------------------
 function ctb85g01_mtcorpo_email_html( lr_param)
#----------------------------------------------------------

   define lr_param record
		   modulo    char(08)
                 , data      char(200)
                 , hora      datetime hour to minute
		 , empcod    like  isskfunc.empcod
		 , usrtip    like  isskfunc.usrtip
		 , funmat    like  isskfunc.funmat
		 , titulo    char(100)
                 , prshstdes char(2000)
          end record

  define l_dbsseqcod  like dbsmhstprs.dbsseqcod,
         l_prshstdes2 like dbsmhstprs.prshstdes,
         l_cmtnom     like isskfunc.funnom,
         l_count,
         l_iter,
         l_length,
         l_length2    smallint,
         l_msg        char(50),
         l_erro       smallint,
         teste         char(1),
         l_stt       smallint,
         l_path      char(100),
         l_cmd      char(4000),
         l_texto_html char(32000)

  initialize l_cmtnom   to null
  initialize l_cmd      to null
  initialize l_texto_html to null
  initialize l_path     to null

  select funnom  into  l_cmtnom
   from isskfunc
  where funmat = lr_param.funmat
  and empcod  = lr_param.empcod

  let l_texto_html = "<html>",
                         "<body>",
                             "<table width=100% border=0  cellpadding='0' cellspacing='5'>",
                                 "<tr bgcolor=red>",
                                     "<td><font face=arial size=2 color=white><center><b>MODIFICACAO REALIZADA</b></center></font>",
                                     "</td>",
                                 "</tr>",
                                 "<tr>",
                                     "<td><font face=arial size=2>",lr_param.prshstdes clipped, "</td>",
                                 "</tr>",
                             "</table>",
                             "<br><font face=arial size=2>",
                             "Modificado em <b>", lr_param.data clipped, "</b> as <b>", lr_param.hora,"</b> ",
                             "pelo usuario <b>", lr_param.funmat , " - ", l_cmtnom, "</b><br><br>",
                             "Porto Seguro Seguros<br>Porto Socorro"

   let l_erro = ctx22g00_envia_email_html(lr_param.modulo ,
                                          lr_param.titulo,
                                          l_texto_html clipped)
   return l_erro


end function


