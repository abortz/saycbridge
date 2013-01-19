
class Explore
    constructor: ->
        # The help text is static to make it most accessible to search engines.
        @aboutDiv = document.getElementById('about')

        [@basePath, @callHistory] = @basePathAndCallHistoryFromPath(window.location.pathname)
        @setupView()

    basePathAndCallHistoryFromPath: (path) ->
        pathWithoutLeadingSlash = path[1..]
        if '/' in pathWithoutLeadingSlash
            [basePath, callsString] = pathWithoutLeadingSlash.split('/')
            basePath = "/" + basePath
        else
            basePath = path
            callsString = ""

        try
            callHistory = model.CallHistory.fromCallsStringAndDealerChar(callsString, "N")
        catch error
            callHistory = new model.CallHistory

        return [basePath, callHistory]

    pathForCallsString: (callsString) ->
        return "/explore/" + callsString

    saveState: ->
        callsString = @callHistory.callsString()
        urlForCurrentState = @pathForCallsString callsString
        # If we already have a history entry for the current URL, no need to save.
        if window.location.pathname == urlForCurrentState
            return

        state = { 'callsString': callsString }
        window.History.pushState state, "", urlForCurrentState

    updateFromState: (state) ->
        urlParser = document.createElement 'a'
        urlParser.href = state.url

        [@basePath, @callHistory] = @basePathAndCallHistoryFromPath(urlParser.pathname)
        @setupView()

    setupView: ->
        content = document.body
        $(content).empty()

        # FIXME: We probably don't want to display N/S/E/W as part of the CallHistory.
        board = new model.Board(1) # This is a hack, we just want a non-vuln board to display.
        historyTable = view.CallHistoryTable.fromBoardAndHistory(board, @callHistory)
        content.appendChild historyTable

        possibleCallTable = view.CallExplorerTable.fromCallHistory(@callHistory)
        content.appendChild possibleCallTable

        content.appendChild @aboutDiv

$ ->
    window.mainController = new Explore

    History.Adapter.bind window, 'statechange', (event) ->
        window.mainController.updateFromState(History.getState())
