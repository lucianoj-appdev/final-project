# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

class Location < ApplicationRecord
    validates :name, uniqueness: { scope: :user_id,
    message: "is already taken. Please choose another" }
end
