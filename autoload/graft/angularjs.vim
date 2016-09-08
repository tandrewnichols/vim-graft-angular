call graft#angular#setDefaults()

function graft#angularjs#load()
  if !exists("b:graft_angular_dir_root")
    let b:graft_angular_dir_root = graft#angular#getRoot()
  endif

  let file = graft#angular#checkFileUnderCursor()
  if !empty(file)
    return file
  endif
  
  let variable = graft#angular#getVariableUnderCursor()
  let prop = ""
  if type(variable) == 3
    let prop = variable[1]
    let variable = variable[0]
  endif

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

  if empty(prop)
    return file
  else
    let Callback = graft#createCallback("graft#angular#highlightVariableProperty", [prop])
    return [ file, Callback ]
  endif
endfunction

