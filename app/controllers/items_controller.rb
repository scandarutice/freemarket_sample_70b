class ItemsController < ApplicationController
  require 'payjp'
  before_action :move_to_session, except: [:index, :show]
  before_action :card_registration, only: [:confirm, :pay]

  def index
  end

  def show
    @item = Item.find(1)
  end

  def confirm
    @item = Item.find(params[:id])
  end

  def pay
    @item = Item.find(params[:id])

    Payjp.api_key = ENV['PAYJP_PRIVATE_KEY']
    Payjp::Charge.create(
      amount: @item.price, 
      card: params['payjp-token'], 
      currency: 'jpy'
    )
    @item.update(seller_id: current_user.id)
    redirect_to action: 'done' #完了画面に移動
  end

  def done
    @item = Item.find(params[:id])
  end

  def new
    @item = Item.new
    @item.item_images.new
    @category = Category.where(ancestry: nil).limit(13)
  end

  def create
    @item = Item.new(item_params)
    if  @item.save
      redirect_to root_path
    else
      flash[:alert] = '出品に失敗しました。必須項目を確認してください。'
      redirect_to new_item_path
    end
  end

  def category_children  
    @category_children = Category.find(params[:productcategory]).children 
  end


  def category_grandchildren
    @category_grandchildren = Category.find(params[:productcategory]).children
  end

  private
  def move_to_session
    redirect_to "/users/sign_in" unless user_signed_in?
  end

  def card_registration
    @card = Card.where(user_id: current_user.id).first if Card.where(user_id: current_user.id).present?
  end

  def item_params
    params.require(:item).permit(:name, :detail, :price,:category_id, :brand,:size,:day_id,:postage_id,:prefecture_id,:condition,item_images_attributes:[:id, :image, :_destroy]).merge(seller_id: current_user.id)
  end

end
