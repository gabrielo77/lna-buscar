#!/usr/bin/env ruby 
# encoding: utf-8

cont = 0
lines = []
ARGV.each do |dir|
    Dir.chdir(dir) { |cur_dir|
    new_file = File.open(".sarasa", "w")
    j = Dir.glob("lista_de_temas_[0-9][0-9][0-9][0-9][0-9][0-9]")[0]
    puts j

    File.open(j, "r") do |f|
        while line = f.gets
            cont += 1
            if line == "\n"
                new_file.write("\n")
                next
                end
            if cont == 2
                sep = "   "
            else
                sep = " - "
            end
            a = line.split(sep)
            b = [a[0], a[1], a[4], a[2], a[3], a[5], a[6]]
            b = b.compact
            l = b.join(sep)
            new_file.write(l)
        end
    end
    new_file.close
    cd = Dir.getwd
    full_path = cd + "/" + j 
    sarasa = cd + "/" + ".sarasa"
    File.rename(".sarasa", full_path)
    }
end
