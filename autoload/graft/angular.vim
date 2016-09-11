let g:graft_angular_source_dir = get(g:, "graft_angular_source_dir", "app")
let g:graft_angular_template_dir = get(g:, "graft_angular_template_dir", "app/templates")
let g:graft_angular_controller_dir = get(g:, "graft_angular_controller_dir", g:graft_angular_source_dir . "/controllers")
let g:graft_angular_directive_dir = get(g:, "graft_angular_directive_dir", g:graft_angular_source_dir . "/directives")
let g:graft_angular_service_dir = get(g:, "graft_angular_service_dir", g:graft_angular_source_dir . "/services")

function graft#angular#load()
  " Try to find the root of the repository
  if !exists("b:graft_angular_dir_root")
    let b:graft_angular_dir_root = graft#angular#getRoot()
  endif

  " Try real file names, like would be in ng-include, first
  let file = graft#angular#checkFileUnderCursor()
  if !empty(file)
    return file
  endif

  " Try looking up the service or controller name
  let variable = graft#angular#getVariableUnderCursor()
  let prop = ""
  if type(variable) == 3
    let prop = variable[1]
    let variable = variable[0]
  endif

  " If the variable starts with a capital it's probably a controller or service name
  if variable =~ "^[A-Z]"
    let service = graft#angular#find(graft#angular#services(), "factory('" . variable . "'")
    if !empty(service)
      let file = service
    endif
    let controller = graft#angular#find(graft#angular#controllers(), "controller('" . variable . "'")
    if !empty(controller)
      let file = controller
    endif
  endif

  " If we have a file at this point, check the prop and return
  if !empty(file)
    if empty(prop)
      return file
    else
      let Callback = graft#createCallback("graft#angular#highlightVariableProperty", [prop])
      return [ file, Callback ]
    endif
  endif

  " If it's not a variable, see if this line has "include=" in it, and load
  " the file included
  let line = getline('.')
  if line =~ "include="
    let include = matchlist(line, "include=\"'\\([^']\\+\\)'\"")
    if len(include) > 1
      return graft#angular#resolveTemplateFile(include[1])
    endif
  endif

  " If we're on a controller name, look for that controller
  if line =~ "ng-controller="
    let controller = matchlist(line, "ng-controller=\"\\([^\"]\\+\\)\"")
    if len(controller) > 1
      return graft#angular#find(graft#angular#controllers(), "controller('" . controller[1] . "'")
    endif
  endif
endfunction

function graft#angular#sourceDir(directory, source, ...)
  let templates = a:0 > 0 ? a:1 : ""
  let austr = "au BufNewFile,BufRead */" . a:directory . "/* call graft#angular#setSourceDir('" . a:source . "')"
  if !empty(templates)
    let austr .= " | let b:graft_angular_template_dir = '" . templates . "'"
  endif

  augroup AngularSouceDir
    au!
    execute austr
  augroup END
endfunction

function graft#angular#setSourceDir(source)
  let b:graft_angular_source_dir = a:source
  let b:graft_angular_controller_dir = a:source . "/controllers"
  let b:graft_angular_service_dir = a:source . "/services"
  let b:graft_angular_directive_dir = a:source . "/directives"
endfunction

function graft#angular#getRoot()
  let lookup = graft#findupFrom(expand("%:p"), ".git")
  if empty(lookup)
    let lookup = getcwd()
  endif
  return substitute(lookup, "/.git", "", "") . "/"
endfunction

function graft#angular#resolveSourceFile(file)
  return b:graft_angular_dir_root . get(b:, "graft_angular_source_dir", g:graft_angular_source_dir) . "/" . a:file 
endfunction

function graft#angular#resolveTemplateFile(file)
  return b:graft_angular_dir_root . get(b:, "graft_angular_template_dir", g:graft_angular_template_dir) . "/" . a:file
endfunction

function graft#angular#checkFileUnderCursor()
  let cfile = expand("<cfile>")
  let cword = expand("<cword>")

  " If this is an actual filename, just try looking it up in the source dir
  " and then in the template dir
  if !empty(cfile) && cfile != cword
    let file = graft#angular#resolveSourceFile(cfile)
    if filereadable(file)
      return file
    endif
    let file = graft#angular#resolveTemplateFile(cfile)
    echom file
    if filereadable(file)
      return file
    endif
  endif

  return ""
endfunction

function graft#angular#getVariableUnderCursor()
  let cword = expand("<cword>")
  let curIsk = &iskeyword
  setlocal iskeyword+=\.
  let jsword = split(expand("<cword>"), '\.')
  let &iskeyword = curIsk

  if cword == jsword[0]
    return [ cword, '' ]
  else
    return [ jsword[0], cword ]
  endif
endfunction

function graft#angular#services()
  let service_dir = get(b:, "graft_angular_service_dir", g:graft_angular_service_dir)
  let lookup = b:graft_angular_dir_root . service_dir
  return split(globpath(lookup, "*"))
endfunction

function graft#angular#controllers()
  let controller_dir = get(b:, "graft_angular_controller_dir", g:graft_angular_controller_dir)
  let lookup = b:graft_angular_dir_root . controller_dir
  return split(globpath(lookup, "*"))
endfunction

function graft#angular#find(list, pattern)
  for item in a:list
    let contents = join(readfile(item), '\n')
    if contents =~ a:pattern
      return item
    endif
  endfor
  return ""
endfunction

function graft#angular#highlightVariableProperty(str)
  call search('.\?\zs' . a:str . '\ze\( =\|:\) ')
  call matchadd("Search", a:str)
endfunction
