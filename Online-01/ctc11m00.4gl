###############################################################################
# Nome do Modulo: CTC11M00                                           Pedro    #
#                                                                    Marcelo  #
# Custos dos servicos realizados pela frota porto                    Dez/1994 #
###############################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
function ctc11m00()
#------------------------------------------------------------

 define d_ctc11m00 record
    hortrab        dec(15,5),
    kmguincho      dec(15,5),
    kmveiculo      dec(15,5)
 end record

 define ws         record
    hortrab        char(16),
    kmguincho      char(16),
    kmveiculo      char(16),
    erro           char(01)
 end record


 open window ctc11m00 at 06,02 with form "ctc11m00"
                         attribute (form line first)

 while  true

   let int_flag = false
   let ws.erro  = "n"
   initialize d_ctc11m00  to null

   input by name d_ctc11m00.*

     before field hortrab
      display by name d_ctc11m00.hortrab    attribute (reverse)

      select grlinf [1,16]
         into  d_ctc11m00.hortrab
         from  igbkgeral
         where mducod = "C24"             and
               grlchv = "HORA-TRABALHADA"
      if status = notfound   then
         error " Valor da hora trabalhada nao encontrada. AVISE A INFORMATICA!"
         sleep 4
         let ws.erro = "s"
         exit input
      else
         display by name d_ctc11m00.hortrab    attribute (reverse)
      end if

      select grlinf [1,16]
         into  d_ctc11m00.kmguincho
         from  igbkgeral
         where mducod = "C24"             and
               grlchv = "KM-GUINCHO"
      if status = notfound   then
         error " Valor do km rodado guincho nao encontrado. AVISE A INFORMATICA!"
         sleep 4
         let ws.erro = "s"
         exit input
      else
         display by name d_ctc11m00.kmguincho
      end if

      select grlinf [1,16]
         into  d_ctc11m00.kmveiculo
         from  igbkgeral
         where mducod = "C24"             and
               grlchv = "KM-VEICULO"
      if status = notfound   then
         error " Valor do km rodado veiculo nao encontrado. AVISE A INFORMATICA!"
         sleep 4
         let ws.erro = "s"
         exit input
      else
         display by name d_ctc11m00.kmveiculo
      end if

     after field hortrab
        display by name d_ctc11m00.hortrab

        if d_ctc11m00.hortrab     is null  then
           error " Valor da hora trabalhada deve ser informado!"
           next field hortrab
        end if

     before field kmguincho
        display by name d_ctc11m00.kmguincho  attribute (reverse)

     after field kmguincho
        display by name d_ctc11m00.kmguincho

        if fgl_lastkey()  =  fgl_keyval("up")     or
           fgl_lastkey()  =  fgl_keyval("left")   then
           next field hortrab
        end if

        if d_ctc11m00.kmguincho   is null  then
           error " Valor do km rodado guincho deve ser informado!"
           next field kmguincho
        end if

     before field kmveiculo
        display by name d_ctc11m00.kmveiculo attribute (reverse)

     after field kmveiculo
        display by name d_ctc11m00.kmveiculo

        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           next field kmguincho
        end if

        if d_ctc11m00.kmveiculo   is null   then
           error " Valor do km rodado veiculo deve ser informado"
           next field kmveiculo
        end if

     on key (interrupt)
        exit input

   end input

   if ws.erro = "s"  then
      exit while
   end if

   if not int_flag  then
      let ws.hortrab    =  d_ctc11m00.hortrab   using "--,---,--&.&&&&&"
      let ws.kmguincho  =  d_ctc11m00.kmguincho using "--,---,--&.&&&&&"
      let ws.kmveiculo  =  d_ctc11m00.kmveiculo using "--,---,--&.&&&&&"

      begin work

         update igbkgeral
            set
              grlinf = ws.hortrab
            where
              mducod = "C24"             and
              grlchv = "HORA-TRABALHADA"
         if status <> 0   then
            error "Problemas na gravacao hora trabalhada. AVISE A INFORMATICA!"
            sleep 4
            let ws.erro = "s"
         end if

         update igbkgeral
            set
              grlinf = ws.kmguincho
            where
              mducod = "C24"             and
              grlchv = "KM-GUINCHO"
         if status <> 0   then
            error "Problemas na gravacao km guincho. AVISE A INFORMATICA!"
            sleep 4
            let ws.erro = "s"
         end if

         update igbkgeral
            set
              grlinf = ws.kmveiculo
            where
              mducod = "C24"             and
              grlchv = "KM-VEICULO"
         if status <> 0   then
            error "Problemas na gravacao km veiculo. AVISE A INFORMATICA!"
            sleep 4
            let ws.erro = "s"
         end if

      commit work
   else
      exit while
   end if

   if ws.erro = "s"  then
      exit while
   end if

end while

let int_flag = false
close window ctc11m00
return

end function  ###  ctc11m00
