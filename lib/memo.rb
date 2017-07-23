class Memo < Post
  Post.post_types[self.name] = self

  def read_from_console
    puts "Новая заметка (все, что пишете до строчки \"end\"):"

    @text = []
    line = nil

    until line == "end" do
      line = STDIN.gets.chomp
      @text << line
    end

    @text.pop
  end

  def to_strings
    time_string = "Создано: #{@created_at.strftime("%Y.%m.%d, %H:%M:%S")}\n\n"

    @text.unshift(time_string)
  end

  def to_db_hash
    super.merge(
      {
        'text' => @text.join('\n\r')
      }
    )
  end

  def load_data(data_hash)
    super(data_hash)

    @text = data_hash['text'].split('\n\r')
  end
end
