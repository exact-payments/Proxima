require 'spec_helper'


describe Proxima::Model do

  before do
    class User < Proxima::Model
      api Proxima::Api.new 'http://api.users.net'

      base_uri -> (r) { "/account/#{r[:account_id]}/user" }

      attribute :name,       'name'
      attribute :account_id, 'account'
    end
  end


  describe '.api' do

    before :context do
      TODOS_API = Proxima::Api.new 'http://api.todos.net'
    end

    it 'sets @api if an api is given and returns it' do
      class Todo < Proxima::Model
        api TODOS_API
      end
      expect(Todo.instance_variable_get(:@api)).to equal(TODOS_API)
    end

    it 'returns the api if no api is given' do
      class Todo < Proxima::Model
        api TODOS_API
      end
      expect(Todo.api).to equal(TODOS_API)
    end
  end


  describe '.new_record?' do

    it 'returns true if the record contains an id' do
      user = User.new id: 1, name: 'Robert'
      expect(user.new_record?).to eql(false)
    end

    it 'returns false if the record does not contain an id' do
      user = User.new name: 'Robert'
      expect(user.new_record?).to eql(true)
    end
  end


  describe '.create' do

    it 'creates an instance from a record and saves it then returns the model' do
      mock_response = RestClient::Response.new '{ "name": "Robert", "account": 1 }'
      mock_response.instance_variable_set :@code, 201

      expect_any_instance_of(Proxima::Api).to(
        receive(:post)
          .with("/account/1/user", { json: { "name" => "Robert", "account" => 1 }})
          .and_return(mock_response)
      )

      expect(User.create name: 'Robert', account_id: 1).to be_a(User)
    end
  end


  # describe '.find' do
  #
  #   it 'requests '
  # end


  describe '#initialize' do

    it 'sets @new_record to false if the record contains an id' do
      user = User.new id: 1, name: 'Robert'
      expect(user.instance_variable_get(:@new_record)).to eql(false)
    end

    it 'sets @new_record to true if the record does not contain an id' do
      user = User.new name: 'Robert'
      expect(user.instance_variable_get(:@new_record)).to eql(true)
    end
  end
end
