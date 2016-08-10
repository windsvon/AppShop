view = null
$w = $(window)

class App extends W.Controller

    hotCategories = ["工具", "购物", "理财", "社交"]

    events: [
        ['mouseover', '.rank-group', 'appSelected']
        ['click', '.link-container', 'appDetail']
        ['click', '.category-name, .hot-category-name', 'categoryDetail']
    ]

    init: ->
        @$view = $(WT.App())
        $('.top-views').empty().append @$view
        $('.top-nav').find('.active').removeClass('active')
        $('[data-target="app"]').addClass('active')

        @bindEvents()

        @initAppTops().bind(@)
        @initHotAppList().bind(@)
        @initHandleAppList().bind(@)
        @initHotAppCategories().bind(@)
        @initAppsByCategories(hotCategories)
        @initCarousel()
        return Promise.resolve(this)

    getAppTops: ->
        W.service.getAppTops()

    getHotAppList: ->
        W.service.getHotAppList()

    getHandleAppList: ->
        W.service.getHandleGameList()

    getHotAppCategories: ->
        W.service.getAppCategories()

    getAppsByCategory: (categoryName) ->
        W.service.getAppsByCategory(categoryName).then (list) =>
            list = _.slice(list, 0, 6)
            list.unshift(categoryName)
            return Promise.resolve(list)


    initAppTops: ->
        @getAppTops().then (list) =>
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
        $this = $ e.currentTarget
        id = $this.parent().attr('data-target')
        location.hash = "/app/#{id}"
        return

    categoryDetail: (e)->
        W.preventDefault e
        $this = $ e.currentTarget
        id = $this.attr('data-target')
        location.hash = "/category/app/#{id}"
        return

    initHotAppList: ->
        @getHotAppList().then (list) =>
            list = _.slice(list, 0, 12)
            @$list = $(WT.HotGameList(list: list))
            @$view.find('.hot-game-item').html @$list

    initHandleAppList: ->
        @getHotAppList().then (list) =>
            list = _.slice(list, 0, 9)
            @$list = $(WT.HandleGameList(list: list))
            @$view.find('.handle-game-item').html @$list

    initHotAppCategories: ->
        @getHotAppCategories().then (list) =>
            list = _.slice(list, 0, 15)
            @categories = list
            @$list = $(WT.HotCategories(list: list))
            @$view.find('.category-item').html @$list

    initAppsByCategories: (hotCategories) ->
        for category in hotCategories
            @getAppsByCategory(category).then (list) =>
                categoryId = _.find(@categories, name: list[0])._id
                @$list = $(WT.GamesByCategory(list: list, categoryId: categoryId))
                @$view.find('.hot-categories').append @$list

    initAppAdList: ->
        W.service.getAppAdList().then (list) =>
            console.log list
            list = _.slice(list, 0)
            @$list = $(WT.AppAdList(list: list, group: "app"))
            @$view.find('.carousel-game').append @$list

    initCarousel: ->
        @initAppAdList().then =>
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
            $('[data-target="app"]').addClass('active')
            Promise.resolve view
        else
            view = new App
            view.init()

W.View.App = App




