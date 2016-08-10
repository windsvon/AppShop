view = null
$w = $(window)

class Game extends W.Controller

    hotCategories = ["跑酷竞速", "卡牌收集", "动作格斗", "角色扮演"]

    events: [
        ['mouseover', '.rank-group', 'appSelected']
        ['click', '.link-container', 'appDetail']
        ['click', '.category-name, .hot-category-name', 'categoryDetail']
    ]

    init: ->
        @$view = $(WT.Game())
        $('.top-views').empty().append @$view

        @bindEvents()

        @initGameTops()
        @initHotGameList()
        @initHandleGameList()
        @initHotGameCategories()
        @initGamesByCategories(hotCategories)
        @initCarousel()
        return Promise.resolve(this)

    getGameTops: ->
        W.service.getGameTops()

    getHotGameList: ->
        W.service.getHotGameList()

    getHandleGameList: ->
        W.service.getHandleGameList()

    getHotGameCategories: ->
        W.service.getGameCategories()

    getGamesByCategory: (categoryName) ->
        W.service.getAppsByCategory(categoryName).then (list) =>
            list = _.slice(list, 0, 6)
            list.unshift(categoryName)
            return Promise.resolve(list)


    initGameTops: =>
        @getGameTops().then (list) =>
            #默认显示10个apk
            list = _.slice(list, 0, 12)
            @$list = $(WT.GameTops(list: list))
            @$view.find('.rank-item').html @$list
            $('.app-group').first().addClass('active')

    appSelected: (e)->
        W.preventDefault e
        $this = $ e.currentTarget
        $('.top-views').find('.active').removeClass('active')
        $this.addClass('active')

    appDetail: (e)->
        W.preventDefault e
        $this = $ e.currentTarget
        id = $this.parent().attr('data-target')
        location.hash = "/game/#{id}"
        return

    categoryDetail: (e)->
        W.preventDefault e
        $this = $ e.currentTarget
        id = $this.attr('data-target')
        location.hash = "/category/game/#{id}"
        return

    initHotGameList: =>
        @getHotGameList().then (list) =>
            list = _.slice(list, 0, 12)
            @$list = $(WT.HotGameList(list: list))
            @$view.find('.hot-game-item').html @$list

    initHandleGameList: =>
        @getHotGameList().then (list) =>
            list = _.slice(list, 0, 9)
            @$list = $(WT.HandleGameList(list: list))
            @$view.find('.handle-game-item').html @$list

    initHotGameCategories: =>
        @getHotGameCategories().then (list) =>
            list = _.slice(list, 0, 15)
            @categories = list
            @$list = $(WT.HotCategories(list: list))
            @$view.find('.category-item').html @$list

    initGamesByCategories: (hotCategories) =>
        for category in hotCategories
            @getGamesByCategory(category).then (list) =>
                categoryId = _.find(@categories, name: list[0])._id
                @$list = $(WT.GamesByCategory(list: list, categoryId: categoryId))
                @$view.find('.hot-categories').append @$list

    initGameAdList: =>
        W.service.getGameAdList().then (list) =>
            list = _.slice(list, 0)
            @$list = $(WT.AppAdList(list: list, group: "game"))
            @$view.find('.carousel-game').append @$list

    initCarousel: =>
        @initGameAdList().then =>
            @$view.find('.carousel-game').slick({
                dots: true
                autoplay: true
                autoplaySpeed: 1500
            })

    dispose: ->
        @$view?.hide().appendTo $('.cache-views')
        Promise.resolve true

    @show: ->
        if view
            view.$view.show().appendTo $('.top-views').empty()
            $('.top-nav').find('.active').removeClass('active')
            $('[data-target="game"]').addClass('active')
            Promise.resolve view
        else
            view = new Game
            view.init()

W.View.Game = Game




