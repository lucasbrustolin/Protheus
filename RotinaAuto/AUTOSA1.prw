#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "PROTHEUS.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} U_AUTOSA1(  aClientes )

EXEMPLO DE ROTINA AUTOMATICA NO PADRAO MVC

@param		aClientes			-> Dados do Cliente

@sample     : Aadd(aDados,{ "010203079",;
                            "01",;
                            "LUCAS CARDOSO BRUSTOLIN",;
                            "BRUSTOLIN",;
                            "RUA DOS ANDRADAS",;
                            "CENTRO",;
                            "F",;
                            "SP",;
                            "50308",;
                            "SAO PAULO ",;
                            "03500111",;
                            "I",;
                            "3384604000X",;
                            "105",;
                            "lucasbrustolin@hotmail.com",;
                            "011",; //ddd
                            "46780000",;
                            "F",;
                            "100230",;
                            "01058"})
                            
                    
            U_AUTOSA1(aDados)

@author 	Lucas.brustolin 
@since		15/04/2020
@version 	P12
/*/
//-------------------------------------------------------------------
User Function AUTOSA1( aClientes )

Local oModel 		:= FwLoadModel("MATA030")
Local oMdlSA1		:= Nil
Local nI 			:= 0
Local lRet			:= .T.

Default aClientes	 = {}


If Len(aClientes) > 0 .And. oModel <> Nil


	For nI := 1 To Len(aClientes)


		oModel:SetOperation( MODEL_OPERATION_INSERT )
		oModel:Activate()
		oMdlSA1	:= oModel:GetModel("MATA030_SA1")
			
		oMdlSA1:setValue("A1_COD",       aClientes[nI][1]   ) // Codigo 
		oMdlSA1:setValue("A1_LOJA",      aClientes[nI][2]   ) // Loja
		oMdlSA1:setValue("A1_NOME",      aClientes[nI][3]   ) // Nome             
		oMdlSA1:setValue("A1_NREDUZ",    aClientes[nI][4]   ) // Nome reduz. 
		oMdlSA1:setValue("A1_END",       aClientes[nI][5]   ) // Endereco
		oMdlSA1:setValue("A1_BAIRRO",    aClientes[nI][6]   ) // Bairro
		oMdlSA1:setValue("A1_TIPO",      aClientes[nI][7]   ) // Tipo 
		oMdlSA1:setValue("A1_EST",       aClientes[nI][8]   ) // Estado
		oMdlSA1:setValue("A1_COD_MUN",   aClientes[nI][9]   ) // Codigo Municipio                
		oMdlSA1:setValue("A1_MUN",       aClientes[nI][10]  ) // Municipio
		oMdlSA1:setValue("A1_CEP",       aClientes[nI][11]  ) // CEP
		oMdlSA1:setValue("A1_INSCR",     aClientes[nI][12]  ) // Inscricao Estadual
		oMdlSA1:setValue("A1_CGC",       aClientes[nI][13]  ) // CNPJ/CPF            
		oMdlSA1:setValue("A1_PAIS",      aClientes[nI][14]  ) // Pais            
		oMdlSA1:setValue("A1_EMAIL",     aClientes[nI][15]  ) // E-Mail
		oMdlSA1:setValue("A1_DDD",       aClientes[nI][16]	) // DDD            
		oMdlSA1:setValue("A1_TEL",       aClientes[nI][17]  ) // Fone                 
		oMdlSA1:setValue("A1_PESSOA",    aClientes[nI][18]  ) // Tipo Pessoa
		oMdlSA1:setValue("A1_VEND",   	 aClientes[nI][19]  ) // Vendedor
		oMdlSA1:setValue("A1_CODPAIS", 	 aClientes[nI][20]  ) // CodPais
		
		

		If ( lRet := oModel:VldData() )
			//³Efetiva gravacao dos dados na tabela ³
			lRet := oModel:CommitData()
		Else
			JurShowErro( oModel:GetErrormessage() )
			lRet := .F.
		EndIf
			
		oModel:DeActivate()	
	Next

EndIf

Return(lRet)

