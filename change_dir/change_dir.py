#!/usr/bin/env python
#-*- coding: utf-8 -*-

import os
import ConfigParser
import argparse
import glob
import subprocess

def _parse_options():
    parser = ConfigParser.ConfigParser()
    parser.read(args.config_file)
    options = parser.defaults()
    return options

def cmp2(x, y):
    i = int(x[8:])
    j = int(y[8:])
    if i > j:
        return 1
    elif i == j:
        return 0
    else:
        return -1

def find_last():
    lna_dir = options['lna_dir']
    ls = filter(lambda l: 'programa' in l, os.listdir(lna_dir))
    ls.sort(cmp=cmp2, reverse=True)
    if args.last:
        return int(ls[0][8:])
    for program in ls:
        actual = os.path.join(lna_dir, program, 'lista_de_temas*')
        lista_file = glob.glob(actual)[0]
        last_program = 0
        with open(lista_file) as lista:
            lines = lista.readlines()
            found = filter(lambda l: 'se pasó' in l, lines)
        if not found:
            continue
        else:
            last_program = int(program[8:]) + 1
            break
    return last_program

parser = argparse.ArgumentParser()
parser.add_argument('-n', '--number', help="Change to program 'number' directory",
                    action='store', type=int, default=0)
parser.add_argument('-c', '--config_file', help="Use this config file",
                    default='/home/gabriel/scripts/lna/config_file')
parser.add_argument('-l', '--last', help="Change to last program directory",
                    action='store_true', default=False)
parser.add_argument('-b', '--base_directory', help="Go to base directory",
                    action='store_true', default=False)
args = parser.parse_args()

if __name__ == '__main__':
    options = _parse_options()
    base_dir = options['lna_dir']
    path = base_dir
    if not args.base_directory:
        program_number = args.number or find_last()
        program = 'programa%d' % program_number
        path = os.path.join(base_dir, program)
    cd_cmd = "roxterm --tab -d %s" % path
    print cd_cmd
    subprocess.call(cd_cmd.split(), stderr=subprocess.PIPE)
    exit(0)
