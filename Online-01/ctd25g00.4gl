#-----------------------------------------------------------------------------#
# Sistema.......: Porto Socorro                                               #
# Modulo........: ctd25g00                                                    #
# Analista Resp.: Nilo Costa                                                  #
# PSI...........:                                                             #
# Objetivo......: Funcoes de consulta e atualizacoes da Tabela de             #
#                 Relacionamento entre atendimento e ligacao(datratdlig)      #
#.............................................................................#
# Desenvolvimento:                                                            #
# Liberacao......:                                                            #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- ------    -----------------------------------------#
# 30/12/08   Priscila Staingel       Retirada do for tentando inserir registro#
#                                    em datratdlig 11 vezes                   #
#-----------------------------------------------------------------------------#
database porto

#-------------------------------------------
function ctd25g00_insere_atendimento(param)
#-------------------------------------------

   define param    record
          atdnum   like datratdlig.atdnum,
          lignum   like datratdlig.lignum
   end record

   define l_msg_erro char(50)
   define i          smallint

   define l_msg_pri  char(100)
   define l_lignum   like datratdlig.lignum
   define l_atdnum   like datratdlig.atdnum
   let l_msg_pri = "PRI - atd:", param.atdnum , "  lignum:", param.lignum
   call errorlog(l_msg_pri)

   let l_msg_erro = null
   let i          = null
   whenever error continue
     select atdnum, lignum
       into l_atdnum, l_lignum
       from datratdlig
      where lignum = param.lignum
        and atdnum = param.atdnum
   whenever error stop
   if (l_atdnum is not null) or (l_lignum is not null) then
      return 0, ' OK!'
   end if

   if param.atdnum is null or
      param.atdnum =  0    or
      param.atdnum = ''    then
      let l_msg_erro = null
      let l_msg_erro = 'Numero de atendimento invalido: '
                       ,param.atdnum using "<<<<<<<<<<"
      return 1,l_msg_erro
   end if

   if param.lignum is null or
      param.lignum =  0    or
      param.lignum = ''    then
      let l_msg_erro = null
      let l_msg_erro = 'Numero da ligacao invalido: '
                       ,param.lignum using "<<<<<<<<<<"
      return 1,l_msg_erro
   end if

   whenever error continue
   insert into datratdlig values (param.atdnum,param.lignum)
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let l_msg_erro = null
      let l_msg_erro = "ERRO (",sqlca.sqlcode,") ao inserir registro em datratdlig. AVISE A INFORMATICA!"
      return 1,l_msg_erro
   else
      return 0,'OK'
   end if

end function
#---------------------------------
function ctd25g00_num_atend(param)
#---------------------------------

    define param    record
           lignum   like datmligacao.lignum
    end record

    define l_atdnum like datratdlig.atdnum

    let l_atdnum = null

    declare c_ctd25g00_001 cursor for
    select atdnum
      from datratdlig
     where lignum = param.lignum

    foreach c_ctd25g00_001 into l_atdnum
    end foreach

    return l_atdnum

end function

#-------------------------------
function ctd25g00_num_ligacoes()
#-------------------------------

 define lr_retorno     record
        erro           smallint,
        atdnum         like datratdlig.atdnum,
        lignum         like datratdlig.lignum
 end record

 define w_cmd          char (500),
        w_lignum       like datmligacao.lignum,
        w_c24astcod    char(04),
        w_c24astdes    like datkassunto.c24astdes,
        w_ligdat       like datmligacao.ligdat,
        w_lighorinc    like  datmligacao.lighorinc,
        w_result       smallint,
        w_qualquer     char (1)

 define l_count smallint

 initialize lr_retorno.*  to  null

 let w_cmd = null
 let w_lignum = null
 let w_c24astcod = null
 let w_c24astdes = null
 let w_ligdat = null
 let w_lighorinc = null
 let w_result = null
 let w_qualquer = null
 let l_count = null

 let  w_cmd = " select lignum , c24astcod ,c24astdes "
            , "      , ligdat , lighorinc "
            , " from cta02m00_tmp_ligacoes "

 call ofgrc002_popup(05,06,10,70,5
          ,"LIGACOES DO ATENDIMENTO"
        ,"  N.LIGACAO| AST |DESCRICAO ASSUNTO|            DT.LIG|     HR.LIG|"
          ,w_cmd
          ,"NN0211##########|AN1417|AN1947|DN5059dd/mm/yyyy|AN6168"
          ,"","","","order by 1 desc",'S')
       returning lr_retorno.erro
                ,lr_retorno.lignum
                ,w_c24astcod
                ,w_c24astdes
                ,w_ligdat
                ,w_lighorinc
                ,w_qualquer,w_qualquer,w_qualquer,w_qualquer,w_qualquer
                ,w_qualquer,w_qualquer,w_qualquer,w_qualquer,w_qualquer
                ,w_qualquer,w_qualquer,w_qualquer,w_qualquer,w_qualquer

 let int_flag = false

 return lr_retorno.erro
       ,lr_retorno.lignum

end function
#----------------------------------------------------------------#
 function ctd25g00_con_num_atend(param) # Consulta N� Atendimento
#----------------------------------------------------------------#
    define param    record
           lignum   like datmligacao.lignum,
           atdnum   like datratdlig.atdnum
    end record
    define l_lignum like datratdlig.lignum
    define l_atdnum like datratdlig.atdnum
    let l_atdnum = null
    let l_lignum = null
     whenever error continue
       select atdnum, lignum
         into l_atdnum, l_lignum
         from datratdlig
        where lignum = param.lignum
          and atdnum = param.atdnum
     whenever error stop
     if (l_atdnum is null or l_atdnum = 0 or l_atdnum = " ") and
        (l_lignum is null or l_lignum = 0 or l_lignum = " ") then
        return 1
     end if
    return 0
end function
