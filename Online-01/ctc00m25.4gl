#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Porto Socorro                                             #
# Modulo.........: ctc00m25                                                  #
# Objetivo.......: Permitir (incluir e alterar) o cadastro do tipo de        #
#                  endereco dos prestadores.                                 #
# Analista Resp. :                                                           #
# Desenvolvido   : Gregorio Ramires, BizTalking                              #
# PSI            : PSI-2012-23608                                            #
#............................................................................#
# Data           : 28/11/2012                                                #
#............................................................................#
#                 * * *  ALTERACOES  * * *                                   #
#                                                                            #
# Data       Autor  Fabrica    Origem       Alteracao                        #
# --------- ----------------- ------------- ---------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#
database porto

   define mr_popup         record
          lgdtip           like dpakpstend.lgdtip      #char(10)
         ,endlgd           like dpakpstend.endlgd      #char(40)
         ,lgdnum           like dpakpstend.lgdnum      #decimal(6,0)
         ,lgdcmp           like dpakpstend.lgdcmp      #char(15)
         ,endbrr           like dpakpstend.endbrr      #char(20)
         ,endcid           like dpakpstend.endcid      #char(20)
         ,ufdsgl           like dpakpstend.ufdsgl      #char(2)
         ,domtipdes        like iddkdominio.cpodes
         ,endtipcod        like dpakpstend.endtipcod   #decimal(2)
         ,endcep           like dpakpstend.endcep      #char(5)
         ,endcepcmp        like dpakpstend.endcepcmp   #char(3)
         ,lclltt           like dpakpstend.lclltt      #decimal(8,6)
         ,lcllgt           like dpakpstend.lcllgt      #decimal(9,6)
   end record

   define mr_enderecos     array[10] of record
          lgdtip           like dpakpstend.lgdtip      #char(10)
         ,endlgd           like dpakpstend.endlgd      #char(40)
         ,lgdnum           like dpakpstend.lgdnum      #decimal(6,0)
         ,lgdcmp           like dpakpstend.lgdcmp      #char(15)
         ,endbrr           like dpakpstend.endbrr      #char(20)
         ,endcid           like dpakpstend.endcid      #char(20)
         ,ufdsgl           like dpakpstend.ufdsgl      #char(2)
         ,domtipdes        like iddkdominio.cpodes
         ,endtipcod        like dpakpstend.endtipcod   #decimal(2)
         ,endcep           like dpakpstend.endcep      #char(5)
         ,endcepcmp        like dpakpstend.endcepcmp   #char(3)
         ,lclltt           like dpakpstend.lclltt      #decimal(8,6)
         ,lcllgt           like dpakpstend.lcllgt      #decimal(9,6)
   end record

   define m_ctc00m25_prep smallint
         ,m_tipo           char(1)
         ,m_count          integer
         ,m_aux_endtipcod  decimal(2,0)
         ,m_aux            decimal(2,0)
         ,m_dominios       smallint


#-------------------------------------------------------------------------------
function ctc00m25_prepare()
#-------------------------------------------------------------------------------
   define l_sql      char(1000)

   initialize l_sql to null

   let l_sql = " select endtipcod      "
              ,"       ,lgdtip         "
              ,"       ,endlgd         "
              ,"       ,lgdnum         "
              ,"       ,lgdcmp         "
              ,"       ,endcep         "
              ,"       ,endcepcmp      "
              ,"       ,endbrr         "
              ,"       ,endcid         "
              ,"       ,ufdsgl         "
              ,"   from dpakpstend     "
              ,"  where pstcoddig = ?  "
              ,"  order by 1           "
   prepare pctc00m25001 from l_sql
   declare cctc00m25001 cursor with hold for pctc00m25001

   let l_sql = "select cpodes                    ",
               "     ,cpocod                     ",
               " from iddkdominio                ",
               "where cponom = 'endtipcod'       ",
               "  and cpocod not in (?)          ",
               " order by cpocod                 "
   prepare pctc00m25002 from l_sql
   declare cctc00m25002 cursor with hold for pctc00m25002

   let l_sql = " select cpodes               "
              ,"   from iddkdominio          "
              ,"  where cponom = 'endtipcod' "
              ,"    and cpocod = ?           "
   prepare pctc00m25003 from l_sql
   declare cctc00m25003 cursor with hold for pctc00m25003

   let l_sql = " select cpodes,              "
              ,"        cpocod               "
              ,"   from iddkdominio          "
              ,"  where cponom = 'endtipcod' "
   prepare pctc00m25004 from l_sql
   declare cctc00m25004 cursor with hold for pctc00m25004

   let l_sql = " select endtipcod"
              ,"   from dpakpstend   "
              ,"  where pstcoddig = ?"
              ,"    and endtipcod = ?"
   prepare pctc00m25005 from l_sql
   declare cctc00m25005 cursor with hold for pctc00m25005


   let l_sql = " select c24lclpdrcod  "
              ,"   from dpaksocor     "
              ,"  where pstcoddig = ? "
   prepare pctc00m25006 from l_sql
   declare cctc00m25006 cursor with hold for pctc00m25006

   let l_sql = " select lgdtip         "
              ,"       ,endlgd         "
              ,"       ,lgdnum         "
              ,"       ,lgdcmp         "
              ,"       ,endcep         "
              ,"       ,endcepcmp      "
              ,"       ,endbrr         "
              ,"       ,endcid         "
              ,"       ,ufdsgl         "
              ,"   from dpakpstend     "
              ,"  where pstcoddig = ?  "
              ,"    and endtipcod = ?  "
   prepare pctc00m25007 from l_sql
   declare cctc00m25007 cursor with hold for pctc00m25007

   let l_sql = " select endtipcod     "
              ,"   from dpakpstend    "
              ,"  where pstcoddig = ? "
              ,"    and endtipcod <> ? "
   prepare pctc00m25008 from l_sql
   declare cctc00m25008 cursor with hold for pctc00m25008

   let l_sql = " select count(*)             "
              ,"   from iddkdominio          "
              ,"  where cponom = 'endtipcod' "
   prepare pctc00m25009 from l_sql
   declare cctc00m25009 cursor with hold for pctc00m25009

   let l_sql = " select endtipcod      "
              ,"       ,lgdtip         "
              ,"       ,endlgd         "
              ,"       ,lgdnum         "
              ,"       ,lgdcmp         "
              ,"       ,endcep         "
              ,"       ,endcepcmp      "
              ,"       ,endbrr         "
              ,"       ,endcid         "
              ,"       ,ufdsgl         "
              ,"       ,lclltt         "
              ,"       ,lcllgt         "
              ,"   from dpakpstend     "
              ,"  where pstcoddig = ?  "
              ,"  order by 1           "
   prepare pctc00m25010 from l_sql
   declare cctc00m25010 cursor with hold for pctc00m25010

   let l_sql = " select pstcoddig, ",
                      " nomrazsoc ",
                 " from dpaksocor ",
                " where pstcoddig = ? "
   prepare pctc00m25011 from l_sql
   declare cctc00m25011 cursor with hold for pctc00m25011

   let m_ctc00m25_prep = true

end function

#-------------------------------------------------------------------------------
function ctc00m25(l_pstcoddigChar,l_limpaArray)
#-------------------------------------------------------------------------------

   define l_pstcoddig    like dpaksocor.pstcoddig
         ,l_linha        smallint
         ,l_operacional  smallint
         ,l_msg          char(50)
         ,l_indice       smallint
         ,l_limpaArray   smallint
         ,l_qtdLinhas    smallint
         ,l_exitFor      smallint
         ,l_pstcoddigChar char(10)

   define la_ctc00m25   array[10] of record
          domtipdes      like iddkdominio.cpodes
         ,lgdtip         like dpakpstend.lgdtip        #char(10)
         ,endlgd         like dpakpstend.endlgd        #char(40)
         ,lgdnum         like dpakpstend.lgdnum        #decimal(6,0)
         ,endbrr         like dpakpstend.endbrr        #char(20)
         ,endcid         like dpakpstend.endcid        #char(20)
         ,ufdsgl         like dpakpstend.ufdsgl        #char(2)
         ,lgdcmp         like dpakpstend.lgdcmp        #char(15)
         ,endcep         like dpakpstend.endcep        #char(5)
         ,endcepcmp      like dpakpstend.endcepcmp     #char(3)
   end record

   define la_array       array[10] of record
          endtipcod      decimal(2,0)
   end record

   define lr_cab         record
          pstcoddig      like dpaksocor.pstcoddig,
          nomrazsoc      like dpaksocor.nomrazsoc
   end record

   initialize la_ctc00m25[l_indice].*
             ,la_array[l_indice].*
             ,lr_cab.* to  null

   initialize l_linha       to null
   initialize l_operacional to null
   initialize l_msg         to null
   initialize l_indice      to null
   initialize l_qtdLinhas   to null
   initialize l_exitFor     to null
   initialize l_pstcoddig   to null

   if l_limpaArray = true then
      for l_indice = 1 to 10
          initialize mr_enderecos[l_indice].*  to  null
      end for
   end if

   if m_ctc00m25_prep is null or
      m_ctc00m25_prep <> true then
      call ctc00m25_prepare()
   end if

   let m_tipo  = null
   let l_linha = 1
   let m_count = 0
   let l_operacional = 1
   let l_exitFor = false
   initialize mr_popup to null

   whenever error continue

   open cctc00m25009
   fetch cctc00m25009 into m_dominios
   close cctc00m25009

   whenever error stop

   if mr_enderecos[1].endlgd is null then
      let l_pstcoddig = l_pstcoddigChar clipped

      open cctc00m25010 using l_pstcoddig
      whenever error continue
      foreach cctc00m25010 into mr_enderecos[l_linha].endtipcod
                                ,la_ctc00m25[l_linha].lgdtip
                                ,la_ctc00m25[l_linha].endlgd
                                ,la_ctc00m25[l_linha].lgdnum
                                ,la_ctc00m25[l_linha].lgdcmp
                                ,la_ctc00m25[l_linha].endcep
                                ,la_ctc00m25[l_linha].endcepcmp
                                ,la_ctc00m25[l_linha].endbrr
                                ,la_ctc00m25[l_linha].endcid
                                ,la_ctc00m25[l_linha].ufdsgl
                                ,mr_enderecos[l_linha].lclltt
                                ,mr_enderecos[l_linha].lcllgt

         open cctc00m25003 using mr_enderecos[l_linha].endtipcod
         whenever error continue
         fetch cctc00m25003 into la_ctc00m25[l_linha].domtipdes
         whenever error stop

         let mr_enderecos[l_linha].lgdtip    = la_ctc00m25[l_linha].lgdtip
         let mr_enderecos[l_linha].endlgd    = la_ctc00m25[l_linha].endlgd
         let mr_enderecos[l_linha].lgdnum    = la_ctc00m25[l_linha].lgdnum
         let mr_enderecos[l_linha].lgdcmp    = la_ctc00m25[l_linha].lgdcmp
         let mr_enderecos[l_linha].endcep    = la_ctc00m25[l_linha].endcep
         let mr_enderecos[l_linha].endcepcmp = la_ctc00m25[l_linha].endcepcmp
         let mr_enderecos[l_linha].endbrr    = la_ctc00m25[l_linha].endbrr
         let mr_enderecos[l_linha].endcid    = la_ctc00m25[l_linha].endcid
         let mr_enderecos[l_linha].ufdsgl    = la_ctc00m25[l_linha].ufdsgl
         let mr_enderecos[l_linha].domtipdes = la_ctc00m25[l_linha].domtipdes

         if sqlca.sqlcode <> 0 then
            let l_msg = 'Problemas ao buscar o dominio do endereco!'

            for l_operacional = 1 to 10
               if mr_enderecos[l_operacional].domtipdes like "%OPERACIONAL%" then
                  exit for
               end if
            end for

            return mr_enderecos[1].*,
                   mr_enderecos[2].*,
                   mr_enderecos[3].*,
                   mr_enderecos[4].*,
                   mr_enderecos[5].*,
                   mr_enderecos[6].*,
                   mr_enderecos[7].*,
                   mr_enderecos[8].*,
                   mr_enderecos[9].*,
                   mr_enderecos[10].*,
                   l_operacional,
                   l_linha
         end if

         if la_ctc00m25[l_linha].domtipdes like "%OPERACIONAL%" then
           let l_operacional = l_linha
         end if

         let l_linha = l_linha + 1

      end foreach
   end if

   if l_linha = 1 then
      for l_indice = 1 to m_dominios

         if mr_enderecos[l_indice].lgdtip    is null or
            mr_enderecos[l_indice].endlgd    is null or
            mr_enderecos[l_indice].lgdnum    is null or
            mr_enderecos[l_indice].endcep    is null or
            mr_enderecos[l_indice].endcepcmp is null or
            mr_enderecos[l_indice].endbrr    is null or
            mr_enderecos[l_indice].endcid    is null or
            mr_enderecos[l_indice].ufdsgl    is null   then
            let l_exitFor = true
            exit for

         end if

         let la_ctc00m25[l_indice].domtipdes = mr_enderecos[l_indice].domtipdes
         let la_ctc00m25[l_indice].lgdtip    = mr_enderecos[l_indice].lgdtip
         let la_ctc00m25[l_indice].endlgd    = mr_enderecos[l_indice].endlgd
         let la_ctc00m25[l_indice].lgdnum    = mr_enderecos[l_indice].lgdnum
         let la_ctc00m25[l_indice].lgdcmp    = mr_enderecos[l_indice].lgdcmp
         let la_ctc00m25[l_indice].endcep    = mr_enderecos[l_indice].endcep
         let la_ctc00m25[l_indice].endcepcmp = mr_enderecos[l_indice].endcepcmp
         let la_ctc00m25[l_indice].endbrr    = mr_enderecos[l_indice].endbrr
         let la_ctc00m25[l_indice].endcid    = mr_enderecos[l_indice].endcid
         let la_ctc00m25[l_indice].ufdsgl    = mr_enderecos[l_indice].ufdsgl

         let l_linha = l_linha + 1
      end for
   end if

   if l_exitFor = true then
      let l_msg = 'Nao foi encontrado nenhum endereco!'
      return mr_enderecos[1].*,
             mr_enderecos[2].*,
             mr_enderecos[3].*,
             mr_enderecos[4].*,
             mr_enderecos[5].*,
             mr_enderecos[6].*,
             mr_enderecos[7].*,
             mr_enderecos[8].*,
             mr_enderecos[9].*,
             mr_enderecos[10].*,
             l_operacional,
             0
   end if

   open cctc00m25011 using l_pstcoddigChar
   fetch cctc00m25011 into lr_cab.*

   call set_count(l_linha - 1)

   open window w_ctc00m25 at 5,2 with form "ctc00m25"
        attribute (form line 1, border)

   display " (F8)Modifica  (F17)Sair"  at 19,10 attribute (reverse)

   display by name lr_cab.*

   let m_count = l_linha
   let l_qtdLinhas = l_linha - 1
   let l_exitFor = false
   while (true)
      display array la_ctc00m25 to s_ctc00m25.*

         on key (interrupt, control-c)
            let int_flag = false
            let l_exitFor = true
            exit display

         on key(f8)

            let l_linha = arr_curr()

            let mr_popup.lgdtip    = la_ctc00m25[l_linha].lgdtip
            let mr_popup.endlgd    = la_ctc00m25[l_linha].endlgd
            let mr_popup.lgdnum    = la_ctc00m25[l_linha].lgdnum
            let mr_popup.lgdcmp    = la_ctc00m25[l_linha].lgdcmp
            let mr_popup.endbrr    = la_ctc00m25[l_linha].endbrr
            let mr_popup.endcid    = la_ctc00m25[l_linha].endcid
            let mr_popup.ufdsgl    = la_ctc00m25[l_linha].ufdsgl
            let mr_popup.domtipdes = la_ctc00m25[l_linha].domtipdes
            let mr_popup.endtipcod = mr_enderecos[l_linha].endtipcod
            let mr_popup.endcep    = la_ctc00m25[l_linha].endcep
            let mr_popup.endcepcmp = la_ctc00m25[l_linha].endcepcmp

            if m_tipo <> "I" or
               m_tipo is null then

               call ctc00m25_controle("A",l_pstcoddig,false, l_linha)
               returning mr_enderecos[1].*,
                         mr_enderecos[2].*,
                         mr_enderecos[3].*,
                         mr_enderecos[4].*,
                         mr_enderecos[5].*,
                         mr_enderecos[6].*,
                         mr_enderecos[7].*,
                         mr_enderecos[8].*,
                         mr_enderecos[9].*,
                         mr_enderecos[10].*,
                         l_operacional,
                         l_qtdLinhas

               let l_linha = 1
               for l_indice = 1 to l_qtdLinhas
                  if mr_enderecos[l_indice].lgdtip    is null or
                     mr_enderecos[l_indice].endlgd    is null or
                     mr_enderecos[l_indice].lgdnum    is null or
                     mr_enderecos[l_indice].endcep    is null or
                     mr_enderecos[l_indice].endcepcmp is null or
                     mr_enderecos[l_indice].endbrr    is null or
                     mr_enderecos[l_indice].endcid    is null or
                     mr_enderecos[l_indice].ufdsgl    is null   then
                     let l_exitFor = true
                     exit for
                  end if

                  let la_ctc00m25[l_indice].domtipdes = mr_enderecos[l_indice].domtipdes
                  let la_ctc00m25[l_indice].lgdtip    = mr_enderecos[l_indice].lgdtip
                  let la_ctc00m25[l_indice].endlgd    = mr_enderecos[l_indice].endlgd
                  let la_ctc00m25[l_indice].lgdnum    = mr_enderecos[l_indice].lgdnum
                  let la_ctc00m25[l_indice].lgdcmp    = mr_enderecos[l_indice].lgdcmp
                  let la_ctc00m25[l_indice].endcep    = mr_enderecos[l_indice].endcep
                  let la_ctc00m25[l_indice].endcepcmp = mr_enderecos[l_indice].endcepcmp
                  let la_ctc00m25[l_indice].endbrr    = mr_enderecos[l_indice].endbrr
                  let la_ctc00m25[l_indice].endcid    = mr_enderecos[l_indice].endcid
                  let la_ctc00m25[l_indice].ufdsgl    = mr_enderecos[l_indice].ufdsgl

                  let l_linha = l_linha + 1
               end for
               call set_count(l_linha - 1)

               exit display
            end if
      end display
      if l_exitFor = true then
         exit while
      end if
   end while

   close window w_ctc00m25

   whenever error continue

   initialize mr_popup to null

   let m_count = m_count - 1
   open cctc00m25004
   foreach cctc00m25004 into mr_popup.domtipdes
                            ,mr_popup.endtipcod

      open cctc00m25005 using l_pstcoddig, mr_popup.endtipcod
      fetch cctc00m25005 into mr_popup.endtipcod

      let l_exitFor = false
      if sqlca.sqlcode = notfound then
          #chamando a tela de cadastro de endereco
	  for l_indice = 1 to 10
              if mr_enderecos[l_indice].endtipcod = mr_popup.endtipcod then
                 let l_exitFor = true
                 exit for
              end if
          end for

          if l_exitFor = false then
             call ctc00m25_input(l_pstcoddig)

             let l_qtdLinhas = l_qtdLinhas + 1
          end if
      end if
      close cctc00m25005
   end foreach

   let m_count = m_count + 1

   for l_indice = 1 to 10
       if mr_enderecos[l_indice].endlgd is null then
          exit for
       end if

       if mr_enderecos[l_indice].domtipdes like "%OPERACIONAL%" then
          let l_operacional = l_indice
          exit for
       end if
   end for

   return mr_enderecos[1].*,
          mr_enderecos[2].*,
          mr_enderecos[3].*,
          mr_enderecos[4].*,
          mr_enderecos[5].*,
          mr_enderecos[6].*,
          mr_enderecos[7].*,
          mr_enderecos[8].*,
          mr_enderecos[9].*,
          mr_enderecos[10].*,
          l_operacional,
          l_qtdLinhas

end function


#-------------------------------------------------------------------------------
function ctc00m25_controle(l_tipo,l_pstcoddig, l_iniarray, l_linha)
#-------------------------------------------------------------------------------

   define lr_enderecos      record
          lgdtip           like dpakpstend.lgdtip      #char(10)
         ,endlgd           like dpakpstend.endlgd      #char(40)
         ,lgdnum           like dpakpstend.lgdnum      #decimal(6,0)
         ,lgdcmp           like dpakpstend.lgdcmp      #char(15)
         ,endbrr           like dpakpstend.endbrr      #char(20)
         ,endcid           like dpakpstend.endcid      #char(20)
         ,ufdsgl           like dpakpstend.ufdsgl      #char(2)
         ,domtipdes        like iddkdominio.cpodes
         ,endtipcod        like dpakpstend.endtipcod   #decimal(2)
         ,endcep           like dpakpstend.endcep      #char(5)
         ,endcepcmp        like dpakpstend.endcepcmp   #char(3)
         ,lclltt           like dpakpstend.lclltt      #decimal(8,6)
         ,lcllgt           like dpakpstend.lcllgt      #decimal(9,6)
   end record

   define l_pstcoddig   like dpaksocor.pstcoddig
         ,l_tipo         char(1)
         ,l_result       smallint
         ,l_msg          char(50)
         ,l_iniarray     smallint
         ,l_linha        smallint
         ,l_operacional  smallint
         ,l_qtdLinha     smallint
         ,l_indice       smallint
         ,l_endtipcod    char(20)

   if m_ctc00m25_prep is null or
      m_ctc00m25_prep <> true then
      call ctc00m25_prepare()
   end if

   if l_iniarray = true then
      for l_indice = 1 to 10
          initialize mr_enderecos[l_indice].* to null
      end for
      let m_count = 0
   end if

   let l_result = null
   let l_msg    = null
   let m_tipo   = l_tipo
   let m_aux    = 0
   let l_endtipcod = 0

   if l_tipo = 'I' then
      initialize mr_popup to null

      for l_indice = 1 to 10
          if mr_enderecos[l_indice].endtipcod is not null then
             #let l_endtipcod = l_endtipcod clipped,", ",mr_enderecos[l_indice].endtipcod
             let m_count = m_count + 1
          end if
      end for

      #Seleciona todos os dominios que não foram preenchidos
      open cctc00m25002 using l_endtipcod
      foreach cctc00m25002 into mr_popup.domtipdes
                               ,mr_popup.endtipcod
         #chamando a tela de cadastro de endereco

         for l_indice = 1 to 10
            if mr_enderecos[l_indice].endtipcod = mr_popup.endtipcod then
               continue foreach
            end if
         end for

         call ctc00m25_input(l_pstcoddig)

      end foreach

      call ctc00m25(l_pstcoddig,false)
      returning mr_enderecos[1].*,
                mr_enderecos[2].*,
                mr_enderecos[3].*,
                mr_enderecos[4].*,
                mr_enderecos[5].*,
                mr_enderecos[6].*,
                mr_enderecos[7].*,
                mr_enderecos[8].*,
                mr_enderecos[9].*,
                mr_enderecos[10].*,
                l_operacional,
                l_qtdLinha
   else
      #chamando a tela de alteracao de endereco
      let m_tipo = "A"
      let l_operacional = 1

      call ctc00m25_alt_inc("A",l_pstcoddig)
      returning mr_popup.*
               ,l_result
               ,l_msg

      for l_indice = 1 to 10
          if mr_enderecos[l_indice].endlgd is null then
             exit for
          end if

          if mr_enderecos[l_indice].domtipdes like "%OPERACIONAL%" then
             let l_operacional = l_indice
          end if
      end for

      let l_qtdLinha  = l_indice - 1

      let mr_enderecos[l_linha].lgdtip    = mr_popup.lgdtip
      let mr_enderecos[l_linha].endlgd    = mr_popup.endlgd
      let mr_enderecos[l_linha].lgdnum    = mr_popup.lgdnum
      let mr_enderecos[l_linha].lgdcmp    = mr_popup.lgdcmp
      let mr_enderecos[l_linha].endbrr    = mr_popup.endbrr
      let mr_enderecos[l_linha].endcid    = mr_popup.endcid
      let mr_enderecos[l_linha].ufdsgl    = mr_popup.ufdsgl
      let mr_enderecos[l_linha].endcep    = mr_popup.endcep
      let mr_enderecos[l_linha].endcepcmp = mr_popup.endcepcmp
      let mr_enderecos[l_linha].lclltt    = mr_popup.lclltt
      let mr_enderecos[l_linha].lcllgt    = mr_popup.lcllgt

   end if

   return mr_enderecos[1].*,
          mr_enderecos[2].*,
          mr_enderecos[3].*,
          mr_enderecos[4].*,
          mr_enderecos[5].*,
          mr_enderecos[6].*,
          mr_enderecos[7].*,
          mr_enderecos[8].*,
          mr_enderecos[9].*,
          mr_enderecos[10].*,
          l_operacional,
          l_qtdLinha

end function

#-------------------------------------------------------------------------------
function ctc00m25_alt_inc(l_tipo,l_pstcoddig)
#-------------------------------------------------------------------------------

   define l_pstcoddig     like dpaksocor.pstcoddig
         ,l_tipo           char(1)
         ,l_c24lclpdrcod   like datmlcl.c24lclpdrcod
         ,l_aux            char(15)
         ,l_lgdtip_aux     char(10)
         ,l_result         smallint
         ,l_msg            char(50)
         ,l_linha          smallint
         ,l_descricao      char(100)
         ,l_status         smallint

   define lr_popup         record
          lgdtip           like dpakpstend.lgdtip      #char(10)
         ,endlgd           like dpakpstend.endlgd      #char(40)
         ,lgdnum           like dpakpstend.lgdnum      #decimal(6,0)
         ,lgdcmp           like dpakpstend.lgdcmp      #char(15)
         ,endbrr           like dpakpstend.endbrr      #char(20)
         ,endcid           like dpakpstend.endcid      #char(20)
         ,ufdsgl           like dpakpstend.ufdsgl      #char(2)
         ,domtipdes        like iddkdominio.cpodes
         ,endtipcod        like dpakpstend.endtipcod   #decimal(2)
         ,endcep           like dpakpstend.endcep      #char(5)
         ,endcepcmp        like dpakpstend.endcepcmp   #char(3)
         ,lclltt           like dpakpstend.lclltt      #decimal(8,6)
         ,lcllgt           like dpakpstend.lcllgt      #decimal(9,6)
   end record

   let lr_popup.* = mr_popup.*

   let m_tipo   = l_tipo
   let l_msg    = null
   let l_result = 0

   if m_ctc00m25_prep is null or
      m_ctc00m25_prep <> true then
      call ctc00m25_prepare()
   end if

   open window w_ctc00m25_a at 5,2 with form "ctc00m25a" #"oaltend999"
        attribute(border, form line first)

   if m_count < 2 then
      display " (F17)Sair"  at 18,10
   else
      if m_count >= 2 then
         display " (F6)Copiar Anterior  (F17)Sair"  at 18,10
      end if
   end if

   display by name mr_popup.domtipdes
   display by name mr_popup.lgdtip
   display by name mr_popup.endlgd
   display by name mr_popup.lgdnum
   display by name mr_popup.endbrr
   display by name mr_popup.endcid
   display by name mr_popup.ufdsgl
   display by name mr_popup.lgdcmp
   display by name mr_popup.endcep
   display by name mr_popup.endcepcmp

   if  l_tipo = 'A' then
       let l_descricao = 'VOCE ESTA ALTERANDO O'
   else
       let l_descricao = 'VOCE ESTA INCLUINDO O'
   end if

   display l_descricao to descricao
   let int_flag = false

   input by name  mr_popup.lgdtip
                , mr_popup.endlgd
                , mr_popup.lgdnum
                , mr_popup.endbrr
                , mr_popup.endcid
                , mr_popup.ufdsgl
                , mr_popup.lgdcmp
                , mr_popup.endcep
                , mr_popup.endcepcmp without defaults

   #Tipo de Logradouro

    before field lgdtip
           if m_aux = 1 then
              display by name mr_popup.lgdtip
              display by name mr_popup.endlgd
              display by name mr_popup.lgdnum
              display by name mr_popup.endbrr
              display by name mr_popup.endcid
              display by name mr_popup.ufdsgl
              display by name mr_popup.lgdcmp
              display by name mr_popup.endcep
              display by name mr_popup.endcepcmp
           else
              display by name mr_popup.lgdtip attribute (reverse)
           end if

    after field lgdtip
          display by name mr_popup.lgdtip attribute (normal)

          if mr_popup.lgdtip is null or
             mr_popup.lgdtip = " " then
             error 'Tipo de Logradouro exemplo: Rua, Alameda, Avenida' sleep 2
             let mr_popup.lgdtip = lr_popup.lgdtip
             next field lgdtip
          end if

   #Logradouro

    before field endlgd
           display by name mr_popup.endlgd attribute (reverse)

    after field endlgd
          display by name mr_popup.endlgd attribute (normal)

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field lgdtip
          end if

          if mr_popup.endlgd is null or
             mr_popup.endlgd = " " then
             error 'Preenchimento do Logradouro obrigatorio' sleep 2
             let mr_popup.endlgd = lr_popup.endlgd
             next field endlgd
          end if

   #Numero

    before field lgdnum
           display by name mr_popup.lgdnum attribute (reverse)

    after field lgdnum
          display by name mr_popup.lgdnum attribute (normal)

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field endlgd
          end if

          if mr_popup.lgdnum is null or
             mr_popup.lgdnum = " " then
             error 'Preenchimento do Numero obrigatorio' sleep 2
             let mr_popup.lgdnum = lr_popup.lgdnum
             next field lgdnum
          end if

   #Bairro

    before field endbrr
           display by name mr_popup.endbrr attribute (reverse)

    after field endbrr
          display by name mr_popup.endbrr attribute (normal)

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field lgdnum
          end if

          if mr_popup.endbrr is null or
             mr_popup.endbrr = " " then
             error 'Preenchimento do Bairro obrigatorio' sleep 2
             let mr_popup.endbrr = lr_popup.endbrr
             next field endbrr
          end if

   #Cidade

    before field endcid
           display by name mr_popup.endcid attribute (reverse)

    after field endcid
          display by name mr_popup.endcid attribute (normal)

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field endbrr
          end if

          if mr_popup.endcid is null or
             mr_popup.endcid = " " then
             error 'Preenchimento da Cidade obrigatorio' sleep 2
             let mr_popup.endcid = lr_popup.endcid
             next field endcid
          end if

   #Estado

    before field ufdsgl
           display by name mr_popup.ufdsgl attribute (reverse)

    after field ufdsgl
          display by name mr_popup.ufdsgl attribute (normal)

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field endcid
          end if

          if mr_popup.ufdsgl is null or
             mr_popup.ufdsgl = " " then
             error 'Preenchimento Estado obrigatorio' sleep 2
             let mr_popup.ufdsgl = lr_popup.ufdsgl
             next field ufdsgl
          end if

          # CORREÇÃO BURINI
          if not ctx25g05_existe_cid(1, # GUIA POSTAL
                                      mr_popup.ufdsgl,
                                      mr_popup.endcid) then
              error " Cidade nao cadastrada!"

              call cts06g04_oficial(mr_popup.endcid,
                                    mr_popup.ufdsgl)

                   returning l_status,
                             mr_popup.endcid,
                             mr_popup.ufdsgl

              display by name mr_popup.endcid
              display by name mr_popup.ufdsgl
              next field ufdsgl
           end if

          open cctc00m25006 using l_pstcoddig
          whenever error continue
          fetch cctc00m25006 into l_c24lclpdrcod
          whenever error stop
          if sqlca.sqlcode <> 0 and sqlca.sqlcode <> 100 then
             let l_msg = 'Error FETCH cctc00m25006 '
                         , sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
             let l_result = 1
             return mr_popup.*, l_result, l_msg
          end if

          let l_c24lclpdrcod = 1

          call ctx25g05("C"
                       ,"                       ROTEIRIZACAO DE ENDERECO"
                       ,mr_popup.ufdsgl
                       ,mr_popup.endcid
                       ,mr_popup.lgdtip
                       ,mr_popup.endlgd
                       ,mr_popup.lgdnum
                       ,mr_popup.endbrr
                       ,""
                       ,mr_popup.endcep
                       ,mr_popup.endcepcmp
                       ,mr_popup.lclltt
                       ,mr_popup.lcllgt
                       ,l_c24lclpdrcod)
           returning  l_lgdtip_aux
                     ,mr_popup.endlgd
                     ,mr_popup.lgdnum
                     ,mr_popup.endbrr
                     ,l_aux
                     ,mr_popup.endcep
                     ,mr_popup.endcepcmp
                     ,mr_popup.lclltt
                     ,mr_popup.lcllgt
                     ,l_c24lclpdrcod
                     ,mr_popup.ufdsgl
                     ,mr_popup.endcid

           call cts06g11_retira_tipo_lougradouro(mr_popup.endlgd)
                 returning mr_popup.lgdtip
                         , mr_popup.endlgd

           display by name mr_popup.lgdtip
           display by name mr_popup.endlgd
           display by name mr_popup.endcep
           display by name mr_popup.endcepcmp
           display by name mr_popup.ufdsgl
           display by name mr_popup.endcid

   #Complemento

    before field lgdcmp
           display by name mr_popup.lgdcmp attribute (reverse)

    after field lgdcmp
          display by name mr_popup.lgdcmp attribute (normal)

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field ufdsgl
          end if
   #Cep

    before field endcep
           display by name mr_popup.endcep attribute (reverse)

    after field endcep
          display by name mr_popup.endcep attribute (normal)

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field lgdcmp
          end if

          if mr_popup.endcep is null or
             mr_popup.endcep = " " then
             error 'Preenchimento Cep obrigatorio' sleep 2
             let mr_popup.endcep = lr_popup.endcep
             next field endcep
          end if

          let mr_popup.endcep = mr_popup.endcep using "&&&&&"

          display by name mr_popup.endcep attribute (normal)

   #Complemento Cep

    before field endcepcmp
           display by name mr_popup.endcepcmp attribute (reverse)

    after field endcepcmp
          display by name mr_popup.endcepcmp attribute (normal)

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field endcep
          end if

          if mr_popup.endcepcmp is null or
             mr_popup.endcepcmp = " " then
             error 'Preenchimento Complemento do Cep obrigatorio' sleep 2
             let mr_popup.endcepcmp = lr_popup.endcepcmp
             next field endcepcmp
          end if

          let mr_popup.endcepcmp = mr_popup.endcepcmp using "&&&"

          display by name mr_popup.endcepcmp attribute (normal)

    on key (interrupt,control-c)
       let int_flag = true
       let l_msg = "E obrigatorio o cadastro de todos os enderecos"
       let l_result = 1
       exit input


    #on key (f8)
    #
    #   if mr_popup.lgdtip is null or
    #      mr_popup.endlgd is null or
    #      mr_popup.lgdnum is null or
    #      mr_popup.endbrr is null or
    #      mr_popup.endcid is null or
    #      mr_popup.ufdsgl is null or
    #      mr_popup.endcep is null or
    #      mr_popup.endcepcmp is null then
    #      next field lgdtip
    #   else
    #      exit input
    #   end if

       on key (f6)

          initialize l_linha to null

          if m_count > 2 then
             call ctc00m25_popup(l_pstcoddig)
             returning l_linha
          else
             let l_linha = m_count - 1
          end if

          if l_linha > 0 then
             let mr_popup.lgdtip    = mr_enderecos[l_linha].lgdtip
             let mr_popup.endlgd    = mr_enderecos[l_linha].endlgd
             let mr_popup.lgdnum    = mr_enderecos[l_linha].lgdnum
             let mr_popup.lgdcmp    = mr_enderecos[l_linha].lgdcmp
             let mr_popup.endbrr    = mr_enderecos[l_linha].endbrr
             let mr_popup.endcid    = mr_enderecos[l_linha].endcid
             let mr_popup.ufdsgl    = mr_enderecos[l_linha].ufdsgl
             let mr_popup.endcep    = mr_enderecos[l_linha].endcep
             let mr_popup.endcepcmp = mr_enderecos[l_linha].endcepcmp
             let mr_popup.lclltt    = mr_enderecos[l_linha].lclltt
             let mr_popup.lcllgt    = mr_enderecos[l_linha].lcllgt

             display by name mr_popup.lgdtip
             display by name mr_popup.endlgd
             display by name mr_popup.lgdnum
             display by name mr_popup.endbrr
             display by name mr_popup.endcid
             display by name mr_popup.ufdsgl
             display by name mr_popup.lgdcmp
             display by name mr_popup.endcep
             display by name mr_popup.endcepcmp
          end if

          let l_msg = 'Dados Copiados com sucesso!'
          let l_result = 0
          let m_aux = 1
          next field endcepcmp

   end input

   if  l_tipo = 'A' then
       if  int_flag then
           let mr_popup.* = lr_popup.*
       end if
   end if

   close window w_ctc00m25_a

   return mr_popup.*, l_result, l_msg

end function

#-------------------------------------------------------------------------------
function ctc00m25_popup(l_pstcoddig)
#-------------------------------------------------------------------------------

   define l_pstcoddig    like dpaksocor.pstcoddig

   define la_ctc00m25   array[10] of record
          ghost          char(01),
          domtipdes      like iddkdominio.cpodes
   end record


   define la_arraypop    array[10] of record
          endtipcod      decimal(2,0)
   end record

   define l_linha         smallint
         ,l_aux_endtipcod decimal(2,0)
         ,l_indice        smallint
         ,l_ind           smallint
         ,l_flg           smallint

   initialize la_ctc00m25 to  null
   initialize la_arraypop to  null

   let l_linha = 1

   if m_ctc00m25_prep is null or
      m_ctc00m25_prep <> true then
      call ctc00m25_prepare()
   end if

   open cctc00m25008 using l_pstcoddig, mr_popup.endtipcod
   foreach cctc00m25008 into la_arraypop[l_linha].endtipcod

      open cctc00m25003 using la_arraypop[l_linha].endtipcod
      whenever error continue
      fetch cctc00m25003 into la_ctc00m25[l_linha].domtipdes
      whenever error stop

      if sqlca.sqlcode <> 0 then
         error 'Problemas ao buscar o dominio do endereco!'
         sleep 2
      end if

      let l_linha = l_linha + 1

   end foreach

      for l_indice = 1 to 10
         if mr_enderecos[l_indice].endtipcod = 0 then
            exit for
         end if

         for l_ind = 1 to 10
            if mr_enderecos[l_indice].endtipcod = la_arraypop[l_ind].endtipcod then
               let l_flg = true
               exit for
            end if

            if mr_enderecos[l_indice].endtipcod = mr_popup.endtipcod then
               let l_flg = true
               exit for
            end if

            let l_flg = false

         end for

         if l_flg = false then
            let la_ctc00m25[l_linha].domtipdes = mr_enderecos[l_indice].domtipdes
            let l_linha = l_linha + 1
         end if
      end for


   call set_count(l_linha - 1)

   open window w_ctc00m25_b at 7,20 with form "ctc00m25b"
        attribute (form line 3, border)

   display array la_ctc00m25 to s_ctc00m25.*

      on key (interrupt, control-c)
         let int_flag = false
         exit display

      on key(f8)

         let l_linha = arr_curr()
         #let l_linha = la_arraypop[l_linha].endtipcod

         exit display
   end display

   close window w_ctc00m25_b

   return l_linha

end function

#---------------------------------------------
function ctc00m25_input(l_pstcoddig)
#---------------------------------------------
 define l_result       smallint,
        l_msg          char(50),
        l_pstcoddig    like dpaksocor.pstcoddig

 #chamando a tela de cadastro de endereco

 let l_result =  0

 let m_count = m_count + 1

 call ctc00m25_alt_inc("I",l_pstcoddig)
 returning mr_popup.*
          ,l_result
          ,l_msg

 if l_result <> 0 then
    error l_msg clipped sleep 2
    let m_count = m_count - 1
 else

    error l_msg clipped sleep 2
    let mr_enderecos[m_count].lgdtip    = mr_popup.lgdtip
    let mr_enderecos[m_count].endlgd    = mr_popup.endlgd
    let mr_enderecos[m_count].lgdnum    = mr_popup.lgdnum
    let mr_enderecos[m_count].lgdcmp    = mr_popup.lgdcmp
    let mr_enderecos[m_count].endbrr    = mr_popup.endbrr
    let mr_enderecos[m_count].endcid    = mr_popup.endcid
    let mr_enderecos[m_count].ufdsgl    = mr_popup.ufdsgl
    let mr_enderecos[m_count].domtipdes = mr_popup.domtipdes
    let mr_enderecos[m_count].endtipcod = mr_popup.endtipcod
    let mr_enderecos[m_count].endcep    = mr_popup.endcep
    let mr_enderecos[m_count].endcepcmp = mr_popup.endcepcmp
    let mr_enderecos[m_count].lclltt    = mr_popup.lclltt
    let mr_enderecos[m_count].lcllgt    = mr_popup.lcllgt
 end if
 #if m_aux = 0 then
 initialize mr_popup to null
 #end if

end function

