ActiveRecord::Schema.define(:version => 0) do

  create_table :articles do |t|
    t.string :title
    t.text :intro
    t.boolean :published
    t.integer :position
    t.timestamps
  end

end

