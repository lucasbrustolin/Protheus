#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"

#DEFINE TECLA_ESC	27
#DEFINE TEXTOHTML	'<p><span style="color: #003366;"><strong>Atencao</strong></span>:</p>' + ;
					'<p><b>A execucao de rotinas em MVC exige a delaracao:<br />Private aRotina := FwLoadMenuDef("NomeFonte")</p>' + ;
					'<p><strong>Executar</strong>:</p>'
					
//-------------------------------------------------------------------
/*/{Protheus.doc} LbRotina                                                    
Rotina para execução de rotinas Customizadas - Substitui Formulas e lançamento padrao

@obs:   Para abrir esta rotina sem a necessidade de inclui-la no menu, sugiro 
        definir uma tecla de atalho especificamente no ( P.E AfterLogin ) para chama-la. 

@author	Lucas.Brustolin
@since 	13/11/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
User Function LbRotina()

Local oExec		:= Nil
Local oDlg		:= Nil
Local bError	:= Nil   
Local cExec		:= ""          	
Local oFont 	:= Nil
Local xResult	:= Nil
Local lRet		:= .T.
Local lHtml 	:= .T.
Local oLayer 	:= Nil 
Local lContinua	:= .T.

Private  lUserFunc	:= .T.

While ( lContinua ) 

	cExec	:= SPACE(100)  
	oFont	:= TFont():New("Courier New",6,0)
	oLayer 	:= FWLayer():new()
	bError	:= ErrorBlock( {|e| Help(" ",1,"ERR_FORM",,e:Description,3,1) } )  
	
	DEFINE MSDIALOG oDlg FROM 0,0 TO 190,460 PIXEL Style DS_MODALFRAME TITLE "Executa Rotina Especifica" COLOR CLR_MAGENTA  FONT oFont  

		
		SetKey(TECLA_ESC, {|| MsgYesNo("Deseja realmente sair?", oDlg:lEscClose := .T.,oDlg:lEscClose := .F.)  } )

		// ----------------------------------+
		// EXEMPLO DE LAYER COM BOX (WINDOW) |
		//-----------------------------------+
		oLayer:init(oDlg)
		oLayer:AddLine('LINE1',100)
		oLayer:AddCollumn('01',100,.T.,'LINE1')
		oLayer:AddWindow('01','SUPERIOR','Informe a rotina: ',100,.F.,.F.,,'LINE1',)
		oPanel 	:= oLayer:GetWinPanel( '01','SUPERIOR', 'LINE1' )   	


		//-- TITULO DA JANELA HTML 
		oSay := TSay():New(05,10,{||TEXTOHTML},oPanel,,/*oFont*/,,,,.T.,,,150,30,,,,,,lHtml)

		//-- CheckBox
		oCheck1 := TCheckBox():New(05,165,'User Function (?)',{|u|if(PCount()>0,lUserFunc:= u,lUserFunc)},oPanel,100,210,,,,,,,,.T.,,,)

		//-- Campo
		@ 040,010 MSGET oExec VAR cExec PICTURE "@!" SIZE 150,13 PIXEL OF oPanel
		oExec:SetFocus()

		//-- Botao
		DEFINE SBUTTON FROM 032,165 TYPE 1 OF oPanel ENABLE ONSTOP "OK" 	ACTION (lContinua	:= .T., oDlg:End() )
		DEFINE SBUTTON FROM 045,165 TYPE 2 OF oPanel ENABLE ONSTOP "Sair" 	ACTION (lContinua 	:= .F., oDlg:End())
		

	ACTIVATE MSDIALOG oDlg CENTER

	If lContinua 

		Begin Sequence

		cExec := AllTrim(cExec)

		//  ------------------------------------+
		//  INSERE O PREFIXO USER FUNCTION 'U_' |
		// -------------------------------------+
		If lUserFunc 
			If SubStr(cExec,1,2) == "U_" 
				If MsgYesNo("Deseja aplicar o prefixo 'U_' ?")
					cExec := "U_" + cExec
				EndIf
			Else
				cExec := "U_" + cExec
			EndIf
		EndIf

		//  ------------------------------------+
		//  INSERE O PREFIXO NA FUNCAO '()'     |
		// -------------------------------------+
		If !( "(" $ cExec )
			cExec += "()"
		EndIf

		xResult := &( cExec  )

		RECOVER
			lRet 		:= .F.
			lContinua 	:= .F.
			cExec 		:= Space(100)
			Return() 	
		
		End Sequence

		ErrorBlock(bError)

	EndIf 

If !( lContinua )
	Return()
EndIf 

EndDo

Return(lRet)


