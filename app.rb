#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leproblog.db'
	@db.results_as_hash = true
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

	@db.execute 'CREATE TABLE if not exists Comments
	(
	id           INTEGER PRIMARY KEY AUTOINCREMENT,
	created_date DATE,
	content      TEXT,
	post_id 	 INTEGER
	)'
end

get '/' do
	@results = @db.execute 'select * from Posts order by id desc'
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

	redirect to '/'
end

get '/post/:post_id' do
	post_id = params[:post_id]

	row = @db.execute 'select * from Posts where id = ?', [post_id]
	@result = row[0]

	erb :details
end
post '/post/:post_id' do
	post_id = params[:post_id]
	@comment = params[:comment]

	@db.execute 'insert into Comments 
		 ( 
			 content,
			 created_date,
			 post_id
		 )
	 		values 
	 	 (
		 	 ?,
		 	 datetime(),
		 	 ?
	 	  )', [@comment, post_id]

	redirect to('/post/' + post_id)
end