# == Schema Information
#
# Table name: leave_time_usages
#
#  id                   :integer          not null, primary key
#  leave_application_id :integer
#  leave_time_id        :integer
#  used_hours           :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_leave_time_usages_on_leave_application_id  (leave_application_id)
#  index_leave_time_usages_on_leave_time_id         (leave_time_id)
#

FactoryGirl.define do
  factory :leave_time_usage do
    leave_application nil
    leave_time nil
    used_hours 1
  end
end
