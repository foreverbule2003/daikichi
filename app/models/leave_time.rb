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
class LeaveTime < ApplicationRecord
  delegate :seniority, :name, to: :user

  enum leave_type: Settings.leave_times.quota_types

  belongs_to :user
  has_many   :leave_applications, through: :leave_time_usages
  has_many   :leave_time_usages

  before_validation :set_default_values

  validates :leave_type, :effective_date, :expiration_date, :quota, :usable_hours, :used_hours, :locked_hours, :user, presence: true
  validates :quota,        numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :usable_hours, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :used_hours,   numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :locked_hours, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate  :positive_range

  scope :belong_to, ->(user) {
    where(user: user)
  }

  scope :personal, ->(user_id, leave_type, beginning, closing) {
    overlaps(beginning, closing).find_by(user_id: user_id, leave_type: leave_type)
  }

  scope :overlaps, ->(beginning, closing) {
    where(
      '(leave_times.effective_date, leave_times.expiration_date) OVERLAPS (timestamp :beginning, timestamp :closing)',
      beginning: beginning.beginning_of_day, closing: closing.end_of_day
    )
  }

  scope :effective, ->(date = Time.current) {
    overlaps(date.beginning_of_day, date.end_of_day)
  }

  def deduct(hours)
    self.used_hours += hours
    self.usable_hours = quota - used_hours
    save!
  end

  def cover?(time_format)
    date = time_format.to_date
    (self.effective_date..self.expiration_date).cover? date
  end

  def lock_hours(hours)
    self.usable_hours -= hours
    self.locked_hours += hours
  end

  def lock_hours!(hours)
    self.lock_hours(hours)
    self.save!
  end

  def unlock_hours(hours)
    self.locked_hours -= hours
    self.usable_hours += hours
  end

  def unlock_hours!(hours)
    self.unlock_hours(hours)
    self.save!
  end

  def use_hours(hours)
    self.locked_hours -= hours
    self.used_hours += hours
  end

  def use_hours!(hours)
    self.use_hours(hours)
    self.save!
  end

  def unuse_hours(hours)
    self.used_hours -= hours
    self.usable_hours += hours
  end

  def unuse_hours!(hours)
    self.unuse_hours(hours)
    self.save!
  end

  def unuse_and_lock_hours(hours)
    self.used_hours -= hours
    self.locked_hours += hours
  end

  def unuse_and_lock_hours!(hours)
    self.unuse_and_lock_hours(hours)
    self.save!
  end

  private

  def set_default_values
    self.usable_hours ||= self.quota
    self.used_hours   ||= 0
    self.locked_hours ||= 0
  end

  def positive_range
    unless expiration_date && effective_date && expiration_date >= effective_date
      errors.add(:effective_date, :range_should_be_positive)
    end
  end

  def overlaps?
    LeaveTime.overlaps(effective_date, expiration_date)
      .where(user_id: user_id, leave_type: self.leave_type)
      .where.not(id: self.id).any?
  end
end
