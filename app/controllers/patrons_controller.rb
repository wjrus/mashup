class PatronsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_patron, only: %i[show edit update]

  def index
    @patrons = Patron.includes(:contacts).order(:name)
  end

  def show
    @bookings = @patron.bookings.recent_first.limit(20)
  end

  def new
    @patron = Patron.new
    2.times { @patron.contacts.build }
  end

  def edit
    @patron.contacts.build if @patron.contacts.empty?
  end

  def create
    @patron = Patron.new(patron_params)
    if @patron.save
      redirect_to @patron, notice: "Patron created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @patron.update(patron_params)
      redirect_to @patron, notice: "Patron updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_patron
    @patron = Patron.find(params[:id])
  end

  def patron_params
    params.require(:patron).permit(
      :name, :patron_type, :status, :email, :phone, :website,
      :address_line1, :address_line2, :city, :state, :postal_code, :notes,
      contacts_attributes: [ :id, :first_name, :last_name, :title, :email, :phone, :primary_contact, :billing_contact, :notes, :_destroy ]
    )
  end
end
