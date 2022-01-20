#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema       :                                                              #
# Modulo        :cty23g00                                                      #
# Analista Resp.:                                                              #
# PSI           :PSI2011-25004-PR Projeto868- Vistoria Previa Azul e Itau      #
#                                                                              #
#                                                                              #
#                                                                              #
#..............................................................................#
# Desenvolvimento: Johnny Alves  BizTalking  em 20/02/2012                     #
# Liberacao      :                                                             #
#..............................................................................#
#                                                                              #
#                  * * * ALTERACOES * * *                                      #
#                                                                              #
# Data       Autor Fabrica     Origem     Alteracao                            #
# ---------- ----------------- ---------- -------------------------------------#
# 06/06/2013 Zyon          PSI-2013-01385 - cty23g00_consul_apol_chas_azul     #
#                                           + retorno corsus                   #
#                                         - cty23g00_consul_apol_placa_azul    #
#                                           + retorno corsus                   #
#                                         - cty23g00_consul_apol_chas_itau     #
#                                           + retorno corsus                   #
#                                         - cty23g00_consul_apol_placa_itau    #
#                                           + retorno corsus                   #
#                                         - cty23g00_extrai_dados_chassi_azul  #
#                                           + retorno corsus                   #
#                                         - cty23g00_extrai_dados_placa_azul   #
#                                           + retorno corsus                   #
#------------------------------------------------------------------------------#
# 24/09/2015 Alberto       Ajuste para o programa da vistorias bvpia880-Linux  #
#------------------------------------------------------------------------------#

database porto

define mr_cty23g00 record
    azlaplcod           integer
   ,xml                 char(32700)
   ,doc_handle          integer
   ,sitdoc              char(09)
end record

define m_prep_sql_azul  smallint
define m_prep_sql_itau  smallint

function cty23g00_prepare_azul()
    
    define l_StrSql    char(3000)
    
    initialize l_StrSql to null


    let l_StrSql = " select count(*)     ",
                   " from datkazlaplcmp  ",
                   " where azlaplcod = ? "
    prepare cty23g00000 from l_StrSql      
    
    let l_StrSql = ' select a.azlaplcod '
                  ,'   from datkazlapl a '
                  ,'  where a.vclchsfnl = ? '
                  ,'    and a.edsnumdig in '
                  ,'   (select max(edsnumdig) '
                  ,'      from datkazlapl b '
                  ,'     where a.succod = b.succod '
                  ,'       and a.aplnumdig = b.aplnumdig '
                  ,'       and a.itmnumdig = b.itmnumdig '
                  ,'       and a.ramcod = b.ramcod) '
    prepare pcty23g00001 from l_StrSql
    declare ccty23g00001 cursor for pcty23g00001
    
    let l_StrSql = ' select a.azlaplcod '
                  ,'   from datkazlapl a '
                  ,'  where a.cgccpfnum = ? '
                  ,'    and a.cgccpfdig = ? '
                  ,'    and a.edsnumdig in '
                  ,'   (select max(edsnumdig) '
                  ,'      from datkazlapl b '
                  ,'     where a.succod = b.succod '
                  ,'       and a.aplnumdig = b.aplnumdig '
                  ,'       and a.itmnumdig = b.itmnumdig '
                  ,'       and a.ramcod = b.ramcod) '
    prepare pcty23g00002 from l_StrSql
    declare ccty23g00002 cursor for pcty23g00002
    
    let l_StrSql = ' select a.azlaplcod '
                  ,'   from datkazlapl a '
                  ,'  where a.cgccpfnum = ? '
                  ,'    and a.cgcord = ? '
                  ,'    and a.cgccpfdig = ? '
                  ,'    and a.edsnumdig in '
                  ,'   (select max(edsnumdig) '
                  ,'      from datkazlapl b '
                  ,'     where a.succod = b.succod '
                  ,'       and a.aplnumdig = b.aplnumdig '
                  ,'       and a.itmnumdig = b.itmnumdig '
                  ,'       and a.ramcod = b.ramcod) '
    prepare pcty23g00003 from l_StrSql
    declare ccty23g00003 cursor for pcty23g00003
    
    let l_StrSql = ' select unique '
                  ,'        aplnumdig '
                  ,'       ,succod '
                  ,'       ,itmnumdig '
                  ,'       ,ramcod '
                  ,'   from datkazlapl '
                  ,'  where vcllicnum = ? '
    prepare pcty23g00008 from l_StrSql
    declare ccty23g00008 cursor for pcty23g00008
    
    let l_StrSql = ' select azlaplcod '
                  ,'   from datkazlapl '
                  ,'  where vcllicnum = ? '
                  ,'    and aplnumdig = ? '
                  ,'    and itmnumdig = ? '
                  ,'    and ramcod = ? '
                  ,'    and edsnumdig = ? '
    prepare pcty23g00009 from l_StrSql
    declare ccty23g00009 cursor for pcty23g00009
    
    let l_StrSql = ' select max (edsnumdig) '
                  ,'   from datkazlapl '
                  ,'  where succod = ? '
                  ,'    and aplnumdig = ? '
                  ,'    and itmnumdig = ? '
                  ,'    and ramcod    = ? '
                 #,'    and vcllicnum = ? '
    prepare pcty23g00010 from l_StrSql
    declare ccty23g00010 cursor for pcty23g00010
    
end function

function cty23g00_prepare_itau()                                                
    
    define l_StrSql     char(3000)
    
    initialize l_StrSql to null
    
    let l_StrSql = ' select a.aplseqnum '
                  ,'       ,b.itaaplnum '
                  ,'       ,b.autplcnum '
                  ,'       ,b.itaaplcanmtvcod '
                  ,'       ,a.pestipcod '
                  ,'       ,a.segcgccpfnum '
                  ,'       ,a.segcgcordnum '
                  ,'       ,a.segcgccpfdig '
                  ,'       ,a.itaaplvigincdat '
                  ,'       ,a.itaaplvigfnldat '
                  ,'       ,a.succod '
                  ,'       ,a.itaciacod '
                  ,'       ,a.itaramcod '
                  ,'       ,a.corsus '
                  ,'   from datmitaapl a '
                  ,'       ,datmitaaplitm b '
                  ,'  where a.itaciacod = b.itaciacod '
                  ,'    and a.itaramcod = b.itaramcod '
                  ,'    and a.itaaplnum = b.itaaplnum '
                  ,'    and a.aplseqnum = b.aplseqnum '
                  ,'    and b.autchsnum = ? '
                  ,'  order by a.itaaplvigfnldat desc '
                  ,'          ,a.aplseqnum desc '
    prepare pcty23g00004 from l_StrSql
    declare ccty23g00004 cursor for pcty23g00004
    
    let l_StrSql = ' select a.itaaplvigincdat '
                  ,'       ,a.itaaplvigfnldat '
                  ,'       ,b.itaaplcanmtvcod '
                  ,'   from datmitaapl a '
                  ,'       ,datmitaaplitm b '
                  ,'  where a.itaciacod = b.itaciacod '
                  ,'    and a.itaramcod = b.itaramcod '
                  ,'    and a.itaaplnum = b.itaaplnum '
                  ,'    and a.aplseqnum = b.aplseqnum '
                  ,'    and a.segcgccpfnum = ? '
                  ,'    and a.segcgccpfdig = ? '
                  ,'  order by a.itaaplvigfnldat desc '
                  ,'          ,a.itaaplnum desc '
                  ,'          ,a.aplseqnum desc '
    prepare pcty23g00006 from l_StrSql
    declare ccty23g00006 cursor for pcty23g00006
    
    let l_StrSql = ' select a.itaaplvigincdat '
                  ,'       ,a.itaaplvigfnldat '
                  ,'       ,b.itaaplcanmtvcod '
                  ,'   from datmitaapl a '
                  ,'       ,datmitaaplitm b '
                  ,'  where a.itaciacod = b.itaciacod '
                  ,'    and a.itaramcod = b.itaramcod '
                  ,'    and a.itaaplnum = b.itaaplnum '
                  ,'    and a.aplseqnum = b.aplseqnum '
                  ,'    and a.segcgccpfnum = ? '
                  ,'    and a.segcgcordnum = ? '
                  ,'    and a.segcgccpfdig = ? '
                  ,'  order by a.itaaplvigfnldat desc '
                  ,'          ,a.itaaplnum desc '
                  ,'          ,a.aplseqnum desc '
    prepare pcty23g00007 from l_StrSql
    declare ccty23g00007 cursor for pcty23g00007
    
    let l_StrSql = ' select b.itaaplnum '
                  ,'       ,b.aplseqnum '
                  ,'       ,b.autplcnum '
                  ,'       ,b.itaaplcanmtvcod '
                  ,'       ,b.autchsnum '
                  ,'       ,a.pestipcod '
                  ,'       ,a.segcgccpfnum '
                  ,'       ,a.segcgcordnum '
                  ,'       ,a.segcgccpfdig '
                  ,'       ,a.itaaplvigincdat '
                  ,'       ,a.itaaplvigfnldat '
                  ,'       ,a.succod '
                  ,'       ,a.corsus '
                  ,'   from datmitaapl a '
                  ,'       ,datmitaaplitm b '
                   ,'  where a.itaciacod = b.itaciacod '
                  ,'    and a.itaramcod = b.itaramcod '
                  ,'    and a.itaaplnum = b.itaaplnum '
                  ,'    and a.aplseqnum = b.aplseqnum '
                  ,'    and b.autplcnum = ? '
                  ,'    and a.aplseqnum = '
                  ,'   (select max(c.aplseqnum) '
                  ,'      from datmitaapl c '
                  ,'     where a.itaciacod = c.itaciacod '
                  ,'       and a.itaramcod = c.itaramcod '
                  ,'       and a.itaaplnum = c.itaaplnum) '
                  ,'  order by a.itaaplvigfnldat desc '
    prepare pcty23g00011 from l_StrSql
    declare ccty23g00011 cursor for pcty23g00011
    
    let l_StrSql = ' select max(a.aplseqnum) '
                  ,'   from datmitaapl a '
                  ,'       ,datmitaaplitm b '
                  ,'  where a.itaciacod = ? '
                  ,'    and a.itaramcod = ? '
                  ,'    and a.itaaplnum = ? '
                  ,'    and b.autchsnum = ? '
    prepare pcty23g00012 from l_StrSql
    declare ccty23g00012 cursor for pcty23g00012
    
    let l_StrSql = ' select a.aplseqnum '
                  ,'       ,b.itaaplnum '
                  ,'       ,b.autplcnum '
                  ,'       ,b.itaaplcanmtvcod '
                  ,'       ,a.pestipcod '
                  ,'       ,a.segcgccpfnum '
                  ,'       ,a.segcgcordnum '
                  ,'       ,a.segcgccpfdig '
                  ,'       ,a.itaaplvigincdat '
                  ,'       ,a.itaaplvigfnldat '
                  ,'       ,a.succod '
                  ,'       ,a.itaciacod '
                  ,'       ,a.itaramcod '
                  ,'       ,a.corsus '
                  ,'   from datmitaapl a '
                  ,'       ,datmitaaplitm b '
                  ,'  where a.itaciacod = b.itaciacod '
                  ,'    and a.itaramcod = b.itaramcod '
                  ,'    and a.itaaplnum = b.itaaplnum '
                  ,'    and a.aplseqnum = b.aplseqnum '
                  ,'    and a.itaciacod = ? '
                  ,'    and a.succod = ? '
                  ,'    and a.itaramcod = ? '
                  ,'    and a.itaaplnum = ? '
                  ,'    and a.aplseqnum = ? '
                  ,'    and b.autplcnum = ? '
                  ,'    and b.autchsnum = ? '
                  ,'  order by a.itaaplvigfnldat desc '
                  ,'          ,a.aplseqnum desc '
    prepare pcty23g00013 from l_StrSql
    declare ccty23g00013 cursor for pcty23g00013    	
    	
   let l_StrSql = ' select sucnom  ' 
                 ,'   from gabksuc '
                 ,'  where succod = ? '
   prepare pcty23g00014 from l_StrSql
   declare ccty23g00014 cursor for pcty23g00014
    
end function

function cty23g00_consul_apol_chas_azul(lr_param)
    
    define lr_param record
        chassi_ini              char(12)
       ,chassi_fim              char(08)
       ,data_vistoria           date
    end record
    
    define lr_cty23g00 record
        documento               char(30)
       ,aplnumdig               dec(9,0)
       ,itmnumdig               decimal(7,0)
       ,edsnumref               decimal(9,0)
       ,succod                  smallint     
       ,sucnom                  char(40)
       ,ramcod                  smallint
       ,emsdat                  date
       ,viginc                  date
       ,vigfnl                  date
       ,segcod                  integer
       ,segnom                  char(50)
       ,vcldes                  char(25)
       ,corsus                  char(06)
       ,situacao                char(15)
       ,tipo_pessoa             char(01)
       ,cgccpfnum               like gsakseg.cgccpfnum
       ,cgcord                  like gsakseg.cgcord
       ,cgccpfdig               like gsakseg.cgccpfdig
       ,vcllicnum               like abbmveic.vcllicnum
       ,vclchs                  char(20)
    end record
    
    define l_chassi_completo    char(17)
    define l_conta integer
    initialize lr_cty23g00.*    to null
    initialize mr_cty23g00.*    to null
    
    if lr_param.chassi_ini      is not null and
       lr_param.chassi_fim      is not null and
       lr_param.data_vistoria   is not null and
       lr_param.chassi_ini      <> ' '      and
       lr_param.chassi_fim      <> ' '      and
       lr_param.data_vistoria   <> ' '      then
       
        if m_prep_sql_azul      is null     or
           m_prep_sql_azul      = false     then
            let m_prep_sql_azul = true
            call cty23g00_prepare_azul()
        end if

        whenever error continue
        open  ccty23g00001
        using lr_param.chassi_fim
        fetch ccty23g00001
        into  mr_cty23g00.xml
        whenever error stop

        if sqlca.sqlcode = 0 then
            
            foreach ccty23g00001
            into    mr_cty23g00.azlaplcod

            let l_conta = 0 

            execute cty23g00000 using mr_cty23g00.azlaplcod into l_conta

            if l_conta = 0 then 
               let lr_cty23g00.succod      = null
               let lr_cty23g00.sucnom      = null
               let lr_cty23g00.aplnumdig   = null
               let lr_cty23g00.itmnumdig   = null
               let lr_cty23g00.tipo_pessoa = null
               let lr_cty23g00.cgccpfnum   = null
               let lr_cty23g00.cgcord      = null
               let lr_cty23g00.cgccpfdig   = null
               let lr_cty23g00.vcllicnum   = null
               let lr_cty23g00.viginc      = null
               let lr_cty23g00.vigfnl      = null
               let lr_cty23g00.corsus      = null

               return lr_cty23g00.succod       
                     ,lr_cty23g00.sucnom
                     ,lr_cty23g00.aplnumdig
                     ,lr_cty23g00.itmnumdig
                     ,lr_cty23g00.tipo_pessoa
                     ,lr_cty23g00.cgccpfnum
                     ,lr_cty23g00.cgcord
                     ,lr_cty23g00.cgccpfdig
                     ,lr_cty23g00.vcllicnum
                     ,lr_cty23g00.viginc
                     ,lr_cty23g00.vigfnl
                     ,lr_cty23g00.corsus
           end if             	
            	
                
                let mr_cty23g00.doc_handle =
                ctd02g00_agrupaXML2(mr_cty23g00.azlaplcod)
                
                call cty23g00_extrai_dados_chassi_azul(
                          mr_cty23g00.doc_handle)
                returning lr_cty23g00.succod      # Sucursal
                         ,lr_cty23g00.sucnom      # Nome da Sucursal
                         ,lr_cty23g00.aplnumdig   # Apolice
                         ,lr_cty23g00.itmnumdig   # Item da Apolice
                         ,lr_cty23g00.tipo_pessoa # Tipo Pessoa (F ou J)
                         ,lr_cty23g00.cgccpfnum   # CPF OU CGC
                         ,lr_cty23g00.cgcord      # Ordem CGC
                         ,lr_cty23g00.cgccpfdig   # Digito do CPF ou CGC
                         ,lr_cty23g00.vcllicnum   # PLACA
                         ,lr_cty23g00.viginc      # Vigencia Inicial
                         ,lr_cty23g00.vigfnl      # Vigencia Final
                         ,lr_cty23g00.situacao    # Situacao da Apolice
                         ,lr_cty23g00.vclchs      # Chassi
                         ,lr_cty23g00.corsus      # SUSEP
                         
                if lr_cty23g00.situacao <> 'ATIVA' then
                    initialize lr_cty23g00.succod      to null
                    initialize lr_cty23g00.sucnom      to null
                    initialize lr_cty23g00.aplnumdig   to null
                    initialize lr_cty23g00.itmnumdig   to null
                    initialize lr_cty23g00.tipo_pessoa to null
                    initialize lr_cty23g00.cgccpfnum   to null
                    initialize lr_cty23g00.cgcord      to null
                    initialize lr_cty23g00.cgccpfdig   to null
                    initialize lr_cty23g00.vcllicnum   to null
                    initialize lr_cty23g00.viginc      to null
                    initialize lr_cty23g00.vigfnl      to null
                    initialize lr_cty23g00.situacao    to null
                    initialize lr_cty23g00.vclchs      to null
                    initialize lr_cty23g00.corsus      to null
                    continue foreach
                end if
                
                let l_chassi_completo =
                    lr_param.chassi_ini clipped
                   ,lr_param.chassi_fim clipped
                   
                if lr_cty23g00.vclchs <> l_chassi_completo then
                    initialize lr_cty23g00.succod      to null
                    initialize lr_cty23g00.sucnom      to null
                    initialize lr_cty23g00.aplnumdig   to null
                    initialize lr_cty23g00.itmnumdig   to null
                    initialize lr_cty23g00.tipo_pessoa to null
                    initialize lr_cty23g00.cgccpfnum   to null
                    initialize lr_cty23g00.cgcord      to null
                    initialize lr_cty23g00.cgccpfdig   to null
                    initialize lr_cty23g00.vcllicnum   to null
                    initialize lr_cty23g00.viginc      to null
                    initialize lr_cty23g00.vigfnl      to null
                    initialize lr_cty23g00.situacao    to null
                    initialize lr_cty23g00.vclchs      to null
                    initialize lr_cty23g00.corsus      to null
                    continue foreach
                end if
                
                if lr_cty23g00.vigfnl < today then
                    initialize lr_cty23g00.succod      to null     
                    initialize lr_cty23g00.sucnom      to null
                    initialize lr_cty23g00.aplnumdig   to null
                    initialize lr_cty23g00.itmnumdig   to null
                    initialize lr_cty23g00.tipo_pessoa to null
                    initialize lr_cty23g00.cgccpfnum   to null
                    initialize lr_cty23g00.cgcord      to null
                    initialize lr_cty23g00.cgccpfdig   to null
                    initialize lr_cty23g00.vcllicnum   to null
                    initialize lr_cty23g00.viginc      to null
                    initialize lr_cty23g00.vigfnl      to null
                    initialize lr_cty23g00.situacao    to null
                    initialize lr_cty23g00.vclchs      to null
                    initialize lr_cty23g00.corsus      to null
                    continue foreach
                end if
                
                if lr_param.data_vistoria < lr_cty23g00.viginc or
                   lr_param.data_vistoria > lr_cty23g00.vigfnl then
                    initialize lr_cty23g00.succod      to null     
                    initialize lr_cty23g00.sucnom      to null
                    initialize lr_cty23g00.aplnumdig   to null
                    initialize lr_cty23g00.itmnumdig   to null
                    initialize lr_cty23g00.tipo_pessoa to null
                    initialize lr_cty23g00.cgccpfnum   to null
                    initialize lr_cty23g00.cgcord      to null
                    initialize lr_cty23g00.cgccpfdig   to null
                    initialize lr_cty23g00.vcllicnum   to null
                    initialize lr_cty23g00.viginc      to null
                    initialize lr_cty23g00.vigfnl      to null
                    initialize lr_cty23g00.situacao    to null
                    initialize lr_cty23g00.vclchs      to null
                    initialize lr_cty23g00.corsus      to null
                    continue foreach
                end if
                
                exit foreach
                
            end foreach

        end if
        
    end if
    
    return lr_cty23g00.succod 
          ,lr_cty23g00.sucnom
          ,lr_cty23g00.aplnumdig
          ,lr_cty23g00.itmnumdig
          ,lr_cty23g00.tipo_pessoa
          ,lr_cty23g00.cgccpfnum
          ,lr_cty23g00.cgcord
          ,lr_cty23g00.cgccpfdig
          ,lr_cty23g00.vcllicnum
          ,lr_cty23g00.viginc
          ,lr_cty23g00.vigfnl
          ,lr_cty23g00.corsus
          
end function

function cty23g00_consul_cpfcgc_azul(lr_param)
    
    define lr_param record
        tipo_pessoa             char(1)
       ,cgccpfnum               like gsakseg.cgccpfnum
       ,cgcord                  like gsakseg.cgcord
       ,cgccpfdig               like gsakseg.cgccpfdig
       ,data_vistoria           date
    end record
    
    define lr_cty23g00 record
        situacao                char(15)
       ,viginc                  date
       ,vigfnl                  date
    end record
    
    define l_retorno            smallint
    define l_conta integer
    initialize mr_cty23g00.*    to null
    initialize lr_cty23g00.*    to null
    
    let l_retorno = true
    
    if lr_param.tipo_pessoa is not null and
       lr_param.cgccpfnum   is not null and
       lr_param.cgccpfdig   is not null and
       lr_param.tipo_pessoa <> ' '      and
       lr_param.cgccpfnum   <> ' '      and
       lr_param.cgccpfdig   <> ' '      then
       
       if m_prep_sql_azul  is null or
          m_prep_sql_azul  = false then
           let m_prep_sql_azul = true
           call cty23g00_prepare_azul()
       end if
       
       if lr_param.tipo_pessoa = 'F' then
          
          whenever error continue
          open  ccty23g00002
          using lr_param.cgccpfnum
               ,lr_param.cgccpfdig
          fetch ccty23g00002
          into  mr_cty23g00.azlaplcod
          whenever error stop
  
          if sqlca.sqlcode = 0 then          


             foreach ccty23g00002 into mr_cty23g00.azlaplcod
             
                let l_conta = 0 
                
                execute cty23g00000 using mr_cty23g00.azlaplcod into l_conta                
                
                if l_conta = 0 then 
                   let l_retorno = false
                   return l_retorno
                end if  
                
                let mr_cty23g00.doc_handle =
                    ctd02g00_agrupaXML2(mr_cty23g00.azlaplcod)
                    
                call cty23g00_extrai_dados_cgccpf_azul(
                          mr_cty23g00.doc_handle)
                returning lr_cty23g00.situacao
                         ,lr_cty23g00.viginc
                         ,lr_cty23g00.vigfnl
                         
                if lr_cty23g00.situacao <> 'ATIVA' then
                    continue foreach
                end if
                
                if lr_param.data_vistoria < lr_cty23g00.viginc or
                   lr_param.data_vistoria > lr_cty23g00.vigfnl then
                    continue foreach
                end if
                
                exit foreach
             
             end foreach
       
          else
                  
             let l_retorno = false
                  
          end if
            
       else 
         
         whenever error continue
         open  ccty23g00003
         using lr_param.cgccpfnum
              ,lr_param.cgcord
              ,lr_param.cgccpfdig
         fetch ccty23g00003
         into  mr_cty23g00.azlaplcod
         whenever error stop

         if sqlca.sqlcode = 0 then
             
             foreach ccty23g00003 into mr_cty23g00.azlaplcod

               let l_conta = 0 
               
               execute cty23g00000 using mr_cty23g00.azlaplcod into l_conta                
               
               if l_conta = 0 then 
                  let l_retorno = false
                  return l_retorno
               end if 
                  
               let mr_cty23g00.doc_handle =
                   ctd02g00_agrupaXML(mr_cty23g00.azlaplcod)
               
               call cty23g00_extrai_dados_cgccpf_azul(
                         mr_cty23g00.doc_handle)
               returning lr_cty23g00.situacao
                        ,lr_cty23g00.viginc
                        ,lr_cty23g00.vigfnl
                        
               if lr_cty23g00.situacao <> 'ATIVA' then
                   continue foreach
               end if
               
               if lr_param.data_vistoria < lr_cty23g00.viginc or
                  lr_param.data_vistoria > lr_cty23g00.vigfnl then
                   continue foreach
               end if
               
               exit foreach
               
             end foreach
             
         else
             
             let l_retorno = false
             
         end if
      
       end if         
    
    else
        
        let l_retorno = false
        
    end if
    
    return l_retorno
    
end function

function cty23g00_consul_apol_placa_azul(lr_param)
    
    define lr_param record
        placa                   like datkazlapl.vcllicnum
       ,data_vistoria           date
    end record
    
    define lr_cty23g00 record
        documento               char(30)
       ,aplnumdig               dec(9,0)
       ,itmnumdig               decimal(7,0)
       ,edsnumref               decimal(9,0)
       ,succod                  smallint
       ,sucnom                  char(40)
       ,ramcod                  smallint
       ,emsdat                  date
       ,viginc                  date
       ,vigfnl                  date
       ,segcod                  integer
       ,segnom                  char(50)
       ,vcldes                  char(25)
       ,corsus                  char(06)
       ,situacao                char(15)
       ,tipo_pessoa             char(01)
       ,cgccpfnum               like gsakseg.cgccpfnum
       ,cgcord                  like gsakseg.cgcord
       ,cgccpfdig               like gsakseg.cgccpfdig
       ,vcllicnum               like abbmveic.vcllicnum
       ,vclchs                  char(20)
    end record
    
    define l_aplnumdig          decimal(9,0)
    define l_max                decimal(10,0)
    define l_succod             smallint
    define l_itmnumdig          decimal(7,0)
    define l_ramcod             smallint
    define l_conta              integer 
    initialize l_aplnumdig      to null
    initialize l_max            to null
    initialize l_succod         to null
    initialize l_itmnumdig      to null
    initialize l_ramcod         to null
    
    initialize lr_cty23g00.*    to null
    initialize mr_cty23g00.*    to null
    
    if lr_param.placa            is not null and
       lr_param.data_vistoria    is not null and
       lr_param.placa            <> ' '      and
       lr_param.data_vistoria    <> ' '      then
        
        if m_prep_sql_azul is null or
           m_prep_sql_azul = false then
            let m_prep_sql_azul = true
            call cty23g00_prepare_azul()
        end if
        
        open  ccty23g00008
        using lr_param.placa
        
        foreach ccty23g00008
        into    l_aplnumdig
               ,l_succod
               ,l_itmnumdig
               ,l_ramcod
               
            let l_max = 0
            
            whenever error continue
            open  ccty23g00010
            using l_succod
                 ,l_aplnumdig
                 ,l_itmnumdig
                 ,l_ramcod
                #,lr_param.placa
            fetch ccty23g00010
            into  l_max
            whenever error stop
            
            if sqlca.sqlcode <> 0 then
                continue foreach
            end if
            
            whenever error continue
            open  ccty23g00009
            using lr_param.placa
                 ,l_aplnumdig
                 ,l_itmnumdig
                 ,l_ramcod
                 ,l_max
            fetch ccty23g00009
            into  mr_cty23g00.azlaplcod
            whenever error stop

            if sqlca.sqlcode < 0 then
                continue foreach
            end if
            
            let l_conta = 0                                                          

            execute cty23g00000 using mr_cty23g00.azlaplcod into l_conta             
                
            if l_conta = 0 then 
               let lr_cty23g00.succod      = null    
               let lr_cty23g00.sucnom      = null
               let lr_cty23g00.aplnumdig   = null
               let lr_cty23g00.itmnumdig   = null
               let lr_cty23g00.tipo_pessoa = null
               let lr_cty23g00.cgccpfnum   = null
               let lr_cty23g00.cgcord      = null
               let lr_cty23g00.cgccpfdig   = null
               let lr_cty23g00.vcllicnum   = null
               let lr_cty23g00.viginc      = null
               let lr_cty23g00.vigfnl      = null
               let lr_cty23g00.corsus      = null

               return lr_cty23g00.succod
                     ,lr_cty23g00.sucnom
                     ,lr_cty23g00.aplnumdig
                     ,lr_cty23g00.itmnumdig
                     ,lr_cty23g00.tipo_pessoa
                     ,lr_cty23g00.cgccpfnum
                     ,lr_cty23g00.cgcord
                     ,lr_cty23g00.cgccpfdig
                     ,lr_cty23g00.vcllicnum
                     ,lr_cty23g00.viginc
                     ,lr_cty23g00.vigfnl
                     ,lr_cty23g00.corsus
           end if 
            
            let mr_cty23g00.doc_handle =
                ctd02g00_agrupaXML(mr_cty23g00.azlaplcod)
                
            call cty23g00_extrai_dados_placa_azul(
                      mr_cty23g00.doc_handle)
            returning lr_cty23g00.succod      # Sucursal
                     ,lr_cty23g00.sucnom      # Nome da Sucursal
                     ,lr_cty23g00.aplnumdig   # Apolice
                     ,lr_cty23g00.itmnumdig   # Item da Apolice
                     ,lr_cty23g00.tipo_pessoa # Tipo Pessoa (F ou J)
                     ,lr_cty23g00.cgccpfnum   # CPF OU CGC
                     ,lr_cty23g00.cgcord      # Ordem CGC
                     ,lr_cty23g00.cgccpfdig   # Digito do CPF ou CGC
                     ,lr_cty23g00.vcllicnum   # PLACA
                     ,lr_cty23g00.viginc      # Vigencia Inicial
                     ,lr_cty23g00.vigfnl      # Vigencia Final
                     ,lr_cty23g00.situacao    # Situacao da Apolice
                     ,lr_cty23g00.vclchs      # Chassi
                     ,lr_cty23g00.corsus      # SUSEP
                     
            if lr_cty23g00.situacao <> 'ATIVA' then
                initialize lr_cty23g00.succod      to null
                initialize lr_cty23g00.sucnom      to null
                initialize lr_cty23g00.aplnumdig   to null
                initialize lr_cty23g00.itmnumdig   to null
                initialize lr_cty23g00.tipo_pessoa to null
                initialize lr_cty23g00.cgccpfnum   to null
                initialize lr_cty23g00.cgcord      to null
                initialize lr_cty23g00.cgccpfdig   to null
                initialize lr_cty23g00.vclchs      to null
                initialize lr_cty23g00.vcllicnum   to null
                initialize lr_cty23g00.viginc      to null
                initialize lr_cty23g00.vigfnl      to null
                initialize lr_cty23g00.corsus      to null
                continue foreach
            end if
            
            if lr_cty23g00.vigfnl < today then
                initialize lr_cty23g00.succod      to null
                initialize lr_cty23g00.sucnom      to null
                initialize lr_cty23g00.aplnumdig   to null
                initialize lr_cty23g00.itmnumdig   to null
                initialize lr_cty23g00.tipo_pessoa to null
                initialize lr_cty23g00.cgccpfnum   to null
                initialize lr_cty23g00.cgcord      to null
                initialize lr_cty23g00.cgccpfdig   to null
                initialize lr_cty23g00.vclchs      to null
                initialize lr_cty23g00.vcllicnum   to null
                initialize lr_cty23g00.viginc      to null
                initialize lr_cty23g00.vigfnl      to null
                initialize lr_cty23g00.corsus      to null
                continue foreach
            end if
            
            if lr_param.data_vistoria < lr_cty23g00.viginc or
               lr_param.data_vistoria > lr_cty23g00.vigfnl then
                initialize lr_cty23g00.succod      to null
                initialize lr_cty23g00.sucnom      to null
                initialize lr_cty23g00.aplnumdig   to null
                initialize lr_cty23g00.itmnumdig   to null
                initialize lr_cty23g00.tipo_pessoa to null
                initialize lr_cty23g00.cgccpfnum   to null
                initialize lr_cty23g00.cgcord      to null
                initialize lr_cty23g00.cgccpfdig   to null
                initialize lr_cty23g00.vclchs      to null
                initialize lr_cty23g00.vcllicnum   to null
                initialize lr_cty23g00.viginc      to null
                initialize lr_cty23g00.vigfnl      to null
                initialize lr_cty23g00.corsus      to null
                continue foreach
            end if
            
            exit foreach
            
        end foreach
        
    end if
    
    return lr_cty23g00.succod
          ,lr_cty23g00.sucnom
          ,lr_cty23g00.aplnumdig
          ,lr_cty23g00.itmnumdig
          ,lr_cty23g00.tipo_pessoa
          ,lr_cty23g00.cgccpfnum
          ,lr_cty23g00.cgcord
          ,lr_cty23g00.cgccpfdig
          ,lr_cty23g00.vclchs
          ,lr_cty23g00.viginc
          ,lr_cty23g00.vigfnl
          ,lr_cty23g00.corsus
          
end function

function cty23g00_consul_apol_chas_itau(lr_param)
    
    define lr_param record
        chassi_comp             like datmitaaplitm.autchsnum
       ,data_vistoria           date
    end record
    
    define lr_cty23g00 record
        succod                  like datmitaapl.succod    
       ,sucnom                  char(40)
       ,itaaplnum               like datmitaapl.itaaplnum
       ,aplseqnum               like datmitaapl.aplseqnum
       ,tipo_pessoa             char(01)
       ,cgccpfnum               like gsakseg.cgccpfnum
       ,cgcord                  like gsakseg.cgcord
       ,cgccpfdig               like gsakseg.cgccpfdig
       ,autplcnum               like datmitaaplitm.autplcnum
       ,itaaplvigincdat         like datmitaapl.itaaplvigincdat
       ,itaaplvigfnldat         like datmitaapl.itaaplvigfnldat
       ,itaaplcanmtvcod         like datmitaaplitm.itaaplcanmtvcod
       ,itaciacod               like datmitaapl.itaciacod
       ,itaramcod               like datmitaapl.itaramcod
       ,corsus                  like datmitaapl.corsus
       ,cont                    smallint
    end record
    
    define lr_cty23g00_aux record
        succod                  like datmitaapl.succod   
       ,sucnom                  char(40)
       ,itaaplnum               like datmitaapl.itaaplnum
       ,aplseqnum               like datmitaapl.aplseqnum
       ,tipo_pessoa             char(01)
       ,cgccpfnum               like gsakseg.cgccpfnum
       ,cgcord                  like gsakseg.cgcord
       ,cgccpfdig               like gsakseg.cgccpfdig
       ,autplcnum               like datmitaaplitm.autplcnum
       ,itaaplvigincdat         like datmitaapl.itaaplvigincdat
       ,itaaplvigfnldat         like datmitaapl.itaaplvigfnldat
       ,itaaplcanmtvcod         like datmitaaplitm.itaaplcanmtvcod
       ,itaciacod               like datmitaapl.itaciacod
       ,itaramcod               like datmitaapl.itaramcod
       ,corsus                  like datmitaapl.corsus
       ,cont                    smallint
    end record
    
    define l_max                decimal(10,0)
    
    initialize l_max                to null
    initialize lr_cty23g00.*        to null
    initialize lr_cty23g00_aux.*    to null
    
    if lr_param.chassi_comp     is not null and
       lr_param.data_vistoria   is not null and
       lr_param.chassi_comp     <> ' '      and
       lr_param.data_vistoria   <> ' '      then
        
        if m_prep_sql_itau is null or
           m_prep_sql_itau = false then
            let m_prep_sql_itau = true
            call cty23g00_prepare_itau()
        end if
        
        open  ccty23g00004
        using lr_param.chassi_comp
        
        foreach ccty23g00004
        into    lr_cty23g00.aplseqnum
               ,lr_cty23g00.itaaplnum
               ,lr_cty23g00.autplcnum
               ,lr_cty23g00.itaaplcanmtvcod
               ,lr_cty23g00.tipo_pessoa
               ,lr_cty23g00.cgccpfnum
               ,lr_cty23g00.cgcord
               ,lr_cty23g00.cgccpfdig
               ,lr_cty23g00.itaaplvigincdat
               ,lr_cty23g00.itaaplvigfnldat
               ,lr_cty23g00.succod
               ,lr_cty23g00.itaciacod
               ,lr_cty23g00.itaramcod
               ,lr_cty23g00.corsus
               
            whenever error continue
            open  ccty23g00012
            using lr_cty23g00.itaciacod
                 ,lr_cty23g00.itaramcod
                 ,lr_cty23g00.itaaplnum
                 ,lr_param.chassi_comp
            fetch ccty23g00012
            into  l_max
            whenever error stop
            
            if sqlca.sqlcode <> 0 then
                continue foreach
            end if
            
            whenever error continue
            open  ccty23g00013
            using lr_cty23g00.itaciacod
                 ,lr_cty23g00.succod
                 ,lr_cty23g00.itaramcod
                 ,lr_cty23g00.itaaplnum
                 ,l_max
                 ,lr_cty23g00.autplcnum
                 ,lr_param.chassi_comp
            fetch ccty23g00013
            into  lr_cty23g00_aux.aplseqnum
                 ,lr_cty23g00_aux.itaaplnum
                 ,lr_cty23g00_aux.autplcnum
                 ,lr_cty23g00_aux.itaaplcanmtvcod
                 ,lr_cty23g00_aux.tipo_pessoa
                 ,lr_cty23g00_aux.cgccpfnum
                 ,lr_cty23g00_aux.cgcord
                 ,lr_cty23g00_aux.cgccpfdig
                 ,lr_cty23g00_aux.itaaplvigincdat
                 ,lr_cty23g00_aux.itaaplvigfnldat
                 ,lr_cty23g00_aux.succod
                 ,lr_cty23g00_aux.itaciacod
                 ,lr_cty23g00_aux.itaramcod
                 ,lr_cty23g00_aux.corsus
            whenever error stop
            
            if sqlca.sqlcode <> 0 then
                continue foreach
            end if
            
            if lr_cty23g00_aux.itaaplvigincdat <= today and
               lr_cty23g00_aux.itaaplvigfnldat >= today then
                if lr_cty23g00_aux.itaaplcanmtvcod is null then
                    let mr_cty23g00.sitdoc = 'ATIVA'
                else
                    let mr_cty23g00.sitdoc = 'CANCELADA'
                end if
            else
                let mr_cty23g00.sitdoc = 'VENCIDA'
            end if
            
            if mr_cty23g00.sitdoc <> 'ATIVA' then
                initialize mr_cty23g00.sitdoc to null
                initialize l_max              to null
                initialize lr_cty23g00.*      to null
                initialize lr_cty23g00_aux.*  to null
                continue foreach
            end if
            
            if lr_param.data_vistoria < lr_cty23g00_aux.itaaplvigincdat or
               lr_param.data_vistoria > lr_cty23g00_aux.itaaplvigfnldat then
                initialize mr_cty23g00.sitdoc  to null
                initialize l_max               to null
                initialize lr_cty23g00.*       to null
                initialize lr_cty23g00_aux.*   to null
                continue foreach
           end if
           
           exit foreach
           
       end foreach
       
   end if
   whenever error continue 
   open ccty23g00014 using lr_cty23g00_aux.succod   
   fetch ccty23g00014 into lr_cty23g00_aux.sucnom
   whenever error stop 
      
   return lr_cty23g00_aux.succod
         ,lr_cty23g00_aux.sucnom
         ,lr_cty23g00_aux.itaaplnum
         ,lr_cty23g00_aux.aplseqnum
         ,lr_cty23g00_aux.tipo_pessoa
         ,lr_cty23g00_aux.cgccpfnum
         ,lr_cty23g00_aux.cgcord
         ,lr_cty23g00_aux.cgccpfdig
         ,lr_cty23g00_aux.autplcnum
         ,lr_cty23g00_aux.itaaplvigincdat
         ,lr_cty23g00_aux.itaaplvigfnldat
         ,lr_cty23g00_aux.corsus
         
end function

function cty23g00_consul_apol_placa_itau(lr_param)
    
    define lr_param record
        placa                   like datmitaaplitm.autplcnum
       ,data_vistoria           date
    end record
    
    define lr_cty23g00 record
        succod                  like datmitaapl.succod
       ,sucnom                  char(40)
       ,itaaplnum               like datmitaapl.itaaplnum
       ,aplseqnum               like datmitaapl.aplseqnum
       ,tipo_pessoa             char(01)
       ,cgccpfnum               like gsakseg.cgccpfnum
       ,cgcord                  like gsakseg.cgcord
       ,cgccpfdig               like gsakseg.cgccpfdig
       ,autplcnum               like datmitaaplitm.autplcnum
       ,itaaplvigincdat         like datmitaapl.itaaplvigincdat
       ,itaaplvigfnldat         like datmitaapl.itaaplvigfnldat
       ,itaaplcanmtvcod         like datmitaaplitm.itaaplcanmtvcod
       ,autchsnum               like datmitaaplitm.autchsnum
       ,corsus                  like datmitaapl.corsus
    end record
    
    initialize lr_cty23g00.*    to null
    
    if lr_param.placa           is not null and
       lr_param.data_vistoria   is not null and
       lr_param.placa           <> ' '      and
       lr_param.data_vistoria   <> ' '      then
        
        if m_prep_sql_itau is null or
           m_prep_sql_itau = false then
            let m_prep_sql_itau = true
            call cty23g00_prepare_itau()
        end if
        
        open  ccty23g00011
        using lr_param.placa
        
        foreach ccty23g00011
        into    lr_cty23g00.itaaplnum
               ,lr_cty23g00.aplseqnum
               ,lr_cty23g00.autplcnum
               ,lr_cty23g00.itaaplcanmtvcod
               ,lr_cty23g00.autchsnum
               ,lr_cty23g00.tipo_pessoa
               ,lr_cty23g00.cgccpfnum
               ,lr_cty23g00.cgcord
               ,lr_cty23g00.cgccpfdig
               ,lr_cty23g00.itaaplvigincdat
               ,lr_cty23g00.itaaplvigfnldat
               ,lr_cty23g00.succod
               ,lr_cty23g00.corsus
               
            if lr_cty23g00.itaaplvigincdat <= today and
               lr_cty23g00.itaaplvigfnldat >= today then
                if lr_cty23g00.itaaplcanmtvcod is null then
                    let mr_cty23g00.sitdoc = 'ATIVA'
                else
                    let mr_cty23g00.sitdoc = 'CANCELADA'
                end if
            else
                let mr_cty23g00.sitdoc = 'VENCIDA'
            end if
            
            if mr_cty23g00.sitdoc <> 'ATIVA' then
                initialize lr_cty23g00.itaaplnum       to null
                initialize lr_cty23g00.aplseqnum       to null
                initialize lr_cty23g00.autchsnum       to null
                initialize lr_cty23g00.autplcnum       to null
                initialize lr_cty23g00.itaaplcanmtvcod to null
                initialize lr_cty23g00.tipo_pessoa     to null
                initialize lr_cty23g00.cgccpfnum       to null
                initialize lr_cty23g00.cgcord          to null
                initialize lr_cty23g00.cgccpfdig       to null
                initialize lr_cty23g00.itaaplvigincdat to null
                initialize lr_cty23g00.itaaplvigfnldat to null                                                 
                initialize lr_cty23g00.succod          to null
                initialize lr_cty23g00.sucnom          to null
                initialize lr_cty23g00.corsus          to null
                continue foreach
            end if
            
            if lr_param.data_vistoria < lr_cty23g00.itaaplvigincdat or
               lr_param.data_vistoria > lr_cty23g00.itaaplvigfnldat then
                initialize lr_cty23g00.itaaplnum       to null
                initialize lr_cty23g00.aplseqnum       to null
                initialize lr_cty23g00.autchsnum       to null
                initialize lr_cty23g00.autplcnum       to null
                initialize lr_cty23g00.itaaplcanmtvcod to null
                initialize lr_cty23g00.tipo_pessoa     to null
                initialize lr_cty23g00.cgccpfnum       to null
                initialize lr_cty23g00.cgcord          to null
                initialize lr_cty23g00.cgccpfdig       to null
                initialize lr_cty23g00.itaaplvigincdat to null
                initialize lr_cty23g00.itaaplvigfnldat to null
                initialize lr_cty23g00.succod          to null
                initialize lr_cty23g00.sucnom          to null
                initialize lr_cty23g00.corsus          to null
                continue foreach
            end if
            
            exit foreach
            
        end foreach
        
    end if
    
    return lr_cty23g00.succod
          ,lr_cty23g00.sucnom
          ,lr_cty23g00.itaaplnum
          ,lr_cty23g00.aplseqnum
          ,lr_cty23g00.tipo_pessoa
          ,lr_cty23g00.cgccpfnum
          ,lr_cty23g00.cgcord
          ,lr_cty23g00.cgccpfdig
          ,lr_cty23g00.autchsnum
          ,lr_cty23g00.itaaplvigincdat
          ,lr_cty23g00.itaaplvigfnldat
          ,lr_cty23g00.corsus
          
end function

function cty23g00_consul_cpfcgc_itau(lr_param)
    
    define lr_param record
        tipo_pessoa             char(01)
       ,cgccpfnum               like gsakseg.cgccpfnum
       ,cgcord                  like gsakseg.cgcord
       ,cgccpfdig               like gsakseg.cgccpfdig
       ,data_vistoria           date
    end record
    
    define lr_cty23g00 record
        itaaplvigincdat         like datmitaapl.itaaplvigincdat
       ,itaaplvigfnldat         like datmitaapl.itaaplvigfnldat
       ,itaaplcanmtvcod         like datmitaaplitm.itaaplcanmtvcod
    end record
    
    define l_retorno            smallint
    
    initialize lr_cty23g00.*    to null
    
    let l_retorno = true
    
    if lr_param.tipo_pessoa is not null and
       lr_param.cgccpfnum   is not null and
       lr_param.cgccpfdig   is not null and
       lr_param.tipo_pessoa <> ' '      and
       lr_param.cgccpfnum   <> ' '      and
       lr_param.cgccpfdig   <> ' '      then
        
        if m_prep_sql_itau is null or
         m_prep_sql_itau = false then
            let m_prep_sql_itau = true
            call cty23g00_prepare_itau()
        end if
        
        if lr_param.tipo_pessoa = 'F' then
            
            whenever error continue
            open  ccty23g00006
            using lr_param.cgccpfnum
                 ,lr_param.cgccpfdig
            fetch ccty23g00006
            into  lr_cty23g00.itaaplvigincdat
                 ,lr_cty23g00.itaaplvigfnldat
                 ,lr_cty23g00.itaaplcanmtvcod
            whenever error stop
            
            if sqlca.sqlcode <> 0 then
                let l_retorno = false
            end if
            
            if lr_cty23g00.itaaplvigincdat <= today and
               lr_cty23g00.itaaplvigfnldat >= today then
                if lr_cty23g00.itaaplcanmtvcod is null then
                    let mr_cty23g00.sitdoc = 'ATIVA'
                else
                    let mr_cty23g00.sitdoc = 'CANCELADA'
                end if
            else
                let mr_cty23g00.sitdoc = 'VENCIDA'
            end if
            
            if mr_cty23g00.sitdoc <> 'ATIVA' then
                let l_retorno = false
            end if
            
            if lr_param.data_vistoria < lr_cty23g00.itaaplvigincdat or
               lr_param.data_vistoria > lr_cty23g00.itaaplvigfnldat then
                let l_retorno = false
            end if
            
        else
            
            whenever error continue
            open  ccty23g00007
            using lr_param.cgccpfnum
                 ,lr_param.cgcord
                 ,lr_param.cgccpfdig
            fetch ccty23g00007
            into  lr_cty23g00.itaaplvigincdat
                 ,lr_cty23g00.itaaplvigfnldat
                 ,lr_cty23g00.itaaplcanmtvcod
            whenever error stop
            
            if sqlca.sqlcode <> 0 then
                let l_retorno = false
            end if
            
            if lr_cty23g00.itaaplvigincdat <= today and
               lr_cty23g00.itaaplvigfnldat >= today then
                if lr_cty23g00.itaaplcanmtvcod is null then
                    let mr_cty23g00.sitdoc = 'ATIVA'
                else
                    let mr_cty23g00.sitdoc = 'CANCELADA'
                end if
            else
                let mr_cty23g00.sitdoc = 'VENCIDA'
            end if
            
            if mr_cty23g00.sitdoc <> 'ATIVA' then
                let l_retorno = false
            end if
            
            if lr_param.data_vistoria < lr_cty23g00.itaaplvigincdat or
               lr_param.data_vistoria > lr_cty23g00.itaaplvigfnldat then
                let l_retorno = false
            end if
            
        end if
        
    else
        
        let l_retorno = false
        
    end if
    
    return l_retorno
    
end function

function cty23g00_extrai_dados_chassi_azul(l_doc_handle)
    
    define l_doc_handle     integer
    
    define lr_cty23g00 record
        documento           char(30)
       ,aplnumdig           dec(9,0)
       ,itmnumdig           dec(7,0)
       ,succod              smallint
       ,sucnom              char(40)
       ,tipo_pessoa         char(01)
       ,cgccpfnum           char(15)
       ,cgcord              char(05)
       ,cgccpfdig           char(03)
       ,vcllicnum           char(07)
       ,viginc              date
       ,vigfnl              date
       ,situacao            char(15)
       ,vclchs              char(20)
       ,corsus              char(06)
    end record
    
    define l_auxcgccpf      char(20)
    
    initialize lr_cty23g00.*    to null
    initialize l_auxcgccpf      to null
    
    let lr_cty23g00.documento   = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/APOLICE')
    let lr_cty23g00.itmnumdig   = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/ITEM')
    let lr_cty23g00.succod      = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/SUCURSAL')
    let lr_cty23g00.sucnom      = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/SUCURSALNOME')
    let lr_cty23g00.tipo_pessoa = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/SEGURADO/TIPOPESSOA')
    let l_auxcgccpf             = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/SEGURADO/CGCCPF')
    let lr_cty23g00.vcllicnum   = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/VEICULO/PLACA')
    let lr_cty23g00.viginc      = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/VIGENCIA/INICIAL')
    let lr_cty23g00.vigfnl      = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/VIGENCIA/FINAL')
    let lr_cty23g00.situacao    = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/SITUACAO')
    let lr_cty23g00.vclchs      = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/VEICULO/CHASSI')
    let lr_cty23g00.corsus      = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/CORRETOR/SUSEP')
                                 
    let lr_cty23g00.cgcord      = null
    let lr_cty23g00.cgccpfdig   = null
    let lr_cty23g00.aplnumdig   = lr_cty23g00.documento
    
    if length(l_auxcgccpf) <= 11 then
        let lr_cty23g00.cgccpfnum = l_auxcgccpf[1,9]
        let lr_cty23g00.cgcord    = null
        let lr_cty23g00.cgccpfdig = l_auxcgccpf[10,11]
    else
        let lr_cty23g00.cgccpfnum = l_auxcgccpf[1,8]
        let lr_cty23g00.cgcord    = l_auxcgccpf[9,12]
        let lr_cty23g00.cgccpfdig = l_auxcgccpf[13,14]
    end if
    
    return lr_cty23g00.succod
          ,lr_cty23g00.sucnom
          ,lr_cty23g00.aplnumdig
          ,lr_cty23g00.itmnumdig
          ,lr_cty23g00.tipo_pessoa
          ,lr_cty23g00.cgccpfnum
          ,lr_cty23g00.cgcord
          ,lr_cty23g00.cgccpfdig
          ,lr_cty23g00.vcllicnum
          ,lr_cty23g00.viginc
          ,lr_cty23g00.vigfnl
          ,lr_cty23g00.situacao
          ,lr_cty23g00.vclchs
          ,lr_cty23g00.corsus
          
end function

function cty23g00_extrai_dados_placa_azul(l_doc_handle)
    
    define l_doc_handle     integer
    
    define lr_cty23g00 record
        documento           char(30)
       ,aplnumdig           dec(9,0)
       ,itmnumdig           dec(7,0)
       ,succod              smallint
       ,sucnom              char(40)
       ,tipo_pessoa         char(01)
       ,cgccpfnum           char(15)
       ,cgcord              char(05)
       ,cgccpfdig           char(03)
       ,vcllicnum           char(07)
       ,viginc              date
       ,vigfnl              date
       ,situacao            char(15)
       ,vclchs              char(20)
       ,corsus              char(06)
    end record
    
    define l_auxcgccpf      char(20)
    
    initialize lr_cty23g00.*    to null
    initialize l_auxcgccpf      to null
    
    let lr_cty23g00.documento   = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/APOLICE')
    let lr_cty23g00.itmnumdig   = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/ITEM')
    let lr_cty23g00.succod      = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/SUCURSAL')
    let lr_cty23g00.sucnom      = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/SUCURSALNOME')
    let lr_cty23g00.tipo_pessoa = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/SEGURADO/TIPOPESSOA')
    let l_auxcgccpf             = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/SEGURADO/CGCCPF')
    let lr_cty23g00.vcllicnum   = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/VEICULO/PLACA')
    let lr_cty23g00.viginc      = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/VIGENCIA/INICIAL')
    let lr_cty23g00.vigfnl      = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/VIGENCIA/FINAL')
    let lr_cty23g00.situacao    = figrc011_xpath(l_doc_handle
                                 ,'/APOLICE/SITUACAO')
    let lr_cty23g00.vclchs      = figrc011_xpath(l_doc_handle
                                ,'/APOLICE/VEICULO/CHASSI')
    let lr_cty23g00.corsus      = figrc011_xpath(l_doc_handle
                                ,'/APOLICE/CORRETOR/SUSEP')
    
    let lr_cty23g00.cgcord      = null
    let lr_cty23g00.cgccpfdig   = null
    let lr_cty23g00.aplnumdig   = lr_cty23g00.documento
    
    if length(l_auxcgccpf) <= 11 then
        let lr_cty23g00.cgccpfnum = l_auxcgccpf[1,9]
        let lr_cty23g00.cgcord    = null
        let lr_cty23g00.cgccpfdig = l_auxcgccpf[10,11]
    else
        let lr_cty23g00.cgccpfnum = l_auxcgccpf[1,8]
        let lr_cty23g00.cgcord    = l_auxcgccpf[9,12]
        let lr_cty23g00.cgccpfdig = l_auxcgccpf[13,14]
    end if
    
    return lr_cty23g00.succod
          ,lr_cty23g00.sucnom
          ,lr_cty23g00.aplnumdig
          ,lr_cty23g00.itmnumdig
          ,lr_cty23g00.tipo_pessoa
          ,lr_cty23g00.cgccpfnum
          ,lr_cty23g00.cgcord
          ,lr_cty23g00.cgccpfdig
          ,lr_cty23g00.vcllicnum
          ,lr_cty23g00.viginc
          ,lr_cty23g00.vigfnl
          ,lr_cty23g00.situacao
          ,lr_cty23g00.vclchs
          ,lr_cty23g00.corsus
          
end function

function cty23g00_extrai_dados_cgccpf_azul(l_doc_handle)
    
    define l_doc_handle     integer
    
    define lr_cty23g00 record
        situacao            char(15)
       ,viginc              date
       ,vigfnl              date
    end record
    
    initialize lr_cty23g00.*    to null
    
    let lr_cty23g00.situacao = figrc011_xpath(l_doc_handle,'/APOLICE/SITUACAO')
    let lr_cty23g00.viginc   = figrc011_xpath(l_doc_handle,'/APOLICE/VIGENCIA/INICIAL')
    let lr_cty23g00.vigfnl   = figrc011_xpath(l_doc_handle,'/APOLICE/VIGENCIA/FINAL')
    
    return lr_cty23g00.situacao
          ,lr_cty23g00.viginc
          ,lr_cty23g00.vigfnl
          
end function