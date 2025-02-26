module API
  module V1
    class UsersController < APIController
      def show
        @user = User.find(params[:id])

        render json: @user, serializer: UserSerializer
      end

      def steam_id
        @user = User.find_by!(steam_id: params[:id])

        render json: @user, serializer: UserSerializer
      end

      def bans
        @user = User.find(params[:id])

        @ban_models = User.ban_models.map do |_action, bans|
          bans.map do |_subject, model|
            next if model.subject?

            model
          end
        end.reduce(:+).compact.sort_by(&:association_name)
        @bans = @ban_models.map { |model| model.where(user: @user).to_a }.reduce(:+).sort_by(&:created_at)
        @new_bans = @ban_models.map(&:new)

        render json: @bans, each_serializer: BanSerializer
      end
    end
  end
end
