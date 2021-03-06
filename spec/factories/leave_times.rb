# == Schema Information
#
# Table name: leave_times
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  leave_type      :string
#  quota           :integer
#  usable_hours    :integer
#  used_hours      :integer          default("0")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  refilled        :boolean          default("false")
#  effective_date  :date             not null
#  expiration_date :date             not null
#  remark          :text
#  locked_hours    :integer
#

# frozen_string_literal: true
FactoryGirl.define do
  factory :leave_time do
    user
    leave_type 'annual'
    effective_date  { Time.current.beginning_of_year }
    expiration_date { Time.current.end_of_year }
    quota           0
    used_hours      0
    usable_hours    0
    locked_hours    0
    remark          'Test string'

    Settings.leave_applications.leave_types.keys.each do |type|
      trait type.to_sym do
        leave_type type
      end
    end
  end
end
