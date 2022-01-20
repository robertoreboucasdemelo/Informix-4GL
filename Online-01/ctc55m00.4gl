###############################################################################
#                      PORTO SEGURO CIA DE SEGUROS GERAIS
#
# Sistema : ct24hs
# Programa:
# Modulo  : ctc55m00
#
# Objetivo: Controle de atendimentos para RAMO RE
#
# Analista Responsavel: Ruiz
# Programador         : Paula Romanini
# Data da Criacao     : 25/03/2001 - Fabrica de Software
# PSI                 : 149969
#
# Alteracoes:
#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
##############################################################################
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
#23/10/2003   Eduardo-Meta   psi168890 Incluir campo Modalidade e Gru-#
#                            osf 27847 -po de problema.               #
#---------------------------------------------------------------------#
#22/09/2006   Ruiz           psi202720 Inclusao do ramo saudo         #
#---------------------------------------------------------------------#
#17/08/2007  Ana Raquel,Meta PSI211915 Inclusao de Union na entidade  #
#                                      rgfkmrsapccls                  #
#---------------------------------------------------------------------#
#25/02/2013 Humberto - Alteração do parametro de exibição de naturezas#
#---------------------------------------------------------------------#

  globals "/homedsa/projetos/geral/globals/glct.4gl"

  define l_campos record
    ramcod    like datrsocntzsrvre.ramcod,
    ramnom    like gtakram.ramnom,
    rmemdlcod like gtakmodal.rmemdlcod, #psi168890 eduardo - meta
    rmemdlnom like gtakmodal.rmemdlnom, #psi168890 eduardo - meta
    clscod    like datrramcls.clscod,
    clsdes    like aackcls.clsdes,
    atdqtd    like datrsocntzsrvre.ntzatdqtd,
    tabnum    like itatvig.tabnum
  end record

  define a_ctc55m00 array[200] of record
    socntzcod       like  datrsocntzsrvre.socntzcod,
    socntzdes       like  datksocntz.socntzdes,
    ntzatdqtd       like  datrsocntzsrvre.ntzatdqtd,
    ghost           char(1),
    c24pbmgrpdes    like  datkpbmgrp.c24pbmgrpdes,
    c24pbmgrpcod    like  datkpbmgrp.c24pbmgrpcod
  end record

  define l_sim   char(01)
  #define l_tem   char(01)
  define l_count integer

  define m_prepara_sql     smallint   #psi168890 eduardo - meta

#---------------------------------
# MAIN (REMOVER)
#---------------------------------
#main
#options
#  prompt line last
#  defer interrupt
#  call ctc55m00()
#end main
#
#------------------------------------------------------------------------------#
function ctc55m00()   # Menu
#------------------------------------------------------------------------------#


 open window s_ctc55m00 at 4,2 with form "ctc55m00"
      attribute(message line last, comment line last -1)

      #inicio psi168890 eduardo - meta
      if m_prepara_sql is null or
         m_prepara_sql <> true then
         call ctc55m00_prep()
      end if
      #fim psi168890 eduardo - meta

      menu "RAMO x NATUREZA"

           command key ("S") "Seleciona" "Seleciona Atendimento"
              call ctc55m00_seleciona()

           command key ("P") "Proximo" "Seleciona Proximo Atendimento"
              call ctc55m00_mostra(1)

           command key ("A") "Anterior" "Seleciona Atendimento Anterior"
              call ctc55m00_mostra(-1)

           command key ("M") "Modifica" "Modifica Atendimento"
             if l_campos.ramcod is not null then
                call ctc55m00_inclui("a")
             else
                error " Nenhuma linha selecionada "
                next option "Seleciona"
             end if

           command key ("I") "Inclui" "Inclui Atendimento"
                clear form
                call ctc55m00_inclui("i")

           command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
              exit menu
      end menu

 close window s_ctc55m00
end function

#-----------------------------------------------------------------------------#
function ctc55m00_prep()   #PREPARANDO COMANDOS SQL
#-----------------------------------------------------------------------------#

  define l_comando    char(600)


  let l_comando = " select clsdes       ",
                  " from rgfkclaus2     ",
                  " where clscod = ?    ",
                    " and ramcod = ?    ",
                    " and rmemdlcod = ? ",
                    " union             ",
                  " select clsdes       ",
                  " from rgfkmrsapccls  ",
                  " where clscod    = ? ",
                    " and ramcod    = ? ",
                    " and rmemdlcod = ? "

  prepare p_ctc55m00001 from l_comando
  declare c_ctc55m00001 cursor for p_ctc55m00001

  let l_comando = "select unique ramcod,rmemdlcod, clscod, clsatdqtd ",
                  "  from datrramcls ",
                  "order by 1,2,3,4  "  #psi198890 eduardo - meta
  prepare p_ctc55m00002 from l_comando
  declare c_ctc55m00002 scroll cursor with hold for p_ctc55m00002

  let l_comando = " select socntzcod, ntzatdqtd, c24pbmgrpcod ",
                  "   from datrsocntzsrvre      ",
                  "  where ramcod = ?           ",
                  "    and rmemdlcod = ?        ", #psi168890 eduardo - meta
                  "    and clscod = ?           ",
                  " order by 1                  "
  prepare p_ctc55m00004 from l_comando
  declare c_ctc55m00004 cursor for p_ctc55m00004

  let l_comando = " select socntzdes     ",
                  "   from datksocntz    ",
                  "  where socntzcod = ? "
  prepare p_ctc55m00005 from l_comando
  declare c_ctc55m00005 cursor for p_ctc55m00005

  let l_comando = " select clscod    ",
                  " from datrramcls  ",
                  " where ramcod = ? ",
                  "   and clscod > '0' "
  prepare p_ctc55m00006 from l_comando
  declare c_ctc55m00006 cursor for p_ctc55m00006

  let l_comando = " select clscod, clsdes ",
                  " from aackcls          ",
                  " where tabnum  = ?     ",
                  "   and ramcod  = ?     ",
                  "   and clscod  = ?     "
  prepare p_ctc55m00007 from l_comando
  declare c_ctc55m00007 cursor for p_ctc55m00007

  let l_comando = " select clscod, clsdes ",
                  " from aackcls          ",
                  " where ramcod  = ?     ",
                  "   and clscod >= ?     "
  prepare p_ctc55m00008 from l_comando
  declare c_ctc55m00008 cursor for p_ctc55m00008

#inicio psi168890 eduardo - meta
#---------------------------
  let l_comando = ' select rmemdlnom ',
                    ' from gtakmodal ',
                   ' where ramcod = ? ',
                     ' and rmemdlcod = ? ',
                     ' and empcod = 1 '

  prepare pctc55m00009 from l_comando
  declare cctc55m00009 cursor for pctc55m00009
#---------------------------

  let l_comando = ' insert into datrramcls (ramcod, ',
                                          ' clscod, ',
                                          ' rmemdlcod, ',
                                          ' clsatdqtd) ',
                                   ' values (?,?,?,?) '

  prepare pctc55m00010 from l_comando
#---------------------------

  let l_comando = ' select a.srvtipabvdes ',
                    ' from datksrvtip a, datkpbmgrp b ',
                   ' where b.c24pbmgrpcod = ? ',
                   '   and b.atdsrvorg = a.atdsrvorg ',
                   '   and b.c24pbmgrpstt <> "C" '

  prepare pctc55m00011 from l_comando
  declare cctc55m00011 cursor for pctc55m00011
#---------------------------
  let l_comando = ' select count(*) ',
                    ' from datrsocntzsrvre ',
                   ' where ramcod    = ? ',
                     ' and clscod    = ? ',
                     ' and socntzcod = ? ',
                     ' and rmemdlcod = ?'

  prepare pctc55m00012 from l_comando
  declare cctc55m00012 cursor for pctc55m00012
#---------------------------

  let l_comando = ' insert into datrsocntzsrvre (socntzcod, ',
                                               ' ramcod, ',
                                               ' clscod, ',
                                               ' ntzatdqtd, ',
                                               ' rmemdlcod, ',
                                               ' c24pbmgrpcod) ',
                                       ' values ( ?,?,?,?,?,?) '

  prepare pctc55m00013 from l_comando
#---------------------------

  let l_comando = ' update datrsocntzsrvre ',
                     ' set ntzatdqtd = ?, ',
                         ' c24pbmgrpcod = ? ',
                   ' where socntzcod = ? ',
                     ' and ramcod = ? ',
                     ' and clscod = ? '

  prepare pctc55m00014 from l_comando
#---------------------------

  let l_comando = ' delete from datrsocntzsrvre ',
                   ' where socntzcod = ? ',
                     ' and ramcod    = ? ',
                     ' and clscod    = ? ',
                     ' and rmemdlcod = ? '

  prepare pctc55m00015 from l_comando
#---------------------------

  let l_comando = 'select c24pbmgrpdes ',
                  '  from datkpbmgrp ',
                  ' where c24pbmgrpcod = ? ',
                  '   and datkpbmgrp.c24pbmgrpstt <> "C" '

  prepare pctc55m00016 from l_comando
  declare cctc55m00016 cursor for pctc55m00016
#---------------------------

  let l_comando = ' select ramnom, ramgrpcod ',
                    ' from gtakram ',
                   ' where ramcod = ? ',
                    '  and empcod = 1 '

  prepare pctc55m00017 from l_comando
  declare cctc55m00017 cursor for pctc55m00017
#---------------------------
  let l_comando = ' select plncod,plndes ',
                    ' from datkplnsau ',
                   ' where plncod = ? '

  prepare pctc55m00018 from l_comando
  declare cctc55m00018 cursor for pctc55m00018
#---------------------------

 let m_prepara_sql = true
#fim psi168890 eduardo - meta

end function

#-----------------------------------------------------------------------------#
function ctc55m00_seleciona() # Carrega input
#-----------------------------------------------------------------------------#

  define l_ramgrpcod  like gtakram.ramgrpcod
  define l_comando    char(600)

  initialize l_campos.* to null
  initialize l_comando  to null

  clear form
  let int_flag = false
  #---------------------------
  #Inicio INPUT BY NAME
  #---------------------------
  input by name l_campos.ramcod,
                l_campos.rmemdlcod,
                l_campos.clscod without defaults

        before field ramcod
           display by name l_campos.ramcod attribute(reverse)

        after  field ramcod
           if l_campos.ramcod is null then
              error "Informe o Ramo."
              next field ramcod
           end if
           display by name l_campos.ramcod

           #------------------------------
           # Acessando a tabela DATRRAMCLS
           #------------------------------
           whenever error continue
           select count(*)
             into l_count
             from datrramcls
            where ramcod = l_campos.ramcod
           whenever error stop
          if l_count = 0 then
             error "Ramo nao cadastrado."
             next field ramcod
          end if
          whenever error continue
          select ramnom, ramgrpcod
            into l_campos.ramnom, l_ramgrpcod
            from gtakram
           where ramcod = l_campos.ramcod
             and empcod = 1

          whenever error stop
          if sqlca.sqlcode < 0 then
             error "Erro ao acessar a tabela gtakram, erro = ",
                    sqlca.sqlcode
              sleep 2
              exit program
          end if
          if sqlca.sqlcode = 0 then
             display by name l_campos.ramnom
          end if

        #inicio psi118890 eduardo - meta
        before field rmemdlcod
           display by name l_campos.rmemdlcod attribute(reverse)

        after field rmemdlcod
           display by name l_campos.rmemdlcod

           open cctc55m00009 using l_campos.ramcod,
                                   l_campos.rmemdlcod

           whenever error continue
           fetch cctc55m00009 into l_campos.rmemdlnom
           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode = 100 then
                 error 'Modalidade (2) nao encontrada!Informe novamente.'sleep 2
                 next field rmemdlcod
              else
                 error 'Erro Select(2) cctc55m00009: ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
                 error 'ctc55m00_inclui','/',l_campos.ramcod,'/',l_campos.rmemdlcod,'/ 1.' sleep 2
                 let int_flag = true
                 exit input
              end if
           end if

           display by name l_campos.rmemdlcod
           display by name l_campos.rmemdlnom


        #fim psi118890 eduardo - meta

        before field clscod
           display by name l_campos.clscod attribute(reverse)

        after  field clscod
           display by name l_campos.clscod
           if l_campos.clscod is null then
              let l_campos.clscod = "0"
           end if
           if l_campos.clscod >  "0" then
              whenever error continue
              select count(*)
                into l_count
                from datrramcls
               where clscod = l_campos.clscod
                 and ramcod = l_campos.ramcod
              whenever error stop
              if l_count = 0 then
                 error "Registro nao cadastrado."
                 next field clscod
              end if
           end if
           if l_campos.clscod = "0" then
              open c_ctc55m00006 using l_campos.ramcod
              fetch c_ctc55m00006 into l_campos.clscod
           end if
           if l_ramgrpcod = 1 then
              whenever error continue
              if g_issk.funmat = 601566 then
                 display "ramcod/clscod=", l_campos.ramcod," ",l_campos.clscod
              end if
              let l_campos.tabnum = F_FUNGERAL_TABNUM("aackcls", today)
              open c_ctc55m00007 using l_campos.tabnum,
                                       l_campos.ramcod,
                                       l_campos.clscod
              whenever error stop
              if sqlca.sqlcode < 0 then
                 error "Erro ao acessar a tabela aackcls, erro = ",
                       sqlca.sqlcode
                 sleep 2
                 exit program
              end if
              whenever error continue
              fetch c_ctc55m00007 into l_campos.clscod,
                                       l_campos.clsdes
              if g_issk.funmat = 601566 then
                 display "ramcod/clscod1=", l_campos.ramcod," ",l_campos.clscod
              end if

              whenever error stop
              if sqlca.sqlcode < 0 then
                 error "Erro ao acessar a tabela aackcls, erro = ",
                       sqlca.sqlcode
                 sleep 2
                 exit program
              end if
              if sqlca.sqlcode <> 0 then
                 let l_campos.clscod = " "
                error "Clausula nao cadastrada.",l_campos.clscod," ",l_ramgrpcod
                 next field clscod
              end if
           end if
           if l_ramgrpcod =  5 then    # saude
              whenever error continue
              if g_issk.funmat = 601566 then
                 display "ramcod/clscod=", l_campos.ramcod," ",l_campos.clscod
              end if
              open cctc55m00018  using l_campos.clscod
              whenever error stop
              if sqlca.sqlcode < 0 then
                 error "Erro ao acessar a tabela datkplnsau, erro = ",
                       sqlca.sqlcode
                 sleep 2
                 exit program
              end if
              whenever error continue
              fetch cctc55m00018  into l_campos.clscod,
                                       l_campos.clsdes
              if g_issk.funmat = 601566 then
                 display "ramcod/clscod1=", l_campos.ramcod," ",l_campos.clscod
              end if

              whenever error stop
              if sqlca.sqlcode < 0 then
                 error "Erro ao acessar a tabela datkplnsau, erro = ",
                       sqlca.sqlcode
                 sleep 2
                 exit program
              end if
              if sqlca.sqlcode <> 0 then
                 let l_campos.clscod = " "
                error "Clausula nao cadastrada.",l_campos.clscod," ",l_ramgrpcod
                 next field clscod
              end if
           end if
           if l_ramgrpcod <> 1 and
              l_ramgrpcod <> 5 then
              whenever error continue
              open c_ctc55m00001 using l_campos.clscod,
                                       l_campos.ramcod,
                                       l_campos.rmemdlcod,
                                       l_campos.clscod,
                                       l_campos.ramcod,
                                       l_campos.rmemdlcod
              fetch c_ctc55m00001 into l_campos.clsdes
              whenever error stop
              if sqlca.sqlcode < 0 then
                 error "Erro ao acessar a tabela rgfkclaus2, erro = ",
                       sqlca.sqlcode
                 sleep 2
                 exit program
              end if
              if sqlca.sqlcode <> 0 then
                 let l_campos.clscod = " "
                 error "Clausula nao cadastrada.."
                 next field clscod
              end if
           end if
           display by name l_campos.clscod
           display by name l_campos.clsdes
           #--------------------------------
           # Selecionando a qtd. Atend.
           #--------------------------------
           whenever error continue
           select clsatdqtd
             into l_campos.atdqtd
             from datrramcls
            where ramcod = l_campos.ramcod
              and clscod = l_campos.clscod
           whenever error stop
           if sqlca.sqlcode < 0 then
              error "Erro ao acessar a tabela datrramcls, erro = ",
                     sqlca.sqlcode
              sleep 2
              exit program
           end if
           if l_campos.atdqtd is null then
              let l_campos.atdqtd = 0
           end if
           display by name l_campos.atdqtd

           on key(interrupt, control-c)
              exit input
  end input
  if int_flag then
     let int_flag = false
  else
     if l_campos.ramcod is not null and
        l_campos.ramcod <> 0        then

        call ctc55m00_abre(l_campos.ramcod,
                           l_campos.rmemdlcod,
                           l_campos.clscod,
                           l_campos.atdqtd)#psi168890 eduardo - meta
     end if
  end if
  return
end function

#-----------------------------------------------------------------------------#
function ctc55m00_abre(l_param) # NAVEGAR: ANTERIOR/POSTERIOR
#-----------------------------------------------------------------------------#
 define l_param   record
        ramcod    like datrsocntzsrvre.ramcod,
        rmemdlcod like datrsocntzsrvre.rmemdlcod, #psi168890 eduardo - meta
        clscod    like datrsocntzsrvre.clscod,
        atdqtd    like datrsocntzsrvre.ntzatdqtd
 end record
 define l_aux     record
        ramcod    like datrsocntzsrvre.ramcod,
        rmemdlcod like datrsocntzsrvre.rmemdlcod,  #psi168890 eduardo - meta
        clscod    like datrsocntzsrvre.clscod,
        atdqtd    like datrsocntzsrvre.ntzatdqtd
 end record
 define l_comando char(500)
 define l_sim     char(01)

 define l_erro  smallint #psi168890 eduardo - meta

 let l_erro = false
 let l_sim = "n"

 #------  LOCALIZAR REGISTRO CONF PARAMETRO ------

     #----------------------------------
     #Utilizando o cursor c_ctc55m00002
     #----------------------------------
     open c_ctc55m00002

     while true
        whenever error continue
        fetch c_ctc55m00002 into l_aux.ramcod,
                                 l_aux.rmemdlcod, #psi168890 eduardo - meta
                                 l_aux.clscod,
                                 l_aux.atdqtd
        whenever error stop
        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = 100 then
              initialize l_campos.* to null
              exit while
           else
              error 'Erro Select c_ctc55m00002: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
              error 'ctc55m00_abre','/',l_aux.ramcod,'/',l_aux.rmemdlcod,'/',l_aux.clscod,'/',l_aux.atdqtd,'.' sleep 2
              let l_erro = true
              exit while
           end if
        end if
        if l_param.ramcod = l_aux.ramcod and
           l_param.rmemdlcod = l_aux.rmemdlcod and #psi168890 eduardo - meta
           l_param.clscod = l_aux.clscod and
           l_param.atdqtd = l_aux.atdqtd then
           let l_sim = "s"
           exit while
        end if

     end while

 if l_erro = false then
    if l_sim = "s" then
       call ctc55m00_exibe(l_param.*,l_sim)
    else
       error "Nenhuma informacao foi encontrada!"
    end if
 else
    let l_erro = false
 end if
 return
end function
#-----------------------------------------------------------------------------#
function ctc55m00_exibe(l_param,l_sim)  # EXIBE DADOS DO ARRAY
#-----------------------------------------------------------------------------#
 define l_param   record
        ramcod    like datrsocntzsrvre.ramcod,
        rmemdlcod like datrsocntzsrvre.rmemdlcod, #psi168890 eduardo - meta
        clscod    like datrsocntzsrvre.clscod,
        atdqtd    like datrsocntzsrvre.ntzatdqtd
 end record

 define i       smallint
 define l_linha integer
 define l_sim   char(1)
 define l_erro  smallint #psi168890 eduardo - meta
 define l_descr char(10) #psi168890 eduardo - meta

 initialize a_ctc55m00 to null

 let i       = 1
 let l_erro = false
 #let l_linha = 10 #numero de linha da tela

 #----------------------------------
 # Inicio do foreach (carrega array)
 #------------------------------
 open c_ctc55m00004 using l_param.ramcod,
                          l_param.rmemdlcod,
                          l_param.clscod

 foreach c_ctc55m00004 into a_ctc55m00[i].socntzcod,
                            a_ctc55m00[i].ntzatdqtd,
                            a_ctc55m00[i].c24pbmgrpcod   #psi168890 eduardo - meta
        #if a_ctc55m00[i].ntzatdqtd is null or
        #   a_ctc55m00[i].ntzatdqtd =  0    then
        #   continue foreach
        #end if
         open c_ctc55m00005 using a_ctc55m00[i].socntzcod
         fetch c_ctc55m00005 into a_ctc55m00[i].socntzdes

         #inicio psi168890 eduardo - meta
         open cctc55m00016 using a_ctc55m00[i].c24pbmgrpcod

         whenever error continue
         fetch cctc55m00016 into a_ctc55m00[i].c24pbmgrpdes
         whenever error stop
         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = 100 then
               let a_ctc55m00[i].c24pbmgrpdes = ''
            else
               error 'Erro Select cctc55m00016: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
               error 'ctc55m00_exibe','/',a_ctc55m00[i].c24pbmgrpcod,'.' sleep 2
               let l_erro = true
               exit foreach
            end if
         end if

         open cctc55m00011 using a_ctc55m00[i].c24pbmgrpcod

         whenever error continue
         fetch cctc55m00011 into l_descr
         whenever error stop
         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = 100 then
               let l_descr = ''
            else
               error 'Erro Select (2) cctc55m00011: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
               error 'ctc55m00_input','/',a_ctc55m00[i].c24pbmgrpcod,'/','C.' sleep 2
               clear form
               let int_flag = true
               exit foreach
            end if
         end if

         if a_ctc55m00[i].c24pbmgrpdes is not null or
            l_descr is not null                    then
            let a_ctc55m00[i].c24pbmgrpdes = a_ctc55m00[i].c24pbmgrpdes clipped ,' / ',l_descr clipped
         end if
         #fim psi168890 eduardo - meta

         let a_ctc55m00[i].ghost = '*'
         let i = i + 1
 end foreach

 #inicio psi168890 eduardo - meta
 if l_erro then
    let l_erro = false
    return
 end if
 #fim psi168890 eduardo - meta

 call set_count(i)
 if i = 1 then
    error "Nao existe nenhuma natureza para este ramo."
    return
 end if
 if l_sim = "n" then
    let l_sim = " "
    for i = 1 to 9
       #if a_ctc55m00[i].socntzcod is null then
       #   exit for
       #end if
        display a_ctc55m00[i].socntzcod to s_ctc55m00[i].socntzcod
        display a_ctc55m00[i].socntzdes to s_ctc55m00[i].socntzdes
        display a_ctc55m00[i].ntzatdqtd to s_ctc55m00[i].ntzatdqtd
        display a_ctc55m00[i].ghost     to s_ctc55m00[i].ghost
        display a_ctc55m00[i].c24pbmgrpcod to s_ctc55m00[i].c24pbmgrpcod
        display a_ctc55m00[i].c24pbmgrpdes to s_ctc55m00[i].c24pbmgrpdes
    end for
    return
 end if
 for i = 1 to 9
    #if a_ctc55m00[i].socntzcod is null then
    #   exit for
    #end if
     display a_ctc55m00[i].socntzcod to s_ctc55m00[i].socntzcod
     display a_ctc55m00[i].socntzdes to s_ctc55m00[i].socntzdes
     display a_ctc55m00[i].ntzatdqtd to s_ctc55m00[i].ntzatdqtd
     display a_ctc55m00[i].ghost     to s_ctc55m00[i].ghost
     display a_ctc55m00[i].c24pbmgrpcod to s_ctc55m00[i].c24pbmgrpcod
     display a_ctc55m00[i].c24pbmgrpdes to s_ctc55m00[i].c24pbmgrpdes
 end for
 #display array a_ctc55m00 to s_ctc55m00.*
 #end display
 return
end function

#-----------------------------------------------------------------------------#
function ctc55m00_mostra(l_desloc)  # MOSTRA REGISTRO ANTERIOR/PROXIMO
#-----------------------------------------------------------------------------#
 define l_ramgrpcod  like gtakram.ramgrpcod #psi168890 eduardo - meta


 define l_desloc  integer

 define l_aux     record
        ramcod    like datrsocntzsrvre.ramcod,
        rmemdlcod like datrsocntzsrvre.rmemdlcod, #psi168890 eduardo - meta
        clscod    like datrsocntzsrvre.clscod,
        atdqtd    like datrsocntzsrvre.ntzatdqtd
 end record

 whenever error continue
 fetch relative l_desloc c_ctc55m00002 into l_aux.ramcod,
                                            l_aux.rmemdlcod, #psi168890
                                            l_aux.clscod,
                                            l_aux.atdqtd
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       error " Nao ha mais linhas nesta direcao "
       whenever error continue
       fetch relative 0 c_ctc55m00002 into l_aux.ramcod
                                          ,l_aux.rmemdlcod #psi168890 eduardo -meta
                                          ,l_aux.clscod
                                          ,l_aux.atdqtd
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode < 0 then
             error 'Erro Select(3) c_ctc55m00002: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
             error 'ctc55m00_abre','/',l_aux.ramcod,'/',l_aux.rmemdlcod,'/',l_aux.clscod,'/',l_aux.atdqtd,'.' sleep 2
             return
          end if
       end if
    else
       error 'Erro Select(2) c_ctc55m00002: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
       error 'ctc55m00_abre','/',l_aux.ramcod,'/',l_aux.rmemdlcod,'/',l_aux.clscod,'/',l_aux.atdqtd,'.' sleep 2
       return
    end if
 else
    let l_campos.ramcod = l_aux.ramcod
    let l_campos.rmemdlcod = l_aux.rmemdlcod
    let l_campos.clscod = l_aux.clscod
    let l_campos.atdqtd = l_aux.atdqtd

    #buscar as descricoes
    #inicio psi168890 eduardo -meta
     open cctc55m00017 using l_campos.ramcod

     whenever error continue
     fetch cctc55m00017 into l_campos.ramnom,
                             l_ramgrpcod
     whenever error stop
     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = 100 then
           error 'Ramo nao encontrado.' sleep 2
        else
           error 'Erro Select cctc55m00017: ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
           error 'ctc55m00_mostra','/',l_campos.ramcod,'/ 1.' sleep 2
           return
        end if
     end if

     #------------------------------------

     open cctc55m00009 using l_campos.ramcod,
                             l_campos.rmemdlcod

     whenever error continue
     fetch cctc55m00009 into l_campos.rmemdlnom
     whenever error stop
     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode < 0 then
           error 'Erro Select(3) cctc55m00009: ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
           error 'ctc55m00_mostra','/',l_campos.ramcod,'/',l_campos.rmemdlcod,'/ 1.' sleep 2
           return
        end if
     end if

     #------------------------------------

     if l_ramgrpcod = 1 then
        if g_issk.funmat = 601566 then
           display "ramcod/clscod=", l_campos.ramcod," ",l_campos.clscod
        end if
        let l_campos.tabnum = F_FUNGERAL_TABNUM("aackcls", today)
        open c_ctc55m00007 using l_campos.tabnum,
                                 l_campos.ramcod,
                                 l_campos.clscod

        whenever error continue
        fetch c_ctc55m00007 into l_campos.clscod,
                                 l_campos.clsdes
        if g_issk.funmat = 601566 then
           display "ramcod/clscod1=", l_campos.ramcod," ",l_campos.clscod
        end if

        whenever error stop
        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode < 0 then
              error 'Erro Select(2) c_ctc55m00007: ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
              error 'ctc55m00_mostra','/',l_campos.ramcod,'/',l_campos.clscod,'.' sleep 2
              return
           end if
        end if
     end if
     if l_ramgrpcod = 5 then
        whenever error continue
        open cctc55m00018  using l_campos.clscod
        fetch cctc55m00018  into l_campos.clscod,
                                 l_campos.clsdes
        whenever error stop
        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode < 0 then
              error "Erro ao acessar a tabela datkplnsau, erro!!! = ",
                    sqlca.sqlcode
              sleep 2
              return
           end if
        end if
     end if
     if l_ramgrpcod <> 1 and
        l_ramgrpcod <> 5 then
        whenever error continue
        open c_ctc55m00001 using l_campos.clscod,
                                 l_campos.ramcod,
                                 l_campos.rmemdlcod,
                                 l_campos.clscod,
                                 l_campos.ramcod,
                                 l_campos.rmemdlcod

        fetch c_ctc55m00001 into l_campos.clsdes
        whenever error stop
        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode < 0 then
              error 'Erro Select(2) c_ctc55m00001: ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
              error 'ctc55m00_mostra','/',l_campos.ramcod,'/',l_campos.clscod,'.' sleep 2
              return
           end if
        end if
     end if
     #------------------------------------
     #fim psi168890 eduardo - meta

    display by name l_campos.ramcod
    display by name l_campos.ramnom
    display by name l_campos.rmemdlcod
    display by name l_campos.rmemdlnom
    display by name l_campos.clscod
    display by name l_campos.clsdes
    display by name l_campos.atdqtd
 end if

 call ctc55m00_exibe(l_aux.*,l_sim)

 end function

#-----------------------------------------------------------------------------#
function ctc55m00_inclui(l_tipo)  # INCLUSAO DO RAMO, ETC NA TABELA DATRRAMCLS
#-----------------------------------------------------------------------------#

  define l_ramgrpcod  like gtakram.ramgrpcod
  define l_comando    char(600)
  define l_tipo       char(01)
  define l_chama      char(01)

  let int_flag = false

  if l_tipo = "i" then
     initialize l_campos.* to null
  end if
  input by name l_campos.ramcod,
                l_campos.rmemdlcod,
                l_campos.clscod,
                l_campos.atdqtd  without defaults

        before field ramcod
           if l_tipo = "a" then
              next field rmemdlcod      ## PSI 168890
           end if
           display by name l_campos.ramcod attribute(reverse)

        after  field ramcod
           display by name l_campos.ramcod

           whenever error continue
           select ramnom, ramgrpcod
             into l_campos.ramnom, l_ramgrpcod
             from gtakram
            where ramcod = l_campos.ramcod
              and empcod = 1
           whenever error stop

           if sqlca.sqlcode < 0 then
              error "Erro ao acessar a tabela gtakram, erro = ",sqlca.sqlcode
              sleep 2
              exit program
           end if
           if sqlca.sqlcode = 0 then
              display by name l_campos.ramnom
           end if
           if sqlca.sqlcode = 100 then
              error "Ramo nao cadastrado."
              call c24geral10()
                   returning l_campos.ramcod,
                             l_campos.ramnom
              next field ramcod
           end if

        #inicio psi168890 eduardo - meta
        before field rmemdlcod
           display by name l_campos.rmemdlcod attribute(reverse)

        after field rmemdlcod
           display by name l_campos.rmemdlcod
           if l_campos.rmemdlcod is null then
              call ctc56m05(l_campos.ramcod) returning l_campos.rmemdlcod
              next field rmemdlcod
           end if

           open cctc55m00009 using l_campos.ramcod,
                                   l_campos.rmemdlcod

           whenever error continue
           fetch cctc55m00009 into l_campos.rmemdlnom
           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode = 100 then
                 error 'Modalidade nao encontrada!Informe novamente.' sleep 2
                 next field rmemdlcod
              else
                 error 'Erro Select cctc55m00009: ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
                 error 'ctc55m00_inclui','/',l_campos.ramcod,'/',l_campos.rmemdlcod,'/ 1.' sleep 2
                 let int_flag = true
                 exit input
              end if
           end if

           display by name l_campos.rmemdlcod
           display by name l_campos.rmemdlnom

           if l_tipo = "a" then
              next field atdqtd
           end if
           #fim psi168890 eduardo - meta

        before field clscod
           display by name l_campos.clscod attribute(reverse)

        after  field clscod
           display by name l_campos.clscod

           if l_campos.clscod is null then
              let l_campos.clscod = 0
           end if
           if l_ramgrpcod = 1 then
              whenever error continue
              let l_campos.tabnum = F_FUNGERAL_TABNUM("aackcls", today)
              open c_ctc55m00007 using l_campos.tabnum,
                                       l_campos.ramcod,
                                       l_campos.clscod
              whenever error stop
              if sqlca.sqlcode < 0 then
                 error "Erro ao acessar a tabela aackcls, erro = ",
                 sqlca.sqlcode
                 sleep 2
                 exit program
              end if
              whenever error continue
              fetch c_ctc55m00007 into l_campos.clscod,
                                       l_campos.clsdes
              whenever error stop
              if sqlca.sqlcode < 0 then
                 error "Erro ao acessar a tabela aackcls, erro = ",
                  sqlca.sqlcode
                 sleep 2
                 exit program
              end if
              if sqlca.sqlcode <> 0 then
                 let l_campos.clscod = " "
                 error "Clausula nao cadastrada...",l_campos.tabnum," ",l_campos.clscod," ",l_ramgrpcod
                 next field clscod
              end if
           end if
           if l_ramgrpcod =  5 then    # saude
              whenever error continue
              open cctc55m00018  using l_campos.clscod
              fetch cctc55m00018  into l_campos.clscod,
                                       l_campos.clsdes
              whenever error stop
              if sqlca.sqlcode < 0 then
                 error "Erro ao acessar a tabela datkplnsau, erro!!!! = ",
                       sqlca.sqlcode
                 sleep 2
                 exit program
              end if
              if sqlca.sqlcode <> 0 then
                 let l_campos.clscod = " "
               error "Clausula nao cadastrada..",l_campos.clscod," ",l_ramgrpcod
                 next field clscod
              end if
           end if
           if l_ramgrpcod <> 1 and
              l_ramgrpcod <> 5 then
              whenever error continue
              open c_ctc55m00001 using l_campos.clscod,
                                       l_campos.ramcod,
                                       l_campos.rmemdlcod,
                                       l_campos.clscod,
                                       l_campos.ramcod,
                                       l_campos.rmemdlcod

              fetch c_ctc55m00001 into l_campos.clsdes
              whenever error stop
              if sqlca.sqlcode < 0 then
                 error "Erro ao acessar a tabela rgfkclaus2, erro = ",
                        sqlca.sqlcode
                 sleep 2
                 exit program
              end if
              if sqlca.sqlcode <> 0 then
                 let l_campos.clscod = " "
                 error "Clausula nao cadastrada...."
                 next field clscod
              end if
           end if
           display by name l_campos.clscod
           display by name l_campos.clsdes

           whenever error continue   #aqui
           select clsatdqtd
             into l_campos.atdqtd
             from datrramcls
            where clscod = l_campos.clscod
              and ramcod = l_campos.ramcod
           whenever error stop

           display by name l_campos.atdqtd

           if sqlca.sqlcode = 0 and
              l_tipo = "i" then
              error "Ramo/Clausula ja existem"
              call ctc55m00_exibe(l_campos.ramcod,
                                  l_campos.rmemdlcod,
                                  l_campos.clscod,
                                  l_campos.atdqtd,"s")
              exit input
           end if   #aqui

        before field atdqtd
           display by name l_campos.atdqtd attribute(reverse)

        after  field atdqtd
           display by name l_campos.atdqtd
           if l_campos.atdqtd is null or
              l_campos.atdqtd = 0   then
              error "Informe a Quantidade Atend."
              next field atdqtd
           end if
           if l_tipo = "a" then
              whenever error continue
              update datrramcls set (clsatdqtd, rmemdlcod)                  ## PSI 168890
                                  = (l_campos.atdqtd, l_campos.rmemdlcod)   ## PSI 168890
              where ramcod = l_campos.ramcod
                and clscod = l_campos.clscod
              whenever error stop
              if sqlca.sqlcode < 0 then
                 error "Erro ao tentar alterar dados na tabela datrramcls, ",
                       "erro = ",sqlca.sqlcode
                 sleep 2
                 exit program
              end if
              let int_flag = false
           end if
           if l_tipo <> "a" then
              #------------------------------
              # INSERINDO DADOS NA DATRRAMCLS
              #------------------------------
              begin work   #inicio psi168890 eduardo - meta
              whenever error continue
              execute pctc55m00010 using l_campos.ramcod,
                                         l_campos.clscod,
                                         l_campos.rmemdlcod,
                                         l_campos.atdqtd
              whenever error stop
              if sqlca.sqlcode <> 0 then
                 rollback work
                 error 'Erro Insert pctc55m00010: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
                 error 'ctc55m00_inclui','/',l_campos.ramcod,'/',l_campos.clscod,
                                         '/',l_campos.rmemdlcod,'/',l_campos.atdqtd,'.' sleep 2
                 clear form
                 let int_flag = true
                 exit input
              else
                 commit work
                 error 'Registro incluido com sucesso.' sleep 2
                 clear form
              end if          #fim psi168890 eduardo - meta
           end if
  end input
  if int_flag then
     if l_tipo = "i" then
        error " Inclusao cancelada "
     else
        error " Alteracao Cancelada "
     end if
     let int_flag = false
    return
 end if
 call ctc55m00_input(l_tipo)  #l_tipo
end function
#------------------------------------
function ctc55m00_input(l_tipo)
#------------------------------------

 define l_tipo char(01)  #- Tipo Operacao: i  Inclusao
                         #-                a  Modificac
 define y smallint
 define l_ant      record
        socntzcod  like  datrsocntzsrvre.socntzcod,
        socntzdes  char(30),
        ntzatdqtd  like  datrsocntzsrvre.ntzatdqtd
 end record
 define l_curr   smallint
 define l_line   smallint
 define l_simnao char(01)
 define l_param  char(01)   #psi168890 eduardo - meta
 define l_param1 smallint   #psi168890 eduardo - meta
 define l_descr  char(10)   #psi168890 eduardo - meta
 define l_clscod like rsdmclaus.clscod        ## PSI 168890

 if l_tipo = "i" then
    initialize a_ctc55m00 to null
    let l_tipo = null
 end if

## PSI 168890 - Inicio

 for y =  1 to  200
     let a_ctc55m00[y].ghost = null
 end for

 let l_param = null

## PSI 168890 - Termino

 input array a_ctc55m00 without defaults from s_ctc55m00.*

    before row
      let l_curr = arr_curr()
      let l_line = scr_line()

    before field socntzcod
     #if a_ctc55m00[l_curr].ghost = '*' then
     #   next field ntzatdqtd
     #end if
      let l_ant.socntzcod = a_ctc55m00[l_curr].socntzcod
      display a_ctc55m00[l_curr].socntzcod to s_ctc55m00[l_line].socntzcod attribute (reverse)

    after field socntzcod
      display a_ctc55m00[l_curr].socntzcod to s_ctc55m00[l_line].socntzcod
      let y = 1
      while a_ctc55m00[y].socntzcod is not null
         if y != l_curr and a_ctc55m00[y].socntzcod = a_ctc55m00[l_curr].socntzcod then
            let y = -1
            exit while
         end if
         let y = y + 1
      end while
      if y < 0 then
         error ' Esta Natureza ja existe !!!'
         next field socntzcod
      end if
      if a_ctc55m00[l_curr].socntzcod is null then
         let l_param = ""                                        #psi168890 - Inicio
         let l_param1 = 1
         call cts12g00(l_param1,l_param,l_param,l_param,
                       l_param,l_param,l_param, "" )
              returning a_ctc55m00[l_curr].socntzcod,
                        l_clscod   #psi168890 - Final
         display a_ctc55m00[l_curr].socntzcod to s_ctc55m00[l_line].socntzcod
      end if

      whenever error continue
      select socntzdes
        into a_ctc55m00[l_curr].socntzdes
        from datksocntz
       where socntzcod = a_ctc55m00[l_curr].socntzcod
         and socntzstt = "A"
      whenever error stop
      if sqlca.sqlcode < 0 then
         error "Erro ao acessar a tabela datksocntz, erro = ",sqlca.sqlcode
         sleep 2
         exit program
      end if
      if sqlca.sqlcode = 100 then
         error "Codico da natureza invalido!!"
         next field socntzcod
      end if
      if sqlca.sqlcode = 0 then
         let l_ant.socntzdes = a_ctc55m00[l_curr].socntzdes
         display a_ctc55m00[l_curr].socntzdes to s_ctc55m00[l_line].socntzdes
      end if

    before field ntzatdqtd
      display a_ctc55m00[l_curr].ntzatdqtd to s_ctc55m00[l_line].ntzatdqtd attribute (reverse)
      let l_ant.ntzatdqtd = a_ctc55m00[l_curr].ntzatdqtd

    after field ntzatdqtd
      display a_ctc55m00[l_curr].ntzatdqtd to s_ctc55m00[l_line].ntzatdqtd
      if a_ctc55m00[l_curr].ntzatdqtd is null then
         error "Informe a Quantidade"
         next field socntzcod
      end if

    #inicio psi168890 eduardo-meta
    before field c24pbmgrpdes
      display a_ctc55m00[l_curr].c24pbmgrpdes to s_ctc55m00[l_line].c24pbmgrpdes attribute (reverse)

    after field c24pbmgrpdes
      display a_ctc55m00[l_curr].c24pbmgrpdes to s_ctc55m00[l_line].c24pbmgrpdes

      if a_ctc55m00[l_curr].c24pbmgrpdes is null then
         call ctc48m02(l_param)
            returning a_ctc55m00[l_curr].c24pbmgrpcod,
                      a_ctc55m00[l_curr].c24pbmgrpdes

         open cctc55m00011 using a_ctc55m00[l_curr].c24pbmgrpcod

         whenever error continue
         fetch cctc55m00011 into l_descr
         whenever error stop
         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = 100 then
               let l_descr = ''
            else
               error 'Erro Select cctc55m00011: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
               error 'ctc55m00_input','/',a_ctc55m00[l_curr].c24pbmgrpcod,'/','C.' sleep 2
               clear form
               let int_flag = true
               exit input
            end if
         end if
         let a_ctc55m00[l_curr].c24pbmgrpdes = a_ctc55m00[l_curr].c24pbmgrpdes clipped,' / ',l_descr clipped
         let a_ctc55m00[l_curr].ghost = null
      end if

      display a_ctc55m00[l_curr].c24pbmgrpdes to s_ctc55m00[l_line].c24pbmgrpdes

      display a_ctc55m00[l_curr].c24pbmgrpcod to s_ctc55m00[l_line].c24pbmgrpcod
      #fim psi168890 eduardo-meta

      if a_ctc55m00[l_curr].ghost is null then
         let a_ctc55m00[l_curr].ghost = '*'
         #inicio psi168890 eduardo-meta
         open cctc55m00012 using l_campos.ramcod,
                                 l_campos.clscod,
                                 a_ctc55m00[l_curr].socntzcod,
                                 l_campos.rmemdlcod
         whenever error continue
         fetch cctc55m00012 into l_count
         whenever error stop
         if sqlca.sqlcode <> 0 then
            error 'Erro Select cctc55m00012: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
            error 'ctc55m00_input','/',l_campos.ramcod,'/',l_campos.clscod,'/'
                   ,a_ctc55m00[l_curr].socntzcod,'/',l_campos.rmemdlcod,'.' sleep 2
            clear form
            let int_flag = true
            exit input
         else
            if l_count = 0 then
               begin work
               whenever error continue
               execute pctc55m00013 using a_ctc55m00[l_curr].socntzcod,
                                          l_campos.ramcod,
                                          l_campos.clscod,
                                          a_ctc55m00[l_curr].ntzatdqtd,
                                          l_campos.rmemdlcod,
                                          a_ctc55m00[l_curr].c24pbmgrpcod
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  error 'Erro Insert pctc55m00013: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
                  error 'ctc55m00_input','/',a_ctc55m00[l_curr].socntzcod,'/',l_campos.ramcod,
                                         '/',l_campos.clscod,'/',a_ctc55m00[l_curr].ntzatdqtd,
                                         '/',l_campos.rmemdlcod,'/',a_ctc55m00[l_curr].c24pbmgrpcod,'.' sleep 2
                  clear form
                  rollback work
                  let int_flag = true
                  exit input
               else
                  if l_tipo = 'i' then
                     error 'Inclusao efetuada com sucesso.' sleep 2
                  end if
                  commit work
               end if
            else
               begin work
               whenever error continue
               execute pctc55m00014 using a_ctc55m00[l_curr].ntzatdqtd,
                                          a_ctc55m00[l_curr].c24pbmgrpcod,
                                          a_ctc55m00[l_curr].socntzcod,
                                          l_campos.ramcod,
                                          l_campos.clscod
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  error 'Erro Update pctc55m00014: ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
                  error 'ctc55m00_input','/',a_ctc55m00[l_curr].c24pbmgrpcod,'/',a_ctc55m00[l_curr].socntzcod,
                                         '/',l_campos.ramcod,'/',l_campos.clscod,'.' sleep 2
                  rollback work
                  clear form
                  let int_flag = true
                  exit input
               else
                  if l_tipo = 'a' then
                     error 'Registro atualizado com sucesso.' sleep 2
                  end if
                  commit work
               end if
            end if
         end if
      end if
      #fim psi168890 eduardo-meta
      if a_ctc55m00[l_curr].ghost = '*' then
         if l_ant.ntzatdqtd is null then
            let l_ant.ntzatdqtd = 0
         end if
         if l_ant.ntzatdqtd <> a_ctc55m00[l_curr].ntzatdqtd then
            #inicio psi168890 eduardo-meta
            begin work
            whenever error continue
            execute pctc55m00014 using a_ctc55m00[l_curr].ntzatdqtd,
                                       a_ctc55m00[l_curr].c24pbmgrpcod,
                                       a_ctc55m00[l_curr].socntzcod,
                                       l_campos.ramcod,
                                       l_campos.clscod
            whenever error stop
            if sqlca.sqlcode <> 0 then
               error 'Erro Update(2) pctc55m00014: ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
               error 'ctc55m00_input','/',a_ctc55m00[l_curr].c24pbmgrpcod,'/',a_ctc55m00[l_curr].socntzcod,
                                      '/',l_campos.ramcod,'/',l_campos.clscod,'.' sleep 2
               rollback work
               clear form
               let int_flag = true
               exit input
            else
               error '(2)Registro atualizado com sucesso.' sleep 2
               commit work
            end if
            #fim psi168890 eduardo-meta
         end if
      end if
    #---------------------------
    #Obs.: Inicio before delete
    #---------------------------
    before delete
      prompt "Deseja remover esta linha S/N ?" for char l_simnao
      if l_simnao = "s"  or  l_simnao = "S" then
         #inicio psi168890 eduardo-meta
         begin work
         whenever error continue
         execute pctc55m00015 using a_ctc55m00[l_curr].socntzcod,
                                    l_campos.ramcod,
                                    l_campos.clscod,
                                    l_campos.rmemdlcod
         whenever error stop
         if sqlca.sqlcode <> 0 then
            error 'Erro Delete pctc55m00015: ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
            error 'ctc55m00_input','/',a_ctc55m00[l_curr].socntzcod,'/',l_campos.ramcod,
                                   '/',l_campos.clscod,'/', l_campos.rmemdlcod,'.' sleep 2
            rollback work
            clear form
            let int_flag = true
            exit input
         else
            error 'Registro excluido com sucesso.' sleep 2
            commit work
         end if
         #inicio psi168890 eduardo-meta

        #call ctc55m00_exibe(l_campos.ramcod,
        #                    l_campos.clscod,
        #                    l_campos.atdqtd,"n")
      end if
 end input

 if int_flag then
    let int_flag = false
 end if

end function
