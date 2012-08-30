class Licensing < Padrino::Application
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers
  include WillPaginate::Sinatra::Helpers
  
  set :delivery_method, :sendmail

  enable :sessions
  
  get "/" do
  	@alert = Alert.new
  	render 'index'
  end
  
get "/search", :provides => [:html, :json, :xml] do
	require 'mapit'
	
	if params[:search]	
		query = {'$or' => [{:refval => /#{params[:search]}/i}, {:address => /#{params[:search]}/i}]}
	else
		date_from = Date.parse(params[:date_from]).to_mongo rescue nil
		date_to = Date.parse(params[:date_to]).to_mongo rescue Date.to_mongo(Date.today)
	
		query = {}
	
		if date_from != nil
			query['$or'] = [{:receiveddate => {:$gte => date_from, :$lte => date_to}}, {'notices.receiveddate' => {:$gte => date_from, :$lte => date_to}}]
		end
		
		unless params[:postcode].blank?
			mapit = Mapit.GetPostcode(params[:postcode])
	    	EARTH_RADIUS_M = 3959
	    	query[:latlng] = {'$within' => {'$centerSphere' => [[mapit["lat"], mapit["lng"]], Float(params[:within].to_i) / EARTH_RADIUS_M ] }}
		end
		
		unless params[:activity].blank?
			query[:type] = params[:activity]
		end
		
		unless params[:location].blank?
			query[:address] = /#{params[:location]}/i
		end
	end
	
	applications = Application.where(query).limit(100000)
	
	if applications.count == 1
		@app = applications.all[0]
		redirect "/view/#{@app.refval}"
	else
		@applications = applications.paginate({:order => :receiveddate.desc, :per_page=> 10, :page => params[:page]})
		case content_type
			when :html then
				render 'search.haml'
			when :json then
				render 'search.jsonify'
			when :xml then
				render 'search.builder'
			when :rss then
				render 'search.rss.builder'
			end
	end
end
  
get '/view/*refval', :provides => [:html, :json, :xml] do
	refval = params[:refval].join("/")
	@app = Application.find_by_refval(refval)
	@comment = Comment.new
	case content_type
		when :html then
			render 'view.haml'
		when :json then
			render 'view.jsonify'
		when :xml then
			render 'view.builder'
	end
end

get 'export' do
	require "csv"
	@apps = Application.where(:type.in => ["Premises New Application", "Premises Conversion (Transition)", "Premises Variation"], :status => "Licence Issued").all
	
	@apps.each do |app|
		puts app.refval
	end
	
	render 'export.erb'
end

post 'alerts' do
	@alert = Alert.new(params[:alert])
	
	if @alert.save
		mapit = Mapit.GetPostcode(@alert.postcode)
		
		hash = Digest::SHA2.hexdigest(@alert.email)
				
		@alert.update_attributes(
			:latlng => [mapit["lat"], mapit["lng"]],
			:hash => hash,
			:lastsent => Date.today.to_mongo,
			:confirmed => false
		)
		
		@alert.save
		
		deliver(:alerts, :send_confirmation, @alert.email, @alert.radius, @alert.postcode, @alert.hash)
		
		flash[:notice] = "Your alert was created successfully. Please check your email and follow the instructions to activate your alerts."
		redirect '/'
	else
		render 'index'
	end
end

get 'activate' do
	alert = Alert.find_by_hash(params[:hash])
	alert.update_attributes(:confirmed => true)
	alert.save
	flash[:notice] = "Thank you, your alert has been activated, you will now recieve an email whenever an application is made in your area."
	redirect '/'
end

get 'remove' do
	alert = Alert.find_by_hash(params[:hash])
	if alert.nil?
		flash[:notice] = "Sorry, we could not cancel your alert. Perhaps you already cancelled it?. If you think this is our error, please email <a href='mailto:webmaster@lichfielddc.gov.uk'>webmaster@lichfielddc.gov.uk</a>"
		redirect '/'
	else
		alert.destroy
		alert.save
		flash[:notice] = "Thank you, your alert has been sucessfully removed. You will no longer receive licensing alerts from us."
		redirect '/'
	end
end

post 'comment' do
	@comment = Comment.new(params[:comment])
	logger.info params[:comment]
	if @comment.save
		deliver(:comments, :send_comments, @comment.refval,@comment.name,@comment.email,@comment.address,@comment.tel,@comment.comments)
		flash[:notice] = "Thank you, your comment has been sent."
		redirect "/view/#{@comment.refval}"
	else
		refval = params[:comment]["refval"]
		@app = Application.find_by_refval(refval)
		render "view.haml"
	end
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
