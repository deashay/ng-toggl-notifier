require 'pstore'

class DailyNotifier
  WEEKEND_DAY_THRESHOLD = 1
  BUSINESS_DAY_THRESHOLD = 8

  STORE = File.join(File.expand_path('..', __dir__), 'store', 'daily.pstore')

  attr_reader :weekly_reports

  def initialize(weekly_reports)
    @weekly_reports = weekly_reports
  end

  def self.call(weekly_reports)
    new(weekly_reports).call
  end

  def call
    today = Date.today
    week_day = today.wday
    weekly_reports.each do |report|
      case week_day
      when 0, 6
        weekend_day_notification(report) if send_business_day_notification?(week_day, report)
      else
        business_day_notification(report) if send_weekend_day_notification?(week_day, report)
      end
    end
  end

  private

  def weekend_day_notification(user_report)
    # TODO: Send email.
    store_notification(report.email)
  end

  def business_day_notification(report)
    Mailer.send_daily_to_user(report.email, report)
    store_notification(report.email)
  end

  def send_weekend_day_notification?(week_day, report)
    report.day_hours(week_day) >= BUSINESS_DAY_THRESHOLD && last_sent(report.email) < Date.today
  end

  def send_business_day_notification?(week_day, report)
    report.day_hours(week_day) >= WEEKEND_DAY_THRESHOLD && last_sent(report.email) < Date.today
  end

  def store_notification(email)
    store = PStore.new(STORE)
    store.transaction do
      store[email] = Date.today.to_s
    end
  end

  def last_sent(email)
    store = PStore.new(STORE)
    store.transaction do
      Date.parse store.fetch(email, Date.new.to_s)
    end
  end
end