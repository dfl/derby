require 'active_record'

class Vote < ActiveRecord::Base
  class << self

    def score_array
      score_hash.values
    end

    def score_hash
      hash = Hash[ totals("contestant_id ASC").map{|v| [v.contestant_id, v.total]} ]
      Hash[ (1..32).to_a.map{|a| [a,0 ]} ].merge( hash )
    end

    def parse votes, ip=nil
      votes.split(",").map(&:to_i).each_with_index{|c,i| create(:contestant_id => i+1, :ip => ip) if c==1  }
    end

    def totals order="total DESC"
      Vote.find_by_sql("SELECT contestant_id, count(*) as total FROM votes GROUP BY contestant_id ORDER BY #{order}")
    end

    def winner
      totals.first
    end
    
    def winner_to_s
      "contestant #{winner.contestant_id} got #{winner.total} votes"
    end

    def reset_all!
      delete_all
    end

  end
end