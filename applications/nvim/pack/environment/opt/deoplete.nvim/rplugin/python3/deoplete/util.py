# ============================================================================
# FILE: util.py
# AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
# License: MIT license
# ============================================================================

import os
import re
import sys
import glob
import importlib.util
import traceback
import typing
import unicodedata

if importlib.util.find_spec('pynvim'):
    from pynvim import Nvim
    from pynvim.api import Buffer
else:
    from neovim import Nvim
    from neovim.api import Buffer

UserContext = typing.Dict[str, typing.Any]
Candidate = typing.Dict[str, typing.Any]
Candidates = typing.List[Candidate]


def set_pattern(variable: typing.Dict[str, str],
                keys: str, pattern: typing.Any) -> None:
    for key in keys.split(','):
        variable[key] = pattern


def convert2list(expr: typing.Any) -> typing.List[typing.Any]:
    return (expr if isinstance(expr, list) else [expr])


def convert2candidates(l: typing.Any) -> Candidates:
    ret = []
    if l and isinstance(l, list):
        for x in l:
            if isinstance(x, str):
                ret.append({'word': x})
            else:
                ret.append(x)
    else:
        ret = l
    return ret


def globruntime(runtimepath: str, path: str) -> typing.List[str]:
    ret: typing.List[str] = []
    for rtp in runtimepath.split(','):
        ret += glob.glob(rtp + '/' + path)
    return ret


def import_plugin(path: str, source: str,
                  classname: str) -> typing.Optional[typing.Any]:
    """Import Deoplete plugin source class.

    If the class exists, add its directory to sys.path.
    """
    name = os.path.splitext(os.path.basename(path))[0]
    module_name = 'deoplete.%s.%s' % (source, name)

    spec = importlib.util.spec_from_file_location(module_name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)  # type: ignore
    cls = getattr(module, classname, None)
    if not cls:
        return None

    dirname = os.path.dirname(path)
    if dirname not in sys.path:
        sys.path.insert(0, dirname)
    return cls


def debug(vim: Nvim, expr: typing.Any) -> None:
    if hasattr(vim, 'out_write'):
        string = (expr if isinstance(expr, str) else str(expr))
        vim.out_write('[deoplete] ' + string + '\n')
    else:
        vim.call('deoplete#util#print_debug', expr)


def error(vim: Nvim, expr: typing.Any) -> None:
    if hasattr(vim, 'err_write'):
        string = (expr if isinstance(expr, str) else str(expr))
        vim.err_write('[deoplete] ' + string + '\n')
    else:
        vim.call('deoplete#util#print_error', expr)


def error_tb(vim: Nvim, msg: str) -> None:
    lines: typing.List[str] = []
    t, v, tb = sys.exc_info()
    if t and v and tb:
        lines += traceback.format_exc().splitlines()
    lines += ['%s.  Use :messages / see above for error details.' % msg]
    if hasattr(vim, 'err_write'):
        vim.err_write('[deoplete] %s\n' % '\n'.join(lines))
    else:
        for line in lines:
            vim.call('deoplete#util#print_error', line)


def error_vim(vim: Nvim, msg: str) -> None:
    throwpoint = vim.eval('v:throwpoint')
    if throwpoint != '':
        error(vim, 'v:throwpoint = ' + throwpoint)
    exception = vim.eval('v:exception')
    if exception != '':
        error(vim, 'v:exception = ' + exception)
    error_tb(vim, msg)


def escape(expr: str) -> str:
    return expr.replace("'", "''")


def charpos2bytepos(encoding: str, text: str, pos: int) -> int:
    return len(bytes(text[: pos], encoding, errors='replace'))


def bytepos2charpos(encoding: str, text: str, pos: int) -> int:
    return len(bytes(text, encoding, errors='replace')[: pos].decode(
        encoding, errors='replace'))


def get_custom(custom: typing.Dict[str, typing.Any],
               source_name: str, key: str,
               default: typing.Any) -> typing.Any:
    custom_source = custom['source']
    if source_name not in custom_source:
        return get_custom(custom, '_', key, default)
    elif key in custom_source[source_name]:
        return custom_source[source_name][key]
    elif key in custom_source['_']:
        return custom_source['_'][key]
    else:
        return default


def get_syn_names(vim: Nvim) -> str:
    return str(vim.call('deoplete#util#get_syn_names'))


def parse_file_pattern(f: typing.Iterable[str],
                       pattern: str) -> typing.List[str]:
    p = re.compile(pattern)
    ret: typing.List[str] = []
    for l in f:
        ret += p.findall(l)
    return list(set(ret))


def parse_buffer_pattern(b: Buffer, pattern: str) -> typing.List[str]:
    return list(set(re.compile(pattern).findall('\n'.join(b))))


def fuzzy_escape(string: str, camelcase: bool) -> str:
    # Escape string for python regexp.
    p = re.sub(r'([a-zA-Z0-9_])', r'\1.*', re.escape(string))
    if camelcase and re.search(r'[A-Z]', string):
        p = re.sub(r'([a-z])', (lambda pat:
                                '['+pat.group(1)+pat.group(1).upper()+']'), p)
    p = re.sub(r'([a-zA-Z0-9_])\.\*', r'\1[^\1]*', p)
    return p


def load_external_module(base: str, module: str) -> None:
    current = os.path.dirname(os.path.abspath(base))
    module_dir = os.path.join(os.path.dirname(current), module)
    if module_dir not in sys.path:
        sys.path.insert(0, module_dir)


def truncate_skipping(string: str, max_width: int,
                      footer: str, footer_len: int) -> str:
    if not string:
        return ''
    if len(string) <= max_width/2:
        return string
    if strwidth(string) <= max_width:
        return string

    footer += string[
            -len(truncate(string[::-1], footer_len)):]
    return truncate(string, max_width - strwidth(footer)) + footer


def truncate(string: str, max_width: int) -> str:
    if len(string) <= max_width/2:
        return string
    if strwidth(string) <= max_width:
        return string

    width = 0
    ret = ''
    for c in string:
        wc = charwidth(c)
        if width + wc > max_width:
            break
        ret += c
        width += wc
    return ret


def strwidth(string: str) -> int:
    width = 0
    for c in string:
        width += charwidth(c)
    return width


def charwidth(c: str) -> int:
    wc = unicodedata.east_asian_width(c)
    return 2 if wc == 'F' or wc == 'W' else 1


def expand(path: str) -> str:
    return os.path.expanduser(os.path.expandvars(path))


def getlines(vim: Nvim, start: int = 1,
             end: typing.Union[int, str] = '$') -> typing.List[str]:
    if end == '$':
        end = len(vim.current.buffer)
    max_len = min([int(end) - start, 5000])
    lines: typing.List[str] = []
    current = start
    while current <= int(end):
        lines += vim.call('getline', current, current + max_len)
        current += max_len + 1
    return lines


def binary_search_begin(l: typing.List[Candidates], prefix: str) -> int:
    if not l:
        return -1
    if len(l) == 1:
        word = l[0]['word']  # type: ignore
        return 0 if word.lower().startswith(prefix) else -1

    s = 0
    e = len(l)
    prefix = prefix.lower()
    while s < e:
        index = int((s + e) / 2)
        word = l[index]['word'].lower()  # type: ignore
        if word.startswith(prefix):
            if (index - 1) < 0:
                return index
            prev_word = l[index-1]['word']  # type: ignore
            if not prev_word.lower().startswith(prefix):
                return index
            e = index
        elif prefix < word:
            e = index
        else:
            s = index + 1
    return -1


def binary_search_end(l: typing.List[Candidates], prefix: str) -> int:
    if not l:
        return -1
    if len(l) == 1:
        word = l[0]['word']  # type: ignore
        return 0 if word.lower().startswith(prefix) else -1

    s = 0
    e = len(l)
    prefix = prefix.lower()
    while s < e:
        index = int((s + e) / 2)
        word = l[index]['word'].lower()  # type: ignore
        if word.startswith(prefix):
            if (index + 1) >= len(l):
                return index
            next_word = l[index+1]['word']  # type: ignore
            if not next_word.lower().startswith(prefix):
                return index
            s = index + 1
        elif prefix < word:
            e = index
        else:
            s = index + 1
    return -1


def uniq_list_dict(l: typing.List[typing.Any]) -> typing.List[typing.Any]:
    # Uniq list of dictionaries
    ret: typing.List[typing.Any] = []
    for d in l:
        if d not in ret:
            ret.append(d)
    return ret
