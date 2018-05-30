# == Schema Information
#
# Table name: routes
#
#  id         :integer          not null, primary key
#  start_id   :integer
#  end_id     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Route < ApplicationRecord
    has_many :locations
end
