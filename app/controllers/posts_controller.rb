class PostsController < ApplicationController
    before_action :find_post, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!, except: [:index,:show]
    before_action :set_ranking, only: [:show,:index]

    def index
        @posts = Post.all.order("created_at DESC")

    end

    def show
        # @post = Post.find(params[:id])
        #showページにいく度に@post.idに１を追加
        REDIS.zincrby "posts", 1, @post.id
    end

    def set_ranking
        #idをscore付きでランキング順に取得
        @id_with_scores = REDIS.zrevrangebyscore("posts", "+inf", 0, withscores: true)
        #@id_with_scoresは二次元破裂なので、ハッシュ化
        @id_with_hash = Hash[*@id_with_scores.flatten]
        # #whereで取得する値はsort済みではないので、sort_byでsortする。@id_with_hash.keysでkeyだけ取得
        @ranking_posts = Post.where(id: @id_with_hash.keys).sort_by{ |ranking_post| @id_with_hash.keys.index(ranking_post.id.to_s) }

        #id(key)だけをランキング順に取得
        # @id_only = REDIS.zrevrangebyscore "posts", "+inf", 0

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
