###############################################################################
# Nome do Modulo: CTC16m01                                           Marcelo  #
#                                                                    Gilberto #
#                                                                    Wagner   #
# Relacionamento das clausulas com natureza                          Out/1999 #
#-----------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
###############################################################################
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 23/10/2003 Marcelo, Meta     psi168890  Incluir o campo Modalidade no form #
#                              osf27847   com suas consistencias no fontes   #
# 25/09/06   Ligia Mattge     PSI 202720  Implementando grupo/cartao saude   #
#----------------------------------------------------------------------------#
# 17/08/2007 Ana Raquel,Meta   PSI211915  Inclusao de Union na entidade      #
#                                         rgfkmrsapccls                      #
#----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

 define ws_ramgrpcod like gtakram.ramgrpcod
 define ws_altflg    smallint
 define m_prep_sql   smallint  #Marcelo - psi168890
 define m_erro       smallint  #Marcelo - psi168890

#Marcelo - psi168890 - inicio
#---------------------------#
 function ctc16m01_prepare()
#---------------------------#
 define l_sql       char(500)
 
 let l_sql = ' select rmemdlnom     ',
             '   from gtakmodal     ',
             '  where empcod    = 1 ',
             '    and ramcod    = ? ',
             '    and rmemdlcod = ? '
 
 prepare pctc16m01001 from l_sql
 declare cctc16m01001 cursor for pctc16m01001
 
 let l_sql = ' select clscod          ',
             '   from datrsocntzsrvre ',
             '  where socntzcod  = ?  ',
             '    and ramcod     = ?  ',
             '    and rmemdlcod  = ?  '
 
 prepare pctc16m01002 from l_sql
 declare cctc16m01002 cursor for pctc16m01002

 let l_sql = ' delete from datrsocntzsrvre ',
             '  where socntzcod   = ?      ',
             '    and ramcod      = ?      ',
             '    and clscod      = ?      ',
             '    and rmemdlcod   = ?      '
 
 prepare pctc16m01003 from l_sql

 let l_sql = ' insert into datrsocntzsrvre (socntzcod,ramcod,clscod,rmemdlcod) ',
             ' values (?,?,?,?) '
 
 prepare pctc16m01004 from l_sql

 let l_sql = ' select clsdes '
              ,' from rgfkclaus2 '
             ,' where ramcod = ? '
               ,' and clscod = ? '
              ,'union '
            ,' select clsdes '       
              ,' from rgfkmrsapccls '
             ,' where ramcod = ? '
               ,' and clscod = ? '

 prepare pctc16m01005 from l_sql
 declare cctc16m01005 cursor for pctc16m01005
  
 end function
#Marcelo - psi168890 - fim

#--------------------------------------------------------------
 function ctc16m01(param)
#--------------------------------------------------------------

 define param        record
    socntzcod        like datrsocntzsrvre.socntzcod
 end record

 define d_ctc16m01   record
    socntzdes        like datksocntz.socntzdes,
    ramcod           like datrsocntzsrvre.ramcod,
    ramnom           like gtakram.ramnom,
    rmemdlcod        like rgpkmodal.rmemdlcod,   #Marcelo - psi168890
    rmemdlnom        like rgpkmodal.rmemdlnom    #Marcelo - psi168890
 end record
 
 #Marcelo - psi168890 - inicio
 if m_prep_sql <> true or
    m_prep_sql is null then
    call ctc16m01_prepare()
    let m_prep_sql = true
 end if
 #Marcelo - psi168890 - fim
 
 initialize d_ctc16m01.* to null

 let m_erro    = 0
 let ws_altflg = 0
 let int_flag  = false

 open window ctc16m01 at 09,22 with form "ctc16m01"
                      attribute (form line 1, border, comment line last - 1)

 message " (F17)Abandona"

 select socntzdes
   into d_ctc16m01.socntzdes
   from datksocntz
  where socntzcod = param.socntzcod

 while 1

    display by name param.socntzcod, d_ctc16m01.socntzdes

    input by name d_ctc16m01.ramcod,
                  d_ctc16m01.rmemdlcod
                  without defaults

       before field ramcod
          display by name d_ctc16m01.ramcod attribute (reverse)

       after  field ramcod
          display by name d_ctc16m01.ramcod

          if d_ctc16m01.ramcod is null  then
             error " Informe o codigo do Ramo!"
             next field ramcod
          end if

          select ramnom, ramgrpcod
            into d_ctc16m01.ramnom, ws_ramgrpcod
            from gtakram
           where ramcod = d_ctc16m01.ramcod
             and empcod = 1

          if sqlca.sqlcode = notfound  then
             error " Ramo nao cadastrado!"
             call c24geral10()
                  returning d_ctc16m01.ramcod, d_ctc16m01.ramnom
             display by name d_ctc16m01.ramnom
             next field ramcod
          end if

          display by name d_ctc16m01.ramcod
          display by name d_ctc16m01.ramnom
       
       #Marcelo - psi168890 - inicio
       before field rmemdlcod
          display by name d_ctc16m01.rmemdlcod attribute (reverse)
       
       after field rmemdlcod
          if fgl_lastkey() <> fgl_keyval("left")and 
             fgl_lastkey() <> fgl_keyval("up")  then
             if d_ctc16m01.rmemdlcod is null then
                call ctc56m05(d_ctc16m01.ramcod)
                              returning d_ctc16m01.rmemdlcod
                next field rmemdlcod
             end if
             open cctc16m01001 using d_ctc16m01.ramcod,
                                     d_ctc16m01.rmemdlcod
             whenever error continue
             fetch cctc16m01001 into d_ctc16m01.rmemdlnom
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                   error 'Modalidade nao encontrada!Informe novamente.'
                   sleep 2
                   call ctc56m05(d_ctc16m01.ramcod)
                                 returning d_ctc16m01.rmemdlcod
                   next field rmemdlcod
                else
                   error 'Problemas de acesso a tabela rgpkmodal, ',
                         sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                   error 'ctc16m01/principal()/',
                         d_ctc16m01.ramcod,'/',d_ctc16m01.rmemdlcod sleep 2
                   let m_erro = 1
                   exit input
                end if
             end if
          
             display by name d_ctc16m01.rmemdlcod
             display by name d_ctc16m01.rmemdlnom
             
             call ctc16m01_clausulas(param.socntzcod, 
                                     d_ctc16m01.ramcod,
                                     d_ctc16m01.rmemdlcod)
             
             if m_erro <> 0 then
                exit input
             end if
          end if
          #Marcelo - psi168890 - fim
          
       on key (interrupt)
          exit input

    end input
    
    #Marcelo - psi168890 - inicio
    if m_erro <> 0 then
       exit while
    end if
    #Marcelo - psi168890 - fim
    
    if int_flag   then
       exit while
    end if

 end while
 
 #Marcelo - psi168890 - inicio
 if m_erro <> 0 then
    let int_flag = false
    close window ctc16m01
    return
 end if
 #Marcelo - psi168890 - fim
 
 if ws_altflg = 1 then

    whenever error continue

    update datksocntz set ( atldat,
                            atlemp,
                            atlmat )
                        = ( today,
                            g_issk.empcod,
                            g_issk.funmat )
        where socntzcod  =  param.socntzcod

    if sqlca.sqlcode <> 0  then
       error " Erro (", sqlca.sqlcode, ") na atualizacao da natureza!"
    end if

 end if

 close window ctc16m01

 let int_flag = false

end function  #  ctc16m01


#--------------------------------------------------------------
 function ctc16m01_clausulas(param2)
#--------------------------------------------------------------

 define param2       record
    socntzcod        like datrsocntzsrvre.socntzcod,
    ramcod           like datrsocntzsrvre.ramcod,
    rmemdlcod        like rgpkmodal.rmemdlcod        #Marcelo - psi168890
 end record

 define a_ctc16m01   array[20] of record
    clscod           like datrsocntzsrvre.clscod,
    clsdes           char (40)
 end record

 define ws           record
    clscod           like datrsocntzsrvre.clscod,
    confirma         char (01),
    operacao         char (01)
 end record

 define arr_aux      integer
 define scr_aux      integer
 define x            smallint

 define l_status       smallint,
        l_msg          char(20), 
        l_plnatnlimnum smallint

 initialize a_ctc16m01  to null
 initialize ws.*        to null
 let arr_aux = 1

 let l_status       = null
 let l_msg          = null
 let l_plnatnlimnum = null

 #Marcelo - psi168890 - inicio
 open cctc16m01002 using param2.socntzcod,
                         param2.ramcod,
                         param2.rmemdlcod
 #Marcelo - psi168890 - fim
 foreach cctc16m01002 into a_ctc16m01[arr_aux].clscod

    if ws_ramgrpcod = 1 then  ## Auto
       declare c_aackclsa cursor for
        select clsdes
          from aackcls
         where ramcod   = param2.ramcod
           and clscod   = a_ctc16m01[arr_aux].clscod

       foreach c_aackclsa into a_ctc16m01[arr_aux].clsdes
          exit foreach
       end foreach
    else 
       if ws_ramgrpcod = 5 then ## Saude - PSI 202720
          call cta01m16_sel_datkplnsau( a_ctc16m01[arr_aux].clscod)
               returning l_status, l_msg, a_ctc16m01[arr_aux].clsdes, 
                         l_plnatnlimnum
       else
          
          open cctc16m01005 using param2.ramcod
                                 ,a_ctc16m01[arr_aux].clscod
                                 ,param2.ramcod             
                                 ,a_ctc16m01[arr_aux].clscod
   
          foreach cctc16m01005 into a_ctc16m01[arr_aux].clsdes
             exit foreach
          end foreach
       end if
    end if

    if a_ctc16m01[arr_aux].clsdes is null then
       let a_ctc16m01[arr_aux].clsdes = " NAO ENCONTRADA !!"
    end if

    let arr_aux = arr_aux + 1
    if arr_aux > 20 then
       error " Limite excedido, natureza/ramo com mais de 20 clausulas"
       exit foreach
    end if

 end foreach

 call set_count(arr_aux-1)
 options comment line last - 1

 message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

 while 2

    let int_flag = false

    input array a_ctc16m01 without defaults from s_ctc16m01.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count()  then
             let ws.operacao = "a"
             let ws.clscod   = a_ctc16m01[arr_aux].clscod
          end if

       before insert
          let ws.operacao = "i"
          initialize a_ctc16m01[arr_aux].*  to null
          display a_ctc16m01[arr_aux].* to s_ctc16m01[scr_aux].*

       before field clscod
          display a_ctc16m01[arr_aux].clscod to
                  s_ctc16m01[scr_aux].clscod attribute (reverse)

       after field clscod
          display a_ctc16m01[arr_aux].clscod to
                  s_ctc16m01[scr_aux].clscod

          if a_ctc16m01[arr_aux].clscod is null then
             error " Codigo da clausula deve ser informado!"
             next field clscod
          end if

          if ws.operacao = "a" and
             a_ctc16m01[arr_aux].clscod <> ws.clscod then
             error " Codigo do grupo de itens nao deve ser alterado!"
             next field clscod
          end if

          initialize a_ctc16m01[arr_aux].clsdes to null
          if ws_ramgrpcod = 1 then ## Auto
             declare c_aackclsb cursor for
              select clsdes
                from aackcls
               where ramcod   = param2.ramcod
                 and clscod   = a_ctc16m01[arr_aux].clscod

             foreach c_aackclsb into a_ctc16m01[arr_aux].clsdes
                exit foreach
             end foreach
          else
             if ws_ramgrpcod = 5 then ## Saude - PSI 202720
                call cta01m16_sel_datkplnsau( a_ctc16m01[arr_aux].clscod)
                     returning l_status, l_msg, a_ctc16m01[arr_aux].clsdes, 
                               l_plnatnlimnum
             else

                open cctc16m01005 using param2.ramcod
                                       ,a_ctc16m01[arr_aux].clscod
                                       ,param2.ramcod             
                                       ,a_ctc16m01[arr_aux].clscod
         
                foreach cctc16m01005 into a_ctc16m01[arr_aux].clsdes
                   exit foreach
                end foreach
             end if
          end if

          if a_ctc16m01[arr_aux].clsdes is null then
             error " Codigo da clausula nao existe ou nao pertence a esse ramo!"
             next field clscod
          end if

          display a_ctc16m01[arr_aux].clsdes  to
                  s_ctc16m01[scr_aux].clsdes

          for x = 1 to 20
              if arr_aux <> x                                       and
                 a_ctc16m01[arr_aux].clscod = a_ctc16m01[x].clscod  then
                 error " Clausula ja' cadastrada neste ramo para esta natureza!"
                 next field clscod
              end if
          end for

       before delete
          let ws.operacao = "d"
          if a_ctc16m01[arr_aux].clscod  is null  then
             continue input
          end if
          
          #Marcelo - psi168890 - inicio
          whenever error continue
          execute pctc16m01003 using param2.socntzcod,
                                     param2.ramcod,
                                     a_ctc16m01[arr_aux].clscod,
                                     param2.rmemdlcod
          whenever error stop
          if sqlca.sqlcode <> 0 then
             error 'Problemas de delete na tabela datrsocntzsrvre, ',
             sqlca.sqlcode,'/',sqlca.sqlerrd[2]
             sleep 2
             error 'ctc16m01_clausulas() parametros : ',
                    param2.socntzcod,'/',param2.ramcod,'/',
                    a_ctc16m01[arr_aux].clscod,'/',param2.rmemdlcod
             sleep 2
             let m_erro = 1
             exit input
          end if
          #Marcelo - psi168890 - fim

          if sqlca.sqlcode <> 0 then
             error " Erro (", sqlca.sqlcode, ") na exclusao desta clausula favor verificar!"
          else
             let ws_altflg = 1
          end if

          initialize a_ctc16m01[arr_aux].* to null
          display a_ctc16m01[arr_aux].* to s_ctc16m01[scr_aux].*

       after row
          case ws.operacao
             when "i"
               #Marcelo - psi168890 - inicio
               whenever error continue
               execute pctc16m01004 using param2.socntzcod,
                                          param2.ramcod,
                                          a_ctc16m01[arr_aux].clscod,
                                          param2.rmemdlcod
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  error 'Problemas de insert na tabela datrsocntzsrvre, ',
                         sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                  error 'ctc16m01_clausulas() parametros : ',
                         param2.socntzcod,'/',param2.ramcod,'/',
                         a_ctc16m01[arr_aux].clscod,'/',param2.rmemdlcod sleep 2
                  let m_erro = 1
                  exit case
               else
                  let ws_altflg = 1
               end if
               #Marcelo - psi168890 - fim

            end case
            
            #Marcelo - psi168890 - inicio
            if m_erro <> 0 then
               exit input
            end if
            #Marcelo - psi168890 - fim
            
          let ws.operacao = " "

       on key (interrupt)
          exit input

    end input
    
    #Marcelo - psi168890 - inicio
    if m_erro <> 0 then
       exit while
    end if
    #Marcelo - psi168890 - fim
    
    if int_flag    then
       exit while
    end if

end while

clear form

let int_flag = false

end function  #  ctc16m01_clausulas
