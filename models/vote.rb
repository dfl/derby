require 'active_record'

class Vote < ActiveRecord::Base
  class << self

    def score_array
      totals("contestant_id ASC").map(&:total)
    end

    def score_hash
      Hash[ totals.map{|v| [v.contestant_id, v.total]} ]
    end

    def parse votes
      votes.split(",").map(&:to_i).each_with_index{|c,i| create(:contestant => i+1) if c==1  }
    end

    def totals order="total DESC"
      Vote.find_by_sql("SELECT contestant_id, count(*) as total
      FROM votes GROUP BY contestant_id ORDER BY #{order}")
    end

    def winner
      totals.first
    end

    def reset_all!
      delete_all
    end

  end
end