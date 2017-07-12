# encoding: utf-8
# Этот код необходим только при использовании русских букв на Windows
if Gem.win_platform?
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

require_relative 'lib/post'
require_relative 'lib/memo'
require_relative 'lib/link'
require_relative 'lib/task'

puts "Привет, я твой блокнот!"
puts "Что хотите записать в блокнот?"

choices = Post.post_types.keys

choice = -1

until choice.between?(0, choices.size - 1)
  # " 1. Memo" <- каждый в отдельной строке
  puts choices.map.with_index { |type, index| "\t#{index}. #{type}" }.join("\n")

  choice = STDIN.gets.to_i
end

entry = Post.create(choices[choice])

entry.read_from_console

entry.save

puts "Ура, запись сохранена!"
