class Post
  @@post_types = {}

  def self.post_types
    @@post_types
  end

  def self.create(type)
    puts type
    @@post_types[type].new
  end

  def initialize
    @created_at = Time.now
    @text = nil
  end

  def read_from_console
    # todo
  end

  def to_strings
    # todo
  end

  def save
    file = File.new(file_path, "w:UTF-8")

    file.puts to_strings.join("\n")

    file.close
  end

  def file_path
    save_path = __dir__ + "/../posts"

    Dir.mkdir(save_path) unless Dir.exists?(save_path)

    file_name = @created_at.strftime("#{self.class.name}_%Y-%m-%d_%H-%M-%S.txt")

    File.join(save_path, file_name)
  end
end
