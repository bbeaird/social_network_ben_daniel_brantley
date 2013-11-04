class PasswordToDigest < ActiveRecord::Migration
  def up
    rename_column :users, :password, :hex_digest
  end

  def down
  end
end
