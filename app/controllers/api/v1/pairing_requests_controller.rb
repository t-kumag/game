class Api::V1::PairingRequestsController < ApplicationController
  before_action :authenticate

  def generate_pairing_token

    puts "current_user =========="
    p @current_user

    puts "generate_pairing_token=========="
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
    @pairing_request = Entities::PairingRequest.create({
      from_user_id: @current_user.id,
      group_id: pg.group_id,
      token: token,
      status: 1 # TODO
    })
    render 'generate_pairing_token', formats: 'json', handlers: 'jbuilder', status: 200
  end

  def receive_pairing_request    

    puts "receive_pairing_request =========="
    p params[:pairing_token]
    @pairing_request = Entities::PairingRequest.find_by(
      token: params[:pairing_token],
      status: 1 # TODO
    )    
    unless @pairing_request
      # error
      puts "receive_pairing_request error =========="
      return
    end
    @pairing_request.to_user_id = @current_user.id
    @pairing_request.status = 2
    @pairing_request.save!
    render json: {}, status: 200
    # render 'receive_pairing_request', formats: 'json', handlers: 'jbuilder', status: 200
  end

  def confirm_pairing_request
    ## TODO: アクティブなものが1件しかない前提だが良いか
    @pairing_request = Entities::PairingRequest.find_by(
      from_user_id: @current_user.id,
      status: 2 # TODO
    )
    unless @pairing_request
      # error
      puts "confirm_pairing_request error =========="
      return
    end
    @pairing_request.status = 3
    @pairing_request.save!

    pg = ParticipateGroup({
      group_id: @current_user.group.id,
      user_id: @pairing_request.to_user_id
    })
    pg.save!

    render json: {}, status: 200
    # render 'confirm_pairing_request', formats: 'json', handlers: 'jbuilder', status: 200
  end


end
