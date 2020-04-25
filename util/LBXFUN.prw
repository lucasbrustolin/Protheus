#Include 'Protheus.ch'

//------------------------------------------------------------------------------------------
// {Protheus.doc} LBXFUN.PRW 
// Class \ FUNCTION \ 
// ************* FONTE COM ROTINAS DE USO GERAL  ************** 
//-------------------------------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} U_LBContar(  cAlias,  cCondicao , cFieldUniqueo )

Rotina com o mesmo objetivo da rotina padrao Contar() [Varre alias para retornar a qtdade de registros]
porém com a possibilidade de avaliar um determinado campo para que nao ocorra duplicidade na contagem.

@sample01		nTotReg := U_LBContar(  cAliasQry )
@sample02		nTotReg := U_LBContar(  cAliasQry, "!EOF()")
@sample03		nTotReg := U_LBContar(  cAliasQry, "!EOF()", "C5_NUM" )

@param		cALias			-> Tabela para leitura
@param		cCond			-> Condição para leitura da tabela
@param		cFieldUnique	-> Campo para ignorar dado em duplicidade
#param 		nTotReg 		-> Retorna total de registros com base na condicao informada
@author 	Lucas.brustolin 
@since		15/04/2020
@version 	P12
/*/
//-------------------------------------------------------------------
User Function LBContar(cALias,cCond,cFieldUnique)

Local cAliasAtu := Alias()
Local aAux 		:= {}
Local xValue	:= Nil
Local lNoExist	:= .T.
Local nRet 		:= 0

Default cCond		 := ".T."
Default cFieldUnique := ""

DbSelectArea(cAlias)
DbGoTop()

While !EOF()
	//----
    If &(cCond)
		//----
		If !Empty(cFieldUnique) .And. (cALias)->( FieldPos( cFieldUnique ) ) > 0
			xValue 	:=  (cALias)->&( cFieldUnique )
			lNoExist	:= AScan(aAux, xValue ) == 0

			If ( lNoExist )
				aAdd(aAux, xValue )
				nRet ++
			EndIf 

		Else  
			nRet ++
		EndIf
    Endif
    DbSkip()
EndDo


DbSelectArea(cAliasAtu)

Return( nRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} CharAZ09
formata string - permitindo apenas os caracteres de A-Z, 0-9, espaço, 
ponto e virgula. 
@author 	Lucas.brustolin 
@since		11/02/2019
@version 	P12
/*/
//-------------------------------------------------------------------
User Function CharAZ09(cString,cException)

Local cNewStr	:= ""
Local nI 		:= 1

Default cString 	:= ""
Default cException	:= ""


If !Empty(cString) 
	
	cString := UPPER(AllTrim(FwNoAccent(cString)))
		
	For nI := 1 To Len(cString)
		If SubStr(cString,nI,1) $ "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ ,." + UPPER(AllTrim(cException))
			cNewStr += SubStr(cString,nI,1)  
		EndIf
	Next	
EndIf

Return(cNewStr)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFldX7
@Sample U_SetFldX7( cParam, xParam )
@Description 	: Rotina de uso em gatiho (SX7) Responsavel por preencher determinado campo
de modo a atender a particulariedade de cada processo.
@param	cCampo	: Campo  dominio
@Param	xValue 	: Valor do campo dominio 
@author 	Lucas.brustolin 
@since		18/03/2020
@version 	P12
/*/
//-------------------------------------------------------------------
User Function SetFldX7( cCampo, xValue )

Local cException := "" 

Default cCampo	:= ReadVar()
Default xValue 	:= &( cCampo )


	// ---------------------------------------------------------+
	// Tratamento de caracteres no preenchimento do(s) campos(s)|
	// ---------------------------------------------------------+ 	
	If FwIsInCallStack("MATA010") //-- Cadastro de Produtos


		Do Case 

			// -------------------------------------------+
			// Este campo em especial só está permitindo  |
			// atribuição via FwFldPut                    |
			// -------------------------------------------+

			Case cCampo $ "M->B1_DESC"

				cException := "!@$%()[]{}--+/\"

				xValue := U_CharAZ09( xValue, cException )

				FWFldPut("B1_DESC",xValue,/*nLinha*/,/*oModel*/,.T.,.F.)


			OtherWise

				xValue :=  &( cCampo )

		EndCase 

	EndIf 


Return( xValue )
