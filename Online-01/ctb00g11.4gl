#===========================================================================
# Sistema   : PORTO SOCORRO
# Modulo    : ctb00g11.4gl
# Objetivo  : Identificar documento de origem para o servico sem apolice
#             emitida(proposta, vistoria previa ou cobertura provisoria)
# Projeto   : PSI 211214
# Analista  : Fabio Oliveira
# Liberacao : xx/12/2007
#===========================================================================
database porto

define m_prep  smallint

#----------------------------------------------------------------
function ctb00g11(l_lignum)
#----------------------------------------------------------------

   define l_lignum like datmligacao.lignum
        , l_cmd    char(150),
          l_teste   char(1)

   define l_aux record
          prporg     like datrligprp.prporg     ,
          prpnumdig  like datrligprp.prpnumdig  ,
          ligdcttip  like datrligsemapl.ligdcttip ,
          doctip     char(3)                    ,
          docorg     like datrligprp.prporg     ,
          ligdctnum  dec(10,0)                  ,
          doctxt     char(20)                   ,
          errcod     smallint
   end record

   initialize l_aux.* to null

   let l_aux.errcod = 0

   if m_prep = false
      then
      let m_prep = true

      # selecionar proposta ligada ao servico
      let l_cmd = " select prporg, prpnumdig "
                 ," from datrligprp "
                 ," where lignum = ? "
      prepare p_proposta_sel from l_cmd
      declare c_proposta_sel cursor for p_proposta_sel

      # selecionar outros doctos ligados ao servico
      let l_cmd = " select ligdcttip, ligdctnum "
                 ," from datrligsemapl "
                 ," where lignum = ? "
      prepare p_docto_sel from l_cmd
      declare c_docto_sel cursor for p_docto_sel

   end if

   # identificar documento gerador do servico
   open c_proposta_sel using l_lignum
   fetch c_proposta_sel into l_aux.prporg, l_aux.prpnumdig

   let l_aux.errcod = sqlca.sqlcode

   if sqlca.sqlcode = 0 then

      let l_aux.doctip = "PRP"
      let l_aux.ligdcttip = 1
      let l_aux.docorg    = l_aux.prporg
      let l_aux.ligdctnum = l_aux.prpnumdig
      let l_aux.doctxt    = l_aux.doctip clipped,
          "|" clipped, l_aux.prporg using "<<" clipped,
          "|" clipped, l_aux.ligdctnum using "&&&&&&&&&&" clipped

   else
      if sqlca.sqlcode = 100 then


         open c_docto_sel using l_lignum
         fetch c_docto_sel into l_aux.ligdcttip, l_aux.ligdctnum

         let l_aux.errcod = sqlca.sqlcode

         if l_aux.ligdctnum is not null then

            case
               when l_aux.ligdcttip = 1
                  let l_aux.doctip = "VST"
               when l_aux.ligdcttip = 2
                  let l_aux.doctip = "CBP"
            end case


            let l_aux.doctxt = l_aux.doctip clipped,
                "|" clipped, l_aux.ligdctnum using "&&&&&&&&&&" clipped

         end if
      end if

   end if

   return l_aux.doctip, l_aux.docorg, l_aux.ligdctnum,
          l_aux.doctxt, l_aux.errcod

end function
