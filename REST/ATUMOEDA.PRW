#include "Totvs.ch"
#include "Tbiconn.ch"

/*/{Protheus.doc} ATUMOEDA
    Fun��o utilizada para buscar a Cota��o da moeda na API do Banco Central
    @type       function
    @author     lucas Silva Vieria
    @since      22/07/2021
    @version    1.0
    @sample        U_ATUMOEDA()
    @url https://olinda.bcb.gov.br/olinda/servico/PTAX/versao/v1/documentacao
 /*/   
User function ATUMOEDA()
	Local cBase     := 'https://olinda.bcb.gov.br/olinda/servico/PTAX/versao/v1/odata'
	Local cUrl      := ''
	Local cGetParms := ''
	Local nTimeOut  := 200
	Local aHeadStr  := {'Content-Type: application/json'}
	Local cHeadGet  := ''
	Local cRet      := ''
	Local aIdMoeda  := {'USD', 'CHF', 'EUR'} //ARRAY COM MOEDAS
	Local cDtCot    := '' //MM-DD-AAAA
	Local oJObj     := ''
	Local cJRet     := ''
	Local cMsg      := ''
	Local nY        := ''
	Local dDataBase := DATE()

	cDtCot := DToS(dDataBase-1)
	cDtCot := SubStr(cDtCot,5,2) + '-' + SubStr(cDtCot,7,2) + '-' + SubStr(cDtCot,1,4)

	FOR nY := 1 TO LEN(aIdMoeda)
		//[GET] Consulta Dados na Api Olinda
		oJObj   := JsonObject():New()
		cUrl := cBase
		cUrl += "/CotacaoMoedaPeriodoFechamento(codigoMoeda=@idMD,dataInicialCotacao=@dtIniCt,dataFinalCotacao=@dtFinCt)"
		cUrl += "?@idMD='"+aIdMoeda[nY]+"'&@dtIniCt='"+cDtCot+"'&@dtFinCt='"+cDtCot
		cUrl += "'&$format=json&$select=cotacaoCompra,cotacaoVenda,dataHoraCotacao,tipoBoletim"

		cRet := HTTPGet( cUrl , cGetParms, nTimeOut, aHeadStr, @cHeadGet )

		cJRet := oJObj:FromJson(cRet)

		If ValType(cJRet) == 'U' //NIL
			//Valida se a Cota��o esta liberada para o dia - oJObj:hasProperty("value")
			If Len(oJObj["value"]) > 0

				cMsg  := "<b>Data:</b> " + DToC(SToD(StrTran(SubStr(oJObj["value"][1]["dataHoraCotacao"],1,10),'-','')))
				cMsg  += " - " + SubStr(oJObj["value"][1]["dataHoraCotacao"],12,5) + "h<br>"
				cMsg  += "<b>Moeda: </b> " + aIdMoeda[nY] + "<br>"
				cMsg  += "<b>Cota��o de Compra:</b> " + cValToChar(oJObj["value"][1]["cotacaoCompra"]) + "<br>"
				cMsg  += "<b>Cota��o de Venda:</b> " + cValToChar(oJObj["value"][1]["cotacaoVenda"]) + "<br>"

				MsgInfo( cMsg ,":: Cota��o "+aIdMoeda[nY]+" - BC API Olinda ::")

			Endif
			FreeObj(oJObj)
		Else
			MsgInfo("Ocorreu erro no processamento do Json" + CRLF+CRLF + cJRet, ':: Cota��o Moeda PTAX - BC API Olinda ::')
		EndIf
	NEXT
Return
