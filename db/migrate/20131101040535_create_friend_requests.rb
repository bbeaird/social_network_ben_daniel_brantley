class CreateFriendRequests < ActiveRecord::Migration
  def change
    create_table(:friend_requests) do |t|
      t.integer :user_id
      t.integer :request_id
      t.timestamps
    end
  end
end
