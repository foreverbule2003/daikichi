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

require 'rails_helper'

RSpec.describe LeaveTimeUsage, type: :model do
  describe "#associations" do
    it { is_expected.to belong_to(:leave_time) }
    it { is_expected.to belong_to(:leave_application) }
  end

  describe "callback" do
    context "should lock LeaveTime usable_hours after LeaveTimeUsage created" do
      it { is_expected.to callback(:lock_leave_time_hours).after(:create) }

      it "locks LeaveTime hours after LeaveTimeUsage created" do
        lt = create(:leave_time, :annual, usable_hours: 50)
        create(:leave_time_usage, leave_time: lt, used_hours: 10)
        leave_time_usage = LeaveTimeUsage.where(leave_time: lt).first
        leave_time = leave_time_usage.leave_time

        expect(leave_time.usable_hours).to eq 40
        expect(leave_time.used_hours).to eq 0
        expect(leave_time.locked_hours).to eq 10
      end
    end
  end
end
