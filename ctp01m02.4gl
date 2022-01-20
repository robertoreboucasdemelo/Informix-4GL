###############################################################################
# Nome do Modulo: CTP01M02                                           Marcelo  #
#                                                                    Gilberto #
# Avaliacao do servico prestado                                      Jan/1996 #
###############################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define d_ctp01m02   record
   psqcod           like datmpesquisa.psqcod,
   psqdes           char(40)
end record

define a_ctp01m02 array[04] of record
   avlitmcod        like datrpesqaval.avlitmcod ,
   avlitmdes        char(20)                    ,
   avlpsqnot        like datrpesqaval.avlpsqnot ,
   histflg          char(01)
end record

define arr_aux      smallint
define scr_aux      smallint

#-----------------------------------------------------------------------------
 function ctp01m02(param)
#-----------------------------------------------------------------------------

define param        record
   atdsrvnum        like datmservico.atdsrvnum ,
   atdsrvano        like datmservico.atdsrvano ,
   atddat           like datmservico.atddat    ,
   data             char(10)                   ,
   hora             char(05)
end record

define ws           record
   operacao         char(01)                 ,
   cttqtd           like datmpesquisa.cttqtd ,
   histreg          char(01)
end record

open window w_ctp01m02 at 15,26 with form "ctp01m02"
     attribute(form line first, border)

initialize a_ctp01m02    to null
initialize d_ctp01m02.*  to null
initialize ws.*          to null

#---------- Monta informacoes na TELA ----------#

select psqcod, cttqtd
  into d_ctp01m02.psqcod, ws.cttqtd
  from datmpesquisa
 where atdsrvnum = param.atdsrvnum    and
       atdsrvano = param.atdsrvano

if sqlca.sqlcode < 0 then
   error "Erro (", sqlca.sqlcode, ") na localizacao da pesquisa. " ,
         "AVISE A INFORMATICA!"
   return
end if
if sqlca.sqlcode = notfound   then
   let d_ctp01m02.psqcod = "P00"
else
   if d_ctp01m02.psqcod = "M10"   then
      call monta_ctp01m02(param.atdsrvnum, param.atdsrvano)
   end if
end if

case d_ctp01m02.psqcod
   when "P10"
       let d_ctp01m02.psqdes = "RECADO"
   when "P20"
       let d_ctp01m02.psqdes = "NAO ATENDE"
   when "P30"
       let d_ctp01m02.psqdes = "OCUPADO"
   when "P40"
       let d_ctp01m02.psqdes = "OUTROS"
   when "M10"
       let d_ctp01m02.psqdes = "PESQUISA REALIZADA"
   when "P00"
       let d_ctp01m02.psqdes = "PESQUISA NAO REALIZADA"
   otherwise
       error "Codigo de pesquisa nao previsto!"
       close window w_ctp01m02
       return
end case
display by name d_ctp01m02.psqdes

input by name d_ctp01m02.*   without defaults

   before field psqcod
      display by name d_ctp01m02.psqcod  attribute (reverse)

    after  field psqcod
      display by name d_ctp01m02.psqcod

      case d_ctp01m02.psqcod
         when "P00"
               let d_ctp01m02.psqdes = "PESQUISA NAO REALIZADA"
         when "P10"
               let d_ctp01m02.psqdes = "RECADO"
         when "P20"
               let d_ctp01m02.psqdes = "NAO ATENDE"
         when "P30"
               let d_ctp01m02.psqdes = "OCUPADO"
         when "P40"
               let d_ctp01m02.psqdes = "OUTROS"
         when "M10"
               let d_ctp01m02.psqdes = "PESQUISA REALIZADA"
         otherwise
               error "Codigo deve ser: P10, P20, P30, P40, M10"
               next field psqcod
      end case
      display by name d_ctp01m02.psqdes

      #------------- Grava CONTATO --------------#

      if d_ctp01m02.psqcod  <>  "P00"   then
         if ws.cttqtd  is null   then
            let ws.cttqtd = 1
            begin work
            insert into datmpesquisa ( atdsrvnum         ,
                                       atdsrvano         ,
                                       cttdat            ,
                                       ctthor            ,
                                       funmat            ,
                                       psqcod            ,
                                       cttqtd            ,
                                       caddat            )
                        values       ( param.atdsrvnum     ,
                                       param.atdsrvano     ,
                                       param.data          ,
                                       param.hora          ,
                                       g_issk.funmat     ,
                                       d_ctp01m02.psqcod ,
                                       ws.cttqtd         ,
                                       param.atddat        )

             if sqlca.sqlcode <> 0  then
                error "Erro (",sqlca.sqlcode,") durante a inclusao do contato.",
                      " AVISE A INFORMATICA!"
                rollback work
             end if
             commit work
         else
            let ws.cttqtd = ws.cttqtd + 1

            begin work
            update datmpesquisa set   cttdat = param.data          ,
                                      ctthor = param.hora          ,
                                      funmat = g_issk.funmat     ,
                                      psqcod = d_ctp01m02.psqcod ,
                                      cttqtd = ws.cttqtd
                   where  atdsrvnum = param.atdsrvnum    and
                          atdsrvano = param.atdsrvano

             if sqlca.sqlcode <> 0  then
                error "Erro (",sqlca.sqlcode,") durante a alteracao do contato."                     ," AVISE A INFORMATICA!"
                rollback work
             end if
             commit work
         end if
      end if

   on key (interrupt)
      exit input

end input

#-------------- Grava AVALIACAO ---------------#

if not int_flag               and
   d_ctp01m02.psqcod = "M10"  then
   call aval_ctp01m02(param.atdsrvnum, param.atdsrvano)

   while true

      let int_flag = false

      options
         insert key F35 ,
         delete key F36

      input array a_ctp01m02 without defaults from s_ctp01m02.*

         before row
            let arr_aux = arr_curr()
            let scr_aux = scr_line()
            if arr_aux <= arr_count()  then
               let ws.operacao = "a"
            end if

         before insert
            let ws.operacao = "i"
            continue input

         before field avlpsqnot
            display a_ctp01m02[arr_aux].avlpsqnot to
                    s_ctp01m02[scr_aux].avlpsqnot attribute (reverse)

         after  field avlpsqnot
            display a_ctp01m02[arr_aux].avlpsqnot to
                    s_ctp01m02[scr_aux].avlpsqnot

            if a_ctp01m02[arr_aux].avlitmcod     is null then
               if a_ctp01m02[arr_aux].avlpsqnot  is null then
                  error "Avaliacao deve ser informada!"
                  next field avlpsqnot
               end if
            end if

            if a_ctp01m02[arr_aux].avlpsqnot <> 0     and
               a_ctp01m02[arr_aux].avlpsqnot <> 1     and
               a_ctp01m02[arr_aux].avlpsqnot <> 2     and
               a_ctp01m02[arr_aux].avlpsqnot <> 3     and
               a_ctp01m02[arr_aux].avlpsqnot <> 4     and
               a_ctp01m02[arr_aux].avlpsqnot <> 5     and
               a_ctp01m02[arr_aux].avlpsqnot <> 6     and
               a_ctp01m02[arr_aux].avlpsqnot <> 7     and
               a_ctp01m02[arr_aux].avlpsqnot <> 8     and
               a_ctp01m02[arr_aux].avlpsqnot <> 9     and
               a_ctp01m02[arr_aux].avlpsqnot <> 10    then
               error "So' sao permitidas notas de 0 a 10!"
               next field avlpsqnot
            end if

         before field histflg
            display a_ctp01m02[arr_aux].histflg  to
                    s_ctp01m02[scr_aux].histflg  attribute (reverse)

         after  field histflg
            display a_ctp01m02[arr_aux].histflg  to
                    s_ctp01m02[scr_aux].histflg

            if a_ctp01m02[arr_aux].histflg = "S"   then
               call ctp01m03(param.atdsrvnum, param.atdsrvano,
                             g_issk.funmat, param.data, param.hora)
               let ws.histreg = "S"
            end if
            if a_ctp01m02[arr_aux].histflg is null then
               display "N" to s_ctp01m02[scr_aux].histflg
            end if
            if a_ctp01m02[arr_aux].histflg <> "N" then
               if ws.histreg <> "S" then
                  error "Informa (S)im ou (N)ao!"
                  next field histflg
               end if
            end if

         on key (interrupt)
            exit input

         before delete
           let ws.operacao = "d"
           if a_ctp01m02[arr_aux].avlpsqnot  is null   then
              continue input
           end if

         after row
           begin work
             if ws.operacao = "a" then
                update datrpesqaval
                   set avlpsqnot = a_ctp01m02[arr_aux].avlpsqnot
                 where atdsrvnum = param.atdsrvnum           and
                       atdsrvano = param.atdsrvano           and
                       avlitmcod = a_ctp01m02[arr_aux].avlitmcod

                if sqlca.sqlcode <> 0  then
                   error "Erro (",sqlca.sqlcode,") na alteracao da avaliacao.",
                         "AVISE A INFORMATICA!"
                   rollback work
                end if
             end if
           commit work

         let ws.operacao = " "
      end input

    if int_flag   then
       exit while
    end if

   end while
end if

let int_flag = false
close window w_ctp01m02

end function  ## ctp01m02

#------------------------------------------------------------------
function monta_ctp01m02(param)
#------------------------------------------------------------------

define param     record
   atdsrvnum     like datmservico.atdsrvnum ,
   atdsrvano     like datmservico.atdsrvano
end record

define arr_idx   smallint

let arr_aux  =  1

declare c_ctp01m02 cursor for
   select avlitmcod, avlpsqnot
     from datrpesqaval
    where atdsrvnum = param.atdsrvnum  and
          atdsrvano = param.atdsrvano

foreach c_ctp01m02 into a_ctp01m02[arr_aux].avlitmcod ,
                        a_ctp01m02[arr_aux].avlpsqnot

   case a_ctp01m02[arr_aux].avlitmcod
        when "01"
             let a_ctp01m02[arr_aux].avlitmdes = "CENTRAL 24 HS"
        when "02"
             let a_ctp01m02[arr_aux].avlitmdes = "TEMPO DE CHEGADA"
        when "03"
             let a_ctp01m02[arr_aux].avlitmdes = "SERVICO"
        when "04"
             let a_ctp01m02[arr_aux].avlitmdes = "OUTROS"
   end  case

   let arr_aux = arr_aux + 1
   if arr_aux > 04 then
      exit foreach
   end if

end foreach

call set_count(arr_aux-1)

for arr_idx = 1  to  4
    display a_ctp01m02[arr_idx].avlitmcod  to  s_ctp01m02[arr_idx].avlitmcod
    display a_ctp01m02[arr_idx].avlitmdes  to  s_ctp01m02[arr_idx].avlitmdes
    display a_ctp01m02[arr_idx].avlpsqnot  to  s_ctp01m02[arr_idx].avlpsqnot
end for

close c_ctp01m02

end function  ## monta_ctp01m02

#------------------------------------------------------------------
 function aval_ctp01m02(param)
#------------------------------------------------------------------

define param     record
   atdsrvnum     like datmservico.atdsrvnum ,
   atdsrvano     like datmservico.atdsrvano
end record

define ws_avlitm      smallint
define ws_avlitmcod   like datrpesqaval.avlitmcod

select max(avlitmcod)
  into ws_avlitmcod
  from datrpesqaval
 where atdsrvnum = param.atdsrvnum    and
       atdsrvano = param.atdsrvano

if ws_avlitmcod > 0  then
   return
end if

BEGIN WORK
for ws_avlitm = 01 to 04
    insert into datrpesqaval ( atdsrvnum     ,
                               atdsrvano     ,
                               avlitmcod     )
                values       ( param.atdsrvnum ,
                               param.atdsrvano ,
                               ws_avlitm     )

    if sqlca.sqlcode <> 0  then
       error "Erro (", sqlca.sqlcode, ") na inclusao da avaliacao. " ,
             "AVISE A INFORMATICA!"
       rollback work
    end if
end for
COMMIT WORK

call monta_ctp01m02(param.atdsrvnum, param.atdsrvano)

end function  ## aval_ctp01m02

