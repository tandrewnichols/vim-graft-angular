function graft#angularLoaders#filename()
  let matched = {}
  let cfile = expand("<cfile>")
  let cword = expand("<cword>")

  " If this is an actual filename, just try looking it up in the source dir
  " and then in the template dir
  if !empty(cfile) && cfile != cword && cfile =~ "[/.]+"
    let file = graft#angular#resolveSourceFile(cfile)
    if filereadable(file)
      let matched.file = file
    else
      let file = graft#angular#resolveTemplateFile(cfile)
      if filereadable(file)
        let matched.file = file
      endif
    endif
  endif

  return matched
endfunction

function graft#angularLoaders#variable()
  let matched = {}
  let file = ""
  let prop = ""

  " Try looking up the service or controller name
  let variable = graft#angular#getVariableUnderCursor()
  if type(variable) == 3
    let prop = variable[1]
    let variable = variable[0]
  endif

  " If the variable starts with a capital it's probably a controller or service name
  if variable =~# "^[A-Z]"
    let service = graft#angular#find(graft#angular#services(), "factory('" . variable . "'")
    if !empty(service)
      let matched.file = service
    else
      let controller = graft#angular#find(graft#angular#controllers(), "controller('" . variable . "'")
      if !empty(controller)
        let matched.file = controller
      endif
    endif
  endif

  if !empty(prop)
    let matched.prop = prop
  endif

  return matched
endfunction

function graft#angularLoaders#directive()
  let matched = {}
  let current = &iskeyword
  setlocal iskeyword+=\.
  let cword = expand("<cword>")
  let &iskeyword = current
  let directiveName = graft#angular#camelCaseDirective(cword)
  if !empty(directiveName)
    let directive = graft#angular#find(graft#angular#directives(), "directive('" . directiveName . "'")

    if !empty(directive)
      let matched.file = directive
    endif
  endif

  return matched
endfunction

function graft#angularLoaders#include()
  let matched = {}
  let include = matchlist(getline('.'), "include=\"'\\([^']\\+\\)'\"")
  if len(include) > 1
    let matched.file = graft#angular#resolveTemplateFile(include[1])
  endif

  return matched
endfunction

function graft#angularLoaders#controller()
  let matched = {}
  let controller = matchlist(getline('.'), "ng-controller=\"\\([^\"]\\+\\)\"")
  if len(controller) > 1
    let matched.file = graft#angular#find(graft#angular#controllers(), "controller(['\"]" . controller[1] . "['\"]")
  endif

  return matched
endfunction

function graft#angularLoaders#scope()
  let matched = {}
  let lnum = line('.')
  let col = col('.')
  let currentLine = getline('.')
  let matchnum = search("ng-controller=\"\\([^\"]\\+\\)\"", "b")
  normal! "xyat
  call cursor(lnum, col)
  for line in split(@x, "\n")
    if graft#trimLeft(line) == graft#trimLeft(currentLine)
      let matches = matchlist(getline(matchnum), "ng-controller=\"\\([^\"]\\+\\)\"")
      if len(matches) > 0
        let controller = matches[1]
        let matched.file = graft#angular#find(graft#angular#controllers(), "controller(['\"]" . controller . "['\"]")
        let matched.prop = expand("<cword>")
        break
      endif
    endif
  endfor

  return matched
endfunction
