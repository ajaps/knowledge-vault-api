module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :authenticate_request!, only: [:create]
      
      def create
        @user = User.new(user_params)
        
        if @user.save
          render json: user_response(@user), status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def me
        render json: user_response(current_user)
      end
      
      def regenerate_owner_api_key
        return unless require_owner_key!
        
        current_user.regenerate_owner_api_key!
        render json: user_response(current_user)
      end
      
      def create_shared_key
        return unless require_owner_key!
        
        shared_key = current_user.create_shared_key(name: params[:name])
        
        render json: {
          id: shared_key.id,
          key: shared_key.key,
          active: shared_key.active,
          created_at: shared_key.created_at
        }, status: :created
      end
      
      def shared_keys
        return unless require_owner_key!
        
        keys = current_user.shared_api_keys.order(created_at: :desc)
        
        render json: keys.map { |k| 
          {
            id: k.id,
            key: k.key,
            active: k.active,
            last_used_at: k.last_used_at,
            created_at: k.created_at
          }
        }
      end
      
      def deactivate_shared_key
        return unless require_owner_key!
        
        shared_key = current_user.shared_api_keys.find(params[:id])
        shared_key.deactivate!
        
        head :no_content
      end
      
      private
      
      def user_params
        params.require(:user).permit(:email, :name)
      end
      
      def user_response(user)
        ownerish = owner_key? != false  # true for true or nil

        response = {
          id:         user.id,
          email:      user.email,
          name:       user.name,
          created_at: user.created_at,
          key_type:   ownerish ? 'owner' : 'shared',
          owner_api_key: (user.owner_api_key if ownerish)
        }.compact
      end
    end
  end
end