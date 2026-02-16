get '/' do
  @notes = Note.all
  @title = 'All Notes'
  erb :home
end