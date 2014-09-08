#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import datetime
import subprocess
import argparse
import ConfigParser
import re

from ordered_set import OrderedSet
from collections import OrderedDict
from agarrar_las_primeras_siete import armar_nueva_lista

def _parse_options():
    parser = ConfigParser.ConfigParser()
    parser.read(args.config_file)
    options = parser.defaults()
    return options

def _get_bigger_program_number():
    ls = os.listdir('.')
    program_numbers = [int(d[8:]) for d in ls
                       if re.match('programa\d+', d)]
    bigger = reduce(lambda x, y: x if x>y else y, program_numbers)
    for i in range(bigger, 0, -1):
        last_program = 'programa%i' % i
        if os.listdir(last_program):
            break
        print "directory %s is empty" % last_program
    if i > 1:
        return i
    else:
        print 'no hay programas, salgo'
        exit(1)

def make_resenias(direc='N'):
    if not direc:
        direc = _get_bigger_program_number()
    directory = 'programa%s' % direc
    ls = os.listdir(directory)
    #TODO: chequear por dia y que resenias este vacio
    lista = [f for f in ls if 'lista_de_temas' in f][0]
    try:
        resenias = [f for f in ls if 'resenias' in f][0]
    except IndexError:
        resenias = 'resenias_%s' % lista[-6:]
    lista_file = os.path.join(directory, lista)
    resenias_file = os.path.join(directory, resenias)
    with open(lista_file) as lf_open:
        canciones = filter(lambda c: c != '\n', lf_open.readlines()[2:])
        print 'Creo %s' % resenias_file
        with open(resenias_file, 'w') as rf_open:
            sep = ' - '
            resenia_template = """{0}) {1}. {2}
**Compartir**:

 @{1} "{3}"

@La Nota Azul: www.planetacabezon.com
**************

"""
            for cancion in canciones:
                splited = cancion.split(sep)
                nro, song, artist, album = splited[0:4]
                rf_open.write(resenia_template.format(nro, artist,
                                                      album, song))

def run():
    last = _get_bigger_program_number()
    last_program =  'programa%i' % last
    #TODO: agregar lna-subir-listas?
    old_path_ls = os.listdir(last_program)
    new = last + 1
    new_program = 'programa%i' % new
    last_program_file = [f for f in old_path_ls if 'lista_de' in f
                         or 'resenias' in f][0]
    last_date = datetime.datetime.strptime(last_program_file[-6:],
                                           '%d%m%y')
    delta = {1: 2, 3: 5}
    days = options['delta_days'] or delta[last_date.weekday()]
    delta_date = last_date + datetime.timedelta(days=days)
    new_date = datetime.datetime.strftime(delta_date, '%d%m%y')
    new_file = 'lista_de_temas_%s' % new_date

    if not os.path.exists('programaN'):
        print 'creo nueva lista'
        armar_nueva_lista(options)

    d = OrderedDict(
        (('mv programaN {new_program}', {'new_program': new_program}),
         ('mv {new_program}/lista_de_temas {new_program}/{new_file}',
          {'new_program': new_program, 'new_file': new_file}))
        )
    for k, v in d.items():
        cmd = k.format(**v)
        print cmd
        subprocess.call(cmd.split())

    for of in ['resenias_%s', 'programa%s.xspf']:
        other_file = of % new_date
        new_path = os.path.join(new_program, other_file)
        if not os.path.exists(new_path):
            print 'También creo: %s' % new_path
            f = open(new_path, 'w')
            f.close()

    print 'Todo ok... salgo'
    exit(0)

def reverse_run():
    last = _get_bigger_program_number()
    last_program = 'programa%i' % last
    ls = os.listdir(last_program)
    to_listen = options.get('to_listen_file', None)
    lista = [f for f in ls if 'lista_de_temas' in f][0]
    last_file = os.path.join(last_program, lista)
    with open(last_file) as lf_open:
        canciones = filter(lambda c: c != '\n', lf_open.readlines()[2:])
        with open(to_listen, 'r+w') as tl_open:
            actuales = tl_open.readlines()

    nuevas = OrderedSet()
    sep = ' - '
    for cancion in canciones:
        splited = cancion.split(sep)[1:]
        nuevas.add(sep.join(splited))

    tl_open = open(to_listen, 'w')
    print 'escribo nuevas'
    tl_open.writelines(nuevas)
    print 'escribo actuales'
    tl_open.writelines(actuales)
    tl_open.close()

    rm_cmd = 'rm -rf %s' % last_program
    print rm_cmd
    subprocess.call(rm_cmd.split())

parser = argparse.ArgumentParser()
parser.add_argument('-r', '--reverse', help="Undo last change",
                    action='store_true', default=False)
parser.add_argument('-m', '--make_resenias', help="Make resenias",
                    action='store', type=int, default=0)
parser.add_argument('-d', '--delta_days', help="Difference (in days) between last program and new one",
                    action='store', type=int, default=0)
parser.add_argument('-e', '--empty', help="Just create empty files",
                    action='store_true', default=False)
parser.add_argument('-c', '--config_file', help="Use this config file",
                    default='/home/gabriel/scripts/lna/config_file')
args = parser.parse_args()

if __name__ == '__main__':
    options = _parse_options()
    options.setdefault('delta_days', args.delta_days)
    print 'ingreso a: %s' % options['lna_dir']
    os.chdir(options['lna_dir'])
    if args.reverse:
        print 'reverse'
        reverse_run()
    elif args.make_resenias:
        print 'resenias'
        make_resenias(args.make_resenias)
    else:
        options.setdefault('empty', args.empty)
        print 'run'
        run()
