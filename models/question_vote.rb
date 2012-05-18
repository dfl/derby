require 'active_record'

class QuestionVote < ActiveRecord::Base
  class << self

    def score_array
      score_hash.values
    end

    def score_hash
      hash = Hash[ totals("question_id ASC").map{|v| [v.question_id, v.total]} ]
      Hash[ (1..32).to_a.map{|a| [a,0 ]} ].merge( hash )
    end
    
    def parse votes, ip=nil
      votes.split(",").map(&:to_i).each_with_index{|c,i| create(:question_id => i+1, :ip => ip) if c==1  }
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