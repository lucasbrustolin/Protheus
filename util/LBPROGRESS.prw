#Include "Protheus.ch"
#Include "PARMTYPE.CH"

User Function LbProgress; Return  // "dummy" function - Internal Use

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LbProgress 
@type			: Clssse 
@Sample			: LbProgress:():New()
@description	: Classe responsavel por criar uma janela de processamento - load. 
@Param			: Nil 
@return			: Nil
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 26/02/2020
@version		: P12
/*/
//------------------------------------------------------------------------------------------
Class LbProgress

    Data oOWner         As Object 
    Data oComponent     As Object 
    Data oSayRun        As Object 
    Data bAction        As BLOCK
    Data cTitle         As String 
    Data cMessage       As String 
    Data nStart         As Numeric 
    Data nFinal         As Numeric 
    Data nStep          As Numeric 

    Data cBackColor     As String
    Data cForeColor     As String
  
    Data oFontDef       As Object    
    Data oFontHtml      As Object   
    Data lBlurWindow    As Boolean 
    Data IsContainered  As Boolean 
    Data lFlagProgress  As Boolean 


    Method New( oOWner, bAction, cTitle, cMessage  ) Constructor    
    Method SetColor()           //-- Permite alterar as cores da barra de progresso [back \ front] 
    Method CreateLoader()       //-- Cria barra de carregamento Formato HTML
    Method SetBlurWindow()      //-- Permite escurecer (blur) a janela anterior   
    Method UpdateMessage()      //-- Permite exibir textos no carregamento
    Method UpdateStep()         //-- Permite atualizar cada step da barra de processamento
    Method Activate()           //-- Faz ativação da janela.

EndClass 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LbProgress 
@type			: New 
@Sample			: LbProgress:():New()
@description	: Classe responsavel por criar uma janela de processamento - load. 
@Param			: oOWner    - Objeto Container para pendurar a janela load     
@Param			: bAction   - Bloco de ação com a rotina que será processada
@Param			: cTitle    - Titulo da janela de load
@Param			: cMessage  - Mensagem inicial ao carregar a janela de load
@return			: Object    - Objeto LbProgress
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 26/02/2020
@version		: P12
/*/
//------------------------------------------------------------------------------------------
Method New( oOWner, bAction, cTitle, cMessage ) Class LbProgress

Local nWidthHtml  := 0
Local nHeightHtml := 0

PARAMTYPE 0 VAR oOWner      AS OBJECT       OPTIONAL 
PARAMTYPE 1 VAR bAction		AS BLOCK        DEFAULT {||.T.}
PARAMTYPE 2 VAR cTitle		AS CHARACTER    OPTIONAL DEFAULT "Processando"
PARAMTYPE 3 VAR cMessage	AS CHARACTER    OPTIONAL DEFAULT ""

Default ::bAction       := bAction
Default ::cTitle        := cTitle
Default ::cMessage      := cMessage

Default ::nStart        := 0
Default ::nFinal        := 10
Default ::nStep         := 0

Default ::cBackColor    := "#F0FFFF"
Default ::cForeColor    := "#00CED1"

Default ::oFontDef      := FWGetDefFont()
Default ::oFontHtml     := TFont():New('Courier new',,-14,.T.)
Default ::lBlurWindow   := .T. 
Default ::IsContainered := oOWner <> Nil 
Default ::lFlagProgress := .F. 

If ( !Empty(::oOWner) )

Else 

    //----------------------------------------------
    // Janela
    //----------------------------------------------
    ::oOWner := FWStyledDialog():New(0,0,250,450,"Aguarde...",{||})

    oPanel := TPanelCss():New(000,000,,::oOWner,,.F.,.F.,,,,,.T.,.F.)
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT
    oPanel:ReadClientCoors()
   

    nWidthHtml    := ( ::oOWner:nClientWidth / 2 ) - 20
    nHeightHtml   := ( ::oOWner:nClientHeight / 2) - 20 

    //----------------------------------------------
    // Titulo
    //----------------------------------------------
    DEFINE FONT oFont NAME ( ::oFontDef:Name ) SIZE 0, -15
    @ 020,019 SAY oSay PROMPT OemToAnsi(::cTitle) COLOR RGB(000,074,119) SIZE 130,020 FONT oFont OF oPanel HTML PIXEL 
    oSay:SetCSS( "QLabel{ color:rgb(000,074,119); background: transparent; }" )


	// Cria o Say permitindo texto no formato HMTL 
	::oSayRun := TSay():New(035     ,;      // Indica a coordenada vertical em pixels ou caracteres.
                            019     ,;      // Indica a coordenada horizontal em pixels ou caracteres.
                            {|| ::CreateLoader( ::nStart, ::nFinal, ::nStep  ) },; // Indica o bloco de cï¿½digo que serï¿½ executado para retornar e apresentar uma string.
                            oPanel  ,;      // Indica a janela ou controle visual onde o objeto serï¿½ criado.
                            /*cPicture*/,;  // Mï¿½scara de formataï¿½ï¿½o
                            ::oFontHtml,;     // Indica o objeto do tipo TFont utilizado
                            /*uParam7*/,;   // Compatibilidade
                            /*uParam8*/,;   // Compatibilidade
                            /*uParam9*/,;   // Compatibilidade
                            .T.,;           // Coordenadas passadas em pixels (.T.) ou caracteres (.F.).
                            /*nClrText*/,;  // Indica a cor do texto do objeto.
                            /*nClrBack*/,;  // Indica a cor de fundo do objeto.
                            nWidthHtml,;    // Indica a largura em pixels do objeto.
                            nHeightHtml,;   // Indica a altura em pixels do objeto.
                            /*uParam15*/,;  // Compatibilidade
                            /*uParam16*/,;  // Compatibilidade
                            /*uParam17*/,;  // Compatibilidade
                            /*uParam18*/,;  // Compatibilidade
                            /*uParam19*/,;  // Compatibilidade
                            .T. /*lHtml*/)  // habilita a visualizaï¿½ï¿½o do texto no formato HTML



EndIf 


Return( Self )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LbProgress 
@type			: New 
@Sample			: LbProgress:():SetColor( cBackColor, cForeColor)
@description	: Permite alterar as cores da barra de progresso sendo no formato 
                  hexadecimal #008080 
@Param			: cBackColor    - Cor do fundo    
@Param			: cForeColor    - Cor 
@return			: Nulo
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 26/02/2020
@version		: P12
/*/
//------------------------------------------------------------------------------------------
Method SetColor( cBackColor, cForeColor ) Class LbProgress

PARAMTYPE 0 VAR cBackColor	AS CHARACTER    OPTIONAL DEFAULT ::cBackColor
PARAMTYPE 1 VAR cForeColor	AS CHARACTER    OPTIONAL DEFAULT ::cForeColor


If !("#" $ cBackColor ) 

    cBackColor := "#" + cBackColor

EndIf 

If !("#" $ cForeColor ) 

    cForeColor := "#" + cForeColor

EndIf 


::cBackColor := cBackColor
::cForeColor := cForeColor


Return()


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LbProgress 
@type			: Activate 
@Sample			: LbProgress:():Activate()
@description	: Ativa a janela de processamento
@return			: Nulo
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 26/02/2020
@version		: P12
/*/
//------------------------------------------------------------------------------------------
Method Activate() Class LbProgress



If ( ::IsContainered )

	Eval(::bAction, Self)
	
Else

    // -----------------------------------------
    // Desfoca a janela anterior
    // -----------------------------------------
    If ( ::lBlurWindow )
        oBackGround := FWCreateTransparent(.F.)
    EndIf 

    ::oOWner:Activate(,,,.T.,,,  { | |  ActiveOwner( Self )   })


    // -------------------------------------------------------
    // Retira o Desfoque da janela anterior
    // -------------------------------------------------------
    If ( ::lBlurWindow )
        FWDestroyTransparent(oBackGround)
    EndIf 

Endif

Return(  )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ActiveOwner 
@type			: Funcao estatica 
@Sample			: LbProgress:():ActiveOwner( oSelf  )
@description	: Funcao para ativar o Owner principal \ simular o processamento \ fechar
                  a janela no fim do processameto.
@return			: Nulo
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 26/02/2020
@version		: P12
/*/
//------------------------------------------------------------------------------------------
Static Function ActiveOwner( oSelf  )

Local cMessage  := ""
Local nInterval := 100
Local nI        := 0

 Eval(oSelf:bAction, oSelf)

 //- Simula processamento quando UpdateStep for omitido
 If !( oSelf:lFlagProgress )
 
    For nI := 1 To 10

        cMessage := "Numero: " + cValToChar( nI )
        oSelf:UpdateStep( nI, cMessage, nInterval )

    Next

 EndIf 

 oSelf:oOWner:End()

Return( .T. )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} UpdateStep 
@type			: UpdateStep 
@Sample			: LbProgress:():UpdateStep()
@description	: Permite atualizar cada step da barra de processamento 
@param          : nStep     : Numero referente ao step atual da barra     
@param          : cMessage  : Mensagem para usuario
@param          : nInterval : Intervalo de tempo entre os steps
@return			: Nulo
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 26/02/2020
@version		: P12
/*/
//------------------------------------------------------------------------------------------
Method UpdateStep( nStep, cMessage, nInterval ) Class LbProgress

Local cSayHtml := "" 

PARAMTYPE 0 VAR nStep	    AS NUMERIC      DEFAULT 0
PARAMTYPE 2 VAR cMessage    AS CHARACTER    OPTIONAL DEFAULT ::cMessage
PARAMTYPE 3 VAR nInterval   AS NUMERIC      OPTIONAL DEFAULT 150

    ::lFlagProgress := .T.
    ::nStep         := nStep

    cSayHtml := ::CreateLoader(nStep, 10 - nStep, nStep * 10, cMessage)
    ::oSayRun:cCaption := cSayHtml  
   
    ProcessMessages()

    Sleep( nInterval )
 
Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CreateLoader 
@type			: CreateLoader 
@Sample			: LbProgress:():CreateLoader()
@description	: Permite atualizar cada step da barra de processamento 
@param          : nStart    : step inicial     
@param          : nFinal    : step final
@param          : nStep     : step atual 
@param          : cMessage  : Messagem 
@return			: Nulo
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 26/02/2020
@version		: P12
/*/
//------------------------------------------------------------------------------------------
Method CreateLoader( nStart, nFinal, nStep, cMessage  ) Class LbProgress

Local cTextHtml := ""

PARAMTYPE 0 VAR nStart      AS NUMERIC      OPTIONAL DEFAULT ::nStart
PARAMTYPE 1 VAR nFinal	    AS NUMERIC      OPTIONAL DEFAULT ::nFinal
PARAMTYPE 2 VAR nStep	    AS NUMERIC      OPTIONAL DEFAULT ::nStep      
PARAMTYPE 3 VAR cMessage    AS CHARACTER    OPTIONAL DEFAULT ::cMessage

::nStart    := nStart
::nFinal    := nFinal
::nStep     := nStep
::cMessage  := cMessage

//Monta o Texto no formato HTML
//http://www.flextool.com.br/tabela_cores.html

cTextHtml := '<html>'
cTextHtml += '      <body>'
cTextHtml += '           <table>'
cTextHtml += '           <tr>'
cTextHtml += '                <td style="background-color:'+ ::cForeColor +';width:' + cValToChar(Round(::nStart,0)) + ';border-style:solid;border-color:black;border-width:1px">'
cTextHtml += '                     ' + Replicate("&nbsp;", ::nStart * 3 )
cTextHtml += '                </td>'
cTextHtml += '                <td style="background-color:'+ ::cBackColor +';width:' + cValToChar(Round(::nFinal,0)) + ';border-style:solid;border-color:black;border-width:1px">'
cTextHtml += '                     ' + Replicate("&nbsp;", ::nFinal * 3 )
cTextHtml += '                </td>'
cTextHtml += '                <td>'
cTextHtml += '                     <font color="#000000">' + ALLTRIM(Transform(( ::nStep ),"@E 999")) + '%</font>'
cTextHtml += '                </td>'
cTextHtml += '           </tr>'

cTextHtml += '          </table>'

cTextHtml += '          <p> '+ cMessage + '</p>'

cTextHtml += '      </body>'
cTextHtml += ' </html>'
	

Return(cTextHtml)



User Function Teste010()

Local cMessage  := ""
Local bAction   := { | | U_Teste11( oSelf, "param2","param3" ) } 
Local nI        := 0

oProgress := LbProgress():New( /*oDlg*/, bAction,"Processando titulos" ) 

oProgress:SetColor( "#66CDAA","#36648B" )

oProgress:Activate()


Return()

User Function Teste11(  oSelf, a, b   )

Local cScore := ""
Local nI        := 1


If MsgYesNo("Parametro 1 " + cValToChar( a ) + CRLF + ;
            "Parametro 2 " + cValToChar( b ) + CRLF + CRLF + ;
            "Deseja executar a barra de progresso ? " )

    nInterval := 1000

    For nI := 1 To 10

        // cScore := '<a href="https://github.com/lucasbrustolin/Protheus" title="GitHub ">https://github.com/lucasbrustolin/Protheus</a>'
        // cScore += '<ol>'
       
        // For nJ := 1 To nI
        //     cSCore += '<li> Process -> ' + cValToChar( nJ ) + "<b> Seconds ....</b></li>
        // Next 

        // cScore += '</ol>'
 

        If Mod( nI, 2 ) <> 0
            cScore := '<p><font face="verdana" color="#FF4500" size=2 > '+ cScore
        Else 
            cScore := '<p><font face="Georgia" color="#43CD80" size=2 > '+ cScore      
        EndIf 

        cSCore += 'Step -> ' + cValToChar( nI ) + ' concluido com sucesso ! </font></p>'

        If nI < 10
            nInterval := 1000
        Else    
            nInterval := 1000
        EndIf 

        oSelf:UpdateStep( nI, cScore, nInterval )

    Next

EndIf 


Return()


