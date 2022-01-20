#---------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                           #
#.......................................................................... #
# Sistema........: CT24H                                                    #
# Modulo         : CTS21m11                                                 #
#                  Listar Coberturas/Naturezas de Sinistro RE               #
# Analista Resp. : Priscila Staingel                                        #
# PSI            : 200140                                                   #
#.......................................................................... #
#                        * * * A L T E R A C A O * * *                      #
#---------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

   define m_prep_sql   smallint
   define am_cts21m11  array[50] of record
          cbttip     like datrpedvistnatcob.cbttip,   #codigo da cobertura
          cbttipnom  like rgpktipcob.cbttipnom,       #descricao da cobertura
          sinntzcod  like datrpedvistnatcob.sinntzcod,#codigo da natureza
          sinntzdes  like sgaknatur.sinntzdes,        #descricao da natureza
          orcvlr     like datrpedvistnatcob.orcvlr    #valor
   end record
   define m_count smallint

#----------------------------#
 function cts21m11_prepara()
#----------------------------#

   define l_sqlstmt  char(500)
   let l_sqlstmt = "select cbttip, sinntzcod, orcvlr "
                  ," from datrpedvistnatcob "
                  ," where sinvstnum = ?    "
                  ,"   and sinvstano = ?    "
   prepare pcts21m11001 from l_sqlstmt
   declare ccts21m11001 cursor for pcts21m11001

   let l_sqlstmt = "select sinntzcod, orcvlr "
                  ," from datmpedvist        "
                  ," where sinvstnum = ?     "
                  ,"   and sinvstano = ?     "
   prepare pcts21m11002 from l_sqlstmt
   declare ccts21m11002 cursor for pcts21m11002

   let m_prep_sql = true

 end function


#---------------------#
 function cts21m11(param)
#----------------------#
 define param   record
    sinvstnum   like datrpedvistnatcob.sinvstnum ,
    sinvstano   like datrpedvistnatcob.sinvstano
 end record

 initialize am_cts21m11 to null

 if m_prep_sql <> true then
    call cts21m11_prepara();
 end if

 let m_count = 1

 #carregar dados no array
 open ccts21m11001 using param.sinvstnum,
                         param.sinvstano

 foreach ccts21m11001 into am_cts21m11[m_count].cbttip    ,
                           am_cts21m11[m_count].sinntzcod ,
                           am_cts21m11[m_count].orcvlr
          #buscar descricao cobertura
          call fsrec780_retornar_descricao(am_cts21m11[m_count].cbttip,
                                           "cobertura" )
               returning am_cts21m11[m_count].cbttipnom

          #buscar descricao natureza
          call fsrec780_retornar_descricao(am_cts21m11[m_count].sinntzcod,
                                           "natureza" )
               returning am_cts21m11[m_count].sinntzdes
          let m_count = m_count + 1
 end foreach

 #Se nao encontrou registro em datrpedvistnatcob
 # buscar natureza e valor de datmpedvist, pois apenas os servicos feitos
 # apos a implantacao terao cobertura/natureza e valor na tabela nova
 # (datrpedvistnatcob), qualquer laudo preenchido anterior a implantacao
 # nao tem a informacao da cobertura, mas tem natureza e valor em datmpedvist
 #30 dias apos a implantacao em producao devemos verificar se existe valor
 # diferente de 0 nos campos sinntzcod, sinramgrp e orcvlr da datmpedivist
 # caso nao exista, significa que todos os laudos presentes na tabela ja
 # foram feitos apos a implantacao, entao iremos dropar esses campos da tabela
 # e alterar fonte para tratamento
 if m_count = 1 then   #Se nao encontrou registro em datrpedvistnatcob
     open ccts21m11002 using param.sinvstnum,
                             param.sinvstano
     fetch ccts21m11002 into am_cts21m11[m_count].sinntzcod,
                             am_cts21m11[m_count].orcvlr
     if sqlca.sqlcode <> 0 then
        error "Problemas ao buscar natureza em datmpedvist. AVISE A INFORMATICA"
        return
     end if
     #Buscar descricao natureza
     call fsrec780_retornar_descricao(am_cts21m11[m_count].sinntzcod,
                                     "natureza" )
         returning am_cts21m11[m_count].sinntzdes
 end if

 call cts21m11_display(param.sinvstnum,
                       param.sinvstano)

 end function


#--------------------------#
 function cts21m11_display(param)
#--------------------------#
 define param   record
    sinvstnum   like datrpedvistnatcob.sinvstnum ,
    sinvstano   like datrpedvistnatcob.sinvstano
 end record

 define vistoria char (11)
 let vistoria = F_FUNDIGIT_INTTOSTR(param.sinvstnum,6) , "-",
                              param.sinvstano

 call set_count(m_count)

 open window w_cts21m11 at 04,02 with form 'cts21m11'

   message "(F17)Abandona"

   display by name vistoria

   display array am_cts21m11 to s_cts21m11.*

     on key(control-c,f17,interrupt)
        exit display

   end display
 close window w_cts21m11

 end function

