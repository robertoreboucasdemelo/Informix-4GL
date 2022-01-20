/*
 * Porto Seguro CIA de Seguros
 * Projeto POMAR - Programa de Otimizacao e Modernizacao do Atendimento e Relacionamento 
 * http://www.portoseguro.com.br/
 *
 * © 2013 - Porto Seguro CIA de Seguros. Todos os direitos reservados
 *
 * Date: 2013-05-28 19:00:00
 * Version: 2
 * Description: Componente JS para integracao entre Sistemas Web e a tela de Cliente do sistema SIEBEL CRM.
 * Escopo: 	Documentos do Automovel => Apolice,Proposta,Vistoria Previa e Cobertura Provisoria.
 *			Documentos do RE		=> Apolice,Proposta. As consultas do Inquilino estão no escopo.
 * Fora do Escopo: Sinistro de Auto e RE
 */

 /*
 * param typeProduct 		string com tipo do produto do documento: AUTO ou RE 
 * param objClientInfo		objeto com os dados do cliente
 * param objDocInfo			objeto com os dados do documento
 * param objItemDocInfo		objeto com os dados do item do documento
 * param objSinistroInfo	objeto com os dados do sinistro
 * exception
 */
function sendDocumentCliente (typeProduct, objClientInfo, objDocInfo, objItemDocInfo, objSinistroInfo) {
	/*
	 * Buscando o contexto do Siebel (High), de forma a atender a sequência de Popups/iFrames existentes atualmente
	 *
	 * Fluxo atual
	 *   Siebel -> showModalPopup(popupA) -> window.open(popupB) -> iFrame(psqclicrm.do) -> outros 2 iFrames (internos ao BuscaCliente)
	 *
	 * Fluxo desejado:
	 *   - Siebel passa "siebelContext" por parâmetro no comando showModalPopup;
	 *   - popupA implementa getDialogArguments(), para receber "siebelContext", e abre popupB com o comando window.open();
	 *   - popupB implementa getDialogArguments(), para buscar "siebelContext" do popupA (via window.opener),
	 *     e carrega a aplicacao BuscaCliente no iFrame;
	 *   - O fluxo do BuscaCliente carrega os demais iFrames encadeados;
	 *   - O javascript do último iFrame (buscacli.js) busca "siebelContext" do popupB (acessado via "top");
	 *
	 * Obs.: No Open UI, siebelContext deve entrar nulo.
	 */
	var siebelContext = null;
	try {
		siebelContext = top.getDialogArguments();
	} catch(e) {
		siebelContext = null;
	}

	if (siebelContext && siebelContext !== undefined && siebelContext.context && siebelContext.context !== undefined) {
		siebelContext = siebelContext.context;
	}

	// Instanciando object ActiveX (ou Wrapper do Open UI)
	var siebDeskIntApp = new SiebelWrapper(siebelContext);
	var openUI = siebDeskIntApp.isOpenUI();

	try {
		if (!siebDeskIntApp) {
			alert("Erro na abertura do ActiveXObject.");
		}
		else {
			var bs = siebDeskIntApp.GetService("PSBuscaCliente");
			var psin = siebDeskIntApp.NewPropertySet();
			var psout = siebDeskIntApp.NewPropertySet();

			// Verifica se o Produto foi informado
			if (typeProduct && (typeProduct != null) && (typeProduct.length != 0)) {

				/* Verificando Objeto com os dados do Sinistro */
				if (objSinistroInfo && (objSinistroInfo != null) && (objSinistroInfo != '')) {
					dadosSinistro(objSinistroInfo, psin);
				}				

				/* Verificando Objeto com os dados do Item do Documento */
				if (objItemDocInfo && (objItemDocInfo != null) && (objItemDocInfo != '')) {

					/* Verificando Objeto com os dados do Documento */
					if (objDocInfo && (objDocInfo != null) && (objDocInfo != '')) {
						dadosDocumento(typeProduct, objItemDocInfo, objDocInfo, psin);	
					}

					dadosItemDocumento(typeProduct, objItemDocInfo, objDocInfo, psin);					
				}						

				/* Verificando Objeto com os dados do Cliente */
				if (objClientInfo && (objClientInfo != null) && (objClientInfo != '')) {
					dadosCliente(objClientInfo, psin);		
				}
				
			}
			else {
				throw new Error("O campo [typeProduct] é obrigatório.");				
			}

			// Invocando serviço Siebel que atualiza campo em tela
			bs.InvokeMethod("BuscaCliente", psin, psout);

			if (psout.GetProperty("Return Code") != "") {
				alert("ERRO: "+psout.GetProperty("Return Message"));
			}
		}
	} catch(e) {
		alert(e.message);
	} finally {
		if (psin) {
			// writeObjectProperties(psin);
		}	
		psin = null;
		psout = null;
		siebDeskIntApp = null;

		if (!openUI) {
			try {
				if (window.parent.parent.parent != null) {
					window.parent.parent.parent.close();
				}
			} catch(e) {
				// do nothing...
			}
			window.close();
		}
	}
}

function dadosSinistro(objSinistroInfo, psin) {

	if(isNotEmptyField(objSinistroInfo.rowId)){
		//ROW_ID do Sinistro
		psin.SetProperty("SinistroId",objSinistroInfo.rowId);
	}else{
		//Nº Sinistro - OBRIGATORIO
		if(isNotEmptyField(objSinistroInfo.numeroSinistro)){						
			// Concatenando RAMO|ANO|NUMERO_SINISTRO|ITEM
			var numeroSinistro = objSinistroInfo.codigoRamoSinistro + "|" + 
								 objSinistroInfo.anoSinistro + "|" +
								 objSinistroInfo.numeroSinistro + "|" +
								 objSinistroInfo.numeroSequenciaItemSinistro
								 
			psin.SetProperty("SinistroNumero",numeroSinistro);
		}else{
			throw new Error("O campo [numeroSinistro] é obrigarório.");
		}
		//Data Sinistro
		if(isNotEmptyField(objSinistroInfo.dataOcorrenciaSinistro)){
			psin.SetProperty("SinistroData",objSinistroInfo.dataOcorrenciaSinistro);	
		}
		//Tipo Sinistro
		if(isNotEmptyField(objSinistroInfo.nomeTipoPerda)){
			psin.SetProperty("SinistroTipo",objSinistroInfo.nomeTipoPerda);						
		}		
		//Codigo Tipo Sinistro 
		//psin.SetProperty("SinistroCodigoTipo","");							
	}	
}

function dadosItemDocumento(typeProduct, objItemDocInfo, objDocInfo, psin){

	if(isNotEmptyField(objItemDocInfo.rowId)){
		//ROW_ID do Itemo do Documento
		psin.SetProperty("ItemId",objItemDocInfo.rowId);
	}else{		
		//Se o documento é do tipo Apólice, esse campo obrigatoriamente deve ser enviado ao Siebel.							
		if(objDocInfo.nomeTipoDocumento == 'APOLICE'){
			if(isNotEmptyField(objItemDocInfo.numeroDigitoItem)){
				psin.SetProperty("ItemNumero",objItemDocInfo.numeroDigitoItem);
			}else{
				throw new Error ("O campo [numeroDigitoItem] é obrigatório.");
			}							
		}else if(objDocInfo.nomeTipoDocumento == 'PROPOSTA'){
			/* ANTES de 29-10-2014
			Se o documento é do tipo Proposta, e a proposta selecionada possui item, o valor do item deve ser enviado, 
				caso contrário (se for uma Proposta nova, que ainda não possui item), o item deve ser enviado para o Siebel em branco							
			if(typeProduct == 'AUTO' || typeProduct == 'auto'){
				itemNumero = objItemDocInfo.codigoOrigemPropostaIndividual + objItemDocInfo.numeroDigitoPropostaIndividual;								
			}else if(typeProduct == 'RE' || typeProduct == 're'){
				itemNumero = objDocInfo.codigoOrigemProposta + objDocInfo.numeroDigitoProposta;
			}
			*/
			if(isNotEmptyField(objItemDocInfo.numeroDigitoItem)){								
				psin.SetProperty("ItemNumero",objItemDocInfo.numeroDigitoItem);
			}
		//Se o documento é do tipo Vistoria Prévia ou Cobertura Provisória, esse campo deve ser enviado com o valor “1”.														
		}else if((objDocInfo.nomeTipoDocumento == 'VISTORIA PREVIA') || (objDocInfo.nomeTipoDocumento == 'COBERTURA PROVISORIA')){
			psin.SetProperty("ItemNumero",1);
		}																	
		
		//Endosso do Item
		var itemEndossoNumero;
		if(objDocInfo.nomeTipoDocumento == 'APOLICE'){							
			itemEndossoNumero = objDocInfo.numeroDigitoEndosso;
		}else{
			itemEndossoNumero = 0;
		}							
		psin.SetProperty("ItemEndossoNumero",itemEndossoNumero);
			
		//Data Inicio Vigencia
		if(isNotEmptyField(objDocInfo.dataInicioVigencia)){
			psin.SetProperty("ItemDataInicio",objItemDocInfo.dataInicioVigencia);
		}
		//Data Final Vigencia
		if(isNotEmptyField(objDocInfo.dataFinalVigencia)){
			psin.SetProperty("ItemDataFim",objItemDocInfo.dataFinalVigencia);
		}
				
		if(typeProduct == 'AUTO' || typeProduct == 'auto'){ // Automovel
			//Placa
			if(isNotEmptyField(objItemDocInfo.numeroLicencaVeiculo)){
				psin.SetProperty("ItemPlaca",objItemDocInfo.numeroLicencaVeiculo);
			}
			//Chassi
			if(isNotEmptyField(objItemDocInfo.numeroChassi)){
				psin.SetProperty("ItemChassi",objItemDocInfo.numeroChassi);
			}
			//Ano Fabricacao
			if(isNotEmptyField(objItemDocInfo.anoFabricacaoVeiculo)){
				psin.SetProperty("ItemVeiculoAnoFabricacao",objItemDocInfo.anoFabricacaoVeiculo);
			}
			//Ano Modelo
			if(isNotEmptyField(objItemDocInfo.anoModeloVeiculo)){
				psin.SetProperty("ItemVeiculoAnoModelo",objItemDocInfo.anoModeloVeiculo);
			}
			//Tipo Veiculo
			if(isNotEmptyField(objItemDocInfo.nomeTipoVeiculo)){
				psin.SetProperty("ItemVeiculoTipo",objItemDocInfo.nomeTipoVeiculo);
			}							
			//Modelo Veiculo
			if(isNotEmptyField(objItemDocInfo.nomeModeloVeiculo)){
				psin.SetProperty("ItemVeiculoModelo",objItemDocInfo.nomeModeloVeiculo);
			}
			//Marca Veiculo
			if(isNotEmptyField(objItemDocInfo.nomeMarcaVeiculo)){
				psin.SetProperty("ItemVeiculoMarca",objItemDocInfo.nomeMarcaVeiculo);
			}
			//Cor Veiculo
			if(isNotEmptyField(objItemDocInfo.nomeCorVeiculo)){
				psin.SetProperty("ItemVeiculoCor",objItemDocInfo.nomeCorVeiculo);
			}

			/* Item da Proposta */
			if((objDocInfo.nomeTipoDocumento == 'APOLICE') || (objDocInfo.nomeTipoDocumento == 'PROPOSTA')){
				if (isNotEmptyField(objItemDocInfo.codigoOrigemPropostaIndividual) && isNotEmptyField(objItemDocInfo.numeroDigitoPropostaIndividual)){
					psin.SetProperty("ItemPropostaOrigem",ebfConcatLeft(objItemDocInfo.codigoOrigemPropostaIndividual,2,0));
					psin.SetProperty("ItemPropostaNumero",objItemDocInfo.numeroDigitoPropostaIndividual);	
				}else{
					throw new Error ("Os campos [codigoOrigemPropostaIndividual] e [codigoOrigemPropostaIndividual] do ITEM são obrigatórios.");
				}
			}														
		
		}else if(typeProduct == 'RE' || typeProduct == 're'){ // Ramos Elementares
			// Formatando CEP
			var localRiscoCEP = '';
			if (isNotEmptyField(objItemDocInfo.numeroInicioCep) && isNotEmptyField(objItemDocInfo.numeroComplementoCep)){
			localRiscoCEP = ebfConcatLeft(objItemDocInfo.numeroInicioCep,5,0) + '-' + ebfConcatLeft(objItemDocInfo.numeroComplementoCep,3,0);
				psin.SetProperty("ItemLocalRiscoCEP",localRiscoCEP);
			}	
			//Local Risco - Tipo Logradouro	
			if(isNotEmptyField(objItemDocInfo.nomeTipoLogradouro)){
				psin.SetProperty("ItemLocalRiscoTipoLogradouro",objItemDocInfo.nomeTipoLogradouro);
			}	
			//Local Risco - Nome Logradouro
			if(isNotEmptyField(objItemDocInfo.nomeLogradouro)){
				psin.SetProperty("ItemLocalRiscoLogradouro",objItemDocInfo.nomeLogradouro);
			}
			//Local Risco - Numero
			if(isNotEmptyField(objItemDocInfo.numeroLogradouro)){
				psin.SetProperty("ItemLocalRiscoNumero",objItemDocInfo.numeroLogradouro);
			}
			//Local Risco - Complemento
			if(isNotEmptyField(objItemDocInfo.complementoEndereco)){
				psin.SetProperty("ItemLocalRiscoComplemento",objItemDocInfo.complementoEndereco);
			}
			//Local Risco - Bairro
			if(isNotEmptyField(objItemDocInfo.nomeBairro)){
				psin.SetProperty("ItemLocalRiscoBairro",objItemDocInfo.nomeBairro);
			}
			//Local Risco - Cidade
			if(isNotEmptyField(objItemDocInfo.nomeCidade)){
				psin.SetProperty("ItemLocalRiscoCidade",objItemDocInfo.nomeCidade);	
			}
			//Local Risco - Estado
			if(isNotEmptyField(objItemDocInfo.codigoUnidadeFederacao)){
				psin.SetProperty("ItemLocalRiscoEstado",objItemDocInfo.codigoUnidadeFederacao);
			}
			//Local Risco - Pais
			if(isNotEmptyField(objItemDocInfo.nomePais)){
				psin.SetProperty("ItemLocalRiscoPais",getSiglaPais(objItemDocInfo.nomePais));
			}
			
			/* Item da Proposta */
			if((objDocInfo.nomeTipoDocumento == 'APOLICE') || (objDocInfo.nomeTipoDocumento == 'PROPOSTA')){
				if (isNotEmptyField(objDocInfo.codigoOrigemProposta) && isNotEmptyField(objDocInfo.numeroDigitoProposta)){
					psin.SetProperty("ItemPropostaOrigem",ebfConcatLeft(objDocInfo.codigoOrigemProposta,2,0));
					psin.SetProperty("ItemPropostaNumero",objDocInfo.numeroDigitoProposta);							
				}else{
					throw new Error ("Os campos [codigoOrigemProposta] e [numeroDigitoProposta] do ITEM são obrigatórios.");
				}								
			}
		}
	}
}

function dadosDocumento(typeProduct, objItemDocInfo, objDocInfo, psin){
	
	// Tipo do Produto - OBRIGATORIO
	if (isNotEmptyField(objDocInfo.codigoProduto)){
		//psin.SetProperty("DocumentoOrigem",getDocumentoOrigem(objDocInfo.codigoProduto));	
		/*
		 * param typeProduct - campo string com tipo do produto do documento: AUTO ou RE
		 * param codigoRamo	- campo numerico com o ramo do documento (utilizado somente para RE)
		 * param codigoModalidadeSeguro	- compo numerico com o codigo da modalidade (utilizado somente para RE)
		 * param codigoRamoAtividadeEconomica - campo numerico com o codigo da atividada economica (utilizado somente para RE)
		 */							
		psin.SetProperty("DocumentoOrigem",getDocumentoOrigemBCP(typeProduct,objDocInfo.codigoRamo,objItemDocInfo.codigoModalidadeSeguro,objItemDocInfo.codigoRamoAtividadeEconomica));
	}else{
		throw new Error ("O campo [codigoProduto] é obrigatório.");
	}
	// Codigo Empresa - OBRIGATORIO
	if (isNotEmptyField(objDocInfo.codigoEmpresa)){
		psin.SetProperty("DocumentoEmpresa",getDocumentoEmpresa(objDocInfo.codigoEmpresa));
	}else{
		throw new Error ("O campo [codigoEmpresa] é obrigatório.");
	}
	// Tipo do Documento - OBRIGATORIO
	if (isNotEmptyField(objDocInfo.nomeTipoDocumento)){
		psin.SetProperty("DocumentoTipo",objDocInfo.nomeTipoDocumento);
	}else{
		throw new Error ("O campo [nomeTipoDocumento] é obrigatório.");
	}
	// Nº Doc - OBRIGATORIO
	if (isNotEmptyField(objDocInfo.numeroDocumento)){
		psin.SetProperty("DocumentoNumero",objDocInfo.numeroDocumento);
	}else{
		throw new Error ("O campo [numeroDocumento] é obrigatório.");
	}
	// Nº Sucursal - OBRIGATORIO se o tipo de documento for APOLICE
	if(objDocInfo.nomeTipoDocumento == "APOLICE"){
		if (isNotEmptyField(objDocInfo.codigoSucursal)){
			psin.SetProperty("DocumentoSucursal",objDocInfo.codigoSucursal);
		}else{
			throw new Error ("O campo [codigoSucursal] é obrigatório.");
		}
	}
	// Ramo - OBRIGATORIO se o tipo de documento for APOLICE
	if(objDocInfo.nomeTipoDocumento == "APOLICE"){
		if (isNotEmptyField(objDocInfo.codigoRamo)){
			psin.SetProperty("DocumentoRamo",objDocInfo.codigoRamo);
		}else{
			throw new Error ("O campo [codigoRamo] é obrigatório.");
		}
	}
	// Nº APOLICE - OBRIGATORIO se o tipo de documento for APOLICE
	if(objDocInfo.nomeTipoDocumento == "APOLICE"){
		if (isNotEmptyField(objDocInfo.numeroDigitoApolice)){
			psin.SetProperty("DocumentoApolice",objDocInfo.numeroDigitoApolice);
		}else{
			throw new Error ("O campo [numeroDigitoApolice] é obrigatório.");
		}
	}
	//Data Inicio Vigencia
	if (isNotEmptyField(objDocInfo.dataInicioVigencia)){
		psin.SetProperty("DocumentoVigenciaInicial",objDocInfo.dataInicioVigencia);
	}
	//Data Final Vigencia
	if (isNotEmptyField(objDocInfo.dataFinalVigencia)){
		psin.SetProperty("DocumentoVigenciaFinal",objDocInfo.dataFinalVigencia);
	}
	//Status Documento
	if (isNotEmptyField(objDocInfo.nomeSituacaoDocumento)){
		psin.SetProperty("DocumentoStatus",objDocInfo.nomeSituacaoDocumento);
	}
	//Data Emissao
	if (isNotEmptyField(objDocInfo.dataEmissao)){
		psin.SetProperty("DocumentoDataEmissao",objDocInfo.dataEmissao);
	}
	//SUSEP
	if (isNotEmptyField(objDocInfo.codigoSusep)){
		psin.SetProperty("DocumentoSusep",objDocInfo.codigoSusep);
	}						
	
	/* Endosso do Documento */
	var documentoEndossoNumero;
	if(objDocInfo.nomeTipoDocumento == 'APOLICE'){
		documentoEndossoNumero = objDocInfo.numeroDigitoEndosso;
	}else{
		documentoEndossoNumero = 0;
	}
	psin.SetProperty("DocumentoEndossoNumero",documentoEndossoNumero);
	
	/* Proposta do Documento */
	if(typeProduct == 'AUTO' || typeProduct == 'auto'){ // AUTO
		if((objDocInfo.nomeTipoDocumento == 'APOLICE') || (objDocInfo.nomeTipoDocumento == 'PROPOSTA')){
			if (isNotEmptyField(objDocInfo.codigoOrigemPropostaPrincipal) && isNotEmptyField(objDocInfo.numeroDigitoPropostaPrincipal)){
				// Proposta do Doc. para AUTOMOVEL
				psin.SetProperty("DocumentoPropostaOrigem",objDocInfo.codigoOrigemPropostaPrincipal);
				psin.SetProperty("DocumentoPropostaNumero",objDocInfo.numeroDigitoPropostaPrincipal);
			}else{
				throw new Error ("Os campos [codigoOrigemPropostaPrincipal] e [numeroDigitoPropostaPrincipal] do DOCUMENTO são obrigatórios.");
			}
		}							
	}else if(typeProduct == 'RE' || typeProduct == 're'){ // RE
		if((objDocInfo.nomeTipoDocumento == 'APOLICE') || (objDocInfo.nomeTipoDocumento == 'PROPOSTA')){
			if(isNotEmptyField(objDocInfo.codigoOrigemProposta) && isNotEmptyField(objDocInfo.numeroDigitoProposta)){
				// Proposta do Doc. para RE
				psin.SetProperty("DocumentoPropostaOrigem",objDocInfo.codigoOrigemProposta);
				psin.SetProperty("DocumentoPropostaNumero",objDocInfo.numeroDigitoProposta);
			}else{
				throw new Error ("Os campos [codigoOrigemProposta] e [numeroDigitoProposta] do DOCUMENTO são obrigatórios.");
			}
		}
	}

}

function dadosCliente(objClientInfo, psin){

	// Nome do Cliente - OBRIGATORIO
	if (isNotEmptyField(objClientInfo.nomePessoa)){
		psin.SetProperty("ClienteNome",objClientInfo.nomePessoa);
	}else{
		throw new Error ("O campo [ClienteNome] é obrigatório.");
	}
	
	// Tipo de Pessoa - OBRIGATORIO
	if (isNotEmptyField(objClientInfo.codigoTipoPessoa)){
		psin.SetProperty("ClienteTipoPessoa",getTipoPessoa(objClientInfo.codigoTipoPessoa));
	}else{
		throw new Error ("O campo [TipoPessoa] é obrigatório.");
	}
	
	// Formatando CPF ou CNPJ
	var numeroCpfouCnpj = '';
	var numeroOrdemCnpj = '';
	var digitoCpfouCnpj = '';
	var clienteCPFCNPJ = '';
	if (isNotEmptyField(objClientInfo.numeroCpfouCnpj)){
		
		if (isNotEmptyField(objClientInfo.digitoCpfouCnpj)){
			digitoCpfouCnpj = ebfConcatLeft(objClientInfo.digitoCpfouCnpj,2,0);							
		}				
		if(objClientInfo.codigoTipoPessoa == 'F'){
			numeroCpfouCnpj = ebfConcatLeft(objClientInfo.numeroCpfouCnpj,9,0);
			clienteCPFCNPJ = numeroCpfouCnpj + digitoCpfouCnpj;	
		}else if(objClientInfo.codigoTipoPessoa == 'J'){
			numeroCpfouCnpj = ebfConcatLeft(objClientInfo.numeroCpfouCnpj,8,0);
			if(isNotEmptyField(objClientInfo.numeroOrdemCnpj)){
				numeroOrdemCnpj = ebfConcatLeft(objClientInfo.numeroOrdemCnpj,4,0);
			}								
			clienteCPFCNPJ = numeroCpfouCnpj + numeroOrdemCnpj + digitoCpfouCnpj;							
		}
		//CPF ou CNPJ
		psin.SetProperty("ClienteCPFCNPJ",clienteCPFCNPJ);
	}
	//Estado Civil						
	if (isNotEmptyField(objClientInfo.codigoEstadoCivil)){
		psin.SetProperty("ClienteEstadoCivil",getEstadoCivil(objClientInfo.codigoEstadoCivil));
	}
	//Sexo						
	if (isNotEmptyField(objClientInfo.codigoSexo)){
		psin.SetProperty("ClienteSexo",objClientInfo.codigoSexo);
	}
	//Data Nascimento	
	if (isNotEmptyField(objClientInfo.dataNascimento)){
		psin.SetProperty("ClienteDataNascimento",objClientInfo.dataNascimento);
	}
	//E-mail
	if (isNotEmptyField(objClientInfo.enderecoEletronico)){
		psin.SetProperty("ClienteEmail",objClientInfo.enderecoEletronico);
	}
	
	// Formatando Telefone
	var telefoneCliente = '';
	if (isNotEmptyField(objClientInfo.codigoDdd) && isNotEmptyField(objClientInfo.numeroTelefone)){
		telefoneCliente = objClientInfo.codigoDdd + objClientInfo.numeroTelefone;
		psin.SetProperty("ClienteTelefone",telefoneCliente);
	}
							
	/* Atribuindo valores para o Endereço */
	//Tipo Logradouro
	if (isNotEmptyField(objClientInfo.nomeTipoLogradouro)){
		psin.SetProperty("ClienteEnderecoTipoLogradouro",objClientInfo.nomeTipoLogradouro);	
	}
	//Nome Logradouro
	if (isNotEmptyField(objClientInfo.nomeLogradouro)){
		psin.SetProperty("ClienteEnderecoLogradouro",objClientInfo.nomeLogradouro);
	}
	//Numero Logradouro
	if (isNotEmptyField(objClientInfo.numeroLogradouro)){
		psin.SetProperty("ClienteEnderecoNumero",objClientInfo.numeroLogradouro);
	}
	//Complemento
	if (isNotEmptyField(objClientInfo.complementoEndereco)){
		psin.SetProperty("ClienteEnderecoComplemento",objClientInfo.complementoEndereco);
	}
	//Bairro
	if (isNotEmptyField(objClientInfo.nomeBairro)){
		psin.SetProperty("ClienteEnderecoBairro",objClientInfo.nomeBairro);
	}
	//Cidade
	if (isNotEmptyField(objClientInfo.nomeCidade)){
		psin.SetProperty("ClienteEnderecoCidade",objClientInfo.nomeCidade);
	}
	//Estado
	if (isNotEmptyField(objClientInfo.codigoUnidadeFederacao)){
		psin.SetProperty("ClienteEnderecoEstado",objClientInfo.codigoUnidadeFederacao);
	}
	//Pais
	if (isNotEmptyField(objClientInfo.nomePais)){
		psin.SetProperty("ClienteEnderecoPais",getSiglaPais(objClientInfo.nomePais));			
	}
	
	/* Formatando CEP */
	var numeroCEP = '';
	if (isNotEmptyField(objClientInfo.numeroInicioCep) && isNotEmptyField(objClientInfo.numeroComplementoCep)){							
		numeroCEP = ebfConcatLeft(objClientInfo.numeroInicioCep,5,0) + '-' + ebfConcatLeft(objClientInfo.numeroComplementoCep,3,0);
		psin.SetProperty("ClienteEnderecoCEP",numeroCEP);
	}	
}


function writeObjectProperties(psin){
	document.write("<b>CLIENTE</b><BR />");	
	document.write("ClienteNome: " + psin.GetProperty("ClienteNome")+"<BR />");
	document.write("ClienteCPFCNPJ: " + psin.GetProperty("ClienteCPFCNPJ")+"<BR />");
	document.write("ClienteDataNascimento: " + psin.GetProperty("ClienteDataNascimento")+"<BR />");
	document.write("ClienteEstadoCivil: " + psin.GetProperty("ClienteEstadoCivil")+"<BR />");
	document.write("ClienteSexo: " + psin.GetProperty("ClienteSexo")+"<BR />");
	document.write("ClienteTipoPessoa: " + psin.GetProperty("ClienteTipoPessoa")+"<BR />");
	document.write("ClienteEmail: " + psin.GetProperty("ClienteEmail")+"<BR />");
	document.write("ClienteTelefone: " + psin.GetProperty("ClienteTelefone")+"<BR />");
	document.write("ClienteEnderecoTipoLogradouro: " + psin.GetProperty("ClienteEnderecoTipoLogradouro")+"<BR />");
	document.write("ClienteEnderecoLogradouro: " + psin.GetProperty("ClienteEnderecoLogradouro")+"<BR />");
	document.write("ClienteEnderecoNumero: " + psin.GetProperty("ClienteEnderecoNumero")+"<BR />");
	document.write("ClienteEnderecoComplemento: " + psin.GetProperty("ClienteEnderecoComplemento")+"<BR />");
	document.write("ClienteEnderecoBairro: " + psin.GetProperty("ClienteEnderecoBairro")+"<BR />");
	document.write("ClienteEnderecoCidade: " + psin.GetProperty("ClienteEnderecoCidade")+"<BR />");
	document.write("ClienteEnderecoEstado: " + psin.GetProperty("ClienteEnderecoEstado")+"<BR />");
	document.write("ClienteEnderecoPais: " + psin.GetProperty("ClienteEnderecoPais")+"<BR />");
	document.write("ClienteEnderecoCEP: " + psin.GetProperty("ClienteEnderecoCEP")+"<BR />");
	
	document.write("<b>DOCUMENTO</b><br />");	
	document.write("DocumentoOrigem:" + psin.GetProperty("DocumentoOrigem")+"<BR />");
	document.write("DocumentoEmpresa:" + psin.GetProperty("DocumentoEmpresa")+"<BR />");
	document.write("DocumentoTipo:" + psin.GetProperty("DocumentoTipo")+"<BR />");
	document.write("DocumentoNumero:" + psin.GetProperty("DocumentoNumero")+"<BR />");
	document.write("DocumentoSucursal:" + psin.GetProperty("DocumentoSucursal")+"<BR />");
	document.write("DocumentoRamo:" + psin.GetProperty("DocumentoRamo")+"<BR />");
	document.write("DocumentoApolice:" + psin.GetProperty("DocumentoApolice")+"<BR />");
	document.write("DocumentoVigenciaInicial:" + psin.GetProperty("DocumentoVigenciaInicial")+"<BR />");
	document.write("DocumentoVigenciaFinal:" + psin.GetProperty("DocumentoVigenciaFinal")+"<BR />");
	document.write("DocumentoStatus:" + psin.GetProperty("DocumentoStatus")+"<BR />");
	document.write("DocumentoDataEmissao:" + psin.GetProperty("DocumentoDataEmissao")+"<BR />");
	document.write("DocumentoSusep:" + psin.GetProperty("DocumentoSusep")+"<BR />");
	document.write("DocumentoEndossoNumero:" + psin.GetProperty("DocumentoEndossoNumero")+"<BR />");
	document.write("DocumentoPropostaOrigem:" + psin.GetProperty("DocumentoPropostaOrigem")+"<BR />");
	document.write("DocumentoPropostaNumero:" + psin.GetProperty("DocumentoPropostaNumero")+"<BR />");

	document.write("<b>DOCUMENTO ITEM</b><br />");
	document.write("ItemNumero:" + psin.GetProperty("ItemNumero")+"<BR />");
	document.write("ItemEndossoNumero:" + psin.GetProperty("ItemEndossoNumero")+"<BR />");
	document.write("ItemDataInicio:" + psin.GetProperty("ItemDataInicio")+"<BR />");
	document.write("ItemDataFim:" + psin.GetProperty("ItemDataFim")+"<BR />");
	document.write("ItemPlaca:" + psin.GetProperty("ItemPlaca")+"<BR />");
	document.write("ItemVeiculoAnoFabricacao:" + psin.GetProperty("ItemVeiculoAnoFabricacao")+"<BR />");
	document.write("ItemVeiculoAnoModelo:" + psin.GetProperty("ItemVeiculoAnoModelo")+"<BR />");
	document.write("ItemVeiculoTipo:" + psin.GetProperty("ItemVeiculoTipo")+"<BR />");
	document.write("ItemVeiculoCor:" + psin.GetProperty("ItemVeiculoCor")+"<BR />");
	document.write("ItemVeiculoModelo:" + psin.GetProperty("ItemVeiculoModelo")+"<BR />");
	document.write("ItemVeiculoMarca:" + psin.GetProperty("ItemVeiculoMarca")+"<BR />");
	document.write("ItemChassi:" + psin.GetProperty("ItemChassi")+"<BR />");
	document.write("ItemPropostaOrigem:" + psin.GetProperty("ItemPropostaOrigem")+"<BR />");
	document.write("ItemPropostaNumero:" + psin.GetProperty("ItemPropostaNumero")+"<BR />");

}

function isNotEmptyField(value){
	if((value != null) && (value.length != 0)){
		return true;
	}else{
		return false;
	}	
}

function getTipoPessoa(chave){
	var arr = new Array();
	var count = 0;
	arr[count++] = new Array('F','FISICA'); 
	arr[count++] = new Array('J','JURIDICA'); 
	
	var tipoPessoa = '';	
	for (x in arr){
		if(arr[x][0] == chave){
			tipoPessoa = arr[x][1];
		}
	}
	return tipoPessoa;
}

function getEstadoCivil(codigo){
	try{
		var descricao = "";
		var arrCodigoEstadoCivil = new Array("0","1","2","3","4","5","6","7","8","9");
		var arrDescEstadoCivil = new Array( "NÃO INFORMADO"
											,"SOLTEIRO"
											,"CASADO"
											,"AMASIADO"
											,"DESQUITADO"
											,"DIVORCIADO"
											,"SEPARADO"
											,"VIUVO"
											,"IGNORADO"
											,"FALECIDO");
		descricao = arrDescEstadoCivil[objClientInfo.codigoEstadoCivil] + '(A)';
		return descricao;
	}catch(e){
		//throw e;
	}
}

function getDocumentoOrigemBCP(tipoProduto,codigoRamo,codigoModalidade,codigoAtividade){
	var codigoProdutoBCP = 0;
	if(tipoProduto == "AUTO"){
		codigoProdutoBCP = 27;
	}else if(tipoProduto == "RE"){
		
		//SEGURO SAUDE + CASA
		if(codigoRamo == 85){
			codigoProdutoBCP = 17;
		}
		//SEGURO RESIDENCIAL
		else if(codigoRamo == 114){
			if((codigoModalidade == 1) || (codigoModalidade == 2) || (codigoModalidade == 6)){
				codigoProdutoBCP = 13;
			}else if(codigoModalidade == 3){
				codigoProdutoBCP = 11;
			}else{
				codigoProdutoBCP = 12;
			}				
		}
		//SEGURO CONDOMINIO
		else if(codigoRamo == 116){
			codigoProdutoBCP = 4; 			
		}
		//SEGURO EMPRESARIAL
		else if(codigoRamo == 118){
			if((codigoModalidade == 113) && (codigoAtividade == 282)){
				codigoProdutoBCP = 2;
			}else if(codigoModalidade == 108){
				codigoProdutoBCP = 3;
			}else if((codigoModalidade == 0) && (codigoAtividade == 150)){
				codigoProdutoBCP = 5;
			}else if((codigoModalidade == 1) || (codigoModalidade == 2) || (codigoModalidade == 3) || (codigoModalidade == 112) || (codigoModalidade == 114)){
				codigoProdutoBCP = 6;
			}else{
				if((codigoAtividade == 155) || (codigoAtividade == 910) || (codigoAtividade == 998)){
					codigoProdutoBCP = 5;
				}else if(codigoAtividade == 5058){
					codigoProdutoBCP = 3;
				}else{
					codigoProdutoBCP = 6;
				}
			}		
		}
		//RISCOS DIVERSOS
		else if(codigoRamo == 171){
			if(codigoModalidade == 415){
				codigoProdutoBCP = 8;
			}else if(codigoModalidade == 429){
				codigoProdutoBCP = 7;
			}else if((codigoModalidade == 416) || (codigoModalidade = 417) || (codigoModalidade = 419) || (codigoModalidade = 421) || (codigoModalidade = 423) || (codigoModalidade = 424)){
				codigoProdutoBCP = 12;
			}else{
				codigoProdutoBCP = 16;
			}
		}
		//GARANTIA ESTENDIDA
		else if(codigoRamo == 195){
			if ((codigoModalidade >= 1) && (codigoModalidade <= 3)){
				codigoProdutoBCP = 12; 
			}else{
				codigoProdutoBCP = 9;
			}		
		}
		//ALUGUEL - FIANCA LOCATICIA
		else if(codigoRamo == 746){
			codigoProdutoBCP = 43; 					
		}		
	}
	return codigoProdutoBCP;
}
function getDocumentoOrigem2(chave){
	var arr = new Array();
	var count = 0;
	arr[count++] = new Array(1,27); // AUTO (legado, bcp)
	arr[count++] = new Array(9,5); // RE (legado, bcp)
	
	var codigoProduto = '';	
	for (x in arr){
		if(arr[x][0] == chave){
			codigoProduto = arr[x][1];
		}
	}
	return codigoProduto;
}

function getDocumentoEmpresa(chave){
	var arr = new Array();
	var count = 0;
	arr[count++] = new Array(1,'PORTO SEGURO CIA'); 
	arr[count++] = new Array(35,'AZUL SEGUROS CIA SEGS GERAIS'); 
	arr[count++] = new Array(84,'ITAU UNIBANCO SEGUROS AUTO E R'); 
		
	var nomeEmpresa = '';	
	for (x in arr){
		if(arr[x][0] == chave){
			nomeEmpresa = arr[x][1];
		}
	}
	return nomeEmpresa;
}

function getSiglaPais(nomePais){	
	var arr = new Array();
	var cont = 0;;
	arr[cont++] = new Array('BRASIL','BR');
	arr[cont++] = new Array('ARGENTINA','AR');
	arr[cont++] = new Array('URUGUAI','UY');
	arr[cont++] = new Array('PARAGUAI','PY');
	arr[cont++] = new Array('VENEZUELA','VE');
	
	var siglaPais = '';	
	for (x in arr){
		if(arr[x][0] == nomePais){
			siglaPais = arr[x][1];
		}
	}
	return siglaPais;
}			
			
function ebfConcatLeft(param, size, character){
	var contador = param.length;
	if(param.length != size){
		while(contador < size){
			param = character + param;	
			contador++;
		}
	}
	return param;
} 

/*
 * Javascript Siebel child iframe app communication library
 * 
 * @version: 0.1 - 2014.11.07
 * @author: Rafael Tiago Vieira (Infinity Systems & Solutions)
 *
 * @version: 0.2 - 2015.04.27
 * @author: Rafael Tiago Vieira (Infinity Systems & Solutions)
 *
 */

/* SiebelWrapper definition */
function SiebelWrapper(siebelContext) {

	/* Start - PropertySetWrapper definition */
	function PropertySetWrapper() {
		this.map = {};
	}

	PropertySetWrapper.prototype.GetProperty = function (key) {
		return this.map[key];
	};

	PropertySetWrapper.prototype.SetProperty = function (key, value) {
		this.map[key] = value;
	};

	PropertySetWrapper.prototype.GetMap = function () {
		return this.map;
	};

	PropertySetWrapper.prototype.ForAll = function (funct) {
		var key;
		for (key in this.map) {
			if (this.map.hasOwnProperty(key)) {
				funct(key, this.map[key]);
			}
		}
	};
	/* End - PropertySetWrapper definition */

	/* Start - BusinessServiceWrapper definition */
	function BusinessServiceWrapper(serviceName) {
		this.serviceName = serviceName;
	}

	BusinessServiceWrapper.prototype.Name = function () {
		return this.serviceName;
	}

	BusinessServiceWrapper.prototype.InvokeMethod = function (funct, inPS, outPS) {
		if (!outPS) {
			outPS = new PropertySetWrapper();
		}
		outPS.SetProperty("Return Code", "-1");

		if (!funct) {
			outPS.SetProperty("Return Message", "Business Service Method not specified.");
			return outPS;
		}

		if (inPS && !(inPS instanceof PropertySetWrapper)) {
			outPS.SetProperty("Return Message", "Unknown format received as input.");
			return outPS;
		}

		try {
			var siebelMessage = {
				method: "invokeBS",
				serviceName: this.serviceName,
				serviceMethod: funct,
				serviceInput: inPS.GetMap()
			};

			var siebelWindow;
			for (siebelWindow = window.parent; siebelWindow != siebelWindow.parent; siebelWindow = siebelWindow.parent);
			siebelWindow.postMessage(siebelMessage, "*");
		} catch (e) {
			outPS.SetProperty("Return Code", "-1");
			outPS.SetProperty("Return Message", "Error invoking Siebel Business Service");
			return outPS;
		}

		outPS.SetProperty("Return Code", "");
		outPS.SetProperty("Return Message", "OK");
		return outPS;
	};
	/* End - BusinessServiceWrapper definition */

	/* Start - Siebel context initialization */
	/*
	 * Instanciando object ActiveX (ou Wrapper do Open UI), nas condicoes a seguir:
	 *  - Se receber "theApplication()" como parametro de abertura de popup, o utiliza, independente de UI;
	 *  - Se conseguir instanciar via ActiveX, entao e High Interactivy;
	 *  - Caso contrario, considera que e Open UI, e utiliza o Wrapper, enviando chamada ao BS via postMessage();
	 */
	this.siebelApp = null;
	this.openUI = false;

	if (siebelContext) {
		this.siebelApp = siebelContext;
	}

	if (!this.siebelApp) {
		var mainWindow;
		for (mainWindow = window; mainWindow !== mainWindow.parent; mainWindow = mainWindow.parent) {
			if (mainWindow.dialogArguments && mainWindow.dialogArguments.context) {
				this.siebelApp = mainWindow.dialogArguments.context;
				break;
			}
		}
	}

	if (!this.siebelApp) {
		try {
			this.siebelApp = new ActiveXObject("Siebel.Desktop_Integration_Application.1");
		} catch (e) {
			this.openUI = true;
		}
	}
	/* End - Siebel context initialization */

	/* Start - SiebelWrapper definition */
	SiebelWrapper.prototype.NewPropertySet = function () {
		if (this.siebelApp && !this.openUI) {
			return this.siebelApp.NewPropertySet();
		}
		return new PropertySetWrapper();
	};

	SiebelWrapper.prototype.GetService = function (serviceName) {
		if (this.siebelApp && !this.openUI) {
			return this.siebelApp.GetService(serviceName);
		}
		return new BusinessServiceWrapper(serviceName);
	};

	SiebelWrapper.prototype.isOpenUI = function () {
		return this.openUI;
	}
	/* End - SiebelWrapper definition */
};
SiebelActiveXObjectWrapper = SiebelWrapper;