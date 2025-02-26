module API
  module V1
    class BanSerializer < ActiveModel::Serializer
      type :ban

      attributes :id, :created_at, :terminated_at
      attribute(:type) { object.class.subject }
    end
  end
end
