class UpostsController < ApplicationController
before_action :authenticate_user!, except: [:index, :show]
before_action :check_ownership, only: [:edit, :update, :destroy]
before_action :log_impression, :only=> [:show]

   def log_impression
      @hit_post = Upost.find(params[:id])
      # this assumes you have a current_user method in your authentication system
      @hit_post.impressions.create(ip_address: request.remote_ip)
   end

  def index
    @notice = adminposts.order('created_at DESC').first
    if params[:category]
     @posts = Upost.where(:category => params[:category]).order('created_at DESC').paginate(:page => params[:page])
    else
      if params[:search]
        if params[:selecto]=="1"
        @posts = Upost.search1(params[:search]).order("created_at DESC").paginate(:page => params[:page])
        elsif params[:selecto]=="2"
        @posts = Upost.search2(params[:search]).order("created_at DESC").paginate(:page => params[:page])
        elsif params[:selecto]=="3"
        @posts = Upost.search3(params[:search]).order("created_at DESC").paginate(:page => params[:page])
        elsif params[:selecto]=="4"
        @users = User.search4(params[:search])
        end
      else
       @posts = Upost.order('created_at DESC').paginate(:page => params[:page])
      end
    end
  end

  def create
      new_post = Upost.new(user_id: current_user.id, title: params[:title], content: params[:content], image: params[:image], category: params[:category])
      if new_post.save
        redirect_to upost_path(new_post.id)
      else
        redirect_to new_upost_path
      end
  end

  def new
  end

  def edit
  end

  def show
    @adminpost = Admimpost.find_by(id: params[:id])
    @post = Upost.find_by(id: params[:id])
  end

  def update

      @post.title = params[:title]
      @post.content = params[:content]
      @post.category = params[:category]
      @post.image   = params[:image] if params[:image].present?

      if @post.save
          redirect_to upost_path
      else
          render :edit
      end
  end

  def destroy
     @post.destroy
     redirect_to uposts_path
  end


  def check_ownership
      @post = Upost.find_by(id: params[:id])
      redirect_to uposts_path if @post.user.id != current_user.id
  end
end
