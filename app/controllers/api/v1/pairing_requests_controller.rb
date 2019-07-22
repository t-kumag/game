class Api::V1::PairingRequestsController < ApplicationController
  before_action :authenticate

  def generate_pairing_token

    salt = Settings.pairing_token_salt
    time = DateTime.now
    token = Digest::SHA256.hexdigest(@current_user.id.to_s + time.to_s + salt)
    @pairing_request = Entities::PairingRequest.create!({
      from_user_id: @current_user.id,
      token: token,
      token_expires_at: DateTime.now + 7,
      status: 1
    })
    render 'generate_pairing_token', formats: 'json', handlers: 'jbuilder', status: 200
  end

  def receive_pairing_request    

    puts "receive_pairing_request =========="
    p params[:pairing_token]

    begin
      ActiveRecord::Base.transaction do
        @pairing_request = Entities::PairingRequest.find_by(
          token: params[:pairing_token],
          status: 1
        )
        unless @pairing_request
          return render json: { errors: { code: '', message: "pairing token not found." } }
        end

        return render json: { errors: { code: '', message: "paring user not found or invalid token." } }, status: 422  if DateTime.now > @pairing_request.token_expires_at
        return render json: { errors: { code: '', message: "paring user already exists" } }, status: 422  if @pairing_request.status.to_i == 2
        return render json: { errors: { code: '', message: "same user" } }, status: 422  if @pairing_request.from_user_id ==  @current_user.id

        @pairing_request.to_user_id = @current_user.id
        @pairing_request.status = 2
        @pairing_request.save!

        from_user_group = Entities::ParticipateGroup.find_by({user_id: [@pairing_request.from_user_id]})
        return render json: { errors: { code: '', message: "from user group taken" } }, status: 422  if from_user_group.present?
        to_user_group = Entities::ParticipateGroup.find_by({user_id: [@pairing_request.to_user_id]})
        return render json: { errors: { code: '', message: "to user group taken" } }, status: 422  if to_user_group.present?

        new_group = Entities::Group.create
        Entities::ParticipateGroup.create!({
          group_id: new_group.id,
          user_id: @pairing_request.from_user_id
        })
        Entities::ParticipateGroup.create({
          group_id: new_group.id,
          user_id: @pairing_request.to_user_id
        })

        render json: {}, status: 200
      end
      rescue ActiveRecord::RecordInvalid => db_err
        raise db_err
      rescue => exception
        raise exception
    end
    # render 'receive_pairing_request', formats: 'json', handlers: 'jbuilder', status: 200
  end

  def destroy
    Services::ParingService.new(@current_user).cancel
    render json: {}, status: 200
  end

end
