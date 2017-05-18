# frozen_string_literal: true
namespace :leave_time do
  desc "initialize employee leave time"
  task :init, [:year, :skip] => [:environment] do |t, args|
    def beginning_of_year?
      (Time.now.beginning_of_year .. Time.now.beginning_of_year.end_of_day).cover? Time.now
    end

    skip_validate = (!args[:skip].nil? && args[:skip] == "force") ? true : false
    if skip_validate || beginning_of_year?
      year = args[:year].nil? ? Time.zone.today.year : args[:year].to_i
        User.fulltime.each do |user|
        LeaveTime.leave_types.values.each do |leave_type|
          user.leave_times.create!(
                                user_id: user.id,
                                leave_type: leave_type,
                                quota: 99,
                                effective_date: Time.now,
                                expiration_date: Time.now.end_of_month
                                )
        end
      end
    end
  end

  desc "my epmloyee leave refill"
  task my_refill: :environment do
    User.fulltime.each do |user|
      LeaveTime.leave_types.values.each do |leave_type|
        user.leave_times.create!(
                              user_id: user.id,
                              leave_type: leave_type,
                              quota: 99,
                              effective_date: Time.now,
                              expiration_date: Time.now.end_of_month
                              )
      end
    end
  end

  desc "correct employee leave time"
  task correct: :environment do
    def adjust(augend , addend)
      diff = augend.used_hours - addend.usable_hours
      positive = (diff >= 0)

      amount = positive ? addend.usable_hours : augend.used_hours
      augend.deduct(-amount)
      addend.deduct(amount)

      diff
    end

    User.all.each do |user|
      personal = LeaveTime.personal(user.id, "personal")
      annual = LeaveTime.personal(user.id, "annual")
      bonus = LeaveTime.personal(user.id, "bonus")

      adjust(personal.reload, bonus) if adjust(personal, annual) > 0

      puts "#{user.name} 修正時數"
    end
  end

  desc "refill employee annual leave time if needed"
  task refill: :environment do
    User.fulltime.each do |user|
      user.get_refilled_annual
    end

    puts "給予任職滿一年的 8hrs 特休"
  end
end
