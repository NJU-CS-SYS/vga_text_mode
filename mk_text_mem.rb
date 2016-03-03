#!/usr/bin/env ruby

infile = ARGV[0]
outfile = ARGV[1] || 'text.coe'
width = (ARGV[2] || "1280").to_i / 8
height = (ARGV[3] || "1024").to_i / 8

puts "Input: #{infile}"
puts "Output: #{outfile}"
puts "Width: #{width}"
puts "Height: #{height}"

File.open(outfile, 'w') do |f|
    bytes = []
    File.open(infile, 'r') do |text|
        line_count = 0
        text.each_byte do |ch|
            if ch == "\n".ord
                (width - line_count).times{ bytes.push(" ".ord) }
                line_count = 0
            else
                line_count = line_count + 1
                bytes.push(ch)
            end
        end
    end

    mem_size = width * height;
    addr_width = Math.log2(mem_size - 1).floor + 1;
    f.puts(";mem size is #{mem_size}")
    f.puts(";mem address width is #{addr_width}")
    f.puts("memory_initialization_radix = 16;")
    f.write("memory_initialization_vector = ")
    f.write(bytes.map{ |byte| sprintf("%02x", byte) }.join(", "))
    f.puts(";")

end
