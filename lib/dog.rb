require 'pry'
class Dog
  attr_accessor :name
  attr_reader :breed, :id

  def initialize(id: nil, name: , breed:)
      @name = name
      @breed = breed
      @id = id
  end

  def self.create_table
    # test does this for us!
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    sql = <<~SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
    SQL

    DB[:conn].execute(sql, @name, @breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name: , breed:)
    Dog.new(name: name, breed: breed).save
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(find_id)
    sql = <<~SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      SQL
    Dog.new_from_db(DB[:conn].execute(sql, find_id)[0])
  end

  def self.find_by_name(find_name)
    sql = <<~SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      SQL
    Dog.new_from_db(DB[:conn].execute(sql, find_name)[0])
  end

  def update
    update_sql = <<~SQL
      UPDATE dogs
      SET name = ?
      WHERE id = ?
      SQL
    DB[:conn].execute(update_sql, self.name, self.id)
  end

  def self.find_or_create_by(name: , breed: )
    sql = <<~SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
      SQL
      search_result = DB[:conn].execute(sql, name, breed)
    if search_result.length == 0
      return Dog.create(name: name,breed: breed)
    else
      return Dog.new_from_db(search_result[0])
    end
  end
end
