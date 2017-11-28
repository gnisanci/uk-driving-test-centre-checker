require 'capybara/poltergeist'
require 'launchy'
require 'capybara-screenshot'

Capybara.register_driver(:poltergeist) { |app| Capybara::Poltergeist::Driver.new(app, js_errors: false) }
Capybara.save_path = "screenshots"
Capybara::Screenshot.autosave_on_failure = true
Capybara.default_driver = :poltergeist

session=Capybara.current_session

# Fill this variables with your data
licence_no=''		#e.g. 'JAMES123456J99XZ'
test_ref_no=''		#e.g. '12345678'
test_month=''  		#e.g. '/12/2017'
test_location='' 	#e.g. 'N4'

if licence_no.empty? or test_ref_no.empty? or test_month.empty? or test_location.empty?
  puts "License no, test reference no, desired test month or location is empty. Fill them in source code!"  
  exit(-1)
end

# Clean old screenshots
dir_path = 'screenshots';
Dir.foreach(dir_path) {|f| fn = File.join(dir_path, f); File.delete(fn) if f != '.' && f != '..'}

session.visit "https://driverpracticaltest.direct.gov.uk/login"

if !session.has_content?("Enter details below to access your booking")
  puts "Site not working!"
  session.save_and_open_screenshot(nil, :full => true)
  exit(-1)
end

if session.has_content?("Get a new challenge")
  puts "Login asking for captcha!"  
  session.save_and_open_screenshot(nil, :full => true)
  exit(-1)
end

Signal.trap('INT') { throw :sigint }

begin
	session.fill_in('driving-licence-number', with: licence_no)
	session.fill_in('application-reference-number', with: test_ref_no)
	session.click_on('booking-login')
	
	session.click_on('test-centre-change')
	session.fill_in('test-centres-input', with: test_location)
	session.find('#test-centres-submit').trigger('click')	
	# session.click_link('fetch-more-centres')

	#while !session.has_content?("/12/2017") or !session.has_content?("/11/2017") do
	while !session.has_content?(test_month) do	
		sleep 50		
		session.fill_in('test-centres-input', with: test_location)
		session.find('#test-centres-submit').trigger('click')						
	end

	# session.save_and_open_screenshot(nil, :full => true)

catch :sigint
    puts "Exiting"
rescue Exception => e 	
	session.save_and_open_screenshot(nil, :full => true)
	puts e.message  
  	puts e.backtrace.inspect
end

	session.visit "https://driverpracticaltest.direct.gov.uk/manage"
	session.click_link('Sign out')
	session.save_and_open_screenshot(nil, :full => true)

