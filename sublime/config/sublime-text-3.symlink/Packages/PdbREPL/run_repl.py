import sublime
import sublime_plugin
import SublimeREPL.sublimerepl
import re

repl_view = [None]
breakpoints = {}
highlights = []

# TODO: add breakpoints without REPL
# TOOD: highlight stack
# TODO: remember opened views (close on close)
# TODO: highlighthing is bugged sometimes (when opening files)

class RunReplCommand(sublime_plugin.WindowCommand):

    def run(self, args={}):
        # Determine view, row and col of cursor when invoking
        view = self.window.active_view()
        (row, col) = view.rowcol(view.sel()[0].begin())

        # Kill old REPL session
        if repl_view[0]:
            rv = repl_view[0]
            self.window.focus_view(rv)
            self.window.run_command("close")

        # Re-focus view from invocation
        self.window.focus_view(view)

        # Start and hijack REPL session
        manager = SublimeREPL.sublimerepl.manager
        encoding = args.get('encoding', 'utf-8')
        del args['encoding']
        type_ = args.get('type', 'subprocess')
        del args['type']
        rv = manager.open(self.window, encoding, type_, **args)

        re1 = '(> )'   # Non-greedy match on filler
        re2 = '((?:\\/[\\w\\.\\-]+)+)'    # Unix Path 1
        re3 = '.*?'   # Non-greedy match on filler
        re4 = '(\\d+)'    # Integer Number 1
        rg = re.compile(re1 + re2 + re3 + re4, re.IGNORECASE | re.DOTALL)

        # Intercept write
        write = rv.write
        def _write(data):
            # Parse data and open appropriate file/line
            m = rg.search(data)
            if m:
                file_ = m.group(2)
                line = m.group(3)
                print("moving to " + file_ + ":" + line)
                new_view = self.window.open_file(file_ + ":" + line,
                                                 sublime.ENCODED_POSITION)

                # Highlight line
                for v in highlights:
                    v.erase_regions("highlight")
                highlights.clear()

                reg = new_view.line(new_view.sel()[0])
                new_view.add_regions("highlight", [reg], "string")
                highlights.append(new_view)

                # If new view is not in source group
                if(self.window.get_view_index(new_view)[0] !=
                   self.window.get_view_index(view)[0]):
                    # Move new view to source groups
                    (group, view_index) = self.window.get_view_index(view)
                    new_index = len(self.window.views_in_group(group))
                    self.window.set_view_index(new_view, group, new_index)

                # Focus debug view
                # self.window.focus_view(rv._view)

            # Call intercepted function
            write(data)
        rv.write = _write

        # Clear repl_view, breakpoints and highlight on close
        def _clear(*args):
            # Remove gutter marks
            print("erasing breakpoints")
            for entry in breakpoints.values():
                entry[0].erase_regions("breakpoints")
            for view in highlights:
                view.erase_regions("highlight")
            # Clear repl_view and breakpoints
            repl_view[0] = None
            breakpoints.clear()
            highlights.clear()
        rv.call_on_close.append(_clear)

        # Store active REPL view
        repl_view[0] = rv._view

        # Create break point on invocation line
        view.run_command("repl_break")

class ReplSubmitCommand(sublime_plugin.TextCommand):
    def run(self, edit, cmd=''):
        if repl_view:
            view = repl_view[0]
            view.insert(edit, view.sel()[0].begin(), cmd)
            view.run_command("repl_enter")

class ReplBreakCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        # Determine (an) active repl view
        if repl_view:
            view = repl_view[0]
            print("adding breakpoint")
            # Determine row and col of cursor in when invoking
            (row, col) = self.view.rowcol(self.view.sel()[0].begin())
            # Set breakpoint at cursor
            file_ = self.view.file_name()
            cmd = "b " + file_ + ":" + str(row + 1)
            view.run_command("repl_submit", {'cmd': cmd})
            # Store breakpoint
            if self.view.id() not in breakpoints:
                breakpoints[self.view.id()] = (self.view, [])
            breakpoints[self.view.id()][1].append(self.view.sel()[0])
            # Create gutter marks
            for entry in breakpoints.values():
                entry[0].add_regions("breakpoints", entry[1], "string", "bookmark", sublime.HIDDEN | sublime.PERSISTENT)
