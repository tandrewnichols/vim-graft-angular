if exists('g:loaded_graft_angular') || &cp | finish | endif

call RegisterGraftLoader("angular", "javascript", function('graft#angular#detect'))
call RegisterGraftLoader("angular", "html", function('graft#angular#detect'))
