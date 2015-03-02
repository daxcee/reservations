require 'spec_helper'

shared_examples_for 'valid user email' do
  it 'sends to the reserver' do
    expect(@mail.to.size).to eq(1)
    expect(@mail.to.first).to eq(reserver.email)
  end
  it 'sends an email' do
    expect(ActionMailer::Base.deliveries.count).to eq(1)
  end
  # FIXME: Workaround for #398 disables this functionality for RSpec testing
  # it "is from the admin" do
  #   expect(@mail.from.size).to eq(1)
  #   expect(@mail.from.first).to eq(AppConfig.first.admin_email)
  # end
end

shared_examples_for 'contains reservation' do
  it 'has reservation link' do
    # body contains link to the reservation
    expect(@mail.body).to \
      include("<a href=\"http://0.0.0.0:3000/reservations/#{@res.id}\"")
  end
end

describe UserMailer, type: :mailer do
  before(:all) do
    @app_config = FactoryGirl.create(:app_config)
  end
  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end
  let!(:reserver) { FactoryGirl.create(:user) }
  describe 'checkin_receipt' do
    before do
      @res = FactoryGirl.build(:checked_in_reservation, reserver: reserver)
      @res.save(validate: false)
      @mail = UserMailer.checkin_receipt(@res).deliver
    end
    it_behaves_like 'valid user email'
    it_behaves_like 'contains reservation'
    it 'includes overdue information when overdue' do
      @res.due_date = @res.checked_in.to_date - 1.day
      @res.save(validate: false)
      @mail = UserMailer.checkin_receipt(@res).deliver
      expect(@mail.body).to include('late fee')
    end
  end
  describe 'checkout_receipt' do
    before do
      @res = FactoryGirl.build(:checked_out_reservation, reserver: reserver)
      @res.save(validate: false)
      @mail = UserMailer.checkout_receipt(@res).deliver
    end
    it_behaves_like 'valid user email'
    it_behaves_like 'contains reservation'
  end
  describe 'missed_reservation_notification' do
    before do
      @res = FactoryGirl.build(:missed_reservation, reserver: reserver)
      @res.save(validate: false)
      @mail = UserMailer.missed_reservation_notification(@res).deliver
    end
    it_behaves_like 'valid user email'
  end
  describe 'overdue_checkin_notification' do
    before do
      @res = FactoryGirl.build(:checked_in_reservation, reserver: reserver)
      @res.save(validate: false)
      @mail = UserMailer.overdue_checkin_notification(@res).deliver
    end
    it_behaves_like 'valid user email'
  end
  describe 'overdue_checked_in_fine' do
    before do
      @res = FactoryGirl.build(:checked_in_reservation, reserver: reserver)
      @res.save(validate: false)
      @mail = UserMailer.overdue_checked_in_fine(@res).deliver
    end
    it_behaves_like 'contains reservation'
    it_behaves_like 'valid user email'
  end
  describe 'overdue_checked_in_fine with no fine' do
    before do
      @em = FactoryGirl.create(:equipment_model, late_fee: 0)
      @res = FactoryGirl.build(:checked_in_reservation,
                               reserver: reserver,
                               equipment_model_id: @em.id)
      @res.save(validate: false)
      @mail = UserMailer.overdue_checked_in_fine(@res).deliver
    end
    it 'doesn\'t send an email' do
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end
  describe 'reservation_confirmation' do
    before do
      @res = [] << FactoryGirl.create(:valid_reservation, reserver: reserver)
      @mail = UserMailer.reservation_confirmation(@res).deliver
    end
    it 'has reservation link' do
      # custom test because @res is an array
      # body contains link to the reservation,
      expect(@mail.body).to \
        include("<a href=\"http://0.0.0.0:3000/reservations/#{@res[0].id}\"")
    end
    it_behaves_like 'valid user email'
  end
  describe 'upcoming_checkin_notification' do
    before do
      @res = FactoryGirl.create(:valid_reservation, reserver: reserver)
      @mail = UserMailer.upcoming_checkin_notification(@res).deliver
    end
    it_behaves_like 'valid user email'
  end
end