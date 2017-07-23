require 'sqlite3'

class Post
  @@post_types = {}
  @@SQLITE_DB_FILE = "#{__dir__}/../notepad.sqlite"

  def self.post_types
    @@post_types
  end

  def self.create(type)
    @@post_types[type].new
  end

  def self.find_by_id(id)
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    db.results_as_hash = true

    result = db.execute("SELECT * FROM posts WHERE rowid = ?", id)

    result = result[0] if result.is_a?(Array)

    db.close

    if result.empty?
      puts "Такой id = #{id} не найден в базе :("
      return nil
    else
      post = create(result['type'])

      post.load_data(result)

      post
    end
  end

  def self.find_all(type, limit)
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    db.results_as_hash = false

    query = "SELECT rowid, * FROM posts "

    query += "WHERE type = :type " unless type.nil?
    query += "ORDER by rowid DESC "
    query += "LIMIT :limit " unless limit.nil?

    statement = db.prepare(query)

    statement.bind_param('type', type) unless type.nil?
    statement.bind_param('limit', limit) unless limit.nil?

    result = statement.execute!

    statement.close
    db.close

    result
  end

  def self.check_db!
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    db.execute(
        'CREATE TABLE IF NOT EXISTS "main"."posts" ("type" TEXT, ' \
        '"created_at" DATETIME, "text" TEXT, "url" TEXT, "due_date" DATETIME)'
    )
    db.close
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

  def save_to_db
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    db.results_as_hash = true

    db.execute(
        "INSERT INTO posts (" +
          to_db_hash.keys.join(',') +
          ")" +
          " VALUES (" +
          ('?,'*to_db_hash.keys.size).chomp(',') +
          ")",
        to_db_hash.values
    )

    insert_row_id = db.last_insert_row_id

    db.close

    insert_row_id
  end

  def to_db_hash
    {
      'type' => self.class.name,
      'created_at' => @created_at.to_s
    }
  end

  def load_data(data_hash)
    @created_at = Time.parse(data_hash['created_at'])
  end
end
