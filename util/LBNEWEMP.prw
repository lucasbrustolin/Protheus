#Include 'Protheus.ch'
#Include 'ParmType.ch'
#Include 'Fileio.ch'

#Include 'TOPCONN.CH'
#Include "TBICONN.CH"
#Include "TBICODE.CH"

User Function LBNEWEMP; Return  // "dummy" function - Internal Use

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LbNewEmp 
@class			: LbNewEmp 
@Sample			: LbNewEmp():New()
@description	: Classe responsavel por fazer a troca de empresa em tempo de execução.
				  A troca so e permitida caso o usuario possua acesso.
@Param			: Nulo
@return			: Object 
@obs 			: Permite ser inserido em bloco de transação podendo realizar o Disarmtransaction()
				  de registros de N empresas.
@project		: Generico
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 03/04/2020
@version		: Protheus 12.1.17
/*/
//------------------------------------------------------------------------------------------
CLASS LbNewEmp 

	Data oAppBk			As Object 
	Data CodEmpBkp 		As String 
	Data CodFilBkp 		As String 
	Data CodEmp			As String 
	Data CodFil 		As String 
	Data Error 			As String 
	Data EmpAccess		As Array 	
	Data AreaSM0 		As Array
						
	METHOD New() CONSTRUCTOR	// Metodo construtor - criação do objeto
	METHOD SetEmp()				// Metodo para setar a troca de empresa 
	METHOD Restore()			// Metodo para restaurar a troca de empresa 

ENDCLASS


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New 
@class			: LbNewEmp 
@Sample			: LbNewEmp():New()
@description	: Classe responsavel para criação do objeto 
@Param			: Nulo
@return			: Object 
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 03/04/2020
@version		: Protheus 12.1.17
/*/
//------------------------------------------------------------------------------------------
Method New() Class LbNewEmp

Self:oAppBk			:= Iif ( Type( 'oApp' ) == 'O', oApp, Nil )
Self:CodEmpBkp 		:= cEmpAnt 
Self:CodFilBkp 		:= cFilAnt
Self:CodEmp 		:= cEmpAnt 
Self:CodFil 		:= cFilAnt
Self:EmpAccess 		:= FWEmpLoad(.F.)

DbSelectArea("SM0") 
Self:AreaSM0 := SM0->(GetArea())

Return( Self )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetEmp 
@class			: LbNewEmp 
@Sample			: LbNewEmp():SetEmp(CodEmp, CodFil)
@description	: Metodo responsavel por fazer a troca de empresa em tempo de execução.
				  A troca so e permitida caso o usuario possua acesso.
@Param			: CodEmp - Empresa
@Param 			: CodFil - Filial
@return			: lAccess .T. Se houve a troca de empresa caso contrario .F.
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 03/04/2020
@version		: Protheus 12.1.17
/*/
//------------------------------------------------------------------------------------------
Method SetEmp( CodEmp, CodFil ) Class LbNewEmp

	Local lAccess 	:= .F.
		
	PARAMTYPE 0 VAR CodEmp AS CHARACTER
	PARAMTYPE 1 VAR CodFil AS CHARACTER


	lAccess :=  CodEmp <> cEmpAnt .And. CodFil <> cFilAnt


	If ( lAccess )

		// Lista Empresas que usuario tem Acesso
		// ::EmpAccess- array
		// 1 - Codigo da empresa
		// 2 - Nome da empresa
		// 3 - Codigo da filial
		// 4 - Nome da filials

		lAccess := aScan( ::EmpAccess, {|x|  x[1] == CodEmp .And. x[3] == CodFil } )  > 0

		If ( lAccess )

			// ------------------------------------+
			// TROCA EMPRESA EM TEMPO DE EXECUCAO  |
			// ------------------------------------+
			lAccess := ChangeEmp( CodEmp, CodFil )

			::Error :=  Iif ( lAccess,"", "Falha interna ao abrir Empresa\Filial: " + CRLF + CRLF + ;
						"Empresa: " + CodEmp + CRLF + ;
						"Filial: " + CodFil )
		Else 
			::Error := "Usuario sem permissao de acesso a Empresa\Filial: " + CRLF + CRLF + ;
						"Empresa: " + CodEmp + CRLF + ;
						"Filial: " + CodFil 
		EndIf 
	Else 
		::Error := "Empresa e filial informada ja se encontra ativa"
	EndIf 


Return( lAccess )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Restore 
@type			: Metodo 
@Sample			: LbNewEmp():Restore()
@description	: Metodo responsavel por restaurar a troca de empresa em tempo de execução.
				  Considera empresa\filial antes da criação do objeto  
@Param			: CodEmp - Empresa
@Param 			: CodFil - Filial
@return			: lAccess .T. Se houve a troca de empresa caso contrario .F. 
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 03/04/2020
@version		: Protheus 12.1.17
/*/
//------------------------------------------------------------------------------------------
Method Restore() Class LbNewEmp

Local lChange  := .F. 

// ------------------------------------+
// TROCA EMPRESA EM TEMPO DE EXECUCAO  |
// ------------------------------------+
lChange := ChangeEmp( ::CodEmpBkp, ::CodFilBkp )

If ( lChange )
	oApp	:= Iif ( ValType( Self:oAppBk ) == 'O', Self:oAppBk, Nil )
	::Error :=  ""
Else 
	::Error :=  "Falha interna ao restaurar empresa em tempo de execucao" 
EndIf 


RestArea( ::AreaSM0 )

Return( lChange )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChangeEmp 
@type			: Metodo 
@Sample			: ChangeEmp( cCodEmp, cCodFil )
@description	: Funcao  responsavel efetivar a troca da empresa em tempo de execucao  
@Param			: CodEmp 	- Codigo da Empresa que sera aberta 
@Param 			: CodFil 	- Codigo da Filial que sera aberta
@return			: lChange 	-  Retorna .T. Se houve a troca de empresa caso contrario .F. 
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 03/04/2020
@version		: Protheus 12.1.17
/*/
//------------------------------------------------------------------------------------------
Static Function ChangeEmp( cCodEmp, cCodFil )

Local lChange := .F. 
	
DbCloseAll() 		//-- Fecha todas as tabela que estao abertas 

OpenSM0() 			//-- Abre Arquivo de empresa (Empresa/Filial)

DbSelectArea("SM0") 	//-- Posiciona tabela de empresa = SM0
SM0->( DbSetOrder(1))	//-- Seta ordem 

If SM0->( DbSeek(  cCodEmp + cCodFil)) //-- Posiciona Empresa e filial 

	//-- Atualiza as variais de sistema 
	cEmpAnt := SM0->M0_CODIGO 
	cFilAnt := AllTrim(SM0->M0_CODFIL)

	OpenFile(cEmpAnt + cFilAnt) //-- Efetiva abertura  da empresa a processar 

	 lRefresh := .T. 			//-- Variavel Private para Atualizar as Tabelas

	lChange :=	cCodEmp == AllTrim( cEmpAnt ) .And. ;
				cCodFil == AllTrim( cFilAnt )

	
EndIf  

Return( lChange )


#Include 'Protheus.ch'


// -----------------------------------------------------------
// EXEMPLO DE UTILIZACAO DA CLASSE  QUE FAZ A TROCA DE EMPRESA [ LbNewEmp ]
// 
// LbNewEmp():New()                         -- Instacia objeto 
// LbNewEmp():SetEmp( Empresa, Filial )     -- Faz a troca de empresa
// LbNewEmp():Restore( )                    -- Retorna para empresa de origem (Antes do SetEmp)
// ----------------------------------------------------------

User Function Teste001()

Local oEmpresa := Nil 


Begin Transaction

    oEmpresa := LbNewEmp():New()

    // ---------------------------------------------+
    // ACESSA EMPRESA 01 E ALTERA O CAD DE CLIENTES |
    // ---------------------------------------------+
	If oEmpresa:SetEmp( "01", "06" )

		If ( cEmpAnt == "01"  .And. cFilAnt = "06" )
			
			cNome :=   POSICIONE("SA1",1,xFilial("SA1")+ "002084068" ,"A1_NOME") 
		
			If !Empty( cNome )
				
				RecLock("SA1", .F. )
				SA1->A1_NOME := AllTrim(cNome) + " x"
				SA1->( MsUnLock() )

			EndIf 


		EndIf
	Else 
		FwAlertInfp( oEmpresa:Error,"Atencao" )
	EndIf 

    // ---------------------------------------------+
    // ACESSA EMPRESA 02 E ALTERA O CAD DE CLIENTES |
    // ---------------------------------------------+

	If oEmpresa:SetEmp( "02", "01" )

		If ( cEmpAnt == "02"  .And. cFilAnt = "01" )
			
			cNome :=   POSICIONE("SA1",1,xFilial("SA1")+ "001074099" ,"A1_NOME") 

			If !Empty( cNome )
				
				RecLock("SA1", .F. )
				SA1->A1_NOME := AllTrim(cNome) + " x"
				SA1->( MsUnLock() )

				// TESTE COM TRANSACTION
				// --------------------------------------------------------------------+
				// DESFAZ ALTERACOES DE AMBOS CADASTROS CLIENTES REF. EMPREESA 01 E 02 |
				// --------------------------------------------------------------------+

				//Forca o Disarm 
				DisarmTransaction()

			EndIf 

		EndIf
	Else 
		FwAlertInfp( oEmpresa:Error,"Atencao" )
	EndIf 

    // ----------------------------------------------------------------------------+
    // RESTAURA \ RETORNA PARA EMPRESA DE ORIGEM - PARA CONTINUAR O PROCESSAMENTO  |
    // ----------------------------------------------------------------------------+
	oEmpresa:Restore()

End Transaction

Return()