call graft#angular#setDefaults()

function graft#angularjs#load()
  if !exists("b:graft_angular_dir_root")
    let b:graft_angular_dir_root = graft#angular#getRoot()
  endif

  let file = graft#angular#checkFileUnderCursor()
  if !empty(file)
    return file
  endif
  
  let variable = graft#angularjs#getVariableUnderCursor()
  let prop = ""
  if type(variable) == 3
    let prop = variable[1]
    let variable = variable[0]
  endif

  if variable =~ "^[A-Z]"
    for service in graft#angularjs#lookupServices()
      let contents = join(readfile(service), '\n')
      if contents =~ "factory('" . variable . "'"
        let file = service
        break
      endif
    endfor
  endif

  if empty(prop)
    return file
  else
    let Callback = graft#createCallback("graft#angularjs#highlightVariableProperty", [prop])
    return [ file, Callback ]
  endif
endfunction

function graft#angularjs#getVariableUnderCursor()
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

function graft#angularjs#lookupServices()
  let service_dir = get(b:, "graft_angular_service_dir", g:graft_angular_service_dir)
  let lookup = b:graft_angular_dir_root . service_dir
  return split(globpath(lookup, "*"))
endfunction

function graft#angularjs#highlightVariableProperty(str)
  call search('.\?\zs' . a:str . '\ze\( =\|:\) ')
  call matchadd("Search", a:str)
endfunction
