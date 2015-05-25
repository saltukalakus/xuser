"""Auto replace helper

Searches the given KEY and if found, replaces it with the REPLACE text

Usage:
  auto_replace.py [--file=<kn>] [--search=<kn>] [--replace=<kn>]

Options:
  -h --help     Show this screen.
  --version     Show version.
  --file=<kn>   File to handle.
  --search=<kn> Text to be replaced
  --replace=<kn> Text to replace
"""
from docopt import docopt

def replace( file, search, replace):
    # open file
    f = open(file, 'r')
    data = f.read()
    f.close()

    data_replaced = data.replace(search, replace, 1);

    # save result
    f = open(file, 'w')
    f.write(data_replaced)
    f.close()

if __name__ == "__main__":
    arguments = docopt(__doc__, version='Auto Replace V:1.0')
    replace(arguments['--file'], arguments['--search'], arguments['--replace'])