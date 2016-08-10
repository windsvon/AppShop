view = null
$w = $(window)

class AppGameDetail extends W.Controller

    events: [
        ['click', '.link-container', 'appDetail']
        ['click', '.btn-add-comment', 'addComment']
        ['click mouseover', '.rating-star', 'getScore']
        ['click', '.more-info', 'showMore']
        ['click', '.page-num, .last, .next', 'toPage']
        ['click', '.category-link', 'categoryDetail']
    ]

    init: (data) ->
        id = data.id
        group = data.group
        @pageNo = 1
        @pageSize = 5
        data =
            pageClass: "view-app-detail"
            title: "应用详情"
            id: id
        @$view = $(WT.AppGameDetail(data))
        $('.top-views').empty().append @$view

        @bindEvents()

        @initAppInfo(id, group)

        Promise.resolve(this)

    getCategoryIdByName: (categoryName) ->
        W.service.getAppCategoryList().then (categories) ->
            id = _.find(categories, name: categoryName)?._id
            return id

    initAppInfo: (id, group) ->
        W.service.getAppDetail(id).then (app) ->
            @app = app
            @$view = $(WT.AppInfo(app: app, group: group))
            $('.app-detail-view').find('.container').append @$view
            return app
        .then (app) =>
            @initAppsByCategory(app.categories[0])
            @initScreenShotsCarousel(app)
            @$comments = @$view.find('.comments-block')
            @initComments(app)
            @getCategoryIdByName(app.categories[0]).then (id) ->
                console.log id
                @$view.find('.category-link').attr('data-target': id)

    initAppsByCategory: (categoryName) ->
        W.service.getAppsByCategory(categoryName, 1, 9).then (list) =>
            list = _.slice(list, 0)
            #由于模式相似, 此处使用了手柄游戏推荐的模板
            @$list = $(WT.HandleGameList(list: list))
            $('.app-may-like').append @$list

    initScreenShotsCarousel: (app) ->
        img = new Image();
        img.src = W.cloudImg(app.screenshots[0]);
        img.onload = ->
            if img.width > img.height
                $('.screen-shots').addClass('horizontal-view').slick({
                    slidesToShow: 2
                })
            else
                $('.screen-shots').addClass('vertical-view').slick({
                    slidesToShow: 3
                })

    appDetail: (e) =>
        W.preventDefault e
        $this = $ e.currentTarget
        id = $this.parent().attr('data-target')
        group = $this.parent().parent().attr('data-target')
        location.hash = "/#{group}/#{id}"
        return

    categoryDetail: (e)->
        W.preventDefault e
        $this = $ e.currentTarget
        id = $this.attr('data-target')
        group = $this.siblings('.group-link').attr('data-target')
        location.hash = "/category/#{group}/#{id}"
        return

#    dispose: ->
#        @$view?.hide().appendTo $('.cache-views')
#        Promise.resolve true

    initComments: (app, pageNo = 1)->
        return unless app
        id = app._id
        W.service.getComments(id, pageNo, @pageSize)
        .then (r)=>
            return unless r
            $commentContent = $('<div>', class: 'wrapper replies')
            $(WT.AppComment(c: c)).appendTo($commentContent) for c in r.page
            $commentContent.appendTo @$comments
            @total = r.total
            @initPagination(@total, pageNo)

    addComment: (e)->
        W.preventDefault e
        return if @addingCommend
        @addingCommend = true

        unless W.user
            @addingCommend = false
            return W.signInDialog()

        @$content = $('.comment-content')
        $star = $('.score-storage')
        content = _.trim @$content.val()
        return W.toastWarning('请填写评论内容!') unless content
        return W.toastWarning('评论内容不能少于4个字!') if content.length < 4
        score = parseInt($star.val())*2 || 6
        userId = W.user.userId || 0
        username = W.user.idName || ""

        q = W.service.addComment(app._id, userId, username, score, content)
        q.then (r)=>
            console.log(r)
            W.toastInfo("添加成功!")
            @addingCommend = false
            @$content.val("")
            c =
                score: score
                comment: content
                username: username
                createdOn: Date.now()

            $comment = $(WT.AppComment(c:c))
            $next = @$comments.find('.replies .comment:first')
            if $next.length
                $comment.insertBefore($next)
            else
                @$comments.find('.replies').html($comment)
        q.catch (jqxhr)->
            W.toast("系统错误，请稍后再试...")


    initPagination: (total, pageNo) ->
        @pageCount = Math.ceil(total/@pageSize)
        $pagination = $(WT.Pagination(pageCount: @pageCount, pageNo: pageNo))
        $('.replies').append($pagination)

        currentPage = '[data-target="' + pageNo + '"]'
        @$view.find('.pagination-block')
            .find('.active').removeClass('active')
            .siblings(currentPage).addClass('active')


    toPage: (e) =>
        W.preventDefault(e)
        $this = $ e.currentTarget
        pageNo = $this.attr('data-target')
        if pageNo <= @pageCount and pageNo > 0
            $('.replies').remove()
            @initComments(app, pageNo).bind(@)


    getScore: (e) ->
        W.preventDefault e
        description = ["太烂", "一般", "还不错", "很好!", "太棒了!"]
        $this = $ e.currentTarget
        currentScore = $('.score-storage').val()
        score = $this.attr('data-target')
        $('.score-storage').val(score)
        $('.comment-rating').removeClass('star-' + currentScore).addClass('star-' + score)
        $('.score-description').empty().append(description[Number(score)-1])
        return

    showMore: (e) ->
        $('.app-intro').addClass('active')
        $('.more-info').remove()


    dispose: ->
        view = null
        Promise.resolve true

    @show: (data)->
        view = new AppGameDetail()
        view.init(data)

W.View.AppGameDetail = AppGameDetail

