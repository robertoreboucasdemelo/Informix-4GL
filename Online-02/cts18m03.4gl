#############################################################################
# Nome do Modulo: cts18m03                                         Marcelo  #
#                                                                  Gilberto #
# Informacoes sobre o acidente                                     Ago/1997 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 21/12/1999  PSI 8852-8   Gilberto     Obter informacoes referentes a fur- #
#                                       to/roubo.                           #
#############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function cts18m03(d_cts18m03)
#-----------------------------------------------------------

 define d_cts18m03    record
    tipchv            char (01)                    ,
    sinlcldes         like ssammot.sinlcldes       ,
    sinendcid         like ssammot.sinendcid       ,
    sinlclufd         like ssammot.sinlclufd       ,
    sinntzcod         like ssamavs.sinntzcod       ,
    sinbocflg         like ssammot.sinbocflg       ,
    dgcnum            like ssammot.dgcnum          ,
    sinvcllcldes      like ssammot.sinvcllcldes    ,
    vclatulgd         like ssammot.vclatulgd       ,
    sinmotcplflg      like ssammot.sinmotcplflg    ,
    sinrclcpdflg      char (01)                    ,
    avsrbfsegvitflg   char (01)                    ,
    segrbfantsim      char (01)                    ,
    segrbfantnao      char (01)                    ,
    segrbfantnaosabe  char (01)                    ,
    segqtdum          char (01)                    ,
    segqtddois        char (01)                    ,
    segqtdtres        char (01)                    ,
    segqtdmaistres    char (01)                    ,
    segqtdnaosabe     char (01)                    ,
    vitrbfantsim      char (01)                    ,
    vitrbfantnao      char (01)                    ,
    vitrbfantnaosabe  char (01)                    ,
    vitqtdum          char (01)                    ,
    vitqtddois        char (01)                    ,
    vitqtdtres        char (01)                    ,
    vitqtdmaistres    char (01)                    ,
    vitqtdnaosabe     char (01)
 end record

 define ws            record
    filler            char (01),
    sinntzdes         like sgaknatur.sinntzdes,
    confirma          char (01)
 end record




	initialize  ws.*  to  null

 open window w_cts18m03 at 12,02 with form "cts18m03"
                        attribute(form line 1, comment line last - 1)

 message " (F17)Abandona"

 if d_cts18m03.tipchv = "I"  then
    if g_documento.c24astcod = "N10" then
       call cts08g01("Q", "N", "", "INFORMACOES REFERENTES", "AO ACIDENTE", "")
            returning ws.confirma
    else
       if g_documento.c24astcod = "N11" then
          call cts08g01("U", "N", "","INFORMACOES REFERENTES","AO ACIDENTE", "")
               returning ws.confirma
       end if
    end if
 else
    select sinntzdes into ws.sinntzdes
      from sgaknatur
     where sinramgrp = 1
       and sinntzcod = d_cts18m03.sinntzcod

    display by name ws.sinntzdes
 end if

 input by name d_cts18m03.sinlcldes     ,
               d_cts18m03.sinendcid     ,
               d_cts18m03.sinlclufd     ,
               d_cts18m03.sinntzcod     ,
               d_cts18m03.sinbocflg     ,
               d_cts18m03.dgcnum        ,
               d_cts18m03.sinvcllcldes  ,
               d_cts18m03.vclatulgd     ,
               d_cts18m03.sinmotcplflg  ,
               d_cts18m03.sinrclcpdflg  ,
               ws.filler                   without defaults

   before field sinlcldes
      if d_cts18m03.tipchv = "M"  then
         if d_cts18m03.sinlcldes is not null  then
            if fgl_lastkey() = fgl_keyval("up")    or
               fgl_lastkey() = fgl_keyval("left")  then
               next field filler
            else
               next field sinendcid
            end if
#           let fgl_lastkey() = fgl_keyval("down")
#           next field cgccpfnum
         else
            display by name d_cts18m03.sinlcldes  attribute (reverse)
         end if
      else
         display by name d_cts18m03.sinlcldes  attribute (reverse)
      end if

   after  field sinlcldes
      display by name d_cts18m03.sinlcldes

      if d_cts18m03.sinlcldes is null  then
         error " Local onde ocorreu o acidente deve ser informado!"
         next field sinlcldes
      end if

   before field sinendcid
      if d_cts18m03.tipchv = "M"           and
         d_cts18m03.sinendcid is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field sinlcldes
         else
            next field sinlclufd
         end if
      end if

      display by name d_cts18m03.sinendcid  attribute (reverse)

   after  field sinendcid
      display by name d_cts18m03.sinendcid

      if d_cts18m03.sinendcid is null  then
         error " Cidade onde ocorreu o acidente deve ser informada!"
         next field sinendcid
      end if

   before field sinlclufd
      if d_cts18m03.tipchv = "M"           and
         d_cts18m03.sinlclufd is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field sinendcid
         else
            next field sinntzcod
         end if
      end if

      display by name d_cts18m03.sinlclufd  attribute (reverse)

   after  field sinlclufd
      display by name d_cts18m03.sinlclufd

      if d_cts18m03.sinlclufd is null  then
         error " U.F. onde ocorreu o acidente deve ser informada!"
         next field sinlclufd
      else
         select ufdcod from glakest
          where ufdcod = d_cts18m03.sinlclufd

         if sqlca.sqlcode = notfound  then
            error " Unidade federativa nao cadastrada!"
            next field sinlclufd
         end if
      end if

   before field sinntzcod
      if d_cts18m03.tipchv = "M"           and
         d_cts18m03.sinntzcod is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field sinendcid
         else
            next field sinbocflg
         end if
      end if

      display by name d_cts18m03.sinntzcod  attribute (reverse)

   after  field sinntzcod
      display by name d_cts18m03.sinntzcod

      if d_cts18m03.sinntzcod is null   then
         error " Natureza do acidente deve ser informada!"
         call fnatureza()  returning d_cts18m03.sinntzcod, ws.sinntzdes
         next field sinntzcod
      else
         select sinntzdes into ws.sinntzdes
           from sgaknatur
          where sinramgrp = 1
            and sinntzcod = d_cts18m03.sinntzcod

         if sqlca.sqlcode = notfound  then
            error " Codigo de natureza nao cadastrada!"
            next field sinntzcod
         end if

         if d_cts18m03.tipchv = "I"  then
#           if d_cts18m03.sinntzcod = 30  or
#              d_cts18m03.sinntzcod = 36  or
#              d_cts18m03.sinntzcod = 64  or
#              d_cts18m03.sinntzcod = 68  then
#              call fiavsrbf() returning d_cts18m03.avsrbfsegvitflg ,
#                                        d_cts18m03.segrbfantsim    ,
#                                        d_cts18m03.segrbfantnao    ,
#                                        d_cts18m03.segrbfantnaosabe,
#                                        d_cts18m03.segqtdum        ,
#                                        d_cts18m03.segqtddois      ,
#                                        d_cts18m03.segqtdtres      ,
#                                        d_cts18m03.segqtdmaistres  ,
#                                        d_cts18m03.segqtdnaosabe   ,
#                                        d_cts18m03.vitrbfantsim    ,
#                                        d_cts18m03.vitrbfantnao    ,
#                                        d_cts18m03.vitrbfantnaosabe,
#                                        d_cts18m03.vitqtdum        ,
#                                        d_cts18m03.vitqtddois      ,
#                                        d_cts18m03.vitqtdtres      ,
#                                        d_cts18m03.vitqtdmaistres  ,
#                                        d_cts18m03.vitqtdnaosabe
#           end if
         end if
      end if

      display by name ws.sinntzdes

   before field sinbocflg
      if d_cts18m03.tipchv = "M"           and
         d_cts18m03.sinbocflg is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field sinntzcod
         else
            if d_cts18m03.sinbocflg = "S"  then
               next field dgcnum
            else
               next field sinvcllcldes
            end if
         end if
      end if

      display by name d_cts18m03.sinbocflg  attribute (reverse)

   after  field sinbocflg
      display by name d_cts18m03.sinbocflg

      if d_cts18m03.sinbocflg is null  then
         error " Informacao sobre B.O. deve ser informada!"
         next field sinbocflg
      else
         if d_cts18m03.sinbocflg <> "S"  and
            d_cts18m03.sinbocflg <> "N"  then
            error " Houve B.O.? Informe apenas (S)im ou (N)ao!"
            next field sinbocflg
         end if
      end if

      if fgl_lastkey() = fgl_keyval("up")    and
         fgl_lastkey() = fgl_keyval("left")  then
         next field sinntzcod
      else
         if d_cts18m03.sinbocflg = "N"  then
            next field sinvcllcldes
         end if
      end if

   before field dgcnum
      if d_cts18m03.tipchv = "M"        and
         d_cts18m03.dgcnum is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field sinlclufd
         else
            next field sinvcllcldes
         end if
      end if

      display by name d_cts18m03.dgcnum  attribute (reverse)

   after  field dgcnum
      display by name d_cts18m03.dgcnum

   before field sinvcllcldes
      if d_cts18m03.tipchv = "M"              and
         d_cts18m03.sinvcllcldes is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field sinbocflg
         else
            next field vclatulgd
         end if
      end if

      display by name d_cts18m03.sinvcllcldes  attribute (reverse)

   after  field sinvcllcldes
      display by name d_cts18m03.sinvcllcldes

      if fgl_lastkey() = fgl_keyval("up")    and
         fgl_lastkey() = fgl_keyval("left")  then
         if d_cts18m03.sinbocflg = "N"  then
            next field sinbocflg
         else
            next field dgcnum
         end if
      end if

   before field vclatulgd
      if d_cts18m03.tipchv = "M"           and
         d_cts18m03.vclatulgd is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field sinvcllcldes
         else
            next field sinmotcplflg
         end if
      end if

      display by name d_cts18m03.vclatulgd  attribute (reverse)

   after  field vclatulgd
      display by name d_cts18m03.vclatulgd

   before field sinmotcplflg
      if d_cts18m03.tipchv = "M"              and
         d_cts18m03.sinmotcplflg is not null  then
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field vclatulgd
         else
            next field filler
         end if
      end if

      display by name d_cts18m03.sinmotcplflg  attribute (reverse)

   after  field sinmotcplflg
      display by name d_cts18m03.sinmotcplflg

      if d_cts18m03.sinmotcplflg is null  then
         error " Culpado pelo acidente deve ser informado!"
         next field sinmotcplflg
      else
         case d_cts18m03.sinmotcplflg
            when "S"  display "SEGURADO"   to sinmotcpl
            when "T"  display "TERCEIRO"   to sinmotcpl
            when "I"  display "INDEFINIDO" to sinmotcpl
                      next field filler
            otherwise error " Culpado deve ser: (S)egurado, (T)erceiro ou (I)ndefinido!"
                      next field sinmotcplflg
         end case
      end if

   before field sinrclcpdflg
      display by name d_cts18m03.sinrclcpdflg  attribute (reverse)

   after  field sinrclcpdflg
      display by name d_cts18m03.sinrclcpdflg

      if d_cts18m03.sinrclcpdflg is null  then
         error " Informacao sobre a culpa deve ser informada!"
         next field sinrclcpdflg
      else
         if d_cts18m03.sinrclcpdflg <> "S"  and
            d_cts18m03.sinrclcpdflg <> "N"  then
            error " Culpado assumiu ? Informe apenas (S)im ou (N)ao!"
            next field sinrclcpdflg
         end if
      end if

   before field filler
      if d_cts18m03.tipchv = "I"  then
         exit input
      else
         error " Pressione ENTER para continuar... "
      end if

   after  field filler
      if fgl_lastkey() = fgl_keyval("return")  then
         exit input
      else
         next field filler
      end if

   on key (interrupt)
      exit input

 end input

 close window w_cts18m03

 return d_cts18m03.sinlcldes thru d_cts18m03.vitqtdnaosabe

end function  ###  cts18m03
