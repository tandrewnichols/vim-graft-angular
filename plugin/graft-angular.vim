if exists('g:loaded_graft_angular') || &cp | finish | endif

call RegisterGraftLoader("angular", "javascript")
call RegisterGraftLoader("angular", "html")
