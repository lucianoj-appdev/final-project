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
    validates :start_id, uniqueness: { scope: :end_id,
    message: "Routes should have a different start and end location." }
    validates :end_id, uniqueness: { scope: :start_id,
    message: "Routes should have a different start and end location." }
    # validates :end_id, exclusion: { in: :start_id,
    # message: "Routes should have a different start and end location." }
end
