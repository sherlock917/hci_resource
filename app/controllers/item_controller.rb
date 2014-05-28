class ItemController < ApplicationController

  def index
    @items = Item.all.desc(:created_at)
  end

  def create
    @item = Item.new(params.permit(:name,:type,:cate,:size,:info,:url,:qiniu_key))
    @item.save
  end

  def update
    @item = Item.find(params[:id])
    @item.update_attributes(params.permit(:download_count))
  end

  # def destroy
  #   @item = Item.find(params[:id])
  #   code, result, response_headers = Qiniu::Storage.delete('scauhci', @item.qiniu_key)
  #   @item.destroy
  # end

  def cate
    @items = Item.all.where(cate: params[:cate]).desc(:created_at)
    render "index"
  end

end
