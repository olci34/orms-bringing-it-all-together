class Dog

    attr_accessor :id, :name, :breed
    def initialize(hash)
        self.name = hash[:name]
        self.breed = hash[:breed]
        self.id = nil
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT)
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            insert_dog = DB[:conn].prepare("INSERT INTO dogs (name, breed) VALUES (?,?)")
            insert_dog.execute(self.name, self.breed)
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(hash)
       dog = self.new(hash)
       dog.save
       dog
    end

    def self.new_from_db(row)
        hash = {name: row[1], breed: row[2]}
        dog = self.new(hash)
        dog.id = row[0]
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL
        row = DB[:conn].execute(sql, id)[0]
        dog = self.new_from_db(row)
    end

    def self.find_or_create_by(hash)
        dog = self.find_by_name(hash[:name])
        dog && dog.breed == hash[:breed] ? dog : self.create(hash)
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
        SQL
        row = DB[:conn].execute(sql, name)[0]
        hash = {name: row[1], breed: row[2]}
        dog = self.find_by_id(row[0])
    end

    def update
        sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end