class Friend < ActiveRecord::Base
  belongs_to :user
  def self.is_friend?(frnd_id, usr_id)
    id_list = []
    Friend.all.each do |friend|
      if friend.user_id == usr_id
        id_list << friend.friend_id
      elsif friend.friend_id == usr_id
        id_list << friend.user_id
      end
    end
    id_list.include?(frnd_id)
  end
end