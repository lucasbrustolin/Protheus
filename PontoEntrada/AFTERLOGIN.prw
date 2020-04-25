#Include 'Protheus.ch'
#INCLUDE "VKEY.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LbRotina     

Ponto de Entrada executado após a efetivação do  login. 
Define Tecla de Atalho para execução da rotina customizada.

@author	Lucas.Brustolin
@since 	13/11/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
User Function Afterlogin()


    // --------------------------------+
    //  U_LbRotina - Rotina para chamar rotinas customizadas\padrao.  
    // --------------------------------+

    SetKey(K_CTRL_A, {|| U_LbRotina() })

Return()