class LessonMailer < ActionMailer::Base
  default from: 'Granlibakken.com <info@snowschoolers.com>'

  def track_apply_visits(email="Unknown user")
      @email = email
      mail(to: 'brian@snowschoolers.com', subject: "Pageview at /apply - #{email}.")
  end

  def notify_admin_preseason_request(request)
      @location_name = request.name
      mail(to: 'brian@snowschoolers.com', subject: "New Preseason Resort request - #{@location_name}.")
  end

  def notify_admin_lesson_request_begun(lesson,email)
      @lesson = lesson
      @user_email = email
      mail(to: 'brian@snowschoolers.com', subject: "New Lesson Request begun - #{@lesson.date} - #{@lesson.guest_email}.")
  end

  def notify_admin_section_sold_out(section)
      @section = section
      mail(to: 'brian+chris@snowschoolers.com', cc: "Chris Parson <#{ENV['SUPERVISOR_EMAIL']}>", subject: "Section is Now Full - #{@section.date} - #{@section.slot}.")
  end

  def notify_admin_lesson_full_form_updated(lesson,email)
      @lesson = lesson
      @user_email = email
      mail(to: 'brian@snowschoolers.com', subject: "Granlibakken Lesson ready for deposit - #{@lesson.date.strftime("%b %-d")}.")
  end

  def notify_admin_beta_user(beta_user)
      @beta_user = beta_user
      mail(to: 'brian@snowschoolers.com', subject: "New Beta User - #{@beta_user.email}.")
  end

  def notify_sumo_success(email="Unknown Sumo User")
      @email = email
      mail(to: 'brian@snowschoolers.com', subject: "Sumo Success - #{@email} has subscribed.")
  end

  def notify_resort_referral(resort,user)
      @resort = resort
      @user = user
      mail(to: 'brian@snowschoolers.com', subject: "#{@user} has clicked thru from GB to #{@resort}")
  end

  def notify_tahoedaves_referral
      mail(to: 'brian@snowschoolers.com', subject: "Tahoe Daves's referral click-thru")
  end

  def notify_beginner_concierge(beta_user)
      @beta_user = beta_user
      mail(to: 'brian@snowschoolers.com', subject: "Concierge request - #{@beta_user.email}.")
  end

  def notify_admin_sms_logs(lesson,recipient,body)
      @lesson = lesson
      @recipient = recipient
      @body = body
      mail(to: 'brian@snowschoolers.com', subject: "SMS sent to #{@recipient}")
  end

  def send_admin_notify_invalid_phone_number(lesson)
      @lesson = lesson
      mail(to: 'brian@snowschoolers.com', subject: "Alert - Failed to send SMSto #{@lesson.phone_number}")
  end

  def application_begun(email="Unknown user",first_name="John", last_name="Doe")
      @email = email
      @name = first_name + last_name
      mail(to: 'brian@snowschoolers.com', subject: "Application begun - #{email} has entered their email.")
  end

  def new_user_signed_up(user)
    @user = user
    mail(to: 'brian@snowschoolers.com', subject: "A new user has registered for Granlibakken Lessons")
  end

  def new_instructor_application_received(instructor)
    @instructor = instructor
    mail(to: 'brian@snowschoolers.com', subject: "Submitted Application: #{@instructor.username} has applied to join Granlibakken")
  end

  def send_new_instructor_application_confirmation(instructor)
    @instructor = instructor
    mail(to: @instructor.username, cc: 'brian@snowschoolers.com', subject: "Thanks for applying to Granlibakken -- please schedule your interview!")
  end

  def new_homewood_application_received(applicant)
    @applicant = applicant
    mail(to: 'brian+marc@snowschoolers.com', cc:'brian@snowschoolers.com', subject: "Submitted Application: #{@applicant.email} has applied to join Homewood")
  end

  def new_review_submitted(review)
    @review = review
    mail(to: 'brian@snowschoolers.com', cc: "Chris Parson <#{ENV['SUPERVISOR_EMAIL']}>", subject: "Review submitted: #{@review.reviewer.email} has provided their review")
  end

  def instructor_status_activated(instructor)
    @instructor = instructor
    mail(to: @instructor.user.email, cc: 'brian@snowschoolers.com', subject: "Instructor status is now Active!")
  end

  def subscriber_sign_up(beta_user)
    @beta_user = beta_user
    mail(to: 'brian@snowschoolers.com', subject: "Someone has subscribed to the Granlibakken mailing list")
  end

  def send_lesson_request_to_instructors(lesson, excluded_instructor=nil)
    @lesson = lesson
    available_instructors = (lesson.available_instructors - [excluded_instructor])
    @available_instructors = []
    #select only the first instructor in the array that is available to email.
    # instructors_to_email = available_instructors[0...1]
    available_instructors.each do |instructor|
      @available_instructors << instructor.user.email
    end
    puts "!!!available instructors to email are: #{@available_instructors}"
    mail(to: 'notify@snowschoolers.com', bcc: @available_instructors, subject: "You have a new Granlibakken lesson request on #{@lesson.date.strftime("%b %-d")}")
  end

  def send_lesson_request_to_new_instructors(lesson, excluded_instructor=nil)
    @lesson = lesson
    available_instructors = (lesson.available_instructors - [excluded_instructor])
    @available_instructors = []
    available_instructors.each do |instructor|
      @available_instructors << instructor.user.email
    end
    mail(to: 'notify@snowschoolers.com', bcc: @available_instructors, subject: 'A previous instructor canceled - can you help with this lesson request?')
  end

  # notification when instructor cancels
  def send_cancellation_confirmation(lesson)
    @lesson = lesson
    mail(to: @lesson.instructor.user.email, cc:'notify@snowschoolers.com', subject: 'You have canceled your Granlibakken lesson')
  end

  def send_lesson_confirmation(lesson)
    @lesson = lesson
    if @lesson.guest_email.nil?
      mail(to: @lesson.requester.email, cc:'notify@snowschoolers.com', bcc:@lesson.instructor.user.email, subject: "Your Granlibakken lesson on #{@lesson.date.strftime("%b %-d")} with #{@lesson.instructor.name} is confirmed!")
    else
      mail(to: @lesson.guest_email, cc:'notify@snowschoolers.com', bcc:@lesson.instructor.user.email, subject: "Your Granlibakken lesson on #{@lesson.date.strftime("%b %-d")} with #{@lesson.instructor.name} is confirmed!")
    end
  end

  def send_lesson_booking_notification(lesson)
    @lesson = lesson
    if @lesson.requester && lesson.requester.email
      mail(to: @lesson.requester.email, cc:"Chris Parson <#{ENV['SUPERVISOR_EMAIL']}>", subject: "Thanks for reserving your Group Lesson at Granlibakken on #{@lesson.date.strftime("%b %-d")}")
    elsif @lesson.guest_email
      mail(to: @lesson.guest_email, bcc:"Chris Parson <#{ENV['SUPERVISOR_EMAIL']}>", subject: "Thanks for reserving your Group Lesson at Granlibakken on #{@lesson.date.strftime("%b %-d")}")
    end
  end

  def send_lesson_update_notice_to_instructor(original_lesson, updated_lesson, changed_attributes)
    @original_lesson = original_lesson
    @updated_lesson = updated_lesson
    @changed_attributes = changed_attributes
    mail(to: @updated_lesson.instructor.user.email, cc:'notify@snowschoolers.com', subject: 'One of your Granlibakken lesson has been updated')
  end

  # notification when client cancels
  def send_cancellation_email_to_instructor(lesson)
    @lesson = lesson
    mail(to: @lesson.instructor.user.email, cc:'notify@snowschoolers.com', bcc: @lesson.requester.email, subject: 'One of your Granlibakken lessons has been canceled')
  end

  def inform_requester_of_instructor_cancellation(lesson, available_instructors)
    @lesson = lesson
    @available_instructors = available_instructors
    mail(to: @lesson.requester.email, cc:'notify@snowschoolers.com', subject: 'Your Granlibakken lesson has been canceled')
  end

  def send_payment_email_to_requester(lesson)
    @lesson = lesson
    if @lesson.guest_email.nil?
      mail(to: @lesson.requester.email, cc:'notify@snowschoolers.com', subject: 'Please complete your Granlibakken online experience!')
    else
      mail(to: @lesson.guest_email, cc:'notify@snowschoolers.com', subject: 'Please complete your Granlibakken online experience!')
    end
  end
end
