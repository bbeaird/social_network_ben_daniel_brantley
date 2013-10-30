class CreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      t.string :name
      t.string :email
      t.string :password
      t.integer :friends_id
      t.timestamps
    end

    create_table(:friends) do |t|
      t.integer :user_id
      t.integer :friend_id
      t.timestamps
    end
  end
end
