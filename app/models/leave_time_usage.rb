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

class LeaveTimeUsage < ApplicationRecord
  belongs_to :leave_application
  belongs_to :leave_time

  after_create :lock_leave_time_hours

  private

  def lock_leave_time_hours
    leave_time = LeaveTime.find(self.leave_time_id)
    leave_time.lock_hours!(self.used_hours)
  end
end
