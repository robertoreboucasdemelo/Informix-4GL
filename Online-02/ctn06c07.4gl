#############################################################################
# Nome do Modulo: CTN06C07                                         Marcelo  #
#                                                                  Gilberto #
# Consulta oficina por nome de guerra, razao social ou telefone    Dez/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 01/10/1998               Gilberto     Fazer "leitura suja" da tabela de   #
#                                       oficinas para evitar queda da tela  #
#                                       por causa de registros locados.     #
#---------------------------------------------------------------------------#
# 11/08/1999  Pdm #29784   Gilberto     Eliminar eventuais aspas que possam #
#                                       ser digitadas na pesquisa por nome. #
#---------------------------------------------------------------------------#
# 07/08/2000  Correio      Ruiz         Mostrar as oficinas que a sucursal  #
#                                       pode marcar vistoria.               #
#---------------------------------------------------------------------------#
# 02/05/2001  Correio      Ruiz         Mudar o status da oficina qdo       #
#                                       estiver Inativa.                    #
#---------------------------------------------------------------------------#
# 23/05/2001  Psi 130818   Ruiz         Nao mostrar oficinas com ofnstt="S".#
#############################################################################

database porto

#------------------------------------------------------------------------
 function ctn06c07(param)
#------------------------------------------------------------------------

 define param         record
    psqnom            char (35),
    ofndddcod         char (04),
    ofntelnum         dec (10,0)
 end record

 define d_ctn06c07    record
    psqnom            char (31),   # Nome para pesquisa
    psqtip            char (01),   # Tipo Pesquisa: (G)uerra, (R)azao, (P)arcial
    ofndddcod         char (04),   # Codigo do DDD
    ofntelnum         dec (10,0)    # Telefone para pesquisa
 end record

 define a_ctn06c07 array[40] of record
    nomrazsoc         like gkpkpos.nomrazsoc,
    nomgrr            like gkpkpos.nomgrr,
    dddcod            like gkpkpos.dddcod,
    telnum            like gkpkpos.telnum1,
    sitdes            char (05),
    endlgd            like gkpkpos.endlgd,
    endbrr            like gkpkpos.endbrr,
    endcid            like gkpkpos.endcid,
    pstcoddig         like gkpkpos.pstcoddig
 end record

 define ws            record
    sql               char (900),
    ofnstt            like sgokofi.ofnstt,
    endufd            like gkpkpos.endufd,
    ofntelnum         like gkpkpos.telnum1,
    fvistsuc          char (01),
    psqnom            char (36)   # Nome para pesquisa parcial
 end record

 define flg_sel       smallint
 define flg_psq       smallint
 define arr_aux       smallint
 define scr_aux       smallint


	define	w_pf1	integer

	let	flg_sel  =  null
	let	flg_psq  =  null
	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  40
		initialize  a_ctn06c07[w_pf1].*  to  null
	end	for

	initialize  d_ctn06c07.*  to  null

	initialize  ws.*  to  null

 open window w_ctn06c07 at 05,02 with form "ctn06c07"
             attribute(form line first)

 let d_ctn06c07.psqnom     =  param.psqnom
 let d_ctn06c07.ofndddcod  =  param.ofndddcod
 let d_ctn06c07.ofntelnum  =  param.ofntelnum
 let flg_psq  =  0

 set isolation to dirty read

 while true

    initialize ws.*        to null
    initialize a_ctn06c07  to null

    let int_flag   = false
    let arr_aux    = 1

    input by name d_ctn06c07.*  without defaults

       before field psqnom
          display by name d_ctn06c07.psqnom  attribute (reverse)

       after  field psqnom
          display by name d_ctn06c07.psqnom

          if d_ctn06c07.psqnom is null  then
             next field ofndddcod
          end if

          call ctn06c07_semaspas(d_ctn06c07.psqnom) returning d_ctn06c07.psqnom

       before field psqtip
          display by name d_ctn06c07.psqtip  attribute (reverse)

       after  field psqtip
          display by name d_ctn06c07.psqtip

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field psqnom
          end if

          if d_ctn06c07.psqnom is not null  and
             d_ctn06c07.psqtip is     null  then
             error " Tipo de pesquisa deve ser informado!"
             next field psqtip
          end if

          if d_ctn06c07.psqnom is     null  and
             d_ctn06c07.psqtip is not null  then
             error " Nome para pesquisa deve ser informado!"
             next field psqtip
          end if

          if d_ctn06c07.psqtip is not null then
             if d_ctn06c07.psqtip <> "G"  and
                d_ctn06c07.psqtip <> "R"  and
                d_ctn06c07.psqtip <> "P"  then
                error " Tipo de pesquisa deve ser (G)uerra, (R)azao Social ou (P)arcial !"
                next field psqtip
             end if

             if d_ctn06c07.psqtip = "P"  and
                flg_psq           <  1   then
                error " Deve-se pesquisar primeiro por Razao Social ou Nome de Guerra!"
                next field psqtip
             else
                if d_ctn06c07.psqtip = "P"  then
                   if length(d_ctn06c07.psqnom) < 4  then
                      error " Minimo de 4 letras para pesquisa!"
                      next field psqnom
                   end if
                   let ws.psqnom = "*", d_ctn06c07.psqnom clipped, "*"
                else
                   let ws.psqnom = d_ctn06c07.psqnom clipped, "*"
                end if
             end if
             exit input
          end if

       before field ofndddcod
          display by name d_ctn06c07.ofndddcod     attribute (reverse)

       after  field ofndddcod
          display by name d_ctn06c07.ofndddcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field psqnom
          end if

       before field ofntelnum
          display by name d_ctn06c07.ofntelnum     attribute (reverse)

       after  field ofntelnum
          display by name d_ctn06c07.ofntelnum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field ofndddcod
          end if

          if d_ctn06c07.psqnom    is null  and
             d_ctn06c07.ofntelnum is null  then
             error "Informe NOME ou TELEFONE para pesquisa!"
             next field psqnom
          end if

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

#------------------------------------------------------------------------
# Converte telefone numerico para string, alinhando a esquerda
#------------------------------------------------------------------------

    let ws.ofntelnum = d_ctn06c07.ofntelnum using "<<<<<<<<<"

#------------------------------------------------------------------------
# Pesquisa oficinas por telefone
#------------------------------------------------------------------------

    let ws.sql = "select nomrazsoc, nomgrr, dddcod, telnum1,",
                 "       endlgd   , endbrr, endcid, endufd ,",
                 "       ofnstt   , pstcoddig"

    if d_ctn06c07.ofntelnum is not null  then
       let ws.sql = ws.sql clipped,
                    "  from gkpkpos, outer sgokofi               ",
                    " where gkpkpos.telnum1   = '", ws.ofntelnum ,"'"   ,
                    "   and sgokofi.ofnnumdig = gkpkpos.pstcoddig",
                    " union ", ws.sql clipped,
                    "  from gkpkpos, outer sgokofi               ",
                    " where gkpkpos.telnum2   = '", ws.ofntelnum ,"'"  ,
                    "   and sgokofi.ofnnumdig = gkpkpos.pstcoddig"
    else

#------------------------------------------------------------------------
# Pesquisa oficinas por nome de guerra
#------------------------------------------------------------------------

       if d_ctn06c07.psqtip  =  "G"   then
          let ws.sql = ws.sql clipped,
                       "  from gkpkpos, outer sgokofi              ",
                       " where gkpkpos.nomgrr matches ", ascii 34,
                       d_ctn06c07.psqnom clipped, ascii 34,
                       " and sgokofi.ofnnumdig = gkpkpos.pstcoddig"
       else

#------------------------------------------------------------------------
# Pesquisa oficinas por razao social
#------------------------------------------------------------------------

           let ws.sql = ws.sql clipped,
                        "  from gkpkpos, outer sgokofi     ",
                        " where gkpkpos.nomrazsoc matches ", ascii 34,
                        ws.psqnom clipped, ascii 34,
                        "  and sgokofi.ofnnumdig = gkpkpos.pstcoddig"
       end if
    end if


    prepare  p_ctn06c07_001  from ws.sql
    declare  c_ctn06c07_001  cursor for p_ctn06c07_001

    message " Aguarde, pesquisando..."  attribute (reverse)

    foreach  c_ctn06c07_001 into  a_ctn06c07[arr_aux].nomrazsoc,
                              a_ctn06c07[arr_aux].nomgrr   ,
                              a_ctn06c07[arr_aux].dddcod   ,
                              a_ctn06c07[arr_aux].telnum   ,
                              a_ctn06c07[arr_aux].endlgd   ,
                              a_ctn06c07[arr_aux].endbrr   ,
                              a_ctn06c07[arr_aux].endcid   ,
                              ws.endufd, ws.ofnstt         ,
                              a_ctn06c07[arr_aux].pstcoddig

       call fvistsuc(a_ctn06c07[arr_aux].pstcoddig,"","") returning ws.fvistsuc
       if ws.fvistsuc <> "S"  then  #pesquisa se a sucursal da regiao
          continue foreach          #pode gerar marcao de vistoria.
       end if

       if ws.ofnstt   =  "S"  then   # oficina substituida 23/05/2001
          continue foreach
       end if
       let a_ctn06c07[arr_aux].endcid =
           a_ctn06c07[arr_aux].endcid clipped, " - ", ws.endufd

       if ws.ofnstt = "A"  then
          let a_ctn06c07[arr_aux].sitdes = "ATIVA"
       else
          if ws.ofnstt = "I"  then
             let a_ctn06c07[arr_aux].sitdes = "INAT."
          else
             let a_ctn06c07[arr_aux].sitdes = "CANC."
          end if
       end if

       let arr_aux = arr_aux + 1
       if arr_aux > 40   then
          error " Limite excedido. Foram encontradas mais de 40 oficinas!"
          exit foreach
       end if
    end foreach

    message ""

    if d_ctn06c07.psqtip = "G"  or
       d_ctn06c07.psqtip = "R"  then
       let flg_psq  =  flg_psq + 1
    end if

    if arr_aux  >  1   then
       let flg_sel = false
       message " (F17)Abandona, (F8)Seleciona"
       call set_count(arr_aux-1)

       display array  a_ctn06c07 to s_ctn06c07.*
          on key (interrupt)
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             error " Oficina selecionada! "
             let flg_sel = true
             exit display
       end display

       for scr_aux = 1 to 4
          clear s_ctn06c07[scr_aux].*
       end for
    else
       error "Nao foi encontrada nenhuma oficina!"
    end if

    if flg_sel = true  then
       exit while
    end if

 end while

 let int_flag = false
 close window w_ctn06c07

 set isolation to committed read

 if d_ctn06c07.psqnom is null  then
    return a_ctn06c07[arr_aux].pstcoddig,
           a_ctn06c07[arr_aux].nomrazsoc,
           a_ctn06c07[arr_aux].dddcod   ,
           a_ctn06c07[arr_aux].telnum
 else
    return a_ctn06c07[arr_aux].pstcoddig,
           d_ctn06c07.psqnom            ,
           a_ctn06c07[arr_aux].dddcod   ,
           a_ctn06c07[arr_aux].telnum
 end if

end function  ###  ctn06c07

#------------------------------------------------------------------------
 function ctn06c07_semaspas(param)
#------------------------------------------------------------------------

 define param         record
    psqnom            char (35)
 end record

 define ws            record
    txtnom            char (35),
    antchr            char (01)
 end record

 define i             smallint


	let	i  =  null

	initialize  ws.*  to  null

 let ws.antchr = ""

 for i = 1 to length(param.psqnom clipped)
    if param.psqnom[i,i] = ascii 34  then
    else
       if ws.antchr = ascii 32  then
          let ws.txtnom = ws.txtnom clipped, ascii 32, param.psqnom[i,i]
       else
          let ws.txtnom = ws.txtnom clipped, param.psqnom[i,i]
       end if

       let ws.antchr = param.psqnom[i,i]
    end if
 end for

 return ws.txtnom

end function  ###  ctn06c07_semaspas
