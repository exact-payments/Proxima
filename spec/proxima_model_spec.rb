require 'spec_helper'


describe Proxima::Model do

  before do
    class User < Proxima::Model
      api Proxima::Api.new 'http://api.users.net'

      base_uri -> (r) { "/account/#{r[:account_id]}/user" }

      attribute :id,         '_id'
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

    it 'returns the value of @new_record' do
      user = User.new name: 'Robert'
      user.instance_variable_set :@new_record, false
      expect(user.new_record?).to eql(false)
    end
  end


  describe '.create' do

    it 'creates an instance from a record and saves it then returns the model' do
      mock_response = double('Response')
      expect(mock_response).to receive(:code).and_return 201
      expect(mock_response).to receive(:body).and_return(
        '{ "_id": "1", "name": "Robert", "account": 1 }'
      )

      expect_any_instance_of(Proxima::Api).to(
        receive(:post)
          .with("/account/1/user", { json: { "name" => "Robert", "account" => 1 }})
          .and_return(mock_response)
      )

      user = User.create name: 'Robert', account_id: 1
      expect(user).to be_a(User)
      expect(user.id).to eql('1')
    end
  end


  describe '.find' do

    it 'sends a query as a get request to the api and returns the results' do
      mock_response = double('Response')
      expect(mock_response).to receive(:code).and_return 200
      expect(mock_response).to receive(:body).and_return(
        '[{ "name": "Robert", "account": 1 }, ' +
        '{ "name": "Brandyn", "account": 1 }]'
      )

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
        {},
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
      mock_response = double('Response')
      expect(mock_response).to receive(:code).and_return 200
      expect(mock_response).to receive(:body).and_return '[{ "name": "Robert", "account": 1 }]'

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
        {},
        { headers: { 'X-TEST': '1' } }
      )

      expect(user).to be_a(User)
      expect(user.name).to eql('Robert')
      expect(user.account_id).to equal(1)
    end
  end


  describe '.count' do

    it 'sends a query as a get request to the api and returns the total count' do
      mock_response = double('Response')
      expect(mock_response).to receive(:code).and_return 200
      expect(mock_response).to receive(:headers).and_return x_total_count: 5

      expect_any_instance_of(Proxima::Api).to(
        receive(:get)
          .with("/account/1/user", {
            headers: { :'X-TEST' => '1' },
            query:   { '$limit' => 0 }
          })
          .and_return(mock_response)
      )
      user_count = User.count(
        {},
        { account_id: 1 },
        { headers: { 'X-TEST': '1' } }
      )

      expect(user_count).to equal(5)
    end
  end


  describe '.find_by_id' do

    it 'sends a query as a get request to the api and returns the first result' do
      mock_response = double('Response')
      expect(mock_response).to receive(:code).and_return 200
      expect(mock_response).to receive(:body).and_return '{ "name": "Robert", "account": 1 }'

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

    it 'returns nil when an id is not informed' do
      expect_any_instance_of(Proxima::Api).not_to receive(:get)

      expect {
        User.find_by_id(nil, { account_id: 1 }, { headers: { 'X-TEST': '1' } })
      }.to raise_error(RuntimeError, 'id cannot be blank')

      expect {
        User.find_by_id('', { account_id: 1 }, { headers: { 'X-TEST': '1' } })
      }.to raise_error(RuntimeError, 'id cannot be blank')
    end
  end


  describe '#initialize' do
    it 'assigns the record to attributes and sets @new_record to true' do
      expect_any_instance_of(User).to receive(:attributes=).with name: 'Robert'
      user = User.new name: 'Robert'
      expect(user.instance_variable_get(:@new_record)).to eql(true)
    end
  end


  describe '#persisted?' do

    it 'returns the value of @persisted' do
      user = User.new name: 'Robert'
      user.instance_variable_set :@persisted, true
      expect(user.persisted?).to equal(true)
    end
  end


  describe '#persisted=' do

    it 'sets @persisted to true and calls #changes_applied if assigned true' do
      user = User.new name: 'Robert'
      expect(user).to receive(:changes_applied)
      user.persisted = true
      expect(user.instance_variable_get(:@persisted)).to equal(true)
    end

    it 'sets @persisted to false assigned false' do
      user = User.new name: 'Robert'
      expect(user).not_to receive(:changes_applied)
      user.persisted = false
      expect(user.instance_variable_get(:@persisted)).to equal(false)
    end
  end


  describe '#new_record?' do

    it 'returns the value of @new_record' do
      user = User.new name: 'Robert'
      user.instance_variable_set :@new_record, true
      expect(user.new_record?).to equal(true)
    end
  end


  describe '#new_record=' do

    it 'sets @new_record to true, @persisted to false if assigned true' do
      user = User.new name: 'Robert'
      expect(user).not_to receive(:clear_changes_information)
      user.new_record = true
      expect(user.instance_variable_get(:@new_record)).to equal(true)
      expect(user.instance_variable_get(:@persisted)).to equal(false)
    end

    it 'sets @new_record to false, @persisted to true, and calls #clear_changes_information if assigned false' do
      user = User.new name: 'Robert'
      expect(user).to receive(:clear_changes_information)
      user.new_record = false
      expect(user.instance_variable_get(:@new_record)).to equal(false)
      expect(user.instance_variable_get(:@persisted)).to equal(true)
    end
  end


  describe '.save' do

    it 'sends a post request to the api if the record is new and returns true' do
      mock_response = double('Response')
      expect(mock_response).to receive(:code).and_return 201
      expect(mock_response).to receive(:body).and_return(
        '{ "_id": "1", "name": "Robert", "account": 1 }'
      )

      expect_any_instance_of(Proxima::Api).to(
        receive(:post)
          .with("/account/1/user", { json: { "name" => "Robert", "account" => 1 }})
          .and_return(mock_response)
      )

      user = User.new name: 'Robert', account_id: 1
      expect(user.save).to equal(true)
    end

    it 'sends a put request to the api if the record is new and returns true' do
      mock_response = double('Response')
      expect(mock_response).to receive(:code).and_return 204

      expect_any_instance_of(Proxima::Api).to(
        receive(:put)
          .with("/account/1/user/1", { json: { "name" => "Marcus" }})
          .and_return(mock_response)
      )

      user = User.new id: 1, name: 'Robert', account_id: 1
      user.new_record = false
      user.name       = 'Marcus'
      expect(user.save).to equal(true)
    end

    it 'simply returns true without making a request if the document is already persisted' do
      expect_any_instance_of(Proxima::Api).not_to receive(:put)

      user = User.new id: 1, name: 'Robert', account_id: 1
      user.new_record = false
      expect(user.save).to equal(true)
    end
  end
end
