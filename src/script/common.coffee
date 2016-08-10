class Controller
    bindEvents: ->
        return unless @events and @events.length
        for event in @events
            do (event) =>
                @$view.on event[0], event[1], (e)=>
                    @[event[2]](e)

    back: (e)->
        W.preventDefault e

W.Controller = Controller

W.preventDefault = (e)->
    e.preventDefault()
    e.stopImmediatePropagation()
    e.stopPropagation()
    e


#路径转换#########

$(".top-nav").delegate 'li', 'click', (e) ->
    $this = $ e.currentTarget
    target = $this.attr('data-target')
    $('.top-nav').find('.active').removeClass('active')
    $this.addClass('active')
    location.hash = "/#{target}"
    return


#通用方法###########
W.getAppError = (jqxhr)->
    try
        JSON.parse jqxhr.responseText
    catch
        null

W.alertAjaxError = (jqxhr)->
    ae = W.getAppError jqxhr
    if ae
        W.toastError ae.defaultMessage || ae.message
    else if jqxhr.status == 403
        W.toastError "权限不够！"
    else
        W.toastError "服务器错误（#{jqxhr.status}）"

toastTime = 0
toast = (message, level, time)->
    clearTimeout(toastTime)
    $("body>.toast").remove()
    $toast = $ "<div>",
        class: "toast toast-#{level}"
    $content = $ "<div>",
        class: "toast-content",
        html: message
    $toast.html $content
    $toast.appendTo $("body").show()

    toastTime = setTimeout (-> $toast.fadeOut(200).remove()), time

W.toastError = (message, time)->
    toast(message, "error", time = 3000)
W.toastInfo = (message, time)->
    toast(message, "info", time = 3000)
W.toastWarning = (message, time)->
    toast(message, "warning", time = 3000)

W.signInDialog = ->
    $signIn = $(WT.SignInDialog())
    .appendTo($('body'))

    $signIn.find('.dialog-markup').on 'click', (e)->
        W.preventDefault e
        $signIn.remove()

    $signIn.find('.submit')
    .on 'click', (e)->
        W.preventDefault e
        data = {}

        $username = $signIn.find('.username')
        username = $.trim $username.val()
        return W.toastWarning('请填写账户') unless username
        return W.toastWarning('请填写账户') unless username
        data.username = username if username

        $password = $signIn.find('.password')
        password = $.trim $password.val()
        return W.toastWarning('请填写密码') unless password
        data.password = password if password

        q = W.api.post('sign-in', data)
        q.then (user)->
            W.ping()
            $signIn.remove()
        q.catch W.alertAjaxError

    .on 'mousedown', (e)->
        W.preventDefault e
        $(this).addClass('down')
    .on 'mouseleave mouseup', (e)->
        W.preventDefault e
        $(this).removeClass('down')

W.buildUserHtml = (user)->
    $userinfo = $(WT.UserInfo(user))
    $userinfo.appendTo $('.user-bar .content').empty()

W.ping = ->
    q = W.api.get('ping')
    q.then (user)->
        W.user = user
        W.buildUserHtml(user)
    q.catch (e)->
        console.log(e)

W.cloudImg = (img) ->
    'http://wpax.oss-cn-hangzhou.aliyuncs.com/' + img.path

W.cloudDownload = (apk) ->
    'http://wpax.oss-cn-hangzhou.aliyuncs.com/' + apk.path

W.appRating = (score) ->
    if score
        "star-" + Math.ceil(score/100*5)
    else
        "star-3"

W.toYMDHM = (date) ->
    return unless date
    date = new Date date
    return date && date.getYear && ((date.getFullYear()) + "-" + (date.getMonth() + 1) + "-" + (date.getDate()) + " " + (date.getHours()) + ":" + (date.getMinutes()));

W.toYMD = (date) ->
    return unless date
    date = new Date date
    return date && date.getYear && ((date.getFullYear()) + "-" + (date.getMonth() + 1) + "-" + (date.getDate()));

# 获取app大小格式 M G
W.appSize = (size)->
    size = (size / (1024 * 1024)).toFixed(1) || 0
    sizeString = size + " MB"
    if size > 1024
        size = (size / 1024).toFixed(1)
        sizeString = size + " GB"
    return sizeString

# 下载量字符串
W.downloadCountStr = (app)->
    dc = app.downloadCount2 || app.downloadCount || 0
    dc = switch
        when dc < 1000 then dc + ' 次'
        when dc < 10000  then (dc / 1000).toFixed(0) + ' 千次'
        when dc < 1000000  then (dc / 10000).toFixed(0) + ' 万次'
        when dc < 10000000  then (dc / 1000000).toFixed(0) + ' 百万次'
        when dc < 100000000  then (dc / 10000000).toFixed(0) + ' 千万次'
        else (dc / 100000000).toFixed(0) + ' 亿次'
    return dc

# 根据分类名称获取分类id 使用场景: 热门分类下点击详情分类标题实现页面跳转
W.categoryNameToId = (categoryName) ->
    service.getAppCategoryList().then (categories)->
        cId = _.find(categories, {name: categoryName})?._id
        cId

# 用于翻译某些名称
W.toCN = (word) ->
    list =
        game: "游戏"
        app: "应用"

    return list[word]
    

# 用户名转换
W.showUsername = (name)->
    return "**" unless name
    if name.indexOf("@") >= 0 # 邮箱
        return name.substring(0, name.indexOf("@"))
    else # 电话号码
        return name.substring(0, 4) + "****" + name.substring(11 - 4, 11)
