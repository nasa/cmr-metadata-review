class AddFormatVersionToRecord < ActiveRecord::Migration[6.0]
  def change
    add_column :records, :format_version, :string
  end
end
