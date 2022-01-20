#-----------------------------------------------------------------------------#
# Porto Seguro Seguradora                                                     #
#.............................................................................#
# Sistema.......: Radar / Porto Socorro                                       #
# Modulo........: ctd18g00                                                    #
# Analista Resp.: Debora Vaz Paez                                             #
# PSI...........: 220710                                                      #
# Objetivo......: Buscar informacoes sobre o socorrista                       #
#.............................................................................#
# Desenvolvimento: Douglas Krein                                              #
# Liberacao......: 22/04/2008                                                 #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data       Autor Fabrica  PSI      Alteracao                                #
# --------   -------------  ------   -----------------------------------------#
# 06/04/09   Adriano Santos 239178   Inclusão da funcao de busca e atualiza   #
#                                    candidato que virou socorrista           #
#-----------------------------------------------------------------------------#

database porto

   define m_prep_sql smallint

#---------------------------
function ctd18g00_prepare()
#---------------------------
   
   define l_sql char(400)
   
   let l_sql = 'select srrcoddig, '
                    ,' srrnom, '
                    ,' pestip, '
                    ,' cgccpfnum, '
                    ,' cgcord, '
                    ,' cgccpfdig, '
                    ,' srrtip, '
                    ,' rdranlultdat, '
                    ,' rdranlsitcod, '
                    ,' socanlsitcod '
               ,' from datksrr '
              ,' where srrcoddig = ? ' 
   
   prepare pctd18g00001 from l_sql
   declare cctd18g00001 cursor for pctd18g00001 
   
   let l_sql = 'update datksrr '
              ,'   set rdranlultdat = ? '
              ,'      ,rdranlsitcod = ? '
              ,'      ,socanlsitcod = ? '
              ,' where srrcoddig = ? '

   prepare pctd18g00002 from l_sql             

   let l_sql = 'select srrcoddig, srrnom, nscdat, cnhnum, cnhautctg, cnhpridat, '
              ,'       rgenum, rgeufdcod, cgccpfnum, cgcord, cgccpfdig,srrstt '
              ,' from datksrr '
              ,' where cgccpfnum  = ? ' 
              ,' and  (cgcord is null or cgcord  = ?) ' 
              ,' and  cgccpfdig  = ? ' 
   
   prepare pctd18g00003 from l_sql
   declare cctd18g00003 cursor for pctd18g00003 
   
   let l_sql = 'select srrcoddig, srrnom, nscdat, cnhnum, cnhautctg, cnhpridat, '
              ,'       rgenum, rgeufdcod, cgccpfnum, cgcord, cgccpfdig,srrstt '
              ,' from datksrr '
              ,' where rgenum  = ? ' 
              ,' and  rgeufdcod  = ? ' 
   
   prepare pctd18g00004 from l_sql
   declare cctd18g00004 cursor for pctd18g00004
   
   let l_sql = 'select pstcndcod '
              ,' from dpakcnd '
              ,' where cgccpfnum  = ? ' 
              ,' and  (cgcord is null or cgcord  = ?) ' 
              ,' and  cgccpfdig  = ? ' 
   
   prepare pctd18g00005 from l_sql
   declare cctd18g00005 cursor for pctd18g00005 
   
   let l_sql = 'select pstcndcod '
              ,' from dpakcnd '
              ,' where cnhnum  = ? ' 
   
   prepare pctd18g00006 from l_sql
   declare cctd18g00006 cursor for pctd18g00006 
   
   let l_sql = 'select pstcndcod '
              ,' from dpakcnd '
              ,' where rgenum  = ? ' 
              ,' and  rgeufdcod  = ? ' 
   
   prepare pctd18g00007 from l_sql
   declare cctd18g00007 cursor for pctd18g00007 
   
   let l_sql = ' update dpakcnd '
                 ,' set srrcoddig = ? '
               ,' where pstcndcod = ? '
   prepare pctd18g00008 from l_sql
   
   let l_sql = 'select srrcoddig '
              ,' from dpakcnd '
              ,' where pstcndcod  = ? ' 
   
   prepare pctd18g00009 from l_sql
   declare cctd18g00009 cursor for pctd18g00009 
   
   let m_prep_sql = true

end function

#-------------------------------------------
function ctd18g00_inf_socorrista(l_srrcoddig)
#-------------------------------------------

   define l_srrcoddig  like datksrr.srrcoddig
         ,l_msg        char(200)
         
   define lr_retorno record 
                     erro         smallint
                    ,mensagem     char(100)
                    ,srrcoddig    like datksrr.srrcoddig         
                    ,srrnom       like datksrr.srrnom      
                    ,pestip       like datksrr.pestip      
                    ,cgccpfnum    like datksrr.cgccpfnum   
                    ,cgcord       like datksrr.cgcord      
                    ,cgccpfdig    like datksrr.cgccpfdig   
                    ,srrtip       like datksrr.srrtip      
                    ,rdranlultdat like datksrr.rdranlultdat
                    ,rdranlsitcod like datksrr.rdranlsitcod
                    ,socanlsitcod like datksrr.socanlsitcod
                     end record

   initialize lr_retorno to null
   let m_prep_sql = false
   
   if l_srrcoddig is null then
      let lr_retorno.erro = 3  
      let lr_retorno.mensagem = 'Parametro nulo'
      return lr_retorno.*
   end if

   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctd18g00_prepare()
   end if
   
   open cctd18g00001 using l_srrcoddig
   whenever error continue
   fetch cctd18g00001 into lr_retorno.srrcoddig   
                          ,lr_retorno.srrnom      
                          ,lr_retorno.pestip      
                          ,lr_retorno.cgccpfnum   
                          ,lr_retorno.cgcord      
                          ,lr_retorno.cgccpfdig   
                          ,lr_retorno.srrtip      
                          ,lr_retorno.rdranlultdat
                          ,lr_retorno.rdranlsitcod
                          ,lr_retorno.socanlsitcod
   whenever error stop
   
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let lr_retorno.erro = 2
         let lr_retorno.mensagem = 'Socorrista nao encontrado'
      else
         let lr_retorno.erro = 3                                       
         let lr_retorno.mensagem = 'ERRO ', sqlca.sqlcode, ' em datksrr'
      end if
   else
      let lr_retorno.erro = 1
   end if
   
   return lr_retorno.*
   
end function
   
#--------------------------------------------
function ctd18g00_update_socorrista(lr_param)
#--------------------------------------------

   define lr_param record
        l_data_hoje date
       ,l_sit_rd    smallint
       ,l_sit_ps    smallint
       ,l_data_bco  date
       ,l_srrcoddig like datksrr.srrcoddig
   end record
   
   define l_coderro  smallint 
         ,l_mensagem char(100)
   
   let l_coderro      = 1 
   let l_mensagem     = null

   let m_prep_sql = false
   
   if lr_param.l_srrcoddig is null then
      let l_coderro = 3  
      let l_mensagem = 'Parametro nulo'
      return l_coderro,l_mensagem 
   end if
   
   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctd18g00_prepare()
   end if

   whenever error continue
   execute pctd18g00002 using lr_param.l_data_hoje
                             ,lr_param.l_sit_rd
                             ,lr_param.l_sit_ps
                             ,lr_param.l_srrcoddig
   whenever error stop
   if sqlca.sqlcode <> 0 then
     let l_coderro = 3                                       
     let l_mensagem = 'ERRO ', sqlca.sqlcode, ' em datksrr'
   else
      let l_coderro = 1
   end if

return l_coderro
      ,l_mensagem
   
end function   

#-------------------------------------------
function ctd18g00_val_socorrista(lr_param)
#-------------------------------------------

   define lr_param record
          cgccpfnum    like datksrr.cgccpfnum
         ,cgcord       like datksrr.cgcord
         ,cgccpfdig    like datksrr.cgccpfdig 
         ,rgenum       like datksrr.rgenum
         ,rgeufdcod    like datksrr.rgeufdcod
         end record
         
   define lr_retorno record 
                     erro         smallint
                    ,mensagem     char(100)
                    ,srrcoddig    like datksrr.srrcoddig   
                    ,srrnom       like datksrr.srrnom      
                    ,nscdat       like datksrr.nscdat      
                    ,cnhnum       like datksrr.cnhnum
                    ,cnhautctg    like datksrr.cnhautctg
                    ,cnhpridat    like datksrr.cnhpridat
                    ,rgenum       like datksrr.rgenum
                    ,rgeufdcod    like datksrr.rgeufdcod
                    ,cgccpfnum    like datksrr.cgccpfnum   
                    ,cgcord       like datksrr.cgcord      
                    ,cgccpfdig    like datksrr.cgccpfdig   
                    ,srrstt       like datksrr.srrstt      
                     end record

   initialize lr_retorno to null
   let m_prep_sql = false
   
   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctd18g00_prepare()
   end if
   
   if lr_param.rgenum is null then

      if lr_param.cgcord = 0 then
         let lr_param.cgcord = null
      end if
   
      open cctd18g00003 using lr_param.cgccpfnum,
                              lr_param.cgcord,
                              lr_param.cgccpfdig
      whenever error continue
      fetch cctd18g00003 into lr_retorno.srrcoddig      
                             ,lr_retorno.srrnom      
                             ,lr_retorno.nscdat    
                             ,lr_retorno.cnhnum   
                             ,lr_retorno.cnhautctg
                             ,lr_retorno.cnhpridat 
                             ,lr_retorno.rgenum
                             ,lr_retorno.rgeufdcod
                             ,lr_retorno.cgccpfnum   
                             ,lr_retorno.cgcord      
                             ,lr_retorno.cgccpfdig   
                             ,lr_retorno.srrstt   
      whenever error stop
   else
      open cctd18g00004 using lr_param.rgenum,
                              lr_param.rgeufdcod
      whenever error continue
      fetch cctd18g00004 into lr_retorno.srrcoddig      
                             ,lr_retorno.srrnom      
                             ,lr_retorno.nscdat    
                             ,lr_retorno.cnhnum   
                             ,lr_retorno.cnhautctg
                             ,lr_retorno.cnhpridat 
                             ,lr_retorno.rgenum
                             ,lr_retorno.rgeufdcod
                             ,lr_retorno.cgccpfnum   
                             ,lr_retorno.cgcord      
                             ,lr_retorno.cgccpfdig   
                             ,lr_retorno.srrstt   
      whenever error stop
   end if
   
   
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let lr_retorno.erro = 2
         let lr_retorno.mensagem = 'Socorrista nao encontrado'
      else
         let lr_retorno.erro = 3                                       
         let lr_retorno.mensagem = 'ERRO ', sqlca.sqlcode, ' em datksrr'
      end if
   else
      let lr_retorno.erro = 1
   end if
   
   return lr_retorno.*
   
end function

#-------------------------------------------
function ctd18g00_dados_socor(l_tipo_retorno, l_srrcoddig)
#-------------------------------------------

   define l_tipo_retorno smallint,
          l_srrcoddig  like datksrr.srrcoddig
         ,l_msg        char(200)
         
   define lr_retorno record 
                     erro         smallint
                    ,mensagem     char(100)
                    ,srrcoddig    like datksrr.srrcoddig         
                    ,srrnom       like datksrr.srrnom      
                    ,pestip       like datksrr.pestip      
                    ,cgccpfnum    like datksrr.cgccpfnum   
                    ,cgcord       like datksrr.cgcord      
                    ,cgccpfdig    like datksrr.cgccpfdig   
                    ,srrtip       like datksrr.srrtip      
                    ,rdranlultdat like datksrr.rdranlultdat
                    ,rdranlsitcod like datksrr.rdranlsitcod
                    ,socanlsitcod like datksrr.socanlsitcod
                     end record

   initialize lr_retorno to null
   let m_prep_sql = false
   
   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctd18g00_prepare()
   end if
   
   open cctd18g00001 using l_srrcoddig
   whenever error continue
   fetch cctd18g00001 into lr_retorno.srrcoddig   
                          ,lr_retorno.srrnom      
                          ,lr_retorno.pestip      
                          ,lr_retorno.cgccpfnum   
                          ,lr_retorno.cgcord      
                          ,lr_retorno.cgccpfdig   
                          ,lr_retorno.srrtip      
                          ,lr_retorno.rdranlultdat
                          ,lr_retorno.rdranlsitcod
                          ,lr_retorno.socanlsitcod
   whenever error stop
   
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let lr_retorno.erro = 2
         let lr_retorno.mensagem = 'Socorrista nao encontrado'
      else
         let lr_retorno.erro = 3                                       
         let lr_retorno.mensagem = 'ERRO ', sqlca.sqlcode, ' em datksrr'
      end if
   else
      let lr_retorno.erro = 1
   end if

   if l_tipo_retorno = 1 then
      return lr_retorno.erro, lr_retorno.mensagem, lr_retorno.srrnom
   end if
   
end function


#-------------------------------------------
function ctd18g00_val_candidato(lr_param)   # PSI - 239178
#-------------------------------------------

   define lr_param record
          cgccpfnum    like dpakcnd.cgccpfnum
         ,cgcord       like dpakcnd.cgcord
         ,cgccpfdig    like dpakcnd.cgccpfdig 
         ,rgenum       like dpakcnd.rgenum
         ,rgeufdcod    like dpakcnd.rgeufdcod
         ,cnhnum       like dpakcnd.cnhnum
         ,srrcoddig    like dpakcnd.srrcoddig
         end record
   
   define l_pstcndcod    like dpakcnd.pstcndcod
         ,l_pstcndcod_2  like dpakcnd.srrcoddig     
         ,l_srrcoddig    like dpakcnd.srrcoddig
         ,l_coderro      smallint 
         ,l_mensagem     char(100)
         ,l_flag         smallint
         
   let l_pstcndcod = null
   let l_srrcoddig = null 
   let l_flag = 0 
   
   
   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctd18g00_prepare()
   end if
         
      
   if lr_param.cgcord = 0 then                           
      let lr_param.cgcord = null              
   end if                                                        
   open cctd18g00005 using lr_param.cgccpfnum,
                           lr_param.cgcord,   
                           lr_param.cgccpfdig 
   whenever error continue                    
   fetch cctd18g00005 into l_pstcndcod        
   whenever error stop 
   if sqlca.sqlcode <> 0 then
       open cctd18g00007 using lr_param.rgenum,
                               lr_param.rgeufdcod
       whenever error continue
       fetch cctd18g00007 into l_pstcndcod     
       whenever error stop
       if sqlca.sqlcode <> 0 then  
           open cctd18g00006 using lr_param.cnhnum
           whenever error continue                
           fetch cctd18g00006 into l_pstcndcod    
           whenever error stop   
       end if
   end if 
      
   if sqlca.sqlcode = 0 then 
      
      open cctd18g00009 using l_pstcndcod     
      whenever error continue
      fetch cctd18g00009 into l_srrcoddig     
      whenever error stop
      
      if l_srrcoddig is not null and l_srrcoddig <> "" and l_srrcoddig <> lr_param.srrcoddig then
          let l_coderro = 4                                       
          let l_mensagem = 'ERRO: CANDIDATO ENCONTRADO COM OUTRO CODIGO DE SOCORRISTA'
      else
           whenever error continue
           execute pctd18g00008 using lr_param.srrcoddig,  
                                      l_pstcndcod 
           whenever error stop
           if sqlca.sqlcode <> 0 then
             let l_coderro = 3                                       
             let l_mensagem = 'ERRO ', sqlca.sqlcode, ' em dpakcnd'
           else
              let l_coderro = 1
           end if
      end if
   else
      let l_coderro = 2                                       
      let l_mensagem = 'Candidato não encontrado'
   end if
   
   return l_coderro
         ,l_mensagem   
          
end function