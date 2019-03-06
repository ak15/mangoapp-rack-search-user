require_relative "search_user"
use Rack::Reloader, 0

use Rack::Auth::Basic do |username, password|
  username == "mangoapp"
  password == "secret"
end
run SearchUser.new
