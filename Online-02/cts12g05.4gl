#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                  #
# Modulo.........: cts12g05                                                  #
# Objetivo.......: Lista de Naturezas a Residencia do Plano Itau RE          #
# Analista Resp. : Ligia Mattge                                              #
# PSI            :                                                           #
#............................................................................#
# Desenvolvimento: Ligia Mattge                                              #
# Liberacao      : ago/2012                                                  #
#............................................................................#
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepare  smallint

define mr_retorno array[500] of record
       socntzcod   like  datksocntz.socntzcod  ,
       socntzdes   like  datksocntz.socntzdes  ,
       utzlmtqtd   integer,
       grplmtqtd   integer,
       grpcod      like datkresitagrp.grpcod
end record

define mr_servicos   array[500] of record
       socntzcod     like datksocntz.socntzcod
      ,socntzdes     char(50)
      ,utiliz        integer
      ,limite        integer
      ,saldo         integer
      ,grpcod        integer
end record

define m_grupos record
       multiplo  char(1)
      ,socntzcod like datksocntz.socntzcod
end record

define m_asiplncod like datkresitaasipln.asiplncod


#------------------------------------------------------------------------------
function cts12g05_prepare()
#------------------------------------------------------------------------------

define l_sql char(10000)

  let l_sql = ' select a.socntzcod               '
          ,  '       , a.socntzdes               '
          ,  '       , b.ntzivcqtd               '
          ,  '       , b.grpivcqtd               '
          ,  '       , b.grpcod                  '
          ,  '   from datksocntz a               '
          ,  '      , datrntzasipln b            '
          ,  '  where a.socntzcod  = b.socntzcod '
          ,  '    and b.asiplncod = ?            '
          ,  '  order by a.socntzdes             '
 prepare p_cts12g05_001 from l_sql
 declare c_cts12g05_001 cursor for p_cts12g05_001


 let l_sql = ' select asiplncod  ',
             '  from datkresitaasipln ',
             '  where  ',
             '  srvcod = ? '
 prepare p_cts12g05_002 from l_sql
 declare c_cts12g05_002 cursor for p_cts12g05_002

 let l_sql = ' select ctonumflg  ',
             '  from datkresitagrp ',
             '  where  ',
             '  grpcod = ? '
 prepare p_cts12g05_003 from l_sql
 declare c_cts12g05_003 cursor for p_cts12g05_003


 let l_sql = " select count(*) ",
             " from datrgrpntz a, datksocntz b , datrempgrp c ",
             " where a.socntzcod = b.socntzcod ",
             " and  a.socntzgrpcod = c.socntzgrpcod ",
             " and b.socntzstt    = 'A'",
             " and c.empcod = ? ",
             " and c.c24astcod = ?" ,
             " and b.socntzcod = ?"
 prepare p_cts12g05_004 from l_sql
 declare c_cts12g05_004 cursor for p_cts12g05_004



 let l_sql = ' select grpcod '
            ,' from datrntzasipln '
            ,' where socntzcod = ? '
            ,' and asiplncod = ? '
 prepare p_cts12g05_005 from l_sql
 declare c_cts12g05_005 cursor for p_cts12g05_005

 let l_sql = ' select launumflg  ',
             '  from datkresitagrp ',
             '  where  ',
             '  grpcod = ? '
 prepare p_cts12g05_006 from l_sql
 declare c_cts12g05_006 cursor for p_cts12g05_006



end function

#------------------------------------------------------------------------------
function cts12g05_rec_natureza(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   srvcod like datkresitaasipln.srvcod
end record

define l_index  integer


for  l_index  =  1  to  500
   initialize  mr_retorno[l_index].* to  null
end  for


if m_prepare is null or
   m_prepare <> true then
   call cts12g05_prepare()
end if

   let l_index = 1
   let m_asiplncod = null


       whenever error continue
       open c_cts12g05_002 using lr_param.srvcod
       fetch c_cts12g05_002 into m_asiplncod
       whenever error stop


       open c_cts12g05_001 using m_asiplncod
       foreach c_cts12g05_001 into mr_retorno[l_index].socntzcod  ,
                                   mr_retorno[l_index].socntzdes  ,
                                   mr_retorno[l_index].utzlmtqtd  ,
                                   mr_retorno[l_index].grplmtqtd  ,
                                   mr_retorno[l_index].grpcod
           
           
           #-------------------------------------------------
           # Valida se o Plano tem Permissao por Assunto
           #-------------------------------------------------
           if ctc97m05_valida_plano(m_asiplncod                   ,
           	                        mr_retorno[l_index].grpcod    ,
                                    mr_retorno[l_index].socntzcod ) then
              #-------------------------------------------------
              # Valida se a Natureza tem Permissao por Assunto
              #-------------------------------------------------
      
              if not ctc97m05_valida_assunto(g_documento.c24astcod         ,
              	                             m_asiplncod                   ,
                                             mr_retorno[l_index].grpcod    ,
                                             mr_retorno[l_index].socntzcod ) then
                     
                    continue foreach
              end if
           end if
           let l_index = l_index + 1

       end foreach

   return l_index

end function

#--------------------------------------------------------------------------
function cts12g05(lr_param)
#--------------------------------------------------------------------------

define lr_param record
       itaasisrvcod  like datmresitaaplitm.srvcod
       ,multiplo      char(1)
       ,socntzcod     like datksocntz.socntzcod
end record

define lr_retorno   record
       sqlcode      integer
      ,msgerro      char(500)
      ,socntzcod    like datksocntz.socntzcod
end record

define t_cts12g05    array[500] of record
       socntzcod     like datksocntz.socntzcod
      ,socntzdes     char(50)
      ,utiliz        smallint
      ,limite        smallint
      ,saldo         smallint
end record

define l_limite    decimal(15,5)
      ,l_saldo     integer
      ,l_util      decimal(15,5)
      ,l_index     integer
      ,l_null      char(1)
      ,l_flag      smallint
      ,l_qtde      smallint
      ,arr_aux     integer
      ,l_existe    smallint
      ,l_tela      integer

   let l_limite            = 0
   let l_saldo             = 0
   let l_util              = 0
   let l_index             = 0
   let l_null              = null
   let l_qtde              = 0
   let arr_aux             = 0
   let l_existe            = false
   let m_grupos.multiplo   = null
   let m_grupos.socntzcod  = null

   let m_grupos.multiplo  = lr_param.multiplo
   let m_grupos.socntzcod = lr_param.socntzcod



   initialize lr_retorno.* to null


   for l_index  =  1  to  500
       initialize  mr_servicos[l_index].* to  null
   end for


   for l_tela  =  1  to  500
       initialize  t_cts12g05[l_tela].* to  null
   end for

   #------------------------------
   # Busca naturezas
   #------------------------------
   call cts12g05_carrega_array(lr_param.itaasisrvcod)
   returning l_qtde

   let l_tela = 0
   for l_index = 1 to l_qtde

       call cts12g05_verifica_grupo_assunto(mr_servicos[l_index].socntzcod)
       returning l_existe

       if l_existe = true then
          let l_tela = l_tela + 1
          let t_cts12g05[l_tela].socntzcod = mr_servicos[l_index].socntzcod
          let t_cts12g05[l_tela].socntzdes = mr_servicos[l_index].socntzdes
          let t_cts12g05[l_tela].utiliz    = mr_servicos[l_index].utiliz

          let t_cts12g05[l_tela].limite    = mr_servicos[l_index].limite
          let t_cts12g05[l_tela].saldo     = t_cts12g05[l_tela].limite - t_cts12g05[l_tela].utiliz
          
          if g_documento.c24astcod = 'R68' or  
          	 g_documento.c24astcod = 'R78' then
             let t_cts12g05[l_tela].utiliz  = null
             let t_cts12g05[l_tela].limite  = null
             let t_cts12g05[l_tela].saldo   = 1          
          end if
       else
          continue for
       end if
   end for

   #-------------------------------
   # Abre a tela
   #-------------------------------
   let g_rs_re[1].qtd_atd = 0
   open window w_cts12g05 at 07,4 with form "cts12g05"
   attribute(form line 1, border)

   let int_flag = false

   message "(F8)Seleciona                            "

   call set_count(l_tela)

   display array t_cts12g05 to s_cts12g05.*


      on key (F8)

         let arr_aux = arr_curr()

            if t_cts12g05[arr_aux].saldo > 0 then
               let lr_retorno.socntzcod = t_cts12g05[arr_aux].socntzcod
               let g_rs_re[1].socntzcod = lr_retorno.socntzcod
               let g_rs_re[1].qtd_atd   = g_rs_re[1].qtd_atd + 1
            else
               error "QUANTIDADE DE SERVICOS JA ESGOTADOS PARA A NATUREZA SELECIONADA" sleep 2
            end if
            exit display


      on key (interrupt,control-c,f17)
            exit display

   end display

   close window  w_cts12g05

   let int_flag = false

   return lr_retorno.socntzcod

end function

#--------------------------------------------------------------------------
function cts12g05_carrega_array(lr_param)
#--------------------------------------------------------------------------

define lr_param record
       srvcod       like datkresitaasipln.srvcod
end record

define l_index          integer                  ,
       l_qtde           integer                  ,
       l_contabiliza    char(1)                  ,
       l_utiliz_grp     integer                  ,
       l_grp            like datkresitagrp.grpcod,
       l_laudo          char(1)



   let l_index       = 0
   let l_qtde        = 0
   let l_contabiliza = null
   let l_utiliz_grp  = 0
   let l_grp         = null
   let l_laudo       = null


   for l_index  =  1  to  500
       initialize  mr_servicos[l_index].* to  null
   end for

   call cts12g05_rec_natureza(lr_param.srvcod)
   returning l_qtde

   #---------------------------
   # Carrega array tela
   #---------------------------
   # Retira o ultimo indice devido ao foreach utilizado na função.
   let l_qtde  = l_qtde - 1
   let l_laudo = "N"

   #-------------------------------
   # Recupera Codigo do Grupo
   #-------------------------------
   whenever error continue
   open c_cts12g05_005 using m_grupos.socntzcod,m_asiplncod
   fetch c_cts12g05_005 into l_grp
   whenever error stop

   #-------------------------------
   # Recupera Flag do Laudo
   #-------------------------------

   whenever error continue
   open c_cts12g05_006 using l_grp
   fetch c_cts12g05_006 into l_laudo
   whenever error stop
   
  
   for l_index = 1 to l_qtde

     if m_grupos.socntzcod is not null and
        m_grupos.multiplo = "S" then


         if l_laudo = 'S' then
           if l_grp = mr_retorno[l_index].grpcod then
              if mr_retorno[l_index].socntzcod <> m_grupos.socntzcod then
                 let mr_servicos[l_index].socntzcod = mr_retorno[l_index].socntzcod
                 let mr_servicos[l_index].socntzdes = mr_retorno[l_index].socntzdes
                 let mr_servicos[l_index].grpcod    = mr_retorno[l_index].grpcod

                 #------------------------------------
                 # Recupera Quantidade Utilizada
                 #------------------------------------
                 call cts65m01_qtd_servico(g_documento.itaciacod          ,
                                           g_documento.ramcod             ,
                                           g_documento.aplnumdig          ,
                                           g_documento.itmnumdig          ,
                                           mr_servicos[l_index].grpcod    ,                                           
                                           mr_servicos[l_index].socntzcod ,
                                           g_documento.c24astcod          )
                 returning mr_servicos[l_index].utiliz
                 
                       
                 #------------------------------------
                 # Recupera Flag de Contabilizacao
                 #------------------------------------
                 whenever error continue
                 open c_cts12g05_003 using mr_retorno[l_index].grpcod
                 fetch c_cts12g05_003 into l_contabiliza
                 whenever error stop


                  if l_contabiliza = "S" then
                     let mr_servicos[l_index].limite = mr_retorno[l_index].grplmtqtd
                  else
                     let mr_servicos[l_index].limite = mr_retorno[l_index].utzlmtqtd
                  end if
                  let mr_servicos[l_index].saldo = mr_servicos[l_index].limite - mr_servicos[l_index].utiliz
              end if
           else
              continue for
           end if
         else
            if mr_retorno[l_index].socntzcod <> m_grupos.socntzcod then
              let mr_servicos[l_index].socntzcod = mr_retorno[l_index].socntzcod
              let mr_servicos[l_index].socntzdes = mr_retorno[l_index].socntzdes
              let mr_servicos[l_index].grpcod    = mr_retorno[l_index].grpcod

              #------------------------------------
              # Recupera Quantidade Utilizada
              #------------------------------------
              call cts65m01_qtd_servico(g_documento.itaciacod          ,
                                        g_documento.ramcod             ,
                                        g_documento.aplnumdig          ,
                                        g_documento.itmnumdig          ,
                                        mr_servicos[l_index].grpcod    ,
                                        mr_servicos[l_index].socntzcod ,
                                        g_documento.c24astcod          )
              returning mr_servicos[l_index].utiliz   
              
              
              if l_grp = mr_servicos[l_index].grpcod then             	 
                 let mr_servicos[l_index].utiliz = mr_servicos[l_index].utiliz + g_rs_re[1].qtd_atd
              end if

              #------------------------------------
              # Recupera Flag de Contabilizacao
              #------------------------------------
              whenever error continue
		          let l_contabiliza = "N"
              open c_cts12g05_003 using mr_retorno[l_index].grpcod
              fetch c_cts12g05_003 into l_contabiliza
              whenever error stop


               if l_contabiliza = "S" then
                  let mr_servicos[l_index].limite = mr_retorno[l_index].grplmtqtd
               else
                  let mr_servicos[l_index].limite = mr_retorno[l_index].utzlmtqtd
               end if
               let mr_servicos[l_index].saldo  = mr_servicos[l_index].limite - mr_servicos[l_index].utiliz

            else
              continue for
            end if
         end if
     else
        let mr_servicos[l_index].socntzcod = mr_retorno[l_index].socntzcod
        let mr_servicos[l_index].socntzdes = mr_retorno[l_index].socntzdes
        let mr_servicos[l_index].grpcod    = mr_retorno[l_index].grpcod
        
        #------------------------------------
        # Recupera Quantidade Utilizada
        #------------------------------------
        call cts65m01_qtd_servico(g_documento.itaciacod           ,
                                  g_documento.ramcod              ,
                                  g_documento.aplnumdig           ,
                                  g_documento.itmnumdig           ,
                                  mr_servicos[l_index].grpcod     ,
                                  mr_servicos[l_index].socntzcod  ,
                                  g_documento.c24astcod           )
        returning mr_servicos[l_index].utiliz
        
        #------------------------------------
        # Recupera Flag de Contabilizacao
        #------------------------------------
        whenever error continue
        open c_cts12g05_003 using mr_retorno[l_index].grpcod
        fetch c_cts12g05_003 into l_contabiliza
        whenever error stop
        

        if l_contabiliza = "S" then
           let mr_servicos[l_index].limite = mr_retorno[l_index].grplmtqtd
        else
           let mr_servicos[l_index].limite = mr_retorno[l_index].utzlmtqtd
        end if
        let mr_servicos[l_index].saldo = mr_servicos[l_index].limite - mr_servicos[l_index].utiliz

     end if


   end for

   return l_qtde

end function

#--------------------------------------------------------
function cts12g05_verifica_saldo(lr_param)
#--------------------------------------------------------

define lr_param record
     asiplncod like datrntzasipln.asiplncod
end record

define lr_retorno record
     flag    smallint,
     sqlcode smallint,
     mens    char(500)
end record

define l_index integer,
       l_qtde  integer


   for l_index  =  1  to  500
       initialize  mr_servicos[l_index].* to  null
   end for

   initialize lr_retorno.* to null
   let l_index = 0
   let l_qtde  = 0
   let lr_retorno.flag = false
   #------------------------------------
   # Busca as Naturezas
   #------------------------------------
   
   call cts12g05_carrega_array(lr_param.asiplncod)
   returning l_qtde

    for l_index = 1 to l_qtde

       if mr_servicos[l_index].saldo > 0 then
          let lr_retorno.flag = true
       end if
    end for

    return lr_retorno.flag

end function

#--------------------------------------------------------
function cts12g05_verifica_grupo_assunto(lr_param)
#--------------------------------------------------------

define lr_param record
       socntzcod  like datksocntz.socntzcod
end record

define l_count integer
      ,l_existe smallint


  let l_existe = false
  let l_count  = 0

   #------------------------------------
   # Valida Grupo de Assunto
   #------------------------------------
   whenever error continue
   open c_cts12g05_004 using g_documento.ciaempcod
                            ,g_documento.c24astcod
                            ,lr_param.socntzcod
   fetch c_cts12g05_004 into l_count

   whenever error stop

   if l_count > 0 then
      let l_existe = true
   end if


  return l_existe

end function




