"""Configuration Search and Append Helper

Searches for a key. If key is not found appends it to the end.

Usage:
  search_append.py [--file=<kn>] [--key=<kn>]

Options:
  -h --help     Show this screen.
  --version     Show version.
  --file=<kn>   File to handle.
  --key=<kn>    Key to append
"""
from docopt import docopt

def append(file, key):
    if key not in open(file).read():
        with open(file, "a") as append_file:
            append_file.write(key)


if __name__ == "__main__":
    arguments = docopt(__doc__, version='Search Append V:1.0')
    append(arguments['--file'], arguments['--key'])
