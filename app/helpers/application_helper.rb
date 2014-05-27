module ApplicationHelper

  def qiniu_token_tag
    put_policy = Qiniu::Auth::PutPolicy.new('scauhci')
    token = Qiniu::Auth.generate_uptoken(put_policy)
    tag :meta, content: token, name: 'qiniu-token'
  end

end
