call graft#angular#setDefaults()

function graft#angularhtml#load()
  if !exists("b:graft_angular_dir_root")
    let b:graft_angular_dir_root = graft#angular#getRoot()
  endif

  let file = graft#angular#checkFileUnderCursor()
  if !empty(file)
    return file
  endif

  let line = getline('.')
  if line =~ "include="
    let include = matchlist(line, "include=\"'\\([^']\\+\\)'\"")
    if len(include) > 1
      echom join(include, ',')
      return graft#angular#resolveTemplateFile(include[1])
    endif
  endif
endfunction
