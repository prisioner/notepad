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

# id, limit, type

require 'optparse'

# Все наши опции будут записаны сюда
options = {}

OptionParser.new do |opt|
  opt.banner = 'Usage: read.rb [options]'

  opt.on('-h', 'Prints this help') do
    puts opt
    exit
  end

  # Опция --type передает тип поста
  opt.on('--type POST_TYPE', 'какой тип постов показывать ' \
         '(по умолчанию любой)') { |o| options[:type] = o }

  # Опция --id передает номер записи в базе (идентификатор)
  opt.on('--id POST_ID', 'если задан id - показываем подробно ' \
         'только этот пост') { |o| options[:id] = o }

  # Опция --limit передает, сколько записей мы хотим прочитать из базы
  opt.on('--limit NUMBER', 'сколько последних постов показать ' \
         '(по умолчанию все)') { |o| options[:limit] = o }
end.parse!

result = Post.find(options[:limit], options[:type], options[:id])

if result.is_a?(Post)
  puts "Запись #{result.class.name}, id = #{options[:id]}"

  puts result.to_strings
else # если результат - не один пост - покажем таблицу результатов
  print '| id                 '
  print '| @type              '
  print '| @created_at        '
  print '| @text              '
  print '| @url               '
  print '| @due_date          '
  print '|'

  # Теперь для каждой строки из результатов выведем её в нужном формате
  result.each do |row|
    puts

    row.each do |element|
      element_text = "| #{element.to_s.delete("\n\r")[0..17]}"

      element_text << ' ' * (21 - element_text.size)

      print element_text
    end

    print '|'
  end

  puts
end
