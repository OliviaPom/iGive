class MissionsController < ApplicationController
  before_action :icon_count, only: [:index, :show]

  def new
    redirect_to root_path if current_user.charity.nil?
    @mission = Mission.new
  end

  def show
    @mission = Mission.find(params[:id])
    @charity = @mission.charity
    bookings = Booking.all

    if current_user.bookings.includes(:mission).where('missions.start_date < ?', Date.today).references(:mission).nil?
      @volunteer_completed_missions = []
    else
      @volunteer_completed_missions = bookings.includes(:mission).where('missions.start_date < ?', Date.today).references(:mission)
    end

    @markers = [
      {
        lat: @mission.latitude,
        image_url: helpers.asset_url('iGive-logo.png'),
        lng: @mission.longitude,
        infoWindow: render_to_string(partial: "info_window", locals: { mission: @mission })
      }]
  end

  def index
    @missions = Mission.all
    @missions = Mission.geocoded

    @markers = @missions.map do |mission|
      {
        lat: mission.latitude,
        lng: mission.longitude,
        infoWindow: render_to_string(partial: "info_window", locals: { mission: mission })
      }
    end

    if params[:query].nil? || (params[:query] == "")
      @missions = Mission.all
    elsif params[:distance].nil? || (params[:distance] == "")
      @missions = @missions.near(params[:query], 10)
    elsif params[:categories]
      @missions = @missions.filter_by_category(params[:categories])
    else
      @missions = @missions.near(params[:query], params[:distance].to_i)
    end


    if params['/missions']
      index_params
    @missions = @missions.where(category: params['/missions'][:category] )

    end
  end

  def create
    @mission = Mission.new(strong_params)
    @charity = current_user.charity
    @mission.charity = @charity
    if @mission.save
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    @mission = Mission.find(params[:id])
  end

  def update
    @mission = Mission.find(params[:id])
    if @mission.update(strong_params)
      redirect_to dashboard_path
    else
      render :edit
    end
  end

  private

  def index_params
    params['/missions'].permit(:category)
  end

  def icon_count
    accepted_volunteer_bookings = current_user.bookings.where(status: "accepted")
    @accepted_volunteer_missions = accepted_volunteer_bookings.includes(:mission).where('missions.start_date > ?', Date.today).references(:mission)
  end

  def strong_params
    params.require(:mission).permit(:start_date, :title, :description, :address, :number_of_volunteers, :category, photos: [])
  end
end
