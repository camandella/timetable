require 'rails_helper'

RSpec.describe SpectaclesController, type: :controller do

  describe 'GET index' do

    let!(:july_spectacle) { Spectacle.create(name: 'july', range: Date.parse('01.07.2020') .. Date.parse('31.07.2020')) }
    let!(:june_spectacle) { Spectacle.create(name: 'june', range: Date.parse('01.06.2020') .. Date.parse('30.06.2020')) }
    let(:spectacles) { JSON.parse(response.body)['spectacles'] }

    context 'There are two spectacles: july and june; reverse order must be in response' do

      before(:each) { get :index }

      it 'Should be ok' do
        expect(response.status).to eq 200
      end

      it 'Count is 2' do
        expect(spectacles.count).to eq 2
      end

      it 'First is june' do
        expect(spectacles[0]).to eq june_spectacle.as_json
      end

      it 'Second is july' do
        expect(spectacles[1]).to eq july_spectacle.as_json
      end

    end

  end

  describe 'POST create' do

    let!(:june_spectacle) { Spectacle.create(name: 'june', range: Date.parse('01.06.2020') .. Date.parse('30.06.2020')) }

    context 'Create july spectacle (successful)' do

      july_params = { name: 'july', start_date: '01.07.2020', finish_date: '31.07.2020' }

      context 'Check response' do

        before(:each) { post :create, params: july_params }

        it 'Should be ok' do
          expect(response.status).to eq 200
        end

        it 'Should has correct values' do
          expect(JSON.parse(response.body)['spectacle'].symbolize_keys.slice(*july_params.keys)).to eq july_params
        end

      end

      context 'Check the change in the number of records' do

        it 'Should increase by one' do
          expect { post :create, params: july_params }.to change(Spectacle, :count).by(1)
        end

      end

    end

    context 'Create summer spectacle (unsuccessful)' do

      summer_params = { name: 'summer', start_date: '01.06.2020', finish_date: '31.08.2020' }

      context 'Check response' do

        before(:each) { post :create, params: summer_params }

        it 'Should be unprocessable_entity' do
          expect(response.status).to eq 422
        end

        it 'Should has required error message' do
          expect(JSON.parse(response.body)['errors']['range']).to eq(
            [I18n.t('activerecord.errors.models.spectacle.attributes.range.crossing_ranges')]
          )
        end

      end

      context 'Check the change in the number of records' do

        it 'Should not be changed' do
          expect { post :create, params: summer_params }.not_to change(Spectacle, :count)
        end

      end

    end

  end

  describe 'DELETE destroy' do

    let!(:spectacle) { Spectacle.create(name: 'deletable_spectacle', range: Date.today .. Date.today + 1.day) }

    context 'Successful' do

      let(:delete_params) do
        { id: spectacle.id }
      end

      context 'Check response' do

        before(:each) { delete :destroy, params: delete_params }

        it 'Should be ok' do
          expect(response.status).to eq 200
        end

        it 'Should be right id' do
          expect(JSON.parse(response.body)['id']).to eq spectacle.id
        end

      end

      context 'Check the change in the number of records' do

        it 'Should decrease by one' do
          expect { delete :destroy, params: delete_params }.to change(Spectacle, :count).by(-1)
        end

      end

    end

    context 'Unsuccessful' do

      let(:delete_params) do
        { id: (Spectacle.maximum(:id) + 1) }
      end

      context 'Check response' do

        it 'Should be not_found' do
          delete :destroy, params: delete_params
          expect(response.status).to eq 404
        end

      end

      context 'Check the change in the number of records' do

        it 'Should not be changed' do
          expect { delete :destroy, params: delete_params }.not_to change(Spectacle, :count)
        end

      end

    end

  end

end
