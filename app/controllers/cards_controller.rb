class CardsController < ApplicationController
  require "payjp"

  # before_action :set_card, only: [:new, :delete, :show]
  # before_action :get_payjp_info, only: [:pay, :delete, :show]


  def new
    card = Card.where(user_id: current_user.id).first
    redirect_to "/cards/:id" if card.present?
  end


  def create 
    Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
    if params['payjp-token'].blank?
      redirect_to action: "new"
    else
      customer = Payjp::Customer.create(
        email: current_user.email,
        card: params['payjp-token'],
        metadata: {user_id: current_user.id}
      )
      @card = Card.new(user_id: current_user.id, customer_id: customer.id, card_id: customer.default_card)
      if @card.save
        redirect_to "/cards/:id"
      else
        redirect_to action: "create"
      end
    end
  end


  def delete
    card = Card.where(user_id: current_user.id).first
    if card.blank?
      redirect_to action: "new" 
    else
      Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
      customer = Payjp::Customer.retrieve(card.customer_id)
      customer.delete
      card.delete
    end
      redirect_to action: "/cards/:id"
  end


  def show
    card = Card.where(user_id: current_user.id).first

    if card.blank?
      redirect_to action: "new" 
    else
      Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
      customer = Payjp::Customer.retrieve(card.customer_id)
      @default_card_information = customer.cards.retrieve(card.card_id)
    end
  end

  # private


  # def set_card
  #   card = Card.where(user_id: current_user.id).first
  # end

  # def get_payjp_info
  #   Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
  # end

end
