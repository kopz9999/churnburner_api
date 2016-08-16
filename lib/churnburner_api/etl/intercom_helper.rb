module ChurnburnerApi
  module ETL
    module IntercomHelper
      include IntercomWorker


      # @param [Fub::User] fub_user
      # @return [Intercom::User]
      def setup_intercom_user(fub_user)
        begin
          intercom_user = intercom_client.users.find(email: fub_user.email)
        rescue Intercom::ResourceNotFound
          intercom_user = nil
        rescue Intercom::MultipleMatchingUsersError
          # Bug on Intercom API
          return nil
        end
        if intercom_user.nil?
          intercom_user = intercom_client.users
                            .create(email: fub_user.email,
                                    name: fub_user.name)
        end
        intercom_user
      end

      # @param [Intercom::User] intercom_user
      # @param [String] company_name
      # @return [Company]
      def setup_intercom_company(intercom_user, company_name)
        company = Company.find_by name: company_name
        if company.nil?
          begin
            intercom_company =
              self.intercom_client.companies.find(name: company_name)
          rescue Intercom::ResourceNotFound
            intercom_company = nil
          end
          company = intercom_company.nil? ?
            Company.intercom_user(intercom_user) :
            Company.intercom_company(intercom_company)
        end
        company
      end
    end
  end
end
