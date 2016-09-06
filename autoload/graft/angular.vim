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

