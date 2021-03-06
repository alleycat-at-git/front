require 'ostruct'
require 'socket'

class PostsController < ApplicationController

  POSTS_PER_PAGE = 10
  COMPLETE_TRAINING_POSTS = 50

  #before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    unless user_signed_in?
      redirect_to users_path
      return
    end
    post_models = current_user.get_top_posts(POSTS_PER_PAGE)
    ids = post_models.map(&:id)
    liked_posts = current_user.get_posts_likes(ids)
    @progress = (current_user.get_positive_likes_count.to_f * 100 / COMPLETE_TRAINING_POSTS).to_i
    @posts = post_models.map do |x|
      post = OpenStruct.new(x.attributes)
      post.vk_url = x.vk_url
      post.attachment_vk_url = x.attachment_vk_url
      post.like = liked_posts[x.id]
      if post.like.nil?
        current_user.like_post(post.id, 0)
        post.like = 0
      end
      post
    end
    update_training_model
  end

  private

  def update_training_model
    connection= Rails.application.config.selector
    begin
      socket = TCPSocket.new(connection[:host], connection[:port])
      request = "GET /train?user_id=#{current_user.id} HTTP/1.1\r\n"
      request << "\r\n"
      socket.write request
    rescue Exception=>e
      puts "Unable to connect to selector. Message: #{e.message}"
      socket.close if socket
    end
  end

=begin
  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render action: 'show', status: :created, location: @post }
      else
        format.html { render action: 'new' }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :no_content }
    end
  end
=end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def post_params
    params[:post]
  end
end
