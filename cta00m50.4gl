#############################################################################
# Nome do Modulo: cta00m50                                         Marcelo  #
#                                                                  Gilberto #
# Solicitacao de consulta (PortoCard)                              Dez/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 09/12/1998  PSI 6478-5   Gilberto     Incluir numero do item (veiculo a   #
#                                       ser atendido) na localizacao.       #
##############################################################################
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor   Fabrica     Origem     Alteracao                        #
# ---------- ----------------- ---------- -----------------------------------#
# 24/01/2005 Robson, Meta       PSI190080   Alterar  a  chamada  da  funcao  #
#                                           cta02m00() para                  #
#                                           cta02m00_solicitar_assunto().    #
#----------------------------------------------------------------------------#
globals '/homedsa/projetos/geral/globals/glct.4gl'

#---------------------------------------------------------------
 function  cta00m50()
#---------------------------------------------------------------

  define  d_cta00m50   record
     solnom            like datmligacao.c24solnom ,
     pcapticod         like eccmpti.pcapticod     ,
     nome              like eccmcli.pcaclinom     ,
     tipo              char(01)                   ,
     vcllicnum         like eccmitem.vcllicnum    ,
     pcaclicgccpf      like eccmcli.pcaclicgccpf
  end record

  define  wsnome       char(41)
  define  wscount      dec(3,0)
  define  wsresp       char(1)
  define  wsachou      char(1)

	let	wsnome  =  null
	let	wscount  =  null
	let	wsresp  =  null
	let	wsachou  =  null

	initialize  d_cta00m50.*  to  null

  open window cta00m50 at  4,2 with form "cta00m50"
                           attribute(form line 1)


# while  true

    let int_flag  =  false
    initialize  g_documento.pcacarnum       to null

    input by name d_cta00m50.*

      before field solnom
         display by name d_cta00m50.solnom  attribute(reverse)

      after field solnom
         display by name d_cta00m50.solnom

         if d_cta00m50.solnom   is null    then
            error " Nome do solicitante e' item obrigatorio!"
            next field  solnom
         else
            let g_documento.solnom = d_cta00m50.solnom
            let g_documento.soltip = "O"
            let g_documento.c24soltipcod = 3
         end if

      before field pcapticod
         display by name d_cta00m50.pcapticod    attribute (reverse)

      after field pcapticod
         display by name d_cta00m50.pcapticod

         if d_cta00m50.pcapticod   is not null   then
            select *
              from eccmpti
             where pcapticod = d_cta00m50.pcapticod

            if status = notfound   then
               error "Cartao nao cadastrado !!!"
               next field pcapticod
            end if
            let g_documento.pcacarnum = d_cta00m50.pcapticod
            exit input
         end if

      before field nome
         display by name d_cta00m50.nome   attribute (reverse)

         initialize d_cta00m50.tipo  to null
         display by name d_cta00m50.tipo

      after  field nome
         display by name d_cta00m50.nome

         if fgl_lastkey() <> fgl_keyval("up")   and
            fgl_lastkey() <> fgl_keyval("left") then
            if d_cta00m50.nome  is not null   and
               d_cta00m50.nome  <>  "  "      then
               next field tipo
            else
               next field vcllicnum
            end if
         end if

      before field tipo
         display by name d_cta00m50.tipo   attribute (reverse)

      after  field tipo
         display by name d_cta00m50.tipo

         initialize wsnome, wscount   to null
         if fgl_lastkey() <> fgl_keyval("up")   and
            fgl_lastkey() <> fgl_keyval("left") then
            if d_cta00m50.nome  is not null     and
               d_cta00m50.nome  <>  "  "        then
               if d_cta00m50.tipo  is null      then
                  error "Informe (T)itular ou (A)dicional!"
                  next field tipo
               end if
               if d_cta00m50.tipo  <> "T"       and
                  d_cta00m50.tipo  <> "A"       then
                  error "Informe (T)itular ou (A)dicional!"
                  next field tipo
               else
                  let wsnome = d_cta00m50.nome clipped, "*"
                  message " Aguarde, Pesquisando ..." attribute (reverse)
                  if d_cta00m50.tipo = "T" then
                     select count(*)  into wscount
                       from eccmcli
                      where pcaclinom matches wsnome
                  else
                     select count(*)  into wscount
                       from eccmpti
                      where pcaptinom matches wsnome
                  end if

                  if wscount = 0   then
                     error " Nenhum cartao encontrado para o Nome !!!"
                     next field nome
                  else
                     if wscount > 50  then
                       error "Mais de 50 cartoes encontrados. Complemente NOME!"
                       next field nome
                     else
                        call cta01m51 (wsnome,d_cta00m50.tipo)
                             returning g_documento.pcacarnum
                        if g_documento.pcacarnum  is null  then
                           error "Nenhum cartao selecionado !!!"
                           next field nome
                        else
                           exit input
                        end if
                     end if
                  end if
               end if
            end if
         end if

      before field vcllicnum
         display by name d_cta00m50.vcllicnum attribute (reverse)

      after field vcllicnum
         display by name d_cta00m50.vcllicnum
         if fgl_lastkey() <> fgl_keyval("up")   and
            fgl_lastkey() <> fgl_keyval("left") then
            if d_cta00m50.vcllicnum   is not null   then
               message " Aguarde, Pesquisando ..." attribute (reverse)
               call cta01m53(d_cta00m50.vcllicnum)
                    returning g_documento.pcacarnum
               if g_documento.pcacarnum is null then
                  error "Nenhum cartao foi localizado com a placa informada!"
                  next field vcllicnum
               else
                  let int_flag = false
                  exit input
               end if
            end if
         else
            next field nome
         end if

      before field pcaclicgccpf
         display by name d_cta00m50.pcaclicgccpf attribute (reverse)

      after field pcaclicgccpf
         display by name d_cta00m50.pcaclicgccpf
         if fgl_lastkey() <> fgl_keyval("up")   and
            fgl_lastkey() <> fgl_keyval("left") then
            if d_cta00m50.pcaclicgccpf   is not null   then
               call cta01m54(d_cta00m50.pcaclicgccpf)
                    returning g_documento.pcacarnum
               if g_documento.pcacarnum is null then
                  error "Nao foi encontrado nenhum cartao com o CGC informado!"
                  next field pcaclicgccpf
               else
                  exit input
               end if
            end if
         end if

      on key (interrupt)
         initialize g_documento.pcacarnum to  null
         exit input

    end input

     if int_flag    then
       #exit while
     else
        if g_documento.pcacarnum is null  then
           error " Nenhum cartao foi selecionado!"
        else
           call cta01m50()
           let g_documento.solnom = d_cta00m50.solnom
           let g_documento.soltip = "O"
           let g_documento.pcaprpitm = 1
           let g_documento.c24soltipcod = 3

           #-- Solicitar Servico --#
           call cta02m00_solicitar_assunto(g_documento.*,g_c24paxnum,'',g_ppt.*)

        end if
     end if

# end while

 let int_flag = false
 close window  cta00m50

end function  #  cta00m50
