# == Schema Information
#
# Table name: bonus_leave_time_logs
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  manager_id     :integer
#  authorize_date :datetime
#  hours          :integer          default("0")
#  description    :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

# frozen_string_literal: true
class BonusLeaveTimeLog < ApplicationRecord
  belongs_to :user
  belongs_to :manager, class_name: 'User', foreign_key: 'manager_id'
end
