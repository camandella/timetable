class CreateSpectacles < ActiveRecord::Migration[5.2]
  def up
    create_table :spectacles do |t|
      t.string :name, null: false
      t.daterange :range, null: false
      t.timestamps
    end

    # Поскольку EXCLUDE реализуется с помощью индексов, то отдельный индекс для range не создаю
    # Само ограничение накладывается на возможность пересечения диапазонов
    ActiveRecord::Base.connection.execute <<-SQL
      ALTER TABLE spectacles ADD CONSTRAINT spectacles_range_constraint EXCLUDE USING GIST(range WITH &&)
    SQL
  end

  def down
    drop_table :spectacles
  end
end
