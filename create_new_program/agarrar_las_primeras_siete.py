#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os

def armar_nueva_lista(options):
    print 'cd %s' % options['lna_dir']
    os.chdir(options['lna_dir'])
    with open(options['to_listen_file']) as source:
        source_lines = source.readlines()
        if not os.path.exists(options['program_dir']):
            os.mkdir(options['program_dir'])
        print 'cd %s' % options['program_dir']
        os.chdir(options['program_dir'])
        with open(options['new_file'], 'w') as dest:
            dest_lines = []
            if not options.get('empty', False):
                dest_lines.append("""Nro - Nombre del tema - Artista o banda - Nombre del disco - Año - Duración aprox (min) - Notas
---   ---------------   ---------------   ----------------   ---   ---------------------  -----\n""")
                count = 0
                control = 0
                while count < 7:
                    control += 1
                    if control == 100:
                        break
                    line = source_lines.pop(0)
                    if line == '\n':
                        continue
                    count += 1
                    dest_lines.append('\n%d - ' % (count) + line)
                    if len(source_lines) == 0:
                        print 'there are $d songs on %s' % (count, options['to_listen_file'])
                        break
            dest.writelines(dest_lines)

    os.chdir(options['lna_dir'])
    source = open(options['to_listen_file'], 'w')
    source.writelines(source_lines)
    source.close()

def _parse_input():
    args = len(sys.argv)
    options = {
        'to_listen_file': 'para_escuchar',
        'lna_dir': "/home/gabriel/Documents/radios/La_Nota_Azul",
        'program_dir': "programaN",
        'new_file': "lista_de_temas"}
    if args > 1:
        temp, options['new_file'] = os.path.split(sys.argv[1])
        options['lna_dir'], options['program_dir'] = os.path.split(temp)
        if args > 2 and os.path.isfile(sys.argv[2]):
            options['to_listen_file'] = sys.argv[2]
    return options

if __name__ == '__main__':
    import sys
    options = _parse_input()
    armar_nueva_lista(options)
    exit(0)
