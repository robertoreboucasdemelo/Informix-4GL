###############################################################################
#Nome do Modulo: CTN24C00                                               Pedro #
#                                                                             #
#Pesquisa prestador por Nome de Guerra, Razao social ou por Parte    Jun/1995 #
#-----------------------------------------------------------------------------#
#                         * * * A L T E R A C A O * * *                       #
# ........................................................................... #
# Data        Autor Fabrica   OSF/PSI       Alteracao                         #
# ----------  -------------  -------------  ----------------------------------#
# 27/01/2004  Sonia Sasaki   31631/177903   Inclusao F6 e execucao da funcao  #
#                                           cta11m00 (Motivos de recusa).     #
# ----------  -------------  -------------  ----------------------------------#
# 22/07/2004  Paulo, Meta    PSI186414      Criacao da nova funcao            #
#                            OSF 37940      ctn24c00_nome_prestador()         #
# 17/11/2006  Ligia Mattge   PSI 205206     ciaempcod                         #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_prep_sql          smallint                           ### PSI186414 - Paulo

# Inicio PSI186414 - Paulo
#
function ctn24c00_prepare()
 define l_sql        char(500)

 let l_sql = 'select nomgrr, nomrazsoc '
            ,'  from dpaksocor '
            ,' where pstcoddig = ? '

 prepare p_ctn24c00_001 from l_sql
 declare c_ctn24c00_001 cursor for p_ctn24c00_001

 let m_prep_sql = true

end function
#
# Final PSI186414 - Paulo

#------------------------------------------------------------------------
function ctn24c00()
#------------------------------------------------------------------------

 define d_ctn24c00    record
    nomepsq           char(31),
    tipo              char(01),
    cgccpfnum         like dpaksocorfav.cgccpfnum,
    ciaempcod         like gabkemp.empcod,
    empnom            like gabkemp.empnom
 end record

 define a_ctn24c00 array[30] of record
    nomgrr            like dpaksocor.nomgrr      ,
    pstcoddig         like dpaksocor.pstcoddig   ,
    situacao          char (10)                  ,
    endlgd            like dpaksocor.endlgd      ,
    endbrr            like dpaksocor.endbrr      ,
    endcid            like dpaksocor.endcid      ,
    endufd            like dpaksocor.endufd      ,
    endcep            like dpaksocor.endcep      ,
    endcepcmp         like dpaksocor.endcepcmp   ,
    dddcod            like dpaksocor.dddcod      ,
    teltxt            like dpaksocor.teltxt      ,
    horsegsexinc      like dpaksocor.horsegsexinc,
    horsegsexfnl      like dpaksocor.horsegsexfnl,
    horsabinc         like dpaksocor.horsabinc   ,
    horsabfnl         like dpaksocor.horsabfnl   ,
    hordominc         like dpaksocor.hordominc   ,
    hordomfnl         like dpaksocor.hordomfnl   ,
    pstobs            like dpaksocor.pstobs      ,
    tabela            char(06)
 end record

 define ws            record
    comando1          char(800)                  ,
    comando2          char(300)                  ,
    nomepsq           char(36)                   ,
    w_int               smallint                   ,
    prssitcod         like dpaksocor.prssitcod   ,
    vlrtabflg         like dpaksocor.vlrtabflg   ,
    confirma          char(1),
    seleciona         char(01)
 end record

 define arr_aux           smallint
 define aux_contpsq       smallint
 define l_srvrcumtvcod    like datmsrvacp.srvrcumtvcod
       ,l_atdsrvorg       like datmservico.atdsrvorg
       ,l_resultado       smallint
       ,l_mensagem        char(50)

	define	w_pf1	integer

	let	arr_aux  =  null
	let	aux_contpsq  =  null

	for	w_pf1  =  1  to  30
		initialize  a_ctn24c00[w_pf1].*  to  null
	end	for

	initialize  d_ctn24c00.*  to  null

	initialize  ws.*  to  null

 open window w_ctn24c00 at  06,02 with form "ctn24c00"
             attribute(form line first)

 if g_documento.atdsrvnum is not null then
    call cts10g06_dados_servicos(10, g_documento.atdsrvnum,
                                     g_documento.atdsrvano)
         returning l_resultado, l_mensagem, d_ctn24c00.ciaempcod

    call cty14g00_empresa(1, d_ctn24c00.ciaempcod)
         returning l_resultado, l_mensagem,  d_ctn24c00.empnom

    display by name d_ctn24c00.ciaempcod attribute (reverse)
    display by name d_ctn24c00.empnom attribute (reverse)

 end if

 let aux_contpsq        = 0

 while true

    initialize ws.*        to null
    initialize a_ctn24c00  to null

    let ws.w_int     = 0
    let int_flag   = false
    let arr_aux    = 1

    input by name d_ctn24c00.*  without defaults

       before field nomepsq
          display by name d_ctn24c00.nomepsq attribute (reverse)

       after  field nomepsq
          display by name d_ctn24c00.nomepsq

       before field tipo
          display by name d_ctn24c00.tipo       attribute (reverse)

       after  field tipo
          display by name d_ctn24c00.tipo

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field nomepsq
          end if

          if d_ctn24c00.nomepsq is not null   and
             d_ctn24c00.tipo    is null       then
             error "Tipo de pesquisa e' item obrigatorio G, R ou P!"
             next field tipo
          end if

          if d_ctn24c00.nomepsq is null       and
             d_ctn24c00.tipo    is not null   then
             error "Nome para pesquisa e' item obrigatorio!"
             next field tipo
          end if

          if d_ctn24c00.tipo <> "G" and
             d_ctn24c00.tipo <> "R" and
             d_ctn24c00.tipo <> "P" then
             error "Tipo de pesquisa invalido - informe G, R ou P!"
             next field tipo
          end if

          if d_ctn24c00.tipo  is not null   then
             if d_ctn24c00.tipo = "P"       and
                aux_contpsq      <  1        then
                error "Deve pesquisar por Razao ou Guerra antes!"
                next field tipo
             else
                if d_ctn24c00.tipo = "P" then
                   let ws.w_int      = (length (d_ctn24c00.nomepsq))

                   if  ws.w_int      < 4  then
                       error "Minimo de 4 letras para pesquisar!"
                       next field nomepsq
                   end if
                   let ws.nomepsq = "*", d_ctn24c00.nomepsq clipped, "*"
                else
                   let ws.nomepsq = d_ctn24c00.nomepsq clipped, "*"
                end if
             end if
          end if

       before field cgccpfnum
          display by name d_ctn24c00.cgccpfnum  attribute (reverse)

       after  field cgccpfnum
          display by name d_ctn24c00.cgccpfnum

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field tipo
          end if

          if d_ctn24c00.nomepsq   is null and
             d_ctn24c00.cgccpfnum is null then
             error "Informe NOME ou CGC para pesquisa!"
             next field nomepsq
          end if

       before field ciaempcod
                display by name d_ctn24c00.ciaempcod attribute (reverse)

       after field ciaempcod

             if d_ctn24c00.ciaempcod is null then
                call cty14g00_popup_empresa()
                     returning l_resultado, d_ctn24c00.ciaempcod,
                               d_ctn24c00.empnom

                display by name d_ctn24c00.ciaempcod attribute (reverse)
                display by name d_ctn24c00.empnom attribute (reverse)
             else

                #if d_ctn24c00.ciaempcod <> 1  and
                #   d_ctn24c00.ciaempcod <> 35 and
                #   d_ctn24c00.ciaempcod <> 40 then
                #   error "Informe a empresa: 1-Porto, 35-Azul ou 40-PortoSeg"
                #   next field ciaempcod
                #end if

                call cty14g00_empresa(1, d_ctn24c00.ciaempcod)
                     returning l_resultado, l_mensagem,  d_ctn24c00.empnom

                if l_resultado <> 1 then
                   error l_mensagem
                   next field ciaempcod
                end if
             end if

             display by name d_ctn24c00.ciaempcod attribute (reverse)
             display by name d_ctn24c00.empnom attribute (reverse)

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

    # MONTA PESQUISA
    #----------------
    if d_ctn24c00.cgccpfnum  is not null   then
       let ws.comando2 = " from dpaksocor",
                         " where ",
                         " dpaksocor.cgccpfnum = ? "
    else
       if d_ctn24c00.tipo  =  "G"   then
          let ws.comando2 = " from dpaksocor ",
                            " where ",
                            " dpaksocor.nomgrr matches '", ws.nomepsq, "' "

       else
          let ws.comando2 = " from dpaksocor ",
                            " where ",
                            " dpaksocor.nomrazsoc matches '", ws.nomepsq, "'"

       end if
    end if

    if d_ctn24c00.tipo = "G" or
       d_ctn24c00.tipo = "R" then
       let aux_contpsq  = aux_contpsq + 1
    end if

    let ws.comando1 =
     " select",
     " dpaksocor.nomgrr,",
     " dpaksocor.pstcoddig,",
     " dpaksocor.prssitcod,",
     " dpaksocor.endlgd,",
     " dpaksocor.endbrr,",
     " dpaksocor.endcid,",
     " dpaksocor.endufd,",
     " dpaksocor.endcep,",
     " dpaksocor.endcepcmp,",
     " dpaksocor.dddcod,",
     " dpaksocor.teltxt,",
     " dpaksocor.horsegsexinc,",
     " dpaksocor.horsegsexfnl,",
     " dpaksocor.horsabinc,",
     " dpaksocor.horsabfnl,",
     " dpaksocor.hordominc,",
     " dpaksocor.hordomfnl,",
     " dpaksocor.pstobs   ,",
     " dpaksocor.vlrtabflg "

   let ws.comando1 = ws.comando1 clipped," ", ws.comando2

   prepare p_ctn24c00_002 from ws.comando1
      declare c_ctn24c00_002 cursor for p_ctn24c00_002

      if d_ctn24c00.cgccpfnum  is not null   then
         open  c_ctn24c00_002 using  d_ctn24c00.cgccpfnum
      else
         open  c_ctn24c00_002
      end if

      foreach c_ctn24c00_002 into a_ctn24c00[arr_aux].nomgrr      ,
                              a_ctn24c00[arr_aux].pstcoddig   ,
                              ws.prssitcod                    ,
                              a_ctn24c00[arr_aux].endlgd      ,
                              a_ctn24c00[arr_aux].endbrr      ,
                              a_ctn24c00[arr_aux].endcid      ,
                              a_ctn24c00[arr_aux].endufd      ,
                              a_ctn24c00[arr_aux].endcep      ,
                              a_ctn24c00[arr_aux].endcepcmp   ,
                              a_ctn24c00[arr_aux].dddcod      ,
                              a_ctn24c00[arr_aux].teltxt      ,
                              a_ctn24c00[arr_aux].horsegsexinc,
                              a_ctn24c00[arr_aux].horsegsexfnl,
                              a_ctn24c00[arr_aux].horsabinc   ,
                              a_ctn24c00[arr_aux].horsabfnl   ,
                              a_ctn24c00[arr_aux].hordominc   ,
                              a_ctn24c00[arr_aux].hordomfnl   ,
                              a_ctn24c00[arr_aux].pstobs      ,
                              ws.vlrtabflg

         if d_ctn24c00.ciaempcod is not null then
            call ctd03g00_valida_emppst(d_ctn24c00.ciaempcod,
                                        a_ctn24c00[arr_aux].pstcoddig)
                 returning l_resultado, l_mensagem

            if l_resultado <> 1 then
               continue foreach
            end if
         end if

         if ws.prssitcod = "A"  then
            let a_ctn24c00[arr_aux].situacao = "ATIVO"
         else
            continue foreach
         end if

         if ws.vlrtabflg = "S"   then
            let a_ctn24c00[arr_aux].tabela = "TABELA"
         end if

         let arr_aux = arr_aux + 1
         if arr_aux  >  30    then
            error " Limite excedido, pesquisa com mais de 30 prestadores !"
            exit foreach
         end if

    end foreach

    let ws.seleciona = "n"
    if arr_aux  >  1   then
       message " (F17)Abandona, (F6)Recusa, (F8)Seleciona"
       call set_count(arr_aux-1)

       display array  a_ctn24c00 to s_ctn24c00.*
          on key(interrupt)
             for arr_aux = 1 to 2
                 clear s_ctn24c00[arr_aux].nomgrr
                 clear s_ctn24c00[arr_aux].pstcoddig
                 clear s_ctn24c00[arr_aux].situacao
                 clear s_ctn24c00[arr_aux].endlgd
                 clear s_ctn24c00[arr_aux].endbrr
                 clear s_ctn24c00[arr_aux].endcid
                 clear s_ctn24c00[arr_aux].endufd
                 clear s_ctn24c00[arr_aux].endcep
                 clear s_ctn24c00[arr_aux].endcepcmp
                 clear s_ctn24c00[arr_aux].dddcod
                 clear s_ctn24c00[arr_aux].teltxt
                 clear s_ctn24c00[arr_aux].horsegsexinc
                 clear s_ctn24c00[arr_aux].horsegsexfnl
                 clear s_ctn24c00[arr_aux].horsabinc
                 clear s_ctn24c00[arr_aux].horsabfnl
                 clear s_ctn24c00[arr_aux].hordominc
                 clear s_ctn24c00[arr_aux].hordomfnl
                 clear s_ctn24c00[arr_aux].pstobs
                 clear s_ctn24c00[arr_aux].tabela
             end for
             initialize a_ctn24c00  to null
             exit display

	  on key (F6)
	     let arr_aux = arr_curr()
	     let l_srvrcumtvcod = null

	     whenever error continue
	        select atdsrvorg into l_atdsrvorg
	          from datmservico
                 where atdsrvnum = g_documento.atdsrvnum
		   and atdsrvano = g_documento.atdsrvano
             whenever error stop

             if sqlca.sqlcode = 0 then
                call cta11m00 ( l_atdsrvorg
			       ,g_documento.atdsrvnum
			       ,g_documento.atdsrvano
			       ,a_ctn24c00[arr_aux].pstcoddig
			       ,"S" )
                     returning l_srvrcumtvcod
              else
                 if sqlca.sqlcode < 0 then
                    error "Erro ", sqlca.sqlcode using "<<<<<&",
			  " na selecao da tabela datmservico."
		 end if
	      end if

          on key (F8)
             let arr_aux = arr_curr()

             call cts08g01("A","S","PRESTADOR SELECIONADO",
                  a_ctn24c00[arr_aux].nomgrr,"ESTA CORRETO ?","")
             returning ws.confirma

             if ws.confirma = "S" then
#               let int_flag =  true
#               error "Prestador selecionado !!"
                let ws.seleciona = "s"
                exit display
             end if

       end display
    else
       error " Nao foi encontrado nenhum prestador para pesquisa!"
    end if

    if ws.seleciona = "s"   then
       exit while
    end if
 end while

 let int_flag = false
 close window  w_ctn24c00
 return a_ctn24c00[arr_aux].pstcoddig

end function  #  ctn24c00

# Inicio PSI186414 - Paulo
#
#-----------------------------------------------------------
function ctn24c00_nome_prestador(l_pstcoddig, l_tipo_nome)
#-----------------------------------------------------------
 define l_pstcoddig       like dpaksocor.pstcoddig
       ,l_tipo_nome       char(01)

 define l_nomgrr          like dpaksocor.nomgrr
       ,l_nome            like dpaksocor.nomrazsoc

 define l_resultado       smallint
       ,l_mensagem        char(80)

 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctn24c00_prepare()
 end if

 if l_pstcoddig is null or
    l_tipo_nome is null or
    l_tipo_nome = ' '   then

    let l_resultado = 2
    let l_mensagem = 'Parametros nao podem ser nulos'
    let l_nome = null
 else
    open c_ctn24c00_001 using l_pstcoddig

    whenever error continue
    fetch c_ctn24c00_001 into l_nomgrr
                           ,l_nome
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let l_resultado = 2
          let l_mensagem = 'Prestador nao encontrado'
       else
          let l_resultado = 3
          let l_mensagem = 'Erro SELECT c_ctn24c00_001 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
       end if
       let l_nome = null
    else
       let l_resultado = 1

       if l_tipo_nome = 'G' then
          let l_nome = l_nomgrr
       end if
    end if
 end if

 return l_resultado
       ,l_mensagem
       ,l_nome

end function
#
# Final PSI186414 - Paulo
