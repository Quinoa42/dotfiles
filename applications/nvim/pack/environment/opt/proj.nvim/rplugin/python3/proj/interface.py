# ======================================================================== {{{
# File: proj/interface.py
# Author: quinoa42
# Description: RPC APIs for proj.nvim
# Last Modified: 2019-05-28
# License: MIT license
# ======================================================================== }}}

import pynvim
import os.path as op
from pathlib import Path

@pynvim.plugin
class ProjPlugin(object):

    def __init__(self, nvim):
        self.nvim = nvim

    @pynvim.function('_proj_root', sync=True)
    def proj_root(self, args):
        filename, filetype = args
        return self._find(op.abspath(filename), filetype)

    def _get_markers(self, ext):
        return self.nvim.call('proj#markers#get', ext)

    def _find(self, filename, ext):
        filename = filename or self.nvim.call('getcwd()')
        markers = self._get_markers(ext) + self._get_markers('_')
        if op.basename(filename) in markers:
            return op.dirname(filename)
        while True:
            if next(filter(op.exists, (op.join(filename, marker)
                for marker in markers)), None) is not None:
                return filename
            if filename == op.abspath(op.sep):
                break
            filename = op.dirname(filename)
        return str(Path.home())

# vim: foldenable:foldmethod=marker
