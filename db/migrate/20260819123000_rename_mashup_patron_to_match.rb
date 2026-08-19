class RenameMashupPatronToMatch < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      UPDATE patrons
      SET name = 'MATCH', updated_at = CURRENT_TIMESTAMP
      WHERE name = 'Mashup' AND patron_type = 3
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE patrons
      SET name = 'Mashup', updated_at = CURRENT_TIMESTAMP
      WHERE name = 'MATCH' AND patron_type = 3
    SQL
  end
end
