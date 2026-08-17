class Admin::SpacesController < Admin::BaseController
  before_action :set_space, only: %i[edit update]

  def index
    @spaces = Space.order(:name)
  end

  def new
    @space = Space.new(active: true)
  end

  def create
    @space = Space.new(space_params)

    if @space.save
      redirect_to admin_spaces_path, notice: "Space created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @space.update(space_params)
      redirect_to admin_spaces_path, notice: "Space updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_space
    @space = Space.find(params[:id])
  end

  def space_params
    params.require(:space).permit(:name, :capacity, :description, :active)
  end
end
