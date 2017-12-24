Rails.application.routes.draw do

  get 'ghost_click' => 'welcome#ghost_click'
  resources :shifts
  resources :product_calendars
  resources :selfies
  resources :contestants
  resources :applicants
  get 'apply-to-homewood' => 'applicants#apply'

  resources :sports

  resources :blogs
  get 'blog' => 'blogs#index'
  resources :pre_season_location_requests

  # mount ActionCable.server => '/cable'
  resources :messages
  get 'start_conversation/:instructor_id' => 'messages#start_conversation'
  get 'conversations/:id' => 'messages#show_conversation', as: :show_conversation
  get 'my_conversations' => 'messages#my_conversations', as: :conversations

  resources :reviews

  resources :snowboard_levels

  resources :ski_levels

  resources :products do
    collection {post :import}
    collection {post :delete_all}
  end

  resources :calendar_blocks
  post 'calendar_blocks/create_10_week_recurring_block' => 'calendar_blocks#create_10_week_recurring_block', as: :create_10_week_recurring_block

  # mount Ckeditor::Engine => '/ckeditor'
  resources :lesson_actions

  resources :transactions do
    member do
      post :charge_lesson
    end
  end

  resources :locations do 
        collection {post :import}
  end
  resources :charges

  # root to: "lessons#new"
  root to: "welcome#index"

  #backup index
  get 'winter' => 'welcome#index_backup_may2017'

  #twilio testing
  get 'twilio/test_sms' => 'twilio#test_sms'
  #promo pages
  get 'jackson-hole' => "welcome#jackson_hole"
  get 'powder' => "welcome#powder"
  get 'road-conditions' => "welcome#road_conditions"
  get 'accommodations' => "welcome#accommodations"
  get 'resorts' => "welcome#resorts"
  get 'beginners-guide-to-tahoe' => "welcome#beginners_guide_to_tahoe"
  get 'learn-to-ski' => "welcome#learn_to_ski_packages"
  get 'learn-to-ski-packages' => "products#learn_to_ski_packages_search_results", as: :lts_search_results
  get 'private-lessons' => "products#private_lessons_search_results", as: :private_lessons_search_results
  get 'lift-tickets' => "products#lift_tickets_search_results", as: :lift_tickets_search_results
  get 'search' => 'products#search'
  get 'tahoe-season-passes' => 'products#pass_search_results'
  get 'tahoe-season-passes-search-results' => 'products#pass_search_results', as: :pass_search_results
  get 'search-results' => 'products#search_results', as: :search_results   
  get 'filtered-schedule-results' => 'lessons#filtered_schedule_results', as: :filtered_schedule_results 

  get   'lessons/sugarbowl'               => 'lessons#sugarbowl'
  # get 'homewood' => "welcome#homewood"
  get 'homewood2' => "welcome#homewood2"
  get   'lessons/homewood'               => 'lessons#homewood'
  #landing page for prospective instructors
  get 'apply' => 'welcome#apply'
  get 'index' => 'welcome#index'
  get 'about_us' => 'welcome#about_us'
  get 'launch_announcement' => 'welcome#launch_announcement'
  get 'privacy' => 'welcome#privacy'
  get 'terms_of_service' => 'welcome#terms_of_service'
  get 'new_hire_packet' => 'welcome#new_hire_packet'
  get 'recommended_accomodations' => 'welcome#recommended_accomodations'
  get '/thanks-for-applying' => 'instructors#thank_you'
  post '/notify_admin' => 'welcome#notify_admin'
  post 'sumo_success' => 'welcome#sumo_success'
  get '/tahoe-daves' => 'welcome#tahoedaves_referral'

  get '/snowschoolers' => 'welcome#snow_schoolers_referral'

  #Avantlink site verification
  get '/avantlink_confirmation.txt' => 'welcome#avantlink'


  resources :instructors do
    member do
        post :verify
        post :revoke
        get :show_candidate
      end
  end
  get '/admin_index' => 'instructors#admin_index'
  get 'lessons/admin_index' => 'lessons#admin_index', as: :lessons_admin_index
  get 'lessons/admin_index_all' => 'lessons#admin_index_all', as: :lessons_admin_index_all
  get 'browse' => 'instructors#browse'
  get 'lessons/book_product/:id' => 'lessons#book_product'
  # post 'search_results' => 'products#search_results', as: :refresh_search_results

  resources :beta_users
  resources :lesson_times
  devise_for :users, controllers: { registrations: 'users/registrations', confirmations: 'users/registrations', omniauth_callbacks: "users/omniauth_callbacks" }

  #snowschoolers admin views
  get 'admin_users' => 'welcome#admin_users'
  get 'admin_edit/:id' => 'welcome#admin_edit', as: :admin_edit_user
  get 'users/:id' => 'welcome#admin_show_user', as: :user
  put 'users/:id' => 'welcome#admin_update_user'
  patch 'users/:id' => 'welcome#admin_update_user'
  delete 'users/:id' => 'welcome#admin_destroy', as: :admin_destroy

  #Snowschoolers as a Service scheduling views
  # get 'schedule' => 'lessons#schedule'  
  get 'assign_all_instructors_to_sections' => 'lessons#assign_all_instructors_to_sections'
  get 'schedule' => 'lessons#lesson_schedule_results'
  get 'schedule-filtered' => 'lessons#lesson_schedule_results', as: :lesson_schedule_results
  # put 'lessons/:id/assign-to-section/:section_id' => 'lessons#assign_to_section', as: :assign_section
  put 'lessons/assign-to-section' => 'lessons#assign_to_section', as: :assign_section
  put 'sections/assign-instructor-to-section' => 'sections#assign_instructor_to_section', as: :assign_instructor_to_section



  resources :sections do 
    member do
      post :duplicate
      delete :remove
      delete :destroy
    end
  end
  get 'lessons-availability' => 'sections#available_lessons', as: :available_lessons
  post 'sections/generate_all_sections' => 'sections#generate_all_sections', as: :generate_all_sections
  post 'sections/generate_new_sections' => 'sections#generate_new_sections', as: :generate_new_sections
  post 'sections/delete_all_sections_and_lessons' => 'sections#delete_all_sections_and_lessons', as: :delete_all_sections_and_lessons
  post 'sections/:id/duplicate_ski_section' => 'sections#duplicate_ski_section', as: :duplicate_ski_section
  post 'sections/:id/duplicate_snowboard_section' => 'sections#duplicate_snowboard_section', as: :duplicate_snowboard_section
  post 'seed_lessons_with_students' => 'sections#fill_sections_with_lessons', as: :seed_lessons_with_students
  post 'delete_all_lessons' => 'sections#delete_all_lessons', as: :delete_all_lessons

  get   'lessons/new2' => 'lessons#new_backup_oct22'
  resources :lessons
  # get 'new_request' => 'lessons#new_request'
  get 'new_request/:id' => 'lessons#new_request'
  get 'book-a-lesson/new' => 'lessons#new_specific_slot', as: :new_specific_slot
  put   'lessons/:id/set_instructor'      => 'lessons#set_instructor',      as: :set_instructor
  put   'lessons/:id/admin_reconfirm_state'      => 'lessons#admin_reconfirm_state',      as: :admin_reconfirm_state
  put   'lessons/:id/decline_instructor'      => 'lessons#decline_instructor',      as: :decline_instructor
  put   'lessons/:id/remove_instructor'   => 'lessons#remove_instructor',   as: :remove_instructor
  put   'lessons/:id/mark_lesson_complete'   => 'lessons#mark_lesson_complete',   as: :mark_lesson_complete
  patch 'lessons/:id/confirm_lesson_time' => 'lessons#confirm_lesson_time', as: :confirm_lesson_time
  get   'lessons/:id/complete'            => 'lessons#complete',            as: :complete_lesson
  get   'lessons/:id/send_reminder_sms_to_instructor' => 'lessons#send_reminder_sms_to_instructor',  as: :send_reminder_sms_to_instructor
  post 'lessons/:id/confirm_reservation'              => 'lessons#confirm_reservation', as: :confirm_reservation
  put 'lessons/:id/issue_refund'              => 'lessons#issue_refund', as: :issue_refund
  post 'lessons/:id/issue_full_refund'              => 'lessons#issue_full_refund', as: :issue_full_refund
  put 'lessons/:id/reissue_invoice'              => 'lessons#reissue_invoice', as: :reissue_invoice
  get 'filtered-lesson-reservations' => 'lessons#filtered_lesson_reservations', as: :filtered_lesson_reservations 

  unless Rails.application.config.consider_all_requests_local
    # having created corresponding controller and action
    # get '*path', to: 'application#houston_we_have_500_routing_problems', via: :all
  end

end
