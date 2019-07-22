class Api::V1::PairingRequestsController < ApplicationController
  before_action :authenticate

  def generate_pairing_token

    puts "current_user =========="
    p @current_user

    puts "generate_pairing_token=========="
    #TODO トランザクション処理
    pg = Entities::ParticipateGroup.find_by({user_id: @current_user.id})
    unless pg
      puts "generate_pairing_token  new pg =========="
      g = Entities::Group.create
      pg = Entities::ParticipateGroup.create({
        group_id: g.id,
        user_id: @current_user.id
      })  
    end

    salt = "2dhp2fw5gra4aks"
    time = DateTime.now
    token = Digest::SHA256.hexdigest(pg.group_id.to_s + time.to_s + salt)
    @pairing_request = Entities::PairingRequest.create!({
      from_user_id: @current_user.id,
      group_id: pg.group_id,
      token: token,
      token_expires_at: DateTime.now + 7,
      status: 1 # TODO
    })
    render 'generate_pairing_token', formats: 'json', handlers: 'jbuilder', status: 200
  end

  def receive_pairing_request    

    puts "receive_pairing_request =========="
    p params[:pairing_token]
    #TODO トランザクション処理
    begin
      @pairing_request = Entities::PairingRequest.find_by(
        token: params[:pairing_token],
        status: 1 # TODO
      )
      unless @pairing_request
        # error
        puts "receive_pairing_request error =========="
        return render json: { errors: { code: '', message: "paring user already exists" } }, status: 422
      end

      return render json: { errors: { code: '', message: "paring user not found or invalid token." } }, status: 422  if DateTime.now > @pairing_request.token_expires_at
      return render json: { errors: { code: '', message: "same user" } }, status: 422  if @pairing_request.from_user_id ==  @current_user.id

      @pairing_request.to_user_id = @current_user.id
      @pairing_request.status = 2
      @pairing_request.save!

      Entities::ParticipateGroup.create!({
        group_id: @pairing_request.group_id,
        user_id: @current_user.id
      })

      render json: {}, status: 200
    end
    # render 'receive_pairing_request', formats: 'json', handlers: 'jbuilder', status: 200
  end

  def destroy
    Services::ParingService.new(@current_user).cancel
    render json: {}, status: 200
  end

end
