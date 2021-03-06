#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema.......:                                                              #
# Modulo........: sg_glob5                                                     #
# Analista Resp.:                                                              #
# PSI...........:                                                              #
# Objetivo......:                                                              #
#..............................................................................#
# Desenvolvimento: Caroline, BizTalking 22/12/2011                             #
# Liberacao......:                                                             #
#..............................................................................#
#                                                                              #
#                   * * * Alteracoes * * *                                     #
#                                                                              #
# Data       Autor Fabrica     Origem     Alteracao                            #
# ---------- ----------------- ---------- -------------------------------------#
#------------------------------------------------------------------------------#
database porto

globals

 define gr_pessoa                 record
        id                        decimal(10,0)
       ,nome                      char(70)
       ,fonetica                  char(20)
       ,primnome                  char(20)
       ,cpfcnpjnum                decimal(12,0)
       ,cnpjordem                 decimal(4,0)
       ,cpfcnpjdig                decimal(2,0)
       ,rne                       char(20)
       ,tiprel                    decimal(3,0)
       ,dtinirelac                date
       ,titulardoc                decimal(1,0)
       ,graurelac                 decimal(2,0)
       ,mae                       char(70)
       ,pai                       char(70)
       ,papel                     decimal(2,0)
       ,origem                    decimal(2,0)
       ,docorigem                 decimal(2,0)
       ,tippess                   char(1)
       ,presttip                  decimal(2,0)
       ,empretip                  decimal(2,0)
       ,sexo                      char(1)
       ,dtabertura                date
       ,dtinicio                  date
       ,dtfinal                   date
       ,nascimento                date
       ,estcivil                  decimal(2,0)
       ,estrcargo                 decimal(3,0)
       ,cargo                     char(24)
       ,cbo                       decimal(6,0)
       ,cnae                      char(7)
       ,situacao                  char(1)
       ,codemp                    decimal(4,0)
       ,fxrendacod                decimal(1,0)
       ,pessmatr                  char(09)
       ,codprestorigem            decimal(8,0)
       ,susepprinc                char(6)
       ,deficflag                 char(1)
       ,defictip                  decimal(1,0)
       ,flagpep                   char(1)
       ,cargopep                  decimal(6,0)
       ,cpfnumpep                 decimal(12,0)
       ,cpfordpep                 decimal(4,0)
       ,cpfdigpep                 decimal(2,0)
       ,relactippep               decimal(3,0)
       ,faturampj                 decimal(2,0)
       ,patrlqpj                  decimal(2,0)
       ,flgestrang                char(1)
       ,tipclassif                decimal(1,0)
       ,dtclassif                 date
       ,dtinclusao                date
       ,dtalteracao               date
       ,grphhold                  decimal(10,0)
       ,dtgrphhold                date
       ,flgportal                 char(1)
       ,dtflgportal               date
       ,vincprestcnpj             decimal(12,0)
       ,vincprestordem            decimal(4,0)
       ,vincprestdig              decimal(2,0)
       ,bucflag                   char(1)
       ,tpcomunic                 decimal(2,0)
       ,twitter                   char(50)
 end record

 define gr_pes_emails array[5] of record
        emailtip                  smallint
       ,email                     char(50)
       ,emailflgopt               char(1)
       ,emaildtflgopt             date
 end record

 define gr_pes_logradouros array[5] of record
        logradtip                 char(10)
       ,lograd                    char(60)
       ,logradnum                 char(15)
       ,logradcompl               char(30)
       ,bairro                    char(25)
       ,cidade                    char(35)
       ,uf                        char(2)
       ,cep                       decimal(5,0)
       ,cepcompl                  decimal(3,0)
       ,siglpais                  char(3)
       ,finalidlogr               decimal(2,0)
       ,latitude                  decimal(6,0)
       ,longitude                 decimal(6,0)
       ,enderflgopt               char(1)
       ,enderdtflgopt             date
 end record

 define gr_pes_contatos array[5] of record
        fonetip                   smallint
       ,foneddi                   decimal(5,0)
       ,foneddd                   decimal(5,0)
       ,fonenum                   decimal(8,0)
       ,foneflgopt                char(1)
       ,fonedtflgopt              date
       ,tpcomunic                 decimal(2,0)
       ,twitter                   char(50)
 end record

 define gr_documentos array[5] of record
        empcod                    decimal(4,0)
       ,status                    smallint
       ,dtatustt                  date
       ,cnpjnumcolet              decimal(12,0)
       ,cnpjordcolet              decimal(4,0)
       ,cnpjdigcolet              decimal(2,0)
       ,papel                     decimal(2,0)
       ,cpfnumvinc                decimal(12,0)
       ,cpfdigvinc                decimal(2,0)
       ,susep                     char(6)
       ,copartsusep               char(6)
       ,inivig                    date
       ,fnlvig                    date
       ,dtemiss                   date
       ,origemprp                 decimal(2,0)
       ,numprp                    decimal(8,0)
       ,segcod                    decimal(16,0)
       ,canalvend                 decimal(2,0)
       ,bucflag                   char(1)
       ,foneflgopt                char(1)
       ,fonedtflgopt              date
       ,emailflgopt               char(1)
       ,emaildtflgopt             date
 end record

 define gr_doc_prod array[50] of record
             doccod                    smallint
            ,prodcod                   decimal(4,0)
            ,chave                     char(50)
            ,contratoorigem            char(50)
 end record


 define gr_item array[100] of record
        doccod                    smallint
       ,numero                    decimal(12,0)
       ,status                    smallint
       ,altertip                  decimal(2,0)
       ,edstip                    decimal(3,0)
       ,alternum                  decimal(9,0)
       ,dtatustt                  date
       ,tipvlrrecebto             decimal(1,0)
       ,vlrrecebto                decimal(18,2)
       ,inivig                    date
       ,fnlvig                    date
       ,dtemiss                   date
       ,formapagto                decimal(2,0)
       ,vlrcontratado             decimal(18,2)
       ,vlrttcontratado           decimal(18,2)
       ,origemprp                 decimal(2,0)
       ,numprp                    decimal(8,0)
       ,ordemrs                   decimal(2,0)
       ,numrs                     decimal(9,0)
       ,sinistrtip                decimal(2,0)
       ,sinistrnum                decimal(16,0)
       ,dtavisosinistro           date
       ,placa                     char(7)
       ,chassi                    char(20)
       ,anofabr                   decimal(4,0)
       ,anomodel                  decimal(4,0)
       ,marca                     char(15)
       ,tipo                      char(30)
       ,modelo                    char(30)
       ,contrchave                char(30)
       ,tipocontrchave            decimal(2,0)
       ,logradtip                 char(10)
       ,lograd                    char(60)
       ,logradnum                 char(15)
       ,logradcomplnum            char(30)
       ,logradbrr                 char(25)
       ,logradcid                 char(35)
       ,lograduf                  char(2)
       ,logradcep                 decimal(5,0)
       ,logradcmpcep              decimal(3,0)
       ,siglpais                  char(3)
       ,finalidlogr               decimal(2,0)
       ,latitude                  decimal(9,6)
       ,longitude                 decimal(9,6)
       ,enderflgopt               char(1)
       ,enderdtflgopt             date
 end record

 define gr_logradouros array[50] of record
        doccod                    smallint
       ,logradtip                 char(10)
       ,lograd                    char(60)
       ,logradnum                 char(15)
       ,logradcomplnum            char(30)
       ,logradbrr                 char(25)
       ,logradcid                 char(35)
       ,lograduf                  char(2)
       ,logradcep                 decimal(5,0)
       ,logradcmpcep              decimal(3,0)
       ,siglpais                  char(3)
       ,finalidlogr               decimal(2,0)
       ,latitude                  decimal(9,6)
       ,longitude                 decimal(9,6)
       ,enderflgopt               char(1)
       ,enderdtflgopt             date
 end record

 define gr_doc_contatos array[50] of record
        doccod                    smallint
       ,fonetip                   char(1)
       ,foneddi                   decimal(5,0)
       ,foneddd                   decimal(5,0)
       ,fonenum                   decimal(8,0)
 end record

 define gr_doc_emails array[50] of record
        doccod                    smallint
       ,emailtip                  smallint
       ,email                     char(50)
 end record

 define gr_grupo_origem record
        mvtorgcod                 decimal(2,0)
       ,xmlgrp                    char(1)
 end record

 define ga_dados_saps array[50] of record
        prdnom         char(16)    # Descri��o do produto
      , docnum         char(15)    # Numero do documento
      , lgdtxt         char(65)    # Tipo + Logradouro + numero
      , lgdtip         char(10)    # tipo Logradouro
      , lgdnom         char(60)    # Logradouro
      , lgdnum         char(10)    # Numero do endereco
      , endcmp         char(25)    # Complemento do endereco
      , lclrefptotxt   char(250)   # Ponto de referencia
      , brrnom         char(40)    # Bairro
      , cidnom         char(45)    # Municipio
      , ufdcod         char(02)    # UF
      , lgdcep         char(05)    # CEP do local
      , lgdcepcmp      char(03)    # Complemento do CEP do local
      , lclcttnom      char(20)    # Nome do segurado no local
      , dddcod         char(04)    # DDD do telefone fixo
      , lcltelnum      dec(10,0)   # Numero do telefone fixo
      , celteldddcod   char(04)    # DDD do telefone celular
      , celtelnum      dec(10,0)   # Numero do telefone celular
      , segnom         char(40)    # Nome do segurado
      , corsus         char(06)    # Susep
      , cornom         char(40)    # Nome do corretor
      , vclcoddig      dec(5,0)    # Codigo do veiculo
      , vcldes         char(40)    # Descricao do veiculo
      , vclanomdl      datetime hour to minute    # Ano do veiculo
      , vcllicnum      char(07)    # Placa do veiculo
      , vclcordes      char(30)    # Cor do veiculo
 end record

 define ga_dct        smallint

 define g_servicoanterior char(20)
 define g_isbigchar smallint
 define g_ismqconn        smallint
end globals

