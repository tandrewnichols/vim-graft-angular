call graft#angular#setDefaults()

function graft#angularhtml#load()
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

  if line =~ "ng-controller="
    let controller = matchlist(line, "ng-controller=\"\\([^\"]\\+\\)\"")
    if len(controller) > 1
      return graft#angular#find(graft#angular#controllers(), "controller('" . controller[1] . "'")
    endif
  endif
endfunction
