#############################################################################
# Nome do Modulo: CTC19M01                                         Marcelo  #
#                                                                  Gilberto #
# Manutencao nos valores das diarias/seguro dos veiculos           Set/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 06/10/1998  PSI 7056-4   Gilberto     Gravar informacoes de atualizacao   #
#                                       quando valores forem modificados.   #
#---------------------------------------------------------------------------#
# 07/12/2000  PSI 10631-3  Wagner       Incluir mais um tipo de franquia    #
#                                       3- Franquia/rede                    #
#---------------------------------------------------------------------------#
# 17/01/2012  P1201-0083   Celso Y.     Impedir cadastro de mesma tarifa    #
#                                       para o mesmo grupo.                 #
#############################################################################

 database porto

# globals "glct.4gl"
globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_count  smallint
       ,m_viginc  like datklocaldiaria.viginc 
       ,m_vigfnl  like datklocaldiaria.vigfnl 
       ,m_fxafnl  like datklocaldiaria.fxafnl 
       ,m_fxainc  like datklocaldiaria.fxainc 
       ,m_erro    dec(1,0) 


#---------------------------------------------------------------
 function ctc19m01(param)
#---------------------------------------------------------------

   define param      record
      lcvcod         like datklocaldiaria.lcvcod      ,
      avivclcod      like datklocaldiaria.avivclcod
   end record

   define a_ctc19m01 array[200] of record
      lcvlojtip      like datklocaldiaria.lcvlojtip,
      lcvlojdes      char (04),
      lcvregprccod   like datklocaldiaria.lcvregprccod,
      viginc         like datklocaldiaria.viginc,      
      vigfnl         like datklocaldiaria.vigfnl,
      fxainc         like datklocaldiaria.fxainc,
      fxafnl         like datklocaldiaria.fxafnl,
      lcvvcldiavlr   LIKE datklocaldiaria.lcvvcldiavlr,        
      prtsgrvlr      LIKE datklocaldiaria.prtsgrvlr,
      lcvvclsgrvlr   like datklocaldiaria.lcvvclsgrvlr,
      diafxovlr      like datklocaldiaria.diafxovlr
   end record

   define arr_aux    smallint
   define scr_aux    smallint
         ,l_arr      smallint 

   define ws         record
      lcvvcldiavlr   like datklocaldiaria.lcvvcldiavlr,
      lcvvclsgrvlr   like datklocaldiaria.lcvvclsgrvlr,
      prtsgrvlr      LIKE datklocaldiaria.prtsgrvlr,
      diafxovlr      like datklocaldiaria.diafxovlr, 
      vigfnl         like datklocaldiaria.vigfnl, 
      fxafnl         like datklocaldiaria.fxafnl, 
      operacao       char (01)
   end record

   open window ctc19m01 at 13,02 with form "ctc19m01"
        attribute (form line first, border, comment line last - 2)

   message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

   declare c_ctc19m01 cursor for
      select lcvlojtip    ,                          
             lcvregprccod ,                       
             viginc       ,                       
             vigfnl       ,                       
             fxainc       ,                       
             fxafnl       ,                       
             lcvvcldiavlr ,                       
             prtsgrvlr    ,                       
             lcvvclsgrvlr ,                       
             diafxovlr                           
        from datklocaldiaria                      
       where lcvcod    = param.lcvcod   and
             avivclcod = param.avivclcod
       order by lcvlojtip, lcvregprccod

   let int_flag = false
   let l_arr    = 0  
   initialize a_ctc19m01  to null
   initialize ws.*        to null

   while not int_flag
      let arr_aux = 1

      foreach c_ctc19m01 into a_ctc19m01[arr_aux].lcvlojtip    ,
                              a_ctc19m01[arr_aux].lcvregprccod ,
                              a_ctc19m01[arr_aux].viginc       ,
                              a_ctc19m01[arr_aux].vigfnl       ,
                              a_ctc19m01[arr_aux].fxainc       ,
                              a_ctc19m01[arr_aux].fxafnl       ,
                              a_ctc19m01[arr_aux].lcvvcldiavlr ,
                              a_ctc19m01[arr_aux].prtsgrvlr    ,
                              a_ctc19m01[arr_aux].lcvvclsgrvlr ,
                              a_ctc19m01[arr_aux].diafxovlr    


         case a_ctc19m01[arr_aux].lcvlojtip
            when 1 let a_ctc19m01[arr_aux].lcvlojdes = "CORP"
            when 2 let a_ctc19m01[arr_aux].lcvlojdes = "FRAN"
            when 3 let a_ctc19m01[arr_aux].lcvlojdes = "FR/R"
         end case
         let arr_aux = arr_aux + 1
         if arr_aux > 200 then
            error " Limite de consulta excedido. AVISE A INFORMATICA!"
            let int_flag = true
            exit while
         end if
      end foreach

      call set_count(arr_aux-1)

      input array a_ctc19m01 without defaults from s_ctc19m01.*

      before row
         let arr_aux = arr_curr()
         let scr_aux = scr_line()
         let m_erro  = 0

         display a_ctc19m01[arr_aux].* to s_ctc19m01[scr_aux].*         
         if  a_ctc19m01[arr_aux].lcvvcldiavlr  is null and
             a_ctc19m01[arr_aux].lcvvclsgrvlr  is null and
             a_ctc19m01[arr_aux].diafxovlr     is null then
            let ws.operacao = "i"
         else 
            let ws.operacao = "a"
            let ws.lcvvcldiavlr = a_ctc19m01[arr_aux].lcvvcldiavlr
            let ws.lcvvclsgrvlr = a_ctc19m01[arr_aux].lcvvclsgrvlr
            let ws.prtsgrvlr    = a_ctc19m01[arr_aux].prtsgrvlr
            let ws.diafxovlr    = a_ctc19m01[arr_aux].diafxovlr
            let ws.vigfnl       = a_ctc19m01[arr_aux].vigfnl
            let ws.fxafnl       = a_ctc19m01[arr_aux].fxafnl
         end if

      before insert
         let ws.operacao = "i"
         initialize a_ctc19m01[arr_aux].* to null
         display a_ctc19m01[arr_aux].* to s_ctc19m01[scr_aux].*         

      before field lcvlojtip
         if ws.operacao = "a"  then
            display a_ctc19m01[arr_aux].lcvlojtip    to
                    s_ctc19m01[scr_aux].lcvlojtip
            next field vigfnl
         end if
         display a_ctc19m01[arr_aux].lcvlojtip    to
                 s_ctc19m01[scr_aux].lcvlojtip    attribute (reverse)

      after field lcvlojtip
         display a_ctc19m01[arr_aux].lcvlojtip    to
                 s_ctc19m01[scr_aux].lcvlojtip
         if  fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  or
             fgl_lastkey() = fgl_keyval("down")  then
             let l_arr = arr_aux + 1 
             if  a_ctc19m01[l_arr].lcvregprccod is null and 
                 fgl_lastkey() = fgl_keyval("down")  then
                 error " Dados da linha  nao foram  preenchidos!"
                 next field lcvlojtip 
             end if
         else

             if a_ctc19m01[arr_aux].lcvlojtip is null  then
                error " Tipo da loja deve ser informado !!"
                next field lcvlojtip
             end if

             case a_ctc19m01[arr_aux].lcvlojtip
                  when 1 let a_ctc19m01[arr_aux].lcvlojdes = "CORP"
                  when 2 let a_ctc19m01[arr_aux].lcvlojdes = "FRAN"
                  when 3 let a_ctc19m01[arr_aux].lcvlojdes = "FR/R"
                  otherwise
                     error " Tipo da loja deve ser 1-CORPORACAO, 2-FRANQUIA ou 3-FRANQUIA/REDE!"
                     next field lcvlojtip
             end case

             display a_ctc19m01[arr_aux].lcvlojdes    to
                     s_ctc19m01[scr_aux].lcvlojdes
          end if  


      before field lcvregprccod
         if  a_ctc19m01[arr_aux].lcvlojtip is null  then
             error " Tipo da loja deve ser informado !!"
             next field lcvlojtip
         end if
         if ws.operacao = "a"  then
            display a_ctc19m01[arr_aux].lcvregprccod to
                    s_ctc19m01[scr_aux].lcvregprccod
            next field vigfnl
         end if
         display a_ctc19m01[arr_aux].lcvregprccod to
                 s_ctc19m01[scr_aux].lcvregprccod attribute (reverse)

      after field lcvregprccod
         display a_ctc19m01[arr_aux].lcvregprccod to
                 s_ctc19m01[scr_aux].lcvregprccod
         if  fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  or
             fgl_lastkey() = fgl_keyval("down")  then
         else

             if a_ctc19m01[arr_aux].lcvregprccod is null  then
                 error " Codigo da regiao deve ser informado !!"
                 next field lcvregprccod
             end if

             if  a_ctc19m01[arr_aux].lcvregprccod < 1  or
                 a_ctc19m01[arr_aux].lcvregprccod > 3  then
                 error " Codigos de tarifa regional validos sao 1, 2 ou 3!"
                 next field lcvregprccod
             end if

         end if

      before field viginc 
         if  a_ctc19m01[arr_aux].lcvregprccod is null  then
             error " Codigo da regiao deve ser informado !!"
             next field lcvregprccod
         end if
         if ws.operacao = "a"  then
            display a_ctc19m01[arr_aux].viginc       to
                    s_ctc19m01[scr_aux].viginc
            next field vigfnl
         end if
         display a_ctc19m01[arr_aux].viginc  to
                 s_ctc19m01[scr_aux].viginc  attribute (reverse)

      after field viginc
         display a_ctc19m01[arr_aux].viginc       to
                 s_ctc19m01[scr_aux].viginc
         if  fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  or
             fgl_lastkey() = fgl_keyval("down")  then
         else
             if  a_ctc19m01[arr_aux].viginc  is null then
                 error " Informe a data de inicial de vigencia "
                 next field viginc
             else 
               #P1201-0083 Inicio
               whenever error continue
               select count(*)
                 into m_count
                 from datklocaldiaria
                where lcvcod = param.lcvcod
                  and avivclcod = param.avivclcod
                  and lcvlojtip = a_ctc19m01[arr_aux].lcvlojtip
                  and lcvregprccod = a_ctc19m01[arr_aux].lcvregprccod
                  and a_ctc19m01[arr_aux].viginc between
                      (select min(viginc)
                         from datklocaldiaria
                        where lcvcod = param.lcvcod 
                          and avivclcod = param.avivclcod 
                          and lcvlojtip = a_ctc19m01[arr_aux].lcvlojtip 
                          and lcvregprccod = a_ctc19m01[arr_aux].lcvregprccod)
                       and
                       (select max(vigfnl)
                         from datklocaldiaria
                        where lcvcod = param.lcvcod 
                          and avivclcod = param.avivclcod  
                          and lcvlojtip = a_ctc19m01[arr_aux].lcvlojtip  
                          and lcvregprccod = a_ctc19m01[arr_aux].lcvregprccod)
               whenever error stop

               #P1201-0083 Fim

               #select count(*) into m_count from datklocaldiaria
               #   where lcvcod       = param.lcvcod                     
               #     and avivclcod    = param.avivclcod                 
               #     and lcvlojtip    = a_ctc19m01[arr_aux].lcvlojtip   
               #     and lcvregprccod = a_ctc19m01[arr_aux].lcvregprccod
               #     and viginc       = a_ctc19m01[arr_aux].viginc       
#display "Ei:",param.lcvcod, "-",param.avivclcod, "-",a_ctc19m01[arr_aux].lcvlojtip, "-",a_ctc19m01[arr_aux].lcvregprccod,"-", a_ctc19m01[arr_aux].viginc 
 
                #display "m_count:",m_count
                
                #P1201-0083 Inicio
                if  m_count > 0   then
                   error "Ja existe cadastro para esta vigencia " 
                   next field viginc 
                end if
                #P1201-0083 Fim
             end if
         end if

      before field vigfnl
         if  a_ctc19m01[arr_aux].viginc  is null then
             error " Informe a data de inicial de vigencia "
             next field viginc
         end if 
         display a_ctc19m01[arr_aux].vigfnl  to
                 s_ctc19m01[scr_aux].vigfnl  attribute (reverse)

      after field vigfnl
         display a_ctc19m01[arr_aux].vigfnl       to
                 s_ctc19m01[scr_aux].vigfnl
         if  fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  or
             fgl_lastkey() = fgl_keyval("down")  then
         else
             if  a_ctc19m01[arr_aux].vigfnl  is null then
                 error " Informe a data final de vigencia "
                 next field vigfnl
             else 
                 if  a_ctc19m01[arr_aux].viginc >
                     a_ctc19m01[arr_aux].vigfnl then #?? 
                     error "Vigencia final menor que vigencia inicial"  
                     next field vigfnl 
                 end if
             end if
         end if

      before field fxainc 
         if  a_ctc19m01[arr_aux].vigfnl  is null then
             error " Informe a data final de vigencia "
             next field vigfnl
         end if  
         if ws.operacao = "a"  then
            display a_ctc19m01[arr_aux].fxainc       to
                    s_ctc19m01[scr_aux].fxainc 
            next field fxafnl
         end if
         display a_ctc19m01[arr_aux].fxainc  to
                 s_ctc19m01[scr_aux].fxainc  attribute (reverse)

      after field fxainc
         display a_ctc19m01[arr_aux].fxainc       to
                 s_ctc19m01[scr_aux].fxainc
         if  fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  or
             fgl_lastkey() = fgl_keyval("down")  then
         else
             if  a_ctc19m01[arr_aux].fxainc  is null or  
                 a_ctc19m01[arr_aux].fxainc  =  0  then
                 error " Informe a faixa inicial valida "
                 next field fxainc
             else 
                 if  ws.operacao          =   "i"   then  
                     let     m_fxafnl     =  null 
                     select  max(fxafnl) into m_fxafnl from datklocaldiaria #?
                      where  lcvcod       =  param.lcvcod                     
                        and  avivclcod    =  param.avivclcod                 
                        and  lcvlojtip    =  a_ctc19m01[arr_aux].lcvlojtip   
                        and  lcvregprccod =  a_ctc19m01[arr_aux].lcvregprccod
                        and  viginc       =  a_ctc19m01[arr_aux].viginc       
                        and  fxainc       =  a_ctc19m01[arr_aux].fxainc       
                     if  m_fxafnl is not null  then 
                         error "Faixa ja' cadastrada "  
                         next field fxainc 
                     end if
                 end if
             end if
         end if

      before field fxafnl 
         if  a_ctc19m01[arr_aux].fxainc  is null then   
             error " Informe a faixa inicial valida "
             next field fxainc
         end if 
         display a_ctc19m01[arr_aux].fxafnl  to
                 s_ctc19m01[scr_aux].fxafnl  attribute (reverse)

      after field fxafnl
         display a_ctc19m01[arr_aux].fxafnl       to
                 s_ctc19m01[scr_aux].fxafnl
         if  fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  or
             fgl_lastkey() = fgl_keyval("down")  then
         else
             if  a_ctc19m01[arr_aux].fxafnl  is null                       or 
                (a_ctc19m01[arr_aux].fxainc > a_ctc19m01[arr_aux].fxafnl ) or
                 a_ctc19m01[arr_aux].fxafnl  =  0                          then
                 error " Informe a faixa final valida  "
                 next field fxafnl
             end if
         end if

      before field lcvvcldiavlr
         if  a_ctc19m01[arr_aux].fxafnl  is null then   
             error " Informe a faixa final valida "
             next field fxafnl
         end if 
         display a_ctc19m01[arr_aux].lcvvcldiavlr to
                 s_ctc19m01[scr_aux].lcvvcldiavlr attribute (reverse)

      after field lcvvcldiavlr
         display a_ctc19m01[arr_aux].lcvvcldiavlr to
                 s_ctc19m01[scr_aux].lcvvcldiavlr
         if  fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  or
             fgl_lastkey() = fgl_keyval("down")  then
         else 
             if a_ctc19m01[arr_aux].lcvvcldiavlr is null  then
                error " Valor da diaria deve ser informado !!"
                next field lcvvcldiavlr
             end if
         end if

      before field prtsgrvlr    
         if  a_ctc19m01[arr_aux].lcvvcldiavlr  is null then   
             error " Informe o valor da diaria "
             next field lcvvcldiavlr
         end if 
         let m_erro  =  0 
         display a_ctc19m01[arr_aux].prtsgrvlr  to
                 s_ctc19m01[scr_aux].prtsgrvlr  attribute (reverse)

      after field prtsgrvlr 
         display a_ctc19m01[arr_aux].prtsgrvlr  to 
                 s_ctc19m01[scr_aux].prtsgrvlr 

         if  fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  or
             fgl_lastkey() = fgl_keyval("down")  then
         else 
             if a_ctc19m01[arr_aux].prtsgrvlr  is null  then
                error " Valor Porto  deve ser informado !!"
                next field prtsgrvlr
             end if
             if a_ctc19m01[arr_aux].diafxovlr  > 0   and 
                a_ctc19m01[arr_aux].prtsgrvlr  > 0   then
                error "Informe Valor fixo ou Valor Porto " 
                let m_erro = 1 
                next field diafxovlr
             end if 
         end if

      before field lcvvclsgrvlr 
         if  a_ctc19m01[arr_aux].prtsgrvlr  is null then   
             error " Informe o valor do seguro      "
             next field prtsgrvlr     
         end if 
         display a_ctc19m01[arr_aux].lcvvclsgrvlr  to
                 s_ctc19m01[scr_aux].lcvvclsgrvlr  attribute (reverse)

      after field lcvvclsgrvlr
         display a_ctc19m01[arr_aux].lcvvclsgrvlr to
                 s_ctc19m01[scr_aux].lcvvclsgrvlr

         if  fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  or
             fgl_lastkey() = fgl_keyval("down")  then
         else 
             if a_ctc19m01[arr_aux].lcvvclsgrvlr is null  then
                error " Valor do seguro deve ser informado !!"
                next field lcvvclsgrvlr
             end if
         end if

      before field diafxovlr   
         if  a_ctc19m01[arr_aux].lcvvclsgrvlr  is null then   
             error " Informe o valor do seguro "
             next field lcvvclsgrvlr
         end if 
         let m_erro  =  0 
         display a_ctc19m01[arr_aux].diafxovlr to
                 s_ctc19m01[scr_aux].diafxovlr attribute (reverse)

      after field diafxovlr
         display a_ctc19m01[arr_aux].diafxovlr to 
                 s_ctc19m01[scr_aux].diafxovlr

         if  fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  or
             fgl_lastkey() = fgl_keyval("down")  then
         else 
             if a_ctc19m01[arr_aux].diafxovlr is null  then
                error " Valor Fixo  deve ser informado !!"
                next field diafxovlr    
             end if
             if a_ctc19m01[arr_aux].diafxovlr  > 0   and 
                a_ctc19m01[arr_aux].prtsgrvlr  > 0   then
                error "Informe Valor fixo ou Valor Porto " 
                let m_erro = 1 
                next field diafxovlr 
             end if
               
         end if

      before delete
            let ws.operacao = "d"

            if a_ctc19m01[arr_aux].lcvregprccod is null   then
               continue  INPUT 
            else
               if cts08g01("A","S","","CONFIRMA A EXCLUSAO ?","","") = "N"  then
                  exit input
               end if

               delete from datklocaldiaria
                where lcvcod       = param.lcvcod                     and
                      avivclcod    = param.avivclcod                  and
                      lcvlojtip    = a_ctc19m01[arr_aux].lcvlojtip    and
                      lcvregprccod = a_ctc19m01[arr_aux].lcvregprccod

               if sqlca.sqlcode <> 0    then
                  error " Erro (",sqlca.sqlcode,") na exclusao dos valores!"
               end if

               initialize a_ctc19m01[arr_aux].* to null
               display a_ctc19m01[arr_aux].*    to s_ctc19m01[scr_aux].*
            end if

      on key (interrupt)
         exit input


      after row
         if  a_ctc19m01[arr_aux].prtsgrvlr > 0 and
             a_ctc19m01[arr_aux].diafxovlr > 0 then 
             error "Informe somente Valor Porto ou Valor Fixo " 
             next field diafxovlr 
         else                          
         if  a_ctc19m01[arr_aux].lcvregprccod is null  or
             a_ctc19m01[arr_aux].lcvvcldiavlr is null  or
             a_ctc19m01[arr_aux].lcvvclsgrvlr is null  then
             let ws.operacao = " " 
             display a_ctc19m01[arr_aux].*    to s_ctc19m01[scr_aux].*
         end if
         case ws.operacao
         when "i"

            insert into datklocaldiaria
                        ( lcvcod, avivclcod, lcvlojtip, lcvregprccod,
                          lcvvcldiavlr, lcvvclsgrvlr, viginc, vigfnl, 
                          fxainc, fxafnl, diafxovlr,prtsgrvlr  )
                 values ( param.lcvcod                     ,      
                          param.avivclcod                  ,      
                          a_ctc19m01[arr_aux].lcvlojtip    ,      
                          a_ctc19m01[arr_aux].lcvregprccod ,      
                          a_ctc19m01[arr_aux].lcvvcldiavlr ,      
                          a_ctc19m01[arr_aux].lcvvclsgrvlr ,
                          a_ctc19m01[arr_aux].viginc       ,
                          a_ctc19m01[arr_aux].vigfnl       ,
                          a_ctc19m01[arr_aux].fxainc       ,
                          a_ctc19m01[arr_aux].fxafnl       ,
                          a_ctc19m01[arr_aux].diafxovlr    ,
                          a_ctc19m01[arr_aux].prtsgrvlr)

            if sqlca.sqlcode <> 0 then
               error " Erro (", sqlca.sqlcode, ") na inclusao dos valores. AVISE A INFORMATICA!"
               return
            end if

            display a_ctc19m01[arr_aux].* to s_ctc19m01[scr_aux].*

	 when "a"
            if ws.lcvvcldiavlr <> a_ctc19m01[arr_aux].lcvvcldiavlr  or
               ws.lcvvclsgrvlr <> a_ctc19m01[arr_aux].lcvvclsgrvlr  or 
               ws.diafxovlr    <> a_ctc19m01[arr_aux].diafxovlr     or
               ws.fxafnl       <> a_ctc19m01[arr_aux].fxafnl        or 
               ws.vigfnl       <> a_ctc19m01[arr_aux].vigfnl        or 
               ws.prtsgrvlr    <> a_ctc19m01[arr_aux].prtsgrvlr     then
               begin work
               update datklocaldiaria 
               set ( lcvvcldiavlr, lcvvclsgrvlr, diafxovlr
                   , prtsgrvlr , fxafnl , vigfnl  )
                       = (a_ctc19m01[arr_aux].lcvvcldiavlr,
                          a_ctc19m01[arr_aux].lcvvclsgrvlr, 
                          a_ctc19m01[arr_aux].diafxovlr   ,
                          a_ctc19m01[arr_aux].prtsgrvlr   ,
                          a_ctc19m01[arr_aux].fxafnl      ,
                          a_ctc19m01[arr_aux].vigfnl   )  
                where lcvcod       = param.lcvcod                    
                  and avivclcod    = param.avivclcod                 
                  and lcvlojtip    = a_ctc19m01[arr_aux].lcvlojtip    
                  and lcvregprccod = a_ctc19m01[arr_aux].lcvregprccod 
                  and viginc       = a_ctc19m01[arr_aux].viginc      
                  and fxainc       = a_ctc19m01[arr_aux].fxainc   

               if sqlca.sqlcode <> 0 then
                  error " Erro (", sqlca.sqlcode, ") na alteracao dos valores. AVISE A INFORMATICA!"
                  rollback work
                  return
               end if

               update datkavisveic
                  set (atlemp, atlmat, atldat)
                    = (g_issk.empcod, g_issk.funmat, today)
                where lcvcod    = param.lcvcod     and
                      avivclcod = param.avivclcod

               if sqlca.sqlcode <> 0 then
                  error " Erro (", sqlca.sqlcode, ") na atualizacao dos dados. AVISE A INFORMATICA!"
                  rollback work
                  return
               end if
               commit work
            end if
         end case

         let ws.operacao = " "
       end if 

      end input

      if int_flag  then
         exit while
      end if

   end while

   close window ctc19m01
   let int_flag = false

end function  ###  ctc19m01
