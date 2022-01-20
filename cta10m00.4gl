#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema       : Ct24h                                                        #
# Modulo        : cta10m00.4gl                                                 #
# Analista Resp.: Ruiz                                                         #
# OSF / PSI     : 27987 / 172413                                               #
# Dados para ligacao sem documento.                                            #
#..............................................................................#
# Desenvolvimento: Meta, Eduardo Luis Nogueira                                 #
# Liberacao      : 27/10/2003                                                  #
#..............................................................................#
#                                                                              #
#                  * * * Alteracoes * * *                                      #
#                                                                              #
# Data        Autor Fabrica  Origem    Alteracao                               #
#------------------------------------------------------------------------------#
# 28/11/2006  Ruiz           psi205206 Implementacao da Azul Seguros.          #
#------------------------------------------------------------------------------#
# 15/05/2007 Eduardo Vieira PSI207233  Debito por centro de custo              #
#------------------------------------------------------------------------------#
# 14/10/2008 Carla Rampazzo PSI230650  Na pesquisa por Atendimento carregar da-#
#                                      dos na tela e solicitar confirmacao     #
#------------------------------------------------------------------------------#
# 26/08/2009 Carla Rampazzo CT         Nao sera mais possivel slecionar Empresa#
#                                      de Atendimento <> 1 e 35 pois a Porto   #
#                                      Socorro nao esta preparado para Pagto.  #
#------------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepara_sql   smallint

#---------------------------#
 function cta10m00_prepara()
#---------------------------#
 define l_sql   char(500)

 let l_sql =  null

 let l_sql = ' select a.cornom ',
               ' from gcakcorr a, gcaksusep b ',
              ' where b.corsus = ? ',
                ' and a.corsuspcp = b.corsuspcp '

 prepare p_cta10m00_001 from l_sql
 declare c_cta10m00_001 cursor for p_cta10m00_001
 #---------------------------------------------

 let l_sql = ' select funnom ',
               ' from isskfunc ',
              ' where funmat = ? ',
              ' and empcod = ? '

 prepare p_cta10m00_002 from l_sql
 declare c_cta10m00_002 cursor for p_cta10m00_002
 #---------------------------------------------

 #---------------------------------------------

 let l_sql = ' select empnom ',
               ' from gabkemp ',
              ' where empcod = ? '

 prepare p_cta10m00_003 from l_sql
 declare c_cta10m00_003 cursor for p_cta10m00_003
 #---------------------------------------------

 #---------------------------------------------

 let l_sql = ' select count(*) ',
               ' from isskfunc ',
              ' where funmat = ? ',
                ' and empcod = ? '

 prepare p_cta10m00_004 from l_sql
 declare c_cta10m00_004 cursor for p_cta10m00_004
 #---------------------------------------------



 let m_prepara_sql = true

end function

#---------------------------------#
 function cta10m00_entrada_dados()
#---------------------------------#
 define lr_cta10m00 record
 	  empcodatd  like gabkemp.empcod   ,
     empnomatd  like gabkemp.empnom   ,
     pestip     like gsakseg.pestip   ,
     cgccpfnum  like gsakseg.cgccpfnum,
     cgcord     like gsakseg.cgcord   ,
     cgccpfdig  like gsakseg.cgccpfdig,
     corsus     like gcaksusep.corsus ,
     cornom     like gcakcorr.cornom  ,
     empcod     like gabkemp.empcod   , ####### PSI207233
     empnom     like gabkemp.empnom   , ####### PSI207233
     funmat     like isskfunc.funmat  ,
     funnom     like isskfunc.funnom  ,
     dddcod     like datmreclam.dddcod,
     ctttel     like datmreclam.ctttel,
     atdnum     char(24)
 end record

 define l_cgccpfdig like gsakseg.cgccpfdig
 define l_param     char(01),
        l_tam       smallint,
        l_funnom    like isskfunc.rhmfunnom,
        l_empcod    like isskfunc.empcod,
        l_funmat    like isskfunc.funmat,
        l_erro      integer,
        l_cont      integer,
        l_cont2     integer,
        l_confirma  char(01)


 let l_cgccpfdig = null
 let l_param     = null
 let l_tam       = null
 let l_funnom    = null
 let l_empcod    = null
 let l_funmat    = null
 let l_erro      = null
 let l_confirma  = null
 let l_cont      = 0
 let l_cont2     = 0


 initialize  lr_cta10m00.*  to  null

 if m_prepara_sql is null or
    m_prepara_sql <> true then
    call cta10m00_prepara()
 end if

 if g_documento.atdnum < 0 then
    let g_documento.atdnum = 0
 end if

 if g_documento.atdnum is null or
    g_documento.atdnum =  0    then

    let int_flag               = false
    let g_documento.corsus     = null
    let g_documento.dddcod     = null
    let g_documento.ctttel     = null
    let g_documento.funmat     = null

    if g_documento.ciaempcod = 84 and
       g_documento.cgccpfnum is not null then
       let lr_cta10m00.cgccpfnum = g_documento.cgccpfnum
       let lr_cta10m00.cgcord    = g_documento.cgcord
       let lr_cta10m00.cgccpfdig = g_documento.cgccpfdig
    else
       let g_documento.cgccpfnum  = null
       let g_documento.cgcord     = null
       let g_documento.cgccpfdig  = null
    end if
 else
    let lr_cta10m00.empcodatd = g_documento.empcodmat
    let lr_cta10m00.corsus    = g_documento.corsus
    let lr_cta10m00.dddcod    = g_documento.dddcod
    let lr_cta10m00.ctttel    = g_documento.ctttel
    let lr_cta10m00.funmat    = g_documento.funmat
    let lr_cta10m00.empcod    = g_issk.empcod
    let lr_cta10m00.cgccpfnum = g_documento.cgccpfnum
    let lr_cta10m00.cgcord    = g_documento.cgcord
    let lr_cta10m00.cgccpfdig = g_documento.cgccpfdig
    let lr_cta10m00.atdnum    = "Atendimento:["
				,g_documento.atdnum using "######&&&&" , "]"

    if lr_cta10m00.cgccpfnum is not null and
       lr_cta10m00.cgccpfnum <> 0        then

       if lr_cta10m00.cgcord is null or
          lr_cta10m00.cgcord =  0    then
          let lr_cta10m00.pestip = "F"
       else
          let lr_cta10m00.pestip = "J"
       end if
    end if

    open c_cta10m00_001 using lr_cta10m00.corsus
    whenever error continue
    fetch c_cta10m00_001 into lr_cta10m00.cornom
    whenever error stop

    open c_cta10m00_002 using lr_cta10m00.funmat,lr_cta10m00.empcod
    whenever error continue
    fetch c_cta10m00_002 into lr_cta10m00.funnom
    whenever error stop

    open c_cta10m00_003 using lr_cta10m00.empcodatd
    whenever error continue
    fetch c_cta10m00_003 into lr_cta10m00.empnomatd
    whenever error stop

    open c_cta10m00_003 using lr_cta10m00.empcod
    whenever error continue
    fetch c_cta10m00_003 into lr_cta10m00.empnom
    whenever error stop
 end if


 open window w_cta10m00 at 09,02 with form 'cta10m00'attribute(border, form line 1)


 input by name lr_cta10m00.* without defaults

    before field empcodatd
       if g_documento.atdnum is not null and
          g_documento.atdnum <> 0        then

          display by name lr_cta10m00.cornom
                         ,lr_cta10m00.funnom
                         ,lr_cta10m00.atdnum
                         ,lr_cta10m00.empnom
                         ,lr_cta10m00.empnomatd
          if l_cont2 = 0 then

             call cts08g01 ("A","N","","", "CONFIRME OS DADOS DO CLIENTE.","")
                  returning l_confirma

             let l_cont2 = l_cont2 + 1

          end if
       end if
       let lr_cta10m00.empcodatd = g_documento.ciaempcod

       open c_cta10m00_003 using lr_cta10m00.empcodatd
       fetch c_cta10m00_003 into lr_cta10m00.empnomatd

       display by name lr_cta10m00.empcodatd
       display by name lr_cta10m00.empnomatd

       next field pestip


    after field empcodatd

       display by name lr_cta10m00.empcodatd

        if lr_cta10m00.empcodatd is null then

           call cty14g00_popup_empresa()
              returning l_erro
                       ,lr_cta10m00.empcodatd
                       ,lr_cta10m00.empnomatd


           if l_erro = 3 then
              error 'Codigo de empresa nao selecionado!'
              next field empcodatd
           end if

           display by name lr_cta10m00.empnomatd

        else

            ---> Permitir somente Empresa 1 ,35 e 84 , pois o Porto Socorro nao
	    ---> esta preprado para pagar outras empresas sem documento
            if  lr_cta10m00.empcodatd <> 1        and
                lr_cta10m00.empcodatd <> 35       and
                lr_cta10m00.empcodatd <> 84       then
                  error 'Informe uma empresa valida!'
                  let lr_cta10m00.empcodatd = null
                  next field empcodatd
            else

                 open c_cta10m00_003 using lr_cta10m00.empcodatd

                 whenever error continue
                 fetch c_cta10m00_003 into lr_cta10m00.empnomatd
                 whenever error stop
                 if sqlca.sqlcode <> 0 then
                    if sqlca.sqlcode = 100 then
                       error 'Empresa nao cadastrada.' sleep 2
                       next field empcodatd
                    else
                       error 'Erro Select ccta10m00003: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
                       error 'cta10m00_entrada_dados','/',lr_cta10m00.empcodatd,'/1.' sleep 2
                       let int_flag = true
                       exit input
                    end if
                 else
                     display by name lr_cta10m00.empnomatd

                 end if
            end if
       end if

       if lr_cta10m00.empcodatd is null then
          let lr_cta10m00.empnomatd = null
          display by name lr_cta10m00.empnomatd
       end if


    before field pestip
       display by name lr_cta10m00.pestip attribute(reverse)

    after field pestip
       display by name lr_cta10m00.pestip

       if fgl_lastkey() = fgl_keyval('up') or
          fgl_lastkey() = fgl_keyval('left') then

          next field pestip
       end if

       if lr_cta10m00.pestip is not null and
          lr_cta10m00.pestip not matches '[FfJj]' then
          error 'Tipo de pessoa invalido!' sleep 2
          next field pestip
       end if

       if lr_cta10m00.pestip is null then
          if g_documento.ciaempcod = 35 or
             lr_cta10m00.empcodatd = 35 then
             next field funmat
          end if

          let lr_cta10m00.cgccpfnum = null
          let lr_cta10m00.cgcord    = null
          let lr_cta10m00.cgccpfdig = null

          display by name lr_cta10m00.cgccpfnum
          display by name lr_cta10m00.cgcord
          display by name lr_cta10m00.cgccpfdig
          next field corsus
       end if

    before field cgccpfnum
       display by name lr_cta10m00.cgccpfnum attribute(reverse)

    after field cgccpfnum
       display by name lr_cta10m00.cgccpfnum

       if fgl_lastkey() = fgl_keyval('up') or
          fgl_lastkey() = fgl_keyval('left') then
          next field pestip
       end if

       if lr_cta10m00.pestip is not null and
          lr_cta10m00.cgccpfnum is null or
          lr_cta10m00.cgccpfnum = 0 then
          error 'Numero do CGC/CPF deve ser informado.' sleep 2
          next field cgccpfnum
       end if

       if lr_cta10m00.pestip = 'F' then
          next field cgccpfdig
       end if

       let g_documento.cgccpfnum = lr_cta10m00.cgccpfnum

    before field cgcord
       display by name lr_cta10m00.cgcord attribute(reverse)

    after field cgcord
       display by name lr_cta10m00.cgcord

       if fgl_lastkey() = fgl_keyval('up') or
          fgl_lastkey() = fgl_keyval('left') then
          next field cgccpfnum
       end if

       if lr_cta10m00.cgcord is null or
          lr_cta10m00.cgcord = 0 then
          error 'Filial do CGC deve ser informada!' sleep 2
          next field cgcord
       end if

       let g_documento.cgcord = lr_cta10m00.cgcord

    before field cgccpfdig
       display by name lr_cta10m00.cgccpfdig attribute(reverse)

    after field cgccpfdig
       display by name lr_cta10m00.cgccpfdig

       if fgl_lastkey() = fgl_keyval('up') or
          fgl_lastkey() = fgl_keyval('left') then
          if lr_cta10m00.pestip = 'J' then
             next field cgcord
          else
             next field cgccpfnum
          end if
       end if

      if lr_cta10m00.cgccpfdig is null then
         error 'Digito do CGC/CPF deve ser informado. ' sleep 2
         next field cgccpfdig
      end if
       if lr_cta10m00.pestip = 'J' then
          call f_fundigit_digitocgc(lr_cta10m00.cgccpfnum, lr_cta10m00.cgcord)
                          returning l_cgccpfdig
       else
          call f_fundigit_digitocpf(lr_cta10m00.cgccpfnum)
               returning l_cgccpfdig
       end if

       if l_cgccpfdig is null or
          l_cgccpfdig <> lr_cta10m00.cgccpfdig then
          error 'Digito do CPF/CGC incorreto!' sleep 2
          next field cgccpfdig
       else
          let g_documento.cgccpfdig = lr_cta10m00.cgccpfdig
          exit input
       end if

    before field corsus
       if g_documento.ciaempcod = 35 or
          lr_cta10m00.empcodatd = 35 then
          next field funmat
       end if
       display by name lr_cta10m00.corsus attribute(reverse)

    after field corsus
       display by name lr_cta10m00.corsus

       if fgl_lastkey() = fgl_keyval('up') or
          fgl_lastkey() = fgl_keyval('left') then
          next field pestip
       end if

       if lr_cta10m00.corsus is null then
          let lr_cta10m00.cornom = null
          display by name lr_cta10m00.cornom
          next field empcod
       end if

       if lr_cta10m00.corsus = "0" then
          error 'Codigo do Corretor invalido.' sleep 2
          next field corsus
       end if

       open c_cta10m00_001 using lr_cta10m00.corsus

       whenever error continue
       fetch c_cta10m00_001 into lr_cta10m00.cornom
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = 100 then
             error 'Corretor nao tem cadastro na Porto' sleep 2
             next field corsus
          else
             error 'Erro Select ccta10m00001: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
             error 'cta10m00_entrada_dados','/',lr_cta10m00.corsus,'.' sleep 2
             let int_flag = true
          end if
          exit input
       end if

       display by name lr_cta10m00.cornom
       let g_documento.corsus = lr_cta10m00.corsus
       sleep 2
       exit input

    before field empcod
        display by name lr_cta10m00.empcod attribute(reverse)

     after field empcod
        display by name lr_cta10m00.empcod

        if fgl_lastkey() = fgl_keyval('up') or
           fgl_lastkey() = fgl_keyval('left') then
           next field corsus
        end if


         if lr_cta10m00.empcod is null then
            error "Campo nao pode ser nulo"
            next field empcod
         else
            open c_cta10m00_003 using lr_cta10m00.empcod

            whenever error continue
            fetch c_cta10m00_003 into lr_cta10m00.empnom
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode = 100 then
                  error 'Empresa nao cadastrada.' sleep 2
                  next field empcod
               else
                  error 'Erro Select ccta10m00003: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
                  error 'cta10m00_entrada_dados','/',lr_cta10m00.empcod,'/1.' sleep 2
                  let int_flag = true
                  exit input
               end if
            else
               display by name lr_cta10m00.empnom
               let g_documento.empcodmat = lr_cta10m00.empcod
               next field funmat
            end if
         end if

     ### PSI207233 fim
    before field funmat
       display by name lr_cta10m00.funmat attribute(reverse)

    after field funmat
       display by name lr_cta10m00.funmat

       if fgl_lastkey() = fgl_keyval('up') or
          fgl_lastkey() = fgl_keyval('left') then
          if g_documento.ciaempcod = 35 or
             lr_cta10m00.empcodatd = 35 then
             next field pestip
          end if
          next field empcod
       end if
       if lr_cta10m00.funmat is null then
          let lr_cta10m00.funnom = null
          let lr_cta10m00.empcod = null
          let lr_cta10m00.empnom = null
          display by name lr_cta10m00.funnom
          display by name lr_cta10m00.empcod
          display by name lr_cta10m00.empnom
          next field dddcod
       else
          open c_cta10m00_002 using lr_cta10m00.funmat,lr_cta10m00.empcod
          whenever error continue
          fetch c_cta10m00_002 into lr_cta10m00.funnom
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = 100 then
                error 'Matricula nao cadastrada.' sleep 2
                next field funmat
             else
                error 'Erro Select ccta10m00002: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
                error 'cta10m00_entrada_dados','/',lr_cta10m00.funmat,'/1.' sleep 2
                let int_flag = true
                exit input
             end if
          else
             display by name lr_cta10m00.funnom
             sleep 2
          end if
       end if
    before field dddcod
       display by name lr_cta10m00.dddcod attribute(reverse)

    after field dddcod
       display by name lr_cta10m00.dddcod

       if fgl_lastkey() = fgl_keyval('up') or
          fgl_lastkey() = fgl_keyval('left') then
          next field funmat
       end if

       if lr_cta10m00.dddcod is null then
          let lr_cta10m00.ctttel = null
          display by name lr_cta10m00.ctttel
          exit input
       else
          let lr_cta10m00.dddcod = lr_cta10m00.dddcod clipped
          if lr_cta10m00.dddcod matches '[AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvXxWwZzYy.,-/]' then
             error 'DDD invalido, informe novamente.' sleep 2
             next field dddcod
          end if
       end if

    before field ctttel
       display by name lr_cta10m00.ctttel attribute(reverse)

    after field ctttel
       display by name lr_cta10m00.ctttel

       if fgl_lastkey() = fgl_keyval('up') or
          fgl_lastkey() = fgl_keyval('left') then
          next field dddcod
       end if

       if lr_cta10m00.ctttel is null and
          lr_cta10m00.dddcod is not null then
          error 'Telefone invalido, informe novamente.' sleep 2
          next field ctttel
       else
          let l_tam = length(lr_cta10m00.ctttel)
          if l_tam < 6 then
             error 'Telefone invalido, informe novamente.' sleep 2
             next field ctttel
          end if
       end if
       sleep 2
       exit input

 on key (f17,control-c, interrupt)


       let int_flag = true
       exit input


 end input

 if lr_cta10m00.cgccpfnum is not null then
    if lr_cta10m00.cgcord is null then
       let lr_cta10m00.cgcord = 0
    end if
    if lr_cta10m00.cgccpfdig is null then
       let lr_cta10m00.cgccpfdig = 0
    end if
 end if

 if int_flag then
    let int_flag = false
    let g_documento.corsus     = null
    let g_documento.dddcod     = null
    let g_documento.ctttel     = null
    let g_documento.funmat     = null
    let g_documento.cgccpfnum  = null
    let g_documento.cgcord     = null
    let g_documento.cgccpfdig  = null
 else
    let g_documento.corsus     = lr_cta10m00.corsus
    let g_documento.dddcod     = lr_cta10m00.dddcod
    let g_documento.ctttel     = lr_cta10m00.ctttel
    let g_documento.funmat     = lr_cta10m00.funmat
    let g_documento.cgccpfnum  = lr_cta10m00.cgccpfnum
    let g_documento.cgcord     = lr_cta10m00.cgcord
    let g_documento.cgccpfdig  = lr_cta10m00.cgccpfdig
    let g_documento.ciaempcod  = lr_cta10m00.empcodatd
 end if

 close window w_cta10m00

end function

#obs.: foram colocados sleep 2 logo apos alguns displays, pois cfme pedido pelo analista
#o programa dara return logo que as informacoes digitados forem consideradas corretas, e
#para que o usuario pudesse visualizar as descricoes dos campos, se faz necessario o uso
#de sleep.
