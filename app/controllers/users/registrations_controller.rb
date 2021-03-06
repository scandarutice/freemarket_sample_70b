# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
   before_action :configure_sign_up_params, only: [:create]
  #  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
   def new
    @user = User.new
   end

  # POST /resource
   def new_address
    @user = User.new(sign_up_params)
    unless @user.valid?
      render :new and return
    end
    session["devise.regist_data"] = {user: @user.attributes}
    session["devise.regist_data"][:user]["password"] = params[:user][:password]
    @address = @user.build_address
    render :new_address
   end

  def new_profile
    @user = User.new(session["devise.regist_data"]["user"])
    @address = Address.new(address_params)
    unless @address.valid?
      render :new_address and return
    end
    session["devise.regist_data"]["address"] = @address.attributes
    @profile = @user.build_profile
  end

  def create
    @user = User.new(session["devise.regist_data"]["user"])
    @address = Address.new(session["devise.regist_data"]["address"])
    @profile = Profile.new(profile_params)
    unless @profile.valid?
      render :new_profile and return
    end
    @user.build_profile(@profile.attributes)
    @user.build_address(@address.attributes)
    @user.save
    sign_in(:user, @user)
    redirect_to root_path
  end

  # GET /resource/edit
  #  def edit
  #    super
  #  end

  # PUT /resource
  #  def update
  #    super
  #  end

  # DELETE /resource
  #  def destroy
  #    super
  #  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  #  def cancel
  #    super
  #  end

   protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  end
  
  def address_params
    params.require(:address).permit(:family_name, :family_name_kana, :first_name, :first_name_kana, :zip_cord, :city, :address, :building, :tel_number)
  end

  def profile_params
    params.require(:profile).permit(:family_name, :family_name_kana, :first_name, :first_name_kana, :birth_year, :birth_month, :birth_day)
  end


  # If you have extra params to permit, append them to the sanitizer.
  #  def configure_account_update_params
  #    devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  #  end

  # The path used after sign up.
  #  def after_sign_up_path_for(resource)
  #    super(resource)
  #  end

  # The path used after sign up for inactive accounts.
  #  def after_inactive_sign_up_path_for(resource)
  #    super(resource)
  #  end

   private

end
