#############################################################################
# Nome do Modulo: CTS15M02                                         Pedro    #
#                                                                  Marcelo  #
# Criterios para locacao de veiculo                                Ago/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 11/11/1998  PSI 7055-6   Gilberto     Permitir atendimento para clausula  #
#                                       80 (Carro Extra Taxi).              #
#---------------------------------------------------------------------------#
# 05/04/1999  PSI 5591-3   Gilberto     Padronizacao na digitacao da cida-  #
#                                       de e UF atraves do guia postal.     #
#---------------------------------------------------------------------------#
# 20/07/1999  PSI 8644-4   Wagner       Incluir no retorno do campo cartao  #
#                                       de credito para comparar c/Ch.Caucao#
#---------------------------------------------------------------------------#
# 14/12/2006  psi 205206   Ruiz         Incluir limite de cartão credito    #
#                                       para Azul Seguros.                  #
#############################################################################

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------
 function cts15m02(param)
#--------------------------------------------------------------

 define param         record
    clscod            like abbmclaus.clscod
 end record

 define d_cts15m02    record
    maior21           char (01)          ,
    habilit           char (01)          ,
    cartao            char (01)          ,
    condutaxi         char (01)          ,
    cidnom            like datmlcl.cidnom,
    ufdcod            like datmlcl.ufdcod
 end record

 define ws            record
    ok                char (02),
    confirma          char (01),
    cidcod            like glakcid.cidcod
 end record



	initialize  d_cts15m02.*  to  null

	initialize  ws.*  to  null

 initialize d_cts15m02.*  to null
 initialize ws.*          to null

 let int_flag  =  false

 #----------------------------------------------------------------
 # CRITICA HORARIO DE FUNCIONAMENTO CENTRAL DE RESERVAS (AVIS)
 #----------------------------------------------------------------
 #let ws.diasem = weekday(today)
 #if ws.diasem = 6   then
 #   if time < "07:00:00"   or
 #      time > "13:00:00"   then
 #      error "Horario Seg a Sex das 07:00 as 20:00 e Sab das 07:00 as 13:00"
 #      goto fim
 #   end if
 #else
 #  if ws.diasem = 0   then
 #     error "Horario Seg a Sex das 07:00 as 20:00 e Sab das 07:00 as 13:00"
 #     goto fim
 #  else
 #    if time < "07:00:00"   or
 #       time > "20:00:00"   then
 #       error "Horario Seg a Sex das 07:00 as 20:00 e Sab das 07:00 as 13:00"
 #       goto fim
 #    end if
 #  end if
 #end if

 open window cts15m02 at 07,14 with form "cts15m02"
                         attribute (form line 1, border)

 if param.clscod[1,2] = "80"  then
    display "Usuario possui CONDUTAXI ?" to qsttxt
 end if

 input by name d_cts15m02.maior21    ,
               d_cts15m02.habilit    ,
               d_cts15m02.condutaxi  ,
               d_cts15m02.cidnom     ,
               d_cts15m02.ufdcod
       without defaults

   before field maior21
          display by name d_cts15m02.maior21    attribute (reverse)

   after  field maior21
          display by name d_cts15m02.maior21

          if ((d_cts15m02.maior21  is null)    or
              (d_cts15m02.maior21  <> "S"     and
               d_cts15m02.maior21  <> "N"))   then
             error " Idade maior que 21 anos deve ser (S)im ou (N)ao!"
             next field maior21
          else
             if d_cts15m02.maior21 = "N"   then
                error " Para locacao, usuario deve ser maior de 21 anos!"
                next field maior21
             end if
          end if

   before field habilit
          display by name d_cts15m02.habilit    attribute (reverse)

   after  field habilit
          display by name d_cts15m02.habilit

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field maior21
          end if

          if ((d_cts15m02.habilit  is null)    or
              (d_cts15m02.habilit  <> "S"     and
               d_cts15m02.habilit  <> "N"))   then
             error " Habilitacao minima de 2 anos deve ser (S)im ou (N)ao!"
             next field habilit
          else
             if d_cts15m02.habilit = "N"   then
                error " Para locacao, usuario deve ter habilitacao minima de 2 anos!"
                next field habilit
             end if
          end if
   before field condutaxi
          if param.clscod[1,2] = "80"  then
             display by name d_cts15m02.condutaxi attribute (reverse)
          else
             if fgl_lastkey() = fgl_keyval("up")     or
                fgl_lastkey() = fgl_keyval("left")   then
                next field habilit
             else
                let d_cts15m02.condutaxi = "S"
                next field cidnom
             end if
          end if

   after  field condutaxi
          display by name d_cts15m02.condutaxi

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field habilit
          end if

          if ((d_cts15m02.condutaxi is null)    or
              (d_cts15m02.condutaxi <> "S"     and
               d_cts15m02.condutaxi <> "N"))   then
             error " Usuario possui CONDUTAXI deve ser (S)im ou (N)ao!"
             next field condutaxi
          else
             if d_cts15m02.condutaxi= "N"   then
                error " Para locacao, usuario deve possuir CONDUTAXI!"
                next field condutaxi
             end if
          end if

   before field cidnom
          display by name d_cts15m02.cidnom attribute (reverse)

   after  field cidnom
          display by name d_cts15m02.cidnom

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts15m02.cidnom is null then
                error " Cidade deve ser informada!"
                next field cidnom
             end if
          end if
          if d_cts15m02.cidnom = "SP" then
            let d_cts15m02.cidnom = "SAO PAULO"
            display by name d_cts15m02.cidnom
          end if
          if d_cts15m02.cidnom = "RJ" then
            let d_cts15m02.cidnom = "RIO DE JANEIRO"
            display by name d_cts15m02.cidnom
          end if

   before field ufdcod
          display by name d_cts15m02.ufdcod attribute (reverse)

   after  field ufdcod
          display by name d_cts15m02.ufdcod

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then

             if d_cts15m02.ufdcod is null  then
                error " Sigla da unidade da federacao deve ser informada!"
                next field ufdcod
             end if

             #--------------------------------------------------------------
             # Verifica se UF esta cadastrada
             #--------------------------------------------------------------
             select ufdcod
               from glakest
              where ufdcod = d_cts15m02.ufdcod

             if sqlca.sqlcode = notfound then
                error " Unidade federativa nao cadastrada!"
                next field ufdcod
             end if

             #--------------------------------------------------------------
             # Verifica se a cidade esta cadastrada
             #--------------------------------------------------------------
             declare c_glakcid cursor for
                select cidcod
                  from glakcid
                 where cidnom = d_cts15m02.cidnom
                   and ufdcod = d_cts15m02.ufdcod

             open  c_glakcid
             fetch c_glakcid  into  ws.cidcod

             if sqlca.sqlcode  =  100   then
                call cts06g04(d_cts15m02.cidnom, d_cts15m02.ufdcod)
                     returning ws.cidcod, d_cts15m02.cidnom, d_cts15m02.ufdcod

                if d_cts15m02.cidnom  is null   then
                   error " Cidade deve ser informada!"
                end if
                next field cidnom
             end if

             close c_glakcid
          end if

   on key (interrupt)
      exit input

 end input

 if not int_flag     then
    if d_cts15m02.maior21   = "S"    and
       d_cts15m02.habilit   = "S"    and
       d_cts15m02.condutaxi = "S"    then
       let ws.ok = "ok"
    end if
 end if

close window cts15m02

 label fim :
#-----------
 let int_flag = false
 return ws.ok, d_cts15m02.cidnom, d_cts15m02.ufdcod

end function  ###  cts15m02
