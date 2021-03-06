# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :set_post, only: %i[edit update destroy]
  before_action :authenticate_user!, only: %i[new edit create update destroy]

  def index
    @posts = Post.all
  end

  def show
    @post = Post.find_by(id: params[:id])
    @comment = Comment.new
  end

  def new
    @post = Post.new
  end

  def edit
    @post = Post.find_by(id: params[:id])
  end

  def create
    @post = Post.new(post_params)
    respond_to do |format|
      if @post.save
        format.html do
          redirect_to @post, notice: 'Post was successfully created.'
        end
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html do
          redirect_to @post, notice: 'Post was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post.destroy
    respond_to do |format|
      format.html do
        redirect_to posts_url,
                    notice: 'Post was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  def set_post
    @post = Post.find_by(id: params[:id], user: current_user)
  end

  def post_params
    params.require(:post)
          .permit(:title, :content)
          .merge(user_id: current_user.id)
  end
end
