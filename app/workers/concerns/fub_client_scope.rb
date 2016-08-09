module FubClientScope
  extend ActiveSupport::Concern

  included do
    # @return [Fub::User]
    attr_accessor :fub_user

    def user_company_slug
      @user_company_slug ||=
        "#{self.fub_user.email} - " + self.fub_user.default_company.name
    end

  end
end
