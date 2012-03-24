class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes, :force => true do |t|
      t.references :contestant
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :votes
  end
end
