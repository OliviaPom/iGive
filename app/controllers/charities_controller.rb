class CharitiesController < ApplicationController

  def index
    @charities = charities.all
  end

  def show
  @charity = Charity.new
  @charity = Charity.find(params[:id])
  end

  def new
    @charity = Charity.new
  end

  def create
    @charity = Charity.new(charity_params)
    @charity.user = current_user
    if @charity.save
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    @charity = Charity.find(params[:id])
  end

  def update
    if current_user.charity.update(charity_params)
      redirect_to dashboard_path
    else
      render :edit
    end
  end

  private

  def charity_params
    params.require(:charity).permit(:user_id, :name, :phone_number, :description, :website)
  end
end
