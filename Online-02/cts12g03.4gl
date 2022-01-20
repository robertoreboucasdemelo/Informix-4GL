###############################################################################
# Nome do Modulo: cts12g03                                                    #
#                                                                             #
# Funcao de naturezas de socorro/sinistro Ramos Elementares          Mai/2008 #
###############################################################################
#.............................................................................#
#                    * * *  ALTERACOES  * * *                                 #
#                                                                             #
#Data        Autor Fabrica PSI       Alteracao                                #
#----------  ------------- --------  -----------------------------------------#
# 18/09/2008  Nilo          221635   Agendamento de Servicos a Residencia     #
#                                    Portal do Segurado                       #
#                                    Programa derivado da função cts12g00     #
#-----------------------------------------------------------------------------#
# 25/10/2010 Carla Rampazzo  00762   Tratamento para Help Desk Casa           #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"


define m_prepare smallint

#---------------------------------------------------------------------------
function cts12g03_prepare()
#---------------------------------------------------------------------------

  define l_sql char(1000)

  define l_qtd smallint
  let l_qtd = null

  let l_sql = "select socntzgrpcod " ,
              "from datrempgrp " ,
              "where empcod = ?" ,
              "and c24astcod = ?"
  prepare p_cts12g03_001 from l_sql
  declare c_cts12g03_001 cursor for p_cts12g03_001

  #----------------------------------------------
  --> Buscar Naturezas Cadastradas para Help Desk
  #----------------------------------------------
  let l_sql = " select cpodes "
               ," from datkdominio "
              ," where cponom = 'natureza_hdk' "
  prepare p_cts12g03003 from l_sql
  declare c_cts12g03003 cursor for p_cts12g03003


  let l_qtd = 1

  while true

     whenever error continue
        drop table cts12g03_natureza
     whenever error stop

     whenever error continue

        create temp table cts12g03_natureza(ntzcod       smallint     ,
                                            ntzdes       char (40)    ,
                                            clscod       char(5)      ,
                                            socntzgrpcod smallint)
                                  with no log

     create unique index idx_tmpcts12g03 on cts12g03_natureza (ntzcod,clscod,socntzgrpcod)
     whenever error stop

     if sqlca.sqlcode <> 0  then
        if sqlca.sqlcode = -310 or
           sqlca.sqlcode = -958 then
           if l_qtd > 10 then
              exit while
           end if
           let l_qtd = l_qtd + 1
           continue while
        end if
     end if

     exit while
  end while

  if l_qtd > 10 then
     return 8 ,"Problema na criacao da tabela temporaria. Erro: " ,sqlca.sqlcode clipped
  end if

  let l_sql = 'insert into cts12g03_natureza'
            , ' values(?,?,?,?)'
  prepare p_cts12g03_002 from l_sql

  let m_prepare = true

end function

#---------------------------------------------------------------
 function cts12g03(param)
#---------------------------------------------------------------

 define param      record
    ntztip         smallint,
    c24astcod      like datmligacao.c24astcod,
    ramcod         smallint,                    ## PSI 168890 - Inicio
    clscod         char(5),                     ## psi 202720 - saude
    rmemdlcod      decimal(3,0),
    prporg         like rsdmdocto.prporg,
    prpnumdig      like rsdmdocto.prpnumdig,    ## PSI 168890 - Final
    socntzgrpcod   like datksocntz.socntzgrpcod,
    chamada        char(01)
 end record

 define d_cts12g03 record
    ntztiptxt      char (08)
 end record

 define lr_cts12g03 record
    ntzdes          char (40),
    ntzcod          smallint
 end record

 define ws record
    socntzgrpcod   like datksocntz.socntzgrpcod
 end record

 define lr_aux     record                   ## PSI 168890
    clscod         like rsdmclaus.clscod    ## PSI 168890
 end record                                 ## PSI 168890

 define l_socntzgrpcod like datksocntz.socntzgrpcod

 define rel_retorno smallint
       ,l_mensagem  char(80)

 define arr_aux    smallint
 define scr_aux    smallint
 define sql        char (1000)   ## PSI 168890
 define w_pf1      integer
 define l_cpodes   char(50)
 define l_natureza smallint
 define l_assunto  like datkassunto.c24astcod
 define l_cont     smallint
 define l_ntz_S68  char(01)

 let arr_aux        = null
 let scr_aux        = null
 let sql            = null
 let l_socntzgrpcod = null
 let rel_retorno    = null
 let l_mensagem     = null
 let l_cpodes       = null
 let l_natureza     = null
 let l_assunto      = null
 let l_cont         = null
 let l_ntz_S68      = null

 initialize lr_aux.*       to null    ## PSI 168890
 initialize lr_cts12g03.*  to null    ## PSI 168890
 initialize d_cts12g03.*   to null
 initialize ws.*           to null

 call cts12g03_prepare()

 ---> Controle p/ nao usar clausula na condicao do select para casos de Cortesia
 if (param.c24astcod = "S68"  or 
     param.c24astcod = "S78"      ) and
    (param.clscod    is null  or
     param.clscod    =  "   "     ) then

    let l_ntz_S68 = "S" 

 end if
 
 if param.ntztip = 1  then

    let d_cts12g03.ntztiptxt = "Socorro"

    if param.ramcod is not null then

       if param.chamada = 'O'  then

          ---> Controle para quando quando nao ha clausula/Servico
          ---> de Help Desk 
          if l_ntz_S68 = "S" then

             let sql = "select socntzdes, socntzcod,'',socntzgrpcod  ",
                       "  from datksocntz          ",
                       " where socntzstt = 'A'     "
          else
             let sql = " select a.socntzdes,a.socntzcod    ", 
                       "       ,b.clscod   ,a.socntzgrpcod ",
                       "   from datksocntz a,             ",
                       "        datrsocntzsrvre b         ",
                       "  where b.ramcod    = ",param.ramcod clipped,
                       "    and b.rmemdlcod = ",param.rmemdlcod clipped,
                       "    and a.socntzcod = b.socntzcod ",
                       "    and a.socntzstt = 'A'         "

             if param.socntzgrpcod is not null then

                let sql = sql clipped,' and a.socntzgrpcod = ',
                                            param.socntzgrpcod clipped,' '
             end if

             if param.prporg    is not null and
                param.prpnumdig is not null then

                let sql = sql clipped, " and (b.clscod    = '",
                                            param.clscod clipped, "' or ",
                          "b.clscod in (select clscod from rsdmclaus ",
                                       " where prporg = ", param.prporg clipped,
                                      " and prpnumdig = ", param.prpnumdig clipped,
                                      " and lclnumseq = 1 ",
                                      "   and clsstt    = 'A'))"
             else
                let sql = sql clipped, "    and b.clscod    = '",
                                            param.clscod clipped, "'"
             end if
          end if
       else
          if param.chamada = 'B'  then

             let sql = " select a.socntzdes ",
                       "       ,a.socntzcod ",
                       "       ,b.clscod    ",
                       "       ,a.socntzgrpcod ",
                       "   from datksocntz a, ",
                       "        datrsocntzsrvre b ",
                       "  where b.ramcod    = ", param.ramcod ,
                       "    and b.rmemdlcod = ", param.rmemdlcod ,
                       "    and a.socntzcod = b.socntzcod ",
                       "    and a.socntzstt = 'A'         ",
                       "    and b.clscod    = '", param.clscod clipped, "'"
          else
             return 10, "Erro paramentros de entrada. Paramentro Chamada nulo."
          end if
       end if
    else

        # Empresa PortoSeg

        if g_documento.ciaempcod = 40 or
           g_documento.ciaempcod = 43 then # PSI 247936 Empresas 27

             whenever error continue
             open c_cts12g03_001 using g_documento.ciaempcod ,
                                     param.c24astcod

             fetch c_cts12g03_001 into l_socntzgrpcod

             whenever error stop

             if l_socntzgrpcod is not null then


                 let sql = "select b.socntzdes, b.socntzcod, a.socntzgrpcod ",
                           "from datrgrpntz a, datksocntz b , datrempgrp c ",
                           "where a.socntzcod = b.socntzcod ",
                           "and  a.socntzgrpcod = c.socntzgrpcod ",
                           "and b.socntzstt    = 'A'",
                           "and c.empcod = " , g_documento.ciaempcod, " ",
                           "and c.c24astcod = '" , param.c24astcod, "' " ,
                           "order by b.socntzdes"

            else
               return 9 ,"Assunto sem Grupo de Natureza Especificada"
            end if
        else

              let sql = "select socntzdes, socntzcod,'',socntzgrpcod  ",
                        "  from datksocntz          ",
                        " where socntzstt = 'A'     "

              if param.socntzgrpcod is not null then

                 let sql = sql clipped,' and socntzgrpcod = ',
                                  param.socntzgrpcod clipped,' '
              end if
              let sql = sql clipped," order by socntzdes "
       end if
    end if
 else
    let d_cts12g03.ntztiptxt = "Sinistro"

    let sql = "select sinntzdes, sinntzcod, '',''",      ## PSI 168890
              "  from sgaknatur           ",
              " where sinramgrp  = '4'    ",
              " order by sinntzdes        "
 end if

 prepare p_cts12g03_003 from sql
 declare c_cts12g03_002 cursor for p_cts12g03_003


 initialize lr_cts12g03.* to null
 let arr_aux = 1

 ---> Assume Clausula 


 open    c_cts12g03_002
 foreach c_cts12g03_002 into lr_cts12g03.ntzdes,
                             lr_cts12g03.ntzcod,
                             lr_aux.clscod,        ## PSI 168890
                             ws.socntzgrpcod

    if param.c24astcod is not null then


       if param.c24astcod = "S66" or
          param.c24astcod = "S67" or
          param.c24astcod = "S68" or
          param.c24astcod = "S78" then   


          #---------------------------------------------------------
          --> Verifica se Clausula da direito ao Help Desk - Dominio
          #---------------------------------------------------------
          let l_cont = 0
          open c_cts12g03003

          foreach c_cts12g03003 into l_cpodes

             let l_assunto  = l_cpodes[10,12]
             let l_natureza = l_cpodes[24,26]

             if param.c24astcod = l_assunto then

                if lr_cts12g03.ntzcod = l_natureza then

                   let l_cont = l_cont + 1
                   exit foreach
                else
                   continue foreach
                end if
             else
                continue foreach
             end if
          end foreach

          if l_cont = 0 then
             continue foreach
          end if

       else

          if lr_cts12g03.ntzcod = 11  then   # Telefonia
             let ws.socntzgrpcod = 1 # linha branca
          end if

          if ws.socntzgrpcod = 1 then
             if param.c24astcod = "S60"  then    # S60 - Tudo exceto L.Branca
                continue foreach
             end if
          else
             if param.c24astcod = "S63"  then    # S63 - Somente L.Branca
                continue foreach
             end if
          end if
       end if
    end if

    call cts12g01_grupo_problema(lr_cts12g03.ntzcod
                                ,param.ramcod
                                ,lr_aux.clscod
                                ,param.rmemdlcod)
                       returning rel_retorno, l_mensagem, ws.socntzgrpcod

    ---> Insere Tabela Temporaria - Natureza
    whenever error continue
       execute p_cts12g03_002 using lr_cts12g03.ntzcod,
                                  lr_cts12g03.ntzdes,
                                  lr_aux.clscod,
                                  ws.socntzgrpcod
 
    whenever error stop

 end foreach

 let int_flag = false

 return 0,"OK"

end function  ###  cts12g03
