require "test_helper"

class ConsultationReminderTest < ActiveSupport::TestCase
  setup do
    ActionMailer::Base.deliveries.clear
  end

  teardown do
    ActionMailer::Base.deliveries.clear
  end

  test "#send_all notifies authors of consultations 4 weeks from deadline" do
    consultations = create_consultations(8.weeks.ago)

    ConsultationReminder.send_all

    assert_equal 2, ActionMailer::Base.deliveries.size

    consultations.each do |consultation|
      assert ActionMailer::Base.deliveries.any? do |email|
        email.to.sort == consultation.authors.map(&:email).sort &&
          email.subject.includes?("response due in") &&
          email.body.includes?(consultation.title) &&
          email.body.includes?("within 4 weeks")
      end
    end
  end

  test "#send_all notifies authors of consultations 1 weeks from deadline" do
    consultations = create_consultations(11.weeks.ago)

    ConsultationReminder.send_all

    assert_equal 2, ActionMailer::Base.deliveries.size

    consultations.each do |consultation|
      assert ActionMailer::Base.deliveries.any? do |email|
        email.to.sort == consultation.authors.map(&:email).sort &&
          email.subject.includes?("response due in") &&
          email.body.includes?(consultation.title) &&
          email.body.includes?("within 1 week")
      end
    end
  end

  test "#send_all notifies authors of consultations which are 1 day past the deadline" do
    consultations = create_consultations((12.weeks + 1.day).ago)

    ConsultationReminder.send_all

    assert_equal 2, ActionMailer::Base.deliveries.size

    consultations.each do |consultation|
      assert ActionMailer::Base.deliveries.any? do |email|
        email.to.sort == consultation.authors.map(&:email).sort &&
          email.subject.includes?("deadline has passed") &&
          email.body.includes?(consultation.title) &&
          email.body.includes?("deadline") &&
          email.body.includes?("has passed")
      end
    end
  end

  def create_consultations(closed_at)
    FactoryBot.create(:consultation, opening_at: 10.months.ago, closing_at: closed_at + 1.day)
    FactoryBot.create(:consultation, opening_at: 10.months.ago, closing_at: closed_at - 1.day)

    [
      FactoryBot.create(:consultation, opening_at: 10.months.ago, closing_at: closed_at),
      FactoryBot.create(:consultation, opening_at: 10.months.ago, closing_at: closed_at - 2.hours),
    ]
  end
end