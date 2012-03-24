require 'active_record'

class Vote < ActiveRecord::Base
  # def winner?
  #   totals.first
  # end
  
  def totals
    Vote.find_by_sql("SELECT contestant_id, count(*) as total
    FROM votes GROUP BY contestant_id ORDER BY contestant_id")
  end
  
  def self.reset_all!
    delete_all
  end
end