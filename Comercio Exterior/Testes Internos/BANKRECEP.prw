#include "Protheus.ch"            
#INCLUDE "FWADAPTEREAI.CH"
//BANKTRANSACTION
Static Function MenuDef()
Return {}

User Function BANKRECEP()
RpcSetType(3)
RpcSetEnv("99","01")

WSAdvValue( oXmlRet,"_SENDMESSAGERESPONSE:_SENDMESSAGERESULT:TEXT","base64Binary",NIL,NIL,NIL,NIL,NIL,NIL) 

Return EnvEAI("BANKRECEP")

Static Function integdef(cXML, nTypeTrans, cTypeMessage)
Local cXMLRet := ""
Local lRet := .T.
Local cMsg := "BANKTRANSACTION"
Varinfo("BANKTRANSACTION",cMsg)
Varinfo("cXML",cXML)
Varinfo("nTypeTrans",nTypeTrans)
Varinfo("cTypeMessage",cTypeMessage)

If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS
        //cXMLRet := '<BusinessEvent><Entity>EECAF217</Entity><Event>upsert</Event><Identification><key name="BranchId">01</key><key name="ModuleType">E</key><key name="ContractNumber">CONTRATO-ACC-01</key><key name="ClosureBranch">01</key><key name="Market">SP</key><key name="ContractSequence">00</key><key name="EventCode">100</key></Identification></BusinessEvent><BusinessContent><CompanyId>99</CompanyId><BranchId>01</BranchId><Bank><BankCode>1</BankCode><AgencyNumber>0000-8</AgencyNumber><BankAccount>11510-1</BankAccount></Bank><MovementDate>2012-01-18</MovementDate><EntryValue>217901.22</EntryValue><MovementType>2</MovementType><ApportionmentDistribution><Apportionment><DebitAccount>11204</DebitAccount><CreditAccount>10000212</CreditAccount><CostCenterCode>01010101</CostCenterCode></Apportionment></ApportionmentDistribution><HistoryCode>999</HistoryCode><ComplementaryHistory>CAPTACAO CONT. ACC</ComplementaryHistory><DocumentType>2</DocumentType><DocumentNumber>CONTRATO-ACC-01</DocumentNumber><BatchNumber/><BatchSequence/></BusinessContent>'
        cXMLRet := '<CompanyId></CompanyId><BranchId></BranchId><DocumentNumber></DocumentNumber><BatchNumber>'+AllTrim(Str(Randomize(10,100)))+'</BatchNumber><BatchSequence>'+AllTrim(Str(Randomize(10,100)))+'</BatchSequence>'
	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		cXMLRet := '<ShipmentDate>20120223</ShipmentDate>' 
	ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := '1.000'
	EndIf
ElseIf nTypeTrans == TRANS_SEND
	cXMLRet := '<BusinessMessage><BusinessRequest><Operation>EECAF227</Operation></BusinessRequest><BusinessContent><CompanyId>99</CompanyId><BranchId>01</BranchId><DocumentPrefix>EEC</DocumentPrefix><DocumentNumber>388</DocumentNumber><DocumentParcel>1</DocumentParcel><DocumentTypeCode>XP</DocumentTypeCode><PaymentDate>2012-02-15</PaymentDate><CreditDate>2012-02-15</CreditDate><EntryDate>2012-02-15</EntryDate><PaymentValue>25</PaymentValue><CurrencyRate>1.81546</CurrencyRate><CustomerCode>1</CustomerCode><StoreId>.</StoreId><PaymentMethod>004</PaymentMethod><PaymentMeans>000</PaymentMeans><HolderCode>900</HolderCode><HolderType>C</HolderType><FinancialCode></FinancialCode><ListOfCreditDocument><CreditDocument><CompanyId>99</CompanyId><BranchId>01</BranchId><DocumentPrefix>EEC</DocumentPrefix><DocumentNumber>26</DocumentNumber><DocumentParcel>2</DocumentParcel><DocumentTypeCode>TC</DocumentTypeCode><CustomerCode>1</CustomerCode><StoreId>.</StoreId><DocumentValue>25</DocumentValue></CreditDocument></ListOfCreditDocument><DischargeSequence>5</DischargeSequence></BusinessContent></BusinessMessage>'
	//'<BusinessEvent><Entity>EECAF217</Entity><Event>upsert</Event><Identification><key name="BranchId">01</key><key name="ModuleType">E</key><key name="ContractNumber">CONTRATO-ACC-01</key><key name="ClosureBranch">01</key><key name="Market">SP</key><key name="ContractSequence">00</key><key name="EventCode">100</key></Identification></BusinessEvent><BusinessContent><CompanyId>99</CompanyId><BranchId>01</BranchId><Bank><BankCode>1</BankCode><AgencyNumber>0000-8</AgencyNumber><BankAccount>11510-1</BankAccount></Bank><MovementDate>2012-01-18</MovementDate><EntryValue>217901.22</EntryValue><MovementType>2</MovementType><ApportionmentDistribution><Apportionment><DebitAccount>11204</DebitAccount><CreditAccount>10000212</CreditAccount><CostCenterCode>01010101</CostCenterCode></Apportionment></ApportionmentDistribution><HistoryCode>999</HistoryCode><ComplementaryHistory>CAPTACAO CONT. ACC</ComplementaryHistory><DocumentType>2</DocumentType><DocumentNumber>CONTRATO-ACC-01</DocumentNumber><BatchNumber/><BatchSequence/></BusinessContent>'
EndIf

//o trecho abaixo se compilado for?a erro de integra??o para testes
/*lRet := .F. 
cXMLRet := "<Error>"+"Retorno de Erro Para testes - Integra?ao da transa??o banc?ria de inclus?o de contrato"+"</Error>"*/

Varinfo("IntegDef_Return",{ lRet, cXMLRet })
Return { lRet, cXMLRet }

*---------------------------------------------------------*
Static Function EnvEAI(cFuncName) 
*---------------------------------------------------------*
Local aArea       := GetArea()
Local aAreaXX4    := XX4->( GetArea() )
Local nTamFunName := Len( cFuncName ) 
Local aRetorno    := {}

EvalTrigger()
/*
If FindFunction( 'FWXX4SEEK' )
	XX4->( dbSetOrder( 1 ) )
	XX4->( MsSeek(PadR(xFilial('XX4'),Len(XX4->XX4_FILIAL) ) + cFuncName ) )
	FWXX4Seek( cFuncName )
	conOut("teste2")
	While !XX4->( EOF() ) .AND. cFuncName == SubStr( XX4->XX4_ROTINA, 1, nTamFunName )
	    conOut("teste3")
		If FWEAICanSend( EAI_MESSAGE_BUSINESS,, cFuncName )
		   conOut("teste4")
		   aRetorno := &( "STATICCALL(" + cFuncName + ", IntegDef, NIL, '" + TRANS_SEND + "', '" + EAI_MESSAGE_BUSINESS + "')")
			VarInfo("aRetorno",aRetorno)
			If ValType( aRetorno ) == 'A' .AND. Len( aRetorno ) > 1 .AND. aRetorno[1]
				FWEAIMake( EAI_MESSAGE_RESPONSE, aRetorno[2] )
			EndIf
		EndIf
		XX4->( dbSkip() )
	End
EndIf
*/

RestArea( aAreaXX4 )
RestArea( aArea )

Return .T.