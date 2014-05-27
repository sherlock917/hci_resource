class Item
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String  # name of the file uploaded
  field :type, type: String  # type of the file, eg. pdf,doc
  field :cate, type: String  # category of the file, eg. Ruby,iOS
  field :size, type: String  # size of the file
  field :info, type: String  # the describtion for the file
  field :url, type: String   # the qiniu url for the file
  field :qiniu_key, type: String  # the key of the file that qiniu returns
  field :download_count, type: Integer, default: 0

end
