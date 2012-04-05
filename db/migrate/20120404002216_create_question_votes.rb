class CreateQuestionVotes < ActiveRecord::Migration
  def self.up
    create_table :question_votes, :force => true do |t|
      t.references :question
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :question_votes
  end
end
