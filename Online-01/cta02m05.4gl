###############################################################################
# Nome do Modulo: CTA02M05                                              Pedro #
#                                                                     Marcelo #
# Informa dados referentes a ligacao (L11 e L12)                     Mai/1995 #
###############################################################################
#.............................................................................#
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor   Fabrica     Origem    Alteracao                          #
# ---------- ----------------- ----------  -----------------------------------#
# 21/12/2006 Priscila          CT          Chamar funcao especifica para      #
#                                          insercao em datmlighist            #
#-----------------------------------------------------------------------------#


database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

define m_cta02m05_prepare smallint

#------------------------------------------------------------
function cta02m05_prepare()
#------------------------------------------------------------

define l_sql char(30000)

let l_sql =   '   select ufdcod       '
          ,   '     from glakest      '
          ,   '    where ufdcod = ?   '
prepare p_cta02m05_0001 from l_sql
declare c_cta02m05_0001 cursor with hold for p_cta02m05_0001


let l_sql =   '  select ufdnom                      '
          ,   '    from glakest                     '
          ,   '   where ufdcod = ?                  '
prepare p_cta02m05_0002 from l_sql
declare c_cta02m05_0002 cursor with hold for p_cta02m05_0002

let l_sql =   ' select cidcod          '
          ,   '   from glakcid         '
          ,   '  where cidnom =  ?     '
          ,   '    and ufdcod =  ?     '
prepare p_cta02m05_0003 from l_sql
declare c_cta02m05_0003 cursor with hold for p_cta02m05_0003

 let m_cta02m05_prepare = 1

end function

#------------------------------------------------------------
 function cta02m05(par_cta02m05)
#------------------------------------------------------------

   define par_cta02m05  record
      lignum            like datmlighist.lignum   ,
      funmat            like datmlighist.c24funmat,
      data              like datmlighist.ligdat   ,
      hora              like datmlighist.lighorinc,
      vcllicnum         like abbmveic.vcllicnum,   #placa
      vclchsnum         char(20)                   #chassi concatenado
   end record

   define d_cta02m05    record
      atddat            like datmservico.atddat   ,
      lcldat            like datmservico.atddat   ,
      vclpdrseg         char (01)                 ,
      cidnom            like datmlcl.cidnom       ,
      ufdcod            like datmlcl.ufdcod       ,
      flagbo            char(1)                   ,
      bocnum            like datmservicocmp.bocnum,
      delegacia         char (07)                 
   end record

   define ws            record
      ligdat            like datmservico.atddat   ,
      lighor            like datmservico.atdhor   ,
      funmat            like datmlighist.c24funmat,
      #c24txtseq         like datmlighist.c24txtseq,
      c24ligdsc         like datmlighist.c24ligdsc
   end record

   define l_ret         smallint,
          l_mensagem    char(50)

   define aux_times     char (11)

   define l_cidcod      like glakcid.cidcod

   define cta02m05_reg record
          atdsrvnum   like datmservico.atdsrvnum,
          atdsrvano   like datmservico.atdsrvano
   end record

  if m_cta02m05_prepare is null or
     m_cta02m05_prepare = false then
     call cta02m05_prepare()
  end if

	let	aux_times  =  null

	initialize  d_cta02m05.*  to  null

	initialize  ws.*  to  null

   open window w_cta02m05 at  9,20 with form "cta02m05"
            attribute(border, form line 1)

   initialize d_cta02m05.*   to null

   input by name d_cta02m05.*

      before field atddat
         display by name d_cta02m05.atddat    attribute (reverse)

      after  field atddat
         display by name d_cta02m05.atddat

         if fgl_lastkey() <> fgl_keyval("up")   and
            fgl_lastkey() <> fgl_keyval("left") then
            if d_cta02m05.atddat > today        then
               error "Data do furto maior que hoje!"
               next field atddat
            end if
         end if

      before field lcldat
         display by name d_cta02m05.lcldat   attribute (reverse)

      after  field lcldat
         display by name d_cta02m05.lcldat

         if fgl_lastkey() <> fgl_keyval("up")   and
            fgl_lastkey() <> fgl_keyval("left") then
            if d_cta02m05.lcldat > today        then
               error "Data da localizacao maior que hoje!"
               next field lcldat
            end if
         end if

      before field vclpdrseg
         display by name d_cta02m05.vclpdrseg  attribute (reverse)

      after  field vclpdrseg
         display by name d_cta02m05.vclpdrseg

         if fgl_lastkey() <> fgl_keyval("up")   and
            fgl_lastkey() <> fgl_keyval("left") then
            if d_cta02m05.vclpdrseg is not null  then
               if d_cta02m05.vclpdrseg <> "S"    and
                  d_cta02m05.vclpdrseg <> "N"    and
                  d_cta02m05.vclpdrseg <> " "    then
                  error " Veiculo em poder do segurado ? (S)im ou (N)ao"
                  next field vclpdrseg
               end if

               if d_cta02m05.vclpdrseg = " " then
                  initialize d_cta02m05.vclpdrseg to null
               end if
            end if
         end if

      before field cidnom
         display by name d_cta02m05.cidnom attribute (reverse)

      after field cidnom
      display by name d_cta02m05.cidnom

      if fgl_lastkey() <> fgl_keyval("up")   and
         fgl_lastkey() <> fgl_keyval("left") then
            next field ufdcod
      end if


      before field ufdcod
         display by name d_cta02m05.ufdcod attribute (reverse)

      after field ufdcod
         display by name d_cta02m05.ufdcod

         if fgl_lastkey() <> fgl_keyval("up")   and
            fgl_lastkey() <> fgl_keyval("left") then
            if d_cta02m05.ufdcod = "DF"  then
               let d_cta02m05.cidnom = "BRASILIA"
               display by name d_cta02m05.cidnom
            end if

            if d_cta02m05.ufdcod is null then
               error 'Sigla da unidade da federacao deve ser informada!'
            end if

            #--------------------------------------------------------------
            # Verifica se UF esta cadastrada
            #--------------------------------------------------------------
            open  c_cta02m05_0001  using  d_cta02m05.ufdcod

             if sqlca.sqlcode = notfound then
                error " Unidade federativa nao cadastrada!"
                next field ufdcod
             end if

            if d_cta02m05.ufdcod = d_cta02m05.cidnom  then
               open c_cta02m05_0002 using d_cta02m05.cidnom
               fetch c_cta02m05_0002 into d_cta02m05.cidnom

               if sqlca.sqlcode = 0  then
                  display by name d_cta02m05.cidnom
               else
                  let d_cta02m05.cidnom = d_cta02m05.ufdcod
               end if
            end if

            #--------------------------------------------------------------
            # Verifica se a cidade esta cadastrada
            #--------------------------------------------------------------
             open  c_cta02m05_0003 using d_cta02m05.cidnom, d_cta02m05.ufdcod
             fetch c_cta02m05_0003  into  l_cidcod

             if sqlca.sqlcode  =  100   then
                call cts06g04(d_cta02m05.cidnom, d_cta02m05.ufdcod)
                     returning l_cidcod, d_cta02m05.cidnom, d_cta02m05.ufdcod

                if d_cta02m05.cidnom  is null   then
                   error " Cidade deve ser informada!"
                end if
                next field cidnom
             end if
             close c_cta02m05_0003
         end if

      before field flagbo
         display by name d_cta02m05.flagbo attribute (reverse)
         message '  (S)im ou (N)ao.'

      after field flagbo
         display by name d_cta02m05.flagbo
         message ''

         if fgl_lastkey() <> fgl_keyval("up")   and
            fgl_lastkey() <> fgl_keyval("left") then
            if d_cta02m05.flagbo = 'S' then
               next field bocnum
            else
               exit input
            end if
         end if

      before field bocnum
         display by name d_cta02m05.bocnum attribute (reverse)

      after field bocnum
          display by name d_cta02m05.bocnum

      before field delegacia
         display by name d_cta02m05.delegacia attribute (reverse)

      after  field delegacia
         display by name d_cta02m05.delegacia


      on key (interrupt)
         error 'Digite as informacoes acima!'
         next field atddat


   end input

   if  d_cta02m05.atddat     is null and
       d_cta02m05.lcldat     is null and
       #d_cta02m05.delegacia  is null and
       d_cta02m05.vclpdrseg  is null then
       error "Nenhum dado informado para esta ligacao!"
       close window  w_cta02m05
       return d_cta02m05.cidnom,
              d_cta02m05.ufdcod,
              d_cta02m05.flagbo,
              d_cta02m05.bocnum
   end if

   if  int_flag       then
       let int_flag = false
       error "Operacao cancelada!"
       close window  w_cta02m05
       return d_cta02m05.cidnom,
              d_cta02m05.ufdcod,
              d_cta02m05.flagbo,
              d_cta02m05.bocnum
   end if

   let int_flag     = false
   #let ws.c24txtseq = 0

   if  par_cta02m05.data is null then
       let aux_times = time
       let ws.lighor = aux_times[1,5]
       let ws.ligdat = today
       let ws.funmat = g_issk.funmat
   else
       let ws.lighor = par_cta02m05.hora
       let ws.ligdat = par_cta02m05.data
       let ws.funmat = par_cta02m05.funmat
   end if

   if  d_cta02m05.atddat  is not null  then
       let ws.c24ligdsc = "Data do Furto......: ", d_cta02m05.atddat
       #let ws.c24txtseq = 1
       #Priscila 21/12/2006
       #call historico_cta02m05(par_cta02m05.lignum, ws.*)
       call ctd06g01_ins_datmlighist(par_cta02m05.lignum,
                                     ws.funmat,
                                     ws.c24ligdsc,
                                     ws.ligdat,
                                     ws.lighor,
                                     g_issk.usrtip,
                                     g_issk.empcod  )
            returning l_ret,
                      l_mensagem
   end if

   if  d_cta02m05.lcldat is not null  then
       let ws.c24ligdsc = "Data da Localizacao: ", d_cta02m05.lcldat
       #let ws.c24txtseq = 2
       #Priscila 21/12/2006
       #call historico_cta02m05(par_cta02m05.lignum, ws.*)
       call ctd06g01_ins_datmlighist(par_cta02m05.lignum,
                                     ws.funmat,
                                     ws.c24ligdsc,
                                     ws.ligdat,
                                     ws.lighor,
                                     g_issk.usrtip,
                                     g_issk.empcod  )
            returning l_ret,
                      l_mensagem
   end if

   if  d_cta02m05.delegacia is not null  then
       let ws.c24ligdsc = "Delegacia  Policial: ", d_cta02m05.delegacia
       #Priscila 21/12/2006
       #let ws.c24txtseq = 3
       #call historico_cta02m05(par_cta02m05.lignum, ws.*)
       call ctd06g01_ins_datmlighist(par_cta02m05.lignum,
                                     ws.funmat,
                                     ws.c24ligdsc,
                                     ws.ligdat,
                                     ws.lighor,
                                     g_issk.usrtip,
                                     g_issk.empcod  )
            returning l_ret,
                      l_mensagem
   end if

   if  d_cta02m05.vclpdrseg = "S"         or
       d_cta02m05.vclpdrseg = "N"         then
       let ws.c24ligdsc = "Veic. poder segur.?: ", d_cta02m05.vclpdrseg
       #Priscila 21/12/2006
       #let ws.c24txtseq = 4
       #call historico_cta02m05(par_cta02m05.lignum, ws.*)
       call ctd06g01_ins_datmlighist(par_cta02m05.lignum,
                                     ws.funmat,
                                     ws.c24ligdsc,
                                     ws.ligdat,
                                     ws.lighor,
                                     g_issk.usrtip,
                                     g_issk.empcod  )
            returning l_ret,
                      l_mensagem
   end if
   if l_ret <> 1 then
      error l_mensagem
   end if

   close window  w_cta02m05
   # PATRICIA
   initialize cta02m05_reg to null

   call cts37m00_envia_localizacao(
        g_documento.c24astcod,
        cta02m05_reg.atdsrvnum,
        cta02m05_reg.atdsrvano,
        par_cta02m05.vcllicnum,
        par_cta02m05.vclchsnum,
        par_cta02m05.funmat,
        d_cta02m05.vclpdrseg,
        d_cta02m05.lcldat,
        d_cta02m05.delegacia)

  return d_cta02m05.cidnom,
         d_cta02m05.ufdcod,
         d_cta02m05.flagbo,
         d_cta02m05.bocnum

end function  #  cta02m05
#Priscila - comentado para utilizar a funcao de insercao
# em datmlighist - ctd06g01
#-------------------------------------------
#function historico_cta02m05(par_ligacao, ws)
#-------------------------------------------
#
#define ws            record
#   ligdat            like datmservico.atddat   ,
#   lighor            like datmservico.atdhor   ,
#   funmat            like datmlighist.c24funmat,
#   c24txtseq         like datmlighist.c24txtseq,
#   c24ligdsc         like datmlighist.c24ligdsc
#end record
#
#define par_ligacao like datmlighist.lignum
#
#  if m_cta02m05_prepare <> 'S' then
#     call cta02m05_prepare()
#  end if
#
#
#begin work
#
#   insert into datmlighist (lignum   ,
#                            c24funmat,
#                            lighorinc,
#                            ligdat   ,
#                            c24txtseq,
#                            c24ligdsc)
#                    values (par_ligacao ,
#                            ws.funmat   ,
#                            ws.lighor   ,
#                            ws.ligdat   ,
#                            ws.c24txtseq,
#                            ws.c24ligdsc)
#
#   if sqlca.sqlcode <> 0 then
#      error "Erro (", sqlca.sqlcode, ") na inclusao no historico da ligacao. AVISE A INFORMATICA!"
#      rollback work
#      return
#   end if
#
#commit work
#
#end function  # historico_cta02m05
