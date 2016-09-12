function graft#angularLoaders#filename()
  let cfile = expand("<cfile>")
  let cword = expand("<cword>")

  " If this is an actual filename, just try looking it up in the source dir
  " and then in the template dir
  if !empty(cfile) && cfile != cword && cfile =~ "[/.]+"
    let file = graft#angular#resolveSourceFile(cfile)
    if filereadable(file)
      return file
    endif
    let file = graft#angular#resolveTemplateFile(cfile)
    if filereadable(file)
      return file
    endif
  endif

  return ""
endfunction

function graft#angularLoaders#variable()
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
      let file = service
    endif
    let controller = graft#angular#find(graft#angular#controllers(), "controller('" . variable . "'")
    if !empty(controller)
      let file = controller
    endif
  endif

  return [file, prop]
endfunction

function graft#angularLoaders#include()
  let include = matchlist(getline('.'), "include=\"'\\([^']\\+\\)'\"")
  if len(include) > 1
    return graft#angular#resolveTemplateFile(include[1])
  endif

  return ""
endfunction

function graft#angularLoaders#controller()
  let controller = matchlist(getline('.'), "ng-controller=\"\\([^\"]\\+\\)\"")
  if len(controller) > 1
    return graft#angular#find(graft#angular#controllers(), "controller(['\"]" . controller[1] . "['\"]")
  endif

  return ""
endfunction

function graft#angularLoaders#scope()
  let lnum = line('.')
  let col = col('.')
  let currentLine = getline('.')
  let matchnum = search("ng-controller=\"\\([^\"]\\+\\)\"", "b")
  normal! "xyat
  call cursor(lnum, col)
  for line in split(@x, "\n")
    if graft#trimLeft(line) == graft#trimLeft(currentLine)
      let controller = matchlist(getline(matchnum), "ng-controller=\"\\([^\"]\\+\\)\"")[1]
      let file = graft#angular#find(graft#angular#controllers(), "controller(['\"]" . controller . "['\"]")
      return [ file, expand("<cword>") ]
    endif
  endfor
endfunction
