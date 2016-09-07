function graft#angular#setDefaults()
  let g:graft_angular_source_dir = get(g:, "graft_angular_source_dir", "app")
  let g:graft_angular_template_dir = get(g:, "graft_angular_template_dir", "app/templates")
  let g:graft_angular_controller_dir = get(g:, "graft_angular_controller_dir", g:graft_angular_source_dir . "/controllers")
  let g:graft_angular_directive_dir = get(g:, "graft_angular_directive_dir", g:graft_angular_source_dir . "/directives")
  let g:graft_angular_service_dir = get(g:, "graft_angular_service_dir", g:graft_angular_source_dir . "/services")
endfunction

function graft#angular#sourceDir(directory, source)
  augroup AngularSouceDir
    au!
    execute "au BufNewFile,BufRead */" . a:directory . "/* call graft#angular#setSourceDir('" . a:source . "')"
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
