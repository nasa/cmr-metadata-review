class PostgresUniqueColumnSets < ActiveRecord::Migration[4.2]
    def self.up
      execute "ALTER TABLE reviews ADD UNIQUE (record_id, user_id)"
    end

    def self.down
      execute "ALTER TABLE reviews DROP UNIQUE (record_id, user_id)"
    end
end
