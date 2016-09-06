if exists('g:loaded_graft_angular') || &cp | finish | endif

call RegisterGraftLoader("angularjs", "javascript")
call RegisterGraftLoader("angularhtml", "html")
