require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
     @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = "
    CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT);
    "
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "
    DROP TABLE dogs;"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
     sql = "
     INSERT INTO dogs
     (name, breed) VALUES
     (?, ?);"

     DB[:conn].execute(sql, self.name, self.breed)
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
     end
     self 
  end

  def update
    sql = "
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?;"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(name:,breed:)
    new_dog = Dog.new(name: name,breed: breed)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    Dog.new(id:row[0], name:row[1], breed:row[2])
  end

  def self.find_by_name(name)
    sql = "
    SELECT * FROM dogs
    WHERE name = ?"

    dog_row = DB[:conn].execute(sql, name)[0]
    Dog.new_from_db(dog_row)
  end

  def self.find_by_id(id)
    sql = "
    SELECT * FROM dogs
    WHERE id = ?;"

    dog_row = DB[:conn].execute(sql, id)[0]
    Dog.new_from_db(dog_row)
  end

  def self.find_or_create_by(name:,breed:)
    sql = "
    SELECT * FROM dogs
    WHERE name = ? AND breed = ?"

    found = DB[:conn].execute(sql,name,breed)

  if !found.empty?
    dog_row = found[0]
    dog = Dog.new_from_db(dog_row)
  else 
    dog = Dog.create(name: name, breed: breed)
  end
  dog
end

end