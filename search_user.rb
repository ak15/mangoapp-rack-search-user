require 'rack'
require "json"
require 'mysql2'
require 'sequel'
require 'pry'

DB = Sequel.connect(adapter: :mysql2,
        database: "rack_development_database",
        host: 'localhost',
        user: 'root',
        password: "infi@123")

class SearchUser
  def call(env)
    req =  Rack::Request.new(env)
    route(req)
  end

  def search(req)
    users = DB[:users]
    user_names = users.where(Sequel.like(:name, "#{req.params['keyword']}%")).map(:name)
    [ 200, { "Content-Type" => "application/json" }, [{ users: user_names }.to_json] ]
  end

  def route(req)
    method = req.path.delete("/")
    begin
      if req.get? && self.respond_to?(method)
        setup_database
        self.send(method, req)
      else
        [404, { "Content-Type" => "application/json"}, []]
      end
    rescue
      [500, {"Content-Type" => "application/json"}, []]
    end
  end

  def setup_database
    Sequel.extension :migration, :core_extensions
    Sequel::Migrator.run(DB, "migrations")
  end
end
