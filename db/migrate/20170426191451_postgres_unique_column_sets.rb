class PostgresUniqueColumnSets < ActiveRecord::Migration
    def self.up
      execute "ALTER TABLE records ADD UNIQUE (recordable_id, revision_id)"
      execute "ALTER TABLE reviews ADD UNIQUE (record_id, user_id)"
    end

    def self.down
      execute "ALTER TABLE records DROP UNIQUE (recordable_id, revision_id)"
      execute "ALTER TABLE reviews DROP UNIQUE (record_id, user_id)"
    end
end
