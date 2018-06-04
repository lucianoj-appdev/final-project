# == Schema Information
#
# Table name: routes
#
#  id         :integer          not null, primary key
#  start_id   :integer
#  end_id     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

class Route < ApplicationRecord
    has_many :locations
    serialize :weather, JSON
end
