###############################################################################
# Nome do Modulo: BDATA103                                                    #
# Analista: Patricia Egri Wissinievski                                        #
# Data cria��o: 25/08/2008                                                    #
#                                                                             #
# Objetivo: Carga do arquivo ARQUIVORV.TXT contendo valores de RV             #
#                                                                             #
# PSI - 228087 RV NO INFORMIX - T�cnico Atendimento                           #
#                                                                             #
###############################################################################

database porto

define m_path char(80)
define m_mensagem char(100)

main

   call fun_dba_abre_banco("CT24HS")
   set isolation to dirty read

   let m_path = f_path("DAT", "LOG")
   
   if m_path is null then 
      let m_path = 'bdata103.log'
   else
      let m_path = m_path clipped, '/bdata103.log'
   end if 
   
   call startlog(m_path)

   call ERRORLOG("------------------------------------------------");
   call ERRORLOG("Inicio execucao BDATA103 ");
   
   call bdata103()

   call ERRORLOG("Termino execucao BDATA103 OK! ");
   call ERRORLOG("------------------------------------------------");

end main

# ------------------------------------------------------------------------------
function bdata103()
# ------------------------------------------------------------------------------
     define v_arq     char(280)

     define l_count, 
            l_erro, 
            l_ano,
            l_mes,
            l_dia int
     define l_comando char (100)
     define l_linhas integer
     define l_data datetime  year to day
     define l_hora datetime hour to hour
     define l_minuto datetime minute to minute
     define l_nomearq char(30) 
     define l_dataarq, 
            l_datmin,
            l_datatu date
     define l_strdata char(10)
     
     define r_dacmrmv record 
          funmat                   like dacmrmv.funmat,
          empcod                   like dacmrmv.empcod,
          usrtip                   like dacmrmv.usrtip,
          cptmes                   like dacmrmv.cptmes,
          cptano                   like dacmrmv.cptano,
          cnddes                   like dacmrmv.cnddes,
          grndes                   like dacmrmv.grndes,
          sprdes                   like dacmrmv.sprdes,
          atuaredes                like dacmrmv.atuaredes,
          avlqstprides             like dacmrmv.avlqstprides,
          avlqstpriatgper          like dacmrmv.avlqstpriatgper,
          avlqstprignhvlr          like dacmrmv.avlqstprignhvlr,
          avlqstsegdes             like dacmrmv.avlqstsegdes,
          avlqstsegatgper          like dacmrmv.avlqstsegatgper,
          avlqstgnhvlr             like dacmrmv.avlqstgnhvlr,
          avlqstterdes             like dacmrmv.avlqstterdes,
          avlqstteratgper          like dacmrmv.avlqstteratgper,
          avlqsttergnhvlr          like dacmrmv.avlqsttergnhvlr,
          avlqstquades             like dacmrmv.avlqstquades,
          avlqstquaatgper          like dacmrmv.avlqstquaatgper,
          avlqstquagnhvlr          like dacmrmv.avlqstquagnhvlr,
          avlqstgnhmaxvlr          like dacmrmv.avlqstgnhmaxvlr,
          gnhtotvlr                like dacmrmv.gnhtotvlr,
          gnhanovlr                like dacmrmv.gnhanovlr
     end record

     let m_mensagem = "Criando tabela temporaria.." 
     call ERRORLOG(m_mensagem);

     create temp table rv_temp(
          funmat	      decimal(6,0),
          empcod	      decimal(2,0),
          usrtip	      char(1),
          cptmes	      char(2),
          cptano	      char(4),
          cnddes	      varchar(30),
          grndes	      varchar(30),
          sprdes	      varchar(30),
          atuaredes	      varchar(30),
          avlqstprides        varchar(30),
          avlqstpriatgper     decimal(5,2),
          avlqstprignhvlr     decimal(15,5),
          avlqstsegdes	      varchar(30),
          avlqstsegatgper     decimal(5,2),
          avlqstgnhvlr	      decimal(15,5),
          avlqstterdes	      varchar(30),
          avlqstteratgper     decimal(5,2),
          avlqsttergnhvlr     decimal(15,5),
          avlqstquades	      varchar(30),
          avlqstquaatgper     decimal(5,2),
          avlqstquagnhvlr     decimal(15,5),
          avlqstgnhmaxvlr     decimal(15,5),
          gnhtotvlr	      decimal(15,5),
          gnhanovlr	      decimal(15,5), ghost char(01)
      ) with no log
     
     let v_arq = "/adat/ARQUIVORV.TXT" 

     call ERRORLOG("Leitura arquivo TXT ...");
     
     whenever error continue
     
     load from v_arq insert into rv_temp

     whenever error stop
     
     if sqlca.sqlcode <> 0 then
        let m_mensagem = '(ERRO ' , sqlca.sqlcode ,') - ERRO NA ABERTURA DO ARQUIVO DE IMPORTACAO! '
        call ERRORLOG(m_mensagem);
        exit program(1)
     end if

     
     select count(*) into l_linhas
       from rv_temp

     let m_mensagem = l_linhas using "&&&&&", " linhas lidas."
     call ERRORLOG(m_mensagem);


     declare cbdata103001 cursor with hold for 
      select * 
        from rv_temp
        
     open cbdata103001
     
     while (true)
          
          fetch cbdata103001 into r_dacmrmv.*

          if sqlca.sqlcode <> 0 then
               exit while
          end if

          let l_count = 0
          
          whenever error continue
          
          select count(*) into l_count
            from dacmrmv 
           where cptano = r_dacmrmv.cptano 
             and cptmes = r_dacmrmv.cptmes 
             and funmat = r_dacmrmv.funmat 
             and empcod = r_dacmrmv.empcod

          if sqlca.sqlcode <> 0 then
               let m_mensagem = '(ERRO ' , sqlca.sqlcode,') - ERRO NA IMPORTA��O DAS INFORMA��ES (1)'
               call ERRORLOG(m_mensagem);
               exit program(1)
          end if
          whenever error stop   

          if l_count > 0 then

               whenever error continue
          
               begin work
               
               update dacmrmv set (cnddes,
                                   grndes,
                                   sprdes,
                                   atuaredes,
                                   avlqstprides,
                                   avlqstpriatgper,
                                   avlqstprignhvlr,
                                   avlqstsegdes,
                                   avlqstsegatgper,
                                   avlqstgnhvlr,
                                   avlqstterdes,
                                   avlqstteratgper,
                                   avlqsttergnhvlr,
                                   avlqstquades,
                                   avlqstquaatgper,
                                   avlqstquagnhvlr,
                                   avlqstgnhmaxvlr,
                                   gnhtotvlr,
                                   gnhanovlr)
                                = (r_dacmrmv.cnddes,
                                   r_dacmrmv.grndes,
                                   r_dacmrmv.sprdes,
                                   r_dacmrmv.atuaredes,
                                   r_dacmrmv.avlqstprides,
                                   r_dacmrmv.avlqstpriatgper,
                                   r_dacmrmv.avlqstprignhvlr,
                                   r_dacmrmv.avlqstsegdes,
                                   r_dacmrmv.avlqstsegatgper,
                                   r_dacmrmv.avlqstgnhvlr,
                                   r_dacmrmv.avlqstterdes,
                                   r_dacmrmv.avlqstteratgper,
                                   r_dacmrmv.avlqsttergnhvlr,
                                   r_dacmrmv.avlqstquades,
                                   r_dacmrmv.avlqstquaatgper,
                                   r_dacmrmv.avlqstquagnhvlr,
                                   r_dacmrmv.avlqstgnhmaxvlr,
                                   r_dacmrmv.gnhtotvlr,
                                   r_dacmrmv.gnhanovlr)
                             where funmat = r_dacmrmv.funmat
                               and empcod = r_dacmrmv.empcod
                               and usrtip = r_dacmrmv.usrtip
                               and cptmes = r_dacmrmv.cptmes
                               and cptano = r_dacmrmv.cptano
          
               whenever error stop

               if sqlca.sqlcode = 0 then
                  commit work
               else
                  let m_mensagem = '(ERRO ' , sqlca.sqlcode,') - ERRO NA IMPORTA��O DE INFORMA��ES (2)'
                  call ERRORLOG(m_mensagem);
                  rollback work
                  exit program(2)
               end if
               
          else
               whenever error continue

               begin work

               insert into dacmrmv (funmat,
                                    empcod,
                                    usrtip,
                                    cptmes,
                                    cptano,
                                    cnddes,
                                    grndes,
                                    sprdes,
                                    atuaredes,
                                    avlqstprides,
                                    avlqstpriatgper,
                                    avlqstprignhvlr,
                                    avlqstsegdes,
                                    avlqstsegatgper,
                                    avlqstgnhvlr,
                                    avlqstterdes,
                                    avlqstteratgper,
                                    avlqsttergnhvlr,
                                    avlqstquades,
                                    avlqstquaatgper,
                                    avlqstquagnhvlr,
                                    avlqstgnhmaxvlr,
                                    gnhtotvlr,
                                    gnhanovlr)
                            values (r_dacmrmv.funmat,
                                    r_dacmrmv.empcod,
                                    r_dacmrmv.usrtip,
                                    r_dacmrmv.cptmes,
                                    r_dacmrmv.cptano,
                                    r_dacmrmv.cnddes,
                                    r_dacmrmv.grndes,
                                    r_dacmrmv.sprdes,
                                    r_dacmrmv.atuaredes,
                                    r_dacmrmv.avlqstprides,
                                    r_dacmrmv.avlqstpriatgper,
                                    r_dacmrmv.avlqstprignhvlr,
                                    r_dacmrmv.avlqstsegdes,
                                    r_dacmrmv.avlqstsegatgper,
                                    r_dacmrmv.avlqstgnhvlr,
                                    r_dacmrmv.avlqstterdes,
                                    r_dacmrmv.avlqstteratgper,
                                    r_dacmrmv.avlqsttergnhvlr,
                                    r_dacmrmv.avlqstquades,
                                    r_dacmrmv.avlqstquaatgper,
                                    r_dacmrmv.avlqstquagnhvlr,
                                    r_dacmrmv.avlqstgnhmaxvlr,
                                    r_dacmrmv.gnhtotvlr,
                                    r_dacmrmv.gnhanovlr)
                                    
               whenever error stop

               if sqlca.sqlcode = 0 then
                  commit work
               else
                  let m_mensagem = '(ERRO ' , sqlca.sqlcode,') - ERRO NA IMPORTA��O DE INFORMA��ES (3)'
                  call ERRORLOG(m_mensagem);
                  rollback work
                  exit program(3)
               end if
          display "<332> sqlca.sqlcode  >> ", sqlca.sqlcode           
          end if
          
     end while
     
     # Se chegou aqui, importa��o foi OK
     # ent�o o arquivo � renomeado      
     
     let l_erro = 0
     let l_data = today
     let l_hora = today
     let l_minuto = today

     # monta o nome do arquivo com data e hora
     let l_nomearq = 'ARQUIVORV_',
                     day(l_data) using '&&',
                     month(l_data) using '&&',
                     year(l_data) using '&&&&',
                     '_',
                     l_hora ,
                     l_minuto,
                     '.TXT'
     
     let l_nomearq = l_nomearq clipped          

     let l_comando = 'mv ARQUIVORV.TXT ',l_nomearq 

     run l_comando 
       returning l_erro

     if l_erro <> 0 then
        let m_mensagem = 'ATENCAO!!!! ERRO AO RENOMEAR ARQUIVO'
        call ERRORLOG(m_mensagem);
     else
        let m_mensagem = 'ARQUIVO ', l_nomearq, ' RENOMEADO.'
        call ERRORLOG(m_mensagem);
     end if  
     
     # removendo arquivos anteriores a 1 m�s de importa��o

     let m_mensagem = 'INICIANDO VERIFICA��O DE ARQUIVOS ANTERIORES..'
     call ERRORLOG(m_mensagem);

     let l_datatu = today
     let l_datmin = today
     let l_datmin = date(l_datatu - 1 units month)
     
     create temp table arquivos(
                                nome char(30)
                               ) with no log
     
     let l_comando = "ls ARQUIVORV_*.TXT > arquivos.txt"

     run l_comando 
         returning l_erro

     if l_erro = 0 then   
     
          whenever error continue
          
          load from 'arquivos.txt' insert into arquivos
           
          whenever error stop
     
          declare cbdata103002 cursor with hold for 
           select * 
             from arquivos
     
          open cbdata103002
          
          while (true)
               fetch cbdata103002 into l_nomearq
               
               if sqlca.sqlcode <> 0 then
                    exit while
               end if

               let l_nomearq = l_nomearq clipped
               
               let l_dia = l_nomearq[11,12]
               let l_mes = l_nomearq[13,14]
               let l_ano = l_nomearq[15,18]
               
               let l_strdata = null
               let l_dataarq = null
               
               let l_strdata = l_dia using "&&",'/',
                               l_mes using "&&",'/',
                               l_ano using "&&&&"
                               
               let l_dataarq = date(l_strdata)
               
               if l_dataarq < l_datmin then
                    let l_comando = 'rm ',l_nomearq
                    run l_comando 
                         returning l_erro
                         
                    if l_erro <> 0 then
                       let m_mensagem = 'O ARQUIVO ',l_nomearq, ' NAO FOI REMOVIDO!'
                       call ERRORLOG(m_mensagem);
                    else
                       let m_mensagem = 'ARQUIVO ',l_nomearq, ' REMOVIDO!'
                       call ERRORLOG(m_mensagem);
                    end if   
                         
               end if               
          end while          
     end if     
end function 
