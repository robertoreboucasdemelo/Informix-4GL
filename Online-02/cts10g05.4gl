###############################################################################
# Nome do Modulo: CTS10G05                                           Marcus   #
#                                                                             #
# Funcoes genericas de acesso a tabela de Cadastro de  Etapas                 #
# do Servico - DATKETAPA                                             Mai/2001 #
###############################################################################


database porto

function cts10g05_desc_etapa(param)

define param  record
 nivel_ret    integer,
 atdetpcod    like datketapa.atdetpcod
end record

define d_cts10g05  record
 atdetpcod         like datketapa.atdetpcod,
 atdetpdes         like datketapa.atdetpdes,
 atdetptipcod      like datketapa.atdetptipcod,
 atdetpstt         like datketapa.atdetpstt,
 caddat            like datketapa.caddat,
 cademp            like datketapa.cademp,
 cadmat            like datketapa.cadmat,
 atldat            like datketapa.atldat,
 atlemp            like datketapa.atlemp,
 atlmat            like datketapa.atlmat,
 atdetppndflg      like datketapa.atdetppndflg
end record

define result      integer


	let	result  =  null

	initialize  d_cts10g05.*  to  null

initialize d_cts10g05 to null
let result = -1

case param.nivel_ret
   when 1
        # Completo
        select atdetpcod,
               atdetpdes,
               atdetptipcod,
               atdetpstt,
               caddat,
               cademp,
               cadmat,
               atldat,
               atlemp,
               atlmat,
               atdetppndflg
         into  d_cts10g05.atdetpcod,
               d_cts10g05.atdetpdes,
               d_cts10g05.atdetptipcod,
               d_cts10g05.atdetpstt,
               d_cts10g05.caddat,
               d_cts10g05.cademp,
               d_cts10g05.cadmat,
               d_cts10g05.atldat,
               d_cts10g05.atlemp,
               d_cts10g05.atlmat,
               d_cts10g05.atdetppndflg
          from datketapa
         where atdetpcod = param.atdetpcod and
               atdetpstt = "A"

         let result = sqlca.sqlcode

         return result,
                d_cts10g05.atdetpcod,
                d_cts10g05.atdetpdes,
                d_cts10g05.atdetptipcod,
                d_cts10g05.atdetpstt,
                d_cts10g05.caddat,
                d_cts10g05.cademp,
                d_cts10g05.cadmat,
                d_cts10g05.atldat,
                d_cts10g05.atlemp,
                d_cts10g05.atlmat,
                d_cts10g05.atdetppndflg

   when 2
         #Descricao e parametros
         select atdetpdes,
                atdetptipcod,
                atdetppndflg
          into  d_cts10g05.atdetpdes,
                d_cts10g05.atdetptipcod,
                d_cts10g05.atdetppndflg
           from datketapa
         where atdetpcod = param.atdetpcod and
               atdetpstt = "A"

         let result = sqlca.sqlcode

         return result,
                d_cts10g05.atdetpdes,
                d_cts10g05.atdetptipcod,
                d_cts10g05.atdetppndflg
   when 3
        #So descricao de etapa
         select atdetpdes
           into d_cts10g05.atdetpdes
           from datketapa
         where atdetpcod = param.atdetpcod and
               atdetpstt = "A"

         let result = sqlca.sqlcode

         return result,
                d_cts10g05.atdetpdes

end case

end function
