# frozen_string_literal: true
require 'spec_helper'

describe OrderingHelper do
  let!(:current_user) { UserMock.new }
  describe 'up' do
    it 'does not go past the first' do
      category = FactoryGirl.create(:category)
      eq_model1 = FactoryGirl.create(:equipment_model, category: category)
      eq_model2 = FactoryGirl.create(:equipment_model,
                                     category: category,
                                     ordering: 2)
      eq_model3 = FactoryGirl.create(:equipment_model,
                                     category: category,
                                     ordering: 3)
      OrderingHelper.new(eq_model1).up
      expect(eq_model1.ordering).to eq(1)
      expect(eq_model2.ordering).to eq(2)
      expect(eq_model3.ordering).to eq(3)
    end
    it 'pivots up and leaves neutral elements' do
      category = FactoryGirl.create(:category)
      eq_model1 = FactoryGirl.create(:equipment_model, category: category)
      eq_model2 = FactoryGirl.create(:equipment_model,
                                     category: category,
                                     ordering: 2)
      eq_model3 = FactoryGirl.create(:equipment_model,
                                     category: category,
                                     ordering: 3)
      OrderingHelper.new(eq_model3).up
      expect(eq_model1.reload.ordering).to eq(1)
      expect(eq_model2.reload.ordering).to eq(3)
      expect(eq_model3.reload.ordering).to eq(2)
    end
  end
  describe 'down' do
    it 'does not go past the last' do
      category = FactoryGirl.create(:category)
      eq_model1 = FactoryGirl.create(:equipment_model, category: category)
      eq_model2 = FactoryGirl.create(:equipment_model,
                                     category: category,
                                     ordering: 2)
      eq_model3 = FactoryGirl.create(:equipment_model,
                                     category: category,
                                     ordering: 3)
      OrderingHelper.new(eq_model3).down
      expect(eq_model1.ordering).to eq(1)
      expect(eq_model2.ordering).to eq(2)
      expect(eq_model3.ordering).to eq(3)
    end
    it 'pivots down and leaves neutral elements' do
      category = FactoryGirl.create(:category)
      eq_model1 = FactoryGirl.create(:equipment_model, category: category)
      eq_model2 = FactoryGirl.create(:equipment_model,
                                     category: category,
                                     ordering: 2)
      eq_model3 = FactoryGirl.create(:equipment_model,
                                     category: category,
                                     ordering: 3)
      OrderingHelper.new(eq_model1).down
      expect(eq_model1.reload.ordering).to eq(2)
      expect(eq_model2.reload.ordering).to eq(1)
      expect(eq_model3.reload.ordering).to eq(3)
    end
  end
  describe 'deactivate' do 
    it 'handles ordering on deactivation' do
      category = FactoryGirl.create(:category)
        eq_model1 = FactoryGirl.create(:equipment_model, category: category)
        eq_model2 = FactoryGirl.create(:equipment_model,
                                       category: category,
                                       ordering: 2)
        eq_model3 = FactoryGirl.create(:equipment_model,
                                       category: category,
                                       ordering: 3)
        OrderingHelper.new(eq_model2).deactivate_order
        expect(eq_model1.reload.ordering).to eq(1)
        expect(eq_model2.reload.ordering).to eq(-1)
        expect(eq_model3.reload.ordering).to eq(2)
      end
    end
end