###############################################################################
# Nome do Modulo: CTC85M00                                                    #
# Analista: Patricia Egri Wissinievski                                        #
# Data criação: 25/08/2008                                                    #
#                                                                             #
# Objetivo: Tela para Consulta de valores de RV                               #
#                                                                             #
# PSI - 228087 RV NO INFORMIX - Técnico Atendimento.                           #
#                                                                             #
###############################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"


#-------------------------------------------------------------------------------
function ctc85m00()
#-------------------------------------------------------------------------------
     define r_dacmrmv record 
          sprdes                   like dacmrmv.sprdes,
          grndes                   like dacmrmv.grndes,
          cnddes                   like dacmrmv.cnddes,
          funmat                   like dacmrmv.funmat,
          cptmes                   like dacmrmv.cptmes,
          cptano                   like dacmrmv.cptano,
          atuaredes                like dacmrmv.atuaredes,
          gnhtotvlr                like dacmrmv.gnhtotvlr,
          gnhanovlr                like dacmrmv.gnhanovlr,
          avlqstprides             like dacmrmv.avlqstprides,
          avlqstpriatgper          like dacmrmv.avlqstpriatgper,
          avlqstprignhvlr          like dacmrmv.avlqstprignhvlr,
          avlqstsegdes             like dacmrmv.avlqstsegdes,
          avlqstsegatgper          like dacmrmv.avlqstsegatgper,
          avlqstgnhvlr             like dacmrmv.avlqstgnhvlr,
          avlqstterdes             like dacmrmv.avlqstterdes,
          avlqstteratgper          like dacmrmv.avlqstteratgper,
          avlqsttergnhvlr          like dacmrmv.avlqsttergnhvlr,
          avlqstquades             like dacmrmv.avlqstquades,
          avlqstquaatgper          like dacmrmv.avlqstquaatgper,
          avlqstquagnhvlr          like dacmrmv.avlqstquagnhvlr,
          avlqstgnhmaxvlr          like dacmrmv.avlqstgnhmaxvlr,
          nome                     like isskfunc.funnom,
          avlqstgnhmaxvlr2         char(17),
          avlqstgnhmaxvlr3         char(17),
          avlqstgnhmaxvlr4         char(17)
     end record
     
     define tempaux char(5)
     define l_comando   char(400)
     define l_cmd       char(500)
     define l_mesatu    char(2)
     define l_anoatu    char(4)
     define l_datatual  date

     let l_cmd = " select cptmes, cptano, gnhtotvlr ",
               "  from dacmrmv ",
               " where cptano = ? ",
               "   and funmat = ? ",
               "   and empcod = ? ",
               "   and usrtip = ? "
               
     prepare pctc85m00001 from l_cmd
     declare cctc85m00001 cursor for pctc85m00001
     
     let l_datatual = current
     let l_mesatu = month(l_datatual)
     let l_anoatu = year(l_datatual)
     
     if l_mesatu < 10 then
        let l_mesatu = "0" , l_mesatu clipped
     end if     


     initialize r_dacmrmv.* to null
     
     select  sprdes
            ,grndes
            ,cnddes
            ,funmat
            ,cptmes
            ,cptano
            ,atuaredes
            ,gnhtotvlr
            ,gnhanovlr
            ,avlqstprides
            ,avlqstpriatgper
            ,avlqstprignhvlr
            ,avlqstsegdes
            ,avlqstsegatgper
            ,avlqstgnhvlr
            ,avlqstterdes
            ,avlqstteratgper
            ,avlqsttergnhvlr
            ,avlqstquades
            ,avlqstquaatgper
            ,avlqstquagnhvlr
            ,avlqstgnhmaxvlr
       into  r_dacmrmv.sprdes
            ,r_dacmrmv.grndes
            ,r_dacmrmv.cnddes
            ,r_dacmrmv.funmat
            ,r_dacmrmv.cptmes
            ,r_dacmrmv.cptano
            ,r_dacmrmv.atuaredes
            ,r_dacmrmv.gnhtotvlr
            ,r_dacmrmv.gnhanovlr
            ,r_dacmrmv.avlqstprides
            ,r_dacmrmv.avlqstpriatgper
            ,r_dacmrmv.avlqstprignhvlr
            ,r_dacmrmv.avlqstsegdes
            ,r_dacmrmv.avlqstsegatgper
            ,r_dacmrmv.avlqstgnhvlr
            ,r_dacmrmv.avlqstterdes
            ,r_dacmrmv.avlqstteratgper
            ,r_dacmrmv.avlqsttergnhvlr
            ,r_dacmrmv.avlqstquades
            ,r_dacmrmv.avlqstquaatgper
            ,r_dacmrmv.avlqstquagnhvlr
            ,r_dacmrmv.avlqstgnhmaxvlr 
       from dacmrmv
      where funmat = g_issk.funmat 
        and empcod = g_issk.empcod
        and usrtip = g_issk.usrtip
        and cptmes = l_mesatu
        and cptano = l_anoatu
        
     open window ctc85m00 at 04,02 with form "ctc85m00"
          attribute(form line first, prompt line last)
     
     select funnom into r_dacmrmv.nome  
       from isskfunc
      where isskfunc.funmat = g_issk.funmat
        and isskfunc.empcod = g_issk.empcod
        and isskfunc.usrtip = g_issk.usrtip
     
     let r_dacmrmv.avlqstgnhmaxvlr2 = r_dacmrmv.avlqstgnhmaxvlr using '##,###,###,###.##'  
     let r_dacmrmv.avlqstgnhmaxvlr3 = r_dacmrmv.avlqstgnhmaxvlr using '##,###,###,###.##' 
     let r_dacmrmv.avlqstgnhmaxvlr4 = r_dacmrmv.avlqstgnhmaxvlr using '##,###,###,###.##' 

     display by name r_dacmrmv.* 
     
     # controle para disparo da popup 
     while true
          let int_flag = false

          prompt "" for char tempaux
          on key (f10)
               call ctc85m00_pop(l_anoatu)
               let int_flag = false
          end prompt
          
          if int_flag then
             let int_flag = false
             exit while
          end if
     end while     

     return     
end function


# -----------------------------------------------------------------------------     
 function ctc85m00_pop(l_anoatu)
# -----------------------------------------------------------------------------     
# ctc85m00_pop() - Dispara pop-up com meses para consulta de meses anteriores

     define l_anoatu    char(4)
     define l_mesatu    int
     define l_datatu    date
     define l_mesaux    int
     define tempaux char(4)
     define l_acuval    char(17)
     
     define l_i int
     
     define a_dacmrmv array[12] of record
          cptmes                   like dacmrmv.cptmes,
          cptano                   like dacmrmv.cptano,
          gnhtotvlr                like dacmrmv.gnhtotvlr
     end record


     open window ctc85m00a at 12,01 with form "ctc85m00a"
          attribute(form line first)

     let l_datatu = current
     let l_mesatu = month(l_datatu)
     
     open cctc85m00001 using l_anoatu,
                             g_issk.funmat,
                             g_issk.empcod, 
                             g_issk.usrtip
                               
     let l_i = 1
     foreach cctc85m00001 into a_dacmrmv[l_i].*
          let l_mesaux = a_dacmrmv[l_i].cptmes
          let l_acuval = a_dacmrmv[l_i].gnhtotvlr using '#,###,###,###.##'
          
          if l_mesaux < l_mesatu then
               case
                    when l_mesaux = 1
                         display l_acuval to jan
                    when l_mesaux = 2
                         display l_acuval to fev
                    when l_mesaux = 3
                         display l_acuval to mar
                    when l_mesaux = 4
                         display l_acuval to abr
                    when l_mesaux = 5
                         display l_acuval to mai
                    when l_mesaux = 6
                         display l_acuval to jun
                    when l_mesaux = 7
                         display l_acuval to jul
                    when l_mesaux = 8
                         display l_acuval to ago
                    when l_mesaux = 9
                         display l_acuval to set
                    when l_mesaux = 10
                         display l_acuval to out
                    when l_mesaux = 11
                         display l_acuval to nov
                    when l_mesaux = 12
                         display l_acuval to dez
               end case
          end if
          
          let l_i = l_i + 1
     end foreach
     
     prompt "" for char tempaux

     close window ctc85m00a
     
     return     
end function 

