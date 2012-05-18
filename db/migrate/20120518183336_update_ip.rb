class UpdateIp < ActiveRecord::Migration
  def self.up
    add_column :votes, :ip, :string
    add_column :question_votes, :ip, :string
  end

  def self.down
    remove_column :votes, :ip
    remove_column :question_votes, :ip
  end
end
