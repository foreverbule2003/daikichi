# == Schema Information
#
# Table name: leave_application_logs
#
#  id                     :integer          not null, primary key
#  leave_application_uuid :string
#  returning?             :boolean          default("false")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  amount                 :integer          default("0")
#
# Indexes
#
#  index_leave_application_logs_on_leave_application_uuid  (leave_application_uuid)
#

# frozen_string_literal: true
class LeaveApplicationLog < ApplicationRecord
  belongs_to :leave_application, foreign_key: 'leave_application_uuid', primary_key: 'uuid'
end
