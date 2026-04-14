function! db#adapter#cloudspanner#auth_input() abort
  return v:false
endfunction

function! s:trim(str) abort
  return substitute(a:str, '^\s*\|\s*$', '', 'g')
endfunction

function! s:normalize(project, instance, database, params) abort
  return db#url#format({
        \ 'scheme': 'cloudspanner',
        \ 'host': a:project,
        \ 'path': '/' . a:instance . '/' . a:database,
        \ 'params': a:params,
        \ })
endfunction

function! s:normalize_jdbc_path(url) abort
  let match = matchlist(a:url, '^cloudspanner://\([^/?#]\+\)/projects/\([^/?#]\+\)/instances/\([^/?#]\+\)/databases/\([^/?#]\+\)\([?#].*\)\=$')
  if !empty(match)
    let parsed = db#url#parse('cloudspanner:' . match[5])
    let parsed.params.endpoint = match[1]
    return s:normalize(match[2], match[3], match[4], parsed.params)
  endif

  let match = matchlist(a:url, '^cloudspanner:\/*projects/\([^/?#]\+\)/instances/\([^/?#]\+\)/databases/\([^/?#]\+\)\([?#].*\)\=$')
  if !empty(match)
    let parsed = db#url#parse('cloudspanner:' . match[4])
    return s:normalize(match[1], match[2], match[3], parsed.params)
  endif

  return ''
endfunction

function! s:split_target(url) abort
  let parsed = db#url#parse(a:url)
  let parts = split(substitute(get(parsed, 'path', ''), '^/', '', ''), '/')
  return [get(parsed, 'host', ''), get(parts, 0, ''), get(parts, 1, ''), parsed.params]
endfunction

function! s:argv(url) abort
  let [project, instance, database, params] = s:split_target(a:url)
  let cmd = ['spanner-cli']

  if get(params, 'endpoint', '') =~# '^\%(localhost\|127\.0\.0\.1\)\%(:\d\+\)\=$'
    let cmd = ['env', 'SPANNER_EMULATOR_HOST=' . remove(params, 'endpoint')] + cmd
  endif

  if !empty(project)
    call add(cmd, '--project=' . project)
  endif
  if !empty(instance)
    call add(cmd, '--instance=' . instance)
  endif
  if !empty(database)
    call add(cmd, '--database=' . database)
  endif

  for [k, v] in items(params)
    if v is# 1 || v is# get(v:, 'true', 1)
      call add(cmd, '--' . k)
    else
      call add(cmd, '--' . k . '=' . v)
    endif
  endfor

  return cmd
endfunction

function! db#adapter#cloudspanner#canonicalize(url) abort
  let url = substitute(a:url, '^jdbc:', '', '')
  let normalized = s:normalize_jdbc_path(url)
  if !empty(normalized)
    return normalized
  endif

  let url = db#url#absorb_params(url, {'project': 'host'})
  let parsed = db#url#parse(url)
  if has_key(parsed.params, 'instance') && has_key(parsed.params, 'database')
    let parsed.path = '/' . remove(parsed.params, 'instance') . '/' . remove(parsed.params, 'database')
  endif
  return db#url#format(parsed)
endfunction

function! db#adapter#cloudspanner#interactive(url) abort
  return s:argv(a:url)
endfunction

function! db#adapter#cloudspanner#filter(url) abort
  let cmd = s:argv(a:url)
  let parsed = db#url#parse(a:url)
  if !get(parsed.params, 'table', 0)
    call add(cmd, '--table')
  endif
  return cmd
endfunction

function! db#adapter#cloudspanner#input(url, in) abort
  return db#adapter#cloudspanner#filter(a:url) + ['--file=' . a:in]
endfunction

function! db#adapter#cloudspanner#tables(url) abort
  let lines = db#systemlist(s:argv(a:url) + ['--execute=SHOW TABLES;'])
  let lines = map(lines, 's:trim(v:val)')
  call filter(lines, '!empty(v:val)')
  if !empty(lines) && lines[0] =~# '^Tables\%(_in_.*\)\=$'
    call remove(lines, 0)
  endif
  return lines
endfunction
