###############################################################################
# Nome do Modulo: cta07m00                                           Ruiz     #
# Mostra o ultimo condutor do veiculo                                Fev/2001 #
###############################################################################

# ...............................................................................#
#                                                                                #
#                           * * * Alteracoes * * *                               #
#                                                                                #
# Data       Autor Fabrica   Origem        Alteracao                             #
# ---------- --------------  ----------    --------------------------------------#
# 10/09/2005 T. Solda,Meta   PSIMelhorias  Chamada da funcao "fun_dba_abre_banco"#
#                                          e troca da "systables" por "dual"     #
#--------------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'

 define d_cta07m00  record
      opcao          dec (01)                   ,
      cdtnom         like aeikcdt.cdtnom        ,
      cgccpfnumc     like aeikcdt.cgccpfnum     ,
      cgccpfdigc     like aeikcdt.cgccpfdig     ,
      segnom         like gsakseg.segnom        ,
      cgccpfnums     like gsakseg.cgccpfnum     ,
      cgccpfdigs     like gsakseg.cgccpfdig     ,
      newcdtnom      like aeikcdt.cdtnom        ,
      cgccpfnumn     like aeikcdt.cgccpfnum     ,
      cgccpfdign     like aeikcdt.cgccpfdig
 end record
 define ws          record
      segnumdig   like gsakseg.segnumdig,
      cdtseq      like aeikcdt.cdtseq,
      cgccpfnum   char(12),
      cgccpfdig   char(02),
      succod      like abamdoc.succod  ,
      aplnumdig   like abamdoc.aplnumdig,
      itmnumdig   like aeikcdt.itmnumdig,
      manut       char(01),
      txtlin      like abbmquesttxt.txtlin,
      tamanho     char(110),
      flgcondutor char(01)
 end record

#main
#  prompt "succod    = " for ws.succod
#  prompt "aplnumdig = " for ws.aplnumdig
#  prompt "itmnumdig = " for ws.itmnumdig
#  prompt "manut     = " for ws.manut
#  call cta07m00(ws.succod,ws.aplnumdig,ws.itmnumdig,ws.manut)
#end main

#------------------------------------------------------------------------------
 function cta07m00(param)
#------------------------------------------------------------------------------
   define param       record
       succod         like abamdoc.succod  ,
       aplnumdig      like abamdoc.aplnumdig,
       itmnumdig      like aeikcdt.itmnumdig,
       manut          char(01)
   end record
   define i smallint
   define a smallint
   define b smallint


	let	i  =  null
	let	a  =  null
	let	b  =  null

   let int_flag  =  false
   initialize d_cta07m00.*  to null
   initialize ws.*          to null

   if param.manut = "C"  then
      call cta07m00_consulta(param.succod,param.aplnumdig,param.itmnumdig,
                             ws.segnumdig)
      return
   else
      open window cta07m00 at 06,10 with form "cta07m00"
                            attribute (border, form line 1)
   end if
  #--------------------------------------------------------------------------
  # Ultima situacao da apolice
  #--------------------------------------------------------------------------
   call f_funapol_ultima_situacao
        (param.succod, param.aplnumdig, param.itmnumdig)
         returning g_funapol.*

  #--------------------------------------------------------------------------
  # Numero do segurado
  #--------------------------------------------------------------------------
   select segnumdig
     into ws.segnumdig
     from abbmdoc
    where abbmdoc.succod    =  param.succod      and
          abbmdoc.aplnumdig =  param.aplnumdig   and
          abbmdoc.itmnumdig =  param.itmnumdig   and
          abbmdoc.dctnumseq =  g_funapol.dctnumseq
   if sqlca.sqlcode <> 0  then
       error " Erro (", sqlca.sqlcode, ") na localizacao da apolice ",
             "de automovel. AVISE A INFORMATICA!"
   end if

   input by name d_cta07m00.opcao     ,
                 d_cta07m00.cdtnom    ,
                 d_cta07m00.segnom    ,
                 d_cta07m00.newcdtnom ,
                 d_cta07m00.cgccpfnumn,
                 d_cta07m00.cgccpfdign

       before field opcao
         display by name d_cta07m00.opcao attribute (reverse)
         select segnom,cgccpfnum,cgccpfdig
             into d_cta07m00.segnom,
                  d_cta07m00.cgccpfnums,
                  d_cta07m00.cgccpfdigs
             from gsakseg
          where segnumdig = ws.segnumdig

          select txtlin
              into d_cta07m00.cdtnom
              from abbmquesttxt
             where succod    = param.succod
               and aplnumdig = param.aplnumdig
               and itmnumdig = param.itmnumdig
               and dctnumseq = g_funapol.dctnumseq
               and qstcod    = 19   # condutor principal
          if sqlca.sqlcode = 0  then
             select txtlin
                into ws.txtlin
                from abbmquesttxt
               where succod    = param.succod
                 and aplnumdig = param.aplnumdig
                 and itmnumdig = param.itmnumdig
                 and dctnumseq = g_funapol.dctnumseq
                 and qstcod    = 20 # cpf do condutor
             if sqlca.sqlcode =  0  then
                let a      = 0
                let b      = 0
                initialize ws.tamanho to null
                for i = 1 to length(ws.txtlin)
                   case ws.txtlin[i]
                     when " "
                     when "-"
                     when "/"
                     when "."
                  otherwise
                     let ws.tamanho   = ws.tamanho   clipped, ws.txtlin[i]
                   end case
                end for
                while ws.tamanho[1] = "0" and length(ws.tamanho)>1
                   let a            = length(ws.tamanho)
                   let ws.tamanho   = ws.tamanho[2,a]
                end while
                if length(ws.tamanho) > 2 then
                   let a            = length(ws.tamanho)-1
                   let b            = length(ws.tamanho)
                   let ws.cgccpfdig = ws.tamanho[a,b]
                   let a            = length(ws.tamanho)-2
                   let ws.cgccpfnum = ws.tamanho[1, a]
                end if
             end if
             let d_cta07m00.cgccpfnumc = ws.cgccpfnum
             let d_cta07m00.cgccpfdigc = ws.cgccpfdig
          end if
          select ctcdtnom,ctcgccpfnum,ctcgccpfdig
                 into d_cta07m00.newcdtnom,
                      d_cta07m00.cgccpfnumn,
                      d_cta07m00.cgccpfdign
                 from tmpcondutor
          if sqlca.sqlcode = 0  then
             let ws.flgcondutor      = "N"     # ruiz 601566
             if d_cta07m00.newcdtnom = d_cta07m00.cdtnom then
                let d_cta07m00.opcao = 1
             else
                if d_cta07m00.newcdtnom = d_cta07m00.segnom then
                   let d_cta07m00.opcao = 2
                else
                   if d_cta07m00.newcdtnom = "Nao Informado" then
                      let d_cta07m00.opcao = 4
                   else
                      let d_cta07m00.opcao = 3
                   end if
                end if
             end if
          end if
          display by name d_cta07m00.*

       after field opcao
         if d_cta07m00.opcao < 1  or
            d_cta07m00.opcao > 4  or
            d_cta07m00.opcao is null then
            error "Opcao invalida, digite novamente "
            next field opcao
         end if
         if d_cta07m00.opcao  =  1  then
            let d_cta07m00.newcdtnom  = d_cta07m00.cdtnom
            let d_cta07m00.cgccpfnumn = d_cta07m00.cgccpfnumc
            let d_cta07m00.cgccpfdign = d_cta07m00.cgccpfdigc
            let ws.flgcondutor   = "S" # o condutor e o motorista
            exit input
         else
            if d_cta07m00.opcao = 2 then
               let d_cta07m00.newcdtnom  = d_cta07m00.segnom
               let d_cta07m00.cgccpfnumn = d_cta07m00.cgccpfnums
               let d_cta07m00.cgccpfdign = d_cta07m00.cgccpfdigs
               exit input
            else
               if d_cta07m00.opcao = 3 then
                  initialize d_cta07m00.newcdtnom to null
                  initialize d_cta07m00.cgccpfnumn to null
                  initialize d_cta07m00.cgccpfdign to null
                  next field newcdtnom
               else
                  let d_cta07m00.newcdtnom = "Nao Informado"
                  initialize d_cta07m00.cgccpfnumn to null
                  initialize d_cta07m00.cgccpfdign to null
                  exit input
               end if
            end if
         end if

       before field newcdtnom
          display by name d_cta07m00.newcdtnom
          display by name d_cta07m00.cgccpfnumn
          display by name d_cta07m00.cgccpfdign

       after  field newcdtnom
          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field opcao
          end if
          if d_cta07m00.newcdtnom is null then
             error "a opcao escolhida, exige que o campo seja obrigatorio"
             next field newcdtnom
          end if

       after  field cgccpfnumn
          if d_cta07m00.cgccpfnumn is null or
             d_cta07m00.cgccpfnumn =  0    then
             exit input
          end if

       after  field cgccpfdign
             if d_cta07m00.cgccpfdign is null or
                d_cta07m00.cgccpfdign =  0    then
                exit input
             end if
             call F_FUNDIGIT_DIGITOCPF(d_cta07m00.cgccpfnumn)
                             returning ws.cgccpfdig
             if ws.cgccpfdig <> d_cta07m00.cgccpfdign  then
                error "C.P.F. invalido "
                next field cgccpfnumn
             end if

       on key (interrupt,control-c)
         if d_cta07m00.newcdtnom is null then
            error "campo opcao e obrigatorio"
            next field opcao
         end if
         exit input

   end input
   if d_cta07m00.newcdtnom is not null  then
      if d_cta07m00.cgccpfnumn is null then
         let d_cta07m00.cgccpfnumn = 0
         let d_cta07m00.cgccpfdign = 0
      end if
      if d_cta07m00.cgccpfdign is null then
         let d_cta07m00.cgccpfdign = 0
      end if
      select ctcdtnom
           from tmpcondutor   # tabela temporaria criada no modulo cta02m00
      if sqlca.sqlcode = notfound then
         if g_issk.funmat = 601566 then
            display "* cta07m00-ws.flgcondutor = ", ws.flgcondutor
         end if
         insert into tmpcondutor
            values (ws.flgcondutor,d_cta07m00.newcdtnom,d_cta07m00.cgccpfnumn,
                    d_cta07m00.cgccpfdign)
      else
         update tmpcondutor
             set ctcdtnom    =  d_cta07m00.newcdtnom,
                 ctcgccpfnum =  d_cta07m00.cgccpfnumn,
                 ctcgccpfdig =  d_cta07m00.cgccpfdign
      end if
   end if
   close window cta07m00
   let int_flag = false
   return
 end function

#------------------------------------------------------------------------------
 function cta07m00_consulta(param)
#------------------------------------------------------------------------------

    define param       record
        succod         like abamdoc.succod  ,
        aplnumdig      like abamdoc.aplnumdig,
        itmnumdig      like aeikcdt.itmnumdig,
        segnumdig      like gsakseg.segnumdig
    end record
    define d_cta07m00a record
         cdtnom         like aeikcdt.cdtnom        ,
         cgccpfnumc     like aeikcdt.cgccpfnum     ,
         cgccpfdigc     like aeikcdt.cgccpfdig     ,
         segnom         like gsakseg.segnom        ,
         cgccpfnums     like gsakseg.cgccpfnum     ,
         cgccpfdigs     like gsakseg.cgccpfdig     ,
         newcdtnom      like aeikcdt.cdtnom        ,
         cgccpfnumn     like aeikcdt.cgccpfnum     ,
         cgccpfdign     like aeikcdt.cgccpfdig
    end record
    define i smallint
    define a smallint
    define b smallint
    define prompt_key   char(01)


	let	i  =  null
	let	a  =  null
	let	b  =  null
	let	prompt_key  =  null

	initialize  d_cta07m00a.*  to  null

    open window cta07m00a at 10,10 with form "cta07m00a"
                         attribute (border, form line 1)

   #--------------------------------------------------------------------------
   # Ultima situacao da apolice
   #--------------------------------------------------------------------------
    call f_funapol_ultima_situacao
         (param.succod, param.aplnumdig, param.itmnumdig)
          returning g_funapol.*

   #--------------------------------------------------------------------------
   # Numero do segurado
   #--------------------------------------------------------------------------
    select segnumdig
      into ws.segnumdig
      from abbmdoc
     where abbmdoc.succod    =  param.succod      and
           abbmdoc.aplnumdig =  param.aplnumdig   and
           abbmdoc.itmnumdig =  param.itmnumdig   and
           abbmdoc.dctnumseq =  g_funapol.dctnumseq
    if sqlca.sqlcode <> 0  then
        error " Erro (", sqlca.sqlcode, ") na localizacao da apolice ",
              "de automovel. AVISE A INFORMATICA!"
    end if

    select txtlin
       into d_cta07m00a.cdtnom
       from abbmquesttxt
      where succod    = param.succod
        and aplnumdig = param.aplnumdig
        and itmnumdig = param.itmnumdig
        and dctnumseq = g_funapol.dctnumseq
        and qstcod    = 19   # condutor principal
    if sqlca.sqlcode = 0  then
       select txtlin
           into ws.txtlin
           from abbmquesttxt
          where succod    = param.succod
            and aplnumdig = param.aplnumdig
            and itmnumdig = param.itmnumdig
            and dctnumseq = g_funapol.dctnumseq
            and qstcod    = 20 # cpf do condutor
       if sqlca.sqlcode =  0  then
          let a      = 0
          let b      = 0
          initialize ws.tamanho to null
          for i = 1 to length(ws.txtlin)
              case ws.txtlin[i]
                 when " "
                 when "-"
                 when "/"
                 when "."
              otherwise
                 let ws.tamanho   = ws.tamanho   clipped, ws.txtlin[i]
              end case
          end for
          while ws.tamanho[1] = "0" and length(ws.tamanho)>1
              let a            = length(ws.tamanho)
              let ws.tamanho   = ws.tamanho[2,a]
          end while
          if length(ws.tamanho) > 2 then
             let a            = length(ws.tamanho)-1
             let b            = length(ws.tamanho)
             let ws.cgccpfdig = ws.tamanho[a,b]
             let a            = length(ws.tamanho)-2
             let ws.cgccpfnum = ws.tamanho[1, a]
          end if
       end if
       let d_cta07m00a.cgccpfnumc = ws.cgccpfnum
       let d_cta07m00a.cgccpfdigc = ws.cgccpfdig
    end if
    #-------------------------------------------------------------------------
    # Nome e cpf do segurado
    #-------------------------------------------------------------------------
    select segnom,cgccpfnum,cgccpfdig
          into d_cta07m00a.segnom,
               d_cta07m00a.cgccpfnums,
               d_cta07m00a.cgccpfdigs
          from gsakseg
         where segnumdig = ws.segnumdig
    #--------------------------------------------------------------------------
    # Ultima alteracao da central
    #--------------------------------------------------------------------------
    if g_documento.atdsrvnum is not null  then
       select vclcndseq
          into ws.cdtseq
          from datrsrvcnd    # tabela de relacionamento
         where atdsrvnum = g_documento.atdsrvnum
           and atdsrvano = g_documento.atdsrvano

       select cdtnom,cgccpfnum,cgccpfdig
          into d_cta07m00a.newcdtnom,
               d_cta07m00a.cgccpfnumn,
               d_cta07m00a.cgccpfdign
          from aeikcdt
         where succod    =  param.succod
           and aplnumdig =  param.aplnumdig
           and itmnumdig =  param.itmnumdig
           and cdtseq    =  ws.cdtseq
        if sqlca.sqlcode = notfound  then
           initialize d_cta07m00a.newcdtnom  to null
           initialize d_cta07m00a.cgccpfnumn to null
           initialize d_cta07m00a.cgccpfdign to null
        end if
     else
        if g_documento.cndslcflg = "S" then
           select ctcdtnom,ctcgccpfnum,ctcgccpfdig # servico ainda nao foi
              into d_cta07m00a.newcdtnom,          # gerado,  utilizar a
                   d_cta07m00a.cgccpfnumn,         # tabela temporaria.
                   d_cta07m00a.cgccpfdign
             from tmpcondutor
        end if
     end if
     display by name d_cta07m00a.*
     prompt " (F17)Abandona" for prompt_key
     let int_flag = false
     close window cta07m00a
     return
 end function
