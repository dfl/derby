require 'active_record'

class Vote < ActiveRecord::Base
  
  def self.score
    Hash[ Vote.totals.map{|v| [v.contestant_id, v.total]} ]
  end
  
  def self.totals
    Vote.find_by_sql("SELECT contestant_id, count(*) as total
    FROM votes GROUP BY contestant_id ORDER BY total DESC")
  end

  def self.winner
    totals.first
  end
  
  def self.reset_all!
    delete_all
  end
end