class PostsController < ApplicationController
    before_action :find_post, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!, except: [:index,:show]

    def index
        @posts = Post.all.order("created_at DESC")
    end

    def show
    end


    def new
        @post = current_user.posts.build
    end

    def create
        @post = current_user.posts.build(post_params)

        if @post.save
            redirect_to @post
        else
            render "new"
        end
    end

    def edit
    end

    def update
        if @post.update(post_params)
            redirect_to @post
        else
            render "edit"
        end
    end

    def destroy
        @post.destroy
        redirect_to root_path
    end

    private

    def find_post
        #自分のコントローラー内のものを見つける時はparams[:id]、自分のコントローラーに無い時(ex:userコントローラー)はparams[:user_id]で参照
        @post = Post.find(params[:id])
    end

    def post_params
        params.require(:post).permit(:title,:link,:description)
    end

end
