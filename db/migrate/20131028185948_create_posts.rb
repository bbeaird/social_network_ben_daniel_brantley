class CreatePosts < ActiveRecord::Migration
  def change
    create_table(:posts) do |t|
      t.string :title
      t.string :body
      t.belongs_to :user
      # t.integer :user_id
      t.timestamps
    end
  end
end
