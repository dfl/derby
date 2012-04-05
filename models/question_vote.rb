require 'active_record'

class QuestionVote < ActiveRecord::Base
  class << self

    def score_array
      totals("question_id ASC").map(&:total)
    end

    def score_hash
      Hash[ totals.map{|v| [v.question_id, v.total]} ]
    end

    def parse votes
      votes.split(",").map(&:to_i).each_with_index{|c,i| create(:question_id => i+1) if c==1  }
    end

    def totals order="total DESC"
      QuestionVote.find_by_sql("SELECT question_id, count(*) as total FROM question_votes GROUP BY question_id ORDER BY #{order}")
    end

    def winner
      totals.first
    end
    
    def winner_to_s
      "question #{winner.question_id} got #{winner.total} votes"
    end

    def reset_all!
      delete_all
    end

  end
end