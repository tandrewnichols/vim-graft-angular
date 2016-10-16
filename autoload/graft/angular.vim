let g:graft_angular_source_dir = get(g:, "graft_angular_source_dir", "app")
let g:graft_angular_template_dir = get(g:, "graft_angular_template_dir", "app/templates")
let g:graft_angular_controller_dir = get(g:, "graft_angular_controller_dir", g:graft_angular_source_dir . "/controllers")
let g:graft_angular_directive_dir = get(g:, "graft_angular_directive_dir", g:graft_angular_source_dir . "/directives")
let g:graft_angular_service_dir = get(g:, "graft_angular_service_dir", g:graft_angular_source_dir . "/services")
let g:graft_angular_strict_cursor_placement = get(g:, "graft_angular_strict_cursor_placement", 0)

function graft#angular#load()
  " Try to find the root of the repository
  if !exists("b:graft_angular_dir_root")
    let b:graft_angular_dir_root = graft#angular#getRoot()
  endif

  let loaders = [function('graft#angularLoaders#filename'), function('graft#angularLoaders#variable'), function('graft#angularLoaders#directive')]

  if !g:graft_angular_strict_cursor_placement
    call add(loaders, function('graft#angularLoaders#include'))
    call add(loaders, function('graft#angularLoaders#scope'))
    call add(loaders, function('graft#angularLoaders#controller'))
  endif
  
  let matched = {}
  for l:Loader in loaders
    let loaderMatch = l:Loader()
    if has_key(loaderMatch, 'file')
      let matched.file = loaderMatch.file
      if has_key(loaderMatch, 'prop')
        let matched.Action = graft#createCallback("graft#angular#highlightVariableProperty", [loaderMatch.prop])
      endif
      break
    endif
  endfor

  return matched
endfunction

function graft#angular#setSourceDir(directory, source, ...)
  let templates = a:0 > 0 ? a:1 : ""
  let austr = "au BufNewFile,BufRead */" . a:directory . "/* call graft#angular#initializeSourceVars('" . a:source . "')"
  if !empty(templates)
    let austr .= " | let b:graft_angular_template_dir = '" . templates . "'"
  endif

  augroup AngularSouceDir
    au!
    execute austr
  augroup END
endfunction

function graft#angular#initializeSourceVars(source)
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

function graft#angular#getVariableUnderCursor()
  let cword = expand("<cword>")
  let current = &iskeyword
  setlocal iskeyword+=\.
  let jsword = split(expand("<cword>"), '\.')
  let &iskeyword = current

  if cword == jsword[0]
    return [ cword, '' ]
  else
    return [ jsword[0], cword ]
  endif
endfunction

function graft#angular#services()
  let service_dir = get(b:, "graft_angular_service_dir", g:graft_angular_service_dir)
  let lookup = b:graft_angular_dir_root . service_dir
  return split(globpath(lookup, "**"))
endfunction

function graft#angular#controllers()
  let controller_dir = get(b:, "graft_angular_controller_dir", g:graft_angular_controller_dir)
  let lookup = b:graft_angular_dir_root . controller_dir
  return split(globpath(lookup, "**"))
endfunction

function graft#angular#directives()
  let directive_dir = get(b:, "graft_angular_directive_dir", g:graft_angular_directive_dir)
  let lookup = b:graft_angular_dir_root . directive_dir
  return split(globpath(lookup, "**"))
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
  call search('.\?\<\zs' . a:str . '\ze\( =\|:\) ')
  call matchadd("Search", a:str)
endfunction

function graft#angular#detect()
  let root = graft#getRoot()
  if !empty(root)
    if isdirectory(root . "/node_modules/angular") || isdirectory(root . "/bower_components/angular")
      return 1
    elseif exists('g:graft_angular_locations') && len(filter(deepcopy(g:graft_angular_locations), 'isdirectory(root . "/" . v:val)'))
      return 1
    else
      return 0
    endif
  else
    return 0
  endif
endfunction

function graft#angular#camelCaseDirective(what)
  let newWords = []
  let curWords = split(a:what, '\v[^a-zA-Z0-9]')
  if len(curWords) == 0
    return ''
  endif

  call add(newWords, curWords[0])
  let curWords = curWords[1:]
  for word in curWords
    call add(newWords, substitute(word, '\v^([a-z])(.*)', '\u\1\2', ''))
  endfor

  return join(newWords, '')
endfunction
