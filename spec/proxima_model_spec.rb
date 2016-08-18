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
      mock_response = RestClient::Response.new(
        '{ "name": "Robert", "account": 1 }'
      )
      mock_response.instance_variable_set :@code, 201

      expect_any_instance_of(Proxima::Api).to(
        receive(:post)
          .with("/account/1/user", { json: { "name" => "Robert", "account" => 1 }})
          .and_return(mock_response)
      )

      expect(User.create name: 'Robert', account_id: 1).to be_a(User)
    end
  end


  describe '.find' do

    it 'sends a query as a get request to the api and returns the results' do
      mock_response = RestClient::Response.new(
        '[{ "name": "Robert", "account": 1 }, ' +
        '{ "name": "Brandyn", "account": 1 }]'
      )
      mock_response.instance_variable_set :@code, 200
      mock_response.instance_variable_set :@headers, { x_total_count: 5 }

      expect_any_instance_of(Proxima::Api).to(
        receive(:get)
          .with("/account/1/user", {
            headers: { :'X-TEST' => '1' },
            query:   { 'account' => 1 }
          })
          .and_return(mock_response)
      )
      users = User.find(
        { account_id: 1 },
        { headers: { 'X-TEST': '1' } }
      )

      users.each do |user|
        expect(user).to be_a(User)
      end

      expect(users[0].name).to eql('Robert')
      expect(users[0].account_id).to equal(1)
      expect(users[1].name).to eql('Brandyn')
      expect(users[1].account_id).to equal(1)
    end
  end


  describe '.find_one' do

    it 'sends a query as a get request to the api and returns the first result' do
      mock_response = RestClient::Response.new '[{ "name": "Robert", "account": 1 }]'
      mock_response.instance_variable_set :@code, 200
      mock_response.instance_variable_set :@headers, { x_total_count: 5 }

      expect_any_instance_of(Proxima::Api).to(
        receive(:get)
          .with("/account/1/user", {
            headers: { :'X-TEST' => '1' },
            query:   { '$limit' => 1, 'account' => 1 }
          })
          .and_return(mock_response)
      )
      user = User.find_one(
        { account_id: 1 },
        { headers: { 'X-TEST': '1' } }
      )

      expect(user).to be_a(User)
      expect(user.name).to eql('Robert')
      expect(user.account_id).to equal(1)
    end
  end


  describe '.count' do

    it 'sends a query as a get request to the api and returns the total count' do
      mock_response = RestClient::Response.new '[]'
      mock_response.instance_variable_set :@code, 200
      mock_response.instance_variable_set :@headers, { x_total_count: 5 }

      expect_any_instance_of(Proxima::Api).to(
        receive(:get)
          .with("/account/1/user", {
            headers: { :'X-TEST' => '1' },
            query:   { '$limit' => 0, 'account' => 1 }
          })
          .and_return(mock_response)
      )
      user_count = User.count(
        { account_id: 1 },
        { headers: { 'X-TEST': '1' } }
      )

      expect(user_count).to equal(5)
    end
  end


  describe '.find_by_id' do

    it 'sends a query as a get request to the api and returns the first result' do
      mock_response = RestClient::Response.new '{ "name": "Robert", "account": 1 }'
      mock_response.instance_variable_set :@code, 200
      mock_response.instance_variable_set :@headers, { x_total_count: 5 }

      expect_any_instance_of(Proxima::Api).to(
        receive(:get)
          .with("/account/1/user/1", { headers: { :'X-TEST' => '1' } })
          .and_return(mock_response)
      )
      user = User.find_by_id('1', { account_id: 1 }, { headers: { 'X-TEST': '1' } })

      expect(user).to be_a(User)
      expect(user.name).to eql('Robert')
      expect(user.account_id).to equal(1)
    end
  end


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


  # describe '#persisted?' do
  #
  # end
end
