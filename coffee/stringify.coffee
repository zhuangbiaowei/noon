###
 0000000  000000000  00000000   000  000   000   0000000   000  00000000  000   000
000          000     000   000  000  0000  000  000        000  000        000 000 
0000000      000     0000000    000  000 0 000  000  0000  000  000000      00000  
     000     000     000   000  000  000  0000  000   000  000  000          000   
0000000      000     000   000  000  000   000   0000000   000  000          000   
###

_       = require 'lodash'
chalk   = require 'chalk'

defaults =
    indent:   4      # number of spaces per indent level
    align:    true   # vertically align object values
    maxalign: 32     # maximal number of spaces when aligning
    sort:     false  # sort object keys alphabetically
    circular: false  # check for circular references (expensive!)
    null:     false  # output null dictionary values
    colors:   false  # colorize output with ansi colors
                     # true for default colors or custom dictionary

defaultColors =
    key:     chalk.bold.gray
    null:    chalk.bold.blue
    value:   chalk.bold.magenta
    string:  chalk.bold.white
    visited: chalk.bold.red
    
noop = (s) -> s
noColors = 
    key:     noop
    null:    noop
    value:   noop
    string:  noop
    visited: noop

stringify = (obj, options={}) ->

    opt = _.assign _.clone(defaults), options
    
    indstr = _.padRight '', opt.indent
    
    if opt.colors == true
        colors = defaultColors
    else if opt.colors == false
        colors = noColors
    else
        colors = _.assign _.clone(defaultColors), opt.colors
    
    pretty = (o, ind, visited) ->
        
        if opt.align        
            maxKey = 0
            for own k,v of o
                kl = parseInt(Math.ceil((k.length+2)/opt.indent)*opt.indent)
                maxKey = Math.max maxKey, kl
                if opt.maxalign and maxKey > opt.maxalign
                    maxKey = opt.maxalign
                    break
        l = []
        
        keyValue = (k,v) ->
            s = ind
            if opt.align
                ks = _.padRight k, Math.max maxKey, k.length+2
                i  = _.padRight ind+indstr, maxKey
            else
                ks = _.padRight k, k.length+2
                i  = ind+indstr
            s += colors.key ks
            s += toStr v, i, false, visited

        if opt.sort
            for k in _.keys(o).sort()
                l.push keyValue k, o[k]
        else
            for own k,v of o
                l.push keyValue k, v
            
        l.join '\n'

    toStr = (o, ind='', arry=false, visited=[]) ->
        if not o? 
            if o == null
                return opt.null or arry and colors.null("null") or ''
            if o == undefined
                return colors.null "undefined"
            return colors.null '<?>'
        t = typeof o
        if t == 'string' then return colors.string o 
        else if t == 'object'
            
            if opt.circular
                if o in visited
                    return colors.visited '<v>'
                visited.push o
                
            if o.constructor.name == 'Array'
                s = ind!='' and arry and '.' or ''
                s += '\n' if o.length and ind!=''
                s += (ind+toStr(v,ind+indstr,true,visited) for v in o).join '\n'
            else
                s = arry and '.\n' or '\n'
                s += pretty o, ind, visited
            return s
        else
            return colors.value String o # plain values
        return colors.null '<???>'

    s = toStr obj
    s

module.exports = stringify
