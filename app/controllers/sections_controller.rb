class SectionsController < ApplicationController
  before_action :set_section, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:available_lessons, :show]

  def assign_instructor_to_section
    puts "the params are #{params}"
    @instructor = Instructor.find(params[:instructor_id])
    @section = Section.find(params[:section_id])
    @section.instructor_id = @instructor.id    
    days_shifts = Shift.all.to_a.keep_if {|shift| shift.start_time.to_date == @section.date}
    shift_to_update = days_shifts.keep_if { |shift| shift.instructor_id == @instructor.id}
    # @shift = shift_to_update.first
    # @shift.update(status:"Assigned")
    # @section.shift_id = @shift.id
    @section.save!
    # redirect_to "/schedule-filtered?utf8=✓&search_date=#{@section.parametized_date}&age_type=#{@section.age_group}"    
    redirect_to "/sections"
  end


  def available_lessons
    # @sections = Section.all.select{|section| section.has_capacity? }
    @ski_sections = Section.where(sport_id:1)
    @snowboard_sections = Section.where(sport_id:2)
  end

  # GET /sections
  # GET /sections.json
  def index
    @sections = Section.order(date: :asc, sport_id: :asc, slot: :asc)
  end
  # GET /sections/1
  # GET /sections/1.json
  def show
    puts "!!!!!! params are #{params}"
    session[:activity] = @section.activity
    session[:slot] = @section.slot 
    session[:date] = @section.date 
    redirect_to new_specific_slot_path
  end

  def browse_available_sections

  end

  # GET /sections/new
  def new
    @section = Section.new
  end

  # GET /sections/1/edit
  def edit
  end

  def fill_sections_with_lessons
    session[:disable_notifications] == true
    Section.fill_sections_with_lessons
    redirect_to '/lessons'
  end

  def delete_all_sections_and_lessons
    Section.delete_all
    Lesson.delete_all
    redirect_to '/lessons'
  end

  def delete_all_lessons
    Lesson.delete_all
    redirect_to '/lessons'
  end

  def generate_new_sections
    day = params[:section][:date]
    puts "!!!!!!! new section params are: #{params[:section][:date]}"
    Section.seed_sections(day)    
    session[:notice] = "Lesson sections created for specified day."
    redirect_to '/lessons'
  end

  def generate_all_sections
    Section.generate_all_sections
    session[:notice] = "Lesson sections created for all eligible days."
    redirect_to '/lessons'
  end

  def duplicate_ski_section
    section = Section.find(params[:id])
    date = section.date 
    slot = section.slot
    Section.duplicate_ski_section(date,slot)
    redirect_to '/lessons'
  end

  def duplicate_snowboard_section
    section = Section.find(params[:id])
    date = section.date 
    slot = section.slot
    Section.duplicate_snowboard_section(date,slot)
    redirect_to '/lessons'
  end

  def duplicate
    section = Section.find(params[:id])
    @section = Section.create({
        sport_id: section.sport_id,
        date: section.date,
        slot: section.slot,
        capacity: 6,
        lesson_type: 'group_lesson'
        })
      puts "!!!!new section created"
    respond_to do |format|
      if @section.save
        format.html { redirect_to "/lessons", notice: 'Section was successfully duplicated.' }
        format.json { render :show, status: :created, location: @section }
      else
        format.html { render :new }
        format.json { render json: @section.errors, status: :unprocessable_entity }
      end
    end
  end

  def remove
    section = Section.find(params[:id])
    section.destroy
    redirect_to '/lessons'
  end

  # POST /sections
  # POST /sections.json
  def create
    @section = Section.new(section_params)

    respond_to do |format|
      if @section.save
        format.html { redirect_to "/lessons", notice: 'Section was successfully created.' }
        format.json { render :show, status: :created, location: @section }
      else
        format.html { render :new }
        format.json { render json: @section.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sections/1
  # PATCH/PUT /sections/1.json
  def update
    respond_to do |format|
      if @section.update(section_params)
        format.html { redirect_to "/sections" }
        # format.html { redirect_to "/schedule-filtered?utf8=✓&search_date=#{@section.parametized_date}&age_type=#{@section.age_group}", notice: 'Section was successfully updated.' }
        format.json { render :show, status: :ok, location: @section }
      else
        format.html { render :edit }
        format.json { render json: @section.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sections/1
  # DELETE /sections/1.json
  def destroy
    @section.destroy
    respond_to do |format|
      format.html {     redirect_to "/sections", notice: 'Section was successfully destroyed.' }
      # format.html {     redirect_to "/schedule-filtered?utf8=✓&search_date=#{@section.parametized_date}&age_type=#{@section.age_group}", notice: 'Section was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_section
      @section = Section.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def section_params
      params.require(:section).permit(:age_group, :slot, :instructor_id, :status, :level, :sport_id, :capacity, :lesson_type, :date, :name, :shift_id)
    end
end
