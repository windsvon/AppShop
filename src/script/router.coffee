W.currentView = null
W.viewTransiting = false

W.disposeCurrentView = (nextViewController)->
    if W.currentView?.dispose
        W.currentView.dispose({nextViewParent: nextViewController.parentViewClass})
    else
        Promise.resolve(true)

W.toView = (nextViewController, params...)->
    if W.viewTransiting
        console.log 'WARNING! View transitions conflict!'
    W.viewTransiting = true
    q = W.disposeCurrentView(nextViewController).then ->
        nextViewController.show(params...).then (view)->
            W.currentView = view
            W.currentController = nextViewController
    q.lastly ->
        W.viewTransiting = false

window.Routers = Backbone.Router.extend({
    initialize: ->

    routes:
        "": "game"
        "game": "game"
        "game/:id": "gameDetail"
        "app": "app"
        "app/:id": "appDetail"
        "zhuanti": "zhuanti"
        "search/:key": "search"
        "zhuanti/:id": "zhuantiDetail"
        "category/game/:id": "gameCategoryDetail"
        "category/app/:id": "appCategoryDetail"

    game: ->
        W.toView W.View.Game

    gameDetail: (id)->
        W.toView W.View.AppGameDetail, {group: "game", id}

    appDetail: (id)->
        W.toView W.View.AppGameDetail, {group: "app", id}

    app: ->
        W.toView W.View.App

    gameCategoryDetail: (id) ->
        W.toView W.View.CategoryDetail, {group: "game", id}

    appCategoryDetail: (id) ->
        W.toView W.View.CategoryDetail, {group: "app", id}

    zhuanti: ->
        W.toView W.View.Zhuanti

    zhuantiDetail: (id) ->
        W.toView W.View.ZhuantiDetail, id

    search: (key)->
        W.toView W.View.Search, {key}
})

#Path.root("#/game")
#
#Path.map("#/game").to ->
#    W.toView W.View.Game
#
#Path.map("#/app").to ->
#    W.toView W.View.App
#
#Path.map("#/zhuanti").to ->
#    W.toView W.View.Zhuanti
#
#Path.map("#/search/:key").to ->
#    W.toView W.View.Search, this.params
#
#Path.map("#/:group/:id").to ->
#    W.toView W.View.AppGameDetail, this.params
