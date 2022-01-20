############################################################################
# Menu de Modulo: CTC56M04                                            Raji #
# Historico dos textos das clausulas                              Mar/2002 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86              #
# 16/11/2006  Ligia               PSI 205206     ciaempcod                 #
#--------------------------------------------------------------------------#
# 17/08/2007  Ana Raquel,Meta     PSI211915   Inclusao de Union na entidade#
#                                             rgfkmrsapccls                #
############################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"

   define m_prep_sql   smallint

#---------------------------#
 function ctc56m04_prepare()
#---------------------------#
   define l_sql       char(800)

   let l_sql = ' select clsdes '
                ,' from rgfkclaus2 '
               ,' where clscod = ? '
                 ,' and ramcod = ? '
                 ,' and rmemdlcod = ? '
               ,' union '
              ,' select clsdes '
                ,' from rgfkmrsapccls '
               ,' where clscod = ? '
                 ,' and ramcod = ? '
                 ,' and rmemdlcod = ? '
   
   prepare pctc56m04001 from l_sql
   declare cctc56m04001 cursor for pctc56m04001
 
   let m_prep_sql = true 
 
 end function

#--------------------------------------------------------------------
 function ctc56m04(par_ctc56m04)
#--------------------------------------------------------------------
   define par_ctc56m04 record
          ciaempcod    like datkclstxt.ciaempcod,
          clscod       like datkclstxt.clscod,
          ramcod       like datkclstxt.ramcod,
          rmemdlcod    like datkclstxt.rmemdlcod
   end record
   define a_ctc56m04 array[300] of record
          atldat       like datkclstxt.atldat,
          atlhor       like datkclstxt.atlhor,
          atlmat       like datkclstxt.atlmat,
          funnom       like isskfunc.funnom,
          clslinseq    like datkclstxt.clslinseq,
          clstxtstt    like datkclstxt.clstxtstt,
          sttdes       char(20)
   end record
   define arr_aux      smallint
   define scr_aux      smallint
   define i            smallint
   define l_ok         smallint

   define ws  record
          clsdes       char(20),
          ramnom       char(20),
          empcod       like isskfunc.empcod
   end record


        define  w_pf1   integer

        let     arr_aux  =  null
        let     scr_aux  =  null
        let     i  =  null

        for     w_pf1  =  1  to  300
                initialize  a_ctc56m04[w_pf1].*  to  null
        end     for

        initialize  ws.*  to  null

   initialize a_ctc56m04   to null
   initialize ws.*         to null
   let arr_aux  =  1
   let l_ok  =  0

   if m_prep_sql <> true or
      m_prep_sql is null then
      call ctc56m04_prepare()
   end if
  
   declare c_ctc56m04 cursor for
      select atldat,atlhor,atlmat,atlemp,clslinseq,clstxtstt
        from datkclstxt
       where clscod    = par_ctc56m04.clscod
         and ramcod    = par_ctc56m04.ramcod
         and rmemdlcod = par_ctc56m04.rmemdlcod
         and ciaempcod = par_ctc56m04.ciaempcod
         and clslin    = 1

   foreach c_ctc56m04 into a_ctc56m04[arr_aux].atldat,
                           a_ctc56m04[arr_aux].atlhor,
                           a_ctc56m04[arr_aux].atlmat,
                           ws.empcod,
                           a_ctc56m04[arr_aux].clslinseq,
                           a_ctc56m04[arr_aux].clstxtstt
       let a_ctc56m04[arr_aux].funnom = "NAO ENCONTRADO"
       select funnom
         into a_ctc56m04[arr_aux].funnom
         from isskfunc
        where empcod = ws.empcod
          and funmat = a_ctc56m04[arr_aux].atlmat

       if a_ctc56m04[arr_aux].clstxtstt = 1 then
          let a_ctc56m04[arr_aux].sttdes = "Ativo"
       else
          let a_ctc56m04[arr_aux].sttdes = "Cancelado"
       end if

       let arr_aux = arr_aux + 1
       if arr_aux > 300 then
           error " Limite excedido! Foram encontradas mais de 300",
                 " manutencoes para a Clausula!"
           exit foreach
        end if
   end foreach
   call set_count(arr_aux-1)

   open window w_ctc56m04 at 06,02 with form "ctc56m04"
       attribute(form line first)

   if arr_aux   >   1  then

      if par_ctc56m04.ciaempcod = 1  or   ## Empresa Porto
         par_ctc56m04.ciaempcod = 50 then ## Empresa Porto Saude

         if par_ctc56m04.ramcod = 31  or
            par_ctc56m04.ramcod = 531 then
            select clsdes
              into ws.clsdes
              from aackcls
             where clscod = par_ctc56m04.clscod
               and ramcod = par_ctc56m04.ramcod
               and tabnum = (select max(tabnum)
                               from aackcls
                              where clscod = par_ctc56m04.clscod
                                and ramcod = par_ctc56m04.ramcod)
         else
             open cctc56m04001 using par_ctc56m04.clscod      
                                    ,par_ctc56m04.ramcod      
                                    ,par_ctc56m04.rmemdlcod
                                    ,par_ctc56m04.clscod   
                                    ,par_ctc56m04.ramcod   
                                    ,par_ctc56m04.rmemdlcod
             whenever error continue
             fetch cctc56m04001 into ws.clsdes
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = notfound then
                   let ws.clsdes = null
                else
                   error 'Erro SELECT cctc56m04001: ',sqlca.sqlcode,' | ',sqlca.sqlerrd[2] sleep 2
                   error 'ctc56m04/ ctc56m04()/ ',par_ctc56m04.clscod   
                                           ,' / ',par_ctc56m04.ramcod   
                                           ,' / ',par_ctc56m04.rmemdlcod   
                                           ,' / ',par_ctc56m04.clscod   
                                           ,' / ',par_ctc56m04.ramcod   
                                           ,' / ',par_ctc56m04.rmemdlcod sleep 2
                   let l_ok = 1
                end if
             end if
         end if

      else
         if par_ctc56m04.ciaempcod = 35 then ## Empresa Azul
            ## obter a informacao
         end if
      end if

      if l_ok = 0 then
         select ramnom
           into ws.ramnom
           from gtakram
          where ramcod = par_ctc56m04.ramcod
            and empcod = 1
         
         display par_ctc56m04.ramcod    to ramcod
         display ws.ramnom              to ramnom
         display par_ctc56m04.rmemdlcod to rmemdlcod
         display par_ctc56m04.clscod    to clscod
         display ws.clsdes              to clsdes
         
         call set_count(arr_aux-1)
         
         display array  a_ctc56m04 to s_ctc56m04.*
         
           on key(interrupt)
              exit display
         
           on key(f8)
              let arr_aux = arr_curr()
              call ctc56m04_mostra_historico(par_ctc56m04.ciaempcod,
                                             par_ctc56m04.clscod,
                                             ws.clsdes,
                                             par_ctc56m04.ramcod,
                                             ws.ramnom,
                                             par_ctc56m04.rmemdlcod,
                                             a_ctc56m04[arr_aux].clslinseq,
                                             a_ctc56m04[arr_aux].atldat,
                                             a_ctc56m04[arr_aux].atlhor,
                                             a_ctc56m04[arr_aux].funnom)
         end display
      end if
   else
       error " Nao existe texto para Clausula "
   end if
   let int_flag = false
   close window w_ctc56m04
 end function

#------------------------------------------------------------------------------
 function ctc56m04_mostra_historico(param)
#------------------------------------------------------------------------------
   define param  record
       ciaempcod    like datkclstxt.ciaempcod,
       clscod       like datkclstxt.clscod,
       clsdes       char (20)             ,
       ramcod       like datkclstxt.ramcod,
       ramnom       char (20)             ,
       rmemdlcod    like datkclstxt.rmemdlcod,
       clslinseq    dec (3,0)             ,
       atldat       like datkclstxt.atldat,
       atlhor       like datkclstxt.atlhor,
       funnom       like isskfunc.funnom
   end record

   define a1_ctc56m04 array[300] of record
       clstxt       like datkclstxt.clstxt ,
       clslin       like datkclstxt.clslin
   end record

   define arr_aux   smallint
   define scr_aux   smallint
   define i         smallint


        define  w_pf1   integer

        let     arr_aux  =  null
        let     scr_aux  =  null
        let     i  =  null

        for     w_pf1  =  1  to  300
                initialize  a1_ctc56m04[w_pf1].*  to  null
        end     for

   initialize a1_ctc56m04  to null
   let arr_aux = 1
   let a1_ctc56m04[arr_aux].clstxt =
             "Em: ",  param.atldat clipped, "  ",
             "As: ",  param.atlhor clipped, "  ",
             "Por: ", upshift(param.funnom clipped)
   let arr_aux = arr_aux + 2

   declare c1_ctc56m04 cursor for
        select clstxt, clslin
           from datkclstxt
          where clscod    = param.clscod
            and ramcod    = param.ramcod
            and rmemdlcod = param.rmemdlcod
            and ciaempcod = param.ciaempcod
            and clslinseq = param.clslinseq
        order by clslin

   foreach c1_ctc56m04 into a1_ctc56m04[arr_aux].clstxt    ,
                            a1_ctc56m04[arr_aux].clslin
     let arr_aux = arr_aux + 1
     if arr_aux > 300 then
        error " Limite excedido! Foram encontradas mais de 300",
              " linhas de procedimento!!"
        exit foreach
     end if
   end foreach

   open window w_ctc56m01 at 06,02 with form "ctc56m01"
        attribute(form line first)

   display param.ramcod  to ramcod
   display param.ramnom  to ramnom
   display param.rmemdlcod  to rmemdlcod
   display param.clscod  to clscod
   display param.clsdes  to clsdes

   if arr_aux   >   1  then
      call set_count(arr_aux-1)
      display array  a1_ctc56m04 to s_ctc56m01.*
        on key(interrupt)
           exit display
      end display
   end if
   close window w_ctc56m01
 end function
