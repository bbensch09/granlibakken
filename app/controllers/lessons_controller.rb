class LessonsController < ApplicationController
  respond_to :html
  skip_before_action :authenticate_user!, only: [:new, :new_specific_slot, :new_request, :create, :complete, :confirm_reservation, :update, :show, :edit]
  before_action :confirm_admin_permissions, except: [:schedule, :book_product, :new, :new_request, :new_specific_slot, :create, :complete, :edit, :update, :confirm_reservation, :show, :index]
  before_action :save_lesson_params_and_redirect, only: [:create]
  before_action :create_lesson_from_session, only: [:create]

  def assign_to_section
    puts "the params are #{params}"
    @lesson = Lesson.find(params[:lesson_id])
    @section = Section.find(params[:section_id])
    @lesson.section_id = @section.id
    @lesson.save!
    redirect_to "/schedule-filtered?utf8=✓&search_date=#{@section.parametized_date}&age_type=#{@section.age_group}"
  end

  def admin_index
    @lessons_to_export = Lesson.where(state:"booked")
    @lessons = Lesson.all.to_a.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed? || lesson.finalizing? || lesson.booked? || lesson.payment_complete? || lesson.ready_to_book? || lesson.waiting_for_review?}
    @lessons = @lessons.sort! { |a,b| a.lesson_time.date <=> b.lesson_time.date }
    respond_to do |format|
          format.html {render 'admin_index'}
          format.csv { send_data @lessons_to_export.to_csv, filename: "group-lessons-export-#{Date.today}.csv" }
    end
  end

  def daily_roster
    @lessons_to_export = Lesson.all.select{|lesson| lesson.state == "booked" && lesson.date == Date.today}
    @lessons = Lesson.all.select{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed? || lesson.finalizing? || lesson.booked? || lesson.payment_complete? || lesson.waiting_for_review?}
    @lessons = @lessons.select{ |lesson| lesson.date == Date.today}
    @lessons = @lessons.sort! { |a,b| a.lesson_time.date <=> b.lesson_time.date }
    respond_to do |format|
          format.html {render 'admin_index'}
          format.csv { send_data @lessons_to_export.to_csv, filename: "group-lessons-export-#{Date.today}.csv" }
    end
  end

  def admin_index_all
    @lessons_to_export = Lesson.where(state:"booked")
    @lessons = Lesson.all.to_a
    @lessons = @lessons.sort! { |a,b| a.lesson_time.date <=> b.lesson_time.date }
    respond_to do |format|
          format.html {render 'admin_index'}
          format.csv { send_data @lessons_to_export.to_csv, filename: "group-lessons-export-#{Date.today}.csv" }
    end
  end  

  def schedule
      # @lessons = Lesson.all.to_a.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed?}
      render 'schedule_new'
  end

  def assign_all_instructors_to_sections
    Lesson.assign_all_instructors_to_sections
    redirect_to '/sections'
  end

  def filtered_lesson_reservations
    search_params = {email: params[:search], name: params[:name], date: params[:date], gear:params[:gear]}
    puts "!!!!! the search_params are: #{search_params}"
    @lessons = Lesson.all
    if params[:date] != ""      
        puts "!!!filter by date.  param is #{params['date']}"
        @lessons = @lessons.to_a.keep_if{|lesson| lesson.date.to_s == params[:date]}  
        puts "found #{@lessons.count} mactching lessons"
    end
    if params[:name] != ""
        puts "!!!filter by name.  param is #{params['name']}"
        @lessons = @lessons.to_a.keep_if{|lesson| lesson.name == params[:name]}  
        puts "found #{@lessons.count} mactching lessons"
    end 
    if params['email'] != ""
        puts "!!!filter by email. email param is #{params['email']}"
        @lessons = @lessons.to_a.keep_if{|lesson| lesson.email == params[:email]}  
        # @lessons = Lesson.all.select{|lesson| lesson.email == 'brian@snowschoolers.com'}  
        puts "found #{@lessons.count} mactching lessons"
    end  
    if params['gear'] == "on"
        puts "!!!filtering for resrations with rentals."
        @lessons = @lessons.to_a.keep_if{|lesson| lesson.gear == true}  
        puts "found #{@lessons.count} mactching lessons"
    end  
    puts "!!!! @lessons.count is #{@lessons.count}"
    @lessons = @lessons.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed? || lesson.finalizing? || lesson.booked? || lesson.payment_complete? || lesson.ready_to_book? || lesson.waiting_for_review?}
    render 'admin_index'
  end

  def filtered_schedule_results
      date = params[:date]
      puts "!!! filtere date: #{date}"
      all_days = Section.select(:date).distinct
      @days = all_days.to_a.keep_if{|a| a.date.to_s == params[:date]}
      puts "!!!filter by date.  param is #{params['date']}"
      @lessons = Lesson.all.to_a.keep_if{|lesson| lesson.date.to_s == params[:date]}       
        puts "found #{@lessons.count} mactching lessons"
      @new_date = Section.new
      render 'index'
  end

  def index
    if current_user && current_user.email == 'brian@snowschoolers.com' || current_user.user_type == 'Ski Area Partner' || current_user.user_type == "Granlibakken Employee"
      all_days = Section.select(:date).distinct.sort{|a,b| a.date <=> b.date}
      @days = all_days.keep_if{|a| a.date >= Date.today}
      @days = @days.first(30)
      @new_date = Section.new
      @lessons = Lesson.first(100).to_a.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed?}
      @lessons.sort! { |a,b| a.lesson_time.date <=> b.lesson_time.date }
      if session[:notice]
        flash.now[:notice] = session[:notice]
      end
    elsif current_user
        @lessons = Lesson.where(requester_id:current_user.id)
        @lessons = @lessons.to_a.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed?}
        render 'student_index'
    end
  end

  def send_reminder_sms_to_instructor
    @lesson = Lesson.find(params[:id])
    if @lesson.instructor.nil?
      puts "!!!instructor = nil"
      instructor = Instructor.find(params[:instructor_id])
      @lesson.send_manual_sms_request_to_instructor(instructor)
    elsif @lesson.completable?
      puts "!!!instructor found, lesson is compeltable"
      @lesson.send_sms_reminder_to_instructor_complete_lessons
    end
    redirect_to @lesson
  end

  def sugarbowl
    @lesson = Lesson.new
    @promo_location = 9
    @lesson_time = @lesson.lesson_time
    render 'new'
  end

  def homewood
    @lesson = Lesson.new
    @promo_location = 6
    @lesson_time = @lesson.lesson_time
    render 'new'
  end

  def book_product
    @lesson = Lesson.new
    @promo_location = Product.find(params[:id]).location.id
    @slot = Product.find(params[:id]).name.to_s
    puts "The selected slot is #{@slot}"
    @lesson_time = @lesson.lesson_time
    render 'new'
  end

  def new
    @lesson = Lesson.new
    @promo_location = session[:lesson].nil? ? nil : session[:lesson]["requested_location"]
    @product_name = session[:lesson].nil? ? nil : session[:lesson]["product_name"]
    @activity = session[:lesson].nil? ? nil : session[:lesson]["activity"]
    @slot = (session[:lesson].nil? || session[:lesson]["lesson_time"].nil?) ? nil : session[:lesson]["lesson_time"]["slot"]
    @date = (session[:lesson].nil? || session[:lesson]["lesson_time"].nil?)  ? nil : session[:lesson]["lesson_time"]["date"]
    @lesson_time = @lesson.lesson_time
    GoogleAnalyticsApi.new.event('lesson-requests', 'load-lessons-new')
  end

  # def new_backup_oct22
  #   @lesson = Lesson.new
  # end

  def new_request
    puts "!!! processing instructor request; Session variable is: #{session[:lesson]}"
    @lesson = Lesson.new
    @promo_location = session[:lesson].nil? ? nil : session[:lesson]["requested_location"]
    @activity = session[:lesson].nil? ? nil : session[:lesson]["activity"]
    @slot = (session[:lesson].nil? || session[:lesson]["lesson_time"].nil?) ? nil : session[:lesson]["lesson_time"]["slot"]
    @date = (session[:lesson].nil? || session[:lesson]["lesson_time"].nil?)  ? nil : session[:lesson]["lesson_time"]["date"]
    @instructor_requested = Instructor.find(params[:id]).id
    @lesson_time = @lesson.lesson_time
    GoogleAnalyticsApi.new.event('lesson-requests', 'load-lessons-new-private-request')
    render 'new'
  end

  def new_specific_slot
    puts "!!!!session data includes: #{session[:activity]}"
    @lesson = Lesson.new
    @lesson.activity = session[:activity]
    @lesson.requested_location = 24
    @activity = session[:lesson].nil? ? nil : session[:lesson]["activity"]
    @slot = (session[:lesson].nil? || session[:lesson]["lesson_time"].nil?) ? nil : session[:lesson]["lesson_time"]["slot"]
    @date = (session[:lesson].nil? || session[:lesson]["lesson_time"].nil?)  ? nil : session[:lesson]["lesson_time"]["date"]    
    @lesson.lesson_time = LessonTime.find_or_create_by(date:session[:date],slot:session[:slot])
    @lesson.save
    GoogleAnalyticsApi.new.event('lesson-requests', 'load-full-form')
    render 'complete'
  end

  def create
      puts "!!!!!!!!! Lesson params are \n #{params}"
      create_lesson_and_redirect
  end

  def complete
    @lesson = Lesson.find(params[:id])
    @lesson_time = @lesson.lesson_time
    @date = @lesson_time.date
    @slot = @lesson_time.slot
    @product_name = @lesson.product_name
    @state = 'booked'
    GoogleAnalyticsApi.new.event('lesson-requests', 'load-full-form')
    flash.now[:notice] = "You're almost there! We just need a few more details."
    flash[:complete_form] = 'TRUE'
  end

  def edit
    @lesson = Lesson.find(params[:id])
    @lesson_time = @lesson.lesson_time
    @slot = @lesson.lesson_time.slot
    @date = @lesson.lesson_time.date
    @state = @lesson.instructor ? 'pending instructor' : @lesson.state
  end

  def reissue_invoice
    @lesson = Lesson.find(params[:id])
    @lesson_time = @lesson.lesson_time    
    @lesson.state == "ready_to_book"
    @lesson.deposit_status = nil
    @lesson.save
    render 'edit'
  end

  def issue_refund
    @lesson = Lesson.find(params[:id])
    @lesson_time = @lesson.lesson_time    
    session[:refund] = true
    render 'edit'
  end

  def issue_full_refund
    @lesson = Lesson.find(params[:id])
    @lesson.state = 'Canceled - full refund issued.'
    @lesson.save 
    session[:refund] = nil
    redirect_to @lesson 
  end

  def confirm_reservation
    @lesson = Lesson.find(params[:id])
    if @lesson.deposit_status != 'confirmed'
        @amount = @lesson.price.to_i
          customer = Stripe::Customer.create(
            :email => params[:stripeEmail],
            :source  => params[:stripeToken]
          )
          charge = Stripe::Charge.create(
            :customer    => customer.id,
            :amount      => @amount*100,
            :description => 'Lesson reservation deposit',
            :currency    => 'usd'
          )
        @lesson.deposit_status = 'confirmed'
        if @lesson.is_gift_voucher?
          @lesson.state = 'gift_voucher_reserved'
        else
          @lesson.state = 'booked'
        end
        puts "!!!!!About to save state & deposit status after processing lessons#update"
        @lesson.save
      GoogleAnalyticsApi.new.event('lesson-requests', 'deposit-submitted', params[:ga_client_id])
      LessonMailer.send_lesson_booking_notification(@lesson).deliver
      flash[:notice] = 'Thank you, your lesson request was successful. You will receive an email notification momentarily. If you have any questions about your reservation, please email frontdesk@granlibakken.com.'
      flash[:conversion] = 'TRUE'
      puts "!!!!!!!! Lesson deposit successfully charged"
    end
    redirect_to @lesson
  end

  def update
    @lesson = Lesson.find(params[:id])
    @original_lesson = @lesson.dup
    @lesson.assign_attributes(lesson_params)
    @lesson.lesson_time = @lesson_time = LessonTime.find_or_create_by(lesson_time_params)
    unless current_user && current_user.user_type == "Granlibakken Employee"
      @lesson.requester = current_user
    end
    if @lesson.is_gift_voucher? && current_user.user_type == "Granlibakken Employee"
      @user = User.new({
          email: @lesson.gift_recipient_email,
          password: 'sstemp2017',
          user_type: "Student",
          name: "#{@lesson.gift_recipient_name}"
        })
      @user.skip_confirmation!
      @user.save!
      @lesson.requester_id = User.last.id
      puts "!!!! admin is creating a new user to receive a gift voucher; new user need not be confirmed"
    end
    if current_user && @lesson.is_gift_voucher? && current_user.email == @lesson.gift_recipient_email.downcase
      @lesson.state = 'booked'
      puts "!!!! marking voucher as booked & sending SMS to instructors"
    end
    unless @lesson.deposit_status == 'confirmed'
      @lesson.state = 'ready_to_book'
    end
    if @lesson.save
      GoogleAnalyticsApi.new.event('lesson-requests', 'full_form-updated', params[:ga_client_id])
      @user_email = current_user ? current_user.email : "unknown"
      if @lesson.state == "ready_to_book"
      # LessonMailer.notify_admin_lesson_full_form_updated(@lesson, @user_email).deliver
      end
      puts "!!!! Lesson update saved; lesson state is #{@lesson.state}"
    else
      determine_update_state
      puts "!!!!!Lesson NOT saved, update notices determined by 'determine update state' method...?"
    end
    redirect_to @lesson
  end

  def show
    @lesson = Lesson.find(params[:id])
    if @lesson.state == "ready_to_book"
      GoogleAnalyticsApi.new.event('lesson-requests', 'ready-for-deposit')
    end
    if @lesson.date <= Date.today && @lesson.review.nil? && @lesson.deposit_status == 'confirmed'
      @lesson.state = 'Lesson complete, waiting for review.'
      @lesson.save
      puts "!!! detected that previously booked lesson should now be complete, now ready for review"
    end
  end

  def destroy
    @lesson = Lesson.find(params[:id])
    @lesson.update(state: 'canceled')
    send_cancellation_email_to_instructor
    flash[:notice] = 'Your lesson has been canceled.'
    redirect_to lessons_admin_index_path
  end

  def admin_reconfirm_state
    @lesson = Lesson.find(params[:id])
    @lesson.state = 'confirmed'
    @lesson.save
    redirect_to @lesson
  end

  def set_instructor
    @lesson = Lesson.find(params[:id])
    @lesson.instructor_id = current_user.instructor.id
    @lesson.state = 'confirmed'
    if @lesson.save
    LessonAction.create!({
      lesson_id: @lesson.id,
      instructor_id: current_user.instructor.id,
      action: "Accept"
      })
    # LessonMailer.send_lesson_confirmation(@lesson).deliver
    @lesson.send_sms_to_requester
    redirect_to @lesson
    else
     redirect_to @lesson, notice: "Error: could not accept lesson. #{@lesson.errors.full_messages}"
    end
  end

  def decline_instructor
    @lesson = Lesson.find(params[:id])
    LessonAction.create!({
      lesson_id: @lesson.id,
      instructor_id: current_user.instructor.id,
      action: "Decline"
      })
    if @lesson.instructor
        @lesson.send_sms_to_admin_1to1_request_failed
        @lesson.update(state: "requested instructor not available")
      elsif @lesson.available_instructors.count >= 1
      @lesson.send_sms_to_instructor
      else
      @lesson.send_sms_to_admin
    end
    flash[:notice] = 'You have declined the request; another instructor has now been notified.'
    # LessonMailer.send_lesson_confirmation(@lesson).deliver
    redirect_to @lesson
  end

  def remove_instructor
    puts "the params are {#{params}"
    @lesson = Lesson.find(params[:id])
    @lesson.instructor = nil
    @lesson.update(state: 'seeking replacement instructor')
    @lesson.send_sms_to_requester
    if @lesson.available_instructors?
      @lesson.send_sms_to_instructor
      else
      @lesson.send_sms_to_admin
    end
    send_instructor_cancellation_emails
    redirect_to @lesson
  end

  def mark_lesson_complete
    puts "the params are {#{params}"
    @lesson = Lesson.find(params[:id])
    @lesson.state = 'finalizing'
    @lesson.save
    redirect_to @lesson
  end

  def confirm_lesson_time
    @lesson = Lesson.find(params[:id])
    if valid_duration_params?
      @lesson.update(lesson_params.merge(state: 'finalizing payment & reviews'))
      @lesson.state = @lesson.valid? ? 'finalizing payment & reviews' : 'confirmed'
      @lesson.send_sms_to_requester
      # LessonMailer.send_payment_email_to_requester(@lesson).deliver
    end
    respond_with @lesson, action: :show
  end

  private

  def valid_duration_params?
     if params[:lesson][:actual_start_time].length == 0  || params[:lesson][:actual_end_time].length == 0
      flash[:alert] = "Please confirm start & end time, as well as lesson duration."
      return false
    else
      session[:lesson] = params[:lesson]
      return true
    end
  end

  def validate_new_lesson_params
    if params[:lesson].nil? ||  params[:lesson] == "" || params[:lesson][:product_name].nil? || params[:lesson][:product_name] == "" || params[:lesson][:activity].nil? ||  params[:lesson][:lesson_time][:date].length < 10
      session[:lesson] = params[:lesson]
      flash[:alert] = "Please first select a lesson type, date, and time."
      redirect_to new_lesson_path
    else
      session[:lesson] = params[:lesson]
    end
  end

  def save_lesson_params_and_redirect
    puts "!!!!! params are below: #{params}"
    puts params[:lesson][:activity]
    puts params[:lesson][:product_name]
    puts params[:lesson][:lesson_time][:date]
    puts params[:lesson][:lesson_time][:slot]
    puts "!!!!!!! end params"
    validate_new_lesson_params
  end

  def create_lesson_from_session
  #   unless params["commit"] == "request-an-instructor"
      create_lesson_and_redirect
  #     session[:lesson] = params[:lesson]
  #     puts "!!!!! params are: #{params[:lesson]}"
  #   end
  end

  def create_lesson_and_redirect
    @lesson = Lesson.new(lesson_params)
    puts "!!!!!!params are: #{lesson_params}"
    @lesson.requester = current_user
    @lesson.requested_location = 24
    @lesson.lesson_time = @lesson_time = LessonTime.find_or_create_by(lesson_time_params)
    @lesson.product_id = Product.where(name:params[:product_name]).first
    if @lesson.save
      GoogleAnalyticsApi.new.event('lesson-requests', 'request-initiated', params[:ga_client_id])
      @user_email = current_user ? current_user.email : "unknown"
      # LessonMailer.notify_admin_lesson_request_begun(@lesson, @user_email).deliver
      redirect_to complete_lesson_path(@lesson)
      else
        @activity = session[:lesson].nil? ? nil : session[:lesson]["activity"]
        @slot = session[:lesson].nil? ? nil : session[:lesson]["lesson_time"]["slot"]
        @date = session[:lesson].nil? ? nil : session[:lesson]["lesson_time"]["date"]
        render 'new'
    end
  end

  def send_cancellation_email_to_instructor
    if @lesson.instructor.present?
      # LessonMailer.send_cancellation_email_to_instructor(@lesson).deliver
    end
  end

  def send_instructor_cancellation_emails
    # LessonMailer.send_lesson_request_to_new_instructors(@lesson, @lesson.instructor).deliver if @lesson.available_instructors?
    # LessonMailer.inform_requester_of_instructor_cancellation(@lesson, @lesson.available_instructors?).deliver
    # LessonMailer.send_cancellation_confirmation(@lesson).deliver
  end

  def send_lesson_update_notice_to_instructor
    return unless @lesson.deposit_status == 'confirmed'
    if @lesson.instructor.present?
      changed_attributes = @lesson.get_changed_attributes(@original_lesson)
      return unless changed_attributes.any?
      return unless current_user.email != "brian@snowschoolers.com"
      # LessonMailer.send_lesson_update_notice_to_instructor(@original_lesson, @lesson, changed_attributes).deliver
    end
  end

  def check_user_permissions
    return unless @lesson.guest_email.nil?
    # FEB7 - disabling permission check to allow non-signed-in users to resume their reservation
    # unless (current_user && current_user == @lesson.requester || (current_user && current_user.instructor && current_user.instructor.status == "Active") || @lesson.requester.nil? || (current_user.nil? && @lesson.requester.email == "brian@snowschoolers.com") || (current_user && (current_user.user_type == "Ski Area Partner" || current_user.user_type == "Granlibakken Employee"))   )
      # puts "!!!!!!! INSUFFICIENT PERMISSIONS"
      # flash[:alert] = "You do not have access to this page."
      # redirect_to root_path
    # end
  end

  def determine_update_state
    @lesson.state = 'new' unless params[:lesson][:terms_accepted] == '1'
    if @lesson.deposit_status == 'confirmed' && @lesson.is_gift_voucher == false
      flash.now[:notice] = "Your lesson deposit has been recorded, but your lesson reservation is incomplete. Please fix the fields below and resubmit."
      @lesson.state = 'booked'
    elsif @lesson.deposit_status == 'confirmed' && @lesson.is_gift_voucher == true
      flash.now[:notice] = "Lesson voucher information has been updated."
      @lesson.state = 'booked_voucher'
    end
    @lesson.save
    @state = params[:lesson][:state]
  end

  def lesson_params
    params.require(:lesson).permit(:activity, :phone_number, :requested_location, :state, :student_count, :gear, :lift_ticket_status, :objectives, :duration, :ability_level, :start_time, :actual_start_time, :actual_end_time, :actual_duration, :terms_accepted, :deposit_status, :public_feedback_for_student, :private_feedback_for_student, :instructor_id, :focus_area, :requester_id, :guest_email, :how_did_you_hear, :num_days, :lesson_price, :requester_name, :is_gift_voucher, :includes_lift_or_rental_package, :package_info, :gift_recipient_email, :gift_recipient_name, :lesson_cost, :non_lesson_cost, :product_id, :section_id, :product_name,
      students_attributes: [:id, :name, :age_range, :gender, :relationship_to_requester, :lesson_history, :requester_id, :most_recent_experience, :most_recent_level, :other_sports_experience, :experience, :_destroy])
  end

  def lesson_time_params
    params[:lesson].require(:lesson_time).permit(:date, :slot)
  end
end
