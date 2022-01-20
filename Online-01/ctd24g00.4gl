#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                    OUT/2008 #
#-----------------------------------------------------------------------------#
# SISTEMA..: Teleatendimento                                                  #
# MODULO...: ctd24g00 - Modulo responsavel pelo acesso a tabela -> datmatd6523#
# ANALISTA : Carla Rampazzo                                                   #
# PSI......: 230650 - Adaptacoes no Sistema referente ao Decreto 6523         #
#-----------------------------------------------------------------------------#
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#
# 22/04/2010 Roberto Melo   PSI 242853      Implementacao do PSS              #
#-----------------------------------------------------------------------------#

database porto

define m_ctd24g00_prep smallint



#-----------------------------------------------------------------------------#
function ctd24g00_prepare()
#-----------------------------------------------------------------------------#

   define l_sql  char(2000)

   ---> Seleciona dados do Atendimento
   let l_sql = "select ciaempcod "
                    ,",solnom "
                    ,",flgavstransp "
                    ,",c24soltipcod "
                    ,",ramcod "
                    ,",flgcar "
                    ,",vcllicnum "
                    ,",corsus "
                    ,",succod "
                    ,",aplnumdig "
                    ,",itmnumdig "
                    ,",etpctrnum "
                    ,",segnom "
                    ,",pestip "
                    ,",cgccpfnum "
                    ,",cgcord "
                    ,",cgccpfdig "
                    ,",prporg "
                    ,",prpnumdig "
                    ,",flgvp "
                    ,",vstnumdig "
                    ,",vstdnumdig "
                    ,",flgvd "
                    ,",flgcp "
                    ,",cpbnum "
                    ,",semdcto "
                    ,",ies_ppt "
                    ,",ies_pss "
                    ,",transp "
                    ,",trpavbnum "
                    ,",vclchsfnl "
                    ,",sinramcod "
                    ,",sinnum "
                    ,",sinano "
                    ,",sinvstnum "
                    ,",sinvstano "
                    ,",flgauto "
                    ,",sinautnum "
                    ,",sinautano "
                    ,",flgre "
                    ,",sinrenum "
                    ,",sinreano "
                    ,",flgavs "
                    ,",sinavsnum "
                    ,",sinavsano "
                    ,",semdoctoempcodatd "
                    ,",semdoctopestip "
                    ,",semdoctocgccpfnum "
                    ,",semdoctocgcord "
                    ,",semdoctocgccpfdig "
                    ,",semdoctocorsus "
                    ,",semdoctofunmat "
                    ,",semdoctoempcod "
                    ,",semdoctodddcod "
                    ,",semdoctoctttel "
                    ,",funmat "
                    ,",empcod "
                    ,",usrtip "
                    ,",caddat "
                    ,",cadhor "
                    ,",ligcvntip "
                ,"from datmatd6523 "
               ,"where atdnum = ? "
   prepare p_ctd24g00_001 from l_sql
   declare c_ctd24g00_001 cursor for p_ctd24g00_001


   ---> Inclui atendimento e seus dados
   let l_sql = "insert into datmatd6523 (atdnum "
                                     ,",ciaempcod "
                                     ,",solnom "
                                     ,",flgavstransp "
                                     ,",c24soltipcod "
                                     ,",ramcod "
                                     ,",flgcar "
                                     ,",vcllicnum "
                                     ,",corsus "
                                     ,",succod "
                                     ,",aplnumdig "
                                     ,",itmnumdig "
                                     ,",etpctrnum "
                                     ,",segnom "
                                     ,",pestip "
                                     ,",cgccpfnum "
                                     ,",cgcord "
                                     ,",cgccpfdig "
                                     ,",prporg "
                                     ,",prpnumdig "
                                     ,",flgvp "
                                     ,",vstnumdig "
                                     ,",vstdnumdig "
                                     ,",flgvd "
                                     ,",flgcp "
                                     ,",cpbnum "
                                     ,",semdcto "
                                     ,",ies_ppt "
                                     ,",ies_pss "
                                     ,",transp "
                                     ,",trpavbnum "
                                     ,",vclchsfnl "
                                     ,",sinramcod "
                                     ,",sinnum "
                                     ,",sinano "
                                     ,",sinvstnum "
                                     ,",sinvstano "
                                     ,",flgauto "
                                     ,",sinautnum "
                                     ,",sinautano "
                                     ,",flgre "
                                     ,",sinrenum "
                                     ,",sinreano "
                                     ,",flgavs "
                                     ,",sinavsnum "
                                     ,",sinavsano "
                                     ,",semdoctoempcodatd "
                                     ,",semdoctopestip "
                                     ,",semdoctocgccpfnum "
                                     ,",semdoctocgcord "
                                     ,",semdoctocgccpfdig "
                                     ,",semdoctocorsus "
                                     ,",semdoctofunmat "
                                     ,",semdoctoempcod "
                                     ,",semdoctodddcod "
                                     ,",semdoctoctttel "
                                     ,",funmat "
                                     ,",empcod "
                                     ,",usrtip "
                                     ,",caddat "
                                     ,",cadhor "
                                     ,",ligcvntip ) "
                                ," values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,"
                                        ," ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,"
                                        ," ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,"
                                        ," ?,?,?,?,?,?,?,?,?,?,?,?,?,?,  "
                                        ," today, current ,? ) "
   prepare p_ctd24g00_002 from l_sql


   ---> Seleciona ultimo Nro.Atendimento
   let l_sql = " select grlinf[01,10] "
                ," from datkgeral "
               ," where grlchv = 'NUMULTATD' "
               ," for update of grlinf "
   prepare p_ctd24g00_003 from l_sql
   declare c_ctd24g00_002 cursor with hold for p_ctd24g00_003


   ---> Atualiza Nro.Atendimento
   let l_sql = " update datkgeral set (grlinf "
                                    ,",atldat "
                                    ,",atlhor) = (?, ?, ?) "
               ," where grlchv = 'NUMULTATD' "
   prepare p_ctd24g00_004 from l_sql


   ---> Complementa dados do Atendimento
   let l_sql = "update datmatd6523 set (flgavstransp "
                                     ,",c24soltipcod "
                                     ,",ramcod "
                                     ,",flgcar "
                                     ,",vcllicnum "
                                     ,",corsus "
                                     ,",succod "
                                     ,",aplnumdig "
                                     ,",itmnumdig "
                                     ,",etpctrnum "
                                     ,",segnom "
                                     ,",pestip "
                                     ,",cgccpfnum "
                                     ,",cgcord "
                                     ,",cgccpfdig "
                                     ,",prporg "
                                     ,",prpnumdig "
                                     ,",flgvp "
                                     ,",vstnumdig "
                                     ,",vstdnumdig "
                                     ,",flgvd "
                                     ,",flgcp "
                                     ,",cpbnum "
                                     ,",semdcto "
                                     ,",ies_ppt "
                                     ,",ies_pss "
                                     ,",transp "
                                     ,",trpavbnum "
                                     ,",vclchsfnl "
                                     ,",sinramcod "
                                     ,",sinnum "
                                     ,",sinano "
                                     ,",sinvstnum "
                                     ,",sinvstano "
                                     ,",flgauto "
                                     ,",sinautnum "
                                     ,",sinautano "
                                     ,",flgre "
                                     ,",sinrenum "
                                     ,",sinreano "
                                     ,",flgavs "
                                     ,",sinavsnum "
                                     ,",sinavsano "
                                     ,",semdoctoempcodatd "
                                     ,",semdoctopestip "
                                     ,",semdoctocgccpfnum "
                                     ,",semdoctocgcord "
                                     ,",semdoctocgccpfdig "
                                     ,",semdoctocorsus "
                                     ,",semdoctofunmat "
                                     ,",semdoctoempcod "
                                     ,",semdoctodddcod "
                                     ,",semdoctoctttel "
                                     ,",funmat "
                                     ,",empcod "
                                     ,",usrtip "
                                     ,",caddat "
                                     ,",cadhor "
                                     ,",ligcvntip ) "
                                ," =  (?,?,?,?,?,?,?,?,?,?,?,?,?,?,"
                                    ," ?,?,?,?,?,?,?,?,?,?,?,?,?,?,"
                                    ," ?,?,?,?,?,?,?,?,?,?,?,?,?,?,"
                                    ," ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,? ) "
                              ," where atdnum = ? "
   prepare p_ctd24g00_005 from l_sql


   ---> Seleciona Sigla da Empresa
   let l_sql = " select empsgl "
                ," from gabkemp "
               ," where empcod = ? "
   prepare p_ctd24g00_006 from l_sql
   declare c_ctd24g00_003 cursor with hold for p_ctd24g00_006

   let m_ctd24g00_prep = true

end function

#-----------------------------------------------------------------------------#
function ctd24g00_valida_atd(lr_param)
#-----------------------------------------------------------------------------#

   define lr_param         record
          atdnum           like datmatd6523.atdnum
         ,ciaempcod        like datmatd6523.ciaempcod
         ,tp_retorno       smallint ---> define parametros a serem retornados
   end record


   define lr_retorno            record
          resultado             smallint
         ,mensagem              char(60)
         ,ciaempcod             like datmatd6523.ciaempcod
         ,solnom                like datmatd6523.solnom
         ,flgavstransp          like datmatd6523.flgavstransp
         ,c24soltipcod          like datmatd6523.c24soltipcod
         ,ramcod                like datmatd6523.ramcod
         ,flgcar                like datmatd6523.flgcar
         ,vcllicnum             like datmatd6523.vcllicnum
         ,corsus                like datmatd6523.corsus
         ,succod                like datmatd6523.succod
         ,aplnumdig             like datmatd6523.aplnumdig
         ,itmnumdig             like datmatd6523.itmnumdig
         ,etpctrnum             like datmatd6523.etpctrnum
         ,segnom                like datmatd6523.segnom
         ,pestip                like datmatd6523.pestip
         ,cgccpfnum             like datmatd6523.cgccpfnum
         ,cgcord                like datmatd6523.cgcord
         ,cgccpfdig             like datmatd6523.cgccpfdig
         ,prporg                like datmatd6523.prporg
         ,prpnumdig             like datmatd6523.prpnumdig
         ,flgvp                 like datmatd6523.flgvp
         ,vstnumdig             like datmatd6523.vstnumdig
         ,vstdnumdig            like datmatd6523.vstdnumdig
         ,flgvd                 like datmatd6523.flgvd
         ,flgcp                 like datmatd6523.flgcp
         ,cpbnum                like datmatd6523.cpbnum
         ,semdcto               like datmatd6523.semdcto
         ,ies_ppt               like datmatd6523.ies_ppt
         ,ies_pss               like datmatd6523.ies_pss
         ,transp                like datmatd6523.transp
         ,trpavbnum             like datmatd6523.trpavbnum
         ,vclchsfnl             like datmatd6523.vclchsfnl
         ,sinramcod             like datmatd6523.sinramcod
         ,sinnum                like datmatd6523.sinnum
         ,sinano                like datmatd6523.sinano
         ,sinvstnum             like datmatd6523.sinvstnum
         ,sinvstano             like datmatd6523.sinvstano
         ,flgauto               like datmatd6523.flgauto
         ,sinautnum             like datmatd6523.sinautnum
         ,sinautano             like datmatd6523.sinautano
         ,flgre                 like datmatd6523.flgre
         ,sinrenum              like datmatd6523.sinrenum
         ,sinreano              like datmatd6523.sinreano
         ,flgavs                like datmatd6523.flgavs
         ,sinavsnum             like datmatd6523.sinavsnum
         ,sinavsano             like datmatd6523.sinavsano
         ,semdoctoempcodatd     like datmatd6523.semdoctoempcodatd
         ,semdoctopestip        like datmatd6523.semdoctopestip
         ,semdoctocgccpfnum     like datmatd6523.semdoctocgccpfnum
         ,semdoctocgcord        like datmatd6523.semdoctocgcord
         ,semdoctocgccpfdig     like datmatd6523.semdoctocgccpfdig
         ,semdoctocorsus        like datmatd6523.semdoctocorsus
         ,semdoctofunmat        like datmatd6523.semdoctofunmat
         ,semdoctoempcod        like datmatd6523.semdoctoempcod
         ,semdoctodddcod        like datmatd6523.semdoctodddcod
         ,semdoctoctttel        like datmatd6523.semdoctoctttel
         ,funmat                like datmatd6523.funmat
         ,empcod                like datmatd6523.empcod
         ,usrtip                like datmatd6523.usrtip
         ,caddat                like datmatd6523.caddat
         ,cadhor                like datmatd6523.cadhor
         ,ligcvntip             like datmatd6523.ligcvntip
   end record

   define l_empsgl         like gabkemp.empsgl

   if m_ctd24g00_prep is null or
      m_ctd24g00_prep <> true then
      call ctd24g00_prepare()
   end if

   initialize lr_retorno.* to null

   let lr_retorno.resultado = 1
   let lr_retorno.mensagem  = null


   ---> Seleciona Dados relacionados ao Atendimento
   open c_ctd24g00_001 using lr_param.atdnum
   whenever error continue
   fetch c_ctd24g00_001 into lr_retorno.ciaempcod
                          ,lr_retorno.solnom
                          ,lr_retorno.flgavstransp
                          ,lr_retorno.c24soltipcod
                          ,lr_retorno.ramcod
                          ,lr_retorno.flgcar
                          ,lr_retorno.vcllicnum
                          ,lr_retorno.corsus
                          ,lr_retorno.succod
                          ,lr_retorno.aplnumdig
                          ,lr_retorno.itmnumdig
                          ,lr_retorno.etpctrnum
                          ,lr_retorno.segnom
                          ,lr_retorno.pestip
                          ,lr_retorno.cgccpfnum
                          ,lr_retorno.cgcord
                          ,lr_retorno.cgccpfdig
                          ,lr_retorno.prporg
                          ,lr_retorno.prpnumdig
                          ,lr_retorno.flgvp
                          ,lr_retorno.vstnumdig
                          ,lr_retorno.vstdnumdig
                          ,lr_retorno.flgvd
                          ,lr_retorno.flgcp
                          ,lr_retorno.cpbnum
                          ,lr_retorno.semdcto
                          ,lr_retorno.ies_ppt
                          ,lr_retorno.ies_pss
                          ,lr_retorno.transp
                          ,lr_retorno.trpavbnum
                          ,lr_retorno.vclchsfnl
                          ,lr_retorno.sinramcod
                          ,lr_retorno.sinnum
                          ,lr_retorno.sinano
                          ,lr_retorno.sinvstnum
                          ,lr_retorno.sinvstano
                          ,lr_retorno.flgauto
                          ,lr_retorno.sinautnum
                          ,lr_retorno.sinautano
                          ,lr_retorno.flgre
                          ,lr_retorno.sinrenum
                          ,lr_retorno.sinreano
                          ,lr_retorno.flgavs
                          ,lr_retorno.sinavsnum
                          ,lr_retorno.sinavsano
                          ,lr_retorno.semdoctoempcodatd
                          ,lr_retorno.semdoctopestip
                          ,lr_retorno.semdoctocgccpfnum
                          ,lr_retorno.semdoctocgcord
                          ,lr_retorno.semdoctocgccpfdig
                          ,lr_retorno.semdoctocorsus
                          ,lr_retorno.semdoctofunmat
                          ,lr_retorno.semdoctoempcod
                          ,lr_retorno.semdoctodddcod
                          ,lr_retorno.semdoctoctttel
                          ,lr_retorno.funmat
                          ,lr_retorno.empcod
                          ,lr_retorno.usrtip
                          ,lr_retorno.caddat
                          ,lr_retorno.cadhor
                          ,lr_retorno.ligcvntip
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let lr_retorno.resultado = 2
         let lr_retorno.mensagem  = "Nao localizou o Atendimento: < "
                                    ,lr_param.atdnum using "<<<<<<<<&&" , " >"
      else
         let lr_retorno.resultado = 3
         let lr_retorno.mensagem  = "Erro no acesso a tabela datmatd6523: "
                                   , sqlca.sqlcode
      end if
   end if
   ---> Valida somente se o Atendimento existe, independente da empresa
   if lr_param.tp_retorno = 5 then
      return lr_retorno.resultado
            ,lr_retorno.mensagem
            ,lr_retorno.ciaempcod
   end if


   ---> Busca Sigla da Empresa
   open c_ctd24g00_003 using lr_retorno.ciaempcod
   whenever error continue
   fetch c_ctd24g00_003 into l_empsgl
   whenever error stop


   ---> Valida se Atendimento pertence a Empresa informada
   if lr_param.tp_retorno = 1 then

      if lr_param.ciaempcod is not null             and
         lr_param.ciaempcod <> 0                    and
         lr_param.ciaempcod <> lr_retorno.ciaempcod then

         if lr_param.ciaempcod = 1    and
            lr_retorno.ciaempcod = 35 then
            let lr_retorno.resultado = 2
         else
            if lr_param.ciaempcod = 35 then
               let lr_retorno.resultado = 2
            else
               let lr_retorno.resultado = 1
            end if
         end if

         let lr_retorno.mensagem  = " Atendimento pertence a empresa: "
                                  , lr_retorno.ciaempcod using "&&"
                                  , "-", l_empsgl
      end if

      return lr_retorno.resultado
            ,lr_retorno.mensagem
   end if


   ---> Retorna dados do Atendente
   if lr_param.tp_retorno = 2 then
      return lr_retorno.resultado
            ,lr_retorno.mensagem
            ,lr_retorno.funmat
            ,lr_retorno.empcod
            ,lr_retorno.usrtip
            ,lr_retorno.ciaempcod
   end if


   ---> Retorna todos os dados do Atendimento
   if lr_param.tp_retorno = 3 then
      return lr_retorno.*
   end if


   ---> Retorna dados de pesquisa para Azul Seguros
   if lr_param.tp_retorno = 4 then
      return lr_retorno.resultado
            ,lr_retorno.mensagem
            ,lr_retorno.ciaempcod
            ,lr_retorno.solnom
            ,lr_retorno.c24soltipcod
            ,lr_retorno.ramcod
            ,lr_retorno.vcllicnum
            ,lr_retorno.succod
            ,lr_retorno.aplnumdig
            ,lr_retorno.itmnumdig
            ,lr_retorno.segnom
            ,lr_retorno.pestip
            ,lr_retorno.cgccpfnum
            ,lr_retorno.cgcord
            ,lr_retorno.cgccpfdig
            ,lr_retorno.semdcto
            ,lr_retorno.vclchsfnl
            ,lr_retorno.semdoctoempcodatd
            ,lr_retorno.semdoctopestip
            ,lr_retorno.semdoctocgccpfnum
            ,lr_retorno.semdoctocgcord
            ,lr_retorno.semdoctocgccpfdig
            ,lr_retorno.semdoctocorsus
            ,lr_retorno.semdoctofunmat
            ,lr_retorno.semdoctoempcod
            ,lr_retorno.semdoctodddcod
            ,lr_retorno.semdoctoctttel
   end if
   ---> Retorna dados de pesquisa para PSS
   if lr_param.tp_retorno = 6 then
        if lr_param.ciaempcod is not null             and
           lr_param.ciaempcod <> 0                    and
           lr_param.ciaempcod <> lr_retorno.ciaempcod then
           let lr_retorno.resultado = 2
           let lr_retorno.mensagem  = "Nao localizou o Atendimento: < "
                                      ,lr_param.atdnum using "<<<<<<<<&&" , " >"
        end if
      return lr_retorno.resultado          ,
             lr_retorno.mensagem           ,
             lr_retorno.ciaempcod          ,
             lr_retorno.solnom             ,
             lr_retorno.c24soltipcod       ,
             lr_retorno.segnom             ,
             lr_retorno.pestip             ,
             lr_retorno.cgccpfnum          ,
             lr_retorno.cgcord             ,
             lr_retorno.cgccpfdig          ,
             lr_retorno.semdcto            ,
             lr_retorno.semdoctoempcodatd  ,
             lr_retorno.semdoctopestip     ,
             lr_retorno.semdoctocgccpfnum  ,
             lr_retorno.semdoctocgcord     ,
             lr_retorno.semdoctocgccpfdig  ,
             lr_retorno.semdoctocorsus     ,
             lr_retorno.semdoctofunmat     ,
             lr_retorno.semdoctoempcod     ,
             lr_retorno.semdoctodddcod     ,
             lr_retorno.semdoctoctttel
   end if
   
   ---> Retorna dados de pesquisa para o Itau                                        
   if lr_param.tp_retorno = 7 then                                                
     
      if lr_param.ciaempcod is not null             and                         
         lr_param.ciaempcod <> 0                    and                         
         lr_param.ciaempcod <> lr_retorno.ciaempcod then                        
         let lr_retorno.resultado = 2                                           
         let lr_retorno.mensagem  = "Nao localizou o Atendimento: < "           
                                    ,lr_param.atdnum using "<<<<<<<<&&" , " >"  
      end if                                                                    
     
      return lr_retorno.resultado          ,                                      
             lr_retorno.mensagem           ,                                      
             lr_retorno.ciaempcod          ,                                      
             lr_retorno.solnom             ,                                      
             lr_retorno.c24soltipcod       ,
             lr_retorno.ramcod             ,
             lr_retorno.succod             ,
             lr_retorno.aplnumdig          ,
             lr_retorno.itmnumdig          , 
             lr_retorno.etpctrnum          ,                                                         
             lr_retorno.semdcto            ,                                      
             lr_retorno.semdoctoempcodatd  ,                                      
             lr_retorno.semdoctopestip     ,                                      
             lr_retorno.semdoctocgccpfnum  ,                                      
             lr_retorno.semdoctocgcord     ,                                      
             lr_retorno.semdoctocgccpfdig  ,                                      
             lr_retorno.semdoctocorsus     ,                                      
             lr_retorno.semdoctofunmat     ,                                      
             lr_retorno.semdoctoempcod     ,                                      
             lr_retorno.semdoctodddcod     ,                                      
             lr_retorno.semdoctoctttel                                            
   end if                                                                         
   
   
   

end function

#-----------------------------------------------------------------------------#
function ctd24g00_upd_atd(lr_param)
#-----------------------------------------------------------------------------#

   define lr_param              record
          atdnum                like datmatd6523.atdnum
         ,flgavstransp          like datmatd6523.flgavstransp
         ,c24soltipcod          like datmatd6523.c24soltipcod
         ,ramcod                like datmatd6523.ramcod
         ,flgcar                like datmatd6523.flgcar
         ,vcllicnum             like datmatd6523.vcllicnum
         ,corsus                like datmatd6523.corsus
         ,succod                like datmatd6523.succod
         ,aplnumdig             like datmatd6523.aplnumdig
         ,itmnumdig             like datmatd6523.itmnumdig
         ,etpctrnum             like datmatd6523.etpctrnum
         ,segnom                like datmatd6523.segnom
         ,pestip                like datmatd6523.pestip
         ,cgccpfnum             like datmatd6523.cgccpfnum
         ,cgcord                like datmatd6523.cgcord
         ,cgccpfdig             like datmatd6523.cgccpfdig
         ,prporg                like datmatd6523.prporg
         ,prpnumdig             like datmatd6523.prpnumdig
         ,flgvp                 like datmatd6523.flgvp
         ,vstnumdig             like datmatd6523.vstnumdig
         ,vstdnumdig            like datmatd6523.vstdnumdig
         ,flgvd                 like datmatd6523.flgvd
         ,flgcp                 like datmatd6523.flgcp
         ,cpbnum                like datmatd6523.cpbnum
         ,semdcto               like datmatd6523.semdcto
         ,ies_ppt               like datmatd6523.ies_ppt
         ,ies_pss               like datmatd6523.ies_pss
         ,transp                like datmatd6523.transp
         ,trpavbnum             like datmatd6523.trpavbnum
         ,vclchsfnl             like datmatd6523.vclchsfnl
         ,sinramcod             like datmatd6523.sinramcod
         ,sinnum                like datmatd6523.sinnum
         ,sinano                like datmatd6523.sinano
         ,sinvstnum             like datmatd6523.sinvstnum
         ,sinvstano             like datmatd6523.sinvstano
         ,flgauto               like datmatd6523.flgauto
         ,sinautnum             like datmatd6523.sinautnum
         ,sinautano             like datmatd6523.sinautano
         ,flgre                 like datmatd6523.flgre
         ,sinrenum              like datmatd6523.sinrenum
         ,sinreano              like datmatd6523.sinreano
         ,flgavs                like datmatd6523.flgavs
         ,sinavsnum             like datmatd6523.sinavsnum
         ,sinavsano             like datmatd6523.sinavsano
         ,semdoctoempcodatd     like datmatd6523.semdoctoempcodatd
         ,semdoctopestip        like datmatd6523.semdoctopestip
         ,semdoctocgccpfnum     like datmatd6523.semdoctocgccpfnum
         ,semdoctocgcord        like datmatd6523.semdoctocgcord
         ,semdoctocgccpfdig     like datmatd6523.semdoctocgccpfdig
         ,semdoctocorsus        like datmatd6523.semdoctocorsus
         ,semdoctofunmat        like datmatd6523.semdoctofunmat
         ,semdoctoempcod        like datmatd6523.semdoctoempcod
         ,semdoctodddcod        like datmatd6523.semdoctodddcod
         ,semdoctoctttel        like datmatd6523.semdoctoctttel
         ,funmat                like datmatd6523.funmat
         ,empcod                like datmatd6523.empcod
         ,usrtip                like datmatd6523.usrtip
         ,caddat                like datmatd6523.caddat
         ,cadhor                like datmatd6523.cadhor
         ,ligcvntip             like datmatd6523.ligcvntip
   end record

   define lr_retorno       record
          resultado        smallint
         ,mensagem         char(60)
   end record

   if m_ctd24g00_prep is null or
      m_ctd24g00_prep <> true then
      call ctd24g00_prepare()
   end if

   initialize lr_retorno.* to null

   ---> Altera Atendimento
   whenever error continue
   execute p_ctd24g00_005 using lr_param.flgavstransp
                             ,lr_param.c24soltipcod
                             ,lr_param.ramcod
                             ,lr_param.flgcar
                             ,lr_param.vcllicnum
                             ,lr_param.corsus
                             ,lr_param.succod
                             ,lr_param.aplnumdig
                             ,lr_param.itmnumdig
                             ,lr_param.etpctrnum
                             ,lr_param.segnom
                             ,lr_param.pestip
                             ,lr_param.cgccpfnum
                             ,lr_param.cgcord
                             ,lr_param.cgccpfdig
                             ,lr_param.prporg
                             ,lr_param.prpnumdig
                             ,lr_param.flgvp
                             ,lr_param.vstnumdig
                             ,lr_param.vstdnumdig
                             ,lr_param.flgvd
                             ,lr_param.flgcp
                             ,lr_param.cpbnum
                             ,lr_param.semdcto
                             ,lr_param.ies_ppt
                             ,lr_param.ies_pss
                             ,lr_param.transp
                             ,lr_param.trpavbnum
                             ,lr_param.vclchsfnl
                             ,lr_param.sinramcod
                             ,lr_param.sinnum
                             ,lr_param.sinano
                             ,lr_param.sinvstnum
                             ,lr_param.sinvstano
                             ,lr_param.flgauto
                             ,lr_param.sinautnum
                             ,lr_param.sinautano
                             ,lr_param.flgre
                             ,lr_param.sinrenum
                             ,lr_param.sinreano
                             ,lr_param.flgavs
                             ,lr_param.sinavsnum
                             ,lr_param.sinavsano
                             ,lr_param.semdoctoempcodatd
                             ,lr_param.semdoctopestip
                             ,lr_param.semdoctocgccpfnum
                             ,lr_param.semdoctocgcord
                             ,lr_param.semdoctocgccpfdig
                             ,lr_param.semdoctocorsus
                             ,lr_param.semdoctofunmat
                             ,lr_param.semdoctoempcod
                             ,lr_param.semdoctodddcod
                             ,lr_param.semdoctoctttel
                             ,lr_param.funmat
                             ,lr_param.empcod
                             ,lr_param.usrtip
                             ,lr_param.caddat
                             ,lr_param.cadhor
                             ,lr_param.atdnum
                             ,lr_param.ligcvntip
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_retorno.resultado = 3
      let lr_retorno.mensagem  = "Erro na alteracao de datmatd6523: "
                               , sqlca.sqlcode
   end if

   return lr_retorno.resultado
         ,lr_retorno.mensagem

end function

#-----------------------------------------------------------------------------#
function ctd24g00_ins_atd(lr_param)
#-----------------------------------------------------------------------------#

   define lr_param              record
          atdnum                like datmatd6523.atdnum
         ,ciaempcod             like datmatd6523.ciaempcod
         ,solnom                like datmatd6523.solnom
         ,flgavstransp          like datmatd6523.flgavstransp
         ,c24soltipcod          like datmatd6523.c24soltipcod
         ,ramcod                like datmatd6523.ramcod
         ,flgcar                like datmatd6523.flgcar
         ,vcllicnum             like datmatd6523.vcllicnum
         ,corsus                like datmatd6523.corsus
         ,succod                like datmatd6523.succod
         ,aplnumdig             like datmatd6523.aplnumdig
         ,itmnumdig             like datmatd6523.itmnumdig
         ,etpctrnum             like datmatd6523.etpctrnum
         ,segnom                like datmatd6523.segnom
         ,pestip                like datmatd6523.pestip
         ,cgccpfnum             like datmatd6523.cgccpfnum
         ,cgcord                like datmatd6523.cgcord
         ,cgccpfdig             like datmatd6523.cgccpfdig
         ,prporg                like datmatd6523.prporg
         ,prpnumdig             like datmatd6523.prpnumdig
         ,flgvp                 like datmatd6523.flgvp
         ,vstnumdig             like datmatd6523.vstnumdig
         ,vstdnumdig            like datmatd6523.vstdnumdig
         ,flgvd                 like datmatd6523.flgvd
         ,flgcp                 like datmatd6523.flgcp
         ,cpbnum                like datmatd6523.cpbnum
         ,semdcto               like datmatd6523.semdcto
         ,ies_ppt               like datmatd6523.ies_ppt
         ,ies_pss               like datmatd6523.ies_pss
         ,transp                like datmatd6523.transp
         ,trpavbnum             like datmatd6523.trpavbnum
         ,vclchsfnl             like datmatd6523.vclchsfnl
         ,sinramcod             like datmatd6523.sinramcod
         ,sinnum                like datmatd6523.sinnum
         ,sinano                like datmatd6523.sinano
         ,sinvstnum             like datmatd6523.sinvstnum
         ,sinvstano             like datmatd6523.sinvstano
         ,flgauto               like datmatd6523.flgauto
         ,sinautnum             like datmatd6523.sinautnum
         ,sinautano             like datmatd6523.sinautano
         ,flgre                 like datmatd6523.flgre
         ,sinrenum              like datmatd6523.sinrenum
         ,sinreano              like datmatd6523.sinreano
         ,flgavs                like datmatd6523.flgavs
         ,sinavsnum             like datmatd6523.sinavsnum
         ,sinavsano             like datmatd6523.sinavsano
         ,semdoctoempcodatd     like datmatd6523.semdoctoempcodatd
         ,semdoctopestip        like datmatd6523.semdoctopestip
         ,semdoctocgccpfnum     like datmatd6523.semdoctocgccpfnum
         ,semdoctocgcord        like datmatd6523.semdoctocgcord
         ,semdoctocgccpfdig     like datmatd6523.semdoctocgccpfdig
         ,semdoctocorsus        like datmatd6523.semdoctocorsus
         ,semdoctofunmat        like datmatd6523.semdoctofunmat
         ,semdoctoempcod        like datmatd6523.semdoctoempcod
         ,semdoctodddcod        like datmatd6523.semdoctodddcod
         ,semdoctoctttel        like datmatd6523.semdoctoctttel
         ,funmat                like datmatd6523.funmat
         ,empcod                like datmatd6523.empcod
         ,usrtip                like datmatd6523.usrtip
         ,ligcvntip             like datmatd6523.ligcvntip
   end record

   define lr_retorno       record
          atdnum           like datmatd6523.atdnum
         ,resultado        smallint
         ,mensagem         char(60)
   end record

   define l_sqlcod         smallint
         ,l_mensagem       char(60)
         ,l_cont           smallint

   if m_ctd24g00_prep is null or
      m_ctd24g00_prep <> true then
      call ctd24g00_prepare()
   end if

   let l_sqlcod   = 1
   let l_mensagem = null
   let l_cont     = 0

   initialize lr_retorno.* to null

   whenever error continue

   set lock mode to not wait

   ---> So gera Atendimento se nro nao foi Informado
   if lr_param.atdnum is null or
      lr_param.atdnum =  0    then

      while true
         let l_cont = l_cont + 1

         ---> Gera Numero do Atendimento
         call ctd24g00_gera_nro_atd()
              returning lr_retorno.atdnum
                       ,l_sqlcod
                       ,l_mensagem

         ---> Apresentou algum problema no momento de gerar o Nro.Atendimento
         if l_sqlcod <> 0  then

            if l_sqlcod = -243 or
               l_sqlcod = -244 or
               l_sqlcod = -245 or
               l_sqlcod = -246 then

               if l_cont < 11  then
                  sleep 1
                  continue while
               else
                  let lr_retorno.mensagem = " Numero do Atendimento travado! "
               end if
            else
               let lr_retorno.mensagem  = l_mensagem
            end if

            let lr_retorno.resultado = l_sqlcod
         else
            let lr_retorno.resultado = l_sqlcod
            let lr_retorno.mensagem  = l_mensagem
         end if
         exit while
      end while

      set lock mode to wait
      whenever error stop


      ---> Apresentou algum problema no momento de gerar o Nro.Atendimento
      if l_sqlcod <> 0 then
         return lr_retorno.atdnum
               ,lr_retorno.resultado
               ,lr_retorno.mensagem
      end if
   else
      let lr_retorno.atdnum = lr_param.atdnum
   end if


   ---> Inclui Atendimento
   whenever error continue
   execute p_ctd24g00_002 using lr_retorno.atdnum
			     ,lr_param.ciaempcod
                             ,lr_param.solnom
                             ,lr_param.flgavstransp
                             ,lr_param.c24soltipcod
                             ,lr_param.ramcod
                             ,lr_param.flgcar
                             ,lr_param.vcllicnum
                             ,lr_param.corsus
                             ,lr_param.succod
                             ,lr_param.aplnumdig
                             ,lr_param.itmnumdig
                             ,lr_param.etpctrnum
                             ,lr_param.segnom
                             ,lr_param.pestip
                             ,lr_param.cgccpfnum
                             ,lr_param.cgcord
                             ,lr_param.cgccpfdig
                             ,lr_param.prporg
                             ,lr_param.prpnumdig
                             ,lr_param.flgvp
                             ,lr_param.vstnumdig
                             ,lr_param.vstdnumdig
                             ,lr_param.flgvd
                             ,lr_param.flgcp
                             ,lr_param.cpbnum
                             ,lr_param.semdcto
                             ,lr_param.ies_ppt
                             ,lr_param.ies_pss
                             ,lr_param.transp
                             ,lr_param.trpavbnum
                             ,lr_param.vclchsfnl
                             ,lr_param.sinramcod
                             ,lr_param.sinnum
                             ,lr_param.sinano
                             ,lr_param.sinvstnum
                             ,lr_param.sinvstano
                             ,lr_param.flgauto
                             ,lr_param.sinautnum
                             ,lr_param.sinautano
                             ,lr_param.flgre
                             ,lr_param.sinrenum
                             ,lr_param.sinreano
                             ,lr_param.flgavs
                             ,lr_param.sinavsnum
                             ,lr_param.sinavsano
                             ,lr_param.semdoctoempcodatd
                             ,lr_param.semdoctopestip
                             ,lr_param.semdoctocgccpfnum
                             ,lr_param.semdoctocgcord
                             ,lr_param.semdoctocgccpfdig
                             ,lr_param.semdoctocorsus
                             ,lr_param.semdoctofunmat
                             ,lr_param.semdoctoempcod
                             ,lr_param.semdoctodddcod
                             ,lr_param.semdoctoctttel
                             ,lr_param.funmat
                             ,lr_param.empcod
                             ,lr_param.usrtip
                             ,lr_param.ligcvntip
   whenever error stop

   if sqlca.sqlcode <> 0 then

      if sqlca.sqlcode = -268 then
         let lr_retorno.resultado = 4
      else
         let lr_retorno.resultado = 3
      end if

      let lr_retorno.mensagem  = "Erro na inclusao de datmatd6523: "
                               , sqlca.sqlcode
   end if

   return lr_retorno.atdnum
         ,lr_retorno.resultado
         ,lr_retorno.mensagem

end function

#-----------------------------------------------------------------------------#
function ctd24g00_gera_nro_atd()
#-----------------------------------------------------------------------------#

   define lr_retorno       record
          atdnum           like datmatd6523.atdnum
         ,sqlcod           smallint
         ,mensagem         char(60)
   end record

   define lr_ctd24g00      record
          atdnum           like datmatd6523.atdnum
         ,atldat           like datkgeral.atldat
         ,atlhor           like datkgeral.atlhor
   end record


   initialize lr_retorno.*
             ,lr_ctd24g00.* to null


   if m_ctd24g00_prep is null or
      m_ctd24g00_prep <> true then
      call ctd24g00_prepare()
   end if

   let lr_retorno.sqlcod    = 0
   let lr_retorno.mensagem  = null

   ---> Seleciona Ultima Numeracao do Atendimento na datkgeral
   open c_ctd24g00_002
   whenever error continue
   fetch c_ctd24g00_002 into lr_ctd24g00.atdnum
   whenever error stop

   if sqlca.sqlcode <> 0  then
      let lr_retorno.sqlcod   = sqlca.sqlcode
      let lr_retorno.mensagem = " Erro na busca do numero do Atendimento! "
      let lr_retorno.atdnum   = null
      return lr_retorno.*
   end if

   let lr_ctd24g00.atdnum = lr_ctd24g00.atdnum + 1

   ---> Busca a data e hora do banco
   call cts40g03_data_hora_banco(2)
        returning lr_ctd24g00.atldat
                 ,lr_ctd24g00.atlhor


   ---> Atualiza Ultimo Numero do Atendimento na datkgeral
   whenever error continue
   execute p_ctd24g00_004 using lr_ctd24g00.atdnum
                             ,lr_ctd24g00.atldat
                             ,lr_ctd24g00.atlhor
   whenever error stop


   if sqlca.sqlcode <> 0  then
      let lr_retorno.sqlcod   = sqlca.sqlcode
      let lr_retorno.mensagem = " Erro na atualizacao do Nro. do Atendimento! "
      let lr_retorno.atdnum   = null
   end if

   let lr_retorno.atdnum = lr_ctd24g00.atdnum

   return lr_retorno.atdnum
         ,lr_retorno.sqlcod
         ,lr_retorno.mensagem

end function

