"""Configuration Append Helper

Searches a configuration block with a given KEY. Removes the old conf if exists and
appends the new one to the end of the file.

Usage:
  conf_append.py [--file=<kn>] [--key=<kn>] [--append=<kn>]

Options:
  -h --help     Show this screen.
  --version     Show version.
  --file=<kn>   File to handle.
  --key=<kn>    Key to search in file.
  --append=<kn> Content to append into file.
"""
from docopt import docopt
import re

magic_text_start=' #Start\n'
magic_text_stop=' #End\n'

def append(file, content, key):
    with open(file, "a") as append_file:
        kstart = key + magic_text_start
        kend = key + magic_text_stop
        capp = content.split('\\n')

        append_file.write(kstart)
        for item in capp:
            append_file.write(item + '\n')
        append_file.write(kend)

def remove(file, key):
    # create regular expression pattern
    kstart = key + magic_text_start
    kend = key + magic_text_stop
    chop = re.compile(kstart+'.*?'+kend, re.DOTALL)

    # open file
    f = open(file, 'r')
    data = f.read()
    f.close()

    # chop text between magic keywords
    data_chopped = chop.sub('', data)

    # save result
    f = open(file, 'w')
    f.write(data_chopped)
    f.close()


if __name__ == "__main__":
    arguments = docopt(__doc__, version='Search Append V:1.0')
    remove (arguments['--file'], arguments['--key'])
    append(arguments['--file'], arguments['--append'], arguments['--key'])
