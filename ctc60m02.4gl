#-----------------------------------------------------------------------------#  
#              *** Porto  Seguro  Cia.  de  Seguros  Gerais ***               #  
#.............................................................................#  
#                                                                             #  
# Sistema.: Ct24hs   - Central 24hs e Pronto Socorro                          #  
# Modulo..: ctc60m02 - Manutencao Veiculos                                    #  
# Analista: Wagner Agostinho                                                  #  
# PSI.....:                  OSF: 10570                                       #  
#                                                                             #  
# Desenvolvimento: Fabrica de Software  -  Talita Menezes - DEZ/02            #  
#-----------------------------------------------------------------------------#  
# Alteracoes:                                                                 #  
#                                                                             #  
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #  
#-----------------------------------------------------------------------------#  
# 19/02/2003  PAS ???????  Zyon         Retirada do campo "Controle"          #  
#-----------------------------------------------------------------------------#  
# 05/04/09    PSI 237337   Kevellin     Adaptações atendimento PSI 237337     #  
#-----------------------------------------------------------------------------#  
# 09/09/2009  PSI 247596   Burini       Restrição no campo DDD/celular        #  
#-----------------------------------------------------------------------------#  
# 30/08/2010  PAS103306    Beatriz    Verifica em um dominio departamentos que#  
#                                     podem alterar o celular da viatura      #  
#-----------------------------------------------------------------------------#  
  
#globals  "/homedsa/projetos/geral/globals/glre.4gl"  
  
globals "/homedsa/projetos/geral/globals/glct.4gl"  
  
#-----------------------------------------------------------------------------#  
function ctc60m02()  
#-----------------------------------------------------------------------------#  
  
   define l_ctc60m02       record  
          atdvclsgl        like datkveiculo.atdvclsgl  
         ,socvclcod        like datkveiculo.socvclcod  
         ,vcldtbgrpcod     like dattfrotalocal.vcldtbgrpcod  
         ,vcldtbgrpdes     like datkvcldtbgrp.vcldtbgrpdes  
         ,atdimpcod        like datkveiculo.atdimpcod  
         ,mdtcod           like datkveiculo.mdtcod  
         ,pgrnum           like datkveiculo.pgrnum  
         ,celdddcod        like datkveiculo.celdddcod  
         ,celtelnum        like datkveiculo.celtelnum  
         ,nxtide           like datkveiculo.nxtide  
         ,nxtdddcod        like datkveiculo.nxtdddcod  
         ,nxtnum           like datkveiculo.nxtnum  
   end record  
  
   define l_posicao        smallint  
         ,l_cmd            char(150)  
         ,ant_socvclcod    like datkveiculo.socvclcod  
         
        
        let     l_posicao  =  null  
        let     l_cmd  =  null  
        let     ant_socvclcod  =  null  
  
        initialize  l_ctc60m02.*  to  null  
  
   initialize l_ctc60m02.* to null  
  
   open window ctc60m02 at 4,2 with form "ctc60m02"  
     attribute (form line 1, message  line last)  
  
   let int_flag    = false  
  
   clear form  
  
   let l_cmd = " select atdvclsgl "  
                    ," ,socvclcod "  
                    ," ,atdimpcod "  
                    ," ,mdtcod "  
                    ," ,pgrnum "  
                    ," ,celdddcod "  
                    ," ,celtelnum "  
                    ," ,nxtide "  
                    ," ,nxtdddcod "  
                ," from datkveiculo "  
               ," where socvclcod >= ? "  
   prepare pctc60m02001 from l_cmd  
   declare cctc60m02001 scroll cursor for pctc60m02001  
  
   let l_cmd = " select vcldtbgrpcod "  
                ," from dattfrotalocal "  
               ," where socvclcod = ? "  
   prepare pctc60m02004 from l_cmd  
   declare cctc60m02004 scroll cursor for pctc60m02004  
  
   let l_cmd = " select vcldtbgrpdes "  
                ," from datkvcldtbgrp "  
               ," where vcldtbgrpcod = ? "  
   prepare pctc60m02005 from l_cmd  
   declare cctc60m02005 scroll cursor for pctc60m02005  
     
   let l_cmd ="select cpodes ",                              
              " from iddkdominio ",                       
             " where iddkdominio.cponom = ? ",             
               " and iddkdominio.cpodes = ? "   
                           
  prepare pctc60m02009 from l_cmd                 
  declare cctc60m02009 cursor for pctc60m02009  
    
     
     
  
   menu "PRESTADOR"  
  
      command key ("S") "Seleciona"   "Consulta Veiculos"  
              call seleciona_ctc60m02()  
                 returning l_ctc60m02.*  
  
      command key ("P") "Proximo"     "Consulta o Proximo Veiculo"  
              if (l_ctc60m02.atdvclsgl is null or  
                  l_ctc60m02.atdvclsgl =  " ") and  
                 (l_ctc60m02.socvclcod is null or  
                  l_ctc60m02.socvclcod =  0  ) then  
                 error "Nenhum Veiculo selecionado !"  
                 next option "Seleciona"  
              else  
                 call scroll_ctc60m02(+1)  
                    returning l_ctc60m02.*  
                             ,int_flag  
  
                 if int_flag then  
                    let int_flag = false  
                    error "Voce ja esta no ultimo Veiculo"  
                    next option "Anterior"  
                 else  
                    display by name l_ctc60m02.*  
                 end if  
              end if  
  
      command key ("A") "Anterior"    "Consulta o Veiculo Anterior"  
              if (l_ctc60m02.atdvclsgl is null or  
                  l_ctc60m02.atdvclsgl =  " ") and  
                 (l_ctc60m02.socvclcod is null or  
                  l_ctc60m02.socvclcod =  0  ) then  
                 error "Nenhum Veiculo selecionado !"  
                 next option "Seleciona"  
              else  
                 call scroll_ctc60m02(-1)  
                    returning l_ctc60m02.*  
                             ,int_flag  
  
                 if int_flag then  
                    let int_flag = false  
                    error "Voce ja esta no primeiro Veiculo"  
                    if l_ctc60m02.socvclcod is null then  
                       let l_ctc60m02.socvclcod = ant_socvclcod  
                    end if  
                    next option "Proximo"  
                 else  
                    display by name l_ctc60m02.*  
                 end if  
  
                 let ant_socvclcod = l_ctc60m02.socvclcod  
  
              end if  
  
  
      command key ("M") "Manutencao"  "Manutencao de Veiculoes"  
              if (l_ctc60m02.atdvclsgl is null or  
                  l_ctc60m02.atdvclsgl =  " ") and  
                 (l_ctc60m02.socvclcod is null or  
                  l_ctc60m02.socvclcod =  0  ) then  
                 error "Nenhum Veiculo selecionado !"  
                 next option "Seleciona"  
              else  
                 call manutenir_ctc60m02(l_ctc60m02.*)  
              end if  
  
      command key (interrupt, "E") "Encerra" "Retorna ao menu anterior "  
                   message " "  
                   exit menu  
   end menu  
  
   close window ctc60m02  
  
   return  
  
end function  
  
#-----------------------------------------------------------------------------#  
function seleciona_ctc60m02()  
#-----------------------------------------------------------------------------#  
  
   define l_ctc60m02       record  
          atdvclsgl        like datkveiculo.atdvclsgl  
         ,socvclcod        like datkveiculo.socvclcod  
         ,vcldtbgrpcod     like dattfrotalocal.vcldtbgrpcod  
         ,vcldtbgrpdes     like datkvcldtbgrp.vcldtbgrpdes  
         ,atdimpcod        like datkveiculo.atdimpcod  
         ,mdtcod           like datkveiculo.mdtcod  
         ,pgrnum           like datkveiculo.pgrnum  
         ,celdddcod        like datkveiculo.celdddcod  
         ,celtelnum        like datkveiculo.celtelnum  
         ,nxtide           like datkveiculo.nxtide  
         ,nxtdddcod        like datkveiculo.nxtdddcod  
         ,nxtnum           like datkveiculo.nxtnum  
   end record  
  
   initialize  l_ctc60m02.*  to  null  
  
   initialize l_ctc60m02.* to null  
   clear form  
  
   call ctc60m02_input("S",l_ctc60m02.*)  
      returning l_ctc60m02.*  
  
   if int_flag then  
      error " Operacao Cancelada! "  
      let int_flag = false  
      return l_ctc60m02.*  
   end if  
  
   open cctc60m02001 using l_ctc60m02.socvclcod  
  
   return l_ctc60m02.*  
  
end function  
  
#-----------------------------------------------------------------------------#  
function ctc60m02_input(aux_manut,l_ctc60m02)  
#-----------------------------------------------------------------------------#  
  
   define l_ctc60m02       record  
          atdvclsgl        like datkveiculo.atdvclsgl  
         ,socvclcod        like datkveiculo.socvclcod  
         ,vcldtbgrpcod     like dattfrotalocal.vcldtbgrpcod  
         ,vcldtbgrpdes     like datkvcldtbgrp.vcldtbgrpdes  
         ,atdimpcod        like datkveiculo.atdimpcod  
         ,mdtcod           like datkveiculo.mdtcod  
         ,pgrnum           like datkveiculo.pgrnum  
         ,celdddcod        like datkveiculo.celdddcod  
         ,celtelnum        like datkveiculo.celtelnum  
         ,nxtide           like datkveiculo.nxtide  
         ,nxtdddcod        like datkveiculo.nxtdddcod  
         ,nxtnum           like datkveiculo.nxtnum  
   end record  
     
   define ws            record  
     celdddcod          like datkveiculo.celdddcod,  
     celtelnum          like datkveiculo.celtelnum      
   end record     
  
    define ctc60m02_depatl record                 
      depatlflg          like iddkdominio.cponom,
      depatldes          like iddkdominio.cpodes 
    end record       
  
   define aux_manut        char(01)  
  
   let ctc60m02_depatl.depatlflg = 'ctc34m01_depatl'
  
  
   input by name l_ctc60m02.atdvclsgl  
                ,l_ctc60m02.socvclcod  
                ,l_ctc60m02.vcldtbgrpcod  
                ,l_ctc60m02.atdimpcod  
                ,l_ctc60m02.mdtcod  
                ,l_ctc60m02.pgrnum  
                ,l_ctc60m02.celdddcod  
                ,l_ctc60m02.celtelnum  
                ,l_ctc60m02.nxtide  
                ,l_ctc60m02.nxtdddcod  
                ,l_ctc60m02.nxtnum without defaults  
  
      before input   
         let ws.celdddcod = l_ctc60m02.celdddcod  
         let ws.celtelnum = l_ctc60m02.celtelnum        
  
      before field atdvclsgl  
         if aux_manut = "M" then  
            next field vcldtbgrpcod  
         end if  
         display by name l_ctc60m02.atdvclsgl attribute(reverse)  
  
      after field atdvclsgl  
         display by name l_ctc60m02.atdvclsgl  
  
         if l_ctc60m02.atdvclsgl is not null or  
            l_ctc60m02.atdvclsgl <>  " "     then  
            #---[ Valida a Sigla do Veiculo ]---#  
            #####################################  
            declare cctc60m02002 cursor with hold for  
               select socvclcod  
                     ,atdvclsgl  
                     ,atdimpcod  
                     ,mdtcod  
                     ,pgrnum  
                     ,celdddcod  
                     ,celtelnum  
                     ,nxtide  
                     ,nxtdddcod  
                     ,nxtnum  
                 from datkveiculo  
                where atdvclsgl = l_ctc60m02.atdvclsgl  
  
            open cctc60m02002  
            fetch cctc60m02002 into l_ctc60m02.socvclcod  
                                   ,l_ctc60m02.atdvclsgl  
                                   ,l_ctc60m02.atdimpcod  
                                   ,l_ctc60m02.mdtcod  
                                   ,l_ctc60m02.pgrnum  
                                   ,l_ctc60m02.celdddcod  
                                   ,l_ctc60m02.celtelnum  
                                   ,l_ctc60m02.nxtide  
                                   ,l_ctc60m02.nxtdddcod  
                                   ,l_ctc60m02.nxtnum  
  
            if sqlca.sqlcode <> 0 then  
               error " Sigla nao cadastrada! "  
               initialize l_ctc60m02.* to null  
               clear form  
               next field atdvclsgl  
            end if  
  
            #---[ Valida Codigo do Grupo ]---#  
            ##################################  
            open cctc60m02004 using l_ctc60m02.socvclcod  
            fetch cctc60m02004 into l_ctc60m02.vcldtbgrpcod  
  
            if sqlca.sqlcode <> 0 then  
               error " Codigo do Grupo nao cadastrado! "  
               next field atdvclsgl  
            end if  
  
            #---[ Valida Descricao do Grupo ]---#  
            #####################################  
            open cctc60m02005 using l_ctc60m02.vcldtbgrpcod  
            fetch cctc60m02005 into l_ctc60m02.vcldtbgrpdes  
  
            if sqlca.sqlcode <> 0 then  
               error " Grupo nao cadastrado! "  
               next field atdvclsgl  
            end if  
  
            display by name l_ctc60m02.*  
  
            if aux_manut = "S" then  
               exit input  
            end if  
         end if  
  
      before field socvclcod  
         if aux_manut = "M" then  
            next field vcldtbgrpcod  
         end if  
         display by name l_ctc60m02.socvclcod attribute(reverse)  
  
      after field socvclcod  
         display by name l_ctc60m02.socvclcod  
  
         if fgl_lastkey() = fgl_keyval("up")   or  
            fgl_lastkey() = fgl_keyval("left") then  
            next field atdvclsgl  
         end if  
  
         if (l_ctc60m02.atdvclsgl is null  or  
             l_ctc60m02.atdvclsgl =  " " ) and  
            (l_ctc60m02.socvclcod is null  or  
             l_ctc60m02.socvclcod =  0   ) then  
            error " Informe algum dado para pesquisa! "  
            next field socvclcod  
         end if  
  
         #---[ Valida Codigo do Veiculo ]---#  
         ####################################  
         declare cctc60m02003 cursor with hold for  
            select socvclcod  
                  ,atdvclsgl  
                  ,atdimpcod  
                  ,mdtcod  
                  ,pgrnum  
                  ,celdddcod  
                  ,celtelnum  
                  ,nxtide  
                  ,nxtdddcod  
                  ,nxtnum  
              from datkveiculo  
             where socvclcod = l_ctc60m02.socvclcod  
  
         open cctc60m02003  
         fetch cctc60m02003 into l_ctc60m02.socvclcod  
                                ,l_ctc60m02.atdvclsgl  
                                ,l_ctc60m02.atdimpcod  
                                ,l_ctc60m02.mdtcod  
                                ,l_ctc60m02.pgrnum  
                                ,l_ctc60m02.celdddcod  
                                ,l_ctc60m02.celtelnum  
                                ,l_ctc60m02.nxtide  
                                ,l_ctc60m02.nxtdddcod  
                                ,l_ctc60m02.nxtnum  
  
         if sqlca.sqlcode <> 0 then  
            error " Veiculo nao cadastrado! "  
            initialize l_ctc60m02.* to null  
            clear form  
            next field socvclcod  
         end if  
  
         #---[ Valida Codigo do Grupo ]---#  
         ##################################  
         open cctc60m02004 using l_ctc60m02.socvclcod  
         fetch cctc60m02004 into l_ctc60m02.vcldtbgrpcod  
  
         if sqlca.sqlcode <> 0 then  
            error " Codigo do Grupo nao cadastrado! "  
            next field atdvclsgl  
         end if  
  
         #---[ Valida Descricao do Grupo ]---#  
         #####################################  
         open cctc60m02005 using l_ctc60m02.vcldtbgrpcod  
         fetch cctc60m02005 into l_ctc60m02.vcldtbgrpdes  
  
         if sqlca.sqlcode <> 0 then  
            error " Grupo nao cadastrado! "  
            next field atdvclsgl  
         end if  
  
         display by name l_ctc60m02.*  
  
         if aux_manut = "S" then  
            exit input  
         end if  
  
      before field vcldtbgrpcod  
         display by name l_ctc60m02.vcldtbgrpcod attribute(reverse)  
  
      after field vcldtbgrpcod  
         display by name l_ctc60m02.vcldtbgrpcod  
  
         if fgl_lastkey() = fgl_keyval("up")   or  
            fgl_lastkey() = fgl_keyval("left") then  
            next field socvclcod  
         end if  
  
         if l_ctc60m02.vcldtbgrpcod is null or  
            l_ctc60m02.vcldtbgrpcod =  0    then  
            error " Informe o Codigo do Grupo! "  
            next field vcldtbgrpcod  
         end if  
  
         #---[ Valida Codigo do Grupo ]---#  
         ##################################  
         open cctc60m02004 using l_ctc60m02.socvclcod  
         fetch cctc60m02004  
  
         if sqlca.sqlcode <> 0 then  
            error " Codigo do Grupo nao cadastrado! "  
            next field vcldtbgrpcod  
         end if  
  
         #---[ Valida Descricao do Grupo ]---#  
         #####################################  
         open cctc60m02005 using l_ctc60m02.vcldtbgrpcod  
         fetch cctc60m02005 into l_ctc60m02.vcldtbgrpdes  
  
         if sqlca.sqlcode <> 0 then  
            error " Grupo nao cadastrado! "  
            next field vcldtbgrpcod  
         end if  
  
         display by name l_ctc60m02.vcldtbgrpdes  
  
      before field atdimpcod  
         display by name l_ctc60m02.atdimpcod attribute(reverse)  
  
      after field atdimpcod  
         display by name l_ctc60m02.atdimpcod  
  
         if fgl_lastkey() = fgl_keyval("up")   or  
            fgl_lastkey() = fgl_keyval("left") then  
            next field vcldtbgrpcod  
         end if  
  
         if l_ctc60m02.atdimpcod is null or  
            l_ctc60m02.atdimpcod =  0    then  
            error " Informe o Pager/MDT! "  
         end if  
  
      before field mdtcod  
         display by name l_ctc60m02.mdtcod attribute(reverse)  
  
      after field mdtcod  
         display by name l_ctc60m02.mdtcod  
  
         if fgl_lastkey() = fgl_keyval("up")   or  
            fgl_lastkey() = fgl_keyval("left") then  
            next field atdimpcod  
         end if  
  
      before field pgrnum  
         display by name l_ctc60m02.pgrnum attribute(reverse)  
  
      after field pgrnum  
         display by name l_ctc60m02.pgrnum  
  
         if fgl_lastkey() = fgl_keyval("up")   or  
            fgl_lastkey() = fgl_keyval("left") then  
            next field pgrnum  
         end if  
  
      before field celdddcod  
         display by name l_ctc60m02.celdddcod attribute(reverse)  
  
      after field celdddcod  
           
         if  (l_ctc60m02.celdddcod <> ws.celdddcod) or   
             (ws.celdddcod is null and l_ctc60m02.celdddcod is not null) or  
             (ws.celdddcod is not null and l_ctc60m02.celdddcod is null) then            
             #30/08/2010 PAS103306-Beatriz  
              whenever error continue   
               open cctc60m02009 using ctc60m02_depatl.depatlflg,  
                                       g_issk.dptsgl  
               fetch cctc60m02009 into ctc60m02_depatl.depatldes        
               if sqlca.sqlcode = notfound then  
                  error "Somente usuarios dos Departamentos cadastrados podem alterar essa informacao."  
                  let l_ctc60m02.celdddcod = ws.celdddcod     
                                                              
                  display by name l_ctc60m02.celdddcod       
                  next field celdddcod    
               end if  
               close cctc60m02009  
              whenever error stop   
                         
               #if  g_issk.dptsgl <> "psocor" then  
               #    error "Somente usuarios do Porto Socorro podem alterar essa informacao."  
               #      
               #    let d_ctc34m01.celdddcod = ws.celdddcod  
               #      
               #    display by name d_ctc34m01.celdddcod  
               #    next field celdddcod  
               #      
               #end if  
         end if            
  
         display by name l_ctc60m02.celdddcod  
  
         if fgl_lastkey() = fgl_keyval("up")   or  
            fgl_lastkey() = fgl_keyval("left") then  
            next field pgrnum  
         end if  
  
      before field celtelnum  
         display by name l_ctc60m02.celtelnum attribute(reverse)  
  
      after field celtelnum  
         display by name l_ctc60m02.celtelnum  
  
         if  (l_ctc60m02.celtelnum <> ws.celtelnum) or   
             (ws.celtelnum is null and l_ctc60m02.celtelnum is not null) or  
             (ws.celtelnum is not null and l_ctc60m02.celtelnum is null) then             
               
             #30/08/2010 PAS103306-Beatriz  
              whenever error continue   
               open cctc60m02009 using ctc60m02_depatl.depatlflg,  
                                       g_issk.dptsgl  
               fetch cctc60m02009 into ctc60m02_depatl.depatldes        
               if sqlca.sqlcode = notfound then  
                  error "Somente usuarios dos Departamentos cadastrados podem alterar essa informacao."  
                  let l_ctc60m02.celdddcod = ws.celdddcod     
                                                              
                  display by name l_ctc60m02.celdddcod       
                  next field celdddcod    
               end if  
               close cctc60m02009 
              whenever error stop   
                         
               #if  g_issk.dptsgl <> "psocor" then  
               #    error "Somente usuarios do Porto Socorro podem alterar essa informacao."  
               #      
               #    let d_ctc34m01.celdddcod = ws.celdddcod  
               #      
               #    display by name d_ctc34m01.celdddcod  
               #    next field celdddcod  
               #      
               #end if  
         end if           
           
         if fgl_lastkey() = fgl_keyval("up")   or  
            fgl_lastkey() = fgl_keyval("left") then  
            next field celdddcod  
         end if  
        
      before field nxtide  
         display by name l_ctc60m02.nxtide attribute(reverse)  
        
      after field nxtide  
         display by name l_ctc60m02.nxtide  
        
         if fgl_lastkey() = fgl_keyval("up")   or  
            fgl_lastkey() = fgl_keyval("left") then  
            next field celtelnum  
         end if     
        
      before field nxtdddcod  
         display by name l_ctc60m02.nxtdddcod attribute(reverse)  
        
      after field nxtdddcod  
         display by name l_ctc60m02.nxtdddcod  
        
         if fgl_lastkey() = fgl_keyval("up")   or  
            fgl_lastkey() = fgl_keyval("left") then  
            next field nxtide  
         end if    
           
      before field nxtnum  
         display by name l_ctc60m02.nxtnum attribute(reverse)  
        
      after field nxtnum  
         display by name l_ctc60m02.nxtnum  
        
         if fgl_lastkey() = fgl_keyval("up")   or  
            fgl_lastkey() = fgl_keyval("left") then  
            next field nxtdddcod  
         end if       
        
      on key (interrupt, control-c)  
         let int_flag = true  
         exit input  
  
   end input  
  
   return l_ctc60m02.*  
  
end function  
  
#-----------------------------------------------------------------------------#  
function scroll_ctc60m02(i)  
#-----------------------------------------------------------------------------#  
  
   define i                integer  
         ,l_flg            smallint  
  
   define l_ctc60m02       record  
          atdvclsgl        like datkveiculo.atdvclsgl  
         ,socvclcod        like datkveiculo.socvclcod  
         ,vcldtbgrpcod     like dattfrotalocal.vcldtbgrpcod  
         ,vcldtbgrpdes     like datkvcldtbgrp.vcldtbgrpdes  
         ,atdimpcod        like datkveiculo.atdimpcod  
         ,mdtcod           like datkveiculo.mdtcod  
         ,pgrnum           like datkveiculo.pgrnum  
         ,celdddcod        like datkveiculo.celdddcod  
         ,celtelnum        like datkveiculo.celtelnum  
         ,nxtide           like datkveiculo.nxtide  
         ,nxtdddcod        like datkveiculo.nxtdddcod  
         ,nxtnum           like datkveiculo.nxtnum  
   end record  
  
  
        let     l_flg  =  null  
  
        initialize  l_ctc60m02.*  to  null  
  
   fetch relative i cctc60m02001 into l_ctc60m02.atdvclsgl  
                                     ,l_ctc60m02.socvclcod  
                                     ,l_ctc60m02.atdimpcod  
                                     ,l_ctc60m02.mdtcod  
                                     ,l_ctc60m02.pgrnum  
                                     ,l_ctc60m02.celdddcod  
                                     ,l_ctc60m02.celtelnum  
                                     ,l_ctc60m02.nxtide  
                                     ,l_ctc60m02.nxtdddcod  
                                     ,l_ctc60m02.nxtnum  
  
   if sqlca.sqlcode <> 0 then  
      let l_flg = true  
   else  
      let l_flg = false  
   end if  
  
   #---[ Valida Codigo do Grupo ]---#  
   ##################################  
   open cctc60m02004 using l_ctc60m02.socvclcod  
   fetch cctc60m02004 into l_ctc60m02.vcldtbgrpcod  
  
   if sqlca.sqlcode = 0 then  
      #---[ Valida Descricao do Grupo ]---#  
      #####################################  
      open cctc60m02005 using l_ctc60m02.vcldtbgrpcod  
      fetch cctc60m02005 into l_ctc60m02.vcldtbgrpdes  
  
   end if  
  
   return l_ctc60m02.*  
         ,l_flg  
  
end function  
  
#-----------------------------------------------------------------------------#  
function manutenir_ctc60m02(l_ctc60m02)  
#-----------------------------------------------------------------------------#  
  
   define l_ctc60m02       record  
          atdvclsgl        like datkveiculo.atdvclsgl  
         ,socvclcod        like datkveiculo.socvclcod  
         ,vcldtbgrpcod     like dattfrotalocal.vcldtbgrpcod  
         ,vcldtbgrpdes     like datkvcldtbgrp.vcldtbgrpdes  
         ,atdimpcod        like datkveiculo.atdimpcod  
         ,mdtcod           like datkveiculo.mdtcod  
         ,pgrnum           like datkveiculo.pgrnum  
         ,celdddcod        like datkveiculo.celdddcod  
         ,celtelnum        like datkveiculo.celtelnum  
         ,nxtide           like datkveiculo.nxtide  
         ,nxtdddcod        like datkveiculo.nxtdddcod  
         ,nxtnum           like datkveiculo.nxtnum  
   end record  
  
   define l_ctc60m02_ant   record  
          atdvclsgl        like datkveiculo.atdvclsgl  
         ,socvclcod        like datkveiculo.socvclcod  
         ,vcldtbgrpcod     like dattfrotalocal.vcldtbgrpcod  
         ,vcldtbgrpdes     like datkvcldtbgrp.vcldtbgrpdes  
         ,atdimpcod        like datkveiculo.atdimpcod  
         ,mdtcod           like datkveiculo.mdtcod  
         ,pgrnum           like datkveiculo.pgrnum  
         ,celdddcod        like datkveiculo.celdddcod  
         ,celtelnum        like datkveiculo.celtelnum  
         ,nxtide           like datkveiculo.nxtide  
         ,nxtdddcod        like datkveiculo.nxtdddcod  
         ,nxtnum           like datkveiculo.nxtnum  
   end record  
  
   define l_mensagem  char(2000)  
         ,l_mensagem2 char(100)  
	 ,l_flg      integer  
	 ,l_stt      integer  
         ,l_cmd      char(100)  
         ,l_mensmail char(2000)  
	 ,l_hora     datetime hour to minute  
	 ,l_today    like datksrr.atldat  
  
   let l_mensagem2 = 'Alteracao no cadastro do Veiculo. Codigo : ' ,  
		     l_ctc60m02.socvclcod  
   let l_hora      = current hour to minute  
   let l_today     = today    
  
   let l_mensmail = null  
     
   let l_ctc60m02_ant.atdvclsgl    = l_ctc60m02.atdvclsgl       
   let l_ctc60m02_ant.socvclcod    = l_ctc60m02.socvclcod     
   let l_ctc60m02_ant.vcldtbgrpcod = l_ctc60m02.vcldtbgrpcod  
   let l_ctc60m02_ant.vcldtbgrpdes = l_ctc60m02.vcldtbgrpdes  
   let l_ctc60m02_ant.atdimpcod    = l_ctc60m02.atdimpcod     
   let l_ctc60m02_ant.mdtcod       = l_ctc60m02.mdtcod        
   let l_ctc60m02_ant.pgrnum       = l_ctc60m02.pgrnum        
   let l_ctc60m02_ant.celdddcod    = l_ctc60m02.celdddcod     
   let l_ctc60m02_ant.celtelnum    = l_ctc60m02.celtelnum     
   let l_ctc60m02_ant.nxtide       = l_ctc60m02.nxtide        
   let l_ctc60m02_ant.nxtdddcod    = l_ctc60m02.nxtdddcod     
   let l_ctc60m02_ant.nxtnum       = l_ctc60m02.nxtnum        
     
   call ctc60m02_input("M",l_ctc60m02.*)  
      returning l_ctc60m02.*  
     
   if int_flag then  
      error " Operacao Cancelada! "  
      let int_flag = false  
      return  
   end if  
  
   if l_ctc60m02.socvclcod is not null and  
      l_ctc60m02.socvclcod <> 0        then  
      update datkveiculo set (atdimpcod       
                             ,mdtcod          
                             ,pgrnum          
                             ,celdddcod       
                             ,celtelnum       
                             ,nxtide          
                             ,nxtdddcod       
                             ,nxtnum          
                             ,atldat          
                             ,atlemp  
                             ,atlmat)  
                           = (l_ctc60m02.atdimpcod  
                             ,l_ctc60m02.mdtcod  
                             ,l_ctc60m02.pgrnum  
                             ,l_ctc60m02.celdddcod  
                             ,l_ctc60m02.celtelnum  
                             ,l_ctc60m02.nxtide  
                             ,l_ctc60m02.nxtdddcod  
                             ,l_ctc60m02.nxtnum  
                             ,l_today  
                             ,g_issk.empcod  
                             ,g_issk.funmat)  
       where socvclcod = l_ctc60m02.socvclcod  
  
      if sqlca.sqlcode <> 0 then  
         error " Erro na alteracao do Veiculo! "  
         return  
      end if  
  
      update dattfrotalocal set (vcldtbgrpcod  
                                ,atlemp  
                                ,atlmat)  
                              = (l_ctc60m02.vcldtbgrpcod  
                                ,g_issk.empcod  
                                ,g_issk.funmat)  
       where socvclcod = l_ctc60m02.socvclcod  
  
      if sqlca.sqlcode <> 0 then  
         error " Erro na alteracao do Veiculo! "  
         return  
      end if  
   end if  
     
   let l_mensagem = null  
   let l_flg = 0     
     
   if (l_ctc60m02.vcldtbgrpdes is     null and l_ctc60m02_ant.vcldtbgrpdes is not null) or  
      (l_ctc60m02.vcldtbgrpdes is not null and l_ctc60m02_ant.vcldtbgrpdes is null)     or  
      (l_ctc60m02.vcldtbgrpdes <> l_ctc60m02_ant.vcldtbgrpdes)                          then  
       let l_mensagem = " Grupo de Distribuicao alterado de [",  
                    l_ctc60m02_ant.vcldtbgrpdes clipped,"] para [",  
                    l_ctc60m02.vcldtbgrpdes     clipped,"],"  
         
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped  
      let l_flg = 1  
  
      if not ctc60m02_grava_hist(l_ctc60m02.socvclcod  
                                ,l_mensagem  
                                ,l_today  
                                ,l_mensagem2,"A") then  
           
         let l_mensagem     = "Erro gravacao Historico "   
         let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped  
      end if  
            
            
   end if  
     
   if (l_ctc60m02_ant.atdimpcod is null     and l_ctc60m02.atdimpcod is not null) or  
      (l_ctc60m02_ant.atdimpcod is not null and l_ctc60m02.atdimpcod is null)     or  
      (l_ctc60m02_ant.atdimpcod              <> l_ctc60m02.atdimpcod)             then  
      let l_mensagem = "Impressao  alterado de [",l_ctc60m02_ant.atdimpcod clipped,"] para [",l_ctc60m02.atdimpcod clipped,"]"  
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped  
      let l_flg = 1  
  
      if not ctc60m02_grava_hist(l_ctc60m02.socvclcod  
                                ,l_mensagem  
                                ,l_today  
                                ,l_mensagem2,"A") then  
  
	 let l_mensagem = "Erro gravacao Historico "  
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped  
  
      end if  
   end if  
  
   if (l_ctc60m02_ant.mdtcod is null     and l_ctc60m02.mdtcod is not null) or  
      (l_ctc60m02_ant.mdtcod is not null and l_ctc60m02.mdtcod is null)     or  
      (l_ctc60m02_ant.mdtcod              <> l_ctc60m02.mdtcod)             then  
      let l_mensagem = "MDT  alterado de [",l_ctc60m02_ant.mdtcod clipped,"] para [",l_ctc60m02.mdtcod clipped,"]"  
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped  
      let l_flg = 1  
  
      if not ctc60m02_grava_hist(l_ctc60m02.socvclcod  
                                ,l_mensagem  
                                ,l_today  
                                ,l_mensagem2,"A") then  
  
	 let l_mensagem = "Erro gravacao Historico "  
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped  
  
      end if  
   end if    
     
   if (l_ctc60m02_ant.pgrnum is null     and l_ctc60m02.pgrnum is not null) or  
      (l_ctc60m02_ant.pgrnum is not null and l_ctc60m02.pgrnum is null)     or  
      (l_ctc60m02_ant.pgrnum              <> l_ctc60m02.pgrnum)             then  
      let l_mensagem = "Numero do Pager alterado de [",l_ctc60m02_ant.pgrnum clipped,"] para [",l_ctc60m02.pgrnum clipped,"]"  
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped  
      let l_flg = 1  
  
      if not ctc60m02_grava_hist(l_ctc60m02.socvclcod  
                                ,l_mensagem  
                                ,l_today  
                                ,l_mensagem2,"A") then  
  
	 let l_mensagem = "Erro gravacao Historico "  
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped  
  
      end if  
   end if      
     
   if (l_ctc60m02_ant.celdddcod is null     and l_ctc60m02.celdddcod is not null) or  
      (l_ctc60m02_ant.celdddcod is not null and l_ctc60m02.celdddcod is null)     or  
      (l_ctc60m02_ant.celdddcod              <> l_ctc60m02.celdddcod)             then  
      let l_mensagem = "DDD do Celular alterado de [",l_ctc60m02_ant.celdddcod clipped,"] para [",l_ctc60m02.celdddcod clipped,"]"  
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped  
      let l_flg = 1  
  
      if not ctc60m02_grava_hist(l_ctc60m02.socvclcod  
                                ,l_mensagem  
                                ,l_today  
                                ,l_mensagem2,"A") then  
  
	 let l_mensagem = "Erro gravacao Historico "  
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped  
  
      end if  
   end if  
     
   if (l_ctc60m02_ant.celtelnum is null     and l_ctc60m02.celtelnum is not null) or  
      (l_ctc60m02_ant.celtelnum is not null and l_ctc60m02.celtelnum is null)     or  
      (l_ctc60m02_ant.celtelnum              <> l_ctc60m02.celtelnum)             then  
      let l_mensagem = "Numero do Celular alterado de [",l_ctc60m02_ant.celtelnum,"] para [",l_ctc60m02.celtelnum,"]"  
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped  
      let l_flg = 1  
  
      if not ctc60m02_grava_hist(l_ctc60m02.socvclcod  
                                ,l_mensagem  
                                ,l_today  
                                ,l_mensagem2,"A") then  
  
	 let l_mensagem = "Erro gravacao Historico "  
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped  
  
      end if  
   end if  
     
   if (l_ctc60m02_ant.nxtide is null     and l_ctc60m02.nxtide is not null) or  
      (l_ctc60m02_ant.nxtide is not null and l_ctc60m02.nxtide is null)     or  
      (l_ctc60m02_ant.nxtide              <> l_ctc60m02.nxtide)             then  
      let l_mensagem = "ID Nextel alterado de [",l_ctc60m02_ant.nxtide clipped,  
                       "] para [",l_ctc60m02.nxtide clipped,"]"  
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped  
      let l_flg = 1  
  
      if not ctc60m02_grava_hist(l_ctc60m02.socvclcod  
                                ,l_mensagem  
                                ,l_today  
                                ,l_mensagem2,"A") then  
  
	 let l_mensagem = "Erro gravacao Historico "  
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped  
  
      end if  
   end if  
     
   if (l_ctc60m02_ant.nxtdddcod is null     and l_ctc60m02.nxtdddcod is not null) or  
      (l_ctc60m02_ant.nxtdddcod is not null and l_ctc60m02.nxtdddcod is null)     or  
      (l_ctc60m02_ant.nxtdddcod              <> l_ctc60m02.nxtdddcod)             then  
      let l_mensagem = "DDD Nextel alterado de [",l_ctc60m02_ant.nxtdddcod,  
                       "] para [",l_ctc60m02.nxtdddcod,"]"  
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped  
      let l_flg = 1  
  
      if not ctc60m02_grava_hist(l_ctc60m02.socvclcod  
                                ,l_mensagem  
                                ,l_today  
                                ,l_mensagem2,"A") then  
  
	 let l_mensagem = "Erro gravacao Historico "  
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped  
  
      end if  
   end if  
     
   if (l_ctc60m02_ant.nxtnum is null     and l_ctc60m02.nxtnum is not null) or  
      (l_ctc60m02_ant.nxtnum is not null and l_ctc60m02.nxtnum is null)     or  
      (l_ctc60m02_ant.nxtnum              <> l_ctc60m02.nxtnum)             then  
      let l_mensagem = "Linha do Nextel alterado de [",l_ctc60m02_ant.nxtnum,  
                       "] para [",l_ctc60m02.nxtnum,"]"  
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped  
      let l_flg = 1  
  
      if not ctc60m02_grava_hist(l_ctc60m02.socvclcod  
                                ,l_mensagem  
                                ,l_today  
                                ,l_mensagem2,"A") then  
  
	 let l_mensagem = "Erro gravacao Historico "  
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped  
  
      end if  
   end if  
     
   if l_mensmail is not null then  
      call ctc60m02_envia_email(l_mensagem2 clipped, l_today, l_hora, l_mensmail clipped)  
	    returning l_stt  
   end if  
     
     
   error " Alteracao efetuada com sucesso! "  
   return  
     
end function  
     
#--------------------------------------------------------  
function ctc60m02_grava_hist(lr_param,l_mensagem,l_opcao)  
#--------------------------------------------------------  
  
   define lr_param record  
          socvclcod  like datkveiculo.socvclcod  
         ,mensagem   char(2000)  
         ,data       date  
          end record  
  
   define lr_retorno record  
           stt       smallint  
          ,msg       char(50)  
          end record  
  
   define l_mensagem    char(100)  
         ,l_erro        smallint  
         ,l_stt         smallint  
         ,l_path        char(100)  
         ,l_opcao       char(1)  
	 ,l_hora        datetime hour to minute  
	 ,l_prshstdes2  char(2000)  
	 ,l_count  
         ,l_iter  
         ,l_length  
         ,l_length2    smallint  
  
   let l_stt  = true  
   let l_path = null  
   let l_hora = current hour to minute  
  
   initialize lr_retorno to null  
  
   let l_length = length(lr_param.mensagem clipped)  
   if  l_length mod 70 = 0 then  
       let l_iter = l_length / 70  
   else  
       let l_iter = l_length / 70 + 1  
   end if  
  
   let l_length2     = 0  
   let l_erro        = 0  
  
   for l_count = 1 to l_iter  
       if  l_count = l_iter then  
           let l_prshstdes2 = lr_param.mensagem[l_length2 + 1, l_length]  
       else  
           let l_length2 = l_length2 + 70  
           let l_prshstdes2 = lr_param.mensagem[l_length2 - 69, l_length2]  
       end if  
  
       call ctb85g01_grava_hist(1  
                              ,lr_param.socvclcod  
                              ,l_prshstdes2  
                              ,lr_param.data  
                              ,g_issk.empcod  
                              ,g_issk.funmat  
                              ,g_issk.usrtip)  
          returning lr_retorno.stt  
                   ,lr_retorno.msg  
  
   end for  
  
   if l_opcao <>  "A" then  
      if lr_retorno.stt =  0 then  
  
        call ctb85g01_mtcorpo_email_html('CTC34M01', # Utiliza os mesmos parametros do Frt_ct24h  
                                         lr_param.data,  
                                         l_hora,  
                                         g_issk.empcod,  
                                         g_issk.usrtip,  
                                         g_issk.funmat,  
                                         l_mensagem clipped,  
                                         lr_param.mensagem clipped)  
               returning l_erro  
  
         if l_erro <> 0 then  
            error 'Erro no envio do e-mail' sleep 2  
            let l_stt = false  
         else  
            let l_stt = true  
         end if  
      else  
         error 'Erro na gravacao do historico' sleep 2  
         let l_stt = false  
      end if  
     else  
      if lr_retorno.stt <> 0 then  
         error 'Erro na gravacao do historico' sleep 2  
         let l_stt = false  
      end if  
   end if  
  
   return l_stt  
  
end function     
     
#------------------------------------------------  
function ctc60m02_envia_email(lr_param)  
#------------------------------------------------  
  
  define lr_param record  
          titulo     char(100)  
         ,data       date  
         ,hora       datetime hour to minute  
         ,mensmail   char(2000)  
  end record  
  
  define l_stt       smallint  
	,l_path      char(100)  
	,l_cmd       char(100)  
	,l_mensmail2 like dbsmhstprs.prshstdes  
	,l_erro  
	,l_count  
	,l_iter  
	,l_length  
	,l_length2    smallint  
  
   let l_stt  = true  
   let l_path = null  
  
   call ctb85g01_mtcorpo_email_html('CTC34M01', # Utiliza os mesmos parametros do Frt_ct24h  
                                    lr_param.data,  
                                    lr_param.hora,  
                                    g_issk.empcod,  
                                    g_issk.usrtip,  
                                    g_issk.funmat,  
                                    lr_param.titulo clipped,  
                                    lr_param.mensmail clipped)  
               returning l_erro  
  
    if l_erro  <> 0 then  
	error 'Erro no envio do e-mail' sleep 2  
	let l_stt = false  
     else  
	let l_stt = true  
    end if  
  
    return l_stt  
  
end function     
  
     
#-----------------------------------------------------------------------------# 