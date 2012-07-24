class Licensing < Padrino::Application
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers
  include WillPaginate::Sinatra::Helpers

  enable :sessions
  
  get "/" do
  	render 'index'
  end
  
get "/search" do
	require 'mapit'
	
	date_from = Date.to_mongo(Date.parse(params[:date_from])) rescue nil
	date_to = Date.to_mongo(Date.parse(params[:date_to])) rescue Date.to_mongo(Date.today)
	
	if params[:postcode] != ""
		mapit = Mapit.GetPostcode(params[:postcode])
    	EARTH_RADIUS_M = 3959
		applications = Application.where(:latlng => {'$nearSphere' => [mapit["lat"], mapit["lng"]], '$maxDistance' => Float(params[:within].to_i) / EARTH_RADIUS_M }, '$or' => [{:refval => /#{params[:search]}/i}, {:address => /#{params[:search]}/i}])
	else 	  	
		applications = Application.where('$or' => [{:refval => /#{params[:search]}/i}, {:address => /#{params[:search]}/i}])
	end
	
	if date_from != nil
		applications = applications.where(:recieveddate => {:$gte => date_from, :$lte => date_to})
	end
	
	if params[:activity] != ""
		applications = applications.where(:type => params[:activity])
	end
	
	if applications.count == 1
		@app = applications.all[0]
		render 'view'
	else
		@applications = applications.paginate({:order => :recieveddate.desc, :per_page=> 10, :page => params[:page]})
		render 'search'
	end
end
  
  get '/view/*refval' do
    refval = params[:refval].join("/")
  	@app = Application.find_by_refval(refval)
  	render 'view'
  end

  ##
  # Caching support
  #
  # register Padrino::Cache
  # enable :caching
  #
  # You can customize caching store engines:
  #
  #   set :cache, Padrino::Cache::Store::Memcache.new(::Memcached.new('127.0.0.1:11211', :exception_retry_limit => 1))
  #   set :cache, Padrino::Cache::Store::Memcache.new(::Dalli::Client.new('127.0.0.1:11211', :exception_retry_limit => 1))
  #   set :cache, Padrino::Cache::Store::Redis.new(::Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0))
  #   set :cache, Padrino::Cache::Store::Memory.new(50)
  #   set :cache, Padrino::Cache::Store::File.new(Padrino.root('tmp', app_name.to_s, 'cache')) # default choice
  #

  ##
  # Application configuration options
  #
  # set :raise_errors, true       # Raise exceptions (will stop application) (default for test)
  # set :dump_errors, true        # Exception backtraces are written to STDERR (default for production/development)
  # set :show_exceptions, true    # Shows a stack trace in browser (default for development)
  # set :logging, true            # Logging in STDOUT for development and file for production (default only for development)
  # set :public_folder, "foo/bar" # Location for static assets (default root/public)
  # set :reload, false            # Reload application files (default in development)
  # set :default_builder, "foo"   # Set a custom form builder (default 'StandardFormBuilder')
  # set :locale_path, "bar"       # Set path for I18n translations (default your_app/locales)
  # disable :sessions             # Disabled sessions by default (enable if needed)
  # disable :flash                # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
  # layout  :my_layout            # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
  #

  ##
  # You can configure for a specified environment like:
  #
  #   configure :development do
  #     set :foo, :bar
  #     disable :asset_stamp # no asset timestamping for dev
  #   end
  #

  ##
  # You can manage errors like:
  #
  #   error 404 do
  #     render 'errors/404'
  #   end
  #
  #   error 505 do
  #     render 'errors/505'
  #   end
  #
end
