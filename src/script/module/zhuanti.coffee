view = null
$w = $(window)

class Zhuanti extends W.Controller


    events: [
        ['click', '.page-num, .last, .next', 'toPage']
        ['click', '.zhuanti-group', 'zhuantiDetail']
    ]



    init:  ->
        @pageSize = 5

        $('.top-nav').find('.active').removeClass('active')
        $('[data-target="zhuanti"]').addClass('active')

        @$view = $(WT.Zhuanti())
        $('.top-views').empty().append @$view

        @initZhuantiList()
        @bindEvents()


        return Promise.resolve(this)


    initZhuantiList: (pageNo = 1) =>
        W.service.getZhuantiList(pageNo, @pageSize).then (list) =>
            total = list.total
            @pageCount = Math.ceil(total/@pageSize)
            list = _.slice(list.page, 0)
            console.log list
            @$list = $(WT.ZhuantiList(list: list, pageCount: @pageCount, pageNo: pageNo))
            @$view.find('.container').html @$list
            @initPagination(total, pageNo)
            return list
        .then (list) =>
            for item in list
                W.service.getAppsOfIdsWithZhuanti(item.apps, item._id).then (appList) =>
                    for i in [1...appList.length]
                        return if i > 5
                        $icon = $("<img src=" + W.cloudImg(appList[i].icon) + " />")
                        id = appList[0]
                        target = '[data-target="' + id + '"]'
                        $('.zhuanti-info').find(target).append($icon)


    initPagination: (total, pageNo) ->
        @pageCount = Math.ceil(total/@pageSize)
        $pagination = $(WT.Pagination(pageCount: @pageCount, pageNo: pageNo))
        $('.pagination-view').append($pagination)
        currentPage = '[data-target="' + pageNo + '"]'
        @$view.find('.pagination-block')
        .find('.active').removeClass('active')
        .siblings(currentPage).addClass('active')


    toPage: (e) =>
        W.preventDefault(e)
        $this = $ e.currentTarget
        pageNo = $this.attr('data-target')
        if pageNo <= @pageCount and pageNo > 0
            @initZhuantiList(pageNo)

    zhuantiDetail: (e)->
        W.preventDefault e
        $this = $ e.currentTarget
        id = $this.attr('data-target')
        location.hash = "/zhuanti/#{id}"
        return

                        
    dispose: ->
        @$view?.hide().appendTo $('.cache-views')
        Promise.resolve true

    @show: ->
        if view
            view.$view.show().appendTo $('.top-views').empty()
            $('.top-nav').find('.active').removeClass('active')
            $('[data-target="zhuanti"]').addClass('active')
            Promise.resolve view
        else
            view = new Zhuanti
            view.init()

W.View.Zhuanti = Zhuanti





