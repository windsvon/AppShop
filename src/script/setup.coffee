console.log 'ENTER UI'

# 建立全局命名空间
W =
    View: {}

window.W = W

class Logger
    constructor: (@tag) -> true
    debug: (messages)->
        console.log messages and messages.join(', ')
W.Logger = Logger