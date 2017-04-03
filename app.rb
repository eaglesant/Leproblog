#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leproblog.db'
	@db.results_as_hash
end
before do
	init_db
end

configure do
	init_db
	@db.execute 'CREATE TABLE if not exists Posts
	(
	id           INTEGER PRIMARY KEY AUTOINCREMENT,
	created_date DATE,
	content      TEXT
	)'
end

get '/' do
	erb :index		
end
get '/new' do
	erb :new
end
post '/new' do
	@post = params[:content]

	if @post.length < 1
		@error = "Enter text"
		return erb :new
	end

	@db.execute 'insert into Posts (created_date, content) values (datetime(), ?)', [@post]

	erb "You typed: #{@post}"
end