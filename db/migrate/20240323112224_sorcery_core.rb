class SorceryCore < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :crypted_password
      t.string :salt

      t.timestamps null: false

      t.integer :root_folder_id
      t.boolean :private, default: false
      t.boolean :admin, default: false
    end
  end
end
